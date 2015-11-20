From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/6] kcm: Add statistics and proc interfaces
Date: Fri, 20 Nov 2015 13:21:59 -0800
Message-ID: <1448054520-1464587-6-git-send-email-tom@herbertland.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davewatson@fb.com>,
	<alexei.starovoitov@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60758 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934593AbbKTVW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 16:22:28 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAKLIbwZ028182
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9us1bn3n-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 13:22:28 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 cc2cfb048fcc11e5bc8d24be0595f910-165fb230 for <netdev@vger.kernel.org>;	Fri,
 20 Nov 2015 13:22:27 -0800
In-Reply-To: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds various counters for KCM. These include counters for
messages and bytes received or sent, as well as counters for number of
attached/unattached TCP sockets and other error or edge events.

The statistics are exposed via a proc interface. /proc/net/kcm provides
statistics per KCM socket and per psock (attached TCP sockets).
/proc/net/kcm_stats provides aggregate statistics.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/kcm.h | 102 +++++++++++++
 net/kcm/Makefile  |   2 +-
 net/kcm/kcmproc.c | 422 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/kcm/kcmsock.c |  66 +++++++++
 4 files changed, 591 insertions(+), 1 deletion(-)
 create mode 100644 net/kcm/kcmproc.c

diff --git a/include/net/kcm.h b/include/net/kcm.h
index 4f371fe..83b4f91 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -11,6 +11,45 @@
 
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
@@ -35,6 +74,8 @@ struct kcm_sock {
 	u32 done : 1;
 	struct work_struct done_work;
 
+	struct kcm_stats stats;
+
 	/* Transmit */
 	struct kcm_psock *tx_psock;
 	struct work_struct tx_work;
@@ -71,6 +112,8 @@ struct kcm_psock {
 
 	struct list_head psock_list;
 
+	struct kcm_psock_stats stats;
+
 	/* Receive */
 	struct sk_buff *rx_skb_head;
 	struct sk_buff **rx_skb_nextp;
@@ -80,15 +123,21 @@ struct kcm_psock {
 	struct delayed_work rx_delayed_work;
 	struct bpf_prog *bpf_prog;
 	struct kcm_sock *rx_kcm;
+	unsigned long long saved_rx_bytes;
+	unsigned long long saved_rx_msgs;
 
 	/* Transmit */
 	struct kcm_sock *tx_kcm;
 	struct list_head psock_avail_list;
+	unsigned long long saved_tx_bytes;
+	unsigned long long saved_tx_msgs;
 };
 
 /* Per net MUX list */
 struct kcm_net {
 	struct mutex mutex;
+	struct kcm_psock_stats aggregate_psock_stats;
+	struct kcm_mux_stats aggregate_mux_stats;
 	struct list_head mux_list;
 	int count;
 };
@@ -104,6 +153,9 @@ struct kcm_mux {
 	struct list_head psocks;	/* List of all psocks on MUX */
 	int psocks_cnt;		/* Total attached sockets */
 
+	struct kcm_mux_stats stats;
+	struct kcm_psock_stats aggregate_psock_stats;
+
 	/* Receive */
 	spinlock_t rx_lock ____cacheline_aligned_in_smp;
 	struct list_head kcm_rx_waiters; /* KCMs waiting for receiving */
@@ -116,6 +168,56 @@ struct kcm_mux {
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
index 0000000..5eb9809
--- /dev/null
+++ b/net/kcm/kcmproc.c
@@ -0,0 +1,422 @@
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
+	const struct seq_operations	seq_ops;
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
+	list_for_each_entry_rcu(m, &knet->mux_list, kcm_mux_list) {
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
+		   "%-14s %-10s %-16s %-10s %-16s %-8s %-8s %-8s %-8s %s",
+		   "Object",
+		   "RX-Msgs",
+		   "RX-Bytes",
+		   "TX-Msgs",
+		   "TX-Bytes",
+		   "Recv-Q",
+		   "Rmem",
+		   "Send-Q",
+		   "Smem",
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
+		   "   kcm-%-7u %-10llu %-16llu %-10llu %-16llu %-8d %-8d %-8d %-8s ",
+		   kcm->index,
+		   kcm->stats.rx_msgs,
+		   kcm->stats.rx_bytes,
+		   kcm->stats.tx_msgs,
+		   kcm->stats.tx_bytes,
+		   kcm->sk.sk_receive_queue.qlen,
+		   sk_rmem_alloc_get(&kcm->sk),
+		   kcm->sk.sk_write_queue.qlen,
+		   "-");
+
+	if (kcm->tx_psock)
+		seq_printf(seq, "Psck-%u ", kcm->tx_psock->index);
+
+	if (kcm->tx_wait)
+		seq_puts(seq, "TxWait ");
+
+	if (kcm->tx_wait_more)
+		seq_puts(seq, "WMore ");
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
+		   "   psock-%-5u %-10llu %-16llu %-10llu %-16llu %-8d %-8d %-8d %-8d ",
+		   psock->index,
+		   psock->stats.rx_msgs,
+		   psock->stats.rx_bytes,
+		   psock->stats.tx_msgs,
+		   psock->stats.tx_bytes,
+		   psock->sk->sk_receive_queue.qlen,
+		   atomic_read(&psock->sk->sk_rmem_alloc),
+		   psock->sk->sk_write_queue.qlen,
+		   atomic_read(&psock->sk->sk_wmem_alloc));
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
+		seq_printf(seq, "Rsvd-%d ", psock->tx_kcm->index);
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
+		   "%-6s%-8s %-10llu %-16llu %-10llu %-16llu %-8s %-8s %-8s %-8s ",
+		   "mux", "",
+		   mux->stats.rx_msgs,
+		   mux->stats.rx_bytes,
+		   mux->stats.tx_msgs,
+		   mux->stats.tx_bytes,
+		   "-", "-", "-", "-");
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
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s\n",
+		   "MUX",
+		   "RX-Msgs",
+		   "RX-Bytes",
+		   "TX-Msgs",
+		   "TX-Bytes",
+		   "TX-Retries",
+		   "Attach",
+		   "Unattach",
+		   "UnattchRsvd",
+		   "RX-RdyDrops");
+
+	seq_printf(seq,
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10u %-10u %-10u %-10u %-10u\n",
+		   "",
+		   mux_stats.rx_msgs,
+		   mux_stats.rx_bytes,
+		   mux_stats.tx_msgs,
+		   mux_stats.tx_bytes,
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
index 061263a..451b504 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -58,6 +58,7 @@ static void kcm_abort_rx_psock(struct kcm_psock *psock, int err,
 		return;
 
 	psock->rx_stopped = 1;
+	KCM_STATS_INCR(psock->stats.rx_aborts);
 
 	/* Report an error on the lower socket */
 	report_csk_error(csk, err);
@@ -79,6 +80,7 @@ static void kcm_abort_tx_psock(struct kcm_psock *psock, int err,
 	}
 
 	psock->tx_stopped = 1;
+	KCM_STATS_INCR(psock->stats.tx_aborts);
 
 	if (!psock->tx_kcm) {
 		/* Take off psocks_avail list */
@@ -291,6 +293,13 @@ static void unreserve_rx_kcm(struct kcm_psock *psock,
 
 	spin_lock_bh(&mux->rx_lock);
 
+	KCM_STATS_ADD(mux->stats.rx_bytes,
+		      psock->stats.rx_bytes - psock->saved_rx_bytes);
+	mux->stats.rx_msgs +=
+		psock->stats.rx_msgs - psock->saved_rx_msgs;
+	psock->saved_rx_msgs = psock->stats.rx_msgs;
+	psock->saved_rx_bytes = psock->stats.rx_bytes;
+
 	psock->rx_kcm = NULL;
 	kcm->rx_psock = NULL;
 
@@ -353,6 +362,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 			skb = alloc_skb(0, GFP_ATOMIC);
 			if (!skb) {
+				KCM_STATS_INCR(psock->stats.rx_mem_fail);
 				desc->error = -ENOMEM;
 				return 0;
 			}
@@ -367,6 +377,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		} else {
 			err = skb_unclone(head, GFP_ATOMIC);
 			if (err) {
+				KCM_STATS_INCR(psock->stats.rx_mem_fail);
 				desc->error = err;
 				return 0;
 			}
@@ -379,11 +390,13 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
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
@@ -398,6 +411,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		/* Need to trim, should be rare? */
 		err = pskb_trim(skb, orig_len - eaten);
 		if (err) {
+			KCM_STATS_INCR(psock->stats.rx_mem_fail);
 			kfree_skb(skb);
 			desc->error = err;
 			break;
@@ -432,11 +446,13 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
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
@@ -466,6 +482,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 		/* Hurray, we have a new message! */
 		psock->rx_skb_head = NULL;
+		KCM_STATS_INCR(psock->stats.rx_msgs);
 
 try_queue:
 		kcm = reserve_rx_kcm(psock, head);
@@ -481,6 +498,8 @@ try_queue:
 		}
 	}
 
+	KCM_STATS_ADD(psock->stats.rx_bytes, eaten);
+
 	return eaten;
 }
 
@@ -642,6 +661,7 @@ static struct kcm_psock *reserve_psock(struct kcm_sock *kcm)
 		}
 		kcm->tx_psock = psock;
 		psock->tx_kcm = kcm;
+		KCM_STATS_INCR(psock->stats.reserved);
 	} else if (!kcm->tx_wait) {
 		list_add_tail(&kcm->wait_psock_list,
 			      &mux->kcm_tx_waiters);
@@ -676,6 +696,7 @@ static void psock_now_avail(struct kcm_psock *psock)
 		smp_mb();
 
 		kcm->tx_psock = psock;
+		KCM_STATS_INCR(psock->stats.reserved);
 		queue_work(kcm_wq, &kcm->tx_work);
 	}
 }
