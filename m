From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/7] vlan: Centralize handling of hardware
 acceleration.
Date: Wed, 13 Oct 2010 23:12:14 +0200
Message-ID: <1287004334.2649.43.camel@edumazet-laptop>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
	 <1287000177-7126-3-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62070 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524Ab0JMVMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:12:36 -0400
Received: by wyb28 with SMTP id 28so1502698wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 14:12:34 -0700 (PDT)
In-Reply-To: <1287000177-7126-3-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 13:02 -0700, Jesse Gross a =C3=A9cri=
t :
> Currently each driver that is capable of vlan hardware acceleration
> must be aware of the vlan groups that are configured and then pass
> the stripped tag to a specialized receive function.  This is
> different from other types of hardware offload in that it places a
> significant amount of knowledge in the driver itself rather keeping
> it in the networking core.
>=20
> This makes vlan offloading function more similarly to other forms
> of offloading (such as checksum offloading or TSO) by doing the
> following:
> * On receive, stripped vlans are passed directly to the network
> core, without attempting to check for vlan groups or reconstructing
> the header if no group
> * vlans are made less special by folding the logic into the main
> receive routines
> * On transmit, the device layer will add the vlan header in software
> if the hardware doesn't support it, instead of spreading that logic
> out in upper layers, such as bonding.
>=20
> There are a number of advantages to this:
> * Fixes all bugs with drivers incorrectly dropping vlan headers at on=
ce.
> * Avoids having to disable VLAN acceleration when in promiscuous mode
> (good for bridging since it always puts devices in promiscuous mode).
> * Keeps VLAN tag separate until given to ultimate consumer, which
> avoids needing to do header reconstruction as in tg3 unless absolutel=
y
> necessary.
> * Consolidates common code in core networking.
>=20
> Signed-off-by: Jesse Gross <jesse@nicira.com>


Hi Jesse !

Very nice and exciting code consolidation, but please read on :)

> ---
>  include/linux/if_vlan.h         |   27 ++++++++-
>  include/linux/netdevice.h       |   12 +++-
>  net/8021q/vlan.c                |  102 ++++++++---------------------=
--
>  net/8021q/vlan.h                |   17 -----
>  net/8021q/vlan_core.c           |  125 +++++++++--------------------=
----------
>  net/8021q/vlan_dev.c            |    2 +-
>  net/bridge/netfilter/ebt_vlan.c |    4 +-
>  net/core/dev.c                  |   42 ++++++++++++--
>  8 files changed, 129 insertions(+), 202 deletions(-)
>=20
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index a523207..e21028b 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -68,6 +68,7 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(cons=
t struct sk_buff *skb)
>  #define VLAN_CFI_MASK		0x1000 /* Canonical Format Indicator */
>  #define VLAN_TAG_PRESENT	VLAN_CFI_MASK
>  #define VLAN_VID_MASK		0x0fff /* VLAN Identifier */
> +#define VLAN_N_VID		4096
> =20

This should be a patch on its own (change VLAN_GROUP_ARRAY_LEN to
VLAN_N_ID), because this patch is too big.

Please try to not change too many things at once, you remove many
temporary variables and this only makes review very time consuming.

