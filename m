From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: FW: [PATCH v2 13/13] net: add Xilinx ll_temac device driver
Date: Mon, 23 Mar 2009 19:15:15 -0600
Message-ID: <fa686aa40903231815x3313bdc3s6119d51c3dfcfd3b@mail.gmail.com>
References: <20090323180935.4ACCE13F0063@mail126-va3.bigfish.com>
	 <9e6f3dfd0903231732hdc49acej50f8ff0cb895bc2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Neuendorffer <stephen.neuendorffer@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>
To: John Williams <jwilliams@itee.uq.edu.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:44400 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbZCXBPR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 21:15:17 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2367943yxl.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 18:15:15 -0700 (PDT)
In-Reply-To: <9e6f3dfd0903231732hdc49acej50f8ff0cb895bc2f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding netdev and linuxppc mailing lists to the CC: list)

On Mon, Mar 23, 2009 at 6:32 PM, John Williams <jwilliams@itee.uq.edu.a=
u> wrote:
> On Tue, Mar 24, 2009 at 4:09 AM, Stephen Neuendorffer <stephen.neuend=
orffer@xilinx.com> wrote:
>> From: Grant Likely <grant.likely@secretlab.ca>
>>>
>>> This patch adds support for the Xilinx ll_temac 10/100/1000 Etherne=
t
>>> device.  The ll_temac ipcore is typically used on Xilinx Virtex and
>>> Spartan designs attached to either a PowerPC 4xx or Microblaze
>>> processor.
>>>
>>> At the present moment, this driver only works with Virtex5 PowerPC
>>> designs because it assumes DCR is used to access the DMA registers.
>>> However, the low level access to DMA registers is abstracted and
>>> it should be easy to adapt for the other implementations.
>>
>> Don't know if you saw this, but 'only supports V5' is something that
>> reasonably directly affects you...
>
> Thanks for the heads up. =A0The DCR support seems reasonably easy to
> factor out for PLB accesses to SDMA regs. =A0I would probably be happ=
y
> enough to let it get merged then we submit patches against it later.
>
> Grant, any thoughts on this? =A0Doesn't look like a great deal of wor=
k
> to support PLB SDMA control?

It really shouldn't be much work at all.  It is on my todo list, but
any help would be appreciated.

Although I'm also thinking about going a step farther and factoring
out the LL code into a separate driver entirely.

g.

