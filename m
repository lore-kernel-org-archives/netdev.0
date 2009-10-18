From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 3/9] pcmcia: use pcmcia_loop_config in misc pcmcia drivers
Date: Mon, 19 Oct 2009 01:07:29 +0200
Message-ID: <1255907255-28297-3-git-send-email-linux@dominikbrodowski.net>
References: <1255907255-28297-1-git-send-email-linux@dominikbrodowski.net>
 <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Kosina <jkosina@suse.cz>, David Sterba <dsterba@suse.cz>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:52284 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751877AbZJRXIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 19:08:07 -0400
In-Reply-To: <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pcmcia_loop_config() in a few drivers missed during the first
round. On fmvj18x_cs.c it -- strangely -- only requries us to set
conf.ConfigIndex, which is done by the core, so include an empty
loop function which returns 0 unconditionally.

CC: David S. Miller <davem@davemloft.net>
CC: John W. Linville <linville@tuxdriver.com>
CC: Jiri Kosina <jkosina@suse.cz>
CC: David Sterba <dsterba@suse.cz>
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/char/pcmcia/ipwireless/main.c |  103 +++++++--------------------------
 drivers/char/pcmcia/synclink_cs.c     |   64 ++++++++-------------
 drivers/net/pcmcia/fmvj18x_cs.c       |   22 +++++--
 drivers/net/wireless/libertas/if_cs.c |   67 +++++++++-------------
 4 files changed, 88 insertions(+), 168 deletions(-)

diff --git a/drivers/char/pcmcia/ipwireless/main.c b/drivers/char/pcmcia/ipwireless/main.c
index 5216fce..263a18f 100644
--- a/drivers/char/pcmcia/ipwireless/main.c
+++ b/drivers/char/pcmcia/ipwireless/main.c
@@ -79,14 +79,32 @@ static void signalled_reboot_callback(void *callback_data)
 	schedule_work(&ipw->work_reboot);
 }
 
