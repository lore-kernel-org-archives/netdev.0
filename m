From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 00:11:50 +0100
Message-ID: <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <1326745733.2564.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326745733.2564.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=C5=88a 16. janu=C3=A1ra 2012 21:28, Eric Dumazet <eric.dumazet@gmail.=
com> nap=C3=ADsal/a:
> Le lundi 16 janvier 2012 =C3=A0 20:45 +0100, =C5=A0tefan Gula a =C3=A9=
crit :
>> From: Stefan Gula <steweg@gmail.com
>>
>> This patch is an extension for current Ethernet over GRE
>> implementation, which allows user to create virtual bridge (multipoi=
nt
>> VPN) and forward traffic based on Ethernet MAC address information i=
n
>> it. It simulates the Bridge behavior learning mechanism, but instead
>> of learning port ID from which given MAC address comes, it learns IP
>> address of peer which encapsulated given packet. Multicast, Broadcas=
t
>> and unknown-multicast traffic is send over network as multicast
>> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can b=
e
>> represented as one single virtual switch on logical level and be als=
o
>> represented as one multicast IPv4 address on network level.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>
>> ---
>>
>> code was merged with latest bridge code and should be easily compara=
ble
>>
>
> Please make sure it applies properly on net-next tree.
>
> That is mandatory.
>
>> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
>> linux-3.2.1-orig/include/net/ipip.h linux-3.2.1-my/include/net/ipip.=
h
>> --- linux-3.2.1-orig/include/net/ipip.h =C2=A0 =C2=A0 =C2=A0 2012-01=
-12 20:42:45.000000000 +0100
>> +++ linux-3.2.1-my/include/net/ipip.h 2012-01-16 11:17:01.000000000 =
+0100
>> @@ -27,6 +27,14 @@ struct ip_tunnel {
>> =C2=A0 =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 o_seqno; =C2=A0 =C2=A0 =C2=A0 =C2=A0/* The last o=
utput seqno */
>> =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 hlen; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Pr=
ecalculated GRE header length */
>> =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 mlink;
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> +#define GRETAP_BR_HASH_BITS 8
>> +#define GRETAP_BR_HASH_SIZE (1 << GRETAP_BR_HASH_BITS)
>> + =C2=A0 =C2=A0 struct hlist_head =C2=A0 =C2=A0 =C2=A0 hash[GRETAP_B=
R_HASH_SIZE];
>> + =C2=A0 =C2=A0 spinlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0hash_lock;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 age=
ing_time;
>> + =C2=A0 =C2=A0 struct timer_list =C2=A0 =C2=A0 =C2=A0 gc_timer;
>> +#endif
>>
>> =C2=A0 =C2=A0 =C2=A0 struct ip_tunnel_parm =C2=A0 parms;
>>
>> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
>> linux-3.2.1-orig/net/ipv4/Kconfig linux-3.2.1-my/net/ipv4/Kconfig
>> --- linux-3.2.1-orig/net/ipv4/Kconfig 2012-01-12 20:42:45.000000000 =
+0100
>> +++ linux-3.2.1-my/net/ipv4/Kconfig =C2=A0 2012-01-16 12:37:00.00000=
0000 +0100
>> @@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Network), but can be distributed all ove=
r the Internet. If you want
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 to do that, say Y here and to "IP multic=
ast routing" below.
>>
>> +config NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 bool "IP: Ethernet over multipoint GRE over IP"
>> + =C2=A0 =C2=A0 depends on IP_MULTICAST && NET_IPGRE && NET_IPGRE_BR=
OADCAST
>> + =C2=A0 =C2=A0 help
>> + =C2=A0 =C2=A0 =C2=A0 Allows you to use multipoint GRE VPN as virtu=
al switch and interconnect
>> + =C2=A0 =C2=A0 =C2=A0 several L2 endpoints over L3 routed infrastru=
cture. It is useful for
>> + =C2=A0 =C2=A0 =C2=A0 creating multipoint L2 VPNs which can be late=
r used inside bridge
>> + =C2=A0 =C2=A0 =C2=A0 interfaces If you want to use. GRE multipoint=
 L2 VPN feature say Y.
