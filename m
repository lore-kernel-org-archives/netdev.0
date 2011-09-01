From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Subject: Re: [PATCH net-next] net: linkwatch: allow vlans to get carrier changes
 faster
Date: Thu, 01 Sep 2011 20:53:45 +0900
Message-ID: <4E5F7249.8020408@hitachi.com>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp>  <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>  <20110826064553.GA5874@gondor.apana.org.au>  <4E5A40A9.2000404@hitachi.com>  <1314540589.3036.12.camel@edumazet-laptop> <1314783118.2801.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?TWljaGHFgk1pcm9zxYJhdw==?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:56561 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1IALxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 07:53:51 -0400
In-Reply-To: <1314783118.2801.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I checked this patch solves the time-lag of IFF_RUNNING flag consistenc=
y
between vlan and real devices.=20

Cheers.

Tested-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>


(2011/08/31 18:31), Eric Dumazet wrote:
> There is a time-lag of IFF_RUNNING flag consistency between vlan and
> real devices when the real devices are in problem such as link or cab=
le
> broken.
>=20
> This leads to a degradation of Availability such as a delay of failov=
er
> in HA systems using vlan since the detection of the problem at real
> device is delayed.
>=20
> We can avoid the linkwatch delay (~1 sec) for devices linked to anoth=
er
> ones, since delay is already done for the realdev.
>=20
> Based on a previous patch from Mitsuo Hayasaka
>=20
> Reported-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jesse Gross <jesse@nicira.com>
> ---
>  net/core/link_watch.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/link_watch.c b/net/core/link_watch.c
> index 357bd4e..c3519c6 100644
> --- a/net/core/link_watch.c
> +++ b/net/core/link_watch.c
> @@ -78,8 +78,13 @@ static void rfc2863_policy(struct net_device *dev)
> =20
>  static bool linkwatch_urgent_event(struct net_device *dev)
>  {
> -	return netif_running(dev) && netif_carrier_ok(dev) &&
> -		qdisc_tx_changing(dev);
> +	if (!netif_running(dev))
> +		return false;
> +
> +	if (dev->ifindex !=3D dev->iflink)
> +		return true;
> +
> +	return netif_carrier_ok(dev) &&	qdisc_tx_changing(dev);
>  }
> =20
> =20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
