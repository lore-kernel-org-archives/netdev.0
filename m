From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v2] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 15 Sep 2010 09:36:12 +0200
Message-ID: <4C90776C.8040000@grandegger.com>
References: <4C8E1773.9090000@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org, arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C8E1773.9090000-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ohtake,

On 09/13/2010 02:22 PM, Masayuki Ohtak wrote:
> CAN driver of Topcliff PCH
> 
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus. 
> Topcliff PCH has CAN I/F. This driver enables CAN function.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

Ouch! Still 3600 lines of code...

> ---
>  drivers/net/can/Kconfig   |    8 +
>  drivers/net/can/Makefile  |    1 +
>  drivers/net/can/pch_can.c | 3601 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 3610 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/pch_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 2c5227c..5c98a20 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -73,6 +73,14 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will be
>  	  called janz-ican3.ko.
>  
> +config PCH_CAN
> +	tristate "PCH CAN"
> +	depends on  CAN_DEV
> +	---help---
> +	  This driver is for PCH CAN of Topcliff which is an IOH for x86
> +	  embedded processor.
> +	  This driver can access CAN bus.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 9047cd0..3ddc6a7 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -16,5 +16,6 @@ obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
> +obj-$(CONFIG_PCH_CAN)		+= pch_can.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> new file mode 100644
> index 0000000..0de978f
> --- /dev/null
> +++ b/drivers/net/can/pch_can.c
> @@ -0,0 +1,3601 @@
> +/*
> + * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; version 2 of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
> + */
> +
> +#include <linux/interrupt.h>
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +#include <linux/module.h>
> +#include <linux/sched.h>
> +#include <linux/pci.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +
> +#define MAX_CAN_DEVICES		1
> +#define MAX_BITRATE		0x3e8
> +#define NUM_NODES		2000	/* Maximum number of
> +						 Software FIFO nodes. */
> +#define MAX_MSG_OBJ		32
> +#define MSG_OBJ_RX		0 /* The receive message object flag. */
> +#define MSG_OBJ_TX		1 /* The transmit message object flag. */
> +
> +#define ENABLE			1 /* The enable flag */
> +#define DISABLE			0 /* The disable flag */
> +#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> +#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> +#define CAN_CTRL_SIE		0x0004
> +#define CAN_CTRL_EIE		0x0008
> +#define CAN_CTRL_DAR		0x0020
> +#define CAN_CTRL_IE_SIE_EIE	0x000e
> +#define CAN_CTRL_CCE		0x0040
> +#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> +#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT register. */
> +#define CAN_CMASK_RX_TX_SET	0x00f3
> +#define CAN_CMASK_RX_TX_GET	0x0073
> +#define CAN_CMASK_ALL		0xff
> +#define CAN_CMASK_RDWR		0x80
> +#define CAN_CMASK_ARB		0x20
> +#define CAN_CMASK_CTRL		0x10
> +#define CAN_CMASK_MASK		0x40
> +#define CAN_CMASK_CLPNT		0x08
> +
> +#define CAN_CMASK_NEWINT	0x04 /* The TxRqst/NewDat bit for the CMASK
> +					register. */
> +
> +#define CAN_IF_MCONT_NEWDAT	0x8000 /* The NewDat bit of the MCONT
> +					  register. */
> +
> +#define CAN_IF_MCONT_INTPND	0x2000 /* The IntPnd bit of the MCONT
> +					  register. */
> +
> +#define CAN_IF_MCONT_UMASK		0x1000
> +#define CAN_IF_MCONT_TXIE		0x0800
> +#define CAN_IF_MCONT_RXIE		0x0400
> +#define CAN_IF_MCONT_RMTEN		0x0200
> +#define CAN_IF_MCONT_TXRQXT		0x0100
> +#define CAN_IF_MCONT_EOB		0x0080
> +#define CAN_IF_MCONT_MSGLOST		0x4000
> +#define CAN_MASK2_MDIR_MXTD		0xc000
> +#define CAN_ID2_MSGVAL_XTD_DIR		0xe000
> +#define CAN_ID2_MSGVAL_DIR		0xa000
> +#define CAN_ID2_DIR			0x2000
> +#define CAN_ID_MSGVAL			0x8000
> +#define CAN_IF_MASK2_MDIR		((u32)1 << 14)
> +#define CAN_IF_MASK2_MXTD		((u32)1 << 15)
> +
> +#define CAN_STATUS_INT			0x8000 /* The status interrupt value of
> +						  the CAN device. */
> +
> +#define CAN_IF_CREQ_BUSY		0x8000 /* The Busy flag bit of the CREQ
> +						  register. */
> +
> +#define CAN_ID2_XTD			0x4000 /* The Xtd bit of ID2
> +						  register. */
> +
> +#define CAN_SRST_BIT			0x0001
> +#define CAN_CONT_OFFSET			0x00	/*Can Control register */
> +#define CAN_STAT_OFFSET			0x04
> +#define CAN_ERRC_OFFSET			0x08
> +#define CAN_BITT_OFFSET			0x0c
> +#define CAN_INT_OFFSET			0x010
> +#define CAN_OPT_OFFSET			0x14	/*Extended function register */
> +#define CAN_BRPE_OFFSET			0x18
> +
> +/* Message interface one (IF1) registers */
> +#define CAN_IF1_CREQ_OFFSET		0x020
> +#define CAN_IF1_CMASK_OFFSET		0x024
> +#define CAN_IF1_ID1_OFFSET		0x030
> +#define CAN_IF1_ID2_OFFSET		0x034
> +#define CAN_IF1_MCONT_OFFSET		0x038
> +#define CAN_IF1_DATAA1_OFFSET		0x03C
> +#define CAN_IF1_DATAA2_OFFSET		0x040
> +#define CAN_IF1_DATAB1_OFFSET		0x044
> +#define CAN_IF1_DATAB2_OFFSET		0x048
> +#define CAN_IF1_MASK1_OFFSET		0x028
> +#define CAN_IF1_MASK2_OFFSET		0x02c
> +#define CAN_IF2_CREQ_OFFSET		0x080
> +#define CAN_IF2_CMASK_OFFSET		0x084
> +#define CAN_IF2_ID1_OFFSET		0x090
> +#define CAN_IF2_ID2_OFFSET		0x094
> +#define CAN_IF2_MCONT_OFFSET		0x098
> +#define CAN_IF2_DATAA1_OFFSET		0x09c
> +#define CAN_IF2_DATAA2_OFFSET		0x0a0
> +#define CAN_IF2_DATAB1_OFFSET		0x0a4
> +#define CAN_IF2_DATAB2_OFFSET		0x0a8
> +#define CAN_IF2_MASK1_OFFSET		0x088
> +#define CAN_IF2_MASK2_OFFSET		0x08c
> +#define CAN_TREQ1_OFFSET		0x100
> +#define CAN_TREQ2_OFFSET		0x104
> +#define CAN_SRST_OFFSET			0x1FC

