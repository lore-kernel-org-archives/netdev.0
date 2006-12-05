From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 3/9] pcmcia: remove manf_id and card_id indirection
Date: Mon, 4 Dec 2006 21:09:36 -0500
Message-ID: <20061205020936.GD2624@dominikbrodowski.de>
References: <20061205015942.GA2624@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org
Return-path: <linux-serial-owner@vger.kernel.org>
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20061205015942.GA2624@dominikbrodowski.de>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Wed, 25 Oct 2006 21:28:53 -0400
Subject: [PATCH] pcmcia: remove manf_id and card_id indirection

As we read out the manufactor and card_id from the PCMCIA device in the
PCMCIA core, and device drivers can access those reliably in struct
pcmcia_device's fields manf_id and card_id, remove additional (and partly
broken) manf_id and card_id detection logic from PCMCIA device drivers.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/ata/pata_pcmcia.c               |    6 +++---
 drivers/ide/legacy/ide-cs.c             |   10 +++-------
 drivers/net/pcmcia/3c589_cs.c           |   12 ++++--------
 drivers/net/pcmcia/fmvj18x_cs.c         |   26 ++++++++------------------
 drivers/net/pcmcia/pcnet_cs.c           |   22 +++++++---------------
 drivers/net/pcmcia/smc91c92_cs.c        |    8 ++------
 drivers/net/wireless/hostap/hostap_cs.c |    7 ++-----
 drivers/scsi/pcmcia/qlogic_stub.c       |    4 +---
 drivers/scsi/pcmcia/sym53c500_cs.c      |    5 +----
 drivers/serial/serial_cs.c              |   30 ++++++++++++++----------------
 10 files changed, 45 insertions(+), 85 deletions(-)

