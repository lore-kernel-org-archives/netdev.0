From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: clean-up ndisc printk's
Date: Tue, 10 Feb 2004 16:46:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210.164650.109511390.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: print KERN_xxx appropriately.
D: put net_ratelimit() inside the macro.
D: re-arrange levels.

===== net/ipv6/ndisc.c 1.71 vs edited =====
--- 1.71/net/ipv6/ndisc.c	Tue Feb 10 04:13:09 2004
+++ edited/net/ipv6/ndisc.c	Tue Feb 10 16:40:49 2004
@@ -28,11 +28,12 @@
 /* Set to 3 to get tracing... */
 #define ND_DEBUG 1
 
-#define ND_PRINTK(x...) printk(KERN_DEBUG x)
+#define ND_PRINTK(x...) do { if (net_ratelimit()) { printk(##x); } } while(0)
 #define ND_NOPRINTK(x...) do { ; } while(0)
 #define ND_PRINTK0 ND_PRINTK
 #define ND_PRINTK1 ND_NOPRINTK
 #define ND_PRINTK2 ND_NOPRINTK
+#define ND_PRINTK3 ND_NOPRINTK
 #if ND_DEBUG >= 1
 #undef ND_PRINTK1
 #define ND_PRINTK1 ND_PRINTK
@@ -41,6 +42,10 @@
 #undef ND_PRINTK2
 #define ND_PRINTK2 ND_PRINTK
 #endif
+#if ND_DEBUG >= 3
+#undef ND_PRINTK3
+#define ND_PRINTK3 ND_PRINTK
+#endif
 
 #include <linux/module.h>
 #include <linux/config.h>
@@ -210,8 +215,10 @@
 		case ND_OPT_MTU:
 		case ND_OPT_REDIRECT_HDR:
 			if (ndopts->nd_opt_array[nd_opt->nd_opt_type]) {
-				ND_PRINTK2("ndisc_parse_options(): duplicated ND6 option found: type=%d\n",
-					    nd_opt->nd_opt_type);
+				ND_PRINTK2(KERN_WARNING
+					   "%s(): duplicated ND6 option found: type=%d\n",
+					   __FUNCTION__,
+					   nd_opt->nd_opt_type);
 			} else {
 				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
 			}
@@ -226,8 +233,9 @@
 			 * Unknown options must be silently ignored,
 			 * to accommodate future extension to the protocol.
 			 */
-			ND_PRINTK2(KERN_WARNING
-				   "ndisc_parse_options(): ignored unsupported option; type=%d, len=%d\n",
+			ND_PRINTK2(KERN_NOTICE
+				   "%s(): ignored unsupported option; type=%d, len=%d\n",
+				   __FUNCTION__,
 				   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
 		}
 		opt_len -= l;
@@ -463,7 +471,9 @@
 				  1, &err);
 
 	if (skb == NULL) {
-		ND_PRINTK1("send_na: alloc skb failed\n");
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 NA: %s() failed to allocate an skb.\n", 
+			   __FUNCTION__);
 		dst_release(dst);
 		return;
 	}
@@ -548,7 +558,9 @@
 	skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
 	if (skb == NULL) {
-		ND_PRINTK1("send_ns: alloc skb failed\n");
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 NA: %s() failed to allocate an skb.\n", 
+			   __FUNCTION__);
 		dst_release(dst);
 		return;
 	}
@@ -620,7 +632,9 @@
         skb = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				  1, &err);
 	if (skb == NULL) {
-		ND_PRINTK1("send_ns: alloc skb failed\n");
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 RS: %s() failed to allocate an skb.\n", 
+			   __FUNCTION__);
 		dst_release(dst);
 		return;
 	}
@@ -683,8 +697,13 @@
 		saddr = &skb->nh.ipv6h->saddr;
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
-		if (!(neigh->nud_state&NUD_VALID))
-			ND_PRINTK1("trying to ucast probe in NUD_INVALID\n");
+		if (!(neigh->nud_state & NUD_VALID)) {
+			ND_PRINTK1(KERN_DEBUG
+				   "%s(): trying to ucast probe in NUD_INVALID: "
+				   "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
+				   __FUNCTION__,
+				   NIP6(*target));
+		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
 #ifdef CONFIG_ARPD
@@ -713,8 +732,8 @@
 	int inc;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP NS: target address is multicast\n");
+		ND_PRINTK2(KERN_WARNING 
+			   "ICMPv6 NS: multicast target address");
 		return;
 	}
 
@@ -727,14 +746,14 @@
 	      daddr->s6_addr32[1] == htonl(0x00000000) &&
 	      daddr->s6_addr32[2] == htonl(0x00000001) &&
 	      daddr->s6_addr [12] == 0xff )) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "ICMP6 NS: bad DAD packet (wrong destination)\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NS: bad DAD packet (wrong destination)\n");
 		return;
 	}
 
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP NS: invalid ND option, ignored.\n");
+		ND_PRINTK2(KERN_WARNING 
+			   "ICMPv6 NS: invalid ND options\n");
 		return;
 	}
 
