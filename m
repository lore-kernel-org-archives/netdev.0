From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 15:05:43 +0100
Message-ID: <CAGsizzJpdF5xzsEiZd5R0GD8r7pDJyz4ro=4vLBnonxfAVYg-Q@mail.gmail.com>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
 <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
In-Reply-To: <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=C5=88a 16. janu=C3=A1ra 2012 14:19, Eric Dumazet <eric.dumazet@gmail.=
com> nap=C3=ADsal/a:
> Le lundi 16 janvier 2012 =C3=A0 13:13 +0100, =C5=A0tefan Gula a =C3=A9=
crit :
>> From: Stefan Gula <steweg@gmail.com
>>
>> This patch is an extension for current Ethernet over GRE
>> implementation, which allows user to create virtual bridge (multipoi=
nt
>> VPN) and forward traffic based on Ethernet MAC address informations =
in
>> it. It simulates the Bridge bahaviour learing mechanism, but instead
>> of learning port ID from which given MAC address comes, it learns IP
>> address of peer which encapsulated given packet. Multicast, Broadcas=
t
>> and unknown-multicast traffic is send over network as multicast
>> enacapsulated GRE packet, so one Ethernet multipoint GRE tunnel can =
be
>> represented as one single virtual switch on logical level and be als=
o
>> represented as one multicast IPv4 address on network level.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>
>> ---
>>
>> Patch was tested for more than one year in real network infrastructu=
re
>> consisting of 98 Linux based access-points
>>
>
> OK, but please always send new patches on top on net-next tree.
>
>> diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
>> linux-3.2.1-orig/Documentation/dontdiff
>> linux-3.2.1-my/Documentation/dontdiff
>> --- linux-3.2.1-orig/Documentation/dontdiff =C2=A0 2012-01-16 12:32:=
18.000000000 +0100
>> +++ linux-3.2.1-my/Documentation/dontdiff =C2=A0 =C2=A0 2012-01-12 2=
0:42:45.000000000 +0100
>> @@ -260,5 +260,3 @@ wakeup.lds
>> =C2=A0zImage*
>> =C2=A0zconf.hash.c
>> =C2=A0zoffset.h
>> -mkpiggy
>> -mdp
>
> Hmm, what is this ?
Sorry, this one is not related to my patch, I have follwed the
guideline and those 2 files always end-up in my diff file even I
didn't modify them, so I have added them into dontdiff file assuming
that that file will not pop-up in my diff file. Apparently wrong
assumption, so please ignore those lines

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
>> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =C2=A02012-01-16 12:29:03.00000=
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
>> @@ -134,6 +139,199 @@ struct ipgre_net {
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
> Not sure if you need a 'struct mac_addr' for this...
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned char mac_addr[ETH_ALEN] ?
not sure either, but I used in that time when I developed the code. Do
I have to change that to make this patch to kernel?
>> +};
>> +
>> +struct ipgre_tap_bridge_entry {
>> + =C2=A0 =C2=A0 struct hlist_node =C2=A0 =C2=A0 =C2=A0 hlist;
>> + =C2=A0 =C2=A0 u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 raddr;
>> + =C2=A0 =C2=A0 struct mac_addr =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr;
>> + =C2=A0 =C2=A0 struct net_device =C2=A0 =C2=A0 =C2=A0 *dev;
>> + =C2=A0 =C2=A0 struct rcu_head =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu;
>> + =C2=A0 =C2=A0 atomic_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0use_count;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 age=
ing_timer;
>
>
>> +};
>> +
>> +static struct kmem_cache *ipgre_tap_bridge_cache __read_mostly;
>> +static u32 ipgre_salt __read_mostly;
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
>> + =C2=A0 =C2=A0 return time_before_eq(entry->ageing_timer + tunnel->=
ageing_time,
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
>> +void ipgre_tap_bridge_put(struct ipgre_tap_bridge_entry *entry)
>> +{
>> + =C2=A0 =C2=A0 if (atomic_dec_and_test(&entry->use_count))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 call_rcu(&entry->rcu, ip=
gre_tap_bridge_rcu_free);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0You can now use kfree_rcu() and get rid of=
 ipgre_tap_bridge_rcu_free()
hmm... for that part of code was copy & pasted from linux bridge code
from version 2.6.26. Do I have to change that or is it optional?
>
>> +}
>> +
>> +static inline void ipgre_tap_bridge_delete(struct
>> ipgre_tap_bridge_entry *entry)
>> +{
>> + =C2=A0 =C2=A0 hlist_del_rcu(&entry->hlist);
>> + =C2=A0 =C2=A0 ipgre_tap_bridge_put(entry);
>> +}
>> +
>> +static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hlist_head *head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 source,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const unsigned char *add=
r, struct net_device *dev)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 entry =3D kmem_cache_alloc(ipgre_tap_bridge_cache, G=
=46P_ATOMIC);
>> + =C2=A0 =C2=A0 if (entry) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(entry->addr.addr,=
 addr, ETH_ALEN);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_set(&entry->use_c=
ount, 1);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hlist_add_head_rcu(&entr=
y->hlist, head);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->raddr =3D source;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->ageing_timer =3D =
jiffies;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry->dev =3D dev;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return entry;
>> +}
>> +
>> +struct ipgre_tap_bridge_entry *__ipgre_tap_bridge_get(struct ip_tun=
nel *tunnel,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct hlist_node *h;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 hlist_for_each_entry_rcu(entry, h,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &tunnel->hash[ipgre_tap_=
bridge_hash(addr)], hlist)
>> + =C2=A0 =C2=A0 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!compare_ether_addr(=
entry->addr.addr, addr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (unlikely(ipgre_tap_bridge_has_expired(tunnel,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry)))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return entry;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>> +struct ipgre_tap_bridge_entry *ipgre_tap_bridge_get(struct ip_tunne=
l *tunnel,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 entry =3D __ipgre_tap_bridge_get(tunnel, addr);
>> + =C2=A0 =C2=A0 if (entry && !atomic_inc_not_zero(&entry->use_count)=
)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry =3D NULL;
>> + =C2=A0 =C2=A0 rcu_read_unlock();
>> + =C2=A0 =C2=A0 return entry;
>> +}
>> +
>
> Unfortunately you call ipgre_tap_bridge_get() from
> ipgre_tap_bridge_get_raddr() but you dont release the refcount on
> use_count. Leak in ipgre_tunnel_xmit()
>
>
>> +__be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 entry =3D ipgre_tap_bridge_get(tunnel, addr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0So maybe you want __ipgre_tap_bridge_get(t=
unnel, addr); here ?
>
Hmmm.. I am sorry, I am maybe not that expert on C coding, as most of
the codes were copied from linux bridge code. Can you give me a hint
how should I change that?

>> + =C2=A0 =C2=A0 if (entry =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return entry->raddr;
>> +}
>> +
>> +
>> +static inline struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
>> + =C2=A0 =C2=A0 struct hlist_head *head,
>> + =C2=A0 =C2=A0 const unsigned char *addr)
>> +{
>> + =C2=A0 =C2=A0 struct hlist_node *h;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 hlist_for_each_entry_rcu(entry, h, head, hlist) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!compare_ether_addr(=
entry->addr.addr, addr))
>
>
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return entry;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>> +int ipgre_tap_bridge_init(void)
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
>> +void ipgre_tap_bridge_cleanup(unsigned long _data)
>> +{
>> + =C2=A0 =C2=A0 struct ip_tunnel *tunnel =3D (struct ip_tunnel *)_da=
ta;
>> + =C2=A0 =C2=A0 unsigned long delay =3D tunnel->ageing_time;
>> + =C2=A0 =C2=A0 unsigned long next_timer =3D jiffies + tunnel->agein=
g_time;
>> + =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 spin_lock_bh(&tunnel->hash_lock);
>
> Since you are called from timer, no need to use _bh() variant.
again copied structure from linux bridge code
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&tunnel->hash_lock);
>
>> + =C2=A0 =C2=A0 for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ipgre_tap_bridge_=
entry *entry;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hlist_node *h, *n=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hlist_for_each_entry_saf=
e(entry, h, n,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 &tunnel->hash[i], hlist)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 unsigned long this_timer;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 this_timer =3D entry->ageing_timer + delay;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (time_before_eq(this_timer, jiffies))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ipgre_tap_bridge_delete(entry);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 else if (time_before(this_timer, next_timer))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 next_timer =3D this_timer;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 spin_unlock_bh(&tunnel->hash_lock);
>> + =C2=A0 =C2=A0 mod_timer(&tunnel->gc_timer, round_jiffies(next_time=
r + HZ/4));
>
> wow... why setup a 250 ms timer, if entries are valid 300 seconds ?
no idea, it was in original linux bridge code
>
>
>
>> +}
>> +
>> +void ipgre_tap_bridge_flush(struct ip_tunnel *tunnel)
>> +{
>> + =C2=A0 =C2=A0 int i;
>> + =C2=A0 =C2=A0 spin_lock_bh(&tunnel->hash_lock);
>> + =C2=A0 =C2=A0 for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ipgre_tap_bridge_=
entry *entry;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct hlist_node *h, *n=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hlist_for_each_entry_saf=
e(entry, h, n,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 &tunnel->hash[i], hlist)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ipgre_tap_bridge_delete(entry);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 spin_unlock_bh(&tunnel->hash_lock);
>> +}
>> +
>> +#endif
>> +
>> =C2=A0/* Tunnel hash table */
>>
>> =C2=A0/*
>> @@ -563,6 +761,13 @@ static int ipgre_rcv(struct sk_buff *skb
>> =C2=A0 =C2=A0 =C2=A0 int =C2=A0 =C2=A0offset =3D 4;
>> =C2=A0 =C2=A0 =C2=A0 __be16 gre_proto;
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 u32 orig_source;
>> + =C2=A0 =C2=A0 struct hlist_head *head;
>> + =C2=A0 =C2=A0 struct ipgre_tap_bridge_entry *entry;
>> + =C2=A0 =C2=A0 struct ethhdr *tethhdr;
>> +#endif
>> +
>> =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pull(skb, 16))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto drop_nolock;
>>
>> @@ -659,10 +864,38 @@ static int ipgre_rcv(struct sk_buff *skb
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
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((tethhdr->h_source[0]&1) =3D=3D 0) =
{
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!is_multicast_ether_addr(tethhdr->h_so=
urce)) ?
>
fixed

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
pgre_tap_bridge_find(head,
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
 =C2=A0 =C2=A0 entry->ageing_timer =3D jiffies;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 spin_lock(&tunnel->hash_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 if (!ipgre_tap_bridge_find(head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tethhdr->h_source))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ipgre_tap_bridge_create(
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0head,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0orig_source,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tethhdr->h_source,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tunnel->dev);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 spin_unlock(&tunnel->hash_lock);
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
>> @@ -716,7 +949,17 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tiph =3D &tunnel->p=
arms.iph;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 if ((dev->type =3D=3D ARPHRD_ETHER) && ipv4_is_multi=
cast(
>
> please format like this :
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((dev->type =3D=3D ARPHRD_ETHER) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ipv4_is_multicast(tunnel->pa=
rms.iph.daddr))
>
fixed

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tunnel->parms.iph.daddr)=
)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst =3D ipgre_tap_bridge=
_get_raddr(tunnel,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ((struct ethhdr *)skb->data)->h_dest);
>> + =C2=A0 =C2=A0 if (dst =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst =3D tiph->daddr;
>> + =C2=A0 =C2=A0 if (dst =3D=3D 0) {
>> +#else
>> =C2=A0 =C2=A0 =C2=A0 if ((dst =3D tiph->daddr) =3D=3D 0) {
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* NBMA tunnel */
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (skb_dst(skb) =3D=
=3D NULL) {
>> @@ -1209,6 +1452,16 @@ static int ipgre_open(struct net_device
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -EADDRNOTAVAIL;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 t->mlink =3D dev->i=
findex;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip_mc_inc_group(__i=
n_dev_get_rtnl(dev), t->parms.iph.daddr);
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (t->dev->type =3D=3D =
ARPHRD_ETHER) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 INIT_HLIST_HEAD(t->hash);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 spin_lock_init(&t->hash_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 t->ageing_time =3D 300 * HZ;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 setup_timer(&t->gc_timer, ipgre_tap_bridge_cleanup,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (unsigned long) t);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 mod_timer(&t->gc_timer, jiffies + t->ageing_time);
>
>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>> @@ -1219,6 +1472,12 @@ static int ipgre_close(struct net_device
>>
>> =C2=A0 =C2=A0 =C2=A0 if (ipv4_is_multicast(t->parms.iph.daddr) && t-=
>mlink) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct in_device *i=
n_dev;
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (t->dev->type =3D=3D =
ARPHRD_ETHER) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ipgre_tap_bridge_flush(t);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 del_timer_sync(&t->gc_timer);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 in_dev =3D inetdev_=
by_index(dev_net(dev), t->mlink);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (in_dev)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ip_mc_dec_group(in_dev, t->parms.iph.daddr);
>> @@ -1341,6 +1600,12 @@ static int __net_init ipgre_init_net(str
>> =C2=A0 =C2=A0 =C2=A0 struct ipgre_net *ign =3D net_generic(net, ipgr=
e_net_id);
>> =C2=A0 =C2=A0 =C2=A0 int err;
>>
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 err =3D ipgre_tap_bridge_init();
>> + =C2=A0 =C2=A0 if (err)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out;
>> +#endif
>> +
>> =C2=A0 =C2=A0 =C2=A0 ign->fb_tunnel_dev =3D alloc_netdev(sizeof(stru=
ct ip_tunnel), "gre0",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0ipgre_tunnel_setup);
>> =C2=A0 =C2=A0 =C2=A0 if (!ign->fb_tunnel_dev) {
>> @@ -1362,6 +1627,10 @@ static int __net_init ipgre_init_net(str
>> =C2=A0err_reg_dev:
>> =C2=A0 =C2=A0 =C2=A0 ipgre_dev_free(ign->fb_tunnel_dev);
>> =C2=A0err_alloc_dev:
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 ipgre_tap_bridge_fini();
>> +err_out:
>> +#endif
>> =C2=A0 =C2=A0 =C2=A0 return err;
>> =C2=A0}
>>
>> @@ -1375,6 +1644,9 @@ static void __net_exit ipgre_exit_net(st
>> =C2=A0 =C2=A0 =C2=A0 ipgre_destroy_tunnels(ign, &list);
>> =C2=A0 =C2=A0 =C2=A0 unregister_netdevice_many(&list);
>> =C2=A0 =C2=A0 =C2=A0 rtnl_unlock();
>> +#ifdef CONFIG_NET_IPGRE_BRIDGE
>> + =C2=A0 =C2=A0 ipgre_tap_bridge_fini();
>> +#endif
>> =C2=A0}
>>
>> =C2=A0static struct pernet_operations ipgre_net_ops =3D {
>>
>
>



--=20
Stefan Gula
CCNP, CCIP
