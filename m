From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Introduce MEN 16Z192-00 CAN controller driver
Date: Fri, 14 Apr 2017 17:21:24 +0200
Message-ID: <a55691fb-9e57-457c-2806-40f7ce9442cf@pengutronix.de>
References: <20160628134412.GA25172@awelinux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Em4RoU0qJsbure8MCXd88jXeldPL3gwur"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, morbidrsa@gmail.com, info@men.de
To: Andreas Werner <andreas.werner@men.de>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160628134412.GA25172@awelinux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Em4RoU0qJsbure8MCXd88jXeldPL3gwur
Content-Type: multipart/mixed; boundary="fo3MFlTctWeecctgFtnONNXcHv53St5xI";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Andreas Werner <andreas.werner@men.de>, wg@grandegger.com
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, morbidrsa@gmail.com, info@men.de
Message-ID: <a55691fb-9e57-457c-2806-40f7ce9442cf@pengutronix.de>
Subject: Re: [PATCH] net: can: Introduce MEN 16Z192-00 CAN controller driver
References: <20160628134412.GA25172@awelinux>
In-Reply-To: <20160628134412.GA25172@awelinux>

--fo3MFlTctWeecctgFtnONNXcHv53St5xI
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/28/2016 03:44 PM, Andreas Werner wrote:
> This CAN Controller is found on MEN Chameleon FPGAs.
>=20
> The driver/device supports the CAN2.0 specification.
> There are 255 RX and 255 Tx buffer within the IP. The
> pointer for the buffer are handled by HW to make the
> access from within the driver as simple as possible.
>=20
> The driver also supports parameters to configure the
> buffer level interrupt for RX/TX as well as a RX timeout
> interrupt.
>=20
> With this configuration options, the driver/device
> provides flexibility for different types of usecases.

Please implement LED support, see commit:

    adccadb92f05 can: flexcan: add LED trigger support

Please add proper IFF_ECHO support, on xmit call can_put_echo_skb() on
tx-complete interrupt can_get_echo_skb().

See inline for more comments.

