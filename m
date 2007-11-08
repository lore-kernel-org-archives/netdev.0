From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Thu, 08 Nov 2007 12:23:29 +0100
Message-ID: <4732F1B1.204@trash.net>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1Ipla8-0001IO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050909030303070802030609"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56865 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758509AbXKHLYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 06:24:03 -0500
In-Reply-To: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050909030303070802030609
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> [IPSEC]: Merge most of the output path
> 
> As part of the work on asynchrnous cryptographic operations, we need to
> be able to resume from the spot where they occur.  As such, it helps if
> we isolate them to one spot.
> 
> This patch moves most of the remaining family-specific processing into
> the common output code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  include/net/dst.h       |    1 
> @@ -66,6 +67,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
>  	.family			= AF_INET,
>  	.proto			= IPPROTO_IPIP,
>  	.eth_proto		= htons(ETH_P_IP),
> +	.nf_post_routing	= NF_IP_POST_ROUTING,


We have a few places that go though the trouble of selecting the
"correct" hook value for the address family, even though the numerical
values are identical. How about we just get rid of the different
naming and use NF_INET_... for both IPv4 and IPv6?


--------------050909030303070802030609
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Introduce NF_INET_ hook values

The IPv4 and IPv6 hook values are identical, yet some code tries to figure
out the "correct" value by looking at the address family. Introduce NF_INET_*
values for both IPv4 and IPv6. The old values are kept in a #ifndef __KERNEL__
section for userspace compatibility.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0c0a9878960e19a0ce8fe56e616c6f55799a2538
tree d7fc8398f685b44de23914d4c6a48a2f53646a7a
parent d79d569958a561da92975784ab7afc8440c96007
author Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 12:22:30 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 12:22:30 +0100

 include/linux/netfilter.h                      |    9 +++++
 include/linux/netfilter/x_tables.h             |    4 +-
 include/linux/netfilter_ipv4.h                 |    2 +
 include/linux/netfilter_ipv4/ip_tables.h       |    8 ++--
 include/linux/netfilter_ipv6.h                 |    3 +-
 include/linux/netfilter_ipv6/ip6_tables.h      |    8 ++--
 include/net/ipip.h                             |    2 +
 include/net/netfilter/nf_nat.h                 |    3 +-
 net/bridge/br_netfilter.c                      |   12 +++----
 net/compat.c                                   |    6 ++-
 net/ipv4/igmp.c                                |    4 +-
 net/ipv4/ip_forward.c                          |    2 +
 net/ipv4/ip_input.c                            |    4 +-
 net/ipv4/ip_output.c                           |   16 ++++-----
 net/ipv4/ipmr.c                                |    2 +
 net/ipv4/ipvs/ip_vs_core.c                     |   18 +++++-----
 net/ipv4/ipvs/ip_vs_xmit.c                     |    2 +
 net/ipv4/netfilter.c                           |    8 ++--
 net/ipv4/netfilter/ip_tables.c                 |   44 ++++++++++++------------
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    4 +-
 net/ipv4/netfilter/ipt_NETMAP.c                |   13 ++++---
 net/ipv4/netfilter/ipt_REDIRECT.c              |    8 ++--
 net/ipv4/netfilter/ipt_REJECT.c                |    8 ++--
 net/ipv4/netfilter/ipt_SAME.c                  |    7 ++--
 net/ipv4/netfilter/ipt_owner.c                 |    3 +-
 net/ipv4/netfilter/iptable_filter.c            |   22 +++++++-----
 net/ipv4/netfilter/iptable_mangle.c            |   40 +++++++++++-----------
 net/ipv4/netfilter/iptable_raw.c               |   14 ++++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   18 +++++-----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +
 net/ipv4/netfilter/nf_nat_core.c               |   14 ++++----
 net/ipv4/netfilter/nf_nat_h323.c               |    8 ++--
 net/ipv4/netfilter/nf_nat_helper.c             |    4 +-
 net/ipv4/netfilter/nf_nat_pptp.c               |    4 +-
 net/ipv4/netfilter/nf_nat_rule.c               |   28 ++++++++-------
 net/ipv4/netfilter/nf_nat_sip.c                |    4 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |   14 ++++----
 net/ipv4/raw.c                                 |    2 +
 net/ipv4/xfrm4_input.c                         |    2 +
 net/ipv4/xfrm4_output.c                        |    8 ++--
 net/ipv6/ip6_input.c                           |    6 ++-
 net/ipv6/ip6_output.c                          |   15 +++++---
 net/ipv6/ip6_tunnel.c                          |    2 +
 net/ipv6/mcast.c                               |    6 ++-
 net/ipv6/ndisc.c                               |    6 ++-
 net/ipv6/netfilter.c                           |    6 ++-
 net/ipv6/netfilter/ip6_tables.c                |   26 +++++++-------
 net/ipv6/netfilter/ip6t_REJECT.c               |    8 ++--
 net/ipv6/netfilter/ip6t_eui64.c                |    4 +-
 net/ipv6/netfilter/ip6t_owner.c                |    3 +-
 net/ipv6/netfilter/ip6table_filter.c           |   22 +++++++-----
 net/ipv6/netfilter/ip6table_mangle.c           |   40 +++++++++++-----------
 net/ipv6/netfilter/ip6table_raw.c              |   14 ++++----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   12 +++----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +
 net/ipv6/raw.c                                 |    2 +
 net/ipv6/xfrm6_input.c                         |    2 +
 net/ipv6/xfrm6_output.c                        |    6 ++-
 net/netfilter/nf_conntrack_netlink.c           |    8 ++--
 net/netfilter/nf_conntrack_proto_tcp.c         |    4 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    4 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    3 +-
 net/netfilter/xt_CLASSIFY.c                    |   12 +++----
 net/netfilter/xt_TCPMSS.c                      |   12 +++----
 net/netfilter/xt_mac.c                         |   12 +++----
 net/netfilter/xt_physdev.c                     |    6 ++-
 net/netfilter/xt_policy.c                      |    5 +--
 net/netfilter/xt_realm.c                       |    4 +-
 net/sched/sch_ingress.c                        |    4 +-
 security/selinux/hooks.c                       |    4 +-
 70 files changed, 332 insertions(+), 312 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 16adac6..25fc122 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -39,6 +39,15 @@
 #define NFC_ALTERED 0x8000
 #endif
 
+enum nf_inet_hooks {
+	NF_INET_PRE_ROUTING,
+	NF_INET_LOCAL_IN,
+	NF_INET_FORWARD,
+	NF_INET_LOCAL_OUT,
+	NF_INET_POST_ROUTING,
+	NF_INET_NUMHOOKS
+};
+
 #ifdef __KERNEL__
 #ifdef CONFIG_NETFILTER
 
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 03e6ce9..9657c4e 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -265,8 +265,8 @@ struct xt_table_info
 	unsigned int initial_entries;
 
 	/* Entry points and underflows */
-	unsigned int hook_entry[NF_IP_NUMHOOKS];
-	unsigned int underflow[NF_IP_NUMHOOKS];
+	unsigned int hook_entry[NF_INET_NUMHOOKS];
+	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* ipt_entry tables: one per CPU */
 	char *entries[NR_CPUS];
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index 1a63adf..9a10092 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -36,7 +36,6 @@
 #define NFC_IP_DST_PT		0x0400
 /* Something else about the proto */
 #define NFC_IP_PROTO_UNKNOWN	0x2000
-#endif /* ! __KERNEL__ */
 
 /* IP Hooks */
 /* After promisc drops, checksum checks. */
@@ -50,6 +49,7 @@
 /* Packets about to hit the wire. */
 #define NF_IP_POST_ROUTING	4
 #define NF_IP_NUMHOOKS		5
