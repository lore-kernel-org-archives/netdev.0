From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: ipv6: ndisc: Neaten ND_PRINTx macros
Date: Wed, 16 May 2012 22:28:38 -0700
Message-ID: <1337232518.17726.21.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43209 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753753Ab2EQF2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 01:28:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why use several macros when one will do?

Convert the multiple ND_PRINTKx macros to a single
ND_PRINTK macro.  Use the new net_<level>_ratelimited
mechanism too.

Add pr_fmt with "ICMPv6: " as prefix.
Remove embedded ICMPv6 prefixes from messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/ndisc.c |  216 +++++++++++++++++++++++-------------------------------
 1 files changed, 91 insertions(+), 125 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index cbb863d..c7a27ac 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -27,27 +27,7 @@
  *	YOSHIFUJI Hideaki @USAGI	:	Verify ND options properly
  */
 
-/* Set to 3 to get tracing... */
-#define ND_DEBUG 1
-
-#define ND_PRINTK(fmt, args...) do { if (net_ratelimit()) { printk(fmt, ## args); } } while(0)
-#define ND_NOPRINTK(x...) do { ; } while(0)
-#define ND_PRINTK0 ND_PRINTK
-#define ND_PRINTK1 ND_NOPRINTK
-#define ND_PRINTK2 ND_NOPRINTK
-#define ND_PRINTK3 ND_NOPRINTK
-#if ND_DEBUG >= 1
-#undef ND_PRINTK1
-#define ND_PRINTK1 ND_PRINTK
-#endif
-#if ND_DEBUG >= 2
-#undef ND_PRINTK2
-#define ND_PRINTK2 ND_PRINTK
-#endif
-#if ND_DEBUG >= 3
-#undef ND_PRINTK3
-#define ND_PRINTK3 ND_PRINTK
-#endif
+#define pr_fmt(fmt) "ICMPv6: " fmt
 
 #include <linux/module.h>
 #include <linux/errno.h>
@@ -92,6 +72,15 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
+/* Set to 3 to get tracing... */
+#define ND_DEBUG 1
+
+#define ND_PRINTK(val, level, fmt, ...)				\
+do {								\
+	if (val <= ND_DEBUG)					\
+		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
+} while (0)
+
 static u32 ndisc_hash(const void *pkey,
 		      const struct net_device *dev,
 		      __u32 *hash_rnd);
@@ -265,10 +254,9 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 		case ND_OPT_MTU:
 		case ND_OPT_REDIRECT_HDR:
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
-				ND_PRINTK2(KERN_WARNING
-					   "%s: duplicated ND6 option found: type=%d\n",
-					   __func__,
-					   nd_opt->nd_opt_type);
+				ND_PRINTK(2, warn,
+					  "%s: duplicated ND6 option found: type=%d\n",
+					  __func__, nd_opt->nd_opt_type);
 			} else {
 				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
 			}
@@ -296,10 +284,11 @@ static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 				 * to accommodate future extension to the
 				 * protocol.
 				 */
-				ND_PRINTK2(KERN_NOTICE
-					   "%s: ignored unsupported option; type=%d, len=%d\n",
-					   __func__,
-					   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
+				ND_PRINTK(2, notice,
+					  "%s: ignored unsupported option; type=%d, len=%d\n",
+					  __func__,
+					  nd_opt->nd_opt_type,
+					  nd_opt->nd_opt_len);
 			}
 		}
 		opt_len -= l;
@@ -455,9 +444,8 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				   len + hlen + tlen),
 				  1, &err);
 	if (!skb) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 ND: %s failed to allocate an skb, err=%d.\n",
-			   __func__, err);
+		ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
+			  __func__, err);
 		return NULL;
 	}
 
@@ -693,8 +681,9 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
-			ND_PRINTK1(KERN_DEBUG "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
-				   __func__, target);
+			ND_PRINTK(1, dbg,
+				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
+				  __func__, target);
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
@@ -740,8 +729,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	int is_router = -1;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NS: multicast target address");
+		ND_PRINTK(2, warn, "NS: multicast target address\n");
 		return;
 	}
 
@@ -754,22 +742,20 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	      daddr->s6_addr32[1] == htonl(0x00000000) &&
 	      daddr->s6_addr32[2] == htonl(0x00000001) &&
 	      daddr->s6_addr [12] == 0xff )) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NS: bad DAD packet (wrong destination)\n");
+		ND_PRINTK(2, warn, "NS: bad DAD packet (wrong destination)\n");
 		return;
 	}
 
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NS: invalid ND options\n");
+		ND_PRINTK(2, warn, "NS: invalid ND options\n");
 		return;
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev);
 		if (!lladdr) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 NS: invalid link-layer address length\n");
+			ND_PRINTK(2, warn,
+				  "NS: invalid link-layer address length\n");
 			return;
 		}
 
@@ -779,8 +765,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		 *	in the message.
 		 */
 		if (dad) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 NS: bad DAD packet (link-layer address option)\n");
