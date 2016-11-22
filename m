From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] ethtool: Protect {get,set}_phy_tunable with PHY device mutex
Date: Tue, 22 Nov 2016 13:55:31 -0800
Message-ID: <20161122215531.18212-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33232 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755213AbcKVVzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 16:55:50 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so3149607pgd.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 13:55:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY drivers should be able to rely on the caller of {get,set}_tunable to
have acquired the PHY device mutex, in order to both serialize against
concurrent calls of these functions, but also against PHY state machine
changes. All ethtool PHY-level functions do this, except
{get,set}_tunable, so we make them consistent here as well.

We need to update the Microsemi PHY driver in the same commit to avoid
introducing either deadlocks, or lack of proper locking.

Fixes: 968ad9da7e0e ("ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE")
Fixes: 310d9ad57ae0 ("net: phy: Add downshift get/set support in Microsemi PHYs driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- also patch drivers/net/phy/mscc.c in the same commit

 drivers/net/phy/mscc.c | 16 +++++-----------
 net/core/ethtool.c     |  4 ++++
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 92018ba6209e..7a3740c7bf6d 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -115,10 +115,9 @@ static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
 	int rc;
 	u16 reg_val;
 
-	mutex_lock(&phydev->lock);
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
 	if (rc != 0)
-		goto out_unlock;
+		goto out;
 
 	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
 	reg_val &= DOWNSHIFT_CNTL_MASK;
@@ -128,9 +127,7 @@ static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
 		*count = ((reg_val & ~DOWNSHIFT_EN) >> DOWNSHIFT_CNTL_POS) + 2;
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
 
-out_unlock:
-	mutex_unlock(&phydev->lock);
-
+out:
 	return rc;
 }
 
@@ -150,23 +147,20 @@ static int vsc85xx_downshift_set(struct phy_device *phydev, u8 count)
 		count = (((count - 2) << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
 	}
 
-	mutex_lock(&phydev->lock);
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
 	if (rc != 0)
-		goto out_unlock;
+		goto out;
 
 	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
 	reg_val &= ~(DOWNSHIFT_CNTL_MASK);
 	reg_val |= count;
 	rc = phy_write(phydev, MSCC_PHY_ACTIPHY_CNTL, reg_val);
 	if (rc != 0)
-		goto out_unlock;
+		goto out;
 
 	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
 
-out_unlock:
-	mutex_unlock(&phydev->lock);
-
+out:
 	return rc;
 }
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index e9b4556751ff..0adb3bec5b5a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2466,7 +2466,9 @@ static int get_phy_tunable(struct net_device *dev, void __user *useraddr)
 	data = kmalloc(tuna.len, GFP_USER);
 	if (!data)
 		return -ENOMEM;
+	mutex_lock(&phydev->lock);
 	ret = phydev->drv->get_tunable(phydev, &tuna, data);
+	mutex_unlock(&phydev->lock);
 	if (ret)
 		goto out;
 	useraddr += sizeof(tuna);
@@ -2501,7 +2503,9 @@ static int set_phy_tunable(struct net_device *dev, void __user *useraddr)
 	ret = -EFAULT;
 	if (copy_from_user(data, useraddr, tuna.len))
 		goto out;
+	mutex_lock(&phydev->lock);
 	ret = phydev->drv->set_tunable(phydev, &tuna, data);
+	mutex_unlock(&phydev->lock);
 
 out:
 	kfree(data);
-- 
2.9.3
