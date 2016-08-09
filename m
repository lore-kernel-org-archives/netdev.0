From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Tue, 9 Aug 2016 09:35:58 +0000
Message-ID: <SG2PR06MB1038CF0A04EA79DA902859A0C31C0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <20160726091555.GA26227@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkl@pengutronix.de" <mkl@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jthumshirn@suse.de" <jthumshirn@suse.de>,
	"andy@wernerandy.de" <andy@wernerandy.de>
To: Andreas Werner <andreas.werner@men.de>,
	"wg@grandegger.com" <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160726091555.GA26227@awelinux>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andreas,

> Subject: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
> driver
> 
> This CAN Controller is found on MEN Chameleon FPGAs.
> 
> The driver/device supports the CAN2.0 specification.
> There are 255 RX and 255 Tx buffer within the IP. The pointer for the
> buffer are handled by HW to make the access from within the driver as
> simple as possible.
> 
> The driver also supports parameters to configure the buffer level
> interrupt for RX/TX as well as a RX timeout interrupt.
> 
> With this configuration options, the driver/device provides flexibility
> for different types of use cases.

Could you give us some example use case where these two configurations would be useful?
What does it bring extra that cannot be achieved by normal NAPI mode itself?

As the timeout is an absolute value, how does it fare when configured with say
	- interface up with 1Mbps bitrate
	- interface down
	- interface up with 10Kbps bitrate

Should it be a % of bitrate rather than a module parameter if this configuration option is really needed?

