From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 11:47:56 +0100
Message-ID: <1326797276.2259.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
	 <1326745733.2564.14.camel@edumazet-laptop>
	 <CAGsizz+2nH+Sx+7TjZwEeKBiHbio0BxoN7CgT4Sspp0EzRN6Ug@mail.gmail.com>
	 <1326775643.2564.36.camel@edumazet-laptop>
	 <CAGsizz+kgBB9APmU9dPExkGQvPUVa3m6qz3NvSguPYNuJQQ_7Q@mail.gmail.com>
	 <1326788970.2564.52.camel@edumazet-laptop>
	 <CAGsizzLwCTpuZsZyx24T9WZy1DSJo+rfhDxLsE8UmeZOSxw+mA@mail.gmail.com>
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
In-Reply-To: <CAGsizzLwCTpuZsZyx24T9WZy1DSJo+rfhDxLsE8UmeZOSxw+mA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 janvier 2012 =C3=A0 11:43 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :

> ok maybe I am getting it wrong, but I am little bit stuck here. I
> recheck the original bridge code. The difference I recognize is that
> in bridge code function:
> br_fdb_init() and br_fdb_fini()
> are called from module init and module exit functions:
> br_init and br_deinit
>=20
> in my code they are called from functions:
> ipgre_init_net and ipgre_exit_net
> instead of:
> ipgre_init and ipgre_fini
>=20
> To be honest I am not so familiar enough with kernel structure that I
> see the difference on the first time. But I think that with your help
> it can be done easily. The main idea was to create hash-table that is
> used to determine the destination IPv4 address (part of the entry
> structure). That hash-table should be different per each gretap
> interface - I think that's the reason why I put those init and fini
> inside ipgre_init_net and ipgre_exit_net. Am I right that the
> placement of this calls is correct or not? If not where those calls
> should be placed?
>=20
> On the other hand I have no idea how to substitute those two function
> with a code that you are suggesting kmalloc()/kfree(). I would be gla=
d
> if you can help me here by providing me example how to substitute
> those two functions with kmalloc/kfree for the future usage (I am mor=
e
> reverse engineer learner type of person than manuals reading one)

Something like the following ?


Note : I also put the "orig_source =3D iph->saddr;"
_after_ "iph =3D ip_hdr(skb);"

 			iph =3D ip_hdr(skb);
#ifdef CONFIG_NET_IPGRE_BRIDGE
			orig_source =3D iph->saddr;
#endif



diff --git a/include/net/ipip.h b/include/net/ipip.h
index a32654d..6a06fc2 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
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
=20
 	struct ip_tunnel_parm	parms;
=20
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 1a8f93b..5b320a3 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
 	  Network), but can be distributed all over the Internet. If you want
 	  to do that, say Y here and to "IP multicast routing" below.
=20
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
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2b53a1f..df22565 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -52,6 +52,11 @@
 #include <net/ip6_route.h>
 #endif
=20
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+#include <linux/jhash.h>
+#include <asm/unaligned.h>
+#endif
+
 /*
    Problems & solutions
    --------------------
@@ -134,6 +139,172 @@ struct ipgre_net {
 	struct net_device *fb_tunnel_dev;
 };
=20
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
+	unsigned long		updated;
+	struct rcu_head		rcu;
+};
+
+static u32 ipgre_salt __read_mostly;
+
+static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
+{
+	u32 key =3D get_unaligned((u32 *)(mac + 2));
+
+	return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_SIZE - 1);
+}
+
+static inline int ipgre_tap_bridge_has_expired(const struct ip_tunnel =
*tunnel,
+				const struct ipgre_tap_bridge_entry *entry)
+{
+	return time_before_eq(entry->updated + tunnel->ageing_time,
+			      jiffies);
+}
+
+static inline void ipgre_tap_bridge_delete(struct ipgre_tap_bridge_ent=
ry *entry)
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
+
+	spin_lock(&tunnel->hash_lock);
+	for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+
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
+
+	spin_lock_bh(&tunnel->hash_lock);
+	for (i =3D 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+
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
+
+	hlist_for_each_entry_rcu(entry, h,
+			&tunnel->hash[ipgre_tap_bridge_hash(addr)], hlist) {
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
+
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
+
+	hlist_for_each_entry_rcu(entry, h, head, hlist) {
+		if (!compare_ether_addr(entry->addr, addr))
+			return entry;
+	}
+	return NULL;
+}
+
+static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
+	struct hlist_head *head,
+	u32 source,
+	const unsigned char *addr)
+{
+	struct ipgre_tap_bridge_entry *entry;
+
+	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (entry) {
+		memcpy(entry->addr, addr, ETH_ALEN);
+		entry->raddr =3D source;
+		entry->updated =3D jiffies;
+		hlist_add_head_rcu(&entry->hlist, head);
+	}
+	return entry;
+}
+
+static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	__be32 raddr =3D 0;
+	struct ipgre_tap_bridge_entry *entry;
+
+	rcu_read_lock();
+	entry =3D __ipgre_tap_bridge_get(tunnel, addr);
+	if (entry)
+		raddr =3D entry->raddr;
+	rcu_read_unlock();
+
+	return raddr;
+}
+
+#endif
 /* Tunnel hash table */
=20
 /*
@@ -562,6 +733,12 @@ static int ipgre_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	int    offset =3D 4;
 	__be16 gre_proto;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	__be32 orig_source;
+	struct hlist_head *head;
+	struct ipgre_tap_bridge_entry *entry;
+	const struct ethhdr *tethhdr;
+#endif
=20
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
@@ -659,10 +836,38 @@ static int ipgre_rcv(struct sk_buff *skb)
 				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
-
 			iph =3D ip_hdr(skb);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			orig_source =3D iph->saddr;
+#endif
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
+							head,
+						 	orig_source,
+						 	tethhdr->h_source);
+					  spin_unlock(&tunnel->hash_lock);
+					}
+				}
+			}
+#endif
 		}
=20
 		tstats =3D this_cpu_ptr(tunnel->dev->tstats);
@@ -702,7 +907,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    gre_hlen;
-	__be32 dst;
+	__be32 dst =3D 0;
 	int    mtu;
=20
 	if (dev->type =3D=3D ARPHRD_ETHER)
@@ -716,7 +921,15 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
 		tiph =3D &tunnel->parms.iph;
 	}
=20
-	if ((dst =3D tiph->daddr) =3D=3D 0) {
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	if ((dev->type =3D=3D ARPHRD_ETHER) &&
+		ipv4_is_multicast(tunnel->parms.iph.daddr))
+		dst =3D ipgre_tap_bridge_get_raddr(tunnel,
+			((struct ethhdr *)skb->data)->h_dest);
+#endif
+	if (dst =3D=3D 0)
+		dst =3D tiph->daddr;
+	if (dst =3D=3D 0) {
 		/* NBMA tunnel */
=20
 		if (skb_dst(skb) =3D=3D NULL) {
@@ -1211,6 +1424,16 @@ static int ipgre_open(struct net_device *dev)
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
@@ -1221,6 +1444,12 @@ static int ipgre_close(struct net_device *dev)
=20
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
@@ -1707,6 +1936,9 @@ static int __init ipgre_init(void)
=20
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
=20
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
+#endif
 	err =3D register_pernet_device(&ipgre_net_ops);
 	if (err < 0)
 		return err;