@@ -742,8 +761,8 @@
 		lladdr = (u8*)(ndopts.nd_opts_src_lladdr + 1);
 		lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "ICMP NS: bad lladdr length.\n");
+			ND_PRINTK2(KERN_WARNING
+				   "ICMPv6 NS: invalid link-layer address length\n");
 			return;
 		}
 
@@ -753,8 +772,8 @@
 		 *	in the message.
 		 */
 		if (dad) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "ICMP6 NS: bad DAD packet (link-layer address option)\n");
+			ND_PRINTK2(KERN_WARNING 
+				   "ICMPv6 NS: bad DAD packet (link-layer address option)\n");
 			return;
 		}
 	}
@@ -868,34 +887,35 @@
 	struct neighbour *neigh;
 
 	if (skb->len < sizeof(struct nd_msg)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP NA: packet too short\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NA: packet too short\n");
 		return;
 	}
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "NDISC NA: target address is multicast\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NA: target address is multicast.\n");
 		return;
 	}
 
 	if (ipv6_addr_is_multicast(daddr) &&
 	    msg->icmph.icmp6_solicited) {
-		ND_PRINTK0("NDISC: solicited NA is multicasted\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NA: solicited NA is multicasted.\n");
 		return;
 	}
 		
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP NS: invalid ND option, ignored.\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NS: invalid ND option\n");
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
 		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(dev->addr_len)) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "NDISC NA: invalid lladdr length.\n");
+			ND_PRINTK2(KERN_WARNING
+				   "ICMPv6 NA: invalid link-layer address length\n");
 			return;
 		}
 	}
@@ -909,7 +929,8 @@
 		   about it. It could be misconfiguration, or
 		   an smart proxy agent tries to help us :-)
 		 */
-		ND_PRINTK0("%s: someone advertises our address!\n",
+		ND_PRINTK1(KERN_WARNING
+			   "ICMPv6 NA: someone advertises our address on %s!\n",
 			   ifp->idev->dev->name);
 		in6_ifa_put(ifp);
 		return;
@@ -954,13 +975,13 @@
 	optlen = (skb->tail - skb->h.raw) - sizeof(struct ra_msg);
 
 	if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP RA: source address is not linklocal\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 RA: source address is not link-local.\n");
 		return;
 	}
 	if (optlen < 0) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP RA: packet too short\n");
+		ND_PRINTK2(KERN_WARNING 
+			   "ICMPv6 RA: packet too short\n");
 		return;
 	}
 
@@ -970,7 +991,9 @@
 
 	in6_dev = in6_dev_get(skb->dev);
 	if (in6_dev == NULL) {
-		ND_PRINTK1("RA: can't find in6 device\n");
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 RA: can't find inet6 device for %s.\n",
+			   skb->dev->name);
 		return;
 	}
 	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_ra) {
@@ -980,9 +1003,8 @@
 
 	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
 		in6_dev_put(in6_dev);
-		if (net_ratelimit())
-			ND_PRINTK2(KERN_WARNING
-				   "ICMP6 RA: invalid ND option, ignored.\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMP6 RA: invalid ND options\n");
 		return;
 	}
 
@@ -1015,18 +1037,23 @@
 	}
 
 	if (rt == NULL && lifetime) {
-		ND_PRINTK2("ndisc_rdisc: adding default router\n");
+		ND_PRINTK3(KERN_DEBUG
+			   "ICMPv6 RA: adding default router.\n");
 
 		rt = rt6_add_dflt_router(&skb->nh.ipv6h->saddr, skb->dev);
 		if (rt == NULL) {
-			ND_PRINTK1("route_add failed\n");
+			ND_PRINTK0(KERN_ERR
+				   "ICMPv6 RA: %s() failed to add default route.\n",
+				   __FUNCTION__);
 			in6_dev_put(in6_dev);
 			return;
 		}
 
 		neigh = rt->rt6i_nexthop;
 		if (neigh == NULL) {
-			ND_PRINTK1("nd: add default router: null neighbour\n");
+			ND_PRINTK0(KERN_ERR
+				   "ICMPv6 RA: %s() got default router without neighbour.\n",
+				   __FUNCTION__);
 			dst_release(&rt->u.dst);
 			in6_dev_put(in6_dev);
 			return;
@@ -1091,9 +1118,8 @@
 			lladdr = (u8*)((ndopts.nd_opts_src_lladdr)+1);
 			lladdrlen = ndopts.nd_opts_src_lladdr->nd_opt_len << 3;
 			if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
-				if (net_ratelimit())
-					ND_PRINTK2(KERN_WARNING
-						   "ICMP6 RA: Invalid lladdr length.\n");
+				ND_PRINTK2(KERN_WARNING
+					   "ICMPv6 RA: invalid link-layer address length\n");
 				goto out;
 			}
 		}
@@ -1116,10 +1142,9 @@
 		mtu = ntohl(mtu);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
