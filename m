From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: some RCU conversions
Date: Thu, 28 Jul 2011 09:13:03 +0200
Message-ID: <1311837183.2697.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56200 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab1G1HNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:13:09 -0400
Received: by wwe5 with SMTP id 5so2162623wwe.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 00:13:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP and ND are not fast path, but still we can avoid changing idev
refcount, using RCU.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/icmp.c  |   25 ++++++++++---------------
 net/ipv6/ndisc.c |   31 +++++++++++--------------------
 2 files changed, 21 insertions(+), 35 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1190041..2b59154 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -490,7 +490,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 		goto out_dst_release;
 	}
 
-	idev = in6_dev_get(skb->dev);
+	rcu_read_lock();
+	idev = __in6_dev_get(skb->dev);
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
 			      len + sizeof(struct icmp6hdr),
@@ -500,19 +501,16 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
-		goto out_put;
+	} else {
+		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
+						 len + sizeof(struct icmp6hdr));
 	}
-	err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr, len + sizeof(struct icmp6hdr));
-
-out_put:
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	rcu_read_unlock();
 out_dst_release:
 	dst_release(dst);
 out:
 	icmpv6_xmit_unlock(sk);
 }
-
 EXPORT_SYMBOL(icmpv6_send);
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
@@ -569,7 +567,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	idev = in6_dev_get(skb->dev);
+	idev = __in6_dev_get(skb->dev);
 
 	msg.skb = skb;
 	msg.offset = 0;
@@ -583,13 +581,10 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
-		goto out_put;
+	} else {
+		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
+						 skb->len + sizeof(struct icmp6hdr));
 	}
-	err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr, skb->len + sizeof(struct icmp6hdr));
-
-out_put:
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
 	dst_release(dst);
 out:
 	icmpv6_xmit_unlock(sk);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9da6e02..1f52dd2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -533,7 +533,8 @@ void ndisc_send_skb(struct sk_buff *skb,
 
 	skb_dst_set(skb, dst);
 
-	idev = in6_dev_get(dst->dev);
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
@@ -543,8 +544,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	rcu_read_unlock();
 }
 
 EXPORT_SYMBOL(ndisc_send_skb);
@@ -1039,7 +1039,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 	if (skb->len < sizeof(*rs_msg))
 		return;
 
-	idev = in6_dev_get(skb->dev);
+	idev = __in6_dev_get(skb->dev);
 	if (!idev) {
 		if (net_ratelimit())
 			ND_PRINTK1("ICMP6 RS: can't find in6 device\n");
@@ -1080,7 +1080,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 		neigh_release(neigh);
 	}
 out:
-	in6_dev_put(idev);
+	return;
 }
 
 static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
@@ -1179,7 +1179,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	 *	set the RA_RECV flag in the interface
 	 */
 
-	in6_dev = in6_dev_get(skb->dev);
+	in6_dev = __in6_dev_get(skb->dev);
 	if (in6_dev == NULL) {
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 RA: can't find inet6 device for %s.\n",
@@ -1188,7 +1188,6 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	}
 
 	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
-		in6_dev_put(in6_dev);
 		ND_PRINTK2(KERN_WARNING
 			   "ICMP6 RA: invalid ND options\n");
 		return;
@@ -1255,7 +1254,6 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() failed to add default route.\n",
 				   __func__);
-			in6_dev_put(in6_dev);
 			return;
 		}
 
@@ -1265,7 +1263,6 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
 				   __func__);
 			dst_release(&rt->dst);
-			in6_dev_put(in6_dev);
 			return;
 		}
 		neigh->flags |= NTF_ROUTER;
@@ -1422,7 +1419,6 @@ out:
 		dst_release(&rt->dst);
 	else if (neigh)
 		neigh_release(neigh);
-	in6_dev_put(in6_dev);
 }
 
 static void ndisc_redirect_rcv(struct sk_buff *skb)
@@ -1481,13 +1477,11 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
-	in6_dev = in6_dev_get(skb->dev);
+	in6_dev = __in6_dev_get(skb->dev);
 	if (!in6_dev)
 		return;
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_redirects) {
-		in6_dev_put(in6_dev);
+	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_redirects)
 		return;
-	}
 
 	/* RFC2461 8.1:
 	 *	The IP source address of the Redirect MUST be the same as the current
@@ -1497,7 +1491,6 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: invalid ND options\n");
-		in6_dev_put(in6_dev);
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
@@ -1506,7 +1499,6 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		if (!lladdr) {
 			ND_PRINTK2(KERN_WARNING
 				   "ICMPv6 Redirect: invalid link-layer address length\n");
-			in6_dev_put(in6_dev);
 			return;
 		}
 	}
@@ -1518,7 +1510,6 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 			     on_link);
 		neigh_release(neigh);
 	}
-	in6_dev_put(in6_dev);
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
@@ -1651,7 +1642,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 					     csum_partial(icmph, len, 0));
 
 	skb_dst_set(buff, dst);
-	idev = in6_dev_get(dst->dev);
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
@@ -1660,8 +1652,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	rcu_read_unlock();
 	return;
 
 release:


