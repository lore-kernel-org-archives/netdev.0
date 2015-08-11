From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 4/6] dlm: use sctp 1-to-1 API
Date: Tue, 11 Aug 2015 19:22:23 -0300
Message-ID: <479a4fd07289ea9043d84a27d706cccd2c968fb0.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932928AbbHKWWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:47 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DLM is using 1-to-many API but in a 1-to-1 fashion. That is, it's not
needed but this causes it to use sctp_do_peeloff() to mimic an
kernel_accept() and this causes a symbol dependency on sctp module.

By switching it to 1-to-1 API we can avoid this dependency and also
reduce quite a lot of SCTP-specific code in lowcomms.c.

The caveat is that now DLM won't always use the same src port. It will
choose a random one, just like TCP code. This allows the peers to
attempt simultaneous connections, which now are handled just like for
TCP.

Even more sharing between TCP and SCTP code on DLM is possible, but it
is intentionally left for a later commit.

Note that for using nodes with this commit, you have to have at least
the early fixes on this patchset otherwise it will trigger some issues
on old nodes.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 671 +++++++++++++++++++-----------------------------------
 1 file changed, 237 insertions(+), 434 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 54a0031067de3ae6d3cd0106d7b9d4e30c956cfd..856d750be96b64d06c48a1a4e2a68785e8dda048 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -120,12 +120,10 @@ struct connection {
 	struct cbuf cb;
 	int retries;
 #define MAX_CONNECT_RETRIES 3
-	int sctp_assoc;
 	struct hlist_node list;
 	struct connection *othercon;
 	struct work_struct rwork; /* Receive workqueue */
 	struct work_struct swork; /* Send workqueue */
-	bool try_new_addr;
 };
 #define sock2con(x) ((struct connection *)(x)->sk_user_data)
 
@@ -252,26 +250,6 @@ static struct connection *nodeid2con(int nodeid, gfp_t allocation)
 	return con;
 }
 