Using a structure to describe you register layout seems much more
appropriate for your driver. E.g.:

struct pch_can_regs {
	u32 cont;
	u32 stat;
	u32 errc;
	...
};

Then the registers are accessed via:

ioread32(&regs->stat);
iowrite32(&regs->cont, value);

This results in more readable code and you profit from type checking.

> +/* bit position of certain controller bits. */
> +#define BIT_BITT_BRP			0
> +#define BIT_BITT_SJW			6
> +#define BIT_BITT_TSEG1			8
> +#define BIT_BITT_TSEG2			12
> +#define BIT_IF1_MCONT_RXIE		10
> +#define BIT_IF2_MCONT_TXIE		11
> +#define BIT_BRPE_BRPE			6
> +#define BIT_ES_TXERRCNT			0
> +#define BIT_ES_RXERRCNT			8
> +#define MSK_BITT_BRP			0x3f
> +#define MSK_BITT_SJW			0xc0
> +#define MSK_BITT_TSEG1			0xf00
> +#define MSK_BITT_TSEG2			0x7000
> +#define MSK_BRPE_BRPE			0x3c0
> +#define MSK_BRPE_GET			0x0f
> +#define MSK_CTRL_IE_SIE_EIE		0x07
> +#define MSK_MCONT_TXIE			0x08
> +#define MSK_MCONT_RXIE			0x10
> +#define MSK_ALL_THREE			0x07
> +#define MSK_ALL_FOUR			0x0f
> +#define MSK_ALL_EIGHT			0xff
> +#define MSK_ALL_ELEVEN			0x7ff
> +#define MSK_ALL_THIRTEEN		0x1fff
> +#define MSK_ALL_SIXTEEN			0xffff
> +
> +/* Error */
> +#define MSK_ES_TXERRCNT	((u32)0xff << BIT_ES_TXERRCNT)	/* Tx err count */
> +#define MSK_ES_RXERRCNT	((u32)0x7f << BIT_ES_RXERRCNT)	/* Rx err count */
> +
> +#define PCH_CAN_BIT_SET(reg, bitmask)	\
> +		(iowrite32((ioread32((reg)) | ((u32)(bitmask))), (reg)))
> +#define PCH_CAN_BIT_CLEAR(reg, bitmask)	\
> +		(iowrite32((ioread32((reg)) & ~((u32)(bitmask))), (reg)))

