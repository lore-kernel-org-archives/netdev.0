From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 02/13] bnx2x: Set ethtool ops for vfs
Date: Mon, 11 Mar 2013 17:17:42 +0200
Message-ID: <1363015073-25743-3-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1468 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461Ab3CKQZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:10 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Virtual functions don't have access to HW registers, therefore most ethtool ops
are forbidden to them. Instead of checking in each op whether the device being
driven is a virtual function or a physical function, this patch creates a
separate ethtool ops struct for virtual functions and uses it to initialize
the ethtool ops of the driver in case it is driving a virtual function device.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   29 ++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    2 +-
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 9577cce..8ddc78b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2285,7 +2285,7 @@ static const u32 dmae_reg_go_c[] = {
 	DMAE_REG_GO_C12, DMAE_REG_GO_C13, DMAE_REG_GO_C14, DMAE_REG_GO_C15
 };
 
-void bnx2x_set_ethtool_ops(struct net_device *netdev);
+void bnx2x_set_ethtool_ops(struct bnx2x *bp, struct net_device *netdev);
 void bnx2x_notify_link_changed(struct bnx2x *bp);
 
 #define BNX2X_MF_SD_PROTOCOL(bp) \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index edfa67a..324d691 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3232,7 +3232,32 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
-void bnx2x_set_ethtool_ops(struct net_device *netdev)
+static const struct ethtool_ops bnx2x_vf_ethtool_ops = {
+	.get_settings		= bnx2x_get_settings,
+	.set_settings		= bnx2x_set_settings,
+	.get_drvinfo		= bnx2x_get_drvinfo,
+	.get_msglevel		= bnx2x_get_msglevel,
+	.set_msglevel		= bnx2x_set_msglevel,
+	.get_link		= bnx2x_get_link,
+	.get_coalesce		= bnx2x_get_coalesce,
+	.get_ringparam		= bnx2x_get_ringparam,
+	.set_ringparam		= bnx2x_set_ringparam,
+	.get_sset_count		= bnx2x_get_sset_count,
+	.get_strings		= bnx2x_get_strings,
+	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
+	.get_rxnfc		= bnx2x_get_rxnfc,
+	.set_rxnfc		= bnx2x_set_rxnfc,
+	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
+	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
+	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
+	.get_channels		= bnx2x_get_channels,
+	.set_channels		= bnx2x_set_channels,
+};
+
+void bnx2x_set_ethtool_ops(struct bnx2x *bp, struct net_device *netdev)
 {
-	SET_ETHTOOL_OPS(netdev, &bnx2x_ethtool_ops);
+	if (IS_PF(bp))
+		SET_ETHTOOL_OPS(netdev, &bnx2x_ethtool_ops);
+	else /* vf */
+		SET_ETHTOOL_OPS(netdev, &bnx2x_vf_ethtool_ops);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e81a747..14a7784 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11953,7 +11953,7 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	dev->netdev_ops = &bnx2x_netdev_ops;
-	bnx2x_set_ethtool_ops(dev);
+	bnx2x_set_ethtool_ops(bp, dev);
 
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
-- 
1.7.7.2
