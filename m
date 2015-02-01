From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] IB/addr: Pass network namespace as a
 parameter
Date: Sun, 01 Feb 2015 13:22:56 +0100
Message-ID: <1422793376.3030.37.camel@opteya.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
	 <1422790133-28725-2-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422790133-28725-2-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le dimanche 01 f=C3=A9vrier 2015 =C3=A0 13:28 +0200, Shachar Raindel a =
=C3=A9crit :
> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> Add network namespace support to the ib_addr module. For that, all th=
e address
> resolution and matching should be done using the appropriate namespac=
e instead
> of init_net.
>=20
> This is achieved by:
>=20
> 1. Adding an explicit network namespace argument to exported function=
 that
>    require a namespace.
> 2. Saving the namespace in the rdma_addr_client structure.
> 3. Using it when calling networking functions.
>=20
> In order to preserve the behavior of calling modules, &init_net is
> passed as the parameter in calls from other modules. This is modified=
 as
> namspace support is added on more levels.

typo: "namespace"

>=20
> Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> ---
>  drivers/infiniband/core/addr.c           | 31 ++++++++++++----------
>  drivers/infiniband/core/cma.c            |  4 ++-
>  drivers/infiniband/core/verbs.c          | 14 +++++++---
>  drivers/infiniband/hw/ocrdma/ocrdma_ah.c |  3 ++-
>  include/rdma/ib_addr.h                   | 44 ++++++++++++++++++++++=
++++++----
>  5 files changed, 72 insertions(+), 24 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core=
/addr.c
> index f80da50d84a5..95beaef6b66d 100644
> --- a/drivers/infiniband/core/addr.c
> +++ b/drivers/infiniband/core/addr.c
> @@ -128,7 +128,7 @@ int rdma_translate_ip(struct sockaddr *addr, stru=
ct rdma_dev_addr *dev_addr,
>  	int ret =3D -EADDRNOTAVAIL;
> =20
>  	if (dev_addr->bound_dev_if) {
> -		dev =3D dev_get_by_index(&init_net, dev_addr->bound_dev_if);
> +		dev =3D dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
>  		if (!dev)
>  			return -ENODEV;
>  		ret =3D rdma_copy_addr(dev_addr, dev, NULL);
> @@ -137,9 +137,10 @@ int rdma_translate_ip(struct sockaddr *addr, str=
uct rdma_dev_addr *dev_addr,
>  	}
> =20
>  	switch (addr->sa_family) {
> -	case AF_INET:
> -		dev =3D ip_dev_find(&init_net,
> -			((struct sockaddr_in *) addr)->sin_addr.s_addr);
> +	case AF_INET: {
> +		struct sockaddr_in *addr_in =3D (struct sockaddr_in *)addr;
> +
> +		dev =3D ip_dev_find(dev_addr->net, addr_in->sin_addr.s_addr);

I don't see the point of this change.

> =20
>  		if (!dev)
>  			return ret;
> @@ -149,12 +150,12 @@ int rdma_translate_ip(struct sockaddr *addr, st=
ruct rdma_dev_addr *dev_addr,
>  			*vlan_id =3D rdma_vlan_dev_vlan_id(dev);
>  		dev_put(dev);
>  		break;
> -
> +	}

closing } here ?

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
> @@ -236,7 +237,7 @@ static int addr4_resolve(struct sockaddr_in *src_=
in,
>  	fl4.daddr =3D dst_ip;
>  	fl4.saddr =3D src_ip;
>  	fl4.flowi4_oif =3D addr->bound_dev_if;
> -	rt =3D ip_route_output_key(&init_net, &fl4);
> +	rt =3D ip_route_output_key(addr->net, &fl4);
>  	if (IS_ERR(rt)) {
>  		ret =3D PTR_ERR(rt);
>  		goto out;
> @@ -278,12 +279,13 @@ static int addr6_resolve(struct sockaddr_in6 *s=
rc_in,
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
> @@ -458,7 +460,7 @@ static void resolve_cb(int status, struct sockadd=
r *src_addr,
>  }
> =20
>  int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgi=
d, u8 *dmac,
> -			       u16 *vlan_id)
> +			       u16 *vlan_id, struct net *net)
>  {
>  	int ret =3D 0;
>  	struct rdma_dev_addr dev_addr;
> @@ -481,6 +483,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid=
, union ib_gid *dgid, u8 *dmac,
>  		return ret;
> =20
>  	memset(&dev_addr, 0, sizeof(dev_addr));
> +	dev_addr.net =3D net;

Should be get_net() be used somewhere to grab a reference on the net
namespace ?

> =20
>  	ctx.addr =3D &dev_addr;
>  	init_completion(&ctx.comp);
> @@ -492,7 +495,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid=
, union ib_gid *dgid, u8 *dmac,
>  	wait_for_completion(&ctx.comp);
> =20
>  	memcpy(dmac, dev_addr.dst_dev_addr, ETH_ALEN);
> -	dev =3D dev_get_by_index(&init_net, dev_addr.bound_dev_if);
> +	dev =3D dev_get_by_index(net, dev_addr.bound_dev_if);
>  	if (!dev)
>  		return -ENODEV;
>  	if (vlan_id)
> @@ -502,7 +505,8 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid=
, union ib_gid *dgid, u8 *dmac,
>  }
>  EXPORT_SYMBOL(rdma_addr_find_dmac_by_grh);
> =20
> -int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *v=
lan_id)
> +int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *v=
lan_id,
> +				struct net *net)
>  {
>  	int ret =3D 0;
>  	struct rdma_dev_addr dev_addr;
> @@ -517,6 +521,7 @@ int rdma_addr_find_smac_by_sgid(union ib_gid *sgi=
d, u8 *smac, u16 *vlan_id)
>  	if (ret)
>  		return ret;
>  	memset(&dev_addr, 0, sizeof(dev_addr));
> +	dev_addr.net =3D net;

get_net() ?

>  	ret =3D rdma_translate_ip(&gid_addr._sockaddr, &dev_addr, vlan_id);
>  	if (ret)
>  		return ret;
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/=
cma.c
> index 6e5e11ca7702..aeb2417ec928 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -512,6 +512,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_h=
andler event_handler,
>  	INIT_LIST_HEAD(&id_priv->listen_list);
>  	INIT_LIST_HEAD(&id_priv->mc_list);
>  	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
> +	id_priv->id.route.addr.dev_addr.net =3D &init_net;
> =20
>  	return &id_priv->id;
>  }
> @@ -637,7 +638,8 @@ static int cma_modify_qp_rtr(struct rdma_id_priva=
te *id_priv,
>  	    =3D=3D RDMA_TRANSPORT_IB &&
>  	    rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_n=
um)
>  	    =3D=3D IB_LINK_LAYER_ETHERNET) {
> -		ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
> +		ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL,
> +						  &init_net);
> =20
>  		if (ret)
>  			goto out;
> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/cor=
e/verbs.c
> index f93eb8da7b5a..ca5c4dd8a67a 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -212,7 +212,9 @@ int ib_init_ah_from_wc(struct ib_device *device, =
u8 port_num, struct ib_wc *wc,
>  			ah_attr->vlan_id =3D wc->vlan_id;
>  		} else {
>  			ret =3D rdma_addr_find_dmac_by_grh(&grh->dgid, &grh->sgid,
> -					ah_attr->dmac, &ah_attr->vlan_id);
> +							 ah_attr->dmac,
> +							 &ah_attr->vlan_id,
> +							 &init_net);
>  			if (ret)
>  				return ret;
>  		}
> @@ -882,11 +884,15 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
>  			if (!(*qp_attr_mask & IB_QP_VID))
>  				qp_attr->vlan_id =3D rdma_get_vlan_id(&sgid);
>  		} else {
> -			ret =3D rdma_addr_find_dmac_by_grh(&sgid, &qp_attr->ah_attr.grh.d=
gid,
> -					qp_attr->ah_attr.dmac, &qp_attr->vlan_id);
> +			ret =3D rdma_addr_find_dmac_by_grh(
> +				&sgid,
> +				&qp_attr->ah_attr.grh.dgid,
> +				qp_attr->ah_attr.dmac, &qp_attr->vlan_id,
> +				&init_net);
>  			if (ret)
>  				goto out;
> -			ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac, NULL);
> +			ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac,
> +							  NULL, &init_net);
>  			if (ret)
>  				goto out;
>  		}
> diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c b/drivers/infin=
iband/hw/ocrdma/ocrdma_ah.c
> index f3cc8c9e65ae..debaac2b6ee8 100644
> --- a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> +++ b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
> @@ -119,7 +119,8 @@ struct ib_ah *ocrdma_create_ah(struct ib_pd *ibpd=
, struct ib_ah_attr *attr)
> =20
>  	if (pd->uctx) {
>  		status =3D rdma_addr_find_dmac_by_grh(&sgid, &attr->grh.dgid,
> -                                        attr->dmac, &attr->vlan_id);
> +						    attr->dmac, &attr->vlan_id,
> +						    &init_net);
>  		if (status) {
>  			pr_err("%s(): Failed to resolve dmac from gid."=20
>  				"status =3D %d\n", __func__, status);
> diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
> index ce55906b54a0..40ccf8b83755 100644
> --- a/include/rdma/ib_addr.h
> +++ b/include/rdma/ib_addr.h
> @@ -47,6 +47,7 @@
>  #include <rdma/ib_verbs.h>
>  #include <rdma/ib_pack.h>
>  #include <net/ipv6.h>
> +#include <net/net_namespace.h>
> =20
>  struct rdma_addr_client {
>  	atomic_t refcount;
> @@ -64,6 +65,16 @@ void rdma_addr_register_client(struct rdma_addr_cl=
ient *client);
>   */
>  void rdma_addr_unregister_client(struct rdma_addr_client *client);
> =20
> +/**
> + * struct rdma_dev_addr - Contains resolved RDMA hardware addresses
> + * @src_dev_addr:	Source MAC address.
> + * @dst_dev_addr:	Destination MAC address.
> + * @broadcast:		Broadcast address of the device.
> + * @dev_type:		The interface hardware type of the device.
> + * @bound_dev_if:	An optional device interface index.
> + * @transport:		The transport type used.
> + * @net:		Network namespace containing the bound_dev_if net_dev.
> + */
>  struct rdma_dev_addr {
>  	unsigned char src_dev_addr[MAX_ADDR_LEN];
>  	unsigned char dst_dev_addr[MAX_ADDR_LEN];
> @@ -71,11 +82,14 @@ struct rdma_dev_addr {
>  	unsigned short dev_type;
>  	int bound_dev_if;
>  	enum rdma_transport_type transport;
> +	struct net *net;
>  };
> =20
>  /**
>   * rdma_translate_ip - Translate a local IP address to an RDMA hardw=
are
>   *   address.
> + *
> + * The dev_addr->net field must be initialized.
>   */
>  int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *d=
ev_addr,
>  		      u16 *vlan_id);
> @@ -90,7 +104,7 @@ int rdma_translate_ip(struct sockaddr *addr, struc=
t rdma_dev_addr *dev_addr,
>   * @dst_addr: The destination address to resolve.
>   * @addr: A reference to a data location that will receive the resol=
ved
>   *   addresses.  The data location must remain valid until the callb=
ack has
> - *   been invoked.
> + *   been invoked. The net field of the addr struct must be valid.
>   * @timeout_ms: Amount of time to wait for the address resolution to=
 complete.
>   * @callback: Call invoked once address resolution has completed, ti=
med out,
>   *   or been canceled.  A status of 0 indicates success.
> @@ -110,9 +124,29 @@ int rdma_copy_addr(struct rdma_dev_addr *dev_add=
r, struct net_device *dev,
> =20
>  int rdma_addr_size(struct sockaddr *addr);
> =20
> -int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *v=
lan_id);
> -int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgi=
d, u8 *smac,
> -			       u16 *vlan_id);
> +/** rdma_addr_find_smac_by_sgid() - Find the src MAC and VLAN ID for=
 a src GID
> + * @sgid:	Source GID to find the MAC and VLAN for.
> + * @smac:	A buffer to contain the resulting MAC address.
> + * @vlan_id:	Will contain the resulting VLAN ID.
> + * @net:	Network namespace to use for the address resolution.
> + *
> + * It is the caller's responsibility to keep the network namespace a=
live until
> + * the function returns.

Why ?

> + */
> +int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *v=
lan_id,
> +				struct net *net);
> +/** rdma_addr_find_dmac_by_grh() - Find the dst MAC and VLAN ID for =
a GID pair
> + * @sgid:	Source GID to use for the search.
> + * @dgid:	Destination GID to find the details for.
> + * @dmac:	Contains the resulting destination MAC address.
> + * @vlan_id:	Contains the resulting VLAN ID.
> + * @net:	Network namespace to use for the address resolution.
> + *
> + * It is the caller's responsibility to keep the network namespace a=
live until
> + * the function returns.

Why ?

> + */
> +int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgi=
d, u8 *dmac,
> +			       u16 *vlan_id, struct net *net);
> =20
>  static inline u16 ib_addr_get_pkey(struct rdma_dev_addr *dev_addr)
>  {
> @@ -182,7 +216,7 @@ static inline void iboe_addr_get_sgid(struct rdma=
_dev_addr *dev_addr,
>  	struct net_device *dev;
>  	struct in_device *ip4;
> =20
> -	dev =3D dev_get_by_index(&init_net, dev_addr->bound_dev_if);
> +	dev =3D dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
>  	if (dev) {
>  		ip4 =3D (struct in_device *)dev->ip_ptr;
>  		if (ip4 && ip4->ifa_list && ip4->ifa_list->ifa_address)


I believe this patch lack proper reference counting in form of
get_net() / put_net(), but cannot say for sure.

Regards.

--=20
Yann Droneaud
OPTEYA


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
