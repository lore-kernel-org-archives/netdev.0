From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v5, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Fri, 27 Jan 2012 11:38:41 +0100
Message-ID: <1327660721.2220.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <21673653.551327658293199.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21673653.551327658293199.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 27 janvier 2012 =C3=A0 10:58 +0100, Stefan Gula a =C3=A9cri=
t :
> From: Stefan Gula <steweg@gmail.com>
>=20

=2E..

> +static struct macvlan_source_list *macvlan_hash_lookup_sources_list(
> +	const struct macvlan_dev *vlan,
> +	const unsigned char *addr)
> +{
> +	struct macvlan_source_list *list;
> +	struct hlist_node *n;
> +	struct hlist_head *h =3D &vlan->port->vlan_source_hash[addr[5]];
> +
> +	hlist_for_each_entry_rcu(list, n, h, hlist) {

You dont hold rcu_read_lock() here, and dont need to, since you are in
the controler path, rtnl is locked :

	hlist_for_each_entry(...)

> +		if (!compare_ether_addr_64bits(list->addr, addr) &&
> +		    list->vlan =3D=3D vlan)
> +			return list;
> +	}
> +	return NULL;
> +}
> +
> +static int macvlan_hash_add_sources(struct macvlan_dev *vlan,
> +				    const unsigned char *addr)
> +{
> +	struct macvlan_port *port =3D vlan->port;
> +	struct macvlan_source_list *list;
> +	struct hlist_head *h;
> +
> +	list =3D macvlan_hash_lookup_sources_list(vlan, addr);
> +	if (!list) {
> +		list =3D kmalloc(sizeof(*list), GFP_KERNEL);

By the way, use of GFP_KERNEL here is a proof you dont hold
rcu_read_lock().

(If you were, you would not be allowed to sleep in kmalloc())

> +		if (list) {
> +			memcpy(list->addr, addr, ETH_ALEN);
> +			list->vlan =3D vlan;
> +			h =3D &port->vlan_source_hash[addr[5]];
> +			hlist_add_head_rcu(&list->hlist, h);
> +		} else
> +			return -ENOMEM;

	if (cond) {
		foo;
		bar;
	} else {
		blip;
	}


> +	}
> +	return 0;
> +}
> +
> +static void macvlan_hash_del_sources(struct macvlan_source_list *lis=
t)
> +{
> +	hlist_del_rcu(&list->hlist);
> +	kfree_rcu(list, rcu);
> +}
> +

=2E..

> +static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 =
mode,
> +				      unsigned char *addr)
> +{
> +	if (mode =3D=3D MACVLAN_MACADDR_ADD)
> +		return macvlan_hash_add_sources(vlan, addr);
> +

Same codestyle here...

	if (cond) {
		foo;
	} else if (cond2) {
	} else {
		blip;
	}


> +	else if (mode =3D=3D MACVLAN_MACADDR_DEL) {
> +		struct macvlan_source_list *list;
> +
> +		list =3D macvlan_hash_lookup_sources_list(vlan, addr);
> +		if (list)
> +			macvlan_hash_del_sources(list);
> +	} else
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
