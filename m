From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 3/5] sctp: apply rhashtable api to sctp procfs
Date: Wed, 30 Dec 2015 23:50:48 +0800
Message-ID: <8694e8698924a89a1dad097a3f1120d4b24443a1.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
 <2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
 <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:32831 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbbL3PvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 10:51:11 -0500
In-Reply-To: <8d89800920719b527dbd6e36dbbcf3c0804fbd7c.1451490447.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1451490447.git.lucien.xin@gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Traversal the transport rhashtable, get the association only once through
the condition assoc->peer.primary_path != transport.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/proc.c | 316 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 173 insertions(+), 143 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0697eda..dfa7eec 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -281,88 +281,136 @@ void sctp_eps_proc_exit(struct net *net)
 	remove_proc_entry("eps", net->sctp.proc_net_sctp);
 }
 
+struct sctp_ht_iter {
+	struct seq_net_private p;
+	struct rhashtable_iter hti;
+};
 
-static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
+static struct sctp_transport *sctp_transport_get_next(struct seq_file *seq)
 {
-	if (*pos >= sctp_assoc_hashsize)
-		return NULL;
+	struct sctp_ht_iter *iter = seq->private;
+	struct sctp_transport *t;
 
-	if (*pos < 0)
-		*pos = 0;
+	t = rhashtable_walk_next(&iter->hti);
+	for (; t; t = rhashtable_walk_next(&iter->hti)) {
+		if (IS_ERR(t)) {
+			if (PTR_ERR(t) == -EAGAIN)
+				continue;
+			break;
+		}
 
-	if (*pos == 0)
-		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
-				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
-				"RPORT LADDRS <-> RADDRS "
-				"HBINT INS OUTS MAXRT T1X T2X RTXC "
-				"wmema wmemq sndbuf rcvbuf\n");
+		if (net_eq(sock_net(t->asoc->base.sk), seq_file_net(seq)) &&
+		    t->asoc->peer.primary_path == t)
+			break;
+	}
 
-	return (void *)pos;
+	return t;
 }
 
-static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
+static struct sctp_transport *sctp_transport_get_idx(struct seq_file *seq,
+						     loff_t pos)
+{
+	void *obj;
+
+	while (pos && (obj = sctp_transport_get_next(seq)) && !IS_ERR(obj))
+		pos--;
+
+	return obj;
+}
+
+static int sctp_transport_walk_start(struct seq_file *seq)
 {
+	struct sctp_ht_iter *iter = seq->private;
+	int err;
+
+	err = rhashtable_walk_init(&sctp_transport_hashtable, &iter->hti);
+	if (err)
+		return err;
+
+	err = rhashtable_walk_start(&iter->hti);
+
+	return err == -EAGAIN ? 0 : err;
 }
 
+static void sctp_transport_walk_stop(struct seq_file *seq)
+{
+	struct sctp_ht_iter *iter = seq->private;
+
+	rhashtable_walk_stop(&iter->hti);
+	rhashtable_walk_exit(&iter->hti);
+}
+
+static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	int err = sctp_transport_walk_start(seq);
+
+	if (err)
+		return ERR_PTR(err);
+
+	return *pos ? sctp_transport_get_idx(seq, *pos) : SEQ_START_TOKEN;
+}
+
+static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
+{
+	sctp_transport_walk_stop(seq);
+}
 
 static void *sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	if (++*pos >= sctp_assoc_hashsize)
-		return NULL;
+	++*pos;
 
