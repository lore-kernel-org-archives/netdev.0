From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: BUG: 32 bit net stats
Date: Mon, 23 Sep 2013 17:49:37 -0400
Message-ID: <5240B771.8040307@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090700090609020802000902"
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:38066 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341Ab3IWVtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 17:49:46 -0400
Received: by mail-qa0-f50.google.com with SMTP id j7so1941087qaq.2
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 14:49:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090700090609020802000902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Something broke in sending of 32 bit version of netstat around the
time 64 bit version was improved. I went back as far as 3.8.0 to recent
kernels. Could have been earlier.
The work around in user space is when you see 64 bit stats just ignore
the 32 bit version (which iproute2 does and so am i;->).

But assumming there are tools out there that know only of 32 bit
variant they will get bad stats. Here's a compile tested only patch.
Wont have to test anything for at least another day.

cheers,
jamal


--------------090700090609020802000902
Content-Type: text/plain; charset=UTF-8;
 name="p-untested"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="p-untested"

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2a0e21d..005be70 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -659,7 +659,7 @@ static unsigned int rtnl_dev_combine_flags(const struct net_device *dev,
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
-				 const struct rtnl_link_stats64 *b)
+				 const struct net_device_stats *b)
 {
 	a->rx_packets = b->rx_packets;
 	a->tx_packets = b->tx_packets;
@@ -876,6 +876,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
 	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
+	const struct net_device_stats *stats32 = &dev->stats;
+	const struct net_device_ops *ops = dev->netdev_ops;
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -940,9 +942,11 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (attr == NULL)
 		goto nla_put_failure;
 
-	stats = dev_get_stats(dev, &temp);
-	copy_rtnl_link_stats(nla_data(attr), stats);
+	if (ops->ndo_get_stats)
+		stats32 = ops->ndo_get_stats(dev);
+	copy_rtnl_link_stats(nla_data(attr), stats32);
 
+	stats = dev_get_stats(dev, &temp);
 	attr = nla_reserve(skb, IFLA_STATS64,
 			sizeof(struct rtnl_link_stats64));
 	if (attr == NULL)

--------------090700090609020802000902--
