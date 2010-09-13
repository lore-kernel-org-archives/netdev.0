From: Masayuki Ohtak <masa-korg@dsn.okisemi.com>
Subject: [MeeGo-Dev][PATCH v2] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Mon, 13 Sep 2010 21:22:11 +0900
Message-ID: <4C8E1773.9090000__8526.29817459292$1284380585$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Wang Qi\"" <qi.wang@intel.com>,
	"Wang Yong Y\"" <yong.y.wang@intel.com>,
	"Andrew\"" <andrew.chih.howe.khor@intel.com>,
	arjan@linux.intel.com, gregkh@suse.de,
	Tomoya MORINAGA <morinaga526@dsn.okisemi.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@g
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:42807 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871Ab0IMMWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 08:22:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAN driver of Topcliff PCH

Topcliff PCH is the platform controller hub that is going to be used in
Intel's upcoming general embedded platform. All IO peripherals in
Topcliff PCH are actually devices sitting on AMBA bus. 
Topcliff PCH has CAN I/F. This driver enables CAN function.

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

---
 drivers/net/can/Kconfig   |    8 +
 drivers/net/can/Makefile  |    1 +
 drivers/net/can/pch_can.c | 3601 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 3610 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/pch_can.c

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 2c5227c..5c98a20 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -73,6 +73,14 @@ config CAN_JANZ_ICAN3
 	  This driver can also be built as a module. If so, the module will be
 	  called janz-ican3.ko.
 
+config PCH_CAN
+	tristate "PCH CAN"
+	depends on  CAN_DEV
+	---help---
+	  This driver is for PCH CAN of Topcliff which is an IOH for x86
+	  embedded processor.
+	  This driver can access CAN bus.
+
 source "drivers/net/can/mscan/Kconfig"
 
 source "drivers/net/can/sja1000/Kconfig"
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 9047cd0..3ddc6a7 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -16,5 +16,6 @@ obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
 obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
 obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
+obj-$(CONFIG_PCH_CAN)		+= pch_can.o
 
 ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
