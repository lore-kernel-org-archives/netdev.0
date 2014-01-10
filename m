From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Fri, 10 Jan 2014 07:36:38 +0100
Message-ID: <20140110063638.GA17866@order.stressinduktion.org>
References: <20140109201411.317040@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch, eric.dumazet@gmail.com
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53243 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaAJGgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 01:36:40 -0500
Content-Disposition: inline
In-Reply-To: <20140109201411.317040@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 09:14:11PM +0100, Bob Falken wrote:
> Hello,
> Testing this patch as im typing this. will check status in about 12hours.
> Unfortuantly, I dont have any receivers avaialble for requesting the multicast stream on the edge point anymore. 
> So there is not TX traffic a.t.m..
> 
> I will have a better test-lab available next week. (hopefully).

Ok, so I am proposing this patch. Only difference from the RFC is that
I removed the superfluous arg.rule NULL-pointer checks (I hate if they
are superfluous and they always seem to spread ;) ).

Maybe you could test this one instead and David could pick it up as soon
as your results are in.

I'll also look for the stable kernels where FIB_LOOKUP_NOREF is not
yet available.

Thank you,

  Hannes

[PATCH net] net: avoid reference counter overflows on fib_rules in multicast forwarding

When introducing multiple table support for multicast forwarding in
IPv4 and IPv6, necessary fib_rules_put reference count decrements were
forgotten.

Bob Falken reported that after 4G packets, multicast forwarding stopped
working. This was because of a rule reference counter overflow which
freed the rule as soon as the overflow happend.

So, use FIB_LOOKUP_NOREF if we are already in a RCU protected section and
correctly deal with reference counter if not (called from ndo_start_xmit).

Fixes: f0ad0860d01e47 ("ipv4: ipmr: support multiple tables")
Fixes: d1db275dd3f6e4 ("ipv6: ip6mr: support multiple tables")
Reported-by: Bob Falken <NetFestivalHaveFun@gmx.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ipmr.c  | 23 +++++++++++++++++------
 net/ipv6/ip6mr.c | 21 +++++++++++++++------
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 421a249..c8d0857 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -157,9 +157,12 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
 static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 			   struct mr_table **mrt)
 {
-	struct ipmr_result res;
-	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
+	struct ipmr_result res;
+	struct fib_lookup_arg arg = {
+		.result = &res,
+		.flags = FIB_LOOKUP_NOREF,
+	};
 
 	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
 			       flowi4_to_flowi(flp4), 0, &arg);
@@ -448,16 +451,22 @@ failure:
 
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	int err;
+	struct ipmr_result res;
 	struct net *net = dev_net(dev);
-	struct mr_table *mrt;
+
+	struct fib_lookup_arg arg = {
+		.result = &res,
+	};
+
 	struct flowi4 fl4 = {
 		.flowi4_oif	= dev->ifindex,
 		.flowi4_iif	= skb->skb_iif,
 		.flowi4_mark	= skb->mark,
 	};
-	int err;
 
-	err = ipmr_fib_lookup(net, &fl4, &mrt);
+	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
+			       flowi4_to_flowi(&fl4), 0, &arg);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
@@ -466,9 +475,11 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ipmr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
+	ipmr_cache_report(res.mrt, skb, res.mrt->mroute_reg_vif_num,
+			  IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
+	fib_rule_put(arg.rule);
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f365310..38347a3 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -141,9 +141,12 @@ static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
 static int ip6mr_fib_lookup(struct net *net, struct flowi6 *flp6,
 			    struct mr6_table **mrt)
 {
-	struct ip6mr_result res;
-	struct fib_lookup_arg arg = { .result = &res, };
 	int err;
+	struct ip6mr_result res;
+	struct fib_lookup_arg arg = {
+		.result = &res,
+		.flags = FIB_LOOKUP_NOREF,
+	};
 
 	err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
 			       flowi6_to_flowi(flp6), 0, &arg);
@@ -693,16 +696,20 @@ static const struct inet6_protocol pim6_protocol = {
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
+	int err;
+	struct ip6mr_result res;
 	struct net *net = dev_net(dev);
-	struct mr6_table *mrt;
 	struct flowi6 fl6 = {
 		.flowi6_oif	= dev->ifindex,
 		.flowi6_iif	= skb->skb_iif,
 		.flowi6_mark	= skb->mark,
 	};
-	int err;
+	struct fib_lookup_arg arg = {
+		.result = &res,
+	};
 
-	err = ip6mr_fib_lookup(net, &fl6, &mrt);
+	err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
+			flowi6_to_flowi(&fl6), 0, &arg);
 	if (err < 0) {
 		kfree_skb(skb);
 		return err;
@@ -711,9 +718,11 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ip6mr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, MRT6MSG_WHOLEPKT);
+	ip6mr_cache_report(res.mrt, skb, res.mrt->mroute_reg_vif_num,
+			   MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
+	fib_rule_put(arg.rule);
 	return NETDEV_TX_OK;
 }
 
-- 
1.8.4.2
