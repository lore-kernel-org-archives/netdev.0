From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] [PATCH 6/7] pcmcia: use pcmcia_loop_config in net pcmcia
	drivers
Date: Tue, 29 Jul 2008 09:21:11 +0200
Message-ID: <20080729072111.GI27385@comet.dominikbrodowski.net>
References: <20080729071539.GB27385@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-pcmcia@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:43261 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752765AbYG2HWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 03:22:10 -0400
Content-Disposition: inline
In-Reply-To: <20080729071539.GB27385@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the config loop helper in (some) net pcmcia drivers.

CC: Jeff Garzik <jgarzik@pobox.com>
CC: <netdev@vger.kernel.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/axnet_cs.c    |   71 ++++++++++++++-------------------
 drivers/net/pcmcia/pcnet_cs.c    |   79 ++++++++++++++++++--------------------
 drivers/net/pcmcia/smc91c92_cs.c |   46 ++++++----------------
 3 files changed, 80 insertions(+), 116 deletions(-)

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
index 250eb19..9edd2d6 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -660,46 +660,26 @@ static int mot_setup(struct pcmcia_device *link)
 
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
 
-- 
1.5.4.3

