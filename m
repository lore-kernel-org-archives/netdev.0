From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 13/39] pcmcia: use pcmcia_loop_config in net pcmcia drivers
Date: Mon, 18 Aug 2008 20:53:04 +0200
Message-ID: <1219085610-12289-13-git-send-email-linux@dominikbrodowski.net>
References: <20080818185025.GA11647@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:35926 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760846AbYHRSyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 14:54:08 -0400
In-Reply-To: <20080818185025.GA11647@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the config loop helper in (some) net pcmcia drivers.

CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/axnet_cs.c           |   71 ++++------
 drivers/net/pcmcia/pcnet_cs.c           |   79 +++++------
 drivers/net/pcmcia/smc91c92_cs.c        |   96 +++++---------
 drivers/net/pcmcia/xirc2ps_cs.c         |   73 ++++++----
 drivers/net/wireless/airo_cs.c          |  230 ++++++++++++++++---------------
 drivers/net/wireless/atmel_cs.c         |  123 ++++++++---------
 drivers/net/wireless/hostap/hostap_cs.c |  227 +++++++++++++++----------------
 drivers/net/wireless/orinoco_cs.c       |  176 ++++++++++++------------
 drivers/net/wireless/spectrum_cs.c      |  175 ++++++++++++------------
 9 files changed, 596 insertions(+), 654 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 3f682d4..04ece0b 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -284,58 +284,47 @@ static int try_io_port(struct pcmcia_device *link)
     }
 }
 
+static int axnet_configcheck(struct pcmcia_device *p_dev,
+			     cistpl_cftable_entry_t *cfg,
+			     void *priv_data)
+{
+	int i;
+	cistpl_io_t *io = &cfg->io;
+
+	if (cfg->index == 0 || cfg->io.nwin == 0)
+		return -ENODEV;
+
+	p_dev->conf.ConfigIndex = 0x05;
+	/* For multifunction cards, by convention, we configure the
+	   network function with window 0, and serial with window 1 */
+	if (io->nwin > 1) {
+		i = (io->win[1].len > io->win[0].len);
+		p_dev->io.BasePort2 = io->win[1-i].base;
+		p_dev->io.NumPorts2 = io->win[1-i].len;
+	} else {
+		i = p_dev->io.NumPorts2 = 0;
+	}
+	p_dev->io.BasePort1 = io->win[i].base;
+	p_dev->io.NumPorts1 = io->win[i].len;
+	p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
+	if (p_dev->io.NumPorts1 + p_dev->io.NumPorts2 >= 32)
+		return try_io_port(p_dev);
+
+	return -ENODEV;
+}
+
 static int axnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     axnet_dev_t *info = PRIV(dev);
-    tuple_t tuple;
-    cisparse_t parse;
     int i, j, last_ret, last_fn;
-    u_short buf[64];
     DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "axnet_config(0x%p)\n", link);
 
-    tuple.Attributes = 0;
-    tuple.TupleData = (cisdata_t *)buf;
-    tuple.TupleDataMax = sizeof(buf);
-    tuple.TupleOffset = 0;
-
     /* don't trust the CIS on this; Linksys got it wrong */
     link->conf.Present = 0x63;
-
-    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-    tuple.Attributes = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    while (last_ret == CS_SUCCESS) {
-	cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-	cistpl_io_t *io = &(parse.cftable_entry.io);
-	
-	if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
-		pcmcia_parse_tuple(link, &tuple, &parse) != 0 ||
-		cfg->index == 0 || cfg->io.nwin == 0)
-	    goto next_entry;
-	
-	link->conf.ConfigIndex = 0x05;
-	/* For multifunction cards, by convention, we configure the
-	   network function with window 0, and serial with window 1 */
-	if (io->nwin > 1) {
-	    i = (io->win[1].len > io->win[0].len);
-	    link->io.BasePort2 = io->win[1-i].base;
-	    link->io.NumPorts2 = io->win[1-i].len;
-	} else {
-	    i = link->io.NumPorts2 = 0;
-	}
-	link->io.BasePort1 = io->win[i].base;
-	link->io.NumPorts1 = io->win[i].len;
-	link->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-	if (link->io.NumPorts1 + link->io.NumPorts2 >= 32) {
-	    last_ret = try_io_port(link);
-	    if (last_ret == CS_SUCCESS) break;
-	}
-    next_entry:
-	last_ret = pcmcia_get_next_tuple(link, &tuple);
-    }
+    last_ret = pcmcia_loop_config(link, axnet_configcheck, NULL);
     if (last_ret != CS_SUCCESS) {
 	cs_error(link, RequestIO, last_ret);
 	goto failed;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 2d4c4ad..7a9eeca 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -512,58 +512,53 @@ static int try_io_port(struct pcmcia_device *link)
     }
 }
 
+static int pcnet_confcheck(struct pcmcia_device *p_dev,
+			   cistpl_cftable_entry_t *cfg,
+			   void *priv_data)
+{
+	int *has_shmem = priv_data;
+	int i;
+	cistpl_io_t *io = &cfg->io;
+
+	if (cfg->index == 0 || cfg->io.nwin == 0)
+		return -EINVAL;
+
+	p_dev->conf.ConfigIndex = cfg->index;
+
+	/* For multifunction cards, by convention, we configure the
+	   network function with window 0, and serial with window 1 */
+	if (io->nwin > 1) {
+		i = (io->win[1].len > io->win[0].len);
+		p_dev->io.BasePort2 = io->win[1-i].base;
+		p_dev->io.NumPorts2 = io->win[1-i].len;
+	} else {
+		i = p_dev->io.NumPorts2 = 0;
+	}
+
+	*has_shmem = ((cfg->mem.nwin == 1) &&
+		      (cfg->mem.win[0].len >= 0x4000));
+	p_dev->io.BasePort1 = io->win[i].base;
+	p_dev->io.NumPorts1 = io->win[i].len;
+	p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
+	if (p_dev->io.NumPorts1 + p_dev->io.NumPorts2 >= 32)
+		return try_io_port(p_dev);
+
+	return 0;
+}
+
 static int pcnet_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     pcnet_dev_t *info = PRIV(dev);
-    tuple_t tuple;
-    cisparse_t parse;
-    int i, last_ret, last_fn, start_pg, stop_pg, cm_offset;
+    int last_ret, last_fn, start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
-    u_short buf[64];
     hw_info_t *local_hw_info;
     DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "pcnet_config(0x%p)\n", link);
 
