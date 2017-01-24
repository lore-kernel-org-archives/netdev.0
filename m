From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 04/18] netvsc: report rss field values
Date: Tue, 24 Jan 2017 13:06:01 -0800
Message-ID: <20170124210615.18628-5-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35315 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f47.google.com with SMTP id 194so57794057pgd.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:22 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report current components used in RSS hash.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b158cab678b3..6ab8b52af965 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1009,6 +1009,30 @@ static void netvsc_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 }
 
 static int
+netvsc_get_rss_hash_opts(struct netvsc_device *nvdev,
+			 struct ethtool_rxnfc *info)
+{
+	info->data = RXH_IP_SRC | RXH_IP_DST;
+
+	switch (info->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fallthrough */
+	case UDP_V4_FLOW:
+	case UDP_V6_FLOW:
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		break;
+	default:
+		info->data = 0;
+		break;
+	}
+
+	return 0;
+}
+
+static int
 netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 		 u32 *rules)
 {
@@ -1019,6 +1043,9 @@ netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 	case ETHTOOL_GRXRINGS:
 		info->data = nvdev->num_chn;
 		return 0;
+
+	case ETHTOOL_GRXFH:
+		return netvsc_get_rss_hash_opts(nvdev, info);
 	}
 	return -EOPNOTSUPP;
 }
-- 
2.11.0