>> +
>> =C2=A0config IP_MROUTE
>> =C2=A0 =C2=A0 =C2=A0 bool "IP: multicast routing"
>> =C2=A0 =C2=A0 =C2=A0 depends on IP_MULTICAST
>> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
>> linux-3.2.1-orig/net/ipv4/ip_gre.c linux-3.2.1-my/net/ipv4/ip_gre.c
>> --- linux-3.2.1-orig/net/ipv4/ip_gre.c =C2=A0 =C2=A0 =C2=A0 =C2=A020=
12-01-12 20:42:45.000000000 +0100
>> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =C2=A02012-01-16 20:42:03.00000=
0000 +0100
>> @@ -52,6 +52,11 @@
>> =C2=A0#include <net/ip6_route.h>
>> =C2=A0#endif
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> +#include <linux/jhash.h>
>> +#include <asm/unaligned.h>
>> +#endif
>> +
>> =C2=A0/*
>> =C2=A0 =C2=A0 Problems & solutions
>> =C2=A0 =C2=A0 --------------------
>> @@ -134,6 +139,191 @@ struct ipgre_net {
>> =C2=A0 =C2=A0 =C2=A0 struct net_device *fb_tunnel_dev;
>> =C2=A0};
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* This part of code includes codes to enable L=
2 ethernet
>> + =C2=A0 =C2=A0 =C2=A0* switch virtualization over IP routed infrast=
ructure with
>> + =C2=A0 =C2=A0 =C2=A0* utilization of multicast capable endpoint us=
ing Ethernet
>> + =C2=A0 =C2=A0 =C2=A0* over GRE
>> + =C2=A0 =C2=A0 =C2=A0*
>> + =C2=A0 =C2=A0 =C2=A0* Author: Stefan Gula
>> + =C2=A0 =C2=A0 =C2=A0* Signed-off-by: Stefan Gula <steweg@gmail.com=
>
>> + =C2=A0 =C2=A0 =C2=A0*/
>> +struct mac_addr {
>> + =C2=A0 =C2=A0 unsigned char =C2=A0 addr[6];
>
> Did I mention : ETH_ALEN ?
>
>> +};
>> +
>> +struct ipgre_tap_bridge_entry {
>> + =C2=A0 =C2=A0 struct hlist_node =C2=A0 =C2=A0 =C2=A0 hlist;
>> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 raddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__be32 raddr ?
>
>> + =C2=A0 =C2=A0 struct mac_addr =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr;
>> + =C2=A0 =C2=A0 struct net_device =C2=A0 =C2=A0 =C2=A0 *dev;
>> + =C2=A0 =C2=A0 struct rcu_head =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 upd=
ated;
>> +};
>> +
>> +static struct kmem_cache *ipgre_tap_bridge_cache __read_mostly;
>> +static u32 ipgre_salt __read_mostly;
>> +
>> +int __net_init ipgre_tap_bridge_init(void)
>> +{
>> + =C2=A0 =C2=A0 ipgre_tap_bridge_cache =3D kmem_cache_create("ipgre_=
tap_bridge_cache",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sizeof(struct ipgre_tap_=
bridge_entry),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SLAB_HWCACHE_ALIGN, NULL=
);
>> + =C2=A0 =C2=A0 if (!ipgre_tap_bridge_cache)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>> + =C2=A0 =C2=A0 get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +void ipgre_tap_bridge_fini(void)
>> +{
>> + =C2=A0 =C2=A0 kmem_cache_destroy(ipgre_tap_bridge_cache);
>> +}
>> +
>> +static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
>> +{
>> + =C2=A0 =C2=A0 u32 key =3D get_unaligned((u32 *)(mac + 2));
>> + =C2=A0 =C2=A0 return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HAS=
H_SIZE - 1);
>> +}
>> +
>> +static inline int ipgre_tap_bridge_has_expired(const struct ip_tunn=
el *tunnel,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct ipgre_tap_b=
ridge_entry *entry)
>> +{
>> + =C2=A0 =C2=A0 return time_before_eq(entry->updated + tunnel->agein=
g_time,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 jiffies);
>> +}
>> +
>> +static void ipgre_tap_bridge_rcu_free(struct rcu_head *head)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D container_of(head, s=
truct ipgre_tap_bridge_entry, rcu);
>> + =C2=A0 =C2=A0 kmem_cache_free(ipgre_tap_bridge_cache, entry);
>> +}
>> +
>> +static inline void ipgre_tap_bridge_delete(struct
>> ipgre_tap_bridge_entry *entry)
>> +{
>> + =C2=A0 =C2=A0 hlist_del_rcu(&entry->hlist);
>> + =C2=A0 =C2=A0 call_rcu(&entry->rcu, ipgre_tap_bridge_rcu_free);
>> +}
>
> Did I mention : kfree_rcu() ?
>
>> +
>> +
>> +
>> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
>> + =C2=A0 =C2=A0 struct hlist_head *head,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct hlist_node *h;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 hlist_for_each_entry(entry, h, head, hlist) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!compare_ether_addr(=
entry->addr.addr, addr))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return entry;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>> +
>> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find_rcu(
>> + =C2=A0 =C2=A0 struct hlist_head *head,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct hlist_node *h;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 hlist_for_each_entry_rcu(entry, h, head, hlist) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!compare_ether_addr(=
entry->addr.addr, addr))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return entry;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hlist_head *head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 source,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__be32 source,
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const unsigned char *add=
r, struct net_device *dev)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 entry =3D kmem_cache_alloc(ipgre_tap_bridge_cache, G=
=46P_ATOMIC);
>> + =C2=A0 =C2=A0 if (entry) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(entry->addr.addr,=
 addr, ETH_ALEN);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hlist_add_head_rcu(&entr=
y->hlist, head);
>
> Thats bogus.
>
> You must init all entry fields _before_ inserting entry in hash table=
=2E
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->raddr =3D source;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->dev =3D dev;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->updated =3D jiffi=
es;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return entry;
>> +}
>> +
>> +__be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 entry =3D __ipgre_tap_bridge_get(tunnel, addr);
>> + =C2=A0 =C2=A0 if (entry =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return entry->raddr;
>> +}
>> +
>> +#endif
>> =C2=A0/* Tunnel hash table */
>>
>> =C2=A0/*
>> @@ -563,6 +753,13 @@ static int ipgre_rcv(struct sk_buff *skb
>> =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=A0offset =3D 4;
>> =C2=A0 =C2=A0 =C2=A0 __be16 gre_proto;
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 u32 orig_source;
>
> Please run sparse on your code... =C2=A0(make C=3D2 ...)
>
> orig_source is not u32, but __be32
>
>> + =C2=A0 =C2=A0 struct hlist_head *head;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 struct ethhdr *tethhdr;
>> +#endif
>> +
>> =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pull(skb, 16))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto drop_nolock;
>>
>> @@ -659,10 +856,39 @@ static int ipgre_rcv(struct sk_buff *skb
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tunnel->dev->stats.rx_errors++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto drop;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 }
>> -
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 orig_source =3D iph->saddr;
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 iph =3D ip_hdr(skb);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 skb->protocol =3D eth_type_trans(skb, tunnel->dev);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (ipv4_is_multicast(tunnel->parms.iph.daddr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tethhdr =3D eth_hdr(skb);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!is_multicast_ether_addr(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tethhdr->h_=
source)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 head =3D &t=
unnel->hash[
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 ipgre_tap_bridge_hash(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tethhdr->h_source)];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry =3D i=
pgre_tap_bridge_find_rcu(head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 tethhdr->h_source);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(=
entry)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 entry->raddr =3D orig_source;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 entry->updated =3D jiffies;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin=
_lock_bh(&tunnel->hash_lock);
>
> You dont need the _bh() variant here, since we run from softirq handl=
er.
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (=
!ipgre_tap_bridge_find(head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 tethhdr->h_source))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 ipgre_tap_bridge_create(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0orig_source,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0tethhdr->h_source,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0tunnel->dev);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin=
_unlock_bh(&tunnel->hash_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tstats =3D this_cpu=
_ptr(tunnel->dev->tstats);
>> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tiph =3D &tunnel->p=
arms.iph;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 if ((dev->type =3D=3D ARPHRD_ETHER) &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ipv4_is_multicast(tunnel=
->parms.iph.daddr))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst =3D ipgre_tap_bridge=
_get_raddr(tunnel,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ((struct ethhdr *)skb->data)->h_dest);
>> + =C2=A0 =C2=A0 rcu_read_unlock();
>
> this rcu_read_lock()/rcu_read_unlock() pair should be done in
> ipgre_tap_bridge_get_raddr() instead... so we dont hit this for all
> packets.
>
>> + =C2=A0 =C2=A0 if (dst =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst =3D tiph->daddr;
>> + =C2=A0 =C2=A0 if (dst =3D=3D 0) {
>> +#else
>> =C2=A0 =C2=A0 =C2=A0 if ((dst =3D tiph->daddr) =3D=3D 0) {
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* NBMA tunnel */
>>
>
> General comment :
>
> It would be nice this stuff is installed on a new "ip tunnel add"
> option...
>
> Hash table is 2048 bytes long... and an "ip tunnel " option would per=
mit
> to size the hash table eventually, instead of fixed 256 slots.
>
>
>

