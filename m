From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: Synchronize unicast filtering with FDB
Date: Fri, 3 Jun 2016 17:54:55 +0300
Message-ID: <F363D072-00A6-447C-9EA8-646362CC9F40@cumulusnetworks.com>
References: <1464942808-3945-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Patrick Schaaf <netdev@bof.de>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35684 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcFCOyz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 10:54:55 -0400
Received: by mail-wm0-f51.google.com with SMTP id a136so280162830wme.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 07:54:54 -0700 (PDT)
In-Reply-To: <1464942808-3945-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 3, 2016, at 11:33 AM, Toshiaki Makita <makita.toshiaki@lab.ntt=
=2Eco.jp> wrote:
>=20
> Patrick Schaaf reported that flooding due to a missing fdb entry of
> the address of macvlan on the bridge device caused high CPU
> consumption of an openvpn process behind a tap bridge port.
> Adding an fdb entry of the macvlan address can suppress flooding
> and avoid this problem.
>=20
> This change makes bridge able to synchronize unicast filtering with
> fdb automatically so admin do not need to manually add an fdb entry.
> This effectively supports IFF_UNICAST_FLT in bridge, thus adding an
> macvlan device would not place bridge into promiscuous mode as well.
>=20
> Reported-by: Patrick Schaaf <netdev@bof.de>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
> net/bridge/br_device.c  |   7 +--
> net/bridge/br_fdb.c     | 117 +++++++++++++++++++++++++++++++++++++++=
++++-----
> net/bridge/br_private.h |   7 +--
> net/bridge/br_vlan.c    |  11 +++--
> 4 files changed, 120 insertions(+), 22 deletions(-)
>=20
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 2c8095a..9b56802 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -123,8 +123,9 @@ static int br_dev_open(struct net_device *dev)
> 	return 0;
> }
>=20
> -static void br_dev_set_multicast_list(struct net_device *dev)
> +static void br_dev_set_rx_mode(struct net_device *dev)
> {
> +	br_fdb_sync_uc(netdev_priv(dev));
> }
>=20
> static void br_dev_change_rx_flags(struct net_device *dev, int change=
)
> @@ -329,7 +330,7 @@ static const struct net_device_ops br_netdev_ops =
=3D {
> 	.ndo_start_xmit		 =3D br_dev_xmit,
> 	.ndo_get_stats64	 =3D br_get_stats64,
> 	.ndo_set_mac_address	 =3D br_set_mac_address,
> -	.ndo_set_rx_mode	 =3D br_dev_set_multicast_list,
> +	.ndo_set_rx_mode	 =3D br_dev_set_rx_mode,
> 	.ndo_change_rx_flags	 =3D br_dev_change_rx_flags,
> 	.ndo_change_mtu		 =3D br_change_mtu,
> 	.ndo_do_ioctl		 =3D br_dev_ioctl,
> @@ -373,7 +374,7 @@ void br_dev_setup(struct net_device *dev)
> 	dev->destructor =3D br_dev_free;
> 	dev->ethtool_ops =3D &br_ethtool_ops;
> 	SET_NETDEV_DEVTYPE(dev, &br_type);
> -	dev->priv_flags =3D IFF_EBRIDGE | IFF_NO_QUEUE;
> +	dev->priv_flags =3D IFF_EBRIDGE | IFF_NO_QUEUE | IFF_UNICAST_FLT;
>=20
> 	dev->features =3D COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOC=
AL |
> 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index dcea4f4..bc082e6 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -184,28 +184,36 @@ static void fdb_delete_local(struct net_bridge =
*br,
> 	vg =3D br_vlan_group(br);
> 	v =3D br_vlan_find(vg, vid);
> 	/* Maybe bridge device has same hw addr? */
> -	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
> -	    (!vid || (v && br_vlan_should_use(v)))) {
> -		f->dst =3D NULL;
> -		f->added_by_user =3D 0;
> -		return;
> +	if (p && (!vid || (v && br_vlan_should_use(v)))) {
> +		struct netdev_hw_addr *ha;
> +
> +		if (ether_addr_equal(br->dev->dev_addr, addr)) {
> +			f->dst =3D NULL;
> +			f->added_by_user =3D 0;
> +			return;
> +		}
> +		netdev_for_each_uc_addr(ha, br->dev) {

I think you need either netif_addr_lock or RCU in order to walk safely =
over the uc list.

> +			if (ether_addr_equal(ha->addr, addr)) {
> +				f->dst =3D NULL;
> +				f->added_by_user =3D 0;
> +				return;
> +			}
> +		}
> 	}
>=20
> 	fdb_delete(br, f);
> }
>=20
> -void br_fdb_find_delete_local(struct net_bridge *br,
> -			      const struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid)
> +static void fdb_find_delete_local(struct net_bridge *br,
> +				  const struct net_bridge_port *p,
> +				  const unsigned char *addr, u16 vid)
> {
> 	struct hlist_head *head =3D &br->hash[br_mac_hash(addr, vid)];
> 	struct net_bridge_fdb_entry *f;
>=20
> -	spin_lock_bh(&br->hash_lock);
> 	f =3D fdb_find(head, addr, vid);
> 	if (f && f->is_local && !f->added_by_user && f->dst =3D=3D p)
> 		fdb_delete_local(br, p, f);
> -	spin_unlock_bh(&br->hash_lock);
> }
>=20
> void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char=
 *newaddr)
