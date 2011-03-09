From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove flowi from struct rtable.
Date: Wed, 09 Mar 2011 14:06:49 -0800 (PST)
Message-ID: <20110309.140649.245387751.davem@davemloft.net>
References: <20110304.221214.189707201.davem@davemloft.net>
	<1299308388.2758.71.camel@edumazet-laptop>
	<20110304.230914.112605809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753745Ab1CIWGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 17:06:13 -0500
In-Reply-To: <20110304.230914.112605809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 04 Mar 2011 23:09:14 -0800 (PST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 05 Mar 2011 07:59:48 +0100
> 
>> Eventually we could have a helper for this, as this is done three times
>> in this file. Or maybe you have further plans for ipmr ?
> 
> No immediate plans, so yes I'll make a helper, good idea.

Sorry for taking so long on this, I just added the following to net-next-2.6:

--------------------
ipv4: Lookup multicast routes by rtable using helper.

Create a common helper for this operation, since we do
it identically in three spots.

Suggested by Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c |   70 ++++++++++++++++++++++---------------------------------
 1 files changed, 28 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d5f634..74909ba 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1793,6 +1793,24 @@ dont_forward:
 	return 0;
 }
 
+static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct rtable *rt)
+{
+	struct flowi fl = {
+		.fl4_dst = rt->rt_key_dst,
+		.fl4_src = rt->rt_key_src,
+		.fl4_tos = rt->rt_tos,
+		.oif = rt->rt_oif,
+		.iif = rt->rt_iif,
+		.mark = rt->rt_mark,
+	};
+	struct mr_table *mrt;
+	int err;
+
+	err = ipmr_fib_lookup(net, &fl, &mrt);
+	if (err)
+		return ERR_PTR(err);
+	return mrt;
+}
 
 /*
  *	Multicast packets for forwarding arrive here
@@ -1805,7 +1823,6 @@ int ip_mr_input(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
 	struct mr_table *mrt;
-	int err;
 
 	/* Packet is looped back after forward, it should not be
 	 * forwarded second time, but still can be delivered locally.
@@ -1813,21 +1830,10 @@ int ip_mr_input(struct sk_buff *skb)
 	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
 
-	{
-		struct rtable *rt = skb_rtable(skb);
-		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
-			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
-		};
-		err = ipmr_fib_lookup(net, &fl, &mrt);
-		if (err < 0) {
-			kfree_skb(skb);
-			return err;
-		}
+	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	if (IS_ERR(mrt)) {
+		kfree_skb(skb);
+		return PTR_ERR(mrt);
 	}
 	if (!local) {
 		if (IPCB(skb)->opt.router_alert) {
@@ -1956,19 +1962,9 @@ int pim_rcv_v1(struct sk_buff *skb)
 
 	pim = igmp_hdr(skb);
 
-	{
-		struct rtable *rt = skb_rtable(skb);
-		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
-			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
-		};
-		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
-			goto drop;
-	}
+	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	if (IS_ERR(mrt))
+		goto drop;
 	if (!mrt->mroute_do_pim ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
@@ -1998,19 +1994,9 @@ static int pim_rcv(struct sk_buff *skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	{
-		struct rtable *rt = skb_rtable(skb);
-		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
-			.oif = rt->rt_oif,
-			.iif = rt->rt_iif,
-			.mark = rt->rt_mark,
-		};
-		if (ipmr_fib_lookup(net, &fl, &mrt) < 0)
-			goto drop;
-	}
+	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	if (IS_ERR(mrt))
+		goto drop;
 	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
 drop:
 		kfree_skb(skb);
-- 
1.7.4.1

