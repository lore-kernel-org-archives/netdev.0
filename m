From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: [Patch v2 5/5] drivers/net: support hdlc function for QE-UCC
Date: Thu, 2 Jun 2016 07:37:32 +0000
Message-ID: <1464853088.7659.21.camel@infinera.com>
References: <1464831901-15913-1-git-send-email-qiang.zhao@nxp.com>
	 <1464831901-15913-5-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"xiaobo.xie@nxp.com" <xiaobo.xie@nxp.com>
To: "oss@buserror.net" <oss@buserror.net>,
	"qiang.zhao@nxp.com" <qiang.zhao@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464831901-15913-5-git-send-email-qiang.zhao@nxp.com>
Content-Language: en-US
Content-ID: <811FE51A6C76974DA197180C26350375@infinera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-02 at 09:45 +0800, Zhao Qiang wrote:
> The driver add hdlc support for Freescale QUICC Engine.
> It support NMSI and TSA mode.
>=20
> Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
> ---
> Changes for v2:
> 	- remove useless code.
> 	- remove Unnecessary casts
> 	- return IRQ_NONE when there are no interrupt
> 	- remove Useless comments
>=20
> =A0MAINTAINERS=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0|=A0=A0=A0=A07 +
> =A0drivers/net/wan/Kconfig=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A011 +
> =A0drivers/net/wan/Makefile=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A0=A01 +
> =A0drivers/net/wan/fsl_ucc_hdlc.c | 1189 ++++++++++++++++++++++++++++=
++++++++++++
> =A0drivers/net/wan/fsl_ucc_hdlc.h |=A0=A0147 +++++
> =A0include/soc/fsl/qe/qe.h=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A0=A01 +
> =A0include/soc/fsl/qe/ucc_fast.h=A0=A0|=A0=A0=A021 +-
> =A07 files changed, 1375 insertions(+), 2 deletions(-)
> =A0create mode 100644 drivers/net/wan/fsl_ucc_hdlc.c
> =A0create mode 100644 drivers/net/wan/fsl_ucc_hdlc.h
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 74bbff3..bdada16 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4572,6 +4572,13 @@ F:	drivers/net/ethernet/freescale/gianfar*
> =A0X:	drivers/net/ethernet/freescale/gianfar_ptp.c
> =A0F:	Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> =A0
> +FREESCALE QUICC ENGINE UCC HDLC DRIVER
> +M:	Zhao Qiang <qiang.zhao@nxp.com>
> +L:	netdev@vger.kernel.org
> +L:	linuxppc-dev@lists.ozlabs.org
> +S:	Maintained
> +F:	drivers/net/wan/fsl_ucc_hdlc*
> +
> =A0FREESCALE QUICC ENGINE UCC UART DRIVER
> =A0M:	Timur Tabi <timur@tabi.org>
> =A0L:	linuxppc-dev@lists.ozlabs.org
> diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
> index a2fdd15..9e314b7 100644
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -280,6 +280,17 @@ config DSCC4
> =A0	=A0=A0To compile this driver as a module, choose M here: the
> =A0	=A0=A0module will be called dscc4.
> =A0
> +config FSL_UCC_HDLC
> +	tristate "Freescale QUICC Engine HDLC support"
> +	depends on HDLC
> +	depends on QUICC_ENGINE
> +	help
> +	=A0=A0Driver for Freescale QUICC Engine HDLC controller. The driver
> +	=A0=A0supports HDLC in NMSI and TDM mode.
> +
> +	=A0=A0To compile this driver as a module, choose M here: the
> +	=A0=A0module will be called fsl_ucc_hdlc.
> +
> =A0config DSCC4_PCISYNC
> =A0	bool "Etinc PCISYNC features"
> =A0	depends on DSCC4
> diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
> index c135ef4..25fec40 100644
> --- a/drivers/net/wan/Makefile
> +++ b/drivers/net/wan/Makefile
> @@ -32,6 +32,7 @@ obj-$(CONFIG_WANXL)		+=3D wanxl.o
> =A0obj-$(CONFIG_PCI200SYN)		+=3D pci200syn.o
> =A0obj-$(CONFIG_PC300TOO)		+=3D pc300too.o
> =A0obj-$(CONFIG_IXP4XX_HSS)	+=3D ixp4xx_hss.o
> +obj-$(CONFIG_FSL_UCC_HDLC)	+=3D fsl_ucc_hdlc.o
> =A0
> =A0clean-files :=3D wanxlfw.inc
> =A0$(obj)/wanxl.o:	$(obj)/wanxlfw.inc
> diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc=
_hdlc.c
> new file mode 100644
> index 0000000..f72634d
> --- /dev/null
> +++ b/drivers/net/wan/fsl_ucc_hdlc.c
> @@ -0,0 +1,1189 @@
> +/* Freescale QUICC Engine HDLC Device Driver
> + *
> + * Copyright 2016 Freescale Semiconductor Inc.
> + *
> + * This program is free software; you can redistribute=A0=A0it and/o=
r modify it
> + * under=A0=A0the terms of=A0=A0the GNU General=A0=A0Public License =
as published by the
> + * Free Software Foundation;=A0=A0either version 2 of the=A0=A0Licen=
se, or (at your
> + * option) any later version.
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/hdlc.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/irq.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/of_address.h>
> +#include <linux/of_irq.h>
> +#include <linux/of_platform.h>
> +#include <linux/platform_device.h>
> +#include <linux/sched.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/stddef.h>
> +#include <soc/fsl/qe/qe_tdm.h>
> +#include <uapi/linux/if_arp.h>
> +
> +#include "fsl_ucc_hdlc.h"
> +
> +#define DRV_DESC "Freescale QE UCC HDLC Driver"
> +#define DRV_NAME "ucc_hdlc"
> +
> +#define TDM_PPPOHT_SLIC_MAXIN
> +#define BROKEN_FRAME_INFO
> +
> +static struct ucc_tdm_info utdm_primary_info =3D {
> +	.uf_info =3D {
> +		.tsa =3D 0,
> +		.cdp =3D 0,
> +		.cds =3D 1,
> +		.ctsp =3D 1,
> +		.ctss =3D 1,
> +		.revd =3D 0,
> +		.urfs =3D 256,
> +		.utfs =3D 256,
> +		.urfet =3D 128,
> +		.urfset =3D 192,
> +		.utfet =3D 128,
> +		.utftt =3D 0x40,
> +		.ufpt =3D 256,
> +		.mode =3D UCC_FAST_PROTOCOL_MODE_HDLC,
> +		.ttx_trx =3D UCC_FAST_GUMR_TRANSPARENT_TTX_TRX_NORMAL,
> +		.tenc =3D UCC_FAST_TX_ENCODING_NRZ,
> +		.renc =3D UCC_FAST_RX_ENCODING_NRZ,
> +		.tcrc =3D UCC_FAST_16_BIT_CRC,
> +		.synl =3D UCC_FAST_SYNC_LEN_NOT_USED,
> +	},
> +
> +	.si_info =3D {
> +#ifdef TDM_PPPOHT_SLIC_MAXIN
> +		.simr_rfsd =3D 1,
> +		.simr_tfsd =3D 2,
> +#else
> +		.simr_rfsd =3D 0,
> +		.simr_tfsd =3D 0,
> +#endif
> +		.simr_crt =3D 0,
> +		.simr_sl =3D 0,
> +		.simr_ce =3D 1,
> +		.simr_fe =3D 1,
> +		.simr_gm =3D 0,
> +	},
> +};
> +
> +static struct ucc_tdm_info utdm_info[MAX_HDLC_NUM];
> +
> +static int uhdlc_init(struct ucc_hdlc_private *priv)
> +{
> +	struct ucc_tdm_info *ut_info;
> +	struct ucc_fast_info *uf_info;
> +	u32 cecr_subblock;
> +	u16 bd_status;
> +	int ret, i;
> +	void *bd_buffer;
> +	dma_addr_t bd_dma_addr;
> +	u32 riptr;
> +	u32 tiptr;
> +	u32 gumr;
> +
> +	ut_info =3D priv->ut_info;
> +	uf_info =3D &ut_info->uf_info;
> +
> +	if (priv->tsa) {
> +		uf_info->tsa =3D 1;
> +		uf_info->ctsp =3D 1;
> +	}
> +	uf_info->uccm_mask =3D ((UCC_HDLC_UCCE_RXB | UCC_HDLC_UCCE_RXF |
> +				UCC_HDLC_UCCE_TXB) << 16);
> +
> +	ret =3D ucc_fast_init(uf_info, &priv->uccf);
> +	if (ret) {
> +		dev_err(priv->dev, "Failed to init uccf.");
> +		return ret;
> +	}
> +
> +	priv->uf_regs =3D priv->uccf->uf_regs;
> +	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
> +
> +	/* Loopback mode */
> +	if (priv->loopback) {
> +		dev_info(priv->dev, "Loopback Mode\n");
> +		gumr =3D ioread32be(&priv->uf_regs->gumr);
> +		gumr |=3D (UCC_FAST_GUMR_LOOPBACK | UCC_FAST_GUMR_CDS |
> +			=A0UCC_FAST_GUMR_TCI);
> +		gumr &=3D ~(UCC_FAST_GUMR_CTSP | UCC_FAST_GUMR_RSYN);
> +		iowrite32be(gumr, &priv->uf_regs->gumr);
> +	}
> +
> +	/* Initialize SI */
> +	if (priv->tsa)
> +		ucc_tdm_init(priv->utdm, priv->ut_info);
> +
> +	/* Write to QE CECR, UCCx channel to Stop Transmission */
> +	cecr_subblock =3D ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
> +	ret =3D qe_issue_cmd(QE_STOP_TX, cecr_subblock,
> +			=A0=A0=A0QE_CR_PROTOCOL_UNSPECIFIED, 0);
> +
> +	/* Set UPSMR normal mode (need fixed)*/
> +	iowrite32be(0, &priv->uf_regs->upsmr);
> +
> +	priv->rx_ring_size =3D RX_BD_RING_LEN;
> +	priv->tx_ring_size =3D TX_BD_RING_LEN;
> +	/* Alloc Rx BD */
> +	priv->rx_bd_base =3D dma_alloc_coherent(priv->dev,
> +			RX_BD_RING_LEN * sizeof(struct qe_bd *),
> +			&priv->dma_rx_bd, GFP_KERNEL);
> +
> +	if (!priv->rx_bd_base) {
> +		dev_err(priv->dev, "Cannot allocate MURAM memory for RxBDs\n");
> +		ret =3D -ENOMEM;
> +		goto rxbd_alloc_error;
> +	}
> +
> +	/* Alloc Tx BD */
> +	priv->tx_bd_base =3D dma_alloc_coherent(priv->dev,
> +			TX_BD_RING_LEN * sizeof(struct qe_bd *),
> +			&priv->dma_tx_bd, GFP_KERNEL);
> +
> +	if (!priv->tx_bd_base) {
> +		dev_err(priv->dev, "Cannot allocate MURAM memory for TxBDs\n");
> +		ret =3D -ENOMEM;
> +		goto txbd_alloc_error;
> +	}
> +
> +	/* Alloc parameter ram for ucc hdlc */
> +	priv->ucc_pram_offset =3D qe_muram_alloc(sizeof(priv->ucc_pram),
> +				ALIGNMENT_OF_UCC_HDLC_PRAM);
> +
> +	if (priv->ucc_pram_offset < 0) {
> +		dev_err(priv->dev, "Can not allocate MURAM for hdlc prameter.\n");
> +		ret =3D -ENOMEM;
> +		goto pram_alloc_error;
> +	}
> +
> +	priv->rx_skbuff =3D kzalloc(priv->rx_ring_size * sizeof(*priv->rx_s=
kbuff),
> +				=A0=A0GFP_KERNEL);
> +	if (!priv->rx_skbuff)
> +		goto rx_skb_alloc_error;
> +
> +	priv->tx_skbuff =3D kzalloc(priv->tx_ring_size * sizeof(*priv->tx_s=
kbuff),
> +				=A0=A0GFP_KERNEL);
> +	if (!priv->tx_skbuff)
> +		goto tx_skb_alloc_error;
> +
> +	priv->skb_curtx =3D 0;
> +	priv->skb_dirtytx =3D 0;
> +	priv->curtx_bd =3D priv->tx_bd_base;
> +	priv->dirty_tx =3D priv->tx_bd_base;
> +	priv->currx_bd =3D priv->rx_bd_base;
> +	priv->currx_bdnum =3D 0;
> +
> +	/* init parameter base */
> +	cecr_subblock =3D ucc_fast_get_qe_cr_subblock(uf_info->ucc_num);
> +	ret =3D qe_issue_cmd(QE_ASSIGN_PAGE_TO_DEVICE, cecr_subblock,
> +			=A0=A0=A0QE_CR_PROTOCOL_UNSPECIFIED, priv->ucc_pram_offset);
> +
> +	priv->ucc_pram =3D (struct ucc_hdlc_param __iomem *)
> +					qe_muram_addr(priv->ucc_pram_offset);
> +
> +	/* Zero out parameter ram */
> +	memset_io(priv->ucc_pram, 0, sizeof(struct ucc_hdlc_param));
> +
> +	/* Alloc riptr, tiptr */
> +	riptr =3D qe_muram_alloc(32, 32);
> +	if (riptr < 0) {
> +		dev_err(priv->dev, "Cannot allocate MURAM mem for Receive internal=
 temp data pointer\n");
> +		ret =3D -ENOMEM;
> +		goto riptr_alloc_error;
> +	}
> +
> +	tiptr =3D qe_muram_alloc(32, 32);
> +	if (tiptr < 0) {
> +		dev_err(priv->dev, "Cannot allocate MURAM mem for Transmit interna=
l temp data pointer\n");
> +		ret =3D -ENOMEM;
> +		goto tiptr_alloc_error;
> +	}
> +
> +	/* Set RIPTR, TIPTR */
> +	iowrite16be(riptr, &priv->ucc_pram->riptr);
> +	iowrite16be(tiptr, &priv->ucc_pram->tiptr);
> +
> +	/* Set MRBLR */
> +	iowrite16be(MAX_RX_BUF_LENGTH, &priv->ucc_pram->mrblr);
> +
> +	/* Set RBASE, TBASE */
> +	iowrite32be(priv->dma_rx_bd, &priv->ucc_pram->rbase);
> +	iowrite32be(priv->dma_tx_bd, &priv->ucc_pram->tbase);
> +
> +	/* Set RSTATE, TSTATE */
> +	iowrite32be(BMR_GBL | BMR_BIG_ENDIAN, &priv->ucc_pram->rstate);
> +	iowrite32be(BMR_GBL | BMR_BIG_ENDIAN, &priv->ucc_pram->tstate);
> +
> +	/* Set C_MASK, C_PRES for 16bit CRC */
> +	iowrite32be(CRC_16BIT_MASK, &priv->ucc_pram->c_mask);
> +	iowrite32be(CRC_16BIT_PRES, &priv->ucc_pram->c_pres);
> +
> +	iowrite16be(MAX_FRAME_LENGTH, &priv->ucc_pram->mflr);
> +	iowrite16be(DEFAULT_RFTHR, &priv->ucc_pram->rfthr);
> +	iowrite16be(DEFAULT_RFTHR, &priv->ucc_pram->rfcnt);
> +	iowrite16be(DEFAULT_ADDR_MASK, &priv->ucc_pram->hmask);
> +	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr1);
> +	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr2);
> +	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr3);
> +	iowrite16be(DEFAULT_HDLC_ADDR, &priv->ucc_pram->haddr4);
> +
> +	/* Get BD buffer */
> +	bd_buffer =3D dma_alloc_coherent(priv->dev,
> +				=A0=A0=A0=A0=A0=A0=A0(RX_BD_RING_LEN + TX_BD_RING_LEN) *
> +				=A0=A0=A0=A0=A0=A0=A0MAX_RX_BUF_LENGTH,
> +				=A0=A0=A0=A0=A0=A0=A0&bd_dma_addr, GFP_KERNEL);
> +
> +	if (!bd_buffer) {
> +		dev_err(priv->dev, "Could not allocate buffer descriptors\n");
> +		ret =3D -ENOMEM;
> +		goto bd_alloc_error;
> +	}
> +
> +	memset(bd_buffer, 0, (RX_BD_RING_LEN + TX_BD_RING_LEN)
> +			* MAX_RX_BUF_LENGTH);
> +
> +	priv->rx_buffer =3D bd_buffer;
> +	priv->tx_buffer =3D bd_buffer + RX_BD_RING_LEN * MAX_RX_BUF_LENGTH;
> +
> +	priv->dma_rx_addr =3D bd_dma_addr;
> +	priv->dma_tx_addr =3D bd_dma_addr + RX_BD_RING_LEN * MAX_RX_BUF_LEN=
GTH;
> +
> +	for (i =3D 0; i < RX_BD_RING_LEN; i++) {
> +		if (i < (RX_BD_RING_LEN - 1))
> +			bd_status =3D R_E_S | R_I_S;
> +		else
> +			bd_status =3D R_E_S | R_I_S | R_W_S;
> +
> +		iowrite16be(bd_status, &priv->rx_bd_base[i].status);
> +		iowrite32be(priv->dma_rx_addr + i * MAX_RX_BUF_LENGTH,
> +			=A0=A0=A0=A0&priv->rx_bd_base[i].buf);
> +	}
> +
> +	for (i =3D 0; i < TX_BD_RING_LEN; i++) {
> +		if (i < (TX_BD_RING_LEN - 1))
> +			bd_status =3D=A0=A0T_I_S | T_TC_S;
> +		else
> +			bd_status =3D=A0=A0T_I_S | T_TC_S | T_W_S;
> +
> +		iowrite16be(bd_status, &priv->tx_bd_base[i].status);
> +		iowrite32be(priv->dma_tx_addr + i * MAX_RX_BUF_LENGTH,
> +			=A0=A0=A0=A0&priv->tx_bd_base[i].buf);
> +	}
> +
> +	return 0;
> +
> +bd_alloc_error:
> +	qe_muram_free(tiptr);
> +tiptr_alloc_error:
> +	qe_muram_free(riptr);
> +riptr_alloc_error:
> +	kfree(priv->tx_skbuff);
> +tx_skb_alloc_error:
> +	kfree(priv->rx_skbuff);
> +rx_skb_alloc_error:
> +	qe_muram_free(priv->ucc_pram_offset);
> +pram_alloc_error:
> +	dma_free_coherent(priv->dev,
> +			=A0=A0TX_BD_RING_LEN * sizeof(struct qe_bd),
> +			=A0=A0priv->tx_bd_base, priv->dma_tx_bd);
> +txbd_alloc_error:
> +	dma_free_coherent(priv->dev,
> +			=A0=A0RX_BD_RING_LEN * sizeof(struct qe_bd),
> +			=A0=A0priv->rx_bd_base, priv->dma_rx_bd);
> +rxbd_alloc_error:
> +	ucc_fast_free(priv->uccf);
> +
> +	return ret;
> +}
> +
> +static netdev_tx_t ucc_hdlc_tx(struct sk_buff *skb, struct net_devic=
e *dev)
> +{
> +	hdlc_device *hdlc =3D dev_to_hdlc(dev);
> +	struct ucc_hdlc_private *priv =3D (struct ucc_hdlc_private *)hdlc->=
priv;
> +	struct qe_bd __iomem *bd;
> +	u16 bd_status;
> +	unsigned long flags;
> +	u8 *send_buf;
> +	int i;
> +	u16 *proto_head;
> +
> +	switch (dev->type) {
> +	case ARPHRD_RAWHDLC:
> +		if (skb_headroom(skb) < HDLC_HEAD_LEN) {
> +			dev->stats.tx_dropped++;
> +			dev_kfree_skb(skb);
> +			netdev_err(dev, "No enough space for hdlc head\n");
> +			return -ENOMEM;
> +		}
> +
> +		skb_push(skb, HDLC_HEAD_LEN);
> +
> +		proto_head =3D (u16 *)skb->data;
> +		*proto_head =3D htons(DEFAULT_HDLC_HEAD);
> +
> +		dev->stats.tx_bytes +=3D skb->len;
> +		break;
> +
> +	case ARPHRD_PPP:
> +		proto_head =3D (u16 *)skb->data;
> +		if (*proto_head !=3D htons(DEFAULT_PPP_HEAD)) {
> +			dev->stats.tx_dropped++;
> +			dev_kfree_skb(skb);
> +			netdev_err(dev, "Wrong ppp header\n");
> +			return -ENOMEM;
> +		}
> +
> +		dev->stats.tx_bytes +=3D skb->len;
> +		break;
> +
> +	default:
> +		dev->stats.tx_dropped++;
> +		dev_kfree_skb(skb);
> +		return -ENOMEM;
> +	}
> +
> +	pr_info("Tx data skb->len:%d ", skb->len);
> +	send_buf =3D (u8 *)skb->data;
> +	pr_info("\nTransmitted data:\n");
> +	for (i =3D 0; i < 16; i++) {
> +		if (i =3D=3D skb->len)
> +			pr_info("++++");
> +		else
> +		pr_info("%02x\n", send_buf[i]);
> +	}
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	/* Start from the next BD that should be filled */
> +	bd =3D priv->curtx_bd;
> +	bd_status =3D ioread16be(&bd->status);
> +	/* Save the skb pointer so we can free it later */
> +	priv->tx_skbuff[priv->skb_curtx] =3D skb;
> +
> +	/* Update the current skb pointer (wrapping if this was the last) *=
/
> +	priv->skb_curtx =3D
> +	=A0=A0=A0=A0(priv->skb_curtx + 1) & TX_RING_MOD_MASK(TX_BD_RING_LEN=
);
> +
> +	/* copy skb data to tx buffer for sdma processing */
> +	memcpy(priv->tx_buffer + (be32_to_cpu(bd->buf) - priv->dma_tx_addr)=
,
> +	=A0=A0=A0=A0=A0=A0=A0skb->data, skb->len);
> +
> +	/* set bd status and length */
> +	bd_status =3D (bd_status & T_W_S) | T_R_S | T_I_S | T_L_S | T_TC_S;
> +
> +	iowrite16be(bd_status, &bd->status);
> +	iowrite16be(skb->len, &bd->length);

Should not status write be after length as status write will trigger th=
e transmit?


Also, RX/TX error handling is very basic. There is only RX/TX errors bu=
t no
detail such as overrun/frame, carrier, crc etc.=A0
These are very useful when trying to find the cause of an RX/TX error, =
especially
during devlopment.

=A0Jocke