new file mode 100644
index 0000000..0de978f
--- /dev/null
+++ b/drivers/net/can/pch_can.c
@@ -0,0 +1,3601 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/platform_device.h>
+#include <linux/clk.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+
+#define MAX_CAN_DEVICES		1
+#define MAX_BITRATE		0x3e8
+#define NUM_NODES		2000	/* Maximum number of
+						 Software FIFO nodes. */
+#define MAX_MSG_OBJ		32
+#define MSG_OBJ_RX		0 /* The receive message object flag. */
+#define MSG_OBJ_TX		1 /* The transmit message object flag. */
+
+#define ENABLE			1 /* The enable flag */
+#define DISABLE			0 /* The disable flag */
+#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
+#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
+#define CAN_CTRL_SIE		0x0004
+#define CAN_CTRL_EIE		0x0008
+#define CAN_CTRL_DAR		0x0020
+#define CAN_CTRL_IE_SIE_EIE	0x000e
+#define CAN_CTRL_CCE		0x0040
+#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
+#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT register. */
+#define CAN_CMASK_RX_TX_SET	0x00f3
+#define CAN_CMASK_RX_TX_GET	0x0073
+#define CAN_CMASK_ALL		0xff
+#define CAN_CMASK_RDWR		0x80
+#define CAN_CMASK_ARB		0x20
+#define CAN_CMASK_CTRL		0x10
+#define CAN_CMASK_MASK		0x40
+#define CAN_CMASK_CLPNT		0x08
+
+#define CAN_CMASK_NEWINT	0x04 /* The TxRqst/NewDat bit for the CMASK
+					register. */
+
+#define CAN_IF_MCONT_NEWDAT	0x8000 /* The NewDat bit of the MCONT
+					  register. */
+
+#define CAN_IF_MCONT_INTPND	0x2000 /* The IntPnd bit of the MCONT
+					  register. */
+
+#define CAN_IF_MCONT_UMASK		0x1000
+#define CAN_IF_MCONT_TXIE		0x0800
+#define CAN_IF_MCONT_RXIE		0x0400
+#define CAN_IF_MCONT_RMTEN		0x0200
+#define CAN_IF_MCONT_TXRQXT		0x0100
+#define CAN_IF_MCONT_EOB		0x0080
+#define CAN_IF_MCONT_MSGLOST		0x4000
+#define CAN_MASK2_MDIR_MXTD		0xc000
+#define CAN_ID2_MSGVAL_XTD_DIR		0xe000
+#define CAN_ID2_MSGVAL_DIR		0xa000
+#define CAN_ID2_DIR			0x2000
+#define CAN_ID_MSGVAL			0x8000
+#define CAN_IF_MASK2_MDIR		((u32)1 << 14)
+#define CAN_IF_MASK2_MXTD		((u32)1 << 15)
+
+#define CAN_STATUS_INT			0x8000 /* The status interrupt value of
+						  the CAN device. */
+
+#define CAN_IF_CREQ_BUSY		0x8000 /* The Busy flag bit of the CREQ
+						  register. */
+
+#define CAN_ID2_XTD			0x4000 /* The Xtd bit of ID2
+						  register. */
+
+#define CAN_SRST_BIT			0x0001
+#define CAN_CONT_OFFSET			0x00	/*Can Control register */
+#define CAN_STAT_OFFSET			0x04
+#define CAN_ERRC_OFFSET			0x08
+#define CAN_BITT_OFFSET			0x0c
+#define CAN_INT_OFFSET			0x010
+#define CAN_OPT_OFFSET			0x14	/*Extended function register */
+#define CAN_BRPE_OFFSET			0x18
+
+/* Message interface one (IF1) registers */
+#define CAN_IF1_CREQ_OFFSET		0x020
+#define CAN_IF1_CMASK_OFFSET		0x024
+#define CAN_IF1_ID1_OFFSET		0x030
+#define CAN_IF1_ID2_OFFSET		0x034
+#define CAN_IF1_MCONT_OFFSET		0x038
+#define CAN_IF1_DATAA1_OFFSET		0x03C
+#define CAN_IF1_DATAA2_OFFSET		0x040
+#define CAN_IF1_DATAB1_OFFSET		0x044
+#define CAN_IF1_DATAB2_OFFSET		0x048
+#define CAN_IF1_MASK1_OFFSET		0x028
+#define CAN_IF1_MASK2_OFFSET		0x02c
+#define CAN_IF2_CREQ_OFFSET		0x080
+#define CAN_IF2_CMASK_OFFSET		0x084
+#define CAN_IF2_ID1_OFFSET		0x090
+#define CAN_IF2_ID2_OFFSET		0x094
+#define CAN_IF2_MCONT_OFFSET		0x098
+#define CAN_IF2_DATAA1_OFFSET		0x09c
+#define CAN_IF2_DATAA2_OFFSET		0x0a0
+#define CAN_IF2_DATAB1_OFFSET		0x0a4
+#define CAN_IF2_DATAB2_OFFSET		0x0a8
+#define CAN_IF2_MASK1_OFFSET		0x088
+#define CAN_IF2_MASK2_OFFSET		0x08c
+#define CAN_TREQ1_OFFSET		0x100
+#define CAN_TREQ2_OFFSET		0x104
+#define CAN_SRST_OFFSET			0x1FC
+
+/* bit position of certain controller bits. */
+#define BIT_BITT_BRP			0
+#define BIT_BITT_SJW			6
+#define BIT_BITT_TSEG1			8
+#define BIT_BITT_TSEG2			12
+#define BIT_IF1_MCONT_RXIE		10
+#define BIT_IF2_MCONT_TXIE		11
+#define BIT_BRPE_BRPE			6
+#define BIT_ES_TXERRCNT			0
+#define BIT_ES_RXERRCNT			8
+#define MSK_BITT_BRP			0x3f
+#define MSK_BITT_SJW			0xc0
+#define MSK_BITT_TSEG1			0xf00
+#define MSK_BITT_TSEG2			0x7000
+#define MSK_BRPE_BRPE			0x3c0
+#define MSK_BRPE_GET			0x0f
+#define MSK_CTRL_IE_SIE_EIE		0x07
+#define MSK_MCONT_TXIE			0x08
+#define MSK_MCONT_RXIE			0x10
+#define MSK_ALL_THREE			0x07
+#define MSK_ALL_FOUR			0x0f
+#define MSK_ALL_EIGHT			0xff
+#define MSK_ALL_ELEVEN			0x7ff
+#define MSK_ALL_THIRTEEN		0x1fff
+#define MSK_ALL_SIXTEEN			0xffff
+
+/* Error */
+#define MSK_ES_TXERRCNT	((u32)0xff << BIT_ES_TXERRCNT)	/* Tx err count */
+#define MSK_ES_RXERRCNT	((u32)0x7f << BIT_ES_RXERRCNT)	/* Rx err count */
+
+#define PCH_CAN_BIT_SET(reg, bitmask)	\
+		(iowrite32((ioread32((reg)) | ((u32)(bitmask))), (reg)))
+#define PCH_CAN_BIT_CLEAR(reg, bitmask)	\
+		(iowrite32((ioread32((reg)) & ~((u32)(bitmask))), (reg)))
+
+#define PCH_CAN_NO_TX_BUFF		1 /* The flag value for denoting the
+					     unavailability of the transmit
+					     message object. */
+
+#define ERROR_COUNT			96
+#define PCH_CAN_MSG_DATA_LEN		8	/* CAN Msg data length */
+
+#define PCH_CAN_NULL			NULL
+
+#define PCI_DEVICE_ID_INTEL_PCH1_CAN	0x8818
+#define DRIVER_NAME			"can"
+
+#define PCH_CAN_CLOCK_DEFAULT_OFFSET	0
+#define PCH_CAN_CLOCK_62_5_OFFSET	0
+#define PCH_CAN_CLOCK_24_OFFSET		8
+#define PCH_CAN_CLOCK_50_OFFSET		16
+
+#define COUNTER_LIMIT 0xFFFF
+
+
+
+enum pch_can_listen_mode {
+	PCH_CAN_ACTIVE = 0,
+	PCH_CAN_LISTEN
+};
+
+enum pch_can_run_mode {
+	PCH_CAN_STOP = 0,
+	PCH_CAN_RUN
+};
+
+enum pch_can_arbiter {
+	PCH_CAN_ROUND_ROBIN = 0,
+	PCH_CAN_FIXED_PRIORITY
+};
+
+enum pch_can_auto_restart {
+	CAN_MANUAL = 0,
+	CAN_AUTO
+};
+
+enum pch_can_baud {
+	PCH_CAN_BAUD_10 = 0,
+	PCH_CAN_BAUD_20,
+	PCH_CAN_BAUD_50,
+	PCH_CAN_BAUD_125,
+	PCH_CAN_BAUD_250,
+	PCH_CAN_BAUD_500,
+	PCH_CAN_BAUD_800,
+	PCH_CAN_BAUD_1000
+};
+
+enum pch_can_interrupt {
+	CAN_ENABLE,
+	CAN_DISABLE,
+	CAN_ALL,
+	CAN_NONE
+};
+
+
+/**
+ * struct pch_can_msg - CAN message structure
+ * @ide:	Standard/extended msg
+ * @id:		11 or 29 bit msg id
+ * @dlc:	Size of data
+ * @data:	Message pay load
+ * @rtr:	RTR message
+ */
+struct pch_can_msg {
+	unsigned short ide;
+	unsigned int id;
+	unsigned short dlc;
+	unsigned char data[PCH_CAN_MSG_DATA_LEN];
+	unsigned short rtr;
+};
+
+/**
+ * pch_can_timing - CAN bittiming structure
+ * @bitrate:	Bitrate (kbps)
+ * @cfg_bitrate:BRP
+ * @cfg_tseg1:	Tseg1
+ * @cfg_tseg2:	Tseg2
+ * @cfg_sjw:	Sync jump width
+ * @smpl_mode:	Sampling mode
+ * @edge_mode:	Edge R / D
+ */
+struct pch_can_timing {
+	unsigned int bitrate;
+	unsigned int cfg_bitrate;
+	unsigned int cfg_tseg1;
+	unsigned int cfg_tseg2;
+	unsigned int cfg_sjw;
+	unsigned int smpl_mode;
+	unsigned int edge_mode;
+};
+
+/**
+ * struct pch_can_error - CAN error structure
+ * @rxgte96:	Rx err cnt >=96
+ * @txgte96:	Tx err cnt >=96
+ * @error_stat:	Error state of CAN node,
+ *		00=error active (normal)
+ *		01=error passive
+ *		1x=bus off
+ * @rx_err_cnt:	Rx error count
+ * @tx_err_cnt:	Tx error count
+ */
+struct pch_can_error {
+	unsigned int rxgte96;
+	unsigned int txgte96;
+	unsigned int error_stat;
+	unsigned int rx_err_cnt;
+	unsigned int tx_err_cnt;
+};
+
+/**
+ * struct pch_can_acc_filter - CAN Filter structure
+ * @id:		The id/mask data
+ * @id_ext:	Standard/extended ID
+ * @rtr:	RTR message
+ */
+struct pch_can_acc_filter {
+	unsigned int id;
+	unsigned int id_ext;
+	unsigned int rtr;
+};
+
+/**
+ * struct pch_can_rx_filter - CAN RX filter
+ * @num:	Filter number
+ * @umask:	UMask value
+ * @amr:	Acceptance Mask Reg
+ * @aidr:	Acceptance Control Reg
+ */
+struct pch_can_rx_filter {
+	unsigned int num;
+	unsigned int umask;
+	struct pch_can_acc_filter amr;
+	struct pch_can_acc_filter aidr;
+};
+
+/**
+ * struct pch_can_os - structure to store the CAN device information.
+ * @can:		CAN: device handle
+ * @opened:		Linux opened device
+ * @can_num:		Linux: CAN Number
+ * @pci_remap:		Linux: MMap regs
+ * @dev:		Linux: PCI Device
+ * @irq:		Linux: IRQ
+ * @block_mode:		Blocking / non-blocking
+ * @read_wait_queue:	Linux: Read wait queue
+ * @write_wait_queue:	Linux: Write wait queue
+ * @write_wait_flag:	Linux: Write wait flag
+ * @read_wait_flag:	Linux: Read wait flag
+ * @open_spinlock:	Linux: Open lock variable
+ * @is_suspending:	Linux: Is suspending state
+ * @inode:		Linux: inode
+ * @timing:		CAN: timing
+ * @run_mode:		CAN: run mode
+ * @listen_mode:	CAN: listen mode
+ * @arbiter_mode:	CAN: arbiter mode
+ * @tx_enable:		CAN: Tx buffer state
+ * @rx_enable:		CAN: Rx buffer state
+ * @rx_link:		CAN: Rx link set
+ * @int_enables:	CAN: ints enabled
+ * @int_stat:		CAN: int status
+ * @bus_off_interrupt:	CAN: Buss off int flag
+ * @rx_filter:		CAN: Rx filters
+ * @ndev:		net_device pointer
+ * @tx_spinlock:	CAN: transmission lock variable
+ */
+struct pch_can_os {
+	struct can_hw *can;
+	unsigned int opened;
+	unsigned int can_num;
+	void __iomem *pci_remap;
+	struct pci_dev *dev;
+	unsigned int irq;
+	int block_mode;
+	wait_queue_head_t read_wait_queue;
+	wait_queue_head_t write_wait_queue;
+	unsigned int write_wait_flag;
+	unsigned int read_wait_flag;
+	spinlock_t open_spinlock;
+	unsigned int is_suspending;
+	struct inode *inode;
+	struct pch_can_timing timing;
+	enum pch_can_run_mode run_mode;
+	enum pch_can_listen_mode listen_mode;
+	enum pch_can_arbiter arbiter_mode;
+	unsigned int tx_enable[MAX_MSG_OBJ];
+	unsigned int rx_enable[MAX_MSG_OBJ];
+	unsigned int rx_link[MAX_MSG_OBJ];
+	unsigned int int_enables;
+	unsigned int int_stat;
+	unsigned int bus_off_interrupt;
+	struct pch_can_rx_filter rx_filter[MAX_MSG_OBJ];
+	struct net_device *ndev;
+	spinlock_t tx_spinlock;
+	struct mutex pch_mutex;
+};
+
+/**
+ * struct pch_can_priv - CAN driver private data structure
+ * @can:		MUST be first member/field
+ * @ndev:		Pointer to net_device structure
+ * @clk:		unused
+ * @base:		Base address
+ * @pch_can_os_p:	Pointer to CAN device information
+ * @have_msi:		PCI MSI mode flag
+ *
+ * Longer description of this structure.
+ */
+struct pch_can_priv {
+	struct can_priv can;
+	struct net_device *ndev;
+	struct clk *clk;
+	void __iomem *base;
+	struct pch_can_os pch_can_os_p;
+	unsigned int have_msi;
+};
+
+struct can_hw {
+	void __iomem *io_base;
+};
+
+static unsigned int pch_can_clock = 50000; /*50MH*/
+
+/*
+The number of message objects that has to be configured as receive/send
+objects.
+Topcliff CAN has total 32 message objects.
+*/
+static unsigned int pch_can_rx_buf_size = 1;
+static unsigned int pch_can_tx_buf_size = 1;
+
+
+static enum pch_can_auto_restart restat_mode = CAN_MANUAL; /* The variable used
+							      to store the
+							      restart mode. */
+
+static struct can_bittiming_const pch_can_bittiming_const = {
+	.name = KBUILD_MODNAME,
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024, /* 6bit + extended 4bit */
+	.brp_inc = 1,
+};
+
+static const struct pci_device_id pch_can_pcidev_id[] __devinitdata = {
+	{PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PCH1_CAN)},
+	{}
+};
+
+/*
+This variable is used to store the configuration (receive /transmit) of the
+available message objects.
+This variable is used for storing the message object configuration related
+information. It includes the information about which message object is used as
+Receiver and Transmitter.
+*/
+static unsigned int pch_msg_obj_conf[MAX_MSG_OBJ] = {
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3,
+	3, 3, 3, 3
+};
+
+static struct can_hw *pch_can_create(void __iomem *io_base,
+				     struct net_device *ndev)
+{
+	struct can_hw *can;
+
+	if (!io_base) {
+		dev_err(&ndev->dev, "%s -> Invalid IO Base\n", __func__);
+		return NULL;
+	}
+
+	/* Allocates memory for the handle. */
+	can = kmalloc(sizeof(struct can_hw), GFP_KERNEL);
+	if (!can) {	/* Allocation failed */
+		dev_err(&ndev->dev,
+			"%s -> CAN Memory allocation failed\n", __func__);
+		return NULL;
+	}
+
+	can->io_base = io_base;
+	dev_dbg(&ndev->dev,
+		"%s -> Handle Creation successful.\n", __func__);
+	return can;
+}
+
+static void pch_can_destroy(struct can_hw *can, struct net_device *ndev)
+{
+	if (can) {
+		/* Free the memory for the handle. */
+		kfree(can);
+		dev_dbg(&ndev->dev, "%s -> Free successful.\n", __func__);
+	} else {
+		dev_err(&ndev->dev, "%s-> Invalid handle.\n", __func__);
+	}
+}
+
+static int pch_can_set_run_mode(struct can_hw *can, enum pch_can_run_mode mode,
+				struct net_device *ndev)
+{
+	int retval = 0;
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle\n", __func__);
+		return -EPERM;
+	}
+
+	/* Retrieving base address for access. */
+	switch (mode) {
+	case PCH_CAN_RUN:
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_CONT_OFFSET),
+				  CAN_CTRL_INIT);
+		dev_dbg(&ndev->dev,
+		    "%s -> Can set to RUN Mode.\n", __func__);
+		break;
+
+	case PCH_CAN_STOP:
+		PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET),
+				CAN_CTRL_INIT);
+		dev_dbg(&ndev->dev,
+		    "%s -> Can set to STOP Mode.\n", __func__);
+		break;
+
+	default:
+		dev_err(&ndev->dev,
+			"%s -> Invalid run mode.\n", __func__);
+		retval = -EPERM;
+		break;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_get_run_mode(struct can_hw *can, enum pch_can_run_mode *mode,
+				struct net_device *ndev)
+{
+	u32 reg_val;
+
+	if (!can || !mode) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid parameter.\n", __func__);
+		return -EPERM;
+	}
+
+	reg_val = ioread32(can->io_base + CAN_CONT_OFFSET);
+
+	/* Checking the Init bit of Can Control Register.
+	   Init Bit 1 -> Stop
+	   Init Bit 0 -> Run
+	 */
+	if (reg_val & CAN_CTRL_INIT) {
+		*mode = PCH_CAN_STOP;
+		dev_dbg(&ndev->dev,
+		    "%s -> Mode is PCH_CAN_STOP\n", __func__);
+	} else {
+		*mode = PCH_CAN_RUN;
+		dev_dbg(&ndev->dev,
+		    "%s -> Mode is PCH_CAN_RUN\n", __func__);
+	}
+
+	return 0;
+}
+
+static int pch_can_set_arbiter_mode(struct can_hw *can,
+				    enum pch_can_arbiter mode,
+				    struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid Handle\n", __func__);
+		return -EPERM;
+	}
+
+	/* PCH CAN Controller supports only PCH_CAN_FIXED_PRIORITY
+	   arbiter mode.
+	 */
+	switch (mode) {
+	case PCH_CAN_FIXED_PRIORITY:
+		dev_dbg(&ndev->dev,
+		    "%s -> FIXED PRIORITY is set for Arbiter mode\n",
+		    __func__);
+		break;
+
+	case PCH_CAN_ROUND_ROBIN:
+	default:
+		dev_dbg(&ndev->dev,
+			"%s -> Invalid arbiter mode\n", __func__);
+		retval = -EPERM;
+		break;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_get_arbiter_mode(struct can_hw *can,
+				    enum pch_can_arbiter *mode,
+				    struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can || !mode) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid parameter\n", __func__);
+		return -EPERM;
+	}
+
+	/* PCH CAN Controller supports only PCH_CAN_FIXED_PRIORITY
+	   arbiter mode.
+	 */
+	*mode = PCH_CAN_FIXED_PRIORITY;
+	dev_dbg(&ndev->dev,
+	    "%s -> Arbiter Mode is PCH_CAN_FIXED_PRIORITY\n", __func__);
+
+	return retval;
+}
+
+static int pch_can_set_restart_mode(struct can_hw *can,
+				    enum pch_can_auto_restart mode,
+				    struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle\n", __func__);
+		return -EPERM;
+	}
+
+	switch (mode) {
+	case CAN_MANUAL:
+		restat_mode = CAN_MANUAL;
+		dev_dbg(&ndev->dev, "%s -> CAN_MANUAL mode set.\n", __func__);
+		break;
+
+	case CAN_AUTO:
+		restat_mode = CAN_AUTO;
+		dev_dbg(&ndev->dev, "%s -> CAN_AUTO mode set.\n", __func__);
+		break;
+
+	default:
+		dev_err(&ndev->dev, "%s -> Invalid restart mode\n", __func__);
+		retval = -EPERM;
+		break;
+	}
+
+	return retval;
+}
+
+static int pch_can_get_restart_mode(struct can_hw *can,
+				    enum pch_can_auto_restart *mode,
+				    struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can || !mode) {
+		dev_err(&ndev->dev, "%s -> Invalid parameter.\n", __func__);
+		return -EPERM;
+	}
+	if (restat_mode == CAN_AUTO) {
+		*mode = CAN_AUTO;
+		dev_dbg(&ndev->dev, "%s -> Mode CAN_AUTO.\n", __func__);
+	} else {
+		*mode = CAN_MANUAL;
+		dev_dbg(&ndev->dev, "%s -> Mode CAN_MANUAL.\n", __func__);
+	}
+
+	return retval;
+}
+
+static int pch_can_set_listen_mode(struct can_hw *can,
+				   enum pch_can_listen_mode mode,
+				   struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle\n", __func__);
+		return -EPERM;
+	}
+	/* Setting for Bit3 of Can Extended function register for
+	   appropriate mode.
+	   Silent bit = 0 (Active mode)
+	   Silent bit = 1 (Silent mode)
+	 */
+	switch (mode) {
+	case PCH_CAN_LISTEN:
+		PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET), CAN_CTRL_OPT);
+		PCH_CAN_BIT_SET((can->io_base + CAN_OPT_OFFSET),
+				 CAN_OPT_SILENT);
+		dev_dbg(&ndev->dev,
+			"%s -> PCH_CAN_LISTEN mode set.\n", __func__);
+		break;
+
+	case PCH_CAN_ACTIVE:
+		PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET), CAN_CTRL_OPT);
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_OPT_OFFSET),
+				  CAN_OPT_SILENT);
+		dev_dbg(&ndev->dev,
+			"%s ->PCH_CAN_ACTIVE mode set.\n", __func__);
+		break;
+
+	default:
+		dev_err(&ndev->dev, "%s ->Invalid listen mode\n", __func__);
+		retval = -EPERM;
+		break;
+	}
+
+	return retval;
+}
+
+static int pch_can_get_listen_mode(struct can_hw *can,
+				   enum pch_can_listen_mode *mode,
+				   struct net_device *ndev)
+{
+	u32 reg_val;
+	int retval = 0;
+
+	if (!can || !mode) {
+		dev_err(&ndev->dev, "%s -> Invalid Parameter\n", __func__);
+		return -EPERM;
+	}
+
+	reg_val = ioread32(can->io_base + CAN_OPT_OFFSET);
+
+	/* Checking for Bit3 of Can Extended function register
+	   for silent mode
+	   Silent bit = 0 (Active mode)
+	   Silent bit = 1 (Silent mode)
+	 */
+
+	if (reg_val & CAN_OPT_SILENT) {
+		*mode = PCH_CAN_LISTEN;
+		dev_dbg(&ndev->dev, "%s -> Mode is listen\n", __func__);
+	} else {
+		*mode = PCH_CAN_ACTIVE;
+		dev_dbg(&ndev->dev, "%s -> Mode is active\n", __func__);
+	}
+
+	return retval;
+}
+
+static int pch_can_set_int_custom(struct can_hw *can, u32 interrupts)
+{
+	int retval = 0;
+
+	if (!can)
+		return -EPERM;
+
+	/* Clearing the IE, SIE and EIE bits of Can control register. */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_CONT_OFFSET),
+			  CAN_CTRL_IE_SIE_EIE);
+
+	/* Appropriately setting them. */
+	PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET),
+			((interrupts & MSK_CTRL_IE_SIE_EIE) << 1));
+
+	return retval;
+}
+
+/* This function retrieves interrupt enabled for the CAN device. */
+static int pch_can_get_int_enables(struct can_hw *can, u32 *enables)
+{
+	u32 reg_ctrl_val;
+	int retval = 0;
+
+	if (!can || !enables)
+		return -EPERM;
+
+	/* Reading the Can control register. */
+	reg_ctrl_val = ioread32(can->io_base + CAN_CONT_OFFSET);
+
+	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
+	*enables = ((reg_ctrl_val & CAN_CTRL_IE_SIE_EIE) >> 1);
+
+	return retval;
+}
+
+static int pch_can_set_int_enables(struct can_hw *can,
+				   enum pch_can_interrupt interrupt_no,
+				   struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	}
+	/*
+	   Appropriately setting the IE, SIE and EIE bits of Can control
+		 register.
+	 */
+	switch (interrupt_no) {
+	case CAN_ENABLE:
+		PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET), CAN_CTRL_IE);
+		dev_dbg(&ndev->dev,
+		    "%s -> CAN_ENABLE (IE) interrupt set.\n", __func__);
+		break;
+
+	case CAN_DISABLE:
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_CONT_OFFSET),
+				  CAN_CTRL_IE);
+		dev_dbg(&ndev->dev,
+		  "%s -> CAN_DIABLE (IE) interrupt reset.\n", __func__);
+		break;
+
+	case CAN_ALL:
+		PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET),
+				CAN_CTRL_IE_SIE_EIE);
+		dev_dbg(&ndev->dev,
+			"%s -> CAN_ALL (IE,SIE,EIE) interrupt set.\n",
+			__func__);
+		break;
+
+	case CAN_NONE:
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_CONT_OFFSET),
+				  CAN_CTRL_IE_SIE_EIE);
+		dev_dbg(&ndev->dev,
+		    "%s -> CAN_NONE (IE,SIE,EIE) interrupt reset.\n",
+		    __func__);
+		break;
+
+	default:
+		dev_err(&ndev->dev,
+		    "%s -> Invalid parameter interrupt.\n", __func__);
+		retval = -EPERM;
+		break;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_set_rx_enable(struct can_hw *can, u32 buff_num, u32 set,
+				 struct net_device *ndev)
+{
+	u32 counter;
+	int retval = 0;
+	u32 if1_creq;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_RX) ||
+		 (buff_num > (pch_can_tx_buf_size + pch_can_rx_buf_size))) {
+		/* if invalid buffer number. */
+		dev_err(&ndev->dev,
+		    "%s -> Message object %u not configured for receive.\n",
+		    __func__, buff_num);
+		return -EPERM;
+	}
+
+	/*Reading the receive buffer data from RAM to Interface1
+							 registers */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(buff_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev,
+		    "%s -> Cannot read the message buffer object %u.\n",
+		    __func__, buff_num);
+		return -EPERM;
+	}
+
+	/* Setting the IF1MASK1 register to access MsgVal and
+						 RxIE bits */
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
+		  (can->io_base + CAN_IF1_CMASK_OFFSET));
+
+	if (set == ENABLE) {
+		/* Setting the MsgVal and RxIE bits */
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MCONT_OFFSET),
+				CAN_IF_MCONT_RXIE);
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_ID2_OFFSET),
+				CAN_ID_MSGVAL);
+
+		dev_dbg(&ndev->dev,
+		   "%s -> Enabled receive message buffer %u.\n",
+		   __func__, buff_num);
+	} else if (set == DISABLE) {
+		/* Resetting the MsgVal and RxIE bits */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET),
+				  CAN_IF_MCONT_RXIE);
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID2_OFFSET),
+				  CAN_ID_MSGVAL);
+
+		dev_dbg(&ndev->dev, "%s -> Disabled receive message buffer %u",
+		    __func__, buff_num);
+	}
+
+	/* Updating the changes to the message object. */
+	iowrite32(buff_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	/* Confirming the write by checking the busy bit. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+					CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev,
+			"%s -> Write failed.\n", __func__);
+		retval = -EPERM;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_rx_enable_all(struct can_hw *can, struct net_device *ndev)
+{
+	u32 counter = 0;
+	int retval = 0;
+	u32 i;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Traversing to obtain the object configured as receivers. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+			/* Here i is the index, however (i+1) is object
+			   number. */
+			retval = pch_can_set_rx_enable(can, i + 1, ENABLE,
+						       ndev);
+
+			if (retval == -EPERM) {
+				dev_dbg(&ndev->dev,
+					"%s -> Can't Enable receive object%u\n",
+					__func__, i + 1);
+				counter++;
+			} else {
+				dev_dbg(&ndev->dev,
+					"%s -> Enabled receive object %u\n",
+					__func__, i + 1);
+			}
+		}
+	}
+
+	/* If enabling of all the receive object failed. */
+	if (counter == pch_can_rx_buf_size) {
+		retval = -EPERM;
+		dev_err(&ndev->dev, "%s failed.\n", __func__);
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_rx_disable_all(struct can_hw *can, struct net_device *ndev)
+{
+	u32 counter = 0;
+	int retval = 0;
+	u32 i;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	}
+	/* Traversing to obtain the object configured as receivers. */
+	for (i = 0; i < (pch_can_rx_buf_size + pch_can_tx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+			/* Here i is the index, however (i+1) is the
+			   object number. */
+			retval = pch_can_set_rx_enable(can, (i + 1), DISABLE,
+						       ndev);
+
+			if (retval == -EPERM) {
+				dev_dbg(&ndev->dev,
+					"%s -> Disabling of Rx buffer %u "
+					"failed.\n", __func__, (i + 1));
+				counter++;
+			} else {
+				dev_dbg(&ndev->dev,
+					"%s -> Disabled receive object %u\n",
+					__func__, i + 1);
+			}
+		}
+	}
+
+	/* If disabling of all the receive object failed. */
+	if (counter == pch_can_rx_buf_size) {
+		retval = -EPERM;
+		dev_err(&ndev->dev, "%s failed.\n", __func__);
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_set_tx_enable(struct can_hw *can, u32 buff_num, u32 set,
+				 struct net_device *ndev)
+{
+	int retval = 0;
+	u32 counter;
+	u32 if1_creq;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle", __func__);
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_TX) ||
+		 (buff_num > (pch_can_rx_buf_size + pch_can_tx_buf_size))) {
+		/* invalid buffer number. */
+		dev_err(&ndev->dev,
+		    "%s -> Message object %u not configured for transmit.\n",
+		    __func__, buff_num);
+		return -EPERM;
+	}
+	/*Reading the Message buffer from Message RAM to Interface2
+							 registers. */
+	iowrite32(CAN_CMASK_RX_TX_GET, (can->io_base + CAN_IF1_CMASK_OFFSET));
+	iowrite32(buff_num, (can->io_base + CAN_IF1_CREQ_OFFSET));
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev,
+		   "%s -> Reading transmit buffer failed.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Setting the IF2CMASK register for accessing the
+		MsgVal and TxIE bits */
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
+		 (can->io_base + CAN_IF1_CMASK_OFFSET));
+
+	if (set == ENABLE) {
+		/* Setting the MsgVal and TxIE bits */
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MCONT_OFFSET),
+				CAN_IF_MCONT_TXIE);
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_ID2_OFFSET),
+				CAN_ID_MSGVAL);
+
+		dev_dbg(&ndev->dev,
+			"%s -> Enabled transmit message buffer %u\n",
+			__func__, buff_num);
+	} else if (set == DISABLE) {
+		/* Resetting the MsgVal and TxIE bits. */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET),
+				  CAN_IF_MCONT_TXIE);
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID2_OFFSET),
+				  CAN_ID_MSGVAL);
+
+		dev_dbg(&ndev->dev,
+		  "%s -> Disabled transmit message buffer %u\n",
+		  __func__, buff_num);
+	}
+
+	/* Updating the changes to the message buffer. */
+	iowrite32(buff_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	/* Confirming the updation. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {	/* Updation failed. */
+		dev_err(&ndev->dev,
+			"%s -> Write failed.\n", __func__);
+		retval = -EPERM;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_tx_enable_all(struct can_hw *can, struct net_device *ndev)
+{
+	u32 counter = 0;
+	int retval = 0;
+	u32 i;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	}
+	/* Traversing to obtain the object configured as transmit
+							 object. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_TX) {
+			/* Here i denotes the index, however (i+1) is
+						 the object number. */
+			retval = pch_can_set_tx_enable(can, (i + 1),
+						       ENABLE, ndev);
+
+			if (retval == -EPERM) {
+				counter++;
+				dev_dbg(&ndev->dev, "%s -> "
+					"Cannot Enable transmit object %u\n",
+					__func__, (i + 1));
+			} else {
+				dev_dbg(&ndev->dev, "%s -> "
+					"Enabled transmit object %u\n",
+					__func__, (i + 1));
+			}
+		}
+	}
+
+	/* If enabling of all transmit object failed. */
+	if (counter == pch_can_tx_buf_size) {
+		dev_err(&ndev->dev, "%s failed.\n", __func__);
+		retval = -EPERM;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_tx_disable_all(struct can_hw *can, struct net_device *ndev)
+{
+	u32 counter = 0;
+	int retval = 0;
+	u32 i;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid Handle.\n", __func__);
+		return -EPERM;
+	}
+	/* Traversing to obtain the object configured as transmit
+							 object. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_tx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_TX) {
+			/* Here i denotes the index, however (i+1) is
+						 the object number. */
+
+			/* Disabling. */
+			retval = pch_can_set_tx_enable(can, (i + 1), DISABLE,
+						       ndev);
+
+			if (retval == -EPERM) {
+				dev_dbg(&ndev->dev,  "%s -> Disabling"
+					" Tx buffer %u failed.\n",
+					__func__, (i + 1));
+				counter++;
+			} else {
+				dev_dbg(&ndev->dev,
+				  "%s -> Disabled transmit object %u\n",
+				  __func__, (i + 1));
+			}
+		}
+	}
+
+	/* If disabling of all the transmit object failed. */
+	if (counter == pch_can_tx_buf_size) {
+		dev_err(&ndev->dev, "%s -> failed.\n", __func__);
+		retval = -EPERM;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_set_rx_filter(struct can_hw *can,
+				 struct pch_can_rx_filter *filter)
+{
+	u32 reg1;
+	u32 reg2;
+	u32 counter;
+	int retval = 0;
+	u32 if1_creq;
+	if (!can || !filter)
+		return -EPERM;
+
+	/* Setting the CMASK for reading */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+
+	/* Setting CREQ to specified Msg Obj. */
+	iowrite32(filter->num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	/* Confirming the read completion. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter)	/* Read Unsuccessful. */
+		return -EPERM;
+
+	/* Clearing the bit 0- 12 of ID2 */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID2_OFFSET),
+			  MSK_ALL_THIRTEEN);
+
+	/* Clearing XTD bit */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID2_OFFSET), CAN_ID2_XTD);
+
+	if (filter->aidr.id_ext) { /* Extended ID */
+		reg1 = filter->aidr.id & MSK_ALL_SIXTEEN; /* ID1 value. */
+
+		/* ID2 value with XTD bit set. */
+		reg2 = (((filter->aidr.id &
+				(MSK_ALL_THIRTEEN << 16)) >> 16) | CAN_ID2_XTD);
+
+	} else {	/* Standard ID */
+
+		reg1 = 0;
+		reg2 = (filter->aidr.id & MSK_ALL_ELEVEN) << 2;
+	}
+
+	iowrite32(reg1, (can->io_base + CAN_IF1_ID1_OFFSET));
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_ID2_OFFSET), reg2);
+
+	if (filter->umask) {
+		/* Clearing bit 0-12 */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MASK2_OFFSET),
+				  MSK_ALL_THIRTEEN);
+
+		/* Clearing Mdir & MXtd */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MASK2_OFFSET),
+				  CAN_MASK2_MDIR_MXTD);
+
+		if (filter->amr.id_ext) { /* Extended Mask */
+			/* Mask1 value */
+			reg1 = filter->amr.id & MSK_ALL_SIXTEEN;
+
+			/* Mask2 value with MXtd set */
+			reg2 = (((filter->amr.id &
+				  (MSK_ALL_THIRTEEN << 16)) >> 16) |
+				  CAN_IF_MASK2_MXTD);
+		} else {
+			reg1 = 0;
+
+			/* Mask2 Value */
+			reg2 = ((filter->amr.id & MSK_ALL_ELEVEN) << 2);
+		}
+
+		/* Writing MASK1 */
+		iowrite32(reg1, (can->io_base + CAN_IF1_MASK1_OFFSET));
+
+		/* Writing MASK2 */
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MASK2_OFFSET), reg2);
+
+		/* Setting Umask bit */
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MCONT_OFFSET),
+				CAN_IF_MCONT_UMASK);
+	} else {
+		/* Resetting Umask bit. */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET),
+				  CAN_IF_MCONT_UMASK);
+	}
+
+	/* Setting CMASK for writing */
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_MASK | CAN_CMASK_ARB |
+		  CAN_CMASK_CTRL), (can->io_base + CAN_IF1_CMASK_OFFSET));
+
+	/* Setting CREQ for specified sg Obj. */
+	iowrite32(filter->num, (can->io_base + CAN_IF1_CREQ_OFFSET));
+
+	/* Confirming the write completion. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) /* Write failed */
+		retval = -EPERM;
+
+	return retval;
+}
+
+static int pch_can_rx_init_filter(struct can_hw *can, u32 buff_num,
+				  struct net_device *ndev)
+{
+	int retval = 0;
+	struct pch_can_rx_filter filter;
+
+	if (!can) {
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_RX) ||
+		 (buff_num > (pch_can_tx_buf_size + pch_can_rx_buf_size))) {
+		/* if invalid buffer number. */
+		dev_err(&ndev->dev,
+			"%s -> Invalid buffer no:%d\n", __func__, buff_num);
+		return -EPERM;
+	}
+	/* Set all Rx filters to allow all msgs. */
+	filter.amr.id = 0;
+	filter.amr.id_ext = 0;
+
+	filter.aidr.id = 0;
+	filter.aidr.id_ext = 0;
+
+	filter.num = buff_num;
+	filter.umask = 1;
+
+	retval = pch_can_set_rx_filter(can, &filter);
+
+	return retval;
+}
+
+static int pch_can_get_rx_enable(struct can_hw *can, u32 buff_num, u32 *enable,
+				 struct net_device *ndev)
+{
+	int retval = 0;
+	u32 counter;
+	u32 if1_creq;
+
+	if (!can || !enable) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	}
+	/* Invalid buffer number. */
+	else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_RX) ||
+		 (buff_num > (pch_can_tx_buf_size + pch_can_rx_buf_size))) {
+		dev_err(&ndev->dev,
+			"%s -> Message object %u not configured for receive.\n",
+			__func__, buff_num);
+		return -EPERM;
+	}
+
+	iowrite32(CAN_CMASK_RX_TX_GET, (can->io_base + CAN_IF1_CMASK_OFFSET));
+	iowrite32(buff_num, (can->io_base + CAN_IF1_CREQ_OFFSET));
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32((can->io_base + CAN_IF1_CREQ_OFFSET))) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev, "%s -> Read Failed.\n", __func__);
+		return -EPERM;
+	}
+	if (((ioread32(can->io_base + CAN_IF1_ID2_OFFSET)) & CAN_ID_MSGVAL) &&
+			((ioread32(can->io_base + CAN_IF1_MCONT_OFFSET)) &
+			CAN_IF_MCONT_RXIE)) {
+		*enable = ENABLE;
+
+		dev_dbg(&ndev->dev,
+			"%s -> Receive message buffer %u is enabled.\n",
+			__func__, buff_num);
+	} else {
+		*enable = DISABLE;
+		dev_dbg(&ndev->dev,
+			"%s -> Receive Message buffer %u is disabled.\n",
+			__func__, buff_num);
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_get_tx_enable(struct can_hw *can, u32 buff_num, u32 *enable,
+				 struct net_device *ndev)
+{
+	int retval = 0;
+	u32 counter;
+	u32 if1_creq;
+
+	if (!can || !enable) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	}
+	/* invalid buffer number. */
+	else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_TX) ||
+		 (buff_num > (pch_can_rx_buf_size + pch_can_tx_buf_size))) {
+		dev_err(&ndev->dev,
+			"%s -> Invalid Message object %u.\n",
+			__func__, buff_num);
+		return -EPERM;
+	}
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(buff_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev, "%s -> Read Failed.\n", __func__);
+		return -EPERM;
+	}
+
+	if (((ioread32(can->io_base + CAN_IF1_ID2_OFFSET)) & CAN_ID_MSGVAL) &&
+			((ioread32(can->io_base + CAN_IF1_MCONT_OFFSET)) &
+			CAN_IF_MCONT_TXIE)) {
+		*enable = ENABLE;
+
+		dev_dbg(&ndev->dev,
+			"%s -> Transmit message buffer %u is enabled.\n",
+			__func__, buff_num);
+	} else {
+		*enable = DISABLE;
+
+		dev_dbg(&ndev->dev,
+			"%s -> Transmit message buffer %u is disabled.\n",
+			__func__, buff_num);
+	}
+
+	return retval;
+}
+
+/* This function returns whether or not interrupts are pending for the CAN
+ * device.
+*/
+static int pch_can_int_pending(struct can_hw *can)
+{
+	int retval = 0;
+
+	if (!can)
+		return -EPERM;
+
+	retval = (ioread32(can->io_base + CAN_INT_OFFSET) & MSK_ALL_SIXTEEN);
+
+	return retval;
+}
+
+static int pch_can_set_baud(struct can_hw *can, struct pch_can_timing *timing)
+{
+	u32 reg_val;
+
+	if (!can || !timing)
+		return -EPERM;
+
+	/* max is MAX_BITRATE */
+	else if (timing->bitrate > MAX_BITRATE)
+		return -EPERM;
+
+	/* Setting the CCE bit of Can control register for accessing the
+						 Can Timing register. */
+	PCH_CAN_BIT_SET((can->io_base + CAN_CONT_OFFSET), CAN_CTRL_CCE);
+
+	/* Obtaining the appropriate register value. */
+	reg_val =
+	    (((timing->cfg_bitrate & MSK_BITT_BRP) << BIT_BITT_BRP) |
+	    (timing->cfg_tseg1 << BIT_BITT_TSEG1) |
+	    (timing->cfg_tseg2 << BIT_BITT_TSEG2) |
+	    (timing->cfg_sjw << BIT_BITT_SJW));
+
+	/* Writing to the timing register. */
+	iowrite32(reg_val, (can->io_base + CAN_BITT_OFFSET));
+	/* Writing to the BRPE register. */
+	iowrite32(((timing->cfg_bitrate & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE),
+				(can->io_base + CAN_BRPE_OFFSET));
+
+	/* Resetting the CCE bit. */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_CONT_OFFSET), CAN_CTRL_CCE);
+
+	return 0;
+}
+
+static int pch_can_get_baud(struct can_hw *can, struct pch_can_timing *timing)
+{
+	u32 timing_bitt_reg;
+	u32 timing_brpe_reg;
+	int retval = 0;
+
+	if (!can || !timing)
+		return -EPERM;
+
+	timing_bitt_reg = ioread32(can->io_base + CAN_BITT_OFFSET);
+	timing_brpe_reg = ioread32(can->io_base + CAN_BRPE_OFFSET);
+
+	/* Separating the individual part from the values read. */
+	timing->cfg_bitrate = ((timing_bitt_reg & MSK_BITT_BRP) |
+			((timing_brpe_reg & MSK_BRPE_GET) << BIT_BRPE_BRPE));
+	timing->cfg_tseg1 =
+			(timing_bitt_reg & MSK_BITT_TSEG1) >> BIT_BITT_TSEG1;
+	timing->cfg_tseg2 =
+			(timing_bitt_reg & MSK_BITT_TSEG2) >> BIT_BITT_TSEG2;
+	timing->cfg_sjw =
+			(timing_bitt_reg & MSK_BITT_SJW) >> BIT_BITT_SJW;
+
+	return retval;
+}
+
+static int pch_can_set_rx_buffer_link(struct can_hw *can, u32 buffer_num,
+				      u32 set, struct net_device *ndev)
+{
+	u32 counter;
+	int retval = 0;
+	u32 if1_creq;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid handle.\n", __func__);
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buffer_num - 1] != MSG_OBJ_RX) ||
+		(buffer_num > (pch_can_rx_buf_size + pch_can_tx_buf_size))) {
+		/* invalid buffer nummber. */
+		dev_err(&ndev->dev, "%s -> Invalid buffer number %u.\n"
+							, __func__, buffer_num);
+		return -EPERM;
+	}
+	/* Reading the corresponding object. */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(buffer_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = ioread32((can->io_base + CAN_IF1_CREQ_OFFSET)) &
+						CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	/* Confirming read. */
+	if (!counter) {
+		dev_err(&ndev->dev, "%s -> Read failed\n", __func__);
+		return -EPERM;
+	}
+
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL),
+		can->io_base + CAN_IF1_CMASK_OFFSET);
+
+	/*
+	Setting/Resetting the EOD bit for Buffer link operation.
+	EOB bit = 1 -> Buffer link disabled.
+	EOB bit = 0 -> Biffer link enabled.
+	*/
+	if (set == ENABLE) {
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET),
+				  CAN_IF_MCONT_EOB);
+		dev_dbg(&ndev->dev,
+			"%s -> Buffer Link enabled.\n", __func__);
+	} else {
+		PCH_CAN_BIT_SET((can->io_base +	CAN_IF1_MCONT_OFFSET),
+				CAN_IF_MCONT_EOB);
+		dev_dbg(&ndev->dev,
+		    "%s -> Buffer Link disabled.\n", __func__);
+	}
+
+	iowrite32(buffer_num, (can->io_base + CAN_IF1_CREQ_OFFSET));
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = ioread32(can->io_base + CAN_IF1_CREQ_OFFSET) &
+				    CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		dev_err(&ndev->dev, "%s -> Write failed.\n", __func__);
+		retval = -EPERM;
+	} else {
+		dev_dbg(&ndev->dev,
+			"%s -> Write successful.\n", __func__);
+		retval = 0;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_get_rx_buffer_link(struct can_hw *can, u32 buffer_num,
+				      u32 *link, struct net_device *ndev)
+{
+	u32 reg_val;
+	u32 counter;
+	int retval = 0;
+	u32 if1_creq;
+
+	if (!can || !link) {
+		dev_err(&ndev->dev, "%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buffer_num - 1] != MSG_OBJ_RX) ||
+		   (buffer_num > (pch_can_rx_buf_size + pch_can_tx_buf_size))) {
+		dev_err(&ndev->dev,
+		    "%s -> Invalid buffer number %u.\n", __func__, buffer_num);
+		return -EPERM;
+	}
+	/* Reading the corresponding message object. */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(buffer_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32((can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY);
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	/* Confirming read. */
+	if (!counter) {
+		dev_err(&ndev->dev, "%s -> Read Failed.\n", __func__);
+		return -EPERM;
+	}
+	/* Checking for the EOB bit.
+	   EOB bit = 1 -> Buffer link disabled.
+	   EOB bit = 0 -> Biffer link enabled.
+	 */
+	reg_val = ioread32(can->io_base + CAN_IF1_MCONT_OFFSET);
+	if (reg_val & CAN_IF_MCONT_EOB)
+		*link = DISABLE;
+	else
+		*link = ENABLE;
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_get_rx_filter(struct can_hw *can,
+				 struct pch_can_rx_filter *filter,
+				 struct net_device *ndev)
+{
+	u32 reg_val1;
+	u32 reg_val2;
+	u32 counter;
+	int retval = 0;
+	u32 if1_creq;
+
+	if (!can || !filter) {
+		dev_err(&ndev->dev, "%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	}
+	/* Preparing to read the specified Msg Obj. */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(filter->num, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	/* Confirming the read completion. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {	/* Read unsuccessful. */
+		dev_err(&ndev->dev,
+			"%s -> Reading of receive buffer %u failed.\n",
+			__func__, filter->num);
+		return -EPERM;
+	}
+
+	/* Checking for Umask */
+	reg_val1 = ioread32((can->io_base + CAN_IF1_MCONT_OFFSET));
+	filter->umask = ((CAN_IF_MCONT_UMASK & reg_val1) >> 12);
+
+	if (filter->umask) {	/* If Umask is set */
+		/* Reading MASK2 register. */
+		reg_val1 = ioread32((can->io_base + CAN_IF1_MASK2_OFFSET));
+
+		if (CAN_IF_MASK2_MXTD & reg_val1) {
+			/* Extended Mask set.
+					 Mask ID is 29 bits */
+			reg_val2 = ioread32(can->io_base +
+					    CAN_IF1_MASK1_OFFSET);
+
+			/* Extracting the 16 MSB bits of the 29bit ID. */
+			reg_val2 = reg_val2 & MSK_ALL_SIXTEEN;
+
+			/* Extracting the remaing 13 bits */
+			reg_val1 = reg_val1 & MSK_ALL_THIRTEEN;
+
+			/* Combing them to a single 29bit ID. */
+			reg_val1 = reg_val1 << 16;
+			reg_val1 = reg_val1 | reg_val2;
+
+			filter->amr.id = reg_val1;
+			filter->amr.id_ext = 1;
+		} else { /* Standard Mask 11bit Mask ID */
+
+			/* Extracting the 13 bits of MASK2 register. */
+			reg_val1 = reg_val1 & MSK_ALL_THIRTEEN;
+
+			/* Modifying it to represent 11bit Mask ID */
+			reg_val1 = reg_val1 >> 2;
+
+			filter->amr.id = reg_val1;
+			filter->amr.id_ext = 0;
+		}
+	}
+
+	reg_val1 = ioread32((can->io_base + CAN_IF1_ID2_OFFSET));
+
+	if (CAN_ID2_XTD & reg_val1) {	/* Extended ID 29bits */
+		reg_val2 = ioread32((can->io_base + CAN_IF1_ID1_OFFSET));
+
+		/* Extracting the 16 MSB bits of the 29bit ID. */
+		reg_val2 = reg_val2 & MSK_ALL_SIXTEEN;
+
+		/* Extracting the remaining 13 bit. */
+		reg_val1 = reg_val1 & MSK_ALL_THIRTEEN;
+
+		/* Combining them to represent 29bit ID. */
+		reg_val1 = reg_val1 << 16;
+		reg_val1 = reg_val1 | reg_val2;
+
+		filter->aidr.id = reg_val1;
+		filter->aidr.id_ext = 1;
+	} else {	/* Standard Id 11bits. */
+
+		/* Extracting the 13 bits of ID2 register */
+		reg_val1 = reg_val1 & MSK_ALL_THIRTEEN;
+		/* Modifying it to represent the 11 bit ID */
+		reg_val1 = reg_val1 >> 2;
+
+		filter->aidr.id = reg_val1;
+		filter->aidr.id_ext = 0;
+	}
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d.\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_clear_buffers(struct can_hw *can)
+{
+	u32 i;
+	u32 rx_buff_num;
+	u32 tx_buff_num;
+	int retval = 0;
+
+	if (!can)
+		return -EPERM;
+
+	iowrite32(CAN_CMASK_RX_TX_SET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(CAN_CMASK_RX_TX_SET, can->io_base + CAN_IF2_CMASK_OFFSET);
+	iowrite32(MSK_ALL_SIXTEEN, can->io_base + CAN_IF1_MASK1_OFFSET);
+	iowrite32(MSK_ALL_SIXTEEN, can->io_base + CAN_IF1_MASK2_OFFSET);
+	iowrite32(MSK_ALL_SIXTEEN, can->io_base + CAN_IF2_MASK1_OFFSET);
+	iowrite32(MSK_ALL_SIXTEEN, can->io_base + CAN_IF2_MASK2_OFFSET);
+
+	iowrite32(0x0, can->io_base + CAN_IF1_ID1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_ID2_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_ID1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_ID2_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_MCONT_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_MCONT_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_DATAA1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_DATAA2_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_DATAB1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF1_DATAB2_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_DATAA1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_DATAA2_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_DATAB1_OFFSET);
+	iowrite32(0x0, can->io_base + CAN_IF2_DATAB2_OFFSET);
+
+	for (i = 1; i <= (MAX_MSG_OBJ / 2); i++) {
+		rx_buff_num = 2 * i;
+		tx_buff_num = (2 * i) - 1;
+
+		iowrite32(rx_buff_num, can->io_base + CAN_IF1_CREQ_OFFSET);
+		iowrite32(tx_buff_num, can->io_base + CAN_IF2_CREQ_OFFSET);
+
+		mdelay(10);
+	}
+
+	return retval;
+}
+
+static void pch_can_config_rx_tx_buffers(struct can_hw *can,
+					 struct net_device *ndev)
+{
+	u32 i;
+	u32 counter;
+	u32 if1_creq;
+	u32 if2_creq;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid handle.\n", __func__);
+		return;
+	}
+
+	/*For accssing MsgVal, ID and EOB bit */
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
+		       (can->io_base + CAN_IF1_CMASK_OFFSET));
+	iowrite32((CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL),
+		       (can->io_base + CAN_IF2_CMASK_OFFSET));
+
+	iowrite32(0x0, (can->io_base + CAN_IF1_ID1_OFFSET));
+	iowrite32(0x0, (can->io_base + CAN_IF1_ID2_OFFSET));
+
+	/* Resetting DIR bit for reception */
+	iowrite32(0x0, (can->io_base + CAN_IF2_ID1_OFFSET));
+
+	/* Setting DIR bit for transmission */
+	iowrite32((CAN_ID2_DIR | (MSK_ALL_ELEVEN << 2)),
+				(can->io_base + CAN_IF2_ID2_OFFSET));
+
+	/* Setting EOB bit for receiver */
+	iowrite32(CAN_IF_MCONT_EOB, can->io_base + CAN_IF1_MCONT_OFFSET);
+
+	/* Setting EOB bit for transmitter */
+	iowrite32(CAN_IF_MCONT_EOB,
+			(can->io_base + CAN_IF2_MCONT_OFFSET));
+
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		counter = COUNTER_LIMIT;
+		/* Configure the receive message objects */
+		if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+
+			iowrite32((i + 1), can->io_base + CAN_IF1_CREQ_OFFSET);
+
+			while (counter) {
+				if1_creq = (ioread32(can->io_base +
+						     CAN_IF1_CREQ_OFFSET)) &
+						     CAN_IF_CREQ_BUSY;
+				if (!if1_creq)
+					break;
+
+				counter--;
+			}
+
+			if (!counter) {
+				dev_dbg(&ndev->dev,
+					"%s ->Config failed for receive message"
+					" object %u\n", __func__, (i + 1));
+			}
+		}
+		/* Configure the transmit message objects */
+		else if (pch_msg_obj_conf[i] == MSG_OBJ_TX) {
+			iowrite32((i + 1), can->io_base + CAN_IF2_CREQ_OFFSET);
+
+			while (counter) {
+				if2_creq = (ioread32(can->io_base +
+						     CAN_IF2_CREQ_OFFSET)) &
+						     CAN_IF_CREQ_BUSY;
+				if (!if2_creq)
+					break;
+
+				counter--;
+			}
+
+			if (!counter) {
+				dev_dbg(&ndev->dev, "%s ->Config failed for "
+					"transmit message object %u\n",
+					__func__, (i + 1));
+			}
+		}
+
+	}
+}
+
+static int pch_can_open(struct can_hw *can, enum pch_can_listen_mode listen,
+			enum pch_can_arbiter arbiter, struct net_device *ndev)
+{
+	int retval;
+	s32 i;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid handle.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Stopping the Can device. */
+	retval = pch_can_set_run_mode(can, PCH_CAN_STOP, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_run_mode failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+
+	/* Clearing all the message object buffers. */
+	retval = pch_can_clear_buffers(can);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s ->pch_can_clear_buffers failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+
+	/* Configuring the respective message object as either rx/tx object. */
+	pch_can_config_rx_tx_buffers(can, ndev);
+
+	/* Initializing filters for receive object. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+			/* Here i denotes the index, however
+				 the object number is (i+1) */
+			retval = pch_can_rx_init_filter(can, i + 1, ndev);
+
+			if (retval) {
+				dev_err(&ndev->dev,
+					"pch_can_rx_init_filter failed.:%d\n",
+					(i + 1));
+				break;
+			}
+		}
+	}
+	if (retval)
+		goto out;
+
+	/* Enabling all receive objects. */
+	retval = pch_can_rx_enable_all(can, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_rx_enable_all failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_rx_enable_all invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Enabling all transmit objects. */
+	retval = pch_can_tx_enable_all(can, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_tx_enable_all failed (returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_tx_enable_all invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Setting the arbiter mode. */
+	retval = pch_can_set_arbiter_mode(can, arbiter, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_arbiter_mode failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+
+	/* Setting the listen mode. */
+	retval = pch_can_set_listen_mode(can, listen, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_listen_mode failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_listen_mode invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Enabling the interrupts. */
+	retval = pch_can_set_int_enables(can, CAN_ALL, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_int_enables failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_int_enables invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Setting the restart mode. */
+	retval = pch_can_set_restart_mode(can, CAN_AUTO, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_restart_mode failed (retval= %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_restart_mode invoked success(retval= %d).\n",
+		__func__, retval);
+
+	/* Setting the CAN to run mode. */
+	retval = pch_can_set_run_mode(can, PCH_CAN_RUN, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_run_mode failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_set_run_mode invoked success(retval= %d).\n",
+		__func__, retval);
+
+out:
+	dev_dbg(&ndev->dev, "%s returns %d.\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_release(struct can_hw *can, struct net_device *ndev)
+{
+	int retval = 0;
+
+	if (!can) {
+		dev_err(&ndev->dev, "%s -> Invalid handle.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Stooping the CAN device. */
+	retval = pch_can_set_run_mode(can, PCH_CAN_STOP, ndev);
+
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_run_mode failed (returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_run_mode invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Disabling the interrupts. */
+	retval = pch_can_set_int_enables(can, CAN_NONE, ndev);
+
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_set_int_enables failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_set_int_enables invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Disabling all the receive object. */
+	retval = pch_can_rx_disable_all(can, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_rx_disable_all failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_rx_disable_all invoked success(returned %d).\n",
+		__func__, retval);
+
+	/* Disabling all the transmit object. */
+	retval = pch_can_tx_disable_all(can, ndev);
+	if (retval == -EPERM) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_tx_disable_all failed(returned %d).\n",
+			__func__, retval);
+		goto out;
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> pch_can_tx_disable_all invoked succesS(returned %d).\n",
+		__func__, retval);
+
+out:
+	dev_dbg(&ndev->dev, "%s returns %d.\n", __func__, retval);
+	return retval;
+}
+
+/* This function clears interrupt(s) from the CAN device. */
+static void pch_can_int_clr(struct can_hw *can, u32 mask,
+			    struct net_device *ndev)
+{
+	u32 counter;
+	u32 rtr;
+	u32 if2_creq;
+
+	if (!(can && mask)) {
+		dev_err(&ndev->dev, "%s -> Invalid parameter\n", __func__);
+		return;
+	}
+	/* Clearing status interrupt. */
+	if (mask == CAN_STATUS_INT) {
+		ioread32((can->io_base + CAN_STAT_OFFSET));
+		dev_dbg(&ndev->dev,
+			"%s -> Status Interrupt cleared.\n", __func__);
+		return;
+	}
+
+	if ((mask <= 0) || (mask > MAX_MSG_OBJ)) {
+		dev_err(&ndev->dev, "%s -> Invalid parameter(mask=0x%x)\n",
+			__func__, mask);
+		return;
+	}
+
+	/* Clear interrupt for transmit object */
+	if (pch_msg_obj_conf[mask - 1] == MSG_OBJ_TX) {
+		/* Checking if the transmission is for remote
+						 frame. */
+		rtr = (!(ioread32((can->io_base + CAN_IF2_ID2_OFFSET)) &
+				  CAN_ID2_DIR));
+
+		if (rtr) {
+
+			dev_dbg(&ndev->dev,
+				"%s -> Remote frame transmission interrupt "
+				"cleared for message object %d.\n",
+				__func__, mask);
+		} else {
+			dev_dbg(&ndev->dev,
+				"%s -> Data frame transmission interrupt "
+				"cleared for message object %d.\n",
+				__func__, mask);
+		}
+
+		/* Setting CMASK for clearing interrupts for
+					 frame transmission. */
+		iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB),
+					(can->io_base +	CAN_IF2_CMASK_OFFSET));
+
+		/* Resetting the ID registers. */
+		PCH_CAN_BIT_SET((can->io_base + CAN_IF2_ID2_OFFSET),
+				(CAN_ID2_DIR | (MSK_ALL_ELEVEN << 2)));
+		iowrite32(0x0, (can->io_base + CAN_IF2_ID1_OFFSET));
+
+		/* Claring NewDat, TxRqst & IntPnd */
+		PCH_CAN_BIT_CLEAR((can->io_base +
+				   CAN_IF2_MCONT_OFFSET),
+				  (CAN_IF_MCONT_NEWDAT |
+				   CAN_IF_MCONT_INTPND |
+				   CAN_IF_MCONT_TXRQXT));
+
+		iowrite32(mask, can->io_base + CAN_IF2_CREQ_OFFSET);
+
+		counter = COUNTER_LIMIT;
+		while (counter) {
+			if2_creq = (ioread32(can->io_base +
+					     CAN_IF2_CREQ_OFFSET) &
+					     CAN_IF_CREQ_BUSY);
+			if (!if2_creq)
+				break;
+
+			counter--;
+		}
+	}
+	/* Clear interrupt for receive object */
+	else if (pch_msg_obj_conf[mask - 1] == MSG_OBJ_RX) {
+		/* Checking if the reception is for remote frame. */
+		rtr = (ioread32((can->io_base +	CAN_IF2_ID2_OFFSET)) &
+				CAN_ID2_DIR);
+
+		if (rtr) {	/* if remote frame. */
+			dev_dbg(&ndev->dev,
+				"%s -> Remote frame reception interrupt cleared"
+				" for message object %d.\n", __func__, mask);
+		} else {
+			dev_dbg(&ndev->dev,
+				"%s -> Data frame reception interrupt cleared "
+				"for message object %d.\n", __func__, mask);
+		}
+
+		/* Setting CMASK for clearing the reception interrupts. */
+		iowrite32((CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB),
+			  (can->io_base + CAN_IF2_CMASK_OFFSET));
+
+		/* Clearing the Dir bit. */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF2_ID2_OFFSET),
+				  CAN_ID2_DIR);
+
+		/* Clearing NewDat & IntPnd */
+		PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF2_MCONT_OFFSET),
+				  (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND));
+
+		iowrite32(mask, can->io_base + CAN_IF2_CREQ_OFFSET);
+
+		counter = COUNTER_LIMIT;
+		while (counter) {
+			if2_creq = ioread32(can->io_base +
+					    CAN_IF2_CREQ_OFFSET) &
+					    CAN_IF_CREQ_BUSY;
+			if (!if2_creq)
+				break;
+
+			counter--;
+		}
+
+	}
+}
+
+static int pch_can_get_buffer_status(struct can_hw *can)
+{
+	u32 reg_treq1;
+	u32 reg_treq2;
+	int retval = 0;
+
+	if (!can)
+		return -EPERM;
+
+	/* Reading the transmission request registers. */
+	reg_treq1 = (ioread32(can->io_base + CAN_TREQ1_OFFSET) &
+			      MSK_ALL_SIXTEEN);
+	reg_treq2 = ((ioread32(can->io_base + CAN_TREQ2_OFFSET) &
+			       MSK_ALL_SIXTEEN) << 16);
+
+	retval = (reg_treq1 | reg_treq2);
+
+	return retval;
+}
+
+static int pch_can_msg_tx(struct can_hw *can, struct pch_can_msg *msg,
+			  struct net_device *ndev)
+{
+	u32 id1 = 0;
+	u32 id2 = 0;
+	u32 data_a1 = 0;
+	u32 data_a2 = 0;
+	u32 data_b1 = 0;
+	u32 data_b2 = 0;
+	u32 tx_disable_counter = 0;
+	u32 buffer_status = 0;
+	u32 tx_buffer_avail = 0;
+	u32 status;
+	u32 i;
+	u32 counter;
+	enum pch_can_run_mode run_mode;
+	int retval = 0;
+	unsigned long flags;
+	u32 if1_creq;
+	struct pch_can_os *can_os;
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	can_os = &priv->pch_can_os_p;
+
+	if (!can || !msg) {
+		dev_err(&ndev->dev, "%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Getting the current CAN mode. */
+	pch_can_get_run_mode(can, &run_mode, ndev);
+
+	/* If CAN is in STOP mode. */
+	if (run_mode != PCH_CAN_RUN) {
+		dev_err(&ndev->dev,
+		  "%s -> CAN stopped on transmit attempt.\n", __func__);
+		return -EPERM;
+	}
+
+	/* Attaining the lock. */
+	spin_lock_irqsave(&can_os->tx_spinlock, flags);
+
+	/* Getting the message object status. */
+	buffer_status = (u32) pch_can_get_buffer_status(can);
+
+	/* Getting the free transmit message object. */
+	for (i = 0; i < (pch_can_rx_buf_size + pch_can_tx_buf_size); i++) {
+		if ((pch_msg_obj_conf[i] == MSG_OBJ_TX)) {
+			/* Checking whether the object is enabled. */
+			pch_can_get_tx_enable(can, i + 1, &status, ndev);
+
+			if ((ENABLE == status)) {
+				if (!((buffer_status >> i) & 1)) {
+					tx_buffer_avail = (i + 1);
+					break;
+				}
+			} else {
+				tx_disable_counter++;
+			}
+		}
+	}
+
+	/* If no transmit object available. */
+	if (!tx_buffer_avail) {
+		dev_dbg(&ndev->dev, "%s -> tx_disable_counter = %d.\n",
+			__func__, tx_disable_counter);
+		spin_unlock_irqrestore(&can_os->tx_spinlock, flags);
+		/* If no object is enabled. */
+		if ((tx_disable_counter == pch_can_tx_buf_size)) {
+			retval = -EPERM;
+			dev_err(&ndev->dev,
+				"%s -> All transmit buffers are disabled.\n",
+				__func__);
+			goto out;
+		} else {
+			retval = PCH_CAN_NO_TX_BUFF;
+			dev_err(&ndev->dev,
+				"%s -> No transmit buffer free.\n", __func__);
+			goto out;
+		}
+	}
+	dev_dbg(&ndev->dev, "%s ->Transmit buffer obtained.\n", __func__);
+
+	/* Reading the message object from the Message
+		 RAM to the Interface register. */
+	iowrite32(CAN_CMASK_RX_TX_GET, can->io_base + CAN_IF1_CMASK_OFFSET);
+	iowrite32(tx_buffer_avail, can->io_base + CAN_IF1_CREQ_OFFSET);
+
+	/* Confirming the read. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+	/* If Read not successful. */
+	if (!counter) {
+		pch_can_set_tx_enable(can, tx_buffer_avail, ENABLE, ndev);
+		retval = -EPERM;
+		goto out;
+	}
+
+	/* Setting the CMASK register. */
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_CMASK_OFFSET), CAN_CMASK_ALL);
+
+	/* If ID extended is set. */
+	if (msg->ide) {
+		/* Setting 29 bit ID with XTD bit set. */
+		id1 = msg->id & MSK_ALL_SIXTEEN;
+		id2 = ((msg->id & (MSK_ALL_THIRTEEN << 16)) >> 16);
+		id2 |= CAN_ID2_XTD;
+	} else {
+		/* Setting 11bit ID with XTD bit
+				 reset. */
+		id1 = 0;
+		id2 = ((msg->id & MSK_ALL_ELEVEN) << 2);
+	}
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID1_OFFSET),
+			  MSK_ALL_SIXTEEN);
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_ID2_OFFSET),
+			  (MSK_ALL_THIRTEEN | CAN_ID2_XTD));
+
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_ID1_OFFSET), id1);
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_ID2_OFFSET), id2);
+
+	/* If remote frame has to be
+			 transmitted.. */
+	if (msg->rtr) {
+		PCH_CAN_BIT_CLEAR((
+			can->io_base + CAN_IF1_ID2_OFFSET), CAN_ID2_DIR);
+		msg->dlc = 0;
+
+		dev_dbg(&ndev->dev,
+		  "%s -> Transmitting a remote frame.\n", __func__);
+	} else {	/* Data frame
+			 transmission. */
+
+		msg->dlc &= MSK_ALL_FOUR;
+		dev_dbg(&ndev->dev,
+		  "%s -> Transmitting a data frame.\n", __func__);
+	}
+
+	/* Writing the data and the DLC */
+	switch (msg->dlc) {
+	case 0:
+		break;
+
+	case 1:
+		data_a1 = msg->data[0];
+		break;
+	case 2:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		break;
+	case 3:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		break;
+	case 4:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		data_a2 |= (((u32) msg->data[3]) << 8);
+		break;
+	case 5:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		data_a2 |= (((u32) msg->data[3]) << 8);
+		data_b1 = msg->data[4];
+		break;
+	case 6:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		data_a2 |= (((u32) msg->data[3]) << 8);
+		data_b1 = msg->data[4];
+		data_b1 |= (((u32) msg->data[5]) << 8);
+		break;
+	case 7:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		data_a2 |= (((u32) msg->data[3]) << 8);
+		data_b1 = msg->data[4];
+		data_b1 |= (((u32) msg->data[5]) << 8);
+		data_b2 = msg->data[6];
+		break;
+	case 8:
+	default:
+		data_a1 = msg->data[0];
+		data_a1 |= (((u32) msg->data[1]) << 8);
+		data_a2 = msg->data[2];
+		data_a2 |= (((u32) msg->data[3]) << 8);
+		data_b1 = msg->data[4];
+		data_b1 |= (((u32) msg->data[5]) << 8);
+		data_b2 = msg->data[6];
+		data_b2 |= (((u32) msg->data[7]) << 8);
+		break;
+
+	}
+
+	/* Writing the DATA registers. */
+	iowrite32(data_a1, (can->io_base + CAN_IF1_DATAA1_OFFSET));
+	iowrite32(data_a2, (can->io_base + CAN_IF1_DATAA2_OFFSET));
+	iowrite32(data_b1, (can->io_base + CAN_IF1_DATAB1_OFFSET));
+	iowrite32(data_b2, (can->io_base + CAN_IF1_DATAB2_OFFSET));
+
+	/* Updating the size of the data. */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET), MSK_ALL_FOUR);
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MCONT_OFFSET), msg->dlc);
+
+	/* Clearing IntPend, NewDat & TxRqst */
+	PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF1_MCONT_OFFSET),
+			  (CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
+			  CAN_IF_MCONT_TXRQXT));
+
+	/* Setting NewDat, TxRqst bits */
+	PCH_CAN_BIT_SET((can->io_base + CAN_IF1_MCONT_OFFSET),
+			(CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT));
+
+	/* Writing the updation to the Message
+				 object. */
+	iowrite32(tx_buffer_avail, (can->io_base + CAN_IF1_CREQ_OFFSET));
+
+	/* Confirming the updation. */
+	counter = COUNTER_LIMIT;
+	while (counter) {
+		if1_creq = (ioread32(can->io_base + CAN_IF1_CREQ_OFFSET)) &
+				     CAN_IF_CREQ_BUSY;
+		if (!if1_creq)
+			break;
+
+		counter--;
+	}
+
+	if (!counter) {
+		retval = -EPERM;
+	} else {
+		dev_dbg(&ndev->dev,
+			"%s -> Updation of transmit buffer successful.\n"
+			"Message object enabled for transmission.\n", __func__);
+
+	}
+
+out:
+	/* Releasing the lock. */
+	spin_unlock_irqrestore(&can_os->tx_spinlock, flags);
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d.\n", __func__, retval);
+	return retval;
+}
+
+/* This function gets a pending message from the CAN device. */
+static int pch_can_rx_dequeue(struct can_hw *can, struct pch_can_msg *msg,
+			      u32 buff_num, struct net_device *ndev)
+{
+	s32 i;
+	u32 reg;
+	int retval = -EPERM;
+
+	if (!can || !msg) {
+		dev_err(&ndev->dev, "%s -> Invalid Parameter.\n", __func__);
+		return -EPERM;
+	} else if ((pch_msg_obj_conf[buff_num - 1] != MSG_OBJ_RX) ||
+		 (buff_num > (pch_can_rx_buf_size + pch_can_tx_buf_size))) {
+		/* invalid buffer number. */
+		dev_err(&ndev->dev, "%s -> Invalid Buffer number.\n", __func__);
+		return -EPERM;
+	}
+
+	msg->ide = 0;
+	msg->id = 0;
+	msg->dlc = 0;
+	for (i = 0; i < PCH_CAN_MSG_DATA_LEN;)
+		msg->data[i++] = 0;
+
+	/* Read the ID type. */
+	msg->ide = ((ioread32(can->io_base + CAN_IF2_ID2_OFFSET)) &
+			      CAN_ID2_XTD) >> 14;
+
+	/* Extracting the ID. */
+	if (msg->ide) {	/* Extended 29bit ID. */
+		msg->id = (ioread32(can->io_base + CAN_IF2_ID1_OFFSET) &
+				    MSK_ALL_SIXTEEN);
+		msg->id |= (((ioread32(can->io_base + CAN_IF2_ID2_OFFSET)) &
+				       MSK_ALL_THIRTEEN) << 16);
+	} else {	/* Standard 11bit ID. */
+
+		msg->id = (((ioread32(can->io_base + CAN_IF2_ID2_OFFSET)) &
+				     (MSK_ALL_ELEVEN << 2)) >> 2);
+	}
+
+	/* Getting the size of the data and the Remote frame bit. */
+	if (msg->rtr) {
+		msg->dlc = 0;
+
+		dev_dbg(&ndev->dev,
+		    "%s -> Remote frame read with message id: %x.\n",
+		    __func__, msg->id);
+	} else {
+		msg->dlc = ((ioread32(can->io_base + CAN_IF2_MCONT_OFFSET)) &
+				      MSK_ALL_FOUR);
+
+		dev_dbg(&ndev->dev,
+		    "%s -> Data frame read with message id: %x.\n",
+		    __func__, msg->id);
+	}
+
+	/* Reading back the data. */
+	switch (msg->dlc) {
+	case 0:
+		break;
+
+	case 1:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		break;
+
+	case 2:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+		break;
+
+	case 3:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		break;
+
+	case 4:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		msg->data[3] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+		break;
+
+	case 5:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		msg->data[3] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB1_OFFSET);
+		msg->data[4] = reg & MSK_ALL_EIGHT;
+		break;
+
+	case 6:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		msg->data[3] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB1_OFFSET);
+		msg->data[4] = reg & MSK_ALL_EIGHT;
+		msg->data[5] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+		break;
+
+	case 7:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		msg->data[3] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB1_OFFSET);
+		msg->data[4] = reg & MSK_ALL_EIGHT;
+		msg->data[5] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB2_OFFSET);
+		msg->data[6] = reg & MSK_ALL_EIGHT;
+		break;
+
+	case 8:
+	default:
+		reg = ioread32(can->io_base + CAN_IF2_DATAA1_OFFSET);
+		msg->data[0] = reg & MSK_ALL_EIGHT;
+		msg->data[1] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAA2_OFFSET);
+		msg->data[2] = reg & MSK_ALL_EIGHT;
+		msg->data[3] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB1_OFFSET);
+		msg->data[4] = reg & MSK_ALL_EIGHT;
+		msg->data[5] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		reg = ioread32(can->io_base + CAN_IF2_DATAB2_OFFSET);
+		msg->data[6] = reg & MSK_ALL_EIGHT;
+		msg->data[7] = ((reg & (MSK_ALL_EIGHT << 8)) >>	8);
+
+		break;
+	}
+	retval = 0;
+
+	dev_dbg(&ndev->dev, "%s -> Return value: %d\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_reset(struct pch_can_os *can_os)
+{
+	int retval = 0;
+
+	if (!can_os) {
+		retval = -EPERM;
+	} else {
+		/* Obtaining the remap address for access. */
+		struct can_hw *can = can_os->can;
+
+		/* write to sw reset register */
+		iowrite32(1, (can->io_base + CAN_SRST_OFFSET));
+		iowrite32(0, (can->io_base + CAN_SRST_OFFSET));
+	}
+	return retval;
+}
+
+static void pch_can_log_message(u32 status, struct net_device *ndev)
+{
+	static int cnt;
+
+	switch ((status & MSK_ALL_THREE)) {
+
+	case 0:
+		dev_dbg(&ndev->dev, "%s ->  No Error\n", __func__);
+		break;
+	case 1:
+		dev_err(&ndev->dev, "%s -> Stuff Error\n", __func__);
+		break;
+	case 2:
+		dev_err(&ndev->dev, "%s -> Form Error.\n", __func__);
+		break;
+	case 3:
+		if (!(cnt % 200))
+			dev_err(&ndev->dev, "%s -> Ack Error\n", __func__);
+		cnt++;
+		break;
+	case 4:
+		dev_err(&ndev->dev, "%s -> Bit 1 Error\n", __func__);
+		break;
+	case 5:
+		dev_err(&ndev->dev, "%s -> Bit 0 Error.\n", __func__);
+		break;
+	case 6:
+		dev_err(&ndev->dev, "%s -> Crc Error\n", __func__);
+		break;
+	case 7:
+		dev_err(&ndev->dev, "%s -> Undefined Error\n", __func__);
+		break;
+	default:
+		break;
+	}
+}
+
+static void pch_can_callback(struct net_device *ndev)
+{
+	u32 int_stat;
+	u32 reg;
+	u32 reg_stat;
+	u32 counter;
+	struct pch_can_msg receive_msg;
+	struct can_hw *can;
+	int retval = 0;
+	u32 if2_creq;
+	enum pch_can_auto_restart restart_mode = 0;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	struct can_frame *ecf;
+	struct sk_buff *eskb;
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+	struct net_device_stats *stats = &(can_os->ndev->stats);
+
+	can = (struct can_hw *)priv->pch_can_os_p.can;
+
+	/* Get the interrupt status */
+	int_stat = can_os->int_stat;
+	can_os->int_stat = 0;
+
+	/* Checking for status interrupt */
+	if (int_stat == CAN_STATUS_INT) {
+		/* Reading of the CANSTAT register. */
+		reg_stat = ioread32((can->io_base + CAN_STAT_OFFSET));
+		reg_stat = reg_stat & MSK_ALL_EIGHT;
+		dev_dbg(&can_os->ndev->dev,
+			"%s -> Status Register: %x.\n", __func__, reg_stat);
+
+		/* If recovered from Bus-Off interrupt. */
+		if (!reg_stat && can_os->bus_off_interrupt) {
+			can_os->bus_off_interrupt = 0;
+			pch_can_tx_enable_all(can_os->can, can_os->ndev);
+			pch_can_rx_enable_all(can_os->can, can_os->ndev);
+
+			dev_err(&can_os->ndev->dev,
+				"%s -> Bus off stage recovered.\n", __func__);
+			goto out;
+		}
+
+		eskb = alloc_can_err_skb(ndev, &ecf);
+		if (!eskb) {
+			dev_err(&can_os->ndev->dev,
+				"%s -> No memory.\n", __func__);
+			return;
+		}
+
+		/* Bus off interrupt. */
+		if (reg_stat & (1 << 7)) {
+			if (!can_os->bus_off_interrupt) {
+
+				dev_err(&can_os->ndev->dev,
+					"%s -> Bus off "
+					"interrupt.\n", __func__);
+
+				pch_can_tx_disable_all(can_os->can,
+							can_os->ndev);
+				pch_can_rx_disable_all(can_os->can,
+							can_os->ndev);
+
+				priv->can.state = CAN_STATE_BUS_OFF;
+				ecf->can_id |= CAN_ERR_BUSOFF;
+				can_bus_off(ndev);
+
+				pch_can_get_restart_mode(can_os->can,
+					&restart_mode, can_os->ndev);
+
+				if (restart_mode == CAN_AUTO) {
+					can_os->bus_off_interrupt = 1;
+					pch_can_set_run_mode(
+						can_os->can,
+						PCH_CAN_RUN,
+						can_os->ndev);
+					dev_dbg(&can_os->ndev->dev,
+					    "%s -> Device restarted.\n",
+					    __func__);
+				}
+			}
+		}
+		/* Warning interrupt. */
+		if (reg_stat & ((u32) 1 << 6)) {
+			priv->can.can_stats.error_warning++;
+			dev_warn(&can_os->ndev->dev,
+				"%s -> Warning interrupt.\n", __func__);
+		}
+		/* Error passive interrupt. */
+		if (reg_stat & ((u32) 1 << 5)) {
+			priv->can.can_stats.error_passive++;
+			priv->can.state = CAN_STATE_ERROR_PASSIVE;
+			dev_err(&can_os->ndev->dev,
+				"%s -> Error interrupt.\n", __func__);
+		}
+		/* RxOK interrupt. */
+		if (reg_stat & ((u32) 1 << 4)) {
+			dev_dbg(&can_os->ndev->dev,
+				"%s -> RxOK interrupt.\n", __func__);
+			reg_stat = reg_stat & ~((u32) 1 << 4);
+		}
+		/* TxOK interrupt */
+		if (reg_stat & ((u32) 1 << 3)) {
+			dev_dbg(&can_os->ndev->dev,
+				"%s -> TxOK interrupt.\n", __func__);
+			reg_stat = reg_stat & ~((u32) 1 << 3);
+		}
+		/* Error status */
+		pch_can_log_message((reg_stat & MSK_ALL_THREE),	can_os->ndev);
+		reg_stat = reg_stat & ~(MSK_ALL_THREE);
+
+		/* Clearing status register interrupt bits. */
+		iowrite32(reg_stat, can->io_base + CAN_STAT_OFFSET);
+
+		int_stat = pch_can_int_pending(can_os->can);
+
+		netif_rx(eskb);
+
+	}
+out:
+	/* Message object interrupt. */
+	if ((int_stat > 0) && (int_stat <= MAX_MSG_OBJ)) {
+		/* Reading the messsage object from the Message RAM to the
+							 interface registers. */
+		iowrite32(CAN_CMASK_RX_TX_GET,
+			       (can->io_base + CAN_IF2_CMASK_OFFSET));
+		iowrite32((int_stat),
+			       (can->io_base + CAN_IF2_CREQ_OFFSET));
+
+		/* Confirming the read. */
+		counter = COUNTER_LIMIT;
+		while (counter) {
+			if2_creq = (ioread32(can->io_base +
+						CAN_IF2_CREQ_OFFSET)) &
+						CAN_IF_CREQ_BUSY;
+
+			if (!if2_creq)
+				break;
+
+			counter--;
+		}
+
+		if (counter <= 0)
+			return;
+
+		/* Reading the MCONT register. */
+		reg = ioread32(can->io_base + CAN_IF2_MCONT_OFFSET);
+		reg &= MSK_ALL_SIXTEEN;
+
+		/* If MsgLost bit set. */
+		if (reg & CAN_IF_MCONT_MSGLOST) {
+			PCH_CAN_BIT_CLEAR((can->io_base + CAN_IF2_MCONT_OFFSET),
+					  CAN_IF_MCONT_MSGLOST);
+
+			dev_err(&can_os->ndev->dev,
+			    "%s -> Message object %d has "
+			    "been overwritten.\n", __func__, int_stat);
+		}
+
+		/* Read the direction bit for determination of remote
+					 frame during reception. */
+		receive_msg.rtr = (ioread32((can->io_base +
+					     CAN_IF2_ID2_OFFSET)) &
+					     CAN_ID2_DIR);
+
+		/* Clearing interrupts. */
+		pch_can_int_clr(can_os->can, int_stat, can_os->ndev);
+		dev_dbg(&can_os->ndev->dev,
+			"%s -> pch_can_int_clr invoked successfully.\n",
+			__func__);
+
+		/* Hanlde reception interrupt */
+		if (pch_msg_obj_conf[int_stat - 1] == MSG_OBJ_RX) {
+			/* If new data arrived */
+			if (!(reg & CAN_IF_MCONT_NEWDAT)) {
+				dev_err(&can_os->ndev->dev,
+					"%s :CAN_IF_MCONT_NEWDAT is not SET.\n",
+					__func__);
+				return;
+			}
+			/* Reading the message object content.*/
+			retval = pch_can_rx_dequeue(can_os->can, &receive_msg,
+						    int_stat, can_os->ndev);
+			if (retval) {
+				dev_err(&can_os->ndev->dev,
+					"%s -> rx_dequeue error.\n", __func__);
+				return;
+			}
+
+			/* create zero'ed CAN frame buffer */
+			skb = alloc_can_skb(can_os->ndev, &cf);
+			if (!skb)
+				return;
+
+			if (receive_msg.ide) {
+				cf->can_id = ((receive_msg.id) & 0x1fffffff) |
+								0x80000000;
+			} else { /* Standard*/
+				cf->can_id = ((receive_msg.id) & 0x00000fff);
+			}
+			if (receive_msg.rtr)
+				cf->can_id |= 0x40000000;
+			cf->can_dlc = receive_msg.dlc;
+			memcpy(cf->data, receive_msg.data, 8);
+			netif_rx(skb);
+			stats->rx_packets++;
+			stats->rx_bytes += cf->can_dlc;
+			dev_dbg(&can_os->ndev->dev,
+				"%s -> Reception interrupt handled "
+				"for receive message object %u.\n",
+				__func__, int_stat);
+
+		} else if (pch_msg_obj_conf[int_stat - 1] == MSG_OBJ_TX) {
+			/* Hanlde transmission interrupt */
+			can_get_echo_skb(can_os->ndev, 0);
+			netif_wake_queue(can_os->ndev);
+
+			dev_dbg(&can_os->ndev->dev,
+			  "%s -> Transmission interrupt handled for "
+			  "transmit message object %u.\n",
+			  __func__, int_stat);
+		}
+	}
+}
+
+static irqreturn_t pch_can_handler(int irq, void *dev_id)
+{
+	irqreturn_t retval = IRQ_NONE;
+	u32 int_stat;
+	struct pch_can_os *can_os;
+	struct net_device *ndev = (struct net_device *)dev_id;
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	dev_dbg(&can_os->ndev->dev, "%s -> Invoked.\n", __func__);
+
+	can_os = &priv->pch_can_os_p;
+	int_stat = pch_can_int_pending(can_os->can);
+
+	dev_dbg(&can_os->ndev->dev,
+	  "%s -> pch_can_int_pending returned value: %x\n", __func__, int_stat);
+
+	if (can_os && (int_stat > 0)) {
+		can_os->int_stat = int_stat;
+		pch_can_callback(ndev);
+		dev_dbg(&can_os->ndev->dev,
+		   "%s -> Callback function invoked successfully.\n", __func__);
+
+		retval = IRQ_HANDLED;
+	}
+	return retval;
+}
+
+static void pch_can_start(struct net_device *ndev)
+{
+	struct pch_can_priv *priv = netdev_priv(ndev);
+
+	pch_can_reset(&priv->pch_can_os_p);
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+
+	return;
+}
+
+static int pch_can_do_set_mode(struct net_device *ndev, enum can_mode mode)
+{
+	int ret = 0;
+
+	switch (mode) {
+	case CAN_MODE_START:
+		pch_can_start(ndev);
+		netif_wake_queue(ndev);
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+
+	return ret;
+}
+
+static int pch_can_get_state(const struct net_device *ndev,
+			     enum can_state *state)
+{
+	struct pch_can_priv *priv = netdev_priv(ndev);
+
+	*state = priv->can.state;
+	return 0;
+}
+
+static int pch_set_bittiming(struct net_device *ndev)
+{
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *dev_can_os = &priv->pch_can_os_p;
+	const struct can_bittiming *bt = &priv->can.bittiming;
+	struct pch_can_timing pch_can_timing_data;
+	enum pch_can_run_mode curr_mode;
+	int retval;
+
+	memset(&pch_can_timing_data, 0, sizeof(pch_can_timing_data));
+	pch_can_timing_data.bitrate = bt->bitrate/1000; /* bps to Kbps */
+	pch_can_timing_data.cfg_bitrate = (bt->tq) / (1000000/pch_can_clock) -
+									1;
+							/* Tq to BRP */
+	pch_can_timing_data.cfg_tseg1 = bt->phase_seg1 + bt->prop_seg - 1;
+	pch_can_timing_data.cfg_tseg2 = bt->phase_seg2 - 1;
+	pch_can_timing_data.cfg_sjw = bt->sjw - 1;
+	pch_can_timing_data.smpl_mode = bt->sample_point;
+	pch_can_timing_data.edge_mode = 0;
+
+	pch_can_get_run_mode(dev_can_os->can, &curr_mode, ndev);
+	if (curr_mode == PCH_CAN_RUN)
+		pch_can_set_run_mode(dev_can_os->can, PCH_CAN_STOP, ndev);
+
+	retval = pch_can_set_baud(dev_can_os->can, &pch_can_timing_data);
+	if (retval)
+		return -EIO;
+
+	if (curr_mode == PCH_CAN_RUN)
+		pch_can_set_run_mode(dev_can_os->can, PCH_CAN_RUN, ndev);
+
+	return 0;
+}
+
+static int pch_open(struct net_device *ndev)
+{
+	int retval;
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *dev_can_os = &priv->pch_can_os_p;
+
+	mutex_lock(&priv->pch_can_os_p.pch_mutex);
+
+	retval = pch_can_open(dev_can_os->can,
+			      PCH_CAN_ACTIVE, PCH_CAN_FIXED_PRIORITY, ndev);
+	if (retval) {
+		dev_err(&ndev->dev,
+			"%s -> pch_can_open failed (returned %d).\n",
+			__func__, retval);
+		goto pch_open_err;
+	}
+
+	retval = pci_enable_msi(dev_can_os->dev);
+	if (retval) {
+		dev_err(&ndev->dev, "Unable to allocate MSI "
+				"interrupt Error: %d\n", retval);
+		goto pci_en_msi_err;
+	}
+
+	priv->have_msi = 1;
+
+	/* Update IRQ value */
+	dev_can_os->irq = dev_can_os->dev->irq;
+	ndev->irq = dev_can_os->dev->irq;
+
+	/* Regsitering the interrupt. */
+	retval = request_irq(dev_can_os->dev->irq,
+			     pch_can_handler, IRQF_SHARED,
+			     ndev->name, ndev);
+	if (retval) {
+		dev_err(&ndev->dev,
+			"%s -> request_irq failed on irq %d"
+			"(returned %d).\n",
+			__func__, dev_can_os->irq, retval);
+		goto req_irq_err;
+	}
+
+	/* Assuming that no bus off interrupt. */
+	dev_can_os->bus_off_interrupt = 0;
+	dev_can_os->write_wait_flag = 0;
+
+	/* Setting the block mode. */
+	dev_can_os->block_mode = 1;
+
+	dev_can_os->opened = 1;
+
+	/* Storing the can structure for further use. */
+	retval = 0;
+
+	/* Open common can device */
+	retval = open_candev(ndev);
+	if (retval) {
+		dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
+		goto err_open_candev;
+	}
+
+	netif_start_queue(ndev);
+
+	mutex_unlock(&priv->pch_can_os_p.pch_mutex);
+	return 0;
+
+
+err_open_candev:
+	free_irq(ndev->irq, ndev);
+	dev_can_os->opened = 0;
+	dev_can_os->block_mode = 0;
+
+req_irq_err:
+	pci_disable_msi(dev_can_os->dev);
+	priv->have_msi = 0;
+
+pci_en_msi_err:
+	pch_can_release(dev_can_os->can, ndev);
+
+pch_open_err:
+	mutex_unlock(&priv->pch_can_os_p.pch_mutex);
+	return retval;
+}
+
+static int pch_close(struct net_device *ndev)
+{
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+
+	netif_stop_queue(ndev);
+	close_candev(ndev);
+	free_irq(ndev->irq, ndev);
+
+	if (priv->have_msi)
+		pci_disable_msi(can_os->dev);
+
+	pch_can_release(can_os->can, ndev);
+
+	priv->can.state = CAN_STATE_STOPPED;
+
+	can_os->opened = 0;
+	can_os->block_mode = 0;
+
+	return 0;
+}
+
+static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	int err;		/* error variable. */
+	struct pch_can_msg msg;	/* The message object for writing. */
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+	struct can_frame *canframe_dat = (struct can_frame *)skb->data;
+	struct net_device_stats *stats = &ndev->stats;
+
+
+	/* Translate CAN core format to CAN PCH's HW format */
+	memset(&msg, 0, sizeof(msg));
+	msg.ide = canframe_dat->can_id & 0x80000000;
+	if (canframe_dat->can_id & 0x80000000) {
+		msg.ide = 1;
+		msg.id =  canframe_dat->can_id & 0x1fffffff;/* Extended
+								Message */
+	} else {
+		msg.ide = 0;
+		msg.id =  canframe_dat->can_id & 0x00000fff;/* Standard
+								Message */
+	}
+
+	msg.dlc = canframe_dat->can_dlc;
+	memcpy(&msg.data, canframe_dat->data, 8);
+
+	if (canframe_dat->can_id & 0x40000000)
+		msg.rtr = 1;
+	else
+		msg.rtr = 0;
+
+	/* If device suspended. */
+	if (can_os->is_suspending) {
+		dev_err(&ndev->dev,
+				"%s -> Device is in suspend mode.\n", __func__);
+		err = -EAGAIN;
+		goto err_out;
+	}
+
+	can_put_echo_skb(skb, ndev, 0);
+	err = pch_can_msg_tx(can_os->can, &msg, ndev);
+
+	if (err) {
+		/* Transmission failed due to unavailability of transmit object
+						 and it is block mode. */
+		if ((err == PCH_CAN_NO_TX_BUFF) && can_os->block_mode) {
+			dev_dbg(&ndev->dev,
+				"%s -> Waiting for transmit message object.\n",
+				__func__);
+
+			/* Transmitting again. */
+			err = pch_can_msg_tx(can_os->can, &msg, ndev);
+
+			/* If again error. */
+			if (err) {
+				dev_err(&ndev->dev,
+				    "%s -> Transmit failed after 2 attempts.\n",
+				    __func__);
+				dev_dbg(&ndev->dev, "%s returns %d\n",
+					__func__, -EPERM);
+				err = -EPERM;
+				goto err_out;
+			}
+		} else {	/* If failed due to some other reasons. */
+			dev_err(&ndev->dev,
+				"%s -> Write from CAN device failed %d.\n",
+				__func__, -EIO);
+			err = -EIO;
+			goto err_out;
+		}
+	}
+	dev_dbg(&ndev->dev,
+		"%s -> Message send for transmission successfully.\n"
+		"The transmitted Message is :\n"
+		"Msg ID   : 0x%x\n"
+		"EXT ID   : %hu\n"
+		"Msg Size : %hu\n"
+		"Rment    : %hu\n"
+		"Dat Byt1 : 0x%x\n"
+		"Dat Byt2 : 0x%x\n"
+		"Dat Byt3 : 0x%x\n"
+		"Dat Byt4 : 0x%x\n"
+		"Dat Byt5 : 0x%x\n"
+		"Dat Byt6 : 0x%x\n"
+		"Dat Byt7 : 0x%x\n"
+		"Dat Byt8 : 0x%x\n"
+		"Write from CAN device successful ( returns %d).",
+		__func__, msg.id, msg.ide, msg.dlc, msg.rtr, msg.data[0],
+		msg.data[1], msg.data[2], msg.data[3], msg.data[4], msg.data[5],
+		msg.data[6], msg.data[7], sizeof(struct pch_can_msg));
+
+	stats->tx_bytes += canframe_dat->can_dlc;
+	stats->tx_packets++;
+
+	return NETDEV_TX_OK;
+
+err_out:
+	return err;
+}
+
+static const struct net_device_ops pch_can_netdev_ops = {
+	.ndo_open		= pch_open,
+	.ndo_stop		= pch_close,
+	.ndo_start_xmit		= pch_xmit,
+};
+
+static void __devexit pch_can_remove(struct pci_dev *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct pch_can_priv *priv = netdev_priv(ndev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+
+	unregister_candev(ndev);
+	pch_can_destroy(can_os->can, ndev);
+	pci_iounmap(pdev, priv->base);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	free_candev(priv->ndev);
+	can_free_echo_skb(ndev, 0);
+	platform_set_drvdata(pdev, NULL);
+}
+
+#ifdef CONFIG_PM
+static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int i;			/* Counter variable. */
+	int retval;		/* Return value. */
+
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct pch_can_priv *priv = netdev_priv(dev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+
+	/* If the device is opened get the current run mode. */
+	if (can_os->opened) {
+		/* Save the Run Mode. */
+		pch_can_get_run_mode(can_os->can, &(can_os->run_mode),
+								can_os->ndev);
+	}
+
+	/* Stop the CAN controller */
+	pch_can_set_run_mode(can_os->can, PCH_CAN_STOP, can_os->ndev);
+
+	/* Indicate that we are aboutto/in suspend */
+	can_os->is_suspending = 1;
+	priv->can.state = CAN_STATE_SLEEPING;
+
+	if (can_os->opened) {
+		u32 buf_stat;	/* Variable for reading the transmit buffer
+								 status. */
+		u32 counter = 0xFFFFFF;
+
+		/*
+		   Waiting for all transmission to complete.
+		   This is done by checking the TXQST pending
+		    register. The loop teriminates when no
+		    transmission is pending.
+		 */
+		while (counter) {
+			buf_stat = pch_can_get_buffer_status(can_os->can);
+			if (!buf_stat)
+				break;
+
+			counter--;
+		}
+
+		if (counter > 0) {
+			dev_dbg(&pdev->dev,
+			    "%s -> No transmission is pending.\n", __func__);
+		} else {
+			dev_err(&pdev->dev,
+				"%s -> Transmission time out.\n", __func__);
+		}
+
+		/* Save interrupt configuration and then disable them */
+		pch_can_get_int_enables(can_os->can,
+					      &(can_os->int_enables));
+		pch_can_set_int_enables(can_os->can, CAN_DISABLE, can_os->ndev);
+
+		/* Save Tx buffer enable state */
+		for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size);
+									i++) {
+			if (pch_msg_obj_conf[i] == MSG_OBJ_TX) {
+				/* Here i is the index, however (i+1) is object
+								 number. */
+				pch_can_get_tx_enable(can_os->can,
+							(i + 1),
+							&(can_os->tx_enable[i]),
+							can_os->ndev);
+			}
+		}
+
+		/* Disable all Transmit buffers */
+		pch_can_tx_disable_all(can_os->can, can_os->ndev);
+
+		/* Save Rx buffer enable state */
+		for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size);
+									i++) {
+			if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+				/* Here i is the index, however (i+1) is object
+								 number. */
+
+				pch_can_get_rx_enable(can_os->can,
+							(i + 1),
+							&(can_os->rx_enable[i]),
+							can_os->ndev);
+				pch_can_get_rx_buffer_link(can_os->can,
+							(i + 1),
+							&(can_os->rx_link[i]),
+							can_os->ndev);
+
+				/* Save Rx Filters */
+				can_os->rx_filter[i].num = (i + 1);
+				pch_can_get_rx_filter(can_os->can,
+							&(can_os->rx_filter[i]),
+							can_os->ndev);
+			}
+		}
+
+		/* Disable all Receive buffers */
+		pch_can_rx_disable_all(can_os->can, can_os->ndev);
+
+		/* Save Context */
+		pch_can_get_baud(can_os->can, &(can_os->timing));
+								/* Timing. */
+		pch_can_get_listen_mode(can_os->can,
+					&(can_os->listen_mode), can_os->ndev);
+							/* Listen mode  */
+		pch_can_get_arbiter_mode(can_os->can,
+					&(can_os->arbiter_mode), can_os->ndev);
+							/* Arbiter mode */
+
+	}
+
+	retval = pci_save_state(pdev);
+
+	if (retval) {
+		/* Indicate that we have not suspended */
+		can_os->is_suspending = 0;
+
+		dev_err(&pdev->dev,
+			"%s -> pci_save_state failed(returned %d).\n",
+			__func__, retval);
+	} else {
+		dev_dbg(&pdev->dev,
+			"%s -> pci_save_state successful(returned %d).\n",
+			__func__, retval);
+
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		dev_dbg(&pdev->dev,
+		    "%s -> pci_enable_wake invoked successfully.\n", __func__);
+
+		pci_disable_device(pdev);
+		dev_dbg(&pdev->dev,
+		  "%s -> pci_disable_device invoked successfully.\n", __func__);
+
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+		dev_dbg(&pdev->dev,
+		 "%s -> pci_set_power_state invoked successfully.\n", __func__);
+	}
+
+	dev_dbg(&pdev->dev, "%s returns %d.\n", __func__, retval);
+	return retval;
+}
+
+static int pch_can_resume(struct pci_dev *pdev)
+{
+	int i;			/* Counter variable. */
+	int retval;		/* Return variable. */
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct pch_can_priv *priv = netdev_priv(dev);
+	struct pch_can_os *can_os = &priv->pch_can_os_p;
+
+	pci_set_power_state(pdev, PCI_D0);
+	dev_dbg(&pdev->dev,
+	    "pch_can_resume -> pci_set_power_state invoked successfully.\n");
+
+	pci_restore_state(pdev);
+	dev_dbg(&pdev->dev,
+		"pch_can_resume -> pci_restore_state invoked successfully.\n");
+
+	retval = pci_enable_device(pdev);
+	if (retval) {
+		dev_err(&pdev->dev,
+		"pch_can_resume -> pci_enable_device failed(returned %d).\n",
+		retval);
+		return retval;
+	}
+
+	dev_dbg(&pdev->dev, "pch_can_resume -> pci_enable_device"
+			" invoked successfully(returned %d)\n", retval);
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+
+	/* Disabling all interrupts. */
+	pch_can_set_int_enables(can_os->can, CAN_DISABLE, can_os->ndev);
+
+	/* Setting the CAN device in Stop Mode. */
+	pch_can_set_run_mode(can_os->can, PCH_CAN_STOP, can_os->ndev);
+
+	/* Configuring the transmit and receive buffers. */
+	pch_can_config_rx_tx_buffers(can_os->can, can_os->ndev);
+	dev_dbg(&pdev->dev, "pch_can_resume -> "
+		"pch_can_config_rx_tx_buffers invoked successfully.\n");
+
+	if (!(can_os->opened))
+		goto out;
+
+	/* Restore the CAN state */
+	pch_can_set_baud(can_os->can, &(can_os->timing));
+
+	/* Listen/Active */
+	pch_can_set_listen_mode(can_os->can, can_os->listen_mode, can_os->ndev);
+
+	/* Arbiter mode */
+	pch_can_set_arbiter_mode(can_os->can, can_os->arbiter_mode,
+				 can_os->ndev);
+
+	/* Enabling the transmit buffer. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_TX) {
+			/* Here i is the index, however (i+1) is
+			   object number. */
+			pch_can_set_tx_enable(can_os->can, i + 1,
+					      can_os->tx_enable[i],
+					      can_os->ndev);
+		}
+	}
+
+	/* Configuring the receive buffer and enabling them. */
+	for (i = 0; i < (pch_can_tx_buf_size + pch_can_rx_buf_size); i++) {
+		if (pch_msg_obj_conf[i] == MSG_OBJ_RX) {
+			/* Here i is the index, however (i+1) is
+					 object number. */
+
+			/* Restore buffer link */
+			pch_can_set_rx_buffer_link(can_os->can,
+						   i + 1, can_os->rx_link[i],
+						   can_os->ndev);
+
+			/* Restore Rx Filters */
+			can_os->rx_filter[i].num = (i + 1);
+			pch_can_set_rx_filter(can_os->can,
+					      &(can_os->rx_filter[i]));
+
+			/* Restore buffer enables */
+			pch_can_set_rx_enable(can_os->can,
+					      i + 1, can_os->rx_enable[i],
+					      can_os->ndev);
+		}
+	}
+
+	/* Enable CAN Interrupts */
+	pch_can_set_int_custom(can_os->can, can_os->int_enables);
+
+	/* Restore Run Mode */
+	pch_can_set_run_mode(can_os->can, can_os->run_mode, can_os->ndev);
+
+out:
+	can_os->is_suspending = 0;
+
+	dev_dbg(&pdev->dev, "pch_can_resume returns %d\n", retval);
+	return retval;
+}
+#else
+#define pch_can_suspend NULL
+#define pch_can_resume NULL
+#endif
+
+static int __devinit pch_can_probe(struct pci_dev *pdev,
+				   const struct pci_device_id *id)
+{
+	struct net_device *ndev;
+	struct pch_can_priv *priv;
+	unsigned int can_num = 0;	/* Variable to denote the CAN */
+	int rc;
+	int index;
+
+	ndev = alloc_candev(sizeof(struct pch_can_priv), 1);
+	if (!ndev)
+		return -ENOMEM;
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	priv = netdev_priv(ndev);
+
+	priv->ndev = ndev;
+
+	priv->can.bittiming_const = &pch_can_bittiming_const;
+	priv->can.do_set_bittiming = &pch_set_bittiming;
+	priv->can.do_set_mode = pch_can_do_set_mode;
+	priv->can.do_get_state = pch_can_get_state;
+	priv->can.clock.freq = pch_can_clock * 1000; /* Unit is Hz(pch_can_clock
+							is KHz) */
+	ndev->flags |= (IFF_NOARP | IFF_ECHO);
+	platform_set_drvdata(pdev, ndev);
+	ndev->netdev_ops = &pch_can_netdev_ops;
+	rc = pci_enable_device(pdev);
+	if (rc)
+		goto err_out_free;
+
+	rc = pci_request_regions(pdev, DRIVER_NAME);
+	if (rc)
+		goto err_out_disable;
+
+	priv->pch_can_os_p.pci_remap = pci_iomap(pdev, 1, 0);
+	if (!priv->pch_can_os_p.pci_remap) {
+		rc = -EIO;
+		goto err_out_res;
+	}
+
+	/* Creating the device handle denoting the remap base address. */
+	priv->pch_can_os_p.can = pch_can_create(priv->pch_can_os_p.pci_remap,
+						ndev);
+
+	/* If handle creation fails. */
+	if (!priv->pch_can_os_p.can) {
+		dev_err(&pdev->dev,
+			"%s -> pch_can_create failed.\n", __func__);
+		rc = -EPERM;
+		goto err_out_iomap;
+	}
+
+	/* Can number (index to the structure) */
+	priv->pch_can_os_p.can_num = can_num;
+	priv->pch_can_os_p.irq = pdev->irq;/* IRQ allocated to this device. */
+	ndev->irq = pdev->irq;
+	priv->pch_can_os_p.dev = pdev;/* Reference to pci_device structure. */
+	priv->pch_can_os_p.opened = 0;/* Open flag denoting the device usage. */
+	priv->pch_can_os_p.is_suspending = 0;
+	priv->pch_can_os_p.ndev = ndev;
+
+	priv->base = priv->pch_can_os_p.pci_remap;
+
+	mutex_init(&priv->pch_can_os_p.pch_mutex);
+
+	for (index = 0; index < pch_can_rx_buf_size;)
+		pch_msg_obj_conf[index++] = MSG_OBJ_RX;
+
+	for (index = index;
+	     index < (pch_can_rx_buf_size + pch_can_tx_buf_size);)
+		pch_msg_obj_conf[index++] = MSG_OBJ_TX;
+
+	rc = register_candev(ndev);
+	if (rc)
+		goto err_out_reg_candev;
+
+	return 0;
+
+err_out_reg_candev:
+	pch_can_destroy(priv->pch_can_os_p.can, ndev);
+err_out_iomap:
+	pci_iounmap(pdev, priv->pch_can_os_p.pci_remap);
+err_out_res:
+	pci_release_regions(pdev);
+err_out_disable:
+	pci_disable_device(pdev);
+err_out_free:
+	free_candev(ndev);
+
+	return rc;
+}
+
+static struct pci_driver pch_can_pcidev = {
+	.name = KBUILD_MODNAME,
+	.id_table = pch_can_pcidev_id,
+	.probe = pch_can_probe,
+	.remove = __devexit_p(pch_can_remove),
+	.suspend = pch_can_suspend,
+	.resume = pch_can_resume,
+};
+
+static int __init pch_can_pci_init(void)
+{
+	return pci_register_driver(&pch_can_pcidev);
+}
+
+static void __exit pch_can_pci_exit(void)
+{
+	pci_unregister_driver(&pch_can_pcidev);
+}
+
+MODULE_DESCRIPTION("Controller Area Network Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("0.94");
+
+module_param_named(pch_can_rx_buf_size, pch_can_rx_buf_size, int, 444);
+module_param_named(pch_can_tx_buf_size, pch_can_tx_buf_size, int, 444);
+module_param_named(pch_can_clock, pch_can_clock, int, 444);
+MODULE_DEVICE_TABLE(pci, pch_can_pcidev_id);
+
+module_init(pch_can_pci_init);
+module_exit(pch_can_pci_exit);
-- 
1.6.0.6