> @@ -288,6 +296,95 @@ out:
> 	spin_unlock_bh(&br->hash_lock);
> }
>=20
> +void br_fdb_sync_uc(struct net_bridge *br)
> +{
> +	struct net_bridge_vlan_group *vg;
> +	struct netdev_hw_addr *ha;
> +	int i;
> +
> +	spin_lock_bh(&br->hash_lock);
> +
> +	for (i =3D 0; i < BR_HASH_SIZE; i++) {
> +		struct hlist_node *h;
> +
> +		hlist_for_each(h, &br->hash[i]) {
> +			struct net_bridge_fdb_entry *f;
> +
> +			f =3D hlist_entry(h, struct net_bridge_fdb_entry, hlist);
> +			if (!f->dst && f->is_local && !f->added_by_user &&
> +			    !ether_addr_equal(f->addr.addr, br->dev->dev_addr)) {
> +				/* delete old one */
> +				fdb_delete_local(br, NULL, f);
> +			}
> +		}
> +	}
> +
> +	vg =3D br_vlan_group(br);
> +
> +	/* insert new address,  may fail if invalid address or dup. */
> +	netdev_for_each_uc_addr(ha, br->dev) {
> +		struct net_bridge_vlan *v;
> +
> +		fdb_insert(br, NULL, ha->addr, 0);
> +
> +		if (!vg || !vg->num_vlans)
> +			continue;
> +
> +		list_for_each_entry(v, &vg->vlan_list, vlist)
> +			fdb_insert(br, NULL, ha->addr, v->vid);

Since here you=E2=80=99re walking over the bridge=E2=80=99s vlan list, =
you should test the vlans with br_vlan_should_use()
because it can be a global context holder if the vlan was configured on=
ly on ports.

> +	}
> +
> +	spin_unlock_bh(&br->hash_lock);
> +}
> +
> +int br_fdb_add_vlan(struct net_bridge *br, struct net_bridge_port *p=
, u16 vid)
> +{
> +	struct netdev_hw_addr *ha, *ha2;
> +	int err =3D 0;
> +
> +	spin_lock_bh(&br->hash_lock);
> +	if (p) {
> +		err =3D fdb_insert(br, p, p->dev->dev_addr, vid);
> +	} else {
> +		netdev_for_each_uc_addr(ha, br->dev) {

Same here for walking the uc list.

> +			err =3D fdb_insert(br, NULL, ha->addr, vid);
> +			if (err)
> +				goto undo;
> +		}
> +		err =3D fdb_insert(br, NULL, br->dev->dev_addr, vid);
> +		if (err)
> +			goto undo;
> +	}
> +out:
> +	spin_unlock_bh(&br->hash_lock);
> +
> +	return err;
> +
> +undo:
> +	netdev_for_each_uc_addr(ha2, br->dev) {
> +		if (ha2 =3D=3D ha)
> +			break;
> +		fdb_find_delete_local(br, NULL, ha2->addr, vid);
> +	}
> +	goto out;
> +}
> +
> +void br_fdb_delete_vlan(struct net_bridge *br, struct net_bridge_por=
t *p,
> +			u16 vid)
> +{
> +	struct netdev_hw_addr *ha;
> +
> +	spin_lock_bh(&br->hash_lock);
> +	if (p) {
> +		fdb_find_delete_local(br, p, p->dev->dev_addr, vid);
> +	} else {
> +		netdev_for_each_uc_addr(ha, br->dev)
> +			fdb_find_delete_local(br, NULL, ha->addr, vid);

Same comment for walking over the uc addr list and locking.

> +		fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
> +	}
> +	spin_unlock_bh(&br->hash_lock);
> +}
> +
> void br_fdb_cleanup(unsigned long _data)
> {
> 	struct net_bridge *br =3D (struct net_bridge *)_data;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index c7fb5d7..d07d24c 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -463,11 +463,12 @@ static inline void br_netpoll_disable(struct ne=
t_bridge_port *p)
> int br_fdb_init(void);
> void br_fdb_fini(void);
> void br_fdb_flush(struct net_bridge *br);
> -void br_fdb_find_delete_local(struct net_bridge *br,
> -			      const struct net_bridge_port *p,
> -			      const unsigned char *addr, u16 vid);
> void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char=
 *newaddr);
