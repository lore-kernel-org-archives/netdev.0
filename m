From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH V2 1/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Thu, 12 Mar 2015 14:58:21 +0800
Message-ID: <1426143501-30827-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <brian.haley@hp.com>, <davem@davemloft.net>,
	<alexandre.dietsch@windriver.com>,
	<clinton.slabbert@windriver.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <kaber@trash.net>, <netdev@vger.kernel.org>,
	<ulf.samuelsson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61602 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbbCLG6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 02:58:43 -0400
In-Reply-To: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@windriver.com>

When the neighbor state machine is in PROBE state, it will normally send
a number of unicast ARP requests (number defined in "ucast_probes" entry
in the proc file system, default=3) and if no reply is received, it will
change state to FAILED.

Enabling CONFIG_ARP_PROBE_BCAST, will make the state machine try to send
broadcast ARP requests if the unicast ARP requests failed. The state machine
will only enter FAILED state if the broadcast ARP requests did not receive
a reply.

Enabling CONFIG_ARP_PROBE_BCAST, makes the IPv4 ARP behaviour more
similar to the IPv6 Neighbor Discovery protocol, and is necessary,
if the other end only responds to broadcast ARPs.

CC: WANG Cong <xiyou.wangcong@gmail.com> 
Reviewed-by: Yang Shi <yang.shi@windriver.com>
Signed-off-by: eulfsam <ulf.samuelsson@windriver.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 include/net/neighbour.h        |  7 ++++++
 include/uapi/linux/neighbour.h |  6 +++++
 include/uapi/linux/sysctl.h    |  3 +++
 kernel/sysctl_binary.c         |  3 +++
 net/core/neighbour.c           | 44 +++++++++++++++++++++++++++++---
 net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/arp.c                 |  7 ++++--
 7 files changed, 121 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 76f7084..85070b2 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -40,6 +40,9 @@ struct neighbour;
 
 enum {
 	NEIGH_VAR_MCAST_PROBES,
+#ifdef CONFIG_IP_ARP_BROADCAST
+	NEIGH_VAR_BCAST_PROBES,
+#endif
 	NEIGH_VAR_UCAST_PROBES,
 	NEIGH_VAR_APP_PROBES,
 	NEIGH_VAR_RETRANS_TIME,
@@ -122,6 +125,10 @@ struct neigh_statistics {
 	unsigned long rcv_probes_mcast;	/* number of received mcast ipv6 */
 	unsigned long rcv_probes_ucast; /* number of received ucast ipv6 */
 
+#ifdef CONFIG_IP_ARP_BROADCAST
+	unsigned long rcv_probes_bcast; /* number of received ucast ipv6 */
+#endif
+
 	unsigned long periodic_gc_runs;	/* number of periodic GC runs */
 	unsigned long forced_gc_runs;	/* number of forced GC runs */
 
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 3873a35..79cef9e 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -103,6 +103,9 @@ struct ndt_stats {
 	__u64		ndts_lookups;
 	__u64		ndts_hits;
 	__u64		ndts_rcv_probes_mcast;
+#ifdef CONFIG_IP_ARP_BROADCAST
+	__u64		ndts_rcv_probes_bcast;
+#endif
 	__u64		ndts_rcv_probes_ucast;
 	__u64		ndts_periodic_gc_runs;
 	__u64		ndts_forced_gc_runs;
@@ -121,6 +124,9 @@ enum {
 	NDTPA_APP_PROBES,		/* u32 */
 	NDTPA_UCAST_PROBES,		/* u32 */
 	NDTPA_MCAST_PROBES,		/* u32 */
+#ifdef CONFIG_IP_ARP_BROADCAST
+	NDTPA_BCAST_PROBES,		/* u32 */
+#endif
 	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
 	NDTPA_PROXY_DELAY,		/* u64, msecs */
 	NDTPA_PROXY_QLEN,		/* u32 */
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index 0956373..0c54d16 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -598,6 +598,9 @@ enum {
 	NET_NEIGH_GC_THRESH3=16,
 	NET_NEIGH_RETRANS_TIME_MS=17,
 	NET_NEIGH_REACHABLE_TIME_MS=18,
+#ifdef CONFIG_IP_ARP_BROADCAST
+	NET_NEIGH_BCAST_SOLICIT=19,
+#endif
 };
 
 /* /proc/sys/net/dccp */
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 7e7746a..47482a6 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -267,6 +267,9 @@ static const struct bin_table bin_net_neigh_vars_table[] = {
 	{ CTL_INT,	NET_NEIGH_MCAST_SOLICIT,	"mcast_solicit" },
 	{ CTL_INT,	NET_NEIGH_UCAST_SOLICIT,	"ucast_solicit" },
 	{ CTL_INT,	NET_NEIGH_APP_SOLICIT,		"app_solicit" },
+#ifdef CONFIG_IP_ARP_BROADCAST
+	{ CTL_INT,	NET_NEIGH_BCAST_SOLICIT,	"bcast_solicit" },
+#endif
 	/* NET_NEIGH_RETRANS_TIME "retrans_time" no longer used */
 	{ CTL_INT,	NET_NEIGH_REACHABLE_TIME,	"base_reachable_time" },
 	{ CTL_INT,	NET_NEIGH_DELAY_PROBE_TIME,	"delay_first_probe_time" },
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 70fe9e1..b372af4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -936,10 +936,16 @@ static void neigh_timer_handler(unsigned long arg)
 
 	if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
 	    atomic_read(&neigh->probes) >= neigh_max_probes(neigh)) {
-		neigh->nud_state = NUD_FAILED;
-		notify = 1;
-		neigh_invalidate(neigh);
-		goto out;
+#ifdef CONFIG_IP_ARP_BROADCAST
+		int delta_probes = atomic_read(&neigh->probes) - neigh_max_probes(neigh);
+		if (delta_probes >= NEIGH_VAR(neigh->parms, BCAST_PROBES))
+#endif
+		{
+			neigh->nud_state = NUD_FAILED;
+			notify = 1;
+			neigh_invalidate(neigh);
+			goto out;
+		}
 	}
 
 	if (neigh->nud_state & NUD_IN_TIMER) {
@@ -973,6 +979,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 		goto out_unlock_bh;
 
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
+		/* We are in (NUD_NONE | NUD_FAILED) */
 		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
 		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
 			unsigned long next, now = jiffies;
@@ -1783,6 +1790,10 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 			NEIGH_VAR(parms, UCAST_PROBES)) ||
 	    nla_put_u32(skb, NDTPA_MCAST_PROBES,
 			NEIGH_VAR(parms, MCAST_PROBES)) ||
+#ifdef CONFIG_IP_ARP_BROADCAST
+	    nla_put_u32(skb, NDTPA_BCAST_PROBES,
+			NEIGH_VAR(parms, BCAST_PROBES)) ||
+#endif
 	    nla_put_msecs(skb, NDTPA_REACHABLE_TIME, parms->reachable_time) ||
 	    nla_put_msecs(skb, NDTPA_BASE_REACHABLE_TIME,
 			  NEIGH_VAR(parms, BASE_REACHABLE_TIME)) ||
@@ -1870,6 +1881,9 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 			ndst.ndts_lookups		+= st->lookups;
 			ndst.ndts_hits			+= st->hits;
 			ndst.ndts_rcv_probes_mcast	+= st->rcv_probes_mcast;
+#ifdef CONFIG_IP_ARP_BROADCAST
+			ndst.ndts_rcv_probes_bcast	+= st->rcv_probes_bcast;
+#endif
 			ndst.ndts_rcv_probes_ucast	+= st->rcv_probes_ucast;
 			ndst.ndts_periodic_gc_runs	+= st->periodic_gc_runs;
 			ndst.ndts_forced_gc_runs	+= st->forced_gc_runs;
@@ -1942,6 +1956,9 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 	[NDTPA_APP_PROBES]		= { .type = NLA_U32 },
 	[NDTPA_UCAST_PROBES]		= { .type = NLA_U32 },
 	[NDTPA_MCAST_PROBES]		= { .type = NLA_U32 },
+#ifdef CONFIG_IP_ARP_BROADCAST
+	[NDTPA_BCAST_PROBES]		= { .type = NLA_U32 },
+#endif
 	[NDTPA_BASE_REACHABLE_TIME]	= { .type = NLA_U64 },
 	[NDTPA_GC_STALETIME]		= { .type = NLA_U64 },
 	[NDTPA_DELAY_PROBE_TIME]	= { .type = NLA_U64 },
@@ -2042,6 +2059,12 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 				NEIGH_VAR_SET(p, MCAST_PROBES,
 					      nla_get_u32(tbp[i]));
 				break;
+#ifdef CONFIG_IP_ARP_BROADCAST
+			case NDTPA_BCAST_PROBES:
+				NEIGH_VAR_SET(p, BCAST_PROBES,
+					      nla_get_u32(tbp[i]));
+				break;
+#endif
 			case NDTPA_BASE_REACHABLE_TIME:
 				NEIGH_VAR_SET(p, BASE_REACHABLE_TIME,
 					      nla_get_msecs(tbp[i]));
@@ -2702,11 +2725,18 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 	struct neigh_statistics *st = v;
 
 	if (v == SEQ_START_TOKEN) {
+#ifdef CONFIG_IP_ARP_BROADCAST
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_bcast rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_discards\n");
+#else
 		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_discards\n");
+#endif
 		return 0;
 	}
 
 	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
+#ifdef CONFIG_IP_ARP_BROADCAST
+			"%08lx "
+#endif
 			"%08lx %08lx  %08lx %08lx %08lx\n",
 		   atomic_read(&tbl->entries),
 
@@ -2719,6 +2749,9 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 
 		   st->res_failed,
 
+#ifdef CONFIG_IP_ARP_BROADCAST
+		   st->rcv_probes_bcast,
+#endif
 		   st->rcv_probes_mcast,
 		   st->rcv_probes_ucast,
 
@@ -2992,6 +3025,9 @@ static struct neigh_sysctl_table {
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
 		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(MCAST_PROBES, "mcast_solicit"),
+#ifdef CONFIG_IP_ARP_BROADCAST
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(BCAST_PROBES, "bcast_solicit"),
+#endif
 		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(UCAST_PROBES, "ucast_solicit"),
 		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(APP_PROBES, "app_solicit"),
 		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(RETRANS_TIME, "retrans_time"),
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index bd29016..2f43dc9 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -1,6 +1,63 @@
 #
 # IP configuration
 #
+config IP_ARP_BROADCAST
+	bool "IP: allow broadcast ARP"
+	default N
+	---help---
+	  The stack will periodically refresh ARP cache by sending unicast ARP requests.
+	  if a number of unicast ARP request fails, the stack will normally enter
+	  FAILED state, and the ARP entry will be removed by the garbage collector.
+	  Enabling this option will make the stack try to send broadcast ARP requests
+	  if the unicast ARP requests fails, before entering FAILED state.
+	  The number of broadcast packets is controlled by
+	  '/proc/sys/net/ipv4/neigh/<dev>/bcast_solicit' which defaults to "0".
+	  The parameter must be assigned a value to enable sending broadcast ARPs.
+
+	  If unsure, say N here.
+
+
+config IP_ARP_UCAST_PROBES
+	int "ucast_solicit initial value"
+	default "3"
+
+	---help---
+	  This value defines the initial value for how many unicast ARP requests
+	  are sent by the ARP state machine in PROBE state.
+	  It can be controlled runtime by '/proc/sys/net/ipv4/neigh/<dev>/ucast_solicit'
+
+	  If unsure, say "3" here.
+
+
+config IP_ARP_MCAST_PROBES
+	int "mcast_solicit initial value"
+	default "3"
+
+	---help---
+	  This value defines the initial value for how many broadcast ARP requests
+	  are sent by the ARP state machine in INCOMPLETE state.
+	  It can be controlled runtime by '/proc/sys/net/ipv4/neigh/<dev>/mcast_solicit'
+
+	  If unsure, say "3" here.
+
+
+config IP_ARP_BCAST_PROBES
+	int "bcast_solicit initial value"
+	depends on IP_ARP_BROADCAST
+	default "0"
+
+	---help---
+	  This value defines the initial value for how many broadcast ARP requests
+	  are sent by the ARP state machine in PROBE state.
+	  It can be controlled runtime by '/proc/sys/net/ipv4/neigh/<dev>/bcast_solicit'
+	  The default value of 'bcast_solicit' is zero, mimicking the behaviour of
+	  older kernels which does not send out broadcast ARPs except for new entries.
+	  If you want broadcast ARP requests to happen in PROBE state, set the number here.
+	  To be compatible with IPv6, the number should be "3"
+
+	  If unsure, say "0" here.
+
+
 config IP_MULTICAST
 	bool "IP: multicasting"
 	help
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 205e147..4795ab6 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -168,8 +168,11 @@ struct neigh_table arp_tbl = {
 		.tbl			= &arp_tbl,
 		.reachable_time		= 30 * HZ,
 		.data	= {
-			[NEIGH_VAR_MCAST_PROBES] = 3,
-			[NEIGH_VAR_UCAST_PROBES] = 3,
+			[NEIGH_VAR_MCAST_PROBES] = CONFIG_IP_ARP_MCAST_PROBES,
+			[NEIGH_VAR_UCAST_PROBES] = CONFIG_IP_ARP_UCAST_PROBES,
+#ifdef CONFIG_IP_ARP_BROADCAST
+			[NEIGH_VAR_BCAST_PROBES] = CONFIG_IP_ARP_BCAST_PROBES,
+#endif
 			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
 			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
 			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
-- 
1.9.1
