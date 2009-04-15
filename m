From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses	dev_addr_list
Date: Wed, 15 Apr 2009 11:27:50 +0200
Message-ID: <49E5A896.90408@cosmosbay.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <49E59A1C.9030108@cn.fujitsu.com> <20090415083223.GF21342@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758874AbZDOJbJ@vger.kernel.org>
In-Reply-To: <20090415083223.GF21342@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko a =E9crit :
> This patch introduces a new list in struct net_device and brings a se=
t of
> functions to handle the work with device address list. The list is a =
replacement
> for the original dev_addr field and because in some situations there =
is need to
> carry several device addresses with the net device. To be backward co=
mpatible,
> dev_addr is made to point to the first member of the list so original=
 drivers
> sees no difference.
>=20

You see no difference ? Please look more closely...

I see one additional dereference in hot path, to small objects possibly
with false sharing effects.

So I would advise not changing dev_addr[] to a pointer.
And instead copy first netdev_hw_addr into it.

Also, doing a kzalloc(sizeof(struct netdev_hw_addr)) for allocating the=
se structs
might give a block of memory < L1_CACHE_SIZE so kernel is free to give =
other
part of this cache line to some other layer that could be a hot spot, s=
o
false sharing could happen.

kzalloc(max(sizeof(*ha), L1_CACHE_SIZE)) is thus higly recommended here=
=2E

> Note: patch adding list_first_entry_rcu (currently in Ingo's tip tree=
) needed.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  include/linux/etherdevice.h |   24 ++++
>  include/linux/netdevice.h   |   31 +++++-
>  net/core/dev.c              |  263 +++++++++++++++++++++++++++++++++=
++++++++++
>  3 files changed, 316 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.=
h
> index a1f17ab..348a75e 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -205,4 +205,28 @@ static inline int compare_ether_header(const voi=
d *a, const void *b)
>  	       (a32[1] ^ b32[1]) | (a32[2] ^ b32[2]);
>  }
> =20
> +/**
> + * is_etherdev_addr - Tell if given Ethernet address belongs to the =
device.
> + * @dev: Pointer to a device structure
> + * @addr: Pointer to a six-byte array containing the Ethernet addres=
s
> + *
> + * Compare passed address with all addresses of the device. Return t=
rue if the
> + * address if one of the device addresses.
> + */
> +static inline bool is_etherdev_addr(const struct net_device *dev,
> +				    const u8 *addr)
> +{
> +	struct netdev_hw_addr *ha;
> +	int res =3D 1;
> +
> +	rcu_read_lock();
> +	for_each_dev_addr(dev, ha) {
> +		res =3D compare_ether_addr(addr, ha->addr);

compare_ether_addr_64bits() please ?

> +		if (!res)
> +			break;
> +	}
> +	rcu_read_unlock();
> +	return !res;
> +}
> +
>  #endif	/* _LINUX_ETHERDEVICE_H */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 2e7783f..77abfdf 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -210,6 +210,12 @@ struct dev_addr_list
>  #define dmi_users	da_users
>  #define dmi_gusers	da_gusers
> =20
> +struct netdev_hw_addr {
> +	struct list_head	list;
> +	unsigned char		addr[MAX_ADDR_LEN];
> +	int			refcount;
> +};
> +
>  struct hh_cache
>  {
>  	struct hh_cache *hh_next;	/* Next entry			     */
> @@ -776,8 +782,11 @@ struct net_device
>   */
>  	unsigned long		last_rx;	/* Time of last Rx	*/
>  	/* Interface address info used in eth_type_trans() */
> -	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast
> -							   because most packets are unicast) */
> +	unsigned char		*dev_addr;	/* hw address, (before bcast
> +						   because most packets are
> +						   unicast) */
> +
> +	struct list_head	dev_addr_list; /* list of device hw addresses */
> =20
>  	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
> =20
> @@ -1778,6 +1787,13 @@ static inline void netif_addr_unlock_bh(struct=
 net_device *dev)
