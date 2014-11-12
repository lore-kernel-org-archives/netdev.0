From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN driver.
Date: Wed, 12 Nov 2014 20:11:27 +0400
Message-ID: <546386AF.9030300@parallels.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>
To: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:48565 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbaKLRNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 12:13:14 -0500
In-Reply-To: <1415744984-25802-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2014 02:29 AM, Mahesh Bandewar wrote:
> This driver is very similar to the macvlan driver except that it
> uses L3 on the frame to determine the logical interface while
> functioning as packet dispatcher. It inherits L2 of the master
> device hence the packets on wire will have the same L2 for all
> the packets originating from all virtual devices off of the same
> master device.
>=20
> This driver was developed keeping the namespace use-case in
> mind. Hence most of the examples given here take that as the
> base setup where main-device belongs to the default-ns and
> virtual devices are assigned to the additional namespaces.
>=20
> The device operates in two different modes and the difference
> in these two modes in primarily in the TX side.
>=20
> (a) L2 mode : In this mode, the device behaves as a L2 device.
> TX processing upto L2 happens on the stack of the virtual device
> associated with (namespace). Packets are switched after that
> into the main device (default-ns) and queued for xmit.
>=20
> RX processing is simple and all multicast, broadcast (if
> applicable), and unicast belonging to the address(es) are
> delivered to the virtual devices.
>=20
> (b) L3 mode : In this mode, the device behaves like a L3 device.
> TX processing upto L3 happens on the stack of the virtual device
> associated with (namespace). Packets are switched to the
> main-device (default-ns) for the L2 processing. Hence the routing
> table of the default-ns will be used in this mode.
>=20
> RX processins is somewhat similar to the L2 mode except that in
> this mode only Unicast packets are delivered to the virtual device
> while main-dev will handle all other packets.
>=20
> The devices can be added using the "ip" command from the iproute2
> package -
>=20
> 	ip link add link <master> <virtual> type ipvlan mode [ l2 | l3 ]
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Laurent Chavey <chavey@google.com>
> Cc: Tim Hockin <thockin@google.com>
> Cc: Brandon Philips <brandon.philips@coreos.com>
> Cc: Pavel Emelianov <xemul@parallels.com>

Acked-by: /me on the general idea. We use this device of type in Parall=
els
heavily for several reasons -- not to generate too many MAC-s from one =
host
and to "enforce" the IP address for a container. I have a comment about=
 the
latter below.


> +static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
> +{
> +	void *lyr3h =3D NULL;
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_ARP): {
> +		struct arphdr *arph;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct arphdr))))
> +			return NULL;
> +
> +		arph =3D arp_hdr(skb);
> +		*type =3D IPVL_ARP;
> +		lyr3h =3D arph;
> +		break;
> +	}
> +
> +	case htons(ETH_P_IP): {
> +		u32 pktlen;
> +		struct iphdr *ip4h;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct iphdr))))
> +			return NULL;
> +
> +		ip4h =3D ip_hdr(skb);
> +		pktlen =3D ntohs(ip4h->tot_len);
> +		if (ip4h->ihl < 5 || ip4h->version !=3D 4)
> +			return NULL;
> +		if (skb->len < pktlen || pktlen < (ip4h->ihl * 4))
> +			return NULL;
> +
> +		*type =3D IPVL_IPV4;
> +		lyr3h =3D ip4h;
> +		break;
> +	}
> +	case htons(ETH_P_IPV6): {
> +		struct ipv6hdr *ip6h;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct iphdr))))

Misprint -- should be sizeof(struct ipv6hdr)

