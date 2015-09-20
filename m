From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/3] kcm: Add statistics and proc interfaces
Date: Sun, 20 Sep 2015 15:29:21 -0700
Message-ID: <1442788161-2626305-4-git-send-email-tom@herbertland.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33775 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755434AbbITWbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 18:31:09 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8KMSGwg005213
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1x1xkjhfrt-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 15:31:08 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 48b716525fe711e5975c0002c992ebde-78dfd240 for <netdev@vger.kernel.org>;	Sun,
 20 Sep 2015 15:31:06 -0700
In-Reply-To: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add various counters for KCM. These include counters for
messages and bytes received or sent, as well as counters number of
attached/unattached TCP sockets and other error or edge events.

The statistics are exposed via a proc interface. /proc/net/kcm provdes
statistics per KCM socket and per psock (attached TCP sockkets).
/proc/net/kcm_stats provides aggregate statistics.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/kcm.h | 102 ++++++++++++++
 net/kcm/Makefile  |   2 +-
 net/kcm/kcmproc.c | 415 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/kcm/kcmsock.c |  63 +++++++++
 4 files changed, 581 insertions(+), 1 deletion(-)
 create mode 100644 net/kcm/kcmproc.c

diff --git a/include/net/kcm.h b/include/net/kcm.h
index 55ef56b..5076247 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -11,6 +11,46 @@
 
 extern unsigned int kcm_net_id;
 
