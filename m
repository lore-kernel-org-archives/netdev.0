From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 7/11 RESEND] cxgb3 - log adapter serial number
Date: Tue, 21 Aug 2007 20:49:36 -0700
Message-ID: <20070822034936.9368.65647.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14048 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252AbXHVDtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Log HW serial number when cxgb3 module is loaded.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    2 ++
 drivers/net/cxgb3/cxgb3_main.c |    6 ++++--
 drivers/net/cxgb3/t3_hw.c      |    3 ++-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 55922ed..d54446f 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -97,6 +97,7 @@ enum {
 	MAX_NPORTS = 2,		/* max # of ports */
 	MAX_FRAME_SIZE = 10240,	/* max MAC frame size, including header + FCS */
 	EEPROMSIZE = 8192,	/* Serial EEPROM size */
+	SERNUM_LEN     = 16,    /* Serial # length */
 	RSS_TABLE_SIZE = 64,	/* size of RSS lookup and mapping tables */
 	TCB_SIZE = 128,		/* TCB size */
 	NMTUS = 16,		/* size of MTU table */
@@ -391,6 +392,7 @@ struct vpd_params {
 	unsigned int uclk;
 	unsigned int mdc;
 	unsigned int mem_timing;
+	u8 sn[SERNUM_LEN + 1];
 	u8 eth_base[6];
 	u8 port_type[MAX_NPORTS];
 	unsigned short xauicfg[2];
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index a1f94cf..e5744e7 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2333,10 +2333,12 @@ static void __devinit print_port_info(struct adapter *adap,
 		       (adap->flags & USING_MSIX) ? " MSI-X" :
 		       (adap->flags & USING_MSI) ? " MSI" : "");
 		if (adap->name == dev->name && adap->params.vpd.mclk)
-			printk(KERN_INFO "%s: %uMB CM, %uMB PMTX, %uMB PMRX\n",
+			printk(KERN_INFO
+			       "%s: %uMB CM, %uMB PMTX, %uMB PMRX, S/N: %s\n",
 			       adap->name, t3_mc7_size(&adap->cm) >> 20,
 			       t3_mc7_size(&adap->pmtx) >> 20,
-			       t3_mc7_size(&adap->pmrx) >> 20);
+			       t3_mc7_size(&adap->pmrx) >> 20,
+			       adap->params.vpd.sn);
 	}
 }
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index dd3149d..23b1a16 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -505,7 +505,7 @@ struct t3_vpd {
 	u8 vpdr_len[2];
 	VPD_ENTRY(pn, 16);	/* part number */
 	VPD_ENTRY(ec, 16);	/* EC level */
-	VPD_ENTRY(sn, 16);	/* serial number */
+	VPD_ENTRY(sn, SERNUM_LEN); /* serial number */
 	VPD_ENTRY(na, 12);	/* MAC address base */
 	VPD_ENTRY(cclk, 6);	/* core clock */
 	VPD_ENTRY(mclk, 6);	/* mem clock */
@@ -648,6 +648,7 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	p->uclk = simple_strtoul(vpd.uclk_data, NULL, 10);
 	p->mdc = simple_strtoul(vpd.mdc_data, NULL, 10);
 	p->mem_timing = simple_strtoul(vpd.mt_data, NULL, 10);
+	memcpy(p->sn, vpd.sn_data, SERNUM_LEN);
 
 	/* Old eeproms didn't have port information */
 	if (adapter->params.rev == 0 && !vpd.port0_data[0]) {
