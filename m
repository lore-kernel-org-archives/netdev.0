From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 7/9] staging: slicoss: dont use a structure but offsets for
 register accesses
Date: Fri, 22 Jul 2016 23:09:17 +0200
Message-ID: <1469221759-17652-8-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Use the new register accessors that use offsets instead of the slic_regs
structure to read/write registers. Since not longer needed remove the
structure completley.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slic.h    |   1 -
 drivers/staging/slicoss/slichw.h  | 219 --------------------------
 drivers/staging/slicoss/slicoss.c | 323 ++++++++++++++------------------------
 3 files changed, 120 insertions(+), 423 deletions(-)

diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index 230d30b..3bba82a 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -417,7 +417,6 @@ struct adapter {
 	struct slic_shmem      *pshmem;
 	dma_addr_t          phys_shmem;
 	u32             isrcopy;
-	__iomem struct slic_regs       *slic_regs;
 	void __iomem *regs;
 	unsigned char               state;
 	unsigned char               linkstate;
diff --git a/drivers/staging/slicoss/slichw.h b/drivers/staging/slicoss/slichw.h
index f06450e..ae04bf6 100644
--- a/drivers/staging/slicoss/slichw.h
+++ b/drivers/staging/slicoss/slichw.h
@@ -402,225 +402,6 @@ struct slic_rspbuf {
 
 #define SLIC_REG_HOSTID		0x1554
 
-struct slic_regs {
-	u32	slic_reset;	/* Reset Register */
-	u32	pad0;
-
-	u32	slic_icr;	/* Interrupt Control Register */
-	u32	pad2;
-#define SLIC_ICR		0x0008
-
-	u32	slic_isp;	/* Interrupt status pointer */
-	u32	pad1;
-#define SLIC_ISP		0x0010
-
-	u32	slic_isr;	/* Interrupt status */
-	u32	pad3;
-#define SLIC_ISR		0x0018
-
-	u32	slic_hbar;	/* Header buffer address reg */
-	u32	pad4;
-	/*
-	 * 31-8 - phy addr of set of contiguous hdr buffers
-	 *  7-0 - number of buffers passed
-	 * Buffers are 256 bytes long on 256-byte boundaries.
-	 */
-#define SLIC_HBAR		0x0020
-#define SLIC_HBAR_CNT_MSK	0x000000FF
-
-	u32	slic_dbar;	/* Data buffer handle & address reg */
-	u32	pad5;
-
-	/* 4 sets of registers; Buffers are 2K bytes long 2 per 4K page. */
-#define SLIC_DBAR		0x0028
-#define SLIC_DBAR_SIZE		2048
-
-	u32	slic_cbar;	/* Xmt Cmd buf addr regs.*/
-	/*
-	 * 1 per XMT interface
-	 * 31-5 - phy addr of host command buffer
-	 *  4-0 - length of cmd in multiples of 32 bytes
-	 * Buffers are 32 bytes up to 512 bytes long
-	 */
-#define SLIC_CBAR		0x0030
-#define SLIC_CBAR_LEN_MSK	0x0000001F
-#define SLIC_CBAR_ALIGN		0x00000020
-
-	u32	slic_wcs;	/* write control store*/
-#define	SLIC_WCS		0x0034
-#define SLIC_WCS_START		0x80000000	/*Start the SLIC (Jump to WCS)*/
-#define SLIC_WCS_COMPARE	0x40000000	/* Compare with value in WCS*/
-
-	u32	slic_rbar;	/* Response buffer address reg.*/
-	u32	pad7;
-	/*
-	 * 31-8 - phy addr of set of contiguous response buffers
-	 * 7-0 - number of buffers passed
-	 * Buffers are 32 bytes long on 32-byte boundaries.
-	 */
-#define SLIC_RBAR		0x0038
-#define SLIC_RBAR_CNT_MSK	0x000000FF
-#define SLIC_RBAR_SIZE		32
-
-	u32	slic_stats;	/* read statistics (UPR) */
-	u32	pad8;
-#define	SLIC_RSTAT		0x0040
-
-	u32	slic_rlsr;	/* read link status */
-	u32	pad9;
-#define SLIC_LSTAT		0x0048
-
-	u32	slic_wmcfg;	/* Write Mac Config */
-	u32	pad10;
-#define	SLIC_WMCFG		0x0050
-
-	u32	slic_wphy;	/* Write phy register */
-	u32	pad11;
-#define SLIC_WPHY		0x0058
-
-	u32	slic_rcbar;	/* Rcv Cmd buf addr reg */
-	u32	pad12;
-#define	SLIC_RCBAR		0x0060
-
-	u32	slic_rconfig;	/* Read SLIC Config*/
-	u32	pad13;
-#define SLIC_RCONFIG	0x0068
-
-	u32	slic_intagg;	/* Interrupt aggregation time */
-	u32	pad14;
-#define SLIC_INTAGG		0x0070
-
-	u32	slic_wxcfg;	/* Write XMIT config reg*/
-	u32	pad16;
-#define	SLIC_WXCFG		0x0078
-
-	u32	slic_wrcfg;	/* Write RCV config reg*/
-	u32	pad17;
-#define	SLIC_WRCFG		0x0080
-
-	u32	slic_wraddral;	/* Write rcv addr a low*/
-	u32	pad18;
-#define	SLIC_WRADDRAL	0x0088
-
-	u32	slic_wraddrah;	/* Write rcv addr a high*/
-	u32	pad19;
-#define	SLIC_WRADDRAH	0x0090
-
-	u32	slic_wraddrbl;	/* Write rcv addr b low*/
-	u32	pad20;
-#define	SLIC_WRADDRBL	0x0098
-
-	u32	slic_wraddrbh;	/* Write rcv addr b high*/
-	u32		pad21;
-#define	SLIC_WRADDRBH	0x00a0
-
-	u32	slic_mcastlow;	/* Low bits of mcast mask*/
-	u32		pad22;
-#define	SLIC_MCASTLOW	0x00a8
-
-	u32	slic_mcasthigh;	/* High bits of mcast mask*/
-	u32		pad23;
-#define	SLIC_MCASTHIGH	0x00b0
-
-	u32	slic_ping;	/* Ping the card*/
-	u32	pad24;
-#define SLIC_PING		0x00b8
-
-	u32	slic_dump_cmd;	/* Dump command */
-	u32	pad25;
-#define SLIC_DUMP_CMD	0x00c0
-
-	u32	slic_dump_data;	/* Dump data pointer */
-	u32	pad26;
-#define SLIC_DUMP_DATA	0x00c8
-
-	u32	slic_pcistatus;	/* Read card's pci_status register */
-	u32	pad27;
-#define	SLIC_PCISTATUS	0x00d0
-
-	u32	slic_wrhostid;	/* Write hostid field */
-	u32		pad28;
-#define SLIC_WRHOSTID		 0x00d8
-#define SLIC_RDHOSTID_1GB	 0x1554
-#define SLIC_RDHOSTID_2GB	 0x1554
-
-	u32	slic_low_power;	/* Put card in a low power state */
-	u32	pad29;
-#define SLIC_LOW_POWER	0x00e0
-
-	u32	slic_quiesce;	/* force slic into quiescent state
-				 * before soft reset
-				 */
-	u32	pad30;
-#define SLIC_QUIESCE	0x00e8
-
-	u32	slic_reset_iface;/* reset interface queues */
-	u32	pad31;
-#define SLIC_RESET_IFACE 0x00f0
-
-	u32	slic_addr_upper;/* Bits 63-32 for host i/f addrs */
-	u32	pad32;
-#define SLIC_ADDR_UPPER	0x00f8 /*Register is only written when it has changed*/
-
-	u32	slic_hbar64;	/* 64 bit Header buffer address reg */
-	u32	pad33;
-#define SLIC_HBAR64		0x0100
-
-	u32	slic_dbar64;	/* 64 bit Data buffer handle & address reg */
-	u32	pad34;
-#define SLIC_DBAR64		0x0108
-
-	u32	slic_cbar64;	/* 64 bit Xmt Cmd buf addr regs. */
-	u32	pad35;
-#define SLIC_CBAR64		0x0110
-
-	u32	slic_rbar64;	/* 64 bit Response buffer address reg.*/
-	u32	pad36;
-#define SLIC_RBAR64		0x0118
-
-	u32	slic_rcbar64;	/* 64 bit Rcv Cmd buf addr reg*/
-	u32	pad37;
-#define	SLIC_RCBAR64	0x0120
-
-	u32	slic_stats64;	/* read statistics (64 bit UPR) */
-	u32	pad38;
-#define	SLIC_RSTAT64	0x0128
-
-	u32	slic_rcv_wcs;	/*Download Gigabit RCV sequencer ucode*/
-	u32	pad39;
-#define SLIC_RCV_WCS	0x0130
-#define SLIC_RCVWCS_BEGIN	0x40000000
-#define SLIC_RCVWCS_FINISH	0x80000000
-
-	u32	slic_wrvlanid;	/* Write VlanId field */
-	u32	pad40;
-#define SLIC_WRVLANID	0x0138
-
-	u32	slic_read_xf_info;	/* Read Transformer info */
-	u32	pad41;
-#define SLIC_READ_XF_INFO	0x0140
-
-	u32	slic_write_xf_info;	/* Write Transformer info */
-	u32	pad42;
-#define SLIC_WRITE_XF_INFO	0x0148
-
-	u32	RSVD1;		/* TOE Only */
-	u32	pad43;
-
-	u32	RSVD2;		/* TOE Only */
-	u32	pad44;
-
-	u32	RSVD3;		/* TOE Only */
-	u32	pad45;
-
-	u32	RSVD4;		/* TOE Only */
-	u32	pad46;
-
-	u32	slic_ticks_per_sec; /* Write card ticks per second */
-	u32	pad47;
-#define SLIC_TICKS_PER_SEC	0x0170
-};
-
 enum UPR_REQUEST {
 	SLIC_UPR_STATS,
 	SLIC_UPR_RLSR,
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 0c2f86a0..8e978e7 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -128,27 +128,6 @@ static struct ethtool_ops slic_ethtool_ops;
 
 MODULE_DEVICE_TABLE(pci, slic_pci_tbl);
 
-static inline void slic_reg32_write(void __iomem *reg, u32 value, bool flush)
-{
-	writel(value, reg);
-	if (flush)
-		mb();
-}
-
-static inline void slic_reg64_write(struct adapter *adapter, void __iomem *reg,
-				    u32 value, void __iomem *regh, u32 paddrh,
-				    bool flush)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->bit64reglock, flags);
-	writel(paddrh, regh);
-	writel(value, reg);
-	if (flush)
-		mb();
-	spin_unlock_irqrestore(&adapter->bit64reglock, flags);
-}
-
 static void slic_mcast_set_bit(struct adapter *adapter, char *address)
 {
 	unsigned char crcpoly;
@@ -172,8 +151,6 @@ static void slic_mcast_set_bit(struct adapter *adapter, char *address)
 
 static void slic_mcast_set_mask(struct adapter *adapter)
 {
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
-
 	if (adapter->macopts & (MAC_ALLMCAST | MAC_PROMISC)) {
 		/*
 		 * Turn on all multicast addresses. We have to do this for
@@ -181,18 +158,17 @@ static void slic_mcast_set_mask(struct adapter *adapter)
 		 * Microcode from having to keep state about the MAC
 		 * configuration.
 		 */
-		slic_reg32_write(&slic_regs->slic_mcastlow, 0xFFFFFFFF, FLUSH);
-		slic_reg32_write(&slic_regs->slic_mcasthigh, 0xFFFFFFFF,
-				 FLUSH);
+		slic_write32(adapter, SLIC_REG_MCASTLOW, 0xFFFFFFFF);
+		slic_write32(adapter, SLIC_REG_MCASTHIGH, 0xFFFFFFFF);
 	} else {
 		/*
 		 * Commit our multicast mast to the SLIC by writing to the
 		 * multicast address mask registers
 		 */
-		slic_reg32_write(&slic_regs->slic_mcastlow,
-			(u32)(adapter->mcastmask & 0xFFFFFFFF), FLUSH);
-		slic_reg32_write(&slic_regs->slic_mcasthigh,
-			(u32)((adapter->mcastmask >> 32) & 0xFFFFFFFF), FLUSH);
+		slic_write32(adapter, SLIC_REG_MCASTLOW,
+			     (u32)(adapter->mcastmask & 0xFFFFFFFF));
+		slic_write32(adapter, SLIC_REG_MCASTHIGH,
+			     (u32)((adapter->mcastmask >> 32) & 0xFFFFFFFF));
 	}
 }
 
@@ -208,13 +184,6 @@ static void slic_timer_ping(ulong dev)
 	add_timer(&adapter->pingtimer);
 }
 
-static void slic_unmap_mmio_space(struct adapter *adapter)
-{
-	if (adapter->slic_regs)
-		iounmap(adapter->slic_regs);
-	adapter->slic_regs = NULL;
-}
-
 /*
  *  slic_link_config
  *
@@ -224,7 +193,6 @@ static void slic_unmap_mmio_space(struct adapter *adapter)
 static void slic_link_config(struct adapter *adapter,
 		      u32 linkspeed, u32 linkduplex)
 {
-	u32 __iomem *wphy;
 	u32 speed;
 	u32 duplex;
 	u32 phy_config;
@@ -239,8 +207,6 @@ static void slic_link_config(struct adapter *adapter,
 	if (linkduplex > LINK_AUTOD)
 		linkduplex = LINK_AUTOD;
 
-	wphy = &adapter->slic_regs->slic_wphy;
-
 	if ((linkspeed == LINK_AUTOSPEED) || (linkspeed == LINK_1000MB)) {
 		if (adapter->flags & ADAPT_FLAGS_FIBERMEDIA) {
 			/*
@@ -252,7 +218,7 @@ static void slic_link_config(struct adapter *adapter,
 			phy_advreg = (MIICR_REG_4 | (PAR_ADV1000XFD));
 			/* enable PAUSE frames        */
 			phy_advreg |= PAR_ASYMPAUSE_FIBER;
-			slic_reg32_write(wphy, phy_advreg, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_advreg);
 
 			if (linkspeed == LINK_AUTOSPEED) {
 				/* reset phy, enable auto-neg  */
@@ -260,14 +226,16 @@ static void slic_link_config(struct adapter *adapter,
 				    (MIICR_REG_PCR |
 				     (PCR_RESET | PCR_AUTONEG |
 				      PCR_AUTONEG_RST));
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 			} else {	/* forced 1000 Mb FD*/
 				/*
 				 * power down phy to break link
 				 * this may not work)
 				 */
 				phy_config = (MIICR_REG_PCR | PCR_POWERDOWN);
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 				slic_flush_write(adapter);
 				/*
 				 * wait, Marvell says 1 sec,
@@ -283,7 +251,8 @@ static void slic_link_config(struct adapter *adapter,
 				    (MIICR_REG_PCR |
 				     (PCR_RESET | PCR_SPEED_1000 |
 				      PCR_DUPLEX_FULL));
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 			}
 		} else {	/* copper gigabit */
 
@@ -310,10 +279,10 @@ static void slic_link_config(struct adapter *adapter,
 			phy_advreg |= PAR_ASYMPAUSE;
 			/* required by the Cicada PHY  */
 			phy_advreg |= PAR_802_3;
-			slic_reg32_write(wphy, phy_advreg, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_advreg);
 			/* advertise FD only @1000 Mb  */
 			phy_gctlreg = (MIICR_REG_9 | (PGC_ADV1000FD));
-			slic_reg32_write(wphy, phy_gctlreg, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_gctlreg);
 
 			if (adapter->subsysid != SLIC_1GB_CICADA_SUBSYS_ID) {
 				/*
@@ -322,20 +291,23 @@ static void slic_link_config(struct adapter *adapter,
 				 */
 				phy_config =
 				    (MIICR_REG_16 | (MRV_REG16_XOVERON));
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 
 				/* reset phy, enable auto-neg  */
 				phy_config =
 				    (MIICR_REG_PCR |
 				     (PCR_RESET | PCR_AUTONEG |
 				      PCR_AUTONEG_RST));
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 			} else {	/* it's a Cicada PHY  */
 				/* enable and restart auto-neg (don't reset)  */
 				phy_config =
 				    (MIICR_REG_PCR |
 				     (PCR_AUTONEG | PCR_AUTONEG_RST));
-				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_write32(adapter, SLIC_REG_WPHY,
+					     phy_config);
 			}
 		}
 	} else {
@@ -355,12 +327,12 @@ static void slic_link_config(struct adapter *adapter,
 			 * disable auto crossover
 			 */
 			phy_config = (MIICR_REG_16 | (MRV_REG16_XOVEROFF));
-			slic_reg32_write(wphy, phy_config, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_config);
 		}
 
 		/* power down phy to break link (this may not work)  */
 		phy_config = (MIICR_REG_PCR | (PCR_POWERDOWN | speed | duplex));
-		slic_reg32_write(wphy, phy_config, FLUSH);
+		slic_write32(adapter, SLIC_REG_WPHY, phy_config);
 		slic_flush_write(adapter);
 		/* wait, Marvell says 1 sec, try to get away with 10 ms */
 		mdelay(10);
@@ -373,11 +345,11 @@ static void slic_link_config(struct adapter *adapter,
 			 */
 			phy_config =
 			    (MIICR_REG_PCR | (PCR_RESET | speed | duplex));
-			slic_reg32_write(wphy, phy_config, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_config);
 		} else {	/* it's a Cicada PHY  */
 			/* disable auto-neg, set speed, powerup  */
 			phy_config = (MIICR_REG_PCR | (speed | duplex));
-			slic_reg32_write(wphy, phy_config, FLUSH);
+			slic_write32(adapter, SLIC_REG_WPHY, phy_config);
 		}
 	}
 }
@@ -387,7 +359,6 @@ static int slic_card_download_gbrcv(struct adapter *adapter)
 	const struct firmware *fw;
 	const char *file = "";
 	int ret;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	u32 codeaddr;
 	u32 instruction;
 	int index = 0;
@@ -428,27 +399,26 @@ static int slic_card_download_gbrcv(struct adapter *adapter)
 		break;
 	}
 	/* start download */
