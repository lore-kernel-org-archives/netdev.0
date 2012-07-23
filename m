From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Really ignore ICMP address requests/replies.
Date: Mon, 23 Jul 2012 13:23:36 -0700 (PDT)
Message-ID: <20120723.132336.801355796496060489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612Ab2GWUXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:23:37 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 481DE58426C
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 13:23:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexey removed kernel side support for requests, and the
only thing we do for replies is log a message if something
doesn't look right.

As Alexey's comment indicates, this belongs in userspace (if
anywhere), and thus we can safely just get rid of this code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |   84 ++-----------------------------------------------------
 1 file changed, 2 insertions(+), 82 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ea3a996..f2a06be 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -837,86 +837,6 @@ out_err:
 	goto out;
 }
 
-
-/*
- *	Handle ICMP_ADDRESS_MASK requests.  (RFC950)
- *
- * RFC1122 (3.2.2.9).  A host MUST only send replies to
- * ADDRESS_MASK requests if it's been configured as an address mask
- * agent.  Receiving a request doesn't constitute implicit permission to
- * act as one. Of course, implementing this correctly requires (SHOULD)
- * a way to turn the functionality on and off.  Another one for sysctl(),
- * I guess. -- MS
- *
- * RFC1812 (4.3.3.9).	A router MUST implement it.
- *			A router SHOULD have switch turning it on/off.
- *		      	This switch MUST be ON by default.
- *
- * Gratuitous replies, zero-source replies are not implemented,
- * that complies with RFC. DO NOT implement them!!! All the idea
- * of broadcast addrmask replies as specified in RFC950 is broken.
- * The problem is that it is not uncommon to have several prefixes
- * on one physical interface. Moreover, addrmask agent can even be
- * not aware of existing another prefixes.
- * If source is zero, addrmask agent cannot choose correct prefix.
- * Gratuitous mask announcements suffer from the same problem.
- * RFC1812 explains it, but still allows to use ADDRMASK,
- * that is pretty silly. --ANK
- *
- * All these rules are so bizarre, that I removed kernel addrmask
- * support at all. It is wrong, it is obsolete, nobody uses it in
- * any case. --ANK
- *
- * Furthermore you can do it with a usermode address agent program
- * anyway...
- */
-
-static void icmp_address(struct sk_buff *skb)
-{
-#if 0
-	net_dbg_ratelimited("a guy asks for address mask. Who is it?\n");
-#endif
-}
-
-/*
- * RFC1812 (4.3.3.9).	A router SHOULD listen all replies, and complain
- *			loudly if an inconsistency is found.
- * called with rcu_read_lock()
- */
-
-static void icmp_address_reply(struct sk_buff *skb)
-{
-	struct rtable *rt = skb_rtable(skb);
-	struct net_device *dev = skb->dev;
-	struct in_device *in_dev;
-	struct in_ifaddr *ifa;
-
-	if (skb->len < 4 || !(rt->rt_flags&RTCF_DIRECTSRC))
-		return;
-
-	in_dev = __in_dev_get_rcu(dev);
-	if (!in_dev)
-		return;
-
-	if (in_dev->ifa_list &&
-	    IN_DEV_LOG_MARTIANS(in_dev) &&
-	    IN_DEV_FORWARD(in_dev)) {
-		__be32 _mask, *mp;
-
-		mp = skb_header_pointer(skb, 0, sizeof(_mask), &_mask);
-		BUG_ON(mp == NULL);
-		for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
-			if (*mp == ifa->ifa_mask &&
-			    inet_ifa_match(ip_hdr(skb)->saddr, ifa))
-				break;
-		}
-		if (!ifa)
-			net_info_ratelimited("Wrong address mask %pI4 from %s/%pI4\n",
-					     mp,
-					     dev->name, &ip_hdr(skb)->saddr);
-	}
-}
-
 static void icmp_discard(struct sk_buff *skb)
 {
 }
@@ -1080,10 +1000,10 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES + 1] = {
 		.handler = icmp_discard,
 	},
 	[ICMP_ADDRESS] = {
-		.handler = icmp_address,
+		.handler = icmp_discard,
 	},
 	[ICMP_ADDRESSREPLY] = {
-		.handler = icmp_address_reply,
+		.handler = icmp_discard,
 	},
 };
 
-- 
1.7.10.4
