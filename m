From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] mac80211: Speedup
 ieee80211_remove_interfaces()
Date: Thu, 05 Nov 2009 19:40:07 +0100
Message-ID: <1257446408.29454.4.camel@johannes.local>
References: <4AF2A3B0.4030100@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-TGPihuVPrg5/LwlHzd31"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:36121 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758273AbZKESkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:40:19 -0500
In-Reply-To: <4AF2A3B0.4030100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TGPihuVPrg5/LwlHzd31
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-11-05 at 11:06 +0100, Eric Dumazet wrote:
> Speedup ieee80211_remove_interfaces() by factorizing synchronize_rcu() ca=
lls

Jouni will be pleased for his testing... :)

Looks good to me. Nice simplification too.

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/mac80211/iface.c |   14 +++++---------
>  1 files changed, 5 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
> index 14f10eb..a445f50 100644
> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
> @@ -852,22 +852,18 @@ void ieee80211_if_remove(struct ieee80211_sub_if_da=
ta *sdata)
>  void ieee80211_remove_interfaces(struct ieee80211_local *local)
>  {
>  	struct ieee80211_sub_if_data *sdata, *tmp;
> +	LIST_HEAD(unreg_list);
> =20
>  	ASSERT_RTNL();
> =20
> +	mutex_lock(&local->iflist_mtx);
>  	list_for_each_entry_safe(sdata, tmp, &local->interfaces, list) {
> -		/*
> -		 * we cannot hold the iflist_mtx across unregister_netdevice,
> -		 * but we only need to hold it for list modifications to lock
> -		 * out readers since we're under the RTNL here as all other
> -		 * writers.
> -		 */
> -		mutex_lock(&local->iflist_mtx);
>  		list_del(&sdata->list);
> -		mutex_unlock(&local->iflist_mtx);
> =20
> -		unregister_netdevice(sdata->dev);
> +		unregister_netdevice_queue(sdata->dev, &unreg_list);
>  	}
> +	mutex_unlock(&local->iflist_mtx);
> +	unregister_netdevice_many(&unreg_list);
>  }
> =20
>  static u32 ieee80211_idle_off(struct ieee80211_local *local,
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=-TGPihuVPrg5/LwlHzd31
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK8xwDAAoJEODzc/N7+QmaaRIQAJPqqt9TW5+tx30rmDC8FYcZ
qj4ogXqmd401zT7I4vPYZzmObg8TfrZm6P3Gpwh67xx++umMettT+z430AS6cbBn
yI5HtWJp2+Ox1IHA3d1PwBvrPGu1gyppEhri2fvA830n2MtAwGS6VM6DQicaOsCD
FXpYoG6R5fnst6q4UUH8Fw7yTrjWtFo6u3b5aZfXBaQFmhlXL5TD6GuO8ZOAOruv
g2xry6E5qZFNBlW851Zhu8brq8uVAMHpxWk6Ou7UsjncbOLX/aFyfZSAyUk+LteP
6fWeB0Kr6yPLmUDXjaoCpmb+ovearfIl/0o0pLkComz36hNAidnHd6eRusLCtmyc
z0EzwukP7s6mc4DDA3xyz7msocLT6F4ru3881PAc6aHmyuWRtJHBeBpYkTOxvSk7
J2EkdtMLPGQSo4Ke4eOQVNzGh9Z3xuMSLx8GsijOK43D5BGPZjw6WoDYiIn9fiv4
CsGGAXN25F++n9tWXegXLIGZ9kHTSCNR4EDQcOIGkplpX1/QVukZ0DnNQPioi7hh
ph8vAWImRo6PC5Yns6LsxTtpuVME1kTmlEga2fpTnG1my5gbYux0pIdrQgH/nfEh
JC0ci59wL42DKKhi+5ExfVIPmJtt4b9yatwywurt0UR+1UWm/sfXdMhWE7VNhCnj
fsxmV7h6jYg1JK//vtdV
=jf1b
-----END PGP SIGNATURE-----

--=-TGPihuVPrg5/LwlHzd31--

