From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [patch 3/5] LL TEMAC driver: add non-Virtex 5 support
Date: Thu, 11 Mar 2010 15:10:45 -0700
Message-ID: <fa686aa41003111410v41e5fe23x3685bf71339d5209@mail.gmail.com>
References: <201003112207.o2BM7qhv013492@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, jtyner@cs.ucr.edu,
	afleming@freescale.com, John Linn <John.Linn@xilinx.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:60774 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758466Ab0CKWLG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:11:06 -0500
Received: by iwn12 with SMTP id 12so581373iwn.21
        for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 14:11:05 -0800 (PST)
In-Reply-To: <201003112207.o2BM7qhv013492@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 11, 2010 at 3:07 PM,  <akpm@linux-foundation.org> wrote:
> From: John Tyner <jtyner@cs.ucr.edu>
>
> Add support for using the LL TEMAC Ethernet driver on non-Virtex 5
> platforms by adding support for accessing the Soft DMA registers as i=
f
> they were memory mapped instead of solely through the DCR's (availabl=
e on
> the Virtex 5).

Thanks Andrew.  Changes were requested on this one, but IIRC John
Tyner doesn't have any bandwidth to work on it.  John Linn from Xilinx
has adopted the patch and is fixing it up.

g.

>
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Cc: Andy Fleming <afleming@freescale.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
> =A0drivers/net/ll_temac.h =A0 =A0 =A0| =A0 =A01 +
> =A0drivers/net/ll_temac_main.c | =A0 31 ++++++++++++++++++++---------=
--
> =A02 files changed, 21 insertions(+), 11 deletions(-)
>
> diff -puN drivers/net/ll_temac.h~ll-temac-driver-add-non-virtex-5-sup=
port drivers/net/ll_temac.h
> --- a/drivers/net/ll_temac.h~ll-temac-driver-add-non-virtex-5-support
> +++ a/drivers/net/ll_temac.h
> @@ -338,6 +338,7 @@ struct temac_local {
> =A0 =A0 =A0 =A0/* IO registers and IRQs */
> =A0 =A0 =A0 =A0void __iomem *regs;
> =A0 =A0 =A0 =A0dcr_host_t sdma_dcrs;
> + =A0 =A0 =A0 u32 __iomem *sdma_regs;
> =A0 =A0 =A0 =A0int tx_irq;
> =A0 =A0 =A0 =A0int rx_irq;
> =A0 =A0 =A0 =A0int emac_num;
> diff -puN drivers/net/ll_temac_main.c~ll-temac-driver-add-non-virtex-=
5-support drivers/net/ll_temac_main.c
> --- a/drivers/net/ll_temac_main.c~ll-temac-driver-add-non-virtex-5-su=
pport
> +++ a/drivers/net/ll_temac_main.c
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
> @@ -117,12 +114,20 @@ void temac_indirect_out32(struct temac_l
>
> =A0static u32 temac_dma_in32(struct temac_local *lp, int reg)
> =A0{
> - =A0 =A0 =A0 return dcr_read(lp->sdma_dcrs, reg);
> + =A0 =A0 =A0 if (lp->sdma_regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return __raw_readl(lp->sdma_regs + reg)=
;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dcr_read(lp->sdma_dcrs, reg);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0static void temac_dma_out32(struct temac_local *lp, int reg, u32 v=
alue)
> =A0{
> - =A0 =A0 =A0 dcr_write(lp->sdma_dcrs, reg, value);
> + =A0 =A0 =A0 if (lp->sdma_regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __raw_writel(value, lp->sdma_regs + reg=
);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dcr_write(lp->sdma_dcrs, reg, value);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0/**
> @@ -870,13 +875,17 @@ temac_of_probe(struct of_device *op, con
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nodev;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 dcrs =3D dcr_resource_start(np, 0);
> - =A0 =A0 =A0 if (dcrs =3D=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not get DMA re=
gister address\n");
> + =A0 =A0 =A0 lp->sdma_regs =3D NULL;
> +
> + =A0 =A0 =A0 if ((dcrs =3D dcr_resource_start(np, 0)) !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr=
_resource_len(np, 0));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(&op->dev, "DCR base: %x\n", dcr=
s);
> + =A0 =A0 =A0 } else if ((lp->sdma_regs =3D of_iomap(np, 0))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(&op->dev, "MEM base: %p\n", lp-=
>sdma_regs);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "unable to map DMA re=
gisters\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nodev;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr_resource_len(np=
, 0));
> - =A0 =A0 =A0 dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
>
> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
> @@ -903,7 +912,7 @@ temac_of_probe(struct of_device *op, con
>
> =A0 =A0 =A0 =A0lp->phy_node =3D of_parse_phandle(op->node, "phy-handl=
e", 0);
> =A0 =A0 =A0 =A0if (lp->phy_node)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(lp->dev, "using PHY node %s (%p=
)\n", np->full_name, np);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(lp->dev, "using PHY node %s (%p=
)\n", lp->phy_node->full_name, lp->phy_node);
>
> =A0 =A0 =A0 =A0/* Add the device attributes */
> =A0 =A0 =A0 =A0rc =3D sysfs_create_group(&lp->dev->kobj, &temac_attr_=
group);
> _
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