-	return pos;
+	return sctp_transport_get_next(seq);
 }
 
 /* Display sctp associations (/proc/net/sctp/assocs). */
 static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 {
-	struct sctp_hashbucket *head;
-	struct sctp_ep_common *epb;
+	struct sctp_transport *transport;
 	struct sctp_association *assoc;
+	struct sctp_ep_common *epb;
 	struct sock *sk;
-	int    hash = *(loff_t *)v;
-
-	if (hash >= sctp_assoc_hashsize)
-		return -ENOMEM;
 
-	head = &sctp_assoc_hashtable[hash];
-	local_bh_disable();
-	read_lock(&head->lock);
-	sctp_for_each_hentry(epb, &head->chain) {
-		assoc = sctp_assoc(epb);
-		sk = epb->sk;
-		if (!net_eq(sock_net(sk), seq_file_net(seq)))
-			continue;
-		seq_printf(seq,
-			   "%8pK %8pK %-3d %-3d %-2d %-4d "
-			   "%4d %8d %8d %7u %5lu %-5d %5d ",
-			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
-			   assoc->state, hash,
-			   assoc->assoc_id,
-			   assoc->sndbuf_used,
-			   atomic_read(&assoc->rmem_alloc),
-			   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
-			   sock_i_ino(sk),
-			   epb->bind_addr.port,
-			   assoc->peer.port);
-		seq_printf(seq, " ");
-		sctp_seq_dump_local_addrs(seq, epb);
-		seq_printf(seq, "<-> ");
-		sctp_seq_dump_remote_addrs(seq, assoc);
-		seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
-			   "%8d %8d %8d %8d",
-			assoc->hbinterval, assoc->c.sinit_max_instreams,
-			assoc->c.sinit_num_ostreams, assoc->max_retrans,
-			assoc->init_retries, assoc->shutdown_retries,
-			assoc->rtx_data_chunks,
-			atomic_read(&sk->sk_wmem_alloc),
-			sk->sk_wmem_queued,
-			sk->sk_sndbuf,
-			sk->sk_rcvbuf);
-		seq_printf(seq, "\n");
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, " ASSOC     SOCK   STY SST ST HBKT "
+				"ASSOC-ID TX_QUEUE RX_QUEUE UID INODE LPORT "
+				"RPORT LADDRS <-> RADDRS "
+				"HBINT INS OUTS MAXRT T1X T2X RTXC "
+				"wmema wmemq sndbuf rcvbuf\n");
+		return 0;
 	}
-	read_unlock(&head->lock);
-	local_bh_enable();
+
+	transport = (struct sctp_transport *)v;
+	assoc = transport->asoc;
+	epb = &assoc->base;
+	sk = epb->sk;
+
+	seq_printf(seq,
+		   "%8pK %8pK %-3d %-3d %-2d %-4d "
+		   "%4d %8d %8d %7u %5lu %-5d %5d ",
+		   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
+		   assoc->state, 0,
+		   assoc->assoc_id,
+		   assoc->sndbuf_used,
+		   atomic_read(&assoc->rmem_alloc),
+		   from_kuid_munged(seq_user_ns(seq), sock_i_uid(sk)),
+		   sock_i_ino(sk),
+		   epb->bind_addr.port,
+		   assoc->peer.port);
+	seq_printf(seq, " ");
+	sctp_seq_dump_local_addrs(seq, epb);
+	seq_printf(seq, "<-> ");
+	sctp_seq_dump_remote_addrs(seq, assoc);
+	seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
+		   "%8d %8d %8d %8d",
+		assoc->hbinterval, assoc->c.sinit_max_instreams,
+		assoc->c.sinit_num_ostreams, assoc->max_retrans,
+		assoc->init_retries, assoc->shutdown_retries,
+		assoc->rtx_data_chunks,
+		atomic_read(&sk->sk_wmem_alloc),
+		sk->sk_wmem_queued,
+		sk->sk_sndbuf,
+		sk->sk_rcvbuf);
+	seq_printf(seq, "\n");
 
 	return 0;
 }
@@ -378,7 +426,7 @@ static const struct seq_operations sctp_assoc_ops = {
 static int sctp_assocs_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &sctp_assoc_ops,
-			    sizeof(struct seq_net_private));
+			    sizeof(struct sctp_ht_iter));
 }
 
 static const struct file_operations sctp_assocs_seq_fops = {
@@ -409,112 +457,94 @@ void sctp_assocs_proc_exit(struct net *net)
 
 static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	if (*pos >= sctp_assoc_hashsize)
-		return NULL;
-
-	if (*pos < 0)
-		*pos = 0;
+	int err = sctp_transport_walk_start(seq);
 
-	if (*pos == 0)
-		seq_printf(seq, "ADDR ASSOC_ID HB_ACT RTO MAX_PATH_RTX "
-				"REM_ADDR_RTX START STATE\n");
+	if (err)
+		return ERR_PTR(err);
 
-	return (void *)pos;
+	return *pos ? sctp_transport_get_idx(seq, *pos) : SEQ_START_TOKEN;
 }
 
 static void *sctp_remaddr_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	if (++*pos >= sctp_assoc_hashsize)
-		return NULL;
+	++*pos;
 
-	return pos;
+	return sctp_transport_get_next(seq);
 }
 
 static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
 {
+	sctp_transport_walk_stop(seq);
 }
 
 static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 {
-	struct sctp_hashbucket *head;
-	struct sctp_ep_common *epb;
 	struct sctp_association *assoc;
 	struct sctp_transport *tsp;
-	int    hash = *(loff_t *)v;
 
-	if (hash >= sctp_assoc_hashsize)
-		return -ENOMEM;
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, "ADDR ASSOC_ID HB_ACT RTO MAX_PATH_RTX "
+				"REM_ADDR_RTX START STATE\n");
+		return 0;
+	}
 
