From: ravinandan.arakali@neterion.com
Subject: [KJ] [PATCH 2.6.12-rc4-bk1 2/3] S2io: h/w initialization fixes
Date: Tue, 29 Mar 2005 15:10:44 -0800 (PST)
Message-ID: <20050329231044.C429C5BB36@linux.site>
Content-Type: multipart/mixed; boundary="===============32916648661802883=="
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
   leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: jgarzik@pobox.com, netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============32916648661802883==

Hello,
Below patch addresses couple of issues w.r.t h/w initialization.

1. The SWAPPER_CTRL register is now initialized as per recommended
   procedure from h/w team. This register when initialized correctly
   ensures correct access to other registers on big-endian and
   little-endian systems.
2. Enabling the Continuous interrupt feature by default on Tx at
   a rate of 250 interrupts/sec. 

Thanks,
Ravi

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -urN statsfix1/drivers/net/s2io.c hwfixes2/drivers/net/s2io.c
--- statsfix1/drivers/net/s2io.c	2005-03-25 05:53:57.000000000 -0800
+++ hwfixes2/drivers/net/s2io.c	2005-03-25 08:37:33.000000000 -0800
@@ -620,79 +620,15 @@
 	mac_info_t *mac_control;
 	struct config_param *config;
 	int mdio_cnt = 0, dtx_cnt = 0;
