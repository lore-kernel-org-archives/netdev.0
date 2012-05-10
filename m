From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/8] ethtool: Split ethtool_get_eeprom() to allow
 for additional EEPROM accessors
Date: Thu, 10 May 2012 03:30:52 +0100
Message-ID: <1336617052.2499.38.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51893 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751668Ab2EJCaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:30:55 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to support reading module (SFP+, XFP, ...) EEPROMs as well as
NIC EEPROMs.  They will need a different command number and driver
operation, but the structure and arguments will be the same and so we
can share most of the code here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/ethtool.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index beacdd9..ca7698f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -751,18 +751,17 @@ static int ethtool_get_link(struct net_device *dev, char __user *useraddr)
 	return 0;
 }
 
-static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
+static int ethtool_get_any_eeprom(struct net_device *dev, void __user *useraddr,
+				  int (*getter)(struct net_device *,
+						struct ethtool_eeprom *, u8 *),
+				  u32 total_len)
 {
 	struct ethtool_eeprom eeprom;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
 	void __user *userbuf = useraddr + sizeof(eeprom);
 	u32 bytes_remaining;
 	u8 *data;
 	int ret = 0;
 
-	if (!ops->get_eeprom || !ops->get_eeprom_len)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
 		return -EFAULT;
 
@@ -771,7 +770,7 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 		return -EINVAL;
 
 	/* Check for exceeding total eeprom len */
-	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
+	if (eeprom.offset + eeprom.len > total_len)
 		return -EINVAL;
 
 	data = kmalloc(PAGE_SIZE, GFP_USER);
@@ -782,7 +781,7 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 	while (bytes_remaining > 0) {
 		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
 
-		ret = ops->get_eeprom(dev, &eeprom, data);
+		ret = getter(dev, &eeprom, data);
 		if (ret)
 			break;
 		if (copy_to_user(userbuf, data, eeprom.len)) {
@@ -803,6 +802,17 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
+static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (!ops->get_eeprom || !ops->get_eeprom_len)
+		return -EOPNOTSUPP;
+
+	return ethtool_get_any_eeprom(dev, useraddr, ops->get_eeprom,
+				      ops->get_eeprom_len(dev));
+}
+
 static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
