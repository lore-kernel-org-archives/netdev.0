From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 3/6]: IPsec output hooks
Date: Mon, 17 Oct 2005 02:22:24 +0200
Message-ID: <4352EEC0.9050507@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="03.diff"
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: IPsec output hooks

Packets visit the FORWARD/LOCAL_OUT->POST_ROUTING hooks in plain text
and LOCAL_OUT->POST_ROUTING once for each tunnel mode transform.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 92dffb4b8138637d28173cc9c10fe5990914cf5d
tree 7d9e5fe149ab4bbee3afd2eafb1848ef2f978056
parent b8225d3928324d81a16b7d82c6c413005ac52c50
author Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 00:40:48 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 00:40:48 +0200

 include/net/dst.h                |    9 +++++++++
 include/net/ipip.h               |    2 +-
 net/ipv4/igmp.c                  |    4 ++--
 net/ipv4/ip_forward.c            |    2 +-
 net/ipv4/ip_output.c             |    6 +++---
 net/ipv4/ipmr.c                  |    2 +-
 net/ipv4/ipvs/ip_vs_xmit.c       |    2 +-
 net/ipv4/netfilter.c             |   32 +++++++++++++++++++++++++++++++-
 net/ipv4/netfilter/ipt_REJECT.c  |    2 +-
 net/ipv4/raw.c                   |    2 +-
 net/ipv4/xfrm4_output.c          |    1 +
 net/ipv6/ip6_input.c             |    4 ++--
 net/ipv6/ip6_output.c            |    7 ++++---
 net/ipv6/ip6_tunnel.c            |    2 +-
 net/ipv6/ndisc.c                 |    8 ++++----
 net/ipv6/netfilter.c             |   29 +++++++++++++++++++++++++++++
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/raw.c                   |    2 +-
 net/ipv6/xfrm6_output.c          |    1 +
 19 files changed, 95 insertions(+), 24 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -237,6 +237,15 @@ static inline int dst_output(struct sk_b
 	}
 }
 
+#if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
+extern int __ip_dst_output(struct sk_buff *skb);
+extern int ip_dst_output(struct sk_buff *skb);
+extern int ip6_dst_output(struct sk_buff *skb);
+#else
+#define ip_dst_output dst_output
+#define ip6_dst_output dst_output
+#endif
+
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
 {
diff --git a/include/net/ipip.h b/include/net/ipip.h
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -34,7 +34,7 @@ struct ip_tunnel
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
 	ip_send_check(iph);						\
 									\
-	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, dst_output);\
+	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev, ip_dst_output);\
 	if (err == NET_XMIT_SUCCESS || err == NET_XMIT_CN) {		\
 		stats->tx_bytes += pkt_len;				\
 		stats->tx_packets++;					\
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -343,7 +343,7 @@ static int igmpv3_sendpack(struct sk_buf
 	pig->csum = ip_compute_csum((void *)skb->h.igmph, igmplen);
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
@@ -674,7 +674,7 @@ static int igmp_send_report(struct in_de
 	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 static void igmp_gq_timer_expire(unsigned long data)
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -51,7 +51,7 @@ static inline int ip_forward_finish(stru
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 int ip_forward(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -155,7 +155,7 @@ int ip_build_and_send_pkt(struct sk_buff
 
 	/* Send it out. */
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 }
 
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
@@ -371,7 +371,7 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 
 	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		       dst_output);
+		       ip_dst_output);
 
 no_route:
 	IP_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
@@ -1190,7 +1190,7 @@ int ip_push_pending_frames(struct sock *
 
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip_dst_output);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1125,7 +1125,7 @@ static inline int ipmr_forward_finish(st
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return ip_dst_output(skb);
 }
 
 /*
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -130,7 +130,7 @@ do {							\
 	(skb)->ipvs_property = 1;			\
 	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
-		(rt)->u.dst.dev, dst_output);		\
+		(rt)->u.dst.dev, ip_dst_output);	\
 } while (0)
 
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -10,8 +10,9 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
-#include <net/route.h>
 #include <linux/ip.h>
+#include <net/route.h>
+#include <net/xfrm.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -78,6 +79,35 @@ int ip_route_me_harder(struct sk_buff **
 }
 EXPORT_SYMBOL(ip_route_me_harder);
 
+#ifdef CONFIG_XFRM
+inline int __ip_dst_output(struct sk_buff *skb)
+{
+	int err;
+
+	do {
+		err = skb->dst->output(skb);
+
+		if (likely(err == 0))
+			return err;
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	} while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	               ip_dst_output);
+}
+EXPORT_SYMBOL(__ip_dst_output);
+
+int ip_dst_output(struct sk_buff *skb)
+{
+	if (skb->dst->xfrm != NULL)
+		return NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
+		               skb->dst->dev, __ip_dst_output);
+	return dst_output(skb);
+}
+EXPORT_SYMBOL(ip_dst_output);
+#endif /* CONFIG_XFRM */
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -220,7 +220,7 @@ static void send_reset(struct sk_buff *o
 	nf_ct_attach(nskb, oldskb);
 
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+		ip_dst_output);
 	return;
 
  free_nskb:
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -313,7 +313,7 @@ static int raw_send_hdrinc(struct sock *
 	}
 
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+		      ip_dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -133,6 +133,7 @@ int xfrm4_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
 out_exit:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -250,9 +250,9 @@ int ip6_mc_input(struct sk_buff *skb)
 			
 			if (deliver) {
 				skb2 = skb_clone(skb, GFP_ATOMIC);
-				dst_output(skb2);
+				ip_dst_output(skb2);
 			} else {
-				dst_output(skb);
+				ip_dst_output(skb);
 				return 0;
 			}
 		}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -229,7 +229,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	if ((skb->len <= mtu) || ipfragok) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
-				dst_output);
+				ip6_dst_output);
 	}
 
 	if (net_ratelimit())
