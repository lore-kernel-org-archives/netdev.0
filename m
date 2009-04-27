From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] 3c589_cs: add cis(firmware) of 3Com multifunction pcmcia
 card
Date: Mon, 27 Apr 2009 21:50:50 +0900
Message-ID: <20090427215050.daeb45fd.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:38806 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbZD0Mv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 08:51:27 -0400
In-Reply-To: <20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3c589_cs,3c574_cs,serial_cs:

 (1)add cis(firmware) of 3Com lan&modem mulitifunction pcmcia card.
 (2)load correct configuration register for 3Com card
 
 
Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
 
---

 drivers/net/pcmcia/3c574_cs.c   |    2 +-
 drivers/net/pcmcia/3c589_cs.c   |    4 ++--
 drivers/serial/serial_cs.c      |   22 +++++++++++++++++-----
 firmware/Makefile               |    2 ++
 firmware/WHENCE                 |   20 ++++++++++++++++++++
 firmware/cis/3CCFEM556.cis.ihex |   13 +++++++++++++
 firmware/cis/3CXEM556.cis.ihex  |   13 +++++++++++++
 7 files changed, 68 insertions(+), 8 deletions(-)

diff -uprN linux-2.6.30-rc3-git1.orig/drivers/net/pcmcia/3c589_cs.c linux-2.6.30-rc3-git1/drivers/net/pcmcia/3c589_cs.c
--- linux-2.6.30-rc3-git1.orig/drivers/net/pcmcia/3c589_cs.c	2009-04-25 14:44:41.000000000 +0900
+++ linux-2.6.30-rc3-git1/drivers/net/pcmcia/3c589_cs.c	2009-04-25 15:07:47.000000000 +0900
@@ -967,8 +967,8 @@ static struct pcmcia_device_id tc589_ids
 	PCMCIA_MFC_DEVICE_PROD_ID1(0, "Motorola MARQUIS", 0xf03e4e77),
 	PCMCIA_DEVICE_MANF_CARD(0x0101, 0x0589),
 	PCMCIA_DEVICE_PROD_ID12("Farallon", "ENet", 0x58d93fc4, 0x992c2202),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x0035, "3CXEM556.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x003d, "3CXEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x0035, "cis/3CXEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x003d, "cis/3CXEM556.cis"),
 	PCMCIA_DEVICE_NULL,
 };
 MODULE_DEVICE_TABLE(pcmcia, tc589_ids);