-	slic_reg32_write(&slic_regs->slic_rcv_wcs, SLIC_RCVWCS_BEGIN, FLUSH);
+	slic_write32(adapter, SLIC_REG_RCV_WCS, SLIC_RCVWCS_BEGIN);
 	/* download the rcv sequencer ucode */
 	for (codeaddr = 0; codeaddr < rcvucodelen; codeaddr++) {
 		/* write out instruction address */
-		slic_reg32_write(&slic_regs->slic_rcv_wcs, codeaddr, FLUSH);
+		slic_write32(adapter, SLIC_REG_RCV_WCS, codeaddr);
 
 		instruction = *(u32 *)(fw->data + index);
 		index += 4;
 		/* write out the instruction data low addr */
-		slic_reg32_write(&slic_regs->slic_rcv_wcs, instruction, FLUSH);
+		slic_write32(adapter, SLIC_REG_RCV_WCS, instruction);
 
 		instruction = *(u8 *)(fw->data + index);
 		index++;
 		/* write out the instruction data high addr */
-		slic_reg32_write(&slic_regs->slic_rcv_wcs, (u8)instruction,
-				 FLUSH);
+		slic_write32(adapter, SLIC_REG_RCV_WCS, instruction);
 	}
 
 	/* download finished */
 	release_firmware(fw);
