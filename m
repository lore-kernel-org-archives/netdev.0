From: Mandeep Singh Baines <msb@google.com>
Subject: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Mon, 14 Apr 2008 11:03:38 -0700
Message-ID: <20080414180338.GA18335@google.com>
References: <48007CA0.6030002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nil@google.com, thockin@google.com,
	matthew@wil.cx
To: netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:56178 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759264AbYDNSEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 14:04:36 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m3EI4Pqe006449
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 19:04:25 +0100
Received: from yw-out-1718.google.com (ywk9.prod.google.com [10.192.11.9])
	by zps75.corp.google.com with ESMTP id m3EI3nxQ032499
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 11:04:24 -0700
Received: by yw-out-1718.google.com with SMTP id 9so683555ywk.6
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 11:04:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48007CA0.6030002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it is not possible to read/write to an eeprom larger than
128k in size because the buffer used for temporarily storing the
eeprom contents is allocated using kmalloc. kmalloc can only allocate
a maximum of 128k depending on architecture.

Modified ethtool_get/set_eeprom to only allocate a page of memory and
then copy the eeprom a page at a time.

Updated original patch as per suggestions from Joe Perches.

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 net/core/ethtool.c |   64 +++++++++++++++++++++++++++++----------------------
 1 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1163eb2..a29b43d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -284,8 +284,10 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	void __user *userbuf = useraddr + sizeof(eeprom);
+	u32 bytes_remaining;
 	u8 *data;
-	int ret;
+	int ret = 0;
 
 	if (!ops->get_eeprom || !ops->get_eeprom_len)
 		return -EOPNOTSUPP;
@@ -301,26 +303,26 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
 		return -EINVAL;
 
-	data = kmalloc(eeprom.len, GFP_USER);
+	data = kmalloc(PAGE_SIZE, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
-	ret = -EFAULT;
-	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
-		goto out;
-
-	ret = ops->get_eeprom(dev, &eeprom, data);
-	if (ret)
-		goto out;
+	bytes_remaining = eeprom.len;
+	while (bytes_remaining > 0) {
+		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
 
-	ret = -EFAULT;
-	if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
-		goto out;
-	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
-		goto out;
-	ret = 0;
+		ret = ops->get_eeprom(dev, &eeprom, data);
+		if (ret)
+			break;
+		if (copy_to_user(userbuf, data, eeprom.len)) {
+			ret = -EFAULT;
+			break;
+		}
+		userbuf += eeprom.len;
+		eeprom.offset += eeprom.len;
+		bytes_remaining -= eeprom.len;
+	}
 
- out:
 	kfree(data);
 	return ret;
 }
@@ -329,8 +331,10 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	void __user *userbuf = useraddr + sizeof(eeprom);
+	u32 bytes_remaining;
 	u8 *data;
-	int ret;
+	int ret = 0;
 
 	if (!ops->set_eeprom || !ops->get_eeprom_len)
 		return -EOPNOTSUPP;
@@ -346,22 +350,26 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
 		return -EINVAL;
 
-	data = kmalloc(eeprom.len, GFP_USER);
+	data = kmalloc(PAGE_SIZE, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
-	ret = -EFAULT;
-	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
-		goto out;
-
-	ret = ops->set_eeprom(dev, &eeprom, data);
-	if (ret)
-		goto out;
+	bytes_remaining = eeprom.len;
+	while (bytes_remaining > 0) {
+		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
 
-	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
-		ret = -EFAULT;
+		if (copy_from_user(data, userbuf, eeprom.len)) {
+			ret = -EFAULT;
+			break;
+		}
+		ret = ops->set_eeprom(dev, &eeprom, data);
+		if (ret)
+			break;
+		userbuf += eeprom.len;
+		eeprom.offset += eeprom.len;
+		bytes_remaining -= eeprom.len;
+	}
 
- out:
 	kfree(data);
 	return ret;
 }
-- 
1.5.2.5