-    tuple.TupleData = (cisdata_t *)buf;
-    tuple.TupleDataMax = sizeof(buf);
-    tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-    tuple.Attributes = 0;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-    while (last_ret == CS_SUCCESS) {
-	cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-	cistpl_io_t *io = &(parse.cftable_entry.io);
-
-	if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
-			pcmcia_parse_tuple(link, &tuple, &parse) != 0 ||
-			cfg->index == 0 || cfg->io.nwin == 0)
-		goto next_entry;
-
-	link->conf.ConfigIndex = cfg->index;
-	/* For multifunction cards, by convention, we configure the
-	   network function with window 0, and serial with window 1 */
-	if (io->nwin > 1) {
-	    i = (io->win[1].len > io->win[0].len);
-	    link->io.BasePort2 = io->win[1-i].base;
-	    link->io.NumPorts2 = io->win[1-i].len;
-	} else {
-	    i = link->io.NumPorts2 = 0;
-	}
-	has_shmem = ((cfg->mem.nwin == 1) &&
-		     (cfg->mem.win[0].len >= 0x4000));
-	link->io.BasePort1 = io->win[i].base;
-	link->io.NumPorts1 = io->win[i].len;
-	link->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-	if (link->io.NumPorts1 + link->io.NumPorts2 >= 32) {
-	    last_ret = try_io_port(link);
-	    if (last_ret == CS_SUCCESS) break;
-	}
-    next_entry:
-	last_ret = pcmcia_get_next_tuple(link, &tuple);
-    }
-    if (last_ret != CS_SUCCESS) {
+    last_ret = pcmcia_loop_config(link, pcnet_confcheck, &has_shmem);
+    if (last_ret) {
 	cs_error(link, RequestIO, last_ret);
 	goto failed;
     }
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 250eb19..c012e34 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -459,28 +459,36 @@ static int mhz_3288_power(struct pcmcia_device *link)
     return 0;
 }
 
+static int mhz_mfc_config_check(struct pcmcia_device *p_dev,
+				cistpl_cftable_entry_t *cf,
+				void *priv_data)
+{
+	int k;
+	p_dev->conf.ConfigIndex = cf->index;
+	p_dev->io.BasePort2 = cf->io.win[0].base;
+	for (k = 0; k < 0x400; k += 0x10) {
+		if (k & 0x80)
+			continue;
+		p_dev->io.BasePort1 = k ^ 0x300;
+		if (!pcmcia_request_io(p_dev, &p_dev->io))
+			return 0;
+	}
+	return -ENODEV;
+}
+
 static int mhz_mfc_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
     struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    cisparse_t *parse;
-    cistpl_cftable_entry_t *cf;
-    u_char *buf;
     win_req_t req;
     memreq_t mem;
-    int i, k;
+    int i;
 
     cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
     if (!cfg_mem)
         return CS_OUT_OF_RESOURCE;
 
-    tuple = &cfg_mem->tuple;
-    parse = &cfg_mem->parse;
-    cf = &parse->cftable_entry;
-    buf = cfg_mem->buf;
-
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
     link->irq.Attributes =
@@ -489,27 +497,9 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
 
-    tuple->Attributes = tuple->TupleOffset = 0;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 255;
-    tuple->DesiredTuple = CISTPL_CFTABLE_ENTRY;
-
-    i = first_tuple(link, tuple, parse);
     /* The Megahertz combo cards have modem-like CIS entries, so
        we have to explicitly try a bunch of port combinations. */
-    while (i == CS_SUCCESS) {
-	link->conf.ConfigIndex = cf->index;
-	link->io.BasePort2 = cf->io.win[0].base;
-	for (k = 0; k < 0x400; k += 0x10) {
-	    if (k & 0x80) continue;
-	    link->io.BasePort1 = k ^ 0x300;
-	    i = pcmcia_request_io(link, &link->io);
-	    if (i == CS_SUCCESS) break;
-	}
-	if (i == CS_SUCCESS) break;
-	i = next_tuple(link, tuple, parse);
-    }
-    if (i != CS_SUCCESS)
+    if (pcmcia_loop_config(link, mhz_mfc_config_check, NULL))
 	goto free_cfg_mem;
     dev->base_addr = link->io.BasePort1;
 
@@ -533,7 +523,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 
 free_cfg_mem:
     kfree(cfg_mem);
-    return i;
+    return -ENODEV;
 }
 
 static int mhz_setup(struct pcmcia_device *link)
@@ -660,46 +650,26 @@ static int mot_setup(struct pcmcia_device *link)
 
 /*====================================================================*/
 
+static int smc_configcheck(struct pcmcia_device *p_dev,
+			   cistpl_cftable_entry_t *cf,
+			   void *priv_data)
+{
+	p_dev->conf.ConfigIndex = cf->index;
+	p_dev->io.BasePort1 = cf->io.win[0].base;
+	p_dev->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
+	return pcmcia_request_io(p_dev, &p_dev->io);
+}
+
 static int smc_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    cisparse_t *parse;
-    cistpl_cftable_entry_t *cf;
-    u_char *buf;
     int i;
 
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-	return CS_OUT_OF_RESOURCE;
-
-    tuple = &cfg_mem->tuple;
-    parse = &cfg_mem->parse;
-    cf = &parse->cftable_entry;
-    buf = cfg_mem->buf;
-
-    tuple->Attributes = tuple->TupleOffset = 0;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 255;
-    tuple->DesiredTuple = CISTPL_CFTABLE_ENTRY;
-
     link->io.NumPorts1 = 16;
-    i = first_tuple(link, tuple, parse);
-    while (i != CS_NO_MORE_ITEMS) {
-	if (i == CS_SUCCESS) {
-	    link->conf.ConfigIndex = cf->index;
-	    link->io.BasePort1 = cf->io.win[0].base;
-	    link->io.IOAddrLines = cf->io.flags & CISTPL_IO_LINES_MASK;
-	    i = pcmcia_request_io(link, &link->io);
-	    if (i == CS_SUCCESS) break;
-	}
-	i = next_tuple(link, tuple, parse);
-    }
-    if (i == CS_SUCCESS)
-	dev->base_addr = link->io.BasePort1;
+    i = pcmcia_loop_config(link, smc_configcheck, NULL);
+    if (!i)
+	    dev->base_addr = link->io.BasePort1;
 
-    kfree(cfg_mem);
     return i;
 }
 
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index f6c4698..a3aeb65 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -715,6 +715,45 @@ has_ce2_string(struct pcmcia_device * p_dev)
 	return 0;
 }
 
