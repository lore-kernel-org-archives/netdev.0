From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: [RFC] Runtime power management on ipw2100
Date: Wed, 31 Jan 2007 07:52:49 +0000
Message-ID: <20070131075249.GA22115@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pm@lists.osdl.org
Return-path: <ipw2100-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw2100-devel-bounces@lists.sourceforge.net
Errors-To: ipw2100-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Based on previous discussions, I've implemented a rough attempt at 
providing some level of basic runtime power management on the ipw2100 
chipset. This patch does the following:

1) On load, it initialises the hardware and then quiesces it again
2) On interface up, it powers the hardware back up
3) On interface down, it powers the hardware down and puts the chip in 
D3
4) It attempts to behave correctly over suspend/resume - ie, if the 
interface was down beforehand, it will ensure that the chip is powered 
down

The degree of bouncing between power states is probably unnecessary, but 
I don't have access to any docs so I've just gone for the most 
conservative approach that still seems to work. It's also possible that 
kill-switch handling isn't quite right - my machine doesn't have a 
working kill switch, so I haven't been able to test that.

Anyway, does this approach look broadly correct to people? If so, I'll 
look into doing something similar for the other hardware I have access 
to.

The situation is slightly more complicated for wired interfaces. As 
previously discussed, we potentially want three interface states (on, 
low power, off) with the intermediate one powering down as much of the 
hardware as possible while still implementing link detection. Is there 
an existing state flag that can be appropriated for this?

---

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 24ef52a..0e3c7e8 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -5771,8 +5771,36 @@ static int ipw2100_open(struct net_device *dev)
 {
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 	unsigned long flags;
+	int err, val;
 	IPW_DEBUG_INFO("dev->open\n");
 
+	mutex_lock(&priv->action_mutex);
+
+	pci_set_power_state(priv->pci_dev, PCI_D0);
+	err = pci_enable_device (priv->pci_dev);
+
+	if (err) {
+	        printk(KERN_WARNING DRV_NAME
+		       "Error calling pci_enable_device.\n");
+		return err;
+        }
+
+	pci_restore_state(priv->pci_dev);
+
+	pci_read_config_dword(priv->pci_dev, 0x40, &val);
+	if ((val & 0x0000ff00) != 0)
+		pci_write_config_dword(priv->pci_dev, 0x40, val & 0xffff00ff);
+
+	err = ipw2100_up(priv, 0);
+
+	if (err) {
+	        printk(KERN_WARNING DRV_NAME
+		       " Error bringing card up.\n");
+		pci_disable_device(priv->pci_dev);
+		pci_set_power_state(priv->pci_dev, PCI_D3hot);		
+		return err;
+        } 
+
 	spin_lock_irqsave(&priv->low_lock, flags);
 	if (priv->status & STATUS_ASSOCIATED) {
 		netif_carrier_on(dev);
@@ -5780,6 +5808,8 @@ static int ipw2100_open(struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 
+	mutex_unlock(&priv->action_mutex);
+
 	return 0;
 }
 
@@ -5814,6 +5844,19 @@ static int ipw2100_close(struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 
+	ipw2100_down(priv);
+
+#ifdef ACPI_CSTATE_LIMIT_DEFINED
+	if (priv->config & CFG_C3_DISABLED) {
+		IPW_DEBUG_INFO(": Resetting C3 transitions.\n");
+		acpi_set_cstate_limit(priv->cstate_limit);
+		priv->config &= ~CFG_C3_DISABLED;
+	}
+#endif
+
+	pci_disable_device(priv->pci_dev);
+	pci_set_power_state(priv->pci_dev, PCI_D3hot);
+
 	IPW_DEBUG_INFO("exit\n");
 
 	return 0;
@@ -6208,6 +6251,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
 
 	pci_set_power_state(pci_dev, PCI_D0);
+	pci_save_state(pci_dev);
 
 	if (!ipw2100_hw_is_adapter_in_system(dev)) {
 		printk(KERN_WARNING DRV_NAME
@@ -6274,23 +6318,8 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	if (err)
 		goto fail_unlock;
 
-	/* If the RF Kill switch is disabled, go ahead and complete the
-	 * startup sequence */
-	if (!(priv->status & STATUS_RF_KILL_MASK)) {
-		/* Enable the adapter - sends HOST_COMPLETE */
-		if (ipw2100_enable_adapter(priv)) {
-			printk(KERN_WARNING DRV_NAME
-			       ": %s: failed in call to enable adapter.\n",
-			       priv->net_dev->name);
-			ipw2100_hw_stop_adapter(priv);
-			err = -EIO;
-			goto fail_unlock;
-		}
-
-		/* Start a scan . . . */
-		ipw2100_set_scan_options(priv);
-		ipw2100_start_scan(priv);
-	}
+	pci_disable_device(pci_dev);
+	pci_set_power_state(pci_dev, PCI_D3hot);	  
 
 	IPW_DEBUG_INFO("exit\n");
 
@@ -6353,8 +6382,6 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		if (ipw2100_firmware.version)
 			ipw2100_release_firmware(priv, &ipw2100_firmware);
 #endif
-		/* Take down the hardware */
-		ipw2100_down(priv);
 
 		/* Release the mutex so that the network subsystem can
 		 * complete any needed calls into the driver... */
@@ -6384,7 +6411,6 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 	}
 
 	pci_release_regions(pci_dev);
-	pci_disable_device(pci_dev);
 
 	IPW_DEBUG_INFO("exit\n");
 }
@@ -6398,7 +6424,7 @@ static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	IPW_DEBUG_INFO("%s: Going into suspend...\n", dev->name);
 
 	mutex_lock(&priv->action_mutex);
-	if (priv->status & STATUS_INITIALIZED) {
+	if (priv->status & STATUS_INITIALIZED && dev->flags & IFF_UP) {
 		/* Take down the device; powers it off, etc. */
 		ipw2100_down(priv);
 	}
@@ -6406,9 +6432,11 @@ static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	/* Remove the PRESENT state of the device */
 	netif_device_detach(dev);
 
-	pci_save_state(pci_dev);
-	pci_disable_device(pci_dev);
-	pci_set_power_state(pci_dev, PCI_D3hot);
+	if (dev->flags & IFF_UP) {
+	        pci_save_state(pci_dev);
+		pci_disable_device(pci_dev);
+		pci_set_power_state(pci_dev, PCI_D3hot);
+	}
 
 	mutex_unlock(&priv->action_mutex);
 
@@ -6453,9 +6481,13 @@ static int ipw2100_resume(struct pci_dev *pci_dev)
 	netif_device_attach(dev);
 
 	/* Bring the device back up */
-	if (!(priv->status & STATUS_RF_KILL_SW))
+	if (!(priv->status & STATUS_RF_KILL_SW) && (dev->flags & IFF_UP))
 		ipw2100_up(priv, 0);
-
+	else {
+		pci_disable_device(pci_dev);
+		pci_set_power_state(pci_dev, PCI_D3hot);
+	}
+	  
 	mutex_unlock(&priv->action_mutex);
 
 	return 0;

-- 
Matthew Garrett | mjg59@srcf.ucam.org

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
