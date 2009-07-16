From: Trilok Soni <soni.trilok@gmail.com>
Subject: Re: [PATCH] Add mac driver for w90p910
Date: Thu, 16 Jul 2009 23:12:00 +0530
Message-ID: <5d5443650907161042g428afc74jf40f5daf71db7620@mail.gmail.com>
References: <4A5F2329.9090901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	"Eric.miao" <eric.y.miao@gmail.com>
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <4A5F2329.9090901@gmail.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Hi Wan,


> diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
> index 811a3cc..303171f 100644
> --- a/drivers/net/arm/Makefile
> +++ b/drivers/net/arm/Makefile
> @@ -11,3 +11,4 @@ obj-$(CONFIG_ARM_AT91_ETHER) =A0+=3D at91_ether.o
> =A0obj-$(CONFIG_ARM_KS8695_ETHER) +=3D ks8695net.o
> =A0obj-$(CONFIG_EP93XX_ETH) =A0 =A0 =A0 +=3D ep93xx_eth.o
> =A0obj-$(CONFIG_IXP4XX_ETH) =A0 =A0 =A0 +=3D ixp4xx_eth.o
> +obj-$(CONFIG_W90P910_ETH) =A0 =A0 =A0+=3D w90p910_ether.o
> diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_et=
her.c
> new file mode 100644
> index 0000000..616fb79
> --- /dev/null
> +++ b/drivers/net/arm/w90p910_ether.c
> @@ -0,0 +1,1105 @@
> +/*
> + * Copyright (c) 2008-2009 Nuvoton technology corporation.
> + *
> + * Wan ZongShun <mcuos.com@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation;version 2 of the License.
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/mii.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/ethtool.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +
> +#define DRV_MODULE_NAME =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"w90p910-emc"
> +#define DRV_MODULE_VERSION =A0 =A0 "0.1"
> +
> +/* Ethernet MAC Registers */
> +#define REG_CAMCMR =A0 =A0 =A0 =A0 =A0 =A0 0x00
> +#define REG_CAMEN =A0 =A0 =A0 =A0 =A0 =A0 =A00x04
> +#define REG_CAMM_BASE =A0 =A0 =A0 =A0 =A00x08
> +#define REG_CAML_BASE =A0 =A0 =A0 =A0 =A00x0c
> +#define REG_TXDLSA =A0 =A0 =A0 =A0 =A0 =A0 0x88
> +#define REG_RXDLSA =A0 =A0 =A0 =A0 =A0 =A0 0x8C
> +#define REG_MCMDR =A0 =A0 =A0 =A0 =A0 =A0 =A00x90
> +#define REG_MIID =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x94
> +#define REG_MIIDA =A0 =A0 =A0 =A0 =A0 =A0 =A00x98
> +#define REG_FFTCR =A0 =A0 =A0 =A0 =A0 =A0 =A00x9C
> +#define REG_TSDR =A0 =A0 =A0 =A0 =A0 =A0 =A0 0xa0
> +#define REG_RSDR =A0 =A0 =A0 =A0 =A0 =A0 =A0 0xa4
> +#define REG_DMARFC =A0 =A0 =A0 =A0 =A0 =A0 0xa8
> +#define REG_MIEN =A0 =A0 =A0 =A0 =A0 =A0 =A0 0xac
> +#define REG_MISTA =A0 =A0 =A0 =A0 =A0 =A0 =A00xb0
> +#define REG_CTXDSA =A0 =A0 =A0 =A0 =A0 =A0 0xcc
> +#define REG_CTXBSA =A0 =A0 =A0 =A0 =A0 =A0 0xd0
> +#define REG_CRXDSA =A0 =A0 =A0 =A0 =A0 =A0 0xd4
> +#define REG_CRXBSA =A0 =A0 =A0 =A0 =A0 =A0 0xd8
> +
> +/* mac controller bit */
> +#define MCMDR_RXON =A0 =A0 =A0 =A0 =A0 =A0 0x01
> +#define MCMDR_ACP =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 3)
> +#define MCMDR_SPCRC =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 5)
> +#define MCMDR_TXON =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 8)
> +#define MCMDR_FDUP =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 18)
> +#define MCMDR_ENMDC =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 19)
> +#define MCMDR_OPMOD =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 20)
> +#define SWR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 24)
> +
> +/* cam command regiser */
> +#define CAMCMR_AUP =A0 =A0 =A0 =A0 =A0 =A0 0x01
> +#define CAMCMR_AMP =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 1)
> +#define CAMCMR_ABP =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 2)
> +#define CAMCMR_CCAM =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 3)
> +#define CAMCMR_ECMP =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 4)
> +#define CAM0EN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x01
> +
> +/* mac mii controller bit */
> +#define MDCCR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x0a << 20)
> +#define PHYAD =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 8)
> +#define PHYWR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 16)
> +#define PHYBUSY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << =
17)
> +#define PHYPRESP =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 18)
> +#define CAM_ENTRY_SIZE =A0 =A0 =A0 =A0 0x08
> +
> +/* rx and tx status */
> +#define TXDS_TXCP =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 19)
> +#define RXDS_CRCE =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 17)
> +#define RXDS_PTLE =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 19)
> +#define RXDS_RXGD =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 20)
> +#define RXDS_ALIE =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 21)
> +#define RXDS_RP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << =
22)
> +
> +/* mac interrupt status*/
> +#define MISTA_EXDEF =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 19)
> +#define MISTA_TXBERR =A0 =A0 =A0 =A0 =A0 (0x01 << 24)
> +#define MISTA_TDU =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 23)
> +#define MISTA_RDU =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 10)
> +#define MISTA_RXBERR =A0 =A0 =A0 =A0 =A0 (0x01 << 11)
> +
> +#define ENSTART =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x01
> +#define ENRXINTR =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x01
> +#define ENRXGD =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 4)
> +#define ENRXBERR =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 11)
> +#define ENTXINTR =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 16)
> +#define ENTXCP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 18)
> +#define ENTXABT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << =
21)
> +#define ENTXBERR =A0 =A0 =A0 =A0 =A0 =A0 =A0 (0x01 << 24)
> +#define ENMDC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 19)
> +#define PHYBUSY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << =
17)
> +#define MDCCR_VAL =A0 =A0 =A0 =A0 =A0 =A0 =A00xa00000
> +
> +/* rx and tx owner bit */
> +#define RX_OWEN_DMA =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 31)
> +#define RX_OWEN_CPU =A0 =A0 =A0 =A0 =A0 =A0(~(0x03 << 30))
> +#define TX_OWEN_DMA =A0 =A0 =A0 =A0 =A0 =A0(0x01 << 31)
> +#define TX_OWEN_CPU =A0 =A0 =A0 =A0 =A0 =A0(~(0x01 << 31))
> +
> +/* tx frame desc controller bit */
> +#define MACTXINTEN =A0 =A0 =A0 =A0 =A0 =A0 0x04
> +#define CRCMODE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x02
> +#define PADDINGMODE =A0 =A0 =A0 =A0 =A0 =A00x01
> +
> +/* fftcr controller bit */
> +#define TXTHD =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x03 << 8)
> +#define BLENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x01 << =
20)
> +
> +/* global setting for driver */
> +#define RX_DESC_SIZE =A0 =A0 =A0 =A0 =A0 50
> +#define TX_DESC_SIZE =A0 =A0 =A0 =A0 =A0 10
> +#define MAX_RBUFF_SZ =A0 =A0 =A0 =A0 =A0 0x600
> +#define MAX_TBUFF_SZ =A0 =A0 =A0 =A0 =A0 0x600
> +#define TX_TIMEOUT =A0 =A0 =A0 =A0 =A0 =A0 50
> +#define DELAY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01000
> +#define CAM0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x0
> +
> +static int w90p910_mdio_read(struct net_device *dev, int phy_id, int reg=
);
> +
> +struct w90p910_rxbd {
> + =A0 =A0 =A0 unsigned int sl;
> + =A0 =A0 =A0 unsigned int buffer;
> + =A0 =A0 =A0 unsigned int reserved;
> + =A0 =A0 =A0 unsigned int next;
> +};
> +
> +struct w90p910_txbd {
> + =A0 =A0 =A0 unsigned int mode;
> + =A0 =A0 =A0 unsigned int buffer;
> + =A0 =A0 =A0 unsigned int sl;
> + =A0 =A0 =A0 unsigned int next;
> +};
> +
> +struct recv_pdesc {
> + =A0 =A0 =A0 struct w90p910_rxbd desclist[RX_DESC_SIZE];
> + =A0 =A0 =A0 char recv_buf[RX_DESC_SIZE][MAX_RBUFF_SZ];
> +};
> +
> +struct tran_pdesc {
> + =A0 =A0 =A0 struct w90p910_txbd desclist[TX_DESC_SIZE];
> + =A0 =A0 =A0 char tran_buf[RX_DESC_SIZE][MAX_TBUFF_SZ];
> +};
> +
> +struct =A0w90p910_ether {
> + =A0 =A0 =A0 struct recv_pdesc *rdesc;
> + =A0 =A0 =A0 struct recv_pdesc *rdesc_phys;
> + =A0 =A0 =A0 struct tran_pdesc *tdesc;
> + =A0 =A0 =A0 struct tran_pdesc *tdesc_phys;
> + =A0 =A0 =A0 struct net_device_stats stats;
> + =A0 =A0 =A0 struct platform_device *pdev;
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 struct clk *clk;
> + =A0 =A0 =A0 struct clk *rmiiclk;
> + =A0 =A0 =A0 struct mii_if_info mii;
> + =A0 =A0 =A0 struct timer_list check_timer;
> + =A0 =A0 =A0 void __iomem *reg;
> + =A0 =A0 =A0 unsigned int rxirq;
> + =A0 =A0 =A0 unsigned int txirq;
> + =A0 =A0 =A0 unsigned int cur_tx;
> + =A0 =A0 =A0 unsigned int cur_rx;
> + =A0 =A0 =A0 unsigned int finish_tx;
> + =A0 =A0 =A0 unsigned int rx_packets;
> + =A0 =A0 =A0 unsigned int rx_bytes;
> + =A0 =A0 =A0 unsigned int start_tx_ptr;
> + =A0 =A0 =A0 unsigned int start_rx_ptr;
> + =A0 =A0 =A0 unsigned int linkflag;
> + =A0 =A0 =A0 spinlock_t lock;

describe what lock protects.

> +};
> +

