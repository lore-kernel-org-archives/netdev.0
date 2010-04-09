From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] [V5] Add non-Virtex5 support for LL TEMAC driver
Date: Fri, 9 Apr 2010 12:10:21 -0600
Message-ID: <x2sfa686aa41004091110l87cd2234rc68906080fc4fe03@mail.gmail.com>
References: <1270746482-29914-1-git-send-email-john.linn@xilinx.com>
	<960dddba-8a63-4480-8245-f06fad59ab36@SG2EHSMHS005.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jwboyer@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>,
	David Miller <davem@davemloft.net>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:36384 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359Ab0DISKm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 14:10:42 -0400
Received: by iwn35 with SMTP id 35so2504259iwn.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 11:10:41 -0700 (PDT)
In-Reply-To: <960dddba-8a63-4480-8245-f06fad59ab36@SG2EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 8, 2010 at 11:08 AM, John Linn <john.linn@xilinx.com> wrote=
:
> This patch adds support for using the LL TEMAC Ethernet driver on
> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> registers as if they were memory mapped instead of solely through the
> DCR's (available on the Virtex 5).
>
> The patch also updates the driver so that it runs on the MicroBlaze.
> The changes were tested on the PowerPC 440, PowerPC 405, and the
> MicroBlaze platforms.
>
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Signed-off-by: John Linn <john.linn@xilinx.com>

Picked up and build tested both patches on 405, 440, 60x and ppc64.
No build problems found either built-in or as a module.

for both:
Acked-by: Grant Likely <grant.likely@secretlab.ca>

g.

>
> ---
>
> V2 - Incorporated comments from Grant and added more logic to allow t=
he driver
> to work on MicroBlaze.
>
> V3 - Only updated it to apply to head, minor change to include slab.h=
=2E Also
> verified that it now builds for MicroBlaze. Retested on PowerPC and M=
icroBlaze.
>
> V4 - Removed buffer alignment for skb and called the network function=
s that
> already do the alignment for cache line and word alignment. Added con=
stants
> to MicroBlaze system to make sure network alignment is maintained. Al=
so updated
> the Kconfig so it depends on Microblaze or PPC based on Grant's comme=
nt.
>
> V5 - Respun the patch on top of a new patch to the driver which remov=
ed the
> call to virt_to_bus as it's now illegal and caused a failure when bui=
lding
> the driver in linux-next. Retested with 440, 405 and Microblaze.
>
> Grant, can you do a build test to verify no build issues?
> ---
> =A0arch/microblaze/include/asm/system.h | =A0 11 +++
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 =
+-
> =A0drivers/net/ll_temac.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 14 +++-
> =A0drivers/net/ll_temac_main.c =A0 =A0 =A0 =A0 =A0| =A0137 ++++++++++=
+++++++++++++++--------
> =A04 files changed, 126 insertions(+), 38 deletions(-)
>
> diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/i=
nclude/asm/system.h
> index 59efb3f..48c4f03 100644
> --- a/arch/microblaze/include/asm/system.h
> +++ b/arch/microblaze/include/asm/system.h
> @@ -12,6 +12,7 @@
> =A0#include <asm/registers.h>
> =A0#include <asm/setup.h>
> =A0#include <asm/irqflags.h>
> +#include <asm/cache.h>
>
> =A0#include <asm-generic/cmpxchg.h>
> =A0#include <asm-generic/cmpxchg-local.h>
> @@ -96,4 +97,14 @@ extern struct dentry *of_debugfs_root;
>
> =A0#define arch_align_stack(x) (x)
>
> +/*
> + * MicroBlaze doesn't handle unaligned accesses in hardware.
> + *
> + * Based on this we force the IP header alignment in network drivers=
=2E
> + * We also modify NET_SKB_PAD to be a cacheline in size, thus mainta=
ining
> + * cacheline alignment of buffers.
> + */
> +#define NET_IP_ALIGN =A0 2
> +#define NET_SKB_PAD =A0 =A0L1_CACHE_BYTES
> +
> =A0#endif /* _ASM_MICROBLAZE_SYSTEM_H */
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 7b832c7..9073741 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2434,8 +2434,8 @@ config MV643XX_ETH
>
> =A0config XILINX_LL_TEMAC
> =A0 =A0 =A0 =A0tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet=
 MAC) driver"
