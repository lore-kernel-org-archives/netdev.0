From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 21:28:53 +0100
Message-ID: <1326745733.2564.14.camel@edumazet-laptop>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 janvier 2012 =C3=A0 20:45 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :
> From: Stefan Gula <steweg@gmail.com
>=20
> This patch is an extension for current Ethernet over GRE
> implementation, which allows user to create virtual bridge (multipoin=
t
> VPN) and forward traffic based on Ethernet MAC address information in
> it. It simulates the Bridge behavior learning mechanism, but instead
> of learning port ID from which given MAC address comes, it learns IP
> address of peer which encapsulated given packet. Multicast, Broadcast
> and unknown-multicast traffic is send over network as multicast
> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
> represented as one single virtual switch on logical level and be also
> represented as one multicast IPv4 address on network level.
>=20
> Signed-off-by: Stefan Gula <steweg@gmail.com>
>=20
> ---
>=20
> code was merged with latest bridge code and should be easily comparab=
le
>=20

Please make sure it applies properly on net-next tree.

That is mandatory.

> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
> linux-3.2.1-orig/include/net/ipip.h linux-3.2.1-my/include/net/ipip.h
> --- linux-3.2.1-orig/include/net/ipip.h	2012-01-12 20:42:45.000000000=
 +0100
> +++ linux-3.2.1-my/include/net/ipip.h	2012-01-16 11:17:01.000000000 +=
0100
> @@ -27,6 +27,14 @@ struct ip_tunnel {
>  	__u32			o_seqno;	/* The last output seqno */
>  	int			hlen;		/* Precalculated GRE header length */
>  	int			mlink;
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +#define GRETAP_BR_HASH_BITS 8
> +#define GRETAP_BR_HASH_SIZE (1 << GRETAP_BR_HASH_BITS)
> +	struct hlist_head	hash[GRETAP_BR_HASH_SIZE];
> +	spinlock_t		hash_lock;
> +	unsigned long		ageing_time;
> +	struct timer_list	gc_timer;
> +#endif
>=20
>  	struct ip_tunnel_parm	parms;
>=20
> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
> linux-3.2.1-orig/net/ipv4/Kconfig linux-3.2.1-my/net/ipv4/Kconfig
> --- linux-3.2.1-orig/net/ipv4/Kconfig	2012-01-12 20:42:45.000000000 +=
0100
> +++ linux-3.2.1-my/net/ipv4/Kconfig	2012-01-16 12:37:00.000000000 +01=
00
> @@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
>  	  Network), but can be distributed all over the Internet. If you wa=
nt
>  	  to do that, say Y here and to "IP multicast routing" below.
>=20
> +config NET_IPGRE_BRIDGE
> +	bool "IP: Ethernet over multipoint GRE over IP"
> +	depends on IP_MULTICAST && NET_IPGRE && NET_IPGRE_BROADCAST
> +	help
> +	  Allows you to use multipoint GRE VPN as virtual switch and interc=
onnect
> +	  several L2 endpoints over L3 routed infrastructure. It is useful =
for
> +	  creating multipoint L2 VPNs which can be later used inside bridge
> +	  interfaces If you want to use. GRE multipoint L2 VPN feature say =
Y.
> +
>  config IP_MROUTE
>  	bool "IP: multicast routing"
>  	depends on IP_MULTICAST
> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
> linux-3.2.1-orig/net/ipv4/ip_gre.c linux-3.2.1-my/net/ipv4/ip_gre.c
> --- linux-3.2.1-orig/net/ipv4/ip_gre.c	2012-01-12 20:42:45.000000000 =
+0100
> +++ linux-3.2.1-my/net/ipv4/ip_gre.c	2012-01-16 20:42:03.000000000 +0=
100
> @@ -52,6 +52,11 @@
>  #include <net/ip6_route.h>
>  #endif
>=20
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +#include <linux/jhash.h>
> +#include <asm/unaligned.h>
> +#endif
> +
>  /*
>     Problems & solutions
>     --------------------
> @@ -134,6 +139,191 @@ struct ipgre_net {
>  	struct net_device *fb_tunnel_dev;
>  };
>=20
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +	/*
> +	 * This part of code includes codes to enable L2 ethernet
> +	 * switch virtualization over IP routed infrastructure with
> +	 * utilization of multicast capable endpoint using Ethernet
> +	 * over GRE
> +	 *
> +	 * Author: Stefan Gula
> +	 * Signed-off-by: Stefan Gula <steweg@gmail.com>
> +	 */
> +struct mac_addr {
> +	unsigned char   addr[6];

Did I mention : ETH_ALEN ?

> +};
> +
> +struct ipgre_tap_bridge_entry {
> +	struct hlist_node	hlist;
> +	u32			raddr;

	__be32 raddr ?

> +	struct mac_addr		addr;
> +	struct net_device	*dev;
> +	struct rcu_head		rcu;
> +	unsigned long		updated;
> +};
> +
> +static struct kmem_cache *ipgre_tap_bridge_cache __read_mostly;
> +static u32 ipgre_salt __read_mostly;
> +
> +int __net_init ipgre_tap_bridge_init(void)
> +{
> +	ipgre_tap_bridge_cache =3D kmem_cache_create("ipgre_tap_bridge_cach=
e",
> +		sizeof(struct ipgre_tap_bridge_entry),
> +		0,
> +		SLAB_HWCACHE_ALIGN, NULL);
> +	if (!ipgre_tap_bridge_cache)
> +		return -ENOMEM;
> +	get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
> +	return 0;
> +}
> +
> +void ipgre_tap_bridge_fini(void)
> +{
> +	kmem_cache_destroy(ipgre_tap_bridge_cache);
> +}
> +
> +static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
> +{
> +	u32 key =3D get_unaligned((u32 *)(mac + 2));
> +	return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_SIZE - 1);
> +}
> +
> +static inline int ipgre_tap_bridge_has_expired(const struct ip_tunne=
l *tunnel,
> +		const struct ipgre_tap_bridge_entry *entry)
> +{
> +	return time_before_eq(entry->updated + tunnel->ageing_time,
> +		jiffies);
> +}
> +
> +static void ipgre_tap_bridge_rcu_free(struct rcu_head *head)
> +{
> +	struct ipgre_tap_bridge_entry *entry
> +		=3D container_of(head, struct ipgre_tap_bridge_entry, rcu);
> +	kmem_cache_free(ipgre_tap_bridge_cache, entry);
> +}
> +
> +static inline void ipgre_tap_bridge_delete(struct
> ipgre_tap_bridge_entry *entry)
> +{
> +	hlist_del_rcu(&entry->hlist);
> +	call_rcu(&entry->rcu, ipgre_tap_bridge_rcu_free);
> +}