diff --git a/drivers/ata/pata_pcmcia.c b/drivers/ata/pata_pcmcia.c
index 3ce33bf..da7c218 100644
--- a/drivers/ata/pata_pcmcia.c
+++ b/drivers/ata/pata_pcmcia.c
@@ -164,9 +164,9 @@ static int pcmcia_init_one(struct pcmcia
 
 	/* See if we have a manufacturer identifier. Use it to set is_kme for
 	   vendor quirks */
-	tuple.DesiredTuple = CISTPL_MANFID;
-	if (!pcmcia_get_first_tuple(pdev, &tuple) && !pcmcia_get_tuple_data(pdev, &tuple) && !pcmcia_parse_tuple(pdev, &tuple, &stk->parse))
-			is_kme = ((stk->parse.manfid.manf == MANFID_KME) && ((stk->parse.manfid.card == PRODID_KME_KXLC005_A) || (stk->parse.manfid.card == PRODID_KME_KXLC005_B)));
+	is_kme = ((pdev->manf_id == MANFID_KME) &&
+		  ((pdev->card_id == PRODID_KME_KXLC005_A) ||
+		   (pdev->card_id == PRODID_KME_KXLC005_B)));
 
 	/* Not sure if this is right... look up the current Vcc */
 	CS_CHECK(GetConfigurationInfo, pcmcia_get_configuration_info(pdev, &stk->conf));
diff --git a/drivers/ide/legacy/ide-cs.c b/drivers/ide/legacy/ide-cs.c
index 7e8d778..1b996e6 100644
--- a/drivers/ide/legacy/ide-cs.c
+++ b/drivers/ide/legacy/ide-cs.c
@@ -199,13 +199,9 @@ static int ide_config(struct pcmcia_devi
     link->conf.ConfigBase = stk->parse.config.base;
     link->conf.Present = stk->parse.config.rmask[0];
 
-    tuple.DesiredTuple = CISTPL_MANFID;
-    if (!pcmcia_get_first_tuple(link, &tuple) &&
-	!pcmcia_get_tuple_data(link, &tuple) &&
-	!pcmcia_parse_tuple(link, &tuple, &stk->parse))
-	is_kme = ((stk->parse.manfid.manf == MANFID_KME) &&
-		  ((stk->parse.manfid.card == PRODID_KME_KXLC005_A) ||
-		   (stk->parse.manfid.card == PRODID_KME_KXLC005_B)));
+    is_kme = ((link->manf_id == MANFID_KME) &&
+	      ((link->card_id == PRODID_KME_KXLC005_A) ||
+	       (link->card_id == PRODID_KME_KXLC005_B)));
 
     /* Not sure if this is right... look up the current Vcc */
     CS_CHECK(GetConfigurationInfo, pcmcia_get_configuration_info(link, &stk->conf));
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 231fa2c..eb57832 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -272,17 +272,13 @@ static int tc589_config(struct pcmcia_de
     CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
     link->conf.ConfigBase = parse.config.base;
     link->conf.Present = parse.config.rmask[0];
-    
-    /* Is this a 3c562? */
-    tuple.DesiredTuple = CISTPL_MANFID;
     tuple.Attributes = TUPLE_RETURN_COMMON;
-    if ((pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) &&
-	(pcmcia_get_tuple_data(link, &tuple) == CS_SUCCESS)) {
-	if (le16_to_cpu(buf[0]) != MANFID_3COM)
+
+    /* Is this a 3c562? */
+    if (link->manf_id != MANFID_3COM)
 	    printk(KERN_INFO "3c589_cs: hmmm, is this really a "
 		   "3Com card??\n");
-	multi = (le16_to_cpu(buf[1]) == PRODID_3COM_3C562);
-    }
+    multi = (link->card_id == PRODID_3COM_3C562);
 
     /* For the 3c562, the base address must be xx00-xx7f */
     link->io.IOAddrLines = 16;
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 65f6fdf..e3731fd 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -374,17 +374,12 @@ static int fmvj18x_config(struct pcmcia_
 	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
 	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
 	link->conf.ConfigIndex = parse.cftable_entry.index;
-	tuple.DesiredTuple = CISTPL_MANFID;
-	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS)
-	    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	else
-	    buf[0] = 0xffff;
-	switch (le16_to_cpu(buf[0])) {
+	switch (link->manf_id) {
 	case MANFID_TDK:
 	    cardtype = TDK;
-	    if (le16_to_cpu(buf[1]) == PRODID_TDK_GN3410
-			|| le16_to_cpu(buf[1]) == PRODID_TDK_NP9610
-			|| le16_to_cpu(buf[1]) == PRODID_TDK_MN3200) {
+	    if (link->card_id == PRODID_TDK_GN3410
+			|| link->card_id == PRODID_TDK_NP9610
+			|| link->card_id == PRODID_TDK_MN3200) {
 		/* MultiFunction Card */
 		link->conf.ConfigBase = 0x800;
 		link->conf.ConfigIndex = 0x47;
@@ -395,11 +390,11 @@ static int fmvj18x_config(struct pcmcia_
 	    cardtype = CONTEC;
 	    break;
 	case MANFID_FUJITSU:
-	    if (le16_to_cpu(buf[1]) == PRODID_FUJITSU_MBH10302)
+	    if (link->card_id == PRODID_FUJITSU_MBH10302)
                 /* RATOC REX-5588/9822/4886's PRODID are 0004(=MBH10302),
                    but these are MBH10304 based card. */ 
 		cardtype = MBH10304;
-	    else if (le16_to_cpu(buf[1]) == PRODID_FUJITSU_MBH10304)
+	    else if (link->card_id == PRODID_FUJITSU_MBH10304)
 		cardtype = MBH10304;
 	    else
 		cardtype = LA501;
@@ -409,14 +404,9 @@ static int fmvj18x_config(struct pcmcia_
 	}
     } else {
 	/* old type card */
-	tuple.DesiredTuple = CISTPL_MANFID;
-	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS)
-	    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
-	else
-	    buf[0] = 0xffff;
-	switch (le16_to_cpu(buf[0])) {
+	switch (link->manf_id) {
 	case MANFID_FUJITSU:
-	    if (le16_to_cpu(buf[1]) == PRODID_FUJITSU_MBH10304) {
+	    if (link->card_id == PRODID_FUJITSU_MBH10304) {
 		cardtype = XXX10304;    /* MBH10304 with buggy CIS */
 	        link->conf.ConfigIndex = 0x20;
 	    } else {
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index c51cc5d..430a41e 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -519,7 +519,7 @@ static int pcnet_config(struct pcmcia_de
     tuple_t tuple;
     cisparse_t parse;
     int i, last_ret, last_fn, start_pg, stop_pg, cm_offset;
-    int manfid = 0, prodid = 0, has_shmem = 0;
+    int has_shmem = 0;
     u_short buf[64];
     hw_info_t *hw_info;
 
@@ -536,14 +536,6 @@ static int pcnet_config(struct pcmcia_de
     link->conf.ConfigBase = parse.config.base;
     link->conf.Present = parse.config.rmask[0];
 
-    tuple.DesiredTuple = CISTPL_MANFID;
-    tuple.Attributes = TUPLE_RETURN_COMMON;
-    if ((pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) &&
- 	(pcmcia_get_tuple_data(link, &tuple) == CS_SUCCESS)) {
-	manfid = le16_to_cpu(buf[0]);
-	prodid = le16_to_cpu(buf[1]);
-    }
-
     tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
     tuple.Attributes = 0;
     CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
@@ -589,8 +581,8 @@ static int pcnet_config(struct pcmcia_de
 	link->conf.Attributes |= CONF_ENABLE_SPKR;
 	link->conf.Status = CCSR_AUDIO_ENA;
     }
-    if ((manfid == MANFID_IBM) &&
-	(prodid == PRODID_IBM_HOME_AND_AWAY))
+    if ((link->manf_id == MANFID_IBM) &&
+	(link->card_id == PRODID_IBM_HOME_AND_AWAY))
 	link->conf.ConfigIndex |= 0x10;
 
     CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
@@ -624,10 +616,10 @@ static int pcnet_config(struct pcmcia_de
     info->flags = hw_info->flags;
     /* Check for user overrides */
     info->flags |= (delay_output) ? DELAY_OUTPUT : 0;
-    if ((manfid == MANFID_SOCKET) &&
-	((prodid == PRODID_SOCKET_LPE) ||
-	 (prodid == PRODID_SOCKET_LPE_CF) ||
-	 (prodid == PRODID_SOCKET_EIO)))
+    if ((link->manf_id == MANFID_SOCKET) &&
+	((link->card_id == PRODID_SOCKET_LPE) ||
+	 (link->card_id == PRODID_SOCKET_LPE_CF) ||
+	 (link->card_id == PRODID_SOCKET_EIO)))
 	info->flags &= ~USE_BIG_BUF;
     if (!use_big_buf)
 	info->flags &= ~USE_BIG_BUF;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 20fcc35..ae024bf 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -999,12 +999,8 @@ static int smc91c92_config(struct pcmcia
     link->conf.ConfigBase = parse->config.base;
     link->conf.Present = parse->config.rmask[0];
 
-    tuple->DesiredTuple = CISTPL_MANFID;
-    tuple->Attributes = TUPLE_RETURN_COMMON;
-    if (first_tuple(link, tuple, parse) == CS_SUCCESS) {
-	smc->manfid = parse->manfid.manf;
-	smc->cardid = parse->manfid.card;
-    }
+    smc->manfid = link->manf_id;
+    smc->cardid = link->card_id;
 
     if ((smc->manfid == MANFID_OSITECH) &&
 	(smc->cardid != PRODID_OSITECH_SEVEN)) {
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index f63909e..8a7984b 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -293,15 +293,12 @@ static int sandisk_enable_wireless(struc
 		goto done;
 	}
 
-	tuple.DesiredTuple = CISTPL_MANFID;
 	tuple.Attributes = TUPLE_RETURN_COMMON;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
-	if (pcmcia_get_first_tuple(hw_priv->link, &tuple) ||
-	    pcmcia_get_tuple_data(hw_priv->link, &tuple) ||
-	    pcmcia_parse_tuple(hw_priv->link, &tuple, parse) ||
-	    parse->manfid.manf != 0xd601 || parse->manfid.card != 0x0101) {
+
+	if (hw_priv->link->manf_id != 0xd601 || hw_priv->link->card_id != 0x0101) {
 		/* No SanDisk manfid found */
 		ret = -ENODEV;
 		goto done;
diff --git a/drivers/scsi/pcmcia/qlogic_stub.c b/drivers/scsi/pcmcia/qlogic_stub.c
index 86c2ac6..336e370 100644
--- a/drivers/scsi/pcmcia/qlogic_stub.c
+++ b/drivers/scsi/pcmcia/qlogic_stub.c
@@ -217,9 +217,7 @@ static int qlogic_config(struct pcmcia_d
 	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
 	link->conf.ConfigBase = parse.config.base;
 
-	tuple.DesiredTuple = CISTPL_MANFID;
-	if ((pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) && (pcmcia_get_tuple_data(link, &tuple) == CS_SUCCESS))
-		info->manf_id = le16_to_cpu(tuple.TupleData[0]);
+	info->manf_id = link->manf_id;
 
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/scsi/pcmcia/sym53c500_cs.c b/drivers/scsi/pcmcia/sym53c500_cs.c
index 72fe5d0..80c28b9 100644
--- a/drivers/scsi/pcmcia/sym53c500_cs.c
+++ b/drivers/scsi/pcmcia/sym53c500_cs.c
@@ -731,10 +731,7 @@ SYM53C500_config(struct pcmcia_device *l
 	CS_CHECK(ParseTuple, pcmcia_parse_tuple(link, &tuple, &parse));
 	link->conf.ConfigBase = parse.config.base;
 
-	tuple.DesiredTuple = CISTPL_MANFID;
-	if ((pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS) &&
-	    (pcmcia_get_tuple_data(link, &tuple) == CS_SUCCESS))
-		info->manf_id = le16_to_cpu(tuple.TupleData[0]);
+	info->manf_id = link->manf_id;
 
 	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
 	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
diff --git a/drivers/serial/serial_cs.c b/drivers/serial/serial_cs.c
index 783b0c5..7aa2820 100644
--- a/drivers/serial/serial_cs.c
+++ b/drivers/serial/serial_cs.c
@@ -757,27 +757,25 @@ static int serial_config(struct pcmcia_d
 
 	/* Is this a multiport card? */
 	tuple->DesiredTuple = CISTPL_MANFID;
-	if (first_tuple(link, tuple, parse) == CS_SUCCESS) {
-		info->manfid = parse->manfid.manf;
-		info->prodid = parse->manfid.card;
-
-		for (i = 0; i < ARRAY_SIZE(quirks); i++)
-			if ((quirks[i].manfid == ~0 ||
-			     quirks[i].manfid == info->manfid) &&
-			    (quirks[i].prodid == ~0 ||
-			     quirks[i].prodid == info->prodid)) {
-				info->quirk = &quirks[i];
-				break;
-			}
-	}
+	info->manfid = link->manf_id;
+	info->prodid = link->card_id;
+
+	for (i = 0; i < ARRAY_SIZE(quirks); i++)
+		if ((quirks[i].manfid == ~0 ||
+		     quirks[i].manfid == info->manfid) &&
+		    (quirks[i].prodid == ~0 ||
+		     quirks[i].prodid == info->prodid)) {
+			info->quirk = &quirks[i];
+			break;
+		}
 
 	/* Another check for dual-serial cards: look for either serial or
 	   multifunction cards that ask for appropriate IO port ranges */
 	tuple->DesiredTuple = CISTPL_FUNCID;
 	if ((info->multi == 0) &&
-	    ((first_tuple(link, tuple, parse) != CS_SUCCESS) ||
-	     (parse->funcid.func == CISTPL_FUNCID_MULTI) ||
-	     (parse->funcid.func == CISTPL_FUNCID_SERIAL))) {
+	    (link->has_func_id) &&
+	    ((link->func_id == CISTPL_FUNCID_MULTI) ||
+	     (link->func_id == CISTPL_FUNCID_SERIAL))) {
 		tuple->DesiredTuple = CISTPL_CFTABLE_ENTRY;
 		if (first_tuple(link, tuple, parse) == CS_SUCCESS) {
 			if ((cf->io.nwin == 1) && (cf->io.win[0].len % 8 == 0))
-- 
1.4.4

