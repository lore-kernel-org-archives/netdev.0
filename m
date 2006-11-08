From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 7 Nov 2006 23:59:27 -0500
Message-ID: <20061108045927.GB15272@tuxdriver.com>
References: <20061108045825.GA15272@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:14351 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1754299AbWKHFY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 00:24:59 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061108045825.GA15272@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit d4f748365129ccfc9dadf6fb14331e45e33cc4ed:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

John W. Linville:
      wireless: clean-up some "check return code" warnings

Larry Finger:
      bcm43xx: remove badness variable and related routine
      bcm43xx: Remove useless core enable/disable messages
      ieee80211softmac: fix verbosity when debug disabled

 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |   56 +++++--------------------
 drivers/net/wireless/hostap/hostap_pci.c      |    8 +++-
 drivers/net/wireless/ipw2100.c                |    8 +++-
 drivers/net/wireless/ipw2200.c                |    8 +++-
 drivers/net/wireless/orinoco_pci.h            |    7 +++
 drivers/net/wireless/prism54/islpci_hotplug.c |   20 +++++++--
 net/ieee80211/softmac/ieee80211softmac_auth.c |   10 ++--
 7 files changed, 60 insertions(+), 57 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index c6bd868..60a9745 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2684,14 +2684,10 @@ #endif
 		bcm->chip_id, bcm->chip_rev);
 	dprintk(KERN_INFO PFX "Number of cores: %d\n", core_count);
 	if (bcm->core_chipcommon.available) {
-		dprintk(KERN_INFO PFX "Core 0: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled");
-	}
-
-	if (bcm->core_chipcommon.available)
+		dprintk(KERN_INFO PFX "Core 0: ID 0x%x, rev 0x%x, vendor 0x%x\n",
+			core_id, core_rev, core_vendor);
 		current_core = 1;
