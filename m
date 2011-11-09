From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4 net-next] neigh: new unresolved queue limits
Date: Wed, 09 Nov 2011 12:14:09 +0100
Message-ID: <1320837249.2315.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38493 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1KILON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 06:14:13 -0500
Received: by bke11 with SMTP id 11so1230500bke.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 03:14:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unres_qlen is the number of frames we are able to queue per unresolved
neighbour. Its default value (3) was never changed and is responsible
for strange drops, especially if IP fragments are used, or multiple
sessions start in parallel. Even a single tcp flow can hit this limit.

$ arp -d 192.168.20.108 ; ping -c 2 -s 8000 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 8000(8028) bytes of data.
8008 bytes from 192.168.20.108: icmp_seq=2 ttl=64 time=0.322 ms

--- 192.168.20.108 ping statistics ---
2 packets transmitted, 1 received, 50% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.322/0.322/0.322/0.000 ms

Increasing unres_qlen can be dangerous, since an attacker might try to
fill many queues with many packets and consume all memory.

Switch to a bytes limit (limiting queued skbs truesize), and allow a
default limit of 64Kbytes per unresolved neighbour. This new limit seems
big, but as a packet can consume 64Kbytes, it reduces the memory window
offered to attackers.

unres_qlen is kept for compatibility, but internally converted to/from
bytes limit.

# cd /proc/sys/net/ipv4/neigh/default/
# grep . unres_qlen*
unres_qlen:31
unres_qlen_bytes:65536
# echo 10 >unres_qlen
# grep . unres_qlen*
unres_qlen:10
unres_qlen_bytes:21540
# echo 30000 >unres_qlen_bytes
# grep . unres_qlen*
unres_qlen:14
unres_qlen_bytes:30000

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |   10 +
 include/linux/neighbour.h              |    1 
 include/net/neighbour.h                |    3 
 net/atm/clip.c                         |    2 
 net/core/neighbour.c                   |  163 +++++++++++++++--------
 net/decnet/dn_neigh.c                  |    2 
 net/ipv4/arp.c                         |    2 
 net/ipv6/ndisc.c                       |    2 
 8 files changed, 129 insertions(+), 56 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f049a1c..b886706 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -31,6 +31,16 @@ neigh/default/gc_thresh3 - INTEGER
 	when using large numbers of interfaces and when communicating
 	with large numbers of directly-connected peers.
 
+neigh/default/unres_qlen_bytes - INTEGER
+	The maximum number of bytes which may be used by packets
+	queued for each	unresolved address by other network layers.
+	(added in linux 3.3)
+
+neigh/default/unres_qlen - INTEGER
+	The maximum number of packets which may be queued for each
+	unresolved address by other network layers.
+	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
+
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
 
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index a7003b7..b188f68 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -116,6 +116,7 @@ enum {
 	NDTPA_PROXY_DELAY,		/* u64, msecs */
 	NDTPA_PROXY_QLEN,		/* u32 */
 	NDTPA_LOCKTIME,			/* u64, msecs */
+	NDTPA_QUEUE_LENBYTES,		/* u32 */
 	__NDTPA_MAX
 };
 #define NDTPA_MAX (__NDTPA_MAX - 1)
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 2720884..7ae5acf 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -59,7 +59,7 @@ struct neigh_parms {
 	int	reachable_time;
 	int	delay_probe_time;
 
-	int	queue_len;
+	int	queue_len_bytes;
 	int	ucast_probes;
 	int	app_probes;
 	int	mcast_probes;
@@ -99,6 +99,7 @@ struct neighbour {
 	rwlock_t		lock;
 	atomic_t		refcnt;
 	struct sk_buff_head	arp_queue;
+	unsigned int		arp_queue_len_bytes;
 	struct timer_list	timer;
 	unsigned long		used;
 	atomic_t		probes;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8523940..32c41b8 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -329,7 +329,7 @@ static struct neigh_table clip_tbl = {
 		.gc_staletime 		= 60 * HZ,
 		.reachable_time 	= 30 * HZ,
 		.delay_probe_time 	= 5 * HZ,
-		.queue_len 		= 3,
+		.queue_len_bytes 	= 64 * 1024,
 		.ucast_probes 		= 3,
 		.mcast_probes 		= 3,
 		.anycast_delay 		= 1 * HZ,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 039d51e..173d9b6 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -238,6 +238,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 				   it to safe state.
 				 */
 				skb_queue_purge(&n->arp_queue);
+				n->arp_queue_len_bytes = 0;
 				n->output = neigh_blackhole;
 				if (n->nud_state & NUD_VALID)
 					n->nud_state = NUD_NOARP;
@@ -702,6 +703,7 @@ void neigh_destroy(struct neighbour *neigh)
 		printk(KERN_WARNING "Impossible event.\n");
 
 	skb_queue_purge(&neigh->arp_queue);
+	neigh->arp_queue_len_bytes = 0;
 
 	dev_put(neigh->dev);
 	neigh_parms_put(neigh->parms);
@@ -842,6 +844,7 @@ static void neigh_invalidate(struct neighbour *neigh)
 		write_lock(&neigh->lock);
 	}
 	skb_queue_purge(&neigh->arp_queue);
+	neigh->arp_queue_len_bytes = 0;
 }
 
 static void neigh_probe(struct neighbour *neigh)
@@ -980,15 +983,20 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (neigh->nud_state == NUD_INCOMPLETE) {
 		if (skb) {
-			if (skb_queue_len(&neigh->arp_queue) >=
-			    neigh->parms->queue_len) {
+			while (neigh->arp_queue_len_bytes + skb->truesize >
+			       neigh->parms->queue_len_bytes) {
 				struct sk_buff *buff;
+
 				buff = __skb_dequeue(&neigh->arp_queue);
+				if (!buff)
+					break;
+				neigh->arp_queue_len_bytes -= buff->truesize;
 				kfree_skb(buff);
 				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
 			skb_dst_force(skb);
 			__skb_queue_tail(&neigh->arp_queue, skb);
+			neigh->arp_queue_len_bytes += skb->truesize;
 		}
 		rc = 1;
 	}
@@ -1175,6 +1183,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
+		neigh->arp_queue_len_bytes = 0;
 	}
 out:
 	if (update_isrouter) {
@@ -1747,7 +1756,11 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 		NLA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
 
 	NLA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
-	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len);
+	NLA_PUT_U32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes);
+	/* approximative value for deprecated QUEUE_LEN (in packets) */
+	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN,
+		    DIV_ROUND_UP(parms->queue_len_bytes,
+				 SKB_TRUESIZE(ETH_FRAME_LEN)));
 	NLA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
 	NLA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
 	NLA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
