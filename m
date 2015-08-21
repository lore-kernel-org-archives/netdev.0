From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Fri, 21 Aug 2015 12:24:30 +0200
Message-ID: <20150821102430.GD19683@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="RASg3xLB4tUQ4RcS"
Cc: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:56890 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbbHUKYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 06:24:33 -0400
Content-Disposition: inline
In-Reply-To: <1440151756-18165-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RASg3xLB4tUQ4RcS
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Sorry, I forgot to mention that I tested this patch on three different
chip versions, RTL_GIGA_MAC_VER_23, RTL_GIGA_MAC_VER_33 and
RTL_GIGA_MAC_VER_35.  I couldn't test on pre-RTL_GIGA_MAC_VER_19, but
the offset handling without counter reset already worked as expected on
later chip versions, so I'm pretty confident that older chip versions
should work accordingly.

On Aug 21 12:09, Corinna Vinschen wrote:
> The r8169 driver collects statistical information returned by
> @get_stats64 by counting them in the driver itself, even though many
> (but not all) of the values are already collected by tally counters
> (TCs) in the NIC.  Some of these TC values are not returned by
> @get_stats64.  Especially the received multicast packages are missing
> from /proc/net/dev.
>=20
> Rectify this by fetching the TCs and returning them from
> rtl8169_get_stats64.
>=20
> The counters collected in the driver obviously disappear as soon as the
> driver is unloaded so after a driver is loaded the counters always start
> at 0. The TCs on the other hand are only reset by a power cycle.  Without
> further considerations the values collected by the driver would not match
> up against the TC values.
>=20
> This patch introduces a new function rtl8169_reset_counters which
> resets the TCs.
>=20
> Unfortunately chip versions prior to RTL_GIGA_MAC_VER_19 don't allow
> to reset the TCs programatically.  Therefore introduce an addition to
> the rtl8169_private struct and a function rtl8169_init_counter_offsets
> to store the TCs at first rtl_open.  Use these values as offsets in
> rtl8169_get_stats64.
>=20
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 107 +++++++++++++++++++++++++++++=
++++++
>  1 file changed, 107 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/=
realtek/r8169.c
> index f790f61..f26a48d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -637,6 +637,9 @@ enum rtl_register_content {
>  	/* _TBICSRBit */
>  	TBILinkOK	=3D 0x02000000,
> =20
> +	/* ResetCounterCommand */
> +	CounterReset	=3D 0x1,
> +
>  	/* DumpCounterCommand */
>  	CounterDump	=3D 0x8,
> =20
> @@ -747,6 +750,14 @@ struct rtl8169_counters {
>  	__le16	tx_underun;
>  };
> =20
> +struct rtl8169_tc_offsets {
> +	bool	inited;
> +	__le64	tx_errors;
> +	__le32	tx_multi_collision;
> +	__le32	rx_multicast;
> +	__le16	tx_aborted;
> +};
> +
>  enum rtl_flag {
>  	RTL_FLAG_TASK_ENABLED,
>  	RTL_FLAG_TASK_SLOW_PENDING,
> @@ -824,6 +835,7 @@ struct rtl8169_private {
> =20
>  	struct mii_if_info mii;
>  	struct rtl8169_counters counters;
> +	struct rtl8169_tc_offsets tc_offset;
>  	u32 saved_wolopts;
>  	u32 opts1_mask;
> =20
> @@ -2179,6 +2191,47 @@ static int rtl8169_get_sset_count(struct net_devic=
e *dev, int sset)
>  	}
>  }
> =20
> +DECLARE_RTL_COND(rtl_reset_counters_cond)
> +{
> +	void __iomem *ioaddr =3D tp->mmio_addr;
> +
> +	return RTL_R32(CounterAddrLow) & CounterReset;
> +}
> +
> +static void rtl8169_reset_counters(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp =3D netdev_priv(dev);
> +	void __iomem *ioaddr =3D tp->mmio_addr;
> +	struct device *d =3D &tp->pci_dev->dev;
> +	struct rtl8169_counters *counters;
> +	dma_addr_t paddr;
> +	u32 cmd;
> +
> +	/*
> +	 * Versions prior to RTL_GIGA_MAC_VER_19 don't support resetting the
> +	 * tally counters.
> +	 */
> +	if (tp->mac_version < RTL_GIGA_MAC_VER_19)
> +		return;
> +
> +	counters =3D dma_alloc_coherent(d, sizeof(*counters), &paddr, GFP_KERNE=
L);
> +	if (!counters)
> +		return;
> +
> +	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
> +	cmd =3D (u64)paddr & DMA_BIT_MASK(32);
> +	RTL_W32(CounterAddrLow, cmd);
> +	RTL_W32(CounterAddrLow, cmd | CounterReset);
> +
> +	if (!rtl_udelay_loop_wait_low(tp, &rtl_reset_counters_cond, 10, 1000))
> +		netif_warn(tp, hw, dev, "counter reset failed\n");
> +
> +	RTL_W32(CounterAddrLow, 0);
> +	RTL_W32(CounterAddrHigh, 0);
> +
> +	dma_free_coherent(d, sizeof(*counters), counters, paddr);
> +}
> +
>  DECLARE_RTL_COND(rtl_counters_cond)
>  {
>  	void __iomem *ioaddr =3D tp->mmio_addr;
> @@ -2220,6 +2273,39 @@ static void rtl8169_update_counters(struct net_dev=
ice *dev)
>  	dma_free_coherent(d, sizeof(*counters), counters, paddr);
>  }
> =20
> +static void rtl8169_init_counter_offsets(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp =3D netdev_priv(dev);
> +
> +	/*
> +	 * rtl8169_init_counter_offsets is called from rtl_open.  On chip
> +	 * versions prior to RTL_GIGA_MAC_VER_19 the tally counters are only
> +	 * reset by a power cycle, while the counter values collected by the
> +	 * driver are reset at every driver unload/load cycle.
> +	 *
> +	 * To make sure the HW values returned by @get_stats64 match the SW
> +	 * values, we collect the initial values at first open(*) and use them
> +	 * as offsets to normalize the values returned by @get_stats64.
> +	 *
> +	 * (*) We can't call rtl8169_init_counter_offsets from rtl_init_one
> +	 * for the reason stated in rtl8169_update_counters; CmdRxEnb is only
> +	 * set at open time by rtl_hw_start.
> +	 */
> +
> +	if (tp->tc_offset.inited)
> +		return;
> +
> +	rtl8169_reset_counters(dev);
> +
> +	rtl8169_update_counters(dev);
> +
> +	tp->tc_offset.tx_errors =3D tp->counters.tx_errors;
> +	tp->tc_offset.tx_multi_collision =3D tp->counters.tx_multi_collision;
> +	tp->tc_offset.rx_multicast =3D tp->counters.rx_multicast;
> +	tp->tc_offset.tx_aborted =3D tp->counters.tx_aborted;
> +	tp->tc_offset.inited =3D true;
> +}
> +
>  static void rtl8169_get_ethtool_stats(struct net_device *dev,
>  				      struct ethtool_stats *stats, u64 *data)
>  {
> @@ -7631,6 +7717,8 @@ static int rtl_open(struct net_device *dev)
> =20
>  	rtl_hw_start(dev);
> =20
> +	rtl8169_init_counter_offsets(dev);
> +
>  	netif_start_queue(dev);
> =20
>  	rtl_unlock_work(tp);
> @@ -7689,6 +7777,25 @@ rtl8169_get_stats64(struct net_device *dev, struct=
 rtnl_link_stats64 *stats)
>  	stats->rx_fifo_errors	=3D dev->stats.rx_fifo_errors;
>  	stats->rx_missed_errors =3D dev->stats.rx_missed_errors;
> =20
> +	/*
> +	 * Fetch additonal counter values missing in stats collected by driver
> +	 * from tally counters.
> +	 */
> +	rtl8169_update_counters(dev);
> +
> +	/*
> +	 * Subtract values fetched during initalization.
> +	 * See rtl8169_init_counter_offsets for a description why we do that.
> +	 */
> +	stats->tx_errors =3D le64_to_cpu(tp->counters.tx_errors) -
> +		le64_to_cpu(tp->tc_offset.tx_errors);
> +	stats->collisions =3D le32_to_cpu(tp->counters.tx_multi_collision) -
> +		le32_to_cpu(tp->tc_offset.tx_multi_collision);
> +	stats->multicast =3D le32_to_cpu(tp->counters.rx_multicast) -
> +		le32_to_cpu(tp->tc_offset.rx_multicast);
> +	stats->tx_aborted_errors =3D le16_to_cpu(tp->counters.tx_aborted) -
> +		le16_to_cpu(tp->tc_offset.tx_aborted);
> +
>  	return stats;
>  }
> =20
> --=20
> 2.1.0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--RASg3xLB4tUQ4RcS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1vxeAAoJEPU2Bp2uRE+gyKMP/2p+d1xsDd8RS74S/QGaZ02t
97Z5BRhWeJIvog0u+usWR3MvTAcFdUAh0mrhsYlXZyvCyb6AC33VaazpALdgZMr+
uV6LPRnOqsiUPIgOQJg6ZhHnN9bgWEC9XyTeYfrOU8EVyBj3EmZ0qBodGoZnKXBH
0sU6sCCufHwzxGoPah4Zk+cgPjJl4cavezmrEJbg5NYM7Xlg+UGniBnaXumOkhts
PNZMkJXn/HYJUFP7GqRgfNQFiN3yEU2b2H1PsGFqERWjsFdwl7/Qvt2oBFMc94mA
PpxqqzS9vopzWtPUn4/TxD71aUe6mBYymFrbm6ltHV7+4hOqi3w5BwG6DHcPzisM
qZUTeMVusCajJnlSDoG6eJGWQHL+JcMBwYnYXpZZApm5cli0//NxMQnU/35L0tvU
/nVHbMM/mIlTzQPYcLhXWtBbLKCFr2k+gtqOY9lYsRSTh5JuqvXmzqOOKPhazDTy
5uGyjAPzCVQKSCqW2MR3g46whxAzrkgxgCZxXYCpW9sXYiyXz/E+r/iK6wv7ZdTL
MKyz8RJnoVABILxHX0+2k1Op5XF27e64Ee6FKcyJl2E9vvsAzsKoNOIzwkqiveJd
tZxo5Y3HgRba1Qqx0AiMOD4FTw7UfFdlgrtwXNQnlO1sBlKK7idZSGfRkdcUT+lb
T5F0Yd3lxGoxgIrU8uzT
=XMA/
-----END PGP SIGNATURE-----

--RASg3xLB4tUQ4RcS--
