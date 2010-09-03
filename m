From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 10/15] pcmcia: introduce autoconfiguration feature
Date: Fri,  3 Sep 2010 12:57:09 +0200
Message-ID: <1283511434-21620-10-git-send-email-linux@dominikbrodowski.net>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-usb@vger.kernel.org,
	laforge@gnumonks.org, linux-mtd@lists.infradead.org,
	linux-bluetooth@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-serial@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	linux-scsi@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20100903105628.GA21255@comet.dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce an autoconfiguration feature to set certain values in
pcmcia_loop_config(), instead of copying the same code over and over
in each PCMCIA driver. At first, introduce the following options:

CONF_AUTO_CHECK_VCC	check or matching Vcc entry
CONF_AUTO_SET_VPP	set Vpp
CONF_AUTO_AUDIO		enable the speaker line

CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
CC: linux-ide@vger.kernel.org
CC: linux-usb@vger.kernel.org
CC: laforge@gnumonks.org
CC: linux-mtd@lists.infradead.org
CC: linux-bluetooth@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: linux-serial@vger.kernel.org
CC: Jiri Kosina <jkosina@suse.cz>
CC: linux-scsi@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c                        |   23 +----
 drivers/bluetooth/bt3c_cs.c                      |    7 +-
 drivers/bluetooth/btuart_cs.c                    |    7 +-
 drivers/bluetooth/dtl1_cs.c                      |    1 -
 drivers/char/pcmcia/cm4000_cs.c                  |    1 -
 drivers/char/pcmcia/cm4040_cs.c                  |    1 -
 drivers/char/pcmcia/ipwireless/main.c            |    1 -
 drivers/char/pcmcia/synclink_cs.c                |    1 -
 drivers/ide/ide-cs.c                             |   23 +----
 drivers/isdn/hardware/avm/avm_cs.c               |    1 -
 drivers/isdn/hisax/avma1_cs.c                    |    1 -
 drivers/isdn/hisax/elsa_cs.c                     |    1 -
 drivers/isdn/hisax/sedlbauer_cs.c                |   25 +-----
 drivers/isdn/hisax/teles_cs.c                    |    1 -
 drivers/net/pcmcia/axnet_cs.c                    |    1 -
 drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
 drivers/net/pcmcia/pcnet_cs.c                    |    1 -
 drivers/net/pcmcia/smc91c92_cs.c                 |    2 -
 drivers/net/pcmcia/xirc2ps_cs.c                  |    5 +-
 drivers/net/wireless/airo_cs.c                   |   17 +---
 drivers/net/wireless/atmel_cs.c                  |   17 +---
 drivers/net/wireless/hostap/hostap_cs.c          |   27 +-----
 drivers/net/wireless/libertas/if_cs.c            |    1 -
 drivers/net/wireless/orinoco/orinoco_cs.c        |   31 +------
 drivers/net/wireless/orinoco/spectrum_cs.c       |   24 +----
 drivers/parport/parport_cs.c                     |    1 -
 drivers/pcmcia/pcmcia_cis.c                      |   36 ++++++-
 drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
 drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
 drivers/scsi/pcmcia/nsp_cs.c                     |  110 ++++++++-------------
 drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
 drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
 drivers/serial/serial_cs.c                       |   10 +--
 drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
 drivers/staging/comedi/drivers/das08_cs.c        |    1 -
 drivers/staging/comedi/drivers/ni_daq_700.c      |   10 +--
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |   10 +--
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |   11 +--
 drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
 drivers/telephony/ixj_pcmcia.c                   |    1 -
 drivers/usb/host/sl811_cs.c                      |   24 +----
 include/pcmcia/ds.h                              |    7 +-
 43 files changed, 120 insertions(+), 329 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 76da55d..954f43c 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -169,34 +169,16 @@ static struct ata_port_operations pcmcia_8bit_port_ops = {
 
 struct pcmcia_config_check {
 	unsigned long ctl_base;
-	int skip_vcc;
 	int is_kme;
 };
 
 static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 				   cistpl_cftable_entry_t *cfg,
 				   cistpl_cftable_entry_t *dflt,
-				   unsigned int vcc,
 				   void *priv_data)
 {
 	struct pcmcia_config_check *stk = priv_data;
 
-	/* Check for matching Vcc, unless we're desperate */
-	if (!stk->skip_vcc) {
-		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000)
-				return -ENODEV;
-		} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] / 10000)
-				return -ENODEV;
-		}
-	}
-
-	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
 		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
@@ -249,6 +231,7 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	pdev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
 	pdev->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
 	pdev->config_flags |= CONF_ENABLE_IRQ;
+	pdev->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
@@ -262,10 +245,10 @@ static int pcmcia_init_one(struct pcmcia_device *pdev)
 	if (!stk)
 		goto out1;
 	stk->is_kme = is_kme;