@@ -1897,6 +1910,7 @@ static const struct nla_policy nl_neightbl_policy[NDTA_MAX+1] = {
 static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 	[NDTPA_IFINDEX]			= { .type = NLA_U32 },
 	[NDTPA_QUEUE_LEN]		= { .type = NLA_U32 },
+	[NDTPA_QUEUE_LENBYTES]		= { .type = NLA_U32 },
 	[NDTPA_PROXY_QLEN]		= { .type = NLA_U32 },
 	[NDTPA_APP_PROBES]		= { .type = NLA_U32 },
 	[NDTPA_UCAST_PROBES]		= { .type = NLA_U32 },
@@ -1974,7 +1988,11 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 			switch (i) {
 			case NDTPA_QUEUE_LEN:
-				p->queue_len = nla_get_u32(tbp[i]);
+				p->queue_len_bytes = nla_get_u32(tbp[i]) *
+						     SKB_TRUESIZE(ETH_FRAME_LEN);
+				break;
+			case NDTPA_QUEUE_LENBYTES:
+				p->queue_len_bytes = nla_get_u32(tbp[i]);
 				break;
 			case NDTPA_PROXY_QLEN:
 				p->proxy_qlen = nla_get_u32(tbp[i]);
@@ -2635,117 +2653,158 @@ EXPORT_SYMBOL(neigh_app_ns);
 
 #ifdef CONFIG_SYSCTL
 
-#define NEIGH_VARS_MAX 19
+static int proc_unres_qlen(ctl_table *ctl, int write, void __user *buffer,
+			   size_t *lenp, loff_t *ppos)
+{
+	int size, ret;
+	ctl_table tmp = *ctl;
+
+	tmp.data = &size;
+	size = DIV_ROUND_UP(*(int *)ctl->data, SKB_TRUESIZE(ETH_FRAME_LEN));
+	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);
+	if (write && !ret)
+		*(int *)ctl->data = size * SKB_TRUESIZE(ETH_FRAME_LEN);
+	return ret;
+}
+
+enum {
+	NEIGH_VAR_MCAST_PROBE,
+	NEIGH_VAR_UCAST_PROBE,
+	NEIGH_VAR_APP_PROBE,
+	NEIGH_VAR_RETRANS_TIME,
+	NEIGH_VAR_BASE_REACHABLE_TIME,
+	NEIGH_VAR_DELAY_PROBE_TIME,
+	NEIGH_VAR_GC_STALETIME,
+	NEIGH_VAR_QUEUE_LEN,
+	NEIGH_VAR_QUEUE_LEN_BYTES,
+	NEIGH_VAR_PROXY_QLEN,
+	NEIGH_VAR_ANYCAST_DELAY,
+	NEIGH_VAR_PROXY_DELAY,
+	NEIGH_VAR_LOCKTIME,
+	NEIGH_VAR_RETRANS_TIME_MS,
+	NEIGH_VAR_BASE_REACHABLE_TIME_MS,
+	NEIGH_VAR_GC_INTERVAL,
+	NEIGH_VAR_GC_THRESH1,
+	NEIGH_VAR_GC_THRESH2,
+	NEIGH_VAR_GC_THRESH3,
+	NEIGH_VAR_MAX
+};
 
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	struct ctl_table neigh_vars[NEIGH_VARS_MAX];
+	struct ctl_table neigh_vars[NEIGH_VAR_MAX + 1];
 	char *dev_name;
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
-		{
+		[NEIGH_VAR_MCAST_PROBE] = {
 			.procname	= "mcast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_UCAST_PROBE] = {
 			.procname	= "ucast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_APP_PROBE] = {
 			.procname	= "app_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_RETRANS_TIME] = {
 			.procname	= "retrans_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
-		{
+		[NEIGH_VAR_BASE_REACHABLE_TIME] = {
 			.procname	= "base_reachable_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
 		},
-		{
+		[NEIGH_VAR_DELAY_PROBE_TIME] = {
 			.procname	= "delay_first_probe_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
 		},
-		{
+		[NEIGH_VAR_GC_STALETIME] = {
 			.procname	= "gc_stale_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
 		},
-		{
+		[NEIGH_VAR_QUEUE_LEN] = {
 			.procname	= "unres_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
+			.proc_handler	= proc_unres_qlen,
+		},
+		[NEIGH_VAR_QUEUE_LEN_BYTES] = {
+			.procname	= "unres_qlen_bytes",
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_PROXY_QLEN] = {
 			.procname	= "proxy_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_ANYCAST_DELAY] = {
 			.procname	= "anycast_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
-		{
+		[NEIGH_VAR_PROXY_DELAY] = {
 			.procname	= "proxy_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
-		{
+		[NEIGH_VAR_LOCKTIME] = {
 			.procname	= "locktime",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
-		{
+		[NEIGH_VAR_RETRANS_TIME_MS] = {
 			.procname	= "retrans_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_ms_jiffies,
 		},
-		{
+		[NEIGH_VAR_BASE_REACHABLE_TIME_MS] = {
 			.procname	= "base_reachable_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_ms_jiffies,
 		},
-		{
+		[NEIGH_VAR_GC_INTERVAL] = {
 			.procname	= "gc_interval",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
 		},
-		{
+		[NEIGH_VAR_GC_THRESH1] = {
 			.procname	= "gc_thresh1",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_GC_THRESH2] = {
 			.procname	= "gc_thresh2",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
-		{
+		[NEIGH_VAR_GC_THRESH3] = {
 			.procname	= "gc_thresh3",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
@@ -2778,47 +2837,49 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (!t)
 		goto err;
 
-	t->neigh_vars[0].data  = &p->mcast_probes;
-	t->neigh_vars[1].data  = &p->ucast_probes;
-	t->neigh_vars[2].data  = &p->app_probes;
-	t->neigh_vars[3].data  = &p->retrans_time;
-	t->neigh_vars[4].data  = &p->base_reachable_time;
-	t->neigh_vars[5].data  = &p->delay_probe_time;
-	t->neigh_vars[6].data  = &p->gc_staletime;
-	t->neigh_vars[7].data  = &p->queue_len;
-	t->neigh_vars[8].data  = &p->proxy_qlen;
-	t->neigh_vars[9].data  = &p->anycast_delay;
-	t->neigh_vars[10].data = &p->proxy_delay;
-	t->neigh_vars[11].data = &p->locktime;
-	t->neigh_vars[12].data  = &p->retrans_time;
-	t->neigh_vars[13].data  = &p->base_reachable_time;
+	t->neigh_vars[NEIGH_VAR_MCAST_PROBE].data  = &p->mcast_probes;
+	t->neigh_vars[NEIGH_VAR_UCAST_PROBE].data  = &p->ucast_probes;
+	t->neigh_vars[NEIGH_VAR_APP_PROBE].data  = &p->app_probes;
+	t->neigh_vars[NEIGH_VAR_RETRANS_TIME].data  = &p->retrans_time;
+	t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].data  = &p->base_reachable_time;
+	t->neigh_vars[NEIGH_VAR_DELAY_PROBE_TIME].data  = &p->delay_probe_time;
+	t->neigh_vars[NEIGH_VAR_GC_STALETIME].data  = &p->gc_staletime;
+	t->neigh_vars[NEIGH_VAR_QUEUE_LEN].data  = &p->queue_len_bytes;
+	t->neigh_vars[NEIGH_VAR_QUEUE_LEN_BYTES].data  = &p->queue_len_bytes;
+	t->neigh_vars[NEIGH_VAR_PROXY_QLEN].data  = &p->proxy_qlen;
+	t->neigh_vars[NEIGH_VAR_ANYCAST_DELAY].data  = &p->anycast_delay;
+	t->neigh_vars[NEIGH_VAR_PROXY_DELAY].data = &p->proxy_delay;
+	t->neigh_vars[NEIGH_VAR_LOCKTIME].data = &p->locktime;
+	t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].data  = &p->retrans_time;
+	t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].data  = &p->base_reachable_time;
 
 	if (dev) {
 		dev_name_source = dev->name;
 		/* Terminate the table early */
-		memset(&t->neigh_vars[14], 0, sizeof(t->neigh_vars[14]));
+		memset(&t->neigh_vars[NEIGH_VAR_GC_INTERVAL], 0,
+		       sizeof(t->neigh_vars[NEIGH_VAR_GC_INTERVAL]));
 	} else {
 		dev_name_source = neigh_path[NEIGH_CTL_PATH_DEV].procname;
-		t->neigh_vars[14].data = (int *)(p + 1);
-		t->neigh_vars[15].data = (int *)(p + 1) + 1;
-		t->neigh_vars[16].data = (int *)(p + 1) + 2;
-		t->neigh_vars[17].data = (int *)(p + 1) + 3;
+		t->neigh_vars[NEIGH_VAR_GC_INTERVAL].data = (int *)(p + 1);
+		t->neigh_vars[NEIGH_VAR_GC_THRESH1].data = (int *)(p + 1) + 1;
+		t->neigh_vars[NEIGH_VAR_GC_THRESH2].data = (int *)(p + 1) + 2;
+		t->neigh_vars[NEIGH_VAR_GC_THRESH3].data = (int *)(p + 1) + 3;
 	}
 
 
 	if (handler) {
 		/* RetransTime */
-		t->neigh_vars[3].proc_handler = handler;
-		t->neigh_vars[3].extra1 = dev;
+		t->neigh_vars[NEIGH_VAR_RETRANS_TIME].proc_handler = handler;
+		t->neigh_vars[NEIGH_VAR_RETRANS_TIME].extra1 = dev;
 		/* ReachableTime */
-		t->neigh_vars[4].proc_handler = handler;
-		t->neigh_vars[4].extra1 = dev;
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].proc_handler = handler;
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].extra1 = dev;
 		/* RetransTime (in milliseconds)*/
-		t->neigh_vars[12].proc_handler = handler;
-		t->neigh_vars[12].extra1 = dev;
+		t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].proc_handler = handler;
+		t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].extra1 = dev;
 		/* ReachableTime (in milliseconds) */
-		t->neigh_vars[13].proc_handler = handler;
-		t->neigh_vars[13].extra1 = dev;
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].proc_handler = handler;
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].extra1 = dev;
 	}
 
 	t->dev_name = kstrdup(dev_name_source, GFP_KERNEL);
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7f0eb08..fb8b096 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -107,7 +107,7 @@ struct neigh_table dn_neigh_table = {
 		.gc_staletime =	60 * HZ,
 		.reachable_time =		30 * HZ,
 		.delay_probe_time =	5 * HZ,
-		.queue_len =		3,
+		.queue_len =		64*1024,
 		.ucast_probes =	0,
 		.app_probes =		0,
 		.mcast_probes =	0,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 96a164a..d732827 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -177,7 +177,7 @@ struct neigh_table arp_tbl = {
 		.gc_staletime		= 60 * HZ,
 		.reachable_time		= 30 * HZ,
 		.delay_probe_time	= 5 * HZ,
-		.queue_len		= 3,
+		.queue_len_bytes	= 64*1024,
 		.ucast_probes		= 3,
 		.mcast_probes		= 3,
 		.anycast_delay		= 1 * HZ,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 44e5b7f..4a20982 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -141,7 +141,7 @@ struct neigh_table nd_tbl = {
 		.gc_staletime		= 60 * HZ,
 		.reachable_time		= ND_REACHABLE_TIME,
 		.delay_probe_time	= 5 * HZ,
-		.queue_len		= 3,
+		.queue_len_bytes	= 64*1024,
 		.ucast_probes		= 3,
 		.mcast_probes		= 3,
 		.anycast_delay		= 1 * HZ,
