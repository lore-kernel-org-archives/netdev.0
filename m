From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix warnings on calls to P54P_READ() for which the result is
	discarded
Date: Fri, 11 Jul 2008 15:14:43 +0100
Message-ID: <20080711141443.14665.63279.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: flamingice@sourmilk.net, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbYGKOPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 10:15:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warnings on calls to P54P_READ() for which the result is discarded because
the side-effect of accessing hardware is what's of interest, not the result of
performing the read.

The warnings are of the form:

drivers/net/wireless/p54/p54pci.c:55: warning: value computed is not used

Casting to (void) gets rid of this.

They were introduced in patch eff1a59c48e3c6a006eb4fe5f2e405a996f2259d.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/wireless/p54/p54pci.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)


diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 7dd4add..47a3654 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -52,14 +52,14 @@ static int p54p_upload_firmware(struct ieee80211_hw *dev)
 	u32 remains, left, device_addr;
 
 	P54P_WRITE(int_enable, cpu_to_le32(0));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	udelay(10);
 
 	reg = P54P_READ(ctrl_stat);
 	reg &= cpu_to_le32(~ISL38XX_CTRL_STAT_RESET);
 	reg &= cpu_to_le32(~ISL38XX_CTRL_STAT_RAMBOOT);
 	P54P_WRITE(ctrl_stat, reg);
-	P54P_READ(ctrl_stat);
+	(void) P54P_READ(ctrl_stat);
 	udelay(10);
 
 	reg |= cpu_to_le32(ISL38XX_CTRL_STAT_RESET);
@@ -89,7 +89,7 @@ static int p54p_upload_firmware(struct ieee80211_hw *dev)
 		u32 i = 0;
 		left = min((u32)0x1000, remains);
 		P54P_WRITE(direct_mem_base, cpu_to_le32(device_addr));
-		P54P_READ(int_enable);
+		(void) P54P_READ(int_enable);
 
 		device_addr += 0x1000;
 		while (i < left) {
@@ -98,7 +98,7 @@ static int p54p_upload_firmware(struct ieee80211_hw *dev)
 		}
 
 		remains -= left;
-		P54P_READ(int_enable);
+		(void) P54P_READ(int_enable);
 	}
 
 	release_firmware(fw_entry);
@@ -108,7 +108,7 @@ static int p54p_upload_firmware(struct ieee80211_hw *dev)
 	reg &= cpu_to_le32(~ISL38XX_CTRL_STAT_RESET);
 	reg |= cpu_to_le32(ISL38XX_CTRL_STAT_RAMBOOT);
 	P54P_WRITE(ctrl_stat, reg);
-	P54P_READ(ctrl_stat);
+	(void) P54P_READ(ctrl_stat);
 	udelay(10);
 
 	reg |= cpu_to_le32(ISL38XX_CTRL_STAT_RESET);
@@ -167,11 +167,11 @@ static int p54p_read_eeprom(struct ieee80211_hw *dev)
 
 	memset(ring_control, 0, sizeof(*ring_control));
 	P54P_WRITE(ring_control_base, cpu_to_le32(priv->ring_control_dma));
-	P54P_READ(ring_control_base);
+	(void) P54P_READ(ring_control_base);
 	udelay(10);
 
 	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_INIT));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	udelay(10);
 
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
@@ -184,7 +184,7 @@ static int p54p_read_eeprom(struct ieee80211_hw *dev)
 	}
 
 	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_UPDATE));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 
 	hdr = eeprom + 0x2010;
 	p54_fill_eeprom_readback(hdr);
@@ -230,7 +230,7 @@ static int p54p_read_eeprom(struct ieee80211_hw *dev)
  out:
 	kfree(eeprom);
 	P54P_WRITE(int_enable, cpu_to_le32(0));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	udelay(10);
 	free_irq(priv->pdev->irq, priv);
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
@@ -397,7 +397,7 @@ static void p54p_tx(struct ieee80211_hw *dev, struct p54_control_hdr *data,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_UPDATE));
-	P54P_READ(dev_int);
+	(void) P54P_READ(dev_int);
 
 	/* FIXME: unlikely to happen because the device usually runs out of
 	   memory before we fill the ring up, but we can make it impossible */
@@ -426,17 +426,17 @@ static int p54p_open(struct ieee80211_hw *dev)
 	p54p_upload_firmware(dev);
 
 	P54P_WRITE(ring_control_base, cpu_to_le32(priv->ring_control_dma));
-	P54P_READ(ring_control_base);
+	(void) P54P_READ(ring_control_base);
 	wmb();
 	udelay(10);
 
 	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_INIT));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	wmb();
 	udelay(10);
 
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
-	P54P_READ(dev_int);
+	(void) P54P_READ(dev_int);
 
 	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
 		printk(KERN_ERR "%s: Cannot boot firmware!\n",
@@ -446,12 +446,12 @@ static int p54p_open(struct ieee80211_hw *dev)
 	}
 
 	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_UPDATE));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	wmb();
 	udelay(10);
 
 	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_UPDATE));
-	P54P_READ(dev_int);
+	(void) P54P_READ(dev_int);
 	wmb();
 	udelay(10);
 
@@ -466,7 +466,7 @@ static void p54p_stop(struct ieee80211_hw *dev)
 	struct p54p_desc *desc;
 
 	P54P_WRITE(int_enable, cpu_to_le32(0));
-	P54P_READ(int_enable);
+	(void) P54P_READ(int_enable);
 	udelay(10);
 
 	free_irq(priv->pdev->irq, dev);

