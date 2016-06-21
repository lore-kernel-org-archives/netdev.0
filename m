From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 2/4] rtnetlink: add HW/SW stats distinction in rtnl_fill_stats
Date: Tue, 21 Jun 2016 17:15:54 +0200
Message-ID: <1466522156-4795-3-git-send-email-jiri@resnulli.us>
References: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:35840 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbcFUPQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:16:03 -0400
Received: by mail-lb0-f194.google.com with SMTP id ur4so2251823lbc.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 08:16:02 -0700 (PDT)
In-Reply-To: <1466522156-4795-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Since hardware stats are now returned by default, add a way to
query only software stats.
They are saved in IFLA_SW_STATS64.
(This option is valid only if the driver returns HW stats in the
default ndo stats)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

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
index eb49ca2..7958cde 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -901,6 +901,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size_64bit(sizeof(struct rtnl_link_ifmap))
 	       + nla_total_size(sizeof(struct rtnl_link_stats))
 	       + nla_total_size_64bit(sizeof(struct rtnl_link_stats64))
+	       + nla_total_size_64bit(sizeof(struct rtnl_link_stats64)) /* IFLA_SW_STATS64 */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
 	       + nla_total_size(4) /* IFLA_TXQLEN */
@@ -928,7 +929,6 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
-
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -1082,6 +1082,17 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 	sp = nla_data(attr);
 	dev_get_stats(dev, sp);
 
+	if (dev_have_sw_stats(dev)) {
+		attr = nla_reserve_64bit(skb, IFLA_SW_STATS64,
+					 sizeof(struct rtnl_link_stats64),
+					 IFLA_PAD);
+		if (!attr)
+			return -EMSGSIZE;
+
+		sp = nla_data(attr);
+		dev_get_sw_stats(dev, sp);
+	}
+
 	attr = nla_reserve(skb, IFLA_STATS,
 			   sizeof(struct rtnl_link_stats));
 	if (!attr)
-- 
2.5.5