Did I mention : kfree_rcu() ?

> +
> +
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
> +	struct hlist_head *head,
> +	const unsigned char *addr)
> +{
> +	struct hlist_node *h;
> +	struct ipgre_tap_bridge_entry *entry;
> +	hlist_for_each_entry(entry, h, head, hlist) {
> +		if (!compare_ether_addr(entry->addr.addr, addr))
> +			return entry;
> +	}
> +	return NULL;
> +}
> +
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find_rcu(
> +	struct hlist_head *head,
> +	const unsigned char *addr)
> +{
> +	struct hlist_node *h;
> +	struct ipgre_tap_bridge_entry *entry;
> +	hlist_for_each_entry_rcu(entry, h, head, hlist) {
> +		if (!compare_ether_addr(entry->addr.addr, addr))
> +			return entry;
> +	}
> +	return NULL;
> +}
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
> +		struct hlist_head *head,
> +		u32 source,

	__be32 source,

> +		const unsigned char *addr, struct net_device *dev)
> +{
> +	struct ipgre_tap_bridge_entry *entry;
> +	entry =3D kmem_cache_alloc(ipgre_tap_bridge_cache, GFP_ATOMIC);
> +	if (entry) {
> +		memcpy(entry->addr.addr, addr, ETH_ALEN);
> +		hlist_add_head_rcu(&entry->hlist, head);

Thats bogus.

You must init all entry fields _before_ inserting entry in hash table.

> +		entry->raddr =3D source;
> +		entry->dev =3D dev;
> +		entry->updated =3D jiffies;
> +	}
> +	return entry;
> +}
> +
> +__be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
> +	const unsigned char *addr)
> +{
> +	struct ipgre_tap_bridge_entry *entry;
> +	entry =3D __ipgre_tap_bridge_get(tunnel, addr);
> +	if (entry =3D=3D NULL)
> +		return 0;
> +	else
> +		return entry->raddr;
> +}
> +
> +#endif
>  /* Tunnel hash table */
>=20
>  /*
> @@ -563,6 +753,13 @@ static int ipgre_rcv(struct sk_buff *skb
>  	int    offset =3D 4;
>  	__be16 gre_proto;
>=20
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +	u32 orig_source;

Please run sparse on your code...  (make C=3D2 ...)

orig_source is not u32, but __be32

> +	struct hlist_head *head;
> +	struct ipgre_tap_bridge_entry *entry;
> +	struct ethhdr *tethhdr;
> +#endif
> +
>  	if (!pskb_may_pull(skb, 16))
>  		goto drop_nolock;
>=20
> @@ -659,10 +856,39 @@ static int ipgre_rcv(struct sk_buff *skb
>  				tunnel->dev->stats.rx_errors++;
>  				goto drop;
>  			}
> -
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +			orig_source =3D iph->saddr;
> +#endif
>  			iph =3D ip_hdr(skb);
>  			skb->protocol =3D eth_type_trans(skb, tunnel->dev);
>  			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +			if (ipv4_is_multicast(tunnel->parms.iph.daddr)) {
> +				tethhdr =3D eth_hdr(skb);
> +				if (!is_multicast_ether_addr(
> +					tethhdr->h_source)) {
> +					head =3D &tunnel->hash[
> +						ipgre_tap_bridge_hash(
> +							tethhdr->h_source)];
> +					entry =3D ipgre_tap_bridge_find_rcu(head,
> +						tethhdr->h_source);
> +					if (likely(entry)) {
> +						entry->raddr =3D orig_source;
> +						entry->updated =3D jiffies;
> +					} else {
> +					  spin_lock_bh(&tunnel->hash_lock);

You dont need the _bh() variant here, since we run from softirq handler=
=2E

> +					  if (!ipgre_tap_bridge_find(head,
> +						tethhdr->h_source))
> +						ipgre_tap_bridge_create(
> +						 head,
> +						 orig_source,
> +						 tethhdr->h_source,
> +						 tunnel->dev);
> +					  spin_unlock_bh(&tunnel->hash_lock);
> +					}
> +				}
> +			}
> +#endif
>  		}
>=20
>  		tstats =3D this_cpu_ptr(tunnel->dev->tstats);
> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>  		tiph =3D &tunnel->parms.iph;
>  	}
>=20
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +	rcu_read_lock();
> +	if ((dev->type =3D=3D ARPHRD_ETHER) &&
> +		ipv4_is_multicast(tunnel->parms.iph.daddr))
> +		dst =3D ipgre_tap_bridge_get_raddr(tunnel,
> +			((struct ethhdr *)skb->data)->h_dest);
> +	rcu_read_unlock();

this rcu_read_lock()/rcu_read_unlock() pair should be done in
ipgre_tap_bridge_get_raddr() instead... so we dont hit this for all
packets.

> +	if (dst =3D=3D 0)
> +		dst =3D tiph->daddr;
> +	if (dst =3D=3D 0) {
> +#else
>  	if ((dst =3D tiph->daddr) =3D=3D 0) {
> +#endif
>  		/* NBMA tunnel */
>=20

General comment :

It would be nice this stuff is installed on a new "ip tunnel add"
option...

Hash table is 2048 bytes long... and an "ip tunnel " option would permi=
t
to size the hash table eventually, instead of fixed 256 slots.
