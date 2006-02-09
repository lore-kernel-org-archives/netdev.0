From: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/7] IrDA: nsc-ircc: ISAPnP support
Date: Thu, 9 Feb 2006 23:31:54 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0602090309260.19426@irie>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "ext David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This enables PnP support for the nsc-ircc chipset.
Since we can't fetch the chipset cfg_base from the PnP layer, we just use
the PnP information as one more hint when probing the chip.

Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel.ortiz-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index ee717d0..74cb38c 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -12,6 +12,7 @@
  *     Copyright (c) 1998-2000 Dag Brattli <dagb-WiQn+q4tdXRhl2p70BpVqQ@public.gmane.org>
  *     Copyright (c) 1998 Lichen Wang, <lwang-df/MbWHcLfRBDgjK7y7TUQ@public.gmane.org>
  *     Copyright (c) 1998 Actisys Corp., www.actisys.com
+ *     Copyright (c) 2000-2004 Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
  *     All Rights Reserved
  *
  *     This program is free software; you can redistribute it and/or
@@ -53,6 +54,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/dma-mapping.h>
+#include <linux/pnp.h>

 #include <asm/io.h>
 #include <asm/dma.h>
@@ -78,8 +80,8 @@ static int dongle_id;

 /* Use BIOS settions by default, but user may supply module parameters */
 static unsigned int io[]  = { ~0, ~0, ~0, ~0 };
-static unsigned int irq[] = { 0, 0, 0, 0, 0 };
-static unsigned int dma[] = { 0, 0, 0, 0, 0 };
+static unsigned int irq[] = {  0,  0,  0,  0 };
+static unsigned int dma[] = {  0,  0,  0,  0 };

 static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_probe_338(nsc_chip_t *chip, chipio_t *info);
