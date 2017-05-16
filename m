From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] net: ethernet: broadcom: bnxt: remove dead code
Date: Mon, 15 May 2017 17:34:30 -0700
Message-ID: <CACKFLimtPW-uxEUK2GaL-ZPLhLOx19Qqzr8d-pVcV3bOEXqYTA@mail.gmail.com>
References: <20170515222818.GA17519@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515222818.GA17519@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 3:28 PM, Gustavo A. R. Silva
<garsilva@embeddedor.com> wrote:
> Local variable _sh_ is assigned to a constant value and it is never updated
> again. Remove this variable and the dead code it guards.
>
> Addresses-Coverity-ID: 1350916
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index 1f1e54b..018674b 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -7380,12 +7380,10 @@ static int bnxt_get_dflt_rings(struct bnxt *bp, int *max_rx, int *max_tx,
>  static int bnxt_set_dflt_rings(struct bnxt *bp)
>  {
>         int dflt_rings, max_rx_rings, max_tx_rings, rc;
> -       bool sh = true;

The point of this logic is that we can easily change the default to
shared rings or separate rings.  I think what I'll do is change it so
that the parameter sh is passed in and let the caller decide.  Thanks
for pointing this out.

>
> -       if (sh)
> -               bp->flags |= BNXT_FLAG_SHARED_RINGS;
> +       bp->flags |= BNXT_FLAG_SHARED_RINGS;
>         dflt_rings = netif_get_num_default_rss_queues();
> -       rc = bnxt_get_dflt_rings(bp, &max_rx_rings, &max_tx_rings, sh);
> +       rc = bnxt_get_dflt_rings(bp, &max_rx_rings, &max_tx_rings, true);
>         if (rc)
>                 return rc;
>         bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
> @@ -7396,8 +7394,7 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
>                 netdev_warn(bp->dev, "Unable to reserve tx rings\n");
>
>         bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
> -       bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
> -                              bp->tx_nr_rings + bp->rx_nr_rings;
> +       bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
>         bp->num_stat_ctxs = bp->cp_nr_rings;
>         if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
>                 bp->rx_nr_rings++;
> --
> 2.5.0
>