I agree with you, but for the start of this feature I believe static
slots size is enough here - same limitation is inside the original
linux bridge code. I have merged hopefully all your comments and here
is the newest patch:

diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/include/net/ipip.h linux-3.2.1-my/include/net/ipip.h
--- linux-3.2.1-orig/include/net/ipip.h	2012-01-12 20:42:45.000000000 +=
0100
+++ linux-3.2.1-my/include/net/ipip.h	2012-01-16 11:17:01.000000000 +01=
00
@@ -27,6 +27,14 @@ struct ip_tunnel {
 	__u32			o_seqno;	/* The last output seqno */
 	int			hlen;		/* Precalculated GRE header length */
 	int			mlink;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+#define GRETAP_BR_HASH_BITS 8
+#define GRETAP_BR_HASH_SIZE (1 << GRETAP_BR_HASH_BITS)
+	struct hlist_head	hash[GRETAP_BR_HASH_SIZE];
+	spinlock_t		hash_lock;
+	unsigned long		ageing_time;
+	struct timer_list	gc_timer;
+#endif

 	struct ip_tunnel_parm	parms;

diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/net/ipv4/Kconfig linux-3.2.1-my/net/ipv4/Kconfig
--- linux-3.2.1-orig/net/ipv4/Kconfig	2012-01-12 20:42:45.000000000 +01=
00
+++ linux-3.2.1-my/net/ipv4/Kconfig	2012-01-16 12:37:00.000000000 +0100
@@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
 	  Network), but can be distributed all over the Internet. If you want
 	  to do that, say Y here and to "IP multicast routing" below.

+config NET_IPGRE_BRIDGE
+	bool "IP: Ethernet over multipoint GRE over IP"
+	depends on IP_MULTICAST && NET_IPGRE && NET_IPGRE_BROADCAST
+	help
+	  Allows you to use multipoint GRE VPN as virtual switch and intercon=
nect
+	  several L2 endpoints over L3 routed infrastructure. It is useful fo=
r
+	  creating multipoint L2 VPNs which can be later used inside bridge
+	  interfaces If you want to use. GRE multipoint L2 VPN feature say Y.
+
 config IP_MROUTE
 	bool "IP: multicast routing"
 	depends on IP_MULTICAST
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/net/ipv4/ip_gre.c linux-3.2.1-my/net/ipv4/ip_gre.c
--- linux-3.2.1-orig/net/ipv4/ip_gre.c	2012-01-12 20:42:45.000000000 +0=
100
+++ linux-3.2.1-my/net/ipv4/ip_gre.c	2012-01-17 00:01:17.000000000 +010=
0
@@ -52,6 +52,11 @@
 #include <net/ip6_route.h>
 #endif

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+#include <linux/jhash.h>
+#include <asm/unaligned.h>
+#endif
+
 /*
    Problems & solutions
    --------------------
@@ -134,6 +139,184 @@ struct ipgre_net {
 	struct net_device *fb_tunnel_dev;
 };

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	/*
+	 * This part of code includes codes to enable L2 ethernet
+	 * switch virtualization over IP routed infrastructure with
+	 * utilization of multicast capable endpoint using Ethernet
+	 * over GRE
+	 *
+	 * Author: Stefan Gula
+	 * Signed-off-by: Stefan Gula <steweg@gmail.com>
+	 */
+struct ipgre_tap_bridge_entry {
+	struct hlist_node	hlist;
+	__be32			raddr;
+	unsigned char		addr[ETH_ALEN];
+	struct net_device	*dev;
+	struct rcu_head		rcu;
+	unsigned long		updated;
+};
+
+static struct kmem_cache *ipgre_tap_bridge_cache __read_mostly;
+static u32 ipgre_salt __read_mostly;
+
+static int __net_init ipgre_tap_bridge_init(void)
+{
+	ipgre_tap_bridge_cache =3D kmem_cache_create("ipgre_tap_bridge_cache"=
,
+		sizeof(struct ipgre_tap_bridge_entry),
+		0,
+		SLAB_HWCACHE_ALIGN, NULL);
+	if (!ipgre_tap_bridge_cache)
+		return -ENOMEM;
+	get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
+	return 0;
+}
+
+static void ipgre_tap_bridge_fini(void)
+{
+	kmem_cache_destroy(ipgre_tap_bridge_cache);
+}
+
+static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
+{
+	u32 key =3D get_unaligned((u32 *)(mac + 2));
+	return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_SIZE - 1);
+}
+
+static inline int ipgre_tap_bridge_has_expired(const struct ip_tunnel =
*tunnel,
+		const struct ipgre_tap_bridge_entry *entry)
+{
+	return time_before_eq(entry->updated + tunnel->ageing_time,
+		jiffies);
+}
+
+static inline void ipgre_tap_bridge_delete(struct
ipgre_tap_bridge_entry *entry)
+{
+	hlist_del_rcu(&entry->hlist);
+	kfree_rcu(entry, rcu);
+}
+
+static void ipgre_tap_bridge_cleanup(unsigned long _data)
+{
+	struct ip_tunnel *tunnel =3D (struct ip_tunnel *)_data;
+	unsigned long delay =3D tunnel->ageing_time;
+	unsigned long next_timer =3D jiffies + tunnel->ageing_time;
+	int i;
+	spin_lock(&tunnel->hash_lock);
+	for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+		hlist_for_each_entry_safe(entry, h, n,
+			&tunnel->hash[i], hlist)
+		{
+			unsigned long this_timer;
+			this_timer =3D entry->updated + delay;
+			if (time_before_eq(this_timer, jiffies))
+				ipgre_tap_bridge_delete(entry);
+			else if (time_before(this_timer, next_timer))
+				next_timer =3D this_timer;
+		}
+	}
+	spin_unlock(&tunnel->hash_lock);
+	mod_timer(&tunnel->gc_timer, round_jiffies_up(next_timer));
+}
+
+static void ipgre_tap_bridge_flush(struct ip_tunnel *tunnel)
+{
+	int i;
+	spin_lock_bh(&tunnel->hash_lock);
+	for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+		hlist_for_each_entry_safe(entry, h, n,
+			&tunnel->hash[i], hlist)
+		{
+			ipgre_tap_bridge_delete(entry);
+		}
+	}
+	spin_unlock_bh(&tunnel->hash_lock);
+}
+
+static struct ipgre_tap_bridge_entry *__ipgre_tap_bridge_get(
+	struct ip_tunnel *tunnel, const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct ipgre_tap_bridge_entry *entry;
+	hlist_for_each_entry_rcu(entry, h,
+		&tunnel->hash[ipgre_tap_bridge_hash(addr)], hlist)
+	{
+		if (!compare_ether_addr(entry->addr, addr)) {
+			if (unlikely(ipgre_tap_bridge_has_expired(tunnel,
+				entry)))
+				break;
+			return entry;
+		}
+	}
+
+	return NULL;
+}
+
+static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
+	struct hlist_head *head,
+	const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct ipgre_tap_bridge_entry *entry;
+	hlist_for_each_entry(entry, h, head, hlist) {
+		if (!compare_ether_addr(entry->addr, addr))
+			return entry;
+	}
+	return NULL;
+}
+
+
+static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find_rcu(
+	struct hlist_head *head,
+	const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct ipgre_tap_bridge_entry *entry;
+	hlist_for_each_entry_rcu(entry, h, head, hlist) {
+		if (!compare_ether_addr(entry->addr, addr))
+			return entry;
+	}
+	return NULL;
+}
+
+static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
+		struct hlist_head *head,
+		u32 source,
+		const unsigned char *addr, struct net_device *dev)
+{
+	struct ipgre_tap_bridge_entry *entry;
+	entry =3D kmem_cache_alloc(ipgre_tap_bridge_cache, GFP_ATOMIC);
+	if (entry) {
+		memcpy(entry->addr, addr, ETH_ALEN);
+		entry->raddr =3D source;
+		entry->dev =3D dev;
+		entry->updated =3D jiffies;
+		hlist_add_head_rcu(&entry->hlist, head);
+	}
+	return entry;
+}
+
+static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	__be32 raddr;
+	struct ipgre_tap_bridge_entry *entry;
+	rcu_read_lock();
+	entry =3D __ipgre_tap_bridge_get(tunnel, addr);
+	if (entry =3D=3D NULL)
+		raddr =3D 0;
+	else
+		raddr =3D entry->raddr;
+	rcu_read_unlock();
+	return raddr;
+}
+
+#endif
 /* Tunnel hash table */

 /*
@@ -563,6 +746,13 @@ static int ipgre_rcv(struct sk_buff *skb
 	int    offset =3D 4;
 	__be16 gre_proto;

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	__be32 orig_source;
+	struct hlist_head *head;
+	struct ipgre_tap_bridge_entry *entry;
+	struct ethhdr *tethhdr;
+#endif
+
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;

@@ -659,10 +849,39 @@ static int ipgre_rcv(struct sk_buff *skb
 				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
-
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			orig_source =3D iph->saddr;
+#endif
 			iph =3D ip_hdr(skb);
 			skb->protocol =3D eth_type_trans(skb, tunnel->dev);
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			if (ipv4_is_multicast(tunnel->parms.iph.daddr)) {
+				tethhdr =3D eth_hdr(skb);
+				if (!is_multicast_ether_addr(
+					tethhdr->h_source)) {
+					head =3D &tunnel->hash[
+						ipgre_tap_bridge_hash(
+							tethhdr->h_source)];
+					entry =3D ipgre_tap_bridge_find_rcu(head,
+						tethhdr->h_source);
+					if (likely(entry)) {
+						entry->raddr =3D orig_source;
+						entry->updated =3D jiffies;
+					} else {
+					  spin_lock(&tunnel->hash_lock);
+					  if (!ipgre_tap_bridge_find(head,
+						tethhdr->h_source))
+						ipgre_tap_bridge_create(
+						 head,
+						 orig_source,
+						 tethhdr->h_source,
+						 tunnel->dev);
+					  spin_unlock(&tunnel->hash_lock);
+					}
+				}
+			}
+#endif
 		}

 		tstats =3D this_cpu_ptr(tunnel->dev->tstats);
@@ -716,7 +935,17 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 		tiph =3D &tunnel->parms.iph;
 	}

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	if ((dev->type =3D=3D ARPHRD_ETHER) &&
+		ipv4_is_multicast(tunnel->parms.iph.daddr))
+		dst =3D ipgre_tap_bridge_get_raddr(tunnel,
+			((struct ethhdr *)skb->data)->h_dest);
+	if (dst =3D=3D 0)
+		dst =3D tiph->daddr;
+	if (dst =3D=3D 0) {
+#else
 	if ((dst =3D tiph->daddr) =3D=3D 0) {
+#endif
 		/* NBMA tunnel */

 		if (skb_dst(skb) =3D=3D NULL) {
@@ -1209,6 +1438,16 @@ static int ipgre_open(struct net_device
 			return -EADDRNOTAVAIL;
 		t->mlink =3D dev->ifindex;
 		ip_mc_inc_group(__in_dev_get_rtnl(dev), t->parms.iph.daddr);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		if (t->dev->type =3D=3D ARPHRD_ETHER) {
+			INIT_HLIST_HEAD(t->hash);
+			spin_lock_init(&t->hash_lock);
+			t->ageing_time =3D 300 * HZ;
+			setup_timer(&t->gc_timer, ipgre_tap_bridge_cleanup,
+				(unsigned long) t);
+			mod_timer(&t->gc_timer, jiffies + t->ageing_time);
+		}
+#endif
 	}
 	return 0;
 }
@@ -1219,6 +1458,12 @@ static int ipgre_close(struct net_device

 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		if (t->dev->type =3D=3D ARPHRD_ETHER) {
+			ipgre_tap_bridge_flush(t);
+			del_timer_sync(&t->gc_timer);
+		}
+#endif
 		in_dev =3D inetdev_by_index(dev_net(dev), t->mlink);
 		if (in_dev)
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
@@ -1341,6 +1586,12 @@ static int __net_init ipgre_init_net(str
 	struct ipgre_net *ign =3D net_generic(net, ipgre_net_id);
 	int err;

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	err =3D ipgre_tap_bridge_init();
+	if (err)
+		goto err_out;
+#endif
+
 	ign->fb_tunnel_dev =3D alloc_netdev(sizeof(struct ip_tunnel), "gre0",
 					   ipgre_tunnel_setup);
 	if (!ign->fb_tunnel_dev) {
@@ -1362,6 +1613,10 @@ static int __net_init ipgre_init_net(str
 err_reg_dev:
 	ipgre_dev_free(ign->fb_tunnel_dev);
 err_alloc_dev:
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	ipgre_tap_bridge_fini();
+err_out:
+#endif
 	return err;
 }

@@ -1375,6 +1630,9 @@ static void __net_exit ipgre_exit_net(st
 	ipgre_destroy_tunnels(ign, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	ipgre_tap_bridge_fini();
+#endif
 }

 static struct pernet_operations ipgre_net_ops =3D {