-	else
+	} else
 		current_core = 0;
 	for ( ; current_core < core_count; current_core++) {
 		struct bcm43xx_coreinfo *core;
@@ -2709,9 +2705,8 @@ #endif
 		core_rev = (sb_id_hi & 0xF);
 		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
-		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			current_core, core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled" );
+		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x\n",
+			current_core, core_id, core_rev, core_vendor);
 
 		core = NULL;
 		switch (core_id) {
@@ -3209,55 +3204,27 @@ static void bcm43xx_periodic_every15sec(
 
 static void do_periodic_work(struct bcm43xx_private *bcm)
 {
-	unsigned int state;
-
-	state = bcm->periodic_state;
-	if (state % 8 == 0)
+	if (bcm->periodic_state % 8 == 0)
 		bcm43xx_periodic_every120sec(bcm);
-	if (state % 4 == 0)
+	if (bcm->periodic_state % 4 == 0)
 		bcm43xx_periodic_every60sec(bcm);
-	if (state % 2 == 0)
+	if (bcm->periodic_state % 2 == 0)
 		bcm43xx_periodic_every30sec(bcm);
-	if (state % 1 == 0)
-		bcm43xx_periodic_every15sec(bcm);
-	bcm->periodic_state = state + 1;
+	bcm43xx_periodic_every15sec(bcm);
 
 	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
 }
 
-/* Estimate a "Badness" value based on the periodic work
- * state-machine state. "Badness" is worse (bigger), if the
- * periodic work will take longer.
- */
-static int estimate_periodic_work_badness(unsigned int state)
-{
-	int badness = 0;
-
-	if (state % 8 == 0) /* every 120 sec */
-		badness += 10;
-	if (state % 4 == 0) /* every 60 sec */
-		badness += 5;
-	if (state % 2 == 0) /* every 30 sec */
-		badness += 1;
-	if (state % 1 == 0) /* every 15 sec */
-		badness += 1;
-
-#define BADNESS_LIMIT	4
-	return badness;
-}
-
 static void bcm43xx_periodic_work_handler(void *d)
 {
 	struct bcm43xx_private *bcm = d;
 	struct net_device *net_dev = bcm->net_dev;
 	unsigned long flags;
 	u32 savedirqs = 0;
-	int badness;
 	unsigned long orig_trans_start = 0;
 
 	mutex_lock(&bcm->mutex);
-	badness = estimate_periodic_work_badness(bcm->periodic_state);
-	if (badness > BADNESS_LIMIT) {
+	if (unlikely(bcm->periodic_state % 4 == 0)) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
@@ -3289,7 +3256,7 @@ static void bcm43xx_periodic_work_handle
 
 	do_periodic_work(bcm);
 
-	if (badness > BADNESS_LIMIT) {
+	if (unlikely(bcm->periodic_state % 4 == 0)) {
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		tasklet_enable(&bcm->isr_tasklet);
 		bcm43xx_interrupt_enable(bcm, savedirqs);
@@ -3300,6 +3267,7 @@ static void bcm43xx_periodic_work_handle
 		net_dev->trans_start = orig_trans_start;
 	}
 	mmiowb();
+	bcm->periodic_state++;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	mutex_unlock(&bcm->mutex);
 }
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index c2fa011..d1de976 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -425,8 +425,14 @@ static int prism2_pci_suspend(struct pci
 static int prism2_pci_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	int err;
 
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		       dev->name);
+		return err;
+	}
 	pci_restore_state(pdev);
 	prism2_hw_config(dev, 0);
 	if (netif_running(dev)) {
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 4e4eaa2..2324e06 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6423,6 +6423,7 @@ static int ipw2100_resume(struct pci_dev
 {
 	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
 	struct net_device *dev = priv->net_dev;
+	int err;
 	u32 val;
 
 	if (IPW2100_PM_DISABLED)
@@ -6433,7 +6434,12 @@ static int ipw2100_resume(struct pci_dev
 	IPW_DEBUG_INFO("%s: Coming out of suspend...\n", dev->name);
 
 	pci_set_power_state(pci_dev, PCI_D0);
-	pci_enable_device(pci_dev);
+	err = pci_enable_device(pci_dev);
+	if (err) {
+		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		       dev->name);
+		return err;
+	}
 	pci_restore_state(pci_dev);
 
 	/*
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 1f74281..a60714e 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11727,12 +11727,18 @@ static int ipw_pci_resume(struct pci_dev
 {
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct net_device *dev = priv->net_dev;
+	int err;
 	u32 val;
 
 	printk(KERN_INFO "%s: Coming out of suspend...\n", dev->name);
 
 	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		       dev->name);
+		return err;
+	}
 	pci_restore_state(pdev);
 
 	/*
diff --git a/drivers/net/wireless/orinoco_pci.h b/drivers/net/wireless/orinoco_pci.h
index be1abea..f4e5e06 100644
--- a/drivers/net/wireless/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco_pci.h
@@ -60,7 +60,12 @@ static int orinoco_pci_resume(struct pci
 	int err;
 
 	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		       dev->name);
+		return err;
+	}
 	pci_restore_state(pdev);
 
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index f6354b1..e0bca3a 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -170,14 +170,15 @@ #endif
 	pci_set_master(pdev);
 
 	/* enable MWI */
-	pci_set_mwi(pdev);
+	if (pci_set_mwi(pdev))
+		goto do_pci_release_regions;
 
 	/* setup the network device interface and its structure */
 	if (!(ndev = islpci_setup(pdev))) {
 		/* error configuring the driver as a network device */
 		printk(KERN_ERR "%s: could not configure network device\n",
 		       DRV_NAME);
-		goto do_pci_release_regions;
+		goto do_pci_clear_mwi;
 	}
 
 	priv = netdev_priv(ndev);
@@ -207,6 +208,8 @@ #endif
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 	priv = NULL;
+      do_pci_clear_mwi:
+	pci_clear_mwi(pdev);
       do_pci_release_regions:
 	pci_release_regions(pdev);
       do_pci_disable_device:
@@ -254,6 +257,8 @@ prism54_remove(struct pci_dev *pdev)
 	free_netdev(ndev);
 	priv = NULL;
 
+	pci_clear_mwi(pdev);
+
 	pci_release_regions(pdev);
 
 	pci_disable_device(pdev);
@@ -287,12 +292,19 @@ prism54_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
-	BUG_ON(!priv);
+	int err;
 
-	pci_enable_device(pdev);
+	BUG_ON(!priv);
 
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
 
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
+		       ndev->name);
+		return err;
+	}
+
 	pci_restore_state(pdev);
 
 	/* alright let's go into the PREBOOT state */
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 4cef39e..95e5287 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -158,7 +158,7 @@ ieee80211softmac_auth_resp(struct net_de
 	/* Make sure that we've got an auth queue item for this request */
 	if(aq == NULL)
 	{
-		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
+		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
 		/* Error #? */
 		return -1;
 	}			
@@ -166,7 +166,7 @@ ieee80211softmac_auth_resp(struct net_de
 	/* Check for out of order authentication */
 	if(!net->authenticating)
 	{
-		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
+		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
 		return -1;
 	}
 
@@ -342,7 +342,7 @@ ieee80211softmac_deauth_req(struct ieee8
 	/* Make sure the network is authenticated */
 	if (!net->authenticated)
 	{
-		printkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
+		dprintkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
 		/* Error okay? */
 		return -EPERM;
 	}
@@ -376,7 +376,7 @@ ieee80211softmac_deauth_resp(struct net_
 	net = ieee80211softmac_get_network_by_bssid(mac, deauth->header.addr2);
 	
 	if (net == NULL) {
-		printkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
+		dprintkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
 			MAC_ARG(deauth->header.addr2));
 		return 0;
 	}
@@ -384,7 +384,7 @@ ieee80211softmac_deauth_resp(struct net_
 	/* Make sure the network is authenticated */
 	if(!net->authenticated)
 	{
-		printkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
+		dprintkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
 		/* Error okay? */
 		return -EPERM;
 	}
-- 
John W. Linville
linville@tuxdriver.com