>  	spin_unlock_bh(&dev->addr_list_lock);
>  }
> =20
> +/*
> + * dev_addr_list walker. Should be used only for read access. Call w=
ith
> + * rcu_read_lock held.
> + */
> +#define for_each_dev_addr(dev, ha) \
> +		list_for_each_entry_rcu(ha, &dev->dev_addr_list, list)
> +
>  /* These functions live elsewhere (drivers/net/net_init.c, but relat=
ed) */
> =20
>  extern void		ether_setup(struct net_device *dev);
> @@ -1790,6 +1806,17 @@ extern struct net_device *alloc_netdev_mq(int =
sizeof_priv, const char *name,
>  	alloc_netdev_mq(sizeof_priv, name, setup, 1)
>  extern int		register_netdev(struct net_device *dev);
>  extern void		unregister_netdev(struct net_device *dev);
> +
> +/* Functions used for device addresses handling */
> +extern int		dev_addr_add(struct net_device *dev,
> +				     unsigned char *addr);
> +extern int		dev_addr_del(struct net_device *dev,
> +				     unsigned char *addr);
> +extern int		dev_addr_add_multiple(struct net_device *to_dev,
> +					      struct net_device *from_dev);
> +extern int		dev_addr_del_multiple(struct net_device *to_dev,
> +					      struct net_device *from_dev);
> +
>  /* Functions used for secondary unicast and multicast support */
>  extern void		dev_set_rx_mode(struct net_device *dev);
>  extern void		__dev_set_rx_mode(struct net_device *dev);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 91d792d..04cddbb 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3437,6 +3437,262 @@ void dev_set_rx_mode(struct net_device *dev)
>  	netif_addr_unlock_bh(dev);
>  }
> =20
> +/* hw addresses list handling functions */
> +
> +static int __hw_addr_add_ii(struct list_head *list, unsigned char *a=
ddr,
> +			    int addr_len, int ignore_index)
> +{
> +	struct netdev_hw_addr *ha;
> +	int i =3D 0;
> +
> +	if (addr_len > MAX_ADDR_LEN)
> +		return -EINVAL;
> +
> +	rcu_read_lock();

This locking is highly suspect.

> +	list_for_each_entry_rcu(ha, list, list) {
> +		if (i++ !=3D ignore_index &&
> +		    !memcmp(ha->addr, addr, addr_len)) {
> +			ha->refcount++;
> +			rcu_read_unlock();
> +			return 0;
> +		}
> +	}
> +	rcu_read_unlock();

Since you obviously need a write lock here to be sure following
can be done by one cpu only.

You have same problem all over this patch.

> +
> +	ha =3D kzalloc(sizeof(*ha), GFP_ATOMIC);

kzalloc(max(sizeof(*ha), L1_CACHE_SIZE), GFP_...) is thus higly recomme=
nded here.

Also, why GFP_ATOMIC is needed here ?

> +	if (!ha)
> +		return -ENOMEM;
> +	memcpy(ha->addr, addr, addr_len);
> +	ha->refcount =3D 1;
> +	list_add_tail_rcu(&ha->list, list);
> +	return 0;
> +}
> +
> +static int __hw_addr_add(struct list_head *list, unsigned char *addr=
,
> +				int addr_len)
> +{
> +	return __hw_addr_add_ii(list, addr, addr_len, -1);
> +}
> +
> +static int __hw_addr_del_ii(struct list_head *list, unsigned char *a=
ddr,
> +			    int addr_len, int ignore_index)
> +{
> +	struct netdev_hw_addr *ha;
> +	int i =3D 0;
> +
> +	list_for_each_entry(ha, list, list) {
> +		if (i++ !=3D ignore_index &&
> +		    !memcmp(ha->addr, addr, addr_len)) {
> +			if (--ha->refcount)
> +				return 0;
> +			list_del_rcu(&ha->list);
> +			synchronize_rcu();

Oh well... I'm pretty sure this synchronize_rcu() call can be avoided,
dont you think ? Check kfree_rcu() or equivalent, as it seems not yet
included in current kernels...

> +			kfree(ha);
> +			return 0;
> +		}
> +	}
> +	return -ENOENT;
> +}
> +
> +static int __hw_addr_del(struct list_head *list, unsigned char *addr=
,
> +				int addr_len)
> +{
> +	return __hw_addr_del_ii(list, addr, addr_len, -1);
> +}
> +
> +static int __hw_addr_add_multiple_ii(struct list_head *to_list,
> +				     struct list_head *from_list,
> +				     int addr_len, int ignore_index)
> +{
> +	int err =3D 0;
> +	struct netdev_hw_addr *ha, *ha2;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ha, from_list, list) {
> +		err =3D __hw_addr_add_ii(to_list, ha->addr, addr_len, 0);
> +		if (err)
> +			goto unroll;
> +	}
> +	goto unlock;
> +unroll:
> +	list_for_each_entry_rcu(ha2, from_list, list) {
> +		if (ha2 =3D=3D ha)
> +			break;
> +		__hw_addr_del_ii(to_list, ha2->addr, addr_len, 0);
> +	}
> +unlock:
> +	rcu_read_unlock();
> +	return err;
> +}
> +
> +static int __hw_addr_add_multiple(struct list_head *to_list,
> +					 struct list_head *from_list,
> +					 int addr_len)
> +{
> +	return __hw_addr_add_multiple_ii(to_list, from_list, addr_len, -1);
> +}
> +
> +static void __hw_addr_del_multiple_ii(struct list_head *to_list,
> +				      struct list_head *from_list,
> +				      int addr_len, int ignore_index)
> +{
> +	struct netdev_hw_addr *ha;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ha, from_list, list) {
> +		__hw_addr_del_ii(to_list, ha->addr, addr_len, 0);
> +	}
> +	rcu_read_unlock();
> +}
> +
> +static void __hw_addr_del_multiple(struct list_head *to_list,
> +					 struct list_head *from_list,
> +					 int addr_len)
> +{
> +	__hw_addr_del_multiple_ii(to_list, from_list, addr_len, -1);
> +}
> +
> +static void __hw_addr_flush(struct list_head *list)
> +{
> +	struct netdev_hw_addr *ha, *tmp;
> +
> +	list_for_each_entry_safe(ha, tmp, list, list) {
> +		list_del_rcu(&ha->list);
> +		synchronize_rcu();

	Oh no... :(

> +		kfree(ha);
> +	}
> +}
> +
> +/* Device addresses handling functions */
> +
> +static void dev_addr_flush(struct net_device *dev)
> +{
> +	__hw_addr_flush(&dev->dev_addr_list);
> +	dev->dev_addr =3D NULL;
> +}
> +
> +static int dev_addr_init(struct net_device *dev)
> +{
> +	unsigned char addr[MAX_ADDR_LEN];
> +	struct netdev_hw_addr *ha;
> +	int err;
> +
> +	INIT_LIST_HEAD(&dev->dev_addr_list);
> +	memset(addr, 0, sizeof(*addr));
> +	err =3D __hw_addr_add(&dev->dev_addr_list, addr, sizeof(*addr));
> +	if (!err) {
> +		/*
> +		 * Get the first (previously created) address from the list
> +		 * and set dev_addr pointer to this location.
> +		 */
> +		rcu_read_lock();

locking is not correct or unnecessary

> +		ha =3D list_first_entry_rcu(&dev->dev_addr_list,
> +					  struct netdev_hw_addr, list);
> +		dev->dev_addr =3D ha->addr;
> +		rcu_read_unlock();
> +	}
> +	return err;
> +}
> +
> +/**
> + *	dev_addr_add	- Add a device address
> + *	@dev: device
> + *	@addr: address to add
> + *
> + *	Add a device address to the device or increase the reference coun=
t if
> + *	it already exists.
> + *
> + *	The caller must hold the rtnl_mutex.
> + */
> +int dev_addr_add(struct net_device *dev, unsigned char *addr)
> +{
> +	int err;
> +
> +	ASSERT_RTNL();
> +
> +	err =3D __hw_addr_add_ii(&dev->dev_addr_list, addr, dev->addr_len, =
0);
> +	if (!err)
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +	return err;
> +}
> +EXPORT_SYMBOL(dev_addr_add);
> +
> +/**
> + *	dev_addr_del	- Release a device address.
> + *	@dev: device
> + *	@addr: address to delete
> + *
> + *	Release reference to a device address and remove it from the devi=
ce
> + *	if the reference count drops to zero.
> + *
> + *	The caller must hold the rtnl_mutex.
> + */
> +int dev_addr_del(struct net_device *dev, unsigned char *addr)
> +{
> +	int err;
> +
> +	ASSERT_RTNL();
> +
> +	err =3D __hw_addr_del_ii(&dev->dev_addr_list, addr, dev->addr_len, =
0);
> +	if (!err)
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +	return err;
> +}
> +EXPORT_SYMBOL(dev_addr_del);
> +
> +/**
> + *	dev_addr_add_multiple	- Add device addresses from another device
> + *	@to_dev: device to which addresses will be added
> + *	@from_dev: device from which addresses will be added
> + *
> + *	Add device addresses of the one device to another.
> + *
> + *	The caller must hold the rtnl_mutex.
> + */
> +int dev_addr_add_multiple(struct net_device *to_dev,
> +			  struct net_device *from_dev)
> +{
> +	int err;
> +
> +	ASSERT_RTNL();
> +
> +	if (from_dev->addr_len !=3D to_dev->addr_len)
> +		return -EINVAL;
> +	err =3D __hw_addr_add_multiple_ii(&to_dev->dev_addr_list,
> +					&from_dev->dev_addr_list,
> +					to_dev->addr_len, 0);
> +	if (!err)
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
> +	return err;
> +}
> +EXPORT_SYMBOL(dev_addr_add_multiple);
> +
> +/**
> + *	dev_addr_del_multiple	- Delete device addresses by another device
> + *	@to_dev: device where the addresses will be deleted
> + *	@from_dev: device by which addresses the addresses will be delete=
d
> + *
> + *	Deletes addresses in to device by the list of addresses in from d=
evice.
> + *
> + *	The caller must hold the rtnl_mutex.
> + */
> +int dev_addr_del_multiple(struct net_device *to_dev,
> +			  struct net_device *from_dev)
> +{
> +	ASSERT_RTNL();
> +
> +	if (from_dev->addr_len !=3D to_dev->addr_len)
> +		return -EINVAL;
> +	__hw_addr_add_multiple_ii(&to_dev->dev_addr_list,
> +				  &from_dev->dev_addr_list,
> +				  to_dev->addr_len, 0);
> +	call_netdevice_notifiers(NETDEV_CHANGEADDR, to_dev);
> +	return 0;
> +}
> +EXPORT_SYMBOL(dev_addr_del_multiple);
> +
> +/* unicast and multicast addresses handling functions */
> +
>  int __dev_addr_delete(struct dev_addr_list **list, int *count,
>  		      void *addr, int alen, int glbl)
>  {
> @@ -4257,6 +4513,9 @@ static void rollback_registered(struct net_devi=
ce *dev)
>  	 */
>  	dev_addr_discard(dev);
> =20
> +	/* Flush device addresses */
> +	dev_addr_flush(dev);
> +
>  	if (dev->netdev_ops->ndo_uninit)
>  		dev->netdev_ops->ndo_uninit(dev);
> =20
> @@ -4779,6 +5038,7 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
> =20
>  	dev->gso_max_size =3D GSO_MAX_SIZE;
> =20
> +	dev_addr_init(dev);
>  	netdev_init_queues(dev);
> =20
>  	INIT_LIST_HEAD(&dev->napi_list);
> @@ -4965,6 +5225,9 @@ int dev_change_net_namespace(struct net_device =
*dev, struct net *net, const char
>  	 */
>  	dev_addr_discard(dev);
> =20
> +	/* Flush device addresses */
> +	dev_addr_flush(dev);
> +
>  	netdev_unregister_kobject(dev);
> =20
>  	/* Actually switch the network namespace */
