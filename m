From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH v2 net-next 4/4] tg3: Implement set/get_eee handlers
Date: Sat, 18 May 2013 09:26:55 -0700
Message-ID: <1368894415-27678-5-git-send-email-nsujir@broadcom.com>
References: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2044 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662Ab3ERQ1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 May 2013 12:27:19 -0400
In-Reply-To: <1368894415-27678-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Ben Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 53 +++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |  1 +
 2 files changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2d9b303..0a2ee3c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13647,6 +13647,57 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	return 0;
 }
 
+static int tg3_set_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP)) {
+		netdev_warn(tp->dev, "Board does not support EEE!\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (edata->advertised != tp->eee.advertised) {
+		netdev_warn(tp->dev,
+			    "Direct manipulation of EEE advertisement is not supported\n");
+		return -EINVAL;
+	}
+
+	if (edata->tx_lpi_timer > TG3_CPMU_DBTMR1_LNKIDLE_MAX) {
+		netdev_warn(tp->dev,
+			    "Maximal Tx Lpi timer supported is %#x(u)\n",
+			    TG3_CPMU_DBTMR1_LNKIDLE_MAX);
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
@@ -13680,6 +13731,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_channels		= tg3_get_channels,
 	.set_channels		= tg3_set_channels,
 	.get_ts_info		= tg3_get_ts_info,
+	.get_eee		= tg3_get_eee,
+	.set_eee		= tg3_set_eee,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 057532c..2530c20 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1175,6 +1175,7 @@
 #define TG3_CPMU_EEE_DBTMR1		0x000036b4
 #define  TG3_CPMU_DBTMR1_PCIEXIT_2047US	 0x07ff0000
 #define  TG3_CPMU_DBTMR1_LNKIDLE_2047US	 0x000007ff
+#define  TG3_CPMU_DBTMR1_LNKIDLE_MAX	 0x0000ffff
 #define TG3_CPMU_EEE_DBTMR2		0x000036b8
 #define  TG3_CPMU_DBTMR2_APE_TX_2047US	 0x07ff0000
 #define  TG3_CPMU_DBTMR2_TXIDXEQ_2047US	 0x000007ff
-- 
1.8.1.4