Please use static inline functions and try to avoid casts.

> +#define PCH_CAN_NO_TX_BUFF		1 /* The flag value for denoting the
> +					     unavailability of the transmit
> +					     message object. */
> +
> +#define ERROR_COUNT			96
> +#define PCH_CAN_MSG_DATA_LEN		8	/* CAN Msg data length */
> +
> +#define PCH_CAN_NULL			NULL
> +
> +#define PCI_DEVICE_ID_INTEL_PCH1_CAN	0x8818
> +#define DRIVER_NAME			"can"
> +
> +#define PCH_CAN_CLOCK_DEFAULT_OFFSET	0
> +#define PCH_CAN_CLOCK_62_5_OFFSET	0
> +#define PCH_CAN_CLOCK_24_OFFSET		8
> +#define PCH_CAN_CLOCK_50_OFFSET		16
> +
> +#define COUNTER_LIMIT 0xFFFF
> +
> +
> +
> +enum pch_can_listen_mode {
> +	PCH_CAN_ACTIVE = 0,
> +	PCH_CAN_LISTEN
> +};
> +
> +enum pch_can_run_mode {
> +	PCH_CAN_STOP = 0,
> +	PCH_CAN_RUN
> +};
> +
> +enum pch_can_arbiter {
> +	PCH_CAN_ROUND_ROBIN = 0,
> +	PCH_CAN_FIXED_PRIORITY
> +};
> +
> +enum pch_can_auto_restart {
> +	CAN_MANUAL = 0,
> +	CAN_AUTO
> +};

Please remove the above enums or explain why you need them.

> +enum pch_can_baud {
> +	PCH_CAN_BAUD_10 = 0,
> +	PCH_CAN_BAUD_20,
> +	PCH_CAN_BAUD_50,
> +	PCH_CAN_BAUD_125,
> +	PCH_CAN_BAUD_250,
> +	PCH_CAN_BAUD_500,
> +	PCH_CAN_BAUD_800,
> +	PCH_CAN_BAUD_1000
> +};

Dead code. Not used anywhere.

> +enum pch_can_interrupt {
> +	CAN_ENABLE,
> +	CAN_DISABLE,
> +	CAN_ALL,
> +	CAN_NONE
> +};
> +

Please remove the above enum or explain why you need it.

> +/**
> + * struct pch_can_msg - CAN message structure
> + * @ide:	Standard/extended msg
> + * @id:		11 or 29 bit msg id
> + * @dlc:	Size of data
> + * @data:	Message pay load
> + * @rtr:	RTR message
> + */
> +struct pch_can_msg {
> +	unsigned short ide;
> +	unsigned int id;
> +	unsigned short dlc;
> +	unsigned char data[PCH_CAN_MSG_DATA_LEN];
> +	unsigned short rtr;
> +};


Please remove the above intermediate struct or explain why you need it.

