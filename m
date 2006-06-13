From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: suspend / resume fix
Date: Tue, 13 Jun 2006 13:45:52 +0900
Message-ID: <20060613134552.331377c3@localhost.localdomain>
References: <Pine.LNX.4.64.0606102234110.5498@g5.osdl.org>
	<448C0F04.9070406@osdl.org>
	<Pine.LNX.4.64.0606121032430.5498@g5.osdl.org>
	<Pine.LNX.4.64.0606121107460.5498@g5.osdl.org>
	<Pine.LNX.4.64.0606121117550.5498@g5.osdl.org>
	<20060612222740.GB5783@shell0.pdx.osdl.net>
	<Pine.LNX.4.64.0606121537420.5498@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60592 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932878AbWFMEqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 00:46:20 -0400
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606121537420.5498@g5.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The resume bug was cause not by an early interrupt but because
the idle timeout was not being stopped on suspend. Also disable hardware
IRQ's on suspend. Will need to revisit this when wake-on-lan is added.

Patch against 2.6.17-rc latest which includes Linus's attempt at
fixing this.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -2164,6 +2164,13 @@ static void sky2_descriptor_error(struct
 /* If idle then force a fake soft NAPI poll once a second
  * to work around cases where sharing an edge triggered interrupt.
  */
+static inline void sky2_idle_start(struct sky2_hw *hw)
+{
+	if (idle_timeout > 0)
+		mod_timer(&hw->idle_timer,
+			  jiffies + msecs_to_jiffies(idle_timeout));
+}
+
 static void sky2_idle(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
@@ -2183,9 +2190,6 @@ static int sky2_poll(struct net_device *
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
-	if (!~status)
-		return 0;
-
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
@@ -3353,9 +3357,7 @@ static int __devinit sky2_probe(struct p
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
-	if (idle_timeout > 0)
-		mod_timer(&hw->idle_timer,
-			  jiffies + msecs_to_jiffies(idle_timeout));
+	sky2_idle_start(hw);
 
 	pci_set_drvdata(pdev, hw);
 
@@ -3427,9 +3429,14 @@ static void __devexit sky2_remove(struct
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i;
+	int i, err;
+	u32 imask;
+
+	pci_save_state(pdev);
 
-	for (i = 0; i < 2; i++) {
+	del_timer_sync(&hw->idle_timer);
+
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
 		if (dev) {
@@ -3441,8 +3448,17 @@ static int sky2_suspend(struct pci_dev *
 		}
 	}
 
-	pci_save_state(pdev);
-	return sky2_set_power_state(hw, pci_choose_state(pdev, state));
+	imask = sky2_read32(hw, B0_IMSK);
+	sky2_write32(hw, B0_IMSK, 0);
+	synchronize_irq(hw->pdev->irq);
+
+	err = sky2_set_power_state(hw, pci_choose_state(pdev, state));
+	if (err) {
+		sky2_write32(hw, B0_IMSK, imask);
+		sky2_idle_start(hw);
+	}
+
+	return err;
 }
 
 static int sky2_resume(struct pci_dev *pdev)
@@ -3460,7 +3476,7 @@ static int sky2_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		if (dev && netif_running(dev)) {
 			netif_device_attach(dev);
@@ -3473,7 +3489,10 @@ static int sky2_resume(struct pci_dev *p
 			}
 		}
 	}
-out:
+
+	sky2_idle_start(hw);
+
+ out:
 	return err;
 }
 #endif
