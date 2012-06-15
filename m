From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 13/20] orinoco: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:53 -0700
Message-ID: <72180c33152b738737302c0cc5e5f446943d18b3.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/orinoco/airport.c        |   28 ++--
 drivers/net/wireless/orinoco/cfg.c            |    9 +-
 drivers/net/wireless/orinoco/hermes.c         |   71 +++++-----
 drivers/net/wireless/orinoco/hw.c             |   79 +++++------
 drivers/net/wireless/orinoco/main.c           |  194 +++++++++++-------------
 drivers/net/wireless/orinoco/mic.c            |   13 +-
 drivers/net/wireless/orinoco/orinoco.h        |   13 +-
 drivers/net/wireless/orinoco/orinoco_cs.c     |   11 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c |   40 +++---
 drivers/net/wireless/orinoco/orinoco_pci.c    |   23 ++--
 drivers/net/wireless/orinoco/orinoco_pci.h    |    6 +-
 drivers/net/wireless/orinoco/orinoco_plx.c    |   40 +++---
 drivers/net/wireless/orinoco/orinoco_tmd.c    |   25 ++--
 drivers/net/wireless/orinoco/orinoco_usb.c    |  145 +++++++++----------
 drivers/net/wireless/orinoco/scan.c           |   16 +-
 drivers/net/wireless/orinoco/spectrum_cs.c    |    6 +-
 drivers/net/wireless/orinoco/wext.c           |   28 ++--
 17 files changed, 361 insertions(+), 386 deletions(-)

diff --git a/drivers/net/wireless/orinoco/airport.c b/drivers/net/wireless/orinoco/airport.c
index 0ca8b14..a6cea29 100644
--- a/drivers/net/wireless/orinoco/airport.c
+++ b/drivers/net/wireless/orinoco/airport.c
@@ -11,8 +11,9 @@
  *  0.06 : fix possible hang on powerup, add sleep support
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "airport"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -41,12 +42,11 @@ airport_suspend(struct macio_dev *mdev, pm_message_t state)
 	unsigned long flags;
 	int err;
 
-	printk(KERN_DEBUG "%s: Airport entering sleep mode\n", dev->name);
+	pr_debug("%s: Airport entering sleep mode\n", dev->name);
 
 	err = orinoco_lock(priv, &flags);
 	if (err) {
-		printk(KERN_ERR "%s: hw_unavailable on PBOOK_SLEEP_NOW\n",
-		       dev->name);
+		pr_err("%s: hw_unavailable on PBOOK_SLEEP_NOW\n", dev->name);
 		return 0;
 	}
 
@@ -69,7 +69,7 @@ airport_resume(struct macio_dev *mdev)
 	unsigned long flags;
 	int err;
 
-	printk(KERN_DEBUG "%s: Airport waking up\n", dev->name);
+	pr_debug("%s: Airport waking up\n", dev->name);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE,
 			  macio_get_of_node(mdev), 0, 1);
@@ -153,7 +153,7 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	struct hermes *hw;
 
 	if (macio_resource_count(mdev) < 1 || macio_irq_count(mdev) < 1) {
-		printk(KERN_ERR PFX "Wrong interrupt/addresses in OF tree\n");
+		pr_err("Wrong interrupt/addresses in OF tree\n");
 		return -ENODEV;
 	}
 
@@ -161,7 +161,7 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	priv = alloc_orinocodev(sizeof(*card), &mdev->ofdev.dev,
 				airport_hard_reset, NULL);
 	if (!priv) {
-		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		pr_err("Cannot allocate network device\n");
 		return -ENODEV;
 	}
 	card = priv->card;
@@ -170,7 +170,7 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	card->mdev = mdev;
 
 	if (macio_request_resource(mdev, 0, DRIVER_NAME)) {
-		printk(KERN_ERR PFX "can't request IO resource !\n");
+		pr_err("can't request IO resource !\n");
 		free_orinocodev(priv);
 		return -EBUSY;
 	}
@@ -180,10 +180,10 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	/* Setup interrupts & base address */
 	card->irq = macio_irq(mdev, 0);
 	phys_addr = macio_resource_start(mdev, 0);  /* Physical address */
-	printk(KERN_DEBUG PFX "Physical address %lx\n", phys_addr);
+	pr_debug("Physical address %lx\n", phys_addr);
 	card->vaddr = ioremap(phys_addr, AIRPORT_IO_LEN);
 	if (!card->vaddr) {
-		printk(KERN_ERR PFX "ioremap() failed\n");
+		pr_err("ioremap() failed\n");
 		goto failed;
 	}
 
@@ -198,20 +198,20 @@ airport_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	hw->ops->init(hw);
 
 	if (request_irq(card->irq, orinoco_interrupt, 0, DRIVER_NAME, priv)) {
-		printk(KERN_ERR PFX "Couldn't get IRQ %d\n", card->irq);
+		pr_err("Couldn't get IRQ %d\n", card->irq);
 		goto failed;
 	}
 	card->irq_requested = 1;
 
 	/* Initialise the main driver */
 	if (orinoco_init(priv) != 0) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto failed;
 	}
 
 	/* Register an interface with the stack */
 	if (orinoco_if_add(priv, phys_addr, card->irq, NULL) != 0) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto failed;
 	}
 	card->ndev_registered = 1;
@@ -252,7 +252,7 @@ static struct macio_driver airport_driver = {
 static int __init
 init_airport(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 
 	return macio_register_driver(&airport_driver);
 }
diff --git a/drivers/net/wireless/orinoco/cfg.c b/drivers/net/wireless/orinoco/cfg.c
index e156755..8d2ad86 100644
--- a/drivers/net/wireless/orinoco/cfg.c
+++ b/drivers/net/wireless/orinoco/cfg.c
@@ -2,6 +2,9 @@
  *
  * See copyright notice in main.c
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ieee80211.h>
 #include <net/cfg80211.h>
 #include "hw.h"
@@ -223,10 +226,8 @@ static int orinoco_set_wiphy_params(struct wiphy *wiphy, u32 changed)
 			if (wiphy->frag_threshold < 0)
 				frag_value = 0;
 			else {
-				printk(KERN_WARNING "%s: Fixed fragmentation "
-				       "is not supported on this firmware. "
-				       "Using MWO robust instead.\n",
-				       priv->ndev->name);
+				pr_warn("%s: Fixed fragmentation is not supported on this firmware. Using MWO robust instead.\n",
+					priv->ndev->name);
 				frag_value = 1;
 			}
 		} else {
diff --git a/drivers/net/wireless/orinoco/hermes.c b/drivers/net/wireless/orinoco/hermes.c
index 75c15bc..e6d0246 100644
--- a/drivers/net/wireless/orinoco/hermes.c
+++ b/drivers/net/wireless/orinoco/hermes.c
@@ -38,6 +38,8 @@
  * under either the MPL or the GPL.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -75,18 +77,26 @@
  * Debugging helpers
  */
 
-#define DMSG(stuff...) do {printk(KERN_DEBUG "hermes @ %p: " , hw->iobase); \
-			printk(stuff); } while (0)
+#define DMSG(fmt, ...)						\
+	pr_debug("@ %p: " fmt, hw->iobase, ##__VA_ARGS__)
 
 #undef HERMES_DEBUG
 #ifdef HERMES_DEBUG
 #include <stdarg.h>
 
-#define DEBUG(lvl, stuff...) if ((lvl) <= HERMES_DEBUG) DMSG(stuff)
+#define DEBUG(lvl, fmt, ...)				\
+do {							\
+	if ((lvl) <= HERMES_DEBUG)			\
+		DMSG(fmt, ##__VA_ARGS__);		\
+} while (0)
 
 #else /* ! HERMES_DEBUG */
 
-#define DEBUG(lvl, stuff...) do { } while (0)
+#define DEBUG(lvl, fmt, ...)				\
+do {							\
+	if (0)						\
+		DMSG(fmt, ##__VA_ARGS__);		\
+} while (0)
 
 #endif /* ! HERMES_DEBUG */
 
@@ -155,15 +165,13 @@ static int hermes_doicmd_wait(struct hermes *hw, u16 cmd,
 	hermes_write_regn(hw, SWSUPPORT0, HERMES_MAGIC);
 
 	if (!hermes_present(hw)) {
-		DEBUG(0, "hermes @ 0x%x: Card removed during reset.\n",
-		       hw->iobase);
+		DEBUG(0, "Card removed during reset\n");
 		err = -ENODEV;
 		goto out;
 	}
 
 	if (!(reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %p: "
-		       "Timeout waiting for card to reset (reg=0x%04x)!\n",
+		pr_err("@ %p: Timeout waiting for card to reset (reg=0x%04x)!\n",
 		       hw->iobase, reg);
 		err = -ETIMEDOUT;
 		goto out;
@@ -262,14 +270,12 @@ static int hermes_docmd_wait(struct hermes *hw, u16 cmd, u16 parm0,
 	if (err) {
 		if (!hermes_present(hw)) {
 			if (net_ratelimit())
-				printk(KERN_WARNING "hermes @ %p: "
-				       "Card removed while issuing command "
-				       "0x%04x.\n", hw->iobase, cmd);
+				pr_warn("@ %p: Card removed while issuing command 0x%04x\n",
+					hw->iobase, cmd);
 			err = -ENODEV;
 		} else
 			if (net_ratelimit())
-				printk(KERN_ERR "hermes @ %p: "
-				       "Error %d issuing command 0x%04x.\n",
+				pr_err("@ %p: Error %d issuing command 0x%04x\n",
 				       hw->iobase, err, cmd);
 		goto out;
 	}
@@ -283,16 +289,15 @@ static int hermes_docmd_wait(struct hermes *hw, u16 cmd, u16 parm0,
 	}
 
 	if (!hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %p: Card removed "
-		       "while waiting for command 0x%04x completion.\n",
-		       hw->iobase, cmd);
+		pr_warn("@ %p: Card removed while waiting for command 0x%04x completion\n",
+			hw->iobase, cmd);
 		err = -ENODEV;
 		goto out;
 	}
 
 	if (!(reg & HERMES_EV_CMD)) {
-		printk(KERN_ERR "hermes @ %p: Timeout waiting for "
-		       "command 0x%04x completion.\n", hw->iobase, cmd);
+		pr_err("@ %p: Timeout waiting for command 0x%04x completion\n",
+		       hw->iobase, cmd);
 		err = -ETIMEDOUT;
 		goto out;
 	}
@@ -336,15 +341,13 @@ static int hermes_allocate(struct hermes *hw, u16 size, u16 *fid)
 	}
 
 	if (!hermes_present(hw)) {
-		printk(KERN_WARNING "hermes @ %p: "
-		       "Card removed waiting for frame allocation.\n",
-		       hw->iobase);
+		pr_warn("@ %p: Card removed waiting for frame allocation\n",
+			hw->iobase);
 		return -ENODEV;
 	}
 
 	if (!(reg & HERMES_EV_ALLOC)) {
-		printk(KERN_ERR "hermes @ %p: "
-		       "Timeout waiting for frame allocation\n",
+		pr_err("@ %p: Timeout waiting for frame allocation\n",
 		       hw->iobase);
 		return -ETIMEDOUT;
 	}
@@ -400,8 +403,8 @@ static int hermes_bap_seek(struct hermes *hw, int bap, u16 id, u16 offset)
 	}
 
 	if (reg != offset) {
-		printk(KERN_ERR "hermes @ %p: BAP%d offset %s: "
-		       "reg=0x%x id=0x%x offset=0x%x\n", hw->iobase, bap,
+		pr_err("@ %p: BAP%d offset %s: reg=0x%x id=0x%x offset=0x%x\n",
+		       hw->iobase, bap,
 		       (reg & HERMES_OFFSET_BUSY) ? "timeout" : "error",
 		       reg, id, offset);
 
@@ -509,14 +512,12 @@ static int hermes_read_ltv(struct hermes *hw, int bap, u16 rid,
 		*length = rlength;
 
 	if (rtype != rid)
-		printk(KERN_WARNING "hermes @ %p: %s(): "
-		       "rid (0x%04x) does not match type (0x%04x)\n",
-		       hw->iobase, __func__, rid, rtype);
+		pr_warn("@ %p: %s(): rid (0x%04x) does not match type (0x%04x)\n",
+			hw->iobase, __func__, rid, rtype);
 	if (HERMES_RECLEN_TO_BYTES(rlength) > bufsize)
-		printk(KERN_WARNING "hermes @ %p: "
-		       "Truncating LTV record from %d to %d bytes. "
-		       "(rid=0x%04x, len=0x%04x)\n", hw->iobase,
-		       HERMES_RECLEN_TO_BYTES(rlength), bufsize, rid, rlength);
+		pr_warn("@ %p: Truncating LTV record from %d to %d bytes. (rid=0x%04x, len=0x%04x)\n",
+			hw->iobase,
+			HERMES_RECLEN_TO_BYTES(rlength), bufsize, rid, rlength);
 
 	nwords = min((unsigned)rlength - 1, bufsize / 2);
 	hermes_read_words(hw, dreg, buf, nwords);
@@ -652,8 +653,7 @@ static int hermesi_program_end(struct hermes *hw)
 
 	rc = hw->ops->cmd_wait(hw, HERMES_PROGRAM_DISABLE, 0, &resp);
 
-	pr_debug("PROGRAM_DISABLE returned %d, "
-		 "r0 0x%04x, r1 0x%04x, r2 0x%04x\n",
+	pr_debug("PROGRAM_DISABLE returned %d, r0 0x%04x, r1 0x%04x, r2 0x%04x\n",
 		 rc, resp.resp0, resp.resp1, resp.resp2);
 
 	if ((rc == 0) &&
@@ -727,8 +727,7 @@ static int hermes_read_pda(struct hermes *hw, __le16 *pda, u32 pda_addr,
 
 	/* Check PDA length */
 	pda_size = le16_to_cpu(pda[0]);
-	pr_debug("Actual PDA length %d, Max allowed %d\n",
-		 pda_size, pda_len);
+	pr_debug("Actual PDA length %d, Max allowed %d\n", pda_size, pda_len);
 	if (pda_size > pda_len)
 		return -EINVAL;
 
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index c09c843..5202845 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -2,6 +2,9 @@
  *
  * See copyright notice in main.c
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/device.h>
 #include <linux/if_arp.h>
@@ -467,8 +470,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 				 HERMES_BYTES_TO_RECLEN(ETH_ALEN),
 				 dev->dev_addr);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting MAC address\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting MAC address\n", dev->name, err);
 		return err;
 	}
 
@@ -476,8 +478,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 	err = hermes_write_wordrec(hw, USER_BAP, HERMES_RID_CNFPORTTYPE,
 				   priv->port_type);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting port type\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting port type\n", dev->name, err);
 		return err;
 	}
 	/* Set the channel/frequency */
@@ -486,7 +487,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFOWNCHANNEL,
 					   priv->channel);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting channel %d\n",
+			pr_err("%s: Error %d setting channel %d\n",
 			       dev->name, err, priv->channel);
 			return err;
 		}
@@ -496,8 +497,8 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 		u16 createibss;
 
 		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)) {
-			printk(KERN_WARNING "%s: This firmware requires an "
-			       "ESSID in IBSS-Ad-Hoc mode.\n", dev->name);
+			pr_warn("%s: This firmware requires an ESSID in IBSS-Ad-Hoc mode\n",
+				dev->name);
 			/* With wvlan_cs, in this case, we would crash.
 			 * hopefully, this driver will behave better...
 			 * Jean II */
@@ -510,7 +511,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFCREATEIBSS,
 					   createibss);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n",
+			pr_err("%s: Error %d setting CREATEIBSS\n",
 			       dev->name, err);
 			return err;
 		}
@@ -519,8 +520,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 	/* Set the desired BSSID */
 	err = __orinoco_hw_set_wap(priv);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting AP address\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting AP address\n", dev->name, err);
 		return err;
 	}
 
@@ -532,16 +532,14 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 			HERMES_BYTES_TO_RECLEN(strlen(priv->desired_essid) + 2),
 			&idbuf);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting OWNSSID\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting OWNSSID\n", dev->name, err);
 		return err;
 	}
 	err = hw->ops->write_ltv(hw, USER_BAP, HERMES_RID_CNFDESIREDSSID,
 			HERMES_BYTES_TO_RECLEN(strlen(priv->desired_essid) + 2),
 			&idbuf);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting DESIREDSSID\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting DESIREDSSID\n", dev->name, err);
 		return err;
 	}
 
