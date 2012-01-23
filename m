From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 23 Jan 2012 14:12:48 +0100
Message-ID: <CAGsizzLUwA_=fZFX-4ZnYU4K-nj1A2DV_BZKOMKxgQDh2Rs54g@mail.gmail.com>
References: <18947389.2811326843064500.JavaMail.root@5-MeO-DMT.ynet.sk> <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/18 Stefan Gula <steweg@ynet.sk>:
> From: Stefan Gula <steweg@gmail.com>
>
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
>
> Signed-off-by: Stefan Gula <steweg@gmail.com>
>
> ---
>
> code was merged with Eric Dumazet proposal (all except the reordering=
 of orig_source as that needed to be previous value), tested and fixed =
with additional lines in ipgre_tap_netdev_ops struct, orig_source line =
was moved before pskb_may_pull
>
> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-ori=
g/include/net/ipip.h linux-3.2.1-my/include/net/ipip.h
> --- linux-3.2.1-orig/include/net/ipip.h 2012-01-12 20:42:45.000000000=
 +0100
> +++ linux-3.2.1-my/include/net/ipip.h =A0 2012-01-16 11:17:01.0000000=
00 +0100
> @@ -27,6 +27,14 @@ struct ip_tunnel {
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o_seqno; =A0=
 =A0 =A0 =A0/* The last output seqno */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlen; =A0 =
=A0 =A0 =A0 =A0 /* Precalculated GRE header length */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mlink;
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +#define GRETAP_BR_HASH_BITS 8
> +#define GRETAP_BR_HASH_SIZE (1 << GRETAP_BR_HASH_BITS)
> + =A0 =A0 =A0 struct hlist_head =A0 =A0 =A0 hash[GRETAP_BR_HASH_SIZE]=
;
> + =A0 =A0 =A0 spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0hash_lock;
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 ageing_time;
> + =A0 =A0 =A0 struct timer_list =A0 =A0 =A0 gc_timer;
> +#endif
>
> =A0 =A0 =A0 =A0struct ip_tunnel_parm =A0 parms;
>
> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-ori=
g/net/ipv4/Kconfig linux-3.2.1-my/net/ipv4/Kconfig
> --- linux-3.2.1-orig/net/ipv4/Kconfig =A0 2012-01-12 20:42:45.0000000=
00 +0100
> +++ linux-3.2.1-my/net/ipv4/Kconfig =A0 =A0 2012-01-16 12:37:00.00000=
0000 +0100
> @@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
> =A0 =A0 =A0 =A0 =A0Network), but can be distributed all over the Inte=
rnet. If you want
> =A0 =A0 =A0 =A0 =A0to do that, say Y here and to "IP multicast routin=
g" below.
>
> +config NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 bool "IP: Ethernet over multipoint GRE over IP"
> + =A0 =A0 =A0 depends on IP_MULTICAST && NET_IPGRE && NET_IPGRE_BROAD=
CAST
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 Allows you to use multipoint GRE VPN as virtual swi=
tch and interconnect
> + =A0 =A0 =A0 =A0 several L2 endpoints over L3 routed infrastructure.=
 It is useful for
> + =A0 =A0 =A0 =A0 creating multipoint L2 VPNs which can be later used=
 inside bridge
