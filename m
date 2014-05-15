From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 10:58:38 +0200
Message-ID: <537481BE.2010303@canonical.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com> <1400143605.1006.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="nskFHjFCNpuITB6SV92xihOiJCAOgVvFM"
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	netdev <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38088 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaEOI6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 04:58:51 -0400
In-Reply-To: <1400143605.1006.1.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--nskFHjFCNpuITB6SV92xihOiJCAOgVvFM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 15.05.2014 10:46, Ian Campbell wrote:
> On Wed, 2014-05-14 at 20:49 +0100, Zoltan Kiss wrote:
>> On 13/05/14 19:21, Stefan Bader wrote:
>>> We had reports about this message being seen on EC2 for a while but f=
inally a
>>> reporter did notice some details about the guests and was able to pro=
vide a
>>> simple way to reproduce[1].
>>>
>>> For my local experiments I use a Xen-4.2.2 based host (though I would=
 say the
>>> host versions are not important). The host has one NIC which is used =
as the
>>> outgoing port of a Linux based (not openvswitch) bridge. And the PV g=
uests use
>>> that bridge. I set the mtu to 9001 (which was seen on affected instan=
ce types)
>>> and also inside the guests. As described in the report one guests run=
s
>>> redis-server and the other nodejs through two scripts (for me I had t=
o do the
>>> two sub.js calls in separate shells). After a bit the error messages =
appear on
>>> the guest running the redis-server.
>>>
>>> I added some debug printk's to show a bit more detail about the skb a=
nd got the
>>> following (<length>@<offset (after masking off complete pages)>):
>>>
>>> [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
>>> [ 698.108134] header 1490@238 -> 1 slots
>>> [ 698.108139] frag #0 1614@2164 -> + 1 pages
>>> [ 698.108143] frag #1 3038@1296 -> + 2 pages
>>> [ 698.108147] frag #2 6076@1852 -> + 2 pages
>>> [ 698.108151] frag #3 6076@292 -> + 2 pages
>>> [ 698.108156] frag #4 6076@2828 -> + 3 pages
>>> [ 698.108160] frag #5 3038@1268 -> + 2 pages
>>> [ 698.108164] frag #6 2272@1824 -> + 1 pages
>>> [ 698.108168] frag #7 3804@0 -> + 1 pages
>>> [ 698.108172] frag #8 6076@264 -> + 2 pages
>>> [ 698.108177] frag #9 3946@2800 -> + 2 pages
>>> [ 698.108180] frags adding 18 slots
>>>
>>> Since I am not deeply familiar with the networking code, I wonder abo=
ut two things:
>>> - is there something that should limit the skb data length from all f=
rags
>>>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?=

>> I think netfront should be able to handle 64K packets at most.
>=20
> Ah, maybe this relates to this fix from Wei?

That indeed should (imo) limit the overall size. And if that would happen=
 still,
we would see the different message. The problem I see is not the overall =
size
but the layout of the frags. Since multiple start at an offset high enoug=
h, the
count of slots goes too high.

Now I have to read that code in more detail, but there also has been some=

changes which introduce a make frags function. I wonder whether maybe the=
re is
already some kind of shifting (or copying) going on and whether its just =
the
check that needs to improve. But right now that is speculation.

For the fun I actually found an even simpler way to trigger it and (need =
to
confirm it yet without mucking around with mtu before). It looked like mt=
u
actually did not make a difference. One only needed the redis server on o=
ne
guest and run redis-benchmark from the other with (I think -d 1000, or wh=
atever
it is that sets the datasize). Then on the range tests this happens quite=
 often.

-Stefan
>=20
> commit 9ecd1a75d977e2e8c48139c7d3efed183f898d94
> Author: Wei Liu <wei.liu2@citrix.com>
> Date:   Mon Apr 22 02:20:41 2013 +0000
>=20
>     xen-netfront: reduce gso_max_size to account for max TCP header
>    =20
>     The maximum packet including header that can be handled by netfront=
 / netback
>     wire format is 65535. Reduce gso_max_size accordingly.
>    =20
>     Drop skb and print warning when skb->len > 65535. This can 1) save =
the effort
>     to send malformed packet to netback, 2) help spotting misconfigurat=
ion of
>     netfront in the future.
>    =20
>     Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>     Acked-by: Ian Campbell <ian.campbell@citrix.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 1bb2e20..1db10141 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -36,7 +36,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/ethtool.h>
>  #include <linux/if_ether.h>
> -#include <linux/tcp.h>
> +#include <net/tcp.h>
>  #include <linux/udp.h>
>  #include <linux/moduleparam.h>
>  #include <linux/mm.h>
> @@ -547,6 +547,16 @@ static int xennet_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	unsigned int len =3D skb_headlen(skb);
>  	unsigned long flags;
> =20
> +	/* If skb->len is too big for wire format, drop skb and alert
> +	 * user about misconfiguration.
> +	 */
> +	if (unlikely(skb->len > XEN_NETIF_MAX_TX_SIZE)) {
> +		net_alert_ratelimited(
> +			"xennet: skb->len =3D %u, too big for wire format\n",
> +			skb->len);
> +		goto drop;
> +	}
> +
>  	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> @@ -1058,7 +1068,8 @@ err:
> =20
>  static int xennet_change_mtu(struct net_device *dev, int mtu)
>  {
> -	int max =3D xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> +	int max =3D xennet_can_sg(dev) ?
> +		XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER : ETH_DATA_LEN;
> =20
>  	if (mtu > max)
>  		return -EINVAL;
> @@ -1362,6 +1373,8 @@ static struct net_device *xennet_create_dev(struc=
t xenbus_device *dev)
>  	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
>  	SET_NETDEV_DEV(netdev, &dev->dev);
> =20
> +	netif_set_gso_max_size(netdev, XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER=
);
> +
>  	np->netdev =3D netdev;
> =20
>  	netif_carrier_off(netdev);
> diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/i=
o/netif.h
> index 9dfc120..58fadca 100644
> --- a/include/xen/interface/io/netif.h
> +++ b/include/xen/interface/io/netif.h
> @@ -47,6 +47,7 @@
>  #define _XEN_NETTXF_extra_info		(3)
>  #define  XEN_NETTXF_extra_info		(1U<<_XEN_NETTXF_extra_info)
> =20
> +#define XEN_NETIF_MAX_TX_SIZE 0xFFFF
>  struct xen_netif_tx_request {
>      grant_ref_t gref;      /* Reference to buffer page */
>      uint16_t offset;       /* Offset within buffer page */
>=20
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20



--nskFHjFCNpuITB6SV92xihOiJCAOgVvFM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTdIHGAAoJEOhnXe7L7s6jWPMQAIC5UgvHMFJYMwdsqGniFrCx
I1c0uhTJnjZpGVEeczXIdK8cBwidBc3/PbA0P2x9omneI0g3x8VJHvJQ17H2MX4e
e+IyOt7TAfnV0mcgWKz/BCHB4ygwJW1Nn4oyHq/z9US02hHIA+y49CN/qVS0SLit
v3O4o/S7xHGl7NU9ZxZjissAWmtmRujL3eMy7aJXAM55EGKaKrXjwzX+rBEnlrEm
8TYg0fyx/SJVHC0+t+eY2OBhPaRJeVg/1mXi7rxvlrPbGWp2vvWa95Lp7E/V6Ktu
6HRdIgU5iZgO/5u/toopgywE9GduZyb8xaciIm/9mmfe6mfxxqlO2e+p8JylqwKG
6RC/lHbdzBKCwY1tL8hhD99s6rxUrslj63uk3xqFPyosdYX55SJFOWRlHdbmcFer
MUVXVXWgQ2ynMOzXjSe2k4anjSR2VOWrnKzSM0fLrkXp1KhYrJF2XPiSlbKG7k1V
8Pogm8ddmoS0ygcbjsUUGpWkAQJ1rCe+IHnEDsaKkfM7ydPomuH4ZqZuEIea41yf
xoxdL92ofjCdVcCQOjhDB4FxVd2fjXxBIc869lFt7SeqWjVTTxAPBpQ/4HqNrmOY
ai66QTLdtT/M6ECyIv7ry+OGVeBGG6E8FXKzHRRe+78CrCAULGmxL7d77JlLjEGY
UeBZzsKkBCHevywmjqRj
=Rct1
-----END PGP SIGNATURE-----

--nskFHjFCNpuITB6SV92xihOiJCAOgVvFM--
