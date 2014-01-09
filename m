From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Thu, 09 Jan 2014 21:14:11 +0100
Message-ID: <20140109201411.317040@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	"Julian Anastasov" <ja@ssi.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:50352 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757315AbaAIUOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:14:15 -0500
Received: from mailout-eu.gmx.com ([10.1.101.210]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MR9pB-1VoXiE3Bgl-00UXK8 for
 <netdev@vger.kernel.org>; Thu, 09 Jan 2014 21:14:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Testing this patch as im typing this. will check status in about 12hours.
Unfortuantly, I dont have any receivers avaialble for requesting the multicast stream on the edge point anymore. 
So there is not TX traffic a.t.m..

I will have a better test-lab available next week. (hopefully).

Thanks again.
----- Original Message -----
From: Hannes Frederic Sowa
Sent: 01/07/14 09:20 PM
To: Bob Falken, Julian Anastasov, netdev@vger.kernel.org
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
 On Tue, Jan 07, 2014 at 09:11:47PM +0100, Hannes Frederic Sowa wrote:
> On Tue, Jan 07, 2014 at 06:43:22PM +0100, Hannes Frederic Sowa wrote:
> > On Tue, Jan 07, 2014 at 06:01:44PM +0100, Bob Falken wrote:
> > > Hello,
> > > 
> > > I patched, kernel 3.2.53 yesterday,
> > > 8774002632packets, and ~9.1TB later, the multicast routing seems to function properly. :)
> > > 
> > > Kudos for fixing this.
> > > 
> > > I will keep checking the next days.
> > > 
> > > As for IPv6 MR, my current setup i.e: the Multicast source, does not support IPv6, so cannot do a check for that natively.
> > > 
> > > Unless I can translate IPv4 multicast into IPv6 multicast easily, using some iptable prerouting rules(?).
> > 
> > Thank you for testing!
> > 
> > I'll review the RCU regions again and will prepare the patches (before
> > introduction of ebc0ffae5dfb44 ("fib: RCU conversion of fib_lookup()")
> > and after.
> 
> It seems ip(6)mr_fib_lookup is not always called from rcu section
> (ndo_start_xmit), so I had to restructure a bit. Could you retest this
> patch as preparation for a submission to stable? Thanks!
> 
> RCU conversion can be done later then.

Broken patch, sorry. Please try this one:

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 421a249..e5e9071 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -157,9 +157,12 @@ static struct mr_table *ipmr_get_table(struct net *net, u32 id)
 static int ipmr_fib_lookup(struct net *net, struct flowi4 *flp4,
 struct mr_table **mrt)
 {
- struct ipmr_result res;
- struct fib_lookup_arg arg = { .result = &res};
 int err;
+ struct ipmr_result res;
+ struct fib_lookup_arg arg = {
+ .result = &res,
+ .flags = FIB_LOOKUP_NOREF,
+ };
 
 err = fib_rules_lookup(net->ipv4.mr_rules_ops,
 flowi4_to_flowi(flp4), 0, &arg);
@@ -448,16 +451,22 @@ failure:
 
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+ int err;
+ struct ipmr_result res;
 struct net *net = dev_net(dev);
- struct mr_table *mrt;
+
+ struct fib_lookup_arg arg = {
+ .result = &res,
+ };
+
 struct flowi4 fl4 = {
 .flowi4_oif = dev->ifindex,
 .flowi4_iif = skb->skb_iif,
 .flowi4_mark = skb->mark,
 };
- int err;
 
- err = ipmr_fib_lookup(net, &fl4, &mrt);
+ err = fib_rules_lookup(net->ipv4.mr_rules_ops,
+ flowi4_to_flowi(&fl4), 0, &arg);
 if (err < 0) {
 kfree_skb(skb);
 return err;
@@ -466,9 +475,12 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 read_lock(&mrt_lock);
 dev->stats.tx_bytes += skb->len;
 dev->stats.tx_packets++;
- ipmr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
+ ipmr_cache_report(res.mrt, skb, res.mrt->mroute_reg_vif_num,
+ IGMPMSG_WHOLEPKT);
 read_unlock(&mrt_lock);
 kfree_skb(skb);
+ if (arg.rule)
+ fib_rule_put(arg.rule);
 return NETDEV_TX_OK;
 }
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f365310..45ec621 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -141,9 +141,12 @@ static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
 static int ip6mr_fib_lookup(struct net *net, struct flowi6 *flp6,
 struct mr6_table **mrt)
 {
- struct ip6mr_result res;
- struct fib_lookup_arg arg = { .result = &res};
 int err;
+ struct ip6mr_result res;
+ struct fib_lookup_arg arg = {
+ .result = &res,
+ .flags = FIB_LOOKUP_NOREF,
+ };
 
 err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
 flowi6_to_flowi(flp6), 0, &arg);
@@ -693,16 +696,20 @@ static const struct inet6_protocol pim6_protocol = {
 static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 struct net_device *dev)
 {
+ int err;
+ struct ip6mr_result res;
 struct net *net = dev_net(dev);
- struct mr6_table *mrt;
 struct flowi6 fl6 = {
 .flowi6_oif = dev->ifindex,
 .flowi6_iif = skb->skb_iif,
 .flowi6_mark = skb->mark,
 };
- int err;
+ struct fib_lookup_arg arg = {
+ .result = &res,
+ };
 
- err = ip6mr_fib_lookup(net, &fl6, &mrt);
+ err = fib_rules_lookup(net->ipv6.mr6_rules_ops,
+ flowi6_to_flowi(&fl6), 0, &arg);
 if (err < 0) {
 kfree_skb(skb);
 return err;
@@ -711,9 +718,12 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 read_lock(&mrt_lock);
 dev->stats.tx_bytes += skb->len;
 dev->stats.tx_packets++;
- ip6mr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, MRT6MSG_WHOLEPKT);
+ ip6mr_cache_report(res.mrt, skb, res.mrt->mroute_reg_vif_num,
+ MRT6MSG_WHOLEPKT);
 read_unlock(&mrt_lock);
 kfree_skb(skb);
+ if (arg.rule)
+ fib_rule_put(arg.rule);
 return NETDEV_TX_OK;
 } 