-	unsigned long long print_var, mem_share;
+	unsigned long long mem_share;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
-	/* 
-	 * Set proper endian settings and verify the same by 
-	 * reading the PIF Feed-back register.
-	 */
-#ifdef  __BIG_ENDIAN
-	/*
-	 * The device by default set to a big endian format, so 
-	 * a big endian driver need not set anything.
-	 */
-	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
-	val64 = (SWAPPER_CTRL_PIF_R_FE |
-		 SWAPPER_CTRL_PIF_R_SE |
-		 SWAPPER_CTRL_PIF_W_FE |
-		 SWAPPER_CTRL_PIF_W_SE |
-		 SWAPPER_CTRL_TXP_FE |
-		 SWAPPER_CTRL_TXP_SE |
-		 SWAPPER_CTRL_TXD_R_FE |
-		 SWAPPER_CTRL_TXD_W_FE |
-		 SWAPPER_CTRL_TXF_R_FE |
-		 SWAPPER_CTRL_RXD_R_FE |
-		 SWAPPER_CTRL_RXD_W_FE |
-		 SWAPPER_CTRL_RXF_W_FE |
-		 SWAPPER_CTRL_XMSI_FE |
-		 SWAPPER_CTRL_XMSI_SE |
-		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	writeq(val64, &bar0->swapper_ctrl);
-#else
-	/* 
-	 * Initially we enable all bits to make it accessible by 
-	 * the driver, then we selectively enable only those bits 
-	 * that we want to set.
-	 */
-	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
-	val64 = (SWAPPER_CTRL_PIF_R_FE |
-		 SWAPPER_CTRL_PIF_R_SE |
-		 SWAPPER_CTRL_PIF_W_FE |
-		 SWAPPER_CTRL_PIF_W_SE |
-		 SWAPPER_CTRL_TXP_FE |
-		 SWAPPER_CTRL_TXP_SE |
-		 SWAPPER_CTRL_TXD_R_FE |
-		 SWAPPER_CTRL_TXD_R_SE |
-		 SWAPPER_CTRL_TXD_W_FE |
-		 SWAPPER_CTRL_TXD_W_SE |
-		 SWAPPER_CTRL_TXF_R_FE |
-		 SWAPPER_CTRL_RXD_R_FE |
-		 SWAPPER_CTRL_RXD_R_SE |
-		 SWAPPER_CTRL_RXD_W_FE |
-		 SWAPPER_CTRL_RXD_W_SE |
-		 SWAPPER_CTRL_RXF_W_FE |
-		 SWAPPER_CTRL_XMSI_FE |
-		 SWAPPER_CTRL_XMSI_SE |
-		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
-	writeq(val64, &bar0->swapper_ctrl);
-#endif
-
-	/* 
-	 * Verifying if endian settings are accurate by 
-	 * reading a feedback register.
-	 */
-	val64 = readq(&bar0->pif_rd_swapper_fb);
-	if (val64 != 0x0123456789ABCDEFULL) {
-		/* Endian settings are incorrect, calls for another dekko. */
-		print_var = (unsigned long long) val64;
-		DBG_PRINT(INIT_DBG, "%s: Endian settings are wrong",
-			  dev->name);
-		DBG_PRINT(ERR_DBG, ", feedback read %llx\n", print_var);
-
-		return FAILURE;
+	/* Initialize swapper control register */
+	if (s2io_set_swapper(nic)) {
+		DBG_PRINT(ERR_DBG,"ERROR: Setting Swapper failed\n");
+		return -1;
 	}
 
 	/* Remove XGXS from reset state */
@@ -920,11 +856,15 @@
 	 * Initializing the Transmit and Receive Traffic Interrupt 
 	 * Scheme.
 	 */
-	/* TTI Initialization */
-	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |
+	/* TTI Initialization. Default Tx timer gets us about
+	 * 250 interrupts per sec. Continuous interrupts are enabled
+	 * by default.
+	 */
+	val64 = TTI_DATA1_MEM_TX_TIMER_VAL(0x2078) |
 	    TTI_DATA1_MEM_TX_URNG_A(0xA) |
 	    TTI_DATA1_MEM_TX_URNG_B(0x10) |
-	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;
+	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN |
+		TTI_DATA1_MEM_TX_TIMER_CI_EN;
 	writeq(val64, &bar0->tti_data1_mem);
 
 	val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
@@ -2508,23 +2448,74 @@
 {
 	struct net_device *dev = sp->dev;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
-	u64 val64;
+	u64 val64, valt, valr;
 
 	/* 
 	 * Set proper endian settings and verify the same by reading
 	 * the PIF Feed-back register.
 	 */
+
+	val64 = readq(&bar0->pif_rd_swapper_fb);
+	if (val64 != 0x0123456789ABCDEFULL) {
+		int i = 0;
+		u64 value[] = { 0xC30000C3C30000C3ULL,   /* FE=1, SE=1 */
+				0x8100008181000081ULL,  /* FE=1, SE=0 */
+				0x4200004242000042ULL,  /* FE=0, SE=1 */
+				0};                     /* FE=0, SE=0 */
+
+		while(i<4) {
+			writeq(value[i], &bar0->swapper_ctrl);
+			val64 = readq(&bar0->pif_rd_swapper_fb);
+			if (val64 == 0x0123456789ABCDEFULL)
+				break;
+			i++;
+		}
+		if (i == 4) {
+			DBG_PRINT(ERR_DBG, "%s: Endian settings are wrong, ",
+				dev->name);
+			DBG_PRINT(ERR_DBG, "feedback read %llx\n",
+				(unsigned long long) val64);
+			return FAILURE;
+		}
+		valr = value[i];
+	} else {
+		valr = readq(&bar0->swapper_ctrl);
+	}
+
+	valt = 0x0123456789ABCDEFULL;
+	writeq(valt, &bar0->xmsi_address);
+	val64 = readq(&bar0->xmsi_address);
+
+	if(val64 != valt) {
+		int i = 0;
+		u64 value[] = { 0x00C3C30000C3C300ULL,  /* FE=1, SE=1 */
+				0x0081810000818100ULL,  /* FE=1, SE=0 */
+				0x0042420000424200ULL,  /* FE=0, SE=1 */
+				0};                     /* FE=0, SE=0 */
+
+		while(i<4) {
+			writeq((value[i] | valr), &bar0->swapper_ctrl);
+			writeq(valt, &bar0->xmsi_address);
+			val64 = readq(&bar0->xmsi_address);
+			if(val64 == valt)
+				break;
+			i++;
+		}
+		if(i == 4) {
+			DBG_PRINT(ERR_DBG, "Write failed, Xmsi_addr ");
+			DBG_PRINT(ERR_DBG, "reads:0x%llx\n",val64);
+			return FAILURE;
+		}
+	}
+	val64 = readq(&bar0->swapper_ctrl);
+	val64 &= 0xFFFF000000000000ULL;
+
 #ifdef  __BIG_ENDIAN
 	/* 
 	 * The device by default set to a big endian format, so a 
 	 * big endian driver need not set anything.
 	 */
-	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
-	val64 = (SWAPPER_CTRL_PIF_R_FE |
-		 SWAPPER_CTRL_PIF_R_SE |
-		 SWAPPER_CTRL_PIF_W_FE |
-		 SWAPPER_CTRL_PIF_W_SE |
-		 SWAPPER_CTRL_TXP_FE |
+	val64 |= (SWAPPER_CTRL_TXP_FE |
 		 SWAPPER_CTRL_TXP_SE |
 		 SWAPPER_CTRL_TXD_R_FE |
 		 SWAPPER_CTRL_TXD_W_FE |
@@ -2542,12 +2533,7 @@
 	 * driver, then we selectively enable only those bits that 
 	 * we want to set.
 	 */
-	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);
-	val64 = (SWAPPER_CTRL_PIF_R_FE |
-		 SWAPPER_CTRL_PIF_R_SE |
-		 SWAPPER_CTRL_PIF_W_FE |
-		 SWAPPER_CTRL_PIF_W_SE |
-		 SWAPPER_CTRL_TXP_FE |
+	val64 |= (SWAPPER_CTRL_TXP_FE |
 		 SWAPPER_CTRL_TXP_SE |
 		 SWAPPER_CTRL_TXD_R_FE |
 		 SWAPPER_CTRL_TXD_R_SE |
@@ -2564,6 +2550,7 @@
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);
 	writeq(val64, &bar0->swapper_ctrl);
 #endif
+	val64 = readq(&bar0->swapper_ctrl);
 
 	/* 
 	 * Verifying if endian settings are accurate by reading a 
diff -urN statsfix1/drivers/net/s2io.h hwfixes2/drivers/net/s2io.h
--- statsfix1/drivers/net/s2io.h	2005-03-25 05:56:40.000000000 -0800
+++ hwfixes2/drivers/net/s2io.h	2005-03-28 07:16:29.000000000 -0800
@@ -753,6 +753,7 @@
 static int verify_xena_quiescence(u64 val64, int flag);
 static struct ethtool_ops netdev_ethtool_ops;
 static void s2io_set_link(unsigned long data);
+static int s2io_set_swapper(nic_t * sp);
 static void s2io_card_down(nic_t * nic);
 static int s2io_card_up(nic_t * nic);
 

--===============32916648661802883==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============32916648661802883==--
