From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: add BQL support
Date: Sun, 28 Dec 2014 08:25:40 -0800
Message-ID: <CAA93jw7XMK0foH_Hf9PHitV+Xhwxu15xATFv-jnn8_1Tv+kFCA@mail.gmail.com>
References: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Beniamino Galvani <b.galvani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 28, 2014 at 6:57 AM, Beniamino Galvani <b.galvani@gmail.com=
> wrote:
> Add support for Byte Queue Limits to the STMicro MAC driver.

Thank you!

> Tested on a Amlogic S805 Cortex-A5 board, where the use of BQL
> slightly decreases the ping latency from ~10ms to ~3ms when the
> 100Mbps link is saturated by TCP streams. No difference is
> observed at 1Gbps.

I see the plural. With TSQ in place it is hard (without something like
the rrul test driving multiple streams) to drive a driver to
saturation with small numbers of flows. This was with pfifo_fast, not
sch_fq, at 100mbit?

Can this board actually drive a full gigabit in the first place? Until
now most of the low end arm boards I have seen only came with
a 100mbit mac, and the gig ones lacking offloads seemed to peak
out at about 600mbit.

Under my christmas tree landed a quad core A5 (odroid-c1), also an
xgene and zedboard - both of the latter are a-needing BQL,
and I haven't booted the udroid yet. Hopefully it is the
same driver you just improved.

(https://plus.google.com/u/0/107942175615993706558/posts/f1D43umhm7E )

> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 118a427..c5af3d8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1097,6 +1097,7 @@ static int init_dma_desc_rings(struct net_devic=
e *dev, gfp_t flags)
>
>         priv->dirty_tx =3D 0;
>         priv->cur_tx =3D 0;
> +       netdev_reset_queue(priv->dev);
>
>         stmmac_clear_descriptors(priv);
>
> @@ -1300,6 +1301,7 @@ static void stmmac_dma_operation_mode(struct st=
mmac_priv *priv)
>  static void stmmac_tx_clean(struct stmmac_priv *priv)
>  {
>         unsigned int txsize =3D priv->dma_tx_size;
> +       unsigned int bytes_compl =3D 0, pkts_compl =3D 0;
>
>         spin_lock(&priv->tx_lock);
>
> @@ -1356,6 +1358,8 @@ static void stmmac_tx_clean(struct stmmac_priv =
*priv)
>                 priv->hw->mode->clean_desc3(priv, p);
>
>                 if (likely(skb !=3D NULL)) {
> +                       pkts_compl++;
> +                       bytes_compl +=3D skb->len;
>                         dev_consume_skb_any(skb);
>                         priv->tx_skbuff[entry] =3D NULL;
>                 }
> @@ -1364,6 +1368,9 @@ static void stmmac_tx_clean(struct stmmac_priv =
*priv)
>
>                 priv->dirty_tx++;
>         }
> +
> +       netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
> +
>         if (unlikely(netif_queue_stopped(priv->dev) &&
>                      stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)))=
 {
>                 netif_tx_lock(priv->dev);
> @@ -1418,6 +1425,7 @@ static void stmmac_tx_err(struct stmmac_priv *p=
riv)
>                                                      (i =3D=3D txsize=
 - 1));
>         priv->dirty_tx =3D 0;
>         priv->cur_tx =3D 0;
> +       netdev_reset_queue(priv->dev);
>         priv->hw->dma->start_tx(priv->ioaddr);
>
>         priv->dev->stats.tx_errors++;
> @@ -2049,6 +2057,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *=
skb, struct net_device *dev)
>                 skb_tx_timestamp(skb);
>
>         priv->hw->dma->enable_dma_transmission(priv->ioaddr);
> +       netdev_sent_queue(dev, skb->len);
>
>         spin_unlock(&priv->tx_lock);
>         return NETDEV_TX_OK;
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