-	slic_reg32_write(&slic_regs->slic_rcv_wcs, SLIC_RCVWCS_FINISH, FLUSH);
+	slic_write32(adapter, SLIC_REG_RCV_WCS, SLIC_RCVWCS_FINISH);
 	slic_flush_write(adapter);
 
 	return 0;
@@ -465,7 +435,6 @@ static int slic_card_download(struct adapter *adapter)
 	u32 section;
 	int thissectionsize;
 	int codeaddr;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	u32 instruction;
 	u32 baseaddress;
 	u32 i;
@@ -509,17 +478,17 @@ static int slic_card_download(struct adapter *adapter)
 
 		for (codeaddr = 0; codeaddr < thissectionsize; codeaddr++) {
 			/* Write out instruction address */
-			slic_reg32_write(&slic_regs->slic_wcs,
-					 baseaddress + codeaddr, FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS,
+				     baseaddress + codeaddr);
 			/* Write out instruction to low addr */
-			slic_reg32_write(&slic_regs->slic_wcs,
-					instruction, FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS,
+				     instruction);
 			instruction = *(u32 *)(fw->data + index);
 			index += 4;
 
 			/* Write out instruction to high addr */
-			slic_reg32_write(&slic_regs->slic_wcs,
-					instruction, FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS,
+				     instruction);
 			instruction = *(u32 *)(fw->data + index);
 			index += 4;
 		}
