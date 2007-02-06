From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [Ipw2100-devel] [RFC] Runtime power management on ipw2100
Date: Tue, 6 Feb 2007 21:44:08 +0000
Message-ID: <20070206214407.GA5254@srcf.ucam.org>
References: <20070131075249.GA22115@srcf.ucam.org> <1170294425.6601.182.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pm@lists.osdl.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:39973 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933300AbXBFVo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 16:44:29 -0500
Content-Disposition: inline
In-Reply-To: <1170294425.6601.182.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 01, 2007 at 09:47:05AM +0800, Zhu Yi wrote:
> On Wed, 2007-01-31 at 07:52 +0000, Matthew Garrett wrote:

> >From my understanding, the intention of this patch is to defer the
> device self-initialization work (including firmware loading) from netdev
> initialization time to netdev open time (ifconfig up) and de-initialize
> the device when it is not being used (ifconfig down). This saves power
> during the time the driver is loaded but the interface is not open.

That's correct.

> You should remove ipw2100_up() from ipw2100_net_init() which is
> netdev->init() since it will be called in ->open() in your patch. I'd
> also suggest you to request_irq()/free_irq() in the netdev ->open() and
> ->close() in case the device shares IRQ with other devices, the
> interrupt handler should not be invoked anyway.

I've removed net_init() entirely, since all it did was call 
ipw2100_up(). I'm reluctant to drop the IRQ because PCMCIA seems to have 
a nasty habit of grabbing free looking IRQs and setting them to be edge 
triggered, which would obviously be bad.

How's this patch?

Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 24ef52a..679946e 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1809,13 +1809,6 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 	return rc;
 }
 
-/* Called by register_netdev() */
-static int ipw2100_net_init(struct net_device *dev)
-{
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	return ipw2100_up(priv, 1);
-}
-
 static void ipw2100_down(struct ipw2100_priv *priv)
 {
 	unsigned long flags;
@@ -5771,8 +5764,38 @@ static int ipw2100_open(struct net_device *dev)
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
+		mutex_unlock(&priv->action_mutex);
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
+		mutex_unlock(&priv->action_mutex);
+		return err;
+        } 
+
 	spin_lock_irqsave(&priv->low_lock, flags);
 	if (priv->status & STATUS_ASSOCIATED) {
 		netif_carrier_on(dev);
@@ -5780,6 +5803,8 @@ static int ipw2100_open(struct net_device *dev)
 	}
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 
+	mutex_unlock(&priv->action_mutex);
+
 	return 0;
 }
 
@@ -5814,6 +5839,19 @@ static int ipw2100_close(struct net_device *dev)
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
@@ -6021,7 +6059,6 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 
 	dev->open = ipw2100_open;
 	dev->stop = ipw2100_close;
-	dev->init = ipw2100_net_init;
 	dev->ethtool_ops = &ipw2100_ethtool_ops;
 	dev->tx_timeout = ipw2100_tx_timeout;
 	dev->wireless_handlers = &ipw2100_wx_handler_def;
@@ -6208,6 +6245,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
 
 	pci_set_power_state(pci_dev, PCI_D0);
+	pci_save_state(pci_dev);
 
 	if (!ipw2100_hw_is_adapter_in_system(dev)) {
 		printk(KERN_WARNING DRV_NAME
@@ -6274,23 +6312,9 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
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
+	ipw2100_down(priv);
+	pci_disable_device(pci_dev);
+	pci_set_power_state(pci_dev, PCI_D3hot);	  
 
 	IPW_DEBUG_INFO("exit\n");
 
@@ -6353,8 +6377,6 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		if (ipw2100_firmware.version)
 			ipw2100_release_firmware(priv, &ipw2100_firmware);
 #endif
-		/* Take down the hardware */
-		ipw2100_down(priv);
 
 		/* Release the mutex so that the network subsystem can
 		 * complete any needed calls into the driver... */
@@ -6384,7 +6406,6 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 	}
 
 	pci_release_regions(pci_dev);
-	pci_disable_device(pci_dev);
 
 	IPW_DEBUG_INFO("exit\n");
 }
@@ -6398,7 +6419,7 @@ static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	IPW_DEBUG_INFO("%s: Going into suspend...\n", dev->name);
 
 	mutex_lock(&priv->action_mutex);
-	if (priv->status & STATUS_INITIALIZED) {
+	if (priv->status & STATUS_INITIALIZED && dev->flags & IFF_UP) {
 		/* Take down the device; powers it off, etc. */
 		ipw2100_down(priv);
 	}
@@ -6406,9 +6427,11 @@ static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
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
 
@@ -6453,9 +6476,13 @@ static int ipw2100_resume(struct pci_dev *pci_dev)
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