+static int ipwireless_ioprobe(struct pcmcia_device *p_dev,
+			      cistpl_cftable_entry_t *cfg,
+			      cistpl_cftable_entry_t *dflt,
+			      unsigned int vcc,
+			      void *priv_data)
+{
+	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+	p_dev->io.BasePort1 = cfg->io.win[0].base;
+	p_dev->io.NumPorts1 = cfg->io.win[0].len;
+	p_dev->io.IOAddrLines = 16;
+
+	p_dev->irq.IRQInfo1 = cfg->irq.IRQInfo1;
+
+	/* 0x40 causes it to generate level mode interrupts. */
+	/* 0x04 enables IREQ pin. */
+	p_dev->conf.ConfigIndex = cfg->index | 0x44;
+	return pcmcia_request_io(p_dev, &p_dev->io);
+}
+
 static int config_ipwireless(struct ipw_dev *ipw)
 {
 	struct pcmcia_device *link = ipw->link;
-	int ret;
+	int ret = 0;
 	tuple_t tuple;
 	unsigned short buf[64];
 	cisparse_t parse;
-	unsigned short cor_value;
 	memreq_t memreq_attr_memory;
 	memreq_t memreq_common_memory;
 
@@ -97,103 +115,26 @@ static int config_ipwireless(struct ipw_dev *ipw)
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
 
-	tuple.DesiredTuple = RETURN_FIRST_TUPLE;
-
-	ret = pcmcia_get_first_tuple(link, &tuple);
-
-	while (ret == 0) {
-		ret = pcmcia_get_tuple_data(link, &tuple);
-
-		if (ret != 0) {
-			cs_error(link, GetTupleData, ret);
-			goto exit0;
-		}
-		ret = pcmcia_get_next_tuple(link, &tuple);
-	}
-
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-
-	ret = pcmcia_get_first_tuple(link, &tuple);
-
-	if (ret != 0) {
-		cs_error(link, GetFirstTuple, ret);
-		goto exit0;
-	}
-
-	ret = pcmcia_get_tuple_data(link, &tuple);
-
-	if (ret != 0) {
-		cs_error(link, GetTupleData, ret);
-		goto exit0;
-	}
-
-	ret = pcmcia_parse_tuple(&tuple, &parse);
-
-	if (ret != 0) {
-		cs_error(link, ParseTuple, ret);
-		goto exit0;
-	}
-
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	link->io.BasePort1 = parse.cftable_entry.io.win[0].base;
-	link->io.NumPorts1 = parse.cftable_entry.io.win[0].len;
-	link->io.IOAddrLines = 16;
-
-	link->irq.IRQInfo1 = parse.cftable_entry.irq.IRQInfo1;
-
-	/* 0x40 causes it to generate level mode interrupts. */
-	/* 0x04 enables IREQ pin. */
-	cor_value = parse.cftable_entry.index | 0x44;
-	link->conf.ConfigIndex = cor_value;
-
-	/* IRQ and I/O settings */
-	tuple.DesiredTuple = CISTPL_CONFIG;
-
-	ret = pcmcia_get_first_tuple(link, &tuple);
-
+	ret = pcmcia_loop_config(link, ipwireless_ioprobe, NULL);
 	if (ret != 0) {
-		cs_error(link, GetFirstTuple, ret);
-		goto exit0;
-	}
-
-	ret = pcmcia_get_tuple_data(link, &tuple);
-
-	if (ret != 0) {
-		cs_error(link, GetTupleData, ret);
+		cs_error(link, RequestIO, ret);
 		goto exit0;
 	}
 
-	ret = pcmcia_parse_tuple(&tuple, &parse);
-
-	if (ret != 0) {
-		cs_error(link, GetTupleData, ret);
-		goto exit0;
-	}
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-	link->conf.ConfigBase = parse.config.base;
-	link->conf.Present = parse.config.rmask[0];
 	link->conf.IntType = INT_MEMORY_AND_IO;
 
 	link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_HANDLE_PRESENT;
 	link->irq.Handler = ipwireless_interrupt;
 	link->irq.Instance = ipw->hardware;
 
-	ret = pcmcia_request_io(link, &link->io);
-
-	if (ret != 0) {
-		cs_error(link, RequestIO, ret);
-		goto exit0;
-	}
-
 	request_region(link->io.BasePort1, link->io.NumPorts1,
 			IPWIRELESS_PCCARD_NAME);
 
 	/* memory settings */
-
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 
 	ret = pcmcia_get_first_tuple(link, &tuple);
-
 	if (ret != 0) {
 		cs_error(link, GetFirstTuple, ret);
 		goto exit1;
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index caf6e4d..429b731 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -575,55 +575,39 @@ static int mgslpc_probe(struct pcmcia_device *link)
 #define CS_CHECK(fn, ret) \
 do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 
+static int mgslpc_ioprobe(struct pcmcia_device *p_dev,
+			  cistpl_cftable_entry_t *cfg,
+			  cistpl_cftable_entry_t *dflt,
+			  unsigned int vcc,
+			  void *priv_data)
+{
+	if (cfg->io.nwin > 0) {
+		p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+		if (!(cfg->io.flags & CISTPL_IO_8BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
+		if (!(cfg->io.flags & CISTPL_IO_16BIT))
+			p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
+		p_dev->io.IOAddrLines = cfg->io.flags & CISTPL_IO_LINES_MASK;
+		p_dev->io.BasePort1 = cfg->io.win[0].base;
+		p_dev->io.NumPorts1 = cfg->io.win[0].len;
+		return pcmcia_request_io(p_dev, &p_dev->io);
+	}
+	return -ENODEV;
+}
+
 static int mgslpc_config(struct pcmcia_device *link)
 {
     MGSLPC_INFO *info = link->priv;
-    tuple_t tuple;
-    cisparse_t parse;
-    int last_fn, last_ret;
-    u_char buf[64];
-    cistpl_cftable_entry_t dflt = { 0 };
-    cistpl_cftable_entry_t *cfg;
+    int last_fn = RequestIO;
+    int last_ret;
 
     if (debug_level >= DEBUG_LEVEL_INFO)
 	    printk("mgslpc_config(0x%p)\n", link);
 
-    tuple.Attributes = 0;
-    tuple.TupleData = buf;
-    tuple.TupleDataMax = sizeof(buf);
-    tuple.TupleOffset = 0;
-
-    /* get CIS configuration entry */
-
-    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-
-    cfg = &(parse.cftable_entry);
-    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-    CS_CHECK(ParseTuple, pcmcia_parse_tuple(&tuple, &parse));
-
-    if (cfg->flags & CISTPL_CFTABLE_DEFAULT) dflt = *cfg;
-    if (cfg->index == 0)
+    last_ret = pcmcia_loop_config(link, mgslpc_ioprobe, NULL);
+    if (last_ret != 0)
 	    goto cs_failed;
 
-    link->conf.ConfigIndex = cfg->index;
-    link->conf.Attributes |= CONF_ENABLE_IRQ;
-
-    /* IO window settings */
-    link->io.NumPorts1 = 0;
-    if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
-	    cistpl_io_t *io = (cfg->io.nwin) ? &cfg->io : &dflt.io;
-	    link->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	    if (!(io->flags & CISTPL_IO_8BIT))
-		    link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-	    if (!(io->flags & CISTPL_IO_16BIT))
-		    link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	    link->io.IOAddrLines = io->flags & CISTPL_IO_LINES_MASK;
-	    link->io.BasePort1 = io->win[0].base;
-	    link->io.NumPorts1 = io->win[0].len;
-	    CS_CHECK(RequestIO, pcmcia_request_io(link, &link->io));
-    }
-
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.ConfigIndex = 8;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 7e01fbd..c7a2bbf 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -341,14 +341,23 @@ static int ungermann_try_io_port(struct pcmcia_device *link)
     return ret;	/* RequestIO failed */
 }
 
+static int fmvj18x_ioprobe(struct pcmcia_device *p_dev,
+			   cistpl_cftable_entry_t *cfg,
+			   cistpl_cftable_entry_t *dflt,
+			   unsigned int vcc,
+			   void *priv_data)
+{
+	return 0; /* strange, but that's what the code did already before... */
+}
+
+
 static int fmvj18x_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     local_info_t *lp = netdev_priv(dev);
     tuple_t tuple;
-    cisparse_t parse;
     u_short buf[32];
-    int i, last_fn = 0, last_ret = 0, ret;
+    int i, last_fn = RequestIO, last_ret = 0, ret;
     unsigned int ioaddr;
     cardtype_t cardtype;
     char *card_name = "unknown";
@@ -362,12 +371,11 @@ static int fmvj18x_config(struct pcmcia_device *link)
     tuple.DesiredTuple = CISTPL_FUNCE;
     tuple.TupleOffset = 0;
     if (pcmcia_get_first_tuple(link, &tuple) == 0) {
+	last_ret = pcmcia_loop_config(link, fmvj18x_ioprobe, NULL);
+	if (last_ret != 0)
+		goto cs_failed;
+
 	/* Yes, I have CISTPL_FUNCE. Let's check CISTPL_MANFID */
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	CS_CHECK(ParseTuple, pcmcia_parse_tuple(&tuple, &parse));
-	link->conf.ConfigIndex = parse.cftable_entry.index;
 	switch (link->manf_id) {
 	case MANFID_TDK:
 	    cardtype = TDK;
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 6238176..cb40c38 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -793,18 +793,37 @@ static void if_cs_release(struct pcmcia_device *p_dev)
  * configure the card at this point -- we wait until we receive a card
  * insertion event.
  */
+
+static int if_cs_ioprobe(struct pcmcia_device *p_dev,
+			 cistpl_cftable_entry_t *cfg,
+			 cistpl_cftable_entry_t *dflt,
+			 unsigned int vcc,
+			 void *priv_data)
+{
+	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
+	p_dev->io.BasePort1 = cfg->io.win[0].base;
+	p_dev->io.NumPorts1 = cfg->io.win[0].len;
+
+	/* Do we need to allocate an interrupt? */
+	if (cfg->irq.IRQInfo1)
+		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
+
+	/* IO window settings */
+	if (cfg->io.nwin != 1) {
+		lbs_pr_err("wrong CIS (check number of IO windows)\n");
+		return -ENODEV;
+	}
+
+	/* This reserves IO space but doesn't actually enable it */
+	return pcmcia_request_io(p_dev, &p_dev->io);
+}
+
 static int if_cs_probe(struct pcmcia_device *p_dev)
 {
 	int ret = -ENOMEM;
 	unsigned int prod_id;
 	struct lbs_private *priv;
 	struct if_cs_card *card;
-	/* CIS parsing */
-	tuple_t tuple;
-	cisparse_t parse;
-	cistpl_cftable_entry_t *cfg = &parse.cftable_entry;
-	cistpl_io_t *io = &cfg->io;
-	u_char buf[64];
 
 	lbs_deb_enter(LBS_DEB_CS);
 
@@ -823,43 +842,11 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 	p_dev->conf.Attributes = 0;
 	p_dev->conf.IntType = INT_MEMORY_AND_IO;
 
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-
-	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
-	if ((ret = pcmcia_get_first_tuple(p_dev, &tuple)) != 0 ||
-	    (ret = pcmcia_get_tuple_data(p_dev, &tuple)) != 0 ||
-	    (ret = pcmcia_parse_tuple(&tuple, &parse)) != 0)
-	{
-		lbs_pr_err("error in pcmcia_get_first_tuple etc\n");
-		goto out1;
-	}
-
-	p_dev->conf.ConfigIndex = cfg->index;
-
-	/* Do we need to allocate an interrupt? */
-	if (cfg->irq.IRQInfo1) {
-		p_dev->conf.Attributes |= CONF_ENABLE_IRQ;
-	}
-
-	/* IO window settings */
-	if (cfg->io.nwin != 1) {
-		lbs_pr_err("wrong CIS (check number of IO windows)\n");
-		ret = -ENODEV;
+	if (pcmcia_loop_config(p_dev, if_cs_ioprobe, NULL)) {
+		lbs_pr_err("error in pcmcia_loop_config\n");
 		goto out1;
 	}
-	p_dev->io.Attributes1 = IO_DATA_PATH_WIDTH_AUTO;
-	p_dev->io.BasePort1 = io->win[0].base;
-	p_dev->io.NumPorts1 = io->win[0].len;
 
-	/* This reserves IO space but doesn't actually enable it */
-	ret = pcmcia_request_io(p_dev, &p_dev->io);
-	if (ret) {
-		lbs_pr_err("error in pcmcia_request_io\n");
-		goto out1;
-	}
 
 	/*
 	 * Allocate an interrupt line.  Note that this does not assign
-- 
1.6.0.4