@@ -307,7 +307,7 @@ static int ip6_call_ra_chain(struct sk_b
 
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
-	return dst_output(skb);
+	return ip6_dst_output(skb);
 }
 
 int ip6_forward(struct sk_buff *skb)
@@ -1107,7 +1107,8 @@ int ip6_push_pending_frames(struct sock 
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	              ip6_dst_output);
 	if (err) {
 		if (err > 0)
 			err = np->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -745,7 +745,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, 
-		      skb->dst->dev, dst_output);
+		      skb->dst->dev, ip6_dst_output);
 
 	if (err == NET_XMIT_SUCCESS || err == NET_XMIT_CN) {
 		stats->tx_bytes += pkt_len;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -499,7 +499,7 @@ static void ndisc_send_na(struct net_dev
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -582,7 +582,7 @@ void ndisc_send_ns(struct net_device *de
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -654,7 +654,7 @@ void ndisc_send_rs(struct net_device *de
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);	
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTROUTERSOLICITS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
@@ -1438,7 +1438,7 @@ void ndisc_send_redirect(struct sk_buff 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
+	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, ip6_dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTREDIRECTS);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -10,6 +10,7 @@
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/xfrm.h>
 
 int ip6_route_me_harder(struct sk_buff *skb)
 {
@@ -41,6 +42,34 @@ int ip6_route_me_harder(struct sk_buff *
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
 
+#ifdef CONFIG_XFRM
+static inline int __ip6_dst_output(struct sk_buff *skb)
+{
+	int err;
+	
+	do {
+		err = skb->dst->output(skb);
+
+		if (likely(err == 0))
+			return err;
+		if (unlikely(err != NET_XMIT_BYPASS))
+			return err;
+	} while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
+
+	return NF_HOOK(PF_INET, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev,
+	               ip6_dst_output);
+}
+
+int ip6_dst_output(struct sk_buff *skb)
+{
+	if (skb->dst->xfrm != NULL)
+		return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
+		               skb->dst->dev, __ip6_dst_output);
+	return dst_output(skb);
+}
+EXPORT_SYMBOL(ip6_dst_output);
+#endif /* CONFIG_XFRM */
+
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -161,7 +161,7 @@ static void send_reset(struct sk_buff *o
 						   sizeof(struct tcphdr), 0));
 
 	NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+		ip6_dst_output);
 }
 
 static inline void
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -579,7 +579,7 @@ static int rawv6_send_hdrinc(struct sock
 
 	IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);		
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+		      ip6_dst_output);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	if (err)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -132,6 +132,7 @@ int xfrm6_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
 out_exit:
