From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 6/9] pcmcia: convert net pcmcia drivers to use new CIS helpers
Date: Mon, 19 Oct 2009 01:07:32 +0200
Message-ID: <1255907255-28297-6-git-send-email-linux@dominikbrodowski.net>
References: <1255907255-28297-1-git-send-email-linux@dominikbrodowski.net>
 <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
 <1255907255-28297-3-git-send-email-linux@dominikbrodowski.net>
 <1255907255-28297-4-git-send-email-linux@dominikbrodowski.net>
 <1255907255-28297-5-git-send-email-linux@dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:52306 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753410AbZJRXIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 19:08:10 -0400
In-Reply-To: <1255907255-28297-5-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new CIS helpers in net pcmcia drivers, which allows for
a few code cleanups.

CC: David S. Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/3c574_cs.c    |   18 ++--
 drivers/net/pcmcia/3c589_cs.c    |   24 ++---
 drivers/net/pcmcia/fmvj18x_cs.c  |   51 ++++-----
 drivers/net/pcmcia/nmclan_cs.c   |   19 ++--
 drivers/net/pcmcia/smc91c92_cs.c |  238 +++++++++++---------------------------
 drivers/net/pcmcia/xirc2ps_cs.c  |  101 ++++++----------
 6 files changed, 154 insertions(+), 297 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index b58965a..6449290 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -344,13 +344,13 @@ static int tc574_config(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 	struct el3_private *lp = netdev_priv(dev);
-	tuple_t tuple;
-	__le16 buf[32];
 	int last_fn, last_ret, i, j;
 	unsigned int ioaddr;
 	__be16 *phys_addr;
 	char *cardname;
 	__u32 config;
+	u8 *buf;
+	size_t len;
 
 	phys_addr = (__be16 *)dev->dev_addr;
 
@@ -378,16 +378,14 @@ static int tc574_config(struct pcmcia_device *link)
 	/* The 3c574 normally uses an EEPROM for configuration info, including
 	   the hardware address.  The future products may include a modem chip
 	   and put the address in the CIS. */
-	tuple.Attributes = 0;
-	tuple.TupleData = (cisdata_t *)buf;
-	tuple.TupleDataMax = 64;
-	tuple.TupleOffset = 0;
-	tuple.DesiredTuple = 0x88;
-	if (pcmcia_get_first_tuple(link, &tuple) == 0) {
-		pcmcia_get_tuple_data(link, &tuple);
+
+	len = pcmcia_get_tuple(link, 0x88, &buf);
+	if (buf && len >= 6) {
 		for (i = 0; i < 3; i++)
-			phys_addr[i] = htons(le16_to_cpu(buf[i]));
+			phys_addr[i] = htons(le16_to_cpu(buf[i * 2]));
+		kfree(buf);
 	} else {
+		kfree(buf); /* 0 < len < 6 */
 		EL3WINDOW(0);
 		for (i = 0; i < 3; i++)
 			phys_addr[i] = htons(read_eeprom(ioaddr, i + 10));
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 569fb06..ea04356 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -256,22 +256,15 @@ static int tc589_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     struct el3_private *lp = netdev_priv(dev);
-    tuple_t tuple;
-    __le16 buf[32];
-    __be16 *phys_addr;
+    __be16 *phys_addr = NULL;
     int last_fn, last_ret, i, j, multi = 0, fifo;
     unsigned int ioaddr;
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
+    u8 *buf;
+    size_t len;
     
     DEBUG(0, "3c589_config(0x%p)\n", link);
 
-    phys_addr = (__be16 *)dev->dev_addr;
-    tuple.Attributes = 0;
-    tuple.TupleData = (cisdata_t *)buf;
-    tuple.TupleDataMax = sizeof(buf);
-    tuple.TupleOffset = 0;
-    tuple.Attributes = TUPLE_RETURN_COMMON;
-
     /* Is this a 3c562? */
     if (link->manf_id != MANFID_3COM)
 	    printk(KERN_INFO "3c589_cs: hmmm, is this really a "
@@ -301,12 +294,13 @@ static int tc589_config(struct pcmcia_device *link)
 
     /* The 3c589 has an extra EEPROM for configuration info, including
        the hardware address.  The 3c562 puts the address in the CIS. */
-    tuple.DesiredTuple = 0x88;
-    if (pcmcia_get_first_tuple(link, &tuple) == 0) {
-	pcmcia_get_tuple_data(link, &tuple);
-	for (i = 0; i < 3; i++)
-	    phys_addr[i] = htons(le16_to_cpu(buf[i]));
+    len = pcmcia_get_tuple(link, 0x88, &buf);
+    if (buf && len >= 6) {
+	    for (i = 0; i < 3; i++)
+		    phys_addr[i] = htons(le16_to_cpu(buf[i*2]));
+	    kfree(buf);
     } else {
+	kfree(buf); /* 0 < len < 6 */
 	for (i = 0; i < 3; i++)
 	    phys_addr[i] = htons(read_eeprom(ioaddr, i));
 	if (phys_addr[0] == htons(0x6060)) {
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index c7a2bbf..58954a6 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -350,32 +350,30 @@ static int fmvj18x_ioprobe(struct pcmcia_device *p_dev,
 	return 0; /* strange, but that's what the code did already before... */
 }
 
-
 static int fmvj18x_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     local_info_t *lp = netdev_priv(dev);
-    tuple_t tuple;
-    u_short buf[32];
     int i, last_fn = RequestIO, last_ret = 0, ret;
     unsigned int ioaddr;
     cardtype_t cardtype;
     char *card_name = "unknown";
-    u_char *node_id;
+    u8 *buf;
+    size_t len;
+    u_char buggybuf[32];
 
     DEBUG(0, "fmvj18x_config(0x%p)\n", link);
 
-    tuple.TupleData = (u_char *)buf;
-    tuple.TupleDataMax = 64;
-    tuple.TupleOffset = 0;
-    tuple.DesiredTuple = CISTPL_FUNCE;
-    tuple.TupleOffset = 0;
-    if (pcmcia_get_first_tuple(link, &tuple) == 0) {
+    len = pcmcia_get_tuple(link, CISTPL_FUNCE, &buf);
+    if (buf)
+	    kfree(buf);
+
+    if (len) {
+	/* Yes, I have CISTPL_FUNCE. Let's check CISTPL_MANFID */
 	last_ret = pcmcia_loop_config(link, fmvj18x_ioprobe, NULL);
 	if (last_ret != 0)
 		goto cs_failed;
 
-	/* Yes, I have CISTPL_FUNCE. Let's check CISTPL_MANFID */
 	switch (link->manf_id) {
 	case MANFID_TDK:
 	    cardtype = TDK;
@@ -482,21 +480,21 @@ static int fmvj18x_config(struct pcmcia_device *link)
     case CONTEC:
     case NEC:
     case KME:
-	tuple.DesiredTuple = CISTPL_FUNCE;
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-	tuple.TupleOffset = 0;
-	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
 	if (cardtype == MBH10304) {
-	    /* MBH10304's CIS_FUNCE is corrupted */
-	    node_id = &(tuple.TupleData[5]);
 	    card_name = "FMV-J182";
-	} else {
-	    while (tuple.TupleData[0] != CISTPL_FUNCE_LAN_NODE_ID ) {
-		CS_CHECK(GetNextTuple, pcmcia_get_next_tuple(link, &tuple));
-		CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
+
+	    len = pcmcia_get_tuple(link, CISTPL_FUNCE, &buf);
+	    if (len < 11) {
+		    kfree(buf);
+		    goto failed;
 	    }
-	    node_id = &(tuple.TupleData[2]);
+	    /* Read MACID from CIS */
+	    for (i = 5; i < 11; i++)
+		    dev->dev_addr[i] = buf[i];
+	    kfree(buf);
+	} else {
+	    if (pcmcia_get_mac_from_cis(link, dev))
+		goto failed;
 	    if( cardtype == TDK ) {
 		card_name = "TDK LAK-CD021";
 	    } else if( cardtype == LA501 ) {
@@ -509,9 +507,6 @@ static int fmvj18x_config(struct pcmcia_device *link)
 		card_name = "C-NET(PC)C";
 	    }
 	}
-	/* Read MACID from CIS */
-	for (i = 0; i < 6; i++)
-	    dev->dev_addr[i] = node_id[i];
 	break;
     case UNGERMANN:
 	/* Read MACID from register */
@@ -521,12 +516,12 @@ static int fmvj18x_config(struct pcmcia_device *link)
 	break;
     case XXX10304:
 	/* Read MACID from Buggy CIS */
-	if (fmvj18x_get_hwinfo(link, tuple.TupleData) == -1) {
+	if (fmvj18x_get_hwinfo(link, buggybuf) == -1) {
 	    printk(KERN_NOTICE "fmvj18x_cs: unable to read hardware net address.\n");
 	    goto failed;
 	}
 	for (i = 0 ; i < 6; i++) {
-	    dev->dev_addr[i] = tuple.TupleData[i];
+	    dev->dev_addr[i] = buggybuf[i];
 	}
 	card_name = "FMV-J182";
 	break;
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 5ed6339..4b96b35 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -661,8 +661,8 @@ static int nmclan_config(struct pcmcia_device *link)
 {
   struct net_device *dev = link->priv;
   mace_private *lp = netdev_priv(dev);
-  tuple_t tuple;
-  u_char buf[64];
+  u8 *buf;
+  size_t len;
   int i, last_ret, last_fn;
   unsigned int ioaddr;
 
@@ -677,14 +677,13 @@ static int nmclan_config(struct pcmcia_device *link)
   ioaddr = dev->base_addr;
 
   /* Read the ethernet address from the CIS. */
-  tuple.DesiredTuple = 0x80 /* CISTPL_CFTABLE_ENTRY_MISC */;
-  tuple.TupleData = buf;
-  tuple.TupleDataMax = 64;
-  tuple.TupleOffset = 0;
-  tuple.Attributes = 0;
-  CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
-  CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-  memcpy(dev->dev_addr, tuple.TupleData, ETHER_ADDR_LEN);
+  len = pcmcia_get_tuple(link, 0x80, &buf);
+  if (!buf || len < ETHER_ADDR_LEN) {
+	  kfree(buf);
+	  goto failed;
+  }
+  memcpy(dev->dev_addr, buf, ETHER_ADDR_LEN);
+  kfree(buf);
 
   /* Verify configuration by reading the MACE ID. */
   {
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index af03759..df92bcd 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -126,12 +126,6 @@ struct smc_private {
     int				rx_ovrn;
 };
 
-struct smc_cfg_mem {
-    tuple_t tuple;
-    cisparse_t parse;
-    u_char buf[255];
-};
-
 /* Special definitions for Megahertz multifunction cards */
 #define MEGAHERTZ_ISR		0x0380
 
@@ -408,34 +402,7 @@ static int cvt_ascii_address(struct net_device *dev, char *s)
     return 0;
 }
 
-/*====================================================================*/
-
-static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
-		cisparse_t *parse)
-{
-	int i;
-
-	i = pcmcia_get_first_tuple(handle, tuple);
-	if (i != 0)
-		return i;
-	i = pcmcia_get_tuple_data(handle, tuple);
-	if (i != 0)
-		return i;
-	return pcmcia_parse_tuple(tuple, parse);
-}
-
-static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
-		cisparse_t *parse)
-{
-	int i;
-
-	if ((i = pcmcia_get_next_tuple(handle, tuple)) != 0 ||
-			(i = pcmcia_get_tuple_data(handle, tuple)) != 0)
-		return i;
-	return pcmcia_parse_tuple(tuple, parse);
-}
-
-/*======================================================================
+/*====================================================================
 
     Configuration stuff for Megahertz cards
 
@@ -490,15 +457,10 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
     struct smc_private *smc = netdev_priv(dev);
-    struct smc_cfg_mem *cfg_mem;
     win_req_t req;
     memreq_t mem;
     int i;
 
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-	    return -ENOMEM;
-
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
     link->irq.Attributes =
@@ -510,7 +472,8 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     /* The Megahertz combo cards have modem-like CIS entries, so
        we have to explicitly try a bunch of port combinations. */
     if (pcmcia_loop_config(link, mhz_mfc_config_check, NULL))
-	goto free_cfg_mem;
+	    return -ENODEV;
+
     dev->base_addr = link->io.BasePort1;
 
     /* Allocate a memory window, for accessing the ISR */
@@ -519,7 +482,8 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     req.AccessSpeed = 0;
     i = pcmcia_request_window(&link, &req, &link->win);
     if (i != 0)
-	goto free_cfg_mem;
+	    return -ENODEV;
+
     smc->base = ioremap(req.Base, req.Size);
     mem.CardOffset = mem.Page = 0;
     if (smc->manfid == MANFID_MOTOROLA)
@@ -531,18 +495,32 @@ static int mhz_mfc_config(struct pcmcia_device *link)
 	&& (smc->cardid == PRODID_MEGAHERTZ_EM3288))
 	mhz_3288_power(link);
 
-free_cfg_mem:
-    kfree(cfg_mem);
-    return -ENODEV;
+    return 0;
 }
 
+static int pcmcia_get_versmac(struct pcmcia_device *p_dev,
+			      tuple_t *tuple,
+			      void *priv)
+{
+	struct net_device *dev = priv;
+	cisparse_t parse;
+
+	if (pcmcia_parse_tuple(tuple, &parse))
+		return -EINVAL;
+
+	if ((parse.version_1.ns > 3) &&
+	    (cvt_ascii_address(dev,
+			       (parse.version_1.str + parse.version_1.ofs[3]))))
+		return 0;
+
+	return -EINVAL;
+};
+
 static int mhz_setup(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    cisparse_t *parse;
-    u_char *buf, *station_addr;
+    size_t len;
+    u8 *buf;
     int rc;
 
     /* Read the station address from the CIS.  It is stored as the last
@@ -552,56 +530,22 @@ static int mhz_setup(struct pcmcia_device *link)
 	    return 0;
 
     /* Workarounds for broken cards start here. */
-
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-	return -1;
-
-    tuple = &cfg_mem->tuple;
-    parse = &cfg_mem->parse;
-    buf = cfg_mem->buf;
-
-    tuple->Attributes = tuple->TupleOffset = 0;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 255;
-
     /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
-    tuple->DesiredTuple = CISTPL_VERS_1;
-    if (first_tuple(link, tuple, parse) != 0) {
-	rc = -1;
-	goto free_cfg_mem;
-    }
-    /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
-    if (next_tuple(link, tuple, parse) != 0)
-	first_tuple(link, tuple, parse);
-    if (parse->version_1.ns > 3) {
-	station_addr = parse->version_1.str + parse->version_1.ofs[3];
-	if (cvt_ascii_address(dev, station_addr) == 0) {
-		rc = 0;
-		goto free_cfg_mem;
-	}
-    }
+    if (!pcmcia_loop_tuple(link, CISTPL_VERS_1, pcmcia_get_versmac, dev))
+	    return 0;
 
     /* Another possibility: for the EM3288, in a special tuple */
-    tuple->DesiredTuple = 0x81;
-    if (pcmcia_get_first_tuple(link, tuple) != 0) {
-	rc = -1;
-	goto free_cfg_mem;
-    }
-    if (pcmcia_get_tuple_data(link, tuple) != 0) {
-	rc = -1;
-	goto free_cfg_mem;
-    }
-    buf[12] = '\0';
-    if (cvt_ascii_address(dev, buf) == 0) {
-	rc = 0;
-	goto free_cfg_mem;
-   }
     rc = -1;
-free_cfg_mem:
-   kfree(cfg_mem);
-   return rc;
-}
+    len = pcmcia_get_tuple(link, 0x81, &buf);
+    if (buf && len >= 13) {
+	    buf[12] = '\0';
+	    if (cvt_ascii_address(dev, buf))
+		    rc = 0;
+    }
+    kfree(buf);
+
+    return rc;
+};
 
 /*======================================================================
 
@@ -691,58 +635,21 @@ static int smc_config(struct pcmcia_device *link)
     return i;
 }
 
+
 static int smc_setup(struct pcmcia_device *link)
 {
     struct net_device *dev = link->priv;
-    struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    cisparse_t *parse;
-    cistpl_lan_node_id_t *node_id;
-    u_char *buf, *station_addr;
-    int i, rc;
-
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-	    return -ENOMEM;
-
-    tuple = &cfg_mem->tuple;
-    parse = &cfg_mem->parse;
-    buf = cfg_mem->buf;
-
-    tuple->Attributes = tuple->TupleOffset = 0;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 255;
 
     /* Check for a LAN function extension tuple */
-    tuple->DesiredTuple = CISTPL_FUNCE;
-    i = first_tuple(link, tuple, parse);
-    while (i == 0) {
-	if (parse->funce.type == CISTPL_FUNCE_LAN_NODE_ID)
-	    break;
-	i = next_tuple(link, tuple, parse);
-    }
-    if (i == 0) {
-	node_id = (cistpl_lan_node_id_t *)parse->funce.data;
-	if (node_id->nb == 6) {
-	    for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = node_id->id[i];
-	    rc = 0;
-	    goto free_cfg_mem;
-	}
-    }
+    if (!pcmcia_get_mac_from_cis(link, dev))
+	    return 0;
+
     /* Try the third string in the Version 1 Version/ID tuple. */
     if (link->prod_id[2]) {
-	station_addr = link->prod_id[2];
-	if (cvt_ascii_address(dev, station_addr) == 0) {
-		rc = 0;
-		goto free_cfg_mem;
-	}
+	    if (cvt_ascii_address(dev, link->prod_id[2]) == 0)
+		    return 0;
     }
-
-    rc = -1;
-free_cfg_mem:
-    kfree(cfg_mem);
-    return rc;
+    return -1;
 }
 
 /*====================================================================*/
@@ -801,41 +708,31 @@ static int osi_load_firmware(struct pcmcia_device *link)
 	return err;
 }
 
-static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
+static int pcmcia_osi_mac(struct pcmcia_device *p_dev,
+			  tuple_t *tuple,
+			  void *priv)
 {
-    struct net_device *dev = link->priv;
-    struct smc_cfg_mem *cfg_mem;
-    tuple_t *tuple;
-    u_char *buf;
-    int i, rc;
+	struct net_device *dev = priv;
+	int i;
 
-    cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
-    if (!cfg_mem)
-        return -1;
+	if (tuple->TupleDataLen < 8)
+		return -EINVAL;
+	if (tuple->TupleData[0] != 0x04)
+		return -EINVAL;
+	for (i = 0; i < 6; i++)
+		dev->dev_addr[i] = tuple->TupleData[i+2];
+	return 0;
+};
 
-    tuple = &cfg_mem->tuple;
-    buf = cfg_mem->buf;
 
-    tuple->Attributes = TUPLE_RETURN_COMMON;
-    tuple->TupleData = (cisdata_t *)buf;
-    tuple->TupleDataMax = 255;
-    tuple->TupleOffset = 0;
+static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
+{
+    struct net_device *dev = link->priv;
+    int rc;
 
     /* Read the station address from tuple 0x90, subtuple 0x04 */
-    tuple->DesiredTuple = 0x90;
-    i = pcmcia_get_first_tuple(link, tuple);
-    while (i == 0) {
-	i = pcmcia_get_tuple_data(link, tuple);
-	if ((i != 0) || (buf[0] == 0x04))
-	    break;
-	i = pcmcia_get_next_tuple(link, tuple);
-    }
-    if (i != 0) {
-	rc = -1;
-	goto free_cfg_mem;
-    }
-    for (i = 0; i < 6; i++)
-	dev->dev_addr[i] = buf[i+2];
+    if (pcmcia_loop_tuple(link, 0x90, pcmcia_osi_mac, dev))
+	    return -1;
 
     if (((manfid == MANFID_OSITECH) &&
 	 (cardid == PRODID_OSITECH_SEVEN)) ||
@@ -843,7 +740,7 @@ static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
 	 (cardid == PRODID_PSION_NET100))) {
 	rc = osi_load_firmware(link);
 	if (rc)
-		goto free_cfg_mem;
+		return rc;
     } else if (manfid == MANFID_OSITECH) {
 	/* Make sure both functions are powered up */
 	set_bits(0x300, link->io.BasePort1 + OSITECH_AUI_PWR);
@@ -853,10 +750,7 @@ static int osi_setup(struct pcmcia_device *link, u_short manfid, u_short cardid)
 	      inw(link->io.BasePort1 + OSITECH_AUI_PWR),
 	      inw(link->io.BasePort1 + OSITECH_RESET_ISR));
     }
-    rc = 0;
-free_cfg_mem:
-   kfree(cfg_mem);
-   return rc;
+    return 0;
 }
 
 static int smc91c92_suspend(struct pcmcia_device *link)
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 3dd6ba6..8ed8449 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -371,28 +371,6 @@ static void do_powerdown(struct net_device *dev);
 static int do_stop(struct net_device *dev);
 
 /*=============== Helper functions =========================*/
-static int
-first_tuple(struct pcmcia_device *handle, tuple_t *tuple, cisparse_t *parse)
-{
-	int err;
-
-	if ((err = pcmcia_get_first_tuple(handle, tuple)) == 0 &&
-			(err = pcmcia_get_tuple_data(handle, tuple)) == 0)
-		err = pcmcia_parse_tuple(tuple, parse);
-	return err;
-}
-
-static int
-next_tuple(struct pcmcia_device *handle, tuple_t *tuple, cisparse_t *parse)
-{
-	int err;
-
-	if ((err = pcmcia_get_next_tuple(handle, tuple)) == 0 &&
-			(err = pcmcia_get_tuple_data(handle, tuple)) == 0)
-		err = pcmcia_parse_tuple(tuple, parse);
-	return err;
-}
-
 #define SelectPage(pgnr)   outb((pgnr), ioaddr + XIRCREG_PR)
 #define GetByte(reg)	   ((unsigned)inb(ioaddr + (reg)))
 #define GetWord(reg)	   ((unsigned)inw(ioaddr + (reg)))
@@ -761,6 +739,26 @@ xirc2ps_config_check(struct pcmcia_device *p_dev,
 
 }
 
+
+static int pcmcia_get_mac_ce(struct pcmcia_device *p_dev,
+			     tuple_t *tuple,
+			     void *priv)
+{
+	struct net_device *dev = priv;
+	int i;
+
+	if (tuple->TupleDataLen != 13)
+		return -EINVAL;
+	if ((tuple->TupleData[0] != 2) || (tuple->TupleData[1] != 1) ||
+		(tuple->TupleData[2] != 6))
+		return -EINVAL;
+	/* another try	(James Lehmer's CE2 version 4.1)*/
+	for (i = 2; i < 6; i++)
+		dev->dev_addr[i] = tuple->TupleData[i+2];
+	return 0;
+};
+
+
 /****************
  * xirc2ps_config() is scheduled to run after a CARD_INSERTION event
  * is received, to configure the PCMCIA socket, and to make the
@@ -774,9 +772,9 @@ xirc2ps_config(struct pcmcia_device * link)
     unsigned int ioaddr;
     tuple_t tuple;
     cisparse_t parse;
-    int err, i;
-    u_char buf[64];
-    cistpl_lan_node_id_t *node_id = (cistpl_lan_node_id_t*)parse.funce.data;
+    int err;
+    u8 *buf;
+    size_t len;
 
     local->dingo_ccr = NULL;
 
@@ -827,49 +825,28 @@ xirc2ps_config(struct pcmcia_device * link)
     }
 
     /* get the ethernet address from the CIS */
-    tuple.DesiredTuple = CISTPL_FUNCE;
-    for (err = first_tuple(link, &tuple, &parse); !err;
-			     err = next_tuple(link, &tuple, &parse)) {
-	/* Once I saw two CISTPL_FUNCE_LAN_NODE_ID entries:
-	 * the first one with a length of zero the second correct -
-	 * so I skip all entries with length 0 */
-	if (parse.funce.type == CISTPL_FUNCE_LAN_NODE_ID
-	    && ((cistpl_lan_node_id_t *)parse.funce.data)->nb)
-	    break;
-    }
-    if (err) { /* not found: try to get the node-id from tuple 0x89 */
-	tuple.DesiredTuple = 0x89;  /* data layout looks like tuple 0x22 */
-	if ((err = pcmcia_get_first_tuple(link, &tuple)) == 0 &&
-		(err = pcmcia_get_tuple_data(link, &tuple)) == 0) {
-	    if (tuple.TupleDataLen == 8 && *buf == CISTPL_FUNCE_LAN_NODE_ID)
-		memcpy(&parse, buf, 8);
-	    else
-		err = -1;
-	}
-    }
-    if (err) { /* another try	(James Lehmer's CE2 version 4.1)*/
-	tuple.DesiredTuple = CISTPL_FUNCE;
-	for (err = first_tuple(link, &tuple, &parse); !err;
-				 err = next_tuple(link, &tuple, &parse)) {
-	    if (parse.funce.type == 0x02 && parse.funce.data[0] == 1
-		&& parse.funce.data[1] == 6 && tuple.TupleDataLen == 13) {
-		buf[1] = 4;
-		memcpy(&parse, buf+1, 8);
-		break;
+    err = pcmcia_get_mac_from_cis(link, dev);
+
+    /* not found: try to get the node-id from tuple 0x89 */
+    if (err) {
+	    len = pcmcia_get_tuple(link, 0x89, &buf);
+	    /* data layout looks like tuple 0x22 */
+	    if (buf && len == 8) {
+		    if (*buf == CISTPL_FUNCE_LAN_NODE_ID)
+			    memcpy(&parse, buf, 8);
+		    else
+			    err = -1;
 	    }
-	}
+	    kfree(buf);
     }
+
+    if (err)
+	err = pcmcia_loop_tuple(link, CISTPL_FUNCE, pcmcia_get_mac_ce, dev);
+
     if (err) {
 	printk(KNOT_XIRC "node-id not found in CIS\n");
 	goto failure;
     }
-    node_id = (cistpl_lan_node_id_t *)parse.funce.data;
-    if (node_id->nb != 6) {
-	printk(KNOT_XIRC "malformed node-id in CIS\n");
-	goto failure;
-    }
-    for (i=0; i < 6; i++)
-	dev->dev_addr[i] = node_id->id[i];
 
     link->io.IOAddrLines =10;
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
-- 
1.6.0.4

