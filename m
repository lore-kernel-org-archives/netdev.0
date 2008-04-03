From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 3 Apr 2008 11:00:21 -0700
Message-ID: <20080403180021.GA5974@google.com>
References: <1207195123.23161.291.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nil@google.com, thockin@google.com
To: netdev@vger.kernel.org, jeff@garzik.org, matthew@wil.cx,
	davem@davemloft.net, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:43195 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931AbYDCSAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 14:00:53 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m33I0h0v019966
	for <netdev@vger.kernel.org>; Thu, 3 Apr 2008 19:00:44 +0100
Received: from gv-out-0910.google.com (gveo2.prod.google.com [10.16.166.2])
	by zps77.corp.google.com with ESMTP id m33I0PC5030593
	for <netdev@vger.kernel.org>; Thu, 3 Apr 2008 11:00:42 -0700
Received: by gv-out-0910.google.com with SMTP id o2so694577gve.3
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2008 11:00:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1207195123.23161.291.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Joe,

Fixed and updated patch. Please take another look.

Regards,
Mandeep

Joe Perches (joe@perches.com) wrote:
> On Wed, 2008-04-02 at 19:12 -0700, Mandeep Singh Baines wrote:
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 1163eb2..54f1004 100644
> 
> please run scripts/checkpatch.pl
> 

Fixed

> > @@ -329,8 +330,10 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
> >  {
> >  	struct ethtool_eeprom eeprom;
> >  	const struct ethtool_ops *ops = dev->ethtool_ops;
> > +	void __user *userbuf = useraddr + sizeof(eeprom);
> > +	u32 bytes_remaining;
> >  	u8 *data;
> > -	int ret;
> > +	int ret = 0;
> 
> You don't need to initialize this.
> 

Fixed

---
Currently, it is not possible to read/write to an eeprom larger than
128k in size because the buffer used for temporarily storing the
eeprom contents is allocated using kmalloc. kmalloc can only allocate
a maximum of 128k depending on architecture.

Modified ethtool_get/set_eeprom to only allocate a page of memory and
then copy the eeprom a page at a time.

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 net/core/ethtool.c |   57 +++++++++++++++++++++++++++++----------------------
 1 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1163eb2..45d5f35 100644
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
+		ret = ops->get_eeprom(dev, &eeprom, data)
+		if (ret)
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
@@ -329,6 +331,8 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
+	void __user *userbuf = useraddr + sizeof(eeprom);
+	u32 bytes_remaining;
 	u8 *data;
 	int ret;
 
@@ -346,22 +350,25 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
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
 		ret = -EFAULT;
+		if (copy_from_user(data, userbuf, eeprom.len))
+			break;
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

