From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] rtnetlink: add HW/SW stats distinction in rtnl_fill_stats
Date: Thu, 12 May 2016 13:48:48 +0200
Message-ID: <1463053730-14991-3-git-send-email-jiri@resnulli.us>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35569 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbcELLsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 07:48:55 -0400
Received: by mail-wm0-f65.google.com with SMTP id e201so15571181wme.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 04:48:54 -0700 (PDT)
In-Reply-To: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Since hardware stats are now returned by default, add a way to
query only software stats.
They are saved in IFLA_SW_STATS64.
(This option is valid only if the driver return HW stats in the
default ndo stats)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb36bd5..98175e7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -156,6 +156,7 @@ enum {
 	IFLA_GSO_MAX_SEGS,
 	IFLA_GSO_MAX_SIZE,
 	IFLA_PAD,
+	IFLA_SW_STATS64,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d69c464..a127d67 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1046,20 +1046,40 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_stats64 *b)
+{
+	memcpy(v, b, sizeof(*b));
+}
+
 static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 					      struct net_device *dev)
 {
+	struct rtnl_link_stats64 sw_stats;
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
+	int err;
 
 	attr = nla_reserve_64bit(skb, IFLA_STATS64,
 				 sizeof(struct rtnl_link_stats64), IFLA_PAD);
+
 	if (!attr)
 		return -EMSGSIZE;
 
 	sp = nla_data(attr);
 	dev_get_stats(dev, sp);
 
+	err = dev_get_sw_stats(dev, &sw_stats);
+	if (!err) {
+		attr = nla_reserve_64bit(skb, IFLA_SW_STATS64,
+					 sizeof(struct rtnl_link_stats64),
+					 IFLA_PAD);
+
+		if (!attr)
+			return -EMSGSIZE;
+
+		copy_rtnl_link_stats64(nla_data(attr), &sw_stats);
+	}
+
 	attr = nla_reserve(skb, IFLA_STATS,
 			   sizeof(struct rtnl_link_stats));
 	if (!attr)
-- 
2.5.5
