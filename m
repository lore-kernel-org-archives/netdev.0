From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 5/9] staging: slicoss: introduce register accessors that use
 register offsets
Date: Fri, 22 Jul 2016 23:09:15 +0200
Message-ID: <1469221759-17652-6-git-send-email-LinoSanfilippo@gmx.de>
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

Introduce accessor functions that read and write registers by using a
register offset.
This is in preparation to replace the register addressing by means of the
slic_regs struct with an addressing by means of offsets.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slic.h    |  24 ++++++++
 drivers/staging/slicoss/slichw.h  | 113 ++++++++++++++++++++++++++++++++++++++
 drivers/staging/slicoss/slicoss.c |   1 +
 3 files changed, 138 insertions(+)

diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index cc0afee..08d9f5b 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -418,6 +418,7 @@ struct adapter {
 	dma_addr_t          phys_shmem;
 	u32             isrcopy;
 	__iomem struct slic_regs       *slic_regs;
+	void __iomem *regs;
 	unsigned char               state;
 	unsigned char               linkstate;
 	unsigned char               linkspeed;
@@ -487,6 +488,29 @@ struct adapter {
 	struct slicnet_stats     slic_stats;
 };
 
+static inline u32 slic_read32(struct adapter *adapter, unsigned int reg)
+{
+	return ioread32(adapter->regs + reg);
+}
+
+static inline void slic_write32(struct adapter *adapter, unsigned int reg,
+				u32 val)
+{
+	iowrite32(val, adapter->regs + reg);
+}
+
+static inline void slic_write64(struct adapter *adapter, unsigned int reg,
+				u32 val, u32 hiaddr)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->bit64reglock, flags);
+	slic_write32(adapter, SLIC_REG_ADDR_UPPER, hiaddr);
+	slic_write32(adapter, reg, val);
+	mmiowb();
+	spin_unlock_irqrestore(&adapter->bit64reglock, flags);
+}
+
 #define UPDATE_STATS(largestat, newstat, oldstat)                        \
 {                                                                        \
 	if ((newstat) < (oldstat))                                       \
diff --git a/drivers/staging/slicoss/slichw.h b/drivers/staging/slicoss/slichw.h
index 9723b4a..f06450e 100644
--- a/drivers/staging/slicoss/slichw.h
+++ b/drivers/staging/slicoss/slichw.h
@@ -289,6 +289,119 @@ struct slic_rspbuf {
 	u32 pad2[4];
 };
 
+/* Reset Register */
+#define SLIC_REG_RESET		0x0000
+/* Interrupt Control Register */
+#define SLIC_REG_ICR		0x0008
+/* Interrupt status pointer */
+#define SLIC_REG_ISP		0x0010
+/* Interrupt status */
+#define SLIC_REG_ISR		0x0018
+/*
+ * Header buffer address reg
+ * 31-8 - phy addr of set of contiguous hdr buffers
+ *  7-0 - number of buffers passed
+ * Buffers are 256 bytes long on 256-byte boundaries.
+ */
+#define SLIC_REG_HBAR		0x0020
+/*
+ * Data buffer handle & address reg
+ * 4 sets of registers; Buffers are 2K bytes long 2 per 4K page.
+ */
+#define SLIC_REG_DBAR		0x0028
+/*
+ * Xmt Cmd buf addr regs.
+ * 1 per XMT interface
+ * 31-5 - phy addr of host command buffer
+ *  4-0 - length of cmd in multiples of 32 bytes
+ * Buffers are 32 bytes up to 512 bytes long
+ */
+#define SLIC_REG_CBAR		0x0030
+/* Write control store */
+#define	SLIC_REG_WCS		0x0034
+/*
+ * Response buffer address reg.
+ * 31-8 - phy addr of set of contiguous response buffers
+ * 7-0 - number of buffers passed
+ * Buffers are 32 bytes long on 32-byte boundaries.
+ */
+#define	SLIC_REG_RBAR		0x0038
+/* Read statistics (UPR) */
+#define	SLIC_REG_RSTAT		0x0040
+/* Read link status */
+#define	SLIC_REG_LSTAT		0x0048
+/* Write Mac Config */
+#define	SLIC_REG_WMCFG		0x0050
+/* Write phy register */
+#define SLIC_REG_WPHY		0x0058
+/* Rcv Cmd buf addr reg */
+#define	SLIC_REG_RCBAR		0x0060
+/* Read SLIC Config*/
+#define SLIC_REG_RCONFIG	0x0068
+/* Interrupt aggregation time */
+#define SLIC_REG_INTAGG		0x0070
+/* Write XMIT config reg */
+#define	SLIC_REG_WXCFG		0x0078
+/* Write RCV config reg */
+#define	SLIC_REG_WRCFG		0x0080
+/* Write rcv addr a low */
+#define	SLIC_REG_WRADDRAL	0x0088
+/* Write rcv addr a high */
+#define	SLIC_REG_WRADDRAH	0x0090
+/* Write rcv addr b low */
+#define	SLIC_REG_WRADDRBL	0x0098
+/* Write rcv addr b high */
+#define	SLIC_REG_WRADDRBH	0x00a0
+/* Low bits of mcast mask */
+#define	SLIC_REG_MCASTLOW	0x00a8
+/* High bits of mcast mask */
+#define	SLIC_REG_MCASTHIGH	0x00b0
+/* Ping the card */
+#define SLIC_REG_PING		0x00b8
+/* Dump command */
+#define SLIC_REG_DUMP_CMD	0x00c0
+/* Dump data pointer */
+#define SLIC_REG_DUMP_DATA	0x00c8
+/* Read card's pci_status register */
+#define	SLIC_REG_PCISTATUS	0x00d0
+/* Write hostid field */
+#define SLIC_REG_WRHOSTID	0x00d8
+/* Put card in a low power state */
+#define SLIC_REG_LOW_POWER	0x00e0
+/* Force slic into quiescent state  before soft reset */
+#define SLIC_REG_QUIESCE	0x00e8
+/* Reset interface queues */
+#define SLIC_REG_RESET_IFACE	0x00f0
+/*
+ * Register is only written when it has changed.
+ * Bits 63-32 for host i/f addrs.
+ */
+#define SLIC_REG_ADDR_UPPER	0x00f8
+/* 64 bit Header buffer address reg */
+#define SLIC_REG_HBAR64		0x0100
+/* 64 bit Data buffer handle & address reg */
+#define SLIC_REG_DBAR64		0x0108
+/* 64 bit Xmt Cmd buf addr regs. */
+#define SLIC_REG_CBAR64		0x0110
+/* 64 bit Response buffer address reg.*/
+#define SLIC_REG_RBAR64		0x0118
+/* 64 bit Rcv Cmd buf addr reg*/
+#define	SLIC_REG_RCBAR64	0x0120
+/* Read statistics (64 bit UPR) */
+#define	SLIC_REG_RSTAT64	0x0128
+/* Download Gigabit RCV sequencer ucode */
+#define SLIC_REG_RCV_WCS	0x0130
+/* Write VlanId field */
+#define SLIC_REG_WRVLANID	0x0138
+/* Read Transformer info */
+#define SLIC_REG_READ_XF_INFO	0x0140
+/* Write Transformer info */
+#define SLIC_REG_WRITE_XF_INFO	0x0148
+/* Write card ticks per second */
+#define SLIC_REG_TICKS_PER_SEC	0x0170
+
+#define SLIC_REG_HOSTID		0x1554
+
 struct slic_regs {
 	u32	slic_reset;	/* Reset Register */
 	u32	pad0;
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 577c2d2..edae0f7 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -2920,6 +2920,7 @@ static int slic_init_adapter(struct net_device *netdev,
 	adapter->slotnumber = ((pcidev->devfn >> 3) & 0x1F);
 	adapter->functionnumber = (pcidev->devfn & 0x7);
 	adapter->slic_regs = memaddr;
+	adapter->regs = memaddr;
 	adapter->irq = pcidev->irq;
 	adapter->chipid = chip_idx;
 	adapter->port = 0;
-- 
1.9.1