@@ -552,8 +550,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 				 HERMES_BYTES_TO_RECLEN(strlen(priv->nick) + 2),
 				 &idbuf);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting nickname\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting nickname\n", dev->name, err);
 		return err;
 	}
 
@@ -563,9 +560,8 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFSYSTEMSCALE,
 					   priv->ap_density);
 		if (err) {
-			printk(KERN_WARNING "%s: Error %d setting SYSTEMSCALE. "
-			       "Disabling sensitivity control\n",
-			       dev->name, err);
+			pr_warn("%s: Error %d setting SYSTEMSCALE. Disabling sensitivity control.\n",
+				dev->name, err);
 
 			priv->has_sensitivity = 0;
 		}
@@ -575,8 +571,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 	err = hermes_write_wordrec(hw, USER_BAP, HERMES_RID_CNFRTSTHRESHOLD,
 				   priv->rts_thresh);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting RTS threshold\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting RTS threshold\n", dev->name, err);
 		return err;
 	}
 
@@ -590,16 +585,14 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFFRAGMENTATIONTHRESHOLD,
 					   priv->frag_thresh);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting fragmentation\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting fragmentation\n", dev->name, err);
 		return err;
 	}
 
 	/* Set bitrate */
 	err = __orinoco_hw_set_bitrate(priv);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d setting bitrate\n",
-		       dev->name, err);
+		pr_err("%s: Error %d setting bitrate\n", dev->name, err);
 		return err;
 	}
 
@@ -609,8 +602,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFPMENABLED,
 					   priv->pm_on);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting up PM\n",
-			       dev->name, err);
+			pr_err("%s: Error %d setting up PM\n", dev->name, err);
 			return err;
 		}
 
@@ -618,24 +610,21 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFMULTICASTRECEIVE,
 					   priv->pm_mcast);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting up PM\n",
-			       dev->name, err);
+			pr_err("%s: Error %d setting up PM\n", dev->name, err);
 			return err;
 		}
 		err = hermes_write_wordrec(hw, USER_BAP,
 					   HERMES_RID_CNFMAXSLEEPDURATION,
 					   priv->pm_period);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting up PM\n",
-			       dev->name, err);
+			pr_err("%s: Error %d setting up PM\n", dev->name, err);
 			return err;
 		}
 		err = hermes_write_wordrec(hw, USER_BAP,
 					   HERMES_RID_CNFPMHOLDOVERDURATION,
 					   priv->pm_timeout);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting up PM\n",
-			       dev->name, err);
+			pr_err("%s: Error %d setting up PM\n", dev->name, err);
 			return err;
 		}
 	}
@@ -646,7 +635,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 					   HERMES_RID_CNFPREAMBLE_SYMBOL,
 					   priv->preamble);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting preamble\n",
+			pr_err("%s: Error %d setting preamble\n",
 			       dev->name, err);
 			return err;
 		}
@@ -656,7 +645,7 @@ int orinoco_hw_program_rids(struct orinoco_private *priv)
 	if (priv->has_wep || priv->has_wpa) {
 		err = __orinoco_hw_setup_enc(priv);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d activating encryption\n",
+			pr_err("%s: Error %d activating encryption\n",
 			       dev->name, err);
 			return err;
 		}
@@ -711,7 +700,7 @@ int __orinoco_hw_set_bitrate(struct orinoco_private *priv)
 	int err = 0;
 
 	if (ratemode >= BITRATE_TABLE_SIZE) {
-		printk(KERN_ERR "%s: BUG: Invalid bitrate mode %d\n",
+		pr_err("%s: BUG: Invalid bitrate mode %d\n",
 		       priv->ndev->name, ratemode);
 		return -EINVAL;
 	}
@@ -768,8 +757,8 @@ int orinoco_hw_get_act_bitrate(struct orinoco_private *priv, int *bitrate)
 			}
 
 		if (i >= BITRATE_TABLE_SIZE) {
-			printk(KERN_INFO "%s: Unable to determine current bitrate (0x%04hx)\n",
-			       priv->ndev->name, val);
+			pr_info("%s: Unable to determine current bitrate (0x%04hx)\n",
+				priv->ndev->name, val);
 			err = -EIO;
 		}
 
@@ -862,7 +851,7 @@ int __orinoco_hw_setup_wepkeys(struct orinoco_private *priv)
 			keylen = priv->keys[priv->tx_key].key_len;
 
 			if (keylen > LARGE_KEY_SIZE) {
-				printk(KERN_ERR "%s: BUG: Key %d has oversize length %d.\n",
+				pr_err("%s: BUG: Key %d has oversize length %d\n",
 				       priv->ndev->name, priv->tx_key, keylen);
 				return -E2BIG;
 			} else if (keylen > SMALL_KEY_SIZE)
@@ -1059,8 +1048,8 @@ int orinoco_clear_tkip_key(struct orinoco_private *priv, int key_idx)
 				   HERMES_RID_CNFREMDEFAULTTKIPKEY_AGERE,
 				   key_idx);
 	if (err)
-		printk(KERN_WARNING "%s: Error %d clearing TKIP key %d\n",
-		       priv->ndev->name, err, key_idx);
+		pr_warn("%s: Error %d clearing TKIP key %d\n",
+			priv->ndev->name, err, key_idx);
 	return err;
 }
 
@@ -1076,7 +1065,7 @@ int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
 					   HERMES_RID_CNFPROMISCUOUSMODE,
 					   promisc);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d setting PROMISCUOUSMODE to 1.\n",
+			pr_err("%s: Error %d setting PROMISCUOUSMODE to 1\n",
 			       priv->ndev->name, err);
 		} else
 			priv->promiscuous = promisc;
@@ -1101,7 +1090,7 @@ int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
 				   HERMES_BYTES_TO_RECLEN(mc_count * ETH_ALEN),
 				   &mclist);
 		if (err)