-/* This is a bit drastic, but only called when things go wrong */
-static struct connection *assoc2con(int assoc_id)
-{
-	int i;
-	struct connection *con;
-
-	mutex_lock(&connections_lock);
-
-	for (i = 0 ; i < CONN_HASH_SIZE; i++) {
-		hlist_for_each_entry(con, &connection_hash[i], list) {
-			if (con->sctp_assoc == assoc_id) {
-				mutex_unlock(&connections_lock);
-				return con;
-			}
-		}
-	}
-	mutex_unlock(&connections_lock);
-	return NULL;
-}
-
 static struct dlm_node_addr *find_node_addr(int nodeid)
 {
 	struct dlm_node_addr *na;
@@ -322,14 +300,14 @@ static int nodeid_to_addr(int nodeid, struct sockaddr_storage *sas_out,
 	spin_lock(&dlm_node_addrs_spin);
 	na = find_node_addr(nodeid);
 	if (na && na->addr_count) {
+		memcpy(&sas, na->addr[na->curr_addr_index],
+		       sizeof(struct sockaddr_storage));
+
 		if (try_new_addr) {
 			na->curr_addr_index++;
 			if (na->curr_addr_index == na->addr_count)
 				na->curr_addr_index = 0;
 		}
-
-		memcpy(&sas, na->addr[na->curr_addr_index ],
-			sizeof(struct sockaddr_storage));
 	}
 	spin_unlock(&dlm_node_addrs_spin);
 
@@ -459,18 +437,23 @@ static inline void lowcomms_connect_sock(struct connection *con)
 
 static void lowcomms_state_change(struct sock *sk)
 {
-	if (sk->sk_state == TCP_ESTABLISHED)
+	/* SCTP layer is not calling sk_data_ready when the connection
+	 * is done, so we catch the signal through here. Also, it
+	 * doesn't switch socket state when entering shutdown, so we
+	 * skip the write in that case.
+	 */
+	if (sk->sk_shutdown) {
+		if (sk->sk_shutdown == RCV_SHUTDOWN)
+			lowcomms_data_ready(sk);
+	} else if (sk->sk_state == TCP_ESTABLISHED) {
 		lowcomms_write_space(sk);
+	}
 }
 
 int dlm_lowcomms_connect_node(int nodeid)
 {
 	struct connection *con;
 
-	/* with sctp there's no connecting without sending */
-	if (dlm_config.ci_protocol != 0)
-		return 0;
-
 	if (nodeid == dlm_our_nodeid())
 		return 0;
 
@@ -542,264 +525,6 @@ static void close_connection(struct connection *con, bool and_other,
 	mutex_unlock(&con->sock_mutex);
 }
 
-/* We only send shutdown messages to nodes that are not part of the cluster
- * or if we get multiple connections from a node.
- */
-static void sctp_send_shutdown(sctp_assoc_t associd)
-{
-	static char outcmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
-	struct msghdr outmessage;
-	struct cmsghdr *cmsg;
-	struct sctp_sndrcvinfo *sinfo;
-	int ret;
-	struct connection *con;
-
-	con = nodeid2con(0,0);
-	BUG_ON(con == NULL);
-
-	outmessage.msg_name = NULL;
-	outmessage.msg_namelen = 0;
-	outmessage.msg_control = outcmsg;
-	outmessage.msg_controllen = sizeof(outcmsg);
-	outmessage.msg_flags = MSG_EOR;
-
-	cmsg = CMSG_FIRSTHDR(&outmessage);
-	cmsg->cmsg_level = IPPROTO_SCTP;
-	cmsg->cmsg_type = SCTP_SNDRCV;
-	cmsg->cmsg_len = CMSG_LEN(sizeof(struct sctp_sndrcvinfo));
-	outmessage.msg_controllen = cmsg->cmsg_len;
-	sinfo = CMSG_DATA(cmsg);
-	memset(sinfo, 0x00, sizeof(struct sctp_sndrcvinfo));
-
-	sinfo->sinfo_flags |= MSG_EOF;
-	sinfo->sinfo_assoc_id = associd;
-
-	ret = kernel_sendmsg(con->sock, &outmessage, NULL, 0, 0);
-
-	if (ret != 0)
-		log_print("send EOF to node failed: %d", ret);
-}
-
-static void sctp_init_failed_foreach(struct connection *con)
-{
-
-	/*
-	 * Don't try to recover base con and handle race where the
-	 * other node's assoc init creates a assoc and we get that
-	 * notification, then we get a notification that our attempt
-	 * failed due. This happens when we are still trying the primary
-	 * address, but the other node has already tried secondary addrs
-	 * and found one that worked.
-	 */
-	if (!con->nodeid || con->sctp_assoc)
-		return;
-
-	log_print("Retrying SCTP association init for node %d\n", con->nodeid);
-
-	con->try_new_addr = true;
-	con->sctp_assoc = 0;
-	if (test_and_clear_bit(CF_INIT_PENDING, &con->flags)) {
-		if (!test_and_set_bit(CF_WRITE_PENDING, &con->flags))
-			queue_work(send_workqueue, &con->swork);
-	}
-}
-
-/* INIT failed but we don't know which node...
-   restart INIT on all pending nodes */
-static void sctp_init_failed(void)
-{
-	mutex_lock(&connections_lock);
-
-	foreach_conn(sctp_init_failed_foreach);
-
-	mutex_unlock(&connections_lock);
-}
-
-static void retry_failed_sctp_send(struct connection *recv_con,
-				   struct sctp_send_failed *sn_send_failed,
-				   char *buf)
-{
-	int len = sn_send_failed->ssf_length - sizeof(struct sctp_send_failed);
-	struct dlm_mhandle *mh;
-	struct connection *con;
-	char *retry_buf;
-	int nodeid = sn_send_failed->ssf_info.sinfo_ppid;
-
-	log_print("Retry sending %d bytes to node id %d", len, nodeid);
-	
-	if (!nodeid) {
-		log_print("Shouldn't resend data via listening connection.");
-		return;
-	}
-
-	con = nodeid2con(nodeid, 0);
-	if (!con) {
-		log_print("Could not look up con for nodeid %d\n",
-			  nodeid);
-		return;
-	}
-
-	mh = dlm_lowcomms_get_buffer(nodeid, len, GFP_NOFS, &retry_buf);
-	if (!mh) {
-		log_print("Could not allocate buf for retry.");
-		return;
-	}
-	memcpy(retry_buf, buf + sizeof(struct sctp_send_failed), len);
-	dlm_lowcomms_commit_buffer(mh);
-
-	/*
-	 * If we got a assoc changed event before the send failed event then
-	 * we only need to retry the send.
-	 */
-	if (con->sctp_assoc) {
-		if (!test_and_set_bit(CF_WRITE_PENDING, &con->flags))
-			queue_work(send_workqueue, &con->swork);
-	} else
-		sctp_init_failed_foreach(con);
-}
-
-/* Something happened to an association */
-static void process_sctp_notification(struct connection *con,
-				      struct msghdr *msg, char *buf)
-{
-	union sctp_notification *sn = (union sctp_notification *)buf;
-	struct linger linger;
-
-	switch (sn->sn_header.sn_type) {
-	case SCTP_SEND_FAILED:
-		retry_failed_sctp_send(con, &sn->sn_send_failed, buf);
-		break;
-	case SCTP_ASSOC_CHANGE:
-		switch (sn->sn_assoc_change.sac_state) {
-		case SCTP_COMM_UP:
-		case SCTP_RESTART:
-		{
-			/* Check that the new node is in the lockspace */
-			struct sctp_prim prim;
-			int nodeid;
-			int prim_len, ret;
-			int addr_len;
-			struct connection *new_con;
-
-			/*
-			 * We get this before any data for an association.
-			 * We verify that the node is in the cluster and
-			 * then peel off a socket for it.
-			 */
-			if ((int)sn->sn_assoc_change.sac_assoc_id <= 0) {
-				log_print("COMM_UP for invalid assoc ID %d",
-					 (int)sn->sn_assoc_change.sac_assoc_id);
-				sctp_init_failed();
-				return;
-			}
-			memset(&prim, 0, sizeof(struct sctp_prim));
-			prim_len = sizeof(struct sctp_prim);
-			prim.ssp_assoc_id = sn->sn_assoc_change.sac_assoc_id;
-
-			ret = kernel_getsockopt(con->sock,
-						IPPROTO_SCTP,
-						SCTP_PRIMARY_ADDR,
-						(char*)&prim,
-						&prim_len);
-			if (ret < 0) {
-				log_print("getsockopt/sctp_primary_addr on "
-					  "new assoc %d failed : %d",
-					  (int)sn->sn_assoc_change.sac_assoc_id,
-					  ret);
-
-				/* Retry INIT later */
-				new_con = assoc2con(sn->sn_assoc_change.sac_assoc_id);
-				if (new_con)
-					clear_bit(CF_CONNECT_PENDING, &con->flags);
-				return;
-			}
-			make_sockaddr(&prim.ssp_addr, 0, &addr_len);
-			if (addr_to_nodeid(&prim.ssp_addr, &nodeid)) {
-				unsigned char *b=(unsigned char *)&prim.ssp_addr;
-				log_print("reject connect from unknown addr");
-				print_hex_dump_bytes("ss: ", DUMP_PREFIX_NONE, 
-						     b, sizeof(struct sockaddr_storage));
-				sctp_send_shutdown(prim.ssp_assoc_id);
-				return;
-			}
-
-			new_con = nodeid2con(nodeid, GFP_NOFS);
-			if (!new_con)
-				return;
-
-			if (new_con->sock) {
-				log_print("reject connect from node %d: "
-					  "already has a connection.",
-					  nodeid);
-				sctp_send_shutdown(prim.ssp_assoc_id);
-				return;
-			}
-
-			/* Peel off a new sock */
-			lock_sock(con->sock->sk);
-			ret = sctp_do_peeloff(con->sock->sk,
-				sn->sn_assoc_change.sac_assoc_id,
-				&new_con->sock);
-			release_sock(con->sock->sk);
-			if (ret < 0) {
-				log_print("Can't peel off a socket for "
-					  "connection %d to node %d: err=%d",
-					  (int)sn->sn_assoc_change.sac_assoc_id,
-					  nodeid, ret);
-				return;
-			}
-			add_sock(new_con->sock, new_con);
-
-			linger.l_onoff = 1;
-			linger.l_linger = 0;
-			ret = kernel_setsockopt(new_con->sock, SOL_SOCKET, SO_LINGER,
-						(char *)&linger, sizeof(linger));
-			if (ret < 0)
-				log_print("set socket option SO_LINGER failed");
-
-			log_print("connecting to %d sctp association %d",
-				 nodeid, (int)sn->sn_assoc_change.sac_assoc_id);
-
-			new_con->sctp_assoc = sn->sn_assoc_change.sac_assoc_id;
-			new_con->try_new_addr = false;
-			/* Send any pending writes */
-			clear_bit(CF_CONNECT_PENDING, &new_con->flags);
-			clear_bit(CF_INIT_PENDING, &new_con->flags);
-			if (!test_and_set_bit(CF_WRITE_PENDING, &new_con->flags)) {
-				queue_work(send_workqueue, &new_con->swork);
-			}
-			if (!test_and_set_bit(CF_READ_PENDING, &new_con->flags))
-				queue_work(recv_workqueue, &new_con->rwork);
-		}
-		break;
-
-		case SCTP_COMM_LOST:
-		case SCTP_SHUTDOWN_COMP:
-		{
-			con = assoc2con(sn->sn_assoc_change.sac_assoc_id);
-			if (con) {
-				con->sctp_assoc = 0;
-			}
-		}
-		break;
-
-		case SCTP_CANT_STR_ASSOC:
-		{
-			/* Will retry init when we get the send failed notification */
-			log_print("Can't start SCTP association - retrying");
-		}
-		break;
-
-		default:
-			log_print("unexpected SCTP assoc change id=%d state=%d",
-				  (int)sn->sn_assoc_change.sac_assoc_id,
-				  sn->sn_assoc_change.sac_state);
-		}
-	default:
-		; /* fall through */
-	}
-}
-
 /* Data received from remote end */
 static int receive_from_sock(struct connection *con)
 {
@@ -810,7 +535,6 @@ static int receive_from_sock(struct connection *con)
 	int r;
 	int call_again_soon = 0;
 	int nvec;
-	char incmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
 
 	mutex_lock(&con->sock_mutex);
 
@@ -830,11 +554,6 @@ static int receive_from_sock(struct connection *con)
 		cbuf_init(&con->cb, PAGE_CACHE_SIZE);
 	}
 
-	/* Only SCTP needs these really */
-	memset(&incmsg, 0, sizeof(incmsg));
-	msg.msg_control = incmsg;
-	msg.msg_controllen = sizeof(incmsg);
-
 	/*
 	 * iov[0] is the bit of the circular buffer between the current end
 	 * point (cb.base + cb.len) and the end of the buffer.
@@ -860,31 +579,20 @@ static int receive_from_sock(struct connection *con)
 			       MSG_DONTWAIT | MSG_NOSIGNAL);
 	if (ret <= 0)
 		goto out_close;
+	else if (ret == len)
+		call_again_soon = 1;
 
-	/* Process SCTP notifications */
-	if (msg.msg_flags & MSG_NOTIFICATION) {
-		msg.msg_control = incmsg;
-		msg.msg_controllen = sizeof(incmsg);
-
-		process_sctp_notification(con, &msg,
-				page_address(con->rx_page) + con->cb.base);
-		mutex_unlock(&con->sock_mutex);
-		return 0;
-	}
 	BUG_ON(con->nodeid == 0);
 
-	if (ret == len)
-		call_again_soon = 1;
 	cbuf_add(&con->cb, ret);
 	ret = dlm_process_incoming_buffer(con->nodeid,
 					  page_address(con->rx_page),
 					  con->cb.base, con->cb.len,
 					  PAGE_CACHE_SIZE);
 	if (ret == -EBADMSG) {
-		log_print("lowcomms: addr=%p, base=%u, len=%u, "
-			  "iov_len=%u, iov_base[0]=%p, read=%d",
-			  page_address(con->rx_page), con->cb.base, con->cb.len,
-			  len, iov[0].iov_base, r);
+		log_print("lowcomms: addr=%p, base=%u, len=%u, read=%d",
+			  page_address(con->rx_page), con->cb.base,
+			  con->cb.len, r);
 	}
 	if (ret < 0)
 		goto out_close;
@@ -1050,6 +758,120 @@ accept_err:
 	return result;
 }
 
+int sctp_accept_from_sock(struct connection *con)
+{
+	/* Check that the new node is in the lockspace */
+	struct sctp_prim prim;
+	int nodeid;
+	int prim_len, ret;
+	int addr_len;
+	struct connection *newcon;
+	struct connection *addcon;
+	struct socket *newsock;
+
+	mutex_lock(&connections_lock);
+	if (!dlm_allow_conn) {
+		mutex_unlock(&connections_lock);
+		return -1;
+	}
+	mutex_unlock(&connections_lock);
+
+	mutex_lock_nested(&con->sock_mutex, 0);
+
+	ret = kernel_accept(con->sock, &newsock, O_NONBLOCK);
+	if (ret < 0)
+		goto accept_err;
+
+	memset(&prim, 0, sizeof(struct sctp_prim));
+	prim_len = sizeof(struct sctp_prim);
+
+	ret = kernel_getsockopt(newsock, IPPROTO_SCTP, SCTP_PRIMARY_ADDR,
+				(char *)&prim, &prim_len);
+	if (ret < 0) {
+		log_print("getsockopt/sctp_primary_addr failed: %d", ret);
+		goto accept_err;
+	}
+
+	make_sockaddr(&prim.ssp_addr, 0, &addr_len);
+	if (addr_to_nodeid(&prim.ssp_addr, &nodeid)) {
+		unsigned char *b = (unsigned char *)&prim.ssp_addr;
+
+		log_print("reject connect from unknown addr");
+		print_hex_dump_bytes("ss: ", DUMP_PREFIX_NONE,
+				     b, sizeof(struct sockaddr_storage));
+		goto accept_err;
+	}
+
+	newcon = nodeid2con(nodeid, GFP_NOFS);
+	if (!newcon) {
+		ret = -ENOMEM;
+		goto accept_err;
+	}
+
+	mutex_lock_nested(&newcon->sock_mutex, 1);
+
+	if (newcon->sock) {
+		struct connection *othercon = newcon->othercon;
+
+		if (!othercon) {
+			othercon = kmem_cache_zalloc(con_cache, GFP_NOFS);
+			if (!othercon) {
+				log_print("failed to allocate incoming socket");
+				mutex_unlock(&newcon->sock_mutex);
+				ret = -ENOMEM;
+				goto accept_err;
+			}
+			othercon->nodeid = nodeid;
+			othercon->rx_action = receive_from_sock;
+			mutex_init(&othercon->sock_mutex);
+			INIT_WORK(&othercon->swork, process_send_sockets);
+			INIT_WORK(&othercon->rwork, process_recv_sockets);
+			set_bit(CF_IS_OTHERCON, &othercon->flags);
+		}
+		if (!othercon->sock) {
+			newcon->othercon = othercon;
+			othercon->sock = newsock;
+			newsock->sk->sk_user_data = othercon;
+			add_sock(newsock, othercon);
+			addcon = othercon;
+		} else {
+			printk("Extra connection from node %d attempted\n", nodeid);
+			ret = -EAGAIN;
+			mutex_unlock(&newcon->sock_mutex);
+			goto accept_err;
+		}
+	} else {
+		newsock->sk->sk_user_data = newcon;
+		newcon->rx_action = receive_from_sock;
+		add_sock(newsock, newcon);
+		addcon = newcon;
+	}
+
+	log_print("connected to %d", nodeid);
+
+	mutex_unlock(&newcon->sock_mutex);
+
+	/*
+	 * Add it to the active queue in case we got data
+	 * between processing the accept adding the socket
+	 * to the read_sockets list
+	 */
+	if (!test_and_set_bit(CF_READ_PENDING, &addcon->flags))
+		queue_work(recv_workqueue, &addcon->rwork);
+	mutex_unlock(&con->sock_mutex);
+
+	return 0;
+
+accept_err:
+	mutex_unlock(&con->sock_mutex);
+	if (newsock)
+		sock_release(newsock);
+	if (ret != -EAGAIN)
+		log_print("error accepting connection from node: %d", ret);
+
+	return ret;
+}
+
 static void free_entry(struct writequeue_entry *e)
 {
 	__free_page(e->page);
@@ -1074,96 +896,127 @@ static void writequeue_entry_complete(struct writequeue_entry *e, int completed)
 	}
 }
 
+/*
+ * sctp_bind_addrs - bind a SCTP socket to all our addresses
+ */
+static int sctp_bind_addrs(struct connection *con, uint16_t port)
+{
+	struct sockaddr_storage localaddr;
+	int i, addr_len, result = 0;
+
+	for (i = 0; i < dlm_local_count; i++) {
+		memcpy(&localaddr, dlm_local_addr[i], sizeof(localaddr));
+		make_sockaddr(&localaddr, port, &addr_len);
+
+		if (!i)
+			result = kernel_bind(con->sock,
+					     (struct sockaddr *)&localaddr,
+					     addr_len);
+		else
+			result = kernel_setsockopt(con->sock, SOL_SCTP,
+						   SCTP_SOCKOPT_BINDX_ADD,
+						   (char *)&localaddr, addr_len);
+
+		if (result < 0) {
+			log_print("Can't bind to %d addr number %d, %d.\n",
+				  port, i + 1, result);
+			break;
+		}
+	}
+	return result;
+}
+
 /* Initiate an SCTP association.
    This is a special case of send_to_sock() in that we don't yet have a
    peeled-off socket for this association, so we use the listening socket
    and add the primary IP address of the remote node.
  */
-static void sctp_init_assoc(struct connection *con)
+static void sctp_connect_to_sock(struct connection *con)
 {
-	struct sockaddr_storage rem_addr;
-	char outcmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
-	struct msghdr outmessage;
-	struct cmsghdr *cmsg;
-	struct sctp_sndrcvinfo *sinfo;
-	struct connection *base_con;
-	struct writequeue_entry *e;
-	int len, offset;
-	int ret;
-	int addrlen;
-	struct kvec iov[1];
+	struct sockaddr_storage daddr;
+	int one = 1;
+	int result;
+	int addr_len;
+	struct socket *sock;
+
+	if (con->nodeid == 0) {
+		log_print("attempt to connect sock 0 foiled");
+		return;
+	}
 
 	mutex_lock(&con->sock_mutex);
-	if (test_and_set_bit(CF_INIT_PENDING, &con->flags))
-		goto unlock;
 
-	if (nodeid_to_addr(con->nodeid, NULL, (struct sockaddr *)&rem_addr,
-			   con->try_new_addr)) {
+	/* Some odd races can cause double-connects, ignore them */
+	if (con->retries++ > MAX_CONNECT_RETRIES)
+		goto out;
+
+	if (con->sock) {
+		log_print("node %d already connected.", con->nodeid);
+		goto out;
+	}
+
+	memset(&daddr, 0, sizeof(daddr));
+	result = nodeid_to_addr(con->nodeid, &daddr, NULL, true);
+	if (result < 0) {
 		log_print("no address for nodeid %d", con->nodeid);
-		goto unlock;
+		goto out;
 	}
-	base_con = nodeid2con(0, 0);
-	BUG_ON(base_con == NULL);
 
-	make_sockaddr(&rem_addr, dlm_config.ci_tcp_port, &addrlen);
+	/* Create a socket to communicate with */
+	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
+				  SOCK_STREAM, IPPROTO_SCTP, &sock);
+	if (result < 0)
+		goto socket_err;
 
-	outmessage.msg_name = &rem_addr;
-	outmessage.msg_namelen = addrlen;
-	outmessage.msg_control = outcmsg;
-	outmessage.msg_controllen = sizeof(outcmsg);
-	outmessage.msg_flags = MSG_EOR;
+	sock->sk->sk_user_data = con;
+	con->rx_action = receive_from_sock;
+	con->connect_action = sctp_connect_to_sock;
+	add_sock(sock, con);
 
-	spin_lock(&con->writequeue_lock);
+	/* Bind to all addresses. */
+	if (sctp_bind_addrs(con, 0))
+		goto bind_err;
 
-	if (list_empty(&con->writequeue)) {
-		spin_unlock(&con->writequeue_lock);
-		log_print("writequeue empty for nodeid %d", con->nodeid);
-		goto unlock;
-	}
+	make_sockaddr(&daddr, dlm_config.ci_tcp_port, &addr_len);
 
-	e = list_first_entry(&con->writequeue, struct writequeue_entry, list);
-	len = e->len;
-	offset = e->offset;
+	log_print("connecting to %d", con->nodeid);
 
-	/* Send the first block off the write queue */
-	iov[0].iov_base = page_address(e->page)+offset;
-	iov[0].iov_len = len;
-	spin_unlock(&con->writequeue_lock);
+	/* Turn off Nagle's algorithm */
+	kernel_setsockopt(sock, SOL_TCP, TCP_NODELAY, (char *)&one,
+			  sizeof(one));
 
-	if (rem_addr.ss_family == AF_INET) {
-		struct sockaddr_in *sin = (struct sockaddr_in *)&rem_addr;
-		log_print("Trying to connect to %pI4", &sin->sin_addr.s_addr);
-	} else {
-		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&rem_addr;
-		log_print("Trying to connect to %pI6", &sin6->sin6_addr);
-	}
+	result = sock->ops->connect(sock, (struct sockaddr *)&daddr, addr_len,
+				   O_NONBLOCK);
+	if (result == -EINPROGRESS)
+		result = 0;
+	if (result == 0)
+		goto out;
 
-	cmsg = CMSG_FIRSTHDR(&outmessage);
-	cmsg->cmsg_level = IPPROTO_SCTP;
-	cmsg->cmsg_type = SCTP_SNDRCV;
-	cmsg->cmsg_len = CMSG_LEN(sizeof(struct sctp_sndrcvinfo));
-	sinfo = CMSG_DATA(cmsg);
-	memset(sinfo, 0x00, sizeof(struct sctp_sndrcvinfo));
-	sinfo->sinfo_ppid = cpu_to_le32(con->nodeid);
-	outmessage.msg_controllen = cmsg->cmsg_len;
-	sinfo->sinfo_flags |= SCTP_ADDR_OVER;
 
-	ret = kernel_sendmsg(base_con->sock, &outmessage, iov, 1, len);
-	if (ret < 0) {
-		log_print("Send first packet to node %d failed: %d",
-			  con->nodeid, ret);
+bind_err:
+	con->sock = NULL;
+	sock_release(sock);
 
-		/* Try again later */
+socket_err:
+	/*
+	 * Some errors are fatal and this list might need adjusting. For other
+	 * errors we try again until the max number of retries is reached.
+	 */
+	if (result != -EHOSTUNREACH &&
+	    result != -ENETUNREACH &&
+	    result != -ENETDOWN &&
+	    result != -EINVAL &&
+	    result != -EPROTONOSUPPORT) {
+		log_print("connect %d try %d error %d", con->nodeid,
+			  con->retries, result);
+		mutex_unlock(&con->sock_mutex);
+		msleep(1000);
 		clear_bit(CF_CONNECT_PENDING, &con->flags);
-		clear_bit(CF_INIT_PENDING, &con->flags);
-	}
-	else {
-		spin_lock(&con->writequeue_lock);
-		writequeue_entry_complete(e, ret);
-		spin_unlock(&con->writequeue_lock);
+		lowcomms_connect_sock(con);
+		return;
 	}
 
-unlock:
+out:
 	mutex_unlock(&con->sock_mutex);
 }
 
@@ -1343,37 +1196,11 @@ static void init_local(void)
 	}
 }
 