+static int
+xirc2ps_config_modem(struct pcmcia_device *p_dev,
+		     cistpl_cftable_entry_t *cf,
+		     void *priv_data)
+{
+	unsigned int ioaddr;
+
+	if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8) {
+		for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
+			p_dev->conf.ConfigIndex = cf->index ;
+			p_dev->io.BasePort2 = cf->io.win[0].base;
+			p_dev->io.BasePort1 = ioaddr;
+			if (!pcmcia_request_io(p_dev, &p_dev->io))
+				return 0;
+		}
+	}
+	return -ENODEV;
+}
+
+static int
+xirc2ps_config_check(struct pcmcia_device *p_dev,
+		     cistpl_cftable_entry_t *cf,
+		     void *priv_data)
+{
+	int *pass = priv_data;
+
+	if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8){
+		p_dev->conf.ConfigIndex = cf->index ;
+		p_dev->io.BasePort2 = cf->io.win[0].base;
+		p_dev->io.BasePort1 = p_dev->io.BasePort2
+			+ (*pass ? (cf->index & 0x20 ? -24:8)
+			   : (cf->index & 0x20 ?   8:-24));
+		if (!pcmcia_request_io(p_dev, &p_dev->io))
+			return 0;
+	}
+	return -ENODEV;
+
+}
+
 /****************
  * xirc2ps_config() is scheduled to run after a CARD_INSERTION event
  * is received, to configure the PCMCIA socket, and to make the
@@ -725,13 +764,12 @@ xirc2ps_config(struct pcmcia_device * link)
 {
     struct net_device *dev = link->priv;
     local_info_t *local = netdev_priv(dev);
+    unsigned int ioaddr;
     tuple_t tuple;
     cisparse_t parse;
-    unsigned int ioaddr;
     int err, i;
     u_char buf[64];
     cistpl_lan_node_id_t *node_id = (cistpl_lan_node_id_t*)parse.funce.data;
-    cistpl_cftable_entry_t *cf = &parse.cftable_entry;
     DECLARE_MAC_BUF(mac);
 
     local->dingo_ccr = NULL;
@@ -846,19 +884,8 @@ xirc2ps_config(struct pcmcia_device * link)
 	    /* Take the Modem IO port from the CIS and scan for a free
 	     * Ethernet port */
 	    link->io.NumPorts1 = 16; /* no Mako stuff anymore */