> + =A0 =A0 =A0 =A0 interfaces If you want to use. GRE multipoint L2 VP=
N feature say Y.
> +
> =A0config IP_MROUTE
> =A0 =A0 =A0 =A0bool "IP: multicast routing"
> =A0 =A0 =A0 =A0depends on IP_MULTICAST
> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-ori=
g/net/ipv4/ip_gre.c linux-3.2.1-my/net/ipv4/ip_gre.c
> --- linux-3.2.1-orig/net/ipv4/ip_gre.c =A02012-01-12 20:42:45.0000000=
00 +0100
> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =A0 =A02012-01-18 00:33:55.00000=
0000 +0100
> @@ -52,6 +52,11 @@
> =A0#include <net/ip6_route.h>
> =A0#endif
>
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> +#include <linux/jhash.h>
> +#include <asm/unaligned.h>
> +#endif
> +
> =A0/*
> =A0 =A0Problems & solutions
> =A0 =A0--------------------
> @@ -134,6 +139,172 @@ struct ipgre_net {
> =A0 =A0 =A0 =A0struct net_device *fb_tunnel_dev;
> =A0};
>
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* This part of code includes codes to enable L2 ethe=
rnet
> + =A0 =A0 =A0 =A0* switch virtualization over IP routed infrastructur=
e with
> + =A0 =A0 =A0 =A0* utilization of multicast capable endpoint using Et=
hernet
> + =A0 =A0 =A0 =A0* over GRE
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Author: Stefan Gula
> + =A0 =A0 =A0 =A0* Signed-off-by: Stefan Gula <steweg@gmail.com>
> + =A0 =A0 =A0 =A0*/
> +struct ipgre_tap_bridge_entry {
> + =A0 =A0 =A0 struct hlist_node =A0 =A0 =A0 hlist;
> + =A0 =A0 =A0 __be32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0raddr;
> + =A0 =A0 =A0 unsigned char =A0 =A0 =A0 =A0 =A0 addr[ETH_ALEN];
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 updated;
> + =A0 =A0 =A0 struct rcu_head =A0 =A0 =A0 =A0 rcu;
> +};
> +
> +static u32 ipgre_salt __read_mostly;
> +
> +static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
> +{
> + =A0 =A0 =A0 u32 key =3D get_unaligned((u32 *)(mac + 2));
> +
> + =A0 =A0 =A0 return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_S=
IZE - 1);
> +}
> +
> +static inline int ipgre_tap_bridge_has_expired(const struct ip_tunne=
l *tunnel,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const s=
truct ipgre_tap_bridge_entry *entry)
> +{
> + =A0 =A0 =A0 return time_before_eq(entry->updated + tunnel->ageing_t=
ime,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies=
);
> +}
> +
> +static inline void ipgre_tap_bridge_delete(struct ipgre_tap_bridge_e=
ntry *entry)
> +{
> + =A0 =A0 =A0 hlist_del_rcu(&entry->hlist);
> + =A0 =A0 =A0 kfree_rcu(entry, rcu);
> +}
> +
> +static void ipgre_tap_bridge_cleanup(unsigned long _data)
> +{
> + =A0 =A0 =A0 struct ip_tunnel *tunnel =3D (struct ip_tunnel *)_data;
> + =A0 =A0 =A0 unsigned long delay =3D tunnel->ageing_time;
> + =A0 =A0 =A0 unsigned long next_timer =3D jiffies + tunnel->ageing_t=
ime;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 spin_lock(&tunnel->hash_lock);
> + =A0 =A0 =A0 for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct hlist_node *h, *n;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_safe(entry, h, n,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &tunnel->hash[i], hlist=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long this_time=
r;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_timer =3D entry->u=
pdated + delay;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (time_before_eq(this=
_timer, jiffies))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_t=
ap_bridge_delete(entry);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (time_before(th=
is_timer, next_timer))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_ti=
mer =3D this_timer;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock(&tunnel->hash_lock);
> + =A0 =A0 =A0 mod_timer(&tunnel->gc_timer, round_jiffies_up(next_time=
r));
> +}
> +
> +static void ipgre_tap_bridge_flush(struct ip_tunnel *tunnel)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 spin_lock_bh(&tunnel->hash_lock);
> + =A0 =A0 =A0 for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct hlist_node *h, *n;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_safe(entry, h, n,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &tunnel->hash[i], hlist=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_tap_bridge_delete=
(entry);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_bh(&tunnel->hash_lock);
> +}
> +
> +static struct ipgre_tap_bridge_entry *__ipgre_tap_bridge_get(
> + =A0 =A0 =A0 struct ip_tunnel *tunnel, const unsigned char *addr)
> +{
> + =A0 =A0 =A0 struct hlist_node *h;
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> +
> + =A0 =A0 =A0 hlist_for_each_entry_rcu(entry, h,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &tunnel->hash[ipgre_tap=
_bridge_hash(addr)], hlist) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!compare_ether_addr(entry->addr, ad=
dr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(ipgre_tap_=
bridge_has_expired(tunnel,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry))=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return entry;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
> + =A0 =A0 =A0 struct hlist_head *head,
> + =A0 =A0 =A0 const unsigned char *addr)
> +{
> + =A0 =A0 =A0 struct hlist_node *h;
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> +
> + =A0 =A0 =A0 hlist_for_each_entry(entry, h, head, hlist) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!compare_ether_addr(entry->addr, ad=
dr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return entry;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find_rcu(
> + =A0 =A0 =A0 struct hlist_head *head,
> + =A0 =A0 =A0 const unsigned char *addr)
> +{
> + =A0 =A0 =A0 struct hlist_node *h;
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> +
> + =A0 =A0 =A0 hlist_for_each_entry_rcu(entry, h, head, hlist) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!compare_ether_addr(entry->addr, ad=
dr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return entry;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
> + =A0 =A0 =A0 struct hlist_head *head,
> + =A0 =A0 =A0 __be32 source,
> + =A0 =A0 =A0 const unsigned char *addr)
> +{
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> +
> + =A0 =A0 =A0 entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
> + =A0 =A0 =A0 if (entry) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(entry->addr, addr, ETH_ALEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->raddr =3D source;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->updated =3D jiffies;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_add_head_rcu(&entry->hlist, head)=
;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return entry;
> +}
> +
> +static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
> + =A0 =A0 =A0 const unsigned char *addr)
> +{
> + =A0 =A0 =A0 __be32 raddr =3D 0;
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 entry =3D __ipgre_tap_bridge_get(tunnel, addr);
> + =A0 =A0 =A0 if (entry)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 raddr =3D entry->raddr;
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 return raddr;
> +}
> +
> +#endif
> =A0/* Tunnel hash table */
>
> =A0/*
> @@ -562,6 +733,12 @@ static int ipgre_rcv(struct sk_buff *skb
> =A0 =A0 =A0 =A0struct ip_tunnel *tunnel;
> =A0 =A0 =A0 =A0int =A0 =A0offset =3D 4;
> =A0 =A0 =A0 =A0__be16 gre_proto;
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 __be32 orig_source;
> + =A0 =A0 =A0 struct hlist_head *head;
> + =A0 =A0 =A0 struct ipgre_tap_bridge_entry *entry;
> + =A0 =A0 =A0 const struct ethhdr *tethhdr;
> +#endif
>
> =A0 =A0 =A0 =A0if (!pskb_may_pull(skb, 16))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop_nolock;
> @@ -654,6 +831,9 @@ static int ipgre_rcv(struct sk_buff *skb
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Warning: All skb pointers will be i=
nvalidated! */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tunnel->dev->type =3D=3D ARPHRD_ET=
HER) {
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 orig_source =3D iph->sa=
ddr;
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pskb_may_pull(skb=
, ETH_HLEN)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tunnel=
->dev->stats.rx_length_errors++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tunnel=
->dev->stats.rx_errors++;
> @@ -663,6 +843,32 @@ static int ipgre_rcv(struct sk_buff *skb
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iph =3D ip_hdr(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol =3D eth_=
type_trans(skb, tunnel->dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_postpull_rcsum(skb=
, eth_hdr(skb), ETH_HLEN);
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ipv4_is_multicast(t=
unnel->parms.iph.daddr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tethhdr=
 =3D eth_hdr(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is=
_multicast_ether_addr(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 tethhdr->h_source)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 head =3D &tunnel->hash[
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_tap_bridge_hash(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tethhdr->h_source)];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 entry =3D ipgre_tap_bridge_find_rcu(head,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 tethhdr->h_source);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (likely(entry)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 entry->raddr =3D orig_source;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 entry->updated =3D jiffies;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 spin_lock(&tunnel->hash_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 if (!ipgre_tap_bridge_find(head,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 tethhdr->h_source))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_tap_bridge_create(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 orig_source,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tethhdr->h_source);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 spin_unlock(&tunnel->hash_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tstats =3D this_cpu_ptr(tunnel->dev->t=
stats);
> @@ -702,7 +908,7 @@ static netdev_tx_t ipgre_tunnel_xmit(str
> =A0 =A0 =A0 =A0struct iphdr =A0*iph; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 /* Our new IP header */
> =A0 =A0 =A0 =A0unsigned int max_headroom; =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* The extra header space needed */
> =A0 =A0 =A0 =A0int =A0 =A0gre_hlen;
> - =A0 =A0 =A0 __be32 dst;
> + =A0 =A0 =A0 __be32 dst =3D 0;
> =A0 =A0 =A0 =A0int =A0 =A0mtu;
>
> =A0 =A0 =A0 =A0if (dev->type =3D=3D ARPHRD_ETHER)
> @@ -716,7 +922,15 @@ static netdev_tx_t ipgre_tunnel_xmit(str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tiph =3D &tunnel->parms.iph;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if ((dst =3D tiph->daddr) =3D=3D 0) {
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 if ((dev->type =3D=3D ARPHRD_ETHER) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipv4_is_multicast(tunnel->parms.iph.dad=
dr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst =3D ipgre_tap_bridge_get_raddr(tunn=
el,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((struct ethhdr *)skb->=
data)->h_dest);
> +#endif
> + =A0 =A0 =A0 if (dst =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst =3D tiph->daddr;
> + =A0 =A0 =A0 if (dst =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* NBMA tunnel */
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb_dst(skb) =3D=3D NULL) {
> @@ -1209,6 +1423,16 @@ static int ipgre_open(struct net_device
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EADDRNOTAVAIL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0t->mlink =3D dev->ifindex;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_mc_inc_group(__in_dev_get_rtnl(dev)=
, t->parms.iph.daddr);
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (t->dev->type =3D=3D ARPHRD_ETHER) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_HLIST_HEAD(t->hash=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_init(&t->hash=
_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 t->ageing_time =3D 300 =
* HZ;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_timer(&t->gc_time=
r, ipgre_tap_bridge_cleanup,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsign=
ed long) t);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&t->gc_timer,=
 jiffies + t->ageing_time);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +#endif
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -1219,6 +1443,12 @@ static int ipgre_close(struct net_device
>
> =A0 =A0 =A0 =A0if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink)=
 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct in_device *in_dev;
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (t->dev->type =3D=3D ARPHRD_ETHER) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ipgre_tap_bridge_flush(=
t);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer_sync(&t->gc_t=
imer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0in_dev =3D inetdev_by_index(dev_net(de=
v), t->mlink);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (in_dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_mc_dec_group(in_dev=
, t->parms.iph.daddr);
> @@ -1488,6 +1718,10 @@ static int ipgre_tap_init(struct net_dev
> =A0static const struct net_device_ops ipgre_tap_netdev_ops =3D {
> =A0 =A0 =A0 =A0.ndo_init =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ipgre_tap_in=
it,
> =A0 =A0 =A0 =A0.ndo_uninit =A0 =A0 =A0 =A0 =A0 =A0 =3D ipgre_tunnel_u=
ninit,
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ipgre_open,
> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ipgre_close,
> +#endif
> =A0 =A0 =A0 =A0.ndo_start_xmit =A0 =A0 =A0 =A0 =3D ipgre_tunnel_xmit,
> =A0 =A0 =A0 =A0.ndo_set_mac_address =A0 =A0=3D eth_mac_addr,
> =A0 =A0 =A0 =A0.ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
> @@ -1705,6 +1939,9 @@ static int __init ipgre_init(void)
>
> =A0 =A0 =A0 =A0printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
>
> +#ifdef CONFIG_NET_IPGRE_BRIDGE
> + =A0 =A0 =A0 get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
> +#endif
> =A0 =A0 =A0 =A0err =3D register_pernet_device(&ipgre_net_ops);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
is there anything else needed from my side to get this code into the
kernel or should I only wait for the maintainers to check it?
