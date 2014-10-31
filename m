From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: ethtool: Return -EOPNOTSUPP if user space tries to read EEPROM with lengh 0
Date: Thu, 30 Oct 2014 20:50:15 -0700
Message-ID: <1414727415-5470-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:42293 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbaJaDuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 23:50:21 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Xk3EC-001Dgk-84
	for netdev@vger.kernel.org; Fri, 31 Oct 2014 03:50:20 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a driver supports reading EEPROM but no EEPROM is installed in the system,
the driver's get_eeprom_len function returns 0. ethtool will subsequently
try to read that zero-length EEPROM anyway. If the driver does not support
EEPROM access at all, this operation will return -EOPNOTSUPP. If the driver
does support EEPROM access but no EEPROM is installed, the operation will
return -EINVAL. Return -EOPNOTSUPP in both cases for consistency.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/core/ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1600aa2..06dfb29 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1036,7 +1036,8 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 
-	if (!ops->get_eeprom || !ops->get_eeprom_len)
+	if (!ops->get_eeprom || !ops->get_eeprom_len ||
+	    !ops->get_eeprom_len(dev))
 		return -EOPNOTSUPP;
 
 	return ethtool_get_any_eeprom(dev, useraddr, ops->get_eeprom,
@@ -1052,7 +1053,8 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	u8 *data;
 	int ret = 0;
 
-	if (!ops->set_eeprom || !ops->get_eeprom_len)
+	if (!ops->set_eeprom || !ops->get_eeprom_len ||
+	    !ops->get_eeprom_len(dev))
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
-- 
1.9.1
