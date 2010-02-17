From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PACH] smsc911x: replace manual phy lookup.
Date: Wed, 17 Feb 2010 10:54:58 +0300
Message-ID: <20100217075458.GA4388@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: steve.glendinning@smsc.com, jpirko@redhat.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:57292 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933712Ab0BQHxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 02:53:09 -0500
Received: by fxm7 with SMTP id 7so8263145fxm.28
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 23:53:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use phy_find_first() function instead of manual lookup.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---

 drivers/net/smsc911x.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 3c1f9aa..13c0b76 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -770,29 +770,25 @@ static int smsc911x_mii_probe(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
-	int phy_addr;
+	int ret;
 
 	/* find the first phy */
-	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-		if (pdata->mii_bus->phy_map[phy_addr]) {
-			phydev = pdata->mii_bus->phy_map[phy_addr];
-			SMSC_TRACE(PROBE, "PHY %d: addr %d, phy_id 0x%08X",
-				phy_addr, phydev->addr, phydev->phy_id);
-			break;
-		}
-	}
-
+	phydev = phy_find_first(pdata->mii_bus);
 	if (!phydev) {
 		pr_err("%s: no PHY found\n", dev->name);
 		return -ENODEV;
 	}
 
-	phydev = phy_connect(dev, dev_name(&phydev->dev),
-		&smsc911x_phy_adjust_link, 0, pdata->config.phy_interface);
+	SMSC_TRACE(PROBE, "PHY %d: addr %d, phy_id 0x%08X",
+			phy_addr, phydev->addr, phydev->phy_id);
+
+	ret = phy_connect_direct(dev, phydev,
+			&smsc911x_phy_adjust_link, 0,
+			pdata->config.phy_interface);
 
-	if (IS_ERR(phydev)) {
+	if (ret) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
+		return ret;
 	}
 
 	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
