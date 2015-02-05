From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 27/29] net: vrf: Add vrf checks and context to ipv4 proc files
Date: Wed,  4 Feb 2015 18:34:28 -0700
Message-ID: <1423100070-31848-28-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:53275 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756391AbbBEBgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:17 -0500
Received: by mail-ie0-f181.google.com with SMTP id rd18so6678454iec.12
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:16 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/fib_trie.c | 24 ++++++++++++++++++------
 net/ipv4/proc.c     | 10 +++++-----
 net/ipv4/raw.c      |  7 ++++---
 net/ipv4/route.c    |  2 +-
 net/ipv4/tcp_ipv4.c | 15 ++++++++-------
 net/ipv4/udp.c      |  6 +++---
 6 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3daf0224ff2e..a3ff1100dc2a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1439,6 +1439,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			}
 			if (fi->fib_flags & RTNH_F_DEAD)
 				continue;
+			if (!vrf_eq(fi->fib_net_ctx.vrf, flp->flowi4_vrf))
+				continue;
 			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
 				const struct fib_nh *nh = &fi->fib_nh[nhsel];
 
@@ -1738,6 +1740,7 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 	int i, s_i;
 	struct fib_alias *fa;
 	__be32 xkey = htonl(key);
+	__u32 vrf = skb->sk->sk_vrf;
 
 	s_i = cb->args[5];
 	i = 0;
@@ -1750,6 +1753,10 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 			continue;
 		}
 
+		 if (!vrf_eq(fa->fa_info->fib_net_ctx.vrf, vrf) &&
+		     !vrf_is_any(vrf))
+			continue;
+
 		if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq,
 				  RTM_NEWROUTE,
@@ -2078,7 +2085,7 @@ static void fib_table_print(struct seq_file *seq, struct fib_table *tb)
 
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = (struct net *)seq->private;
+	struct net *net = seq_file_net(seq);
 	unsigned int h;
 
 	seq_printf(seq,
@@ -2414,11 +2421,12 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 {
 	struct tnode *l = v;
 	struct leaf_info *li;
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-127s\n", "Iface\tDestination\tGateway "
 			   "\tFlags\tRefCnt\tUse\tMetric\tMask\t\tMTU"
-			   "\tWindow\tIRTT");
+			   "\tWindow\tIRTT\tvrf");
 		return 0;
 	}
 
@@ -2439,10 +2447,13 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 
 			seq_setwidth(seq, 127);
 
+			if (fi && !vrf_eq_or_any(fi->fib_vrf, ctx->vrf))
+				continue;
+
 			if (fi)
 				seq_printf(seq,
 					 "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u",
+					 "%d\t%08X\t%d\t%u\t%u\t%u",
 					 fi->fib_dev ? fi->fib_dev->name : "*",
 					 prefix,
 					 fi->fib_nh->nh_gw, flags, 0, 0,
@@ -2451,13 +2462,14 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 					 (fi->fib_advmss ?
 					  fi->fib_advmss + 40 : 0),
 					 fi->fib_window,
-					 fi->fib_rtt >> 3);
+					 fi->fib_rtt >> 3,
+					 fi->fib_vrf);
 			else
 				seq_printf(seq,
 					 "*\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u",
+					 "%d\t%08X\t%d\t%u\t%u\t%u",
 					 prefix, 0, flags, 0, 0, 0,
-					 mask, 0, 0, 0);
+					 mask, 0, 0, 0, 0);
 
 			seq_pad(seq, '\n');
 		}
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8f9cd200ce20..721dd600d722 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -51,7 +51,7 @@
  */
 static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 	unsigned int frag_mem;
 	int orphans, sockets;
 
@@ -319,7 +319,7 @@ static void icmpmsg_put(struct seq_file *seq)
 	int i, count;
 	unsigned short type[PERLINE];
 	unsigned long vals[PERLINE], val;
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
@@ -341,7 +341,7 @@ static void icmpmsg_put(struct seq_file *seq)
 static void icmp_put(struct seq_file *seq)
 {
 	int i;
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 	atomic_long_t *ptr = net->mib.icmpmsg_statistics->mibs;
 
 	seq_puts(seq, "\nIcmp: InMsgs InErrors InCsumErrors");
@@ -371,7 +371,7 @@ static void icmp_put(struct seq_file *seq)
 static int snmp_seq_show(struct seq_file *seq, void *v)
 {
 	int i;
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 
@@ -455,7 +455,7 @@ static const struct file_operations snmp_seq_fops = {
 static int netstat_seq_show(struct seq_file *seq, void *v)
 {
 	int i;
-	struct net *net = seq->private;
+	struct net *net = seq_file_net(seq);
 
 	seq_puts(seq, "TcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6d4be3fd2d01..11e8313b5ea2 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1027,14 +1027,15 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
 		0, 0L, 0,
 		from_kuid_munged(seq_user_ns(seq), sock_i_uid(sp)),
 		0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
+		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops),
+		sp->sk_vrf);
 }
 
 static int raw_seq_show(struct seq_file *seq, void *v)
@@ -1042,7 +1043,7 @@ static int raw_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "  sl  local_address rem_address   st tx_queue "
 				"rx_queue tr tm->when retrnsmt   uid  timeout "
-				"inode ref pointer drops\n");
+				"inode ref pointer drops vrf\n");
 	else
 		raw_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
 	return 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6c5f0a8ab17..59af5016bf26 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -215,7 +215,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "%-127s\n",
 			   "Iface\tDestination\tGateway \tFlags\t\tRefCnt\tUse\t"
 			   "Metric\tSource\t\tMTU\tWindow\tIRTT\tTOS\tHHRef\t"
-			   "HHUptod\tSpecDst");
+			   "HHUptod\tSpecDst\tvrf");
 	return 0;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 24089b9534bf..249ce80d12d6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2215,7 +2215,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 	long delta = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %u %d %pK %d",
 		i,
 		ireq->ir_loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2230,7 +2230,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
 		atomic_read(&sk->sk_refcnt),
-		req);
+		req, sk->sk_vrf);
 }
 
 static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
@@ -2272,7 +2272,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d",
+			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d %2d",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2289,7 +2289,8 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 		tp->snd_cwnd,
 		sk->sk_state == TCP_LISTEN ?
 		    (fastopenq ? fastopenq->max_qlen : 0) :
-		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh));
+		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh),
+		sk->sk_vrf);
 }
 
 static void get_timewait4_sock(const struct inet_timewait_sock *tw,
@@ -2305,10 +2306,10 @@ static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %pK %2d",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_delta_to_clock_t(delta), 0, 0, 0, 0,
-		atomic_read(&tw->tw_refcnt), tw);
+		atomic_read(&tw->tw_refcnt), tw, tw->tw_vrf);
 }
 
 #define TMPSZ 150
@@ -2322,7 +2323,7 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+			   "inode  vrf");
 		goto out;
 	}
 	st = seq->private;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2d7e2748a138..345d5a5b4489 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2422,7 +2422,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d",
+		" %02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %d %d",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
@@ -2430,7 +2430,7 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 		from_kuid_munged(seq_user_ns(f), sock_i_uid(sp)),
 		0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops));
+		atomic_read(&sp->sk_drops), sp->sk_vrf);
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
@@ -2439,7 +2439,7 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode ref pointer drops");
+			   "inode ref pointer drops vrf");
 	else {
 		struct udp_iter_state *state = seq->private;
 
-- 
1.9.3 (Apple Git-50)
