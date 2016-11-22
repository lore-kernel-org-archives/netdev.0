From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] ethtool: Protect {get,set}_phy_tunable with PHY device mutex
Date: Tue, 22 Nov 2016 12:13:16 -0800
Message-ID: <20161122201316.10830-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35197 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754238AbcKVUNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 15:13:22 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so1926573pfk.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 12:13:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY drivers should be able to rely on the caller of {get,set}_tunable to
have acquired the PHY device mutex, in order to both serialize against
concurrent calls of these functions, but also against PHY state machine
changes. All ethtool PHY-level functions do this, except
{get,set}_tunable, so we make them consistent here as well.

Fixes: 968ad9da7e0e ("ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/core/ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

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
