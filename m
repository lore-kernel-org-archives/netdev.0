From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 1/5] jme: Fix PHY power-off error
Date: Tue, 19 Oct 2010 08:10:40 +0800
Message-ID: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>, <stable@kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49738 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757188Ab0JSAU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding phy_on in opposition to phy_off.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: <stable@kernel.org>
---
 drivers/net/jme.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index c04c096..e04f180 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1574,6 +1574,16 @@ jme_free_irq(struct jme_adapter *jme)
 	}
 }
 
+static inline void
+jme_phy_on(struct jme_adapter *jme)
+{
+	u32 bmcr;
+
+	bmcr = jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
+	bmcr &= ~BMCR_PDOWN;
+	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, bmcr);
+}
+
 static int
 jme_open(struct net_device *netdev)
 {
@@ -1594,10 +1604,12 @@ jme_open(struct net_device *netdev)
 
 	jme_start_irq(jme);
 
-	if (test_bit(JME_FLAG_SSET, &jme->flags))
+	if (test_bit(JME_FLAG_SSET, &jme->flags)) {
+		jme_phy_on(jme);
 		jme_set_settings(netdev, &jme->old_ecmd);
-	else
+	} else {
 		jme_reset_phy_processor(jme);
+	}
 
 	jme_reset_link(jme);
 
@@ -3005,10 +3017,12 @@ jme_resume(struct pci_dev *pdev)
 	jme_clear_pm(jme);
 	pci_restore_state(pdev);
 
-	if (test_bit(JME_FLAG_SSET, &jme->flags))
+	if (test_bit(JME_FLAG_SSET, &jme->flags)) {
+		jme_phy_on(jme);
 		jme_set_settings(netdev, &jme->old_ecmd);
-	else
+	} else {
 		jme_reset_phy_processor(jme);
+	}
 
 	jme_start_irq(jme);
 	netif_device_attach(netdev);
-- 
1.7.2.2