+#define KCM_STATS_ADD(stat, count)			\
+	((stat) += (count))
+
+#define KCM_STATS_INCR(stat)				\
+	((stat)++)
+
+struct kcm_psock_stats {
+	unsigned long long rx_msgs;
+	unsigned long long rx_bytes;
+	unsigned long long tx_msgs;
+	unsigned long long tx_bytes;
+	unsigned int rx_aborts;
+	unsigned int rx_mem_fail;
+	unsigned int rx_need_more_hdr;
+	unsigned int rx_bad_hdr_len;
+	unsigned long long reserved;
+	unsigned long long unreserved;
+	unsigned int tx_aborts;
+};
+
+struct kcm_mux_stats {
+	unsigned long long rx_msgs;
+	unsigned long long rx_bytes;
+	unsigned long long tx_msgs;
+	unsigned long long tx_bytes;
+	unsigned int rx_ready_drops;
+	unsigned int tx_no_psock;
+	unsigned int tx_retries;
+	unsigned int psock_attach;
+	unsigned int psock_unattach_rsvd;
+	unsigned int psock_unattach;
+};
+
+struct kcm_stats {
+	unsigned long long rx_msgs;
+	unsigned long long rx_bytes;
+	unsigned long long tx_msgs;
+	unsigned long long tx_bytes;
+};
+
 struct kcm_tx_msg {
 	unsigned int sent;
 	unsigned int fragidx;
@@ -30,6 +70,8 @@ struct kcm_sock {
 	struct kcm_mux *mux;
 	struct list_head kcm_sock_list;
 
+	struct kcm_stats stats;
+
 	/* Transmit */
 	struct kcm_psock *tx_psock;
 	struct work_struct tx_work;
@@ -61,6 +103,10 @@ struct kcm_psock {
 
 	struct list_head psock_list;
 
+	struct kcm_psock_stats stats;
+	unsigned long long saved_tx_bytes;
+	unsigned long long saved_tx_msgs;
+
 	/* Receive */
 	struct sk_buff *rx_skb_head;
 	struct sk_buff **rx_skb_nextp;
@@ -78,6 +124,8 @@ struct kcm_psock {
 /* Per net MUX list */
 struct kcm_net {
 	struct mutex mutex;
+	struct kcm_psock_stats aggregate_psock_stats;
+	struct kcm_mux_stats aggregate_mux_stats;
 	struct list_head mux_list;
 	int count;
 };
@@ -94,6 +142,9 @@ struct kcm_mux {
 	struct list_head psocks;	/* List of all psocks on MUX */
 	int psocks_cnt;		/* Total attached sockets */
 
+	struct kcm_mux_stats stats;
+	struct kcm_psock_stats aggregate_psock_stats;
+
 	/* Receive */
 	struct list_head kcm_rx_waiters; /* KCMs waiting for receiving */
 	struct kcm_sock *last_rx_kcm;
@@ -104,6 +155,57 @@ struct kcm_mux {
 	struct list_head kcm_tx_waiters; /* KCMs waiting for a TX psock */
 };
 
+#ifdef CONFIG_PROC_FS
+int kcm_proc_init(void);
+void kcm_proc_exit(void);
+#else
+static int kcm_proc_init(void) { return 0; }
+static void kcm_proc_exit(void) { }
+#endif
+
+
+static inline void aggregate_psock_stats(struct kcm_psock_stats *stats,
+					 struct kcm_psock_stats *agg_stats)
+{
+	/* Save psock statistics in the mux when psock is being unattached. */
+
+#define SAVE_PSOCK_STATS(_stat) (agg_stats->_stat += stats->_stat)
+
+	SAVE_PSOCK_STATS(rx_msgs);
+	SAVE_PSOCK_STATS(rx_bytes);
+	SAVE_PSOCK_STATS(rx_aborts);
+	SAVE_PSOCK_STATS(rx_mem_fail);
+	SAVE_PSOCK_STATS(rx_need_more_hdr);
+	SAVE_PSOCK_STATS(rx_bad_hdr_len);
+	SAVE_PSOCK_STATS(tx_msgs);
+	SAVE_PSOCK_STATS(tx_bytes);
+	SAVE_PSOCK_STATS(reserved);
+	SAVE_PSOCK_STATS(unreserved);
+	SAVE_PSOCK_STATS(tx_aborts);
+
+#undef SAVE_PSOCK_STATS
+}
+
+static inline void aggregate_mux_stats(struct kcm_mux_stats *stats,
+				       struct kcm_mux_stats *agg_stats)
+{
+	/* Save psock statistics in the mux when psock is being unattached. */
+
+#define SAVE_MUX_STATS(_stat) (agg_stats->_stat += stats->_stat)
+
+	SAVE_MUX_STATS(rx_msgs);
+	SAVE_MUX_STATS(rx_bytes);
+	SAVE_MUX_STATS(tx_msgs);
+	SAVE_MUX_STATS(tx_bytes);
+	SAVE_MUX_STATS(tx_no_psock);
+	SAVE_MUX_STATS(rx_ready_drops);
+	SAVE_MUX_STATS(psock_attach);
+	SAVE_MUX_STATS(psock_unattach_rsvd);
+	SAVE_MUX_STATS(psock_unattach);
+
+#undef SAVE_MUX_STATS
+}
+
 #endif /* __KERNEL__ */
 
 #endif /* __NET_KCM_H_ */
diff --git a/net/kcm/Makefile b/net/kcm/Makefile
index cb525f7..7125613 100644
--- a/net/kcm/Makefile
+++ b/net/kcm/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_AF_KCM) += kcm.o
 
-kcm-y := kcmsock.o
+kcm-y := kcmsock.o kcmproc.o
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
new file mode 100644
index 0000000..6334973
--- /dev/null
+++ b/net/kcm/kcmproc.c
@@ -0,0 +1,415 @@
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/proc_fs.h>
+#include <linux/rculist.h>
+#include <linux/seq_file.h>
+#include <linux/socket.h>
+#include <net/inet_sock.h>
+#include <net/kcm.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/tcp.h>
+
+#ifdef CONFIG_PROC_FS
+struct kcm_seq_muxinfo {
+	char				*name;
+	const struct file_operations	*seq_fops;
+	struct seq_operations		seq_ops;
+};
+
+static struct kcm_mux *kcm_get_first(struct seq_file *seq)
+{
+	struct net *net = seq_file_net(seq);
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+
+	return list_first_or_null_rcu(&knet->mux_list,
+				      struct kcm_mux, kcm_mux_list);
+}
+
+static struct kcm_mux *kcm_get_next(struct kcm_mux *mux)
+{
+	struct kcm_net *knet = mux->knet;
+
+	return list_next_or_null_rcu(&knet->mux_list, &mux->kcm_mux_list,
+				     struct kcm_mux, kcm_mux_list);
+}
+
+static struct kcm_mux *kcm_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct net *net = seq_file_net(seq);
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+	struct kcm_mux *m;
+
+	list_for_each_entry(m, &knet->mux_list, kcm_mux_list) {
+		if (!pos)
+			return m;
+		--pos;
+	}
+	return NULL;
+}
+
+static void *kcm_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	void *p;
+
+	if (v == SEQ_START_TOKEN)
+		p = kcm_get_first(seq);
+	else
+		p = kcm_get_next(v);
+	++*pos;
+	return p;
+}
+
+static void *kcm_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rcu)
+{
+	rcu_read_lock();
+
+	if (!*pos)
+		return SEQ_START_TOKEN;
+	else
+		return kcm_get_idx(seq, *pos - 1);
+}
+
+static void kcm_seq_stop(struct seq_file *seq, void *v)
+	__releases(rcu)
+{
+	rcu_read_unlock();
+}
+
+struct kcm_proc_mux_state {
+	struct seq_net_private p;
+	int idx;
+};
+
+static int kcm_seq_open(struct inode *inode, struct file *file)
+{
+	struct kcm_seq_muxinfo *muxinfo = PDE_DATA(inode);
+	int err;
+
+	err = seq_open_net(inode, file, &muxinfo->seq_ops,
+			   sizeof(struct kcm_proc_mux_state));
+	if (err < 0)
+		return err;
+	return err;
+}
+
+static void kcm_format_mux_header(struct seq_file *seq)
+{
+	struct net *net = seq_file_net(seq);
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+
+	seq_printf(seq,
+		   "*** KCM statistics (%d MUX) ****\n",
+		   knet->count);
+
+	seq_printf(seq,
+		   "%-8s %-10s %-16s %-10s %-16s %-8s %-8s %s",
+		   "Object",
+		   "RX-Msgs",
+		   "RX-Bytes",
+		   "TX-Msgs",
+		   "TX-Bytes",
+		   "Recv-Q",
+		   "Send-Q",
+		   "Status");
+
+	/* XXX: pdsts header stuff here */
+	seq_puts(seq, "\n");
+}
+
+static void kcm_format_sock(struct kcm_sock *kcm, struct seq_file *seq,
+			    int i, int *len)
+{
+	seq_printf(seq,
+		   "%-6s%-6s %-10llu %-16llu %-10llu %-16llu %-8d %-8d",
+		   "", "kcm",
+		   kcm->stats.rx_msgs,
+		   kcm->stats.rx_bytes,
+		   kcm->stats.tx_msgs,
+		   kcm->stats.tx_bytes,
+		   kcm->sk.sk_receive_queue.qlen,
+		   kcm->sk.sk_write_queue.qlen);
+
+	if (kcm->tx_psock)
+		seq_puts(seq, "Psck ");
+
+	if (kcm->tx_wait)
+		seq_puts(seq, "TxWait ");
+
+	if (kcm->rx_wait)
+		seq_puts(seq, "RxWait ");
+
+	seq_puts(seq, "\n");
+}
+
+static void kcm_format_psock(struct kcm_psock *psock, struct seq_file *seq,
+			     int i, int *len)
+{
+	seq_printf(seq,
+		   "%-6s%-6s %-10llu %-16llu %-10llu %-16llu %-8d %-8d",
+		   "", "psock",
+		   psock->stats.rx_msgs,
+		   psock->stats.rx_bytes,
+		   psock->stats.tx_msgs,
+		   psock->stats.tx_bytes,
+		   psock->sk->sk_receive_queue.qlen,
+		   psock->sk->sk_write_queue.qlen);
+
+	if (psock->done)
+		seq_puts(seq, "Done ");
+
+	if (psock->tx_stopped)
+		seq_puts(seq, "TxStop ");
+
+	if (psock->rx_stopped)
+		seq_puts(seq, "RxStop ");
+
+	if (psock->tx_kcm)
+		seq_puts(seq, "Rsvd ");
+
+	if (psock->ready_rx_msg)
+		seq_puts(seq, "RdyRx ");
+
+	seq_puts(seq, "\n");
+}
+
+static void
+kcm_format_mux(struct kcm_mux *mux, loff_t idx, struct seq_file *seq)
+{
+	int i, len;
+	struct kcm_sock *kcm;
+	struct kcm_psock *psock;
+
+	/* mux information */
+	seq_printf(seq,
+		   "%-6s%-6s %-10llu %-16llu %-10llu %-16llu %-8s %-8s",
+		   "mux", "",
+		   mux->stats.tx_msgs,
+		   mux->stats.tx_bytes,
+		   mux->stats.rx_msgs,
+		   mux->stats.rx_bytes,
+		   "-", "-");
+
+	seq_printf(seq, "KCMs: %d, Psocks %d\n",
+		   mux->kcm_socks_cnt, mux->psocks_cnt);
+
+	/* kcm sock information */
+	i = 0;
+	spin_lock_bh(&mux->lock);
+	list_for_each_entry(kcm, &mux->kcm_socks, kcm_sock_list) {
+		kcm_format_sock(kcm, seq, i, &len);
+		i++;
+	}
+	i = 0;
+	list_for_each_entry(psock, &mux->psocks, psock_list) {
+		kcm_format_psock(psock, seq, i, &len);
+		i++;
+	}
+	spin_unlock_bh(&mux->lock);
+}
+
+static int kcm_seq_show(struct seq_file *seq, void *v)
+{
+	struct kcm_proc_mux_state *mux_state;
+
+	mux_state = seq->private;
+	if (v == SEQ_START_TOKEN) {
+		mux_state->idx = 0;
+		kcm_format_mux_header(seq);
+	} else {
+		kcm_format_mux(v, mux_state->idx, seq);
+		mux_state->idx++;
+	}
+	return 0;
+}
+
+static const struct file_operations kcm_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= kcm_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+};
+
+static struct kcm_seq_muxinfo kcm_seq_muxinfo = {
+	.name		= "kcm",
+	.seq_fops	= &kcm_seq_fops,
+	.seq_ops	= {
+		.show	= kcm_seq_show,
+		.start	= kcm_seq_start,
+		.next	= kcm_seq_next,
+		.stop	= kcm_seq_stop,
+	}
+};
+
+static int kcm_proc_register(struct net *net, struct kcm_seq_muxinfo *muxinfo)
+{
+	struct proc_dir_entry *p;
+	int rc = 0;
+
+	p = proc_create_data(muxinfo->name, S_IRUGO, net->proc_net,
+			     muxinfo->seq_fops, muxinfo);
+	if (!p)
+		rc = -ENOMEM;
+	return rc;
+}
+EXPORT_SYMBOL(kcm_proc_register);
+
+static void kcm_proc_unregister(struct net *net,
+				struct kcm_seq_muxinfo *muxinfo)
+{
+	remove_proc_entry(muxinfo->name, net->proc_net);
+}
+EXPORT_SYMBOL(kcm_proc_unregister);
+
+static int kcm_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct kcm_psock_stats psock_stats;
+	struct kcm_mux_stats mux_stats;
+	struct kcm_mux *mux;
+	struct kcm_psock *psock;
+	struct net *net = seq->private;
+	struct kcm_net *knet = net_generic(net, kcm_net_id);
+
+	memset(&mux_stats, 0, sizeof(mux_stats));
+	memset(&psock_stats, 0, sizeof(psock_stats));
+
+	mutex_lock(&knet->mutex);
+
+	aggregate_mux_stats(&knet->aggregate_mux_stats, &mux_stats);
+	aggregate_psock_stats(&knet->aggregate_psock_stats,
+			      &psock_stats);
+
+	list_for_each_entry_rcu(mux, &knet->mux_list, kcm_mux_list) {
+		spin_lock_bh(&mux->lock);
+		aggregate_mux_stats(&mux->stats, &mux_stats);
+		aggregate_psock_stats(&mux->aggregate_psock_stats,
+				      &psock_stats);
+		list_for_each_entry(psock, &mux->psocks, psock_list)
+			aggregate_psock_stats(&psock->stats, &psock_stats);
+		spin_unlock_bh(&mux->lock);
+	}
+
+	mutex_unlock(&knet->mutex);
+
+	seq_printf(seq,
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s\n",
+		   "MUX",
+		   "RX-Msgs",
+		   "RX-Bytes",
+		   "TX-Msgs",
+		   "TX-Bytes",
+		   "TX-NoPsock",
+		   "TX-Retries",
+		   "Attach",
+		   "Unattach",
+		   "UnattchRsvd",
+		   "RX-RdyDrops");
+
+	seq_printf(seq,
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10u %-10u %-10u %-10u %-10u %-10u\n",
+		   "",
+		   mux_stats.rx_msgs,
+		   mux_stats.rx_bytes,
+		   mux_stats.tx_msgs,
+		   mux_stats.tx_bytes,
+		   mux_stats.tx_no_psock,
+		   mux_stats.tx_retries,
+		   mux_stats.psock_attach,
+		   mux_stats.psock_unattach_rsvd,
+		   mux_stats.psock_unattach,
+		   mux_stats.rx_ready_drops);
+
+	seq_printf(seq,
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
+		   "Psock",
+		   "RX-Msgs",
+		   "RX-Bytes",
+		   "TX-Msgs",
+		   "TX-Bytes",
+		   "Reserved",
+		   "Unreserved",
+		   "RX-Aborts",
+		   "RX-MemFail",
+		   "RX-NeedMor",
+		   "RX-BadLen",
+		   "TX-Aborts");
+
+	seq_printf(seq,
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u\n",
+		   "",
+		   psock_stats.rx_msgs,
+		   psock_stats.rx_bytes,
+		   psock_stats.tx_msgs,
+		   psock_stats.tx_bytes,
+		   psock_stats.reserved,
+		   psock_stats.unreserved,
+		   psock_stats.rx_aborts,
+		   psock_stats.rx_mem_fail,
+		   psock_stats.rx_need_more_hdr,
+		   psock_stats.rx_bad_hdr_len,
+		   psock_stats.tx_aborts);
+
+	return 0;
+}
+
+static int kcm_stats_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open_net(inode, file, kcm_stats_seq_show);
+}
+
+static const struct file_operations kcm_stats_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = kcm_stats_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release_net,
+};
+
+static int kcm_proc_init_net(struct net *net)
+{
+	int err;
+
+	if (!proc_create("kcm_stats", S_IRUGO, net->proc_net,
+			 &kcm_stats_seq_fops)) {
+		err = -ENOMEM;
+		goto out_kcm_stats;
+	}
+
+	err = kcm_proc_register(net, &kcm_seq_muxinfo);
+	if (err)
+		goto out_kcm;
+
+	return 0;
+
+out_kcm:
+	remove_proc_entry("kcm_stats", net->proc_net);
+out_kcm_stats:
+	return err;
+}
+
+static void kcm_proc_exit_net(struct net *net)
+{
+	kcm_proc_unregister(net, &kcm_seq_muxinfo);
+	remove_proc_entry("kcm_stats", net->proc_net);
+}
+
+static struct pernet_operations kcm_net_ops = {
+	.init = kcm_proc_init_net,
+	.exit = kcm_proc_exit_net,
+};
+
+int __init kcm_proc_init(void)
+{
+	return register_pernet_subsys(&kcm_net_ops);
+}
+
+void __exit kcm_proc_exit(void)
+{
+	unregister_pernet_subsys(&kcm_net_ops);
+}
+
+#endif /* CONFIG_PROC_FS */
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 0240ce3..5508274 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -53,6 +53,7 @@ static void kcm_abort_rx_psock(struct kcm_psock *psock, int err,
 		return;
 
 	psock->rx_stopped = 1;
+	KCM_STATS_INCR(psock->stats.rx_aborts);
 
 	if (!skb)
 		return;
@@ -93,6 +94,7 @@ static void kcm_abort_tx_psock(struct kcm_psock *psock, int err,
 	}
 
 	psock->tx_stopped = 1;
+	KCM_STATS_INCR(psock->stats.tx_aborts);
 
 	if (!psock->tx_kcm) {
 		/* Take off psocks_avail list */
@@ -144,6 +146,9 @@ static bool new_rx_msg(struct kcm_psock *psock, struct sk_buff *head)
 		return false;
 	}
 
+	KCM_STATS_ADD(mux->stats.rx_bytes, kcm_rx_msg(head)->full_len);
+	KCM_STATS_INCR(mux->stats.rx_msgs);
+
 	if (list_empty(&mux->kcm_rx_waiters)) {
 		psock->ready_rx_msg = head;
 
@@ -263,6 +268,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 			skb = alloc_skb(0, GFP_ATOMIC);
 			if (!skb) {
+				KCM_STATS_INCR(psock->stats.rx_mem_fail);
 				desc->error = -ENOMEM;
 				return 0;
 			}
@@ -277,6 +283,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		} else {
 			err = skb_unclone(head, GFP_ATOMIC);
 			if (err) {
+				KCM_STATS_INCR(psock->stats.rx_mem_fail);
 				desc->error = err;
 				return 0;
 			}
@@ -289,11 +296,13 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		/* Always clone since we will consume something */
 		skb = skb_clone(orig_skb, GFP_ATOMIC);
 		if (!skb) {
+			KCM_STATS_INCR(psock->stats.rx_mem_fail);
 			desc->error = -ENOMEM;
 			break;
 		}
 
 		if (!pskb_pull(skb, offset + eaten)) {
+			KCM_STATS_INCR(psock->stats.rx_mem_fail);
 			kfree_skb(skb);
 			desc->error = -ENOMEM;
 			break;
@@ -308,6 +317,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		/* Need to trim should be rare */
 		err = pskb_trim(skb, orig_len - eaten);
 		if (err) {
+			KCM_STATS_INCR(psock->stats.rx_mem_fail);
 			kfree_skb(skb);
 			desc->error = err;
 			break;
@@ -342,11 +352,13 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 			if (!len) {
 				/* Need more header to determine length */
+				KCM_STATS_INCR(psock->stats.rx_need_more_hdr);
 				break;
 			} else if (len <= head->len - skb->len) {
 				/* Length must be into new skb (and also
 				 * greater than zero)
 				 */
+				KCM_STATS_INCR(psock->stats.rx_bad_hdr_len);
 				desc->error = -EPROTO;
 				psock->rx_skb_head = NULL;
 				kcm_abort_rx_psock(psock, EPROTO, head);
@@ -376,6 +388,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 		/* Hurray, we have a new message! */
 		psock->rx_skb_head = NULL;
+		KCM_STATS_INCR(psock->stats.rx_msgs);
 
 		if (new_rx_msg(psock, head)) {
 			/* Message was held at psock */
@@ -383,6 +396,8 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		}
 	}
 
+	KCM_STATS_ADD(psock->stats.rx_bytes, eaten);
+
 	return eaten;
 }
 
@@ -512,6 +527,9 @@ static struct kcm_psock *reserve_psock(struct kcm_sock *kcm,
 		}
 		kcm->tx_psock = psock;
 		psock->tx_kcm = kcm;
+		KCM_STATS_INCR(psock->stats.reserved);
+		psock->saved_tx_bytes = psock->stats.tx_bytes;
+		psock->saved_tx_msgs = psock->stats.tx_msgs;
 	} else if (kcm->tx_wait) {
 		err = -EAGAIN;
 	} else {
@@ -521,6 +539,7 @@ static struct kcm_psock *reserve_psock(struct kcm_sock *kcm,
 			kcm->tx_wait = 1;
 			err = -EAGAIN;
 		} else {
+			KCM_STATS_INCR(mux->stats.tx_no_psock);
 			err = -EPIPE;
 		}
 	}
@@ -548,6 +567,9 @@ static void psock_now_avail(struct kcm_psock *psock)
 		kcm->tx_wait = 0;
 		kcm->tx_psock = psock;
 		psock->tx_kcm = kcm;
+		KCM_STATS_INCR(psock->stats.reserved);
+		psock->saved_tx_bytes = psock->stats.tx_bytes;
+		psock->saved_tx_msgs = psock->stats.tx_msgs;
 		queue_work(kcm_wq, &kcm->tx_work);
 	}
 }