@@ -534,17 +503,15 @@ static int slic_card_download(struct adapter *adapter)
 
 		for (codeaddr = 0; codeaddr < thissectionsize; codeaddr++) {
 			/* Write out instruction address */
-			slic_reg32_write(&slic_regs->slic_wcs,
-				SLIC_WCS_COMPARE | (baseaddress + codeaddr),
-				FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS,
+				     SLIC_WCS_COMPARE | (baseaddress +
+							 codeaddr));
 			/* Write out instruction to low addr */
-			slic_reg32_write(&slic_regs->slic_wcs, instruction,
-					 FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS, instruction);
 			instruction = *(u32 *)(fw->data + index);
 			index += 4;
 			/* Write out instruction to high addr */
-			slic_reg32_write(&slic_regs->slic_wcs, instruction,
-					 FLUSH);
+			slic_write32(adapter, SLIC_REG_WCS, instruction);
 			instruction = *(u32 *)(fw->data + index);
 			index += 4;
 
@@ -553,9 +520,9 @@ static int slic_card_download(struct adapter *adapter)
 	release_firmware(fw);
 	/* Everything OK, kick off the card */
 	mdelay(10);
-	slic_reg32_write(&slic_regs->slic_wcs, SLIC_WCS_START, FLUSH);
-	slic_flush_write(adapter);
 
+	slic_write32(adapter, SLIC_REG_WCS, SLIC_WCS_START);
+	slic_flush_write(adapter);
 	/*
 	 * stall for 20 ms, long enough for ucode to init card
 	 * and reach mainloop
@@ -587,21 +554,21 @@ static void slic_adapter_set_hwaddr(struct adapter *adapter)
 
 static void slic_intagg_set(struct adapter *adapter, u32 value)
 {
-	slic_reg32_write(&adapter->slic_regs->slic_intagg, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_INTAGG, value);
 	adapter->card->loadlevel_current = value;
 }
 
 static void slic_soft_reset(struct adapter *adapter)
 {
 	if (adapter->card->state == CARD_UP) {
-		slic_reg32_write(&adapter->slic_regs->slic_quiesce, 0, FLUSH);
+		slic_write32(adapter, SLIC_REG_QUIESCE, 0);
 		slic_flush_write(adapter);
 		mdelay(1);
 	}
 
-	slic_reg32_write(&adapter->slic_regs->slic_reset, SLIC_RESET_MAGIC,
-			 FLUSH);
+	slic_write32(adapter, SLIC_REG_RESET, SLIC_RESET_MAGIC);
 	slic_flush_write(adapter);
+
 	mdelay(1);
 }
 
@@ -609,17 +576,16 @@ static void slic_mac_address_config(struct adapter *adapter)
 {
 	u32 value;
 	u32 value2;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 
 	value = ntohl(*(__be32 *)&adapter->currmacaddr[2]);
-	slic_reg32_write(&slic_regs->slic_wraddral, value, FLUSH);
-	slic_reg32_write(&slic_regs->slic_wraddrbl, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_WRADDRAL, value);
+	slic_write32(adapter, SLIC_REG_WRADDRBL, value);
 
 	value2 = (u32)((adapter->currmacaddr[0] << 8 |
 			     adapter->currmacaddr[1]) & 0xFFFF);
 
-	slic_reg32_write(&slic_regs->slic_wraddrah, value2, FLUSH);
-	slic_reg32_write(&slic_regs->slic_wraddrbh, value2, FLUSH);
+	slic_write32(adapter, SLIC_REG_WRADDRAH, value2);
+	slic_write32(adapter, SLIC_REG_WRADDRBH, value2);
 
 	/*
 	 * Write our multicast mask out to the card.  This is done
@@ -632,7 +598,6 @@ static void slic_mac_address_config(struct adapter *adapter)
 static void slic_mac_config(struct adapter *adapter)
 {
 	u32 value;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 
 	/* Setup GMAC gaps */
 	if (adapter->linkspeed == LINK_1000MB) {
@@ -656,7 +621,7 @@ static void slic_mac_config(struct adapter *adapter)
 	}
 
 	/* write mac config */
-	slic_reg32_write(&slic_regs->slic_wmcfg, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_WMCFG, value);
 
 	/* setup mac addresses */
 	slic_mac_address_config(adapter);
@@ -666,7 +631,6 @@ static void slic_config_set(struct adapter *adapter, bool linkchange)
 {
 	u32 value;
 	u32 RcrReset;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 
 	if (linkchange) {
 		/* Setup MAC */
@@ -683,7 +647,7 @@ static void slic_config_set(struct adapter *adapter, bool linkchange)
 			 GXCR_XMTEN |	/* Enable transmit  */
 			 GXCR_PAUSEEN);	/* Enable pause     */
 
-		slic_reg32_write(&slic_regs->slic_wxcfg, value, FLUSH);
+		slic_write32(adapter, SLIC_REG_WXCFG, value);
 
 		/* Setup rcvcfg last */
 		value = (RcrReset |	/* Reset, if linkchange */
@@ -696,7 +660,7 @@ static void slic_config_set(struct adapter *adapter, bool linkchange)
 		value = (GXCR_RESET |	/* Always reset     */
 			 GXCR_XMTEN);	/* Enable transmit  */
 
-		slic_reg32_write(&slic_regs->slic_wxcfg, value, FLUSH);
+		slic_write32(adapter, SLIC_REG_WXCFG, value);
 
 		/* Setup rcvcfg last */
 		value = (RcrReset |	/* Reset, if linkchange */
@@ -713,7 +677,7 @@ static void slic_config_set(struct adapter *adapter, bool linkchange)
 	if (adapter->macopts & MAC_PROMISC)
 		value |= GRCR_RCVALL;
 
-	slic_reg32_write(&slic_regs->slic_wrcfg, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_WRCFG, value);
 }
 
 /*
@@ -723,24 +687,23 @@ static void slic_config_clear(struct adapter *adapter)
 {
 	u32 value;
 	u32 phy_config;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 
 	/* Setup xmtcfg */
 	value = (GXCR_RESET |	/* Always reset */
 		 GXCR_PAUSEEN);	/* Enable pause */
 
-	slic_reg32_write(&slic_regs->slic_wxcfg, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_WXCFG, value);
 
 	value = (GRCR_RESET |	/* Always reset      */
 		 GRCR_CTLEN |	/* Enable CTL frames */
 		 GRCR_ADDRAEN |	/* Address A enable  */
 		 (GRCR_HASHSIZE << GRCR_HASHSIZE_SHIFT));
 
-	slic_reg32_write(&slic_regs->slic_wrcfg, value, FLUSH);
+	slic_write32(adapter, SLIC_REG_WRCFG, value);
 
 	/* power down phy */
 	phy_config = (MIICR_REG_PCR | (PCR_POWERDOWN));
-	slic_reg32_write(&slic_regs->slic_wphy, phy_config, FLUSH);
+	slic_write32(adapter, SLIC_REG_WPHY, phy_config);
 }
 
 static bool slic_mac_filter(struct adapter *adapter,
@@ -816,13 +779,11 @@ static void slic_timer_load_check(ulong cardaddr)
 {
 	struct sliccard *card = (struct sliccard *)cardaddr;
 	struct adapter *adapter = card->master;
-	u32 __iomem *intagg;
 	u32 load = card->events;
 	u32 level = 0;
 
 	if ((adapter) && (adapter->state == ADAPT_UP) &&
 	    (card->state == CARD_UP) && (slic_global.dynamic_intagg)) {
-		intagg = &adapter->slic_regs->slic_intagg;
 		if (adapter->devid == SLIC_1GB_DEVICE_ID) {
 			if (adapter->linkspeed == LINK_1000MB)
 				level = 100;
@@ -842,7 +803,7 @@ static void slic_timer_load_check(ulong cardaddr)
 			}
 			if (card->loadlevel_current != level) {
 				card->loadlevel_current = level;
-				slic_reg32_write(intagg, level, FLUSH);
+				slic_write32(adapter, SLIC_REG_INTAGG, level);
 			}
 		} else {
 			if (load > SLIC_LOAD_5)
@@ -859,7 +820,7 @@ static void slic_timer_load_check(ulong cardaddr)
 				level = SLIC_INTAGG_0;
 			if (card->loadlevel_current != level) {
 				card->loadlevel_current = level;
-				slic_reg32_write(intagg, level, FLUSH);
+				slic_write32(adapter, SLIC_REG_INTAGG, level);
 			}
 		}
 	}
@@ -903,7 +864,6 @@ static int slic_upr_queue_request(struct adapter *adapter,
 static void slic_upr_start(struct adapter *adapter)
 {
 	struct slic_upr *upr;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 
 	upr = adapter->upr_list;
 	if (!upr)
@@ -915,29 +875,24 @@ static void slic_upr_start(struct adapter *adapter)
 	switch (upr->upr_request) {
 	case SLIC_UPR_STATS:
 		if (upr->upr_data_h == 0) {
-			slic_reg32_write(&slic_regs->slic_stats, upr->upr_data,
-					 FLUSH);
+			slic_write32(adapter, SLIC_REG_RSTAT, upr->upr_data);
 		} else {
-			slic_reg64_write(adapter, &slic_regs->slic_stats64,
-					 upr->upr_data,
-					 &slic_regs->slic_addr_upper,
-					 upr->upr_data_h, FLUSH);
+			slic_write64(adapter, SLIC_REG_RSTAT64, upr->upr_data,
+				     upr->upr_data_h);
 		}
 		break;
 
 	case SLIC_UPR_RLSR:
-		slic_reg64_write(adapter, &slic_regs->slic_rlsr, upr->upr_data,
-				 &slic_regs->slic_addr_upper, upr->upr_data_h,
-				 FLUSH);
+		slic_write64(adapter, SLIC_REG_LSTAT, upr->upr_data,
+			     upr->upr_data_h);
 		break;
 
 	case SLIC_UPR_RCONFIG:
-		slic_reg64_write(adapter, &slic_regs->slic_rconfig,
-				 upr->upr_data, &slic_regs->slic_addr_upper,
-				 upr->upr_data_h, FLUSH);
+		slic_write64(adapter, SLIC_REG_RCONFIG, upr->upr_data,
+			     upr->upr_data_h);
 		break;
 	case SLIC_UPR_PING:
-		slic_reg32_write(&slic_regs->slic_ping, 1, FLUSH);
+		slic_write32(adapter, SLIC_REG_PING, 1);
 		break;
 	}
 	slic_flush_write(adapter);
@@ -1194,7 +1149,6 @@ static int slic_rspqueue_init(struct adapter *adapter)
 {
 	int i;
 	struct slic_rspqueue *rspq = &adapter->rspqueue;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	u32 paddrh = 0;
 
 	memset(rspq, 0, sizeof(struct slic_rspqueue));
@@ -1213,14 +1167,12 @@ static int slic_rspqueue_init(struct adapter *adapter)
 		}
 
 		if (paddrh == 0) {
-			slic_reg32_write(&slic_regs->slic_rbar,
-				(rspq->paddr[i] | SLIC_RSPQ_BUFSINPAGE),
-				DONT_FLUSH);
+			slic_write32(adapter, SLIC_REG_RBAR,
+				     rspq->paddr[i] | SLIC_RSPQ_BUFSINPAGE);
 		} else {
-			slic_reg64_write(adapter, &slic_regs->slic_rbar64,
-				(rspq->paddr[i] | SLIC_RSPQ_BUFSINPAGE),
-				&slic_regs->slic_addr_upper,
-				paddrh, DONT_FLUSH);
+			slic_write64(adapter, SLIC_REG_RBAR64,
+				     rspq->paddr[i] | SLIC_RSPQ_BUFSINPAGE,
+				     paddrh);
 		}
 	}
 	rspq->offset = 0;
@@ -1241,9 +1193,9 @@ static struct slic_rspbuf *slic_rspqueue_getnext(struct adapter *adapter)
 	if (++rspq->offset < SLIC_RSPQ_BUFSINPAGE) {
 		rspq->rspbuf++;
 	} else {
-		slic_reg64_write(adapter, &adapter->slic_regs->slic_rbar64,
-			(rspq->paddr[rspq->pageindex] | SLIC_RSPQ_BUFSINPAGE),
-			&adapter->slic_regs->slic_addr_upper, 0, DONT_FLUSH);
+		slic_write64(adapter, SLIC_REG_RBAR64,
+			     rspq->paddr[rspq->pageindex] |
+			     SLIC_RSPQ_BUFSINPAGE, 0);
 		rspq->pageindex = (rspq->pageindex + 1) % rspq->num_pages;
 		rspq->offset = 0;
 		rspq->rspbuf = (struct slic_rspbuf *)
@@ -1577,14 +1529,11 @@ retry_rcvqfill:
 			}
 #endif
 			if (paddrh == 0) {
-				slic_reg32_write(&adapter->slic_regs->slic_hbar,
-						 (u32)paddrl, DONT_FLUSH);
+				slic_write32(adapter, SLIC_REG_HBAR,
+					     (u32)paddrl);
 			} else {
-				slic_reg64_write(adapter,
-					&adapter->slic_regs->slic_hbar64,
-					paddrl,
-					&adapter->slic_regs->slic_addr_upper,
-					paddrh, DONT_FLUSH);
+				slic_write64(adapter, SLIC_REG_HBAR64, paddrl,
+					     paddrh);
 			}
 			if (rcvq->head)
 				rcvq->tail->next = skb;
@@ -1707,12 +1656,9 @@ static u32 slic_rcvqueue_reinsert(struct adapter *adapter, struct sk_buff *skb)
 		dev_err(dev, "         rcvq->count[%x]\n", rcvq->count);
 	}
 	if (paddrh == 0) {
-		slic_reg32_write(&adapter->slic_regs->slic_hbar, (u32)paddrl,
-				 DONT_FLUSH);
+		slic_write32(adapter, SLIC_REG_HBAR, (u32)paddrl);
 	} else {
-		slic_reg64_write(adapter, &adapter->slic_regs->slic_hbar64,
-				 paddrl, &adapter->slic_regs->slic_addr_upper,
-				 paddrh, DONT_FLUSH);
+		slic_write64(adapter, SLIC_REG_HBAR64, paddrl, paddrh);
 	}
 	if (rcvq->head)
 		rcvq->tail->next = skb;
@@ -2158,9 +2104,9 @@ static irqreturn_t slic_interrupt(int irq, void *dev_id)
 	u32 isr;
 
 	if ((adapter->pshmem) && (adapter->pshmem->isr)) {
-		slic_reg32_write(&adapter->slic_regs->slic_icr,
-				 ICR_INT_MASK, FLUSH);
+		slic_write32(adapter, SLIC_REG_ICR, ICR_INT_MASK);
 		slic_flush_write(adapter);
+
 		isr = adapter->isrcopy = adapter->pshmem->isr;
 		adapter->pshmem->isr = 0;
 		adapter->num_isrs++;
@@ -2181,7 +2127,7 @@ static irqreturn_t slic_interrupt(int irq, void *dev_id)
 		adapter->isrcopy = 0;
 		adapter->all_reg_writes += 2;
 		adapter->isr_reg_writes++;
-		slic_reg32_write(&adapter->slic_regs->slic_isr, 0, FLUSH);
+		slic_write32(adapter, SLIC_REG_ISR, 0);
 	} else {
 		adapter->false_interrupts++;
 	}
@@ -2233,13 +2179,11 @@ static netdev_tx_t slic_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 	if (hcmd->paddrh == 0) {
-		slic_reg32_write(&adapter->slic_regs->slic_cbar,
-				 (hcmd->paddrl | hcmd->cmdsize), DONT_FLUSH);
+		slic_write32(adapter, SLIC_REG_CBAR, (hcmd->paddrl |
+						      hcmd->cmdsize));
 	} else {
-		slic_reg64_write(adapter, &adapter->slic_regs->slic_cbar64,
-				 (hcmd->paddrl | hcmd->cmdsize),
-				 &adapter->slic_regs->slic_addr_upper,
-				 hcmd->paddrh, DONT_FLUSH);
+		slic_write64(adapter, SLIC_REG_CBAR64,
+			     hcmd->paddrl | hcmd->cmdsize, hcmd->paddrh);
 	}
 xmit_done:
 	return NETDEV_TX_OK;
@@ -2299,7 +2243,6 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 {
 	struct sliccard *card = adapter->card;
 	struct net_device *dev = adapter->netdev;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	struct slic_shmem *pshmem;
 	int rc;
 
@@ -2344,7 +2287,7 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 		adapter->queues_initialized = 1;
 	}
 
-	slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
+	slic_write32(adapter, SLIC_REG_ICR, ICR_INT_OFF);
 	slic_flush_write(adapter);
 	mdelay(1);
 
@@ -2357,14 +2300,13 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 		spin_lock_irqsave(&adapter->bit64reglock, flags);
 
 #if BITS_PER_LONG == 64
-		slic_reg32_write(&slic_regs->slic_addr_upper,
-				 SLIC_GET_ADDR_HIGH(&pshmem->isr), DONT_FLUSH);
-		slic_reg32_write(&slic_regs->slic_isp,
-				 SLIC_GET_ADDR_LOW(&pshmem->isr), FLUSH);
+		slic_write32(adapter, SLIC_REG_ADDR_UPPER,
+			     SLIC_GET_ADDR_HIGH(&pshmem->isr));
+		slic_write32(adapter, SLIC_REG_ISP,
+			     SLIC_GET_ADDR_LOW(&pshmem->isr));
 #else
-		slic_reg32_write(&slic_regs->slic_addr_upper, 0, DONT_FLUSH);
-		slic_reg32_write(&slic_regs->slic_isp, (u32)&pshmem->isr,
-				FLUSH);
+		slic_write32(adapter, SLIC_REG_ADDR_UPPER, 0);
+		slic_write32(adapter, SLIC_REG_ISP, (u32)&pshmem->isr);
 #endif
 		spin_unlock_irqrestore(&adapter->bit64reglock, flags);
 		adapter->isp_initialized = 1;
@@ -2395,17 +2337,19 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 	 */
 	adapter->isrcopy = 0;
 	adapter->pshmem->isr = 0;
-	slic_reg32_write(&slic_regs->slic_isr, 0, FLUSH);
-	slic_reg32_write(&slic_regs->slic_icr, ICR_INT_ON, FLUSH);
+	slic_write32(adapter, SLIC_REG_ISR, 0);
+	slic_write32(adapter, SLIC_REG_ICR, ICR_INT_ON);
 
 	slic_link_config(adapter, LINK_AUTOSPEED, LINK_AUTOD);
 	slic_flush_write(adapter);
+
 	rc = slic_link_event_handler(adapter);
 	if (rc) {
 		/* disable interrupts then clear pending events */
-		slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
-		slic_reg32_write(&slic_regs->slic_isr, 0, FLUSH);
+		slic_write32(adapter, SLIC_REG_ICR, ICR_INT_OFF);
+		slic_write32(adapter, SLIC_REG_ISR, 0);
 		slic_flush_write(adapter);
+
 		if (adapter->pingtimerset) {
 			del_timer(&adapter->pingtimer);
 			adapter->pingtimerset = 0;
@@ -2478,7 +2422,7 @@ static void slic_entry_remove(struct pci_dev *pcidev)
 	unregister_netdev(dev);
 
 	slic_adapter_freeresources(adapter);
-	slic_unmap_mmio_space(adapter);
+	iounmap(adapter->regs);
 
 	/* free multicast addresses */
 	mlist = adapter->mcastaddrs;
@@ -2512,7 +2456,6 @@ static int slic_entry_halt(struct net_device *dev)
 {
 	struct adapter *adapter = netdev_priv(dev);
 	struct sliccard *card = adapter->card;
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	unsigned long flags;
 
 	spin_lock_irqsave(&slic_global.driver_lock, flags);
@@ -2522,7 +2465,7 @@ static int slic_entry_halt(struct net_device *dev)
 	adapter->upr_list = NULL;
 	adapter->upr_busy = 0;
 	adapter->devflags_prev = 0;
-	slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
+	slic_write32(adapter, SLIC_REG_ICR, ICR_INT_OFF);
 	adapter->all_reg_writes++;
 	adapter->icr_reg_writes++;
 	slic_config_clear(adapter);
@@ -2532,9 +2475,10 @@ static int slic_entry_halt(struct net_device *dev)
 		adapter->activated = 0;
 	}
 #ifdef AUTOMATIC_RESET
-	slic_reg32_write(&slic_regs->slic_reset_iface, 0, FLUSH);
+	slic_write32(adapter, SLIC_REG_RESET_IFACE, 0);
 #endif
 	slic_flush_write(adapter);
+
 	/*
 	 *  Reset the adapter's cmd queues
 	 */
@@ -2680,7 +2624,6 @@ static void slic_config_pci(struct pci_dev *pcidev)
 
 static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 {
-	__iomem struct slic_regs *slic_regs = adapter->slic_regs;
 	struct slic_eeprom *peeprom;
 	struct oslic_eeprom *pOeeprom;
 	dma_addr_t phys_config;
@@ -2725,17 +2668,17 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 
 		memset(peeprom, 0, sizeof(struct slic_eeprom));
 
-		slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
+		slic_write32(adapter, SLIC_REG_ICR, ICR_INT_OFF);
 		slic_flush_write(adapter);
 		mdelay(1);
 		pshmem = (struct slic_shmem *)(unsigned long)
 			 adapter->phys_shmem;
 
 		spin_lock_irqsave(&adapter->bit64reglock, flags);
-		slic_reg32_write(&slic_regs->slic_addr_upper,
-				 SLIC_GET_ADDR_HIGH(&pshmem->isr), DONT_FLUSH);
-		slic_reg32_write(&slic_regs->slic_isp,
-				 SLIC_GET_ADDR_LOW(&pshmem->isr), FLUSH);
+		slic_write32(adapter, SLIC_REG_ADDR_UPPER,
+			     SLIC_GET_ADDR_HIGH(&pshmem->isr));
+		slic_write32(adapter, SLIC_REG_ISP,
+			     SLIC_GET_ADDR_LOW(&pshmem->isr));
 		spin_unlock_irqrestore(&adapter->bit64reglock, flags);
 
 		status = slic_config_get(adapter, phys_configl, phys_configh);
@@ -2749,12 +2692,9 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 			if (adapter->pshmem->isr) {
 				if (adapter->pshmem->isr & ISR_UPC) {
 					adapter->pshmem->isr = 0;
-					slic_reg64_write(adapter,
-						&slic_regs->slic_isp, 0,
-						&slic_regs->slic_addr_upper,
-						0, FLUSH);
-					slic_reg32_write(&slic_regs->slic_isr,
-							 0, FLUSH);
+					slic_write64(adapter, SLIC_REG_ISP, 0,
+						     0);
+					slic_write32(adapter, SLIC_REG_ISR, 0);
 					slic_flush_write(adapter);
 
 					slic_upr_request_complete(adapter, 0);
@@ -2762,8 +2702,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 				}
 
 				adapter->pshmem->isr = 0;
-				slic_reg32_write(&slic_regs->slic_isr,
-						 0, FLUSH);
+				slic_write32(adapter, SLIC_REG_ISR, 0);
 				slic_flush_write(adapter);
 			} else {
 				mdelay(1);
@@ -2771,11 +2710,10 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 				if (i > 5000) {
 					dev_err(&adapter->pcidev->dev,
 						"Fetch of config data timed out.\n");
-					slic_reg64_write(adapter,
-						&slic_regs->slic_isp, 0,
-						&slic_regs->slic_addr_upper,
-						0, FLUSH);
+					slic_write64(adapter, SLIC_REG_ISP,
+						     0, 0);
 					slic_flush_write(adapter);
+
 					status = -EINVAL;
 					goto card_init_err;
 				}
@@ -2853,9 +2791,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 				    peeprom, phys_config);
 
 		if (!card->config.EepromValid) {
-			slic_reg64_write(adapter, &slic_regs->slic_isp, 0,
-					 &slic_regs->slic_addr_upper,
-					 0, FLUSH);
+			slic_write64(adapter, SLIC_REG_ISP, 0, 0);
 			slic_flush_write(adapter);
 			dev_err(&adapter->pcidev->dev, "EEPROM invalid.\n");
 			return -EINVAL;
@@ -2936,7 +2872,6 @@ static int slic_init_adapter(struct net_device *netdev,
 	adapter->busnumber = pcidev->bus->number;
 	adapter->slotnumber = ((pcidev->devfn >> 3) & 0x1F);
 	adapter->functionnumber = (pcidev->devfn & 0x7);
-	adapter->slic_regs = memaddr;
 	adapter->regs = memaddr;
 	adapter->irq = pcidev->irq;
 	adapter->chipid = chip_idx;
@@ -2989,27 +2924,9 @@ static u32 slic_card_locate(struct adapter *adapter)
 	struct sliccard *card = slic_global.slic_card;
 	struct physcard *physcard = slic_global.phys_card;
 	ushort card_hostid;
-	u16 __iomem *hostid_reg;
 	uint i;
-	uint rdhostid_offset = 0;
-
-	switch (adapter->devid) {
-	case SLIC_2GB_DEVICE_ID:
-		rdhostid_offset = SLIC_RDHOSTID_2GB;
-		break;
-	case SLIC_1GB_DEVICE_ID:
-		rdhostid_offset = SLIC_RDHOSTID_1GB;
-		break;
-	default:
-		return -ENODEV;
-	}
-
-	hostid_reg =
-	    (u16 __iomem *)(((u8 __iomem *)(adapter->slic_regs)) +
-	    rdhostid_offset);
 
-	/* read the 16 bit hostid from SRAM */
-	card_hostid = (ushort)readw(hostid_reg);
+	card_hostid = slic_read32(adapter, SLIC_REG_HOSTID);
 
 	/* Initialize a new card structure if need be */
 	if (card_hostid == SLIC_HOSTID_DEFAULT) {
-- 
1.9.1