-			printk(KERN_ERR "%s: Error %d setting multicast list.\n",
+			pr_err("%s: Error %d setting multicast list\n",
 			       priv->ndev->name, err);
 		else
 			priv->mc_count = mc_count;
@@ -1187,8 +1176,8 @@ int orinoco_hw_get_freq(struct orinoco_private *priv)
 	}
 
 	if ((channel < 1) || (channel > NUM_CHANNELS)) {
-		printk(KERN_WARNING "%s: Channel out of range (%d)!\n",
-		       priv->ndev->name, channel);
+		pr_warn("%s: Channel out of range (%d)!\n",
+			priv->ndev->name, channel);
 		err = -EBUSY;
 		goto out;
 
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 88e3ad2..b9c2ab9 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -74,6 +74,8 @@
  * hw_unavailable is non-zero).
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco"
 
 #include <linux/module.h>
@@ -245,7 +247,7 @@ void set_port_type(struct orinoco_private *priv)
 		priv->createibss = 0;
 		break;
 	default:
-		printk(KERN_ERR "%s: Invalid priv->iw_mode in set_port_type()\n",
+		pr_err("%s: Invalid priv->iw_mode in set_port_type()\n",
 		       priv->ndev->name);
 	}
 }
@@ -308,8 +310,8 @@ void orinoco_set_multicast_list(struct net_device *dev)
 	unsigned long flags;
 
 	if (orinoco_lock(priv, &flags) != 0) {
-		printk(KERN_DEBUG "%s: orinoco_set_multicast_list() "
-		       "called when hw_unavailable\n", dev->name);
+		pr_debug("%s: orinoco_set_multicast_list() called when hw_unavailable\n",
+			 dev->name);
 		return;
 	}
 
@@ -395,8 +397,7 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 
 		if (skb_headroom(skb) < ENCAPS_OVERHEAD) {
 			if (net_ratelimit())
-				printk(KERN_ERR
-				       "%s: Not enough headroom for 802.2 headers %d\n",
+				pr_err("%s: Not enough headroom for 802.2 headers %d\n",
 				       dev->name, skb_headroom(skb));
 			return -ENOMEM;
 		}
@@ -445,19 +446,17 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 mic_buf[MICHAEL_MIC_LEN + 1];
 
 	if (!netif_running(dev)) {
-		printk(KERN_ERR "%s: Tx on stopped device!\n",
-		       dev->name);
+		pr_err("%s: Tx on stopped device!\n", dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
 	if (netif_queue_stopped(dev)) {
-		printk(KERN_DEBUG "%s: Tx while transmitter busy!\n",
-		       dev->name);
+		pr_debug("%s: Tx while transmitter busy!\n", dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
 	if (orinoco_lock(priv, &flags) != 0) {
-		printk(KERN_ERR "%s: orinoco_xmit() called while hw_unavailable\n",
+		pr_err("%s: orinoco_xmit() called while hw_unavailable\n",
 		       dev->name);
 		return NETDEV_TX_BUSY;
 	}
@@ -496,8 +495,8 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 					  txfid, 0);
 		if (err) {
 			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error %d writing Tx "
-				       "descriptor to BAP\n", dev->name, err);
+				pr_err("%s: Error %d writing Tx descriptor to BAP\n",
+				       dev->name, err);
 			goto busy;
 		}
 	} else {
@@ -510,8 +509,8 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 					  txfid, 0);
 		if (err) {
 			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error %d writing Tx "
-				       "descriptor to BAP\n", dev->name, err);
+				pr_err("%s: Error %d writing Tx descriptor to BAP\n",
+				       dev->name, err);
 			goto busy;
 		}
 
@@ -525,8 +524,7 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 	err = hw->ops->bap_pwrite(hw, USER_BAP, skb->data, skb->len,
 				  txfid, HERMES_802_3_OFFSET);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d writing packet to BAP\n",
-		       dev->name, err);
+		pr_err("%s: Error %d writing packet to BAP\n", dev->name, err);
 		goto busy;
 	}
 
@@ -541,7 +539,7 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 		err = hw->ops->bap_pwrite(hw, USER_BAP, &mic_buf[0], len,
 					  txfid, offset);
 		if (err) {
-			printk(KERN_ERR "%s: Error %d writing MIC to BAP\n",
+			pr_err("%s: Error %d writing MIC to BAP\n",
 			       dev->name, err);
 			goto busy;
 		}
@@ -555,8 +553,8 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (err) {
 		netif_start_queue(dev);
 		if (net_ratelimit())
-			printk(KERN_ERR "%s: Error %d transmitting packet\n",
-				dev->name, err);
+			pr_err("%s: Error %d transmitting packet\n",
+			       dev->name, err);
 		goto busy;
 	}
 
@@ -586,8 +584,8 @@ static void __orinoco_ev_alloc(struct net_device *dev, struct hermes *hw)
 
 	if (fid != priv->txfid) {
 		if (fid != DUMMY_FID)
-			printk(KERN_WARNING "%s: Allocate event on unexpected fid (%04X)\n",
-			       dev->name, fid);
+			pr_warn("%s: Allocate event on unexpected fid (%04X)\n",
+				dev->name, fid);
 		return;
 	}
 
@@ -627,9 +625,8 @@ static void __orinoco_ev_txexc(struct net_device *dev, struct hermes *hw)
 	stats->tx_errors++;
 
 	if (err) {
-		printk(KERN_WARNING "%s: Unable to read descriptor on Tx error "
-		       "(FID=%04X error %d)\n",
-		       dev->name, fid, err);
+		pr_warn("%s: Unable to read descriptor on Tx error (FID=%04X error %d)\n",
+			dev->name, fid, err);
 		return;
 	}
 
@@ -668,10 +665,9 @@ void orinoco_tx_timeout(struct net_device *dev)
 	struct net_device_stats *stats = &priv->stats;
 	struct hermes *hw = &priv->hw;
 
-	printk(KERN_WARNING "%s: Tx timeout! "
-	       "ALLOCFID=%04x, TXCOMPLFID=%04x, EVSTAT=%04x\n",
-	       dev->name, hermes_read_regn(hw, ALLOCFID),
-	       hermes_read_regn(hw, TXCOMPLFID), hermes_read_regn(hw, EVSTAT));
+	pr_warn("%s: Tx timeout! ALLOCFID=%04x, TXCOMPLFID=%04x, EVSTAT=%04x\n",
+		dev->name, hermes_read_regn(hw, ALLOCFID),
+		hermes_read_regn(hw, TXCOMPLFID), hermes_read_regn(hw, EVSTAT));
 
 	stats->tx_errors++;
 
@@ -793,16 +789,16 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 
 	/* sanity check the length */
 	if (datalen > IEEE80211_MAX_DATA_LEN + 12) {
-		printk(KERN_DEBUG "%s: oversized monitor frame, "
-		       "data length = %d\n", dev->name, datalen);
+		pr_debug("%s: oversized monitor frame, data length = %d\n",
+			 dev->name, datalen);
 		stats->rx_length_errors++;
 		goto update_stats;
 	}
 
 	skb = dev_alloc_skb(hdrlen + datalen);
 	if (!skb) {
-		printk(KERN_WARNING "%s: Cannot allocate skb for monitor frame\n",
-		       dev->name);
+		pr_warn("%s: Cannot allocate skb for monitor frame\n",
+			dev->name);
 		goto update_stats;
 	}
 
@@ -816,7 +812,7 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 					 ALIGN(datalen, 2), rxfid,
 					 HERMES_802_2_OFFSET);
 		if (err) {
-			printk(KERN_ERR "%s: error %d reading monitor frame\n",
+			pr_err("%s: error %d reading monitor frame\n",
 			       dev->name, err);
 			goto drop;
 		}
@@ -854,9 +850,8 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 
 	desc = kmalloc(sizeof(*desc), GFP_ATOMIC);
 	if (!desc) {
-		printk(KERN_WARNING
-		       "%s: Can't allocate space for RX descriptor\n",
-		       dev->name);
+		pr_warn("%s: Can't allocate space for RX descriptor\n",
+			dev->name);
 		goto update_stats;
 	}
 
@@ -865,8 +860,8 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 	err = hw->ops->bap_pread(hw, IRQ_BAP, desc, sizeof(*desc),
 				 rxfid, 0);
 	if (err) {
-		printk(KERN_ERR "%s: error %d reading Rx descriptor. "
-		       "Frame dropped.\n", dev->name, err);
+		pr_err("%s: error %d reading Rx descriptor. Frame dropped.\n",
+		       dev->name, err);
 		goto update_stats;
 	}
 
@@ -902,8 +897,8 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 		goto out;
 	}
 	if (length > IEEE80211_MAX_DATA_LEN) {
-		printk(KERN_WARNING "%s: Oversized frame received (%d bytes)\n",
-		       dev->name, length);
+		pr_warn("%s: Oversized frame received (%d bytes)\n",
+			dev->name, length);
 		stats->rx_length_errors++;
 		goto update_stats;
 	}
@@ -920,8 +915,7 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 	   bits */
 	skb = dev_alloc_skb(length + ETH_HLEN + 2 + 1);
 	if (!skb) {
-		printk(KERN_WARNING "%s: Can't allocate skb for Rx\n",
-		       dev->name);
+		pr_warn("%s: Can't allocate skb for Rx\n", dev->name);
 		goto update_stats;
 	}
 
@@ -934,8 +928,8 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 				 ALIGN(length, 2), rxfid,
 				 HERMES_802_2_OFFSET);
 	if (err) {
-		printk(KERN_ERR "%s: error %d reading frame. "
-		       "Frame dropped.\n", dev->name, err);
+		pr_err("%s: error %d reading frame. Frame dropped.\n",
+		       dev->name, err);
 		goto drop;
 	}
 
@@ -994,9 +988,8 @@ static void orinoco_rx(struct net_device *dev,
 		key = (struct orinoco_tkip_key *) priv->keys[key_id].key;
 
 		if (!key) {
-			printk(KERN_WARNING "%s: Received encrypted frame from "
-			       "%pM using key %i, but key is not installed\n",
-			       dev->name, src, key_id);
+			pr_warn("%s: Received encrypted frame from %pM using key %i, but key is not installed\n",
+				dev->name, src, key_id);
 			goto drop;
 		}
 
@@ -1009,10 +1002,8 @@ static void orinoco_rx(struct net_device *dev,
 			union iwreq_data wrqu;
 			struct iw_michaelmicfailure wxmic;
 
-			printk(KERN_WARNING "%s: "
-			       "Invalid Michael MIC in data frame from %pM, "
-			       "using key %i\n",
-			       dev->name, src, key_id);
+			pr_warn("%s: Invalid Michael MIC in data frame from %pM, using key %i\n",
+				dev->name, src, key_id);
 
 			/* TODO: update stats */
 
@@ -1152,8 +1143,7 @@ static void print_linkstatus(struct net_device *dev, u16 status)
 		s = "UNKNOWN";
 	}
 
-	printk(KERN_DEBUG "%s: New link status: %s (%04x)\n",
-	       dev->name, s, status);
+	pr_debug("%s: New link status: %s (%04x)\n", dev->name, s, status);
 }
 
 /* Search scan results for requested BSSID, join it if found */