> +/**
> + * pch_can_timing - CAN bittiming structure
> + * @bitrate:	Bitrate (kbps)
> + * @cfg_bitrate:BRP
> + * @cfg_tseg1:	Tseg1
> + * @cfg_tseg2:	Tseg2
> + * @cfg_sjw:	Sync jump width
> + * @smpl_mode:	Sampling mode
> + * @edge_mode:	Edge R / D
> + */
> +struct pch_can_timing {
> +	unsigned int bitrate;
> +	unsigned int cfg_bitrate;
> +	unsigned int cfg_tseg1;
> +	unsigned int cfg_tseg2;
> +	unsigned int cfg_sjw;
> +	unsigned int smpl_mode;
> +	unsigned int edge_mode;
> +};
> +
> +/**
> + * struct pch_can_error - CAN error structure
> + * @rxgte96:	Rx err cnt >=96
> + * @txgte96:	Tx err cnt >=96
> + * @error_stat:	Error state of CAN node,
> + *		00=error active (normal)
> + *		01=error passive
> + *		1x=bus off
> + * @rx_err_cnt:	Rx error count
> + * @tx_err_cnt:	Tx error count
> + */
> +struct pch_can_error {
> +	unsigned int rxgte96;
> +	unsigned int txgte96;
> +	unsigned int error_stat;
> +	unsigned int rx_err_cnt;
> +	unsigned int tx_err_cnt;
> +};

Ditto.

> +/**
> + * struct pch_can_acc_filter - CAN Filter structure
> + * @id:		The id/mask data
> + * @id_ext:	Standard/extended ID
> + * @rtr:	RTR message
> + */
> +struct pch_can_acc_filter {
> +	unsigned int id;
> +	unsigned int id_ext;
> +	unsigned int rtr;
> +};

Ditto.

> +/**
> + * struct pch_can_rx_filter - CAN RX filter
> + * @num:	Filter number
> + * @umask:	UMask value
> + * @amr:	Acceptance Mask Reg
> + * @aidr:	Acceptance Control Reg
> + */
> +struct pch_can_rx_filter {
> +	unsigned int num;
> +	unsigned int umask;
> +	struct pch_can_acc_filter amr;
> +	struct pch_can_acc_filter aidr;
> +};

Ditto.