>=20
> Signed-off-by: Andreas Werner <andreas.werner@men.de>
> ---
>  drivers/net/can/Kconfig        |  10 +
>  drivers/net/can/Makefile       |   1 +
>  drivers/net/can/men_z192_can.c | 990 +++++++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 1001 insertions(+)
>  create mode 100644 drivers/net/can/men_z192_can.c
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 0d40aef..0fa0387 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -104,6 +104,16 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will b=
e
>  	  called janz-ican3.ko.
> =20
> +config CAN_MEN_Z192
> +	tristate "MEN 16Z192-00 CAN Controller"
> +	depends on MCB
> +	---help---
> +	  Driver for MEN 16Z192-00 CAN Controller IP-Core, which
> +	  is connected to the MEN Chameleon Bus.
> +
> +	  This driver can also be built as a module. If so, the module will b=
e
> +	  called men_z192_can.ko.
> +
>  config CAN_RCAR
>  	tristate "Renesas R-Car CAN controller"
>  	depends on ARCH_RENESAS || ARM
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index e3db0c8..eb206b3 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -22,6 +22,7 @@ obj-$(CONFIG_CAN_FLEXCAN)	+=3D flexcan.o
>  obj-$(CONFIG_CAN_GRCAN)		+=3D grcan.o
>  obj-$(CONFIG_CAN_IFI_CANFD)	+=3D ifi_canfd/
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ican3.o
> +obj-$(CONFIG_CAN_MEN_Z192)	+=3D men_z192_can.o
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
>  obj-$(CONFIG_CAN_M_CAN)		+=3D m_can/
>  obj-$(CONFIG_CAN_RCAR)		+=3D rcar_can.o
> diff --git a/drivers/net/can/men_z192_can.c b/drivers/net/can/men_z192_=
can.c
> new file mode 100644
> index 0000000..d3acc2e
> --- /dev/null
> +++ b/drivers/net/can/men_z192_can.c
> @@ -0,0 +1,990 @@
> +/*
> + * MEN 16Z192 CAN Controller driver
> + *
> + * Copyright (C) 2016 MEN Mikroelektronik GmbH (www.men.de)
> + *
> + * This program is free software; you can redistribute it and/or modif=
y it
> + * under the terms of the GNU General Public License as published by t=
he Free
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

please use a single space after the macro definition

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
> +static int txlvl =3D MEN_Z192_TX_BUF_LVL_DEF;
> +module_param(txlvl, int, S_IRUGO);
> +MODULE_PARM_DESC(txlvl, "TX IRQ trigger level (in frames) 0-254, defau=
lt=3D"
> +		 __MODULE_STRING(MEN_Z192_TX_BUF_LVL_DEF) ")");
> +
> +static int rxlvl =3D MEN_Z192_RX_BUF_LVL_DEF;
> +module_param(rxlvl, int, S_IRUGO);
> +MODULE_PARM_DESC(rxlvl, "RX IRQ trigger level (in frames) 0-254, defau=
lt=3D"
> +		 __MODULE_STRING(MEN_Z192_RX_BUF_LVL_DEF) ")");
> +
> +static int rx_timeout =3D MEN_Z192_RX_TOUT_DEF;
> +module_param(rx_timeout, int, S_IRUGO);
> +MODULE_PARM_DESC(rx_timeout, "RX IRQ timeout (in 100usec steps), defau=
lt=3D"
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
> +	u32 timebase;		/* Base frequency for baudrate calculation */
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
> +	MEN_Z192_CAN_DIS =3D 0,
> +	MEN_Z192_CAN_EN,
> +	MEN_Z192_CAN_NAPI_DIS,
> +	MEN_Z192_CAN_NAPI_EN,
> +};
> +
> +static enum can_state bus_state_map[] =3D {
> +	CAN_STATE_ERROR_ACTIVE,
> +	CAN_STATE_ERROR_WARNING,
> +	CAN_STATE_ERROR_PASSIVE,
> +	CAN_STATE_BUS_OFF
> +};
> +
> +static const struct can_bittiming_const men_z192_bittiming_const =3D {=

> +	.name =3D DRV_NAME,
> +	.tseg1_min =3D 4,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 2,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 2,
> +	.brp_max =3D 64,
> +	.brp_inc =3D 1,
> +};
> +
> +static inline void men_z192_bit_clr(struct men_z192 *priv, void __iome=
m *addr,
> +				    u32 mask)
> +{
> +	unsigned long flags;
> +	u32 val;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	val =3D readl(addr);
> +	val &=3D ~mask;
> +	writel(val, addr);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +}
> +
> +static inline void men_z192_bit_set(struct men_z192 *priv, void __iome=
m *addr,
> +				    u32 mask)
> +{
> +	unsigned long flags;
> +	u32 val;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	val =3D readl(addr);
> +	val |=3D mask;
> +	writel(val, addr);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +}
> +
> +static inline void men_z192_ack_rx_pkg(struct men_z192 *priv,
> +				       unsigned int count)
u32
> +{
> +	writel(count, &priv->regs->rxa);
> +}
> +
> +static inline void men_z192_ack_tx_pkg(struct men_z192 *priv,
> +				       unsigned int count)
u32
> +{
> +	writel(count, &priv->regs->txa);
> +}
> +
> +static void men_z192_set_int(struct men_z192 *priv,
> +			     enum men_z192_int_state state)
> +{
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
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
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	u32 err_cnt;
> +
> +	err_cnt =3D readl(&regs->rx_tx_err);
> +
> +	bec->txerr =3D MEN_Z192_GET_TX_ERR_CNT(err_cnt);
> +	bec->rxerr =3D MEN_Z192_GET_RX_ERR_CNT(err_cnt);
> +
> +	return 0;
> +}
> +
> +static int men_z192_req_run_mode(struct men_z192 *priv)
> +{
> +	unsigned int timeout =3D MEN_Z192_MODE_TOUT_US / 10;
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	u32 val;
> +
> +	men_z192_bit_clr(priv, &regs->ctl_btr, MEN_Z192_CTL0_INITRQ);
> +
> +	while (timeout--) {
> +		val =3D readl(&regs->ctl_btr);
> +		if (!(val & MEN_Z192_CTL1_INITAK))
> +			break;
> +
> +		udelay(10);
> +	}

readl_relaxed_poll_timeout_atomic

> +
> +	if (val & MEN_Z192_CTL1_INITAK)
> +		return -ETIMEDOUT;
> +
> +	return 0;
> +}
> +
> +static int men_z192_req_init_mode(struct men_z192 *priv)
> +{
> +	unsigned int timeout =3D MEN_Z192_MODE_TOUT_US / 10;
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	u32 val;
> +
> +	men_z192_bit_set(priv, &regs->ctl_btr, MEN_Z192_CTL0_INITRQ);
> +
> +	while (timeout--) {
> +		val =3D readl(&regs->ctl_btr);
> +		if (val & MEN_Z192_CTL1_INITAK)
> +			break;
> +
> +		udelay(10);
> +	}

Use readl_relaxed_poll_timeout_atomic()

> +
> +	if (!(val & MEN_Z192_CTL1_INITAK))
> +		return -ETIMEDOUT;
> +
> +	return 0;
> +}
> +
> +static int men_z192_read_frame(struct net_device *ndev, unsigned int f=
rame_nr)
> +{
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_cf_buf __iomem *cf_buf;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 cf_offset;
> +	u32 length;
> +	u32 data;
> +	u32 id;
> +
> +	skb =3D alloc_can_skb(ndev, &cf);
> +	if (unlikely(!skb)) {
> +		stats->rx_dropped++;
> +		return 0;
> +	}
> +
> +	cf_offset =3D sizeof(struct men_z192_cf_buf) * frame_nr;
> +
> +	cf_buf =3D priv->dev_base + MEN_Z192_RX_BUF_START + cf_offset;
> +	length =3D readl(&cf_buf->length) & MEN_Z192_CFBUF_LEN;
> +	id =3D readl(&cf_buf->can_id);
> +
> +	if (id & MEN_Z192_CFBUF_IDE) {
> +		/* Extended frame */
> +		cf->can_id =3D (id & MEN_Z192_CFBUF_ID1) >> 3;
> +		cf->can_id |=3D (id & MEN_Z192_CFBUF_ID2) >>
> +				MEN_Z192_CFBUF_ID2_SHIFT;
> +
> +		cf->can_id |=3D CAN_EFF_FLAG;
> +
> +		if (id & MEN_Z192_CFBUF_SRR)
> +			cf->can_id |=3D CAN_RTR_FLAG;
> +	} else {
> +		/* Standard frame */
> +		cf->can_id =3D (id & MEN_Z192_CFBUF_ID1) >>
> +				MEN_Z192_CFBUF_ID1_SHIFT;
> +
> +		if (id & MEN_Z192_CFBUF_S_RTR)
> +			cf->can_id |=3D CAN_RTR_FLAG;
> +	}
> +
> +	cf->can_dlc =3D get_can_dlc(length);
> +
> +	/* remote transmission request frame
> +	 * contains no data field even if the
> +	 * data length is set to a value > 0
> +	 */
> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> +		if (cf->can_dlc > 0) {
> +			data =3D readl(&cf_buf->data[0]);
> +			*(__be32 *)cf->data =3D cpu_to_be32(data);
> +		}
> +		if (cf->can_dlc > 4) {
> +			data =3D readl(&cf_buf->data[1]);
> +			*(__be32 *)(cf->data + 4) =3D cpu_to_be32(data);
> +		}
> +	}
> +
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	stats->rx_packets++;
> +	netif_receive_skb(skb);
> +
> +	return 1;
> +}
> +
> +static int men_z192_poll(struct napi_struct *napi, int quota)
> +{
> +	struct net_device *ndev =3D napi->dev;
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	int work_done =3D 0;
> +	u32 frame_cnt;
> +	u32 status;
> +
> +	status =3D readl(&regs->rx_tx_sts);
> +
> +	frame_cnt =3D MEN_Z192_RX_BUF_CNT(status);
> +
> +	while (frame_cnt-- && (work_done < quota)) {
> +		work_done +=3D men_z192_read_frame(ndev, 0);
> +		men_z192_ack_rx_pkg(priv, 1);
> +	}
> +
> +	if (work_done < quota) {
> +		napi_complete(napi);
napi_complete_done(napi, work_done);
> +		men_z192_set_int(priv, MEN_Z192_CAN_NAPI_EN);
> +	}
> +
> +	return work_done;
> +}
> +
> +static int men_z192_xmit(struct sk_buff *skb, struct net_device *ndev)=

