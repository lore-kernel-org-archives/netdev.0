From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Mon, 16 Nov 2015 14:40:59 -0800
Message-ID: <1447713659.22599.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
	 <20151116.153837.635003227845494331.davem@davemloft.net>
	 <1447712329.2095039.441554865.621B2AF9@webmail.messagingengine.com>
	 <1447713039.22599.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33882 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbKPWlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:41:00 -0500
Received: by padhx2 with SMTP id hx2so188736110pad.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 14:41:00 -0800 (PST)
In-Reply-To: <1447713039.22599.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-16 at 14:30 -0800, Eric Dumazet wrote:
> On Mon, 2015-11-16 at 23:18 +0100, Hannes Frederic Sowa wrote:
> > > need something that handles all cases properly.
> > 
> > I just wanted to shut up the gcc warning which is added if a function
> > uses more than 2048 bytes of stack space. We normally don't have the
> > problem and could also divide the function into two, but I don't see a
> > general solution to the problem. Mostly they need to be custom tailored
> > to the specific usage.
> > 
> > I can have a look if we can use kmalloc based storage for the stats, but
> > this also means that we add another NULL pointer check and error
> > handling for those cases. Let me have a look!
> 
> Simply put the code different functions with noinline_for_stack

First step : 

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 504bd17b7456..ff109fad5a7f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1045,15 +1045,35 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static noinline_for_stack bool rtnl_fill_stats(struct sk_buff *skb,
+					       struct net_device *dev)
+{
+	const struct rtnl_link_stats64 *stats;
+	struct rtnl_link_stats64 temp;
+	struct nlattr *attr;
+
+	attr = nla_reserve(skb, IFLA_STATS,
+			   sizeof(struct rtnl_link_stats));
+	if (!attr)
+		return true;
+	stats = dev_get_stats(dev, &temp);
+	copy_rtnl_link_stats(nla_data(attr), stats);
+
+	attr = nla_reserve(skb, IFLA_STATS64,
+			   sizeof(struct rtnl_link_stats64));
+	if (!attr)
+		return true;
+	copy_rtnl_link_stats64(nla_data(attr), stats);
+	return false;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	struct rtnl_link_stats64 temp;
-	const struct rtnl_link_stats64 *stats;
-	struct nlattr *attr, *af_spec;
+	struct nlattr *af_spec;
 	struct rtnl_af_ops *af_ops;
 	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 
@@ -1124,19 +1144,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_phys_switch_id_fill(skb, dev))
 		goto nla_put_failure;
 
-	attr = nla_reserve(skb, IFLA_STATS,
-			sizeof(struct rtnl_link_stats));
-	if (attr == NULL)
-		goto nla_put_failure;
-
-	stats = dev_get_stats(dev, &temp);
-	copy_rtnl_link_stats(nla_data(attr), stats);
-
-	attr = nla_reserve(skb, IFLA_STATS64,
-			sizeof(struct rtnl_link_stats64));
-	if (attr == NULL)
+	if (rtnl_fill_stats(skb, dev))
 		goto nla_put_failure;
-	copy_rtnl_link_stats64(nla_data(attr), stats);
 
 	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
 	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