> 
> Signed-off-by: Andreas Werner <andreas.werner@men.de>
> ---
>  drivers/net/can/Kconfig        |  10 +
>  drivers/net/can/Makefile       |   1 +
>  drivers/net/can/men_z192_can.c | 989
> +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1000 insertions(+)
>  create mode 100644 drivers/net/can/men_z192_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
> 0d40aef..0fa0387 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -104,6 +104,16 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will
> be
>  	  called janz-ican3.ko.
> 
> +config CAN_MEN_Z192
> +	tristate "MEN 16Z192-00 CAN Controller"
> +	depends on MCB
> +	---help---
> +	  Driver for MEN 16Z192-00 CAN Controller IP-Core, which
> +	  is connected to the MEN Chameleon Bus.
> +
> +	  This driver can also be built as a module. If so, the module will
> be
> +	  called men_z192_can.ko.
> +
>  config CAN_RCAR
>  	tristate "Renesas R-Car CAN controller"
>  	depends on ARCH_RENESAS || ARM
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile index
> e3db0c8..eb206b3 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -22,6 +22,7 @@ obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
>  obj-$(CONFIG_CAN_GRCAN)		+= grcan.o
>  obj-$(CONFIG_CAN_IFI_CANFD)	+= ifi_canfd/
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
> +obj-$(CONFIG_CAN_MEN_Z192)	+= men_z192_can.o
>  obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_M_CAN)		+= m_can/
>  obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
> diff --git a/drivers/net/can/men_z192_can.c
> b/drivers/net/can/men_z192_can.c new file mode 100644 index
> 0000000..b39ffee
> --- /dev/null
> +++ b/drivers/net/can/men_z192_can.c
> @@ -0,0 +1,989 @@
> +/*
> + * MEN 16Z192 CAN Controller driver
> + *
> + * Copyright (C) 2016 MEN Mikroelektronik GmbH (www.men.de)
> + *
> + * This program is free software; you can redistribute it and/or modify
> +it
> + * under the terms of the GNU General Public License as published by
> +the Free
> + * Software Foundation; version 2 of the License.
> + */
> +
> +#include <linux/netdevice.h>
> +#include <linux/can/error.h>
> +#include <linux/can/dev.h>
> +#include <linux/bitops.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/err.h>
> +#include <linux/mcb.h>
> +#include <linux/can.h>
> +#include <linux/io.h>
> +
> +#define DRV_NAME	"z192_can"
> +
> +#define MEN_Z192_NAPI_WEIGHT	64
> +#define MEN_Z192_MODE_TOUT_US	40
> +
> +/* CTL/BTR Register Bits */
> +#define MEN_Z192_CTL0_INITRQ	BIT(0)
> +#define MEN_Z192_CTL0_SLPRQ	BIT(1)
> +#define MEN_Z192_CTL1_INITAK	BIT(8)
> +#define MEN_Z192_CTL1_SLPAK	BIT(9)
> +#define MEN_Z192_CTL1_LISTEN	BIT(12)
> +#define MEN_Z192_CTL1_LOOPB	BIT(13)
> +#define MEN_Z192_CTL1_CANE	BIT(15)
> +#define MEN_Z192_BTR0_BRP(x)	(((x) & 0x3f) << 16)
> +#define MEN_Z192_BTR0_SJW(x)	(((x) & 0x03) << 22)
> +#define MEN_Z192_BTR1_TSEG1(x)	(((x) & 0x0f) << 24)
> +#define MEN_Z192_BTR1_TSEG2(x)	(((x) & 0x07) << 28)
> +#define MEN_Z192_BTR1_SAMP	BIT(31)
> +
> +/* IER Interrupt Enable Register bits */
> +#define MEN_Z192_RXIE		BIT(0)
> +#define MEN_Z192_OVRIE		BIT(1)
> +#define MEN_Z192_CSCIE		BIT(6)
> +#define MEN_Z192_TOUTE		BIT(7)
> +#define MEN_Z192_TXIE		BIT(16)
> +#define MEN_Z192_ERRIE		BIT(17)
> +
> +#define MEN_Z192_IRQ_ALL				\
> +		(MEN_Z192_RXIE | MEN_Z192_OVRIE |	\
> +		 MEN_Z192_CSCIE | MEN_Z192_TOUTE |	\
> +		 MEN_Z192_TXIE)
> +
> +#define MEN_Z192_IRQ_NAPI	(MEN_Z192_RXIE | MEN_Z192_TOUTE)
> +
> +/* RX_TX_STAT RX/TX Status status register bits */
> +#define MEN_Z192_RX_BUF_CNT(x)	((x) & 0xff)
> +#define MEN_Z192_TX_BUF_CNT(x)	(((x) & 0xff00) >> 8)
> +#define	MEN_Z192_RFLG_RXIF	BIT(16)
> +#define	MEN_Z192_RFLG_OVRF	BIT(17)
> +#define	MEN_Z192_RFLG_TSTATE	GENMASK(19, 18)
> +#define	MEN_Z192_RFLG_RSTATE	GENMASK(21, 20)
> +#define	MEN_Z192_RFLG_CSCIF	BIT(22)
> +#define	MEN_Z192_RFLG_TOUTF	BIT(23)
> +#define MEN_Z192_TFLG_TXIF	BIT(24)
> +
> +#define MEN_Z192_GET_TSTATE(x)	(((x) & MEN_Z192_RFLG_TSTATE) >> 18)
> +#define MEN_Z192_GET_RSTATE(x)	(((x) & MEN_Z192_RFLG_RSTATE) >> 20)
> +
> +#define MEN_Z192_IRQ_FLAGS_ALL					\
> +		(MEN_Z192_RFLG_RXIF | MEN_Z192_RFLG_OVRF |	\
> +		 MEN_Z192_RFLG_TSTATE | MEN_Z192_RFLG_RSTATE |	\
> +		 MEN_Z192_RFLG_CSCIF | MEN_Z192_RFLG_TOUTF |	\
> +		 MEN_Z192_TFLG_TXIF)
> +
> +/* RX/TX Error counter bits */
> +#define MEN_Z192_GET_RX_ERR_CNT(x)	((x) & 0xff)
> +#define MEN_Z192_GET_TX_ERR_CNT(x)	(((x) & 0x00ff0000) >> 16)
> +
> +/* Buffer level register bits */
> +#define MEN_Z192_RX_BUF_LVL	GENMASK(15, 0)
> +#define MEN_Z192_TX_BUF_LVL	GENMASK(31, 16)
> +
> +/* RX/TX Buffer register bits */
> +#define MEN_Z192_CFBUF_LEN	GENMASK(3, 0)
> +#define MEN_Z192_CFBUF_ID1	GENMASK(31, 21)
> +#define MEN_Z192_CFBUF_ID2	GENMASK(18, 1)
> +#define MEN_Z192_CFBUF_TS	GENMASK(31, 8)
> +#define MEN_Z192_CFBUF_E_RTR	BIT(0)
> +#define MEN_Z192_CFBUF_IDE	BIT(19)
> +#define MEN_Z192_CFBUF_SRR	BIT(20)
> +#define MEN_Z192_CFBUF_S_RTR	BIT(20)
> +#define MEN_Z192_CFBUF_ID2_SHIFT	1
> +#define MEN_Z192_CFBUF_ID1_SHIFT	21
> +
> +/* Global register offsets */
> +#define MEN_Z192_RX_BUF_START	0x0000
> +#define MEN_Z192_TX_BUF_START	0x1000
> +#define MEN_Z192_REGS_OFFS	0x2000
> +
> +/* Buffer level control values */
> +#define MEN_Z192_MIN_BUF_LVL	0
> +#define MEN_Z192_MAX_BUF_LVL	254
> +#define MEN_Z192_RX_BUF_LVL_DEF	5
> +#define MEN_Z192_TX_BUF_LVL_DEF	5
> +#define MEN_Z192_RX_TOUT_MIN	0
> +#define MEN_Z192_RX_TOUT_MAX	65535
> +#define MEN_Z192_RX_TOUT_DEF	1000
> +
> +static int txlvl = MEN_Z192_TX_BUF_LVL_DEF; module_param(txlvl, int,
> +S_IRUGO); MODULE_PARM_DESC(txlvl, "TX IRQ trigger level (in frames)
> +0-254, default="
> +		 __MODULE_STRING(MEN_Z192_TX_BUF_LVL_DEF) ")");
> +
> +static int rxlvl = MEN_Z192_RX_BUF_LVL_DEF; module_param(rxlvl, int,
> +S_IRUGO); MODULE_PARM_DESC(rxlvl, "RX IRQ trigger level (in frames)
> +0-254, default="
> +		 __MODULE_STRING(MEN_Z192_RX_BUF_LVL_DEF) ")");
> +
> +static int rx_timeout = MEN_Z192_RX_TOUT_DEF; module_param(rx_timeout,
> +int, S_IRUGO); MODULE_PARM_DESC(rx_timeout, "RX IRQ timeout (in 100usec
> +steps), default="
> +		 __MODULE_STRING(MEN_Z192_RX_TOUT_DEF) ")");
> +
> +struct men_z192_regs {
> +	u32 ctl_btr;		/* Control and bus timing register */
> +	u32 ier;                /* Interrupt enable register */
> +	u32 buf_lvl;            /* Buffer level register */
> +	u32 rxa;                /* RX Data acknowledge register */
> +	u32 txa;                /* TX data acknowledge register */
> +	u32 rx_tx_sts;          /* RX/TX flags and buffer level */
> +	u32 ovr_ecc_sts;        /* Overrun/ECC status register */
> +	u32 idac_ver;           /* ID acceptance control / version */
> +	u32 rx_tx_err;          /* RX/TX error counter register */
> +	u32 idar_0_to_3;        /* ID acceptance register 0...3 */
> +	u32 idar_4_to_7;        /* ID acceptance register 4...7 */
> +	u32 idmr_0_to_3;        /* ID mask register 0...3 */
> +	u32 idmr_4_to_7;        /* ID mask register 4...7 */
> +	u32 rx_timeout;		/* receive timeout */

It would be nice to start all the comments with a capital letter or small letter - but uniformly.

> +	u32 timebase;		/* Base frequency for baudrate calculation

Unused variable?

> */
> +};
> +
> +struct men_z192 {
> +	struct can_priv can;
> +	struct napi_struct napi;
> +	struct net_device *ndev;
> +	struct device *dev;
> +
> +	/* Lock for CTL_BTR register access.
> +	 * This register combines bittiming bits
> +	 * and the operation mode bits.
> +	 * It is also used for bit r/m/w access
> +	 * to all registers.
> +	 */
> +	spinlock_t lock;
> +	struct resource *mem;
> +	struct men_z192_regs __iomem *regs;
> +	void __iomem *dev_base;
> +};
> +
> +struct men_z192_cf_buf {
> +	u32 can_id;
> +	u32 data[2];
> +	u32 length;
> +};
> +
> +enum men_z192_int_state {
> +	MEN_Z192_CAN_DIS = 0,
> +	MEN_Z192_CAN_EN,
> +	MEN_Z192_CAN_NAPI_DIS,
> +	MEN_Z192_CAN_NAPI_EN,
> +};
> +
> +static enum can_state bus_state_map[] = {
> +	CAN_STATE_ERROR_ACTIVE,
> +	CAN_STATE_ERROR_WARNING,
> +	CAN_STATE_ERROR_PASSIVE,
> +	CAN_STATE_BUS_OFF
> +};
> +
> +static const struct can_bittiming_const men_z192_bittiming_const = {
> +	.name = DRV_NAME,
> +	.tseg1_min = 4,
> +	.tseg1_max = 16,
> +	.tseg2_min = 2,
> +	.tseg2_max = 8,
> +	.sjw_max = 4,
> +	.brp_min = 2,
> +	.brp_max = 64,
> +	.brp_inc = 1,
> +};
> +
> +static inline void men_z192_bit_clr(struct men_z192 *priv, void __iomem
> *addr,
> +				    u32 mask)
> +{
> +	unsigned long flags;
> +	u32 val;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	val = readl(addr);
> +	val &= ~mask;
> +	writel(val, addr);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags); }
> +
> +static inline void men_z192_bit_set(struct men_z192 *priv, void __iomem
> *addr,
> +				    u32 mask)
> +{
> +	unsigned long flags;
> +	u32 val;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	val = readl(addr);
> +	val |= mask;
> +	writel(val, addr);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags); }
> +
> +static inline void men_z192_ack_rx_pkg(struct men_z192 *priv,
> +				       unsigned int count)
> +{
> +	writel(count, &priv->regs->rxa);
> +}
> +
> +static inline void men_z192_ack_tx_pkg(struct men_z192 *priv,
> +				       unsigned int count)
> +{
> +	writel(count, &priv->regs->txa);
> +}
> +
> +static void men_z192_set_int(struct men_z192 *priv,
> +			     enum men_z192_int_state state)
> +{
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +
> +	switch (state) {
> +	case MEN_Z192_CAN_DIS:
> +		men_z192_bit_clr(priv, &regs->ier, MEN_Z192_IRQ_ALL);
> +		break;
> +
> +	case MEN_Z192_CAN_EN:
> +		men_z192_bit_set(priv, &regs->ier, MEN_Z192_IRQ_ALL);
> +		break;
> +
> +	case MEN_Z192_CAN_NAPI_DIS:
> +		men_z192_bit_clr(priv, &regs->ier, MEN_Z192_IRQ_NAPI);
> +		break;
> +
> +	case MEN_Z192_CAN_NAPI_EN:
> +		men_z192_bit_set(priv, &regs->ier, MEN_Z192_IRQ_NAPI);
> +		break;
> +
> +	default:
> +		netdev_err(priv->ndev, "invalid interrupt state\n");
> +		break;
> +	}
> +}
> +
> +static int men_z192_get_berr_counter(const struct net_device *ndev,
> +				     struct can_berr_counter *bec)
> +{
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	u32 err_cnt;
> +
> +	err_cnt = readl(&regs->rx_tx_err);
> +
> +	bec->txerr = MEN_Z192_GET_TX_ERR_CNT(err_cnt);
> +	bec->rxerr = MEN_Z192_GET_RX_ERR_CNT(err_cnt);
> +
> +	return 0;
> +}
> +
> +static int men_z192_req_run_mode(struct men_z192 *priv) {
> +	unsigned int timeout = MEN_Z192_MODE_TOUT_US / 10;
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	u32 val;
> +
> +	men_z192_bit_clr(priv, &regs->ctl_btr, MEN_Z192_CTL0_INITRQ);
> +
> +	while (timeout--) {
> +		val = readl(&regs->ctl_btr);
> +		if (!(val & MEN_Z192_CTL1_INITAK))
> +			break;
> +
> +		udelay(10);
> +	}
> +

Can this loop be replaced with readl_poll_timeout()?

> +	if (val & MEN_Z192_CTL1_INITAK)
> +		return -ETIMEDOUT;
> +
> +	return 0;
> +}
> +
> +static int men_z192_req_init_mode(struct men_z192 *priv) {
> +	unsigned int timeout = MEN_Z192_MODE_TOUT_US / 10;
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	u32 val;
> +
> +	men_z192_bit_set(priv, &regs->ctl_btr, MEN_Z192_CTL0_INITRQ);
> +
> +	while (timeout--) {
> +		val = readl(&regs->ctl_btr);
> +		if (val & MEN_Z192_CTL1_INITAK)
> +			break;
> +
> +		udelay(10);
> +	}
> +
> +	if (!(val & MEN_Z192_CTL1_INITAK))
> +		return -ETIMEDOUT;
> +
> +	return 0;
> +}
> +
> +static int men_z192_read_frame(struct net_device *ndev, unsigned int
> +frame_nr) {
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_cf_buf __iomem *cf_buf;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 cf_offset;
> +	u32 length;
> +	u32 data;
> +	u32 id;
> +
> +	skb = alloc_can_skb(ndev, &cf);
> +	if (unlikely(!skb)) {
> +		stats->rx_dropped++;
> +		return 0;
> +	}
> +
> +	cf_offset = sizeof(struct men_z192_cf_buf) * frame_nr;
> +
> +	cf_buf = priv->dev_base + MEN_Z192_RX_BUF_START + cf_offset;
> +	length = readl(&cf_buf->length) & MEN_Z192_CFBUF_LEN;
> +	id = readl(&cf_buf->can_id);
> +
> +	if (id & MEN_Z192_CFBUF_IDE) {
> +		/* Extended frame */
> +		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >> 3;
> +		cf->can_id |= (id & MEN_Z192_CFBUF_ID2) >>
> +				MEN_Z192_CFBUF_ID2_SHIFT;
> +
> +		cf->can_id |= CAN_EFF_FLAG;
> +
> +		if (id & MEN_Z192_CFBUF_E_RTR)
> +			cf->can_id |= CAN_RTR_FLAG;
> +	} else {
> +		/* Standard frame */
> +		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >>
> +				MEN_Z192_CFBUF_ID1_SHIFT;
> +
> +		if (id & MEN_Z192_CFBUF_S_RTR)
> +			cf->can_id |= CAN_RTR_FLAG;
> +	}
> +
> +	cf->can_dlc = get_can_dlc(length);
> +
> +	/* remote transmission request frame
> +	 * contains no data field even if the
> +	 * data length is set to a value > 0
> +	 */
> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> +		if (cf->can_dlc > 0) {
> +			data = readl(&cf_buf->data[0]);
> +			*(__be32 *)cf->data = cpu_to_be32(data);
> +		}
> +		if (cf->can_dlc > 4) {
> +			data = readl(&cf_buf->data[1]);
> +			*(__be32 *)(cf->data + 4) = cpu_to_be32(data);
> +		}
> +	}
> +
> +	stats->rx_bytes += cf->can_dlc;
> +	stats->rx_packets++;
> +	netif_receive_skb(skb);
> +
> +	return 1;
> +}
> +
> +static int men_z192_poll(struct napi_struct *napi, int quota) {
> +	struct net_device *ndev = napi->dev;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	int work_done = 0;
> +	u32 frame_cnt;
> +	u32 status;
> +
> +	status = readl(&regs->rx_tx_sts);
> +
> +	frame_cnt = MEN_Z192_RX_BUF_CNT(status);
> +
> +	while (frame_cnt-- && (work_done < quota)) {
> +		work_done += men_z192_read_frame(ndev, 0);

Why we need the second arg if we are always going to read from 0th offset?

> +		men_z192_ack_rx_pkg(priv, 1);
> +	}
> +
> +	if (work_done < quota) {
> +		napi_complete(napi);
> +		men_z192_set_int(priv, MEN_Z192_CAN_NAPI_EN);
> +	}
> +
> +	return work_done;
> +}
> +
> +static int men_z192_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct men_z192_cf_buf __iomem *cf_buf;
> +	u32 data[2] = {0, 0};
> +	int status;
> +	u32 id;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	status = readl(&regs->rx_tx_sts);
> +
> +	if (MEN_Z192_TX_BUF_CNT(status) >= 255) {

Can this ever be > 255?

> +		netif_stop_queue(ndev);
> +		netdev_err(ndev, "not enough space in TX buffer\n");
> +
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	cf_buf = priv->dev_base + MEN_Z192_TX_BUF_START;
> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame */
> +		id = ((cf->can_id & CAN_EFF_MASK) <<
> +			MEN_Z192_CFBUF_ID2_SHIFT) & MEN_Z192_CFBUF_ID2;
> +
> +		id |= (((cf->can_id & CAN_EFF_MASK) >>
> +			(CAN_EFF_ID_BITS - CAN_SFF_ID_BITS)) <<
> +			 MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		id |= MEN_Z192_CFBUF_IDE;
> +		id |= MEN_Z192_CFBUF_SRR;
> +
> +		if (cf->can_id & CAN_RTR_FLAG)
> +			id |= MEN_Z192_CFBUF_E_RTR;
> +	} else {
> +		/* Standard frame */
> +		id = ((cf->can_id & CAN_SFF_MASK) <<
> +		       MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		if (cf->can_id & CAN_RTR_FLAG)
> +			id |= MEN_Z192_CFBUF_S_RTR;
> +	}
> +
> +	if (cf->can_dlc > 0)
> +		data[0] = be32_to_cpup((__be32 *)(cf->data));
> +	if (cf->can_dlc > 3)
> +		data[1] = be32_to_cpup((__be32 *)(cf->data + 4));
> +
> +	writel(id, &cf_buf->can_id);
> +	writel(cf->can_dlc, &cf_buf->length);
> +
> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> +		writel(data[0], &cf_buf->data[0]);
> +		writel(data[1], &cf_buf->data[1]);
> +
> +		stats->tx_bytes += cf->can_dlc;
> +	}
> +
> +	/* be sure everything is written to the
> +	 * device before acknowledge the data.
> +	 */
> +	mmiowb();
> +
> +	/* trigger the transmission */
> +	men_z192_ack_tx_pkg(priv, 1);
> +
> +	stats->tx_packets++;
> +

Assuming MEN_Z192_TFLG_TXIF interrupt confirms frame transmission, should the stats we updated on the completion interrupt? You may also want to keep a local echo_skb[txlvl] if you have to implement local loopback.

> +	kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void men_z192_err_interrupt(struct net_device *ndev, u32 status)
> +{
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct can_berr_counter bec;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	enum can_state rx_state = 0, tx_state = 0;
> +
> +	skb = alloc_can_err_skb(ndev, &cf);
> +	if (unlikely(!skb))
> +		return;
> +
> +	/* put the rx/tx error counter to
> +	 * the additional controller specific
> +	 * section of the error frame.
> +	 */
> +	men_z192_get_berr_counter(ndev, &bec);
> +	cf->data[6] = bec.txerr;
> +	cf->data[7] = bec.rxerr;
> +
> +	/* overrun interrupt */
> +	if (status & MEN_Z192_RFLG_OVRF) {
> +		cf->can_id |= CAN_ERR_CRTL;
> +		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> +		stats->rx_over_errors++;
> +		stats->rx_errors++;
> +	}
> +
> +	/* bus change interrupt */
> +	if (status & MEN_Z192_RFLG_CSCIF) {
> +		rx_state = bus_state_map[MEN_Z192_GET_RSTATE(status)];
> +		tx_state = bus_state_map[MEN_Z192_GET_TSTATE(status)];
> +		can_change_state(ndev, cf, tx_state, rx_state);
> +
> +		if (priv->can.state == CAN_STATE_BUS_OFF)
> +			can_bus_off(ndev);

Should the priv->can.can_stats be updated?

> +	}
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +	netif_receive_skb(skb);

Should this be netif_rx(skb)?

> +}
> +
> +static irqreturn_t men_z192_isr(int irq, void *dev_id) {
> +	struct net_device *ndev = dev_id;
> +	struct men_z192 *priv = netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs = priv->regs;
> +	bool handled = false;
> +	u32 irq_flags;
> +	u32 status;
> +
> +	status = readl(&regs->rx_tx_sts);
> +
> +	irq_flags = status & MEN_Z192_IRQ_FLAGS_ALL;
> +	if (!irq_flags)
> +		goto out;
> +
> +	/* It is save to write to RX_TS_STS[15:0] */

s/save/safe/ ?

> +	writel(irq_flags, &regs->rx_tx_sts);
> +
> +	if (irq_flags & MEN_Z192_TFLG_TXIF) {
> +		netif_wake_queue(ndev);
> +		handled = true;
> +	}
> +
> +	/* handle errors */
> +	if ((irq_flags & MEN_Z192_RFLG_OVRF) ||
> +	    (irq_flags & MEN_Z192_RFLG_CSCIF)) {
> +		men_z192_err_interrupt(ndev, status);
> +		handled = true;
> +	}
> +
> +	/* schedule NAPI if:
> +	 * - rx IRQ
> +	 * - rx timeout IRQ
> +	 */
> +	if ((irq_flags & MEN_Z192_RFLG_RXIF) ||
> +	    (irq_flags & MEN_Z192_RFLG_TOUTF)) {

Is it a good idea to check if frames are really there to consume before napi_schedule? It could be just a periodic rx timeout interrupt? Still not convinced by that logic.

Thanks,
Ramesh
