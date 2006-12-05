From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 5/9] pcmcia: conf.ConfigBase and conf.Present consolidation
Date: Mon, 4 Dec 2006 21:17:16 -0500
Message-ID: <20061205021716.GF2624@dominikbrodowski.de>
References: <20061205015942.GA2624@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, bluez-devel@lists.sf.net,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-parport@lists.infradead.org,
	linux-usb-devel@lists.sourceforge.net, laforge@gnumonks.org
Return-path: <linux-serial-owner@vger.kernel.org>
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20061205015942.GA2624@dominikbrodowski.de>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Wed, 25 Oct 2006 21:49:27 -0400
Subject: [PATCH] pcmcia: conf.ConfigBase and conf.Present consolidation

struct pcmcia_device *p_dev->conf.ConfigBase and .Present are set in almost
all PCMICA driver right at the beginning, using the same calls but slightly
different implementations. Unfiy this in the PCMCIA core.

Includes a small bugfix ("drivers/net/pcmcia/xirc2ps_cs.c: remove unused
label") from and Signed-off-by Adrian Bunk <bunk@stusta.de>

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c               |    7 -----
 drivers/bluetooth/bluecard_cs.c         |   38 +------------------------------
 drivers/bluetooth/bt3c_cs.c             |   20 +---------------
 drivers/bluetooth/btuart_cs.c           |   20 +---------------
 drivers/bluetooth/dtl1_cs.c             |   20 +---------------
 drivers/char/pcmcia/cm4000_cs.c         |   20 ----------------
 drivers/char/pcmcia/cm4040_cs.c         |   20 ----------------
 drivers/char/pcmcia/synclink_cs.c       |    7 -----
 drivers/ide/legacy/ide-cs.c             |    6 -----
 drivers/isdn/hardware/avm/avm_cs.c      |   22 ------------------
 drivers/isdn/hisax/avma1_cs.c           |   22 ------------------
 drivers/isdn/hisax/elsa_cs.c            |   17 -------------
 drivers/isdn/hisax/sedlbauer_cs.c       |   10 --------
 drivers/isdn/hisax/teles_cs.c           |   17 -------------
 drivers/net/pcmcia/3c574_cs.c           |   16 +++---------
 drivers/net/pcmcia/3c589_cs.c           |    7 -----
 drivers/net/pcmcia/axnet_cs.c           |    6 +----
 drivers/net/pcmcia/com20020_cs.c        |   13 ----------
 drivers/net/pcmcia/fmvj18x_cs.c         |   14 +----------
 drivers/net/pcmcia/ibmtr_cs.c           |   12 ---------
 drivers/net/pcmcia/nmclan_cs.c          |   12 +---------
 drivers/net/pcmcia/pcnet_cs.c           |    8 ------
 drivers/net/pcmcia/smc91c92_cs.c        |   24 -------------------
 drivers/net/pcmcia/xirc2ps_cs.c         |    9 -------
 drivers/net/wireless/airo_cs.c          |   19 +++------------
 drivers/net/wireless/atmel_cs.c         |   11 ---------
 drivers/net/wireless/hostap/hostap_cs.c |    6 -----
 drivers/net/wireless/netwave_cs.c       |   18 --------------
 drivers/net/wireless/orinoco_cs.c       |   19 +++------------
 drivers/net/wireless/ray_cs.c           |   15 ------------
 drivers/net/wireless/spectrum_cs.c      |   19 +++------------
 drivers/net/wireless/wavelan_cs.c       |   33 --------------------------
 drivers/net/wireless/wl3501_cs.c        |   15 ------------
 drivers/parport/parport_cs.c            |    8 ------
 drivers/pcmcia/ds.c                     |   13 ++++++++++
 drivers/scsi/pcmcia/aha152x_stub.c      |    7 +-----
 drivers/scsi/pcmcia/fdomain_stub.c      |    5 ----
 drivers/scsi/pcmcia/nsp_cs.c            |    6 -----
 drivers/scsi/pcmcia/qlogic_stub.c       |    9 +-----
 drivers/scsi/pcmcia/sym53c500_cs.c      |    9 +-----
 drivers/serial/serial_cs.c              |   13 +---------
 drivers/telephony/ixj_pcmcia.c          |    7 -----
 drivers/usb/host/sl811_cs.c             |   15 +++---------
 sound/pcmcia/pdaudiocf/pdaudiocf.c      |   21 -----------------
 sound/pcmcia/vx/vxpocket.c              |   26 +--------------------
 45 files changed, 47 insertions(+), 614 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index da7c218..9ed7f58 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -154,13 +154,6 @@ static int pcmcia_init_one(struct pcmcia
 	tuple.TupleOffset = 0;
 	tuple.TupleDataMax = 255;
 	tuple.Attributes = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(pdev, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(pdev, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(pdev, &tuple, &stk->parse));
-	pdev->conf.ConfigBase = stk->parse.config.base;
-	pdev->conf.Present = stk->parse.config.rmask[0];
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index cbc0725..acfb6a4 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -892,43 +892,10 @@ static void bluecard_detach(struct pcmci
 }
 
 
-static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple, cisparse_t *parse)
-{
-	int i;
-
-	i = pcmcia_get_first_tuple(handle, tuple);
-	if (i != CS_SUCCESS)
-		return CS_NO_MORE_ITEMS;
-
-	i = pcmcia_get_tuple_data(handle, tuple);
-	if (i != CS_SUCCESS)
-		return i;
-
-	return pcmcia_parse_tuple(handle, tuple, parse);
-}
-
 static int bluecard_config(struct pcmcia_device *link)
 {
 	bluecard_info_t *info = link->priv;
-	tuple_t tuple;
-	u_short buf[256];
-	cisparse_t parse;
-	int i, n, last_ret, last_fn;
-
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleOffset = 0;
-	tuple.TupleDataMax = 255;
-	tuple.Attributes = 0;
-
-	/* Get configuration register information */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	last_ret = first_tuple(link, &tuple, &parse);
-	if (last_ret != CS_SUCCESS) {
-		last_fn = ParseTuple;
-		goto cs_failed;
-	}
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
+	int i, n;
 
 	link->conf.ConfigIndex = 0x20;
 	link->io.NumPorts1 = 64;
@@ -966,9 +933,6 @@ static int bluecard_config(struct pcmcia
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
-
 failed:
 	bluecard_release(link);
 	return -ENODEV;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 3a96a0b..aae3aba 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -713,22 +713,7 @@ static int bt3c_config(struct pcmcia_dev
 	u_short buf[256];
 	cisparse_t parse;
 	cistpl_cftable_entry_t *cf = &parse.cftable_entry;
-	int i, j, try, last_ret, last_fn;
-
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleOffset = 0;
-	tuple.TupleDataMax = 255;
-	tuple.Attributes = 0;
-
-	/* Get configuration register information */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	last_ret = first_tuple(link, &tuple, &parse);
-	if (last_ret != CS_SUCCESS) {
-		last_fn = ParseTuple;
-		goto cs_failed;
-	}
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
+	int i, j, try;
 
 	/* First pass: look for a config entry that looks normal. */
 	tuple.TupleData = (cisdata_t *)buf;
@@ -802,9 +787,6 @@ found_port:
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
-
 failed:
 	bt3c_release(link);
 	return -ENODEV;
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index 3b29086..92648ef 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -644,22 +644,7 @@ static int btuart_config(struct pcmcia_d
 	u_short buf[256];
 	cisparse_t parse;
 	cistpl_cftable_entry_t *cf = &parse.cftable_entry;
-	int i, j, try, last_ret, last_fn;
-
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleOffset = 0;
-	tuple.TupleDataMax = 255;
-	tuple.Attributes = 0;
-
-	/* Get configuration register information */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	last_ret = first_tuple(link, &tuple, &parse);
-	if (last_ret != CS_SUCCESS) {
-		last_fn = ParseTuple;
-		goto cs_failed;
-	}
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
+	int i, j, try;
 
 	/* First pass: look for a config entry that looks normal. */
 	tuple.TupleData = (cisdata_t *) buf;
@@ -734,9 +719,6 @@ found_port:
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
-
 failed:
 	btuart_release(link);
 	return -ENODEV;
diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 07eafbc..77b99ee 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -626,22 +626,7 @@ static int dtl1_config(struct pcmcia_dev
 	u_short buf[256];
 	cisparse_t parse;
 	cistpl_cftable_entry_t *cf = &parse.cftable_entry;
-	int i, last_ret, last_fn;
-
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleOffset = 0;
-	tuple.TupleDataMax = 255;
-	tuple.Attributes = 0;
-
-	/* Get configuration register information */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	last_ret = first_tuple(link, &tuple, &parse);
-	if (last_ret != CS_SUCCESS) {
-		last_fn = ParseTuple;
-		goto cs_failed;
-	}
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
+	int i;
 
 	tuple.TupleData = (cisdata_t *)buf;
 	tuple.TupleOffset = 0;
@@ -690,9 +675,6 @@ static int dtl1_config(struct pcmcia_dev
 
 	return 0;
 
-cs_failed:
-	cs_error(link, last_fn, last_ret);
-
 failed:
 	dtl1_release(link);
 	return -ENODEV;
diff --git a/drivers/char/pcmcia/cm4000_cs.c b/drivers/char/pcmcia/cm4000_cs.c
index d9fdef2..211c93f 100644
--- a/drivers/char/pcmcia/cm4000_cs.c
+++ b/drivers/char/pcmcia/cm4000_cs.c
@@ -1764,29 +1764,11 @@ static int cm4000_config(struct pcmcia_d
 	int rc;
 
 	/* read the config-tuples */
-	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
 
-	if ((fail_rc = pcmcia_get_first_tuple(link, &tuple)) != CS_SUCCESS) {
-		fail_fn = GetFirstTuple;
-		goto cs_failed;
-	}
-	if ((fail_rc = pcmcia_get_tuple_data(link, &tuple)) != CS_SUCCESS) {
-		fail_fn = GetTupleData;
-		goto cs_failed;
-	}
-	if ((fail_rc =
-	     pcmcia_parse_tuple(link, &tuple, &parse)) != CS_SUCCESS) {
-		fail_fn = ParseTuple;
-		goto cs_failed;
-	}
-
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	link->io.BasePort2 = 0;
 	link->io.NumPorts2 = 0;
 	link->io.Attributes2 = 0;
@@ -1841,8 +1823,6 @@ static int cm4000_config(struct pcmcia_d
 
 	return 0;
 
-cs_failed:
-	cs_error(link, fail_fn, fail_rc);
 cs_release:
 	cm4000_release(link);
 	return -ENODEV;
diff --git a/drivers/char/pcmcia/cm4040_cs.c b/drivers/char/pcmcia/cm4040_cs.c
index 7368332..9b1ff7e 100644
--- a/drivers/char/pcmcia/cm4040_cs.c
+++ b/drivers/char/pcmcia/cm4040_cs.c
@@ -523,29 +523,11 @@ static int reader_config(struct pcmcia_d
 	int fail_fn, fail_rc;
 	int rc;
 
-	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
  	tuple.TupleOffset = 0;
 
-	if ((fail_rc = pcmcia_get_first_tuple(link, &tuple)) != CS_SUCCESS) {
-		fail_fn = GetFirstTuple;
-		goto cs_failed;
-	}
-	if ((fail_rc = pcmcia_get_tuple_data(link, &tuple)) != CS_SUCCESS) {
-		fail_fn = GetTupleData;
-		goto cs_failed;
-	}
-	if ((fail_rc = pcmcia_parse_tuple(link, &tuple, &parse))
-							!= CS_SUCCESS) {
-		fail_fn = ParseTuple;
-		goto cs_failed;
-	}
-
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	link->io.BasePort2 = 0;
 	link->io.NumPorts2 = 0;
 	link->io.Attributes2 = 0;
@@ -609,8 +591,6 @@ static int reader_config(struct pcmcia_d
 
 	return 0;
 
-cs_failed:
-	cs_error(link, fail_fn, fail_rc);
 cs_release:
 	reader_release(link);
 	return -ENODEV;
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 1a0bc30..f9f7250 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -604,17 +604,10 @@ static int mgslpc_config(struct pcmcia_d
     if (debug_level >= DEBUG_LEVEL_INFO)
 	    printk("mgslpc_config(0x%p)\n", link);
 
-    /* read CONFIG tuple to find its configuration registers */
-    tuple.DesiredTuple = CISTPL_CONFIG;
     tuple.Attributes = 0;
     tuple.TupleData = buf;
     tuple.TupleDataMax = sizeof(buf);
     tuple.TupleOffset = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
 
     /* get CIS configuration entry */
 
diff --git a/drivers/ide/legacy/ide-cs.c b/drivers/ide/legacy/ide-cs.c
index 1b996e6..7efd28a 100644
--- a/drivers/ide/legacy/ide-cs.c
+++ b/drivers/ide/legacy/ide-cs.c
@@ -192,12 +192,6 @@ static int ide_config(struct pcmcia_devi
     tuple.TupleOffset = 0;
     tuple.TupleDataMax = 255;
     tuple.Attributes = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &stk->parse));
-    link->conf.ConfigBase = stk->parse.config.base;
-    link->conf.Present = stk->parse.config.rmask[0];
 
     is_kme = ((link->manf_id == MANFID_KME) &&
 	      ((link->card_id == PRODID_KME_KXLC005_A) ||
diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index db3755b..fd5d736 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -194,28 +194,6 @@ static int avmcs_config(struct pcmcia_de
 
     dev = link->priv;
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    do {
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	i = pcmcia_get_first_tuple(link, &tuple);
-	if (i != CS_SUCCESS) break;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = 64;
-	tuple.TupleOffset = 0;
-	i = pcmcia_get_tuple_data(link, &tuple);
-	if (i != CS_SUCCESS) break;
-	i = pcmcia_parse_tuple(link, &tuple, &parse);
-	if (i != CS_SUCCESS) break;
-	link->conf.ConfigBase = parse.config.base;
-    } while (0);
-    if (i != CS_SUCCESS) {
-	cs_error(link, ParseTuple, i);
-	return -ENODEV;
-    }
-
     do {
 	devname[0] = 0;
 	if (link->prod_id[1])
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index 40c9b02..876fec6 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -216,28 +216,6 @@ static int avma1cs_config(struct pcmcia_
 
     DEBUG(0, "avma1cs_config(0x%p)\n", link);
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    do {
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	i = pcmcia_get_first_tuple(link, &tuple);
-	if (i != CS_SUCCESS) break;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = 64;
-	tuple.TupleOffset = 0;
-	i = pcmcia_get_tuple_data(link, &tuple);
-	if (i != CS_SUCCESS) break;
-	i = pcmcia_parse_tuple(link, &tuple, &parse);
-	if (i != CS_SUCCESS) break;
-	link->conf.ConfigBase = parse.config.base;
-    } while (0);
-    if (i != CS_SUCCESS) {
-	cs_error(link, ParseTuple, i);
-	return -ENODEV;
-    }
-
     do {
 	devname[0] = 0;
 	if (link->prod_id[1])
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index e18e75b..4e180d2 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -242,23 +242,6 @@ static int elsa_cs_config(struct pcmcia_
     DEBUG(0, "elsa_config(0x%p)\n", link);
     dev = link->priv;
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    tuple.TupleData = (cisdata_t *)buf;
-    tuple.TupleDataMax = 255;
-    tuple.TupleOffset = 0;
-    tuple.Attributes = 0;
-    i = first_tuple(link, &tuple, &parse);
-    if (i != CS_SUCCESS) {
-        last_fn = ParseTuple;
-	goto cs_failed;
-    }
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
     tuple.Attributes = 0;
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index f9c14a2..46ed653 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -233,20 +233,10 @@ static int sedlbauer_config(struct pcmci
 
     DEBUG(0, "sedlbauer_config(0x%p)\n", link);
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    tuple.DesiredTuple = CISTPL_CONFIG;
     tuple.Attributes = 0;
     tuple.TupleData = buf;
     tuple.TupleDataMax = sizeof(buf);
     tuple.TupleOffset = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
 
     CS_CHECK(GetConfigurationInfo, pcmcia_get_configuration_info(link, &conf));
 
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index afcc2ae..6b754f1 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -232,23 +232,6 @@ static int teles_cs_config(struct pcmcia
     DEBUG(0, "teles_config(0x%p)\n", link);
     dev = link->priv;
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    tuple.TupleData = (cisdata_t *)buf;
-    tuple.TupleDataMax = 255;
-    tuple.TupleOffset = 0;
-    tuple.Attributes = 0;
-    i = first_tuple(link, &tuple, &parse);
-    if (i != CS_SUCCESS) {
-        last_fn = ParseTuple;
-	goto cs_failed;
-    }
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
     tuple.Attributes = 0;
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 420f70b..794cc61 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -338,7 +338,6 @@ static int tc574_config(struct pcmcia_de
 	struct net_device *dev = link->priv;
 	struct el3_private *lp = netdev_priv(dev);
 	tuple_t tuple;
-	cisparse_t parse;
 	unsigned short buf[32];
 	int last_fn, last_ret, i, j;
 	kio_addr_t ioaddr;
@@ -350,17 +349,6 @@ static int tc574_config(struct pcmcia_de
 
 	DEBUG(0, "3c574_config(0x%p)\n", link);
 
-	tuple.Attributes = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleDataMax = 64;
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	link->io.IOAddrLines = 16;
 	for (i = j = 0; j < 0x400; j += 0x20) {
 		link->io.BasePort1 = j ^ 0x300;
@@ -382,6 +370,10 @@ static int tc574_config(struct pcmcia_de
 	/* The 3c574 normally uses an EEPROM for configuration info, including
 	   the hardware address.  The future products may include a modem chip
 	   and put the address in the CIS. */
+	tuple.Attributes = 0;
+	tuple.TupleData = (cisdata_t *)buf;
+	tuple.TupleDataMax = 64;
+	tuple.TupleOffset = 0;
 	tuple.DesiredTuple = 0x88;
 	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
 		pcmcia_get_tuple_data(link, &tuple);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index eb57832..1e73ff7 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -253,7 +253,6 @@ static int tc589_config(struct pcmcia_de
     struct net_device *dev = link->priv;
     struct el3_private *lp = netdev_priv(dev);
     tuple_t tuple;
-    cisparse_t parse;
     u16 buf[32], *phys_addr;
     int last_fn, last_ret, i, j, multi = 0, fifo;
     kio_addr_t ioaddr;
@@ -263,15 +262,9 @@ static int tc589_config(struct pcmcia_de
 
     phys_addr = (u16 *)dev->dev_addr;
     tuple.Attributes = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleDataMax = sizeof(buf);
     tuple.TupleOffset = 0;
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
     tuple.Attributes = TUPLE_RETURN_COMMON;
 
     /* Is this a 3c562? */
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 5ddd574..6139048 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -299,11 +299,7 @@ static int axnet_config(struct pcmcia_de
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleDataMax = sizeof(buf);
     tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
+
     /* don't trust the CIS on this; Linksys got it wrong */
     link->conf.Present = 0x63;
 
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index 48434d7..91f65e9 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -249,12 +249,9 @@ do { last_fn = (fn); if ((last_ret = (re
 static int com20020_config(struct pcmcia_device *link)
 {
     struct arcnet_local *lp;
-    tuple_t tuple;
-    cisparse_t parse;
     com20020_dev_t *info;
     struct net_device *dev;
     int i, last_ret, last_fn;
-    u_char buf[64];
     int ioaddr;
 
     info = link->priv;
@@ -264,16 +261,6 @@ static int com20020_config(struct pcmcia
 
     DEBUG(0, "com20020_config(0x%p)\n", link);
 
-    tuple.Attributes = 0;
-    tuple.TupleData = buf;
-    tuple.TupleDataMax = 64;
-    tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-
     DEBUG(1,"arcnet: baseport1 is %Xh\n", link->io.BasePort1);
     i = !CS_SUCCESS;
     if (!link->io.BasePort1)
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index e3731fd..0d7de61 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -342,7 +342,7 @@ static int fmvj18x_config(struct pcmcia_
     tuple_t tuple;
     cisparse_t parse;
     u_short buf[32];
-    int i, last_fn, last_ret, ret;
+    int i, last_fn = 0, last_ret = 0, ret;
     kio_addr_t ioaddr;
     cardtype_t cardtype;
     char *card_name = "unknown";
@@ -350,21 +350,9 @@ static int fmvj18x_config(struct pcmcia_
 
     DEBUG(0, "fmvj18x_config(0x%p)\n", link);
 
-    /*
-       This reads the card's CONFIG tuple to find its configuration
-       registers.
-    */
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
     tuple.TupleData = (u_char *)buf;
     tuple.TupleDataMax = 64;
     tuple.TupleOffset = 0;
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-
-    link->conf.ConfigBase = parse.config.base; 
-    link->conf.Present = parse.config.rmask[0];
-
     tuple.DesiredTuple = CISTPL_FUNCE;
     tuple.TupleOffset = 0;
     if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) {
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index bc0ca41..a956a51 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -222,24 +222,12 @@ static int ibmtr_config(struct pcmcia_de
     ibmtr_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
     struct tok_info *ti = netdev_priv(dev);
-    tuple_t tuple;
-    cisparse_t parse;
     win_req_t req;
     memreq_t mem;
     int i, last_ret, last_fn;
-    u_char buf[64];
 
     DEBUG(0, "ibmtr_config(0x%p)\n", link);
 
-    tuple.Attributes = 0;
-    tuple.TupleData = buf;
-    tuple.TupleDataMax = 64;
-    tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
     link->conf.ConfigIndex = 0x61;
 
     /* Determine if this is PRIMARY or ALTERNATE. */
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index e77110e..3b70774 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -656,23 +656,12 @@ static int nmclan_config(struct pcmcia_d
   struct net_device *dev = link->priv;
   mace_private *lp = netdev_priv(dev);
   tuple_t tuple;
-  cisparse_t parse;
   u_char buf[64];
   int i, last_ret, last_fn;
   kio_addr_t ioaddr;
 
   DEBUG(0, "nmclan_config(0x%p)\n", link);
 
-  tuple.Attributes = 0;
-  tuple.TupleData = buf;
-  tuple.TupleDataMax = 64;
-  tuple.TupleOffset = 0;
-  tuple.DesiredTuple = CISTPL_CONFIG;
-  CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-  CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-  CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-  link->conf.ConfigBase = parse.config.base;
-
   CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
   CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
   CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
@@ -686,6 +675,7 @@ static int nmclan_config(struct pcmcia_d
   tuple.TupleData = buf;
   tuple.TupleDataMax = 64;
   tuple.TupleOffset = 0;
+  tuple.Attributes = 0;
   CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
   CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
   memcpy(dev->dev_addr, tuple.TupleData, ETHER_ADDR_LEN);
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 430a41e..2b1238e 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -525,17 +525,9 @@ static int pcnet_config(struct pcmcia_de
 
     DEBUG(0, "pcnet_config(0x%p)\n", link);
 
-    tuple.Attributes = 0;
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleDataMax = sizeof(buf);
     tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
     tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
     tuple.Attributes = 0;
     CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index bf40848..530df88 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -959,10 +959,6 @@ static int smc91c92_config(struct pcmcia
 {
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
-    struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    cisparse_t *parse;
-    u_char *buf;
     char *name;
     int i, j, rev;
     kio_addr_t ioaddr;
@@ -970,24 +966,6 @@ static int smc91c92_config(struct pcmcia
 
     DEBUG(0, "smc91c92_config(0x%p)\n", link);
 
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-	goto config_failed;
-
-    tuple = &cfg_mem->tuple;
-    parse = &cfg_mem->parse;
-    buf = cfg_mem->buf;
-
-    tuple->Attributes = tuple->TupleOffset = 0;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 64;
-
-    tuple->DesiredTuple = CISTPL_CONFIG;
-    i = first_tuple(link, tuple, parse);
-    CS_EXIT_TEST(i, ParseTuple, config_failed);
-    link->conf.ConfigBase = parse->config.base;
-    link->conf.Present = parse->config.rmask[0];
-
     smc->manfid = link->manf_id;
     smc->cardid = link->card_id;
 
@@ -1119,14 +1097,12 @@ static int smc91c92_config(struct pcmcia
     	    printk(KERN_NOTICE "  No MII transceivers found!\n");
 	}
     }
-    kfree(cfg_mem);
     return 0;
 
 config_undo:
     unregister_netdev(dev);
 config_failed:			/* CS_EXIT_TEST() calls jump to here... */
     smc91c92_release(link);
-    kfree(cfg_mem);
     return -ENODEV;
 } /* smc91c92_config */
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index d627361..6981340 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -781,13 +781,6 @@ xirc2ps_config(struct pcmcia_device * li
 	goto failure;
     }
 
-    /* get configuration stuff */
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    if ((err=first_tuple(link, &tuple, &parse)))
-	goto cis_error;
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present =    parse.config.rmask[0];
-
     /* get the ethernet address from the CIS */
     tuple.DesiredTuple = CISTPL_FUNCE;
     for (err = first_tuple(link, &tuple, &parse); !err;
@@ -1051,8 +1044,6 @@ xirc2ps_config(struct pcmcia_device * li
     xirc2ps_release(link);
     return -ENODEV;
 
-  cis_error:
-    printk(KNOT_XIRC "unable to parse CIS\n");
   failure:
     return -ENODEV;
 } /* xirc2ps_config */
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index ac9437d..f123553 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -219,21 +219,6 @@ static int airo_config(struct pcmcia_dev
 	dev = link->priv;
 
 	DEBUG(0, "airo_config(0x%p)\n", link);
-	
-	/*
-	  This reads the card's CONFIG tuple to find its configuration
-	  registers.
-	*/
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
 
 	/*
 	  In this loop, we scan the CIS for configuration table entries,
@@ -247,6 +232,10 @@ static int airo_config(struct pcmcia_dev
 	  these things without consulting the CIS, and most client drivers
 	  will only use the CIS to fill in implementation-defined details.
 	*/
+	tuple.Attributes = 0;
+	tuple.TupleData = buf;
+	tuple.TupleDataMax = sizeof(buf);
+	tuple.TupleOffset = 0;
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
 	while (1) {
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 5c41098..12617cd 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -244,17 +244,6 @@ static int atmel_config(struct pcmcia_de
 	tuple.TupleOffset = 0;
 
 	/*
-	  This reads the card's CONFIG tuple to find its configuration
-	  registers.
-	*/
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
-	/*
 	  In this loop, we scan the CIS for configuration table entries,
 	  each of which describes a valid card configuration, including
 	  voltage, IO window, memory window, and interrupt settings.
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 8a7984b..ee542ec 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -570,16 +570,10 @@ static int prism2_config(struct pcmcia_d
 	}
 	memset(hw_priv, 0, sizeof(*hw_priv));
 
-	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, parse));
-	link->conf.ConfigBase = parse->config.base;
-	link->conf.Present = parse->config.rmask[0];
 
 	CS_CHECK(GetConfigurationInfo,
 		 pcmcia_get_configuration_info(link, &conf));
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 6714e0d..644b474 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -735,10 +735,7 @@ do { last_fn = (fn); if ((last_ret = (re
 static int netwave_pcmcia_config(struct pcmcia_device *link) {
     struct net_device *dev = link->priv;
     netwave_private *priv = netdev_priv(dev);
-    tuple_t tuple;
-    cisparse_t parse;
     int i, j, last_ret, last_fn;
-    u_char buf[64];
     win_req_t req;
     memreq_t mem;
     u_char __iomem *ramBase = NULL;
@@ -746,21 +743,6 @@ static int netwave_pcmcia_config(struct
     DEBUG(0, "netwave_pcmcia_config(0x%p)\n", link);
 
     /*
-      This reads the card's CONFIG tuple to find its configuration
-      registers.
-    */
-    tuple.Attributes = 0;
-    tuple.TupleData = (cisdata_t *) buf;
-    tuple.TupleDataMax = 64;
-    tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
-    /*
      *  Try allocating IO ports.  This tries a few fixed addresses.
      *  If you want, you can also read the card's config table to
      *  pick addresses -- see the serial driver for an example.
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index bc14689..d08ae8d 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -178,21 +178,6 @@ orinoco_cs_config(struct pcmcia_device *
 	cisparse_t parse;
 	void __iomem *mem;
 
-	/*
-	 * This reads the card's CONFIG tuple to find its
-	 * configuration registers.
-	 */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo,
 		 pcmcia_get_configuration_info(link, &conf));
@@ -211,6 +196,10 @@ orinoco_cs_config(struct pcmcia_device *
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
+	tuple.Attributes = 0;
+	tuple.TupleData = buf;
+	tuple.TupleDataMax = sizeof(buf);
+	tuple.TupleOffset = 0;
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
 	while (1) {
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 75cdc3e..88e10c9 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -408,11 +408,8 @@ do { last_fn = (fn); if ((last_ret = (re
 #define MAX_TUPLE_SIZE 128
 static int ray_config(struct pcmcia_device *link)
 {
-    tuple_t tuple;
-    cisparse_t parse;
     int last_fn = 0, last_ret = 0;
     int i;
-    u_char buf[MAX_TUPLE_SIZE];
     win_req_t req;
     memreq_t mem;
     struct net_device *dev = (struct net_device *)link->priv;
@@ -420,19 +417,7 @@ static int ray_config(struct pcmcia_devi
 
     DEBUG(1, "ray_config(0x%p)\n", link);
 
-    /* This reads the card's CONFIG tuple to find its configuration regs */
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    tuple.TupleData = buf;
-    tuple.TupleDataMax = MAX_TUPLE_SIZE;
-    tuple.TupleOffset = 0;
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
     /* Determine card type and firmware version */
-    buf[0] = buf[MAX_TUPLE_SIZE - 1] = 0;
     printk(KERN_INFO "ray_cs Detected: %s%s%s%s\n",
 	   link->prod_id[0] ? link->prod_id[0] : " ",
 	   link->prod_id[1] ? link->prod_id[1] : " ",
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index bcc7038..cf2d148 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -647,21 +647,6 @@ spectrum_cs_config(struct pcmcia_device
 	cisparse_t parse;
 	void __iomem *mem;
 
-	/*
-	 * This reads the card's CONFIG tuple to find its
-	 * configuration registers.
-	 */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo,
 		 pcmcia_get_configuration_info(link, &conf));
@@ -681,6 +666,10 @@ spectrum_cs_config(struct pcmcia_device
 	 * implementation-defined details.
 	 */
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
+	tuple.Attributes = 0;
+	tuple.TupleData = buf;
+	tuple.TupleDataMax = sizeof(buf);
+	tuple.TupleOffset = 0;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
 	while (1) {
 		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index aafb301..233d906 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3939,11 +3939,8 @@ wv_hw_reset(struct net_device *	dev)
 static inline int
 wv_pcmcia_config(struct pcmcia_device *	link)
 {
-  tuple_t		tuple;
-  cisparse_t		parse;
   struct net_device *	dev = (struct net_device *) link->priv;
   int			i;
-  u_char		buf[64];
   win_req_t		req;
   memreq_t		mem;
   net_local *		lp = netdev_priv(dev);
@@ -3953,36 +3950,6 @@ wv_pcmcia_config(struct pcmcia_device *
   printk(KERN_DEBUG "->wv_pcmcia_config(0x%p)\n", link);
 #endif
 
-  /*
-   * This reads the card's CONFIG tuple to find its configuration
-   * registers.
-   */
-  do
-    {
-      tuple.Attributes = 0;
-      tuple.DesiredTuple = CISTPL_CONFIG;
-      i = pcmcia_get_first_tuple(link, &tuple);
-      if(i != CS_SUCCESS)
-	break;
-      tuple.TupleData = (cisdata_t *)buf;
-      tuple.TupleDataMax = 64;
-      tuple.TupleOffset = 0;
-      i = pcmcia_get_tuple_data(link, &tuple);
-      if(i != CS_SUCCESS)
-	break;
-      i = pcmcia_parse_tuple(link, &tuple, &parse);
-      if(i != CS_SUCCESS)
-	break;
-      link->conf.ConfigBase = parse.config.base;
-      link->conf.Present = parse.config.rmask[0];
-    }
-  while(0);
-  if(i != CS_SUCCESS)
-    {
-      cs_error(link, ParseTuple, i);
-      return FALSE;
-    }
-
   do
     {
       i = pcmcia_request_io(link, &link->io);
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 5b98a78..583e0d6 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1966,25 +1966,10 @@ do { last_fn = (fn); if ((last_ret = (re
  */
 static int wl3501_config(struct pcmcia_device *link)
 {
-	tuple_t tuple;
-	cisparse_t parse;
 	struct net_device *dev = link->priv;
 	int i = 0, j, last_fn, last_ret;
-	unsigned char bf[64];
 	struct wl3501_card *this;
 
-	/* This reads the card's CONFIG tuple to find its config registers. */
-	tuple.Attributes	= 0;
-	tuple.DesiredTuple	= CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	tuple.TupleData		= bf;
-	tuple.TupleDataMax	= sizeof(bf);
-	tuple.TupleOffset	= 0;
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase	= parse.config.base;
-	link->conf.Present	= parse.config.rmask[0];
-
 	/* Try allocating IO ports.  This tries a few fixed addresses.  If you
 	 * want, you can also read the card's config table to pick addresses --
 	 * see the serial driver for an example. */
diff --git a/drivers/parport/parport_cs.c b/drivers/parport/parport_cs.c
index fb80fed..e60b4bf 100644
--- a/drivers/parport/parport_cs.c
+++ b/drivers/parport/parport_cs.c
@@ -166,14 +166,6 @@ static int parport_config(struct pcmcia_
     
     tuple.TupleData = (cisdata_t *)buf;
     tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
-    tuple.Attributes = 0;
-    tuple.DesiredTuple = CISTPL_CONFIG;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-    link->conf.Present = parse.config.rmask[0];
-
     tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
     tuple.Attributes = 0;
     CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/pcmcia/ds.c b/drivers/pcmcia/ds.c
index 6572b38..5b302e8 100644
--- a/drivers/pcmcia/ds.c
+++ b/drivers/pcmcia/ds.c
@@ -313,6 +313,7 @@ static int pcmcia_device_probe(struct de
 	struct pcmcia_driver *p_drv;
 	struct pcmcia_device_id *did;
 	struct pcmcia_socket *s;
+	cistpl_config_t cis_config;
 	int ret = 0;
 
 	dev = get_device(dev);
@@ -329,6 +330,18 @@ static int pcmcia_device_probe(struct de
 		goto put_dev;
 	}
 
+	/* set up some more device information */
+	ret = pccard_read_tuple(p_dev->socket, p_dev->func, CISTPL_CONFIG,
+				&cis_config);
+	if (!ret) {
+		p_dev->conf.ConfigBase = cis_config.base;
+		p_dev->conf.Present = cis_config.rmask[0];
+	} else {
+		printk(KERN_INFO "pcmcia: could not parse base and rmask0 of CIS\n");
+		p_dev->conf.ConfigBase = 0;
+		p_dev->conf.Present = 0;
+	}
+
 	ret = p_drv->probe(p_dev);
 	if (ret)
 		goto put_module;
diff --git a/drivers/scsi/pcmcia/aha152x_stub.c b/drivers/scsi/pcmcia/aha152x_stub.c
index ee449b2..aad362b 100644
--- a/drivers/scsi/pcmcia/aha152x_stub.c
+++ b/drivers/scsi/pcmcia/aha152x_stub.c
@@ -154,16 +154,11 @@ static int aha152x_config_cs(struct pcmc
     
     DEBUG(0, "aha152x_config(0x%p)\n", link);
 
-    tuple.DesiredTuple = CISTPL_CONFIG;
     tuple.TupleData = tuple_data;
     tuple.TupleDataMax = 64;
     tuple.TupleOffset = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
-
     tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
+    tuple.Attributes = 0;
     CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
     while (1) {
 	if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
diff --git a/drivers/scsi/pcmcia/fdomain_stub.c b/drivers/scsi/pcmcia/fdomain_stub.c
index 85f7ffa..a1c5f26 100644
--- a/drivers/scsi/pcmcia/fdomain_stub.c
+++ b/drivers/scsi/pcmcia/fdomain_stub.c
@@ -136,14 +136,9 @@ static int fdomain_config(struct pcmcia_
 
     DEBUG(0, "fdomain_config(0x%p)\n", link);
 
-    tuple.DesiredTuple = CISTPL_CONFIG;
     tuple.TupleData = tuple_data;
     tuple.TupleDataMax = 64;
     tuple.TupleOffset = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-    link->conf.ConfigBase = parse.config.base;
 
     tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
     CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/scsi/pcmcia/nsp_cs.c b/drivers/scsi/pcmcia/nsp_cs.c
index f2d79c3..d72df5d 100644
--- a/drivers/scsi/pcmcia/nsp_cs.c
+++ b/drivers/scsi/pcmcia/nsp_cs.c
@@ -1685,16 +1685,10 @@ static int nsp_cs_config(struct pcmcia_d
 
 	nsp_dbg(NSP_DEBUG_INIT, "in");
 
-	tuple.DesiredTuple    = CISTPL_CONFIG;
 	tuple.Attributes      = 0;
 	tuple.TupleData	      = tuple_data;
 	tuple.TupleDataMax    = sizeof(tuple_data);
 	tuple.TupleOffset     = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData,	pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple,	pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present    = parse.config.rmask[0];
 
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo, pcmcia_get_configuration_info(link, &conf));
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 336e370..9d431fe 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -208,16 +208,11 @@ static int qlogic_config(struct pcmcia_d
 
 	DEBUG(0, "qlogic_config(0x%p)\n", link);
 
+	info->manf_id = link->manf_id;
+
 	tuple.TupleData = (cisdata_t *) tuple_data;
 	tuple.TupleDataMax = 64;
 	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-
-	info->manf_id = link->manf_id;
 
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 80c28b9..fb7acea 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -722,16 +722,11 @@ SYM53C500_config(struct pcmcia_device *l
 
 	DEBUG(0, "SYM53C500_config(0x%p)\n", link);
 
+	info->manf_id = link->manf_id;
+
 	tuple.TupleData = (cisdata_t *)tuple_data;
 	tuple.TupleDataMax = 64;
 	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-
-	info->manf_id = link->manf_id;
 
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 7aa2820..431433f 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -723,7 +723,7 @@ static int serial_config(struct pcmcia_d
 	u_char *buf;
 	cisparse_t *parse;
 	cistpl_cftable_entry_t *cf;
-	int i, last_ret, last_fn;
+	int i;
 
 	DEBUG(0, "serial_config(0x%p)\n", link);
 
@@ -740,15 +740,6 @@ static int serial_config(struct pcmcia_d
 	tuple->TupleOffset = 0;
 	tuple->TupleDataMax = 255;
 	tuple->Attributes = 0;
-	/* Get configuration register information */
-	tuple->DesiredTuple = CISTPL_CONFIG;
-	last_ret = first_tuple(link, tuple, parse);
-	if (last_ret != CS_SUCCESS) {
-		last_fn = ParseTuple;
-		goto cs_failed;
-	}
-	link->conf.ConfigBase = parse->config.base;
-	link->conf.Present = parse->config.rmask[0];
 
 	/* Is this a compliant multifunction card? */
 	tuple->DesiredTuple = CISTPL_LONGLINK_MFC;
@@ -812,8 +803,6 @@ static int serial_config(struct pcmcia_d
 	kfree(cfg_mem);
 	return 0;
 
- cs_failed:
-	cs_error(link, last_fn, last_ret);
  failed:
 	serial_remove(link);
 	kfree(cfg_mem);
diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
index 3f88978..164a5dc 100644
--- a/drivers/telephony/ixj_pcmcia.c
+++ b/drivers/telephony/ixj_pcmcia.c
@@ -144,13 +144,6 @@ static int ixj_config(struct pcmcia_devi
 	tuple.TupleData = (cisdata_t *) buf;
 	tuple.TupleOffset = 0;
 	tuple.TupleDataMax = 255;
-	tuple.Attributes = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	tuple.Attributes = 0;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/usb/host/sl811_cs.c b/drivers/usb/host/sl811_cs.c
index 54f554e..ac9f11d 100644
--- a/drivers/usb/host/sl811_cs.c
+++ b/drivers/usb/host/sl811_cs.c
@@ -169,21 +169,14 @@ static int sl811_cs_config(struct pcmcia
 
 	DBG(0, "sl811_cs_config(0x%p)\n", link);
 
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
-
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo,
 			pcmcia_get_configuration_info(link, &conf));
 
+	tuple.Attributes = 0;
+	tuple.TupleData = buf;
+	tuple.TupleDataMax = sizeof(buf);
+	tuple.TupleOffset = 0;
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
 	while (1) {
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index a31d80c..2d40cc7 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -219,35 +219,15 @@ do { last_fn = (fn); if ((last_ret = (re
 static int pdacf_config(struct pcmcia_device *link)
 {
 	struct snd_pdacf *pdacf = link->priv;
-	tuple_t tuple;
-	cisparse_t *parse = NULL;
-	u_short buf[32];
 	int last_fn, last_ret;
 
 	snd_printdd(KERN_DEBUG "pdacf_config called\n");
-	parse = kmalloc(sizeof(*parse), GFP_KERNEL);
-	if (! parse) {
-		snd_printk(KERN_ERR "pdacf_config: cannot allocate\n");
-		return -ENOMEM;
-	}
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	tuple.Attributes = 0;
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, parse));
-	link->conf.ConfigBase = parse->config.base;
 	link->conf.ConfigIndex = 0x5;
 
 	CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
 	CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
 	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
 
-	kfree(parse);
-
 	if (snd_pdacf_assign_resources(pdacf, link->io.BasePort1, link->irq.AssignedIRQ) < 0)
 		goto failed;
 
@@ -255,7 +235,6 @@ static int pdacf_config(struct pcmcia_de
 	return 0;
 
 cs_failed:
-	kfree(parse);
 	cs_error(link, last_fn, last_ret);
 failed:
 	pcmcia_disable_device(link);
diff --git a/sound/pcmcia/vx/vxpocket.c b/sound/pcmcia/vx/vxpocket.c
index 3089fcc..d7df59e 100644
--- a/sound/pcmcia/vx/vxpocket.c
+++ b/sound/pcmcia/vx/vxpocket.c
@@ -217,34 +217,12 @@ static int vxpocket_config(struct pcmcia
 {
 	struct vx_core *chip = link->priv;
 	struct snd_vxpocket *vxp = (struct snd_vxpocket *)chip;
-	tuple_t tuple;
-	cisparse_t *parse;
-	u_short buf[32];
 	int last_fn, last_ret;
 
 	snd_printdd(KERN_DEBUG "vxpocket_config called\n");
-	parse = kmalloc(sizeof(*parse), GFP_KERNEL);
-	if (! parse) {
-		snd_printk(KERN_ERR "vx: cannot allocate\n");
-		return -ENOMEM;
-	}
-	tuple.Attributes = 0;
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, parse));
-	link->conf.ConfigBase = parse->config.base;
-	link->conf.Present = parse->config.rmask[0];
 
 	/* redefine hardware record according to the VERSION1 string */
-	tuple.DesiredTuple = CISTPL_VERS_1;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, parse));
-	if (! strcmp(parse->version_1.str + parse->version_1.ofs[1], "VX-POCKET")) {
+	if (!strcmp(link->prod_id[1], "VX-POCKET")) {
 		snd_printdd("VX-pocket is detected\n");
 	} else {
 		snd_printdd("VX-pocket 440 is detected\n");
@@ -265,14 +243,12 @@ static int vxpocket_config(struct pcmcia
 		goto failed;
 
 	link->dev_node = &vxp->node;
-	kfree(parse);
 	return 0;
 
 cs_failed:
 	cs_error(link, last_fn, last_ret);
 failed:
 	pcmcia_disable_device(link);
-	kfree(parse);
 	return -ENODEV;
 }
 
-- 
1.4.4