> +static int ipvlan_link_new(struct net *src_net, struct net_device *d=
ev,
> +			   struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
> +	struct ipvl_port *port;
> +	struct net_device *phy_dev;
> +	int err;
> +
> +	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
> +	if (!tb[IFLA_LINK]) {
> +		ipvlan_dbg(3, "%s[%d]: Returning -EINVAL...\n",
> +			   __func__, __LINE__);
> +		return -EINVAL;
> +	}
> +
> +	phy_dev =3D __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]))=
;
> +	if (phy_dev =3D=3D NULL) {
> +		ipvlan_dbg(3, "%s[%d]: Returning -ENODEV...\n",
> +			   __func__, __LINE__);
> +		return -ENODEV;
> +	}
> +
> +	/* TODO will someone try creating ipvlan-dev on an ipvlan-virtual d=
ev?*/
> +	if (!ipvlan_dev_master(phy_dev)) {
> +		err =3D ipvlan_port_create(phy_dev);
> +		if (err < 0) {
> +			ipvlan_dbg(3, "%s[%d]: Returning error (%d)...\n",
> +				   __func__, __LINE__, err);
> +			return err;
> +		}
> +	}
> +
> +	port =3D ipvlan_port_get_rtnl(phy_dev);
> +	/* Get the mode if specified. */
> +	if (data && data[IFLA_IPVLAN_MODE])
> +		port->mode =3D nla_get_u16(data[IFLA_IPVLAN_MODE]);

Should the invalid value be checked here? There are places
where we BUG() in mode being "unknown".

> +
> +	ipvlan->phy_dev =3D phy_dev;
> +	ipvlan->dev =3D dev;
> +	ipvlan->port =3D port;
> +	ipvlan->sfeatures =3D IPVLAN_FEATURES;
> +	INIT_LIST_HEAD(&ipvlan->addrs);
> +	ipvlan->ipv4cnt =3D 0;
> +	ipvlan->ipv6cnt =3D 0;


> +static int ipvlan_device_event(struct notifier_block *unused,
> +			       unsigned long event, void *ptr)
> +{
> +	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
> +	struct ipvl_dev *ipvlan, *next;
> +	struct ipvl_port *port;
> +	LIST_HEAD(lst_kill);
> +
> +	if (!ipvlan_dev_master(dev))
> +		return NOTIFY_DONE;
> +
> +	port =3D ipvlan_port_get_rtnl(dev);
> +
> +	switch (event) {
> +	case NETDEV_CHANGE:
> +		list_for_each_entry(ipvlan, &port->ipvlans, pnode)
> +			netif_stacked_transfer_operstate(ipvlan->phy_dev,
> +							 ipvlan->dev);
> +		break;
> +
> +	case NETDEV_UNREGISTER:
> +		if (dev->reg_state !=3D NETREG_UNREGISTERING)
> +			break;
> +
> +		list_for_each_entry_safe(ipvlan, next, &port->ipvlans,
> +					 pnode)
> +			ipvlan->dev->rtnl_link_ops->dellink(ipvlan->dev,
> +							    &lst_kill);
> +		unregister_netdevice_many(&lst_kill);
> +		list_del(&lst_kill);

This list_del seems to be excessive.

> +		break;
> +

> +static int ipvlan_addr4_event(struct notifier_block *unused,
> +			      unsigned long event, void *ptr)
> +{
> +	struct in_ifaddr *if4 =3D (struct in_ifaddr *)ptr;
> +	struct net_device *dev =3D (struct net_device *)if4->ifa_dev->dev;
> +	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
> +	struct in_addr ip4_addr;
> +
> +	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
> +	if (!ipvlan_dev_slave(dev))
> +		return NOTIFY_DONE;
> +
> +	if (!ipvlan || !ipvlan->port)
> +		return NOTIFY_DONE;
> +
> +	switch (event) {
> +	case NETDEV_UP:

Can it be (in the future) somehow restricted so that net-namespace woul=
dn't
be able to assign arbitrary IP address here? One of the reasons for usi=
ng
such devices is to enforce the container to use the IP address given fr=
om
the host.

> +		ip4_addr.s_addr =3D if4->ifa_address;
> +		if (ipvlan_add_addr4(ipvlan, &ip4_addr))
> +			return NOTIFY_BAD;
> +		break;
> +
> +	case NETDEV_DOWN:
> +		ip4_addr.s_addr =3D if4->ifa_address;
> +		ipvlan_del_addr4(ipvlan, &ip4_addr);
> +		break;
> +	}
> +
> +	ipvlan_dbg(3, "%s[%d]: Leaving...\n", __func__, __LINE__);
> +	return NOTIFY_OK;
> +}
