From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 4/4] tg3: Implement set/get_eee handlers
Date: Fri, 17 May 2013 08:19:50 -0700
Message-ID: <1368803990-10098-5-git-send-email-nsujir@broadcom.com>
References: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3250 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab3EQPUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:20:01 -0400
In-Reply-To: <1368803990-10098-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 47 +++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3aeb98f..7d4f664 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13657,6 +13657,51 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	return 0;
 }
 
+static int tg3_set_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP)) {
+		netdev_warn(tp->dev,
+			    "Board does not support EEE!\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (edata->advertised != tp->eee.advertised) {
+		netdev_warn(tp->dev,
+			    "Direct manipulation of EEE advertisement is not supported\n");
+		return -EINVAL;
+	}
+
+	tp->eee = *edata;
+
+	tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
+	tg3_warn_mgmt_link_flap(tp);
+
+	if (netif_running(tp->dev)) {
+		tg3_full_lock(tp, 0);
+		tg3_setup_eee(tp);
+		tg3_phy_reset(tp);
+		tg3_full_unlock(tp);
+	}
+
+	return 0;
+}
+
+static int tg3_get_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP)) {
+		netdev_warn(tp->dev,
+			    "Board does not support EEE!\n");
+		return -EOPNOTSUPP;
+	}
+
+	*edata = tp->eee;
+	return 0;
+}
+
 static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_settings		= tg3_get_settings,
 	.set_settings		= tg3_set_settings,
@@ -13690,6 +13735,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_channels		= tg3_get_channels,
 	.set_channels		= tg3_set_channels,
 	.get_ts_info		= tg3_get_ts_info,
+	.get_eee		= tg3_get_eee,
+	.set_eee		= tg3_set_eee,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-- 
1.8.1.4