+#endif /* ! __KERNEL__ */
 
 enum nf_ip_hook_priorities {
 	NF_IP_PRI_FIRST = INT_MIN,
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index d79ed69..54da616 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -156,10 +156,10 @@ struct ipt_getinfo
 	unsigned int valid_hooks;
 
 	/* Hook entry points: one per netfilter hook. */
-	unsigned int hook_entry[NF_IP_NUMHOOKS];
+	unsigned int hook_entry[NF_INET_NUMHOOKS];
 
 	/* Underflow points. */
-	unsigned int underflow[NF_IP_NUMHOOKS];
+	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* Number of entries */
 	unsigned int num_entries;
@@ -185,10 +185,10 @@ struct ipt_replace
 	unsigned int size;
 
 	/* Hook entry points. */
-	unsigned int hook_entry[NF_IP_NUMHOOKS];
+	unsigned int hook_entry[NF_INET_NUMHOOKS];
 
 	/* Underflow points. */
-	unsigned int underflow[NF_IP_NUMHOOKS];
+	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* Information about old entries: */
 	/* Number of counters (must be equal to current number of entries). */
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 66ca8e3..3475a65 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -40,8 +40,6 @@
 #define NFC_IP6_DST_PT           0x0400
 /* Something else about the proto */
 #define NFC_IP6_PROTO_UNKNOWN    0x2000
-#endif /* ! __KERNEL__ */
-
 
 /* IP6 Hooks */
 /* After promisc drops, checksum checks. */
@@ -55,6 +53,7 @@
 /* Packets about to hit the wire. */
 #define NF_IP6_POST_ROUTING	4
 #define NF_IP6_NUMHOOKS		5
+#endif /* ! __KERNEL__ */
 
 
 enum nf_ip6_hook_priorities {
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 7dc481c..2e98654 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -216,10 +216,10 @@ struct ip6t_getinfo
 	unsigned int valid_hooks;
 
 	/* Hook entry points: one per netfilter hook. */
-	unsigned int hook_entry[NF_IP6_NUMHOOKS];
+	unsigned int hook_entry[NF_INET_NUMHOOKS];
 
 	/* Underflow points. */
-	unsigned int underflow[NF_IP6_NUMHOOKS];
+	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* Number of entries */
 	unsigned int num_entries;
@@ -245,10 +245,10 @@ struct ip6t_replace
 	unsigned int size;
 
 	/* Hook entry points. */
-	unsigned int hook_entry[NF_IP6_NUMHOOKS];
+	unsigned int hook_entry[NF_INET_NUMHOOKS];
 
 	/* Underflow points. */
-	unsigned int underflow[NF_IP6_NUMHOOKS];
+	unsigned int underflow[NF_INET_NUMHOOKS];
 
 	/* Information about old entries: */
 	/* Number of counters (must be equal to current number of entries). */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 7cdc914..27a32a8 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -34,7 +34,7 @@ struct ip_tunnel
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
 	ip_send_check(iph);						\
 									\
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
+	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
 	if (net_xmit_eval(err) == 0) {					\
 		stats->tx_bytes += pkt_len;				\
 		stats->tx_packets++;					\
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 6ae52f7..76da322 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -12,7 +12,8 @@ enum nf_nat_manip_type
 };
 
 /* SRC manip occurs POST_ROUTING or LOCAL_IN */
-#define HOOK2MANIP(hooknum) ((hooknum) != NF_IP_POST_ROUTING && (hooknum) != NF_IP_LOCAL_IN)
+#define HOOK2MANIP(hooknum) ((hooknum) != NF_INET_POST_ROUTING && \
+			     (hooknum) != NF_INET_LOCAL_IN)
 
 #define IP_NAT_RANGE_MAP_IPS 1
 #define IP_NAT_RANGE_PROTO_SPECIFIED 2
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index da22f90..f941aab 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -488,7 +488,7 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
-	NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
@@ -561,7 +561,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 	store_orig_dstaddr(skb);
 
-	NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
@@ -653,7 +653,7 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
 
-	NF_HOOK(pf, NF_IP_FORWARD, skb, bridge_parent(in), parent,
+	NF_HOOK(pf, NF_INET_FORWARD, skb, bridge_parent(in), parent,
 		br_nf_forward_finish);
 
 	return NF_STOLEN;
@@ -796,7 +796,7 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 	if (nf_bridge->netoutdev)
 		realoutdev = nf_bridge->netoutdev;
 #endif
-	NF_HOOK(pf, NF_IP_POST_ROUTING, skb, NULL, realoutdev,
+	NF_HOOK(pf, NF_INET_POST_ROUTING, skb, NULL, realoutdev,
 		br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
@@ -869,12 +869,12 @@ static struct nf_hook_ops br_nf_ops[] = {
 	{ .hook = ip_sabotage_in,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET,
-	  .hooknum = NF_IP_PRE_ROUTING,
+	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP_PRI_FIRST, },
 	{ .hook = ip_sabotage_in,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET6,
-	  .hooknum = NF_IP6_PRE_ROUTING,
+	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP6_PRI_FIRST, },
 };
 
diff --git a/net/compat.c b/net/compat.c
index d74d821..b599cf1 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -323,8 +323,8 @@ struct compat_ipt_replace {
 	u32			valid_hooks;
 	u32			num_entries;
 	u32			size;
-	u32			hook_entry[NF_IP_NUMHOOKS];
-	u32			underflow[NF_IP_NUMHOOKS];
+	u32			hook_entry[NF_INET_NUMHOOKS];
+	u32			underflow[NF_INET_NUMHOOKS];
 	u32			num_counters;
 	compat_uptr_t		counters;	/* struct ipt_counters * */
 	struct ipt_entry	entries[0];
@@ -389,7 +389,7 @@ static int do_netfilter_replace(int fd, int level, int optname,
 			   origsize))
 		goto out;
 
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		if (__get_user(tmp32, &urepl->hook_entry[i]) ||
 		    __put_user(tmp32, &repl_nat->hook_entry[i]) ||
 		    __get_user(tmp32, &urepl->underflow[i]) ||
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7dbc282..d1733f4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -358,7 +358,7 @@ static int igmpv3_sendpack(struct sk_buff *skb)
 	ip_send_check(pip);
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dev,
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		       dst_output);
 }
 
@@ -695,7 +695,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	ih->group=group;
 	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		       dst_output);
 }
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 877da3e..0b3b328 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -110,7 +110,7 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(PF_INET, NF_IP_FORWARD, skb, skb->dev, rt->u.dst.dev,
+	return NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, rt->u.dst.dev,
 		       ip_forward_finish);
 
 sr_failed:
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 168c871..5b8a760 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -268,7 +268,7 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -442,7 +442,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Remove any debris in the socket control block */
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 
-	return NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip_rcv_finish);
 
 inhdr_error:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e5f7dc2..3305c56 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -150,7 +150,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	skb->priority = sk->sk_priority;
 
 	/* Send it out. */
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		       dst_output);
 }
 
@@ -251,8 +251,8 @@ int ip_mc_output(struct sk_buff *skb)
 		) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
-				NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
-					newskb->dev,
+				NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb,
+					NULL, newskb->dev,
 					ip_dev_loopback_xmit);
 		}
 
@@ -267,11 +267,11 @@ int ip_mc_output(struct sk_buff *skb)
 	if (rt->rt_flags&RTCF_BROADCAST) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
-			NF_HOOK(PF_INET, NF_IP_POST_ROUTING, newskb, NULL,
+			NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb, NULL,
 				newskb->dev, ip_dev_loopback_xmit);
 	}
 
-	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dev,
+	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
@@ -285,7 +285,7 @@ int ip_output(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, dev,
+	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb, NULL, dev,
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
@@ -371,7 +371,7 @@ packet_routed:
 
 	skb->priority = sk->sk_priority;
 
-	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	return NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		       dst_output);
 
 no_route:
@@ -1266,7 +1266,7 @@ int ip_push_pending_frames(struct sock *sk)
 			skb_transport_header(skb))->type);
 
 	/* Netfilter gets whole the not fragmented skb. */
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
+	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 37bb497..7c1bd0c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1245,7 +1245,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	 * not mrouter) cannot join to more than one interface - it will
 	 * result in receiving multiple packets.
 	 */
