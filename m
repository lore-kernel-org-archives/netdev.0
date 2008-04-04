From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 03 Apr 2008 17:03:37 -0700
Message-ID: <1207267417.23161.353.camel@localhost>
References: <20080403180021.GA5974@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, matthew@wil.cx,
	davem@davemloft.net, nil@google.com, thockin@google.com
To: Mandeep Singh Baines <msb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2582 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbYDDAEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 20:04:06 -0400
In-Reply-To: <20080403180021.GA5974@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-04-03 at 11:00 -0700, Mandeep Singh Baines wrote:
> Fixed and updated patch. Please take another look.
Hi Mandeep,

This looks better.
There's a typo at line 315 though, it needs a ";".

I was also wrong that int ret _does_ need to be
initialized to 0 in case (eeprom.len == 0)

I think this should be written as below:

cheers, Joe

 net/core/ethtool.c |   68 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 30 deletions(-)

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


