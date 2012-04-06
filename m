From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH V4 net-next 04/26] gianfar: Support the get_ts_info
 ethtool method.
Date: Fri, 6 Apr 2012 00:25:32 -0400
Message-ID: <CAP=VYLrNBjHgPJFzwBrQ4=5rouCD81PLW4f_TPZMkF7yObUdcA@mail.gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com> <c268d71203b066b9052a8cabd5f6c71de2a8fa77.1333529506.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-next@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <c268d71203b066b9052a8cabd5f6c71de2a8fa77.1333529506.git.richardcochran@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 4, 2012 at 4:59 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
> =A0drivers/net/ethernet/freescale/gianfar.h =A0 =A0 =A0 =A0 | =A0 =A0=
3 ++
> =A0drivers/net/ethernet/freescale/gianfar_ethtool.c | =A0 29 ++++++++=
++++++++++++++
> =A0drivers/net/ethernet/freescale/gianfar_ptp.c =A0 =A0 | =A0 =A02 +
> =A03 files changed, 34 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/e=
thernet/freescale/gianfar.h
> index 4c9f8d4..2136c7f 100644
> --- a/drivers/net/ethernet/freescale/gianfar.h
> +++ b/drivers/net/ethernet/freescale/gianfar.h
> @@ -1210,4 +1210,7 @@ struct filer_table {
> =A0 =A0 =A0 =A0struct gfar_filer_entry fe[MAX_FILER_CACHE_IDX + 20];
> =A0};
>
> +/* The gianfar_ptp module will set this variable */
> +extern int gfar_phc_index;
> +
> =A0#endif /* __GIANFAR_H */
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drive=
rs/net/ethernet/freescale/gianfar_ethtool.c
> index 8d74efd..27f49c7 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -1739,6 +1739,34 @@ static int gfar_get_nfc(struct net_device *dev=
, struct ethtool_rxnfc *cmd,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +int gfar_phc_index =3D -1;
> +
> +static int gfar_get_ts_info(struct net_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_=
ts_info *info)
> +{
> + =A0 =A0 =A0 struct gfar_private *priv =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->so_timestamping =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_RX_SOF=
TWARE |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_SOFTWA=
RE;

Commit 66636287 in linux-next appears to cause this:

drivers/net/ethernet/freescale/gianfar_ethtool.c:1751:4: error:
'SOF_TIMESTAMPING_RX_SOFTWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1752:4: error:
'SOF_TIMESTAMPING_SOFTWARE' undeclared (first use in this function)

Needs an include of <linux/net_tstamp.h> ?

http://kisskb.ellerman.id.au/kisskb/buildresult/6039723/
http://kisskb.ellerman.id.au/kisskb/buildresult/6039704/
http://kisskb.ellerman.id.au/kisskb/buildresult/6040028/

I'd normally just provide a tested and signed off patch, but I'm kind o=
f
limited to just browsing the build results at this particular moment.  =
Sorry
about that.

Paul.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 info->phc_index =3D -1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 info->so_timestamping =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_TX_HARDWARE |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_RX_HARDWARE |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_RAW_HARDWARE;
> + =A0 =A0 =A0 info->phc_index =3D gfar_phc_index;
> + =A0 =A0 =A0 info->tx_types =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_TX_OFF) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_TX_ON);
> + =A0 =A0 =A0 info->rx_filters =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_NONE) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_ALL);
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0const struct ethtool_ops gfar_ethtool_ops =3D {
> =A0 =A0 =A0 =A0.get_settings =3D gfar_gsettings,
> =A0 =A0 =A0 =A0.set_settings =3D gfar_ssettings,
> @@ -1761,4 +1789,5 @@ const struct ethtool_ops gfar_ethtool_ops =3D {
> =A0#endif
> =A0 =A0 =A0 =A0.set_rxnfc =3D gfar_set_nfc,
> =A0 =A0 =A0 =A0.get_rxnfc =3D gfar_get_nfc,
> + =A0 =A0 =A0 .get_ts_info =3D gfar_get_ts_info,
> =A0};
> diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/n=
et/ethernet/freescale/gianfar_ptp.c
> index 5fd620b..c08e5d4 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ptp.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
> @@ -515,6 +515,7 @@ static int gianfar_ptp_probe(struct platform_devi=
ce *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(etsects->clock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto no_clock;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 gfar_phc_clock =3D ptp_clock_index(etsects->clock);
>
> =A0 =A0 =A0 =A0dev_set_drvdata(&dev->dev, etsects);
>
> @@ -538,6 +539,7 @@ static int gianfar_ptp_remove(struct platform_dev=
ice *dev)
> =A0 =A0 =A0 =A0gfar_write(&etsects->regs->tmr_temask, 0);
> =A0 =A0 =A0 =A0gfar_write(&etsects->regs->tmr_ctrl, =A0 0);
>
> + =A0 =A0 =A0 gfar_phc_clock =3D -1;
> =A0 =A0 =A0 =A0ptp_clock_unregister(etsects->clock);
> =A0 =A0 =A0 =A0iounmap(etsects->regs);
> =A0 =A0 =A0 =A0release_resource(etsects->rsrc);
> --
> 1.7.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