@@ -697,10 +718,18 @@ static void unreserve_psock(struct kcm_sock *kcm)
 
 	smp_rmb(); /* Read tx_psock before tx_wait */
 
+	KCM_STATS_ADD(mux->stats.tx_bytes,
+		      psock->stats.tx_bytes - psock->saved_tx_bytes);
+	mux->stats.tx_msgs +=
+		psock->stats.tx_msgs - psock->saved_tx_msgs;
+	psock->saved_tx_msgs = psock->stats.tx_msgs;
+	psock->saved_tx_bytes = psock->stats.tx_bytes;
+
 	WARN_ON(kcm->tx_wait);
 
 	kcm->tx_psock = NULL;
 	psock->tx_kcm = NULL;
+	KCM_STATS_INCR(psock->stats.unreserved);
 
 	if (unlikely(psock->tx_stopped)) {
 		if (psock->done) {
@@ -724,6 +753,15 @@ static void unreserve_psock(struct kcm_sock *kcm)
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
@@ -744,6 +782,7 @@ static int kcm_write_msgs(struct kcm_sock *kcm)
 		 * it and we'll retry the message.
 		 */
 		unreserve_psock(kcm);
+		kcm_report_tx_retry(kcm);
 		if (skb_queue_empty(&sk->sk_write_queue))
 			return 0;
 
@@ -827,6 +866,7 @@ do_frag:
 				unreserve_psock(kcm);
 
 				txm->sent = 0;
+				kcm_report_tx_retry(kcm);
 				ret = 0;
 
 				goto try_again;
@@ -834,6 +874,7 @@ do_frag:
 
 			sent += ret;
 			frag_offset += ret;
+			KCM_STATS_ADD(psock->stats.tx_bytes, ret);
 			if (frag_offset < frag->size) {
 				/* Not finished with this frag */
 				goto do_frag;
@@ -855,6 +896,7 @@ do_frag:
 		kfree_skb(head);
 		sk->sk_wmem_queued -= sent;
 		total_sent += sent;
+		KCM_STATS_INCR(psock->stats.tx_msgs);
 	} while ((head = skb_peek(&sk->sk_write_queue)));
 out:
 	if (!head) {
@@ -1031,6 +1073,7 @@ wait_for_memory:
 		/* Message complete, queue it on send buffer */
 		__skb_queue_tail(&sk->sk_write_queue, head);
 		kcm->seq_skb = NULL;
+		KCM_STATS_INCR(kcm->stats.tx_msgs);
 
 		if (msg->msg_flags & MSG_BATCH) {
 			kcm->tx_wait_more = true;
@@ -1053,6 +1096,8 @@ partial_message:
 		kcm_tx_msg(head)->last_skb = skb;
 	}
 
+	KCM_STATS_ADD(kcm->stats.tx_bytes, copied);
+
 	release_sock(sk);
 	return copied;
 
@@ -1083,6 +1128,7 @@ static int kcm_recvmsg(struct socket *sock, struct msghdr *msg,
 		       size_t len, int flags)
 {
 	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
 	int err = 0;
 	long timeo;
 	struct kcm_rx_msg *rxm;
@@ -1129,6 +1175,7 @@ static int kcm_recvmsg(struct socket *sock, struct msghdr *msg,
 
 	copied = len;
 	if (likely(!(flags & MSG_PEEK))) {
+		KCM_STATS_ADD(kcm->stats.rx_bytes, copied);
 		if (copied < rxm->full_len) {
 			if (sock->type == SOCK_DGRAM) {
 				/* Truncated message */
@@ -1141,6 +1188,7 @@ static int kcm_recvmsg(struct socket *sock, struct msghdr *msg,
 msg_finished:
 			/* Finished with message */
 			msg->msg_flags |= MSG_EOR;
+			KCM_STATS_INCR(kcm->stats.rx_msgs);
 			skb_unlink(skb, &sk->sk_receive_queue);
 			kfree_skb(skb);
 		}
@@ -1352,6 +1400,7 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	list_add(&psock->psock_list, head);
 	psock->index = index;
 
+	KCM_STATS_INCR(mux->stats.psock_attach);
 	mux->psocks_cnt++;
 	psock_now_avail(psock);
 	spin_unlock_bh(&mux->lock);
@@ -1427,6 +1476,7 @@ static void kcm_unattach(struct kcm_psock *psock)
 		list_del(&psock->psock_ready_list);
 		kfree_skb(psock->ready_rx_msg);
 		psock->ready_rx_msg = NULL;
+		KCM_STATS_INCR(mux->stats.rx_ready_drops);
 	}
 
 	spin_unlock_bh(&mux->rx_lock);
@@ -1443,11 +1493,16 @@ static void kcm_unattach(struct kcm_psock *psock)
 
 	spin_lock_bh(&mux->lock);
 
+	aggregate_psock_stats(&psock->stats, &mux->aggregate_psock_stats);
+
+	KCM_STATS_INCR(mux->stats.psock_unattach);
+
 	if (psock->tx_kcm) {
 		/* psock was reserved.  Just mark it finished and we will clean
 		 * up in the kcm paths, we need kcm lock which can not be
 		 * acquired here.
 		 */
+		KCM_STATS_INCR(mux->stats.psock_unattach_rsvd);
 		spin_unlock_bh(&mux->lock);
 
 		/* We are unattaching a socket that is reserved. Abort the
@@ -1675,6 +1730,9 @@ static void release_mux(struct kcm_mux *mux)
 	__skb_queue_purge(&mux->rx_hold_queue);
 
 	mutex_lock(&knet->mutex);
+	aggregate_mux_stats(&mux->stats, &knet->aggregate_mux_stats);
+	aggregate_psock_stats(&mux->aggregate_psock_stats,
+			      &knet->aggregate_psock_stats);
 	list_del_rcu(&mux->kcm_mux_list);
 	knet->count--;
 	mutex_unlock(&knet->mutex);
@@ -1937,8 +1995,15 @@ static int __init kcm_init(void)
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
 
@@ -1957,6 +2022,7 @@ fail:
 
 static void __exit kcm_exit(void)
 {
+	kcm_proc_exit();
 	unregister_pernet_device(&kcm_net_ops);
 	sock_unregister(PF_KCM);
 	proto_unregister(&kcm_proto);
-- 
2.4.6
