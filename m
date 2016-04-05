From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/7] sctp: export some apis or variables for sctp_diag
Date: Tue,  5 Apr 2016 12:06:27 +0800
Message-ID: <c99aafbc687328f783c0777e10df3e207004db10.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1459829123.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36622 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbcDEEGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:06:48 -0400
In-Reply-To: <c507274a984bd1b0a7e7a59d1e825352536efd25.1459829123.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some main variables in sctp.ko, we couldn't export it to other modules,
so we have to define some api to access them.

It will include sctp transport and endpoint's traversal.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h |  13 +++++
 net/sctp/socket.c       | 124 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 137 insertions(+)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 36e1eae..c0c4deb 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -116,6 +116,19 @@ extern struct percpu_counter sctp_sockets_allocated;
 int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
 struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *);
 
+int sctp_transport_walk_start(struct rhashtable_iter *iter);
+void sctp_transport_walk_stop(struct rhashtable_iter *iter);
+struct sctp_transport *sctp_transport_get_next(struct net *net,
+			struct rhashtable_iter *iter);
+struct sctp_transport *sctp_transport_get_idx(struct net *net,
+			struct rhashtable_iter *iter, int pos);
+int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
+				  struct net *net,
+				  const union sctp_addr *laddr,
+				  const union sctp_addr *paddr, void *p);
+int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
+			    struct net *net, int pos, void *p);
+int sctp_for_each_endpoint(int (*cb)(struct sctp_endpoint *, void *), void *p);
 int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 		       struct sctp_info *info);
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 8f79f23..b0bf6c7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4288,6 +4288,130 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 }
 EXPORT_SYMBOL_GPL(sctp_get_sctp_info);
 
+/* use callback to avoid exporting the core structure */
+int sctp_transport_walk_start(struct rhashtable_iter *iter)
+{
+	int err;
+
+	err = rhashtable_walk_init(&sctp_transport_hashtable, iter);
+	if (err)
+		return err;
+
+	err = rhashtable_walk_start(iter);
+
+	return err == -EAGAIN ? 0 : err;
+}
+
+void sctp_transport_walk_stop(struct rhashtable_iter *iter)
+{
+	rhashtable_walk_stop(iter);
+	rhashtable_walk_exit(iter);
+}
+
+struct sctp_transport *sctp_transport_get_next(struct net *net,
+					       struct rhashtable_iter *iter)
+{
+	struct sctp_transport *t;
+
+	t = rhashtable_walk_next(iter);
+	for (; t; t = rhashtable_walk_next(iter)) {
+		if (IS_ERR(t)) {
+			if (PTR_ERR(t) == -EAGAIN)
+				continue;
+			break;
+		}
+
+		if (net_eq(sock_net(t->asoc->base.sk), net) &&
+		    t->asoc->peer.primary_path == t)
+			break;
+	}
+
+	return t;
+}
+
+struct sctp_transport *sctp_transport_get_idx(struct net *net,
+					      struct rhashtable_iter *iter,
+					      int pos)
+{
+	void *obj = SEQ_START_TOKEN;
+
+	while (pos && (obj = sctp_transport_get_next(net, iter)) &&
+	       !IS_ERR(obj))
+		pos--;
+
+	return obj;
+}
+
+int sctp_for_each_endpoint(int (*cb)(struct sctp_endpoint *, void *),
+			   void *p) {
+	int err = 0;
+	int hash = 0;
+	struct sctp_ep_common *epb;
+	struct sctp_hashbucket *head;
+
+	for (head = sctp_ep_hashtable; hash < sctp_ep_hashsize;
+	     hash++, head++) {
+		read_lock(&head->lock);
+		sctp_for_each_hentry(epb, &head->chain) {
+			err = cb(sctp_ep(epb), p);
+			if (err)
+				break;
+		}
+		read_unlock(&head->lock);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(sctp_for_each_endpoint);
+
+int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
+				  struct net *net,
+				  const union sctp_addr *laddr,
+				  const union sctp_addr *paddr, void *p)
+{
+	struct sctp_transport *transport;
+	int err = 0;
+
+	rcu_read_lock();
+	transport = sctp_addrs_lookup_transport(net, laddr, paddr);
+	if (!transport || !sctp_transport_hold(transport))
+		goto out;
+	err = cb(transport, p);
+	sctp_transport_put(transport);
+
+out:
+	rcu_read_unlock();
+	return err;
+}
+EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
+
+int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
+			    struct net *net, int pos, void *p) {
+	struct rhashtable_iter hti;
+	int err = 0;
+	void *obj;
+
+	if (sctp_transport_walk_start(&hti))
+		goto out;
+
+	sctp_transport_get_idx(net, &hti, pos);
+	obj = sctp_transport_get_next(net, &hti);
+	for (; obj && !IS_ERR(obj); obj = sctp_transport_get_next(net, &hti)) {
+		struct sctp_transport *transport = obj;
+
+		if (!sctp_transport_hold(transport))
+			continue;
+		err = cb(transport, p);
+		sctp_transport_put(transport);
+		if (err)
+			break;
+	}
+out:
+	sctp_transport_walk_stop(&hti);
+	return err;
+}
+EXPORT_SYMBOL_GPL(sctp_for_each_transport);
+
 /* 7.2.1 Association Status (SCTP_STATUS)
 
  * Applications can retrieve current status information about an
-- 
2.1.0
