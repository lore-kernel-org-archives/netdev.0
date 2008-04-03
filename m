From: Mandeep Singh Baines <msb@google.com>
Subject: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Wed, 2 Apr 2008 19:12:31 -0700
Message-ID: <20080403021230.GA22357@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nil@google.com, thockin@google.com
To: netdev@vger.kernel.org, jeff@garzik.org, matthew@wil.cx,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:21245 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760774AbYDCCM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 22:12:59 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m332CnxB031470
	for <netdev@vger.kernel.org>; Thu, 3 Apr 2008 03:12:49 +0100
Received: from wx-out-0506.google.com (wxdh29.prod.google.com [10.70.134.29])
	by zps78.corp.google.com with ESMTP id m332CmCP006557
	for <netdev@vger.kernel.org>; Wed, 2 Apr 2008 19:12:48 -0700
Received: by wx-out-0506.google.com with SMTP id h29so2896322wxd.27
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 19:12:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it is not possible to read/write to an eeprom larger than
128k in size because the buffer used for temporarily storing the
eeprom contents is allocated using kmalloc. kmalloc can only allocate
a maximum of 128k depending on architecture.

Modified ethtool_get/set_eeprom to only allocate a page of memory and
then copy the eeprom a page at a time.

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 net/core/ethtool.c |   57 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1163eb2..54f1004 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -284,6 +284,8 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	void __user *userbuf = useraddr + sizeof(eeprom);
+	u32 bytes_remaining;
 	u8 *data;
 	int ret;
 
@@ -301,26 +303,25 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
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
+		if ((ret = ops->get_eeprom(dev, &eeprom, data)))
+			break;
+		ret = -EFAULT;
+		if (copy_to_user(userbuf, data, eeprom.len))
+			break;
+		ret = 0;
+		userbuf += eeprom.len;
+		eeprom.offset += eeprom.len;
+		bytes_remaining -= eeprom.len;
+	}
 
- out:
 	kfree(data);
 	return ret;
 }
@@ -329,8 +330,10 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
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
@@ -346,22 +349,24 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
 		return -EINVAL;
 
-	data = kmalloc(eeprom.len, GFP_USER);
+	data = kmalloc(PAGE_SIZE, GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
-	ret = -EFAULT;
-	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
-		goto out;
+	bytes_remaining = eeprom.len;
+	while (bytes_remaining > 0) {
+		eeprom.len = min(bytes_remaining, (u32)PAGE_SIZE);
 
-	ret = ops->set_eeprom(dev, &eeprom, data);
-	if (ret)
-		goto out;
-
-	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
 		ret = -EFAULT;
+		if (copy_from_user(data, userbuf, eeprom.len))
+			break;
+		if ((ret = ops->set_eeprom(dev, &eeprom, data)))
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