@@ -563,10 +585,16 @@ static void unreserve_psock(struct kcm_sock *kcm)
 
 	spin_lock_bh(&mux->lock);
 
+	KCM_STATS_ADD(mux->stats.tx_bytes,
+		      psock->stats.tx_bytes - psock->saved_tx_bytes);
+	mux->stats.tx_msgs +=
+		psock->stats.tx_msgs - psock->saved_tx_msgs;
+
 	WARN_ON(kcm->tx_wait);
 
 	kcm->tx_psock = NULL;
 	psock->tx_kcm = NULL;
+	KCM_STATS_INCR(psock->stats.unreserved);
 
 	if (unlikely(psock->done || psock->tx_stopped)) {
 		if (psock->done) {
@@ -590,6 +618,15 @@ static void unreserve_psock(struct kcm_sock *kcm)
 	spin_unlock_bh(&mux->lock);
 }
 
+static void kcm_report_tx_retry(struct kcm_sock *kcm)
+{
+	struct kcm_mux *mux = kcm->mux;
+
+	spin_lock_bh(&mux->lock);
+	KCM_STATS_INCR(mux->stats.tx_retries);
+	spin_unlock_bh(&mux->lock);
+}
+
 /* Write any messages ready on the kcm socket.  Called with kcm sock lock
  * held.  Return bytes actually sent or error.
  */
@@ -616,6 +653,7 @@ static int kcm_write_msgs(struct kcm_sock *kcm)
 		 * it and we'll retry the message.
 		 */
 		unreserve_psock(kcm);
+		kcm_report_tx_retry(kcm);
 		txm->sent = 0;
 	} else if (txm->sent) {
 		/* Send of first skbuff in queue already in progress */
@@ -690,12 +728,14 @@ do_frag:
 				unreserve_psock(kcm);
 
 				txm->sent = 0;
+				kcm_report_tx_retry(kcm);
 
 				goto try_again;
 			}
 
 			sent += ret;
 			frag_offset += ret;