-/* Bind to an IP address. SCTP allows multiple address so it can do
-   multi-homing */
-static int add_sctp_bind_addr(struct connection *sctp_con,
-			      struct sockaddr_storage *addr,
-			      int addr_len, int num)
-{
-	int result = 0;
-
-	if (num == 1)
-		result = kernel_bind(sctp_con->sock,
-				     (struct sockaddr *) addr,
-				     addr_len);
-	else
-		result = kernel_setsockopt(sctp_con->sock, SOL_SCTP,
-					   SCTP_SOCKOPT_BINDX_ADD,
-					   (char *)addr, addr_len);
-
-	if (result < 0)
-		log_print("Can't bind to port %d addr number %d",
-			  dlm_config.ci_tcp_port, num);
-
-	return result;
-}
-
 /* Initialise SCTP socket and bind to all interfaces */
 static int sctp_listen_for_all(void)
 {
 	struct socket *sock = NULL;
-	struct sockaddr_storage localaddr;
-	struct sctp_event_subscribe subscribe;
-	int result = -EINVAL, num = 1, i, addr_len;
+	int result = -EINVAL;
 	struct connection *con = nodeid2con(0, GFP_NOFS);
 	int bufsize = NEEDED_RMEM;
 	int one = 1;
@@ -1384,33 +1211,17 @@ static int sctp_listen_for_all(void)
 	log_print("Using SCTP for communications");
 
 	result = sock_create_kern(&init_net, dlm_local_addr[0]->ss_family,
-				  SOCK_SEQPACKET, IPPROTO_SCTP, &sock);
+				  SOCK_STREAM, IPPROTO_SCTP, &sock);
 	if (result < 0) {
 		log_print("Can't create comms socket, check SCTP is loaded");
 		goto out;
 	}
 