-	    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	    for (err = first_tuple(link, &tuple, &parse); !err;
-				 err = next_tuple(link, &tuple, &parse)) {
-		if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8) {
-		    for (ioaddr = 0x300; ioaddr < 0x400; ioaddr += 0x10) {
-			link->conf.ConfigIndex = cf->index ;
-			link->io.BasePort2 = cf->io.win[0].base;
-			link->io.BasePort1 = ioaddr;
-			if (!(err=pcmcia_request_io(link, &link->io)))
-			    goto port_found;
-		    }
-		}
-	    }
+	    if (!pcmcia_loop_config(link, xirc2ps_config_modem, NULL))
+		    goto port_found;
 	} else {
 	    link->io.NumPorts1 = 18;
 	    /* We do 2 passes here: The first one uses the regular mapping and
@@ -866,21 +893,9 @@ xirc2ps_config(struct pcmcia_device * link)
 	     * mirrored every 32 bytes. Actually we use a mirrored port for
 	     * the Mako if (on the first pass) the COR bit 5 is set.
 	     */
-	    for (pass=0; pass < 2; pass++) {
-		tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-		for (err = first_tuple(link, &tuple, &parse); !err;
-				     err = next_tuple(link, &tuple, &parse)){
-		    if (cf->io.nwin > 0  &&  (cf->io.win[0].base & 0xf) == 8){
-			link->conf.ConfigIndex = cf->index ;
-			link->io.BasePort2 = cf->io.win[0].base;
-			link->io.BasePort1 = link->io.BasePort2
-				    + (pass ? (cf->index & 0x20 ? -24:8)
-					    : (cf->index & 0x20 ?   8:-24));
-			if (!(err=pcmcia_request_io(link, &link->io)))
+	    for (pass=0; pass < 2; pass++)
+		    if (!pcmcia_loop_config(link, xirc2ps_config_check, &pass))
 			    goto port_found;
-		    }
-		}
-	    }
 	    /* if special option:
 	     * try to configure as Ethernet only.
 	     * .... */
diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index f123553..4fbe811 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -206,126 +206,131 @@ static void airo_detach(struct pcmcia_device *link)
 #define CS_CHECK(fn, ret) \
 do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 
+struct airo_cs_config_data {
+	cistpl_cftable_entry_t dflt;
+	win_req_t req;
+};
+
+static int airo_cs_config_check(struct pcmcia_device *p_dev,
+				cistpl_cftable_entry_t *cfg,
+				void *priv_data)
+{
+	struct airo_cs_config_data *cfg_mem = priv_data;
+
+	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
+		cfg_mem->dflt = *cfg;
+
+	if (cfg->index == 0)
+		return -ENODEV;
+
+	p_dev->conf.ConfigIndex = cfg->index;
+
+	/* Does this card need audio output? */
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->conf.Status = CCSR_AUDIO_ENA;
+	}
+
+	/* Use power settings for Vcc and Vpp if present */
+	/*  Note that the CIS values need to be rescaled */
+	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
+	else if (cfg_mem->dflt.vpp1.present & (1<<CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = cfg_mem->dflt.vpp1.param[CISTPL_POWER_VNOM]/10000;
+
+	/* Do we need to allocate an interrupt? */
+	if (cfg->irq.IRQInfo1 || cfg_mem->dflt.irq.IRQInfo1)
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+
+	/* IO window settings */
+	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	if ((cfg->io.nwin > 0) || (cfg_mem->dflt.io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &cfg_mem->dflt.io;
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		if (!(io->flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(io->flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.BasePort1 = io->win[0].base;
+		p_dev->io.NumPorts1 = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->io.Attributes2 = p_dev->io.Attributes1;
+			p_dev->io.BasePort2 = io->win[1].base;
+			p_dev->io.NumPorts2 = io->win[1].len;
+		}
+	}
+
+	/* This reserves IO space but doesn't actually enable it */
+	if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+		return -ENODEV;
+
+	/*
+	  Now set up a common memory window, if needed.  There is room
+	  in the struct pcmcia_device structure for one memory window handle,
+	  but if the base addresses need to be saved, or if multiple
+	  windows are needed, the info should go in the private data
+	  structure for this device.
+
+	  Note that the memory window base is a physical address, and
+	  needs to be mapped to virtual space with ioremap() before it
+	  is used.
+	*/
+	if ((cfg->mem.nwin > 0) || (cfg_mem->dflt.mem.nwin > 0)) {
+		cistpl_mem_t *mem = (cfg->mem.nwin) ? &cfg->mem : &cfg_mem->dflt.mem;
+		memreq_t map;
+		cfg_mem->req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
+		cfg_mem->req.Base = mem->win[0].host_addr;
+		cfg_mem->req.Size = mem->win[0].len;
+		cfg_mem->req.AccessSpeed = 0;
+		if (pcmcia_request_window(&p_dev, &cfg_mem->req, &p_dev->win) != 0)
+			return -ENODEV;
+		map.Page = 0;
+		map.CardOffset = mem->win[0].card_addr;
+		if (pcmcia_map_mem_page(p_dev->win, &map) != 0)
+			return -ENODEV;
+	}
+	/* If we got this far, we're cool! */
+	return 0;
+}
+
+
 static int airo_config(struct pcmcia_device *link)
 {
-	tuple_t tuple;
-	cisparse_t parse;
 	local_info_t *dev;
+	struct airo_cs_config_data *cfg_mem;
 	int last_fn, last_ret;
-	u_char buf[64];
-	win_req_t req;
-	memreq_t map;
 
 	dev = link->priv;
 
 	DEBUG(0, "airo_config(0x%p)\n", link);
 
+	cfg_mem = kzalloc(sizeof(struct airo_cs_config_data), GFP_KERNEL);
+	if (!cfg_mem)
+		return -ENOMEM;
+
 	/*
-	  In this loop, we scan the CIS for configuration table entries,
-	  each of which describes a valid card configuration, including
-	  voltage, IO window, memory window, and interrupt settings.
-	  
-	  We make no assumptions about the card to be configured: we use
-	  just the information available in the CIS.  In an ideal world,
-	  this would work for any PCMCIA card, but it requires a complete
-	  and accurate CIS.  In practice, a driver usually "knows" most of
-	  these things without consulting the CIS, and most client drivers
-	  will only use the CIS to fill in implementation-defined details.
+	 * In this loop, we scan the CIS for configuration table
+	 * entries, each of which describes a valid card
+	 * configuration, including voltage, IO window, memory window,
+	 * and interrupt settings.
+	 *
+	 * We make no assumptions about the card to be configured: we
+	 * use just the information available in the CIS.  In an ideal
+	 * world, this would work for any PCMCIA card, but it requires
+	 * a complete and accurate CIS.  In practice, a driver usually
+	 * "knows" most of these things without consulting the CIS,
+	 * and most client drivers will only use the CIS to fill in
+	 * implementation-defined details.
+	 */
+	last_ret = pcmcia_loop_config(link, airo_cs_config_check, cfg_mem);
+	if (last_ret)
+		goto failed;
+
+	/*
+	  Allocate an interrupt line.  Note that this does not assign a
+	  handler to the interrupt, unless the 'Handler' member of the
+	  irq structure is initialized.
 	*/
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	while (1) {
-		cistpl_cftable_entry_t dflt = { 0 };
-		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-		if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
-				pcmcia_parse_tuple(link, &tuple, &parse) != 0)
-			goto next_entry;
-		
-		if (cfg->flags & CISTPL_CFTABLE_DEFAULT) dflt = *cfg;
-		if (cfg->index == 0) goto next_entry;
-		link->conf.ConfigIndex = cfg->index;
-		
-		/* Does this card need audio output? */
-		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
-			link->conf.Attributes |= CONF_ENABLE_SPKR;
-			link->conf.Status = CCSR_AUDIO_ENA;
-		}
-		
-		/* Use power settings for Vcc and Vpp if present */
-		/*  Note that the CIS values need to be rescaled */
-		if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-		else if (dflt.vpp1.present & (1<<CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				dflt.vpp1.param[CISTPL_POWER_VNOM]/10000;
-		
-		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
-		
-		/* IO window settings */
-		link->io.NumPorts1 = link->io.NumPorts2 = 0;
-		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-			cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt.io;
-			link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			if (!(io->flags & CISTPL_IO_8BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-			link->io.BasePort1 = io->win[0].base;
-			link->io.NumPorts1 = io->win[0].len;
-			if (io->nwin > 1) {
-				link->io.Attributes2 = link->io.Attributes1;
-				link->io.BasePort2 = io->win[1].base;
-				link->io.NumPorts2 = io->win[1].len;
-			}
-		}
-		
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(link, &link->io) != 0)
-			goto next_entry;
-		
-		/*
-		  Now set up a common memory window, if needed.  There is room
-		  in the struct pcmcia_device structure for one memory window handle,
-		  but if the base addresses need to be saved, or if multiple
-		  windows are needed, the info should go in the private data
-		  structure for this device.
-		  
-		  Note that the memory window base is a physical address, and
-		  needs to be mapped to virtual space with ioremap() before it
-		  is used.
-		*/
-		if ((cfg->mem.nwin > 0) || (dflt.mem.nwin > 0)) {
-			cistpl_mem_t *mem =
-				(cfg->mem.nwin) ? &cfg->mem : &dflt.mem;
-			req.Attributes = WIN_DATA_WIDTH_16|WIN_MEMORY_TYPE_CM;
-			req.Base = mem->win[0].host_addr;
-			req.Size = mem->win[0].len;
-			req.AccessSpeed = 0;
-			if (pcmcia_request_window(&link, &req, &link->win) != 0)
-				goto next_entry;
-			map.Page = 0; map.CardOffset = mem->win[0].card_addr;
-			if (pcmcia_map_mem_page(link->win, &map) != 0)
-				goto next_entry;
-		}
-		/* If we got this far, we're cool! */
-		break;
-		
-	next_entry:
-		CS_CHECK(GetNextTuple, pcmcia_get_next_tuple(link, &tuple));
-	}
-	
-    /*
-      Allocate an interrupt line.  Note that this does not assign a
-      handler to the interrupt, unless the 'Handler' member of the
-      irq structure is initialized.
-    */
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
 	
@@ -362,14 +367,17 @@ static int airo_config(struct pcmcia_device *link)
 		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
 		       link->io.BasePort2+link->io.NumPorts2-1);
 	if (link->win)
-		printk(", mem 0x%06lx-0x%06lx", req.Base,
-		       req.Base+req.Size-1);
+		printk(", mem 0x%06lx-0x%06lx", cfg_mem->req.Base,
+		       cfg_mem->req.Base+cfg_mem->req.Size-1);
 	printk("\n");
+	kfree(cfg_mem);
 	return 0;
 
  cs_failed:
 	cs_error(link, last_fn, last_ret);
+ failed:
 	airo_release(link);
+	kfree(cfg_mem);
 	return -ENODEV;
 } /* airo_config */
 
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index 12617cd..841323f 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -224,25 +224,69 @@ static int card_present(void *arg)
 	return 0;
 }
 
+static int atmel_config_check(struct pcmcia_device *p_dev,
+			      cistpl_cftable_entry_t *cfg,
+			      void *priv_data)
+{
+	cistpl_cftable_entry_t *dflt = priv_data;
+
+	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
+		*dflt = *cfg;
+	if (cfg->index == 0)
+		return -ENODEV;
+	p_dev->conf.ConfigIndex = cfg->index;
+
+	/* Does this card need audio output? */
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->conf.Status = CCSR_AUDIO_ENA;
+	}
+
+	/* Use power settings for Vcc and Vpp if present */
+	/*  Note that the CIS values need to be rescaled */
+	if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
+	else if (dflt->vpp1.present & (1<<CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = dflt->vpp1.param[CISTPL_POWER_VNOM]/10000;
+
+	/* Do we need to allocate an interrupt? */
+	if (cfg->irq.IRQInfo1 || dflt->irq.IRQInfo1)
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+
+	/* IO window settings */
+	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	if ((cfg->io.nwin > 0) || (dflt->io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt->io;
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		if (!(io->flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(io->flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.BasePort1 = io->win[0].base;
+		p_dev->io.NumPorts1 = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->io.Attributes2 = p_dev->io.Attributes1;
+			p_dev->io.BasePort2 = io->win[1].base;
+			p_dev->io.NumPorts2 = io->win[1].len;
+		}
+	}
+
+	/* This reserves IO space but doesn't actually enable it */
+	return (pcmcia_request_io(p_dev, &p_dev->io));
+}
+
 static int atmel_config(struct pcmcia_device *link)
 {
-	tuple_t tuple;
-	cisparse_t parse;
 	local_info_t *dev;
 	int last_fn, last_ret;
-	u_char buf[64];
 	struct pcmcia_device_id *did;
+	cistpl_cftable_entry_t dflt = { 0 };
 
 	dev = link->priv;
 	did = handle_to_dev(link).driver_data;
 
 	DEBUG(0, "atmel_config(0x%p)\n", link);
 
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-
 	/*
 	  In this loop, we scan the CIS for configuration table entries,
 	  each of which describes a valid card configuration, including
@@ -255,66 +299,8 @@ static int atmel_config(struct pcmcia_device *link)
 	  these things without consulting the CIS, and most client drivers
 	  will only use the CIS to fill in implementation-defined details.
 	*/
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	while (1) {
-		cistpl_cftable_entry_t dflt = { 0 };
-		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-		if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
-				pcmcia_parse_tuple(link, &tuple, &parse) != 0)
-			goto next_entry;
-
-		if (cfg->flags & CISTPL_CFTABLE_DEFAULT) dflt = *cfg;
-		if (cfg->index == 0) goto next_entry;
-		link->conf.ConfigIndex = cfg->index;
-
-		/* Does this card need audio output? */
-		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
-			link->conf.Attributes |= CONF_ENABLE_SPKR;
-			link->conf.Status = CCSR_AUDIO_ENA;
-		}
-
-		/* Use power settings for Vcc and Vpp if present */
-		/*  Note that the CIS values need to be rescaled */
-		if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				cfg->vpp1.param[CISTPL_POWER_VNOM]/10000;
-		else if (dflt.vpp1.present & (1<<CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				dflt.vpp1.param[CISTPL_POWER_VNOM]/10000;
-
-		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
-
-		/* IO window settings */
-		link->io.NumPorts1 = link->io.NumPorts2 = 0;
-		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-			cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt.io;
-			link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			if (!(io->flags & CISTPL_IO_8BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-			link->io.BasePort1 = io->win[0].base;
-			link->io.NumPorts1 = io->win[0].len;
-			if (io->nwin > 1) {
-				link->io.Attributes2 = link->io.Attributes1;
-				link->io.BasePort2 = io->win[1].base;
-				link->io.NumPorts2 = io->win[1].len;
-			}
-		}
-
-		/* This reserves IO space but doesn't actually enable it */
-		if (pcmcia_request_io(link, &link->io) != 0)
-			goto next_entry;
-
-		/* If we got this far, we're cool! */
-		break;
-
-	next_entry:
-		CS_CHECK(GetNextTuple, pcmcia_get_next_tuple(link, &tuple));
-	}
+	if (pcmcia_loop_config(link, atmel_config_check, &dflt))
+		goto failed;
 
 	/*
 	  Allocate an interrupt line.  Note that this does not assign a
@@ -360,6 +346,7 @@ static int atmel_config(struct pcmcia_device *link)
 
  cs_failed:
 	cs_error(link, last_fn, last_ret);
+ failed:
 	atmel_release(link);
 	return -ENODEV;
 }
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 3b4e55c..5285259 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -532,145 +532,134 @@ static void prism2_detach(struct pcmcia_device *link)
 #define CS_CHECK(fn, ret) \
 do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 
-#define CFG_CHECK2(fn, retf) \
-do { int _ret = (retf); \
-if (_ret != 0) { \
-	PDEBUG(DEBUG_EXTRA, "CardServices(" #fn ") returned %d\n", _ret); \
-	cs_error(link, fn, _ret); \
-	goto next_entry; \
-} \
-} while (0)
-
 
 /* run after a CARD_INSERTION event is received to configure the PCMCIA
  * socket and make the device available to the system */
+
+struct prism2_config_data {
+	cistpl_cftable_entry_t dflt;
+	config_info_t conf;
+};
+
+static int prism2_config_check(struct pcmcia_device *p_dev,
+			       cistpl_cftable_entry_t *cfg,
+			       void *priv_data)
+{
+	struct prism2_config_data *cfg_mem = priv_data;
+
+	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
+		cfg_mem->dflt = *cfg;
+	if (cfg->index == 0)
+		return -ENODEV;
+
+	p_dev->conf.ConfigIndex = cfg->index;
+	PDEBUG(DEBUG_EXTRA, "Checking CFTABLE_ENTRY 0x%02X "
+	       "(default 0x%02X)\n", cfg->index, cfg_mem->dflt.index);
+
+	/* Does this card need audio output? */
+	if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
+		p_dev->conf.Attributes |= CONF_ENABLE_SPKR;
+		p_dev->conf.Status = CCSR_AUDIO_ENA;
+	}
+
+	/* Use power settings for Vcc and Vpp if present */
+	/*  Note that the CIS values need to be rescaled */
+	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] /
+		    10000 && !ignore_cis_vcc) {
+			PDEBUG(DEBUG_EXTRA, "  Vcc mismatch - skipping"
+			       " this entry\n");
+			return -ENODEV;
+		}
+	} else if (cfg_mem->dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg_mem->dflt.vcc.param[CISTPL_POWER_VNOM] /
+		    10000 && !ignore_cis_vcc) {
+			PDEBUG(DEBUG_EXTRA, "  Vcc (default) mismatch "
+			       "- skipping this entry\n");
+			return -ENODEV;
+		}
+	}
+
+	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+	else if (cfg_mem->dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp = cfg_mem->dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
+
+	/* Do we need to allocate an interrupt? */
+	if (cfg->irq.IRQInfo1 || cfg_mem->dflt.irq.IRQInfo1)
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	else if (!(p_dev->conf.Attributes & CONF_ENABLE_IRQ)) {
+		/* At least Compaq WL200 does not have IRQInfo1 set,
+		 * but it does not work without interrupts.. */
+		printk("Config has no IRQ info, but trying to enable "
+		       "IRQ anyway..\n");
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+	}
+
+	/* IO window settings */
+	PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
+	       "cfg_mem->dflt.io.nwin=%d\n",
+	       cfg->io.nwin, cfg_mem->dflt.io.nwin);
+	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	if ((cfg->io.nwin > 0) || (cfg_mem->dflt.io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &cfg_mem->dflt.io;
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		PDEBUG(DEBUG_EXTRA, "io->flags = 0x%04X, "
+		       "io.base=0x%04x, len=%d\n", io->flags,
+		       io->win[0].base, io->win[0].len);
+		if (!(io->flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(io->flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.IOAddrLines = io->flags &
+			CISTPL_IO_LINES_MASK;
+		p_dev->io.BasePort1 = io->win[0].base;
+		p_dev->io.NumPorts1 = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->io.Attributes2 = p_dev->io.Attributes1;
+			p_dev->io.BasePort2 = io->win[1].base;
+			p_dev->io.NumPorts2 = io->win[1].len;
+		}
+	}
+
+	/* This reserves IO space but doesn't actually enable it */
+	return (pcmcia_request_io(p_dev, &p_dev->io));
+}
+
 static int prism2_config(struct pcmcia_device *link)
 {
 	struct net_device *dev;
 	struct hostap_interface *iface;
+	struct prism2_config_data *cfg_mem;
 	local_info_t *local;
 	int ret = 1;
-	tuple_t tuple;
-	cisparse_t *parse;
 	int last_fn, last_ret;
-	u_char buf[64];
-	config_info_t conf;
-	cistpl_cftable_entry_t dflt = { 0 };
 	struct hostap_cs_priv *hw_priv;
 
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
 
-	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
+	cfg_mem = kzalloc(sizeof(struct prism2_config_data), GFP_KERNEL);
+	if (!cfg_mem)
+		return -ENOMEM;
+
 	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
-	if (parse == NULL || hw_priv == NULL) {
+	if (hw_priv == NULL) {
 		ret = -ENOMEM;
 		goto failed;
 	}
 
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-
 	CS_CHECK(GetConfigurationInfo,
-		 pcmcia_get_configuration_info(link, &conf));
+		 pcmcia_get_configuration_info(link, &cfg_mem->conf));
 
 	/* Look for an appropriate configuration table entry in the CIS */
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	for (;;) {
-		cistpl_cftable_entry_t *cfg = &(parse->cftable_entry);
-		CFG_CHECK2(GetTupleData,
-			   pcmcia_get_tuple_data(link, &tuple));
-		CFG_CHECK2(ParseTuple,
-			   pcmcia_parse_tuple(link, &tuple, parse));
-
-		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
-			dflt = *cfg;
-		if (cfg->index == 0)
-			goto next_entry;
-		link->conf.ConfigIndex = cfg->index;
-		PDEBUG(DEBUG_EXTRA, "Checking CFTABLE_ENTRY 0x%02X "
-		       "(default 0x%02X)\n", cfg->index, dflt.index);
-
-		/* Does this card need audio output? */
-		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
-			link->conf.Attributes |= CONF_ENABLE_SPKR;
-			link->conf.Status = CCSR_AUDIO_ENA;
-		}
-
-		/* Use power settings for Vcc and Vpp if present */
-		/*  Note that the CIS values need to be rescaled */
-		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] /
-			    10000 && !ignore_cis_vcc) {
-				PDEBUG(DEBUG_EXTRA, "  Vcc mismatch - skipping"
-				       " this entry\n");
-				goto next_entry;
-			}
-		} else if (dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != dflt.vcc.param[CISTPL_POWER_VNOM] /
-			    10000 && !ignore_cis_vcc) {
-				PDEBUG(DEBUG_EXTRA, "  Vcc (default) mismatch "
-				       "- skipping this entry\n");
-				goto next_entry;
-			}
-		}
-
-		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		else if (dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-				dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
-
-		/* Do we need to allocate an interrupt? */
-		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
-		else if (!(link->conf.Attributes & CONF_ENABLE_IRQ)) {
-			/* At least Compaq WL200 does not have IRQInfo1 set,
-			 * but it does not work without interrupts.. */
-			printk("Config has no IRQ info, but trying to enable "
-			       "IRQ anyway..\n");
-			link->conf.Attributes |= CONF_ENABLE_IRQ;
-		}
-
-		/* IO window settings */
-		PDEBUG(DEBUG_EXTRA, "IO window settings: cfg->io.nwin=%d "
-		       "dflt.io.nwin=%d\n",
-		       cfg->io.nwin, dflt.io.nwin);
-		link->io.NumPorts1 = link->io.NumPorts2 = 0;
-		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-			cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt.io;
-			link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			PDEBUG(DEBUG_EXTRA, "io->flags = 0x%04X, "
-			       "io.base=0x%04x, len=%d\n", io->flags,
-			       io->win[0].base, io->win[0].len);
-			if (!(io->flags & CISTPL_IO_8BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-			link->io.IOAddrLines = io->flags &
-				CISTPL_IO_LINES_MASK;
-			link->io.BasePort1 = io->win[0].base;
-			link->io.NumPorts1 = io->win[0].len;
-			if (io->nwin > 1) {
-				link->io.Attributes2 = link->io.Attributes1;
-				link->io.BasePort2 = io->win[1].base;
-				link->io.NumPorts2 = io->win[1].len;
-			}
-		}
-
-		/* This reserves IO space but doesn't actually enable it */
-		CFG_CHECK2(RequestIO,
-			   pcmcia_request_io(link, &link->io));
-
-		/* This configuration table entry is OK */
-		break;
-
-	next_entry:
-		CS_CHECK(GetNextTuple,
-			 pcmcia_get_next_tuple(link, &tuple));
+	last_ret = pcmcia_loop_config(link, prism2_config_check, cfg_mem);
+	if (last_ret) {
+		if (!ignore_cis_vcc)
+			printk(KERN_ERR "GetNextTuple(): No matching "
+			       "CIS configuration.  Maybe you need the "
+			       "ignore_cis_vcc=1 parameter.\n");
+		cs_error(link, RequestIO, last_ret);
+		goto failed;
 	}
 
 	/* Need to allocate net_device before requesting IRQ handler */
@@ -738,15 +727,15 @@ static int prism2_config(struct pcmcia_device *link)
 		if (ret == 0 && local->ddev)
 			strcpy(hw_priv->node.dev_name, local->ddev->name);
 	}
-	kfree(parse);
+	kfree(cfg_mem);
 	return ret;
 
  cs_failed:
 	cs_error(link, last_fn, last_ret);
 
  failed:
-	kfree(parse);
 	kfree(hw_priv);
+	kfree(cfg_mem);
 	prism2_release((u_long)link);
 	return ret;
 }
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index 1c216e0..473370c 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -164,23 +164,96 @@ static void orinoco_cs_detach(struct pcmcia_device *link)
 		last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; \
 	} while (0)
 
+struct orinoco_cs_config_data {
+	cistpl_cftable_entry_t dflt;
+	config_info_t conf;
+};
+
+static int orinoco_cs_config_check(struct pcmcia_device *p_dev,
+				   cistpl_cftable_entry_t *cfg,
+				   void *priv_data)
+{
+	struct orinoco_cs_config_data *cfg_mem = priv_data;
+
+	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
+		cfg_mem->dflt = *cfg;
+	if (cfg->index == 0)
+		goto next_entry;
+	p_dev->conf.ConfigIndex = cfg->index;
+
+	/* Use power settings for Vcc and Vpp if present */
+	/* Note that the CIS values need to be rescaled */
+	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
+			DEBUG(2, "spectrum_cs_config: Vcc mismatch (cfg_mem->conf.Vcc = %d, CIS = %d)\n",  cfg_mem->conf.Vcc, cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
+			if (!ignore_cis_vcc)
+				goto next_entry;
+		}
+	} else if (cfg_mem->dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg_mem->dflt.vcc.param[CISTPL_POWER_VNOM] / 10000) {
+			DEBUG(2, "spectrum_cs_config: Vcc mismatch (cfg_mem->conf.Vcc = %d, CIS = %d)\n",  cfg_mem->conf.Vcc, cfg_mem->dflt.vcc.param[CISTPL_POWER_VNOM] / 10000);
+			if (!ignore_cis_vcc)
+				goto next_entry;
+		}
+	}
+
+	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp =
+			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+	else if (cfg_mem->dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp =
+			cfg_mem->dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
+
+	/* Do we need to allocate an interrupt? */
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+
+	/* IO window settings */
+	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	if ((cfg->io.nwin > 0) || (cfg_mem->dflt.io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &cfg_mem->dflt.io;
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		if (!(io->flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(io->flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->io.BasePort1 = io->win[0].base;
+		p_dev->io.NumPorts1 = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->io.Attributes2 = p_dev->io.Attributes1;
+			p_dev->io.BasePort2 = io->win[1].base;
+			p_dev->io.NumPorts2 = io->win[1].len;
+		}
+
+		/* This reserves IO space but doesn't actually enable it */
+		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+			goto next_entry;
+	}
+	return 0;
+
+next_entry:
+	pcmcia_disable_device(p_dev);
+	return -ENODEV;
+};
+
 static int
 orinoco_cs_config(struct pcmcia_device *link)
 {
+	struct orinoco_cs_config_data *cfg_mem;
 	struct net_device *dev = link->priv;
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pccard *card = priv->card;
 	hermes_t *hw = &priv->hw;
 	int last_fn, last_ret;
-	u_char buf[64];
-	config_info_t conf;
-	tuple_t tuple;
-	cisparse_t parse;
 	void __iomem *mem;
 
+	cfg_mem = kzalloc(sizeof(struct orinoco_cs_config_data), GFP_KERNEL);
+	if (!cfg_mem)
+		return -ENOMEM;
+
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo,
-		 pcmcia_get_configuration_info(link, &conf));
+		 pcmcia_get_configuration_info(link, &cfg_mem->conf));
 
 	/*
 	 * In this loop, we scan the CIS for configuration table
@@ -196,94 +269,14 @@ orinoco_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	while (1) {
-		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-		cistpl_cftable_entry_t dflt = { .index = 0 };
-
-		if ( (pcmcia_get_tuple_data(link, &tuple) != 0)
-		    || (pcmcia_parse_tuple(link, &tuple, &parse) != 0))
-			goto next_entry;
-
-		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
-			dflt = *cfg;
-		if (cfg->index == 0)
-			goto next_entry;
-		link->conf.ConfigIndex = cfg->index;
-
-		/* Use power settings for Vcc and Vpp if present */
-		/* Note that the CIS values need to be rescaled */
-		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-				DEBUG(2, "orinoco_cs_config: Vcc mismatch (conf.Vcc = %d, cfg CIS = %d)\n",  conf.Vcc, cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
-				if (!ignore_cis_vcc)
-					goto next_entry;
-			}
-		} else if (dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != dflt.vcc.param[CISTPL_POWER_VNOM] / 10000) {
-				DEBUG(2, "orinoco_cs_config: Vcc mismatch (conf.Vcc = %d, dflt CIS = %d)\n",  conf.Vcc, dflt.vcc.param[CISTPL_POWER_VNOM] / 10000);
-				if(!ignore_cis_vcc)
-					goto next_entry;
-			}
-		}
-
-		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-			    cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		else if (dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-			    dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		
-		/* Do we need to allocate an interrupt? */
-		link->conf.Attributes |= CONF_ENABLE_IRQ;
-
-		/* IO window settings */
-		link->io.NumPorts1 = link->io.NumPorts2 = 0;
-		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-			cistpl_io_t *io =
-			    (cfg->io.nwin) ? &cfg->io : &dflt.io;
-			link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			if (!(io->flags & CISTPL_IO_8BIT))
-				link->io.Attributes1 =
-				    IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				link->io.Attributes1 =
-				    IO_DATA_PATH_WIDTH_8;
-			link->io.IOAddrLines =
-			    io->flags & CISTPL_IO_LINES_MASK;
-			link->io.BasePort1 = io->win[0].base;
-			link->io.NumPorts1 = io->win[0].len;
-			if (io->nwin > 1) {
-				link->io.Attributes2 =
-				    link->io.Attributes1;
-				link->io.BasePort2 = io->win[1].base;
-				link->io.NumPorts2 = io->win[1].len;
-			}
-
-			/* This reserves IO space but doesn't actually enable it */
-			if (pcmcia_request_io(link, &link->io) != 0)
-				goto next_entry;
-		}
-
-
-		/* If we got this far, we're cool! */
-
-		break;
-		
-	next_entry:
-		pcmcia_disable_device(link);
-		last_ret = pcmcia_get_next_tuple(link, &tuple);
-		if (last_ret  == CS_NO_MORE_ITEMS) {
+	last_ret = pcmcia_loop_config(link, orinoco_cs_config_check, cfg_mem);
+	if (last_ret) {
+		if (!ignore_cis_vcc)
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
-			goto cs_failed;
-		}
+		cs_error(link, RequestIO, last_ret);
+		goto failed;
 	}
 
 	/*
@@ -334,7 +327,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 	       "0x%04x-0x%04x\n", dev->name, dev->dev.parent->bus_id,
 	       link->irq.AssignedIRQ, link->io.BasePort1,
 	       link->io.BasePort1 + link->io.NumPorts1 - 1);
-
+	kfree(cfg_mem);
 	return 0;
 
  cs_failed:
@@ -342,6 +335,7 @@ orinoco_cs_config(struct pcmcia_device *link)
 
  failed:
 	orinoco_cs_release(link);
+	kfree(cfg_mem);
 	return -ENODEV;
 }				/* orinoco_cs_config */
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index 98df9bc..8e1951c 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -633,23 +633,96 @@ static void spectrum_cs_detach(struct pcmcia_device *link)
  * device available to the system.
  */
 
+struct spectrum_cs_config_data {
+	cistpl_cftable_entry_t dflt;
+	config_info_t conf;
+};
+
+static int spectrum_cs_config_check(struct pcmcia_device *p_dev,
+				    cistpl_cftable_entry_t *cfg,
+				    void *priv_data)
+{
+	struct spectrum_cs_config_data *cfg_mem = priv_data;
+
+	if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
+		cfg_mem->dflt = *cfg;
+	if (cfg->index == 0)
+		goto next_entry;
+	p_dev->conf.ConfigIndex = cfg->index;
+
+	/* Use power settings for Vcc and Vpp if present */
+	/* Note that the CIS values need to be rescaled */
+	if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
+			DEBUG(2, "spectrum_cs_config: Vcc mismatch (cfg_mem->conf.Vcc = %d, CIS = %d)\n",  cfg_mem->conf.Vcc, cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
+			if (!ignore_cis_vcc)
+				goto next_entry;
+		}
+	} else if (cfg_mem->dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
+		if (cfg_mem->conf.Vcc != cfg_mem->dflt.vcc.param[CISTPL_POWER_VNOM] / 10000) {
+			DEBUG(2, "spectrum_cs_config: Vcc mismatch (cfg_mem->conf.Vcc = %d, CIS = %d)\n",  cfg_mem->conf.Vcc, cfg_mem->dflt.vcc.param[CISTPL_POWER_VNOM] / 10000);
+			if (!ignore_cis_vcc)
+				goto next_entry;
+		}
+	}
+
+	if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp =
+			cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
+	else if (cfg_mem->dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
+		p_dev->conf.Vpp =
+			cfg_mem->dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
+
+	/* Do we need to allocate an interrupt? */
+	p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+
+	/* IO window settings */
+	p_dev->io.NumPorts1 = p_dev->io.NumPorts2 = 0;
+	if ((cfg->io.nwin > 0) || (cfg_mem->dflt.io.nwin > 0)) {
+		cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &cfg_mem->dflt.io;
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		if (!(io->flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(io->flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
+		p_dev->io.BasePort1 = io->win[0].base;
+		p_dev->io.NumPorts1 = io->win[0].len;
+		if (io->nwin > 1) {
+			p_dev->io.Attributes2 = p_dev->io.Attributes1;
+			p_dev->io.BasePort2 = io->win[1].base;
+			p_dev->io.NumPorts2 = io->win[1].len;
+		}
+
+		/* This reserves IO space but doesn't actually enable it */
+		if (pcmcia_request_io(p_dev, &p_dev->io) != 0)
+			goto next_entry;
+	}
+	return 0;
+
+next_entry:
+	pcmcia_disable_device(p_dev);
+	return -ENODEV;
+};
+
 static int
 spectrum_cs_config(struct pcmcia_device *link)
 {
+	struct spectrum_cs_config_data *cfg_mem;
 	struct net_device *dev = link->priv;
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pccard *card = priv->card;
 	hermes_t *hw = &priv->hw;
 	int last_fn, last_ret;
-	u_char buf[64];
-	config_info_t conf;
-	tuple_t tuple;
-	cisparse_t parse;
 	void __iomem *mem;
 
+	cfg_mem = kzalloc(sizeof(struct spectrum_cs_config_data), GFP_KERNEL);
+	if (!cfg_mem)
+		return -ENOMEM;
+
 	/* Look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo,
-		 pcmcia_get_configuration_info(link, &conf));
+		 pcmcia_get_configuration_info(link, &cfg_mem->conf));
 
 	/*
 	 * In this loop, we scan the CIS for configuration table
@@ -665,94 +738,14 @@ spectrum_cs_config(struct pcmcia_device *link)
 	 * and most client drivers will only use the CIS to fill in
 	 * implementation-defined details.
 	 */
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	while (1) {
-		cistpl_cftable_entry_t *cfg = &(parse.cftable_entry);
-		cistpl_cftable_entry_t dflt = { .index = 0 };
-
-		if ( (pcmcia_get_tuple_data(link, &tuple) != 0)
-		    || (pcmcia_parse_tuple(link, &tuple, &parse) != 0))
-			goto next_entry;
-
-		if (cfg->flags & CISTPL_CFTABLE_DEFAULT)
-			dflt = *cfg;
-		if (cfg->index == 0)
-			goto next_entry;
-		link->conf.ConfigIndex = cfg->index;
-
-		/* Use power settings for Vcc and Vpp if present */
-		/* Note that the CIS values need to be rescaled */
-		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != cfg->vcc.param[CISTPL_POWER_VNOM] / 10000) {
-				DEBUG(2, "spectrum_cs_config: Vcc mismatch (conf.Vcc = %d, CIS = %d)\n",  conf.Vcc, cfg->vcc.param[CISTPL_POWER_VNOM] / 10000);
-				if (!ignore_cis_vcc)
-					goto next_entry;
-			}
-		} else if (dflt.vcc.present & (1 << CISTPL_POWER_VNOM)) {
-			if (conf.Vcc != dflt.vcc.param[CISTPL_POWER_VNOM] / 10000) {
-				DEBUG(2, "spectrum_cs_config: Vcc mismatch (conf.Vcc = %d, CIS = %d)\n",  conf.Vcc, dflt.vcc.param[CISTPL_POWER_VNOM] / 10000);
-				if(!ignore_cis_vcc)
-					goto next_entry;
-			}
-		}
-
-		if (cfg->vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-			    cfg->vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		else if (dflt.vpp1.present & (1 << CISTPL_POWER_VNOM))
-			link->conf.Vpp =
-			    dflt.vpp1.param[CISTPL_POWER_VNOM] / 10000;
-		
-		/* Do we need to allocate an interrupt? */
-		link->conf.Attributes |= CONF_ENABLE_IRQ;
-
-		/* IO window settings */
-		link->io.NumPorts1 = link->io.NumPorts2 = 0;
-		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-			cistpl_io_t *io =
-			    (cfg->io.nwin) ? &cfg->io : &dflt.io;
-			link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-			if (!(io->flags & CISTPL_IO_8BIT))
-				link->io.Attributes1 =
-				    IO_DATA_PATH_WIDTH_16;
-			if (!(io->flags & CISTPL_IO_16BIT))
-				link->io.Attributes1 =
-				    IO_DATA_PATH_WIDTH_8;
-			link->io.IOAddrLines =
-			    io->flags & CISTPL_IO_LINES_MASK;
-			link->io.BasePort1 = io->win[0].base;
-			link->io.NumPorts1 = io->win[0].len;
-			if (io->nwin > 1) {
-				link->io.Attributes2 =
-				    link->io.Attributes1;
-				link->io.BasePort2 = io->win[1].base;
-				link->io.NumPorts2 = io->win[1].len;
-			}
-
-			/* This reserves IO space but doesn't actually enable it */
-			if (pcmcia_request_io(link, &link->io) != 0)
-				goto next_entry;
-		}
-
-
-		/* If we got this far, we're cool! */
-
-		break;
-		
-	next_entry:
-		pcmcia_disable_device(link);
-		last_ret = pcmcia_get_next_tuple(link, &tuple);
-		if (last_ret  == CS_NO_MORE_ITEMS) {
+	last_ret = pcmcia_loop_config(link, spectrum_cs_config_check, cfg_mem);
+	if (last_ret) {
+		if (!ignore_cis_vcc)
 			printk(KERN_ERR PFX "GetNextTuple(): No matching "
 			       "CIS configuration.  Maybe you need the "
 			       "ignore_cis_vcc=1 parameter.\n");
-			goto cs_failed;
-		}
+		cs_error(link, RequestIO, last_ret);
+		goto failed;
 	}
 
 	/*
@@ -809,6 +802,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 	       link->irq.AssignedIRQ, link->io.BasePort1,
 	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
+	kfree(cfg_mem);
 	return 0;
 
  cs_failed:
@@ -816,6 +810,7 @@ spectrum_cs_config(struct pcmcia_device *link)
 
  failed:
 	spectrum_cs_release(link);
+	kfree(cfg_mem);
 	return -ENODEV;
 }				/* spectrum_cs_config */
 
-- 
1.5.4.3

