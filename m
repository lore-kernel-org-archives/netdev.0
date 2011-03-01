From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/8] xfrm: Kill XFRM_LOOKUP_WAIT flag.
Date: Tue, 01 Mar 2011 15:11:34 -0800 (PST)
Message-ID: <20110301.151134.229741756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48519
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757121Ab1CAXK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:57 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8C15324C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This can be determined from the flow flags instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |    3 +--
 net/decnet/dn_route.c  |    5 +++--
 net/ipv4/route.c       |    4 +---
 net/ipv6/ip6_output.c  |    4 ++--
 net/xfrm/xfrm_policy.c |    2 +-
 5 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 4fedffd..15d67c8 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -421,8 +421,7 @@ extern void		dst_init(void);
 
 /* Flags for xfrm_lookup flags argument. */
 enum {
-	XFRM_LOOKUP_WAIT = 1 << 0,
-	XFRM_LOOKUP_ICMP = 1 << 1,
+	XFRM_LOOKUP_ICMP = 1 << 0,
 };
 
 struct flowi;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 06c054d..0877147 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1233,8 +1233,9 @@ int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
 	if (err == 0 && fl->proto) {
-		err = xfrm_lookup(&init_net, pprt, fl, sk,
-				 (flags & MSG_DONTWAIT) ? 0 : XFRM_LOOKUP_WAIT);
+		if (!(flags & MSG_DONTWAIT))
+			fl->flags |= FLOWI_FLAG_CAN_SLEEP;
+		err = xfrm_lookup(&init_net, pprt, fl, sk, 0);
 	}
 	return err;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7846265..23d2050 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2732,9 +2732,7 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 			flp->fl4_src = (*rp)->rt_src;
 		if (!flp->fl4_dst)
 			flp->fl4_dst = (*rp)->rt_dst;
-		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk,
-				    ((flp->flags & FLOWI_FLAG_CAN_SLEEP) ?
-				     XFRM_LOOKUP_WAIT : 0));
+		err = __xfrm_lookup(net, (struct dst_entry **)rp, flp, sk, 0);
 		if (err == -EREMOTE)
 			err = ipv4_dst_blackhole(net, rp, flp);
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b5f8769..faf7b9d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1027,7 +1027,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (can_sleep) {
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
-		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
+		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, fl);
 		if (err)
@@ -1072,7 +1072,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		ipv6_addr_copy(&fl->fl6_dst, final_dst);
 	if (can_sleep) {
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
-		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
+		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
 		if (err == -EREMOTE)
 			err = ip6_dst_blackhole(sk, &dst, fl);
 		if (err)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 41a91d2..f4c7467 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1831,7 +1831,7 @@ restart:
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
 			return -EREMOTE;
 		}
-		if (flags & XFRM_LOOKUP_WAIT) {
+		if (fl->flags & FLOWI_FLAG_CAN_SLEEP) {
 			DECLARE_WAITQUEUE(wait, current);
 
 			add_wait_queue(&net->xfrm.km_waitq, &wait);
-- 
1.7.4.1