-			if (net_ratelimit()) {
-				ND_PRINTK0("NDISC: router announcement with mtu = %d\n",
-					   mtu);
-			}
+			ND_PRINTK2(KERN_WARNING
+				   "ICMPv6 RA: invalid mtu: %d\n",
+				   mtu);
 		} else if (in6_dev->cnf.mtu6 != mtu) {
 			in6_dev->cnf.mtu6 = mtu;
 
@@ -1131,9 +1156,8 @@
 	}
 			
 	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
-		if (net_ratelimit())
-			ND_PRINTK0(KERN_WARNING
-				   "ICMP6 RA: got invalid option with RA");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 RA: invalid RA options");
 	}
 out:
 	if (rt)
@@ -1155,8 +1179,8 @@
 	int lladdrlen;
 
 	if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP redirect: source address is not linklocal\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: source address is not link-local.\n");
 		return;
 	}
 
@@ -1164,8 +1188,8 @@
 	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 
 	if (optlen < 0) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP redirect: packet too small\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: packet too short\n");
 		return;
 	}
 
@@ -1174,16 +1198,16 @@
 	dest = target + 1;
 
 	if (ipv6_addr_is_multicast(dest)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP redirect for multicast addr\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: destination address is multicast.\n");
 		return;
 	}
 
 	if (ipv6_addr_cmp(dest, target) == 0) {
 		on_link = 1;
 	} else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP redirect: target address is not linklocal\n");
+		ND_PRINTK2(KERN_WARNING 
+			   "ICMPv6 Redirect: target address is not link-local.\n");
 		return;
 	}
 
@@ -1201,9 +1225,8 @@
 	 */
 		
 	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
-		if (net_ratelimit())
-			ND_PRINTK2(KERN_WARNING
-				   "ICMP6 Redirect: invalid ND options, rejected.\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: invalid ND options\n");
 		in6_dev_put(in6_dev);
 		return;
 	}
@@ -1211,9 +1234,8 @@
 		lladdr = (u8*)(ndopts.nd_opts_tgt_lladdr + 1);
 		lladdrlen = ndopts.nd_opts_tgt_lladdr->nd_opt_len << 3;
 		if (lladdrlen != NDISC_OPT_SPACE(skb->dev->addr_len)) {
-			if (net_ratelimit())
-				ND_PRINTK2(KERN_WARNING
-					   "ICMP6 Redirect: invalid lladdr length.\n");
+			ND_PRINTK2(KERN_WARNING
+				   "ICMPv6 Redirect: invalid link-layer address length\n");
 			in6_dev_put(in6_dev);
 			return;
 		}
@@ -1258,7 +1280,9 @@
 	dev = skb->dev;
 
 	if (ipv6_get_lladdr(dev, &saddr_buf)) {
- 		ND_PRINTK1("redirect: no link_local addr for dev\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: no link-local address on %s\n",
+			   dev->name);
  		return;
  	}
 
@@ -1278,7 +1302,8 @@
 	rt = (struct rt6_info *) dst;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
-		ND_PRINTK1("ndisc_send_redirect: not a neighbour\n");
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: destination is not a neighbour.\n");
 		dst_release(dst);
 		return;
 	}
@@ -1308,7 +1333,9 @@
 	buff = sock_alloc_send_skb(sk, MAX_HEADER + len + LL_RESERVED_SPACE(dev),
 				   1, &err);
 	if (buff == NULL) {
-		ND_PRINTK1("ndisc_send_redirect: alloc_skb failed\n");
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 Redirect: %s() failed to allocate an skb.\n",
+			   __FUNCTION__);
 		dst_release(dst);
 		return;
 	}
@@ -1388,16 +1415,16 @@
 	__skb_push(skb, skb->data-skb->h.raw);
 
 	if (skb->nh.ipv6h->hop_limit != 255) {
-		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "ICMP NDISC: fake message with non-255 Hop Limit received: %d\n",
-			       		skb->nh.ipv6h->hop_limit);
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 NDISC: invalid hop-limit: %d\n",
+			   skb->nh.ipv6h->hop_limit);
 		return 0;
 	}
 
 	if (msg->icmph.icmp6_code != 0) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "ICMP NDISC: code is not zero\n");
+		ND_PRINTK2(KERN_WARNING 
+			   "ICMPv6 NDISC: invalid ICMPv6 code: %d\n",
+			   msg->icmph.icmp6_code);
 		return 0;
 	}
 
@@ -1465,9 +1492,9 @@
 
 	err = sock_create(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &ndisc_socket);
 	if (err < 0) {
-		printk(KERN_ERR
-		       "Failed to initialize the NDISC control socket (err %d).\n",
-		       err);
+		ND_PRINTK0(KERN_ERR
+			   "ICMPv6 NDISC: Failed to initialize the control socket (err %d).\n", 
+			   err);
 		ndisc_socket = NULL; /* For safety. */
 		return err;
 	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
