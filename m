From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Thu, 28 Jun 2012 03:59:46 -0700 (PDT)
Message-ID: <20120628.035946.1026666621448892198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2F1K7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 06:59:48 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 20DFE5845DC
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 03:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The specific destination is the host we direct unicast replies to.
Usually this is the original packet source address, but if we are
responding to a multicast or broadcast packet we have to use something
different.

Specifically we must use the source address we would use if we were to
send a packet to the unicast source of the original packet.

The routing cache precomputes this value, but we want to remove that
precomputation because it creates a hard dependency on the expensive
rpfilter source address validation which we'd like to make cheaper.

There are only three places where this matters:

1) ICMP replies.

2) pktinfo CMSG

3) IP options

Now there will be no real users of rt->rt_spec_dst and we can simply
remove it altogether.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h    |    1 +
 net/ipv4/fib_frontend.c |   29 +++++++++++++++++++++++++++++
 net/ipv4/icmp.c         |    6 ++++--
 net/ipv4/ip_options.c   |   22 +++++++++++-----------
 net/ipv4/ip_sockglue.c  |    7 ++++---
 5 files changed, 49 insertions(+), 16 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 4b347c0..1687b3d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -230,6 +230,7 @@ extern struct fib_table *fib_get_table(struct net *net, u32 id);
 /* Exported by fib_frontend.c */
 extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
+extern __be32 fib_compute_spec_dst(struct sk_buff *skb);
 extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       u8 tos, int oif, struct net_device *dev,
 			       __be32 *spec_dst, u32 *itag);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3854411..451939b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -180,6 +180,35 @@ unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
+__be32 fib_compute_spec_dst(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct in_device *in_dev;
+	struct fib_result res;
+	struct flowi4 fl4;
+	struct net *net;
+
+	if (skb->pkt_type != PACKET_BROADCAST &&
+	    skb->pkt_type != PACKET_MULTICAST)
+		return ip_hdr(skb)->daddr;
+
+	in_dev = __in_dev_get_rcu(dev);
+	BUG_ON(!in_dev);
+	fl4.flowi4_oif = 0;
+	fl4.flowi4_iif = 0;
+	fl4.daddr = ip_hdr(skb)->saddr;
+	fl4.saddr = ip_hdr(skb)->daddr;
+	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
+
+	net = dev_net(dev);
+	if (!fib_lookup(net, &fl4, &res))
+		return FIB_RES_PREFSRC(net, res);
+	else
+		return inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
+}
+
 /* Given (packet source, input interface) and optional (dst, oif, tos):
  * - (main) check, that source is valid i.e. not broadcast or our local
  *   address.
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 49a74cc..4bce5a2 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -95,6 +95,7 @@
 #include <net/checksum.h>
 #include <net/xfrm.h>
 #include <net/inet_common.h>
+#include <net/ip_fib.h>
 
 /*
  *	Build xmit assembly blocks
@@ -333,7 +334,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct flowi4 fl4;
 	struct sock *sk;
 	struct inet_sock *inet;
-	__be32 daddr;
+	__be32 daddr, saddr;
 
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
 		return;
@@ -347,6 +348,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = ip_hdr(skb)->saddr;
+	saddr = fib_compute_spec_dst(skb);
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 	if (icmp_param->replyopts.opt.opt.optlen) {
@@ -356,7 +358,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	}
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
-	fl4.saddr = rt->rt_spec_dst;
+	fl4.saddr = saddr;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 708b994..766dfe56 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -27,6 +27,7 @@
 #include <net/icmp.h>
 #include <net/route.h>
 #include <net/cipso_ipv4.h>
+#include <net/ip_fib.h>
 
 /*
  * Write options to IP header, record destination address to
@@ -104,7 +105,7 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 	sptr = skb_network_header(skb);
 	dptr = dopt->__data;
 
-	daddr = skb_rtable(skb)->rt_spec_dst;
+	daddr = fib_compute_spec_dst(skb);
 
 	if (sopt->rr) {
 		optlen  = sptr[sopt->rr+1];
@@ -250,15 +251,14 @@ void ip_options_fragment(struct sk_buff *skb)
 int ip_options_compile(struct net *net,
 		       struct ip_options *opt, struct sk_buff *skb)
 {
-	int l;
-	unsigned char *iph;
-	unsigned char *optptr;
-	int optlen;
+	__be32 spec_dst = (__force __be32) 0;
 	unsigned char *pp_ptr = NULL;
-	struct rtable *rt = NULL;
+	unsigned char *optptr;
+	unsigned char *iph;
+	int optlen, l;
 
 	if (skb != NULL) {
-		rt = skb_rtable(skb);
+		spec_dst = fib_compute_spec_dst(skb);
 		optptr = (unsigned char *)&(ip_hdr(skb)[1]);
 	} else
 		optptr = opt->__data;
@@ -330,8 +330,8 @@ int ip_options_compile(struct net *net,
 					pp_ptr = optptr + 2;
 					goto error;
 				}
-				if (rt) {
-					memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
+				if (skb) {
+					memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 					opt->is_changed = 1;
 				}
 				optptr[2] += 4;
@@ -372,8 +372,8 @@ int ip_options_compile(struct net *net,
 						goto error;
 					}
 					opt->ts = optptr - iph;
-					if (rt)  {
-						memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
+					if (skb)  {
+						memcpy(&optptr[optptr[2]-1], &spec_dst, 4);
 						timeptr = &optptr[optptr[2]+3];
 					}
 					opt->ts_needaddr = 1;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 0d11f23..de29f46 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -40,6 +40,7 @@
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/transp_v6.h>
 #endif
+#include <net/ip_fib.h>
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
@@ -1019,8 +1020,8 @@ e_inval:
  * @sk: socket
  * @skb: buffer
  *
- * To support IP_CMSG_PKTINFO option, we store rt_iif and rt_spec_dst
- * in skb->cb[] before dst drop.
+ * To support IP_CMSG_PKTINFO option, we store rt_iif and specific
+ * destination in skb->cb[] before dst drop.
  * This way, receiver doesnt make cache line misses to read rtable.
  */
 void ipv4_pktinfo_prepare(struct sk_buff *skb)
@@ -1030,7 +1031,7 @@ void ipv4_pktinfo_prepare(struct sk_buff *skb)
 
 	if (rt) {
 		pktinfo->ipi_ifindex = rt->rt_iif;
-		pktinfo->ipi_spec_dst.s_addr = rt->rt_spec_dst;
+		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
 		pktinfo->ipi_ifindex = 0;
 		pktinfo->ipi_spec_dst.s_addr = 0;
-- 
1.7.10.2
