From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 17:45:25 +0100
Message-ID: <1213807525.26255.1331.camel@pmac.infradead.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	 <4856CE43.4020706@garzik.org>
	 <1213652749.26255.842.camel@pmac.infradead.org>
	 <4856E50C.5050908@garzik.org>
	 <1213699220.26255.977.camel@pmac.infradead.org>
	 <1213805681.26255.1312.camel@pmac.infradead.org>
	 <4859371F.8090404@garzik.org>
	 <1213807439.26255.1327.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45984 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbYFRQp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:45:28 -0400
In-Reply-To: <1213807439.26255.1327.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 17:44 +0100, David Woodhouse wrote:
> In the patch I just
> sent, you can see exactly what's changing. Now, just for fun, let's
> try
> splitting it into two pointlessly separate patches as you seem to
> want.
> 
> First we add the 'new' code path...

... and then we remove the old...

For this pair of patches to be sanely reviewable, you need to combine
them into one and see what _actually_ changed. And that's why I've
posted it like that.

--- drivers/net/acenic.c	2008-06-18 17:40:10.000000000 +0100
+++ drivers/net/acenic.c	2008-06-18 17:17:51.000000000 +0100
@@ -2873,40 +2873,7 @@ static struct net_device_stats *ace_get_
 }
 
 
-static void __devinit ace_copy(struct ace_regs __iomem *regs, void *src,
-			    u32 dest, int size)
-{
-	void __iomem *tdest;
-	u32 *wsrc;
-	short tsize, i;
-
-	if (size <= 0)
-		return;
-
-	while (size > 0) {
-		tsize = min_t(u32, ((~dest & (ACE_WINDOW_SIZE - 1)) + 1),
-			    min_t(u32, size, ACE_WINDOW_SIZE));
-		tdest = (void __iomem *) &regs->Window +
-			(dest & (ACE_WINDOW_SIZE - 1));
-		writel(dest & ~(ACE_WINDOW_SIZE - 1), &regs->WinBase);
-		/*
-		 * This requires byte swapping on big endian, however
-		 * writel does that for us
-		 */
-		wsrc = src;
-		for (i = 0; i < (tsize / 4); i++) {
-			writel(wsrc[i], tdest + i*4);
-		}
-		dest += tsize;
-		src += tsize;
-		size -= tsize;
-	}
-
-	return;
-}
-
-
-static void __devinit ace_copy_be(struct ace_regs __iomem *regs, const __be32 *src,
+static void __devinit ace_copy(struct ace_regs __iomem *regs, const __be32 *src,
 			       u32 dest, int size)
 {
 	void __iomem *tdest;
@@ -2959,49 +2926,13 @@ static void __devinit ace_clear(struct a
 	return;
 }
 
+
 /*
  * Download the firmware into the SRAM on the NIC
  *
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-static int __devinit ace_load_static_firmware(struct net_device *dev)
-{
-	struct ace_private *ap = netdev_priv(dev);
-	struct ace_regs __iomem *regs = ap->regs;
-
-	/*
-	 * Do not try to clear more than 512KB or we end up seeing
-	 * funny things on NICs with only 512KB SRAM
-	 */
-	ace_clear(regs, 0x2000, 0x80000-0x2000);
-	if (ACE_IS_TIGON_I(ap)) {
-		ap->firmware_major = tigonFwReleaseMajor;
-		ap->firmware_minor = tigonFwReleaseMinor;
-		ap->firmware_fix = tigonFwReleaseFix;
-		ap->firmware_start = tigonFwStartAddr;
-		ace_copy(regs, tigonFwText, tigonFwTextAddr, tigonFwTextLen);
-		ace_copy(regs, tigonFwData, tigonFwDataAddr, tigonFwDataLen);
-		ace_copy(regs, tigonFwRodata, tigonFwRodataAddr,
-			 tigonFwRodataLen);
-		ace_clear(regs, tigonFwBssAddr, tigonFwBssLen);
-		ace_clear(regs, tigonFwSbssAddr, tigonFwSbssLen);
-	}else if (ap->version == 2) {
-		ap->firmware_major = tigon2FwReleaseMajor;
-		ap->firmware_minor = tigon2FwReleaseMinor;
-		ap->firmware_fix = tigon2FwReleaseFix;
-		ap->firmware_start = tigon2FwStartAddr;
-		ace_clear(regs, tigon2FwBssAddr, tigon2FwBssLen);
-		ace_clear(regs, tigon2FwSbssAddr, tigon2FwSbssLen);
-		ace_copy(regs, tigon2FwText, tigon2FwTextAddr,tigon2FwTextLen);
-		ace_copy(regs, tigon2FwRodata, tigon2FwRodataAddr,
-			 tigon2FwRodataLen);
-		ace_copy(regs, tigon2FwData, tigon2FwDataAddr,tigon2FwDataLen);
-	}
-
-	return 0;
-}
-
 static int __devinit ace_load_firmware(struct net_device *dev)
 {
 	const struct firmware *fw;
@@ -3025,7 +2956,7 @@ static int __devinit ace_load_firmware(s
 	if (ret) {
 		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
 		       ap->name, fw_name);
-		return ace_load_static_firmware(dev);
+		return ret;
 	}
 
 	fw_data = (void *)fw->data;
@@ -3060,7 +2991,7 @@ static int __devinit ace_load_firmware(s
 	 * funny things on NICs with only 512KiB SRAM
 	 */
 	ace_clear(regs, 0x2000, 0x80000-0x2000);
-	ace_copy_be(regs, &fw_data[3], load_addr, fw->size-12);
+	ace_copy(regs, &fw_data[3], load_addr, fw->size-12);
  out:
 	release_firmware(fw);
 	return ret;

-- 
dwmw2

