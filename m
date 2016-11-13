From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit ethernet driver
Date: Sun, 13 Nov 2016 05:47:32 +0100
Message-ID: <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add driver for Alacritech gigabit ethernet cards with SLIC (session-layer
interface control) technology. The driver provides basic support without
SLIC for the following devices:

- Mojave cards (single port PCI Gigabit) both copper and fiber
- Oasis cards (single and dual port PCI-x Gigabit) copper and fiber
- Kalahari cards (dual and quad port PCI-e Gigabit) copper and fiber

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/alacritech/Kconfig   |   28 +
 drivers/net/ethernet/alacritech/Makefile  |    4 +
 drivers/net/ethernet/alacritech/slic.h    |  606 ++++++++++
 drivers/net/ethernet/alacritech/slicoss.c | 1855 +++++++++++++++++++++++++++++
 include/linux/pci_ids.h                   |   18 +
 7 files changed, 2513 insertions(+)
 create mode 100644 drivers/net/ethernet/alacritech/Kconfig
 create mode 100644 drivers/net/ethernet/alacritech/Makefile
 create mode 100644 drivers/net/ethernet/alacritech/slic.h
 create mode 100644 drivers/net/ethernet/alacritech/slicoss.c

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 2ffd634..a4cc87fe 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -21,6 +21,7 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/agere/Kconfig"
+source "drivers/net/ethernet/alacritech/Kconfig"
 source "drivers/net/ethernet/allwinner/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/altera/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1d349e9..b448027 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_NET_VENDOR_AGERE) += agere/
+obj-$(CONFIG_NET_VENDOR_ALACRITECH) += alacritech/
 obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_ALTERA_TSE) += altera/