diff -uprN linux-2.6.30-rc3-git1.orig/drivers/serial/serial_cs.c linux-2.6.30-rc3-git1/drivers/serial/serial_cs.c
--- linux-2.6.30-rc3-git1.orig/drivers/serial/serial_cs.c	2009-03-24 08:12:14.000000000 +0900
+++ linux-2.6.30-rc3-git1/drivers/serial/serial_cs.c	2009-04-25 15:12:19.000000000 +0900
@@ -681,7 +681,7 @@ static int serial_config(struct pcmcia_d
 	u_char *buf;
 	cisparse_t *parse;
 	cistpl_cftable_entry_t *cf;
-	int i;
+	int i, last_ret, last_fn;
 
 	DEBUG(0, "serial_config(0x%p)\n", link);
 
@@ -699,6 +699,16 @@ static int serial_config(struct pcmcia_d
 	tuple->TupleDataMax = 255;
 	tuple->Attributes = 0;
 
+	/* Get configuration register information */
+	tuple->DesiredTuple = CISTPL_CONFIG;
+	last_ret = first_tuple(link, tuple, parse);
+	if (last_ret != 0) {
+		last_fn = ParseTuple;
+		goto cs_failed;
+ 	}
+    	link->conf.ConfigBase = parse->config.base;
+   	link->conf.Present = parse->config.rmask[0];
+
 	/* Is this a compliant multifunction card? */
 	tuple->DesiredTuple = CISTPL_LONGLINK_MFC;
 	tuple->Attributes = TUPLE_RETURN_COMMON | TUPLE_RETURN_LINK;
@@ -761,7 +771,9 @@ static int serial_config(struct pcmcia_d
 	kfree(cfg_mem);
 	return 0;
 
- failed:
+cs_failed:
+	cs_error(link, last_fn, last_ret);
+failed:
 	serial_remove(link);
 	kfree(cfg_mem);
 	return -ENODEV;
@@ -863,10 +875,10 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "PCMLM28.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(1, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(1, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0556, "3CCFEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0556, "cis/3CCFEM556.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0175, 0x0000, "DP83903.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0035, "3CXEM556.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x003d, "3CXEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0035, "cis/3CXEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x003d, "cis/3CXEM556.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC850", 0xd85f6206, 0x42a2c018, "SW_8xx_SER.cis"),  /* Sierra Wireless AC850 3G Network Adapter R1 */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0x0710, "SW_7xx_SER.cis"),	/* Sierra Wireless AC710/AC750 GPRS Network Adapter R1 */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
diff -uprN linux-2.6.30-rc3-git1.orig/firmware/cis/3CCFEM556.cis.ihex linux-2.6.30-rc3-git1/firmware/cis/3CCFEM556.cis.ihex
--- linux-2.6.30-rc3-git1.orig/firmware/cis/3CCFEM556.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.30-rc3-git1/firmware/cis/3CCFEM556.cis.ihex	2009-04-25 14:56:14.000000000 +0900
@@ -0,0 +1,13 @@
+:1000000001030000FF152D050033436F6D004D65A2
+:100010006761686572747A2033434346454D3535D0
+:1000200036004C414E202B2035366B204D6F6465D9
+:100030006D0000FF20040101560521020000060B9F
+:1000400002004D000000006B000000FF001303439E
+:100050004953210206001A060507001067021B0912
+:1000600087011901556430FFFFFF00130343495313
+:10007000210202001A060527001177021B09A701B9
+:090080001901552330FFFFFF00B8
+:00000001FF
+#
+# This card is MFC-compliant, but identifies itself as single function
+#
diff -uprN linux-2.6.30-rc3-git1.orig/firmware/cis/3CXEM556.cis.ihex linux-2.6.30-rc3-git1/firmware/cis/3CXEM556.cis.ihex
--- linux-2.6.30-rc3-git1.orig/firmware/cis/3CXEM556.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.30-rc3-git1/firmware/cis/3CXEM556.cis.ihex	2009-04-25 14:56:14.000000000 +0900
@@ -0,0 +1,13 @@
+:1000000001030000FF152C050033436F6D004D65A3
+:100010006761686572747A20334358454D353536CB
+:10002000004C414E202B2035366B204D6F64656DA2
+:100030000000FF20040101350021020000060B0230
+:10004000004C0000000069000000FF00130343495A
+:1000500053210206001A0501070008631B098701E6
+:100060001901556430FFFFFF001303434953210278
+:1000700002001A0501270009631B09A70119015590
+:060080002330FFFFFF002A
+:00000001FF
+#
+# This card is MFC-compliant, but identifies itself as single function
+#
diff -uprN linux-2.6.30-rc3-git1.orig/firmware/Makefile linux-2.6.30-rc3-git1/firmware/Makefile
--- linux-2.6.30-rc3-git1.orig/firmware/Makefile	2009-04-25 14:45:22.000000000 +0900
+++ linux-2.6.30-rc3-git1/firmware/Makefile	2009-04-25 15:07:09.000000000 +0900
@@ -47,6 +47,8 @@ fw-shipped-$(CONFIG_E100) += e100/d101m_
 			     e100/d102e_ucode.bin
 fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
 fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis
+fw-shipped-$(CONFIG_PCMCIA_3C589) += cis/3CXEM556.cis
+fw-shipped-$(CONFIG_PCMCIA_3C574) += cis/3CCFEM556.cis
 fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
 fw-shipped-$(CONFIG_SCSI_ADVANSYS) += advansys/mcode.bin advansys/38C1600.bin \
 				      advansys/3550.bin advansys/38C0800.bin
diff -uprN linux-2.6.30-rc3-git1.orig/firmware/WHENCE linux-2.6.30-rc3-git1/firmware/WHENCE
--- linux-2.6.30-rc3-git1.orig/firmware/WHENCE	2009-04-25 14:45:22.000000000 +0900
+++ linux-2.6.30-rc3-git1/firmware/WHENCE	2009-04-25 15:06:07.000000000 +0900
@@ -586,6 +586,26 @@ Originally developed by the pcmcia-cs pr
 
 --------------------------------------------------------------------------
 
+Driver: PCMCIA_3C589 - 3Com PCMCIA adapter
+
+File: cis/3CXEM556.cis
+
+Licence: GPL
+
+Originally developed by the pcmcia-cs project
+
+--------------------------------------------------------------------------
+
+Driver: PCMCIA_3C574 - 3Com PCMCIA adapter
+
+File: cis/3CCFEM556.cis
+
+Licence: GPL
+
+Originally developed by the pcmcia-cs project
+
+--------------------------------------------------------------------------
+
 Driver: PCMCIA_SMC91C92 - SMC 91Cxx PCMCIA
 
 File: ositech/Xilinx7OD.bin

diff -uprN linux-2.6.30-rc3-git1.orig/drivers/net/pcmcia/3c574_cs.c linux-2.6.30-rc3-git1/drivers/net/pcmcia/3c574_cs.c
--- linux-2.6.30-rc3-git1.orig/drivers/net/pcmcia/3c574_cs.c	2009-04-26 07:50:02.000000000 +0900
+++ linux-2.6.30-rc3-git1/drivers/net/pcmcia/3c574_cs.c	2009-04-26 07:58:23.000000000 +0900
@@ -1195,7 +1195,7 @@ static int el3_close(struct net_device *
 
 static struct pcmcia_device_id tc574_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x0101, 0x0574),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x0556, "3CCFEM556.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0101, 0x0556, "cis/3CCFEM556.cis"),
 	PCMCIA_DEVICE_NULL,
 };
 MODULE_DEVICE_TABLE(pcmcia, tc574_ids);
