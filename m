From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH 06/13] net: mvneta: enable mixed egress processing using
 HR timer
Date: Thu, 26 Nov 2015 17:45:40 +0100
Message-ID: <20151126164540.GH4665@kw.sim.vm.gnt>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
 <1448178839-3541-7-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Ca5z/wkVxIQXz1GF"
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	andrew@lunn.ch, linux@arm.linux.org.uk, jason@lakedaemon.net,
	myair@marvell.com, jaz@semihalf.com, xswang@marvell.com,
	nadavh@marvell.com, alior@marvell.com, tn@semihalf.com,
	gregory.clement@free-electrons.com, nitroshift@yahoo.com,
	davem@davemloft.net, sebastian.hesselbarth@gmail.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448178839-3541-7-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Ca5z/wkVxIQXz1GF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marcin,

On Sun, Nov 22, 2015 at 08:53:52AM +0100, Marcin Wojtas wrote:
> Mixed approach allows using higher interrupt threshold (increased back to
> 15 packets), useful in high throughput. In case of small amount of data
> or very short TX queues HR timer ensures releasing buffers with small
> latency.
>=20
> Along with existing tx_done processing by coalescing interrupts this
> commit enables triggering HR timer each time the packets are sent.
> Time threshold can also be configured, using ethtool.
>=20
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 89 +++++++++++++++++++++++++++++=
++++--
>  1 file changed, 85 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet=
/marvell/mvneta.c
> index 9c9e858..f5acaf6 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -21,6 +21,8 @@
>  #include <linux/module.h>
>  #include <linux/interrupt.h>
>  #include <linux/if_vlan.h>
> +#include <linux/hrtimer.h>
> +#include <linux/ktime.h>

ktime.h is already included by hrtimer.h.

>  #include <net/ip.h>
>  #include <net/ipv6.h>
>  #include <linux/io.h>
> @@ -226,7 +228,8 @@
>  /* Various constants */
> =20
>  /* Coalescing */
> -#define MVNETA_TXDONE_COAL_PKTS		1
> +#define MVNETA_TXDONE_COAL_PKTS		15
> +#define MVNETA_TXDONE_COAL_USEC		100

Maybe we should keep the default configuration and let the user choose
to enable (or not) this feature ?

>  #define MVNETA_RX_COAL_PKTS		32
>  #define MVNETA_RX_COAL_USEC		100
> =20
> @@ -356,6 +359,11 @@ struct mvneta_port {
>  	struct net_device *dev;
>  	struct notifier_block cpu_notifier;
> =20
> +	/* Egress finalization */
> +	struct tasklet_struct tx_done_tasklet;
> +	struct hrtimer tx_done_timer;
> +	bool timer_scheduled;

I think we could use hrtimer_is_queued() instead of introducing a new
variable.

[...]

Simon

--Ca5z/wkVxIQXz1GF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZXNzQACgkQgtp0PDeOcDpnIACdEO+KRCAE/nBYK21KzQ6X0qtK
HXkAn3h5OMe6jX6bGhn+T1FuOGzdanAd
=+3rS
-----END PGP SIGNATURE-----

--Ca5z/wkVxIQXz1GF--