-	head = &sctp_assoc_hashtable[hash];
-	local_bh_disable();
-	read_lock(&head->lock);
-	rcu_read_lock();
-	sctp_for_each_hentry(epb, &head->chain) {
-		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
+	tsp = (struct sctp_transport *)v;
+	assoc = tsp->asoc;
+
+	list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
+				transports) {
+		if (tsp->dead)
 			continue;
-		assoc = sctp_assoc(epb);
-		list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
-					transports) {
-			if (tsp->dead)
-				continue;
+		/*
+		 * The remote address (ADDR)
+		 */
+		tsp->af_specific->seq_dump_addr(seq, &tsp->ipaddr);
+		seq_printf(seq, " ");
+		/*
+		 * The association ID (ASSOC_ID)
+		 */
+		seq_printf(seq, "%d ", tsp->asoc->assoc_id);
+
+		/*
+		 * If the Heartbeat is active (HB_ACT)
+		 * Note: 1 = Active, 0 = Inactive
+		 */
+		seq_printf(seq, "%d ", timer_pending(&tsp->hb_timer));
+
+		/*
+		 * Retransmit time out (RTO)
+		 */
+		seq_printf(seq, "%lu ", tsp->rto);
+
+		/*
+		 * Maximum path retransmit count (PATH_MAX_RTX)
+		 */
+		seq_printf(seq, "%d ", tsp->pathmaxrxt);
+
+		/*
+		 * remote address retransmit count (REM_ADDR_RTX)
+		 * Note: We don't have a way to tally this at the moment
+		 * so lets just leave it as zero for the moment
+		 */
+		seq_puts(seq, "0 ");
+
+		/*
+		 * remote address start time (START).  This is also not
+		 * currently implemented, but we can record it with a
+		 * jiffies marker in a subsequent patch
+		 */
+		seq_puts(seq, "0 ");
+
+		/*
+		 * The current state of this destination. I.e.
+		 * SCTP_ACTIVE, SCTP_INACTIVE, ...
+		 */
+		seq_printf(seq, "%d", tsp->state);
 
-			/*
-			 * The remote address (ADDR)
-			 */
-			tsp->af_specific->seq_dump_addr(seq, &tsp->ipaddr);
-			seq_printf(seq, " ");
-
-			/*
-			 * The association ID (ASSOC_ID)
-			 */
-			seq_printf(seq, "%d ", tsp->asoc->assoc_id);
-
-			/*
-			 * If the Heartbeat is active (HB_ACT)
-			 * Note: 1 = Active, 0 = Inactive
-			 */
-			seq_printf(seq, "%d ", timer_pending(&tsp->hb_timer));
-
-			/*
-			 * Retransmit time out (RTO)
-			 */
-			seq_printf(seq, "%lu ", tsp->rto);
-
-			/*
-			 * Maximum path retransmit count (PATH_MAX_RTX)
-			 */
-			seq_printf(seq, "%d ", tsp->pathmaxrxt);
-
-			/*
-			 * remote address retransmit count (REM_ADDR_RTX)
-			 * Note: We don't have a way to tally this at the moment
-			 * so lets just leave it as zero for the moment
-			 */
-			seq_puts(seq, "0 ");
-
-			/*
-			 * remote address start time (START).  This is also not
-			 * currently implemented, but we can record it with a
-			 * jiffies marker in a subsequent patch
-			 */
-			seq_puts(seq, "0 ");
-
-			/*
-			 * The current state of this destination. I.e.
-			 * SCTP_ACTIVE, SCTP_INACTIVE, ...
-			 */
-			seq_printf(seq, "%d", tsp->state);
-
-			seq_printf(seq, "\n");
-		}
+		seq_printf(seq, "\n");
 	}
 
-	rcu_read_unlock();
-	read_unlock(&head->lock);
-	local_bh_enable();
-
 	return 0;
-
 }
 
 static const struct seq_operations sctp_remaddr_ops = {
@@ -533,7 +563,7 @@ void sctp_remaddr_proc_exit(struct net *net)
 static int sctp_remaddr_seq_open(struct inode *inode, struct file *file)
 {
 	return seq_open_net(inode, file, &sctp_remaddr_ops,
-			    sizeof(struct seq_net_private));
+			    sizeof(struct sctp_ht_iter));
 }
 
 static const struct file_operations sctp_remaddr_seq_fops = {
-- 
2.1.0