+			KCM_STATS_ADD(psock->stats.tx_bytes, ret);
 			if (frag_offset < frag->size) {
 				/* Not finished with this frag */
 				goto do_frag;
@@ -717,6 +757,7 @@ do_frag:
 		kfree_skb(head);
 		sk->sk_wmem_queued -= sent;
 		total_sent += sent;
+		KCM_STATS_INCR(psock->stats.tx_msgs);
 	} while ((head = skb_peek(&sk->sk_write_queue)));
 out:
 	if (!head) {
@@ -901,6 +942,9 @@ static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	/* Everything seems okay */
 
+	KCM_STATS_ADD(kcm->stats.tx_bytes, total_len);
+	KCM_STATS_INCR(kcm->stats.tx_msgs);
+
 	release_sock(sk);
 	return total_len;
 
@@ -987,6 +1031,8 @@ static int kcm_recvmsg(struct socket *sock,
 	copied = len;
 	if (likely(!(flags & MSG_PEEK))) {
 		/* Finished with message */
+		KCM_STATS_ADD(kcm->stats.rx_bytes, copied);
+		KCM_STATS_INCR(kcm->stats.rx_msgs);
 		skb_unlink(skb, &sk->sk_receive_queue);
 		kfree_skb(skb);
 	}
@@ -1058,6 +1104,7 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 
 	/* Finished initialization, now add the psock to the MUX. */
 	spin_lock_bh(&mux->lock);
+	KCM_STATS_INCR(mux->stats.psock_attach);
 	list_add_tail(&psock->psock_list, &mux->psocks);
 	mux->psocks_cnt++;
 	psock_now_avail(psock);
@@ -1154,14 +1201,19 @@ static void kcm_unattach(struct kcm_psock *psock)
 		list_del(&psock->psock_ready_list);
 		kfree_skb(psock->ready_rx_msg);
 		psock->ready_rx_msg = NULL;
+		KCM_STATS_INCR(mux->stats.rx_ready_drops);
 	}
 
+	KCM_STATS_INCR(mux->stats.psock_unattach);
+	aggregate_psock_stats(&psock->stats, &mux->aggregate_psock_stats);
+
 	if (psock->tx_kcm) {
 		/* psock was reserved.  Just mark it finished and we will clean
 		 * up in the kcm paths, we need kcm lock which can not be
 		 * acquired here.
 		 */
 		psock->done = 1;
+		KCM_STATS_INCR(mux->stats.psock_unattach_rsvd);
 		spin_unlock_bh(&mux->lock);
 		kcm_abort_tx_psock(psock, EPIPE, true, true);
 	} else {
@@ -1283,6 +1335,9 @@ static void release_mux(struct kcm_mux *mux)
 		return;
 
 	mutex_lock(&knet->mutex);
+	aggregate_mux_stats(&mux->stats, &knet->aggregate_mux_stats);
+	aggregate_psock_stats(&mux->aggregate_psock_stats,
+			      &knet->aggregate_psock_stats);
 	list_del_rcu(&mux->kcm_mux_list);
 	knet->count--;
 	mutex_unlock(&knet->mutex);
@@ -1529,8 +1584,15 @@ static int __init kcm_init(void)
 	if (err)
 		goto net_ops_fail;
 
+	err = kcm_proc_init();
+	if (err)
+		goto proc_init_fail;
+
 	return 0;
 
+proc_init_fail:
+	unregister_pernet_device(&kcm_net_ops);
+
 net_ops_fail:
 	sock_unregister(PF_KCM);
 
@@ -1549,6 +1611,7 @@ fail:
 
 static void __exit kcm_exit(void)
 {
+	kcm_proc_exit();
 	unregister_pernet_device(&kcm_net_ops);
 	sock_unregister(PF_KCM);
 	proto_unregister(&kcm_proto);
-- 
1.8.1