> +/**
> + * struct pch_can_os - structure to store the CAN device information.
> + * @can:		CAN: device handle
> + * @opened:		Linux opened device
> + * @can_num:		Linux: CAN Number
> + * @pci_remap:		Linux: MMap regs
> + * @dev:		Linux: PCI Device
> + * @irq:		Linux: IRQ
> + * @block_mode:		Blocking / non-blocking
> + * @read_wait_queue:	Linux: Read wait queue
> + * @write_wait_queue:	Linux: Write wait queue
> + * @write_wait_flag:	Linux: Write wait flag
> + * @read_wait_flag:	Linux: Read wait flag
> + * @open_spinlock:	Linux: Open lock variable
> + * @is_suspending:	Linux: Is suspending state
> + * @inode:		Linux: inode
> + * @timing:		CAN: timing
> + * @run_mode:		CAN: run mode
> + * @listen_mode:	CAN: listen mode
> + * @arbiter_mode:	CAN: arbiter mode
> + * @tx_enable:		CAN: Tx buffer state
> + * @rx_enable:		CAN: Rx buffer state
> + * @rx_link:		CAN: Rx link set
> + * @int_enables:	CAN: ints enabled
> + * @int_stat:		CAN: int status
> + * @bus_off_interrupt:	CAN: Buss off int flag
> + * @rx_filter:		CAN: Rx filters
> + * @ndev:		net_device pointer
> + * @tx_spinlock:	CAN: transmission lock variable
> + */
> +struct pch_can_os {
> +	struct can_hw *can;
> +	unsigned int opened;
> +	unsigned int can_num;
> +	void __iomem *pci_remap;
> +	struct pci_dev *dev;
> +	unsigned int irq;
> +	int block_mode;
> +	wait_queue_head_t read_wait_queue;
> +	wait_queue_head_t write_wait_queue;

Not used anywhere! Dead code :-(.

> +	unsigned int write_wait_flag;
> +	unsigned int read_wait_flag;
> +	spinlock_t open_spinlock;
> +	unsigned int is_suspending;
> +	struct inode *inode;
> +	struct pch_can_timing timing;
> +	enum pch_can_run_mode run_mode;
> +	enum pch_can_listen_mode listen_mode;
> +	enum pch_can_arbiter arbiter_mode;
> +	unsigned int tx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_link[MAX_MSG_OBJ];
> +	unsigned int int_enables;
> +	unsigned int int_stat;
> +	unsigned int bus_off_interrupt;
> +	struct pch_can_rx_filter rx_filter[MAX_MSG_OBJ];
> +	struct net_device *ndev;
> +	spinlock_t tx_spinlock;
> +	struct mutex pch_mutex;
> +};

Why do you need an extra structure here? Is pch_can_priv not OK?

> +/**
> + * struct pch_can_priv - CAN driver private data structure
> + * @can:		MUST be first member/field
> + * @ndev:		Pointer to net_device structure
> + * @clk:		unused
> + * @base:		Base address
> + * @pch_can_os_p:	Pointer to CAN device information
> + * @have_msi:		PCI MSI mode flag
> + *
> + * Longer description of this structure.
> + */
> +struct pch_can_priv {
> +	struct can_priv can;
> +	struct net_device *ndev;
> +	struct clk *clk;
> +	void __iomem *base;
> +	struct pch_can_os pch_can_os_p;
> +	unsigned int have_msi;
> +};
> +
> +struct can_hw {
> +	void __iomem *io_base;
> +};

See above.

> +static unsigned int pch_can_clock = 50000; /*50MH*/
> +
> +/*
> +The number of message objects that has to be configured as receive/send
> +objects.
> +Topcliff CAN has total 32 message objects.
> +*/
> +static unsigned int pch_can_rx_buf_size = 1;
> +static unsigned int pch_can_tx_buf_size = 1;
> +
> +
> +static enum pch_can_auto_restart restat_mode = CAN_MANUAL; /* The variable used
> +							      to store the
> +							      restart mode. */
> +
> +static struct can_bittiming_const pch_can_bittiming_const = {
> +	.name = KBUILD_MODNAME,
> +	.tseg1_min = 1,
> +	.tseg1_max = 16,
> +	.tseg2_min = 1,
> +	.tseg2_max = 8,
> +	.sjw_max = 4,
> +	.brp_min = 1,
> +	.brp_max = 1024, /* 6bit + extended 4bit */
> +	.brp_inc = 1,
> +};
> +
> +static const struct pci_device_id pch_can_pcidev_id[] __devinitdata = {
> +	{PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PCH1_CAN)},
> +	{}
> +};
> +
> +/*
> +This variable is used to store the configuration (receive /transmit) of the
> +available message objects.
> +This variable is used for storing the message object configuration related
> +information. It includes the information about which message object is used as
> +Receiver and Transmitter.
> +*/

Please use the usual Linux style for comments:

/*
 *
 */

> +static unsigned int pch_msg_obj_conf[MAX_MSG_OBJ] = {
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3,
> +	3, 3, 3, 3
> +};
> +
> +static struct can_hw *pch_can_create(void __iomem *io_base,
> +				     struct net_device *ndev)
> +{
> +	struct can_hw *can;
> +
> +	if (!io_base) {
> +		dev_err(&ndev->dev, "%s -> Invalid IO Base\n", __func__);
> +		return NULL;
> +	}
> +
> +	/* Allocates memory for the handle. */
> +	can = kmalloc(sizeof(struct can_hw), GFP_KERNEL);
> +	if (!can) {	/* Allocation failed */
> +		dev_err(&ndev->dev,
> +			"%s -> CAN Memory allocation failed\n", __func__);
> +		return NULL;
> +	}
> +
> +	can->io_base = io_base;
> +	dev_dbg(&ndev->dev,
> +		"%s -> Handle Creation successful.\n", __func__);

Please restrict debugging output to a few useful messages for the final
user. Puh, I stop reviewing here because of too much issues, which have
already been pointed out with you previous patch. I share most of the
other comments on that patch. Please work on your *code quality*. I also
believe that *rewriting* the driver from *scratch* using an existing
Socket-CAN driver as example is the most efficient way towards a clean
and compact driver with, let's say, less than approximately 1000 lines
of code.

Wolfgang.