-	NF_HOOK(PF_INET, NF_IP_FORWARD, skb, skb->dev, dev,
+	NF_HOOK(PF_INET, NF_INET_FORWARD, skb, skb->dev, dev,
 		ipmr_forward_finish);
 	return;
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index c6ed765..e2c883f 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -481,7 +481,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 
 
 /*
- *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_IP_POST_ROUTING
+ *      It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
  *      chain, and is used for VS/NAT.
  *      It detects packets for VS/NAT connections and sends the packets
  *      immediately. This can avoid that iptable_nat mangles the packets
@@ -679,7 +679,7 @@ static inline int is_tcp_reset(const struct sk_buff *skb)
 }
 
 /*
- *	It is hooked at the NF_IP_FORWARD chain, used only for VS/NAT.
+ *	It is hooked at the NF_INET_FORWARD chain, used only for VS/NAT.
  *	Check if outgoing packet belongs to the established ip_vs_conn,
  *      rewrite addresses of the packet and send it on its way...
  */
@@ -814,7 +814,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 
 	/* reassemble IP fragments */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (ip_vs_gather_frags(skb, hooknum == NF_IP_LOCAL_IN ?
+		if (ip_vs_gather_frags(skb, hooknum == NF_INET_LOCAL_IN ?
 					    IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD))
 			return NF_STOLEN;
 	}
@@ -995,12 +995,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 
 
 /*
- *	It is hooked at the NF_IP_FORWARD chain, in order to catch ICMP
+ *	It is hooked at the NF_INET_FORWARD chain, in order to catch ICMP
  *      related packets destined for 0.0.0.0/0.
  *      When fwmark-based virtual service is used, such as transparent
  *      cache cluster, TCP packets can be marked and routed to ip_vs_in,
  *      but ICMP destined for 0.0.0.0/0 cannot not be easily marked and
- *      sent to ip_vs_in_icmp. So, catch them at the NF_IP_FORWARD chain
+ *      sent to ip_vs_in_icmp. So, catch them at the NF_INET_FORWARD chain
  *      and send them to ip_vs_in_icmp.
  */
 static unsigned int
@@ -1024,7 +1024,7 @@ static struct nf_hook_ops ip_vs_in_ops = {
 	.hook		= ip_vs_in,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_LOCAL_IN,
+	.hooknum        = NF_INET_LOCAL_IN,
 	.priority       = 100,
 };
 
@@ -1033,7 +1033,7 @@ static struct nf_hook_ops ip_vs_out_ops = {
 	.hook		= ip_vs_out,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
+	.hooknum        = NF_INET_FORWARD,
 	.priority       = 100,
 };
 
@@ -1043,7 +1043,7 @@ static struct nf_hook_ops ip_vs_forward_icmp_ops = {
 	.hook		= ip_vs_forward_icmp,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_FORWARD,
+	.hooknum        = NF_INET_FORWARD,
 	.priority       = 99,
 };
 
@@ -1052,7 +1052,7 @@ static struct nf_hook_ops ip_vs_post_routing_ops = {
 	.hook		= ip_vs_post_routing,
 	.owner		= THIS_MODULE,
 	.pf		= PF_INET,
-	.hooknum        = NF_IP_POST_ROUTING,
+	.hooknum        = NF_INET_POST_ROUTING,
 	.priority       = NF_IP_PRI_NAT_SRC-1,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 7c074e3..526e48e 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -129,7 +129,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 do {							\
 	(skb)->ipvs_property = 1;			\
 	skb_forward_csum(skb);				\
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
+	NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 5539deb..d902246 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -23,7 +23,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		addr_type = type;
 
 	/* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
-	 * packets with foreign saddr to appear on the NF_IP_LOCAL_OUT hook.
+	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
 	 */
 	if (addr_type == RTN_LOCAL) {
 		fl.nl_u.ip4_u.daddr = iph->daddr;
@@ -126,7 +126,7 @@ static void nf_ip_saveroute(const struct sk_buff *skb, struct nf_info *info)
 {
 	struct ip_rt_info *rt_info = nf_info_reroute(info);
 
-	if (info->hook == NF_IP_LOCAL_OUT) {
+	if (info->hook == NF_INET_LOCAL_OUT) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		rt_info->tos = iph->tos;
@@ -139,7 +139,7 @@ static int nf_ip_reroute(struct sk_buff *skb, const struct nf_info *info)
 {
 	const struct ip_rt_info *rt_info = nf_info_reroute(info);
 
-	if (info->hook == NF_IP_LOCAL_OUT) {
+	if (info->hook == NF_INET_LOCAL_OUT) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (!(iph->tos == rt_info->tos
@@ -158,7 +158,7 @@ __sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (hook != NF_IP_PRE_ROUTING && hook != NF_IP_LOCAL_IN)
+		if (hook != NF_INET_PRE_ROUTING && hook != NF_INET_LOCAL_IN)
 			break;
 		if ((protocol == 0 && !csum_fold(skb->csum)) ||
 		    !csum_tcpudp_magic(iph->saddr, iph->daddr,
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 4b10b98..a99fe89 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -220,11 +220,11 @@ unconditional(const struct ipt_ip *ip)
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 static const char *hooknames[] = {
-	[NF_IP_PRE_ROUTING]		= "PREROUTING",
-	[NF_IP_LOCAL_IN]		= "INPUT",
-	[NF_IP_FORWARD]			= "FORWARD",
-	[NF_IP_LOCAL_OUT]		= "OUTPUT",
-	[NF_IP_POST_ROUTING]		= "POSTROUTING",
+	[NF_INET_PRE_ROUTING]		= "PREROUTING",
+	[NF_INET_LOCAL_IN]		= "INPUT",
+	[NF_INET_FORWARD]			= "FORWARD",
+	[NF_INET_LOCAL_OUT]		= "OUTPUT",
+	[NF_INET_POST_ROUTING]		= "POSTROUTING",
 };
 
 enum nf_ip_trace_comments {
@@ -465,7 +465,7 @@ mark_source_chains(struct xt_table_info *newinfo,
 
 	/* No recursion; use packet counter to save back ptrs (reset
 	   to 0 as we leave), and comefrom to save source hook bitmask */
-	for (hook = 0; hook < NF_IP_NUMHOOKS; hook++) {
+	for (hook = 0; hook < NF_INET_NUMHOOKS; hook++) {
 		unsigned int pos = newinfo->hook_entry[hook];
 		struct ipt_entry *e
 			= (struct ipt_entry *)(entry0 + pos);
@@ -481,13 +481,13 @@ mark_source_chains(struct xt_table_info *newinfo,
 				= (void *)ipt_get_target(e);
 			int visited = e->comefrom & (1 << hook);
 
-			if (e->comefrom & (1 << NF_IP_NUMHOOKS)) {
+			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
 				printk("iptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
 			e->comefrom
-				|= ((1 << hook) | (1 << NF_IP_NUMHOOKS));
+				|= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
 			if ((e->target_offset == sizeof(struct ipt_entry)
@@ -507,10 +507,10 @@ mark_source_chains(struct xt_table_info *newinfo,
 				/* Return: backtrack through the last
 				   big jump. */
 				do {
-					e->comefrom ^= (1<<NF_IP_NUMHOOKS);
+					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
 #ifdef DEBUG_IP_FIREWALL_USER
 					if (e->comefrom
-					    & (1 << NF_IP_NUMHOOKS)) {
+					    & (1 << NF_INET_NUMHOOKS)) {
 						duprintf("Back unset "
 							 "on hook %u "
 							 "rule %u\n",
@@ -741,7 +741,7 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 	}
 
 	/* Check hooks & underflows */
-	for (h = 0; h < NF_IP_NUMHOOKS; h++) {
+	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -795,7 +795,7 @@ translate_table(const char *name,
 	newinfo->number = number;
 
 	/* Init all hooks to impossible value. */
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		newinfo->hook_entry[i] = 0xFFFFFFFF;
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
@@ -819,7 +819,7 @@ translate_table(const char *name,
 	}
 
 	/* Check hooks all assigned */
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(valid_hooks & (1 << i)))
 			continue;
@@ -1107,7 +1107,7 @@ static int compat_calc_entry(struct ipt_entry *e, struct xt_table_info *info,
 	if (ret)
 		return ret;
 
-	for (i = 0; i< NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		if (info->hook_entry[i] && (e < (struct ipt_entry *)
 				(base + info->hook_entry[i])))
 			newinfo->hook_entry[i] -= off;
@@ -1130,7 +1130,7 @@ static int compat_table_info(struct xt_table_info *info,
 	memset(newinfo, 0, sizeof(struct xt_table_info));
 	newinfo->size = info->size;
 	newinfo->number = info->number;
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
@@ -1479,8 +1479,8 @@ struct compat_ipt_replace {
 	u32			valid_hooks;
 	u32			num_entries;
 	u32			size;
-	u32			hook_entry[NF_IP_NUMHOOKS];
-	u32			underflow[NF_IP_NUMHOOKS];
+	u32			hook_entry[NF_INET_NUMHOOKS];
+	u32			underflow[NF_INET_NUMHOOKS];
 	u32			num_counters;
 	compat_uptr_t		counters;	/* struct ipt_counters * */
 	struct compat_ipt_entry	entries[0];
@@ -1638,7 +1638,7 @@ check_compat_entry_size_and_hooks(struct ipt_entry *e,
 		goto out;
 
 	/* Check hooks & underflows */
-	for (h = 0; h < NF_IP_NUMHOOKS; h++) {
+	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -1693,7 +1693,7 @@ static int compat_copy_entry_from_user(struct ipt_entry *e, void **dstptr,
 	xt_compat_target_from_user(t, dstptr, size);
 
 	de->next_offset = e->next_offset - (origsize - *size);
-	for (h = 0; h < NF_IP_NUMHOOKS; h++) {
+	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
 		if ((unsigned char *)de - base < newinfo->hook_entry[h])
 			newinfo->hook_entry[h] -= origsize - *size;
 		if ((unsigned char *)de - base < newinfo->underflow[h])
@@ -1746,7 +1746,7 @@ translate_compat_table(const char *name,
 	info->number = number;
 
 	/* Init all hooks to impossible value. */
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		info->hook_entry[i] = 0xFFFFFFFF;
 		info->underflow[i] = 0xFFFFFFFF;
 	}
@@ -1771,7 +1771,7 @@ translate_compat_table(const char *name,
 	}
 
 	/* Check hooks all assigned */
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(valid_hooks & (1 << i)))
 			continue;
@@ -1793,7 +1793,7 @@ translate_compat_table(const char *name,
 		goto out_unlock;
 
 	newinfo->number = number;
-	for (i = 0; i < NF_IP_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		newinfo->hook_entry[i] = info->hook_entry[i];
 		newinfo->underflow[i] = info->underflow[i];
 	}
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 44b516e..5a18997 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -67,7 +67,7 @@ masquerade_target(struct sk_buff *skb,
 	const struct rtable *rt;
 	__be32 newsrc;
 
-	NF_CT_ASSERT(hooknum == NF_IP_POST_ROUTING);
+	NF_CT_ASSERT(hooknum == NF_INET_POST_ROUTING);
 
 	ct = nf_ct_get(skb, &ctinfo);
 	nat = nfct_nat(ct);
@@ -172,7 +172,7 @@ static struct xt_target masquerade __read_mostly = {
 	.target		= masquerade_target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= 1 << NF_IP_POST_ROUTING,
+	.hooks		= 1 << NF_INET_POST_ROUTING,
 	.checkentry	= masquerade_check,
 	.me		= THIS_MODULE,
 };
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index f869929..973bbee 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -56,14 +56,14 @@ target(struct sk_buff *skb,
 	const struct nf_nat_multi_range_compat *mr = targinfo;
 	struct nf_nat_range newrange;
 
-	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING
-		     || hooknum == NF_IP_POST_ROUTING
-		     || hooknum == NF_IP_LOCAL_OUT);
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING
+		     || hooknum == NF_INET_POST_ROUTING
+		     || hooknum == NF_INET_LOCAL_OUT);
 	ct = nf_ct_get(skb, &ctinfo);
 
 	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
 
-	if (hooknum == NF_IP_PRE_ROUTING || hooknum == NF_IP_LOCAL_OUT)
+	if (hooknum == NF_INET_PRE_ROUTING || hooknum == NF_INET_LOCAL_OUT)
 		new_ip = ip_hdr(skb)->daddr & ~netmask;
 	else
 		new_ip = ip_hdr(skb)->saddr & ~netmask;
@@ -84,8 +84,9 @@ static struct xt_target target_module __read_mostly = {
 	.target 	= target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= (1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_POST_ROUTING) |
-			  (1 << NF_IP_LOCAL_OUT),
+	.hooks		= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT),
 	.checkentry 	= check,
 	.me 		= THIS_MODULE
 };
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index f7cf7d6..4757af2 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -60,14 +60,14 @@ redirect_target(struct sk_buff *skb,
 	const struct nf_nat_multi_range_compat *mr = targinfo;
 	struct nf_nat_range newrange;
 
-	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING
-		     || hooknum == NF_IP_LOCAL_OUT);
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING
+		     || hooknum == NF_INET_LOCAL_OUT);
 
 	ct = nf_ct_get(skb, &ctinfo);
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
 	/* Local packets: make them go to loopback */
-	if (hooknum == NF_IP_LOCAL_OUT)
+	if (hooknum == NF_INET_LOCAL_OUT)
 		newdst = htonl(0x7F000001);
 	else {
 		struct in_device *indev;
@@ -101,7 +101,7 @@ static struct xt_target redirect_reg __read_mostly = {
 	.target		= redirect_target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= (1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_OUT),
+	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= redirect_check,
 	.me		= THIS_MODULE,
 };
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index dcf4d21..8351183 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -124,7 +124,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	niph->id = 0;
 
 	addr_type = RTN_UNSPEC;
-	if (hook != NF_IP_FORWARD
+	if (hook != NF_INET_FORWARD
 #ifdef CONFIG_BRIDGE_NETFILTER
 	    || (nskb->nf_bridge && nskb->nf_bridge->mask & BRNF_BRIDGED)
 #endif
@@ -149,7 +149,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 
 	nf_ct_attach(nskb, oldskb);
 
-	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
+	NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
 		dst_output);
 	return;
 
@@ -240,8 +240,8 @@ static struct xt_target ipt_reject_reg __read_mostly = {
 	.target		= reject,
 	.targetsize	= sizeof(struct ipt_reject_info),
 	.table		= "filter",
-	.hooks		= (1 << NF_IP_LOCAL_IN) | (1 << NF_IP_FORWARD) |
-			  (1 << NF_IP_LOCAL_OUT),
+	.hooks		= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= check,
 	.me		= THIS_MODULE,
 };
diff --git a/net/ipv4/netfilter/ipt_SAME.c b/net/ipv4/netfilter/ipt_SAME.c
index 8988571..f2f62b5 100644
--- a/net/ipv4/netfilter/ipt_SAME.c
+++ b/net/ipv4/netfilter/ipt_SAME.c
@@ -119,8 +119,8 @@ same_target(struct sk_buff *skb,
 	struct nf_nat_range newrange;
 	const struct nf_conntrack_tuple *t;
 
-	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING ||
-			hooknum == NF_IP_POST_ROUTING);
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING ||
+			hooknum == NF_INET_POST_ROUTING);
 	ct = nf_ct_get(skb, &ctinfo);
 
 	t = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
@@ -158,7 +158,8 @@ static struct xt_target same_reg __read_mostly = {
 	.target		= same_target,
 	.targetsize	= sizeof(struct ipt_same_info),
 	.table		= "nat",
-	.hooks		= (1 << NF_IP_PRE_ROUTING | 1 << NF_IP_POST_ROUTING),
+	.hooks		= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING),
 	.checkentry	= same_check,
 	.destroy	= same_destroy,
 	.me		= THIS_MODULE,
diff --git a/net/ipv4/netfilter/ipt_owner.c b/net/ipv4/netfilter/ipt_owner.c
index b14e77d..6bc4bfe 100644
--- a/net/ipv4/netfilter/ipt_owner.c
+++ b/net/ipv4/netfilter/ipt_owner.c
@@ -73,7 +73,8 @@ static struct xt_match owner_match __read_mostly = {
 	.family		= AF_INET,
 	.match		= match,
 	.matchsize	= sizeof(struct ipt_owner_info),
-	.hooks		= (1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_POST_ROUTING),
+	.hooks		= (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_POST_ROUTING),
 	.checkentry	= checkentry,
 	.me		= THIS_MODULE,
 };
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index ba3262c..06ab64e 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -19,7 +19,9 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables filter table");
 
-#define FILTER_VALID_HOOKS ((1 << NF_IP_LOCAL_IN) | (1 << NF_IP_FORWARD) | (1 << NF_IP_LOCAL_OUT))
+#define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_FORWARD) | \
+			    (1 << NF_INET_LOCAL_OUT))
 
 static struct
 {
@@ -33,14 +35,14 @@ static struct
 		.num_entries = 4,
 		.size = sizeof(struct ipt_standard) * 3 + sizeof(struct ipt_error),
 		.hook_entry = {
-			[NF_IP_LOCAL_IN] = 0,
-			[NF_IP_FORWARD] = sizeof(struct ipt_standard),
-			[NF_IP_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
+			[NF_INET_LOCAL_IN] = 0,
+			[NF_INET_FORWARD] = sizeof(struct ipt_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
 		},
 		.underflow = {
-			[NF_IP_LOCAL_IN] = 0,
-			[NF_IP_FORWARD] = sizeof(struct ipt_standard),
-			[NF_IP_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
+			[NF_INET_LOCAL_IN] = 0,
+			[NF_INET_FORWARD] = sizeof(struct ipt_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2,
 		},
 	},
 	.entries = {
@@ -94,21 +96,21 @@ static struct nf_hook_ops ipt_ops[] = {
 		.hook		= ipt_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
 		.hook		= ipt_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_FORWARD,
+		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
 		.hook		= ipt_local_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 };
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index b4360a6..0335827 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -21,11 +21,11 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables mangle table");
 
-#define MANGLE_VALID_HOOKS ((1 << NF_IP_PRE_ROUTING) | \
-			    (1 << NF_IP_LOCAL_IN) | \
-			    (1 << NF_IP_FORWARD) | \
-			    (1 << NF_IP_LOCAL_OUT) | \
-			    (1 << NF_IP_POST_ROUTING))
+#define MANGLE_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | \
+			    (1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_FORWARD) | \
+			    (1 << NF_INET_LOCAL_OUT) | \
+			    (1 << NF_INET_POST_ROUTING))
 
 /* Ouch - five different hooks? Maybe this should be a config option..... -- BC */
 static struct
@@ -40,18 +40,18 @@ static struct
 		.num_entries = 6,
 		.size = sizeof(struct ipt_standard) * 5 + sizeof(struct ipt_error),
 		.hook_entry = {
-			[NF_IP_PRE_ROUTING] 	= 0,
-			[NF_IP_LOCAL_IN] 	= sizeof(struct ipt_standard),
-			[NF_IP_FORWARD] 	= sizeof(struct ipt_standard) * 2,
-			[NF_IP_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
-			[NF_IP_POST_ROUTING] 	= sizeof(struct ipt_standard) * 4,
+			[NF_INET_PRE_ROUTING] 	= 0,
+			[NF_INET_LOCAL_IN] 	= sizeof(struct ipt_standard),
+			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard) * 2,
+			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
+			[NF_INET_POST_ROUTING] 	= sizeof(struct ipt_standard) * 4,
 		},
 		.underflow = {
-			[NF_IP_PRE_ROUTING] 	= 0,
-			[NF_IP_LOCAL_IN] 	= sizeof(struct ipt_standard),
-			[NF_IP_FORWARD] 	= sizeof(struct ipt_standard) * 2,
-			[NF_IP_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
-			[NF_IP_POST_ROUTING]	= sizeof(struct ipt_standard) * 4,
+			[NF_INET_PRE_ROUTING] 	= 0,
+			[NF_INET_LOCAL_IN] 	= sizeof(struct ipt_standard),
+			[NF_INET_FORWARD] 	= sizeof(struct ipt_standard) * 2,
+			[NF_INET_LOCAL_OUT] 	= sizeof(struct ipt_standard) * 3,
+			[NF_INET_POST_ROUTING]	= sizeof(struct ipt_standard) * 4,
 		},
 	},
 	.entries = {
@@ -133,35 +133,35 @@ static struct nf_hook_ops ipt_ops[] = {
 		.hook		= ipt_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_FORWARD,
+		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_local_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
 		.hook		= ipt_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 };
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 5de6e57..11be0ee 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -7,7 +7,7 @@
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <net/ip.h>
 
-#define RAW_VALID_HOOKS ((1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_OUT))
+#define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
 static struct
 {
@@ -21,12 +21,12 @@ static struct
 		.num_entries = 3,
 		.size = sizeof(struct ipt_standard) * 2 + sizeof(struct ipt_error),
 		.hook_entry = {
-			[NF_IP_PRE_ROUTING] = 0,
-			[NF_IP_LOCAL_OUT] = sizeof(struct ipt_standard)
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard)
 		},
 		.underflow = {
-			[NF_IP_PRE_ROUTING] = 0,
-			[NF_IP_LOCAL_OUT]  = sizeof(struct ipt_standard)
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_LOCAL_OUT]  = sizeof(struct ipt_standard)
 		},
 	},
 	.entries = {
@@ -78,14 +78,14 @@ static struct nf_hook_ops ipt_ops[] = {
 	{
 		.hook = ipt_hook,
 		.pf = PF_INET,
-		.hooknum = NF_IP_PRE_ROUTING,
+		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP_PRI_RAW,
 		.owner = THIS_MODULE,
 	},
 	{
 		.hook = ipt_local_hook,
 		.pf = PF_INET,
-		.hooknum = NF_IP_LOCAL_OUT,
+		.hooknum = NF_INET_LOCAL_OUT,
 		.priority = NF_IP_PRI_RAW,
 		.owner = THIS_MODULE,
 	},
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 831e9b2..9ac3020 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -150,7 +150,7 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 		if (nf_ct_ipv4_gather_frags(skb,
-					    hooknum == NF_IP_PRE_ROUTING ?
+					    hooknum == NF_INET_PRE_ROUTING ?
 					    IP_DEFRAG_CONNTRACK_IN :
 					    IP_DEFRAG_CONNTRACK_OUT))
 			return NF_STOLEN;
@@ -190,56 +190,56 @@ static struct nf_hook_ops ipv4_conntrack_ops[] = {
 		.hook		= ipv4_conntrack_defrag,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv4_conntrack_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook           = ipv4_conntrack_defrag,
 		.owner          = THIS_MODULE,
 		.pf             = PF_INET,
-		.hooknum        = NF_IP_LOCAL_OUT,
+		.hooknum        = NF_INET_LOCAL_OUT,
 		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv4_conntrack_local,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv4_conntrack_help,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv4_conntrack_help,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
 	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
 };
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index adcbaf6..0e2c448 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -195,7 +195,7 @@ icmp_error(struct sk_buff *skb, unsigned int dataoff,
 	}
 
 	/* See ip_conntrack_proto_tcp.c */
-	if (nf_conntrack_checksum && hooknum == NF_IP_PRE_ROUTING &&
+	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip_checksum(skb, hooknum, dataoff, 0)) {
 		if (LOG_INVALID(IPPROTO_ICMP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 70e7997..eac75eb 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -213,9 +213,9 @@ find_best_ips_proto(struct nf_conntrack_tuple *tuple,
 	*var_ipp = htonl(minip + j % (maxip - minip + 1));
 }
 
-/* Manipulate the tuple into the range given.  For NF_IP_POST_ROUTING,
- * we change the source to map into the range.  For NF_IP_PRE_ROUTING
- * and NF_IP_LOCAL_OUT, we change the destination to map into the
+/* Manipulate the tuple into the range given.  For NF_INET_POST_ROUTING,
+ * we change the source to map into the range.  For NF_INET_PRE_ROUTING
+ * and NF_INET_LOCAL_OUT, we change the destination to map into the
  * range.  It might not be possible to get a unique tuple, but we try.
  * At worst (or if we race), we will end up with a final duplicate in
  * __ip_conntrack_confirm and drop the packet. */
@@ -293,10 +293,10 @@ nf_nat_setup_info(struct nf_conn *ct,
 		}
 	}
 
-	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING ||
-		     hooknum == NF_IP_POST_ROUTING ||
-		     hooknum == NF_IP_LOCAL_IN ||
-		     hooknum == NF_IP_LOCAL_OUT);
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING ||
+		     hooknum == NF_INET_POST_ROUTING ||
+		     hooknum == NF_INET_LOCAL_IN ||
+		     hooknum == NF_INET_LOCAL_OUT);
 	BUG_ON(nf_nat_initialized(ct, maniptype));
 
 	/* What we've got will look like inverse of reply. Normally
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 93e18ef..0f226df 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -391,7 +391,7 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
 
 	/* hook doesn't matter, but it has to do source manip */
-	nf_nat_setup_info(new, &range, NF_IP_POST_ROUTING);
+	nf_nat_setup_info(new, &range, NF_INET_POST_ROUTING);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
@@ -400,7 +400,7 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 	    new->master->tuplehash[!this->dir].tuple.src.u3.ip;
 
 	/* hook doesn't matter, but it has to do destination manip */
-	nf_nat_setup_info(new, &range, NF_IP_PRE_ROUTING);
+	nf_nat_setup_info(new, &range, NF_INET_PRE_ROUTING);
 }
 
 /****************************************************************************/
@@ -481,7 +481,7 @@ static void ip_nat_callforwarding_expect(struct nf_conn *new,
 	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
 
 	/* hook doesn't matter, but it has to do source manip */
-	nf_nat_setup_info(new, &range, NF_IP_POST_ROUTING);
+	nf_nat_setup_info(new, &range, NF_INET_POST_ROUTING);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
@@ -489,7 +489,7 @@ static void ip_nat_callforwarding_expect(struct nf_conn *new,
 	range.min_ip = range.max_ip = this->saved_ip;
 
 	/* hook doesn't matter, but it has to do destination manip */
-	nf_nat_setup_info(new, &range, NF_IP_PRE_ROUTING);
+	nf_nat_setup_info(new, &range, NF_INET_PRE_ROUTING);
 }
 
 /****************************************************************************/
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 8718da0..d00b8b2 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -431,7 +431,7 @@ void nf_nat_follow_master(struct nf_conn *ct,
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
 	/* hook doesn't matter, but it has to do source manip */
-	nf_nat_setup_info(ct, &range, NF_IP_POST_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_POST_ROUTING);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
@@ -439,6 +439,6 @@ void nf_nat_follow_master(struct nf_conn *ct,
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.src.u3.ip;
 	/* hook doesn't matter, but it has to do destination manip */
-	nf_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_PRE_ROUTING);
 }
 EXPORT_SYMBOL(nf_nat_follow_master);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 6817e79..c540999 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -94,7 +94,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 		range.min = range.max = exp->saved_proto;
 	}
 	/* hook doesn't matter, but it has to do source manip */
-	nf_nat_setup_info(ct, &range, NF_IP_POST_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_POST_ROUTING);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = IP_NAT_RANGE_MAP_IPS;
@@ -105,7 +105,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 		range.min = range.max = exp->saved_proto;
 	}
 	/* hook doesn't matter, but it has to do destination manip */
-	nf_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_PRE_ROUTING);
 }
 
 /* outbound packets == from PNS to PAC */
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 46b25ab..ee39ed8 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -24,7 +24,9 @@
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_rule.h>
 
-#define NAT_VALID_HOOKS ((1<<NF_IP_PRE_ROUTING) | (1<<NF_IP_POST_ROUTING) | (1<<NF_IP_LOCAL_OUT))
+#define NAT_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | \
+			 (1 << NF_INET_POST_ROUTING) | \
+			 (1 << NF_INET_LOCAL_OUT))
 
 static struct
 {
@@ -38,14 +40,14 @@ static struct
 		.num_entries = 4,
 		.size = sizeof(struct ipt_standard) * 3 + sizeof(struct ipt_error),
 		.hook_entry = {
-			[NF_IP_PRE_ROUTING] = 0,
-			[NF_IP_POST_ROUTING] = sizeof(struct ipt_standard),
-			[NF_IP_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_POST_ROUTING] = sizeof(struct ipt_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
 		},
 		.underflow = {
-			[NF_IP_PRE_ROUTING] = 0,
-			[NF_IP_POST_ROUTING] = sizeof(struct ipt_standard),
-			[NF_IP_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_POST_ROUTING] = sizeof(struct ipt_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ipt_standard) * 2
 		},
 	},
 	.entries = {
@@ -76,7 +78,7 @@ static unsigned int ipt_snat_target(struct sk_buff *skb,
 	enum ip_conntrack_info ctinfo;
 	const struct nf_nat_multi_range_compat *mr = targinfo;
 
-	NF_CT_ASSERT(hooknum == NF_IP_POST_ROUTING);
+	NF_CT_ASSERT(hooknum == NF_INET_POST_ROUTING);
 
 	ct = nf_ct_get(skb, &ctinfo);
 
@@ -118,15 +120,15 @@ static unsigned int ipt_dnat_target(struct sk_buff *skb,
 	enum ip_conntrack_info ctinfo;
 	const struct nf_nat_multi_range_compat *mr = targinfo;
 
-	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING ||
-		     hooknum == NF_IP_LOCAL_OUT);
+	NF_CT_ASSERT(hooknum == NF_INET_PRE_ROUTING ||
+		     hooknum == NF_INET_LOCAL_OUT);
 
 	ct = nf_ct_get(skb, &ctinfo);
 
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
-	if (hooknum == NF_IP_LOCAL_OUT &&
+	if (hooknum == NF_INET_LOCAL_OUT &&
 	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
 		warn_if_extra_mangle(ip_hdr(skb)->daddr,
 				     mr->range[0].min_ip);
@@ -227,7 +229,7 @@ static struct xt_target ipt_snat_reg __read_mostly = {
 	.target		= ipt_snat_target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= 1 << NF_IP_POST_ROUTING,
+	.hooks		= 1 << NF_INET_POST_ROUTING,
 	.checkentry	= ipt_snat_checkentry,
 	.family		= AF_INET,
 };
@@ -237,7 +239,7 @@ static struct xt_target ipt_dnat_reg __read_mostly = {
 	.target		= ipt_dnat_target,
 	.targetsize	= sizeof(struct nf_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= (1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_OUT),
+	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= ipt_dnat_checkentry,
 	.family		= AF_INET,
 };
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 3ca9897..6ebf509 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -229,14 +229,14 @@ static void ip_nat_sdp_expect(struct nf_conn *ct,
 	range.min_ip = range.max_ip
 		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
 	/* hook doesn't matter, but it has to do source manip */
-	nf_nat_setup_info(ct, &range, NF_IP_POST_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_POST_ROUTING);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (IP_NAT_RANGE_MAP_IPS | IP_NAT_RANGE_PROTO_SPECIFIED);
 	range.min = range.max = exp->saved_proto;
 	range.min_ip = range.max_ip = exp->saved_ip;
 	/* hook doesn't matter, but it has to do destination manip */
-	nf_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
+	nf_nat_setup_info(ct, &range, NF_INET_PRE_ROUTING);
 }
 
 /* So, this packet has hit the connection tracking matching code.
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 7db76ea..84172e9 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -137,7 +137,7 @@ nf_nat_fn(unsigned int hooknum,
 			if (unlikely(nf_ct_is_confirmed(ct)))
 				/* NAT module was loaded late */
 				ret = alloc_null_binding_confirmed(ct, hooknum);
-			else if (hooknum == NF_IP_LOCAL_IN)
+			else if (hooknum == NF_INET_LOCAL_IN)
 				/* LOCAL_IN hook doesn't have a chain!  */
 				ret = alloc_null_binding(ct, hooknum);
 			else
@@ -279,7 +279,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_NAT_DST,
 	},
 	/* After packet filtering, change source */
@@ -287,7 +287,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_out,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_NAT_SRC,
 	},
 	/* After conntrack, adjust sequence number */
@@ -295,7 +295,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_adjust,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_NAT_SEQ_ADJUST,
 	},
 	/* Before packet filtering, change destination */
@@ -303,7 +303,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_local_fn,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST,
 	},
 	/* After packet filtering, change source */
@@ -311,7 +311,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_fn,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC,
 	},
 	/* After conntrack, adjust sequence number */
@@ -319,7 +319,7 @@ static struct nf_hook_ops nf_nat_ops[] = {
 		.hook		= nf_nat_adjust,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
-		.hooknum	= NF_IP_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SEQ_ADJUST,
 	},
 };
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3916fac..cb12204 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -318,7 +318,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 		icmp_out_count(((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	err = NF_HOOK(PF_INET, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5e95c8a..f1ca855 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -135,7 +135,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		ip_hdr(skb)->tot_len = htons(skb->len);
 		ip_send_check(ip_hdr(skb));
 
-		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+		NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 			xfrm4_rcv_encap_finish);
 		return 0;
 #else
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c4a7156..28c7f9d 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -78,7 +78,7 @@ static int xfrm4_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm4_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
+		err = nf_hook(PF_INET, NF_INET_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, dst_output);
 		if (unlikely(err != 1))
 			break;
@@ -86,7 +86,7 @@ static int xfrm4_output_finish2(struct sk_buff *skb)
 		if (!skb->dst->xfrm)
 			return dst_output(skb);
 
-		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+		err = nf_hook(PF_INET, NF_INET_POST_ROUTING, skb, NULL,
 			      skb->dst->dev, xfrm4_output_finish2);
 		if (unlikely(err != 1))
 			break;
@@ -139,7 +139,7 @@ static int xfrm4_output_finish(struct sk_buff *skb)
 
 int xfrm4_output(struct sk_buff *skb)
 {
-	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
-			    xfrm4_output_finish,
+	return NF_HOOK_COND(PF_INET, NF_INET_POST_ROUTING, skb,
+			    NULL, skb->dst->dev, xfrm4_output_finish,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index fac6f7f..79610b4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -134,7 +134,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	rcu_read_unlock();
 
-	return NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
+	return NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, dev, NULL,
+		       ip6_rcv_finish);
 err:
 	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
 drop:
@@ -229,7 +230,8 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6,NF_IP6_LOCAL_IN, skb, skb->dev, NULL, ip6_input_finish);
+	return NF_HOOK(PF_INET6, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
+		       ip6_input_finish);
 }
 
 int ip6_mc_input(struct sk_buff *skb)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 653fc0a..1a84b74 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -120,8 +120,8 @@ static int ip6_output2(struct sk_buff *skb)
 			   is not supported in any case.
 			 */
 			if (newskb)
-				NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, newskb, NULL,
-					newskb->dev,
+				NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, newskb,
+					NULL, newskb->dev,
 					ip6_dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
@@ -134,7 +134,8 @@ static int ip6_output2(struct sk_buff *skb)
 		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
 	}
 
-	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
+	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
+		       ip6_output_finish);
 }
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
@@ -236,7 +237,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if ((skb->len <= mtu) || ipfragok || skb_is_gso(skb)) {
 		IP6_INC_STATS(ip6_dst_idev(skb->dst),
 			      IPSTATS_MIB_OUTREQUESTS);
-		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
+		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
 	}
 
@@ -500,7 +501,8 @@ int ip6_forward(struct sk_buff *skb)
 	hdr->hop_limit--;
 
 	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	return NF_HOOK(PF_INET6,NF_IP6_FORWARD, skb, skb->dev, dst->dev, ip6_forward_finish);
+	return NF_HOOK(PF_INET6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
+		       ip6_forward_finish);
 
 error:
 	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
@@ -1406,7 +1408,8 @@ int ip6_push_pending_frames(struct sock *sk)
 		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
 	}
 
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dst->dev,
+		      dst_output);
 	if (err) {
 		if (err > 0)
 			err = np->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5383b33..2f30ca2 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -917,7 +917,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6_addr_copy(&ipv6h->daddr, &fl->fl6_dst);
 	nf_reset(skb);
 	pkt_len = skb->len;
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
 
 	if (net_xmit_eval(err) == 0) {
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 331d728..27e2821 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1450,7 +1450,7 @@ static inline int mld_dev_queue_xmit2(struct sk_buff *skb)
 
 static inline int mld_dev_queue_xmit(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dev,
+	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
 		       mld_dev_queue_xmit2);
 }
 
@@ -1471,7 +1471,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	pmr->csum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
 		IPPROTO_ICMPV6, csum_partial(skb_transport_header(skb),
 					     mldlen, 0));
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		mld_dev_queue_xmit);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS_BH(idev, ICMPV6_MLD2_REPORT);
@@ -1815,7 +1815,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	idev = in6_dev_get(skb->dev);
 
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		mld_dev_queue_xmit);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 36f7dbf..0ed3216 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -533,7 +533,8 @@ static void __ndisc_send(struct net_device *dev,
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
 
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
+		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, type);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -1537,7 +1538,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
+		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, NDISC_REDIRECT);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index b1326c2..175e19f 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -60,7 +60,7 @@ static void nf_ip6_saveroute(const struct sk_buff *skb, struct nf_info *info)
 {
 	struct ip6_rt_info *rt_info = nf_info_reroute(info);
 
-	if (info->hook == NF_IP6_LOCAL_OUT) {
+	if (info->hook == NF_INET_LOCAL_OUT) {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		rt_info->daddr = iph->daddr;
@@ -72,7 +72,7 @@ static int nf_ip6_reroute(struct sk_buff *skb, const struct nf_info *info)
 {
 	struct ip6_rt_info *rt_info = nf_info_reroute(info);
 
-	if (info->hook == NF_IP6_LOCAL_OUT) {
+	if (info->hook == NF_INET_LOCAL_OUT) {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr))
@@ -89,7 +89,7 @@ __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (hook != NF_IP6_PRE_ROUTING && hook != NF_IP6_LOCAL_IN)
+		if (hook != NF_INET_PRE_ROUTING && hook != NF_INET_LOCAL_IN)
 			break;
 		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
 				     skb->len - dataoff, protocol,
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index acaba15..e1e87ef 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -258,11 +258,11 @@ unconditional(const struct ip6t_ip6 *ipv6)
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 /* This cries for unification! */
 static const char *hooknames[] = {
-	[NF_IP6_PRE_ROUTING]		= "PREROUTING",
-	[NF_IP6_LOCAL_IN]		= "INPUT",
-	[NF_IP6_FORWARD]		= "FORWARD",
-	[NF_IP6_LOCAL_OUT]		= "OUTPUT",
-	[NF_IP6_POST_ROUTING]		= "POSTROUTING",
+	[NF_INET_PRE_ROUTING]		= "PREROUTING",
+	[NF_INET_LOCAL_IN]		= "INPUT",
+	[NF_INET_FORWARD]		= "FORWARD",
+	[NF_INET_LOCAL_OUT]		= "OUTPUT",
+	[NF_INET_POST_ROUTING]		= "POSTROUTING",
 };
 
 enum nf_ip_trace_comments {
@@ -502,7 +502,7 @@ mark_source_chains(struct xt_table_info *newinfo,
 
 	/* No recursion; use packet counter to save back ptrs (reset
 	   to 0 as we leave), and comefrom to save source hook bitmask */
-	for (hook = 0; hook < NF_IP6_NUMHOOKS; hook++) {
+	for (hook = 0; hook < NF_INET_NUMHOOKS; hook++) {
 		unsigned int pos = newinfo->hook_entry[hook];
 		struct ip6t_entry *e
 			= (struct ip6t_entry *)(entry0 + pos);
@@ -518,13 +518,13 @@ mark_source_chains(struct xt_table_info *newinfo,
 			struct ip6t_standard_target *t
 				= (void *)ip6t_get_target(e);
 
-			if (e->comefrom & (1 << NF_IP6_NUMHOOKS)) {
+			if (e->comefrom & (1 << NF_INET_NUMHOOKS)) {
 				printk("iptables: loop hook %u pos %u %08X.\n",
 				       hook, pos, e->comefrom);
 				return 0;
 			}
 			e->comefrom
-				|= ((1 << hook) | (1 << NF_IP6_NUMHOOKS));
+				|= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
 
 			/* Unconditional return/END. */
 			if ((e->target_offset == sizeof(struct ip6t_entry)
@@ -544,10 +544,10 @@ mark_source_chains(struct xt_table_info *newinfo,
 				/* Return: backtrack through the last
 				   big jump. */
 				do {
-					e->comefrom ^= (1<<NF_IP6_NUMHOOKS);
+					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
 #ifdef DEBUG_IP_FIREWALL_USER
 					if (e->comefrom
-					    & (1 << NF_IP6_NUMHOOKS)) {
+					    & (1 << NF_INET_NUMHOOKS)) {
 						duprintf("Back unset "
 							 "on hook %u "
 							 "rule %u\n",
@@ -746,7 +746,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 	}
 
 	/* Check hooks & underflows */
-	for (h = 0; h < NF_IP6_NUMHOOKS; h++) {
+	for (h = 0; h < NF_INET_NUMHOOKS; h++) {
 		if ((unsigned char *)e - base == hook_entries[h])
 			newinfo->hook_entry[h] = hook_entries[h];
 		if ((unsigned char *)e - base == underflows[h])
@@ -800,7 +800,7 @@ translate_table(const char *name,
 	newinfo->number = number;
 
 	/* Init all hooks to impossible value. */
-	for (i = 0; i < NF_IP6_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		newinfo->hook_entry[i] = 0xFFFFFFFF;
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
@@ -824,7 +824,7 @@ translate_table(const char *name,
 	}
 
 	/* Check hooks all assigned */
-	for (i = 0; i < NF_IP6_NUMHOOKS; i++) {
+	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
 		/* Only hooks which are valid */
 		if (!(valid_hooks & (1 << i)))
 			continue;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 1a7d291..9d45e9e 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -159,14 +159,14 @@ static void send_reset(struct sk_buff *oldskb)
 
 	nf_ct_attach(nskb, oldskb);
 
-	NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
+	NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
 		dst_output);
 }
 
 static inline void
 send_unreach(struct sk_buff *skb_in, unsigned char code, unsigned int hooknum)
 {
-	if (hooknum == NF_IP6_LOCAL_OUT && skb_in->dev == NULL)
+	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
 		skb_in->dev = init_net.loopback_dev;
 
 	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0, NULL);
@@ -245,8 +245,8 @@ static struct xt_target ip6t_reject_reg __read_mostly = {
 	.target		= reject6_target,
 	.targetsize	= sizeof(struct ip6t_reject_info),
 	.table		= "filter",
-	.hooks		= (1 << NF_IP6_LOCAL_IN) | (1 << NF_IP6_FORWARD) |
-			  (1 << NF_IP6_LOCAL_OUT),
+	.hooks		= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_LOCAL_OUT),
 	.checkentry	= check,
 	.me		= THIS_MODULE
 };
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index 34ba150..00084e8 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -67,8 +67,8 @@ static struct xt_match eui64_match __read_mostly = {
 	.family		= AF_INET6,
 	.match		= match,
 	.matchsize	= sizeof(int),
-	.hooks		= (1 << NF_IP6_PRE_ROUTING) | (1 << NF_IP6_LOCAL_IN) |
-			  (1 << NF_IP6_FORWARD),
+	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_IN) |
+			  (1 << NF_INET_FORWARD),
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/ipv6/netfilter/ip6t_owner.c b/net/ipv6/netfilter/ip6t_owner.c
index 6036613..1e0dc4a 100644
--- a/net/ipv6/netfilter/ip6t_owner.c
+++ b/net/ipv6/netfilter/ip6t_owner.c
@@ -73,7 +73,8 @@ static struct xt_match owner_match __read_mostly = {
 	.family		= AF_INET6,
 	.match		= match,
 	.matchsize	= sizeof(struct ip6t_owner_info),
-	.hooks		= (1 << NF_IP6_LOCAL_OUT) | (1 << NF_IP6_POST_ROUTING),
+	.hooks		= (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_POST_ROUTING),
 	.checkentry	= checkentry,
 	.me		= THIS_MODULE,
 };
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 1d26b20..0ae072d 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -17,7 +17,9 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("ip6tables filter table");
 
-#define FILTER_VALID_HOOKS ((1 << NF_IP6_LOCAL_IN) | (1 << NF_IP6_FORWARD) | (1 << NF_IP6_LOCAL_OUT))
+#define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_FORWARD) | \
+			    (1 << NF_INET_LOCAL_OUT))
 
 static struct
 {
@@ -31,14 +33,14 @@ static struct
 		.num_entries = 4,
 		.size = sizeof(struct ip6t_standard) * 3 + sizeof(struct ip6t_error),
 		.hook_entry = {
-			[NF_IP6_LOCAL_IN] = 0,
-			[NF_IP6_FORWARD] = sizeof(struct ip6t_standard),
-			[NF_IP6_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
+			[NF_INET_LOCAL_IN] = 0,
+			[NF_INET_FORWARD] = sizeof(struct ip6t_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
 		},
 		.underflow = {
-			[NF_IP6_LOCAL_IN] = 0,
-			[NF_IP6_FORWARD] = sizeof(struct ip6t_standard),
-			[NF_IP6_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
+			[NF_INET_LOCAL_IN] = 0,
+			[NF_INET_FORWARD] = sizeof(struct ip6t_standard),
+			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard) * 2
 		},
 	},
 	.entries = {
@@ -93,21 +95,21 @@ static struct nf_hook_ops ip6t_ops[] = {
 		.hook		= ip6t_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
 		.hook		= ip6t_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_FORWARD,
+		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
 		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 };
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index a0b6381..8e62b23 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -15,11 +15,11 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("ip6tables mangle table");
 
-#define MANGLE_VALID_HOOKS ((1 << NF_IP6_PRE_ROUTING) | \
-			    (1 << NF_IP6_LOCAL_IN) | \
-			    (1 << NF_IP6_FORWARD) | \
-			    (1 << NF_IP6_LOCAL_OUT) | \
-			    (1 << NF_IP6_POST_ROUTING))
+#define MANGLE_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | \
+			    (1 << NF_INET_LOCAL_IN) | \
+			    (1 << NF_INET_FORWARD) | \
+			    (1 << NF_INET_LOCAL_OUT) | \
+			    (1 << NF_INET_POST_ROUTING))
 
 static struct
 {
@@ -33,18 +33,18 @@ static struct
 		.num_entries = 6,
 		.size = sizeof(struct ip6t_standard) * 5 + sizeof(struct ip6t_error),
 		.hook_entry = {
-			[NF_IP6_PRE_ROUTING] 	= 0,
-			[NF_IP6_LOCAL_IN]	= sizeof(struct ip6t_standard),
-			[NF_IP6_FORWARD]	= sizeof(struct ip6t_standard) * 2,
-			[NF_IP6_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
-			[NF_IP6_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
+			[NF_INET_PRE_ROUTING] 	= 0,
+			[NF_INET_LOCAL_IN]	= sizeof(struct ip6t_standard),
+			[NF_INET_FORWARD]	= sizeof(struct ip6t_standard) * 2,
+			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
+			[NF_INET_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
 		},
 		.underflow = {
-			[NF_IP6_PRE_ROUTING] 	= 0,
-			[NF_IP6_LOCAL_IN]	= sizeof(struct ip6t_standard),
-			[NF_IP6_FORWARD]	= sizeof(struct ip6t_standard) * 2,
-			[NF_IP6_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
-			[NF_IP6_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
+			[NF_INET_PRE_ROUTING] 	= 0,
+			[NF_INET_LOCAL_IN]	= sizeof(struct ip6t_standard),
+			[NF_INET_FORWARD]	= sizeof(struct ip6t_standard) * 2,
+			[NF_INET_LOCAL_OUT] 	= sizeof(struct ip6t_standard) * 3,
+			[NF_INET_POST_ROUTING]	= sizeof(struct ip6t_standard) * 4,
 		},
 	},
 	.entries = {
@@ -125,35 +125,35 @@ static struct nf_hook_ops ip6t_ops[] = {
 		.hook		= ip6t_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_local_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_FORWARD,
+		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_local_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
 		.hook		= ip6t_route_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 };
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 8f7109f..4fecd8d 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -6,7 +6,7 @@
 #include <linux/module.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 
-#define RAW_VALID_HOOKS ((1 << NF_IP6_PRE_ROUTING) | (1 << NF_IP6_LOCAL_OUT))
+#define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
 static struct
 {
@@ -20,12 +20,12 @@ static struct
 		.num_entries = 3,
 		.size = sizeof(struct ip6t_standard) * 2 + sizeof(struct ip6t_error),
 		.hook_entry = {
-			[NF_IP6_PRE_ROUTING] = 0,
-			[NF_IP6_LOCAL_OUT] = sizeof(struct ip6t_standard)
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard)
 		},
 		.underflow = {
-			[NF_IP6_PRE_ROUTING] = 0,
-			[NF_IP6_LOCAL_OUT] = sizeof(struct ip6t_standard)
+			[NF_INET_PRE_ROUTING] = 0,
+			[NF_INET_LOCAL_OUT] = sizeof(struct ip6t_standard)
 		},
 	},
 	.entries = {
@@ -58,14 +58,14 @@ static struct nf_hook_ops ip6t_ops[] = {
 	{
 	  .hook = ip6t_hook,
 	  .pf = PF_INET6,
-	  .hooknum = NF_IP6_PRE_ROUTING,
+	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
 	},
 	{
 	  .hook = ip6t_hook,
 	  .pf = PF_INET6,
-	  .hooknum = NF_IP6_LOCAL_OUT,
+	  .hooknum = NF_INET_LOCAL_OUT,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
 	},
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index ad74bab..50f4678 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -263,42 +263,42 @@ static struct nf_hook_ops ipv6_conntrack_ops[] = {
 		.hook		= ipv6_defrag,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv6_conntrack_in,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_PRE_ROUTING,
+		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_conntrack_local,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_defrag,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_OUT,
+		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_POST_ROUTING,
+		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_LAST,
 	},
 	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
-		.hooknum	= NF_IP6_LOCAL_IN,
+		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_LAST-1,
 	},
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index fd9123f..e99384f 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -192,7 +192,7 @@ icmpv6_error(struct sk_buff *skb, unsigned int dataoff,
 		return -NF_ACCEPT;
 	}
 
-	if (nf_conntrack_checksum && hooknum == NF_IP6_PRE_ROUTING &&
+	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip6_checksum(skb, hooknum, dataoff, IPPROTO_ICMPV6)) {
 		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
 			      "nf_ct_icmpv6: ICMPv6 checksum failed\n");
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ca24ef1..fb804e0 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -618,7 +618,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
+	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5157837..a0e103b 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -110,7 +110,7 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 		ipv6_hdr(skb)->payload_len = htons(skb->len);
 		__skb_push(skb, skb->data - skb_network_header(skb));
 
-		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
+		NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 			ip6_rcv_finish);
 		return -1;
 #else
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6569767..d6b05f9 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -80,7 +80,7 @@ static int xfrm6_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm6_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
+		err = nf_hook(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, dst_output);
 		if (unlikely(err != 1))
 			break;
@@ -88,7 +88,7 @@ static int xfrm6_output_finish2(struct sk_buff *skb)
 		if (!skb->dst->xfrm)
 			return dst_output(skb);
 
-		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
+		err = nf_hook(PF_INET6, NF_INET_POST_ROUTING, skb, NULL,
 			      skb->dst->dev, xfrm6_output_finish2);
 		if (unlikely(err != 1))
 			break;
@@ -134,6 +134,6 @@ static int xfrm6_output_finish(struct sk_buff *skb)
 
 int xfrm6_output(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
+	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dst->dev,
 		       xfrm6_output_finish);
 }
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9be1826..628bd65 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -829,18 +829,18 @@ ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 						&range) < 0)
 				return -EINVAL;
 			if (nf_nat_initialized(ct,
-					       HOOK2MANIP(NF_IP_PRE_ROUTING)))
+					       HOOK2MANIP(NF_INET_PRE_ROUTING)))
 				return -EEXIST;
-			nf_nat_setup_info(ct, &range, NF_IP_PRE_ROUTING);
+			nf_nat_setup_info(ct, &range, NF_INET_PRE_ROUTING);
 		}
 		if (cda[CTA_NAT_SRC]) {
 			if (nfnetlink_parse_nat(cda[CTA_NAT_SRC], ct,
 						&range) < 0)
 				return -EINVAL;
 			if (nf_nat_initialized(ct,
-					       HOOK2MANIP(NF_IP_POST_ROUTING)))
+					       HOOK2MANIP(NF_INET_POST_ROUTING)))
 				return -EEXIST;
-			nf_nat_setup_info(ct, &range, NF_IP_POST_ROUTING);
+			nf_nat_setup_info(ct, &range, NF_INET_POST_ROUTING);
 		}
 #endif
 	}
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 7a3f64c..d96f188 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -783,9 +783,7 @@ static int tcp_error(struct sk_buff *skb,
 	 * because the checksum is assumed to be correct.
 	 */
 	/* FIXME: Source route IP option packets --RR */
-	if (nf_conntrack_checksum &&
-	    ((pf == PF_INET && hooknum == NF_IP_PRE_ROUTING) ||
-	     (pf == PF_INET6 && hooknum == NF_IP6_PRE_ROUTING)) &&
+	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_TCP, pf)) {
 		if (LOG_INVALID(IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index b3e7ecb..570a2e1 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -128,9 +128,7 @@ static int udp_error(struct sk_buff *skb, unsigned int dataoff,
 	 * We skip checking packets on the outgoing path
 	 * because the checksum is assumed to be correct.
 	 * FIXME: Source route IP option packets --RR */
-	if (nf_conntrack_checksum &&
-	    ((pf == PF_INET && hooknum == NF_IP_PRE_ROUTING) ||
-	     (pf == PF_INET6 && hooknum == NF_IP6_PRE_ROUTING)) &&
+	if (nf_conntrack_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_checksum(skb, hooknum, dataoff, IPPROTO_UDP, pf)) {
 		if (LOG_INVALID(IPPROTO_UDP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index b8981dd..7e116d5 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -133,8 +133,7 @@ static int udplite_error(struct sk_buff *skb, unsigned int dataoff,
 
 	/* Checksum invalid? Ignore. */
 	if (nf_conntrack_checksum && !skb_csum_unnecessary(skb) &&
-	    ((pf == PF_INET && hooknum == NF_IP_PRE_ROUTING) ||
-	     (pf == PF_INET6 && hooknum == NF_IP6_PRE_ROUTING))) {
+	    hooknum == NF_INET_PRE_ROUTING) {
 		if (pf == PF_INET) {
 			struct iphdr *iph = ip_hdr(skb);
 
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index 77eeae6..e4f7f86 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -47,9 +47,9 @@ static struct xt_target xt_classify_target[] __read_mostly = {
 		.target 	= target,
 		.targetsize	= sizeof(struct xt_classify_target_info),
 		.table		= "mangle",
-		.hooks		= (1 << NF_IP_LOCAL_OUT) |
-				  (1 << NF_IP_FORWARD) |
-				  (1 << NF_IP_POST_ROUTING),
+		.hooks		= (1 << NF_INET_LOCAL_OUT) |
+				  (1 << NF_INET_FORWARD) |
+				  (1 << NF_INET_POST_ROUTING),
 		.me 		= THIS_MODULE,
 	},
 	{
@@ -58,9 +58,9 @@ static struct xt_target xt_classify_target[] __read_mostly = {
 		.target 	= target,
 		.targetsize	= sizeof(struct xt_classify_target_info),
 		.table		= "mangle",
-		.hooks		= (1 << NF_IP6_LOCAL_OUT) |
-				  (1 << NF_IP6_FORWARD) |
-				  (1 << NF_IP6_POST_ROUTING),
+		.hooks		= (1 << NF_INET_LOCAL_OUT) |
+				  (1 << NF_INET_FORWARD) |
+				  (1 << NF_INET_POST_ROUTING),
 		.me 		= THIS_MODULE,
 	},
 };
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 07435a6..851e121 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -216,9 +216,9 @@ xt_tcpmss_checkentry4(const char *tablename,
 	const struct ipt_entry *e = entry;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
-	    (hook_mask & ~((1 << NF_IP_FORWARD) |
-			   (1 << NF_IP_LOCAL_OUT) |
-			   (1 << NF_IP_POST_ROUTING))) != 0) {
+	    (hook_mask & ~((1 << NF_INET_FORWARD) |
+			   (1 << NF_INET_LOCAL_OUT) |
+			   (1 << NF_INET_POST_ROUTING))) != 0) {
 		printk("xt_TCPMSS: path-MTU clamping only supported in "
 		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
@@ -241,9 +241,9 @@ xt_tcpmss_checkentry6(const char *tablename,
 	const struct ip6t_entry *e = entry;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
-	    (hook_mask & ~((1 << NF_IP6_FORWARD) |
-			   (1 << NF_IP6_LOCAL_OUT) |
-			   (1 << NF_IP6_POST_ROUTING))) != 0) {
+	    (hook_mask & ~((1 << NF_INET_FORWARD) |
+			   (1 << NF_INET_LOCAL_OUT) |
+			   (1 << NF_INET_POST_ROUTING))) != 0) {
 		printk("xt_TCPMSS: path-MTU clamping only supported in "
 		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index 00490d7..6ff4479 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -50,9 +50,9 @@ static struct xt_match xt_mac_match[] __read_mostly = {
 		.family		= AF_INET,
 		.match		= match,
 		.matchsize	= sizeof(struct xt_mac_info),
-		.hooks		= (1 << NF_IP_PRE_ROUTING) |
-				  (1 << NF_IP_LOCAL_IN) |
-				  (1 << NF_IP_FORWARD),
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN) |
+				  (1 << NF_INET_FORWARD),
 		.me		= THIS_MODULE,
 	},
 	{
@@ -60,9 +60,9 @@ static struct xt_match xt_mac_match[] __read_mostly = {
 		.family		= AF_INET6,
 		.match		= match,
 		.matchsize	= sizeof(struct xt_mac_info),
-		.hooks		= (1 << NF_IP6_PRE_ROUTING) |
-				  (1 << NF_IP6_LOCAL_IN) |
-				  (1 << NF_IP6_FORWARD),
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN) |
+				  (1 << NF_INET_FORWARD),
 		.me		= THIS_MODULE,
 	},
 };
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index a4bab04..e91aee7 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -113,12 +113,12 @@ checkentry(const char *tablename,
 	if (info->bitmask & XT_PHYSDEV_OP_OUT &&
 	    (!(info->bitmask & XT_PHYSDEV_OP_BRIDGED) ||
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
-	    hook_mask & ((1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_FORWARD) |
-			 (1 << NF_IP_POST_ROUTING))) {
+	    hook_mask & ((1 << NF_INET_LOCAL_OUT) | (1 << NF_INET_FORWARD) |
+			 (1 << NF_INET_POST_ROUTING))) {
 		printk(KERN_WARNING "physdev match: using --physdev-out in the "
 		       "OUTPUT, FORWARD and POSTROUTING chains for non-bridged "
 		       "traffic is not supported anymore.\n");
-		if (hook_mask & (1 << NF_IP_LOCAL_OUT))
+		if (hook_mask & (1 << NF_INET_LOCAL_OUT))
 			return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 6d6d3b7..2eaa6fd 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -144,14 +144,13 @@ static bool checkentry(const char *tablename, const void *ip_void,
 				"outgoing policy selected\n");
 		return false;
 	}
-	/* hook values are equal for IPv4 and IPv6 */
-	if (hook_mask & (1 << NF_IP_PRE_ROUTING | 1 << NF_IP_LOCAL_IN)
+	if (hook_mask & (1 << NF_INET_PRE_ROUTING | 1 << NF_INET_LOCAL_IN)
 	    && info->flags & XT_POLICY_MATCH_OUT) {
 		printk(KERN_ERR "xt_policy: output policy not valid in "
 				"PRE_ROUTING and INPUT\n");
 		return false;
 	}
-	if (hook_mask & (1 << NF_IP_POST_ROUTING | 1 << NF_IP_LOCAL_OUT)
+	if (hook_mask & (1 << NF_INET_POST_ROUTING | 1 << NF_INET_LOCAL_OUT)
 	    && info->flags & XT_POLICY_MATCH_IN) {
 		printk(KERN_ERR "xt_policy: input policy not valid in "
 				"POST_ROUTING and OUTPUT\n");
diff --git a/net/netfilter/xt_realm.c b/net/netfilter/xt_realm.c
index cc3e76d..91113dc 100644
--- a/net/netfilter/xt_realm.c
+++ b/net/netfilter/xt_realm.c
@@ -41,8 +41,8 @@ static struct xt_match realm_match __read_mostly = {
 	.name		= "realm",
 	.match		= match,
 	.matchsize	= sizeof(struct xt_realm_info),
-	.hooks		= (1 << NF_IP_POST_ROUTING) | (1 << NF_IP_FORWARD) |
-			  (1 << NF_IP_LOCAL_OUT) | (1 << NF_IP_LOCAL_IN),
+	.hooks		= (1 << NF_INET_POST_ROUTING) | (1 << NF_INET_FORWARD) |
+			  (1 << NF_INET_LOCAL_OUT) | (1 << NF_INET_LOCAL_IN),
 	.family		= AF_INET,
 	.me		= THIS_MODULE
 };
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 3f8335e..d377dec 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -235,7 +235,7 @@ static struct nf_hook_ops ing_ops = {
 	.hook           = ing_hook,
 	.owner		= THIS_MODULE,
 	.pf             = PF_INET,
-	.hooknum        = NF_IP_PRE_ROUTING,
+	.hooknum        = NF_INET_PRE_ROUTING,
 	.priority       = NF_IP_PRI_FILTER + 1,
 };
 
@@ -243,7 +243,7 @@ static struct nf_hook_ops ing6_ops = {
 	.hook           = ing_hook,
 	.owner		= THIS_MODULE,
 	.pf             = PF_INET6,
-	.hooknum        = NF_IP6_PRE_ROUTING,
+	.hooknum        = NF_INET_PRE_ROUTING,
 	.priority       = NF_IP6_PRI_FILTER + 1,
 };
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 9f3124b..c3bb3e4 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5035,7 +5035,7 @@ static struct nf_hook_ops selinux_ipv4_op = {
 	.hook =		selinux_ipv4_postroute_last,
 	.owner =	THIS_MODULE,
 	.pf =		PF_INET,
-	.hooknum =	NF_IP_POST_ROUTING,
+	.hooknum =	NF_INET_POST_ROUTING,
 	.priority =	NF_IP_PRI_SELINUX_LAST,
 };
 
@@ -5045,7 +5045,7 @@ static struct nf_hook_ops selinux_ipv6_op = {
 	.hook =		selinux_ipv6_postroute_last,
 	.owner =	THIS_MODULE,
 	.pf =		PF_INET6,
-	.hooknum =	NF_IP6_POST_ROUTING,
+	.hooknum =	NF_INET_POST_ROUTING,
 	.priority =	NF_IP6_PRI_SELINUX_LAST,
 };
 

--------------050909030303070802030609--