+			ND_PRINTK(2, warn,
+				  "NS: bad DAD packet (link-layer address option)\n");
 			return;
 		}
 	}
@@ -898,34 +884,30 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	struct neighbour *neigh;
 
 	if (skb->len < sizeof(struct nd_msg)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NA: packet too short\n");
+		ND_PRINTK(2, warn, "NA: packet too short\n");
 		return;
 	}
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NA: target address is multicast.\n");
+		ND_PRINTK(2, warn, "NA: target address is multicast\n");
 		return;
 	}
 
 	if (ipv6_addr_is_multicast(daddr) &&
 	    msg->icmph.icmp6_solicited) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NA: solicited NA is multicasted.\n");
+		ND_PRINTK(2, warn, "NA: solicited NA is multicasted\n");
 		return;
 	}
 
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NS: invalid ND option\n");
+		ND_PRINTK(2, warn, "NS: invalid ND option\n");
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev);
 		if (!lladdr) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 NA: invalid link-layer address length\n");
+			ND_PRINTK(2, warn,
+				  "NA: invalid link-layer address length\n");
 			return;
 		}
 	}
@@ -946,9 +928,9 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		   unsolicited advertisement.
 		 */
 		if (skb->pkt_type != PACKET_LOOPBACK)
-			ND_PRINTK1(KERN_WARNING
-			   "ICMPv6 NA: someone advertises our address %pI6 on %s!\n",
-			   &ifp->addr, ifp->idev->dev->name);
+			ND_PRINTK(1, warn,
+				  "NA: someone advertises our address %pI6 on %s!\n",
+				  &ifp->addr, ifp->idev->dev->name);
 		in6_ifa_put(ifp);
 		return;
 	}
@@ -1010,8 +992,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 
 	idev = __in6_dev_get(skb->dev);
 	if (!idev) {
-		if (net_ratelimit())
-			ND_PRINTK1("ICMP6 RS: can't find in6 device\n");
+		ND_PRINTK(1, err, "RS: can't find in6 device\n");
 		return;
 	}
 
@@ -1028,8 +1009,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 
 	/* Parse ND options */
 	if (!ndisc_parse_options(rs_msg->opt, ndoptlen, &ndopts)) {
-		if (net_ratelimit())
-			ND_PRINTK2("ICMP6 NS: invalid ND option, ignored\n");
+		ND_PRINTK(2, notice, "NS: invalid ND option, ignored\n");
 		goto out;
 	}
 
@@ -1127,20 +1107,17 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	optlen = (skb->tail - skb->transport_header) - sizeof(struct ra_msg);
 
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 RA: source address is not link-local.\n");
+		ND_PRINTK(2, warn, "RA: source address is not link-local\n");
 		return;
 	}
 	if (optlen < 0) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 RA: packet too short\n");
+		ND_PRINTK(2, warn, "RA: packet too short\n");
 		return;
 	}
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	if (skb->ndisc_nodetype == NDISC_NODETYPE_HOST) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 RA: from host or unauthorized router\n");
+		ND_PRINTK(2, warn, "RA: from host or unauthorized router\n");
 		return;
 	}
 #endif
@@ -1151,15 +1128,13 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	in6_dev = __in6_dev_get(skb->dev);
 	if (in6_dev == NULL) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 RA: can't find inet6 device for %s.\n",
-			   skb->dev->name);
+		ND_PRINTK(0, err, "RA: can't find inet6 device for %s\n",
+			  skb->dev->name);
 		return;
 	}
 
 	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMP6 RA: invalid ND options\n");
+		ND_PRINTK(2, warn, "RA: invalid ND options\n");
 		return;
 	}
 
@@ -1212,9 +1187,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (rt) {
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
 		if (!neigh) {
-			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s got default router without neighbour.\n",
-				   __func__);
+			ND_PRINTK(0, err,
+				  "RA: %s got default router without neighbour\n",
+				  __func__);
 			dst_release(&rt->dst);
 			return;
 		}
@@ -1225,22 +1200,21 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	}
 
 	if (rt == NULL && lifetime) {
-		ND_PRINTK3(KERN_DEBUG
-			   "ICMPv6 RA: adding default router.\n");
+		ND_PRINTK(3, dbg, "RA: adding default router\n");
 
 		rt = rt6_add_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev, pref);
 		if (rt == NULL) {
-			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s failed to add default route.\n",
-				   __func__);
+			ND_PRINTK(0, err,
+				  "RA: %s failed to add default route\n",
+				  __func__);
 			return;
 		}
 
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
 		if (neigh == NULL) {
-			ND_PRINTK0(KERN_ERR
-				   "ICMPv6 RA: %s got default router without neighbour.\n",
-				   __func__);
+			ND_PRINTK(0, err,
+				  "RA: %s got default router without neighbour\n",
+				  __func__);
 			dst_release(&rt->dst);
 			return;
 		}
@@ -1308,8 +1282,8 @@ skip_linkparms:
 			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
 						     skb->dev);
 			if (!lladdr) {
-				ND_PRINTK2(KERN_WARNING
-					   "ICMPv6 RA: invalid link-layer address length\n");
+				ND_PRINTK(2, warn,
+					  "RA: invalid link-layer address length\n");
 				goto out;
 			}
 		}