> + =A0 =A0 =A0 depends on PPC || MICROBLAZE
> =A0 =A0 =A0 =A0select PHYLIB
> - =A0 =A0 =A0 depends on PPC_DCR_NATIVE
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0This driver supports the Xilinx 10/100/1000 LocalL=
ink TEMAC
> =A0 =A0 =A0 =A0 =A0core used in Xilinx Spartan and Virtex FPGAs
> diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> index 1af66a1..c033584 100644
> --- a/drivers/net/ll_temac.h
> +++ b/drivers/net/ll_temac.h
> @@ -5,8 +5,11 @@
> =A0#include <linux/netdevice.h>
> =A0#include <linux/of.h>
> =A0#include <linux/spinlock.h>
> +
> +#ifdef CONFIG_PPC_DCR
> =A0#include <asm/dcr.h>
> =A0#include <asm/dcr-regs.h>
> +#endif
>
> =A0/* packet size info */
> =A0#define XTE_HDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 14 =A0 =A0=
 =A0/* size of Ethernet header */
> @@ -290,9 +293,6 @@ This option defaults to enabled (set) */
>
> =A0#define TX_CONTROL_CALC_CSUM_MASK =A0 1
>
> -#define XTE_ALIGN =A0 =A0 =A0 32
> -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
> -
> =A0#define MULTICAST_CAM_TABLE_NUM 4
>
> =A0/* TX/RX CURDESC_PTR points to first descriptor */
> @@ -335,9 +335,15 @@ struct temac_local {
> =A0 =A0 =A0 =A0struct mii_bus *mii_bus; =A0 =A0 =A0 =A0/* MII bus ref=
erence */
> =A0 =A0 =A0 =A0int mdio_irqs[PHY_MAX_ADDR]; =A0 =A0/* IRQs table for =
MDIO bus */
>
> - =A0 =A0 =A0 /* IO registers and IRQs */
> + =A0 =A0 =A0 /* IO registers, dma functions and IRQs */
> =A0 =A0 =A0 =A0void __iomem *regs;
> + =A0 =A0 =A0 void __iomem *sdma_regs;
> +#ifdef CONFIG_PPC_DCR
> =A0 =A0 =A0 =A0dcr_host_t sdma_dcrs;
> +#endif
> + =A0 =A0 =A0 u32 (*dma_in)(struct temac_local *, int);
> + =A0 =A0 =A0 void (*dma_out)(struct temac_local *, int, u32);
> +
> =A0 =A0 =A0 =A0int tx_irq;
> =A0 =A0 =A0 =A0int rx_irq;
> =A0 =A0 =A0 =A0int emac_num;
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.=
c
> index ce9aa78..2b69d6c 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -20,9 +20,6 @@
> =A0* =A0 or rx, so this should be okay.
> =A0*
> =A0* TODO:
> - * - Fix driver to work on more than just Virtex5. =A0Right now the =
driver
> - * =A0 assumes that the locallink DMA registers are accessed via DCR
> - * =A0 instructions.
> =A0* - Factor out locallink DMA code into separate driver
> =A0* - Fix multicast assignment.
> =A0* - Fix support for hardware checksumming.
> @@ -116,17 +113,86 @@ void temac_indirect_out32(struct temac_local *l=
p, int reg, u32 value)
> =A0 =A0 =A0 =A0temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MA=
SK | reg);
> =A0}
>
> +/**
> + * temac_dma_in32 - Memory mapped DMA read, this function expects a
> + * register input that is based on DCR word addresses which
> + * are then converted to memory mapped byte addresses
> + */
> =A0static u32 temac_dma_in32(struct temac_local *lp, int reg)
> =A0{
> - =A0 =A0 =A0 return dcr_read(lp->sdma_dcrs, reg);
> + =A0 =A0 =A0 return in_be32((u32 *)(lp->sdma_regs + (reg << 2)));
> =A0}
>
> +/**
> + * temac_dma_out32 - Memory mapped DMA read, this function expects a
> + * register input that is based on DCR word addresses which
> + * are then converted to memory mapped byte addresses
> + */
> =A0static void temac_dma_out32(struct temac_local *lp, int reg, u32 v=
alue)
> =A0{
> + =A0 =A0 =A0 out_be32((u32 *)(lp->sdma_regs + (reg << 2)), value);
> +}
> +
> +/* DMA register access functions can be DCR based or memory mapped.
> + * The PowerPC 440 is DCR based, the PowerPC 405 and MicroBlaze are =
both
> + * memory mapped.
> + */
> +#ifdef CONFIG_PPC_DCR
> +
> +/**
> + * temac_dma_dcr_in32 - DCR based DMA read
> + */
> +static u32 temac_dma_dcr_in(struct temac_local *lp, int reg)
> +{
> + =A0 =A0 =A0 return dcr_read(lp->sdma_dcrs, reg);
> +}
> +
> +/**
> + * temac_dma_dcr_out32 - DCR based DMA write
> + */
> +static void temac_dma_dcr_out(struct temac_local *lp, int reg, u32 v=
alue)
> +{
> =A0 =A0 =A0 =A0dcr_write(lp->sdma_dcrs, reg, value);
> =A0}
>
> =A0/**
> + * temac_dcr_setup - If the DMA is DCR based, then setup the address=
 and
> + * I/O =A0functions
> + */
> +static int temac_dcr_setup(struct temac_local *lp, struct of_device =
*op,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
device_node *np)
> +{
> + =A0 =A0 =A0 unsigned int dcrs;
> +
> + =A0 =A0 =A0 /* setup the dcr address mapping if it's in the device =
tree */
> +
> + =A0 =A0 =A0 dcrs =3D dcr_resource_start(np, 0);
> + =A0 =A0 =A0 if (dcrs !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr=
_resource_len(np, 0));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->dma_in =3D temac_dma_dcr_in;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->dma_out =3D temac_dma_dcr_out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(&op->dev, "DCR base: %x\n", dcr=
s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* no DCR in the device tree, indicate a failure */
> + =A0 =A0 =A0 return -1;
> +}
> +
> +#else
> +
> +/*
> + * temac_dcr_setup - This is a stub for when DCR is not supported,
> + * such as with MicroBlaze
> + */
> +static int temac_dcr_setup(struct temac_local *lp, struct of_device =
*op,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
device_node *np)
> +{
> + =A0 =A0 =A0 return -1;
> +}
> +
> +#endif
> +
> +/**
> =A0* temac_dma_bd_init - Setup buffer descriptor rings
> =A0*/
> =A0static int temac_dma_bd_init(struct net_device *ndev)
> @@ -156,14 +222,14 @@ static int temac_dma_bd_init(struct net_device =
*ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_bd_v[i].next =3D lp->rx_bd_p +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof=
(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(XTE_MAX_JUMBO_FRAME_S=
IZE
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + XTE_A=
LIGN, GFP_ATOMIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb_ip_align(ndev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 XTE_MAX_JUMBO_FRAME_SIZE);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev, "a=
lloc_skb error %d\n", i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_skb[i] =3D skb;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, =A0BUFFER_ALIGN(skb->d=
ata));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* returns physical address of skb->da=
ta */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_bd_v[i].phys =3D dma_map_single=
(ndev->dev.parent,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data,
> @@ -173,23 +239,23 @@ static int temac_dma_bd_init(struct net_device =
*ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_bd_v[i].app0 =3D STS_CTRL_APP0_=
IRQONEND;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 temac_dma_out32(lp, TX_CHNL_CTRL, 0x10220400 |
> + =A0 =A0 =A0 lp->dma_out(lp, TX_CHNL_CTRL, 0x10220400 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_EN |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_DLY_EN |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_COAL_EN);
> =A0 =A0 =A0 =A0/* 0x10220483 */
> =A0 =A0 =A0 =A0/* 0x00100483 */
> - =A0 =A0 =A0 temac_dma_out32(lp, RX_CHNL_CTRL, 0xff010000 |
> + =A0 =A0 =A0 lp->dma_out(lp, RX_CHNL_CTRL, 0xff010000 |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_EN |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_DLY_EN |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_COAL_EN |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0CHNL_CTRL_IRQ_IOE);
> =A0 =A0 =A0 =A0/* 0xff010283 */
>
> - =A0 =A0 =A0 temac_dma_out32(lp, RX_CURDESC_PTR, =A0lp->rx_bd_p);
> - =A0 =A0 =A0 temac_dma_out32(lp, RX_TAILDESC_PTR,
> + =A0 =A0 =A0 lp->dma_out(lp, RX_CURDESC_PTR, =A0lp->rx_bd_p);
> + =A0 =A0 =A0 lp->dma_out(lp, RX_TAILDESC_PTR,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_bd_p + (sizeof(*lp=
->rx_bd_v) * (RX_BD_NUM - 1)));
> - =A0 =A0 =A0 temac_dma_out32(lp, TX_CURDESC_PTR, lp->tx_bd_p);
> + =A0 =A0 =A0 lp->dma_out(lp, TX_CURDESC_PTR, lp->tx_bd_p);
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -427,9 +493,9 @@ static void temac_device_reset(struct net_device =
*ndev)
> =A0 =A0 =A0 =A0temac_indirect_out32(lp, XTE_RXC1_OFFSET, val & ~XTE_R=
XC1_RXEN_MASK);
>
> =A0 =A0 =A0 =A0/* Reset Local Link (DMA) */
> - =A0 =A0 =A0 temac_dma_out32(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
> + =A0 =A0 =A0 lp->dma_out(lp, DMA_CONTROL_REG, DMA_CONTROL_RST);
> =A0 =A0 =A0 =A0timeout =3D 1000;
> - =A0 =A0 =A0 while (temac_dma_in32(lp, DMA_CONTROL_REG) & DMA_CONTRO=
L_RST) {
> + =A0 =A0 =A0 while (lp->dma_in(lp, DMA_CONTROL_REG) & DMA_CONTROL_RS=
T) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0udelay(1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (--timeout =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev,
> @@ -437,7 +503,7 @@ static void temac_device_reset(struct net_device =
*ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 temac_dma_out32(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
> + =A0 =A0 =A0 lp->dma_out(lp, DMA_CONTROL_REG, DMA_TAIL_ENABLE);
>
> =A0 =A0 =A0 =A0temac_dma_bd_init(ndev);
>
> @@ -598,7 +664,7 @@ static int temac_start_xmit(struct sk_buff *skb, =
struct net_device *ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->tx_bd_tail =3D 0;
>
> =A0 =A0 =A0 =A0/* Kick off the transfer */
> - =A0 =A0 =A0 temac_dma_out32(lp, TX_TAILDESC_PTR, tail_p); /* DMA st=
art */
> + =A0 =A0 =A0 lp->dma_out(lp, TX_TAILDESC_PTR, tail_p); /* DMA start =
*/
>
> =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0}
> @@ -638,16 +704,15 @@ static void ll_temac_recv(struct net_device *nd=
ev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ndev->stats.rx_packets++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ndev->stats.rx_bytes +=3D length;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_skb =3D alloc_skb(XTE_MAX_JUMBO_FRA=
ME_SIZE + XTE_ALIGN,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_ATO=
MIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_skb =3D netdev_alloc_skb_ip_align(n=
dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 XTE_MAX_JUMBO_FRAME_SIZE);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (new_skb =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev, "n=
o memory for new sk_buff\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore=
(&lp->rx_lock, flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(new_skb, BUFFER_ALIGN(new_s=
kb->data));
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur_p->app0 =3D STS_CTRL_APP0_IRQONEND=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur_p->phys =3D dma_map_single(ndev->d=
ev.parent, new_skb->data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 XTE_MAX_JUMBO_FRAME_SIZE,
> @@ -662,7 +727,7 @@ static void ll_temac_recv(struct net_device *ndev=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur_p =3D &lp->rx_bd_v[lp->rx_bd_ci];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdstat =3D cur_p->app0;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 temac_dma_out32(lp, RX_TAILDESC_PTR, tail_p);
> + =A0 =A0 =A0 lp->dma_out(lp, RX_TAILDESC_PTR, tail_p);
>
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&lp->rx_lock, flags);
> =A0}
> @@ -673,8 +738,8 @@ static irqreturn_t ll_temac_tx_irq(int irq, void =
*_ndev)
> =A0 =A0 =A0 =A0struct temac_local *lp =3D netdev_priv(ndev);
> =A0 =A0 =A0 =A0unsigned int status;
>
> - =A0 =A0 =A0 status =3D temac_dma_in32(lp, TX_IRQ_REG);
> - =A0 =A0 =A0 temac_dma_out32(lp, TX_IRQ_REG, status);
> + =A0 =A0 =A0 status =3D lp->dma_in(lp, TX_IRQ_REG);
> + =A0 =A0 =A0 lp->dma_out(lp, TX_IRQ_REG, status);
>
> =A0 =A0 =A0 =A0if (status & (IRQ_COAL | IRQ_DLY))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0temac_start_xmit_done(lp->ndev);
> @@ -691,8 +756,8 @@ static irqreturn_t ll_temac_rx_irq(int irq, void =
*_ndev)
> =A0 =A0 =A0 =A0unsigned int status;
>
> =A0 =A0 =A0 =A0/* Read and clear the status registers */
> - =A0 =A0 =A0 status =3D temac_dma_in32(lp, RX_IRQ_REG);
> - =A0 =A0 =A0 temac_dma_out32(lp, RX_IRQ_REG, status);
> + =A0 =A0 =A0 status =3D lp->dma_in(lp, RX_IRQ_REG);
> + =A0 =A0 =A0 lp->dma_out(lp, RX_IRQ_REG, status);
>
> =A0 =A0 =A0 =A0if (status & (IRQ_COAL | IRQ_DLY))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ll_temac_recv(lp->ndev);
> @@ -793,7 +858,7 @@ static ssize_t temac_show_llink_regs(struct devic=
e *dev,
> =A0 =A0 =A0 =A0int i, len =3D 0;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < 0x11; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D sprintf(buf + len, "%.8x%s", t=
emac_dma_in32(lp, i),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D sprintf(buf + len, "%.8x%s", l=
p->dma_in(lp, i),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (i % 8) =3D=
=3D 7 ? "\n" : " ");
> =A0 =A0 =A0 =A0len +=3D sprintf(buf + len, "\n");
>
> @@ -819,7 +884,6 @@ temac_of_probe(struct of_device *op, const struct=
 of_device_id *match)
> =A0 =A0 =A0 =A0struct net_device *ndev;
> =A0 =A0 =A0 =A0const void *addr;
> =A0 =A0 =A0 =A0int size, rc =3D 0;
> - =A0 =A0 =A0 unsigned int dcrs;
>
> =A0 =A0 =A0 =A0/* Init network device structure */
> =A0 =A0 =A0 =A0ndev =3D alloc_etherdev(sizeof(*lp));
> @@ -869,13 +933,20 @@ temac_of_probe(struct of_device *op, const stru=
ct of_device_id *match)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nodev;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 dcrs =3D dcr_resource_start(np, 0);
> - =A0 =A0 =A0 if (dcrs =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not get DMA re=
gister address\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
> + =A0 =A0 =A0 /* Setup the DMA register accesses, could be DCR or mem=
ory mapped */
> + =A0 =A0 =A0 if (temac_dcr_setup(lp, op, np)) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* no DCR in the device tree, try non-D=
CR */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->sdma_regs =3D of_iomap(np, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->sdma_regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->dma_in =3D temac_dm=
a_in32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->dma_out =3D temac_d=
ma_out32;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(&op->dev, "MEM =
base: %p\n", lp->sdma_regs);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "unab=
le to map DMA registers\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr_resource_len(np=
, 0));
> - =A0 =A0 =A0 dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
>
> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
> --
> 1.6.2.1
>
>
>
> This email and any attachments are intended for the sole use of the n=
amed recipient(s) and contain(s) confidential information that may be p=
roprietary, privileged or copyrighted under applicable law. If you are =
not the intended recipient, do not read, copy, or forward this email me=
ssage or any attachments. Delete this email message and any attachments=
 immediately.
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