> void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newad=
dr);
> +void br_fdb_sync_uc(struct net_bridge *br);
> +int br_fdb_add_vlan(struct net_bridge *br, struct net_bridge_port *p=
, u16 vid);
> +void br_fdb_delete_vlan(struct net_bridge *br, struct net_bridge_por=
t *p,
> +			u16 vid);
> void br_fdb_cleanup(unsigned long arg);
> void br_fdb_delete_by_port(struct net_bridge *br,
> 			   const struct net_bridge_port *p, u16 vid, int do_all);
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index b6de4f4..86ac873 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -246,7 +246,7 @@ static int __vlan_add(struct net_bridge_vlan *v, =
u16 flags)
>=20
> 	/* Add the dev mac and count the vlan only if it's usable */
> 	if (br_vlan_should_use(v)) {
> -		err =3D br_fdb_insert(br, p, dev->dev_addr, v->vid);
> +		err =3D br_fdb_add_vlan(br, p, v->vid);
> 		if (err) {
> 			br_err(br, "failed insert local address into bridge forwarding tab=
le\n");
> 			goto out_filt;
> @@ -266,7 +266,7 @@ out:
>=20
> out_fdb_insert:
> 	if (br_vlan_should_use(v)) {
> -		br_fdb_find_delete_local(br, p, dev->dev_addr, v->vid);
> +		br_fdb_delete_vlan(br, p, v->vid);
> 		vg->num_vlans--;
> 	}
>=20
> @@ -557,8 +557,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u=
16 flags)
> 			if (!(flags & BRIDGE_VLAN_INFO_BRENTRY))
> 				return -EINVAL;
> 			/* It was only kept for port vlans, now make it real */
> -			ret =3D br_fdb_insert(br, NULL, br->dev->dev_addr,
> -					    vlan->vid);
> +			ret =3D br_fdb_add_vlan(br, NULL, vlan->vid);
> 			if (ret) {
> 				br_err(br, "failed insert local address into bridge forwarding ta=
ble\n");
> 				return ret;
> @@ -610,7 +609,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid=
)
> 	if (!v || !br_vlan_is_brentry(v))
> 		return -ENOENT;
>=20
> -	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
> +	br_fdb_delete_vlan(br, NULL, vid);
> 	br_fdb_delete_by_port(br, NULL, vid, 0);
>=20
> 	return __vlan_del(v);
> @@ -1036,7 +1035,7 @@ int nbp_vlan_delete(struct net_bridge_port *por=
t, u16 vid)
> 	v =3D br_vlan_find(nbp_vlan_group(port), vid);
> 	if (!v)
> 		return -ENOENT;
> -	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
> +	br_fdb_delete_vlan(port->br, port, vid);
> 	br_fdb_delete_by_port(port->br, port, vid, 0);
>=20
> 	return __vlan_del(v);
> --=20
> 1.8.3.1
>=20
>=20
>=20