>  /* found in socket.c */
>  extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *))=
;
> @@ -76,7 +77,7 @@ extern void vlan_ioctl_set(int (*hook)(struct net *=
, void __user *));
>   * depends on completely exhausting the VLAN identifier space.  Thus
>   * it gives constant time look-up, but in many cases it wastes memor=
y.
>   */
> -#define VLAN_GROUP_ARRAY_LEN          4096
> +#define VLAN_GROUP_ARRAY_LEN          VLAN_N_VID
>  #define VLAN_GROUP_ARRAY_SPLIT_PARTS  8
>  #define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_GROUP_ARRAY_LEN/VLAN_GRO=
UP_ARRAY_SPLIT_PARTS)
> =20
> @@ -114,12 +115,24 @@ static inline void vlan_group_set_device(struct=
 vlan_group *vg,
>  #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESE=
NT)
> =20
>  #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> +/* Must be invoked with rcu_read_lock or with RTNL. */
> +static inline struct net_device *vlan_find_dev(struct net_device *re=
al_dev,
> +					       u16 vlan_id)
> +{
> +	struct vlan_group *grp =3D rcu_dereference(real_dev->vlgrp);
> +

This rcu_dereference() doesnt match the comment.

You might want rcu_dereference_rtnl() instead and use CONFIG_PROVE_RCU

> +	if (grp)
> +		return vlan_group_get_device(grp, vlan_id);
> +
> +	return NULL;
> +}
> +
>  extern struct net_device *vlan_dev_real_dev(const struct net_device =
*dev);
>  extern u16 vlan_dev_vlan_id(const struct net_device *dev);
> =20
>  extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group =
*grp,
>  			     u16 vlan_tci, int polling);
> -extern void vlan_hwaccel_do_receive(struct sk_buff *skb);
> +extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
>  extern gro_result_t
>  vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
>  		 unsigned int vlan_tci, struct sk_buff *skb);
> @@ -128,6 +141,12 @@ vlan_gro_frags(struct napi_struct *napi, struct =
vlan_group *grp,
>  	       unsigned int vlan_tci);
> =20
>  #else
> +static inline struct net_device *vlan_find_dev(struct net_device *re=
al_dev,
> +					       u16 vlan_id)
> +{
> +	return NULL;
> +}
> +
>  static inline struct net_device *vlan_dev_real_dev(const struct net_=
device *dev)
>  {
>  	BUG();
> @@ -147,8 +166,10 @@ static inline int __vlan_hwaccel_rx(struct sk_bu=
ff *skb, struct vlan_group *grp,
>  	return NET_XMIT_SUCCESS;
>  }
> =20
> -static inline void vlan_hwaccel_do_receive(struct sk_buff *skb)
> +static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
>  {
> +	BUG();
> +	return 0;
>  }
> =20
>  static inline gro_result_t
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 14fbb04..ef4bbcb 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -942,7 +942,10 @@ struct net_device {
> =20
>=20
>  	/* Protocol specific pointers */
> -=09
> +
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> +	struct vlan_group	*vlgrp;		/* VLAN group */
> +#endif
>  #ifdef CONFIG_NET_DSA
>  	void			*dsa_ptr;	/* dsa specific data */
>  #endif
> @@ -2248,8 +2251,13 @@ static inline int skb_gso_ok(struct sk_buff *s=
kb, int features)
> =20
>  static inline int netif_needs_gso(struct net_device *dev, struct sk_=
buff *skb)
>  {
> +	int features =3D dev->features;
> +
> +	if (skb->protocol =3D=3D htons(ETH_P_8021Q) || skb->vlan_tci)
> +		features &=3D dev->vlan_features;
> +
>  	return skb_is_gso(skb) &&
> -	       (!skb_gso_ok(skb, dev->features) ||
> +	       (!skb_gso_ok(skb, features) ||
>  		unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL));


Maybe reorder tests to common case, avoiding some uneeded computations
if !skb_is_gso()

	if (skb_is_gso(skb)) {
		int features =3D dev->features;

		if (skb->protocol =3D=3D htons(ETH_P_8021Q) || skb->vlan_tci)
			features &=3D dev->vlan_features;
	=09
		return !skb_gso_ok(skb, features) ||
			skb->ip_summed !=3D CHECKSUM_PARTIAL;

	}
	return 0;

>  }
> =20
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 25c2133..77634b9 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -44,9 +44,6 @@
> =20
>  int vlan_net_id __read_mostly;
> =20
> -/* Our listing of VLAN group(s) */
> -static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
> -
>  const char vlan_fullname[] =3D "802.1Q VLAN Support";
>  const char vlan_version[] =3D DRV_VERSION;
>  static const char vlan_copyright[] =3D "Ben Greear <greearb@candelat=
ech.com>";
> @@ -59,40 +56,6 @@ static struct packet_type vlan_packet_type __read_=
mostly =3D {
> =20
>  /* End of global variables definitions. */
> =20
> -static inline unsigned int vlan_grp_hashfn(unsigned int idx)
> -{
> -	return ((idx >> VLAN_GRP_HASH_SHIFT) ^ idx) & VLAN_GRP_HASH_MASK;
> -}
> -
> -/* Must be invoked with RCU read lock (no preempt) */
> -static struct vlan_group *__vlan_find_group(struct net_device *real_=
dev)
> -{
> -	struct vlan_group *grp;
> -	struct hlist_node *n;
> -	int hash =3D vlan_grp_hashfn(real_dev->ifindex);
> -
> -	hlist_for_each_entry_rcu(grp, n, &vlan_group_hash[hash], hlist) {
> -		if (grp->real_dev =3D=3D real_dev)
> -			return grp;
> -	}
> -
> -	return NULL;
> -}
> -
> -/*  Find the protocol handler.  Assumes VID < VLAN_VID_MASK.
> - *
> - * Must be invoked with RCU read lock (no preempt)
> - */
> -struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 =
vlan_id)
> -{
> -	struct vlan_group *grp =3D __vlan_find_group(real_dev);
> -
> -	if (grp)
> -		return vlan_group_get_device(grp, vlan_id);
> -
> -	return NULL;
> -}
> -
>  static void vlan_group_free(struct vlan_group *grp)
>  {
>  	int i;
> @@ -111,8 +74,6 @@ static struct vlan_group *vlan_group_alloc(struct =
net_device *real_dev)
>  		return NULL;
> =20
>  	grp->real_dev =3D real_dev;
> -	hlist_add_head_rcu(&grp->hlist,
> -			&vlan_group_hash[vlan_grp_hashfn(real_dev->ifindex)]);
>  	return grp;
>  }
> =20
> @@ -146,13 +107,10 @@ void unregister_vlan_dev(struct net_device *dev=
, struct list_head *head)
>  	struct vlan_dev_info *vlan =3D vlan_dev_info(dev);
>  	struct net_device *real_dev =3D vlan->real_dev;
>  	const struct net_device_ops *ops =3D real_dev->netdev_ops;
> -	struct vlan_group *grp;
>  	u16 vlan_id =3D vlan->vlan_id;
> =20
>  	ASSERT_RTNL();
> -
> -	grp =3D __vlan_find_group(real_dev);
> -	BUG_ON(!grp);
> +	BUG_ON(!real_dev->vlgrp);
> =20
>  	/* Take it out of our own structures, but be sure to interlock with
>  	 * HW accelerating devices or SW vlan input packet processing if
> @@ -161,25 +119,26 @@ void unregister_vlan_dev(struct net_device *dev=
, struct list_head *head)
>  	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
>  		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
> =20
> -	grp->nr_vlans--;
> +	real_dev->vlgrp->nr_vlans--;
> =20
> -	vlan_group_set_device(grp, vlan_id, NULL);
> -	if (!grp->killall)
> +	vlan_group_set_device(real_dev->vlgrp, vlan_id, NULL);
> +	if (!real_dev->vlgrp->killall)
>  		synchronize_net();
> =20
>  	unregister_netdevice_queue(dev, head);
> =20
>  	/* If the group is now empty, kill off the group. */
> -	if (grp->nr_vlans =3D=3D 0) {
> -		vlan_gvrp_uninit_applicant(real_dev);
> +	if (real_dev->vlgrp->nr_vlans =3D=3D 0) {
> +		struct vlan_group *vlgrp =3D real_dev->vlgrp;
> =20
> -		if (real_dev->features & NETIF_F_HW_VLAN_RX)
> +		rcu_assign_pointer(real_dev->vlgrp, NULL);
> +		if (ops->ndo_vlan_rx_register)
>  			ops->ndo_vlan_rx_register(real_dev, NULL);
> =20
> -		hlist_del_rcu(&grp->hlist);
> +		vlan_gvrp_uninit_applicant(real_dev);
> =20
>  		/* Free the group, after all cpu's are done. */
> -		call_rcu(&grp->rcu, vlan_rcu_free);
> +		call_rcu(&vlgrp->rcu, vlan_rcu_free);
>  	}
> =20
>  	/* Get rid of the vlan's reference to real_dev */
> @@ -196,18 +155,13 @@ int vlan_check_real_dev(struct net_device *real=
_dev, u16 vlan_id)
>  		return -EOPNOTSUPP;
>  	}
> =20
> -	if ((real_dev->features & NETIF_F_HW_VLAN_RX) && !ops->ndo_vlan_rx_=
register) {
> -		pr_info("8021q: device %s has buggy VLAN hw accel\n", name);
> -		return -EOPNOTSUPP;
> -	}
> -
>  	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
>  	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid)) {
>  		pr_info("8021q: Device %s has buggy VLAN hw accel\n", name);
>  		return -EOPNOTSUPP;
>  	}
> =20
> -	if (__find_vlan_dev(real_dev, vlan_id) !=3D NULL)
> +	if (vlan_find_dev(real_dev, vlan_id) !=3D NULL)
>  		return -EEXIST;
> =20
>  	return 0;
> @@ -222,7 +176,7 @@ int register_vlan_dev(struct net_device *dev)
>  	struct vlan_group *grp, *ngrp =3D NULL;
>  	int err;
> =20
> -	grp =3D __vlan_find_group(real_dev);
> +	grp =3D real_dev->vlgrp;
>  	if (!grp) {
>  		ngrp =3D grp =3D vlan_group_alloc(real_dev);
>  		if (!grp)
> @@ -252,8 +206,11 @@ int register_vlan_dev(struct net_device *dev)
>  	vlan_group_set_device(grp, vlan_id, dev);
>  	grp->nr_vlans++;
> =20
> -	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
> -		ops->ndo_vlan_rx_register(real_dev, ngrp);
> +	if (ngrp) {
> +		if (ops->ndo_vlan_rx_register)
> +			ops->ndo_vlan_rx_register(real_dev, ngrp);
> +		rcu_assign_pointer(real_dev->vlgrp, ngrp);
> +	}
>  	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
>  		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
> =20
> @@ -264,7 +221,6 @@ out_uninit_applicant:
>  		vlan_gvrp_uninit_applicant(real_dev);
>  out_free_group:
>  	if (ngrp) {
> -		hlist_del_rcu(&ngrp->hlist);
>  		/* Free the group, after all cpu's are done. */
>  		call_rcu(&ngrp->rcu, vlan_rcu_free);
>  	}
> @@ -428,7 +384,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
>  		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
>  	}
> =20
> -	grp =3D __vlan_find_group(dev);
> +	grp =3D dev->vlgrp;
>  	if (!grp)
>  		goto out;
> =20
> @@ -439,7 +395,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
>  	switch (event) {
>  	case NETDEV_CHANGE:
>  		/* Propagate real device state to vlan devices */
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {
>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -450,7 +406,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
> =20
>  	case NETDEV_CHANGEADDR:
>  		/* Adjust unicast filters on underlying device */
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {
>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -464,7 +420,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
>  		break;
> =20
>  	case NETDEV_CHANGEMTU:
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {
>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -478,7 +434,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
> =20
>  	case NETDEV_FEAT_CHANGE:
>  		/* Propagate device features to underlying device */
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {

cleanup patch please


>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -490,7 +446,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
> =20
>  	case NETDEV_DOWN:
>  		/* Put all VLANs for this dev in the down state too.  */
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {

cleanup patch please

>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -508,7 +464,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
> =20
>  	case NETDEV_UP:
>  		/* Put all VLANs for this dev in the up state too.  */
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {

cleanup patch please

>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -532,7 +488,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
>  		/* Delete all VLANs for this dev. */
>  		grp->killall =3D 1;
> =20
> -		for (i =3D 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		for (i =3D 0; i < VLAN_N_VID; i++) {

cleanup patch please

>  			vlandev =3D vlan_group_get_device(grp, i);
>  			if (!vlandev)
>  				continue;
> @@ -540,7 +496,7 @@ static int vlan_device_event(struct notifier_bloc=
k *unused, unsigned long event,
>  			/* unregistration of last vlan destroys group, abort
>  			 * afterwards */
>  			if (grp->nr_vlans =3D=3D 1)
> -				i =3D VLAN_GROUP_ARRAY_LEN;
> +				i =3D VLAN_N_VID;
> =20
>  			unregister_vlan_dev(vlandev, &list);
>  		}
> @@ -746,8 +702,6 @@ err0:
> =20
>  static void __exit vlan_cleanup_module(void)
>  {
> -	unsigned int i;
> -
>  	vlan_ioctl_set(NULL);
>  	vlan_netlink_fini();
> =20
> @@ -755,10 +709,6 @@ static void __exit vlan_cleanup_module(void)
> =20
>  	dev_remove_pack(&vlan_packet_type);
> =20
> -	/* This table must be empty if there are no module references left.=
 */
> -	for (i =3D 0; i < VLAN_GRP_HASH_SIZE; i++)
> -		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
> -
>  	unregister_pernet_subsys(&vlan_net_ops);
>  	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> =20
> diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
> index 8d9503a..db01b31 100644
> --- a/net/8021q/vlan.h
> +++ b/net/8021q/vlan.h
> @@ -72,23 +72,6 @@ static inline struct vlan_dev_info *vlan_dev_info(=
const struct net_device *dev)
>  	return netdev_priv(dev);
>  }
> =20
> -#define VLAN_GRP_HASH_SHIFT	5
> -#define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
> -#define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
> -
> -/*  Find a VLAN device by the MAC address of its Ethernet device, an=
d
> - *  it's VLAN ID.  The default configuration is to have VLAN's scope
> - *  to be box-wide, so the MAC will be ignored.  The mac will only b=
e
> - *  looked at if we are configured to have a separate set of VLANs p=
er
> - *  each MAC addressable interface.  Note that this latter option do=
es
> - *  NOT follow the spec for VLANs, but may be useful for doing very
> - *  large quantities of VLAN MUX/DEMUX onto FrameRelay or ATM PVCs.
> - *
> - *  Must be invoked with rcu_read_lock (ie preempt disabled)
> - *  or with RTNL.
> - */
> -struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 =
vlan_id);
> -
>  /* found in vlan_dev.c */
>  int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
>  		  struct packet_type *ptype, struct net_device *orig_dev);
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index dee727c..df90412 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -4,54 +4,33 @@
>  #include <linux/netpoll.h>
>  #include "vlan.h"
> =20
> -/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive=
_skb}(). */
> -int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> -		      u16 vlan_tci, int polling)
> +int vlan_hwaccel_do_receive(struct sk_buff *skb)
>  {
> +	u16 vlan_id =3D skb->vlan_tci & VLAN_VID_MASK;
>  	struct net_device *vlan_dev;
> -	u16 vlan_id;
> -
> -	if (netpoll_rx(skb))
> -		return NET_RX_DROP;
> -
> -	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
> -		skb->deliver_no_wcard =3D 1;
> -
> -	skb->skb_iif =3D skb->dev->ifindex;
> -	__vlan_hwaccel_put_tag(skb, vlan_tci);
> -	vlan_id =3D vlan_tci & VLAN_VID_MASK;
> -	vlan_dev =3D vlan_group_get_device(grp, vlan_id);
> +	struct vlan_rx_stats *rx_stats;
> =20
> -	if (vlan_dev)
> -		skb->dev =3D vlan_dev;
> -	else if (vlan_id) {
> -		if (!(skb->dev->flags & IFF_PROMISC))
> -			goto drop;
> -		skb->pkt_type =3D PACKET_OTHERHOST;
> +	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
> +	if (!vlan_dev) {
> +		if (vlan_id)
> +			skb->pkt_type =3D PACKET_OTHERHOST;
> +		return NET_RX_SUCCESS;
>  	}
> =20
> -	return polling ? netif_receive_skb(skb) : netif_rx(skb);
> -
> -drop:
> -	atomic_long_inc(&skb->dev->rx_dropped);
> -	dev_kfree_skb_any(skb);
> -	return NET_RX_DROP;
> -}
> -EXPORT_SYMBOL(__vlan_hwaccel_rx);
> -
> -void vlan_hwaccel_do_receive(struct sk_buff *skb)
> -{
> -	struct net_device *dev =3D skb->dev;

this temporary variable was nice for a better code readability

> -	struct vlan_rx_stats     *rx_stats;
> +	if (netpoll_receive_skb(skb))
> +		return NET_RX_DROP;
> =20
> -	skb->dev =3D vlan_dev_real_dev(dev);

>  	netif_nit_deliver(skb);
Strange you dont change netif_nit_deliver() ?

> =20
> -	skb->dev =3D dev;
> -	skb->priority =3D vlan_get_ingress_priority(dev, skb->vlan_tci);
> +	skb->skb_iif =3D skb->dev->ifindex;
> +	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
> +		skb->deliver_no_wcard =3D 1;
> +
> +	skb->dev =3D vlan_dev;
> +	skb->priority =3D vlan_get_ingress_priority(skb->dev, skb->vlan_tci=
);
>  	skb->vlan_tci =3D 0;
> =20
> -	rx_stats =3D this_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats);
> +	rx_stats =3D this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats);

vlan_dev here, instead of skb->dev ?

> =20
>  	u64_stats_update_begin(&rx_stats->syncp);
>  	rx_stats->rx_packets++;
> @@ -68,11 +47,13 @@ void vlan_hwaccel_do_receive(struct sk_buff *skb)
>  		 * This allows the VLAN to have a different MAC than the
>  		 * underlying device, and still route correctly. */
>  		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
> -					dev->dev_addr))
> +					skb->dev->dev_addr))

all this skb->dev->... are really hard to understand

>  			skb->pkt_type =3D PACKET_HOST;
>  		break;
>  	}
>  	u64_stats_update_end(&rx_stats->syncp);
> +
> +	return NET_RX_SUCCESS;
>  }
> =20
>  struct net_device *vlan_dev_real_dev(const struct net_device *dev)
> @@ -87,75 +68,27 @@ u16 vlan_dev_vlan_id(const struct net_device *dev=
)
>  }
>  EXPORT_SYMBOL(vlan_dev_vlan_id);
> =20
> -static gro_result_t
> -vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
> -		unsigned int vlan_tci, struct sk_buff *skb)
> +/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive=
_skb}(). */
> +int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> +		      u16 vlan_tci, int polling)
>  {
> -	struct sk_buff *p;
> -	struct net_device *vlan_dev;
> -	u16 vlan_id;
> -
> -	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
> -		skb->deliver_no_wcard =3D 1;
> -
> -	skb->skb_iif =3D skb->dev->ifindex;
>  	__vlan_hwaccel_put_tag(skb, vlan_tci);
> -	vlan_id =3D vlan_tci & VLAN_VID_MASK;
> -	vlan_dev =3D vlan_group_get_device(grp, vlan_id);
> -
> -	if (vlan_dev)
> -		skb->dev =3D vlan_dev;
> -	else if (vlan_id) {
> -		if (!(skb->dev->flags & IFF_PROMISC))
> -			goto drop;
> -		skb->pkt_type =3D PACKET_OTHERHOST;
> -	}
> -
> -	for (p =3D napi->gro_list; p; p =3D p->next) {
> -		unsigned long diffs;
> -
> -		diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
> -		diffs |=3D compare_ether_header(skb_mac_header(p),
> -					      skb_gro_mac_header(skb));
> -		NAPI_GRO_CB(p)->same_flow =3D !diffs;
> -		NAPI_GRO_CB(p)->flush =3D 0;
> -	}
> -
> -	return dev_gro_receive(napi, skb);
> -
> -drop:
> -	atomic_long_inc(&skb->dev->rx_dropped);
> -	return GRO_DROP;
> +	return polling ? netif_receive_skb(skb) : netif_rx(skb);
>  }
> +EXPORT_SYMBOL(__vlan_hwaccel_rx);
> =20
>  gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_=
group *grp,
>  			      unsigned int vlan_tci, struct sk_buff *skb)
>  {
> -	if (netpoll_rx_on(skb))
> -		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci)
> -			? GRO_DROP : GRO_NORMAL;
> -
> -	skb_gro_reset_offset(skb);
> -
> -	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), s=
kb);
> +	__vlan_hwaccel_put_tag(skb, vlan_tci);
> +	return napi_gro_receive(napi, skb);
>  }
>  EXPORT_SYMBOL(vlan_gro_receive);
> =20
>  gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_gr=
oup *grp,
>  			    unsigned int vlan_tci)
>  {
> -	struct sk_buff *skb =3D napi_frags_skb(napi);
> -
> -	if (!skb)
> -		return GRO_DROP;
> -
> -	if (netpoll_rx_on(skb)) {
> -		skb->protocol =3D eth_type_trans(skb, skb->dev);
> -		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci)
> -			? GRO_DROP : GRO_NORMAL;
> -	}
> -
> -	return napi_frags_finish(napi, skb,
> -				 vlan_gro_common(napi, grp, vlan_tci, skb));
> +	__vlan_hwaccel_put_tag(napi->skb, vlan_tci);
> +	return napi_gro_frags(napi);
>  }
>  EXPORT_SYMBOL(vlan_gro_frags);
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index f54251e..14e3d1f 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -158,7 +158,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net=
_device *dev,
>  	vlan_id =3D vlan_tci & VLAN_VID_MASK;
> =20
>  	rcu_read_lock();
> -	vlan_dev =3D __find_vlan_dev(dev, vlan_id);
> +	vlan_dev =3D vlan_find_dev(dev, vlan_id);
> =20
>  	/* If the VLAN device is defined, we use it.
>  	 * If not, and the VID is 0, it is a 802.1p packet (not
> diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/e=
bt_vlan.c
> index a39d92d..e724720 100644
> --- a/net/bridge/netfilter/ebt_vlan.c
> +++ b/net/bridge/netfilter/ebt_vlan.c
> @@ -119,10 +119,10 @@ static int ebt_vlan_mt_check(const struct xt_mt=
chk_param *par)
>  	 * 0 - The null VLAN ID.
>  	 * 1 - The default Port VID (PVID)
>  	 * 0x0FFF - Reserved for implementation use.
> -	 * if_vlan.h: VLAN_GROUP_ARRAY_LEN 4096. */
> +	 * if_vlan.h: VLAN_N_VID 4096. */
>  	if (GET_BITMASK(EBT_VLAN_ID)) {
>  		if (!!info->id) { /* if id!=3D0 =3D> check vid range */
> -			if (info->id > VLAN_GROUP_ARRAY_LEN) {
> +			if (info->id > VLAN_N_VID) {
>  				pr_debug("id %d is out of range (1-4096)\n",
>  					 info->id);
>  				return -EINVAL;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 04972a4..9586aff 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1692,7 +1692,12 @@ static bool can_checksum_protocol(unsigned lon=
g features, __be16 protocol)
> =20
>  static bool dev_can_checksum(struct net_device *dev, struct sk_buff =
*skb)
>  {
> -	if (can_checksum_protocol(dev->features, skb->protocol))
> +	int features =3D dev->features;
> +
> +	if (vlan_tx_tag_present(skb))
> +		features &=3D dev->vlan_features;
> +
> +	if (can_checksum_protocol(features, skb->protocol))
>  		return true;
> =20
>  	if (skb->protocol =3D=3D htons(ETH_P_8021Q)) {
> @@ -1791,6 +1796,16 @@ struct sk_buff *skb_gso_segment(struct sk_buff=
 *skb, int features)
>  	__be16 type =3D skb->protocol;
>  	int err;
> =20
> +	if (type =3D=3D htons(ETH_P_8021Q)) {
> +		struct vlan_ethhdr *veh;
> +
> +		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
> +			return ERR_PTR(-EINVAL);
> +
> +		veh =3D (struct vlan_ethhdr *)skb->data;
> +		type =3D veh->h_vlan_encapsulated_proto;
> +	}
> +
>  	skb_reset_mac_header(skb);
>  	skb->mac_len =3D skb->network_header - skb->mac_header;
>  	__skb_pull(skb, skb->mac_len);
> @@ -1962,9 +1977,14 @@ static inline void skb_orphan_try(struct sk_bu=
ff *skb)
>  static inline int skb_needs_linearize(struct sk_buff *skb,
>  				      struct net_device *dev)
>  {
> +	int features =3D dev->features;
> +
> +	if (skb->protocol =3D=3D htons(ETH_P_8021Q) || vlan_tx_tag_present(=
skb))
> +		features &=3D dev->vlan_features;
> +
>  	return skb_is_nonlinear(skb) &&
> -	       ((skb_has_frag_list(skb) && !(dev->features & NETIF_F_FRAGLI=
ST)) ||
> -	        (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG=
) ||
> +	       ((skb_has_frag_list(skb) && !(features & NETIF_F_FRAGLIST)) =
||
> +	        (skb_shinfo(skb)->nr_frags && (!(features & NETIF_F_SG) ||
>  					      illegal_highdma(dev, skb))));
>  }
> =20
> @@ -1987,6 +2007,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
truct net_device *dev,
> =20
>  		skb_orphan_try(skb);
> =20
> +		if (vlan_tx_tag_present(skb) &&
> +		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
> +			skb =3D __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> +			if (unlikely(!skb))
> +				goto out;
> +
> +			skb->vlan_tci =3D 0;
> +		}
> +
>  		if (netif_needs_gso(dev, skb)) {
>  			if (unlikely(dev_gso_segment(skb)))
>  				goto out_kfree_skb;
> @@ -2048,6 +2077,7 @@ out_kfree_gso_skb:
>  		skb->destructor =3D DEV_GSO_CB(skb)->destructor;
>  out_kfree_skb:
>  	kfree_skb(skb);
> +out:
>  	return rc;
>  }
> =20
> @@ -2893,8 +2923,8 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>  	if (!netdev_tstamp_prequeue)
>  		net_timestamp_check(skb);
> =20
> -	if (vlan_tx_tag_present(skb))
> -		vlan_hwaccel_do_receive(skb);
> +	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
> +		return NET_RX_DROP;
> =20
>  	/* if we've gotten here through NAPI, check netpoll */
>  	if (netpoll_receive_skb(skb))
> @@ -3232,6 +3262,7 @@ __napi_gro_receive(struct napi_struct *napi, st=
ruct sk_buff *skb)
>  		unsigned long diffs;
> =20
>  		diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
> +		diffs |=3D p->vlan_tci ^ skb->vlan_tci;
>  		diffs |=3D compare_ether_header(skb_mac_header(p),
>  					      skb_gro_mac_header(skb));
>  		NAPI_GRO_CB(p)->same_flow =3D !diffs;
> @@ -3291,6 +3322,7 @@ void napi_reuse_skb(struct napi_struct *napi, s=
truct sk_buff *skb)
>  {
>  	__skb_pull(skb, skb_headlen(skb));
>  	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
> +	skb->vlan_tci =3D 0;
> =20
>  	napi->skb =3D skb;
>  }


I believe this stuff is a great idea, but you should take more time to
make your patches more understandable.

Given 2.6.36 is about to be released, and Netfilter Workshop 2010 begin=
s
in few days, there is no hurry, because there is no chance we add so
many fundamental changes before three weeks at least.

I believe this patch (2/7), should be split in small units, maybe 3 or =
4
different patches.

Thanks