@@ -1373,9 +1347,7 @@ skip_routeinfo:
 		mtu = ntohl(n);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 RA: invalid mtu: %d\n",
-				   mtu);
+			ND_PRINTK(2, warn, "RA: invalid mtu: %d\n", mtu);
 		} else if (in6_dev->cnf.mtu6 != mtu) {
 			in6_dev->cnf.mtu6 = mtu;
 
@@ -1396,8 +1368,7 @@ skip_routeinfo:
 	}
 
 	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 RA: invalid RA options");
+		ND_PRINTK(2, warn, "RA: invalid RA options\n");
 	}
 out:
 	if (rt)
@@ -1422,15 +1393,15 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	switch (skb->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
 	case NDISC_NODETYPE_NODEFAULT:
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: from host or unauthorized router\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: from host or unauthorized router\n");
 		return;
 	}
 #endif
 
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: source address is not link-local.\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: source address is not link-local\n");
 		return;
 	}
 
@@ -1438,8 +1409,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 
 	if (optlen < 0) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: packet too short\n");
+		ND_PRINTK(2, warn, "Redirect: packet too short\n");
 		return;
 	}
 
@@ -1448,8 +1418,8 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	dest = target + 1;
 
 	if (ipv6_addr_is_multicast(dest)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: destination address is multicast.\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: destination address is multicast\n");
 		return;
 	}
 
@@ -1457,8 +1427,8 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		on_link = 1;
 	} else if (ipv6_addr_type(target) !=
 		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: target address is not link-local unicast.\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: target address is not link-local unicast\n");
 		return;
 	}
 
@@ -1474,16 +1444,15 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	 */
 
 	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: invalid ND options\n");
+		ND_PRINTK(2, warn, "Redirect: invalid ND options\n");
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
 					     skb->dev);
 		if (!lladdr) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 Redirect: invalid link-layer address length\n");
+			ND_PRINTK(2, warn,
+				  "Redirect: invalid link-layer address length\n");
 			return;
 		}
 	}
@@ -1518,16 +1487,15 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: no link-local address on %s\n",
-			   dev->name);
+		ND_PRINTK(2, warn, "Redirect: no link-local address on %s\n",
+			  dev->name);
 		return;
 	}
 
 	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
 	    ipv6_addr_type(target) != (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
-		ND_PRINTK2(KERN_WARNING
-			"ICMPv6 Redirect: target address is not link-local unicast.\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: target address is not link-local unicast\n");
 		return;
 	}
 
@@ -1546,8 +1514,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	rt = (struct rt6_info *) dst;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: destination is not a neighbour.\n");
+		ND_PRINTK(2, warn,
+			  "Redirect: destination is not a neighbour\n");
 		goto release;
 	}
 	if (!rt->rt6i_peer)
@@ -1558,8 +1526,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (dev->addr_len) {
 		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
 		if (!neigh) {
-			ND_PRINTK2(KERN_WARNING
-				   "ICMPv6 Redirect: no neigh for target address\n");
+			ND_PRINTK(2, warn,
+				  "Redirect: no neigh for target address\n");
 			goto release;
 		}
 
@@ -1587,9 +1555,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 				    len + hlen + tlen),
 				   1, &err);
 	if (buff == NULL) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 Redirect: %s failed to allocate an skb, err=%d.\n",
-			   __func__, err);
+		ND_PRINTK(0, err,
+			  "Redirect: %s failed to allocate an skb, err=%d\n",
+			  __func__, err);
 		goto release;
 	}
 
@@ -1674,16 +1642,14 @@ int ndisc_rcv(struct sk_buff *skb)
 	__skb_push(skb, skb->data - skb_transport_header(skb));
 
 	if (ipv6_hdr(skb)->hop_limit != 255) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NDISC: invalid hop-limit: %d\n",
-			   ipv6_hdr(skb)->hop_limit);
+		ND_PRINTK(2, warn, "NDISC: invalid hop-limit: %d\n",
+			  ipv6_hdr(skb)->hop_limit);
 		return 0;
 	}
 
 	if (msg->icmph.icmp6_code != 0) {
-		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 NDISC: invalid ICMPv6 code: %d\n",
-			   msg->icmph.icmp6_code);
+		ND_PRINTK(2, warn, "NDISC: invalid ICMPv6 code: %d\n",
+			  msg->icmph.icmp6_code);
 		return 0;
 	}
 
@@ -1804,9 +1770,9 @@ static int __net_init ndisc_net_init(struct net *net)
 	err = inet_ctl_sock_create(&sk, PF_INET6,
 				   SOCK_RAW, IPPROTO_ICMPV6, net);
 	if (err < 0) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 NDISC: Failed to initialize the control socket (err %d).\n",
-			   err);
+		ND_PRINTK(0, err,
+			  "NDISC: Failed to initialize the control socket (err %d)\n",
+			  err);
 		return err;
 	}
 
