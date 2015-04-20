From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 02/11] IB/addr: Pass network namespace as a parameter
Date: Mon, 20 Apr 2015 18:05:30 -0400
Message-ID: <1429567530.45956.31.camel@redhat.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
	 <1429520622-10303-3-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-+285zWrsSafreHchff6E"
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429520622-10303-3-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-+285zWrsSafreHchff6E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-04-20 at 12:03 +0300, Haggai Eran wrote:
> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> Add network namespace support to the ib_addr module. For that, all the ad=
dress
> resolution and matching should be done using the appropriate namespace in=
stead
> of init_net.
>=20
> This is achieved by:
>=20
> 1. Adding an explicit network namespace argument to exported function tha=
t
>    require a namespace.
> 2. Saving the namespace in the rdma_addr_client structure.
> 3. Using it when calling networking functions.
>=20
> In order to preserve the behavior of calling modules, &init_net is
> passed as the parameter in calls from other modules. This is modified as
> namespace support is added on more levels.
>=20
> Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/core/addr.c           | 31 ++++++++++++----------
>  drivers/infiniband/core/cma.c            |  4 ++-
>  drivers/infiniband/core/verbs.c          | 14 +++++++---
>  drivers/infiniband/hw/ocrdma/ocrdma_ah.c |  3 ++-
>  include/rdma/ib_addr.h                   | 44 ++++++++++++++++++++++++++=
++----
>  5 files changed, 72 insertions(+), 24 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/add=
r.c
> index f80da50d84a5..95beaef6b66d 100644
> --- a/drivers/infiniband/core/addr.c
> +++ b/drivers/infiniband/core/addr.c
> @@ -128,7 +128,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct r=
dma_dev_addr *dev_addr,
>  	int ret =3D -EADDRNOTAVAIL;
> =20
>  	if (dev_addr->bound_dev_if) {
> -		dev =3D dev_get_by_index(&init_net, dev_addr->bound_dev_if);
> +		dev =3D dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
>  		if (!dev)
>  			return -ENODEV;
>  		ret =3D rdma_copy_addr(dev_addr, dev, NULL);
> @@ -137,9 +137,10 @@ int rdma_translate_ip(struct sockaddr *addr, struct =
rdma_dev_addr *dev_addr,
>  	}
> =20
>  	switch (addr->sa_family) {
> -	case AF_INET:
> -		dev =3D ip_dev_find(&init_net,
> -			((struct sockaddr_in *) addr)->sin_addr.s_addr);
> +	case AF_INET: {
                       ^ Please don't add brackets just so you can
convert a cast into a variable declaration that's unnecessary

> +		struct sockaddr_in *addr_in =3D (struct sockaddr_in *)addr;
> +
> +		dev =3D ip_dev_find(dev_addr->net, addr_in->sin_addr.s_addr);
> =20
>  		if (!dev)
>  			return ret;
> @@ -149,12 +150,12 @@ int rdma_translate_ip(struct sockaddr *addr, struct=
 rdma_dev_addr *dev_addr,
>  			*vlan_id =3D rdma_vlan_dev_vlan_id(dev);
>  		dev_put(dev);
>  		break;
> -
> +	}
>  #if IS_ENABLED(CONFIG_IPV6)
>  	case AF_INET6:
>  		rcu_read_lock();
> -		for_each_netdev_rcu(&init_net, dev) {
> -			if (ipv6_chk_addr(&init_net,
> +		for_each_netdev_rcu(dev_addr->net, dev) {
> +			if (ipv6_chk_addr(dev_addr->net,
>  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
>  					  dev, 1)) {
>  				ret =3D rdma_copy_addr(dev_addr, dev, NULL);
> @@ -236,7 +237,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
>  	fl4.daddr =3D dst_ip;
>  	fl4.saddr =3D src_ip;
>  	fl4.flowi4_oif =3D addr->bound_dev_if;
> -	rt =3D ip_route_output_key(&init_net, &fl4);
> +	rt =3D ip_route_output_key(addr->net, &fl4);
>  	if (IS_ERR(rt)) {
>  		ret =3D PTR_ERR(rt);
>  		goto out;
> @@ -278,12 +279,13 @@ static int addr6_resolve(struct sockaddr_in6 *src_i=
n,
>  	fl6.saddr =3D src_in->sin6_addr;
>  	fl6.flowi6_oif =3D addr->bound_dev_if;
> =20
> -	dst =3D ip6_route_output(&init_net, NULL, &fl6);
> +	dst =3D ip6_route_output(addr->net, NULL, &fl6);
>  	if ((ret =3D dst->error))
>  		goto put;
> =20
>  	if (ipv6_addr_any(&fl6.saddr)) {
> -		ret =3D ipv6_dev_get_saddr(&init_net, ip6_dst_idev(dst)->dev,
> +		ret =3D ipv6_dev_get_saddr(addr->net,
> +					 ip6_dst_idev(dst)->dev,
>  					 &fl6.daddr, 0, &fl6.saddr);
>  		if (ret)
>  			goto put;
> @@ -458,7 +460,7 @@ static void resolve_cb(int status, struct sockaddr *s=
rc_addr,
>  }
> =20
>  int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u=
8 *dmac,
> -			       u16 *vlan_id)
> +			       u16 *vlan_id, struct net *net)

In the core networking code, the net namespace is always first.  Please
stick with that paradigm.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-+285zWrsSafreHchff6E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVNXgqAAoJELgmozMOVy/dvTgQALIsvMMo3Y/0bHddqkJc7kMI
3IU3IEphcdRP6NVIOKxjV+cvyxO3Cs8EyE5JfY+Gw6ktxFyJK82SnF5PiqieKYp8
NKdIE6VRpru7d2CtOtW2usckD98Fyh0SOPjfe2yNGmz1eb/I1ivTEGOfIlYDZ1EM
Dqbwvd7ppZXTMmitYL6+fOJ67rUGV7ARb6PHFFppkCugmmCsVDj0iBN+fhFK3vAs
7cTFa0VdmqPPDUW5ViRh4ikyRgnQNoJDefWWhfC8kle9fkBk1Hc/i8y01bhjktof
81tNF1fZ5c0nIza447Vt7IzGeXa0+gEveVgW19+K2DyWS3Nd+1z+4pYGmuQAs3ZJ
DnM6apVsFlex5yygJ9tPur7A3o21166cMvw70l8IdJupR+xW+fYc1AUdolsdyl3O
9OiVEi15Y2ww0NzXZGgZTMgnjoZuDsA/vVcYY01Chs42LcN4PY/n3gialRY8yydT
DxI49Vi7BEAeAFJe8rkxKqRb9jOStKf/+7N86rtE4cdsjoXlcuJ647+sdnKrrFPL
oKu1LuyCuCkfCtPN/tsAPW9YyDQjtJzxzw4x0sH+GS6CNg6lJPpV0lV+YjnLlf3j
LvhB3xgWFYp0xV8gVG2ly1m9ZJsn/5ohmLwvxg1BGgQ5bD72C/8dwMR5buVoj27s
Q7qWQYhia4i/ioTxn0v+
=kX7+
-----END PGP SIGNATURE-----

--=-+285zWrsSafreHchff6E--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