@@ -87,6 +89,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_init_338(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_init_39x(nsc_chip_t *chip, chipio_t *info);
+static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *id);

 /* These are the known NSC chips */
 static nsc_chip_t chips[] = {
@@ -104,7 +107,6 @@ static nsc_chip_t chips[] = {
 	{ NULL }
 };

-/* Max 4 instances for now */
 static struct nsc_ircc_cb *dev_self[] = { NULL, NULL, NULL, NULL };

 static char *dongle_types[] = {
@@ -126,8 +128,24 @@ static char *dongle_types[] = {
 	"No dongle connected",
 };

+/* PNP probing */
+static chipio_t pnp_info;
+static const struct pnp_device_id nsc_ircc_pnp_table[] = {
+	{ .id = "NSC6001", .driver_data = 0 },
+	{ .id = "IBM0071", .driver_data = 0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(pnp, nsc_ircc_pnp_table);
+
+static struct pnp_driver nsc_ircc_pnp_driver = {
+	.name = "nsc-ircc",
+	.id_table = nsc_ircc_pnp_table,
+	.probe = nsc_ircc_pnp_probe,
+};
+
 /* Some prototypes */
-static int  nsc_ircc_open(int i, chipio_t *info);
+static int  nsc_ircc_open(chipio_t *info);
 static int  nsc_ircc_close(struct nsc_ircc_cb *self);
 static int  nsc_ircc_setup(chipio_t *info);
 static void nsc_ircc_pio_receive(struct nsc_ircc_cb *self);
@@ -148,6 +166,10 @@ static int  nsc_ircc_net_ioctl(struct ne
 static struct net_device_stats *nsc_ircc_net_get_stats(struct net_device *dev);
 static int nsc_ircc_pmproc(struct pm_dev *dev, pm_request_t rqst, void *data);

+/* Globals */
+static int pnp_registered;
+static int pnp_succeeded;
+
 /*
  * Function nsc_ircc_init ()
  *
@@ -158,28 +180,30 @@ static int __init nsc_ircc_init(void)
 {
 	chipio_t info;
 	nsc_chip_t *chip;
-	int ret = -ENODEV;
+	int ret;
 	int cfg_base;
 	int cfg, id;
 	int reg;
 	int i = 0;

+ 	/* Register with PnP subsystem to detect disable ports */
+	ret = pnp_register_driver(&nsc_ircc_pnp_driver);
+
+ 	if (ret >= 0)
+ 		pnp_registered = 1;
+
+	ret = -ENODEV;
+
 	/* Probe for all the NSC chipsets we know about */
-	for (chip=chips; chip->name ; chip++) {
+	for (chip = chips; chip->name ; chip++) {
 		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__,
 			   chip->name);

 		/* Try all config registers for this chip */
-		for (cfg=0; cfg<3; cfg++) {
+		for (cfg = 0; cfg < ARRAY_SIZE(chip->cfg); cfg++) {
 			cfg_base = chip->cfg[cfg];
 			if (!cfg_base)
 				continue;
-
-			memset(&info, 0, sizeof(chipio_t));
-			info.cfg_base = cfg_base;
-			info.fir_base = io[i];
-			info.dma = dma[i];
-			info.irq = irq[i];

 			/* Read index register */
 			reg = inb(cfg_base);
@@ -194,26 +218,66 @@ static int __init nsc_ircc_init(void)
 			if ((id & chip->cid_mask) == chip->cid_value) {
 				IRDA_DEBUG(2, "%s() Found %s chip, revision=%d\n",
 					   __FUNCTION__, chip->name, id & ~chip->cid_mask);
-				/*
-				 * If the user supplies the base address, then
-				 * we init the chip, if not we probe the values
-				 * set by the BIOS
-				 */
-				if (io[i] < 0x2000) {
-					chip->init(chip, &info);
-				} else
-					chip->probe(chip, &info);
-
-				if (nsc_ircc_open(i, &info) == 0)
-					ret = 0;
+
+				/*
+				 * If we found a correct PnP setting,
+				 * we first try it.
+				 */
+				if (pnp_succeeded) {
+					memset(&info, 0, sizeof(chipio_t));
+					info.cfg_base = cfg_base;
+					info.fir_base = pnp_info.fir_base;
+					info.dma = pnp_info.dma;
+					info.irq = pnp_info.irq;
+
+					if (info.fir_base < 0x2000) {
+						IRDA_MESSAGE("%s, chip->init\n", driver_name);
+						chip->init(chip, &info);
+					} else
+						chip->probe(chip, &info);
+
+					if (nsc_ircc_open(&info) >= 0)
+						ret = 0;
+				}
+
+				/*
+				 * Opening based on PnP values failed.
+				 * Let's fallback to user values, or probe
+				 * the chip.
+				 */
+				if (ret) {
+					IRDA_DEBUG(2, "%s, PnP init failed\n", driver_name);
+					memset(&info, 0, sizeof(chipio_t));
+					info.cfg_base = cfg_base;
+					info.fir_base = io[i];
+					info.dma = dma[i];
+					info.irq = irq[i];
+
+					/*
+					 * If the user supplies the base address, then
+					 * we init the chip, if not we probe the values
+					 * set by the BIOS
+					 */
+					if (io[i] < 0x2000) {
+						chip->init(chip, &info);
+					} else
+						chip->probe(chip, &info);
+
+					if (nsc_ircc_open(&info) >= 0)
+						ret = 0;
+				}
 				i++;
 			} else {
 				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __FUNCTION__, id);
 			}
 		}
-
 	}

+	if (ret) {
+		pnp_unregister_driver(&nsc_ircc_pnp_driver);
+		pnp_registered = 0;
+	}
+
 	return ret;
 }

@@ -228,11 +292,16 @@ static void __exit nsc_ircc_cleanup(void
 	int i;

 	pm_unregister_all(nsc_ircc_pmproc);
-
-	for (i=0; i < 4; i++) {
+
+	for (i = 0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			nsc_ircc_close(dev_self[i]);
 	}
+
+	if (pnp_registered)
+ 		pnp_unregister_driver(&nsc_ircc_pnp_driver);
+
+	pnp_registered = 0;
 }

 /*
@@ -241,16 +310,27 @@ static void __exit nsc_ircc_cleanup(void
  *    Open driver instance
  *
  */
-static int __init nsc_ircc_open(int i, chipio_t *info)
+static int __init nsc_ircc_open(chipio_t *info)
 {
 	struct net_device *dev;
 	struct nsc_ircc_cb *self;
-        struct pm_dev *pmdev;
+	struct pm_dev *pmdev;
 	void *ret;
-	int err;
+	int err, chip_index;

 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);

+
+ 	for (chip_index = 0; chip_index < ARRAY_SIZE(dev_self); chip_index++) {
+		if (!dev_self[chip_index])
+			break;
+	}
+
+	if (chip_index == ARRAY_SIZE(dev_self)) {
+		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __FUNCTION__);
+		return -ENOMEM;
+	}
+
 	IRDA_MESSAGE("%s, Found chip at base=0x%03x\n", driver_name,
 		     info->cfg_base);

@@ -271,8 +351,8 @@ static int __init nsc_ircc_open(int i, c
 	spin_lock_init(&self->lock);

 	/* Need to store self somewhere */
-	dev_self[i] = self;
-	self->index = i;
+	dev_self[chip_index] = self;
+	self->index = chip_index;

 	/* Initialize IO */
 	self->io.cfg_base  = info->cfg_base;
@@ -351,7 +431,7 @@ static int __init nsc_ircc_open(int i, c

 	/* Check if user has supplied a valid dongle id or not */
 	if ((dongle_id <= 0) ||
-	    (dongle_id >= (sizeof(dongle_types) / sizeof(dongle_types[0]))) ) {
+	    (dongle_id >= ARRAY_SIZE(dongle_types))) {
 		dongle_id = nsc_ircc_read_dongle_id(self->io.fir_base);

 		IRDA_MESSAGE("%s, Found dongle: %s\n", driver_name,
@@ -368,7 +448,7 @@ static int __init nsc_ircc_open(int i, c
         if (pmdev)
                 pmdev->data = self;

-	return 0;
+	return chip_index;
  out4:
 	dma_free_coherent(NULL, self->tx_buff.truesize,
 			  self->tx_buff.head, self->tx_buff_dma);
@@ -379,7 +459,7 @@ static int __init nsc_ircc_open(int i, c
 	release_region(self->io.fir_base, self->io.fir_ext);
  out1:
 	free_netdev(dev);
-	dev_self[i] = NULL;
+	dev_self[chip_index] = NULL;
 	return err;
 }

@@ -806,6 +886,43 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 	return 0;
 }

+/* PNP probing */
+static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *id)
+{
+	memset(&pnp_info, 0, sizeof(chipio_t));
+	pnp_info.irq = -1;
+	pnp_info.dma = -1;
+	pnp_succeeded = 1;
+
+	/* There don't seem to be any way to get the cfg_base.
+	 * On my box, cfg_base is in the PnP descriptor of the
+	 * motherboard. Oh well... Jean II */
+
+	if (pnp_port_valid(dev, 0) &&
+		!(pnp_port_flags(dev, 0) & IORESOURCE_DISABLED))
+		pnp_info.fir_base = pnp_port_start(dev, 0);
+
+	if (pnp_irq_valid(dev, 0) &&
+		!(pnp_irq_flags(dev, 0) & IORESOURCE_DISABLED))
+		pnp_info.irq = pnp_irq(dev, 0);
+
+	if (pnp_dma_valid(dev, 0) &&
+		!(pnp_dma_flags(dev, 0) & IORESOURCE_DISABLED))
+		pnp_info.dma = pnp_dma(dev, 0);
+
+	IRDA_DEBUG(0, "%s() : From PnP, found firbase 0x%03X ; irq %d ; dma %d.\n",
+		   __FUNCTION__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
+
+	if((pnp_info.fir_base == 0) ||
+	   (pnp_info.irq == -1) || (pnp_info.dma == -1)) {
+		/* Returning an error will disable the device. Yuck ! */
+		//return -EINVAL;
+		pnp_succeeded = 0;
+	}
+
+	return 0;
+}
+
 /*
  * Function nsc_ircc_setup (info)
  *



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