-	stk->skip_vcc = io_base = ctl_base = 0;
+	io_base = ctl_base = 0;
 
 	if (pcmcia_loop_config(pdev, pcmcia_check_one_config, stk)) {
-		stk->skip_vcc = 1;
+		pdev->config_flags &= ~CONF_AUTO_CHECK_VCC;
 		if (pcmcia_loop_config(pdev, pcmcia_check_one_config, stk))
 			goto failed; /* No suitable config found */
 	}
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 3db9588..97338a3 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -659,7 +659,7 @@ static int bt3c_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 8;
 
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP;
 
 	return bt3c_config(link);
 }
@@ -676,15 +676,11 @@ static void bt3c_detach(struct pcmcia_device *link)
 static int bt3c_check_config(struct pcmcia_device *p_dev,
 			     cistpl_cftable_entry_t *cf,
 			     cistpl_cftable_entry_t *dflt,
-			     unsigned int vcc,
 			     void *priv_data)
 {
 	unsigned long try = (unsigned long) priv_data;
-
 	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
-	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
 		p_dev->resource[0]->start = cf->io.win[0].base;
@@ -697,7 +693,6 @@ static int bt3c_check_config(struct pcmcia_device *p_dev,
 static int bt3c_check_config_notpicky(struct pcmcia_device *p_dev,
 				      cistpl_cftable_entry_t *cf,
 				      cistpl_cftable_entry_t *dflt,
-				      unsigned int vcc,
 				      void *priv_data)
 {
 	static unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index c5c4359..8a6864f 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -588,7 +588,7 @@ static int btuart_probe(struct pcmcia_device *link)
 	link->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
 	link->resource[0]->end = 8;
 
-	link->config_flags |= CONF_ENABLE_IRQ;
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP;
 
 	return btuart_config(link);
 }
@@ -605,15 +605,11 @@ static void btuart_detach(struct pcmcia_device *link)
 static int btuart_check_config(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cf,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	int *try = priv_data;
-
 	p_dev->io_lines = (try == 0) ? 16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
-	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp = cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	if ((cf->io.nwin > 0) && (cf->io.win[0].len == 8) &&
 	    (cf->io.win[0].base != 0)) {
 		p_dev->resource[0]->start = cf->io.win[0].base;
@@ -626,7 +622,6 @@ static int btuart_check_config(struct pcmcia_device *p_dev,
 static int btuart_check_config_notpicky(struct pcmcia_device *p_dev,
 					cistpl_cftable_entry_t *cf,
 					cistpl_cftable_entry_t *dflt,
-					unsigned int vcc,
 					void *priv_data)
 {
 	static unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 38206df..4620cc3 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -592,7 +592,6 @@ static void dtl1_detach(struct pcmcia_device *link)
 static int dtl1_confcheck(struct pcmcia_device *p_dev,
 			  cistpl_cftable_entry_t *cf,
 			  cistpl_cftable_entry_t *dflt,
-			  unsigned int vcc,
 			  void *priv_data)
 {
 	if ((cf->io.nwin != 1) || (cf->io.win[0].len <= 8))
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index 75caa8c..0b2f3b9 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1744,7 +1744,6 @@ static void cmm_cm4000_release(struct pcmcia_device * link)
 static int cm4000_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	if (!cfg->io.nwin)
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 0c87b80..acf88d5 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -518,7 +518,6 @@ static void cm4040_reader_release(struct pcmcia_device *link)
 static int cm4040_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	int rc;
diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index cd21b2b..1b7f092 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -78,7 +78,6 @@ static void signalled_reboot_callback(void *callback_data)
 static int ipwireless_probe(struct pcmcia_device *p_dev,
 			    cistpl_cftable_entry_t *cfg,
 			    cistpl_cftable_entry_t *dflt,
-			    unsigned int vcc,
 			    void *priv_data)
 {
 	struct ipw_dev *ipw = priv_data;
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 99feaed..c701434 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -564,7 +564,6 @@ static int mgslpc_probe(struct pcmcia_device *link)
 static int mgslpc_ioprobe(struct pcmcia_device *p_dev,
 			  cistpl_cftable_entry_t *cfg,
 			  cistpl_cftable_entry_t *dflt,
-			  unsigned int vcc,
 			  void *priv_data)
 {
 	if (!cfg->io.nwin)
diff --git a/drivers/ide/ide-cs.c b/drivers/ide/ide-cs.c
index 87ad049..25b8a10 100644
--- a/drivers/ide/ide-cs.c
+++ b/drivers/ide/ide-cs.c
@@ -99,6 +99,7 @@ static int ide_probe(struct pcmcia_device *link)
     link->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
     link->resource[1]->flags |= IO_DATA_PATH_WIDTH_8;
     link->config_flags |= CONF_ENABLE_IRQ;
+    link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
 
     return ide_config(link);
 } /* ide_attach */
@@ -195,34 +196,16 @@ out_release:
 
 struct pcmcia_config_check {
 	unsigned long ctl_base;
-	int skip_vcc;
 	int is_kme;
 };
 
 static int pcmcia_check_one_config(struct pcmcia_device *pdev,
 				   cistpl_cftable_entry_t *cfg,
 				   cistpl_cftable_entry_t *dflt,
-				   unsigned int vcc,
 				   void *priv_data)
 {
 	struct pcmcia_config_check *stk = priv_data;
 
-	/* Check for matching Vcc, unless we're desperate */
-	if (!stk->skip_vcc) {
-		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000)
-				return -ENODEV;
-		} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] / 10000)
-				return -ENODEV;
-		}
-	}
-
-	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		pdev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
 		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
 		pdev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
@@ -271,10 +254,10 @@ static int ide_config(struct pcmcia_device *link)
     if (!stk)
 	    goto err_mem;
     stk->is_kme = is_kme;
-    stk->skip_vcc = io_base = ctl_base = 0;
+    io_base = ctl_base = 0;
 
     if (pcmcia_loop_config(link, pcmcia_check_one_config, stk)) {
-	    stk->skip_vcc = 1;
+	    link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	    if (pcmcia_loop_config(link, pcmcia_check_one_config, stk))
 		    goto failed; /* No suitable config found */
     }
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 6ea5cd2..9dbab9c 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -110,7 +110,6 @@ static void avmcs_detach(struct pcmcia_device *link)
 static int avmcs_configcheck(struct pcmcia_device *p_dev,
 			     cistpl_cftable_entry_t *cf,
 			     cistpl_cftable_entry_t *dflt,
-			     unsigned int vcc,
 			     void *priv_data)
 {
 	if (cf->io.nwin <= 0)
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 5dd47ad..2f2b000 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -117,7 +117,6 @@ static void __devexit avma1cs_detach(struct pcmcia_device *link)
 static int avma1cs_configcheck(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cf,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	if (cf->io.nwin <= 0)
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 368c8a2..0a65280 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -163,7 +163,6 @@ static void __devexit elsa_cs_detach(struct pcmcia_device *link)
 static int elsa_cs_configcheck(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cf,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	int j;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index 791e23a..b69eccf 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -164,33 +164,11 @@ static void __devexit sedlbauer_detach(struct pcmcia_device *link)
 static int sedlbauer_config_check(struct pcmcia_device *p_dev,
 				  cistpl_cftable_entry_t *cfg,
 				  cistpl_cftable_entry_t *dflt,
-				  unsigned int vcc,
 				  void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-		if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM]/10000)
-			return -ENODEV;
-	} else if (dflt->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-		if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM]/10000)
-			return -ENODEV;
-	}
-
-	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
-
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -223,6 +201,9 @@ static int __devinit sedlbauer_config(struct pcmcia_device *link)
 
     dev_dbg(&link->dev, "sedlbauer_config(0x%p)\n", link);
 
+    link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_CHECK_VCC |
+	    CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO;
+
     /*
       In this loop, we scan the CIS for configuration table entries,
       each of which describes a valid card configuration, including
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 2ae71e3..6605480 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -145,7 +145,6 @@ static void __devexit teles_detach(struct pcmcia_device *link)
 static int teles_cs_configcheck(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cf,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	int j;
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index f361d28..17f1040 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -287,7 +287,6 @@ static int try_io_port(struct pcmcia_device *link)
 static int axnet_configcheck(struct pcmcia_device *p_dev,
 			     cistpl_cftable_entry_t *cfg,
 			     cistpl_cftable_entry_t *dflt,
-			     unsigned int vcc,
 			     void *priv_data)
 {
 	int i;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index f6865ad..c1479e3 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -322,7 +322,6 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
 static int fmvj18x_ioprobe(struct pcmcia_device *p_dev,
 			   cistpl_cftable_entry_t *cfg,
 			   cistpl_cftable_entry_t *dflt,
-			   unsigned int vcc,
 			   void *priv_data)
 {
 	return 0; /* strange, but that's what the code did already before... */
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index ddd4bd2..301f3d4 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -503,7 +503,6 @@ static int try_io_port(struct pcmcia_device *link)
 static int pcnet_confcheck(struct pcmcia_device *p_dev,
 			   cistpl_cftable_entry_t *cfg,
 			   cistpl_cftable_entry_t *dflt,
-			   unsigned int vcc,
 			   void *priv_data)
 {
 	int *has_shmem = priv_data;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 8c16ba6..e127d2b 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -420,7 +420,6 @@ static int mhz_3288_power(struct pcmcia_device *link)
 static int mhz_mfc_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cf,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	int k;
@@ -590,7 +589,6 @@ static int mot_setup(struct pcmcia_device *link)
 static int smc_configcheck(struct pcmcia_device *p_dev,
 			   cistpl_cftable_entry_t *cf,
 			   cistpl_cftable_entry_t *dflt,
-			   unsigned int vcc,
 			   void *priv_data)
 {
 	p_dev->resource[0]->start = cf->io.win[0].base;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 7a4a99b..2bc2eb8 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -668,7 +668,6 @@ static int
 xirc2ps_config_modem(struct pcmcia_device *p_dev,
 		     cistpl_cftable_entry_t *cf,
 		     cistpl_cftable_entry_t *dflt,
-		     unsigned int vcc,
 		     void *priv_data)
 {
 	unsigned int ioaddr;
@@ -688,7 +687,6 @@ static int
 xirc2ps_config_check(struct pcmcia_device *p_dev,
 		     cistpl_cftable_entry_t *cf,
 		     cistpl_cftable_entry_t *dflt,
-		     unsigned int vcc,
 		     void *priv_data)
 {
 	int *pass = priv_data;
@@ -826,7 +824,8 @@ xirc2ps_config(struct pcmcia_device * link)
 	     * the Mako if (on the first pass) the COR bit 5 is set.
 	     */
 	    for (pass=0; pass < 2; pass++)
-		    if (!pcmcia_loop_config(link, xirc2ps_config_check, &pass))
+		    if (!pcmcia_loop_config(link, xirc2ps_config_check,
+						    &pass))
 			    goto port_found;
 	    /* if special option:
 	     * try to configure as Ethernet only.
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 5939d0c..63bf662 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -140,25 +140,11 @@ static void airo_detach(struct pcmcia_device *link)
 static int airo_cs_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
-
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -193,6 +179,9 @@ static int airo_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "airo_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
+		CONF_AUTO_AUDIO;
+
 	/*
 	 * In this loop, we scan the CIS for configuration table
 	 * entries, each of which describes a valid card
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 080266e..812decd 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -157,25 +157,11 @@ static int card_present(void *arg)
 static int atmel_config_check(struct pcmcia_device *p_dev,
 			      cistpl_cftable_entry_t *cfg,
 			      cistpl_cftable_entry_t *dflt,
-			      unsigned int vcc,
 			      void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
-
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -207,6 +193,9 @@ static int atmel_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "atmel_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_VPP |
+		CONF_AUTO_AUDIO;
+
 	/*
 	  In this loop, we scan the CIS for configuration table entries,
 	  each of which describes a valid card configuration, including
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 5b0b582..d4f19af 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -472,7 +472,6 @@ static void prism2_detach(struct pcmcia_device *link)
 static int prism2_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	if (cfg->index == 0)
@@ -481,28 +480,6 @@ static int prism2_config_check(struct pcmcia_device *p_dev,
 	PDEBUG(DEBUG_EXTRA, "Checking CFTABLE_ENTRY 0x%02X "
 	       "(default 0x%02X)\n", cfg->index, dflt->index);
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] /
-		    10000 && !ignore_cis_vcc) {
-			PDEBUG(DEBUG_EXTRA, "  Vcc mismatch - skipping"
-			       " this entry\n");
-			return -ENODEV;
-		}
-	} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] /
-		    10000 && !ignore_cis_vcc) {
-			PDEBUG(DEBUG_EXTRA, "  Vcc (default) mismatch "
-			       "- skipping this entry\n");
-			return -ENODEV;
-		}
-	}
-
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
 		p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
 	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
@@ -553,6 +530,10 @@ static int prism2_config(struct pcmcia_device *link)
 	}
 
 	/* Look for an appropriate configuration table entry in the CIS */
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO |
+		CONF_AUTO_CHECK_VCC;
+	if (ignore_cis_vcc)
+		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, prism2_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 6020c19..031f3e6 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -797,7 +797,6 @@ static void if_cs_release(struct pcmcia_device *p_dev)
 static int if_cs_ioprobe(struct pcmcia_device *p_dev,
 			 cistpl_cftable_entry_t *cfg,
 			 cistpl_cftable_entry_t *dflt,
-			 unsigned int vcc,
 			 void *priv_data)
 {
 	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 00316a1..b921738 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -145,39 +145,11 @@ static void orinoco_cs_detach(struct pcmcia_device *link)
 static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
 				   cistpl_cftable_entry_t *cfg,
 				   cistpl_cftable_entry_t *dflt,
-				   unsigned int vcc,
 				   void *priv_data)
 {
 	if (cfg->index == 0)
 		goto next_entry;
 
-	/* Use power settings for Vcc and Vpp if present */
-	/* Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-			DEBUG(2, "%s: Vcc mismatch (vcc = %d, CIS = %d)\n",
-			      __func__, vcc,
-			      cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
-			if (!ignore_cis_vcc)
-				goto next_entry;
-		}
-	} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-			DEBUG(2, "%s: Vcc mismatch (vcc = %d, CIS = %d)\n",
-			      __func__, vcc,
-			      dflt->vcc.param[CISTPL_POWER_VNOM] / 10000);
-			if (!ignore_cis_vcc)
-				goto next_entry;
-		}
-	}
-
-	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-	else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
 	/* Do we need to allocate an interrupt? */
 	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
@@ -230,6 +202,9 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+	if (ignore_cis_vcc)
+		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, orinoco_cs_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index ca2c6c0..f462c78 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -207,32 +207,11 @@ static void spectrum_cs_detach(struct pcmcia_device *link)
 static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
 				    cistpl_cftable_entry_t *cfg,
 				    cistpl_cftable_entry_t *dflt,
-				    unsigned int vcc,
 				    void *priv_data)
 {
 	if (cfg->index == 0)
 		goto next_entry;
 
-	/* Use power settings for Vcc and Vpp if present */
-	/* Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-			DEBUG(2, "%s: Vcc mismatch (vcc = %d, CIS = %d)\n",
-			      __func__, vcc,
-			      cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
-			if (!ignore_cis_vcc)
-				goto next_entry;
-		}
-	} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-		if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-			DEBUG(2, "%s: Vcc mismatch (vcc = %d, CIS = %d)\n",
-			      __func__, vcc,
-			      dflt->vcc.param[CISTPL_POWER_VNOM] / 10000);
-			if (!ignore_cis_vcc)
-				goto next_entry;
-		}
-	}
-
 	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
 		p_dev->vpp =
 			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
@@ -292,6 +271,9 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
+	link->config_flags |= CONF_AUTO_SET_VPP | CONF_AUTO_CHECK_VCC;
+	if (ignore_cis_vcc)
+		link->config_flags &= ~CONF_AUTO_CHECK_VCC;
 	ret = pcmcia_loop_config(link, spectrum_cs_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index 63b3d3c..8c2a473 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -136,7 +136,6 @@ static void parport_detach(struct pcmcia_device *link)
 static int parport_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
diff --git a/drivers/pcmcia/pcmcia_cis.c b/drivers/pcmcia/pcmcia_cis.c
index ce8b94a..d3f8d47 100644
--- a/drivers/pcmcia/pcmcia_cis.c
+++ b/drivers/pcmcia/pcmcia_cis.c
@@ -131,7 +131,6 @@ struct pcmcia_cfg_mem {
 	int (*conf_check) (struct pcmcia_device *p_dev,
 			   cistpl_cftable_entry_t *cfg,
 			   cistpl_cftable_entry_t *dflt,
-			   unsigned int vcc,
 			   void *priv_data);
 	cisparse_t parse;
 	cistpl_cftable_entry_t dflt;
@@ -146,16 +145,46 @@ struct pcmcia_cfg_mem {
  */
 static int pcmcia_do_loop_config(tuple_t *tuple, cisparse_t *parse, void *priv)
 {
-	cistpl_cftable_entry_t *cfg = &parse->cftable_entry;
 	struct pcmcia_cfg_mem *cfg_mem = priv;
+	struct pcmcia_device *p_dev = cfg_mem->p_dev;
+	cistpl_cftable_entry_t *cfg = &parse->cftable_entry;
+	cistpl_cftable_entry_t *dflt = &cfg_mem->dflt;
+	unsigned int flags = p_dev->config_flags;
+	unsigned int vcc = p_dev->socket->socket.Vcc;
+
+	dev_dbg(&p_dev->dev, "testing configuration %d, autoconf %x\n",
+		cfg->index, flags);
 
 	/* default values */
 	cfg_mem->p_dev->config_index = cfg->index;
 	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
 		cfg_mem->dflt = *cfg;
 
+	/* check for matching Vcc? */
+	if (flags & CONF_AUTO_CHECK_VCC) {
+		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
+			if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000)
+				return -ENODEV;
+		} else if (dflt->vcc.present & (1 << CISTPL_POWER_VNOM)) {
+			if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM] / 10000)
+				return -ENODEV;
+		}
+	}
+
+	/* set Vpp? */
+	if (flags & CONF_AUTO_SET_VPP) {
+		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
+			p_dev->vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+		else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM))
+			p_dev->vpp =
+				dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+	}
+
+	/* enable audio? */
+	if ((flags & CONF_AUTO_AUDIO) && (cfg->flags & CISTPL_CFTABLE_AUDIO))
+		p_dev->config_flags |= CONF_ENABLE_SPKR;
+
 	return cfg_mem->conf_check(cfg_mem->p_dev, cfg, &cfg_mem->dflt,
-				   cfg_mem->p_dev->socket->socket.Vcc,
 				   cfg_mem->priv_data);
 }
 
@@ -176,7 +205,6 @@ int pcmcia_loop_config(struct pcmcia_device *p_dev,
 		       int	(*conf_check)	(struct pcmcia_device *p_dev,
 						 cistpl_cftable_entry_t *cfg,
 						 cistpl_cftable_entry_t *dflt,
-						 unsigned int vcc,
 						 void *priv_data),
 		       void *priv_data)
 {
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index e1f7485..0b5fc2f 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -124,7 +124,6 @@ static void aha152x_detach(struct pcmcia_device *link)
 static int aha152x_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	p_dev->io_lines = 10;
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index ae263b1..3b9f311 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -106,7 +106,6 @@ static void fdomain_detach(struct pcmcia_device *link)
 static int fdomain_config_check(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	p_dev->io_lines = 10;
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index 7cb1ae6..9b4ac20 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1597,7 +1597,6 @@ static void nsp_cs_detach(struct pcmcia_device *link)
 static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	struct nsp_hw_data		*data = priv_data;
@@ -1605,77 +1604,49 @@ static int nsp_cs_config_check(struct pcmcia_device *p_dev,
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-		if (vcc != cfg->vcc.param[CISTPL_POWER_VNOM]/10000)
-			return -ENODEV;
-		else if (dflt->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-			if (vcc != dflt->vcc.param[CISTPL_POWER_VNOM]/10000)
-				return -ENODEV;
-		}
-
-		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM)) {
-			p_dev->vpp =
-				cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		} else if (dflt->vpp1.present & (1 << CISTPL_POWER_VNOM)) {
-			p_dev->vpp =
-				dflt->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		}
-
-		/* Do we need to allocate an interrupt? */
-		p_dev->config_flags |= CONF_ENABLE_IRQ;
-
-		/* IO window settings */
-		p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
-		if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
-			cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
-			p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
-			p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
-			p_dev->resource[0]->flags |=
-				pcmcia_io_cfg_data_width(io->flags);
-			p_dev->resource[0]->start = io->win[0].base;
-			p_dev->resource[0]->end = io->win[0].len;
-			if (io->nwin > 1) {
-				p_dev->resource[1]->flags =
-					p_dev->resource[0]->flags;
-				p_dev->resource[1]->start = io->win[1].base;
-				p_dev->resource[1]->end = io->win[1].len;
-			}
-			/* This reserves IO space but doesn't actually enable it */
-			if (pcmcia_request_io(p_dev) != 0)
-				goto next_entry;
+	/* IO window settings */
+	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
+	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		p_dev->io_lines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->resource[0]->flags &= ~IO_DATA_PATH_WIDTH;
+		p_dev->resource[0]->flags |=
+					pcmcia_io_cfg_data_width(io->flags);
+		p_dev->resource[0]->start = io->win[0].base;
+		p_dev->resource[0]->end = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->resource[1]->flags = p_dev->resource[0]->flags;
+			p_dev->resource[1]->start = io->win[1].base;
+			p_dev->resource[1]->end = io->win[1].len;
 		}
+		/* This reserves IO space but doesn't actually enable it */
+		if (pcmcia_request_io(p_dev) != 0)
+			goto next_entry;
+	}
 
-		if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
-			cistpl_mem_t	*mem =
-				(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
-			p_dev->resource[2]->flags |= (WIN_DATA_WIDTH_16 |
-						WIN_MEMORY_TYPE_CM |
-						WIN_ENABLE);
-			p_dev->resource[2]->start = mem->win[0].host_addr;
-			p_dev->resource[2]->end = mem->win[0].len;
-			if (p_dev->resource[2]->end < 0x1000)
-				p_dev->resource[2]->end = 0x1000;
-			if (pcmcia_request_window(p_dev, p_dev->resource[2],
-							0) != 0)
-				goto next_entry;
-			if (pcmcia_map_mem_page(p_dev, p_dev->resource[2],
-					mem->win[0].card_addr) != 0)
-				goto next_entry;
-
-			data->MmioAddress = (unsigned long)
-				ioremap_nocache(p_dev->resource[2]->start,
+	if ((cfg->mem.nwin > 0) || (dflt->mem.nwin > 0)) {
+		cistpl_mem_t	*mem =
+			(cfg->mem.nwin) ? &cfg->mem : &dflt->mem;
+		p_dev->resource[2]->flags |= (WIN_DATA_WIDTH_16 |
+					WIN_MEMORY_TYPE_CM |
+					WIN_ENABLE);
+		p_dev->resource[2]->start = mem->win[0].host_addr;
+		p_dev->resource[2]->end = mem->win[0].len;
+		if (p_dev->resource[2]->end < 0x1000)
+			p_dev->resource[2]->end = 0x1000;
+		if (pcmcia_request_window(p_dev, p_dev->resource[2], 0) != 0)
+			goto next_entry;
+		if (pcmcia_map_mem_page(p_dev, p_dev->resource[2],
+						mem->win[0].card_addr) != 0)
+			goto next_entry;
+
+		data->MmioAddress = (unsigned long)
+			ioremap_nocache(p_dev->resource[2]->start,
 					resource_size(p_dev->resource[2]));
-			data->MmioLength  = resource_size(p_dev->resource[2]);
-		}
-		/* If we got this far, we're cool! */
-		return 0;
+		data->MmioLength  = resource_size(p_dev->resource[2]);
 	}
+	/* If we got this far, we're cool! */
+	return 0;
 
 next_entry:
 	nsp_dbg(NSP_DEBUG_INIT, "next");
@@ -1692,6 +1663,9 @@ static int nsp_cs_config(struct pcmcia_device *link)
 
 	nsp_dbg(NSP_DEBUG_INIT, "in");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_CHECK_VCC |
+		CONF_AUTO_SET_VPP | CONF_AUTO_AUDIO;
+
 	ret = pcmcia_loop_config(link, nsp_cs_config_check, data);
 	if (ret)
 		goto cs_failed;
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 7d3f49c..468fd12 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -179,7 +179,6 @@ static void qlogic_detach(struct pcmcia_device *link)
 static int qlogic_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cfg,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	p_dev->io_lines = 10;
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 600630e..7a0bb9a 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -686,7 +686,6 @@ static struct scsi_host_template sym53c500_driver_template = {
 static int SYM53C500_config_check(struct pcmcia_device *p_dev,
 				  cistpl_cftable_entry_t *cfg,
 				  cistpl_cftable_entry_t *dflt,
-				  unsigned int vcc,
 				  void *priv_data)
 {
 	p_dev->io_lines = 10;
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 2285d5d..57e042b 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -406,16 +406,11 @@ static int setup_serial(struct pcmcia_device *handle, struct serial_info * info,
 static int simple_config_check(struct pcmcia_device *p_dev,
 			       cistpl_cftable_entry_t *cf,
 			       cistpl_cftable_entry_t *dflt,
-			       unsigned int vcc,
 			       void *priv_data)
 {
 	static const int size_table[2] = { 8, 16 };
 	int *try = priv_data;
 
-	if (cf->vpp1.present & (1 << CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			cf->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
 	p_dev->io_lines = ((*try & 0x1) == 0) ?
 			16 : cf->io.flags & CISTPL_IO_LINES_MASK;
 
@@ -431,7 +426,6 @@ static int simple_config_check(struct pcmcia_device *p_dev,
 static int simple_config_check_notpicky(struct pcmcia_device *p_dev,
 					cistpl_cftable_entry_t *cf,
 					cistpl_cftable_entry_t *dflt,
-					unsigned int vcc,
 					void *priv_data)
 {
 	static const unsigned int base[5] = { 0x3f8, 0x2f8, 0x3e8, 0x2e8, 0x0 };
@@ -476,6 +470,7 @@ static int simple_config(struct pcmcia_device *link)
 
 	/* First pass: look for a config entry that looks normal.
 	 * Two tries: without IO aliases, then with aliases */
+	link->config_flags |= CONF_AUTO_SET_VPP;
 	for (try = 0; try < 4; try++)
 		if (!pcmcia_loop_config(link, simple_config_check, &try))
 			goto found_port;
@@ -509,7 +504,6 @@ found_port:
 static int multi_config_check(struct pcmcia_device *p_dev,
 			      cistpl_cftable_entry_t *cf,
 			      cistpl_cftable_entry_t *dflt,
-			      unsigned int vcc,
 			      void *priv_data)
 {
 	int *base2 = priv_data;
@@ -530,7 +524,6 @@ static int multi_config_check(struct pcmcia_device *p_dev,
 static int multi_config_check_notpicky(struct pcmcia_device *p_dev,
 				       cistpl_cftable_entry_t *cf,
 				       cistpl_cftable_entry_t *dflt,
-				       unsigned int vcc,
 				       void *priv_data)
 {
 	int *base2 = priv_data;
@@ -620,7 +613,6 @@ static int multi_config(struct pcmcia_device *link)
 static int serial_check_for_multi(struct pcmcia_device *p_dev,
 				  cistpl_cftable_entry_t *cf,
 				  cistpl_cftable_entry_t *dflt,
-				  unsigned int vcc,
 				  void *priv_data)
 {
 	struct serial_info *info = p_dev->priv;
diff --git a/drivers/staging/comedi/drivers/cb_das16_cs.c b/drivers/staging/comedi/drivers/cb_das16_cs.c
index ee91c89..678fbf6 100644
--- a/drivers/staging/comedi/drivers/cb_das16_cs.c
+++ b/drivers/staging/comedi/drivers/cb_das16_cs.c
@@ -712,7 +712,6 @@ static void das16cs_pcmcia_detach(struct pcmcia_device *link)
 static int das16cs_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
diff --git a/drivers/staging/comedi/drivers/das08_cs.c b/drivers/staging/comedi/drivers/das08_cs.c
index f8f3de5..12a96b7 100644
--- a/drivers/staging/comedi/drivers/das08_cs.c
+++ b/drivers/staging/comedi/drivers/das08_cs.c
@@ -194,7 +194,6 @@ static void das08_pcmcia_detach(struct pcmcia_device *link)
 static int das08_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
diff --git a/drivers/staging/comedi/drivers/ni_daq_700.c b/drivers/staging/comedi/drivers/ni_daq_700.c
index 803683b..f22dc0f 100644
--- a/drivers/staging/comedi/drivers/ni_daq_700.c
+++ b/drivers/staging/comedi/drivers/ni_daq_700.c
@@ -532,19 +532,11 @@ static void dio700_cs_detach(struct pcmcia_device *link)
 static int dio700_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -578,6 +570,8 @@ static void dio700_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "dio700_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO;
+
 	ret = pcmcia_loop_config(link, dio700_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/staging/comedi/drivers/ni_daq_dio24.c b/drivers/staging/comedi/drivers/ni_daq_dio24.c
index 6512f7a..6dc2b06 100644
--- a/drivers/staging/comedi/drivers/ni_daq_dio24.c
+++ b/drivers/staging/comedi/drivers/ni_daq_dio24.c
@@ -284,19 +284,11 @@ static void dio24_cs_detach(struct pcmcia_device *link)
 static int dio24_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -329,6 +321,8 @@ static void dio24_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "dio24_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_AUDIO;
+
 	ret = pcmcia_loop_config(link, dio24_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/staging/comedi/drivers/ni_labpc_cs.c b/drivers/staging/comedi/drivers/ni_labpc_cs.c
index 255cf40..6eacbd7 100644
--- a/drivers/staging/comedi/drivers/ni_labpc_cs.c
+++ b/drivers/staging/comedi/drivers/ni_labpc_cs.c
@@ -263,19 +263,11 @@ static void labpc_cs_detach(struct pcmcia_device *link)
 static int labpc_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Does this card need audio output? */
-	if (cfg->flags & CISTPL_CFTABLE_AUDIO)
-		p_dev->config_flags |= CONF_ENABLE_SPKR;
-
-	/* Do we need to allocate an interrupt? */
-	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -307,6 +299,9 @@ static void labpc_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "labpc_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ | CONF_ENABLE_PULSE_IRQ |
+		CONF_AUTO_AUDIO;
+
 	ret = pcmcia_loop_config(link, labpc_pcmcia_config_loop, NULL);
 	if (ret) {
 		dev_warn(&link->dev, "no configuration found\n");
diff --git a/drivers/staging/comedi/drivers/ni_mio_cs.c b/drivers/staging/comedi/drivers/ni_mio_cs.c
index b88f52d..da4e2a2 100644
--- a/drivers/staging/comedi/drivers/ni_mio_cs.c
+++ b/drivers/staging/comedi/drivers/ni_mio_cs.c
@@ -302,7 +302,6 @@ static int mio_cs_resume(struct pcmcia_device *link)
 static int mio_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	int base, ret;
diff --git a/drivers/staging/comedi/drivers/quatech_daqp_cs.c b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
index b8940d7..03a72d7 100644
--- a/drivers/staging/comedi/drivers/quatech_daqp_cs.c
+++ b/drivers/staging/comedi/drivers/quatech_daqp_cs.c
@@ -1071,7 +1071,6 @@ static void daqp_cs_detach(struct pcmcia_device *link)
 static int daqp_pcmcia_config_loop(struct pcmcia_device *p_dev,
 				cistpl_cftable_entry_t *cfg,
 				cistpl_cftable_entry_t *dflt,
-				unsigned int vcc,
 				void *priv_data)
 {
 	if (cfg->index == 0)
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index e23270d..670a76b 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -112,7 +112,6 @@ failed:
 static int ixj_config_check(struct pcmcia_device *p_dev,
 			    cistpl_cftable_entry_t *cfg,
 			    cistpl_cftable_entry_t *dflt,
-			    unsigned int vcc,
 			    void *priv_data)
 {
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 744c2cd..d960629 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -134,32 +134,11 @@ static void sl811_cs_release(struct pcmcia_device * link)
 static int sl811_cs_config_check(struct pcmcia_device *p_dev,
 				 cistpl_cftable_entry_t *cfg,
 				 cistpl_cftable_entry_t *dflt,
-				 unsigned int vcc,
 				 void *priv_data)
 {
 	if (cfg->index == 0)
 		return -ENODEV;
 
-	/* Use power settings for Vcc and Vpp if present */
-	/*  Note that the CIS values need to be rescaled */
-	if (cfg->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-		if (cfg->vcc.param[CISTPL_POWER_VNOM]/10000 != vcc)
-			return -ENODEV;
-	} else if (dflt->vcc.present & (1<<CISTPL_POWER_VNOM)) {
-		if (dflt->vcc.param[CISTPL_POWER_VNOM]/10000 != vcc)
-			return -ENODEV;
-		}
-
-	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
-		p_dev->vpp =
-			dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
-
-	/* we need an interrupt */
-	p_dev->config_flags |= CONF_ENABLE_IRQ;
-
 	/* IO window settings */
 	p_dev->resource[0]->end = p_dev->resource[1]->end = 0;
 	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
@@ -184,6 +163,9 @@ static int sl811_cs_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "sl811_cs_config\n");
 
+	link->config_flags |= CONF_ENABLE_IRQ |	CONF_AUTO_SET_VPP |
+		CONF_AUTO_CHECK_VCC;
+
 	if (pcmcia_loop_config(link, sl811_cs_config_check, NULL))
 		goto failed;
 
diff --git a/include/pcmcia/ds.h b/include/pcmcia/ds.h
index 50b03fd..0577e5f 100644
--- a/include/pcmcia/ds.h
+++ b/include/pcmcia/ds.h
@@ -177,7 +177,6 @@ int pcmcia_loop_config(struct pcmcia_device *p_dev,
 		       int	(*conf_check)	(struct pcmcia_device *p_dev,
 						 cistpl_cftable_entry_t *cf,
 						 cistpl_cftable_entry_t *dflt,
-						 unsigned int vcc,
 						 void *priv_data),
 		       void *priv_data);
 
@@ -270,6 +269,12 @@ static inline int pcmcia_io_cfg_data_width(unsigned int flags)
 #define CONF_ENABLE_PULSE_IRQ   0x04
 #define CONF_ENABLE_ESR         0x08
 
+/* flags used by pcmcia_loop_config() autoconfiguration */
+#define CONF_AUTO_CHECK_VCC	0x10 /* check for matching Vcc? */
+#define CONF_AUTO_SET_VPP	0x20 /* set Vpp? */
+#define CONF_AUTO_AUDIO		0x40 /* enable audio line? */
+
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_DS_H */
-- 
1.7.0.4