@@ -1196,8 +1186,7 @@ static void orinoco_join_ap(struct work_struct *work)
 				HERMES_RID_SCANRESULTSTABLE,
 				MAX_SCAN_LEN, &len, buf);
 	if (err) {
-		printk(KERN_ERR "%s: Cannot read scan results\n",
-		       dev->name);
+		pr_err("%s: Cannot read scan results\n", dev->name);
 		goto out;
 	}
 
@@ -1224,7 +1213,7 @@ static void orinoco_join_ap(struct work_struct *work)
 	err = HERMES_WRITE_RECORD(hw, USER_BAP, HERMES_RID_CNFJOINREQUEST,
 				  &req);
 	if (err)
-		printk(KERN_ERR "%s: Error issuing join request\n", dev->name);
+		pr_err("%s: Error issuing join request\n", dev->name);
 
  out:
 	orinoco_unlock(priv, &flags);
@@ -1337,7 +1326,7 @@ static void qbuf_scan(struct orinoco_private *priv, void *buf,
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
 	if (!sd) {
-		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		pr_err("%s: failed to alloc memory\n", __func__);
 		return;
 	}
 	sd->buf = buf;
@@ -1358,7 +1347,7 @@ static void qabort_scan(struct orinoco_private *priv)
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
 	if (!sd) {
-		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+		pr_err("%s: failed to alloc memory\n", __func__);
 		return;
 	}
 	sd->len = -1; /* Abort */
@@ -1429,8 +1418,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 	err = hw->ops->bap_pread(hw, IRQ_BAP, &info, sizeof(info),
 				 infofid, 0);
 	if (err) {
-		printk(KERN_ERR "%s: error %d reading info frame. "
-		       "Frame dropped.\n", dev->name, err);
+		pr_err("%s: error %d reading info frame. Frame dropped.\n",
+		       dev->name, err);
 		return;
 	}
 
@@ -1443,8 +1432,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 		struct iw_statistics *wstats = &priv->wstats;
 
 		if (len > sizeof(tallies)) {
-			printk(KERN_WARNING "%s: Tallies frame too long (%d bytes)\n",
-			       dev->name, len);
+			pr_warn("%s: Tallies frame too long (%d bytes)\n",
+				dev->name, len);
 			len = sizeof(tallies);
 		}
 
@@ -1479,8 +1468,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 			break;
 
 		if (len != sizeof(linkstatus)) {
-			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
-			       dev->name, len);
+			pr_warn("%s: Unexpected size for linkstatus frame (%d bytes)\n",
+				dev->name, len);
 			break;
 		}
 
@@ -1534,8 +1523,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 
 		/* Sanity check */
 		if (len > 4096) {
-			printk(KERN_WARNING "%s: Scan results too large (%d bytes)\n",
-			       dev->name, len);
+			pr_warn("%s: Scan results too large (%d bytes)\n",
+				dev->name, len);
 			qabort_scan(priv);
 			break;
 		}
@@ -1560,10 +1549,10 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 #ifdef ORINOCO_DEBUG
 		{
 			int	i;
-			printk(KERN_DEBUG "Scan result [%02X", buf[0]);
+			pr_debug("Scan result [%02X", buf[0]);
 			for (i = 1; i < (len * 2); i++)
-				printk(":%02X", buf[i]);
-			printk("]\n");
+				pr_cont(":%02X", buf[i]);
+			pr_cont("]\n");
 		}
 #endif	/* ORINOCO_DEBUG */
 
@@ -1575,8 +1564,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 		struct agere_ext_scan_info *bss;
 
 		if (!priv->scan_request) {
-			printk(KERN_DEBUG "%s: Got chaninfo without scan, "
-			       "len=%d\n", dev->name, len);
+			pr_debug("%s: Got chaninfo without scan, len=%d\n",
+				 dev->name, len);
 			break;
 		}
 
@@ -1591,9 +1580,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 					   data) + 2)) {
 			/* Drop this result now so we don't have to
 			 * keep checking later */
-			printk(KERN_WARNING
-			       "%s: Ext scan results too short (%d bytes)\n",
-			       dev->name, len);
+			pr_warn("%s: Ext scan results too short (%d bytes)\n",
+				dev->name, len);
 			break;
 		}
 
@@ -1618,8 +1606,8 @@ void __orinoco_ev_info(struct net_device *dev, struct hermes *hw)
 			break;
 		/* fall through */
 	default:
-		printk(KERN_DEBUG "%s: Unknown information frame received: "
-		       "type 0x%04x, length %d\n", dev->name, type, len);
+		pr_debug("%s: Unknown information frame received: type 0x%04x, length %d\n",
+			 dev->name, type, len);
 		/* We don't actually do anything about it */
 		break;
 	}
@@ -1629,7 +1617,7 @@ EXPORT_SYMBOL(__orinoco_ev_info);
 static void __orinoco_ev_infdrop(struct net_device *dev, struct hermes *hw)
 {
 	if (net_ratelimit())
-		printk(KERN_DEBUG "%s: Information frame lost.\n", dev->name);
+		pr_debug("%s: Information frame lost\n", dev->name);
 }
 
 /********************************************************************/
@@ -1646,8 +1634,7 @@ static int __orinoco_up(struct orinoco_private *priv)
 
 	err = __orinoco_commit(priv);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d configuring card\n",
-		       dev->name, err);
+		pr_err("%s: Error %d configuring card\n", dev->name, err);
 		return err;
 	}
 
@@ -1655,8 +1642,7 @@ static int __orinoco_up(struct orinoco_private *priv)
 	hermes_set_irqmask(hw, ORINOCO_INTEN);
 	err = hermes_enable_port(hw, 0);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d enabling MAC port\n",
-		       dev->name, err);
+		pr_err("%s: Error %d enabling MAC port\n", dev->name, err);
 		return err;
 	}
 
@@ -1680,8 +1666,8 @@ static int __orinoco_down(struct orinoco_private *priv)
 				/* Some firmwares (e.g. Intersil 1.3.x) seem
 				 * to have problems disabling the port, oh
 				 * well, too bad. */
-				printk(KERN_WARNING "%s: Error %d disabling MAC port\n",
-				       dev->name, err);
+				pr_warn("%s: Error %d disabling MAC port\n",
+					dev->name, err);
 				priv->broken_disableport = 1;
 			}
 		}
