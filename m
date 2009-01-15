From: Oliver Neukum <oliver@neukum.org>
Subject: Re: Buffer allocation for USB transfers
Date: Thu, 15 Jan 2009 16:43:49 +0100
Message-ID: <200901151643.50635.oliver@neukum.org>
References: <496E43F4.24792.158F9B@ceggers.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: "Christian Eggers" <ceggers@gmx.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:34451 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbZAOPnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 10:43:13 -0500
In-Reply-To: <496E43F4.24792.158F9B@ceggers.gmx.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Wednesday 14 January 2009 19:58:44 schrieb Christian Eggers:
> At least the latter does not work on my SH-4 platform. It seems that other 
> variables on the stack are overwritten after calling usb_control_msg(), probably as 
> result of incorrect alignment.

Does this make it run on SH-4?

	Regards
		Oliver

---

--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -181,12 +181,17 @@ static int mcs7830_read_phy(struct usbnet *dev, u8 index)
 {
 	int ret;
 	int i;
-	__le16 val;
-
-	u8 cmd[2] = {
-		HIF_REG_PHY_CMD1_READ | HIF_REG_PHY_CMD1_PHYADDR,
-		HIF_REG_PHY_CMD2_PEND_FLAG_BIT | index,
-	};
+	__le16 *val;
+	u8 *cmd;
+
+	cmd = kmalloc(2, GFP_NOIO);
+	if (!cmd)
+		return -ENOMEM;
+	cmd[0] = HIF_REG_PHY_CMD1_READ | HIF_REG_PHY_CMD1_PHYADDR;
+	cmd[1] = HIF_REG_PHY_CMD2_PEND_FLAG_BIT | index;
+	val = kzalloc(sizeof(__le16), GFP_NOIO);
+	if (!val)
+		goto out2;
 
 	mutex_lock(&dev->phy_mutex);
 	/* write the MII command */
@@ -206,7 +211,7 @@ static int mcs7830_read_phy(struct usbnet *dev, u8 index)
 		goto out;
 
 	/* read actual register contents */
-	ret = mcs7830_get_reg(dev, HIF_REG_PHY_DATA, 2, &val);
+	ret = mcs7830_get_reg(dev, HIF_REG_PHY_DATA, 2, val);
 	if (ret < 0)
 		goto out;
 	ret = le16_to_cpu(val);
@@ -214,6 +219,9 @@ static int mcs7830_read_phy(struct usbnet *dev, u8 index)
 		index, val, i);
 out:
 	mutex_unlock(&dev->phy_mutex);
+	kfree(val);
+out2:
+	kfree(cmd);
 	return ret;
 }
 
@@ -221,18 +229,24 @@ static int mcs7830_write_phy(struct usbnet *dev, u8 index, u16 val)
 {
 	int ret;
 	int i;
-	__le16 le_val;
+	__le16 *le_val;
+	u8 *cmd;
+
+	cmd = kmalloc(2, GFP_NOIO);
+	if (!cmd)
+		return -ENOMEM;
+	cmd[0] = HIF_REG_PHY_CMD1_WRITE | HIF_REG_PHY_CMD1_PHYADDR;
+	cmd[1] = HIF_REG_PHY_CMD2_PEND_FLAG_BIT | (index & 0x1F);
 
-	u8 cmd[2] = {
-		HIF_REG_PHY_CMD1_WRITE | HIF_REG_PHY_CMD1_PHYADDR,
-		HIF_REG_PHY_CMD2_PEND_FLAG_BIT | (index & 0x1F),
-	};
+	le_val = kmalloc(sizeof(__le16), GFP_NOIO);
+	if (!le_val)
+		goto out2;
 
 	mutex_lock(&dev->phy_mutex);
 
 	/* write the new register contents */
 	le_val = cpu_to_le16(val);
-	ret = mcs7830_set_reg(dev, HIF_REG_PHY_DATA, 2, &le_val);
+	ret = mcs7830_set_reg(dev, HIF_REG_PHY_DATA, 2, le_val);
 	if (ret < 0)
 		goto out;
 
@@ -257,6 +271,9 @@ static int mcs7830_write_phy(struct usbnet *dev, u8 index, u16 val)
 		index, val, i);
 out:
 	mutex_unlock(&dev->phy_mutex);
+	kfree(le_val);
+out2:
+	kfree(cmd);
 	return ret;
 }
 
@@ -289,9 +306,14 @@ static int mcs7830_set_autoneg(struct usbnet *dev, int ptrUserPhyMode)
  */
 static int mcs7830_get_rev(struct usbnet *dev)
 {
-	u8 dummy[2];
+	u8 *dummy;
 	int ret;
+
+	dummy = kmalloc(2, GFP_NOIO);
+	if (!dummy)
+		return 1;
 	ret = mcs7830_get_reg(dev, HIF_REG_22, 2, dummy);
+	kfree(dummy);
 	if (ret > 0)
 		return 2; /* Rev C or later */
 	return 1; /* earlier revision */
@@ -302,17 +324,22 @@ static int mcs7830_get_rev(struct usbnet *dev)
  */
 static void mcs7830_rev_C_fixup(struct usbnet *dev)
 {
-	u8 pause_threshold = HIF_REG_PAUSE_THRESHOLD_DEFAULT;
+	u8 *pause_threshold;
 	int retry;
 
+	pause_threshold = kmalloc(sizeof(u8), GFP_NOIO);
+	if (!pause_threshold)
+		return;
+	*pause_threshold = HIF_REG_PAUSE_THRESHOLD_DEFAULT;
 	for (retry = 0; retry < 2; retry++) {
 		if (mcs7830_get_rev(dev) == 2) {
 			dev_info(&dev->udev->dev, "applying rev.C fixup\n");
 			mcs7830_set_reg(dev, HIF_REG_PAUSE_THRESHOLD,
-					1, &pause_threshold);
+					1, pause_threshold);
 		}
 		msleep(1);
 	}
+	kfree(pause_threshold);
 }
 
 static int mcs7830_init_dev(struct usbnet *dev)