> +
> +static void w90p910_init_desc(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether;
> + =A0 =A0 =A0 struct w90p910_txbd =A0*tdesc, *tdesc_phys;
> + =A0 =A0 =A0 struct w90p910_rxbd =A0*rdesc, *rdesc_phys;
> + =A0 =A0 =A0 unsigned int i, j;
> +
> + =A0 =A0 =A0 ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 ether->tdesc =3D (struct tran_pdesc *)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_alloc_coherent(NULL, si=
zeof(struct tran_pdesc),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dma_addr_t=
 *) &ether->tdesc_phys, GFP_KERNEL);

no-need of casting I think.

> +
> + =A0 =A0 =A0 ether->rdesc =3D (struct recv_pdesc *)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_alloc_coherent(NULL, si=
zeof(struct recv_pdesc),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dma_addr_t=
 *) &ether->rdesc_phys, GFP_KERNEL);

Ditto.

> +
> + =A0 =A0 =A0 for (i =3D 0; i < TX_DESC_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc =3D &(ether->tdesc->desclist[i]);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 j =3D ((i + 1) / TX_DESC_SIZE);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (j !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc_phys =3D &(ether->tde=
sc_phys->desclist[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->start_tx_ptr =3D (un=
signed int)tdesc_phys;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc->next =3D (unsigned i=
nt)ether->start_tx_ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc_phys =3D &(ether->tde=
sc_phys->desclist[i+1]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc->next =3D (unsigned i=
nt)tdesc_phys;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc->buffer =3D (unsigned int)ether->tdes=
c_phys->tran_buf[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc->sl =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tdesc->mode =3D 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (i =3D 0; i < RX_DESC_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc =3D &(ether->rdesc->desclist[i]);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 j =3D ((i + 1) / RX_DESC_SIZE);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (j !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc_phys =3D &(ether->rde=
sc_phys->desclist[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->start_rx_ptr =3D (un=
signed int)rdesc_phys;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc->next =3D (unsigned i=
nt)ether->start_rx_ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc_phys =3D &(ether->rde=
sc_phys->desclist[i+1]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc->next =3D (unsigned i=
nt)rdesc_phys;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc->sl =3D RX_OWEN_DMA;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdesc->buffer =3D (unsigned int)ether->rdes=
c_phys->recv_buf[i];
> + =A0 =A0 =A0 =A0 }
> +}
> +
> +static void w90p910_set_fifo_threshold(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned int val;
> +
> + =A0 =A0 =A0 val =3D TXTHD | BLENGTH;
> + =A0 =A0 =A0 __raw_writel(val, ether->reg + REG_FFTCR);
> +}
> +
> +static void w90p910_return_default_idle(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned int val;
> +
> + =A0 =A0 =A0 val =3D __raw_readl(ether->reg + REG_MCMDR);
> + =A0 =A0 =A0 val |=3D SWR;
> + =A0 =A0 =A0 __raw_writel(val, ether->reg + REG_MCMDR);
> +}
> +
> +static void w90p910_trigger_rx(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 __raw_writel(ENSTART, ether->reg + REG_RSDR);
> +}
> +
> +static void w90p910_trigger_tx(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 __raw_writel(ENSTART, ether->reg + REG_TSDR);
> +}
> +
> +static void w90p910_enable_mac_interrupt(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned int val;
> +
> + =A0 =A0 =A0 val =3D ENTXINTR | ENRXINTR | ENRXGD | ENTXCP;
> + =A0 =A0 =A0 val |=3D ENTXBERR | ENRXBERR | ENTXABT;
> +
> + =A0 =A0 =A0 __raw_writel(val, ether->reg + REG_MIEN);
> +}


> +
> +static int set_mac_address(struct net_device *dev, void *addr)
> +{

how about naming it as w90p910_set_mac_address for consistency.

> + =A0 =A0 =A0 struct sockaddr *address =3D addr;
> +
> + =A0 =A0 =A0 if (!is_valid_ether_addr(address->sa_data))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EADDRNOTAVAIL;
> +
> + =A0 =A0 =A0 memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
> + =A0 =A0 =A0 w90p910_write_cam(dev, CAM0, dev->dev_addr);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +


> +
> +static int w90p910_ether_start_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 if (!(w90p910_send_frame(dev, skb->data, skb->len))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->skb =3D skb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_irq(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return -1;

better error code?


> +}
> +
> +static irqreturn_t w90p910_tx_interrupt(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether;
> + =A0 =A0 =A0 struct w90p910_txbd =A0*txbd;
> + =A0 =A0 =A0 struct platform_device *pdev;
> + =A0 =A0 =A0 struct tran_pdesc *tran_pdesc;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 unsigned int cur_entry, entry, status;
> +
> + =A0 =A0 =A0 dev =3D (struct net_device *)dev_id;

un-necessary casting.

> + =A0 =A0 =A0 ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 pdev =3D ether->pdev;
> +
> + =A0 =A0 =A0 spin_lock(&ether->lock);
> +
> + =A0 =A0 =A0 w90p910_get_and_clear_int(dev, &status);
> +
> + =A0 =A0 =A0 cur_entry =3D __raw_readl(ether->reg + REG_CTXDSA);
> +
> + =A0 =A0 =A0 tran_pdesc =3D ether->tdesc_phys;
> + =A0 =A0 =A0 entry =3D (unsigned int)(&tran_pdesc->desclist[ether->finis=
h_tx]);
> +
> + =A0 =A0 =A0 while (entry !=3D cur_entry) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 txbd =3D &ether->tdesc->desclist[ether->fin=
ish_tx];
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->finish_tx =3D (ether->finish_tx + 1)=
 % TX_DESC_SIZE;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (txbd->sl & TXDS_TXCP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->stats.tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->stats.tx_bytes +=3D =
txbd->sl & 0xFFFF;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ether->stats.tx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 txbd->sl =3D 0x0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 txbd->mode =3D 0x0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_queue_stopped(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (unsigned int)(&tran_pdesc->descl=
ist[ether->finish_tx]);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (status & MISTA_EXDEF) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "emc defer exceed inter=
rupt\n");
> + =A0 =A0 =A0 } else if (status & MISTA_TXBERR) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "emc bu=
s error interrupt\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w90p910_reset_mac(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (status & MISTA_TDU) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_q=
ueue_stopped(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 netif_wake_queue(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

indentation doesn't look correct.

> +
> + =A0 =A0 =A0 spin_unlock(&ether->lock);
> +
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
> +

> +
> +static irqreturn_t w90p910_rx_interrupt(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct w90p910_ether =A0*ether;
> + =A0 =A0 =A0 struct platform_device *pdev;
> + =A0 =A0 =A0 unsigned int status;
> +
> + =A0 =A0 =A0 dev =3D (struct net_device *)dev_id;

No need of casting.

> + =A0 =A0 =A0 ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 pdev =3D ether->pdev;
> +
> + =A0 =A0 =A0 spin_lock(&ether->lock);
> +
> + =A0 =A0 =A0 w90p910_get_and_clear_int(dev, &status);
> +
> + =A0 =A0 =A0 if (status & MISTA_RDU) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_rx(dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w90p910_trigger_rx(dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&ether->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_HANDLED;
> + =A0 =A0 =A0 } else if (status & MISTA_RXBERR) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "emc rx=
 bus error\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w90p910_reset_mac(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

indentation problem.

> +
> + =A0 =A0 =A0 netdev_rx(dev);
> + =A0 =A0 =A0 spin_unlock(&ether->lock);
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
> +
> +static int w90p910_ether_open(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether;
> + =A0 =A0 =A0 struct platform_device *pdev;
> +
> + =A0 =A0 =A0 ether =3D netdev_priv(dev);
> + =A0 =A0 =A0 pdev =3D ether->pdev;
> +
> + =A0 =A0 =A0 w90p910_reset_mac(dev);
> + =A0 =A0 =A0 w90p910_set_fifo_threshold(dev);
> + =A0 =A0 =A0 w90p910_set_curdest(dev);
> + =A0 =A0 =A0 w90p910_enable_cam(dev);
> + =A0 =A0 =A0 w90p910_enable_cam_command(dev);
> + =A0 =A0 =A0 w90p910_enable_mac_interrupt(dev);
> + =A0 =A0 =A0 w90p910_set_global_maccmd(dev);
> + =A0 =A0 =A0 w90p910_enable_rx(dev, 1);
> +
> + =A0 =A0 =A0 ether->rx_packets =3D 0x0;
> + =A0 =A0 =A0 ether->rx_bytes =3D 0x0;
> +
> + =A0 =A0 =A0 if (request_irq(ether->txirq, w90p910_tx_interrupt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 0x0, pdev->name, dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "register irq tx failed=
\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (request_irq(ether->rxirq, w90p910_rx_interrupt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 0x0, pdev->name, dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "register irq rx failed=
\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;

error path problem. You should do free_irq(ether->txirq);

> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mod_timer(&ether->check_timer, jiffies + msecs_to_jiffies(1=
000));
> + =A0 =A0 =A0 netif_start_queue(dev);
> + =A0 =A0 =A0 w90p910_trigger_rx(dev);
> +
> + =A0 =A0 =A0 dev_info(&pdev->dev, "%s is OPENED\n", dev->name);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +



> +
> +static int __devinit w90p910_ether_probe(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 struct w90p910_ether *ether;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct resource *res;
> + =A0 =A0 =A0 int error;
> +
> + =A0 =A0 =A0 dev =3D alloc_etherdev(sizeof(struct w90p910_ether));
> + =A0 =A0 =A0 if (!dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> + =A0 =A0 =A0 if (res =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to get I/O memo=
ry\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENXIO;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 res =3D request_mem_region(res->start, resource_size(res), =
pdev->name);
> + =A0 =A0 =A0 if (res =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to request I/O =
memory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 ether->reg =3D ioremap(res->start, resource_size(res));
> + =A0 =A0 =A0 if (ether->reg =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to remap I/O me=
mory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENXIO;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free_mem;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ether->txirq =3D platform_get_irq(pdev, 0);
> + =A0 =A0 =A0 if (ether->txirq < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to get ether tx=
 irq\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENXIO;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free_io;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ether->rxirq =3D platform_get_irq(pdev, 1);
> + =A0 =A0 =A0 if (ether->rxirq < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to get ether rx=
 irq\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENXIO;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free_txirq;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 platform_set_drvdata(pdev, dev);
> +
> + =A0 =A0 =A0 ether->clk =3D clk_get(&pdev->dev, NULL);
> + =A0 =A0 =A0 if (IS_ERR(ether->clk)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to get ether cl=
ock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D PTR_ERR(ether->clk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_free_rxirq;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ether->rmiiclk =3D clk_get(&pdev->dev, "RMII");
> + =A0 =A0 =A0 if (IS_ERR(ether->rmiiclk)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "failed to get ether cl=
ock\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D PTR_ERR(ether->rmiiclk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_put_clk;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ether->pdev =3D pdev;
> +
> + =A0 =A0 =A0 w90p910_ether_setup(dev);
> +
> + =A0 =A0 =A0 error =3D register_netdev(dev);
> + =A0 =A0 =A0 if (error !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "Regiter EMC w90p910 FA=
ILED\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto failed_put_rmiiclk;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +failed_put_rmiiclk:
> + =A0 =A0 =A0 clk_put(ether->rmiiclk);
> +failed_put_clk:
> + =A0 =A0 =A0 clk_put(ether->clk);
> +failed_free_rxirq:
> + =A0 =A0 =A0 free_irq(ether->rxirq, pdev);
> + =A0 =A0 =A0 platform_set_drvdata(pdev, NULL);
> +failed_free_txirq:
> + =A0 =A0 =A0 free_irq(ether->txirq, pdev);
> +failed_free_io:
> + =A0 =A0 =A0 iounmap(ether->reg);
> +failed_free_mem:
> + =A0 =A0 =A0 release_mem_region(res->start, resource_size(res));
> +failed_free:
> + =A0 =A0 =A0 free_netdev(dev);
> + =A0 =A0 =A0 return error;
> +}
> +
> +static int __devexit w90p910_ether_remove(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
> + =A0 =A0 =A0 struct w90p910_ether *ether =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 unregister_netdev(dev);
> + =A0 =A0 =A0 clk_put(ether->rmiiclk);
> + =A0 =A0 =A0 clk_put(ether->clk);
> + =A0 =A0 =A0 del_timer_sync(&ether->check_timer);
> + =A0 =A0 =A0 platform_set_drvdata(pdev, NULL);
> + =A0 =A0 =A0 free_netdev(dev);

I don't see free_irq for two irqs.


> + =A0 =A0 =A0 return 0;
> +}



-- =

---Trilok Soni
http://triloksoni.wordpress.com
http://www.linkedin.com/in/triloksoni

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
