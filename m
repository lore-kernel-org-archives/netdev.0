From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [NET] Sparse annotations
Date: Wed, 02 Jan 2008 06:50:14 +0100
Message-ID: <477B2616.4090409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060801040200020807010009"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37440 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbYABFu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:50:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060801040200020807010009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Add __acquires() and __releases() annotations to suppress some sparse warnings.

example of warnings :

net/ipv4/udp.c:1555:14: warning: context imbalance in 'udp_seq_start' - wrong 
count at exit
net/ipv4/udp.c:1571:13: warning: context imbalance in 'udp_seq_stop' - 
unexpected unlock


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/core/dev.c             |    2 ++
  net/core/dev_mcast.c       |    2 ++
  net/core/gen_stats.c       |    1 +
  net/core/neighbour.c       |    2 ++
  net/core/sock.c            |    2 ++
  net/ipv4/fib_hash.c        |    2 ++
  net/ipv4/inet_hashtables.c |    1 +
  net/ipv4/udp.c             |    2 ++
  net/ipv6/anycast.c         |    2 ++
  net/ipv6/ip6_flowlabel.c   |    2 ++
  net/ipv6/mcast.c           |    4 ++++
  net/netlink/af_netlink.c   |    4 ++++
  net/sched/sch_generic.c    |    4 ++++
  net/sunrpc/cache.c         |    2 ++
  net/unix/af_unix.c         |    2 ++
  net/xfrm/xfrm_state.c      |    2 ++
  16 files changed, 36 insertions(+)


--------------060801040200020807010009
Content-Type: text/plain;
 name="net_sparse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net_sparse.patch"

diff --git a/net/core/dev.c b/net/core/dev.c
index aca6dad..ea43c02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2364,6 +2364,7 @@ static int dev_ifconf(struct net *net, char __user *arg)
  *	in detail.
  */
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	struct net *net = seq_file_net(seq);
 	loff_t off;
@@ -2390,6 +2391,7 @@ void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	read_unlock(&dev_base_lock);
 }
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 63f0b33..cadbfbf 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -186,6 +186,7 @@ EXPORT_SYMBOL(dev_mc_unsync);
 
 #ifdef CONFIG_PROC_FS
 static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	struct net *net = seq_file_net(seq);
 	struct net_device *dev;
@@ -206,6 +207,7 @@ static void *dev_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void dev_mc_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	read_unlock(&dev_base_lock);
 }
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index bcc2559..8073561 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -55,6 +55,7 @@ rtattr_failure:
 int
 gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
+	__acquires(lock)
 {
 	memset(d, 0, sizeof(*d));
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index bd899d5..8024933 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2313,6 +2313,7 @@ static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
 }
 
 void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl, unsigned int neigh_seq_flags)
