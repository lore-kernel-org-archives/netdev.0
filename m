From: akpm@osdl.org
Subject: [patch 06/13] ppc 8260 fcc ethernet driver cannot read LXT971 PHY id
Date: Tue, 15 Mar 2005 14:22:43 -0800
Message-ID: <200503152222.j2FMMccq016808@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, oray@lucent.com
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "Balasaygun, Oray (Oray)" <oray@lucent.com>

- fix for Bug 4310

- The fcc_enet.c, as distributed in 2.6.10, does not compile.  Evidently
  the 2.6 kernel no longer supports the schedule_task() and "struct
  tq_struct" to go with it.  Lines 73 through and including 96 of the
  diffout file show the changes I made to port schedule_task() into
  tasklet_schedule().  I should have reported this as a bug too but I
  forgot about it.

- customize fcc_enet.c to work with my custom board.  These changes are
  conditional on CONFIG_EON8260 being defined.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/ppc/8260_io/fcc_enet.c |   91 ++++++++++++++++++++++++++++++------
 1 files changed, 78 insertions(+), 13 deletions(-)

diff -puN arch/ppc/8260_io/fcc_enet.c~ppc-8260-fcc-ethernet-driver-cannot-read-lxt971-phy-id arch/ppc/8260_io/fcc_enet.c
--- 25/arch/ppc/8260_io/fcc_enet.c~ppc-8260-fcc-ethernet-driver-cannot-read-lxt971-phy-id	Tue Mar 15 14:19:53 2005
+++ 25-akpm/arch/ppc/8260_io/fcc_enet.c	Tue Mar 15 14:19:53 2005
@@ -177,6 +177,54 @@ static int fcc_enet_set_mac_address(stru
 #define CMX1_CLK_MASK	((uint)0xff000000)
 #endif
 
+#ifdef CONFIG_EON8260
+
+#define MAKE_BITMASK(n) (1 << (31-n))
+
+#define PA8  MAKE_BITMASK(8)
+#define PA9  MAKE_BITMASK(9)
+
+#define PB18 MAKE_BITMASK(18)
+#define PB19 MAKE_BITMASK(19)
+#define PB20 MAKE_BITMASK(20)
+#define PB21 MAKE_BITMASK(21)
+#define PB22 MAKE_BITMASK(22)
+#define PB23 MAKE_BITMASK(23)
+#define PB24 MAKE_BITMASK(24)
+#define PB25 MAKE_BITMASK(25)
+#define PB26 MAKE_BITMASK(26)
+#define PB27 MAKE_BITMASK(27)
+#define PB28 MAKE_BITMASK(28)
+#define PB29 MAKE_BITMASK(29)
+#define PB30 MAKE_BITMASK(30)
+#define PB31 MAKE_BITMASK(31)
+
+#define PB2_TXER        PB31
+#define PB2_RXDV        PB30
+#define PB2_TXEN        PB29
+#define PB2_RXER        PB28
+#define PB2_COL         PB27
+#define PB2_CRS         PB26
+#define PB2_TXDAT       (PB22 | PB23 | PB24 | PB25)
+#define PB2_RXDAT       (PB18 | PB19 | PB20 | PB21)
+#define PB2_PSORB0      (PB2_RXDAT | PB2_TXDAT | PB2_CRS | PB2_COL | \
+                                PB2_RXER | PB2_RXDV | PB2_TXER)
+#define PB2_PSORB1      (PB2_TXEN)
+#define PB2_DIRB0       (PB2_RXDAT | PB2_CRS | PB2_COL | PB2_RXER | PB2_RXDV)
+#define PB2_DIRB1       (PB2_TXDAT | PB2_TXEN | PB2_TXER)
+
+/* CLK16 (PC16) is receive, CLK15 (PC17) is transmit */
+
+#define PC_F2RXCLK      ((uint)0x00008000)
+#define PC_F2TXCLK      ((uint)0x00004000)
+
+#define CMXFCR_TF2CS_CLK15 0x00060000   /* Transmit FCC2 Clock Source is CLK15 */
+#define CMXFCR_RF2CS_CLK16 0x00380000   /*  Receive FCC2 Clock Source is CLK16 */
+#define CMX2_CLK_ROUTE  (CMXFCR_RF2CS_CLK16 | CMXFCR_TF2CS_CLK15)
+#define CMX2_CLK_MASK   ((uint)0x00ff0000)
+
+#else /* #ifdef CONFIG_EON8260 */
+
 /* I/O Pin assignment for FCC2.  I don't yet know the best way to do this,
  * but there is little variation among the choices.
  */