-	/* Listen for events */
-	memset(&subscribe, 0, sizeof(subscribe));
-	subscribe.sctp_data_io_event = 1;
-	subscribe.sctp_association_event = 1;
-	subscribe.sctp_send_failure_event = 1;
-	subscribe.sctp_shutdown_event = 1;
-	subscribe.sctp_partial_delivery_event = 1;
-
 	result = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUFFORCE,
 				 (char *)&bufsize, sizeof(bufsize));
 	if (result)
 		log_print("Error increasing buffer space on socket %d", result);
 
-	result = kernel_setsockopt(sock, SOL_SCTP, SCTP_EVENTS,
-				   (char *)&subscribe, sizeof(subscribe));
-	if (result < 0) {
-		log_print("Failed to set SCTP_EVENTS on socket: result=%d",
-			  result);
-		goto create_delsock;
-	}
-
 	result = kernel_setsockopt(sock, SOL_SCTP, SCTP_NODELAY, (char *)&one,
 				   sizeof(one));
 	if (result < 0)
@@ -1420,19 +1231,12 @@ static int sctp_listen_for_all(void)
 	sock->sk->sk_user_data = con;
 	con->sock = sock;
 	con->sock->sk->sk_data_ready = lowcomms_data_ready;
-	con->rx_action = receive_from_sock;
-	con->connect_action = sctp_init_assoc;
-
-	/* Bind to all interfaces. */
-	for (i = 0; i < dlm_local_count; i++) {
-		memcpy(&localaddr, dlm_local_addr[i], sizeof(localaddr));
-		make_sockaddr(&localaddr, dlm_config.ci_tcp_port, &addr_len);
+	con->rx_action = sctp_accept_from_sock;
+	con->connect_action = sctp_connect_to_sock;
 
-		result = add_sctp_bind_addr(con, &localaddr, addr_len, num);
-		if (result)
-			goto create_delsock;
-		++num;
-	}
+	/* Bind to all addresses. */
+	if (sctp_bind_addrs(con, dlm_config.ci_tcp_port))
+		goto create_delsock;
 
 	result = sock->ops->listen(sock, 5);
 	if (result < 0) {
@@ -1636,8 +1440,7 @@ send_error:
 
 out_connect:
 	mutex_unlock(&con->sock_mutex);
-	if (!test_bit(CF_INIT_PENDING, &con->flags))
-		lowcomms_connect_sock(con);
+	lowcomms_connect_sock(con);
 }
 
 static void clean_one_writequeue(struct connection *con)
-- 
2.4.3
