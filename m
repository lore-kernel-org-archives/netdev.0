From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull upstream branch of wireless-2.6
Date: Fri, 5 May 2006 21:09:07 -0400
Message-ID: <20060506010907.GB26189@tuxdriver.com>
References: <20060506010613.GA26189@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:8206 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750786AbWEFBJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 21:09:38 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060506010613.GA26189@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are patches intended for the next release (i.e. 2.6.18)...thanks!

---

The following changes since commit fd5226a72694d1c0abe1cc39711a86f1754e637d:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Adrian Bunk:
      ieee80211_wx.c: remove dead code

Daniel Drake:
      softmac: deauthentication implies deassociation
      softmac: suggest per-frame-type TX rate

Michal Schmidt:
      wireless/airo: minimal WPA awareness

Pavel Roskin:
      orinoco: unregister network device before releasing PCMCIA resources
      orinoco: report more relevant data on startup
      orinoco: simplify locking, fix error handling in PCMCIA resume
      orinoco: eliminate the suspend/resume functions if CONFIG_PM is unset
      orinoco: don't put PCI resource data to the network device

Stefano Brivio:
      bcm43xx: fix whitespace
      bcm43xx: add PCI ID for bcm4319

 drivers/net/wireless/airo.c                     |    2 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c     |    8 +-
 drivers/net/wireless/orinoco_cs.c               |   33 ++----
 drivers/net/wireless/orinoco_nortel.c           |    5 +
 drivers/net/wireless/orinoco_pci.c              |    5 +
 drivers/net/wireless/orinoco_pci.h              |   31 +-----
 drivers/net/wireless/orinoco_plx.c              |    5 +
 drivers/net/wireless/orinoco_tmd.c              |    5 +
 drivers/net/wireless/spectrum_cs.c              |   33 ++----
 include/net/ieee80211softmac.h                  |   38 ++++++-
 net/ieee80211/ieee80211_wx.c                    |    2 
 net/ieee80211/softmac/ieee80211softmac_assoc.c  |   72 +++++++-------
 net/ieee80211/softmac/ieee80211softmac_auth.c   |    3 +
 net/ieee80211/softmac/ieee80211softmac_module.c |  117 +++++++++++++++++++----
 net/ieee80211/softmac/ieee80211softmac_priv.h   |    6 +
 net/ieee80211/softmac/ieee80211softmac_wx.c     |    6 +
 16 files changed, 222 insertions(+), 149 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 7f2dacf..4069b79 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2768,7 +2768,7 @@ static int airo_test_wpa_capable(struct 
 
 	/* Only firmware versions 5.30.17 or better can do WPA */
 	if ((cap_rid.softVer > 0x530)
-	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 0x17))) {
+	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 17))) {
 		airo_print_info(name, "WPA is supported.");
 		return 1;
 	}
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 8d0f618..e69e8b5 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -128,13 +128,15 @@ #endif /* CONFIG_BCM43XX_DEBUG*/
 	static struct pci_device_id bcm43xx_pci_tbl[] = {
 	/* Broadcom 4303 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4307 802.11b */
+	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4318 802.11b/g */
+	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4319 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4319, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-		/* Broadcom 4306 802.11a */
+	/* Broadcom 4306 802.11a */
 //	{ PCI_VENDOR_ID_BROADCOM, 0x4321, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4309 802.11a/b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4324, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index d2c48ac..b2aec4d 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -147,14 +147,11 @@ static void orinoco_cs_detach(struct pcm
 {
 	struct net_device *dev = link->priv;
 
+	if (link->dev_node)
+		unregister_netdev(dev);
+
 	orinoco_cs_release(link);
 
-	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
-	if (link->dev_node) {
-		DEBUG(0, PFX "About to unregister net device %p\n",
-		      dev);
-		unregister_netdev(dev);
-	}
 	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
@@ -346,19 +343,10 @@ orinoco_cs_config(struct pcmcia_device *
                                     net_device has been registered */
 
 	/* Finally, report what we've done */
-	printk(KERN_DEBUG "%s: index 0x%02x: ",
-	       dev->name, link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp / 10,
-		       link->conf.Vpp % 10);
-	printk(", irq %d", link->irq.AssignedIRQ);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
-	printk("\n");
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
+	       "0x%04x-0x%04x\n", dev->name, dev->class_dev.dev->bus_id,
+	       link->irq.AssignedIRQ, link->io.BasePort1,
+	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
 	return 0;
 
@@ -427,7 +415,6 @@ static int orinoco_cs_resume(struct pcmc
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pccard *card = priv->card;
 	int err = 0;
-	unsigned long flags;
 
 	if (! test_bit(0, &card->hard_reset_in_progress)) {
 		err = orinoco_reinit_firmware(dev);
@@ -437,7 +424,7 @@ static int orinoco_cs_resume(struct pcmc
 			return -EIO;
 		}
 
-		spin_lock_irqsave(&priv->lock, flags);
+		spin_lock(&priv->lock);
 
 		netif_device_attach(dev);
 		priv->hw_unavailable--;
@@ -449,10 +436,10 @@ static int orinoco_cs_resume(struct pcmc
 				       dev->name, err);
 		}
 
-		spin_unlock_irqrestore(&priv->lock, flags);
+		spin_unlock(&priv->lock);
 	}
 
-	return 0;
+	return err;
 }
 
 
diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
index 1596182..74b9d5b 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -206,7 +206,6 @@ static int orinoco_nortel_init_one(struc
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_nortel_hw_init(card);
 	if (err) {
@@ -227,6 +226,8 @@ static int orinoco_nortel_init_one(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -265,7 +266,7 @@ static void __devexit orinoco_nortel_rem
 	iowrite16(0, card->bridge_io + 10);
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
index df37b95..1c105f4 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -161,7 +161,6 @@ static int orinoco_pci_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 0);
 
 	err = orinoco_pci_cor_reset(priv);
 	if (err) {
@@ -176,6 +175,8 @@ static int orinoco_pci_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -204,7 +205,7 @@ static void __devexit orinoco_pci_remove
 	struct orinoco_private *priv = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_pci.h b/drivers/net/wireless/orinoco_pci.h
index b05a9a5..7eb1e08 100644
--- a/drivers/net/wireless/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco_pci.h
@@ -18,32 +18,7 @@ struct orinoco_pci_card {
 	void __iomem *attr_io;
 };
 
-/* Set base address or memory range of the network device based on
- * the PCI device it's using.  Specify BAR of the "main" resource.
- * To be used after request_irq().  */
-static inline void orinoco_pci_setup_netdev(struct net_device *dev,
-					    struct pci_dev *pdev, int bar)
-{
-	char *range_type;
-	unsigned long start = pci_resource_start(pdev, bar);
-	unsigned long len = pci_resource_len(pdev, bar);
-	unsigned long flags = pci_resource_flags(pdev, bar);
-	unsigned long end = start + len - 1;
-
-	dev->irq = pdev->irq;
-	if (flags & IORESOURCE_IO) {
-		dev->base_addr = start;
-		range_type = "ports";
-	} else {
-		dev->mem_start = start;
-		dev->mem_end = end;
-		range_type = "memory";
-	}
-
-	printk(KERN_DEBUG PFX "%s: irq %d, %s 0x%lx-0x%lx\n",
-	       pci_name(pdev), pdev->irq, range_type, start, end);
-}
-
+#ifdef CONFIG_PM
 static int orinoco_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -121,5 +96,9 @@ static int orinoco_pci_resume(struct pci
 
 	return 0;
 }
+#else
+#define orinoco_pci_suspend NULL
+#define orinoco_pci_resume NULL
+#endif
 
 #endif /* _ORINOCO_PCI_H */
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
index 7b94050..84f696c 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -245,7 +245,6 @@ static int orinoco_plx_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_plx_hw_init(card);
 	if (err) {
@@ -266,6 +265,8 @@ static int orinoco_plx_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -301,7 +302,7 @@ static void __devexit orinoco_plx_remove
 	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
index 0496663..d2b4dec 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -147,7 +147,6 @@ static int orinoco_tmd_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_tmd_cor_reset(priv);
 	if (err) {
@@ -162,6 +161,8 @@ static int orinoco_tmd_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -194,7 +195,7 @@ static void __devexit orinoco_tmd_remove
 	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index aeb38d9..7f9aa13 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -625,14 +625,11 @@ static void spectrum_cs_detach(struct pc
 {
 	struct net_device *dev = link->priv;
 
+	if (link->dev_node)
+		unregister_netdev(dev);
+
 	spectrum_cs_release(link);
 
-	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
-	if (link->dev_node) {
-		DEBUG(0, PFX "About to unregister net device %p\n",
-		      dev);
-		unregister_netdev(dev);
-	}
 	free_orinocodev(dev);
 }				/* spectrum_cs_detach */
 
@@ -825,19 +822,10 @@ spectrum_cs_config(struct pcmcia_device 
                                     net_device has been registered */
 
 	/* Finally, report what we've done */
-	printk(KERN_DEBUG "%s: index 0x%02x: ",
-	       dev->name, link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp / 10,
-		       link->conf.Vpp % 10);
-	printk(", irq %d", link->irq.AssignedIRQ);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
-	printk("\n");
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
+	       "0x%04x-0x%04x\n", dev->name, dev->class_dev.dev->bus_id,
+	       link->irq.AssignedIRQ, link->io.BasePort1,
+	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
 	return 0;
 
@@ -878,11 +866,10 @@ spectrum_cs_suspend(struct pcmcia_device
 {
 	struct net_device *dev = link->priv;
 	struct orinoco_private *priv = netdev_priv(dev);
-	unsigned long flags;
 	int err = 0;
 
 	/* Mark the device as stopped, to block IO until later */
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock(&priv->lock);
 
 	err = __orinoco_down(dev);
 	if (err)
@@ -892,9 +879,9 @@ spectrum_cs_suspend(struct pcmcia_device
 	netif_device_detach(dev);
 	priv->hw_unavailable++;
 
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock(&priv->lock);
 
-	return 0;
+	return err;
 }
 
 static int
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 052ed59..703463a 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -86,6 +86,9 @@ struct ieee80211softmac_assoc_info {
 	
 	/* BSSID we're trying to associate to */
 	char bssid[ETH_ALEN];
+
+	/* Rates supported by the network */
+	struct ieee80211softmac_ratesinfo supported_rates;
 	
 	/* some flags.
 	 * static_essid is valid if the essid is constant,
@@ -132,23 +135,26 @@ #define IEEE80211SOFTMAC_ASSOC_SCAN_RETR
 struct ieee80211softmac_txrates {
 	/* The Bit-Rate to be used for multicast frames. */
 	u8 mcast_rate;
-	/* The Bit-Rate to be used for multicast fallback
-	 * (If the device supports fallback and hardware-retry)
-	 */
-	u8 mcast_fallback;
+
+	/* The Bit-Rate to be used for multicast management frames. */
+	u8 mgt_mcast_rate;
+
 	/* The Bit-Rate to be used for any other (normal) data packet. */
 	u8 default_rate;
 	/* The Bit-Rate to be used for default fallback
 	 * (If the device supports fallback and hardware-retry)
 	 */
 	u8 default_fallback;
+
+	/* This is the rate that the user asked for */
+	u8 user_rate;
 };
 
 /* Bits for txrates_change callback. */
 #define IEEE80211SOFTMAC_TXRATECHG_DEFAULT		(1 << 0) /* default_rate */
 #define IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK	(1 << 1) /* default_fallback */
 #define IEEE80211SOFTMAC_TXRATECHG_MCAST		(1 << 2) /* mcast_rate */
-#define IEEE80211SOFTMAC_TXRATECHG_MCAST_FBACK		(1 << 3) /* mcast_fallback */
+#define IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST		(1 << 3) /* mgt_mcast_rate */
 
 struct ieee80211softmac_device {
 	/* 802.11 structure for data stuff */
@@ -250,6 +256,28 @@ extern void ieee80211softmac_fragment_lo
  * Note that the rates need to be sorted. */
 extern void ieee80211softmac_set_rates(struct net_device *dev, u8 count, u8 *rates);
 
+/* Helper function which advises you the rate at which a frame should be
+ * transmitted at. */
+static inline u8 ieee80211softmac_suggest_txrate(struct ieee80211softmac_device *mac,
+						 int is_multicast,
+						 int is_mgt)
+{
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
+
+	if (!mac->associated)
+		return txrates->mgt_mcast_rate;
+
+	/* We are associated, sending unicast frame */
+	if (!is_multicast)
+		return txrates->default_rate;
+
+	/* We are associated, sending multicast frame */
+	if (is_mgt)
+		return txrates->mgt_mcast_rate;
+	else
+		return txrates->mcast_rate;
+}
+
 /* Start the SoftMAC. Call this after you initialized the device
  * and it is ready to run.
  */
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index 0ea55cb..a78c4f8 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -503,7 +503,7 @@ int ieee80211_wx_get_encode(struct ieee8
 	len = sec->key_sizes[key];
 	memcpy(keybuf, sec->keys[key], len);
 
-	erq->length = (len >= 0 ? len : 0);
+	erq->length = len;
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	if (ieee->open_wep)
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index d4c79ce..5d90b9a 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -82,51 +82,52 @@ ieee80211softmac_assoc_timeout(void *d)
 	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, NULL);
 }
 
-/* Sends out a disassociation request to the desired AP */
 void
-ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason)
+ieee80211softmac_disassoc(struct ieee80211softmac_device *mac)
 {
 	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (mac->associnfo.associating)
+		cancel_delayed_work(&mac->associnfo.timeout);
+
+	netif_carrier_off(mac->dev);
+
+	mac->associated = 0;
+	mac->associnfo.bssvalid = 0;
+	mac->associnfo.associating = 0;
+	ieee80211softmac_init_txrates(mac);
+	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
+/* Sends out a disassociation request to the desired AP */
+void
+ieee80211softmac_send_disassoc_req(struct ieee80211softmac_device *mac, u16 reason)
+{
 	struct ieee80211softmac_network *found;
 
 	if (mac->associnfo.bssvalid && mac->associated) {
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);
 		if (found)
 			ieee80211softmac_send_mgt_frame(mac, found, IEEE80211_STYPE_DISASSOC, reason);
-	} else if (mac->associnfo.associating) {
-		cancel_delayed_work(&mac->associnfo.timeout);
 	}
 
-	/* Change our state */
-	spin_lock_irqsave(&mac->lock, flags);
-	/* Do NOT clear bssvalid as that will break ieee80211softmac_assoc_work! */
-	mac->associated = 0;
-	mac->associnfo.associating = 0;
-	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
-	spin_unlock_irqrestore(&mac->lock, flags);
+	ieee80211softmac_disassoc(mac);
 }
 
 static inline int
 we_support_all_basic_rates(struct ieee80211softmac_device *mac, u8 *from, u8 from_len)
 {
-	int idx, search, found;
-	u8 rate, search_rate;
+	int idx;
+	u8 rate;
 
 	for (idx = 0; idx < (from_len); idx++) {
 		rate = (from)[idx];
 		if (!(rate & IEEE80211_BASIC_RATE_MASK))
 			continue;
-		found = 0;
 		rate &= ~IEEE80211_BASIC_RATE_MASK;
-		for (search = 0; search < mac->ratesinfo.count; search++) {
-			search_rate = mac->ratesinfo.rates[search];
-			search_rate &= ~IEEE80211_BASIC_RATE_MASK;
-			if (rate == search_rate) {
-				found = 1;
-				break;
-			}
-		}
-		if (!found)
+		if (!ieee80211softmac_ratesinfo_rate_supported(&mac->ratesinfo, rate))
 			return 0;
 	}
 	return 1;
@@ -176,14 +177,18 @@ ieee80211softmac_assoc_work(void *d)
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
 	struct ieee80211softmac_network *found = NULL;
 	struct ieee80211_network *net = NULL, *best = NULL;
+	int bssvalid;
 	unsigned long flags;
-	
+
+	/* ieee80211_disassoc might clear this */
+	bssvalid = mac->associnfo.bssvalid;
+
 	/* meh */
 	if (mac->associated)
-		ieee80211softmac_disassoc(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
+		ieee80211softmac_send_disassoc_req(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
 	/* try to find the requested network in our list, if we found one already */
-	if (mac->associnfo.bssvalid || mac->associnfo.bssfixed)
+	if (bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
 	
 	/* Search the ieee80211 networks for this network if we didn't find it by bssid,
@@ -297,6 +302,9 @@ ieee80211softmac_associated(struct ieee8
 	struct ieee80211softmac_network *net)
 {
 	mac->associnfo.associating = 0;
+	mac->associnfo.supported_rates = net->supported_rates;
+	ieee80211softmac_recalc_txrates(mac);
+
 	mac->associated = 1;
 	if (mac->set_bssid_filter)
 		mac->set_bssid_filter(mac->dev, net->bssid);
@@ -380,7 +388,6 @@ ieee80211softmac_handle_disassoc(struct 
 				 struct ieee80211_disassoc *disassoc)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
-	unsigned long flags;
 
 	if (unlikely(!mac->running))
 		return -ENODEV;
@@ -392,14 +399,11 @@ ieee80211softmac_handle_disassoc(struct 
 		return 0;
 
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
-	netif_carrier_off(dev);
-	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.bssvalid = 0;
-	mac->associated = 0;
-	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
+	ieee80211softmac_disassoc(mac);
+
+	/* try to reassociate */
 	schedule_work(&mac->associnfo.work);
-	spin_unlock_irqrestore(&mac->lock, flags);
-	
+
 	return 0;
 }
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 06e3326..084b621 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -279,6 +279,9 @@ ieee80211softmac_deauth_from_net(struct 
 	struct list_head *list_ptr;
 	unsigned long flags;
 
+	/* deauthentication implies disassociation */
+	ieee80211softmac_disassoc(mac);
+
 	/* Lock and reset status flags */
 	spin_lock_irqsave(&mac->lock, flags);
 	net->authenticating = 0;
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index 6252be2..4b2e57d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -26,6 +26,7 @@
 
 #include "ieee80211softmac_priv.h"
 #include <linux/sort.h>
+#include <linux/etherdevice.h>
 
 struct net_device *alloc_ieee80211softmac(int sizeof_priv)
 {
@@ -61,14 +62,6 @@ struct net_device *alloc_ieee80211softma
 	softmac->wait_for_scan = ieee80211softmac_wait_for_scan_implementation;
 	softmac->stop_scan = ieee80211softmac_stop_scan_implementation;
 
-	//TODO: The mcast rate has to be assigned dynamically somewhere (in scanning, association. Not sure...)
-	//      It has to be set to the highest rate all stations in the current network can handle.
-	softmac->txrates.mcast_rate = IEEE80211_CCK_RATE_1MB;
-	softmac->txrates.mcast_fallback = IEEE80211_CCK_RATE_1MB;
-	/* This is reassigned in ieee80211softmac_start to sane values. */
-	softmac->txrates.default_rate = IEEE80211_CCK_RATE_1MB;
-	softmac->txrates.default_fallback = IEEE80211_CCK_RATE_1MB;
-
 	/* to start with, we can't send anything ... */
 	netif_carrier_off(dev);
 	
@@ -170,15 +163,82 @@ static void ieee80211softmac_start_check
 	}
 }
 
-void ieee80211softmac_start(struct net_device *dev)
+int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate)
+{
+	int search;
+	u8 search_rate;
+
+	for (search = 0; search < ri->count; search++) {
+		search_rate = ri->rates[search];
+		search_rate &= ~IEEE80211_BASIC_RATE_MASK;
+		if (rate == search_rate)
+			return 1;
+	}
+
+	return 0;
+}
+
+/* Finds the highest rate which is:
+ *  1. Present in ri (optionally a basic rate)
+ *  2. Supported by the device
+ *  3. Less than or equal to the user-defined rate
+ */
+static u8 highest_supported_rate(struct ieee80211softmac_device *mac,
+	struct ieee80211softmac_ratesinfo *ri, int basic_only)
+{
+	u8 user_rate = mac->txrates.user_rate;
+	int i;
+
+	if (ri->count == 0) {
+		dprintk(KERN_ERR PFX "empty ratesinfo?\n");
+		return IEEE80211_CCK_RATE_1MB;
+	}
+
+	for (i = ri->count - 1; i >= 0; i--) {
+		u8 rate = ri->rates[i];
+		if (basic_only && !(rate & IEEE80211_BASIC_RATE_MASK))
+			continue;
+		rate &= ~IEEE80211_BASIC_RATE_MASK;
+		if (rate > user_rate)
+			continue;
+		if (ieee80211softmac_ratesinfo_rate_supported(&mac->ratesinfo, rate))
+			return rate;
+	}
+
+	/* If we haven't found a suitable rate by now, just trust the user */
+	return user_rate;
+}
+
+void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac)
+{
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
+	struct ieee80211softmac_txrates oldrates;
+	u32 change = 0;
+
+	if (mac->txrates_change)
+		oldrates = mac->txrates;
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
+	txrates->default_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 0);
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+	txrates->default_fallback = lower_rate(mac, txrates->default_rate);
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
+	txrates->mcast_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 1);
+
+	if (mac->txrates_change)
+		mac->txrates_change(mac->dev, change, &oldrates);
+
+}
+
+void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac)
 {
-	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	struct ieee80211_device *ieee = mac->ieee;
 	u32 change = 0;
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
 	struct ieee80211softmac_txrates oldrates;
 
-	ieee80211softmac_start_check_rates(mac);
-
 	/* TODO: We need some kind of state machine to lower the default rates
 	 *       if we loose too many packets.
 	 */
@@ -193,22 +253,37 @@ void ieee80211softmac_start(struct net_d
 	   more reliable. Note similar logic in
 	   ieee80211softmac_wx_set_rate() */	 
 	if (ieee->modulation & IEEE80211_CCK_MODULATION) {
-		mac->txrates.default_rate = IEEE80211_CCK_RATE_11MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-		mac->txrates.default_fallback = IEEE80211_CCK_RATE_5MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+		txrates->user_rate = IEEE80211_CCK_RATE_11MB;
 	} else if (ieee->modulation & IEEE80211_OFDM_MODULATION) {
-		mac->txrates.default_rate = IEEE80211_OFDM_RATE_54MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-		mac->txrates.default_fallback = IEEE80211_OFDM_RATE_24MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+		txrates->user_rate = IEEE80211_OFDM_RATE_54MB;
 	} else
 		assert(0);
+
+	txrates->default_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
+
+	txrates->default_fallback = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+
+	txrates->mcast_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
+
+	txrates->mgt_mcast_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST;
+
 	if (mac->txrates_change)
-		mac->txrates_change(dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change, &oldrates);
 
 	mac->running = 1;
 }
+
+void ieee80211softmac_start(struct net_device *dev)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+
+	ieee80211softmac_start_check_rates(mac);
+	ieee80211softmac_init_txrates(mac);
+}
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
 void ieee80211softmac_stop(struct net_device *dev)
diff --git a/net/ieee80211/softmac/ieee80211softmac_priv.h b/net/ieee80211/softmac/ieee80211softmac_priv.h
index 8c95b3a..fa1f8e3 100644
--- a/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ b/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -116,7 +116,10 @@ ieee80211softmac_get_network_by_essid(st
 	struct ieee80211softmac_essid *essid);
 
 /* Rates related */
+int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate);
 u8 ieee80211softmac_lower_rate_delta(struct ieee80211softmac_device *mac, u8 rate, int delta);
+void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac);
+void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac);
 static inline u8 lower_rate(struct ieee80211softmac_device *mac, u8 rate) {
 	return ieee80211softmac_lower_rate_delta(mac, rate, 1);
 }
@@ -150,7 +153,8 @@ int ieee80211softmac_handle_disassoc(str
 int ieee80211softmac_handle_reassoc_req(struct net_device * dev,
 				        struct ieee80211_reassoc_request * reassoc);
 void ieee80211softmac_assoc_timeout(void *d);
-void ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason);
+void ieee80211softmac_send_disassoc_req(struct ieee80211softmac_device *mac, u16 reason);
+void ieee80211softmac_disassoc(struct ieee80211softmac_device *mac);
 
 /* some helper functions */
 static inline int ieee80211softmac_scan_handlers_check_self(struct ieee80211softmac_device *sm)
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 8d0c226..22aa619 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -211,8 +211,8 @@ ieee80211softmac_wx_set_rate(struct net_
 	if (is_ofdm && !(ieee->modulation & IEEE80211_OFDM_MODULATION))
 		goto out_unlock;
 
-	mac->txrates.default_rate = rate;
-	mac->txrates.default_fallback = lower_rate(mac, rate);
+	mac->txrates.user_rate = rate;
+	ieee80211softmac_recalc_txrates(mac);
 	err = 0;
 
 out_unlock:	
@@ -456,7 +456,7 @@ ieee80211softmac_wx_set_mlme(struct net_
 		}
 		return ieee80211softmac_deauth_req(mac, net, reason);
 	case IW_MLME_DISASSOC:
-		ieee80211softmac_disassoc(mac, reason);
+		ieee80211softmac_send_disassoc_req(mac, reason);
 		return 0;
 	default:
 		return -EOPNOTSUPP;
-- 
John W. Linville
linville@tuxdriver.com