> +{
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct men_z192_cf_buf __iomem *cf_buf;
> +	u32 data[2] =3D {0, 0};
> +	int status;
> +	u32 id;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	status =3D readl(&regs->rx_tx_sts);
> +
> +	if (MEN_Z192_TX_BUF_CNT(status) >=3D 255) {
> +		netif_stop_queue(ndev);
> +		netdev_err(ndev, "not enough space in TX buffer\n");

Please do this at the end of the function, stop the tx_queue, if there
are no tx buffers available anymore.
> +
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	cf_buf =3D priv->dev_base + MEN_Z192_TX_BUF_START;
> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame */
> +		id =3D ((cf->can_id & CAN_EFF_MASK) <<
> +			MEN_Z192_CFBUF_ID2_SHIFT) & MEN_Z192_CFBUF_ID2;
> +
> +		id |=3D (((cf->can_id & CAN_EFF_MASK) >>
> +			(CAN_EFF_ID_BITS - CAN_SFF_ID_BITS)) <<
> +			 MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		id |=3D MEN_Z192_CFBUF_IDE;
> +
> +		if (cf->can_id & CAN_RTR_FLAG) {
> +			id |=3D MEN_Z192_CFBUF_SRR;
> +			id |=3D MEN_Z192_CFBUF_E_RTR;
> +		}
> +	} else {
> +		/* Standard frame */
> +		id =3D ((cf->can_id & CAN_SFF_MASK) <<
> +		       MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
> +
> +		if (cf->can_id & CAN_RTR_FLAG)
> +			id |=3D MEN_Z192_CFBUF_S_RTR;
> +	}
> +
> +	if (cf->can_dlc > 0)
> +		data[0] =3D be32_to_cpup((__be32 *)(cf->data));
> +	if (cf->can_dlc > 3)
> +		data[1] =3D be32_to_cpup((__be32 *)(cf->data + 4));
> +
> +	writel(id, &cf_buf->can_id);
> +	writel(cf->can_dlc, &cf_buf->length);
> +
> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
> +		writel(data[0], &cf_buf->data[0]);
> +		writel(data[1], &cf_buf->data[1]);
> +
> +		stats->tx_bytes +=3D cf->can_dlc;
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
> +	kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void men_z192_err_interrupt(struct net_device *ndev, u32 status=
)
> +{
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct can_berr_counter bec;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	enum can_state rx_state =3D 0, tx_state =3D 0;
> +
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (unlikely(!skb))
> +		return;

Please do the stats handling and the bus_off, even if there's skb.
> +
> +	/* put the rx/tx error counter to
> +	 * the additional controller specific
> +	 * section of the error frame.
> +	 */
> +	men_z192_get_berr_counter(ndev, &bec);
> +	cf->data[6] =3D bec.txerr;
> +	cf->data[7] =3D bec.rxerr;
> +
> +	/* overrun interrupt */
> +	if (status & MEN_Z192_RFLG_OVRF) {
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +		stats->rx_over_errors++;
> +		stats->rx_errors++;
> +	}
> +
> +	/* bus change interrupt */
> +	if (status & MEN_Z192_RFLG_CSCIF) {
> +		rx_state =3D bus_state_map[MEN_Z192_GET_RSTATE(status)];
> +		tx_state =3D bus_state_map[MEN_Z192_GET_TSTATE(status)];
> +		can_change_state(ndev, cf, tx_state, rx_state);
> +
> +		if (priv->can.state =3D=3D CAN_STATE_BUS_OFF)
> +			can_bus_off(ndev);
> +	}
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	netif_receive_skb(skb);
> +}
> +
> +static irqreturn_t men_z192_isr(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D dev_id;
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	bool handled =3D false;
> +	u32 irq_flags;
> +	u32 status;
> +
> +	status =3D readl(&regs->rx_tx_sts);
> +
> +	irq_flags =3D status & MEN_Z192_IRQ_FLAGS_ALL;
> +	if (!irq_flags)
> +		goto out;
> +
> +	/* It is save to write to RX_TS_STS[15:0] */
> +	writel(irq_flags, &regs->rx_tx_sts);
> +
> +	if (irq_flags & MEN_Z192_TFLG_TXIF) {
> +		netif_wake_queue(ndev);
> +		handled =3D true;
> +	}
> +
> +	/* handle errors */
> +	if ((irq_flags & MEN_Z192_RFLG_OVRF) ||
> +	    (irq_flags & MEN_Z192_RFLG_CSCIF)) {
> +		men_z192_err_interrupt(ndev, status);
> +		handled =3D true;
> +	}
> +
> +	/* schedule NAPI if:
> +	 * - rx IRQ
> +	 * - rx timeout IRQ
> +	 */
> +	if ((irq_flags & MEN_Z192_RFLG_RXIF) ||
> +	    (irq_flags & MEN_Z192_RFLG_TOUTF)) {
> +		men_z192_set_int(priv, MEN_Z192_CAN_NAPI_DIS);
> +		napi_schedule(&priv->napi);
> +		handled =3D true;
> +	}
> +
> +out:
> +	return IRQ_RETVAL(handled);
> +}
> +
> +static int men_z192_set_bittiming(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +	unsigned long flags;
> +	u32 ctlbtr;
> +	int ret =3D 0;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	ctlbtr =3D readl(&priv->regs->ctl_btr);
> +
> +	if (!(ctlbtr & MEN_Z192_CTL1_INITAK)) {
> +		netdev_alert(ndev,
> +			     "cannot set bittiminig while in running mode\n");
> +		ret =3D -EPERM;
> +		goto out_restore;
> +	}
> +
> +	ctlbtr &=3D ~(MEN_Z192_BTR0_BRP(0x3f) |
> +		    MEN_Z192_BTR0_SJW(0x03) |
> +		    MEN_Z192_BTR1_TSEG1(0x0f) |
> +		    MEN_Z192_BTR1_TSEG2(0x07) |
> +		    MEN_Z192_CTL1_LISTEN |
> +		    MEN_Z192_CTL1_LOOPB |
> +		    MEN_Z192_BTR1_SAMP);
> +
> +	ctlbtr |=3D MEN_Z192_BTR0_BRP(bt->brp - 1) |
> +		  MEN_Z192_BTR0_SJW(bt->sjw - 1) |
> +		  MEN_Z192_BTR1_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
> +		  MEN_Z192_BTR1_TSEG2(bt->phase_seg2 - 1);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> +		ctlbtr |=3D MEN_Z192_BTR1_SAMP;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> +		ctlbtr |=3D MEN_Z192_CTL1_LISTEN;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> +		ctlbtr |=3D MEN_Z192_CTL1_LOOPB;
> +
> +	netdev_dbg(ndev, "CTL_BTR=3D0x%08x\n", ctlbtr);
> +
> +	writel(ctlbtr, &priv->regs->ctl_btr);
> +
> +out_restore:
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	return ret;
> +}
> +
> +static void men_z192_init_idac(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +
> +	/* hardware filtering (accept everything) */
> +	writel(0x00000000, &regs->idar_0_to_3);
> +	writel(0x00000000, &regs->idar_4_to_7);
> +	writel(0xffffffff, &regs->idmr_0_to_3);
> +	writel(0xffffffff, &regs->idmr_4_to_7);
> +}
> +
> +void men_z192_set_can_state(struct net_device *ndev)

static

> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	enum can_state rx_state, tx_state;
> +	u32 status;
> +
> +	status =3D readl(&regs->rx_tx_sts);
> +
> +	rx_state =3D bus_state_map[MEN_Z192_GET_RSTATE(status)];
> +	tx_state =3D bus_state_map[MEN_Z192_GET_TSTATE(status)];
> +
> +	priv->can.state =3D max(tx_state, rx_state);
> +}
> +
> +static int men_z192_start(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	ret =3D men_z192_req_init_mode(priv);
> +	if (ret)
> +		return ret;
> +
> +	ret =3D men_z192_set_bittiming(ndev);
> +	if (ret)
> +		return ret;
> +
> +	ret =3D men_z192_req_run_mode(priv);
> +	if (ret)
> +		return ret;
> +
> +	men_z192_init_idac(ndev);
> +
> +	/* The 16z192 CAN IP does not reset the can bus state
> +	 * if we enter the init mode. There is also
> +	 * no software reset to reset the state machine.
> +	 * We need to read the current state, and
> +	 * inform the upper layer about the current state.
> +	 */
> +	men_z192_set_can_state(ndev);
> +
> +	men_z192_set_int(priv, MEN_Z192_CAN_EN);
> +
> +	return 0;
> +}
> +
> +static int men_z192_open(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	ret =3D open_candev(ndev);
> +	if (ret)
> +		return ret;
> +
> +	ret =3D request_irq(ndev->irq, men_z192_isr, IRQF_SHARED,
> +			  ndev->name, ndev);
> +	if (ret)
> +		goto out_close;
> +
> +	ret =3D men_z192_start(ndev);
> +	if (ret)
> +		goto out_free_irq;
> +
> +	napi_enable(&priv->napi);
> +	netif_start_queue(ndev);
> +
> +	return 0;
> +
> +out_free_irq:
> +	free_irq(ndev->irq, ndev);
> +out_close:
> +	close_candev(ndev);
> +	return ret;
> +}
> +
> +static int men_z192_stop(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	men_z192_set_int(priv, MEN_Z192_CAN_DIS);
> +
> +	ret =3D men_z192_req_init_mode(priv);
> +	if (ret)
> +		return ret;
> +
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +
> +	return 0;
> +}
> +
> +static int men_z192_close(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	netif_stop_queue(ndev);
> +
> +	napi_disable(&priv->napi);
> +
> +	ret =3D men_z192_stop(ndev);
> +
> +	free_irq(ndev->irq, ndev);
> +
> +	close_candev(ndev);
> +
> +	return ret;
> +}
> +
> +static int men_z192_set_mode(struct net_device *ndev, enum can_mode mo=
de)
> +{
> +	int ret;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		ret =3D men_z192_start(ndev);
> +		if (ret)
> +			return ret;
> +
> +		netif_wake_queue(ndev);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops men_z192_netdev_ops =3D {
> +	.ndo_open	=3D men_z192_open,
> +	.ndo_stop	=3D men_z192_close,
> +	.ndo_start_xmit	=3D men_z192_xmit,
> +	.ndo_change_mtu	=3D can_change_mtu,
> +};
> +
> +static int men_z192_verify_buf_lvl(int buffer_lvl)
> +{
> +	if (buffer_lvl < MEN_Z192_MIN_BUF_LVL ||
> +	    buffer_lvl > MEN_Z192_MAX_BUF_LVL)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static void men_z192_set_buf_lvl_irq(struct net_device *ndev, int rxlv=
l,
> +				     int txlvl)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	int reg_val;
> +
> +	if (men_z192_verify_buf_lvl(rxlvl))
> +		reg_val =3D MEN_Z192_RX_BUF_LVL_DEF & MEN_Z192_RX_BUF_LVL;
> +	else
> +		reg_val =3D rxlvl & MEN_Z192_RX_BUF_LVL;
> +
> +	if (men_z192_verify_buf_lvl(txlvl))
> +		reg_val |=3D (MEN_Z192_TX_BUF_LVL_DEF << 16) &
> +			    MEN_Z192_TX_BUF_LVL;
> +	else
> +		reg_val |=3D (txlvl << 16) & MEN_Z192_TX_BUF_LVL;
> +
> +	dev_info(priv->dev, "RX IRQ Level: %d TX IRQ Level: %d\n",
> +		 rxlvl, txlvl);
> +
> +	writel(reg_val, &regs->buf_lvl);
> +}
> +
> +static void men_z192_set_rx_tout(struct net_device *ndev, int tout)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	int reg_val;
> +
> +	if (tout < MEN_Z192_RX_TOUT_MIN || tout > MEN_Z192_RX_TOUT_MAX)
> +		reg_val =3D MEN_Z192_RX_TOUT_MAX;
> +	else
> +		reg_val =3D tout;
> +
> +	dev_info(priv->dev, "RX IRQ timeout set to: %d\n", reg_val);
> +
> +	writel(reg_val, &regs->rx_timeout);
> +}
> +
> +static int men_z192_register(struct net_device *ndev)
> +{
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +	struct men_z192_regs __iomem *regs =3D priv->regs;
> +	u32 ctl_btr;
> +	int ret;
> +
> +	/* The CAN controller should be always enabled.
> +	 * There is no way to enable it if disabled.
> +	 */
> +	ctl_btr =3D readl(&regs->ctl_btr);
> +	if (!(ctl_btr & MEN_Z192_CTL1_CANE))
> +		return -ENODEV;
> +
> +	men_z192_set_buf_lvl_irq(ndev, rxlvl, txlvl);
> +	men_z192_set_rx_tout(ndev, rx_timeout);
> +
> +	ret =3D men_z192_req_init_mode(priv);
> +	if (ret) {
> +		dev_err(priv->dev, "failed to request init mode\n");
> +		return ret;
> +	}
> +
> +	return register_candev(ndev);
> +}
> +
> +static void men_z192_unregister(struct net_device *ndev)
          ^^^^

void, but you return a value....

> +{
> +	return unregister_candev(ndev);

=2E..or not, as unregister_candev() itself is void

> +}
> +
> +static int men_z192_probe(struct mcb_device *mdev,
> +			  const struct mcb_device_id *id)
> +{
> +	struct device *dev =3D &mdev->dev;
> +	struct men_z192 *priv;
> +	struct net_device *ndev;
> +	void __iomem *dev_base;
> +	struct resource *mem;
> +	u32 timebase;
> +	int ret =3D 0;
> +	int irq;
> +
> +	mem =3D mcb_request_mem(mdev, dev_name(dev));
> +	if (IS_ERR(mem)) {
> +		dev_err(dev, "failed to request device memory");
> +		return PTR_ERR(mem);
> +	}
> +
> +	dev_base =3D ioremap(mem->start, resource_size(mem));
devm_ioremap_resource
> +	if (!dev_base) {
> +		dev_err(dev, "failed to ioremap device memory");
> +		ret =3D -ENXIO;
> +		goto out_release;
> +	}
> +
> +	irq =3D mcb_get_irq(mdev);
> +	if (irq <=3D 0) {
> +		ret =3D -ENODEV;
> +		goto out_unmap;
> +	}
> +
> +	ndev =3D alloc_candev(sizeof(struct men_z192), 1);
> +	if (!ndev) {
> +		dev_err(dev, "failed to allocate the can device");
> +		ret =3D -ENOMEM;
> +		goto out_unmap;
> +	}
> +
> +	ndev->netdev_ops =3D &men_z192_netdev_ops;
> +	ndev->irq =3D irq;
> +
> +	priv =3D netdev_priv(ndev);
> +	priv->ndev =3D ndev;
> +	priv->dev =3D dev;
> +
> +	priv->mem =3D mem;
> +	priv->dev_base =3D dev_base;
> +	priv->regs =3D priv->dev_base + MEN_Z192_REGS_OFFS;
> +
> +	timebase =3D readl(&priv->regs->timebase);
> +	if (!timebase) {
> +		dev_err(dev, "invalid timebase configured (timebase=3D%d)\n",
> +			timebase);
> +		ret =3D -EINVAL;
> +		goto out_unmap;
goto out_free_candev
> +	}
> +
> +	priv->can.clock.freq =3D timebase;
> +	priv->can.bittiming_const =3D &men_z192_bittiming_const;
> +	priv->can.do_set_mode =3D men_z192_set_mode;
> +	priv->can.do_get_berr_counter =3D men_z192_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LISTENONLY |
> +				       CAN_CTRLMODE_3_SAMPLES |
> +				       CAN_CTRLMODE_LOOPBACK;
> +
> +	spin_lock_init(&priv->lock);
> +
> +	netif_napi_add(ndev, &priv->napi, men_z192_poll,
> +		       MEN_Z192_NAPI_WEIGHT);
> +
> +	mcb_set_drvdata(mdev, ndev);
> +	SET_NETDEV_DEV(ndev, dev);
> +
> +	ret =3D men_z192_register(ndev);
> +	if (ret) {
> +		dev_err(dev, "failed to register CAN device");
> +		goto out_napi_del;
> +	}
> +
> +	dev_info(dev, "MEN 16z192 CAN driver successfully registered\n");
> +
> +	return 0;
> +
> +out_free_candev:
out_napi_del:
> +	netif_napi_del(&priv->napi);
out_free_candev:
> +	free_candev(ndev);
> +out_unmap:
> +	iounmap(dev_base);

obsolete with devm_ioremap_resource()

> +out_release:
> +	mcb_release_mem(mem);
> +	return ret;
> +}
> +
> +static void men_z192_remove(struct mcb_device *mdev)
> +{
> +	struct net_device *ndev =3D mcb_get_drvdata(mdev);
> +	struct men_z192 *priv =3D netdev_priv(ndev);
> +
> +	men_z192_unregister(ndev);

please call unregister_candev() directly

> +	netif_napi_del(&priv->napi);
> +
> +	iounmap(priv->dev_base);

obsolete with devm_ioremap_resource()

> +	mcb_release_mem(priv->mem);
> +
> +	free_candev(ndev);
> +}
> +
> +static const struct mcb_device_id men_z192_ids[] =3D {
> +	{ .device =3D 0xc0 },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(mcb, men_z192_ids);
> +
> +static struct mcb_driver men_z192_driver =3D {
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +	},
> +	.probe =3D men_z192_probe,
> +	.remove =3D men_z192_remove,
> +	.id_table =3D men_z192_ids,
> +};
> +module_mcb_driver(men_z192_driver);
> +
> +MODULE_AUTHOR("Andreas Werner <andreas.werner@men.de>");
> +MODULE_DESCRIPTION("MEN 16z192 CAN Controller");
> +MODULE_LICENSE("GPL v2");
> +MODULE_ALIAS("mcb:16z192");
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fo3MFlTctWeecctgFtnONNXcHv53St5xI--

--Em4RoU0qJsbure8MCXd88jXeldPL3gwur
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljw6PQACgkQHv7KIOw4
HPZf6Af+IXteTBeCKTlI5Yj4ObDbpiDiMB04gt3Bwh+SWAfI4QQgMkxAycsRPauH
CgLHnK5811cg3eyvWZ/VwQ0wGN5ucS0mi+teBXJ8XamGk79YRAFuKXprsmVBoCsi
sSqZkbuLO05kTOjXpGc0sbHtAV+8gqT8xtPAEamYa/QRhLNDjoS9nwA2vtxPpKrk
QMOJSfbwD5bZVK0FUtoRmsTEpCMhqxxTYxD859Omx0s1HKfH/Kp1BHkmIwv3/Kub
0ZV5/7dKNdNX2HNoE+MYS3D3YedePULdJhpqDqfU74kIK9Wgz915CGAkRAgUU7Wn
SwqjiEtWEC882DXDgU37734KmaBzOg==
=9g7i
-----END PGP SIGNATURE-----

--Em4RoU0qJsbure8MCXd88jXeldPL3gwur--