+	__acquires(tbl->lock)
 {
 	struct neigh_seq_state *state = seq->private;
 	loff_t pos_minus_one;
@@ -2356,6 +2357,7 @@ out:
 EXPORT_SYMBOL(neigh_seq_next);
 
 void neigh_seq_stop(struct seq_file *seq, void *v)
+	__releases(tbl->lock)
 {
 	struct neigh_seq_state *state = seq->private;
 	struct neigh_table *tbl = state->tbl;
diff --git a/net/core/sock.c b/net/core/sock.c
index 3804e7d..3d7757e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2025,6 +2025,7 @@ EXPORT_SYMBOL(proto_unregister);
 
 #ifdef CONFIG_PROC_FS
 static void *proto_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(proto_list_lock)
 {
 	read_lock(&proto_list_lock);
 	return seq_list_start_head(&proto_list, *pos);
@@ -2036,6 +2037,7 @@ static void *proto_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void proto_seq_stop(struct seq_file *seq, void *v)
+	__releases(proto_list_lock)
 {
 	read_unlock(&proto_list_lock);
 }
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 481de47..d32385c 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -935,6 +935,7 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(fib_hash_lock)
 {
 	void *v = NULL;
 
@@ -951,6 +952,7 @@ static void *fib_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void fib_seq_stop(struct seq_file *seq, void *v)
+	__releases(fib_hash_lock)
 {
 	read_unlock(&fib_hash_lock);
 }
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 2e5814a..88a059e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -96,6 +96,7 @@ EXPORT_SYMBOL(inet_put_port);
  * exclusive lock release). It should be ifdefed really.
  */
 void inet_listen_wlock(struct inet_hashinfo *hashinfo)
+	__acquires(hashinfo->lhash_lock)
 {
 	write_lock(&hashinfo->lhash_lock);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3532843..02fcccd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1550,6 +1550,7 @@ static struct sock *udp_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(udp_hash_lock)
 {
 	read_lock(&udp_hash_lock);
 	return *pos ? udp_get_idx(seq, *pos-1) : (void *)1;
@@ -1569,6 +1570,7 @@ static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void udp_seq_stop(struct seq_file *seq, void *v)
+	__releases(udp_hash_lock)
 {
 	read_unlock(&udp_hash_lock);
 }
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index f915c4d..5c41900 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -504,6 +504,7 @@ static struct ifacaddr6 *ac6_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *ac6_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	read_lock(&dev_base_lock);
 	return ac6_get_idx(seq, *pos);
@@ -518,6 +519,7 @@ static void *ac6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ac6_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	struct ac6_iter_state *state = ac6_seq_private(seq);
 	if (likely(state->idev != NULL)) {
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index d0babea..2b7d9ee 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -629,6 +629,7 @@ static struct ip6_flowlabel *ip6fl_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *ip6fl_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(ip6_fl_lock)
 {
 	read_lock_bh(&ip6_fl_lock);
 	return *pos ? ip6fl_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -647,6 +648,7 @@ static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ip6fl_seq_stop(struct seq_file *seq, void *v)
+	__releases(ip6_fl_lock)
 {
 	read_unlock_bh(&ip6_fl_lock);
 }
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 82b1294..ab228d1 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2373,6 +2373,7 @@ static struct ifmcaddr6 *igmp6_mc_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	read_lock(&dev_base_lock);
 	return igmp6_mc_get_idx(seq, *pos);
@@ -2387,6 +2388,7 @@ static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void igmp6_mc_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 	if (likely(state->idev != NULL)) {
@@ -2516,6 +2518,7 @@ static struct ip6_sf_list *igmp6_mcf_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	read_lock(&dev_base_lock);
 	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -2533,6 +2536,7 @@ static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
 	if (likely(state->im != NULL)) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index dbd7cad..be07f1b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -171,6 +171,7 @@ static void netlink_sock_destruct(struct sock *sk)
  */
 
 static void netlink_table_grab(void)
+	__acquires(nl_table_lock)
 {
 	write_lock_irq(&nl_table_lock);
 
@@ -193,6 +194,7 @@ static void netlink_table_grab(void)
 }
 
 static inline void netlink_table_ungrab(void)
+	__releases(nl_table_lock)
 {
 	write_unlock_irq(&nl_table_lock);
 	wake_up(&nl_table_wait);
@@ -1728,6 +1730,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *netlink_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(nl_table_lock)
 {
 	read_lock(&nl_table_lock);
 	return *pos ? netlink_seq_socket_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -1776,6 +1779,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void netlink_seq_stop(struct seq_file *seq, void *v)
+	__releases(nl_table_lock)
 {
 	read_unlock(&nl_table_lock);
 }
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9be2f15..ea5a05b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -40,12 +40,16 @@
  */
 
 void qdisc_lock_tree(struct net_device *dev)
+	__acquires(dev->queue_lock)
+	__acquires(dev->ingress_lock)
 {
 	spin_lock_bh(&dev->queue_lock);
 	spin_lock(&dev->ingress_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
+	__releases(dev->ingress_lock)
+	__releases(dev->queue_lock)
 {
 	spin_unlock(&dev->ingress_lock);
 	spin_unlock_bh(&dev->queue_lock);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8e05557..73f053d 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1127,6 +1127,7 @@ struct handle {
 };
 
 static void *c_start(struct seq_file *m, loff_t *pos)
+	__acquires(cd->hash_lock)
 {
 	loff_t n = *pos;
 	unsigned hash, entry;
@@ -1183,6 +1184,7 @@ static void *c_next(struct seq_file *m, void *p, loff_t *pos)
 }
 
 static void c_stop(struct seq_file *m, void *p)
+	__releases(cd->hash_lock)
 {
 	struct cache_detail *cd = ((struct handle*)m->private)->cd;
 	read_unlock(&cd->hash_lock);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 63a9239..eea7588 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2033,6 +2033,7 @@ static struct sock *unix_seq_idx(struct unix_iter_state *iter, loff_t pos)
 
 
 static void *unix_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(unix_table_lock)
 {
 	struct unix_iter_state *iter = seq->private;
 	spin_lock(&unix_table_lock);
@@ -2055,6 +2056,7 @@ static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void unix_seq_stop(struct seq_file *seq, void *v)
+	__releases(unix_table_lock)
 {
 	spin_unlock(&unix_table_lock);
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 8a9166c..4dec655 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -211,6 +211,7 @@ static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
 }
 
 static void xfrm_state_unlock_afinfo(struct xfrm_state_afinfo *afinfo)
+	__releases(xfrm_state_afinfo_lock)
 {
 	write_unlock_bh(&xfrm_state_afinfo_lock);
 }
@@ -1907,6 +1908,7 @@ static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 }
 
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
+	__releases(xfrm_state_afinfo_lock)
 {
 	read_unlock(&xfrm_state_afinfo_lock);
 }

--------------060801040200020807010009--