@@ -208,6 +256,8 @@ static int fcc_enet_set_mac_address(stru
 #define CMX2_CLK_MASK	((uint)0x00ff0000)
 #endif
 
+#endif /* #ifdef CONFIG_EON8260 */
+
 /* I/O Pin assignment for FCC3.  I don't yet know the best way to do this,
  * but there is little variation among the choices.
  */
@@ -234,7 +284,11 @@ static int fcc_enet_set_mac_address(stru
 
 /* MII status/control serial interface.
 */
-#ifdef	CONFIG_TQM8260
+#if defined (CONFIG_EON8260)
+/* EON8260 has MDIO and MDCK on PC31 and PC30 respectively */
+#define PC_MDIO         ((uint)0x00000001)
+#define PC_MDCK         ((uint)0x00000002)
+#elif defined (CONFIG_TQM8260)
 /* TQM8260 has MDIO and MDCK on PC30 and PC31 respectively */
 #define PC_MDIO		((uint)0x00000002)
 #define PC_MDCK		((uint)0x00000001)
@@ -268,7 +322,7 @@ static fcc_info_t fcc_ports[] = {
 #ifdef CONFIG_FCC1_ENET
 	{ 0, CPM_CR_FCC1_SBLOCK, CPM_CR_FCC1_PAGE, PROFF_FCC1, SIU_INT_FCC1,
 		(PC_F1RXCLK | PC_F1TXCLK), CMX1_CLK_ROUTE, CMX1_CLK_MASK,
-# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)
+# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || defined(CONFIG_EON8260)
 		PC_MDIO, PC_MDCK },
 # else
 		0x00000004, 0x00000100 },
@@ -277,7 +331,7 @@ static fcc_info_t fcc_ports[] = {
 #ifdef CONFIG_FCC2_ENET
 	{ 1, CPM_CR_FCC2_SBLOCK, CPM_CR_FCC2_PAGE, PROFF_FCC2, SIU_INT_FCC2,
 		(PC_F2RXCLK | PC_F2TXCLK), CMX2_CLK_ROUTE, CMX2_CLK_MASK,
-# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)
+# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || defined(CONFIG_EON8260)
 		PC_MDIO, PC_MDCK },
 # elif defined(CONFIG_EST8260) || defined(CONFIG_ADS8260)
 		0x00400000, 0x00200000 },
@@ -288,7 +342,7 @@ static fcc_info_t fcc_ports[] = {
 #ifdef CONFIG_FCC3_ENET
 	{ 2, CPM_CR_FCC3_SBLOCK, CPM_CR_FCC3_PAGE, PROFF_FCC3, SIU_INT_FCC3,
 		(PC_F3RXCLK | PC_F3TXCLK), CMX3_CLK_ROUTE, CMX3_CLK_MASK,
-# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272)
+# if defined(CONFIG_TQM8260) || defined(CONFIG_ADS8272) || defined(CONFIG_EON8260)
 		PC_MDIO, PC_MDCK },
 # else
 		0x00000001, 0x00000040 },
@@ -329,7 +383,7 @@ struct fcc_enet_private {
 	uint	phy_id_done;
 	uint	phy_status;
 	phy_info_t	*phy;
-	struct tq_struct phy_task;
+	struct tasklet_struct phy_task;
 
 	uint	sequence_done;
 
@@ -1191,8 +1245,9 @@ static void mii_display_status(struct ne
 	printk(".\n");
 }
 
-static void mii_display_config(struct net_device *dev)
+static void mii_display_config(unsigned long arg)
 {
+	struct net_device *dev = (struct net_device *)arg;
 	volatile struct fcc_enet_private *fep = dev->priv;
 	uint s = fep->phy_status;
 
@@ -1222,8 +1277,9 @@ static void mii_display_config(struct ne
 	fep->sequence_done = 1;
 }
 
-static void mii_relink(struct net_device *dev)
+static void mii_relink(unsigned long arg)
 {
+	struct net_device *dev = (struct net_device *)arg;
 	struct fcc_enet_private *fep = dev->priv;
 	int duplex;
 
@@ -1246,18 +1302,18 @@ static void mii_queue_relink(uint mii_re
 {
 	struct fcc_enet_private *fep = dev->priv;
 
-	fep->phy_task.routine = (void *)mii_relink;
+	fep->phy_task.func = mii_relink;
 	fep->phy_task.data = dev;
-	schedule_task(&fep->phy_task);
+	tasklet_schedule(&fep->phy_task);
 }
 
 static void mii_queue_config(uint mii_reg, struct net_device *dev)
 {
 	struct fcc_enet_private *fep = dev->priv;
 
-	fep->phy_task.routine = (void *)mii_display_config;
+	fep->phy_task.func = mii_display_config;
 	fep->phy_task.data = dev;
-	schedule_task(&fep->phy_task);
+	tasklet_schedule(&fep->phy_task);
 }
 
 
@@ -1464,6 +1520,9 @@ static int __init fec_enet_init(void)
 			return -ENOMEM;
 
 		cep = dev->priv;
+		cep->phy_task.next = NULL;
+		cep->phy_task.state = 0;
+		cep->phy_task.count.counter = 0;
 		spin_lock_init(&cep->lock);
 		cep->fip = fip;
 
@@ -1698,6 +1757,11 @@ init_fcc_param(fcc_info_t *fip, struct n
 	 * non-static part of the address.
 	 */
 	eap = (unsigned char *)&(ep->fen_paddrh);
+#if defined(CONFIG_EON8260)
+        for (i = 5; i >=0 ; i--) {
+                *eap++ = dev->dev_addr[i] = bd->bi_enetaddr[i];
+        }
+#else   /* if defined(CONFIG_EON8260) */
 	for (i=5; i>=0; i--) {
 #ifdef CONFIG_SBC82xx
 		if (i == 5) {
@@ -1718,6 +1782,7 @@ init_fcc_param(fcc_info_t *fip, struct n
 			*eap++ = dev->dev_addr[i] = bd->bi_enetaddr[i];
 		}
 	}
+#endif /* if defined(CONFIG_EON8260) */
 
 	ep->fen_taddrh = 0;
 	ep->fen_taddrm = 0;
@@ -1940,10 +2005,10 @@ mii_send_receive(fcc_info_t *fip, uint c
 		{
 			FCC_PDATC_MDC(1);
 			retval <<= 1;
-			if (io->iop_pdatc & fip->fc_mdio)
-				retval++;
 			udelay(1);
 			FCC_PDATC_MDC(0);
+			if (io->iop_pdatc & fip->fc_mdio)
+				retval++;
 			udelay(1);
 		}
 	}
_
