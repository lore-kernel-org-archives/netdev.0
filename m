From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/2] drivers: net: xgene: fix: Use GPIO to get link status
Date: Thu,  6 Oct 2016 14:35:57 -0700
Message-ID: <1475789758-5196-2-git-send-email-isubramanian@apm.com>
References: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
        patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35905 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935447AbcJFVdI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 17:33:08 -0400
Received: by mail-pf0-f175.google.com with SMTP id i85so14674998pfa.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 14:33:08 -0700 (PDT)
In-Reply-To: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link value reported by the link status register is not
reliable when no SPF module inserted. This patchset fixes this
issue by using GPIO to determine the link status.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  6 +++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 19 +++++++++++++++++--
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 429f18f..f75d955 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1381,9 +1381,13 @@ static void xgene_enet_gpiod_get(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
 
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII)
+	pdata->sfp_gpio_en = false;
+	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII ||
+	    (!device_property_present(dev, "sfp-gpios") &&
+	     !device_property_present(dev, "rxlos-gpios")))
 		return;
 
+	pdata->sfp_gpio_en = true;
 	pdata->sfp_rdy = gpiod_get(dev, "rxlos", GPIOD_IN);
 	if (IS_ERR(pdata->sfp_rdy))
 		pdata->sfp_rdy = gpiod_get(dev, "sfp", GPIOD_IN);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 0cda58f..011965b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -219,6 +219,7 @@ struct xgene_enet_pdata {
 	u8 rx_delay;
 	bool mdio_driver;
 	struct gpio_desc *sfp_rdy;
+	bool sfp_gpio_en;
 };
 
 struct xgene_indirect_ctl {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 6475f38..d1758b0 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -415,16 +415,31 @@ static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
 	xgene_enet_wr_ring_if(pdata, addr, data);
 }
 
+static int xgene_enet_gpio_lookup(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+
+	pdata->sfp_rdy = gpiod_get(dev, "rxlos", GPIOD_IN);
+	if (IS_ERR(pdata->sfp_rdy))
+		pdata->sfp_rdy = gpiod_get(dev, "sfp", GPIOD_IN);
+
+	if (IS_ERR(pdata->sfp_rdy))
+		return -ENODEV;
+
+	return 0;
+}
+
 static void xgene_enet_link_state(struct work_struct *work)
 {
 	struct xgene_enet_pdata *pdata = container_of(to_delayed_work(work),
 					 struct xgene_enet_pdata, link_work);
-	struct gpio_desc *sfp_rdy = pdata->sfp_rdy;
 	struct net_device *ndev = pdata->ndev;
 	u32 link_status, poll_interval;
 
 	link_status = xgene_enet_link_status(pdata);
-	if (link_status && !IS_ERR(sfp_rdy) && !gpiod_get_value(sfp_rdy))
+	if (pdata->sfp_gpio_en && link_status &&
+	    (!IS_ERR(pdata->sfp_rdy) || !xgene_enet_gpio_lookup(pdata)) &&
+	    !gpiod_get_value(pdata->sfp_rdy))
 		link_status = 0;
 
 	if (link_status) {
-- 
1.9.1