@@ -1774,15 +1760,15 @@ void orinoco_reset(struct work_struct *work)
 	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
 		if (err) {
-			printk(KERN_ERR "%s: orinoco_reset: Error %d "
-			       "performing hard reset\n", dev->name, err);
+			pr_err("%s: orinoco_reset: Error %d performing hard reset\n",
+			       dev->name, err);
 			goto disable;
 		}
 	}
 
 	err = orinoco_reinit_firmware(priv);
 	if (err) {
-		printk(KERN_ERR "%s: orinoco_reset: Error %d re-initializing firmware\n",
+		pr_err("%s: orinoco_reset: Error %d re-initializing firmware\n",
 		       dev->name, err);
 		goto disable;
 	}
@@ -1797,7 +1783,7 @@ void orinoco_reset(struct work_struct *work)
 	if (priv->open && (!priv->hw_unavailable)) {
 		err = __orinoco_up(priv);
 		if (err) {
-			printk(KERN_ERR "%s: orinoco_reset: Error %d reenabling card\n",
+			pr_err("%s: orinoco_reset: Error %d reenabling card\n",
 			       dev->name, err);
 		} else
 			dev->trans_start = jiffies;
@@ -1809,7 +1795,7 @@ void orinoco_reset(struct work_struct *work)
  disable:
 	hermes_set_irqmask(hw, 0);
 	netif_device_detach(dev);
-	printk(KERN_ERR "%s: Device has been disabled!\n", dev->name);
+	pr_err("%s: Device has been disabled!\n", dev->name);
 }
 
 static int __orinoco_commit(struct orinoco_private *priv)
@@ -1847,29 +1833,28 @@ int orinoco_commit(struct orinoco_private *priv)
 
 	err = hermes_disable_port(hw, 0);
 	if (err) {
-		printk(KERN_WARNING "%s: Unable to disable port "
-		       "while reconfiguring card\n", dev->name);
+		pr_warn("%s: Unable to disable port while reconfiguring card\n",
+			dev->name);
 		priv->broken_disableport = 1;
 		goto out;
 	}
 
 	err = __orinoco_commit(priv);
 	if (err) {
-		printk(KERN_WARNING "%s: Unable to reconfigure card\n",
-		       dev->name);
+		pr_warn("%s: Unable to reconfigure card\n", dev->name);
 		goto out;
 	}
 
 	err = hermes_enable_port(hw, 0);
 	if (err) {
-		printk(KERN_WARNING "%s: Unable to enable port while reconfiguring card\n",
-		       dev->name);
+		pr_warn("%s: Unable to enable port while reconfiguring card\n",
+			dev->name);
 		goto out;
 	}
 
  out:
 	if (err) {
-		printk(KERN_WARNING "%s: Resetting instead...\n", dev->name);
+		pr_warn("%s: Resetting instead...\n", dev->name);
 		schedule_work(&priv->reset_work);
 		err = 0;
 	}
@@ -1882,15 +1867,15 @@ int orinoco_commit(struct orinoco_private *priv)
 
 static void __orinoco_ev_tick(struct net_device *dev, struct hermes *hw)
 {
-	printk(KERN_DEBUG "%s: TICK\n", dev->name);
+	pr_debug("%s: TICK\n", dev->name);
 }
 
 static void __orinoco_ev_wterr(struct net_device *dev, struct hermes *hw)
 {
 	/* This seems to happen a fair bit under load, but ignoring it
 	   seems to work fine...*/
-	printk(KERN_DEBUG "%s: MAC controller error (WTERR). Ignoring.\n",
-	       dev->name);
+	pr_debug("%s: MAC controller error (WTERR). Ignoring.\n",
+		 dev->name);
 }
 
 irqreturn_t orinoco_interrupt(int irq, void *dev_id)
@@ -1929,8 +1914,8 @@ irqreturn_t orinoco_interrupt(int irq, void *dev_id)
 
 	while (events && count--) {
 		if (++loops_this_jiffy > MAX_IRQLOOPS_PER_JIFFY) {
-			printk(KERN_WARNING "%s: IRQ handler is looping too "
-			       "much! Resetting.\n", dev->name);
+			pr_warn("%s: IRQ handler is looping too much! Resetting.\n",
+				dev->name);
 			/* Disable interrupts for now */
 			hermes_set_irqmask(hw, 0);
 			schedule_work(&priv->reset_work);
@@ -2374,7 +2359,7 @@ int orinoco_up(struct orinoco_private *priv)
 
 	err = orinoco_reinit_firmware(priv);
 	if (err) {
-		printk(KERN_ERR "%s: Error %d re-initializing firmware\n",
+		pr_err("%s: Error %d re-initializing firmware\n",
 		       dev->name, err);
 		goto exit;
 	}
@@ -2385,7 +2370,7 @@ int orinoco_up(struct orinoco_private *priv)
 	if (priv->open && !priv->hw_unavailable) {
 		err = __orinoco_up(priv);
 		if (err)
-			printk(KERN_ERR "%s: Error %d restarting card\n",
+			pr_err("%s: Error %d restarting card\n",
 			       dev->name, err);
 	}
 
@@ -2405,8 +2390,7 @@ void orinoco_down(struct orinoco_private *priv)
 	priv->hw.ops->lock_irqsave(&priv->lock, &flags);
 	err = __orinoco_down(priv);
 	if (err)
-		printk(KERN_WARNING "%s: Error %d downing interface\n",
-		       dev->name, err);
+		pr_warn("%s: Error %d downing interface\n", dev->name, err);
 
 	netif_device_detach(dev);
 	priv->hw_unavailable++;
@@ -2426,7 +2410,7 @@ static char version[] __initdata = DRIVER_NAME " " DRIVER_VERSION
 
 static int __init init_orinoco(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 	return 0;
 }
 
diff --git a/drivers/net/wireless/orinoco/mic.c b/drivers/net/wireless/orinoco/mic.c
index fce4a84..2263c14 100644
--- a/drivers/net/wireless/orinoco/mic.c
+++ b/drivers/net/wireless/orinoco/mic.c
@@ -2,6 +2,9 @@
  *
  * See copyright notice in main.c
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/if_ether.h>
@@ -18,16 +21,16 @@ int orinoco_mic_init(struct orinoco_private *priv)
 {
 	priv->tx_tfm_mic = crypto_alloc_hash("michael_mic", 0, 0);
 	if (IS_ERR(priv->tx_tfm_mic)) {
-		printk(KERN_DEBUG "orinoco_mic_init: could not allocate "
-		       "crypto API michael_mic\n");
+		pr_debug("%s: could not allocate crypto API michael_mic\n",
+			 __func__);
 		priv->tx_tfm_mic = NULL;
 		return -ENOMEM;
 	}
 
 	priv->rx_tfm_mic = crypto_alloc_hash("michael_mic", 0, 0);
 	if (IS_ERR(priv->rx_tfm_mic)) {
-		printk(KERN_DEBUG "orinoco_mic_init: could not allocate "
-		       "crypto API michael_mic\n");
+		pr_debug("%s: could not allocate crypto API michael_mic\n",
+			 __func__);
 		priv->rx_tfm_mic = NULL;
 		return -ENOMEM;
 	}
@@ -52,7 +55,7 @@ int orinoco_mic(struct crypto_hash *tfm_michael, u8 *key,
 	u8 hdr[ETH_HLEN + 2]; /* size of header + padding */
 
 	if (tfm_michael == NULL) {
-		printk(KERN_WARNING "orinoco_mic: tfm_michael == NULL\n");
+		pr_warn("%s: tfm_michael == NULL\n", __func__);
 		return -1;
 	}
 
diff --git a/drivers/net/wireless/orinoco/orinoco.h b/drivers/net/wireless/orinoco/orinoco.h
index 3bb936b..b63a71a 100644
--- a/drivers/net/wireless/orinoco/orinoco.h
+++ b/drivers/net/wireless/orinoco/orinoco.h
@@ -170,12 +170,17 @@ struct orinoco_private {
 
 #ifdef ORINOCO_DEBUG
 extern int orinoco_debug;
-#define DEBUG(n, args...) do { \
-	if (orinoco_debug > (n)) \
-		printk(KERN_DEBUG args); \
+#define DEBUG(n, fmt, ...)				\
+do {							\
+	if (orinoco_debug > (n))			\
+		pr_debug(fmt, ##__VA_ARGS__);		\
 } while (0)
 #else
-#define DEBUG(n, args...) do { } while (0)
+#define DEBUG(n, fmt, ...)				\
+do {							\
+	if (0)						\
+		pr_debug(fmt, ##__VA_ARGS__);		\
+} while (0)
 #endif	/* ORINOCO_DEBUG */
 
 /********************************************************************/
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index d7dbc00..ed4b834 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -10,8 +10,9 @@
  * Copyright notice & release notes in file main.c
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_cs"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -145,9 +146,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 	ret = pcmcia_loop_config(link, orinoco_cs_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
-			printk(KERN_ERR PFX "GetNextTuple(): No matching "
-			       "CIS configuration.  Maybe you need the "
-			       "ignore_cis_vcc=1 parameter.\n");
+			pr_err("GetNextTuple(): No matching CIS configuration.  Maybe you need the ignore_cis_vcc=1 parameter.\n");
 		goto failed;
 	}
 
@@ -171,14 +170,14 @@ orinoco_cs_config(struct pcmcia_device *link)
 
 	/* Initialise the main driver */
 	if (orinoco_init(priv) != 0) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto failed;
 	}
 
 	/* Register an interface with the stack */
 	if (orinoco_if_add(priv, link->resource[0]->start,
 			   link->irq, NULL) != 0) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto failed;
 	}
 
diff --git a/drivers/net/wireless/orinoco/orinoco_nortel.c b/drivers/net/wireless/orinoco/orinoco_nortel.c
index 326396b..1a2750f 100644
--- a/drivers/net/wireless/orinoco/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco/orinoco_nortel.c
@@ -37,8 +37,9 @@
  * under either the MPL or the GPL.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_nortel"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -94,7 +95,7 @@ static int orinoco_nortel_hw_init(struct orinoco_pci_card *card)
 
 	/* Setup bridge */
 	if (ioread16(card->bridge_io) & 1) {
-		printk(KERN_ERR PFX "brg1 answer1 wrong\n");
+		pr_err("brg1 answer1 wrong\n");
 		return -EBUSY;
 	}
 	iowrite16(0x118, card->bridge_io + 2);
@@ -107,19 +108,19 @@ static int orinoco_nortel_hw_init(struct orinoco_pci_card *card)
 			break;
 	}
 	if (i == 30) {
-		printk(KERN_ERR PFX "brg1 timed out\n");
+		pr_err("brg1 timed out\n");
 		return -EBUSY;
 	}
 	if (ioread16(card->attr_io + COR_OFFSET) & 1) {
-		printk(KERN_ERR PFX "brg2 answer1 wrong\n");
+		pr_err("brg2 answer1 wrong\n");
 		return -EBUSY;
 	}
 	if (ioread16(card->attr_io + COR_OFFSET + 2) & 1) {
-		printk(KERN_ERR PFX "brg2 answer2 wrong\n");
+		pr_err("brg2 answer2 wrong\n");
 		return -EBUSY;
 	}
 	if (ioread16(card->attr_io + COR_OFFSET + 4) & 1) {
-		printk(KERN_ERR PFX "brg2 answer3 wrong\n");
+		pr_err("brg2 answer3 wrong\n");
 		return -EBUSY;
 	}
 
@@ -128,8 +129,7 @@ static int orinoco_nortel_hw_init(struct orinoco_pci_card *card)
 	mdelay(1);
 	reg = ioread16(card->attr_io + COR_OFFSET);
 	if (reg != COR_VALUE) {
-		printk(KERN_ERR PFX "Error setting COR value (reg=%x)\n",
-		       reg);
+		pr_err("Error setting COR value (reg=%x)\n", reg);
 		return -EBUSY;
 	}
 
@@ -148,33 +148,33 @@ static int orinoco_nortel_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		pr_err("Cannot enable PCI device\n");
 		return err;
 	}
 
 	err = pci_request_regions(pdev, DRIVER_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		pr_err("Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
 
 	bridge_io = pci_iomap(pdev, 0, 0);
 	if (!bridge_io) {
-		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		pr_err("Cannot map bridge registers\n");
 		err = -EIO;
 		goto fail_map_bridge;
 	}
 
 	attr_io = pci_iomap(pdev, 1, 0);
 	if (!attr_io) {
-		printk(KERN_ERR PFX "Cannot map PCMCIA attributes\n");
+		pr_err("Cannot map PCMCIA attributes\n");
 		err = -EIO;
 		goto fail_map_attr;
 	}
 
 	hermes_io = pci_iomap(pdev, 2, 0);
 	if (!hermes_io) {
-		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		pr_err("Cannot map chipset registers\n");
 		err = -EIO;
 		goto fail_map_hermes;
 	}
@@ -183,7 +183,7 @@ static int orinoco_nortel_init_one(struct pci_dev *pdev,
 	priv = alloc_orinocodev(sizeof(*card), &pdev->dev,
 				orinoco_nortel_cor_reset, NULL);
 	if (!priv) {
-		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		pr_err("Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail_alloc;
 	}
@@ -197,32 +197,32 @@ static int orinoco_nortel_init_one(struct pci_dev *pdev,
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
 			  DRIVER_NAME, priv);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
+		pr_err("Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
 		goto fail_irq;
 	}
 
 	err = orinoco_nortel_hw_init(card);
 	if (err) {
-		printk(KERN_ERR PFX "Hardware initialization failed\n");
+		pr_err("Hardware initialization failed\n");
 		goto fail;
 	}
 
 	err = orinoco_nortel_cor_reset(priv);
 	if (err) {
-		printk(KERN_ERR PFX "Initial reset failed\n");
+		pr_err("Initial reset failed\n");
 		goto fail;
 	}
 
 	err = orinoco_init(priv);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto fail;
 	}
 
 	err = orinoco_if_add(priv, 0, 0, NULL);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto fail;
 	}
 
@@ -301,7 +301,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 static int __init orinoco_nortel_init(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 	return pci_register_driver(&orinoco_nortel_driver);
 }
 
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.c b/drivers/net/wireless/orinoco/orinoco_pci.c
index 6058c66..fd7b0ed 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco/orinoco_pci.c
@@ -41,8 +41,9 @@
  * under either the MPL or the GPL.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_pci"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -103,7 +104,7 @@ static int orinoco_pci_cor_reset(struct orinoco_private *priv)
 
 	/* Still busy? */
 	if (reg & HERMES_CMD_BUSY) {
-		printk(KERN_ERR PFX "Busy timeout\n");
+		pr_err("Busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -120,19 +121,19 @@ static int orinoco_pci_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		pr_err("Cannot enable PCI device\n");
 		return err;
 	}
 
 	err = pci_request_regions(pdev, DRIVER_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		pr_err("Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
 
 	hermes_io = pci_iomap(pdev, 0, 0);
 	if (!hermes_io) {
-		printk(KERN_ERR PFX "Cannot remap chipset registers\n");
+		pr_err("Cannot remap chipset registers\n");
 		err = -EIO;
 		goto fail_map_hermes;
 	}
@@ -141,7 +142,7 @@ static int orinoco_pci_init_one(struct pci_dev *pdev,
 	priv = alloc_orinocodev(sizeof(*card), &pdev->dev,
 				orinoco_pci_cor_reset, NULL);
 	if (!priv) {
-		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		pr_err("Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail_alloc;
 	}
@@ -153,26 +154,26 @@ static int orinoco_pci_init_one(struct pci_dev *pdev,
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
 			  DRIVER_NAME, priv);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
+		pr_err("Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
 		goto fail_irq;
 	}
 
 	err = orinoco_pci_cor_reset(priv);
 	if (err) {
-		printk(KERN_ERR PFX "Initial reset failed\n");
+		pr_err("Initial reset failed\n");
 		goto fail;
 	}
 
 	err = orinoco_init(priv);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto fail;
 	}
 
 	err = orinoco_if_add(priv, 0, 0, NULL);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto fail;
 	}
 
@@ -244,7 +245,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 static int __init orinoco_pci_init(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 	return pci_register_driver(&orinoco_pci_driver);
 }
 
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.h b/drivers/net/wireless/orinoco/orinoco_pci.h
index ea7231a..8985975 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco/orinoco_pci.h
@@ -41,8 +41,7 @@ static int orinoco_pci_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, 0);
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
-		       dev->name);
+		pr_err("%s: pci_enable_device failed on resume\n", dev->name);
 		return err;
 	}
 	pci_restore_state(pdev);
@@ -50,8 +49,7 @@ static int orinoco_pci_resume(struct pci_dev *pdev)
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
 			  dev->name, priv);
 	if (err) {
-		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
-		       dev->name);
+		pr_err("%s: cannot re-allocate IRQ on resume\n", dev->name);
 		pci_disable_device(pdev);
 		return -EBUSY;
 	}
diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/orinoco/orinoco_plx.c
index 2bac824..4d20f62 100644
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -83,8 +83,9 @@
  * radio card's firmware locks up).
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_plx"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -130,7 +131,7 @@ static int orinoco_plx_cor_reset(struct orinoco_private *priv)
 
 	/* Still busy? */
 	if (reg & HERMES_CMD_BUSY) {
-		printk(KERN_ERR PFX "Busy timeout\n");
+		pr_err("Busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -145,17 +146,16 @@ static int orinoco_plx_hw_init(struct orinoco_pci_card *card)
 		0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
 	};
 
-	printk(KERN_DEBUG PFX "CIS: ");
+	pr_debug("CIS: ");
 	for (i = 0; i < 16; i++)
-		printk("%02X:", ioread8(card->attr_io + (i << 1)));
-	printk("\n");
+		pr_cont("%02X:", ioread8(card->attr_io + (i << 1)));
+	pr_cont("\n");
 
 	/* Verify whether a supported PC card is present */
 	/* FIXME: we probably need to be smarted about this */
 	for (i = 0; i < sizeof(cis_magic); i++) {
 		if (cis_magic[i] != ioread8(card->attr_io + (i << 1))) {
-			printk(KERN_ERR PFX "The CIS value of Prism2 PC "
-			       "card is unexpected\n");
+			pr_err("The CIS value of Prism2 PC card is unexpected\n");
 			return -ENODEV;
 		}
 	}
@@ -169,7 +169,7 @@ static int orinoco_plx_hw_init(struct orinoco_pci_card *card)
 		iowrite32(csr_reg, card->bridge_io + PLX_INTCSR);
 		csr_reg = ioread32(card->bridge_io + PLX_INTCSR);
 		if (!(csr_reg & PLX_INTCSR_INTEN)) {
-			printk(KERN_ERR PFX "Cannot enable interrupts\n");
+			pr_err("Cannot enable interrupts\n");
 			return -EIO;
 		}
 	}
@@ -187,33 +187,33 @@ static int orinoco_plx_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		pr_err("Cannot enable PCI device\n");
 		return err;
 	}
 
 	err = pci_request_regions(pdev, DRIVER_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		pr_err("Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
 
 	bridge_io = pci_iomap(pdev, 1, 0);
 	if (!bridge_io) {
-		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		pr_err("Cannot map bridge registers\n");
 		err = -EIO;
 		goto fail_map_bridge;
 	}
 
 	attr_io = pci_iomap(pdev, 2, 0);
 	if (!attr_io) {
-		printk(KERN_ERR PFX "Cannot map PCMCIA attributes\n");
+		pr_err("Cannot map PCMCIA attributes\n");
 		err = -EIO;
 		goto fail_map_attr;
 	}
 
 	hermes_io = pci_iomap(pdev, 3, 0);
 	if (!hermes_io) {
-		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		pr_err("Cannot map chipset registers\n");
 		err = -EIO;
 		goto fail_map_hermes;
 	}
@@ -222,7 +222,7 @@ static int orinoco_plx_init_one(struct pci_dev *pdev,
 	priv = alloc_orinocodev(sizeof(*card), &pdev->dev,
 				orinoco_plx_cor_reset, NULL);
 	if (!priv) {
-		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		pr_err("Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail_alloc;
 	}
@@ -236,32 +236,32 @@ static int orinoco_plx_init_one(struct pci_dev *pdev,
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
 			  DRIVER_NAME, priv);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
+		pr_err("Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
 		goto fail_irq;
 	}
 
 	err = orinoco_plx_hw_init(card);
 	if (err) {
-		printk(KERN_ERR PFX "Hardware initialization failed\n");
+		pr_err("Hardware initialization failed\n");
 		goto fail;
 	}
 
 	err = orinoco_plx_cor_reset(priv);
 	if (err) {
-		printk(KERN_ERR PFX "Initial reset failed\n");
+		pr_err("Initial reset failed\n");
 		goto fail;
 	}
 
 	err = orinoco_init(priv);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto fail;
 	}
 
 	err = orinoco_if_add(priv, 0, 0, NULL);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto fail;
 	}
 
@@ -349,7 +349,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 static int __init orinoco_plx_init(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 	return pci_register_driver(&orinoco_plx_driver);
 }
 
diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/orinoco/orinoco_tmd.c
index 93159d6..be6883c 100644
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -37,8 +37,9 @@
  * Pheecom sells cards with the TMD chip as "ASIC version"
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_tmd"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -80,7 +81,7 @@ static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
 
 	/* Still busy? */
 	if (reg & HERMES_CMD_BUSY) {
-		printk(KERN_ERR PFX "Busy timeout\n");
+		pr_err("Busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -98,26 +99,26 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		pr_err("Cannot enable PCI device\n");
 		return err;
 	}
 
 	err = pci_request_regions(pdev, DRIVER_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		pr_err("Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
 
 	bridge_io = pci_iomap(pdev, 1, 0);
 	if (!bridge_io) {
-		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		pr_err("Cannot map bridge registers\n");
 		err = -EIO;
 		goto fail_map_bridge;
 	}
 
 	hermes_io = pci_iomap(pdev, 2, 0);
 	if (!hermes_io) {
-		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		pr_err("Cannot map chipset registers\n");
 		err = -EIO;
 		goto fail_map_hermes;
 	}
@@ -126,7 +127,7 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 	priv = alloc_orinocodev(sizeof(*card), &pdev->dev,
 				orinoco_tmd_cor_reset, NULL);
 	if (!priv) {
-		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		pr_err("Cannot allocate network device\n");
 		err = -ENOMEM;
 		goto fail_alloc;
 	}
@@ -139,26 +140,26 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 	err = request_irq(pdev->irq, orinoco_interrupt, IRQF_SHARED,
 			  DRIVER_NAME, priv);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
+		pr_err("Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
 		goto fail_irq;
 	}
 
 	err = orinoco_tmd_cor_reset(priv);
 	if (err) {
-		printk(KERN_ERR PFX "Initial reset failed\n");
+		pr_err("Initial reset failed\n");
 		goto fail;
 	}
 
 	err = orinoco_init(priv);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto fail;
 	}
 
 	err = orinoco_if_add(priv, 0, 0, NULL);
 	if (err) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err("orinoco_if_add() failed\n");
 		goto fail;
 	}
 
@@ -227,7 +228,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 
 static int __init orinoco_tmd_init(void)
 {
-	printk(KERN_DEBUG "%s\n", version);
+	pr_debug("%s\n", version);
 	return pci_register_driver(&orinoco_tmd_driver);
 }
 
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index 7f53cea2..99b0972 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -43,8 +43,9 @@
  * gone so MPL/GPL applies.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRIVER_NAME "orinoco_usb"
-#define PFX DRIVER_NAME ": "
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -109,12 +110,12 @@ static int debug;
 
 /* Debugging macros */
 #undef dbg
-#define dbg(format, arg...) \
-	do { if (debug) printk(KERN_DEBUG PFX "%s: " format "\n", \
-			       __func__ , ## arg); } while (0)
-#undef err
-#define err(format, arg...) \
-	do { printk(KERN_ERR PFX format "\n", ## arg); } while (0)
+#define dbg(format, ...)					\
+do {								\
+	if (debug)						\
+		pr_debug("%s: " format,				\
+			 __func__, ##__VA_ARGS__);		\
+} while (0)
 
 /* Module paramaters */
 module_param(debug, int, 0644);
@@ -439,13 +440,13 @@ static void ezusb_ctx_complete(struct request_context *ctx)
 		if (!upriv->udev) {
 			/* This is normal, as all request contexts get flushed
 			 * when the device is disconnected */
-			err("Called, CTX not terminating, but device gone");
+			pr_err("Called, CTX not terminating, but device gone\n");
 			ezusb_complete_all(&ctx->done);
 			ezusb_request_context_put(ctx);
 			break;
 		}
 
-		err("Called, CTX not in terminating state.");
+		pr_err("Called, CTX not in terminating state\n");
 		/* Things are really bad if this happens. Just leak
 		 * the CTX because it may still be linked to the
 		 * queue or the OUT urb may still be active.
@@ -494,8 +495,8 @@ static void ezusb_req_queue_run(struct ezusb_priv *upriv)
 
 			spin_unlock_irqrestore(&upriv->req_lock, flags);
 
-			err("Fatal, failed to submit command urb."
-			    " error=%d\n", result);
+			pr_err("Fatal, failed to submit command urb. error=%d\n",
+			       result);
 
 			ezusb_ctx_complete(ctx);
 			ezusb_request_context_put(ctx);
@@ -549,7 +550,7 @@ static void ezusb_request_out_callback(struct urb *urb)
 
 	if (ctx->killed) {
 		spin_unlock_irqrestore(&upriv->req_lock, flags);
-		pr_warning("interrupt called with dead ctx");
+		pr_warn("interrupt called with dead ctx");
 		goto out;
 	}
 
@@ -577,8 +578,8 @@ static void ezusb_request_out_callback(struct urb *urb)
 
 		default:
 			spin_unlock_irqrestore(&upriv->req_lock, flags);
-			err("Unexpected state(0x%x, %d) in OUT URB",
-			    state, urb->status);
+			pr_err("Unexpected state(0x%x, %d) in OUT URB\n",
+			       state, urb->status);
 			break;
 		}
 	} else {
@@ -601,8 +602,8 @@ static void ezusb_request_out_callback(struct urb *urb)
 		default:
 			spin_unlock_irqrestore(&upriv->req_lock, flags);
 
-			err("Unexpected state(0x%x, %d) in OUT URB",
-			    state, urb->status);
+			pr_err("Unexpected state(0x%x, %d) in OUT URB\n",
+			       state, urb->status);
 			break;
 		}
 	}
@@ -643,8 +644,8 @@ static void ezusb_request_in_callback(struct ezusb_priv *upriv,
 
 	if (ctx == NULL) {
 		spin_unlock_irqrestore(&upriv->req_lock, flags);
-		err("%s: got unexpected RID: 0x%04X", __func__,
-		    le16_to_cpu(ans->hermes_rid));
+		pr_err("%s: got unexpected RID: 0x%04X\n",
+		       __func__, le16_to_cpu(ans->hermes_rid));
 		ezusb_req_queue_run(upriv);
 		return;
 	}
@@ -686,7 +687,7 @@ static void ezusb_request_in_callback(struct ezusb_priv *upriv,
 	default:
 		spin_unlock_irqrestore(&upriv->req_lock, flags);
 
-		pr_warning("Matched IN URB, unexpected context state(0x%x)",
+		pr_warn("Matched IN URB, unexpected context state(0x%x)",
 		     state);
 		/* Throw this CTX away and try submitting another */
 		del_timer(&ctx->timer);
@@ -779,7 +780,7 @@ static int ezusb_submit_in_urb(struct ezusb_priv *upriv)
 	upriv->read_urb->transfer_flags = 0;
 	retval = usb_submit_urb(upriv->read_urb, GFP_ATOMIC);
 	if (retval)
-		err("%s submit failed %d", __func__, retval);
+		pr_err("%s submit failed %d\n", __func__, retval);
 
  exit:
 	return retval;
@@ -790,7 +791,7 @@ static inline int ezusb_8051_cpucs(struct ezusb_priv *upriv, int reset)
 	u8 res_val = reset;	/* avoid argument promotion */
 
 	if (!upriv->udev) {
-		err("%s: !upriv->udev", __func__);
+		pr_err("%s: !upriv->udev\n", __func__);
 		return -EFAULT;
 	}
 	return usb_control_msg(upriv->udev,
@@ -816,8 +817,8 @@ static int ezusb_firmware_download(struct ezusb_priv *upriv,
 	 */
 	variant_offset = be16_to_cpup((__be16 *) &fw->code[FW_VAR_OFFSET_PTR]);
 	if (variant_offset >= fw->size) {
-		printk(KERN_ERR PFX "Invalid firmware variant offset: "
-		       "0x%04x\n", variant_offset);
+		pr_err("Invalid firmware variant offset: 0x%04x\n",
+		       variant_offset);
 		retval = -EINVAL;
 		goto fail;
 	}
@@ -856,8 +857,7 @@ static int ezusb_firmware_download(struct ezusb_priv *upriv,
 
 	goto exit;
  fail:
-	printk(KERN_ERR PFX "Firmware download failed, error %d\n",
-	       retval);
+	pr_err("Firmware download failed, error %d\n", retval);
  exit:
 	return retval;
 }
@@ -879,7 +879,7 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
 	}
 
 	if (upriv->read_urb->status != -EINPROGRESS)
-		err("%s: in urb not pending", __func__);
+		pr_err("%s: in urb not pending\n", __func__);
 
 	/* protect upriv->reply_count, guarantee sequential numbers */
 	spin_lock_bh(&upriv->reply_count_lock);
@@ -910,22 +910,21 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
 		if (!ctx->in_rid)
 			break;
 	default:
-		err("%s: Unexpected context state %d", __func__,
-		    state);
+		pr_err("%s: Unexpected context state %d\n", __func__, state);
 		/* fall though */
 	case EZUSB_CTX_REQ_TIMEOUT:
 	case EZUSB_CTX_REQ_FAILED:
 	case EZUSB_CTX_RESP_TIMEOUT:
 	case EZUSB_CTX_REQSUBMIT_FAIL:
-		printk(KERN_ERR PFX "Access failed, resetting (state %d,"
-		       " reply_count %d)\n", state, upriv->reply_count);
+		pr_err("Access failed, resetting (state %d, reply_count %d)\n",
+		       state, upriv->reply_count);
 		upriv->reply_count = 0;
 		if (state == EZUSB_CTX_REQ_TIMEOUT
 		    || state == EZUSB_CTX_RESP_TIMEOUT) {
-			printk(KERN_ERR PFX "ctx timed out\n");
+			pr_err("ctx timed out\n");
 			retval = -ETIMEDOUT;
 		} else {
-			printk(KERN_ERR PFX "ctx failed\n");
+			pr_err("ctx failed\n");
 			retval = -EFAULT;
 		}
 		goto exit;
@@ -941,9 +940,8 @@ static int ezusb_access_ltv(struct ezusb_priv *upriv,
 			exp_len = 14;
 
 		if (exp_len != ctx->buf_length) {
-			err("%s: length mismatch for RID 0x%04x: "
-			    "expected %d, got %d", __func__,
-			    ctx->in_rid, exp_len, ctx->buf_length);
+			pr_err("%s: length mismatch for RID 0x%04x: expected %d, got %d\n",
+			       __func__, ctx->in_rid, exp_len, ctx->buf_length);
 			retval = -EIO;
 			goto exit;
 		}
@@ -1058,8 +1056,7 @@ static int ezusb_bap_pread(struct hermes *hw, int bap,
 
 	if (id == EZUSB_RID_RX) {
 		if ((sizeof(*ans) + offset + len) > actual_length) {
-			printk(KERN_ERR PFX "BAP read beyond buffer end "
-			       "in rx frame\n");
+			pr_err("BAP read beyond buffer end in rx frame\n");
 			return -EINVAL;
 		}
 		memcpy(buf, ans->data + offset, len);
@@ -1069,13 +1066,12 @@ static int ezusb_bap_pread(struct hermes *hw, int bap,
 	if (EZUSB_IS_INFO(id)) {
 		/* Include 4 bytes for length/type */
 		if ((sizeof(*ans) + offset + len - 4) > actual_length) {
-			printk(KERN_ERR PFX "BAP read beyond buffer end "
-			       "in info frame\n");
+			pr_err("BAP read beyond buffer end in info frame\n");
 			return -EFAULT;
 		}
 		memcpy(buf, ans->data + offset - 4, len);
 	} else {
-		printk(KERN_ERR PFX "Unexpected fid 0x%04x\n", id);
+		pr_err("Unexpected fid 0x%04x\n", id);
 		return -EINVAL;
 	}
 
@@ -1205,20 +1201,17 @@ static netdev_tx_t ezusb_xmit(struct sk_buff *skb, struct net_device *dev)
 	int tx_size;
 
 	if (!netif_running(dev)) {
-		printk(KERN_ERR "%s: Tx on stopped device!\n",
-		       dev->name);
+		pr_err("%s: Tx on stopped device!\n", dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
 	if (netif_queue_stopped(dev)) {
-		printk(KERN_DEBUG "%s: Tx while transmitter busy!\n",
-		       dev->name);
+		pr_debug("%s: Tx while transmitter busy!\n", dev->name);
 		return NETDEV_TX_BUSY;
 	}
 
 	if (orinoco_lock(priv, &flags) != 0) {
-		printk(KERN_ERR
-		       "%s: ezusb_xmit() called while hw_unavailable\n",
+		pr_err("%s: ezusb_xmit() called while hw_unavailable\n",
 		       dev->name);
 		return NETDEV_TX_BUSY;
 	}
@@ -1281,7 +1274,7 @@ static netdev_tx_t ezusb_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (err) {
 		netif_start_queue(dev);
 		if (net_ratelimit())
-			printk(KERN_ERR "%s: Error %d transmitting packet\n",
+			pr_err("%s: Error %d transmitting packet\n",
 				dev->name, err);
 		goto busy;
 	}
@@ -1317,13 +1310,13 @@ static int ezusb_hard_reset(struct orinoco_private *priv)
 	int retval = ezusb_8051_cpucs(upriv, 1);
 
 	if (retval < 0) {
-		err("Failed to reset");
+		pr_err("Failed to reset\n");
 		return retval;
 	}
 
 	retval = ezusb_8051_cpucs(upriv, 0);
 	if (retval < 0) {
-		err("Failed to unreset");
+		pr_err("Failed to unreset\n");
 		return retval;
 	}
 
@@ -1335,7 +1328,7 @@ static int ezusb_hard_reset(struct orinoco_private *priv)
 				 USB_DIR_OUT, 0x0, 0x0, NULL, 0,
 				 DEF_TIMEOUT);
 	if (retval < 0) {
-		err("EZUSB_REQUEST_TRIGER failed retval %d", retval);
+		pr_err("EZUSB_REQUEST_TRIGER failed retval %d\n", retval);
 		return retval;
 	}
 #if 0
@@ -1347,7 +1340,7 @@ static int ezusb_hard_reset(struct orinoco_private *priv)
 				 USB_DIR_OUT, 0x00FA, 0x0, NULL, 0,
 				 DEF_TIMEOUT);
 	if (retval < 0) {
-		err("EZUSB_REQUEST_TRIG_AC failed retval %d", retval);
+		pr_err("EZUSB_REQUEST_TRIG_AC failed retval %d\n", retval);
 		return retval;
 	}
 #endif
@@ -1376,13 +1369,13 @@ static int ezusb_init(struct hermes *hw)
 	retval = ezusb_write_ltv(hw, 0, EZUSB_RID_INIT1,
 				 HERMES_BYTES_TO_RECLEN(2), "\x10\x00");
 	if (retval < 0) {
-		printk(KERN_ERR PFX "EZUSB_RID_INIT1 error %d\n", retval);
+		pr_err("EZUSB_RID_INIT1 error %d\n", retval);
 		return retval;
 	}
 
 	retval = ezusb_docmd_wait(hw, HERMES_CMD_INIT, 0, NULL);
 	if (retval < 0) {
-		printk(KERN_ERR PFX "HERMES_CMD_INIT error %d\n", retval);
+		pr_err("HERMES_CMD_INIT error %d\n", retval);
 		return retval;
 	}
 
@@ -1405,11 +1398,11 @@ static void ezusb_bulk_in_callback(struct urb *urb)
 		/* When a device gets unplugged we get this every time
 		 * we resubmit, flooding the logs.  Since we don't use
 		 * USB timeouts, it shouldn't happen any other time*/
-		pr_warning("%s: urb timed out, not resubmiting", __func__);
+		pr_warn("%s: urb timed out, not resubmiting", __func__);
 		return;
 	}
 	if (urb->status == -ECONNABORTED) {
-		pr_warning("%s: connection abort, resubmiting urb",
+		pr_warn("%s: connection abort, resubmiting urb",
 		     __func__);
 		goto resubmit;
 	}
@@ -1423,12 +1416,12 @@ static void ezusb_bulk_in_callback(struct urb *urb)
 		dbg("status: %d length: %d",
 		    urb->status, urb->actual_length);
 	if (urb->actual_length < sizeof(*ans)) {
-		err("%s: short read, ignoring", __func__);
+		pr_err("%s: short read, ignoring\n", __func__);
 		goto resubmit;
 	}
 	crc = build_crc(ans);
 	if (le16_to_cpu(ans->crc) != crc) {
-		err("CRC error, ignoring packet");
+		pr_err("CRC error, ignoring packet\n");
 		goto resubmit;
 	}
 
@@ -1502,7 +1495,7 @@ static inline void ezusb_delete(struct ezusb_priv *upriv)
 					  struct request_context, list));
 
 	if (upriv->read_urb && upriv->read_urb->status == -EINPROGRESS)
-		printk(KERN_ERR PFX "Some URB in progress\n");
+		pr_err("Some URB in progress\n");
 
 	mutex_unlock(&upriv->mtx);
 
@@ -1586,7 +1579,7 @@ static int ezusb_probe(struct usb_interface *interface,
 	priv = alloc_orinocodev(sizeof(*upriv), &udev->dev,
 				ezusb_hard_reset, NULL);
 	if (!priv) {
-		err("Couldn't allocate orinocodev");
+		pr_err("Couldn't allocate orinocodev\n");
 		goto exit;
 	}
 
@@ -1621,19 +1614,19 @@ static int ezusb_probe(struct usb_interface *interface,
 		     == USB_ENDPOINT_XFER_BULK)) {
 			/* we found a bulk in endpoint */
 			if (upriv->read_urb != NULL) {
-				pr_warning("Found a second bulk in ep, ignored");
+				pr_warn("Found a second bulk in ep, ignored");
 				continue;
 			}
 
 			upriv->read_urb = usb_alloc_urb(0, GFP_KERNEL);
 			if (!upriv->read_urb) {
-				err("No free urbs available");
+				pr_err("No free urbs available\n");
 				goto error;
 			}
 			if (le16_to_cpu(ep->wMaxPacketSize) != 64)
-				pr_warning("bulk in: wMaxPacketSize!= 64");
+				pr_warn("bulk in: wMaxPacketSize!= 64");
 			if (ep->bEndpointAddress != (2 | USB_DIR_IN))
-				pr_warning("bulk in: bEndpointAddress: %d",
+				pr_warn("bulk in: bEndpointAddress: %d",
 				     ep->bEndpointAddress);
 			upriv->read_pipe = usb_rcvbulkpipe(udev,
 							 ep->
@@ -1641,7 +1634,7 @@ static int ezusb_probe(struct usb_interface *interface,
 			upriv->read_urb->transfer_buffer =
 			    kmalloc(BULK_BUF_SIZE, GFP_KERNEL);
 			if (!upriv->read_urb->transfer_buffer) {
-				err("Couldn't allocate IN buffer");
+				pr_err("Couldn't allocate IN buffer\n");
 				goto error;
 			}
 		}
@@ -1652,27 +1645,27 @@ static int ezusb_probe(struct usb_interface *interface,
 		     == USB_ENDPOINT_XFER_BULK)) {
 			/* we found a bulk out endpoint */
 			if (upriv->bap_buf != NULL) {
-				pr_warning("Found a second bulk out ep, ignored");
+				pr_warn("Found a second bulk out ep, ignored");
 				continue;
 			}
 
 			if (le16_to_cpu(ep->wMaxPacketSize) != 64)
-				pr_warning("bulk out: wMaxPacketSize != 64");
+				pr_warn("bulk out: wMaxPacketSize != 64");
 			if (ep->bEndpointAddress != 2)
-				pr_warning("bulk out: bEndpointAddress: %d",
+				pr_warn("bulk out: bEndpointAddress: %d",
 				     ep->bEndpointAddress);
 			upriv->write_pipe = usb_sndbulkpipe(udev,
 							  ep->
 							  bEndpointAddress);
 			upriv->bap_buf = kmalloc(BULK_BUF_SIZE, GFP_KERNEL);
 			if (!upriv->bap_buf) {
-				err("Couldn't allocate bulk_out_buffer");
+				pr_err("Couldn't allocate bulk_out_buffer\n");
 				goto error;
 			}
 		}
 	}
 	if (!upriv->bap_buf || !upriv->read_urb) {
-		err("Didn't find the required bulk endpoints");
+		pr_err("Didn't find the required bulk endpoints\n");
 		goto error;
 	}
 
@@ -1684,12 +1677,12 @@ static int ezusb_probe(struct usb_interface *interface,
 	if (firmware.size && firmware.code) {
 		ezusb_firmware_download(upriv, &firmware);
 	} else {
-		err("No firmware to download");
+		pr_err("No firmware to download\n");
 		goto error;
 	}
 
 	if (ezusb_hard_reset(priv) < 0) {
-		err("Cannot reset the device");
+		pr_err("Cannot reset the device\n");
 		goto error;
 	}
 
@@ -1698,20 +1691,20 @@ static int ezusb_probe(struct usb_interface *interface,
 	 * the kernel very unstable, so we try initializing here and quit in
 	 * case of error */
 	if (ezusb_init(hw) < 0) {
-		err("Couldn't initialize the device");
-		err("Firmware may not be downloaded or may be wrong.");
+		pr_err("Couldn't initialize the device\n");
+		pr_err("Firmware may not be downloaded or may be wrong\n");
 		goto error;
 	}
 
 	/* Initialise the main driver */
 	if (orinoco_init(priv) != 0) {
-		err("orinoco_init() failed\n");
+		pr_err("orinoco_init() failed\n");
 		goto error;
 	}
 
 	if (orinoco_if_add(priv, 0, 0, &ezusb_netdev_ops) != 0) {
 		upriv->dev = NULL;
-		err("%s: orinoco_if_add() failed", __func__);
+		pr_err("%s: orinoco_if_add() failed\n", __func__);
 		goto error;
 	}
 	upriv->dev = priv->ndev;
@@ -1742,7 +1735,7 @@ static void ezusb_disconnect(struct usb_interface *intf)
 	struct ezusb_priv *upriv = usb_get_intfdata(intf);
 	usb_set_intfdata(intf, NULL);
 	ezusb_delete(upriv);
-	printk(KERN_INFO PFX "Disconnected\n");
+	pr_info("Disconnected\n");
 }
 
 
diff --git a/drivers/net/wireless/orinoco/scan.c b/drivers/net/wireless/orinoco/scan.c
index 96e39ed..afa6f79 100644
--- a/drivers/net/wireless/orinoco/scan.c
+++ b/drivers/net/wireless/orinoco/scan.c
@@ -3,6 +3,8 @@
  * See copyright notice in main.c
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/gfp.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -113,8 +115,8 @@ static void orinoco_add_hostscan_result(struct orinoco_private *priv,
 	freq = ieee80211_dsss_chan_to_freq(le16_to_cpu(bss->a.channel));
 	channel = ieee80211_get_channel(wiphy, freq);
 	if (!channel) {
-		printk(KERN_DEBUG "Invalid channel designation %04X(%04X)",
-			bss->a.channel, freq);
+		pr_debug("Invalid channel designation %04X(%04X)\n",
+			 bss->a.channel, freq);
 		return;	/* Then ignore it for now */
 	}
 	timestamp = 0;
@@ -199,9 +201,8 @@ void orinoco_add_hostscan_results(struct orinoco_private *priv,
 			atom_len = le16_to_cpup((__le16 *)buf);
 			/* Sanity check for atom_len */
 			if (atom_len < sizeof(struct prism2_scan_apinfo)) {
-				printk(KERN_ERR "%s: Invalid atom_len in scan "
-				       "data: %zu\n", priv->ndev->name,
-				       atom_len);
+				pr_err("%s: Invalid atom_len in scan data: %zu\n",
+				       priv->ndev->name, atom_len);
 				abort = true;
 				goto scan_abort;
 			}
@@ -216,9 +217,8 @@ void orinoco_add_hostscan_results(struct orinoco_private *priv,
 
 	/* Check that we got an whole number of atoms */
 	if ((len - offset) % atom_len) {
-		printk(KERN_ERR "%s: Unexpected scan data length %zu, "
-		       "atom_len %zu, offset %d\n", priv->ndev->name, len,
-		       atom_len, offset);
+		pr_err("%s: Unexpected scan data length %zu, atom_len %zu, offset %d\n",
+		       priv->ndev->name, len, atom_len, offset);
 		abort = true;
 		goto scan_abort;
 	}
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index 6e28ee4..4722aa5 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -208,7 +208,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 	ret = pcmcia_loop_config(link, spectrum_cs_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
-			printk(KERN_ERR PFX "GetNextTuple(): No matching "
+			pr_err(PFX "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
 		goto failed;
@@ -239,14 +239,14 @@ spectrum_cs_config(struct pcmcia_device *link)
 
 	/* Initialise the main driver */
 	if (orinoco_init(priv) != 0) {
-		printk(KERN_ERR PFX "orinoco_init() failed\n");
+		pr_err(PFX "orinoco_init() failed\n");
 		goto failed;
 	}
 
 	/* Register an interface with the stack */
 	if (orinoco_if_add(priv, link->resource[0]->start,
 			   link->irq, NULL) != 0) {
-		printk(KERN_ERR PFX "orinoco_if_add() failed\n");
+		pr_err(PFX "orinoco_if_add() failed\n");
 		goto failed;
 	}
 
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 33747e1..b48ec31 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -2,6 +2,9 @@
  *
  * See copyright notice in main.c
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
@@ -94,8 +97,8 @@ static struct iw_statistics *orinoco_get_wireless_stats(struct net_device *dev)
 	unsigned long flags;
 
 	if (!netif_device_present(dev)) {
-		printk(KERN_WARNING "%s: get_wireless_stats() called while device not present\n",
-		       dev->name);
+		pr_warn("%s: get_wireless_stats() called while device not present\n",
+			dev->name);
 		return NULL; /* FIXME: Can we do better than this? */
 	}
 
@@ -180,16 +183,15 @@ static int orinoco_ioctl_setwap(struct net_device *dev,
 	}
 
 	if (priv->firmware_type == FIRMWARE_TYPE_AGERE) {
-		printk(KERN_WARNING "%s: Lucent/Agere firmware doesn't "
-		       "support manual roaming\n",
-		       dev->name);
+		pr_warn("%s: Lucent/Agere firmware doesn't support manual roaming\n",
+			dev->name);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
 
 	if (priv->iw_mode != NL80211_IFTYPE_STATION) {
-		printk(KERN_WARNING "%s: Manual roaming supported only in "
-		       "managed mode\n", dev->name);
+		pr_warn("%s: Manual roaming supported only in managed mode\n",
+			dev->name);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
@@ -197,8 +199,8 @@ static int orinoco_ioctl_setwap(struct net_device *dev,
 	/* Intersil firmware hangs without Desired ESSID */
 	if (priv->firmware_type == FIRMWARE_TYPE_INTERSIL &&
 	    strlen(priv->desired_essid) == 0) {
-		printk(KERN_WARNING "%s: Desired ESSID must be set for "
-		       "manual roaming\n", dev->name);
+		pr_warn("%s: Desired ESSID must be set for manual roaming\n",
+			dev->name);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
@@ -795,8 +797,8 @@ static int orinoco_ioctl_set_encodeext(struct net_device *dev,
 				 priv->keys[idx].key,
 				 tkip_iv, ORINOCO_SEQ_LEN, NULL, 0);
 			if (err)
-				printk(KERN_ERR "%s: Error %d setting TKIP key"
-				       "\n", dev->name, err);
+				pr_err("%s: Error %d setting TKIP key\n",
+				       dev->name, err);
 
 			goto out;
 		}
@@ -1107,12 +1109,12 @@ static int orinoco_ioctl_reset(struct net_device *dev,
 		return -EPERM;
 
 	if (info->cmd == (SIOCIWFIRSTPRIV + 0x1)) {
-		printk(KERN_DEBUG "%s: Forcing reset!\n", dev->name);
+		pr_debug("%s: Forcing reset!\n", dev->name);
 
 		/* Firmware reset */
 		orinoco_reset(&priv->reset_work);
 	} else {
-		printk(KERN_DEBUG "%s: Force scheduling reset!\n", dev->name);
+		pr_debug("%s: Force scheduling reset!\n", dev->name);
 
 		schedule_work(&priv->reset_work);
 	}
-- 
1.7.8.111.gad25c.dirty