diff --git a/drivers/net/ethernet/alacritech/Kconfig b/drivers/net/ethernet/alacritech/Kconfig
new file mode 100644
index 0000000..41000a3
--- /dev/null
+++ b/drivers/net/ethernet/alacritech/Kconfig
@@ -0,0 +1,28 @@
+config NET_VENDOR_ALACRITECH
+        bool "Alacritech devices"
+        default y
+        ---help---
+          If you have a network (Ethernet) card belonging to this class, say Y.
+
+          Note that the answer to this question doesn't directly affect the
+          kernel: saying N will just cause the configurator to skip all
+          the questions about Renesas devices. If you say Y, you will be asked
+          for your specific device in the following questions.
+
+if NET_VENDOR_ALACRITECH
+
+config SLICOSS
+	tristate "Alacritech Slicoss support"
+	depends on PCI
+	select CRC32
+	---help---
+	  This driver supports Gigabit Ethernet adapters based on the
+	  Session Layer Interface (SLIC) technology by Alacritech.
+
+	  Supported are Mojave (1 port) and Oasis (1, 2 and 4 port) cards,
+	  both copper and fiber.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called slicoss. This is recommended.
+
+endif # NET_VENDOR_ALACRITECH
diff --git a/drivers/net/ethernet/alacritech/Makefile b/drivers/net/ethernet/alacritech/Makefile
new file mode 100644
index 0000000..8790e9e
--- /dev/null
+++ b/drivers/net/ethernet/alacritech/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for the Alacritech Slicoss driver
+#
+obj-$(CONFIG_SLICOSS) += slicoss.o
diff --git a/drivers/net/ethernet/alacritech/slic.h b/drivers/net/ethernet/alacritech/slic.h
new file mode 100644
index 0000000..963a20d
--- /dev/null
+++ b/drivers/net/ethernet/alacritech/slic.h
@@ -0,0 +1,606 @@
+
+#ifndef _SLIC_H
+#define _SLIC_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock_types.h>
+#include <linux/dma-mapping.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/list.h>
+#include <linux/u64_stats_sync.h>
+
+#define SLIC_VGBSTAT_XPERR		0x40000000
+#define SLIC_VGBSTAT_XERRSHFT		25
+#define SLIC_VGBSTAT_XCSERR		0x23
+#define SLIC_VGBSTAT_XUFLOW		0x22
+#define SLIC_VGBSTAT_XHLEN		0x20
+#define SLIC_VGBSTAT_NETERR		0x01000000
+#define SLIC_VGBSTAT_NERRSHFT		16
+#define SLIC_VGBSTAT_NERRMSK		0x1ff
+#define SLIC_VGBSTAT_NCSERR		0x103
+#define SLIC_VGBSTAT_NUFLOW		0x102
+#define SLIC_VGBSTAT_NHLEN		0x100
+#define SLIC_VGBSTAT_LNKERR		0x00000080
+#define SLIC_VGBSTAT_LERRMSK		0xff
+#define SLIC_VGBSTAT_LDEARLY		0x86
+#define SLIC_VGBSTAT_LBOFLO		0x85
+#define SLIC_VGBSTAT_LCODERR		0x84
+#define SLIC_VGBSTAT_LDBLNBL		0x83
+#define SLIC_VGBSTAT_LCRCERR		0x82
+#define SLIC_VGBSTAT_LOFLO		0x81
+#define SLIC_VGBSTAT_LUFLO		0x80
+#define SLIC_IRHDDR_FLEN_MSK		0x0000ffff
+#define SLIC_IRHDDR_SVALID		0x80000000
+#define SLIC_IRHDDR_ERR			0x10000000
+#define SLIC_VRHSTAT_802OE		0x80000000
+#define SLIC_VRHSTAT_TPOFLO		0x10000000
+#define SLIC_VRHSTATB_802UE		0x80000000
+#define SLIC_VRHSTATB_RCVE		0x40000000
+#define SLIC_VRHSTATB_BUFF		0x20000000
+#define SLIC_VRHSTATB_CARRE		0x08000000
+#define SLIC_VRHSTATB_LONGE		0x02000000
+#define SLIC_VRHSTATB_PREA		0x01000000
+#define SLIC_VRHSTATB_CRC		0x00800000
+#define SLIC_VRHSTATB_DRBL		0x00400000
+#define SLIC_VRHSTATB_CODE		0x00200000
+#define SLIC_VRHSTATB_TPCSUM		0x00100000
+#define SLIC_VRHSTATB_TPHLEN		0x00080000
+#define SLIC_VRHSTATB_IPCSUM		0x00040000
+#define SLIC_VRHSTATB_IPLERR		0x00020000
+#define SLIC_VRHSTATB_IPHERR		0x00010000
+#define SLIC_MAX64_BCNT			23
+#define SLIC_MAX32_BCNT			26
+#define SLIC_CMD_XMT_REQ		0x01
+#define SLIC_CMD_TYPE_DUMB		3
+#define SLIC_IHFLG_IFSHFT		2
+
+#define SLIC_RESET_MAGIC		0xDEAD
+#define SLIC_ICR_INT_OFF		0
+#define SLIC_ICR_INT_ON			1
+#define SLIC_ICR_INT_MASK		2
+
+#define SLIC_ISR_ERR			0x80000000
+#define SLIC_ISR_RCV			0x40000000
+#define SLIC_ISR_CMD			0x20000000
+#define SLIC_ISR_IO			0x60000000
+#define SLIC_ISR_UPC			0x10000000
+#define SLIC_ISR_LEVENT			0x08000000
+#define SLIC_ISR_RMISS			0x02000000
+#define SLIC_ISR_UPCERR			0x01000000
+#define SLIC_ISR_XDROP			0x00800000
+#define SLIC_ISR_UPCBSY			0x00020000
+
+#define SLIC_ISR_PING_MASK		0x00700000
+#define SLIC_ISR_UPCERR_MASK		(SLIC_ISR_UPCERR | SLIC_ISR_UPCBSY)
+#define SLIC_ISR_UPC_MASK		(SLIC_ISR_UPC | SLIC_ISR_UPCERR_MASK)
+#define SLIC_WCS_START			0x80000000
+#define SLIC_WCS_COMPARE		0x40000000
+#define SLIC_RCVWCS_BEGIN		0x40000000
+#define SLIC_RCVWCS_FINISH		0x80000000
+#define SLIC_PM_MAXPATTERNS		6
+#define SLIC_PM_PATTERNSIZE		128
+#define SLIC_PMCAPS_WAKEONLAN		0x00000001
+#define SLIC_MIICR_REG_16		0x00100000
+#define SLIC_PCR_RESET			0x8000
+#define SLIC_PCR_POWERDOWN		0x0800
+#define SLIC_PCR_SPEED_100		0x2000
+#define SLIC_PCR_SPEED_1000		0x0040
+#define SLIC_PCR_AUTONEG		0x1000
+#define SLIC_PCR_AUTONEG_RST		0x0200
+#define SLIC_PCR_DUPLEX_FULL		0x0100
+#define SLIC_PSR_LINKUP			0x0004
+
+#define SLIC_PAR_ADV100FD		0x0100
+#define SLIC_PAR_ADV100HD		0x0080
+#define SLIC_PAR_ADV10FD		0x0040
+#define SLIC_PAR_ADV10HD		0x0020
+#define SLIC_PAR_ASYMPAUSE		0x0C00
+#define SLIC_PAR_802_3			0x0001
+
+#define SLIC_PAR_ADV1000XFD		0x0020
+#define SLIC_PAR_ADV1000XHD		0x0040
+#define SLIC_PAR_ASYMPAUSE_FIBER	0x0180
+
+#define SLIC_PGC_ADV1000FD		0x0200
+#define SLIC_PGC_ADV1000HD		0x0100
+#define SLIC_SEEQ_LINKFAIL		0x4000
+#define SLIC_SEEQ_SPEED			0x0080
+#define SLIC_SEEQ_DUPLEX		0x0040
+#define SLIC_TDK_DUPLEX			0x0800
+#define SLIC_TDK_SPEED			0x0400
+#define SLIC_MRV_REG16_XOVERON		0x0068
+#define SLIC_MRV_REG16_XOVEROFF		0x0008
+#define SLIC_MRV_SPEED_1000		0x8000
+#define SLIC_MRV_SPEED_100		0x4000
+#define SLIC_MRV_SPEED_10		0x0000
+#define SLIC_MRV_FULLDUPLEX		0x2000
+#define SLIC_MRV_LINKUP			0x0400
+
+#define SLIC_GIG_LINKUP			0x0001
+#define SLIC_GIG_FULLDUPLEX		0x0002
+#define SLIC_GIG_SPEED_MASK		0x000C
+#define SLIC_GIG_SPEED_1000		0x0008
+#define SLIC_GIG_SPEED_100		0x0004
+#define SLIC_GIG_SPEED_10		0x0000
+
+#define SLIC_MCR_RESET			0x80000000
+#define SLIC_MCR_CRCEN			0x40000000
+#define SLIC_MCR_FULLD			0x10000000
+#define SLIC_MCR_PAD			0x02000000
+#define SLIC_MCR_RETRYLATE		0x01000000
+#define SLIC_MCR_BOL_SHIFT		21
+#define SLIC_MCR_IPG1_SHIFT		14
+#define SLIC_MCR_IPG2_SHIFT		7
+#define SLIC_MCR_IPG3_SHIFT		0
+#define SLIC_GMCR_RESET			0x80000000
+#define SLIC_GMCR_GBIT			0x20000000
+#define SLIC_GMCR_FULLD			0x10000000
+#define SLIC_GMCR_GAPBB_SHIFT		14
+#define SLIC_GMCR_GAPR1_SHIFT		7
+#define SLIC_GMCR_GAPR2_SHIFT		0
+#define SLIC_GMCR_GAPBB_1000		0x60
+#define SLIC_GMCR_GAPR1_1000		0x2C
+#define SLIC_GMCR_GAPR2_1000		0x40
+#define SLIC_GMCR_GAPBB_100		0x70
+#define SLIC_GMCR_GAPR1_100		0x2C
+#define SLIC_GMCR_GAPR2_100		0x40
+#define SLIC_XCR_RESET			0x80000000
+#define SLIC_XCR_XMTEN			0x40000000
+#define SLIC_XCR_PAUSEEN		0x20000000
+#define SLIC_XCR_LOADRNG		0x10000000
+#define SLIC_RCR_RESET			0x80000000
+#define SLIC_RCR_RCVEN			0x40000000
+#define SLIC_RCR_RCVALL			0x20000000
+#define SLIC_RCR_RCVBAD			0x10000000
+#define SLIC_RCR_CTLEN			0x08000000
+#define SLIC_RCR_ADDRAEN		0x02000000
+#define SLIC_GXCR_RESET			0x80000000
+#define SLIC_GXCR_XMTEN			0x40000000
+#define SLIC_GXCR_PAUSEEN		0x20000000
+#define SLIC_GRCR_RESET			0x80000000
+#define SLIC_GRCR_RCVEN			0x40000000
+#define SLIC_GRCR_RCVALL		0x20000000
+#define SLIC_GRCR_RCVBAD		0x10000000
+#define SLIC_GRCR_CTLEN			0x08000000
+#define SLIC_GRCR_ADDRAEN		0x02000000
+#define SLIC_GRCR_HASHSIZE_SHIFT	17
+#define SLIC_GRCR_HASHSIZE		14
+
+/* Reset Register */
+#define SLIC_REG_RESET			0x0000
+/* Interrupt Control Register */
+#define SLIC_REG_ICR			0x0008
+/* Interrupt status pointer */
+#define SLIC_REG_ISP			0x0010
+/* Interrupt status */
+#define SLIC_REG_ISR			0x0018
+/* Header buffer address reg
+ * 31-8 - phy addr of set of contiguous hdr buffers
+ *  7-0 - number of buffers passed
+ * Buffers are 256 bytes long on 256-byte boundaries.
+ */
+#define SLIC_REG_HBAR			0x0020
+/* Data buffer handle & address reg
+ * 4 sets of registers; Buffers are 2K bytes long 2 per 4K page.
+ */
+#define SLIC_REG_DBAR			0x0028
+/* Xmt Cmd buf addr regs.
+ * 1 per XMT interface
+ * 31-5 - phy addr of host command buffer
+ *  4-0 - length of cmd in multiples of 32 bytes
+ * Buffers are 32 bytes up to 512 bytes long
+ */
+#define SLIC_REG_CBAR			0x0030
+/* Write control store */
+#define	SLIC_REG_WCS			0x0034
+/*Response buffer address reg.
+ * 31-8 - phy addr of set of contiguous response buffers
+ * 7-0 - number of buffers passed
+ * Buffers are 32 bytes long on 32-byte boundaries.
+ */
+#define	SLIC_REG_RBAR			0x0038
+/* Read statistics (UPR) */
+#define	SLIC_REG_RSTAT			0x0040
+/* Read link status */
+#define	SLIC_REG_LSTAT			0x0048
+/* Write Mac Config */
+#define	SLIC_REG_WMCFG			0x0050
+/* Write phy register */
+#define SLIC_REG_WPHY			0x0058
+/* Rcv Cmd buf addr reg */
+#define	SLIC_REG_RCBAR			0x0060
+/* Read SLIC Config*/
+#define SLIC_REG_RCONFIG		0x0068
+/* Interrupt aggregation time */
+#define SLIC_REG_INTAGG			0x0070
+/* Write XMIT config reg */
+#define	SLIC_REG_WXCFG			0x0078
+/* Write RCV config reg */
+#define	SLIC_REG_WRCFG			0x0080
+/* Write rcv addr a low */
+#define	SLIC_REG_WRADDRAL		0x0088
+/* Write rcv addr a high */
+#define	SLIC_REG_WRADDRAH		0x0090
+/* Write rcv addr b low */
+#define	SLIC_REG_WRADDRBL		0x0098
+/* Write rcv addr b high */
+#define	SLIC_REG_WRADDRBH		0x00a0
+/* Low bits of mcast mask */
+#define	SLIC_REG_MCASTLOW		0x00a8
+/* High bits of mcast mask */
+#define	SLIC_REG_MCASTHIGH		0x00b0
+/* Ping the card */
+#define SLIC_REG_PING			0x00b8
+/* Dump command */
+#define SLIC_REG_DUMP_CMD		0x00c0
+/* Dump data pointer */
+#define SLIC_REG_DUMP_DATA		0x00c8
+/* Read card's pci_status register */
+#define	SLIC_REG_PCISTATUS		0x00d0
+/* Write hostid field */
+#define SLIC_REG_WRHOSTID		0x00d8
+/* Put card in a low power state */
+#define SLIC_REG_LOW_POWER		0x00e0
+/* Force slic into quiescent state  before soft reset */
+#define SLIC_REG_QUIESCE		0x00e8
+/* Reset interface queues */
+#define SLIC_REG_RESET_IFACE		0x00f0
+/* Register is only written when it has changed.
+ * Bits 63-32 for host i/f addrs.
+ */
+#define SLIC_REG_ADDR_UPPER		0x00f8
+/* 64 bit Header buffer address reg */
+#define SLIC_REG_HBAR64			0x0100
+/* 64 bit Data buffer handle & address reg */
+#define SLIC_REG_DBAR64			0x0108
+/* 64 bit Xmt Cmd buf addr regs. */
+#define SLIC_REG_CBAR64			0x0110
+/* 64 bit Response buffer address reg.*/
+#define SLIC_REG_RBAR64			0x0118
+/* 64 bit Rcv Cmd buf addr reg*/
+#define	SLIC_REG_RCBAR64		0x0120
+/* Read statistics (64 bit UPR) */
+#define	SLIC_REG_RSTAT64		0x0128
+/* Download Gigabit RCV sequencer ucode */
+#define SLIC_REG_RCV_WCS		0x0130
+/* Write VlanId field */
+#define SLIC_REG_WRVLANID		0x0138
+/* Read Transformer info */
+#define SLIC_REG_READ_XF_INFO		0x0140
+/* Write Transformer info */
+#define SLIC_REG_WRITE_XF_INFO		0x0148
+/* Write card ticks per second */
+#define SLIC_REG_TICKS_PER_SEC		0x0170
+#define SLIC_REG_HOSTID			0x1554
+
+/* Note: power of two required for number descriptors  */
+#define SLIC_NUM_RX_LES			256
+#define SLIC_RX_BUFF_SIZE		2048
+#define SLIC_RX_BUFF_ALIGN		256
+#define SLIC_RX_BUFF_HDR_SIZE		34
+#define SLIC_MAX_REQ_RX_DESCS		1
+
+#define SLIC_NUM_TX_DESCS		256
+#define SLIC_TX_DESC_ALIGN		32
+#define SLIC_MIN_TX_WAKEUP_DESCS	10
+#define SLIC_MAX_REQ_TX_DESCS		1
+#define SLIC_MAX_TX_COMPLETIONS		100
+
+#define SLIC_NUM_STAT_DESCS		128
+#define SLIC_STATS_DESC_ALIGN		256
+
+#define SLIC_NUM_STAT_DESC_ARRAYS	4
+#define SLIC_INVALID_STAT_DESC_IDX	0xffffffff
+
+#define SLIC_NAPI_WEIGHT		64
+
+#define SLIC_UPR_LSTAT			0
+#define SLIC_UPR_STATS			1
+#define SLIC_UPR_CONFIG			2
+
+#define SLIC_EEPROM_SIZE		128
+#define SLIC_EEPROM_MAGIC		0xa5a5
+
+#define SLIC_FIRMWARE_MOAVE		"slicoss/gbdownload.sys"
+#define SLIC_FIRMWARE_OASIS		"slicoss/oasisdownload.sys"
+#define SLIC_RCV_FIRMWARE_MOAVE		"slicoss/gbrcvucode.sys"
+#define SLIC_RCV_FIRMWARE_OASIS		"slicoss/oasisrcvucode.sys"
+#define SLIC_FIRMWARE_MIN_SIZE		64
+#define SLIC_FIRMWARE_MAX_SECTIONS	3
+
+#define SLIC_MODEL_MOJAVE		0
+#define SLIC_MODEL_OASIS		1
+
+#define SLIC_INC_STATS_COUNTER(st, counter)	\
+do {						\
+	u64_stats_update_begin(&(st)->syncp);	\
+	(st)->counter++;			\
+	u64_stats_update_end(&(st)->syncp);	\
+} while (0)
+
+#define SLIC_GET_STATS_COUNTER(newst, st, counter)			\
+{									\
+	unsigned int start;						\
+	do {							\
+		start = u64_stats_fetch_begin_irq(&(st)->syncp);	\
+		newst = (st)->counter;					\
+	} while (u64_stats_fetch_retry_irq(&(st)->syncp, start));	\
+}
+
+struct slic_upr {
+	dma_addr_t paddr;
+	unsigned int type;
+	struct list_head list;
+};
+
+struct slic_upr_list {
+	bool pending;
+	struct list_head list;
+	/* upr list lock */
+	spinlock_t lock;
+};
+
+/* SLIC EEPROM structure for Oasis */
+struct slic_mojave_eeprom {
+	__le16 id;		/* 00 EEPROM/FLASH Magic code 'A5A5'*/
+	__le16 eeprom_code_size;/* 01 Size of EEPROM Codes (bytes * 4)*/
+	__le16 flash_size;	/* 02 Flash size */
+	__le16 eeprom_size;	/* 03 EEPROM Size */
+	__le16 vendor_id;	/* 04 Vendor ID */
+	__le16 dev_id;		/* 05 Device ID */
+	u8 rev_id;		/* 06 Revision ID */
+	u8 class_code[3];	/* 07 Class Code */
+	u8 irqpin_dbg;		/* 08 Debug Interrupt pin */
+	u8 irqpin;		/*    Network Interrupt Pin */
+	u8 min_grant;		/* 09 Minimum grant */
+	u8 max_lat;		/*    Maximum Latency */
+	__le16 pci_stat;	/* 10 PCI Status */
+	__le16 sub_vendor_id;	/* 11 Subsystem Vendor Id */
+	__le16 sub_id;		/* 12 Subsystem ID */
+	__le16 dev_id_dbg;	/* 13 Debug Device Id */
+	__le16 ramrom;		/* 14 Dram/Rom function */
+	__le16 dram_size2pci;	/* 15 DRAM size to PCI (bytes * 64K) */
+	__le16 rom_size2pci;	/* 16 ROM extension size to PCI (bytes * 4k) */
+	u8 pad[2];		/* 17 Padding */
+	u8 freetime;		/* 18 FreeTime setting */
+	u8 ifctrl;		/* 10-bit interface control (Mojave only) */
+	__le16 dram_size;	/* 19 DRAM size (bytes * 64k) */
+	u8 mac[ETH_ALEN];	/* 20 MAC addresses */
+	u8 mac2[ETH_ALEN];
+	u8 pad2[6];
+	u16 dev_id2;		/* Device ID for 2nd PCI function */
+	u8 irqpin2;		/* Interrupt pin for 2nd PCI function */
+	u8 class_code2[3];	/* Class Code for 2nd PCI function */
+	u16 cfg_byte6;		/* Config Byte 6 */
+	u16 pme_cap;		/* Power Mgment capabilities */
+	u16 nwclk_ctrl;		/* NetworkClockControls */
+	u8 fru_format;		/* Alacritech FRU format type */
+	u8 fru_assembly[6];	/* Alacritech FRU information */
+	u8 fru_rev[2];
+	u8 fru_serial[14];
+	u8 fru_pad[3];
+	u8 oem_fru[28];		/* optional OEM FRU format type */
+	u8 pad3[4];		/* Pad to 128 bytes - includes 2 cksum bytes
+				 * (if OEM FRU info exists) and two unusable
+				 * bytes at the end
+				 */
+};
+
+/* SLIC EEPROM structure for Oasis */
+struct slic_oasis_eeprom {
+	__le16 id;		/* 00 EEPROM/FLASH Magic code 'A5A5' */
+	__le16 eeprom_code_size;/* 01 Size of EEPROM Codes (bytes * 4)*/
+	__le16 spidev0_cfg;	/* 02 Flash Config for SPI device 0 */
+	__le16 spidev1_cfg;	/* 03 Flash Config for SPI device 1 */
+	__le16 vendor_id;	/* 04 Vendor ID */
+	__le16 dev_id;		/* 05 Device ID (function 0) */
+	u8 rev_id;		/* 06 Revision ID */
+	u8 class_code0[3];	/* 07 Class Code for PCI function 0 */
+	u8 irqpin1;		/* 08 Interrupt pin for PCI function 1*/
+	u8 class_code1[3];	/* 09 Class Code for PCI function 1 */
+	u8 irqpin2;		/* 10 Interrupt pin for PCI function 2*/
+	u8 irqpin0;		/*    Interrupt pin for PCI function 0*/
+	u8 min_grant;		/* 11 Minimum grant */
+	u8 max_lat;		/*    Maximum Latency */
+	__le16 sub_vendor_id;	/* 12 Subsystem Vendor Id */
+	__le16 sub_id;		/* 13 Subsystem ID */
+	__le16 flash_size;	/* 14 Flash size (bytes / 4K) */
+	__le16 dram_size2pci;	/* 15 DRAM size to PCI (bytes / 64K) */
+	__le16 rom_size2pci;	/* 16 Flash (ROM extension) size to PCI
+				 *   (bytes / 4K)
+				 */
+	__le16 dev_id1;		/* 17 Device Id (function 1) */
+	__le16 dev_id2;		/* 18 Device Id (function 2) */
+	__le16 dev_stat_cfg;	/* 19 Device Status Config Bytes 6-7 */
+	__le16 pme_cap;		/* 20 Power Mgment capabilities */
+	u8 msi_cap;		/* 21 MSI capabilities */
+	u8 clock_div;		/*    Clock divider */
+	__le16 pci_stat_lo;	/* 22 PCI Status bits 15:0 */
+	__le16 pci_stat_hi;	/* 23 PCI Status bits 31:16 */
+	__le16 dram_cfg_lo;	/* 24 DRAM Configuration bits 15:0 */
+	__le16 dram_cfg_hi;	/* 25 DRAM Configuration bits 31:16 */
+	__le16 dram_size;	/* 26 DRAM size (bytes / 64K) */
+	__le16 gpio_tbi_ctrl;	/* 27 GPIO/TBI controls for functions 1/0 */
+	__le16 eeprom_size;	/* 28 EEPROM Size */
+	u8 mac[ETH_ALEN];	/* 29 MAC addresses (2 ports) */
+	u8 mac2[ETH_ALEN];
+	u8 fru_format;		/* 35 Alacritech FRU format type */
+	u8 fru_assembly[6];	/* Alacritech FRU information */
+	u8 fru_rev[2];
+	u8 fru_serial[14];
+	u8 fru_pad[3];
+	u8 oem_fru[28];		/* optional OEM FRU information */
+	u8 pad[4];		/* Pad to 128 bytes - includes 2 checksum bytes
+				 * (if OEM FRU info exists) and two unusable
+				 * bytes at the end
+				 */
+};
+
+struct slic_stats {
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_mcasts;
+	u64 rx_errors;
+	u64 tx_packets;
+	u64 tx_bytes;
+	/* HW STATS */
+	u64 rx_buff_miss;
+	u64 tx_dropped;
+	u64 irq_errs;
+	/* transport layer */
+	u64 rx_tpcsum;
+	u64 rx_tpoflow;
+	u64 rx_tphlen;
+	/* ip layer */
+	u64 rx_ipcsum;
+	u64 rx_iplen;
+	u64 rx_iphlen;
+	/* link layer */
+	u64 rx_early;
+	u64 rx_buffoflow;
+	u64 rx_lcode;
+	u64 rx_drbl;
+	u64 rx_crc;
+	u64 rx_oflow802;
+	u64 rx_uflow802;
+	/* oasis only */
+	u64 tx_carrier;
+	struct u64_stats_sync syncp;
+};
+
+struct slic_shmem_data {
+	__le32 isr;
+	__le32 link;
+};
+
+struct slic_shmem {
+	dma_addr_t isr_paddr;
+	dma_addr_t link_paddr;
+	struct slic_shmem_data *shmem_data;
+};
+
+struct slic_rx_info_oasis {
+	__le32 frame_status;
+	__le32 frame_status_b;
+	__le32 time_stamp;
+	__le32 checksum;
+};
+
+struct slic_rx_info_mojave {
+	__le32 frame_status;
+	__le16 byte_cnt;
+	__le16 tp_chksum;
+	__le16 ctx_hash;
+	__le16 mac_hash;
+	__le16 buff_lnk;
+};
+
+struct slic_stat_desc {
+	__le32 hnd;
+	__u8 pad[8];
+	__le32 status;
+	__u8 pad2[16];
+};
+
+struct slic_stat_queue {
+	struct slic_stat_desc *descs[SLIC_NUM_STAT_DESC_ARRAYS];
+	dma_addr_t paddr[SLIC_NUM_STAT_DESC_ARRAYS];
+	unsigned int addr_offset[SLIC_NUM_STAT_DESC_ARRAYS];
+	unsigned int active_array;
+	unsigned int len;
+	unsigned int done_idx;
+	size_t mem_size;
+};
+
+struct slic_tx_desc {
+	__le32 hnd;
+	__le32 rsvd;
+	u8 cmd;
+	u8 flags;
+	__le16 rsvd2;
+	__le32 totlen;
+	__le32 paddrl;
+	__le32 paddrh;
+	__le32 len;
+	__le32 type;
+};
+
+struct slic_tx_buffer {
+	struct sk_buff *skb;
+	DEFINE_DMA_UNMAP_ADDR(map_addr);
+	DEFINE_DMA_UNMAP_LEN(map_len);
+	struct slic_tx_desc *desc;
+	dma_addr_t desc_paddr;
+};
+
+struct slic_tx_queue {
+	struct dma_pool *dma_pool;
+	struct slic_tx_buffer *txbuffs;
+	unsigned int len;
+	unsigned int put_idx;
+	unsigned int done_idx;
+};
+
+struct slic_rx_desc {
+	u8 pad[16];
+	__le32 buffer;
+	__le32 length;
+	__le32 status;
+};
+
+struct slic_rx_buffer {
+	struct sk_buff *skb;
+	DEFINE_DMA_UNMAP_ADDR(map_addr);
+	DEFINE_DMA_UNMAP_LEN(map_len);
+	unsigned int addr_offset;
+};
+
+struct slic_rx_queue {
+	struct slic_rx_buffer *rxbuffs;
+	unsigned int len;
+	unsigned int done_idx;
+	unsigned int put_idx;
+};
+
+struct slic_device {
+	struct pci_dev *pdev;
+	struct net_device *netdev;
+	void __iomem *regs;
+	/* upper address setting lock */
+	spinlock_t upper_lock;
+	struct slic_shmem shmem;
+	struct napi_struct napi;
+	struct slic_rx_queue rxq;
+	struct slic_tx_queue txq;
+	struct slic_stat_queue stq;
+	struct slic_stats stats;
+	struct slic_upr_list upr_list;
+	/* link configuration lock */
+	spinlock_t link_lock;
+	bool promisc;
+	bool autoneg;
+	int speed;
+	int duplex;
+	bool is_fiber;
+	unsigned char model;
+};
+
+static inline u32 slic_read(struct slic_device *sdev, unsigned int reg)
+{
+	return ioread32(sdev->regs + reg);
+}
+
+static inline void slic_write(struct slic_device *sdev, unsigned int reg,
+			      u32 val)
+{
+	iowrite32(val, sdev->regs + reg);
+}
+
+static inline void slic_flush_write(struct slic_device *sdev)
+{
+	(void)ioread32(sdev->regs + SLIC_REG_HOSTID);
+}
+
+#endif /* _SLIC_H */
diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
new file mode 100644
index 0000000..8beefb0
--- /dev/null
+++ b/drivers/net/ethernet/alacritech/slicoss.c
@@ -0,0 +1,1855 @@
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/crc32.h>
+#include <linux/dma-mapping.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/firmware.h>
+#include <linux/list.h>
+#include <linux/u64_stats_sync.h>
+
+#include "slic.h"
+
+#define DRV_NAME			"slicoss"
+#define DRV_VERSION			"1.0"
+
+static const struct pci_device_id slic_id_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_ALACRITECH,
+		     PCI_DEVICE_ID_ALACRITECH_MOAVE) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_ALACRITECH,
+		     PCI_DEVICE_ID_ALACRITECH_OASIS) },
+	{ 0 }
+};
+
+static const char slic_stats_strings[][ETH_GSTRING_LEN] = {
+	"rx_packets     ",
+	"rx_bytes       ",
+	"rx_multicasts  ",
+	"rx_errors      ",
+	"rx_buff_miss   ",
+	"rx_tp_csum     ",
+	"rx_tp_oflow    ",
+	"rx_tp_hlen     ",
+	"rx_ip_csum     ",
+	"rx_ip_len      ",
+	"rx_ip_hdr_len  ",
+	"rx_early       ",
+	"rx_buff_oflow  ",
+	"rx_lcode       ",
+	"rx_drbl        ",
+	"rx_crc         ",
+	"rx_oflow_802   ",
+	"rx_uflow_802   ",
+	"tx_packets     ",
+	"tx_bytes       ",
+	"tx_carrier     ",
+	"tx_dropped     ",
+	"irq_errs       ",
+};
+
+static inline int slic_next_queue_idx(unsigned int idx, unsigned int qlen)
+{
+	return (idx + 1) & (qlen - 1);
+}
+
+static inline int slic_get_free_queue_descs(unsigned int put_idx,
+					    unsigned int done_idx,
+					    unsigned int qlen)
+{
+	if (put_idx >= done_idx)
+		return (qlen - (put_idx - done_idx) - 1);
+	return (done_idx - put_idx - 1);
+}
+
+static unsigned int slic_next_compl_idx(struct slic_device *sdev)
+{
+	struct slic_stat_queue *stq = &sdev->stq;
+	unsigned int active = stq->active_array;
+	struct slic_stat_desc *descs;
+	struct slic_stat_desc *stat;
+	unsigned int idx;
+
+	descs = stq->descs[active];
+	stat = &descs[stq->done_idx];
+
+	if (!stat->status)
+		return SLIC_INVALID_STAT_DESC_IDX;
+
+	idx = (le32_to_cpu(stat->hnd) & 0xffff) - 1;
+	/* reset desc */
+	stat->hnd = 0;
+	stat->status = 0;
+
+	stq->done_idx = slic_next_queue_idx(stq->done_idx, stq->len);
+	/* check for wraparound */
+	if (!stq->done_idx) {
+		dma_addr_t paddr = stq->paddr[active];
+
+		slic_write(sdev, SLIC_REG_RBAR, lower_32_bits(paddr) |
+						stq->len);
+		/* make sure new status descriptors are immediately available */
+		slic_flush_write(sdev);
+		active++;
+		active &= (SLIC_NUM_STAT_DESC_ARRAYS - 1);
+		stq->active_array = active;
+	}
+	return idx;
+}
+
+static unsigned int slic_get_free_tx_descs(struct slic_tx_queue *txq)
+{
+	/* ensure tail idx is updated */
+	smp_mb();
+	return slic_get_free_queue_descs(txq->put_idx, txq->done_idx, txq->len);
+}
+
+static unsigned int slic_get_free_rx_descs(struct slic_rx_queue *rxq)
+{
+	return slic_get_free_queue_descs(rxq->put_idx, rxq->done_idx, rxq->len);
+}
+
+static void slic_clear_upr_list(struct slic_upr_list *upr_list)
+{
+	struct slic_upr *upr;
+	struct slic_upr *tmp;
+
+	spin_lock_bh(&upr_list->lock);
+	list_for_each_entry_safe(upr, tmp, &upr_list->list, list) {
+		list_del(&upr->list);
+		kfree(upr);
+	}
+	upr_list->pending = false;
+	spin_unlock_bh(&upr_list->lock);
+}
+
+static void slic_start_upr(struct slic_device *sdev, struct slic_upr *upr)
+{
+	u32 reg;
+
+	switch (upr->type) {
+	case SLIC_UPR_STATS:
+		reg = SLIC_REG_RSTAT;
+		break;
+	case SLIC_UPR_CONFIG:
+		reg = SLIC_REG_RCONFIG;
+		break;
+	default:
+		reg = SLIC_REG_LSTAT;
+	}
+	slic_write(sdev, reg, lower_32_bits(upr->paddr));
+	slic_flush_write(sdev);
+}
+
+static void slic_queue_upr(struct slic_device *sdev, struct slic_upr *upr)
+{
+	struct slic_upr_list *upr_list = &sdev->upr_list;
+	bool pending;
+
+	spin_lock_bh(&upr_list->lock);
+	pending = upr_list->pending;
+	INIT_LIST_HEAD(&upr->list);
+	list_add_tail(&upr->list, &upr_list->list);
+	upr_list->pending = true;
+	spin_unlock_bh(&upr_list->lock);
+
+	if (!pending)
+		slic_start_upr(sdev, upr);
+}
+
+static struct slic_upr *slic_dequeue_upr(struct slic_device *sdev)
+{
+	struct slic_upr_list *upr_list = &sdev->upr_list;
+	struct slic_upr *next_upr = NULL;
+	struct slic_upr *upr = NULL;
+
+	spin_lock_bh(&upr_list->lock);
+	if (!list_empty(&upr_list->list)) {
+		upr = list_first_entry(&upr_list->list, struct slic_upr, list);
+		list_del(&upr->list);
+
+		if (list_empty(&upr_list->list))
+			upr_list->pending = false;
+		else
+			next_upr = list_first_entry(&upr_list->list,
+						    struct slic_upr, list);
+	}
+	spin_unlock_bh(&upr_list->lock);
+	/* trigger processing of next upr in list */
+	if (next_upr)
+		slic_start_upr(sdev, next_upr);
+
+	return upr;
+}
+
+static int slic_new_upr(struct slic_device *sdev, unsigned int type,
+			dma_addr_t paddr)
+{
+	struct slic_upr *upr;
+
+	upr = kmalloc(sizeof(*upr), GFP_ATOMIC);
+	if (!upr)
+		return -ENOMEM;
+	upr->type = type;
+	upr->paddr = paddr;
+
+	slic_queue_upr(sdev, upr);
+
+	return 0;
+}
+
+static void slic_set_mcast_bit(u64 *mcmask, unsigned char const *addr)
+{
+	u64 mask = *mcmask;
+	u8 crc;
+	/* Get the CRC polynomial for the mac address: we use bits 1-8 (lsb),
+	 * bitwise reversed, * msb (= lsb bit 0 before bitrev) is automatically
+	 * discarded.
+	 */
+	crc = ether_crc(ETH_ALEN, addr) >> 23;
+	 /* We only have space on the SLIC for 64 entries */
+	crc &= 0x3F;
+	mask |= (u64)1 << crc;
+	*mcmask = mask;
+}
+
+/* must be called with link_lock held */
+static void slic_configure_rcv(struct slic_device *sdev)
+{
+	u32 val;
+
+	val = SLIC_GRCR_RESET | SLIC_GRCR_ADDRAEN | SLIC_GRCR_RCVEN |
+	      SLIC_GRCR_HASHSIZE << SLIC_GRCR_HASHSIZE_SHIFT | SLIC_GRCR_RCVBAD;
+
+	if (sdev->duplex == DUPLEX_FULL)
+		val |= SLIC_GRCR_CTLEN;
+
+	if (sdev->promisc)
+		val |= SLIC_GRCR_RCVALL;
+
+	slic_write(sdev, SLIC_REG_WRCFG, val);
+}
+
+/* must be called with link_lock held */
+static void slic_configure_xmt(struct slic_device *sdev)
+{
+	u32 val;
+
+	val = SLIC_GXCR_RESET | SLIC_GXCR_XMTEN;
+
+	if (sdev->duplex == DUPLEX_FULL)
+		val |= SLIC_GXCR_PAUSEEN;
+
+	slic_write(sdev, SLIC_REG_WXCFG, val);
+}
+
+/* must be called with link_lock held */
+static void slic_configure_mac(struct slic_device *sdev)
+{
+	u32 val;
+
+	if (sdev->speed == SPEED_1000) {
+		val = SLIC_GMCR_GAPBB_1000 << SLIC_GMCR_GAPBB_SHIFT |
+		      SLIC_GMCR_GAPR1_1000 << SLIC_GMCR_GAPR1_SHIFT |
+		      SLIC_GMCR_GAPR2_1000 << SLIC_GMCR_GAPR2_SHIFT |
+		      SLIC_GMCR_GBIT; /* enable GMII */
+	} else {
+		val = SLIC_GMCR_GAPBB_100 << SLIC_GMCR_GAPBB_SHIFT |
+		      SLIC_GMCR_GAPR1_100 << SLIC_GMCR_GAPR1_SHIFT |
+		      SLIC_GMCR_GAPR2_100 << SLIC_GMCR_GAPR2_SHIFT;
+	}
+
+	if (sdev->duplex == DUPLEX_FULL)
+		val |= SLIC_GMCR_FULLD;
+
+	slic_write(sdev, SLIC_REG_WMCFG, val);
+}
+
+static void slic_configure_link_locked(struct slic_device *sdev,
+				       unsigned int speed, unsigned int duplex)
+{
+	struct net_device *dev = sdev->netdev;
+
+	if (sdev->speed == speed && sdev->duplex == duplex)
+		return;
+
+	sdev->speed = speed;
+	sdev->duplex = duplex;
+
+	if (sdev->speed == SPEED_UNKNOWN) {
+		if (netif_carrier_ok(dev))
+			netif_carrier_off(dev);
+	} else {
+		/* (re)configure link settings */
+		slic_configure_mac(sdev);
+		slic_configure_xmt(sdev);
+		slic_configure_rcv(sdev);
+
+		if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
+	}
+}
+
+static void slic_configure_link(struct slic_device *sdev, unsigned int speed,
+				unsigned int duplex)
+{
+	spin_lock_bh(&sdev->link_lock);
+	slic_configure_link_locked(sdev, speed, duplex);
+	spin_unlock_bh(&sdev->link_lock);
+}
+
+static void slic_set_rx_mode(struct net_device *dev)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	struct netdev_hw_addr *hwaddr;
+	bool set_promisc;
+	u64 mcmask;
+
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		/* Turn on all multicast addresses. We have to do this for
+		 * promiscuous mode as well as ALLMCAST mode (it saves the
+		 * Microcode from having to keep state about the MAC
+		 * configuration).
+		 */
+		mcmask = ~(u64)0;
+	} else  {
+		mcmask = 0;
+
+		netdev_for_each_mc_addr(hwaddr, dev) {
+			slic_set_mcast_bit(&mcmask, hwaddr->addr);
+		}
+	}
+
+	slic_write(sdev, SLIC_REG_MCASTLOW, lower_32_bits(mcmask));
+	slic_write(sdev, SLIC_REG_MCASTHIGH, upper_32_bits(mcmask));
+
+	set_promisc = !!(dev->flags & IFF_PROMISC);
+
+	spin_lock_bh(&sdev->link_lock);
+	if (sdev->promisc != set_promisc) {
+		sdev->promisc = set_promisc;
+		slic_configure_rcv(sdev);
+	}
+	spin_unlock_bh(&sdev->link_lock);
+}
+
+static void slic_xmit_complete(struct slic_device *sdev)
+{
+	struct slic_tx_queue *txq = &sdev->txq;
+	struct net_device *dev = sdev->netdev;
+	unsigned int idx = txq->done_idx;
+	struct slic_tx_buffer *buff;
+	unsigned int frames = 0;
+	unsigned int bytes = 0;
+
+	do {
+		idx = slic_next_compl_idx(sdev);
+		if (idx == SLIC_INVALID_STAT_DESC_IDX)
+			break;
+
+		txq->done_idx = idx;
+		buff = &txq->txbuffs[idx];
+
+		if (unlikely(!buff->skb)) {
+			netdev_warn(dev,
+				    "no skb found for desc idx %i\n", idx);
+			continue;
+		}
+		dma_unmap_single(&sdev->pdev->dev,
+				 dma_unmap_addr(buff, map_addr),
+				 dma_unmap_len(buff, map_len), DMA_TO_DEVICE);
+
+		bytes += buff->skb->len;
+		frames++;
+
+		dev_kfree_skb_any(buff->skb);
+		buff->skb = NULL;
+	} while (frames < SLIC_MAX_TX_COMPLETIONS);
+
+	u64_stats_update_begin(&sdev->stats.syncp);
+	sdev->stats.tx_bytes += bytes;
+	sdev->stats.tx_packets += frames;
+	u64_stats_update_end(&sdev->stats.syncp);
+	/* make sure done_idx is updated for any other CPU */
+	smp_wmb();
+
+	netif_tx_lock(dev);
+	if (netif_queue_stopped(dev) &&
+	    (slic_get_free_tx_descs(txq) >= SLIC_MIN_TX_WAKEUP_DESCS))
+		netif_wake_queue(dev);
+	netif_tx_unlock(dev);
+}
+
+static void slic_refill_rx_queue(struct slic_device *sdev, gfp_t gfp)
+{
+	const unsigned int ALIGN_MASK = SLIC_RX_BUFF_ALIGN - 1;
+	unsigned int maplen = SLIC_RX_BUFF_SIZE;
+	struct slic_rx_queue *rxq = &sdev->rxq;
+	struct net_device *dev = sdev->netdev;
+	struct slic_rx_buffer *buff;
+	struct slic_rx_desc *desc;
+	unsigned int misalign;
+	unsigned int offset;
+	struct sk_buff *skb;
+	dma_addr_t paddr;
+
+	while (slic_get_free_rx_descs(rxq) > SLIC_MAX_REQ_RX_DESCS) {
+		skb = alloc_skb(maplen + ALIGN_MASK, gfp);
+		if (!skb)
+			break;
+
+		paddr = dma_map_single(&sdev->pdev->dev, skb->data, maplen,
+				       DMA_FROM_DEVICE);
+		if (dma_mapping_error(&sdev->pdev->dev, paddr)) {
+			netdev_err(dev, "mapping rx packet failed\n");
+			/* drop skb */
+			dev_kfree_skb_any(skb);
+			break;
+		}
+		/* ensure head buffer descriptors are 256 bytes aligned */
+		offset = 0;
+		misalign = paddr & ALIGN_MASK;
+		if (misalign) {
+			offset = SLIC_RX_BUFF_ALIGN - misalign;
+			skb_reserve(skb, offset);
+		}
+		/* The HW expects dma chunks for descriptor + frame data. */
+		desc = (struct slic_rx_desc *)skb->data;
+		memset(desc, 0, sizeof(*desc));
+
+		buff = &rxq->rxbuffs[rxq->put_idx];
+		buff->skb = skb;
+		dma_unmap_addr_set(buff, map_addr, paddr);
+		dma_unmap_len_set(buff, map_len, maplen);
+		buff->addr_offset = offset;
+		/* head buffer descriptors are placed immedialy before skb */
+		slic_write(sdev, SLIC_REG_HBAR, lower_32_bits(paddr) +
+						offset);
+		rxq->put_idx = slic_next_queue_idx(rxq->put_idx, rxq->len);
+	}
+}
+
+static void slic_handle_frame_error(struct slic_device *sdev,
+				    struct sk_buff *skb)
+{
+	struct slic_stats *stats = &sdev->stats;
+
+	if (sdev->model == SLIC_MODEL_OASIS) {
+		struct slic_rx_info_oasis *info;
+		u32 status_b;
+		u32 status;
+
+		info = (struct slic_rx_info_oasis *)skb->data;
+		status = le32_to_cpu(info->frame_status);
+		status_b = le32_to_cpu(info->frame_status_b);
+		/* transport layer */
+		if (status_b & SLIC_VRHSTATB_TPCSUM)
+			SLIC_INC_STATS_COUNTER(stats, rx_tpcsum);
+		if (status & SLIC_VRHSTAT_TPOFLO)
+			SLIC_INC_STATS_COUNTER(stats, rx_tpoflow);
+		if (status_b & SLIC_VRHSTATB_TPHLEN)
+			SLIC_INC_STATS_COUNTER(stats, rx_tphlen);
+		/* ip layer */
+		if (status_b & SLIC_VRHSTATB_IPCSUM)
+			SLIC_INC_STATS_COUNTER(stats, rx_ipcsum);
+		if (status_b & SLIC_VRHSTATB_IPLERR)
+			SLIC_INC_STATS_COUNTER(stats, rx_iplen);
+		if (status_b & SLIC_VRHSTATB_IPHERR)
+			SLIC_INC_STATS_COUNTER(stats, rx_iphlen);
+		/* link layer */
+		if (status_b & SLIC_VRHSTATB_RCVE)
+			SLIC_INC_STATS_COUNTER(stats, rx_early);
+		if (status_b & SLIC_VRHSTATB_BUFF)
+			SLIC_INC_STATS_COUNTER(stats, rx_buffoflow);
+		if (status_b & SLIC_VRHSTATB_CODE)
+			SLIC_INC_STATS_COUNTER(stats, rx_lcode);
+		if (status_b & SLIC_VRHSTATB_DRBL)
+			SLIC_INC_STATS_COUNTER(stats, rx_drbl);
+		if (status_b & SLIC_VRHSTATB_CRC)
+			SLIC_INC_STATS_COUNTER(stats, rx_crc);
+		if (status & SLIC_VRHSTAT_802OE)
+			SLIC_INC_STATS_COUNTER(stats, rx_oflow802);
+		if (status_b & SLIC_VRHSTATB_802UE)
+			SLIC_INC_STATS_COUNTER(stats, rx_uflow802);
+		if (status_b & SLIC_VRHSTATB_CARRE)
+			SLIC_INC_STATS_COUNTER(stats, tx_carrier);
+	} else { /* mojave */
+		struct slic_rx_info_mojave *info;
+		u32 status;
+
+		info = (struct slic_rx_info_mojave *)skb->data;
+		status = le32_to_cpu(info->frame_status);
+		/* transport layer */
+		if (status & SLIC_VGBSTAT_XPERR) {
+			u32 xerr = status >> SLIC_VGBSTAT_XERRSHFT;
+
+			if (xerr == SLIC_VGBSTAT_XCSERR)
+				SLIC_INC_STATS_COUNTER(stats, rx_tpcsum);
+			if (xerr == SLIC_VGBSTAT_XUFLOW)
+				SLIC_INC_STATS_COUNTER(stats, rx_tpoflow);
+			if (xerr == SLIC_VGBSTAT_XHLEN)
+				SLIC_INC_STATS_COUNTER(stats, rx_tphlen);
+		}
+		/* ip layer */
+		if (status & SLIC_VGBSTAT_NETERR) {
+			u32 nerr = status >> SLIC_VGBSTAT_NERRSHFT &
+				   SLIC_VGBSTAT_NERRMSK;
+
+			if (nerr == SLIC_VGBSTAT_NCSERR)
+				SLIC_INC_STATS_COUNTER(stats, rx_ipcsum);
+			if (nerr == SLIC_VGBSTAT_NUFLOW)
+				SLIC_INC_STATS_COUNTER(stats, rx_iplen);
+			if (nerr == SLIC_VGBSTAT_NHLEN)
+				SLIC_INC_STATS_COUNTER(stats, rx_iphlen);
+		}
+		/* link layer */
+		if (status & SLIC_VGBSTAT_LNKERR) {
+			u32 lerr = status & SLIC_VGBSTAT_LERRMSK;
+
+			if (lerr == SLIC_VGBSTAT_LDEARLY)
+				SLIC_INC_STATS_COUNTER(stats, rx_early);
+			if (lerr == SLIC_VGBSTAT_LBOFLO)
+				SLIC_INC_STATS_COUNTER(stats, rx_buffoflow);
+			if (lerr == SLIC_VGBSTAT_LCODERR)
+				SLIC_INC_STATS_COUNTER(stats, rx_lcode);
+			if (lerr == SLIC_VGBSTAT_LDBLNBL)
+				SLIC_INC_STATS_COUNTER(stats, rx_drbl);
+			if (lerr == SLIC_VGBSTAT_LCRCERR)
+				SLIC_INC_STATS_COUNTER(stats, rx_crc);
+			if (lerr == SLIC_VGBSTAT_LOFLO)
+				SLIC_INC_STATS_COUNTER(stats, rx_oflow802);
+			if (lerr == SLIC_VGBSTAT_LUFLO)
+				SLIC_INC_STATS_COUNTER(stats, rx_uflow802);
+		}
+	}
+	SLIC_INC_STATS_COUNTER(stats, rx_errors);
+}
+
+static void slic_handle_receive(struct slic_device *sdev, unsigned int todo,
+				unsigned int *done)
+{
+	struct slic_rx_queue *rxq = &sdev->rxq;
+	struct net_device *dev = sdev->netdev;
+	struct slic_rx_buffer *buff;
+	struct slic_rx_desc *desc;
+	unsigned int frames = 0;
+	unsigned int bytes = 0;
+	struct sk_buff *skb;
+	u32 status;
+	u32 len;
+
+	while (todo && (rxq->done_idx != rxq->put_idx)) {
+		buff = &rxq->rxbuffs[rxq->done_idx];
+
+		skb = buff->skb;
+		if (!skb)
+			break;
+
+		desc = (struct slic_rx_desc *)skb->data;
+
+		dma_sync_single_for_cpu(&sdev->pdev->dev,
+					dma_unmap_addr(buff, map_addr),
+					buff->addr_offset + sizeof(*desc),
+					DMA_FROM_DEVICE);
+
+		status = le32_to_cpu(desc->status);
+		if (!(status & SLIC_IRHDDR_SVALID))
+			break;
+
+		buff->skb = NULL;
+
+		dma_unmap_single(&sdev->pdev->dev,
+				 dma_unmap_addr(buff, map_addr),
+				 dma_unmap_len(buff, map_len),
+				 DMA_FROM_DEVICE);
+
+		/* Skip rx descriptor that is placed before the frame data */
+		skb_reserve(skb, SLIC_RX_BUFF_HDR_SIZE);
+
+		if (unlikely(status & SLIC_IRHDDR_ERR)) {
+			slic_handle_frame_error(sdev, skb);
+			dev_kfree_skb_any(skb);
+		} else {
+			struct ethhdr *eh = (struct ethhdr *)skb->data;
+
+			if (is_multicast_ether_addr(eh->h_dest))
+				SLIC_INC_STATS_COUNTER(&sdev->stats, rx_mcasts);
+
+			len = le32_to_cpu(desc->length) & SLIC_IRHDDR_FLEN_MSK;
+			skb_put(skb, len);
+			skb->protocol = eth_type_trans(skb, dev);
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			skb->dev = dev;
+
+			napi_gro_receive(&sdev->napi, skb);
+
+			bytes += len;
+			frames++;
+		}
+		rxq->done_idx = slic_next_queue_idx(rxq->done_idx, rxq->len);
+		todo--;
+	}
+
+	u64_stats_update_begin(&sdev->stats.syncp);
+	sdev->stats.rx_bytes += bytes;
+	sdev->stats.rx_packets += frames;
+	u64_stats_update_end(&sdev->stats.syncp);
+
+	slic_refill_rx_queue(sdev, GFP_ATOMIC);
+}
+
+static void slic_handle_link_irq(struct slic_device *sdev)
+{
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+	unsigned int duplex;
+	unsigned int speed;
+	u32 link;
+
+	link = le32_to_cpu(sm_data->link);
+
+	if (link & SLIC_GIG_LINKUP) {
+		if (link & SLIC_GIG_SPEED_1000)
+			speed = SPEED_1000;
+		else if (link & SLIC_GIG_SPEED_100)
+			speed = SPEED_100;
+		else
+			speed = SPEED_10;
+
+		duplex = (link & SLIC_GIG_FULLDUPLEX) ? DUPLEX_FULL :
+							DUPLEX_HALF;
+	} else {
+		duplex = DUPLEX_UNKNOWN;
+		speed = SPEED_UNKNOWN;
+	}
+	slic_configure_link(sdev, speed, duplex);
+}
+
+static void slic_handle_upr_irq(struct slic_device *sdev, u32 irqs)
+{
+	struct slic_upr *upr;
+
+	/* remove upr that caused this irq (always the first entry in list) */
+	upr = slic_dequeue_upr(sdev);
+	if (!upr) {
+		netdev_warn(sdev->netdev, "no upr found on list\n");
+		return;
+	}
+
+	if (upr->type == SLIC_UPR_LSTAT) {
+		if (unlikely(irqs & SLIC_ISR_UPCERR_MASK)) {
+			/* try again */
+			slic_queue_upr(sdev, upr);
+			return;
+		}
+		slic_handle_link_irq(sdev);
+	}
+	kfree(upr);
+}
+
+static int slic_handle_link_change(struct slic_device *sdev)
+{
+	return slic_new_upr(sdev, SLIC_UPR_LSTAT, sdev->shmem.link_paddr);
+}
+
+static void slic_handle_err_irq(struct slic_device *sdev, u32 isr)
+{
+	struct slic_stats *stats = &sdev->stats;
+
+	if (isr & SLIC_ISR_RMISS)
+		SLIC_INC_STATS_COUNTER(stats, rx_buff_miss);
+	if (isr & SLIC_ISR_XDROP)
+		SLIC_INC_STATS_COUNTER(stats, tx_dropped);
+	if (!(isr & (SLIC_ISR_RMISS | SLIC_ISR_XDROP)))
+		SLIC_INC_STATS_COUNTER(stats, irq_errs);
+}
+
+static void slic_handle_irq(struct slic_device *sdev, u32 isr,
+			    unsigned int todo, unsigned int *done)
+{
+	if (isr & SLIC_ISR_ERR)
+		slic_handle_err_irq(sdev, isr);
+
+	if (isr & SLIC_ISR_LEVENT)
+		slic_handle_link_change(sdev);
+
+	if (isr & SLIC_ISR_UPC_MASK)
+		slic_handle_upr_irq(sdev, isr);
+
+	if (isr & SLIC_ISR_RCV)
+		slic_handle_receive(sdev, todo, done);
+
+	if (isr & SLIC_ISR_CMD)
+		slic_xmit_complete(sdev);
+}
+
+static int slic_poll(struct napi_struct *napi, int todo)
+{
+	struct slic_device *sdev = container_of(napi, struct slic_device, napi);
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+	u32 isr = le32_to_cpu(sm_data->isr);
+	unsigned int done = 0;
+
+	slic_handle_irq(sdev, isr, todo, &done);
+
+	if (done < todo) {
+		napi_complete(napi);
+		/* reenable irqs */
+		sm_data->isr = 0;
+		/* make sure sm_data->isr is cleard before irqs are reenabled */
+		wmb();
+		slic_write(sdev, SLIC_REG_ISR, 0);
+		slic_flush_write(sdev);
+	}
+
+	return done;
+}
+
+static irqreturn_t slic_irq(int irq, void *dev_id)
+{
+	struct slic_device *sdev = dev_id;
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+
+	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_MASK);
+	slic_flush_write(sdev);
+	/* make sure sm_data->isr is read after ICR_INT_MASK is set */
+	wmb();
+
+	if (!sm_data->isr) {
+		dma_rmb();
+		/* spurious interrupt */
+		slic_write(sdev, SLIC_REG_ISR, 0);
+		slic_flush_write(sdev);
+		return IRQ_NONE;
+	}
+
+	napi_schedule(&sdev->napi);
+
+	return IRQ_HANDLED;
+}
+
+static void slic_card_reset(struct slic_device *sdev)
+{
+	u16 cmd;
+
+	slic_write(sdev, SLIC_REG_RESET, SLIC_RESET_MAGIC);
+	/* flush write by means of config space */
+	pci_read_config_word(sdev->pdev, PCI_COMMAND, &cmd);
+	mdelay(1);
+}
+
+static int slic_init_stat_queue(struct slic_device *sdev)
+{
+	const unsigned int DESC_ALIGN_MASK = SLIC_STATS_DESC_ALIGN - 1;
+	struct slic_stat_queue *stq = &sdev->stq;
+	struct slic_stat_desc *descs;
+	unsigned int misalign;
+	unsigned int offset;
+	dma_addr_t paddr;
+	size_t size;
+	int err;
+	int i;
+
+	stq->len = SLIC_NUM_STAT_DESCS;
+	stq->active_array = 0;
+	stq->done_idx = 0;
+
+	size = stq->len * sizeof(*descs) + DESC_ALIGN_MASK;
+
+	for (i = 0; i < SLIC_NUM_STAT_DESC_ARRAYS; i++) {
+		descs = dma_zalloc_coherent(&sdev->pdev->dev, size, &paddr,
+					    GFP_KERNEL);
+		if (!descs) {
+			netdev_err(sdev->netdev,
+				   "failed to allocate status descriptors\n");
+			err = -ENOMEM;
+			goto free_descs;
+		}
+		/* ensure correct alignment */
+		offset = 0;
+		misalign = paddr & DESC_ALIGN_MASK;
+		if (misalign) {
+			offset = SLIC_STATS_DESC_ALIGN - misalign;
+			descs += offset;
+			paddr += offset;
+		}
+
+		slic_write(sdev, SLIC_REG_RBAR, lower_32_bits(paddr) |
+						stq->len);
+		stq->descs[i] = descs;
+		stq->paddr[i] = paddr;
+		stq->addr_offset[i] = offset;
+	}
+
+	stq->mem_size = size;
+
+	return 0;
+
+free_descs:
+	while (i--) {
+		dma_free_coherent(&sdev->pdev->dev, stq->mem_size,
+				  stq->descs[i] - stq->addr_offset[i],
+				  stq->paddr[i] - stq->addr_offset[i]);
+	}
+
+	return err;
+}
+
+static void slic_free_stat_queue(struct slic_device *sdev)
+{
+	struct slic_stat_queue *stq = &sdev->stq;
+	int i;
+
+	for (i = 0; i < SLIC_NUM_STAT_DESC_ARRAYS; i++) {
+		dma_free_coherent(&sdev->pdev->dev, stq->mem_size,
+				  stq->descs[i] - stq->addr_offset[i],
+				  stq->paddr[i] - stq->addr_offset[i]);
+	}
+}
+
+static int slic_init_tx_queue(struct slic_device *sdev)
+{
+	struct slic_tx_queue *txq = &sdev->txq;
+	struct slic_tx_buffer *buff;
+	struct slic_tx_desc *desc;
+	int err;
+	int i;
+
+	txq->len = SLIC_NUM_TX_DESCS;
+	txq->put_idx = 0;
+	txq->done_idx = 0;
+
+	txq->txbuffs = kcalloc(txq->len, sizeof(*buff), GFP_KERNEL);
+	if (!txq->txbuffs)
+		return -ENOMEM;
+
+	txq->dma_pool = dma_pool_create("slic_pool", &sdev->pdev->dev,
+					sizeof(*desc), SLIC_TX_DESC_ALIGN,
+					4096);
+	if (!txq->dma_pool) {
+		err = -ENOMEM;
+		netdev_err(sdev->netdev, "failed to create dma pool\n");
+		goto free_buffs;
+	}
+
+	for (i = 0; i < txq->len; i++) {
+		buff = &txq->txbuffs[i];
+		desc = dma_pool_zalloc(txq->dma_pool, GFP_KERNEL,
+				       &buff->desc_paddr);
+		if (!desc) {
+			netdev_err(sdev->netdev,
+				   "failed to alloc pool chunk (%i)\n", i);
+			err = -ENOMEM;
+			goto free_descs;
+		}
+
+		desc->hnd = cpu_to_le32((u32)(i + 1));
+		desc->cmd = SLIC_CMD_XMT_REQ;
+		desc->flags = 0;
+		desc->type = cpu_to_le32(SLIC_CMD_TYPE_DUMB);
+		buff->desc = desc;
+	}
+
+	return 0;
+
+free_descs:
+	while (i--) {
+		buff = &txq->txbuffs[i];
+		dma_pool_free(txq->dma_pool, buff->desc, buff->desc_paddr);
+	}
+	dma_pool_destroy(txq->dma_pool);
+
+free_buffs:
+	kfree(txq->txbuffs);
+
+	return err;
+}
+
+static void slic_free_tx_queue(struct slic_device *sdev)
+{
+	struct slic_tx_queue *txq = &sdev->txq;
+	struct slic_tx_buffer *buff;
+	int i;
+
+	for (i = 0; i < txq->len; i++) {
+		buff = &txq->txbuffs[i];
+		dma_pool_free(txq->dma_pool, buff->desc, buff->desc_paddr);
+		if (!buff->skb)
+			continue;
+
+		dma_unmap_single(&sdev->pdev->dev,
+				 dma_unmap_addr(buff, map_addr),
+				 dma_unmap_len(buff, map_len), DMA_TO_DEVICE);
+		consume_skb(buff->skb);
+	}
+	dma_pool_destroy(txq->dma_pool);
+
+	kfree(txq->txbuffs);
+}
+
+static int slic_init_rx_queue(struct slic_device *sdev)
+{
+	struct slic_rx_queue *rxq = &sdev->rxq;
+	struct slic_rx_buffer *buff;
+
+	rxq->len = SLIC_NUM_RX_LES;
+	rxq->done_idx = 0;
+	rxq->put_idx = 0;
+
+	buff = kcalloc(rxq->len, sizeof(*buff), GFP_KERNEL);
+	if (!buff)
+		return -ENOMEM;
+
+	rxq->rxbuffs = buff;
+	slic_refill_rx_queue(sdev, GFP_KERNEL);
+
+	return 0;
+}
+
+static void slic_free_rx_queue(struct slic_device *sdev)
+{
+	struct slic_rx_queue *rxq = &sdev->rxq;
+	struct slic_rx_buffer *buff;
+	int i;
+
+	/* free rx buffers */
+	for (i = 0; i < rxq->len; i++) {
+		buff = &rxq->rxbuffs[i];
+
+		if (!buff->skb)
+			continue;
+
+		dma_unmap_single(&sdev->pdev->dev,
+				 dma_unmap_addr(buff, map_addr),
+				 dma_unmap_len(buff, map_len),
+				 DMA_FROM_DEVICE);
+		consume_skb(buff->skb);
+	}
+	kfree(rxq->rxbuffs);
+}
+
+static void slic_set_link_autoneg(struct slic_device *sdev)
+{
+	unsigned int subid = sdev->pdev->subsystem_device;
+	u32 val;
+
+	if (sdev->is_fiber) {
+		/* We've got a fiber gigabit interface, and register 4 is
+		 * different in fiber mode than in copper mode.
+		 */
+		/* advertise FD only @1000 Mb */
+		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV1000XFD |
+		      SLIC_PAR_ASYMPAUSE_FIBER;
+		/* enable PAUSE frames */
+		slic_write(sdev, SLIC_REG_WPHY, val);
+		/* reset phy, enable auto-neg  */
+		val = MII_BMCR << 16 | SLIC_PCR_RESET | SLIC_PCR_AUTONEG |
+		      SLIC_PCR_AUTONEG_RST;
+		slic_write(sdev, SLIC_REG_WPHY, val);
+	} else {	/* copper gigabit */
+		/* We've got a copper gigabit interface, and register 4 is
+		 * different in copper mode than in fiber mode.
+		 */
+		/* advertise 10/100 Mb modes   */
+		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV100FD |
+		      SLIC_PAR_ADV100HD | SLIC_PAR_ADV10FD | SLIC_PAR_ADV10HD;
+		/* enable PAUSE frames  */
+		val |= SLIC_PAR_ASYMPAUSE;
+		/* required by the Cicada PHY  */
+		val |= SLIC_PAR_802_3;
+		slic_write(sdev, SLIC_REG_WPHY, val);
+
+		/* advertise FD only @1000 Mb  */
+		val = MII_CTRL1000 << 16 | SLIC_PGC_ADV1000FD;
+		slic_write(sdev, SLIC_REG_WPHY, val);
+
+		if (subid != PCI_SUBDEVICE_ID_ALACRITECH_CICADA) {
+			 /* if a Marvell PHY enable auto crossover */
+			val = SLIC_MIICR_REG_16 | SLIC_MRV_REG16_XOVERON;
+			slic_write(sdev, SLIC_REG_WPHY, val);
+
+			/* reset phy, enable auto-neg  */
+			val = MII_BMCR << 16 | SLIC_PCR_RESET |
+			      SLIC_PCR_AUTONEG | SLIC_PCR_AUTONEG_RST;
+			slic_write(sdev, SLIC_REG_WPHY, val);
+		} else {
+			/* enable and restart auto-neg (don't reset)  */
+			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
+			      SLIC_PCR_AUTONEG_RST;
+			slic_write(sdev, SLIC_REG_WPHY, val);
+		}
+	}
+	sdev->autoneg = true;
+}
+
+static void slic_set_mac_address(struct slic_device *sdev)
+{
+	u8 *addr = sdev->netdev->dev_addr;
+	u32 val;
+
+	val = addr[5] | addr[4] << 8 | addr[3] << 16 | addr[2] << 24;
+
+	slic_write(sdev, SLIC_REG_WRADDRAL, val);
+	slic_write(sdev, SLIC_REG_WRADDRBL, val);
+
+	val = addr[0] << 8 | addr[1];
+
+	slic_write(sdev, SLIC_REG_WRADDRAH, val);
+	slic_write(sdev, SLIC_REG_WRADDRBH, val);
+}
+
+static u32 slic_read_dword_from_firmware(const struct firmware *fw, int *offset)
+{
+	int idx = *offset;
+	__le32 val;
+
+	memcpy(&val, fw->data + *offset, sizeof(val));
+	idx += 4;
+	*offset = idx;
+
+	return le32_to_cpu(val);
+}
+
+MODULE_FIRMWARE(SLIC_RCV_FIRMWARE_MOAVE);
+MODULE_FIRMWARE(SLIC_RCV_FIRMWARE_OASIS);
+
+static int slic_load_rcvseq_firmware(struct slic_device *sdev)
+{
+	const struct firmware *fw;
+	const char *file;
+	u32 codelen;
+	int idx = 0;
+	u32 instr;
+	u32 addr;
+	int err;
+
+	file = (sdev->model == SLIC_MODEL_OASIS) ?  SLIC_RCV_FIRMWARE_OASIS :
+						    SLIC_RCV_FIRMWARE_MOAVE;
+	err = request_firmware(&fw, file, &sdev->pdev->dev);
+	if (err) {
+		dev_err(&sdev->pdev->dev,
+			"Failed to load receive sequencer firmware %s\n", file);
+		return err;
+	}
+	/* Do an initial sanity check concerning firmware size now. A further
+	 * check follows below.
+	 */
+	if (fw->size < SLIC_FIRMWARE_MIN_SIZE) {
+		dev_err(&sdev->pdev->dev,
+			"Invalid firmware size %zu (min %u expected)\n",
+			fw->size, SLIC_FIRMWARE_MIN_SIZE);
+		err = -EINVAL;
+		goto release;
+	}
+
+	codelen = slic_read_dword_from_firmware(fw, &idx);
+
+	/* Do another sanity check against firmware size */
+	if ((codelen + 4) > fw->size) {
+		dev_err(&sdev->pdev->dev,
+			"Invalid rcv-sequencer firmware size %zu\n", fw->size);
+		err = -EINVAL;
+		goto release;
+	}
+
+	/* download sequencer code to card */
+	slic_write(sdev, SLIC_REG_RCV_WCS, SLIC_RCVWCS_BEGIN);
+	for (addr = 0; addr < codelen; addr++) {
+		__le32 val;
+		/* write out instruction address */
+		slic_write(sdev, SLIC_REG_RCV_WCS, addr);
+
+		instr = slic_read_dword_from_firmware(fw, &idx);
+		/* write out the instruction data low addr */
+		slic_write(sdev, SLIC_REG_RCV_WCS, instr);
+
+		val = (__le32)fw->data[idx];
+		instr = le32_to_cpu(val);
+		idx++;
+		/* write out the instruction data high addr */
+		slic_write(sdev, SLIC_REG_RCV_WCS, instr);
+	}
+	/* finish download */
+	slic_write(sdev, SLIC_REG_RCV_WCS, SLIC_RCVWCS_FINISH);
+	slic_flush_write(sdev);
+release:
+	release_firmware(fw);
+
+	return 0;
+}
+
+MODULE_FIRMWARE(SLIC_FIRMWARE_MOAVE);
+MODULE_FIRMWARE(SLIC_FIRMWARE_OASIS);
+
+static int slic_load_firmware(struct slic_device *sdev)
+{
+	u32 sectstart[SLIC_FIRMWARE_MAX_SECTIONS];
+	u32 sectsize[SLIC_FIRMWARE_MAX_SECTIONS];
+	const struct firmware *fw;
+	unsigned int datalen;
+	const char *file;
+	int code_start;
+	u32 numsects;
+	int idx = 0;
+	u32 sect;
+	u32 instr;
+	u32 addr;
+	u32 base;
+	int err;
+	int i;
+
+	file = (sdev->model == SLIC_MODEL_OASIS) ?  SLIC_FIRMWARE_OASIS :
+						    SLIC_FIRMWARE_MOAVE;
+	err = request_firmware(&fw, file, &sdev->pdev->dev);
+	if (err) {
+		dev_err(&sdev->pdev->dev, "Failed to load firmware %s\n", file);
+		return err;
+	}
+	/* Do an initial sanity check concerning firmware size now. A further
+	 * check follows below.
+	 */
+	if (fw->size < SLIC_FIRMWARE_MIN_SIZE) {
+		dev_err(&sdev->pdev->dev,
+			"Invalid firmware size %zu (min is %u)\n", fw->size,
+			SLIC_FIRMWARE_MIN_SIZE);
+		err = -EINVAL;
+		goto release;
+	}
+
+	numsects = slic_read_dword_from_firmware(fw, &idx);
+	if (numsects == 0 || numsects > SLIC_FIRMWARE_MAX_SECTIONS) {
+		dev_err(&sdev->pdev->dev,
+			"Invalid number of sections in firmware: %u", numsects);
+		err = -EINVAL;
+		goto release;
+	}
+
+	datalen = numsects * 8 + 4;
+	for (i = 0; i < numsects; i++) {
+		sectsize[i] = slic_read_dword_from_firmware(fw, &idx);
+		datalen += sectsize[i];
+	}
+
+	/* Do another sanity check against firmware size */
+	if (datalen > fw->size) {
+		dev_err(&sdev->pdev->dev,
+			"Invalid firmware size %zu (expected >= %u)\n",
+			fw->size, datalen);
+		err = -EINVAL;
+		goto release;
+	}
+	/* Get sections */
+	for (i = 0; i < numsects; i++)
+		sectstart[i] = slic_read_dword_from_firmware(fw, &idx);
+
+	code_start = idx;
+	instr = slic_read_dword_from_firmware(fw, &idx);
+
+	for (sect = 0; sect < numsects; sect++) {
+		unsigned int ssize = sectsize[sect] >> 3;
+
+		base = sectstart[sect];
+
+		for (addr = 0; addr < ssize; addr++) {
+			/* Write out instruction address */
+			slic_write(sdev, SLIC_REG_WCS, base + addr);
+			/* Write out instruction to low addr */
+			slic_write(sdev, SLIC_REG_WCS, instr);
+			instr = slic_read_dword_from_firmware(fw, &idx);
+			/* Write out instruction to high addr */
+			slic_write(sdev, SLIC_REG_WCS, instr);
+			instr = slic_read_dword_from_firmware(fw, &idx);
+		}
+	}
+
+	idx = code_start;
+
+	for (sect = 0; sect < numsects; sect++) {
+		unsigned int ssize = sectsize[sect] >> 3;
+
+		instr = slic_read_dword_from_firmware(fw, &idx);
+		base = sectstart[sect];
+		if (base < 0x8000)
+			continue;
+
+		for (addr = 0; addr < ssize; addr++) {
+			/* Write out instruction address */
+			slic_write(sdev, SLIC_REG_WCS,
+				   SLIC_WCS_COMPARE | (base + addr));
+			/* Write out instruction to low addr */
+			slic_write(sdev, SLIC_REG_WCS, instr);
+			instr = slic_read_dword_from_firmware(fw, &idx);
+			/* Write out instruction to high addr */
+			slic_write(sdev, SLIC_REG_WCS, instr);
+			instr = slic_read_dword_from_firmware(fw, &idx);
+		}
+	}
+	slic_flush_write(sdev);
+	mdelay(10);
+	/* Everything OK, kick off the card */
+	slic_write(sdev, SLIC_REG_WCS, SLIC_WCS_START);
+	slic_flush_write(sdev);
+	/* wait long enough for ucode to init card and reach mainloop */
+	mdelay(20);
+release:
+	release_firmware(fw);
+
+	return err;
+}
+
+static int slic_init_shmem(struct slic_device *sdev)
+{
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data;
+	dma_addr_t paddr;
+
+	sm_data = dma_zalloc_coherent(&sdev->pdev->dev, sizeof(*sm_data),
+				      &paddr, GFP_KERNEL);
+	if (!sm_data) {
+		dev_err(&sdev->pdev->dev, "failed to allocate shared memory\n");
+		return -ENOMEM;
+	}
+
+	sm->shmem_data = sm_data;
+	sm->isr_paddr = paddr;
+	sm->link_paddr = paddr + offsetof(struct slic_shmem_data, link);
+
+	return 0;
+}
+
+static void slic_free_shmem(struct slic_device *sdev)
+{
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+
+	dma_free_coherent(&sdev->pdev->dev, sizeof(*sm_data), sm_data,
+			  sm->isr_paddr);
+}
+
+static int slic_init_iface(struct slic_device *sdev)
+{
+	struct slic_shmem *sm = &sdev->shmem;
+	int err;
+
+	sdev->upr_list.pending = false;
+
+	err = slic_init_shmem(sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to load firmware\n");
+		return err;
+	}
+
+	err = slic_load_firmware(sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to load firmware\n");
+		goto free_sm;
+	}
+
+	err = slic_load_rcvseq_firmware(sdev);
+	if (err) {
+		netdev_err(sdev->netdev,
+			   "failed to load firmware for receive sequencer\n");
+		goto free_sm;
+	}
+
+	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_OFF);
+	slic_flush_write(sdev);
+	mdelay(1);
+
+	err = slic_init_rx_queue(sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to init rx queue: %u\n", err);
+		goto free_sm;
+	}
+
+	err = slic_init_tx_queue(sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to init tx queue: %u\n", err);
+		goto free_rxq;
+	}
+
+	err = slic_init_stat_queue(sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to init status queue: %u\n",
+			   err);
+		goto free_txq;
+	}
+
+	slic_write(sdev, SLIC_REG_ISP, lower_32_bits(sm->isr_paddr));
+	napi_enable(&sdev->napi);
+	/* disable irq mitigation */
+	slic_write(sdev, SLIC_REG_INTAGG, 0);
+	slic_write(sdev, SLIC_REG_ISR, 0);
+	slic_flush_write(sdev);
+
+	slic_set_mac_address(sdev);
+
+	spin_lock_bh(&sdev->link_lock);
+	sdev->duplex = DUPLEX_UNKNOWN;
+	sdev->speed = SPEED_UNKNOWN;
+	spin_unlock_bh(&sdev->link_lock);
+
+	slic_set_link_autoneg(sdev);
+
+	err = request_irq(sdev->pdev->irq, slic_irq, IRQF_SHARED, DRV_NAME,
+			  sdev);
+	if (err) {
+		netdev_err(sdev->netdev, "failed to request irq: %u\n", err);
+		goto disable_napi;
+	}
+
+	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_ON);
+	slic_flush_write(sdev);
+	/* request initial link status */
+	err = slic_handle_link_change(sdev);
+	if (err)
+		netdev_warn(sdev->netdev,
+			    "failed to set initial link state: %u\n", err);
+	return 0;
+
+disable_napi:
+	napi_disable(&sdev->napi);
+	slic_free_stat_queue(sdev);
+free_txq:
+	slic_free_tx_queue(sdev);
+free_rxq:
+	slic_free_rx_queue(sdev);
+free_sm:
+	slic_free_shmem(sdev);
+	slic_card_reset(sdev);
+
+	return err;
+}
+
+static int slic_open(struct net_device *dev)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	int err;
+
+	netif_carrier_off(dev);
+
+	err = slic_init_iface(sdev);
+	if (err) {
+		netdev_err(dev, "failed to initialize interface: %i\n", err);
+		return err;
+	}
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int slic_close(struct net_device *dev)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	u32 val;
+
+	netif_stop_queue(dev);
+
+	/* stop irq handling */
+	napi_disable(&sdev->napi);
+	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_OFF);
+	slic_write(sdev, SLIC_REG_ISR, 0);
+	slic_flush_write(sdev);
+
+	free_irq(sdev->pdev->irq, sdev);
+	/* turn off RCV and XMT and power down PHY */
+	val = SLIC_GXCR_RESET | SLIC_GXCR_PAUSEEN;
+	slic_write(sdev, SLIC_REG_WXCFG, val);
+
+	val = SLIC_GRCR_RESET | SLIC_GRCR_CTLEN | SLIC_GRCR_ADDRAEN |
+	      SLIC_GRCR_HASHSIZE << SLIC_GRCR_HASHSIZE_SHIFT;
+	slic_write(sdev, SLIC_REG_WRCFG, val);
+
+	val = MII_BMCR << 16 | SLIC_PCR_POWERDOWN;
+	slic_write(sdev, SLIC_REG_WPHY, val);
+	slic_flush_write(sdev);
+
+	slic_clear_upr_list(&sdev->upr_list);
+	slic_write(sdev, SLIC_REG_QUIESCE, 0);
+
+	slic_free_stat_queue(sdev);
+	slic_free_tx_queue(sdev);
+	slic_free_rx_queue(sdev);
+	slic_free_shmem(sdev);
+
+	slic_card_reset(sdev);
+	netif_carrier_off(dev);
+
+	return 0;
+}
+
+static netdev_tx_t slic_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	struct slic_tx_queue *txq = &sdev->txq;
+	struct slic_tx_buffer *buff;
+	struct slic_tx_desc *desc;
+	dma_addr_t paddr;
+	u32 cbar_val;
+	u32 maplen;
+
+	if (unlikely(slic_get_free_tx_descs(txq) < SLIC_MAX_REQ_TX_DESCS)) {
+		netdev_err(dev, "BUG! not enought tx LEs left: %u\n",
+			   slic_get_free_tx_descs(txq));
+		return NETDEV_TX_BUSY;
+	}
+
+	maplen = skb_headlen(skb);
+	paddr = dma_map_single(&sdev->pdev->dev, skb->data, maplen,
+			       DMA_TO_DEVICE);
+	if (dma_mapping_error(&sdev->pdev->dev, paddr)) {
+		netdev_err(dev, "failed to map tx buffer\n");
+		goto drop_skb;
+	}
+
+	buff = &txq->txbuffs[txq->put_idx];
+	buff->skb = skb;
+	dma_unmap_addr_set(buff, map_addr, paddr);
+	dma_unmap_len_set(buff, map_len, maplen);
+
+	desc = buff->desc;
+	desc->totlen = cpu_to_le32(maplen);
+	desc->paddrl = cpu_to_le32(lower_32_bits(paddr));
+	desc->paddrh = cpu_to_le32(upper_32_bits(paddr));
+	desc->len = cpu_to_le32(maplen);
+
+	txq->put_idx = slic_next_queue_idx(txq->put_idx, txq->len);
+
+	cbar_val = lower_32_bits(buff->desc_paddr) | 1;
+	/* Complete writes to RAM and DMA are before hardware is informed */
+	wmb();
+
+	slic_write(sdev, SLIC_REG_CBAR, cbar_val);
+
+	if (slic_get_free_tx_descs(txq) < SLIC_MAX_REQ_TX_DESCS)
+		netif_stop_queue(dev);
+	/* Make sure writes io-memory cant leak out of tx queue lock */
+	mmiowb();
+
+	return NETDEV_TX_OK;
+drop_skb:
+	dev_kfree_skb_any(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static struct rtnl_link_stats64 *slic_get_stats(struct net_device *dev,
+						struct rtnl_link_stats64 *lst)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	struct slic_stats *stats = &sdev->stats;
+
+	SLIC_GET_STATS_COUNTER(lst->rx_packets, stats, rx_packets);
+	SLIC_GET_STATS_COUNTER(lst->tx_packets, stats, tx_packets);
+	SLIC_GET_STATS_COUNTER(lst->rx_bytes, stats, rx_bytes);
+	SLIC_GET_STATS_COUNTER(lst->tx_bytes, stats, tx_bytes);
+	SLIC_GET_STATS_COUNTER(lst->rx_errors, stats, rx_errors);
+	SLIC_GET_STATS_COUNTER(lst->rx_dropped, stats, rx_buff_miss);
+	SLIC_GET_STATS_COUNTER(lst->tx_dropped, stats, tx_dropped);
+	SLIC_GET_STATS_COUNTER(lst->multicast, stats, rx_mcasts);
+	SLIC_GET_STATS_COUNTER(lst->rx_over_errors, stats, rx_buffoflow);
+	SLIC_GET_STATS_COUNTER(lst->rx_crc_errors, stats, rx_crc);
+	SLIC_GET_STATS_COUNTER(lst->rx_fifo_errors, stats, rx_oflow802);
+	SLIC_GET_STATS_COUNTER(lst->tx_carrier_errors, stats, tx_carrier);
+
+	return lst;
+}
+
+static int slic_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(slic_stats_strings);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void slic_get_ethtool_stats(struct net_device *dev,
+				   struct ethtool_stats *eth_stats, u64 *data)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+	struct slic_stats *stats = &sdev->stats;
+
+	SLIC_GET_STATS_COUNTER(data[0], stats, rx_packets);
+	SLIC_GET_STATS_COUNTER(data[1], stats, rx_bytes);
+	SLIC_GET_STATS_COUNTER(data[2], stats, rx_mcasts);
+	SLIC_GET_STATS_COUNTER(data[3], stats, rx_errors);
+	SLIC_GET_STATS_COUNTER(data[4], stats, rx_buff_miss);
+	SLIC_GET_STATS_COUNTER(data[5], stats, rx_tpcsum);
+	SLIC_GET_STATS_COUNTER(data[6], stats, rx_tpoflow);
+	SLIC_GET_STATS_COUNTER(data[7], stats, rx_tphlen);
+	SLIC_GET_STATS_COUNTER(data[8], stats, rx_ipcsum);
+	SLIC_GET_STATS_COUNTER(data[9], stats, rx_iplen);
+	SLIC_GET_STATS_COUNTER(data[10], stats, rx_iphlen);
+	SLIC_GET_STATS_COUNTER(data[11], stats, rx_early);
+	SLIC_GET_STATS_COUNTER(data[12], stats, rx_buffoflow);
+	SLIC_GET_STATS_COUNTER(data[13], stats, rx_lcode);
+	SLIC_GET_STATS_COUNTER(data[14], stats, rx_drbl);
+	SLIC_GET_STATS_COUNTER(data[15], stats, rx_crc);
+	SLIC_GET_STATS_COUNTER(data[16], stats, rx_oflow802);
+	SLIC_GET_STATS_COUNTER(data[17], stats, rx_uflow802);
+	SLIC_GET_STATS_COUNTER(data[18], stats, tx_packets);
+	SLIC_GET_STATS_COUNTER(data[19], stats, tx_bytes);
+	SLIC_GET_STATS_COUNTER(data[20], stats, tx_carrier);
+	SLIC_GET_STATS_COUNTER(data[21], stats, tx_dropped);
+	SLIC_GET_STATS_COUNTER(data[22], stats, irq_errs);
+}
+
+static void slic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	if (stringset == ETH_SS_STATS) {
+		memcpy(data, slic_stats_strings, sizeof(slic_stats_strings));
+		data += sizeof(slic_stats_strings);
+	}
+}
+
+static void slic_get_drvinfo(struct net_device *dev,
+			     struct ethtool_drvinfo *info)
+{
+	struct slic_device *sdev = netdev_priv(dev);
+
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(sdev->pdev), sizeof(info->bus_info));
+}
+
+static const struct ethtool_ops slic_ethtool_ops = {
+	.get_drvinfo		= slic_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= slic_get_strings,
+	.get_ethtool_stats	= slic_get_ethtool_stats,
+	.get_sset_count		= slic_get_sset_count,
+};
+
+static const struct net_device_ops slic_netdev_ops = {
+	.ndo_open		= slic_open,
+	.ndo_stop		= slic_close,
+	.ndo_start_xmit		= slic_xmit,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_get_stats64	= slic_get_stats,
+	.ndo_set_rx_mode	= slic_set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static u16 slic_eeprom_csum(unsigned char *eeprom, unsigned int len)
+{
+	unsigned char *ptr = eeprom;
+	u32 csum = 0;
+	__le16 data;
+
+	while (len > 1) {
+		memcpy(&data, ptr, sizeof(data));
+		csum += le16_to_cpu(data);
+		ptr += 2;
+		len -= 2;
+	}
+	if (len > 0)
+		csum += *(u8 *)ptr;
+	while (csum >> 16)
+		csum = (csum & 0xFFFF) + ((csum >> 16) & 0xFFFF);
+	return ~csum;
+}
+
+/* check eeprom size, magic and checksum */
+static bool slic_eeprom_valid(unsigned char *eeprom, unsigned int size)
+{
+	const unsigned int MAX_SIZE = 128;
+	const unsigned int MIN_SIZE = 98;
+	__le16 magic;
+	__le16 csum;
+
+	if (size < MIN_SIZE || size > MAX_SIZE)
+		return false;
+	memcpy(&magic, eeprom, sizeof(magic));
+	if (le16_to_cpu(magic) != SLIC_EEPROM_MAGIC)
+		return false;
+	// cut checksum bytes
+	size -= 2;
+	memcpy(&csum, eeprom + size, sizeof(csum));
+
+	return (le16_to_cpu(csum) == slic_eeprom_csum(eeprom, size));
+}
+
+static int slic_read_eeprom(struct slic_device *sdev)
+{
+	unsigned int devfn = PCI_FUNC(sdev->pdev->devfn);
+	struct slic_shmem *sm = &sdev->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+	const unsigned int MAX_LOOPS = 5000;
+	unsigned int codesize;
+	unsigned char *eeprom;
+	struct slic_upr *upr;
+	dma_addr_t paddr;
+	int err = 0;
+	u8 *mac[2];
+	int i = 0;
+
+	eeprom = dma_zalloc_coherent(&sdev->pdev->dev, SLIC_EEPROM_SIZE,
+				     &paddr, GFP_KERNEL);
+	if (!eeprom)
+		return -ENOMEM;
+
+	slic_write(sdev, SLIC_REG_ICR, SLIC_ICR_INT_OFF);
+	/* setup ISP temporarily */
+	slic_write(sdev, SLIC_REG_ISP, lower_32_bits(sm->isr_paddr));
+
+	err = slic_new_upr(sdev, SLIC_UPR_CONFIG, paddr);
+	if (!err) {
+		for (i = 0; i < MAX_LOOPS; i++) {
+			if (le32_to_cpu(sm_data->isr) & SLIC_ISR_UPC)
+				break;
+			mdelay(1);
+		}
+		if (i == MAX_LOOPS) {
+			dev_err(&sdev->pdev->dev,
+				"timed out while waiting for eeprom data\n");
+			err = -ETIMEDOUT;
+		}
+		upr = slic_dequeue_upr(sdev);
+		kfree(upr);
+	}
+
+	slic_write(sdev, SLIC_REG_ISP, 0);
+	slic_write(sdev, SLIC_REG_ISR, 0);
+	slic_flush_write(sdev);
+
+	if (err)
+		goto free_eeprom;
+
+	if (sdev->model == SLIC_MODEL_OASIS) {
+		struct slic_oasis_eeprom *oee;
+
+		oee = (struct slic_oasis_eeprom *)eeprom;
+		mac[0] = oee->mac;
+		mac[1] = oee->mac2;
+		codesize = le16_to_cpu(oee->eeprom_code_size);
+	} else {
+		struct slic_mojave_eeprom *mee;
+
+		mee = (struct slic_mojave_eeprom *)eeprom;
+		mac[0] = mee->mac;
+		mac[1] = mee->mac2;
+		codesize = le16_to_cpu(mee->eeprom_code_size);
+	}
+
+	if (!slic_eeprom_valid(eeprom, codesize)) {
+		dev_err(&sdev->pdev->dev, "invalid checksum in eeprom\n");
+		err = -EINVAL;
+		goto free_eeprom;
+	}
+	/* set mac address */
+	ether_addr_copy(sdev->netdev->dev_addr, mac[devfn]);
+free_eeprom:
+	dma_free_coherent(&sdev->pdev->dev, SLIC_EEPROM_SIZE, eeprom, paddr);
+
+	return err;
+}
+
+static int slic_init(struct slic_device *sdev)
+{
+	int err;
+
+	spin_lock_init(&sdev->upper_lock);
+	spin_lock_init(&sdev->link_lock);
+	INIT_LIST_HEAD(&sdev->upr_list.list);
+	spin_lock_init(&sdev->upr_list.lock);
+	u64_stats_init(&sdev->stats.syncp);
+
+	slic_card_reset(sdev);
+
+	err = slic_load_firmware(sdev);
+	if (err) {
+		dev_err(&sdev->pdev->dev, "failed to load firmware\n");
+		return err;
+	}
+
+	/* We need the shared memory to read EEPROM so set it up temporarily */
+	err = slic_init_shmem(sdev);
+	if (err) {
+		dev_err(&sdev->pdev->dev, "failed to init shared memory\n");
+		return err;
+	}
+
+	err = slic_read_eeprom(sdev);
+	if (err) {
+		dev_err(&sdev->pdev->dev, "failed to read eeprom\n");
+		goto free_sm;
+	}
+
+	slic_card_reset(sdev);
+	slic_free_shmem(sdev);
+
+	return 0;
+free_sm:
+	slic_free_shmem(sdev);
+
+	return err;
+}
+
+static bool slic_is_fiber(unsigned short subdev)
+{
+	switch (subdev) {
+	/* Mojave */
+	case PCI_SUBDEVICE_ID_ALACRITECH_1000X1F: /* fallthrough */
+	case PCI_SUBDEVICE_ID_ALACRITECH_SES1001F: /* fallthrough */
+	/* Oasis */
+	case PCI_SUBDEVICE_ID_ALACRITECH_SEN2002XF: /* fallthrough */
+	case PCI_SUBDEVICE_ID_ALACRITECH_SEN2001XF: /* fallthrough */
+	case PCI_SUBDEVICE_ID_ALACRITECH_SEN2104EF: /* fallthrough */
+	case PCI_SUBDEVICE_ID_ALACRITECH_SEN2102EF: /* fallthrough */
+		return true;
+	}
+	return false;
+}
+
+static void slic_configure_pci(struct pci_dev *pdev)
+{
+	u16 old;
+	u16 cmd;
+
+	pci_read_config_word(pdev, PCI_COMMAND, &old);
+
+	cmd = old | PCI_COMMAND_PARITY | PCI_COMMAND_SERR;
+	if (old != cmd)
+		pci_write_config_word(pdev, PCI_COMMAND, cmd);
+}
+
+static int slic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct slic_device *sdev;
+	struct net_device *dev;
+	int err;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to enable PCI device\n");
+		return err;
+	}
+
+	pci_set_master(pdev);
+	pci_try_set_mwi(pdev);
+
+	slic_configure_pci(pdev);
+
+	err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+	if (err) {
+		dev_err(&pdev->dev, "failed to setup DMA\n");
+		goto disable;
+	}
+
+	dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err) {
+		dev_err(&pdev->dev, "failed to obtain PCI regions\n");
+		goto disable;
+	}
+
+	dev = alloc_etherdev(sizeof(*sdev));
+	if (!dev) {
+		dev_err(&pdev->dev, "failed to alloc ethernet device\n");
+		err = -ENOMEM;
+		goto free_regions;
+	}
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	pci_set_drvdata(pdev, dev);
+	dev->irq = pdev->irq;
+	dev->netdev_ops = &slic_netdev_ops;
+	dev->hw_features = NETIF_F_RXCSUM;
+	dev->features |= dev->hw_features;
+
+	dev->ethtool_ops = &slic_ethtool_ops;
+
+	sdev = netdev_priv(dev);
+	sdev->model = (pdev->device == PCI_DEVICE_ID_ALACRITECH_OASIS) ?
+		      SLIC_MODEL_OASIS : SLIC_MODEL_MOJAVE;
+	sdev->is_fiber = slic_is_fiber(pdev->subsystem_device);
+	sdev->pdev = pdev;
+	sdev->netdev = dev;
+	sdev->regs = ioremap_nocache(pci_resource_start(pdev, 0),
+				     pci_resource_len(pdev, 0));
+	if (!sdev->regs) {
+		dev_err(&pdev->dev, "failed to map registers\n");
+		err = -ENOMEM;
+		goto free_netdev;
+	}
+
+	err = slic_init(sdev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to initialize driver\n");
+		err = -ENOMEM;
+		goto unmap;
+	}
+
+	netif_napi_add(dev, &sdev->napi, slic_poll, SLIC_NAPI_WEIGHT);
+	netif_carrier_off(dev);
+
+	err = register_netdev(dev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to register net device: %i\n",
+			err);
+		goto unmap;
+	}
+
+	return 0;
+
+unmap:
+	iounmap(sdev->regs);
+free_netdev:
+	free_netdev(dev);
+free_regions:
+	pci_release_regions(pdev);
+disable:
+	pci_disable_device(pdev);
+
+	return err;
+}
+
+static void slic_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct slic_device *sdev = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	iounmap(sdev->regs);
+	free_netdev(dev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+static struct pci_driver slic_driver = {
+	.name = DRV_NAME,
+	.id_table = slic_id_tbl,
+	.probe = slic_probe,
+	.remove = slic_remove,
+};
+
+static int __init slic_init_module(void)
+{
+	return pci_register_driver(&slic_driver);
+}
+
+static void __exit slic_cleanup_module(void)
+{
+	pci_unregister_driver(&slic_driver);
+}
+
+module_init(slic_init_module);
+module_exit(slic_cleanup_module);
+
+MODULE_DESCRIPTION("Alacritech non-accelerated SLIC driver");
+MODULE_AUTHOR("Lino Sanfilippo <LinoSanfilippo@gmx.de>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index c58752f..a2fab65 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2015,6 +2015,24 @@
 #define PCI_SUBDEVICE_ID_CCD_OV4S	0xE888
 #define PCI_SUBDEVICE_ID_CCD_OV8S	0xE998
 
+#define PCI_VENDOR_ID_ALACRITECH		0x139A
+#define PCI_DEVICE_ID_ALACRITECH_MOAVE		0x0005
+#define PCI_SUBDEVICE_ID_ALACRITECH_1000X1	0x0005
+#define PCI_SUBDEVICE_ID_ALACRITECH_1000X1_2	0x0006
+#define PCI_SUBDEVICE_ID_ALACRITECH_1000X1F	0x0007
+#define PCI_SUBDEVICE_ID_ALACRITECH_CICADA	0x0008
+#define PCI_SUBDEVICE_ID_ALACRITECH_SES1001T	0x2006
+#define PCI_SUBDEVICE_ID_ALACRITECH_SES1001F	0x2007
+#define PCI_DEVICE_ID_ALACRITECH_OASIS		0x0007
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2002XT	0x000B
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2002XF	0x000C
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2001XT	0x000D
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2001XF	0x000E
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2104EF	0x000F
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2104ET	0x0010
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2102EF	0x0011
+#define PCI_SUBDEVICE_ID_ALACRITECH_SEN2102ET	0x0012
+
 #define PCI_VENDOR_ID_EXAR		0x13a8
 #define PCI_DEVICE_ID_EXAR_XR17C152	0x0152
 #define PCI_DEVICE_ID_EXAR_XR17C154	0x0154
-- 
1.9.1
