From: divy@chelsio.com
Subject: [PATCH 4/7] cxgb3 - Update FW to 4.1
Date: Sat, 26 May 2007 16:00:04 -0700
Message-ID: <20070526230003.12156.10521.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11866 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375AbXEZXAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 19:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Bump FW version to 4.1.
Modify chip tuning in consequence.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/regs.h    |    4 ++++
 drivers/net/cxgb3/t3_hw.c   |   42 +++++++++++++++++++++++-------------------
 drivers/net/cxgb3/version.h |    2 +-
 3 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index bf9d6be..2c47d4a 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1160,6 +1160,8 @@
 
 #define A_TP_MOD_CHANNEL_WEIGHT 0x434
 
+#define A_TP_MOD_RATE_LIMIT 0x438
+
 #define A_TP_PIO_ADDR 0x440
 
 #define A_TP_PIO_DATA 0x444
@@ -1214,6 +1216,8 @@
 #define G_TXDROPCNTCH0RCVD(x) (((x) >> S_TXDROPCNTCH0RCVD) & \
 			       M_TXDROPCNTCH0RCVD)
 
+#define A_TP_PROXY_FLOW_CNTL 0x4b0
+
 #define A_ULPRX_CTL 0x500
 
 #define S_ROUND_ROBIN    4
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index fb485d0..9e3591d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -921,7 +921,7 @@ static int t3_flash_erase_sectors(struct
 /*
  *	t3_load_fw - download firmware
  *	@adapter: the adapter
- *	@fw_data: the firrware image to write
+ *	@fw_data: the firmware image to write
  *	@size: image size
  *
  *	Write the supplied firmware image to the card's serial flash.
@@ -2362,7 +2362,7 @@ static void tp_config(struct adapter *ad
 		     F_TCPCHECKSUMOFFLOAD | V_IPTTL(64));
 	t3_write_reg(adap, A_TP_TCP_OPTIONS, V_MTUDEFAULT(576) |
 		     F_MTUENABLE | V_WINDOWSCALEMODE(1) |
-		     V_TIMESTAMPSMODE(1) | V_SACKMODE(1) | V_SACKRX(1));
+		     V_TIMESTAMPSMODE(0) | V_SACKMODE(1) | V_SACKRX(1));
 	t3_write_reg(adap, A_TP_DACK_CONFIG, V_AUTOSTATE3(1) |
 		     V_AUTOSTATE2(1) | V_AUTOSTATE1(0) |
 		     V_BYTETHRESHOLD(16384) | V_MSSTHRESHOLD(2) |
@@ -2371,16 +2371,18 @@ static void tp_config(struct adapter *ad
 			 F_IPV6ENABLE | F_NICMODE);
 	t3_write_reg(adap, A_TP_TX_RESOURCE_LIMIT, 0x18141814);
 	t3_write_reg(adap, A_TP_PARA_REG4, 0x5050105);
-	t3_set_reg_field(adap, A_TP_PARA_REG6,
-			 adap->params.rev > 0 ? F_ENABLEESND : F_T3A_ENABLEESND,
-			 0);
+	t3_set_reg_field(adap, A_TP_PARA_REG6, 0,
+			 adap->params.rev > 0 ? F_ENABLEESND :
+			 F_T3A_ENABLEESND);
 
 	t3_set_reg_field(adap, A_TP_PC_CONFIG,
-			 F_ENABLEEPCMDAFULL | F_ENABLEOCSPIFULL,
-			 F_TXDEFERENABLE | F_HEARBEATDACK | F_TXCONGESTIONMODE |
-			 F_RXCONGESTIONMODE);
+			 F_ENABLEEPCMDAFULL,
+			 F_ENABLEOCSPIFULL |F_TXDEFERENABLE | F_HEARBEATDACK |
+			 F_TXCONGESTIONMODE | F_RXCONGESTIONMODE);
 	t3_set_reg_field(adap, A_TP_PC_CONFIG2, F_CHDRAFULL, 0);
-
+	t3_write_reg(adap, A_TP_PROXY_FLOW_CNTL, 1080);
+	t3_write_reg(adap, A_TP_PROXY_FLOW_CNTL, 1000);
+	
 	if (adap->params.rev > 0) {
 		tp_wr_indirect(adap, A_TP_EGRESS_CONFIG, F_REWRITEFORCETOSIZE);
 		t3_set_reg_field(adap, A_TP_PARA_REG3, F_TXPACEAUTO,
@@ -2390,9 +2392,10 @@ static void tp_config(struct adapter *ad
 	} else
 		t3_set_reg_field(adap, A_TP_PARA_REG3, 0, F_TXPACEFIXED);
 
-	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT1, 0x12121212);
-	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT0, 0x12121212);
-	t3_write_reg(adap, A_TP_MOD_CHANNEL_WEIGHT, 0x1212);
+	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT1, 0);
+	t3_write_reg(adap, A_TP_TX_MOD_QUEUE_WEIGHT0, 0);
+	t3_write_reg(adap, A_TP_MOD_CHANNEL_WEIGHT, 0);
+	t3_write_reg(adap, A_TP_MOD_RATE_LIMIT, 0xf2200000);
 }
 
 /* Desired TP timer resolution in usec */
@@ -2468,6 +2471,7 @@ int t3_tp_set_coalescing_size(struct ada
 		val |= F_RXCOALESCEENABLE;
 		if (psh)
 			val |= F_RXCOALESCEPSHEN;
+		size = min(MAX_RX_COALESCING_LEN, size);
 		t3_write_reg(adap, A_TP_PARA_REG2, V_RXCOALESCESIZE(size) |
 			     V_MAXRXDATA(MAX_RX_COALESCING_LEN));
 	}
@@ -2496,11 +2500,11 @@ static void __devinit init_mtus(unsigned
 	 * it can accomodate max size TCP/IP headers when SACK and timestamps
 	 * are enabled and still have at least 8 bytes of payload.
 	 */
-	mtus[0] = 88;
-	mtus[1] = 256;
-	mtus[2] = 512;
-	mtus[3] = 576;
-	mtus[4] = 808;
+	mtus[1] = 88;
+	mtus[1] = 88;
+	mtus[2] = 256;
+	mtus[3] = 512;
+	mtus[4] = 576;
 	mtus[5] = 1024;
 	mtus[6] = 1280;
 	mtus[7] = 1492;
@@ -2802,7 +2806,7 @@ static void init_hw_for_avail_ports(stru
 		t3_set_reg_field(adap, A_ULPTX_CONFIG, F_CFG_RR_ARB, 0);
 		t3_write_reg(adap, A_MPS_CFG, F_TPRXPORTEN | F_TPTXPORT0EN |
 			     F_PORT0ACTIVE | F_ENFORCEPKT);
-		t3_write_reg(adap, A_PM1_TX_CFG, 0xc000c000);
+		t3_write_reg(adap, A_PM1_TX_CFG, 0xffffffff);
 	} else {
 		t3_set_reg_field(adap, A_ULPRX_CTL, 0, F_ROUND_ROBIN);
 		t3_set_reg_field(adap, A_ULPTX_CONFIG, 0, F_CFG_RR_ARB);
@@ -3097,7 +3101,7 @@ int t3_init_hw(struct adapter *adapter,
 	else
 		t3_set_reg_field(adapter, A_PCIX_CFG, 0, F_CLIDECEN);
 
-	t3_write_reg(adapter, A_PM1_RX_CFG, 0xf000f000);
+	t3_write_reg(adapter, A_PM1_RX_CFG, 0xffffffff);
 	init_hw_for_avail_ports(adapter, adapter->params.nports);
 	t3_sge_init(adapter, &adapter->params.sge);
 
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index b112317..8eddd23 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -39,6 +39,6 @@
 
 /* Firmware version */
 #define FW_VERSION_MAJOR 4
-#define FW_VERSION_MINOR 0
+#define FW_VERSION_MINOR 1
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
