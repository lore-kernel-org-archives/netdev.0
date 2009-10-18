From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 2/9] pcmcia: use pre-determined values
Date: Mon, 19 Oct 2009 01:07:28 +0200
Message-ID: <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
References: <1255907255-28297-1-git-send-email-linux@dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:52302 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753689AbZJRXIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 19:08:09 -0400
In-Reply-To: <1255907255-28297-1-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few PCMCIA network drivers can make use of values provided by the pcmcia
core, instead of tedious, independent CIS parsing.

xirc32ps_cs.c: manf_id

hostap_cs.c: multifunction count

b43/pcmcia.c: ConfigBase address and "Present"

smc91c92_cs.c:  By default, mhz_setup() can use VERS_1 as it is stored
in struct pcmcia_device. Only some cards require workarounds, such as
reading out VERS_1 twice.

CC: David S. Miller <davem@davemloft.net>
CC: John W. Linville <linville@tuxdriver.com>
CC: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/smc91c92_cs.c        |   11 +++++++++--
 drivers/net/pcmcia/xirc2ps_cs.c         |    5 ++---
 drivers/net/wireless/b43/pcmcia.c       |   20 --------------------
 drivers/net/wireless/hostap/hostap_cs.c |   21 +--------------------
 4 files changed, 12 insertions(+), 45 deletions(-)

diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 7bde2cd..af03759 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -545,6 +545,14 @@ static int mhz_setup(struct pcmcia_device *link)
     u_char *buf, *station_addr;
     int rc;
 
+    /* Read the station address from the CIS.  It is stored as the last
+       (fourth) string in the Version 1 Version/ID tuple. */
+    if ((link->prod_id[3]) &&
+	(cvt_ascii_address(dev, link->prod_id[3]) == 0))
+	    return 0;
+
+    /* Workarounds for broken cards start here. */
+
     cfg_mem = kmalloc(sizeof(struct smc_cfg_mem), GFP_KERNEL);
     if (!cfg_mem)
 	return -1;
@@ -557,8 +565,7 @@ static int mhz_setup(struct pcmcia_device *link)
     tuple->TupleData = (cisdata_t *)buf;
     tuple->TupleDataMax = 255;
 
-    /* Read the station address from the CIS.  It is stored as the last
-       (fourth) string in the Version 1 Version/ID tuple. */
+    /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
     tuple->DesiredTuple = CISTPL_VERS_1;
     if (first_tuple(link, tuple, parse) != 0) {
 	rc = -1;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index cf84231..3dd6ba6 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -792,13 +792,12 @@ xirc2ps_config(struct pcmcia_device * link)
     tuple.TupleOffset = 0;
 
     /* Is this a valid	card */
-    tuple.DesiredTuple = CISTPL_MANFID;
-    if ((err=first_tuple(link, &tuple, &parse))) {
+    if (link->has_manf_id == 0) {
 	printk(KNOT_XIRC "manfid not found in CIS\n");
 	goto failure;
     }
 
-    switch(parse.manfid.manf) {
+    switch (link->manf_id) {
       case MANFID_XIRCOM:
 	local->manf_str = "Xircom";
 	break;
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 6c3a749..cd14b7e 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -65,35 +65,15 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	struct ssb_bus *ssb;
 	win_req_t win;
 	memreq_t mem;
-	tuple_t tuple;
-	cisparse_t parse;
 	int err = -ENOMEM;
 	int res = 0;
-	unsigned char buf[64];
 
 	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
 	if (!ssb)
 		goto out_error;
 
 	err = -ENODEV;
-	tuple.DesiredTuple = CISTPL_CONFIG;
-	tuple.Attributes = 0;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
 
-	res = pcmcia_get_first_tuple(dev, &tuple);
-	if (res != 0)
-		goto err_kfree_ssb;
-	res = pcmcia_get_tuple_data(dev, &tuple);
-	if (res != 0)
-		goto err_kfree_ssb;
-	res = pcmcia_parse_tuple(&tuple, &parse);
-	if (res != 0)
-		goto err_kfree_ssb;
-
-	dev->conf.ConfigBase = parse.config.base;
-	dev->conf.Present = parse.config.rmask[0];
 	dev->conf.Attributes = CONF_ENABLE_IRQ;
 	dev->conf.IntType = INT_MEMORY_AND_IO;
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index ad8eab4..31b60dd 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -274,9 +274,6 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	conf_reg_t reg;
 	struct hostap_interface *iface = netdev_priv(dev);
 	local_info_t *local = iface->local;
-	tuple_t tuple;
-	cisparse_t *parse = NULL;
-	u_char buf[64];
 	struct hostap_cs_priv *hw_priv = local->hw_priv;
 
 	if (hw_priv->link->io.NumPorts1 < 0x42) {
@@ -285,28 +282,13 @@ static int sandisk_enable_wireless(struct net_device *dev)
 		goto done;
 	}
 
-	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
-	if (parse == NULL) {
-		ret = -ENOMEM;
-		goto done;
-	}
-
-	tuple.Attributes = TUPLE_RETURN_COMMON;
-	tuple.TupleData = buf;
-	tuple.TupleDataMax = sizeof(buf);
-	tuple.TupleOffset = 0;
-
 	if (hw_priv->link->manf_id != 0xd601 || hw_priv->link->card_id != 0x0101) {
 		/* No SanDisk manfid found */
 		ret = -ENODEV;
 		goto done;
 	}
 
-	tuple.DesiredTuple = CISTPL_LONGLINK_MFC;
-	if (pcmcia_get_first_tuple(hw_priv->link, &tuple) ||
-	    pcmcia_get_tuple_data(hw_priv->link, &tuple) ||
-	    pcmcia_parse_tuple(&tuple, parse) ||
-		parse->longlink_mfc.nfn < 2) {
+	if (hw_priv->link->socket->functions < 2) {
 		/* No multi-function links found */
 		ret = -ENODEV;
 		goto done;
@@ -354,7 +336,6 @@ static int sandisk_enable_wireless(struct net_device *dev)
 	udelay(10);
 
 done:
-	kfree(parse);
 	return ret;
 }
 
-- 
1.6.0.4

