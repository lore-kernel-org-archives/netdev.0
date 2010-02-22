From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/5] temac: dma init for Virtex4
Date: Mon, 22 Feb 2010 15:23:40 -0700
Message-ID: <fa686aa41002221423g74349c60k7602f47b9e946018@mail.gmail.com>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
	<1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: gfilip@ee.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:38602 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab0BVWYE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 17:24:04 -0500
Received: by ywh35 with SMTP id 35so1488935ywh.4
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 14:24:04 -0800 (PST)
In-Reply-To: <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2010 at 12:06 PM,  <gfilip@ee.ethz.ch> wrote:
> This patch belongs to a set of patches which extends the temac driver=
 to support Virtex4-FX. It was successfully tested on the ML403 evaluat=
ion board.
>
> Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
> ---
> =A0drivers/net/ll_temac.h =A0 =A0 =A0| =A0 =A04 ++++
> =A0drivers/net/ll_temac_main.c | =A0 17 ++++++++++++++++-
> =A02 files changed, 20 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> index 95dd650..51824a8 100644
> --- a/drivers/net/ll_temac.h
> +++ b/drivers/net/ll_temac.h
> @@ -383,7 +383,11 @@ struct temac_local {
>
> =A0 =A0 =A0 =A0/* IO registers and IRQs */
> =A0 =A0 =A0 =A0void __iomem *regs;
> +#ifdef CONFIG_XILINX_VIRTEX_4_FX
> + =A0 =A0 =A0 void __iomem *dma_regs;
> +#else
> =A0 =A0 =A0 =A0dcr_host_t sdma_dcrs;
> +#endif

Hi Filip,

Rather than using a CONFIG symbol to select between MMIO and DCR
modes, you should look at how this patch implemented it:

http://www.gossamer-threads.com/lists/linux/kernel/1184834?page=3Dlast

John Tyner's approach is pretty good, but it needs a bit more work
before merging and he is no longer working on a virtex platform so he
isn't planning to finish it.  Basically, there is no reason for the
driver to have to choose at compile time whether DCR or MMIO will be
used.

g.

> =A0 =A0 =A0 =A0int tx_irq;
> =A0 =A0 =A0 =A0int rx_irq;
> =A0 =A0 =A0 =A0int emac_num;
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.=
c
> index a8522bd..0d4b1c5 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -812,7 +812,6 @@ temac_of_probe(struct of_device *op, const struct=
 of_device_id *match)
> =A0 =A0 =A0 =A0struct net_device *ndev;
> =A0 =A0 =A0 =A0const void *addr;
> =A0 =A0 =A0 =A0int size, rc =3D 0;
> - =A0 =A0 =A0 unsigned int dcrs;
>
> =A0 =A0 =A0 =A0/* Init network device structure */
> =A0 =A0 =A0 =A0ndev =3D alloc_etherdev(sizeof(*lp));
> @@ -862,6 +861,21 @@ temac_of_probe(struct of_device *op, const struc=
t of_device_id *match)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nodev;
> =A0 =A0 =A0 =A0}
>
> +#ifdef CONFIG_XILINX_VIRTEX_4_FX
> + =A0 =A0 =A0 unsigned int ds;
> + =A0 =A0 =A0 const u32 *dr =3D of_get_property(np, "reg", &ds);
> + =A0 =A0 =A0 if (dr =3D=3D NULL || ds & 1 || 0 >=3D ds ) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not get DMA re=
gister address\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 lp->dma_regs =3D (u32) ioremap(*dr, 4096);
> + =A0 =A0 =A0 if (!lp->dma_regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not get DMA vi=
rtual address\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 dev_dbg(&op->dev, "DMA base: %x\n", lp->dma_regs);
> +#else =A0/*CONFIG_XILINX_VIRTEX_4_FX*/
> + =A0 =A0 =A0 unsigned int dcrs;
> =A0 =A0 =A0 =A0dcrs =3D dcr_resource_start(np, 0);
> =A0 =A0 =A0 =A0if (dcrs =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&op->dev, "could not get DMA r=
egister address\n");
> @@ -869,6 +883,7 @@ temac_of_probe(struct of_device *op, const struct=
 of_device_id *match)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0lp->sdma_dcrs =3D dcr_map(np, dcrs, dcr_resource_len(n=
p, 0));
> =A0 =A0 =A0 =A0dev_dbg(&op->dev, "DCR base: %x\n", dcrs);
> +#endif /*CONFIG_XILINX_VIRTEX_4_FX*/'
>
> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
> --
> 1.6.4.4
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
