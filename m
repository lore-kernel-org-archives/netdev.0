From: cooldavid@cooldavid.org
Subject: [PATCH net 2/2] jme: Fix device PM wakeup API usage
Date: Sat,  5 Mar 2016 08:11:56 +0800
Message-ID: <1457136716-7251-2-git-send-email-cooldavid@cooldavid.org>
References: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Diego Viola" <diego.viola@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:56906 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760533AbcCEAGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 19:06:52 -0500
In-Reply-To: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

According to Documentation/power/devices.txt

The driver should not use device_set_wakeup_enable() which is the policy
for user to decide.

Using device_init_wakeup() to initialize dev->power.should_wakeup and
dev->power.can_wakeup on driver initialization.

And use device_may_wakeup() on suspend to decide if WoL function should
be enabled on NIC.

Reported-by: Diego Viola <diego.viola@gmail.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/ethernet/jme.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 74b9c9d..3ddf657 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1931,7 +1931,7 @@ jme_wait_link(struct jme_adapter *jme)
 static void
 jme_powersave_phy(struct jme_adapter *jme)
 {
-	if (jme->reg_pmcs) {
+	if (jme->reg_pmcs && device_may_wakeup(&jme->pdev->dev)) {
 		jme_set_100m_half(jme);
 		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
 			jme_wait_link(jme);
@@ -2652,8 +2652,6 @@ jme_set_wol(struct net_device *netdev,
 	if (wol->wolopts & WAKE_MAGIC)
 		jme->reg_pmcs |= PMCS_MFEN;
 
-	device_set_wakeup_enable(&jme->pdev->dev, !!(jme->reg_pmcs));
-
 	return 0;
 }
 
@@ -3178,7 +3176,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->mii_if.mdio_write = jme_mdio_write;
 
 	jme_clear_pm_disable_wol(jme);
-	device_set_wakeup_enable(&pdev->dev, true);
+	device_init_wakeup(&pdev->dev, true);
 
 	jme_set_phyfifo_5level(jme);
 	jme->pcirev = pdev->revision;
-- 
1.8.5.5
