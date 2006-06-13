From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 5/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:31 +0900
Message-ID: <20060613081930.968244000@localhost.localdomain>
References: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18411 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750728AbWFMIUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:34 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-resume.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [RFT 5/5] sky2: stop/start hardware idle timer on suspend/resume

The resume bug was cause not by an early interrupt but because
the idle timeout was not being stopped on suspend. Also disable hardware
IRQ's on suspend. Will need to revisit this with hotplug?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -2161,6 +2161,13 @@ static void sky2_descriptor_error(struct
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
@@ -3350,9 +3357,7 @@ static int __devinit sky2_probe(struct p
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
-	if (idle_timeout > 0)
-		mod_timer(&hw->idle_timer,
-			  jiffies + msecs_to_jiffies(idle_timeout));
+	sky2_idle_start(hw);
 
 	pci_set_drvdata(pdev, hw);
 
@@ -3430,6 +3435,8 @@ static int sky2_suspend(struct pci_dev *
 	if (!(pstate == PCI_D3hot || pstate == PCI_D3cold))
 		return -EINVAL;
 
+	del_timer_sync(&hw->idle_timer);
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
@@ -3472,10 +3479,12 @@ static int sky2_resume(struct pci_dev *p
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
 				       dev->name, err);
 				dev_close(dev);
-				break;
+				goto out;
 			}
 		}
 	}
+
+	sky2_idle_start(hw);
 out:
 	return err;
 }

--