>
> Cheers,
>
> John
>
>
>>
>> -----Original Message-----
>> From: linuxppc-dev-bounces+stephen.neuendorffer=3Dxilinx.com@ozlabs.=
org
>> [mailto:linuxppc-dev-bounces+stephen.neuendorffer=3Dxilinx.com@ozlab=
s.org]
>> On Behalf Of Grant Likely
>> Sent: Saturday, March 21, 2009 3:29 PM
>> To: linuxppc-dev@ozlabs.org; netdev@vger.kernel.org; olof@lixom.net
>> Cc: afleming@freescale.com; davem@davemloft.net
>> Subject: [PATCH v2 13/13] net: add Xilinx ll_temac device driver
>>
>> I'm posting this driver now as an RFC. =A0There are still some thing=
s that
>> need to be tightened up, but it does appear to be stable.
>>
>> Derived from driver code written by Yoshio Kashiwagi and David H. Ly=
nch
>> Jr.
>>
>> CC: Yoshio Kashiwagi <kashiwagi@co-nss.co.jp>
>> CC: David H. Lynch Jr. <dhlii@dlasys.net>
>> CC: John Linn <john.linn@xilinx.com>
>> CC: John Bonesio <john.bonesio@xilinx.com>
>> CC: David DeBonis <ddeboni@xilinx.com>
>> CC: Wilson Yang <wyang@xilinx.com>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>> ---
>>
>> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08
>> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02
>> =A0drivers/net/xilinx_temac.c =A0 =A0 =A0| =A0970
>> +++++++++++++++++++++++++++++++++++++++
>> =A0drivers/net/xilinx_temac.h =A0 =A0 =A0| =A0374 +++++++++++++++
>> =A0drivers/net/xilinx_temac_mdio.c | =A0119 +++++
>> =A05 files changed, 1473 insertions(+), 0 deletions(-)
>> =A0create mode 100644 drivers/net/xilinx_temac.c
>> =A0create mode 100644 drivers/net/xilinx_temac.h
>> =A0create mode 100644 drivers/net/xilinx_temac_mdio.c
>>
>>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index 435e2e3..29d6c1f 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -2321,6 +2321,14 @@ config MV643XX_ETH
>> =A0 =A0 =A0 =A0 =A0Some boards that use the Discovery chipset are th=
e Momenco
>> =A0 =A0 =A0 =A0 =A0Ocelot C and Jaguar ATX and Pegasos II.
>>
>> +config XILINX_TEMAC
>> + =A0 =A0 =A0 tristate "Xilinx TEMAC 10/100/1000 Ethernet MAC driver=
"
>> + =A0 =A0 =A0 select PHYLIB
>> + =A0 =A0 =A0 depends on PPC
>> + =A0 =A0 =A0 help
>> + =A0 =A0 =A0 =A0 This driver supports the Xilinx 10/100/1000 LocalL=
ink TEMAC
>> + =A0 =A0 =A0 =A0 device found in Virtex FPGAs
>> +
>> =A0config QLA3XXX
>> =A0 =A0 =A0 =A0tristate "QLogic QLA3XXX Network Driver Support"
>> =A0 =A0 =A0 =A0depends on PCI
>> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
>> index 471baaf..c7b4dd9 100644
>> --- a/drivers/net/Makefile
>> +++ b/drivers/net/Makefile
>> @@ -132,6 +132,8 @@ obj-$(CONFIG_AX88796) +=3D ax88796.o
>>
>> =A0obj-$(CONFIG_TSI108_ETH) +=3D tsi108_eth.o
>> =A0obj-$(CONFIG_MV643XX_ETH) +=3D mv643xx_eth.o
>> +xilinxtemac-objs :=3D xilinx_temac.o xilinx_temac_mdio.o
>> +obj-$(CONFIG_XILINX_TEMAC) +=3D xilinxtemac.o
>> =A0obj-$(CONFIG_QLA3XXX) +=3D qla3xxx.o
>> =A0obj-$(CONFIG_QLGE) +=3D qlge/
>>
>> diff --git a/drivers/net/xilinx_temac.c b/drivers/net/xilinx_temac.c
>> new file mode 100644
>> index 0000000..d778a55
>> --- /dev/null
>> +++ b/drivers/net/xilinx_temac.c
>> @@ -0,0 +1,970 @@
>> +/*
>> + * Driver for Xilinx TEMAC Ethernet device
>> + *
>> + * Copyright (c) 2008 Nissin Systems Co., Ltd., =A0Yoshio Kashiwagi
>> + * Copyright (c) 2005-2008 DLA Systems, =A0David H. Lynch Jr.
>> <dhlii@dlasys.net>
>> + * Copyright (c) 2008-2009 Secret Lab Technologies Ltd.
>> + *
>> + * This is a driver for the Xilinx ll_temac ipcore which is often u=
sed
>> + * in the Virtex and Spartan series of chips.
>> + *
>> + * Notes:
>> + * - The ll_temac hardware uses indirect access for many of the TEM=
AC
>> + * =A0 registers, include the MDIO bus. =A0However, indirect access=
 to MDIO
>> + * =A0 registers take considerably more clock cycles than to TEMAC
>> registers.
>> + * =A0 MDIO accesses are long, so threads doing them should probabl=
y
>> sleep
>> + * =A0 rather than busywait. =A0However, since only one indirect ac=
cess can
>> be
>> + * =A0 in progress at any given time, that means that *all* indirec=
t
>> accesses
>> + * =A0 could end up sleeping (to wait for an MDIO access to complet=
e).
>> + * =A0 Fortunately none of the indirect accesses are on the 'hot' p=
ath
>> for tx
>> + * =A0 or rx, so this should be okay.
>> + *
>> + * TODO:
>> + * - Fix driver to work on more than just Virtex5. =A0Right now the
>> driver
>> + * =A0 assumes that the locallink DMA registers are accessed via DC=
R
>> + * =A0 instructions.
>> + * - Factor out locallink DMA code into separate driver
>> + * - Fix multicast assignment.
>> + * - Fix support for hardware checksumming.
>> + * - Testing. =A0Lots and lots of testing.
>> + *
>> + */
>> +
>> +#include <linux/delay.h>
>> +#include <linux/etherdevice.h>
>> +#include <linux/init.h>
>> +#include <linux/mii.h>
>> +#include <linux/module.h>
>> +#include <linux/mutex.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_mdio.h>
>> +#include <linux/of_platform.h>
>> +#include <linux/skbuff.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/tcp.h> =A0 =A0 =A0/* needed for sizeof(tcphdr) */
>> +#include <linux/udp.h> =A0 =A0 =A0/* needed for sizeof(udphdr) */
>> +#include <linux/pci.h>
>> +#include <linux/phy.h>
>> +#include <linux/in.h>
>> +#include <linux/io.h>
>> +#include <linux/ip.h>
>> +
>> +#include "xilinx_temac.h"
>> +
>> +#define TX_BD_NUM =A0 64
>> +#define RX_BD_NUM =A0 128
>> +
>> +/*
>> --------------------------------------------------------------------=
-
>> + * Low level register access functions
>> + */
>> +
>> +u32 temac_ior(struct temac_local *lp, int offset)
>> +{
>> + =A0 =A0 =A0 return in_be32((u32 *)(lp->regs + offset));
>> +}
>> +
>> +void temac_iow(struct temac_local *lp, int offset, u32 value)
>> +{
>> + =A0 =A0 =A0 out_be32((u32 *) (lp->regs + offset), value);
>> +}
>> +
>> +int temac_indirect_busywait(struct temac_local *lp)
>> +{
>> + =A0 =A0 =A0 long end =3D jiffies + 2;
>> +
>> + =A0 =A0 =A0 while (!(temac_ior(lp, XTE_RDY0_OFFSET) &
>> XTE_RDY0_HARD_ACS_RDY_MASK)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (end - jiffies <=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON(1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 msleep(1);
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +/**
>> + * temac_indirect_in32
>> + *
>> + * lp->indirect_mutex must be held when calling this function
>> + */
>> +u32 temac_indirect_in32(struct temac_local *lp, int reg)
>> +{
>> + =A0 =A0 =A0 u32 val;
>> +
>> + =A0 =A0 =A0 if (temac_indirect_busywait(lp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
>> + =A0 =A0 =A0 temac_iow(lp, XTE_CTL0_OFFSET, reg);
>> + =A0 =A0 =A0 if (temac_indirect_busywait(lp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
>> + =A0 =A0 =A0 val =3D temac_ior(lp, XTE_LSW0_OFFSET);
>> +
>> + =A0 =A0 =A0 return val;
>> +}
>> +
>> +/**
>> + * temac_indirect_out32
>> + *
>> + * lp->indirect_mutex must be held when calling this function
>> + */
>> +void temac_indirect_out32(struct temac_local *lp, int reg, u32 valu=
e)
>> +{
>> + =A0 =A0 =A0 if (temac_indirect_busywait(lp))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 temac_iow(lp, XTE_LSW0_OFFSET, value);
>> + =A0 =A0 =A0 temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MA=
SK | reg);
>> +}
>> +
>> +static u32 temac_dma_in32(struct temac_local *lp, int reg)
>> +{
>> + =A0 =A0 =A0 return dcr_read(lp->sdma_dcrs, reg);
>> +}
>> +
>> +static void temac_dma_out32(struct temac_local *lp, int reg, u32 va=
lue)
>> +{
>> + =A0 =A0 =A0 dcr_write(lp->sdma_dcrs, reg, value);
>> +}
>> +
>> +/**
>> + * temac_dma_bd_init - Setup buffer descriptor rings
>> + */
>> +static int temac_dma_bd_init(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct sk_buff *skb;
>> + =A0 =A0 =A0 int i;
>> +
>> + =A0 =A0 =A0 lp->rx_skb =3D kzalloc(sizeof(struct sk_buff)*RX_BD_NU=
M,
>> GFP_KERNEL);
>> + =A0 =A0 =A0 /* allocate the tx and rx ring buffer descriptors. */
>> + =A0 =A0 =A0 /* returns a virtual addres and a physical address. */
>> + =A0 =A0 =A0 lp->tx_bd_v =3D dma_alloc_coherent(NULL, sizeof(*lp->t=
x_bd_v) *
>> TX_BD_NUM,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0&lp->tx_bd_p, GFP_KERNEL);
>> + =A0 =A0 =A0 lp->rx_bd_v =3D dma_alloc_coherent(NULL, sizeof(*lp->r=
x_bd_v) *
>> RX_BD_NUM,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0&lp->rx_bd_p, GFP_KERNEL);
>> +
>> + =A0 =A0 =A0 memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NU=
M);
>> + =A0 =A0 =A0 for (i =3D 0; i < TX_BD_NUM; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_v[i].next =3D lp->tx_bd_p +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof=
(*lp->tx_bd_v) * ((i + 1) %
>> TX_BD_NUM);
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NU=
M);
>> + =A0 =A0 =A0 for (i =3D 0; i < RX_BD_NUM; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_v[i].next =3D lp->rx_bd_p +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof=
(*lp->rx_bd_v) * ((i + 1) %
>> RX_BD_NUM);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(XTE_MAX_JUMBO_FRAME_=
SIZE
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + XTE_=
ALIGN, GFP_ATOMIC);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev, "a=
lloc_skb error %d\n", i);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_skb[i] =3D skb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, =A0BUFFER_ALIGN(skb->=
data));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* returns physical address of skb->da=
ta */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_v[i].phys =3D pci_map_single=
(NULL, skb->data,
>> +
>> XTE_MAX_JUMBO_FRAME_SIZE,
>> +
>> PCI_DMA_FROMDEVICE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_v[i].len =3D XTE_MAX_JUMBO_F=
RAME_SIZE;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_v[i].app0 =3D STS_CTRL_APP0_=
IRQONEND;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 temac_dma_out32(lp, TX_CHNL_CTRL, 0x10220400 |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_EN |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_DLY_EN |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_COAL_EN);
>> + =A0 =A0 =A0 /* 0x10220483 */
>> + =A0 =A0 =A0 /* 0x00100483 */
>> + =A0 =A0 =A0 temac_dma_out32(lp, RX_CHNL_CTRL, 0xff010000 |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_EN |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_DLY_EN |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_COAL_EN |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 CHNL_CTRL_IRQ_IOE);
>> + =A0 =A0 =A0 /* 0xff010283 */
>> +
>> + =A0 =A0 =A0 temac_dma_out32(lp, RX_CURDESC_PTR, =A0lp->rx_bd_p);
>> + =A0 =A0 =A0 temac_dma_out32(lp, RX_TAILDESC_PTR,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_bd_p + (sizeof(*=
lp->rx_bd_v) * (RX_BD_NUM
>> - 1)));
>> + =A0 =A0 =A0 temac_dma_out32(lp, TX_CURDESC_PTR, lp->tx_bd_p);
>> +
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +/*
>> --------------------------------------------------------------------=
-
>> + * net_device_ops
>> + */
>> +
>> +static int temac_set_mac_address(struct net_device *ndev, void
>> *address)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> +
>> + =A0 =A0 =A0 if (address)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(ndev->dev_addr, address, ETH_AL=
EN);
>> +
>> + =A0 =A0 =A0 if (!is_valid_ether_addr(ndev->dev_addr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 random_ether_addr(ndev->dev_addr);
>> +
>> + =A0 =A0 =A0 /* set up unicast MAC address filter set its mac addre=
ss */
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_UAW0_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[0]) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[1] << 8) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[2] << 16) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[3] << 24));
>> + =A0 =A0 =A0 /* There are reserved bits in EUAW1
>> + =A0 =A0 =A0 =A0* so don't affect them Set MAC bits [47:32] in EUAW=
1 */
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_UAW1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[4] & 0x000000ff) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ndev->dev_=
addr[5] << 8));
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +static void temac_set_multicast_list(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 u32 multi_addr_msw, multi_addr_lsw, val;
>> + =A0 =A0 =A0 int i;
>> +
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || ndev->mc_count > MU=
LTICAST_CAM_TABLE_NUM) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0We must make the kerne=
l realise we had to move
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0into promisc mode or w=
e start all out war on
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0the cable. If it was a=
 promisc request the
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0flag is already set. I=
f not we assert it.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->flags |=3D IFF_PROMISC;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, XTE_AFM_OFFSE=
T,
>> XTE_AFM_EPPRM_MASK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "Promiscuous mode=
 enabled.\n");
>> + =A0 =A0 =A0 } else if (ndev->mc_count) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dev_mc_list *mclist =3D ndev->m=
c_list;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; mclist && i < ndev->mc_c=
ount; i++) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i >=3D MULTICAST_C=
AM_TABLE_NUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 multi_addr_msw =3D ((m=
clist->dmi_addr[3] << 24) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 (mclist->dmi_addr[2] << 16) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 (mclist->dmi_addr[1] << 8) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 (mclist->dmi_addr[0]));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(l=
p, XTE_MAW0_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0multi_addr_msw);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 multi_addr_lsw =3D ((m=
clist->dmi_addr[5] << 8) |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 (mclist->dmi_addr[4]) | (i <<
>> 16));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(l=
p, XTE_MAW1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0multi_addr_lsw);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mclist =3D mclist->nex=
t;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D temac_indirect_in32(lp, XTE_AF=
M_OFFSET);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, XTE_AFM_OFFSE=
T,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0val & ~XTE_AFM_EPPRM_MASK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, XTE_MAW0_OFFS=
ET, 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, XTE_MAW1_OFFS=
ET, 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "Promiscuous mode=
 disabled.\n");
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +}
>> +
>> +struct temac_option {
>> + =A0 =A0 =A0 int flg;
>> + =A0 =A0 =A0 u32 opt;
>> + =A0 =A0 =A0 u32 reg;
>> + =A0 =A0 =A0 u32 m_or;
>> + =A0 =A0 =A0 u32 m_and;
>> +} temac_options[] =3D {
>> + =A0 =A0 =A0 /* Turn on jumbo packet support for both Rx and Tx */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_JUMBO,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_TXC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3D XTE_TXC_TXJMBO_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_JUMBO,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_RXC1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_RXC1_RXJMBO_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on VLAN packet support for both Rx and Tx */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_VLAN,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_TXC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_TXC_TXVLAN_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_VLAN,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_RXC1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_RXC1_RXVLAN_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on FCS stripping on receive packets */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_FCS_STRIP,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_RXC1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_RXC1_RXFCS_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on FCS insertion on transmit packets */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_FCS_INSERT,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_TXC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_TXC_TXFCS_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on length/type field checking on receive packe=
ts */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_LENTYPE_ERR,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_RXC1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_RXC1_RXLT_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on flow control */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_FLOW_CONTROL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_FCC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_FCC_RXFLO_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on flow control */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_FLOW_CONTROL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_FCC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_FCC_TXFLO_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Turn on promiscuous frame filtering (all frames are=
 received
>> ) */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_PROMISC,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_AFM_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_AFM_EPPRM_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Enable transmitter if not already enabled */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_TXEN,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_TXC_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_TXC_TXEN_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 /* Enable receiver? */
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .opt =3D XTE_OPTION_RXEN,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reg =3D XTE_RXC1_OFFSET,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .m_or =3DXTE_RXC1_RXEN_MASK,
>> + =A0 =A0 =A0 },
>> + =A0 =A0 =A0 {}
>> +};
>> +
>> +/**
>> + * temac_setoptions
>> + */
>> +static u32 temac_setoptions(struct net_device *ndev, u32 options)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct temac_option *tp =3D &temac_options[0];
>> + =A0 =A0 =A0 int reg;
>> +
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 while (tp->opt) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D temac_indirect_in32(lp, tp->re=
g) & ~tp->m_or;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (options & tp->opt)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg |=3D tp->m_or;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, tp->reg, reg)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp++;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 lp->options |=3D options;
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 return (0);
>> +}
>> +
>> +/* Initilize temac */
>> +static void temac_device_reset(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 u32 timeout;
>> + =A0 =A0 =A0 u32 val;
>> +
>> + =A0 =A0 =A0 /* Perform a software reset */
>> +
>> + =A0 =A0 =A0 /* 0x300 host enable bit ? */
>> + =A0 =A0 =A0 /* reset PHY through control register ?:1 */
>> +
>> + =A0 =A0 =A0 dev_dbg(&ndev->dev, "%s()\n", __func__);
>> +
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 /* Reset the receiver and wait for it to finish reset =
*/
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_RXC1_OFFSET, XTE_RXC1_RXR=
ST_MASK);
>> + =A0 =A0 =A0 timeout =3D 1000;
>> + =A0 =A0 =A0 while (temac_indirect_in32(lp, XTE_RXC1_OFFSET) &
>> XTE_RXC1_RXRST_MASK) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (--timeout =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "temac=
_device_reset RX reset
>> timeout!!\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 /* Reset the transmitter and wait for it to finish res=
et */
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_TXC_OFFSET, XTE_TXC_TXRST=
_MASK);
>> + =A0 =A0 =A0 timeout =3D 1000;
>> + =A0 =A0 =A0 while (temac_indirect_in32(lp, XTE_TXC_OFFSET) &
>> XTE_TXC_TXRST_MASK) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (--timeout =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "temac=
_device_reset TX reset
>> timeout!!\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 /* Disable the receiver */
>> + =A0 =A0 =A0 val =3D temac_indirect_in32(lp, XTE_RXC1_OFFSET);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_RXC1_OFFSET, val &
>> ~XTE_RXC1_RXEN_MASK);
>> +
>> + =A0 =A0 =A0 /* Reset Local Link (DMA) */
>> + =A0 =A0 =A0 temac_dma_out32(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
>> + =A0 =A0 =A0 timeout =3D 1000;
>> + =A0 =A0 =A0 while (temac_dma_in32(lp, DMA_CONTROL_REG) & DMA_CONTR=
OL_RST) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (--timeout =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "temac=
_device_reset DMA reset
>> timeout!!\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 temac_dma_out32(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
>> +
>> + =A0 =A0 =A0 temac_dma_bd_init(ndev);
>> +
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_RXC0_OFFSET, 0);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_RXC1_OFFSET, 0);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_TXC_OFFSET, 0);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_FCC_OFFSET, XTE_FCC_RXFLO=
_MASK);
>> +
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 /* Sync default options with HW
>> + =A0 =A0 =A0 =A0* but leave receiver and transmitter disabled. =A0*=
/
>> + =A0 =A0 =A0 temac_setoptions(ndev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->options & ~(XTE=
_OPTION_TXEN |
>> XTE_OPTION_RXEN));
>> +
>> + =A0 =A0 =A0 temac_set_mac_address(ndev, NULL);
>> +
>> + =A0 =A0 =A0 /* Set address filter table */
>> + =A0 =A0 =A0 temac_set_multicast_list(ndev);
>> + =A0 =A0 =A0 if (temac_setoptions(ndev, lp->options))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev, "Error setting TEM=
AC options\n");
>> +
>> + =A0 =A0 =A0 /* Init Driver variable */
>> + =A0 =A0 =A0 ndev->trans_start =3D 0;
>> +}
>> +
>> +void temac_adjust_link(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct phy_device *phy =3D lp->phy_dev;
>> + =A0 =A0 =A0 u32 mii_speed;
>> + =A0 =A0 =A0 int link_state;
>> +
>> + =A0 =A0 =A0 /* hash together the state values to decide if somethi=
ng has
>> changed */
>> + =A0 =A0 =A0 link_state =3D phy->speed | (phy->duplex << 1) | phy->=
link;
>> +
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 if (lp->last_link !=3D link_state) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mii_speed =3D temac_indirect_in32(lp, =
XTE_EMCFG_OFFSET);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mii_speed &=3D ~XTE_EMCFG_LINKSPD_MASK=
;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (phy->speed) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SPEED_1000: mii_speed |=3D XTE_EM=
CFG_LINKSPD_1000;
>> break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SPEED_100: mii_speed |=3D XTE_EMC=
=46G_LINKSPD_100;
>> break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SPEED_10: mii_speed |=3D XTE_EMCF=
G_LINKSPD_10; break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Write new speed setting out to TEMA=
C */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_out32(lp, XTE_EMCFG_OFF=
SET, mii_speed);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->last_link =3D link_state;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_print_status(phy);
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +}
>> +
>> +static void temac_start_xmit_done(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct cdmac_bd *cur_p;
>> + =A0 =A0 =A0 unsigned int stat =3D 0;
>> +
>> + =A0 =A0 =A0 cur_p =3D &lp->tx_bd_v[lp->tx_bd_ci];
>> + =A0 =A0 =A0 stat =3D cur_p->app0;
>> +
>> + =A0 =A0 =A0 while (stat & STS_CTRL_APP0_CMPLT) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_unmap_single(NULL, (unsigned long)=
cur_p->phys,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p-=
>len, PCI_DMA_TODEVICE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cur_p->app4)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_irq((str=
uct sk_buff
>> *)cur_p->app4);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->app0 =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.tx_packets++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.tx_bytes +=3D cur_p->len;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_ci++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->tx_bd_ci >=3D TX_BD_NUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_ci =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p =3D &lp->tx_bd_v[lp->tx_bd_ci];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat =3D cur_p->app0;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 netif_wake_queue(ndev);
>> +}
>> +
>> +static int temac_start_xmit(struct sk_buff *skb, struct net_device
>> *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct cdmac_bd *cur_p;
>> + =A0 =A0 =A0 dma_addr_t start_p, tail_p;
>> + =A0 =A0 =A0 int ii;
>> + =A0 =A0 =A0 unsigned long num_frag;
>> + =A0 =A0 =A0 skb_frag_t *frag;
>> +
>> + =A0 =A0 =A0 num_frag =3D skb_shinfo(skb)->nr_frags;
>> + =A0 =A0 =A0 frag =3D &skb_shinfo(skb)->frags[0];
>> + =A0 =A0 =A0 start_p =3D lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->t=
x_bd_tail;
>> + =A0 =A0 =A0 cur_p =3D &lp->tx_bd_v[lp->tx_bd_tail];
>> +
>> + =A0 =A0 =A0 if (cur_p->app0 & STS_CTRL_APP0_CMPLT) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!netif_queue_stopped(ndev)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(ndev)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 cur_p->app0 =3D 0;
>> + =A0 =A0 =A0 if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct iphdr *ip =3D ip_hdr(skb)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int length =3D 0, start, insert =3D 0,=
 headlen;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ip->protocol) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case IPPROTO_TCP:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sizeof(struc=
t iphdr) + ETH_HLEN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 insert =3D sizeof(stru=
ct iphdr) + ETH_HLEN + 16;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 length =3D ip->tot_len=
 - sizeof(struct iphdr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 headlen =3D ETH_HLEN +=
 sizeof(struct iphdr) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 si=
zeof(struct tcphdr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case IPPROTO_UDP:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sizeof(struc=
t iphdr) + ETH_HLEN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 insert =3D sizeof(stru=
ct iphdr) + ETH_HLEN + 6;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 length =3D ip->tot_len=
 - sizeof(struct iphdr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 headlen =3D ETH_HLEN +=
 sizeof(struct iphdr) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 si=
zeof(struct udphdr);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->app1 =3D ((start << 16) | inser=
t);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->app2 =3D csum_tcpudp_magic(ip->=
saddr, ip->daddr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 length, ip->protocol,
>> 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data[insert] =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data[insert + 1] =3D 0;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 cur_p->app0 |=3D STS_CTRL_APP0_SOP;
>> + =A0 =A0 =A0 cur_p->len =3D skb_headlen(skb);
>> + =A0 =A0 =A0 cur_p->phys =3D pci_map_single(NULL, skb->data, skb->l=
en,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0PCI_DMA_TODEVICE);
>> + =A0 =A0 =A0 cur_p->app4 =3D (unsigned long)skb;
>> +
>> + =A0 =A0 =A0 for (ii =3D 0; ii < num_frag; ii++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_tail++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->tx_bd_tail >=3D TX_BD_NUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_tail =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p =3D &lp->tx_bd_v[lp->tx_bd_tail]=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->phys =3D pci_map_single(NULL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void =
*)page_address(frag->page)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + frag=
->page_offset,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frag->=
size, PCI_DMA_TODEVICE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->len =3D frag->size;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->app0 =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frag++;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 cur_p->app0 |=3D STS_CTRL_APP0_EOP;
>> +
>> + =A0 =A0 =A0 tail_p =3D lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx=
_bd_tail;
>> + =A0 =A0 =A0 lp->tx_bd_tail++;
>> + =A0 =A0 =A0 if (lp->tx_bd_tail >=3D TX_BD_NUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_bd_tail =3D 0;
>> +
>> + =A0 =A0 =A0 /* Kick off the transfer */
>> + =A0 =A0 =A0 temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA s=
tart */
>> +
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +
>> +static void ll_temac_recv(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 struct sk_buff *skb, *new_skb;
>> + =A0 =A0 =A0 unsigned int bdstat;
>> + =A0 =A0 =A0 struct cdmac_bd *cur_p;
>> + =A0 =A0 =A0 dma_addr_t tail_p;
>> + =A0 =A0 =A0 int length;
>> + =A0 =A0 =A0 unsigned long skb_vaddr;
>> + =A0 =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 =A0 spin_lock_irqsave(&lp->rx_lock, flags);
>> +
>> + =A0 =A0 =A0 tail_p =3D lp->rx_bd_p + sizeof(*lp->rx_bd_v) * lp->rx=
_bd_ci;
>> + =A0 =A0 =A0 cur_p =3D &lp->rx_bd_v[lp->rx_bd_ci];
>> +
>> + =A0 =A0 =A0 bdstat =3D cur_p->app0;
>> + =A0 =A0 =A0 while ((bdstat & STS_CTRL_APP0_CMPLT)) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D lp->rx_skb[lp->rx_bd_ci];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 length =3D cur_p->app4;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_vaddr =3D virt_to_bus(skb->data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_unmap_single(NULL, skb_vaddr, leng=
th,
>> PCI_DMA_FROMDEVICE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_put(skb, length);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D ndev;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_type_trans(skb, =
ndev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->ip_summed =3D CHECKSUM_NONE;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_packets++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ndev->stats.rx_bytes +=3D length;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_skb =3D alloc_skb(XTE_MAX_JUMBO_FR=
AME_SIZE +
>> XTE_ALIGN,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_AT=
OMIC);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_skb =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev, "n=
o memory for new
>> sk_buff\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore=
(&lp->rx_lock, flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(new_skb, BUFFER_ALIGN(new_=
skb->data));
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->app0 =3D STS_CTRL_APP0_IRQONEND=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->phys =3D pci_map_single(NULL, n=
ew_skb->data,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0XTE_MAX_JUMBO_FRAME_SIZE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0PCI_DMA_FROMDEVICE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p->len =3D XTE_MAX_JUMBO_FRAME_SIZ=
E;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_skb[lp->rx_bd_ci] =3D new_skb;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_ci++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->rx_bd_ci >=3D RX_BD_NUM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_ci =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cur_p =3D &lp->rx_bd_v[lp->rx_bd_ci];
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdstat =3D cur_p->app0;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 temac_dma_out32(lp, RX_TAILDESC_PTR, tail_p);
>> +
>> + =A0 =A0 =A0 spin_unlock_irqrestore(&lp->rx_lock, flags);
>> +}
>> +
>> +static irqreturn_t ll_temac_tx_irq(int irq, void *_ndev)
>> +{
>> + =A0 =A0 =A0 struct net_device *ndev =3D _ndev;
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 unsigned int status;
>> +
>> + =A0 =A0 =A0 status =3D temac_dma_in32(lp, TX_IRQ_REG);
>> + =A0 =A0 =A0 temac_dma_out32(lp, TX_IRQ_REG, status);
>> +
>> + =A0 =A0 =A0 if (status & (IRQ_COAL | IRQ_DLY))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_start_xmit_done(lp->ndev);
>> + =A0 =A0 =A0 if (status & 0x080)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&ndev->dev, "DMA error 0x%x\n"=
, status);
>> +
>> + =A0 =A0 =A0 return IRQ_HANDLED;
>> +}
>> +
>> +static irqreturn_t ll_temac_rx_irq(int irq, void *_ndev)
>> +{
>> + =A0 =A0 =A0 struct net_device *ndev =3D _ndev;
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 unsigned int status;
>> +
>> + =A0 =A0 =A0 /* Read and clear the status registers */
>> + =A0 =A0 =A0 status =3D temac_dma_in32(lp, RX_IRQ_REG);
>> + =A0 =A0 =A0 temac_dma_out32(lp, RX_IRQ_REG, status);
>> +
>> + =A0 =A0 =A0 if (status & (IRQ_COAL | IRQ_DLY))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ll_temac_recv(lp->ndev);
>> +
>> + =A0 =A0 =A0 return IRQ_HANDLED;
>> +}
>> +
>> +static int temac_open(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 int rc;
>> +
>> + =A0 =A0 =A0 dev_dbg(&ndev->dev, "temac_open()\n");
>> +
>> + =A0 =A0 =A0 if (lp->phy_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev =3D of_phy_connect(lp->nde=
v, lp->phy_node,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0temac_adjust_link, 0, 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lp->phy_dev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(lp->dev, "of_p=
hy_connect() failed\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start(lp->phy_dev);
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 rc =3D request_irq(lp->tx_irq, ll_temac_tx_irq, 0, nde=
v->name,
>> ndev);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_tx_irq;
>> + =A0 =A0 =A0 rc =3D request_irq(lp->rx_irq, ll_temac_rx_irq, 0, nde=
v->name,
>> ndev);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_rx_irq;
>> +
>> + =A0 =A0 =A0 temac_device_reset(ndev);
>> + =A0 =A0 =A0 return 0;
>> +
>> + err_rx_irq:
>> + =A0 =A0 =A0 free_irq(lp->tx_irq, ndev);
>> + err_tx_irq:
>> + =A0 =A0 =A0 if (lp->phy_dev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(lp->phy_dev);
>> + =A0 =A0 =A0 lp->phy_dev =3D NULL;
>> + =A0 =A0 =A0 dev_err(lp->dev, "request_irq() failed\n");
>> + =A0 =A0 =A0 return rc;
>> +}
>> +
>> +static int temac_stop(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> +
>> + =A0 =A0 =A0 dev_dbg(&ndev->dev, "temac_close()\n");
>> +
>> + =A0 =A0 =A0 free_irq(lp->tx_irq, ndev);
>> + =A0 =A0 =A0 free_irq(lp->rx_irq, ndev);
>> +
>> + =A0 =A0 =A0 if (lp->phy_dev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(lp->phy_dev);
>> + =A0 =A0 =A0 lp->phy_dev =3D NULL;
>> +
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +static void
>> +temac_poll_controller(struct net_device *ndev)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> +
>> + =A0 =A0 =A0 disable_irq(lp->tx_irq);
>> + =A0 =A0 =A0 disable_irq(lp->rx_irq);
>> +
>> + =A0 =A0 =A0 ll_temac_rx_irq(lp->tx_irq, lp, 0);
>> + =A0 =A0 =A0 ll_temac_tx_irq(lp->rx_irq, lp, 0);
>> +
>> + =A0 =A0 =A0 enable_irq(lp->tx_irq);
>> + =A0 =A0 =A0 enable_irq(lp->rx_irq);
>> +}
>> +#endif
>> +
>> +static const struct net_device_ops temac_netdev_ops =3D {
>> + =A0 =A0 =A0 .ndo_open =3D temac_open,
>> + =A0 =A0 =A0 .ndo_stop =3D temac_stop,
>> + =A0 =A0 =A0 .ndo_start_xmit =3D temac_start_xmit,
>> + =A0 =A0 =A0 .ndo_set_mac_address =3D temac_set_mac_address,
>> + =A0 =A0 =A0 //.ndo_set_multicast_list =3D temac_set_multicast_list=
,
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> + =A0 =A0 =A0 .ndo_poll_controller =3D temac_poll_controller,
>> +#endif
>> +};
>> +
>> +/*
>> --------------------------------------------------------------------=
-
>> + * SYSFS device attributes
>> + */
>> +static ssize_t temac_show_llink_regs(struct device *dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct device_attribute *attr, char
>> *buf)
>> +{
>> + =A0 =A0 =A0 struct net_device *ndev =3D dev_get_drvdata(dev);
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 int i, len =3D 0;
>> +
>> + =A0 =A0 =A0 for (i =3D 0; i < 0x11; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D sprintf(buf + len, "%.8x%s", =
temac_dma_in32(lp,
>> i),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(i % 8)=
 =3D=3D 7 ? "\n" : " ");
>> + =A0 =A0 =A0 len +=3D sprintf(buf + len, "\n");
>> +
>> + =A0 =A0 =A0 return len;
>> +}
>> +
>> +static DEVICE_ATTR(llink_regs, 0440, temac_show_llink_regs, NULL);
>> +
>> +static struct attribute *temac_device_attrs[] =3D {
>> + =A0 =A0 =A0 &dev_attr_llink_regs.attr,
>> + =A0 =A0 =A0 NULL,
>> +};
>> +
>> +static const struct attribute_group temac_attr_group =3D {
>> + =A0 =A0 =A0 .attrs =3D temac_device_attrs,
>> +};
>> +
>> +static int __init
>> +temac_of_probe(struct of_device *op, const struct of_device_id *mat=
ch)
>> +{
>> + =A0 =A0 =A0 struct device_node *np;
>> + =A0 =A0 =A0 struct temac_local *lp;
>> + =A0 =A0 =A0 struct net_device *ndev;
>> + =A0 =A0 =A0 const void *addr;
>> + =A0 =A0 =A0 int size, rc =3D 0;
>> + =A0 =A0 =A0 unsigned int dcrs;
>> +
>> + =A0 =A0 =A0 /* Init network device structure */
>> + =A0 =A0 =A0 ndev =3D alloc_etherdev(sizeof(*lp));
>> + =A0 =A0 =A0 if (!ndev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not allocate =
device.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 ether_setup(ndev);
>> + =A0 =A0 =A0 dev_set_drvdata(&op->dev, ndev);
>> + =A0 =A0 =A0 SET_NETDEV_DEV(ndev, &op->dev);
>> + =A0 =A0 =A0 ndev->flags &=3D ~IFF_MULTICAST; =A0/* clear multicast=
 */
>> + =A0 =A0 =A0 ndev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST;
>> + =A0 =A0 =A0 ndev->netdev_ops =3D &temac_netdev_ops;
>> +#if 0
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_IP_CSUM; /* Can checksum T=
CP/UDP over
>> IPv4. */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_HW_CSUM; /* Can checksum a=
ll the
>> packets. */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_IPV6_CSUM; /* Can checksum=
 IPV6
>> TCP/UDP */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_HIGHDMA; /* Can DMA to hig=
h memory. */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_HW_VLAN_TX; /* Transmit VL=
AN hw accel
>> */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_HW_VLAN_RX; /* Receive VLA=
N hw
>> acceleration */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_HW_VLAN_FILTER; /* Receive=
 VLAN
>> filtering */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_VLAN_CHALLENGED; /* cannot=
 handle VLAN
>> pkts */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_GSO; /* Enable software GS=
O. */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_MULTI_QUEUE; /* Has multip=
le TX/RX
>> queues */
>> + =A0 =A0 =A0 ndev->features |=3D NETIF_F_LRO; /* large receive offl=
oad */
>> +#endif
>> +
>> + =A0 =A0 =A0 /* setup temac private info structure */
>> + =A0 =A0 =A0 lp =3D netdev_priv(ndev);
>> + =A0 =A0 =A0 lp->ndev =3D ndev;
>> + =A0 =A0 =A0 lp->dev =3D &op->dev;
>> + =A0 =A0 =A0 lp->options =3D XTE_OPTION_DEFAULTS;
>> + =A0 =A0 =A0 spin_lock_init(&lp->rx_lock);
>> + =A0 =A0 =A0 mutex_init(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 /* map device registers */
>> + =A0 =A0 =A0 lp->regs =3D of_iomap(op->node, 0);
>> + =A0 =A0 =A0 if (!lp->regs) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not map temac=
 regs.\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 /* Find the DMA node, map the DMA registers, and decod=
e the DMA
>> IRQs */
>> + =A0 =A0 =A0 np =3D of_parse_phandle(op->node, "llink-connected", 0=
);
>> + =A0 =A0 =A0 if (!np) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not find DMA =
node\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 dcrs =3D dcr_resource_start(np, 0);
>> + =A0 =A0 =A0 if (dcrs =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not get DMA r=
egister
>> address\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr_resource_len(n=
p, 0));
>> + =A0 =A0 =A0 dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
>> +
>> + =A0 =A0 =A0 lp->rx_irq =3D irq_of_parse_and_map(np, 0);
>> + =A0 =A0 =A0 lp->tx_irq =3D irq_of_parse_and_map(np, 1);
>> + =A0 =A0 =A0 if (!lp->rx_irq || !lp->tx_irq) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not determine=
 irqs\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 of_node_put(np); /* Finished with the DMA node; drop t=
he
>> reference */
>> +
>> + =A0 =A0 =A0 /* Retrieve the MAC address */
>> + =A0 =A0 =A0 addr =3D of_get_property(op->node, "local-mac-address"=
, &size);
>> + =A0 =A0 =A0 if ((!addr) || (size !=3D 6)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not find MAC =
address\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -ENODEV;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 temac_set_mac_address(ndev, (void *)addr);
>> +
>> + =A0 =A0 =A0 rc =3D temac_mdio_setup(lp, op->node);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(&op->dev, "error registering =
MDIO bus\n");
>> +
>> + =A0 =A0 =A0 lp->phy_node =3D of_parse_phandle(op->node, "phy-handl=
e", 0);
>> + =A0 =A0 =A0 if (lp->phy_node)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(lp->dev, "using PHY node %s (%=
p)\n",
>> np->full_name, np);
>> +
>> + =A0 =A0 =A0 /* Add the device attributes */
>> + =A0 =A0 =A0 rc =3D sysfs_create_group(&lp->dev->kobj, &temac_attr_=
group);
>> + =A0 =A0 =A0 if (rc) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(lp->dev, "Error creating sysfs=
 files\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 rc =3D register_netdev(lp->ndev);
>> + =A0 =A0 =A0 if (rc) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(lp->dev, "register_netdev() er=
ror (%i)\n", rc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_register_ndev;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 return 0;
>> +
>> + err_register_ndev:
>> + =A0 =A0 =A0 sysfs_remove_group(&lp->dev->kobj, &temac_attr_group);
>> + nodev:
>> + =A0 =A0 =A0 free_netdev(ndev);
>> + =A0 =A0 =A0 ndev =3D NULL;
>> + =A0 =A0 =A0 return rc;
>> +}
>> +
>> +static int __devexit temac_of_remove(struct of_device *op)
>> +{
>> + =A0 =A0 =A0 struct net_device *ndev =3D dev_get_drvdata(&op->dev);
>> + =A0 =A0 =A0 struct temac_local *lp =3D netdev_priv(ndev);
>> +
>> + =A0 =A0 =A0 temac_mdio_teardown(lp);
>> + =A0 =A0 =A0 unregister_netdev(ndev);
>> + =A0 =A0 =A0 sysfs_remove_group(&lp->dev->kobj, &temac_attr_group);
>> + =A0 =A0 =A0 if (lp->phy_node)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(lp->phy_node);
>> + =A0 =A0 =A0 lp->phy_node =3D NULL;
>> + =A0 =A0 =A0 dev_set_drvdata(&op->dev, NULL);
>> + =A0 =A0 =A0 free_netdev(ndev);
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +static struct of_device_id temac_of_match[] __devinitdata =3D {
>> + =A0 =A0 =A0 { .compatible =3D "xlnx,xps-ll-temac-1.01.b", },
>> + =A0 =A0 =A0 {},
>> +};
>> +MODULE_DEVICE_TABLE(of, temac_of_match);
>> +
>> +static struct of_platform_driver temac_of_driver =3D {
>> + =A0 =A0 =A0 .match_table =3D temac_of_match,
>> + =A0 =A0 =A0 .probe =3D temac_of_probe,
>> + =A0 =A0 =A0 .remove =3D __devexit_p(temac_of_remove),
>> + =A0 =A0 =A0 .driver =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =3D THIS_MODULE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "xilinx_temac",
>> + =A0 =A0 =A0 },
>> +};
>> +
>> +static int __init temac_init(void)
>> +{
>> + =A0 =A0 =A0 return of_register_platform_driver(&temac_of_driver);
>> +}
>> +module_init(temac_init);
>> +
>> +static void __exit temac_exit(void)
>> +{
>> + =A0 =A0 =A0 of_unregister_platform_driver(&temac_of_driver);
>> +}
>> +module_exit(temac_exit);
>> +
>> +MODULE_DESCRIPTION("Xilinx LL_TEMAC Ethernet driver");
>> +MODULE_AUTHOR("Yoshio Kashiwagi");
>> +MODULE_LICENSE("GPL");
>> diff --git a/drivers/net/xilinx_temac.h b/drivers/net/xilinx_temac.h
>> new file mode 100644
>> index 0000000..4bc340c
>> --- /dev/null
>> +++ b/drivers/net/xilinx_temac.h
>> @@ -0,0 +1,374 @@
>> +
>> +#ifndef XILINX_TEMAC_H
>> +#define XILINX_TEMAC_H
>> +
>> +#include <linux/netdevice.h>
>> +#include <linux/of.h>
>> +#include <linux/spinlock.h>
>> +#include <asm/dcr.h>
>> +#include <asm/dcr-regs.h>
>> +
>> +/* packet size info */
>> +#define XTE_HDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 14 =A0 =A0=
 =A0/* size of Ethernet
>> header */
>> +#define XTE_TRL_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =
=A0 /* size of Ethernet
>> trailer (FCS) */
>> +#define XTE_JUMBO_MTU =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A09000
>> +#define XTE_MAX_JUMBO_FRAME_SIZE =A0 =A0 =A0 (XTE_JUMBO_MTU + XTE_H=
DR_SIZE +
>> XTE_TRL_SIZE)
>> +
>> +/* =A0Configuration options */
>> +
>> +/* =A0Accept all incoming packets.
>> + * =A0This option defaults to disabled (cleared) */
>> +#define XTE_OPTION_PROMISC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0(1 << 0)
>> +/* =A0Jumbo frame support for Tx & Rx.
>> + * =A0This option defaults to disabled (cleared) */
>> +#define XTE_OPTION_JUMBO =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0(1 << 1)
>> +/* =A0VLAN Rx & Tx frame support.
>> + * =A0This option defaults to disabled (cleared) */
>> +#define XTE_OPTION_VLAN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (1 << 2)
>> +/* =A0Enable recognition of flow control frames on Rx
>> + * =A0This option defaults to enabled (set) */
>> +#define XTE_OPTION_FLOW_CONTROL =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 =
<< 4)
>> +/* =A0Strip FCS and PAD from incoming frames.
>> + * =A0Note: PAD from VLAN frames is not stripped.
>> + * =A0This option defaults to disabled (set) */
>> +#define XTE_OPTION_FCS_STRIP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
(1 << 5)
>> +/* =A0Generate FCS field and add PAD automatically for outgoing fra=
mes.
>> + * =A0This option defaults to enabled (set) */
>> +#define XTE_OPTION_FCS_INSERT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
1 << 6)
>> +/* =A0Enable Length/Type error checking for incoming frames. When t=
his
>> option is
>> +set, the MAC will filter frames that have a mismatched type/length
>> field
>> +and if XTE_OPTION_REPORT_RXERR is set, the user is notified when th=
ese
>> +types of frames are encountered. When this option is cleared, the M=
AC
>> will
>> +allow these types of frames to be received.
>> +This option defaults to enabled (set) */
>> +#define XTE_OPTION_LENTYPE_ERR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(=
1 << 7)
>> +/* =A0Enable the transmitter.
>> + * =A0This option defaults to enabled (set) */
>> +#define XTE_OPTION_TXEN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (1 << 11)
>> +/* =A0Enable the receiver
>> +* =A0 This option defaults to enabled (set) */
>> +#define XTE_OPTION_RXEN =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (1 << 12)
>> +
>> +/* =A0Default options set when device is initialized or reset */
>> +#define XTE_OPTION_DEFAULTS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 \
>> + =A0 =A0 =A0 (XTE_OPTION_TXEN | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0XTE_OPTION_FLOW_CONTROL | =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0\
>> + =A0 =A0 =A0 =A0XTE_OPTION_RXEN)
>> +
>> +/* XPS_LL_TEMAC SDMA registers definition */
>> +
>> +#define TX_NXTDESC_PTR =A0 =A0 =A00x00 =A0 =A0 =A0 =A0 =A0 =A0/* r =
*/
>> +#define TX_CURBUF_ADDR =A0 =A0 =A00x01 =A0 =A0 =A0 =A0 =A0 =A0/* r =
*/
>> +#define TX_CURBUF_LENGTH =A0 =A00x02 =A0 =A0 =A0 =A0 =A0 =A0/* r */
>> +#define TX_CURDESC_PTR =A0 =A0 =A00x03 =A0 =A0 =A0 =A0 =A0 =A0/* rw=
 */
>> +#define TX_TAILDESC_PTR =A0 =A0 0x04 =A0 =A0 =A0 =A0 =A0 =A0/* rw *=
/
>> +#define TX_CHNL_CTRL =A0 =A0 =A0 =A00x05 =A0 =A0 =A0 =A0 =A0 =A0/* =
rw */
>> +/*
>> + 0:7 =A0 =A0 =A024:31 =A0 =A0 =A0 IRQTimeout
>> + 8:15 =A0 =A0 16:23 =A0 =A0 =A0 IRQCount
>> + 16:20 =A0 =A011:15 =A0 =A0 =A0 Reserved
>> + 21 =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =A00
>> + 22 =A0 =A0 =A0 9 =A0 =A0 =A0 =A0 =A0 UseIntOnEnd
>> + 23 =A0 =A0 =A0 8 =A0 =A0 =A0 =A0 =A0 LdIRQCnt
>> + 24 =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =A0 IRQEn
>> + 25:28 =A0 =A03:6 =A0 =A0 =A0 =A0 Reserved
>> + 29 =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 IrqErrEn
>> + 30 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 IrqDlyEn
>> + 31 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 IrqCoalEn
>> +*/
>> +#define CHNL_CTRL_IRQ_IOE =A0 =A0 =A0 (1 << 9)
>> +#define CHNL_CTRL_IRQ_EN =A0 =A0 =A0 =A0(1 << 7)
>> +#define CHNL_CTRL_IRQ_ERR_EN =A0 =A0(1 << 2)
>> +#define CHNL_CTRL_IRQ_DLY_EN =A0 =A0(1 << 1)
>> +#define CHNL_CTRL_IRQ_COAL_EN =A0 (1 << 0)
>> +#define TX_IRQ_REG =A0 =A0 =A0 =A0 =A00x06 =A0 =A0 =A0 =A0 =A0 =A0/=
* rw */
>> +/*
>> + =A00:7 =A0 =A0 =A024:31 =A0 =A0 =A0 DltTmrValue
>> + 8:15 =A0 =A0 16:23 =A0 =A0 =A0 ClscCntrValue
>> + 16:17 =A0 =A014:15 =A0 =A0 =A0 Reserved
>> + 18:21 =A0 =A010:13 =A0 =A0 =A0 ClscCnt
>> + 22:23 =A0 =A08:9 =A0 =A0 =A0 =A0 DlyCnt
>> + 24:28 =A0 =A03::7 =A0 =A0 =A0 =A0Reserved
>> + 29 =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 ErrIrq
>> + 30 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 DlyIrq
>> + 31 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 CoalIrq
>> + */
>> +#define TX_CHNL_STS =A0 =A0 =A0 =A0 0x07 =A0 =A0 =A0 =A0 =A0 =A0/* =
r */
>> +/*
>> + =A0 0:9 =A0 =A0 =A022:31 =A0 Reserved
>> + 10 =A0 =A0 =A0 21 =A0 =A0 =A0TailPErr
>> + 11 =A0 =A0 =A0 20 =A0 =A0 =A0CmpErr
>> + 12 =A0 =A0 =A0 19 =A0 =A0 =A0AddrErr
>> + 13 =A0 =A0 =A0 18 =A0 =A0 =A0NxtPErr
>> + 14 =A0 =A0 =A0 17 =A0 =A0 =A0CurPErr
>> + 15 =A0 =A0 =A0 16 =A0 =A0 =A0BsyWr
>> + 16:23 =A0 =A08:15 =A0 =A0Reserved
>> + 24 =A0 =A0 =A0 7 =A0 =A0 =A0 Error
>> + 25 =A0 =A0 =A0 6 =A0 =A0 =A0 IOE
>> + 26 =A0 =A0 =A0 5 =A0 =A0 =A0 SOE
>> + 27 =A0 =A0 =A0 4 =A0 =A0 =A0 Cmplt
>> + 28 =A0 =A0 =A0 3 =A0 =A0 =A0 SOP
>> + 29 =A0 =A0 =A0 2 =A0 =A0 =A0 EOP
>> + 30 =A0 =A0 =A0 1 =A0 =A0 =A0 EngBusy
>> + 31 =A0 =A0 =A0 0 =A0 =A0 =A0 Reserved
>> +*/
>> +
>> +#define RX_NXTDESC_PTR =A0 =A0 =A00x08 =A0 =A0 =A0 =A0 =A0 =A0/* r =
*/
>> +#define RX_CURBUF_ADDR =A0 =A0 =A00x09 =A0 =A0 =A0 =A0 =A0 =A0/* r =
*/
>> +#define RX_CURBUF_LENGTH =A0 =A00x0a =A0 =A0 =A0 =A0 =A0 =A0/* r */
>> +#define RX_CURDESC_PTR =A0 =A0 =A00x0b =A0 =A0 =A0 =A0 =A0 =A0/* rw=
 */
>> +#define RX_TAILDESC_PTR =A0 =A0 0x0c =A0 =A0 =A0 =A0 =A0 =A0/* rw *=
/
>> +#define RX_CHNL_CTRL =A0 =A0 =A0 =A00x0d =A0 =A0 =A0 =A0 =A0 =A0/* =
rw */
>> +/*
>> + 0:7 =A0 =A0 =A024:31 =A0 =A0 =A0 IRQTimeout
>> + 8:15 =A0 =A0 16:23 =A0 =A0 =A0 IRQCount
>> + 16:20 =A0 =A011:15 =A0 =A0 =A0 Reserved
>> + 21 =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =A00
>> + 22 =A0 =A0 =A0 9 =A0 =A0 =A0 =A0 =A0 UseIntOnEnd
>> + 23 =A0 =A0 =A0 8 =A0 =A0 =A0 =A0 =A0 LdIRQCnt
>> + 24 =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =A0 IRQEn
>> + 25:28 =A0 =A03:6 =A0 =A0 =A0 =A0 Reserved
>> + 29 =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 IrqErrEn
>> + 30 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 IrqDlyEn
>> + 31 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 IrqCoalEn
>> + */
>> +#define RX_IRQ_REG =A0 =A0 =A0 =A0 =A00x0e =A0 =A0 =A0 =A0 =A0 =A0/=
* rw */
>> +#define IRQ_COAL =A0 =A0 =A0 =A0(1 << 0)
>> +#define IRQ_DLY =A0 =A0 =A0 =A0 (1 << 1)
>> +#define IRQ_ERR =A0 =A0 =A0 =A0 (1 << 2)
>> +#define IRQ_DMAERR =A0 =A0 =A0(1 << 7) =A0 =A0 =A0 =A0 =A0 =A0/* th=
is is not documented
>> ??? */
>> +/*
>> + 0:7 =A0 =A0 =A024:31 =A0 =A0 =A0 DltTmrValue
>> + 8:15 =A0 =A0 16:23 =A0 =A0 =A0 ClscCntrValue
>> + 16:17 =A0 =A014:15 =A0 =A0 =A0 Reserved
>> + 18:21 =A0 =A010:13 =A0 =A0 =A0 ClscCnt
>> + 22:23 =A0 =A08:9 =A0 =A0 =A0 =A0 DlyCnt
>> + 24:28 =A0 =A03::7 =A0 =A0 =A0 =A0Reserved
>> +*/
>> +#define RX_CHNL_STS =A0 =A0 =A0 =A0 0x0f =A0 =A0 =A0 =A0/* r */
>> +#define CHNL_STS_ENGBUSY =A0 =A0(1 << 1)
>> +#define CHNL_STS_EOP =A0 =A0 =A0 =A0(1 << 2)
>> +#define CHNL_STS_SOP =A0 =A0 =A0 =A0(1 << 3)
>> +#define CHNL_STS_CMPLT =A0 =A0 =A0(1 << 4)
>> +#define CHNL_STS_SOE =A0 =A0 =A0 =A0(1 << 5)
>> +#define CHNL_STS_IOE =A0 =A0 =A0 =A0(1 << 6)
>> +#define CHNL_STS_ERR =A0 =A0 =A0 =A0(1 << 7)
>> +
>> +#define CHNL_STS_BSYWR =A0 =A0 =A0(1 << 16)
>> +#define CHNL_STS_CURPERR =A0 =A0(1 << 17)
>> +#define CHNL_STS_NXTPERR =A0 =A0(1 << 18)
>> +#define CHNL_STS_ADDRERR =A0 =A0(1 << 19)
>> +#define CHNL_STS_CMPERR =A0 =A0 (1 << 20)
>> +#define CHNL_STS_TAILERR =A0 =A0(1 << 21)
>> +/*
>> + 0:9 =A0 =A0 =A022:31 =A0 Reserved
>> + 10 =A0 =A0 =A0 21 =A0 =A0 =A0TailPErr
>> + 11 =A0 =A0 =A0 20 =A0 =A0 =A0CmpErr
>> + 12 =A0 =A0 =A0 19 =A0 =A0 =A0AddrErr
>> + 13 =A0 =A0 =A0 18 =A0 =A0 =A0NxtPErr
>> + 14 =A0 =A0 =A0 17 =A0 =A0 =A0CurPErr
>> + 15 =A0 =A0 =A0 16 =A0 =A0 =A0BsyWr
>> + 16:23 =A0 =A08:15 =A0 =A0Reserved
>> + 24 =A0 =A0 =A0 7 =A0 =A0 =A0 Error
>> + 25 =A0 =A0 =A0 6 =A0 =A0 =A0 IOE
>> + 26 =A0 =A0 =A0 5 =A0 =A0 =A0 SOE
>> + 27 =A0 =A0 =A0 4 =A0 =A0 =A0 Cmplt
>> + 28 =A0 =A0 =A0 3 =A0 =A0 =A0 SOP
>> + 29 =A0 =A0 =A0 2 =A0 =A0 =A0 EOP
>> + 30 =A0 =A0 =A0 1 =A0 =A0 =A0 EngBusy
>> + 31 =A0 =A0 =A0 0 =A0 =A0 =A0 Reserved
>> +*/
>> +
>> +#define DMA_CONTROL_REG =A0 =A0 =A0 =A0 =A0 =A0 0x10 =A0 =A0 =A0 =A0=
 =A0 =A0/* rw */
>> +#define DMA_CONTROL_RST =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 0)
>> +#define DMA_TAIL_ENABLE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 2)
>> +
>> +/* XPS_LL_TEMAC direct registers definition */
>> +
>> +#define XTE_RAF0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x00
>> +#define RAF0_RST =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 =
<< 0)
>> +#define RAF0_MCSTREJ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 1=
)
>> +#define RAF0_BCSTREJ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 2=
)
>> +#define XTE_TPF0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x04
>> +#define XTE_IFGP0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 0x08
>> +#define XTE_ISR0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x0c
>> +#define ISR0_HARDACSCMPLT =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 0)
>> +#define ISR0_AUTONEG =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 1=
)
>> +#define ISR0_RXCMPLT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 2=
)
>> +#define ISR0_RXREJ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 <<=
 3)
>> +#define ISR0_RXFIFOOVR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 4)
>> +#define ISR0_TXCMPLT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 5=
)
>> +#define ISR0_RXDCMLCK =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 6)
>> +
>> +#define XTE_IPR0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x10
>> +#define XTE_IER0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x14
>> +
>> +#define XTE_MSW0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x20
>> +#define XTE_LSW0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x24
>> +#define XTE_CTL0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x28
>> +#define XTE_RDY0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x2c
>> +
>> +#define XTE_RSE_MIIM_RR_MASK =A0 =A0 =A00x0002
>> +#define XTE_RSE_MIIM_WR_MASK =A0 =A0 =A00x0004
>> +#define XTE_RSE_CFG_RR_MASK =A0 =A0 =A0 0x0020
>> +#define XTE_RSE_CFG_WR_MASK =A0 =A0 =A0 0x0040
>> +#define XTE_RDY0_HARD_ACS_RDY_MASK =A0(0x10000)
>> +
>> +/* XPS_LL_TEMAC indirect registers offset definition */
>> +
>> +#define =A0 =A0 =A0 =A0XTE_RXC0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0x00000200 /* Rx
>> configuration word 0 */
>> +#define =A0 =A0 =A0 =A0XTE_RXC1_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0x00000240 /* Rx
>> configuration word 1 */
>> +#define XTE_RXC1_RXRST_MASK =A0 =A0 =A0 =A0 =A0 =A0(1 << 31) =A0/* =
Receiver reset */
>> +#define XTE_RXC1_RXJMBO_MASK =A0 =A0 =A0 =A0 =A0 (1 << 30) =A0/* Ju=
mbo frame enable
>> */
>> +#define XTE_RXC1_RXFCS_MASK =A0 =A0 =A0 =A0 =A0 =A0(1 << 29) =A0/* =
=46CS not stripped
>> */
>> +#define XTE_RXC1_RXEN_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 28) =A0/* =
Receiver enable */
>> +#define XTE_RXC1_RXVLAN_MASK =A0 =A0 =A0 =A0 =A0 (1 << 27) =A0/* VL=
AN enable */
>> +#define XTE_RXC1_RXHD_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 26) =A0/* =
Half duplex */
>> +#define XTE_RXC1_RXLT_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 25) =A0/* =
Length/type check
>> disable */
>> +
>> +#define XTE_TXC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00000280 /=
* =A0Tx configuration
>> */
>> +#define XTE_TXC_TXRST_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 31) =A0/* =
Transmitter reset
>> */
>> +#define XTE_TXC_TXJMBO_MASK =A0 =A0 =A0 =A0 =A0 =A0(1 << 30) =A0/* =
Jumbo frame enable
>> */
>> +#define XTE_TXC_TXFCS_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 29) =A0/* =
Generate FCS */
>> +#define XTE_TXC_TXEN_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 28) =A0/=
* Transmitter enable
>> */
>> +#define XTE_TXC_TXVLAN_MASK =A0 =A0 =A0 =A0 =A0 =A0(1 << 27) =A0/* =
VLAN enable */
>> +#define XTE_TXC_TXHD_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << 26) =A0/=
* Half duplex */
>> +
>> +#define XTE_FCC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x000002C0 /=
* Flow control
>> config */
>> +#define XTE_FCC_RXFLO_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 29) =A0/* =
Rx flow control
>> enable */
>> +#define XTE_FCC_TXFLO_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 30) =A0/* =
Tx flow control
>> enable */
>> +
>> +#define XTE_EMCFG_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00000300 /* =
EMAC configuration
>> */
>> +#define XTE_EMCFG_LINKSPD_MASK =A0 =A0 =A0 =A0 0xC0000000 /* Link s=
peed */
>> +#define XTE_EMCFG_HOSTEN_MASK =A0 =A0 =A0 =A0 =A0(1 << 26) =A0/* Ho=
st interface
>> enable */
>> +#define XTE_EMCFG_LINKSPD_10 =A0 =A0 =A0 =A0 =A0 0x00000000 /* 10 M=
bit
>> LINKSPD_MASK */
>> +#define XTE_EMCFG_LINKSPD_100 =A0 =A0 =A0 =A0 =A0(1 << 30) =A0/* 10=
0 Mbit
>> LINKSPD_MASK */
>> +#define XTE_EMCFG_LINKSPD_1000 =A0 =A0 =A0 =A0 (1 << 31) =A0/* 1000=
 Mbit
>> LINKSPD_MASK */
>> +
>> +#define XTE_GMIC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x00000320 /*
>> RGMII/SGMII config */
>> +#define XTE_MC_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x00000340=
 /* MDIO configuration
>> */
>> +#define XTE_UAW0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x00000380 /* Unicast
>> address word 0 */
>> +#define XTE_UAW1_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x00000384 /* Unicast
>> address word 1 */
>> +
>> +#define XTE_MAW0_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x00000388 /* Multicast
>> addr word 0 */
>> +#define XTE_MAW1_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A00x0000038C /* Multicast
>> addr word 1 */
>> +#define XTE_AFM_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x00000390 /=
* Promiscuous mode
>> */
>> +#define XTE_AFM_EPPRM_MASK =A0 =A0 =A0 =A0 =A0 =A0 (1 << 31) =A0/* =
Promiscuous mode
>> enable */
>> +
>> +/* Interrupt Request status */
>> +#define XTE_TIS_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x000003A0
>> +#define TIS_FRIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
0)
>> +#define TIS_MRIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
1)
>> +#define TIS_MWIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
2)
>> +#define TIS_ARIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
3)
>> +#define TIS_AWIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
4)
>> +#define TIS_CRIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
5)
>> +#define TIS_CWIS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << =
6)
>> +
>> +#define XTE_TIE_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x000003A4 /=
* Interrupt enable
>> */
>> +
>> +/** =A0MII Mamagement Control register (MGTCR) */
>> +#define XTE_MGTDR_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x000003B0 /* =
MII data */
>> +#define XTE_MIIMAI_OFFSET =A0 =A0 =A0 =A0 =A0 =A0 =A00x000003B4 /* =
MII control */
>> +
>> +#define CNTLREG_WRITE_ENABLE_MASK =A0 0x8000
>> +#define CNTLREG_EMAC1SEL_MASK =A0 =A0 =A0 0x0400
>> +#define CNTLREG_ADDRESSCODE_MASK =A0 =A00x03ff
>> +
>> +/* CDMAC descriptor status bit definitions */
>> +
>> +#define STS_CTRL_APP0_ERR =A0 =A0 =A0 =A0 (1 << 31)
>> +#define STS_CTRL_APP0_IRQONEND =A0 =A0(1 << 30)
>> +/* undoccumented */
>> +#define STS_CTRL_APP0_STOPONEND =A0 (1 << 29)
>> +#define STS_CTRL_APP0_CMPLT =A0 =A0 =A0 (1 << 28)
>> +#define STS_CTRL_APP0_SOP =A0 =A0 =A0 =A0 (1 << 27)
>> +#define STS_CTRL_APP0_EOP =A0 =A0 =A0 =A0 (1 << 26)
>> +#define STS_CTRL_APP0_ENGBUSY =A0 =A0 (1 << 25)
>> +/* undocumented */
>> +#define STS_CTRL_APP0_ENGRST =A0 =A0 =A0(1 << 24)
>> +
>> +#define TX_CONTROL_CALC_CSUM_MASK =A0 1
>> +
>> +#define XTE_ALIGN =A0 =A0 =A0 32
>> +#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
>> +
>> +#define MULTICAST_CAM_TABLE_NUM 4
>> +
>> +/* TX/RX CURDESC_PTR points to first descriptor */
>> +/* TX/RX TAILDESC_PTR points to last descriptor in linked list */
>> +
>> +/**
>> + * struct cdmac_bd - LocalLink buffer descriptor format
>> + *
>> + * app0 bits:
>> + * =A0 =A0 0 =A0 =A0Error
>> + * =A0 =A0 1 =A0 =A0IrqOnEnd =A0 =A0generate an interrupt at comple=
tion of DMA =A0op
>> + * =A0 =A0 2 =A0 =A0reserved
>> + * =A0 =A0 3 =A0 =A0completed =A0 Current descriptor completed
>> + * =A0 =A0 4 =A0 =A0SOP =A0 =A0 =A0 =A0 TX - marks first desc/ RX m=
arks first desct
>> + * =A0 =A0 5 =A0 =A0EOP =A0 =A0 =A0 =A0 TX marks last desc/RX marks=
 last desc
>> + * =A0 =A0 6 =A0 =A0EngBusy =A0 =A0 DMA is processing
>> + * =A0 =A0 7 =A0 =A0reserved
>> + * =A0 =A0 8:31 application specific
>> + */
>> +struct cdmac_bd {
>> + =A0 =A0 =A0 u32 next; =A0 =A0 =A0 /* Physical address of next buff=
er descriptor */
>> + =A0 =A0 =A0 u32 phys;
>> + =A0 =A0 =A0 u32 len;
>> + =A0 =A0 =A0 u32 app0;
>> + =A0 =A0 =A0 u32 app1; =A0 =A0 =A0 /* TX start << 16 | insert */
>> + =A0 =A0 =A0 u32 app2; =A0 =A0 =A0 /* TX csum */
>> + =A0 =A0 =A0 u32 app3;
>> + =A0 =A0 =A0 u32 app4; =A0 =A0 =A0 /* skb for TX length for RX */
>> +};
>> +
>> +struct temac_local {
>> + =A0 =A0 =A0 struct net_device *ndev;
>> + =A0 =A0 =A0 struct device *dev;
>> +
>> + =A0 =A0 =A0 /* Connection to PHY device */
>> + =A0 =A0 =A0 struct phy_device *phy_dev; =A0 =A0 /* Pointer to PHY =
device */
>> + =A0 =A0 =A0 struct device_node *phy_node;
>> +
>> + =A0 =A0 =A0 /* MDIO bus data */
>> + =A0 =A0 =A0 struct mii_bus *mii_bus; =A0 =A0 =A0 =A0/* MII bus ref=
erence */
>> + =A0 =A0 =A0 int mdio_irqs[PHY_MAX_ADDR]; =A0 =A0/* IRQs table for =
MDIO bus */
>> +
>> + =A0 =A0 =A0 /* IO registers and IRQs */
>> + =A0 =A0 =A0 void __iomem *regs;
>> + =A0 =A0 =A0 dcr_host_t sdma_dcrs;
>> + =A0 =A0 =A0 int tx_irq;
>> + =A0 =A0 =A0 int rx_irq;
>> + =A0 =A0 =A0 int emac_num;
>> +
>> + =A0 =A0 =A0 struct sk_buff **rx_skb;
>> + =A0 =A0 =A0 spinlock_t rx_lock;
>> + =A0 =A0 =A0 struct mutex indirect_mutex;
>> + =A0 =A0 =A0 u32 options; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*=
 Current options word */
>> + =A0 =A0 =A0 int last_link;
>> +
>> + =A0 =A0 =A0 /* Buffer descriptors */
>> + =A0 =A0 =A0 struct cdmac_bd *tx_bd_v;
>> + =A0 =A0 =A0 dma_addr_t tx_bd_p;
>> + =A0 =A0 =A0 struct cdmac_bd *rx_bd_v;
>> + =A0 =A0 =A0 dma_addr_t rx_bd_p;
>> + =A0 =A0 =A0 int tx_bd_ci;
>> + =A0 =A0 =A0 int tx_bd_next;
>> + =A0 =A0 =A0 int tx_bd_tail;
>> + =A0 =A0 =A0 int rx_bd_ci;
>> +};
>> +
>> +/* xilinx_temac.c */
>> +u32 temac_ior(struct temac_local *lp, int offset);
>> +void temac_iow(struct temac_local *lp, int offset, u32 value);
>> +int temac_indirect_busywait(struct temac_local *lp);
>> +u32 temac_indirect_in32(struct temac_local *lp, int reg);
>> +void temac_indirect_out32(struct temac_local *lp, int reg, u32 valu=
e);
>> +
>> +
>> +/* xilinx_temac_mdio.c */
>> +int temac_mdio_setup(struct temac_local *lp, struct device_node *np=
);
>> +void temac_mdio_teardown(struct temac_local *lp);
>> +
>> +#endif /* XILINX_TEMAC_H */
>> diff --git a/drivers/net/xilinx_temac_mdio.c
>> b/drivers/net/xilinx_temac_mdio.c
>> new file mode 100644
>> index 0000000..eeea61b
>> --- /dev/null
>> +++ b/drivers/net/xilinx_temac_mdio.c
>> @@ -0,0 +1,119 @@
>> +/*
>> + * MDIO bus driver for the Xilinx TEMAC device
>> + *
>> + * Copyright (c) 2009 Secret Lab Technologies, Ltd.
>> + */
>> +
>> +#include <linux/io.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/mutex.h>
>> +#include <linux/phy.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_mdio.h>
>> +#include "xilinx_temac.h"
>> +
>> +/*
>> --------------------------------------------------------------------=
-
>> + * MDIO Bus functions
>> + */
>> +static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg=
)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D bus->priv;
>> + =A0 =A0 =A0 u32 rc;
>> +
>> + =A0 =A0 =A0 /* Write the PHY address to the MIIM Access Initiator =
register.
>> + =A0 =A0 =A0 =A0* When the transfer completes, the PHY register val=
ue will
>> appear
>> + =A0 =A0 =A0 =A0* in the LSW0 register */
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 temac_iow(lp, XTE_LSW0_OFFSET, (phy_id << 5) | reg);
>> + =A0 =A0 =A0 rc =3D temac_indirect_in32(lp, XTE_MIIMAI_OFFSET);
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 dev_dbg(lp->dev, "temac_mdio_read(phy_id=3D%i, reg=3D%=
x) =3D=3D %x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, rc);
>> +
>> + =A0 =A0 =A0 return rc;
>> +}
>> +
>> +static int temac_mdio_write(struct mii_bus *bus, int phy_id, int re=
g,
>> u16 val)
>> +{
>> + =A0 =A0 =A0 struct temac_local *lp =3D bus->priv;
>> +
>> + =A0 =A0 =A0 dev_dbg(lp->dev, "temac_mdio_write(phy_id=3D%i, reg=3D=
%x,
>> val=3D%x)\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, val);
>> +
>> + =A0 =A0 =A0 /* First write the desired value into the write data r=
egister
>> + =A0 =A0 =A0 =A0* and then write the address into the access initia=
tor register
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_MGTDR_OFFSET, val);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_MIIMAI_OFFSET, (phy_id <<=
 5) |
>> reg);
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +int temac_mdio_setup(struct temac_local *lp, struct device_node *np=
)
>> +{
>> + =A0 =A0 =A0 struct mii_bus *bus;
>> + =A0 =A0 =A0 const u32 *bus_hz;
>> + =A0 =A0 =A0 int clk_div;
>> + =A0 =A0 =A0 int rc, size;
>> + =A0 =A0 =A0 struct resource res;
>> +
>> + =A0 =A0 =A0 /* Calculate a reasonable divisor for the clock rate *=
/
>> + =A0 =A0 =A0 clk_div =3D 0x3f; /* worst-case default setting */
>> + =A0 =A0 =A0 bus_hz =3D of_get_property(np, "clock-frequency", &siz=
e);
>> + =A0 =A0 =A0 if (bus_hz && size >=3D sizeof(*bus_hz)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clk_div =3D (*bus_hz) / (2500 * 1000 *=
 2) - 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clk_div < 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clk_div =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (clk_div > 0x3f)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clk_div =3D 0x3f;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 /* Enable the MDIO bus by asserting the enable bit and=
 writing
>> + =A0 =A0 =A0 =A0* in the clock config */
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 temac_indirect_out32(lp, XTE_MC_OFFSET, 1 << 6 | clk_d=
iv);
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> +
>> + =A0 =A0 =A0 bus =3D mdiobus_alloc();
>> + =A0 =A0 =A0 if (!bus)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> +
>> + =A0 =A0 =A0 of_address_to_resource(np, 0, &res);
>> + =A0 =A0 =A0 snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long long)res.start);
>> + =A0 =A0 =A0 bus->priv =3D lp;
>> + =A0 =A0 =A0 bus->name =3D "Xilinx TEMAC MDIO";
>> + =A0 =A0 =A0 bus->read =3D temac_mdio_read;
>> + =A0 =A0 =A0 bus->write =3D temac_mdio_write;
>> + =A0 =A0 =A0 bus->parent =3D lp->dev;
>> + =A0 =A0 =A0 bus->irq =3D lp->mdio_irqs; /* preallocated IRQ table =
*/
>> +
>> + =A0 =A0 =A0 lp->mii_bus =3D bus;
>> +
>> + =A0 =A0 =A0 rc =3D of_mdiobus_register(bus, np);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_register;
>> +
>> + =A0 =A0 =A0 mutex_lock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 dev_dbg(lp->dev, "MDIO bus registered; =A0MC:%x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 temac_indirect_in32(lp, XTE_MC_OFFSET)=
);
>> + =A0 =A0 =A0 mutex_unlock(&lp->indirect_mutex);
>> + =A0 =A0 =A0 return 0;
>> +
>> + err_register:
>> + =A0 =A0 =A0 mdiobus_free(bus);
>> + =A0 =A0 =A0 return rc;
>> +}
>> +
>> +void temac_mdio_teardown(struct temac_local *lp)
>> +{
>> + =A0 =A0 =A0 mdiobus_unregister(lp->mii_bus);
>> + =A0 =A0 =A0 kfree(lp->mii_bus->irq);
>> + =A0 =A0 =A0 mdiobus_free(lp->mii_bus);
>> + =A0 =A0 =A0 lp->mii_bus =3D NULL;
>> +}
>> +
>>
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@ozlabs.org
>> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>>
>>
>> This email and any attachments are intended for the sole use of the =
named recipient(s) and contain(s) confidential information that may be =
proprietary, privileged or copyrighted under applicable law. If you are=
 not the intended recipient, do not read, copy, or forward this email m=
essage or any attachments. Delete this email message and any attachment=
s immediately.
>>
>>
>>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
