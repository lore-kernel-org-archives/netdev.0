From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Subject: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet multipoint
 GRE over IP
Date: Mon, 16 Jan 2012 13:13:19 +0100
Message-ID: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44737 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab2APMNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 07:13:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Gula <steweg@gmail.com

This patch is an extension for current Ethernet over GRE
implementation, which allows user to create virtual bridge (multipoint
VPN) and forward traffic based on Ethernet MAC address informations in
it. It simulates the Bridge bahaviour learing mechanism, but instead
of learning port ID from which given MAC address comes, it learns IP
address of peer which encapsulated given packet. Multicast, Broadcast
and unknown-multicast traffic is send over network as multicast
enacapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
represented as one single virtual switch on logical level and be also
represented as one multicast IPv4 address on network level.

Signed-off-by: Stefan Gula <steweg@gmail.com>

---

Patch was tested for more than one year in real network infrastructure
consisting of 98 Linux based access-points

diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-my/Documentation/dontdiff
--- linux-3.2.1-orig/Documentation/dontdiff	2012-01-16 12:32:18.000000000 +0100
+++ linux-3.2.1-my/Documentation/dontdiff	2012-01-12 20:42:45.000000000 +0100
@@ -260,5 +260,3 @@ wakeup.lds
 zImage*
 zconf.hash.c
 zoffset.h
-mkpiggy
-mdp
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/include/net/ipip.h linux-3.2.1-my/include/net/ipip.h
--- linux-3.2.1-orig/include/net/ipip.h	2012-01-12 20:42:45.000000000 +0100
+++ linux-3.2.1-my/include/net/ipip.h	2012-01-16 11:17:01.000000000 +0100
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
--- linux-3.2.1-orig/net/ipv4/Kconfig	2012-01-12 20:42:45.000000000 +0100
+++ linux-3.2.1-my/net/ipv4/Kconfig	2012-01-16 12:37:00.000000000 +0100
@@ -211,6 +211,15 @@ config NET_IPGRE_BROADCAST
 	  Network), but can be distributed all over the Internet. If you want
 	  to do that, say Y here and to "IP multicast routing" below.

+config NET_IPGRE_BRIDGE
+	bool "IP: Ethernet over multipoint GRE over IP"
+	depends on IP_MULTICAST && NET_IPGRE && NET_IPGRE_BROADCAST
+	help
+	  Allows you to use multipoint GRE VPN as virtual switch and interconnect
+	  several L2 endpoints over L3 routed infrastructure. It is useful for
+	  creating multipoint L2 VPNs which can be later used inside bridge
+	  interfaces If you want to use. GRE multipoint L2 VPN feature say Y.
+
 config IP_MROUTE
 	bool "IP: multicast routing"
 	depends on IP_MULTICAST
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff
linux-3.2.1-orig/net/ipv4/ip_gre.c linux-3.2.1-my/net/ipv4/ip_gre.c
--- linux-3.2.1-orig/net/ipv4/ip_gre.c	2012-01-12 20:42:45.000000000 +0100
+++ linux-3.2.1-my/net/ipv4/ip_gre.c	2012-01-16 12:29:03.000000000 +0100
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
@@ -134,6 +139,199 @@ struct ipgre_net {
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
+struct mac_addr {
+	unsigned char   addr[6];
+};
+
+struct ipgre_tap_bridge_entry {
+	struct hlist_node	hlist;
+	u32			raddr;
+	struct mac_addr		addr;
+	struct net_device	*dev;
+	struct rcu_head		rcu;
+	atomic_t		use_count;
+	unsigned long		ageing_timer;
+};
+
+static struct kmem_cache *ipgre_tap_bridge_cache __read_mostly;
+static u32 ipgre_salt __read_mostly;
+
+static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
+{
+	u32 key = get_unaligned((u32 *)(mac + 2));
+	return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_SIZE - 1);
+}
+
+static inline int ipgre_tap_bridge_has_expired(const struct ip_tunnel *tunnel,
+		const struct ipgre_tap_bridge_entry *entry)
+{
+	return time_before_eq(entry->ageing_timer + tunnel->ageing_time,
+		jiffies);
+}
+
+static void ipgre_tap_bridge_rcu_free(struct rcu_head *head)
+{
+	struct ipgre_tap_bridge_entry *entry
+		= container_of(head, struct ipgre_tap_bridge_entry, rcu);
+	kmem_cache_free(ipgre_tap_bridge_cache, entry);
+}
+
+void ipgre_tap_bridge_put(struct ipgre_tap_bridge_entry *entry)
+{
+	if (atomic_dec_and_test(&entry->use_count))
+		call_rcu(&entry->rcu, ipgre_tap_bridge_rcu_free);
+}
+
+static inline void ipgre_tap_bridge_delete(struct
ipgre_tap_bridge_entry *entry)
+{
+	hlist_del_rcu(&entry->hlist);
+	ipgre_tap_bridge_put(entry);
+}
+
+static struct ipgre_tap_bridge_entry *ipgre_tap_bridge_create(
+		struct hlist_head *head,
+		u32 source,
+		const unsigned char *addr, struct net_device *dev)
+{
+	struct ipgre_tap_bridge_entry *entry;
+	entry = kmem_cache_alloc(ipgre_tap_bridge_cache, GFP_ATOMIC);
+	if (entry) {
+		memcpy(entry->addr.addr, addr, ETH_ALEN);
+		atomic_set(&entry->use_count, 1);
+		hlist_add_head_rcu(&entry->hlist, head);
+		entry->raddr = source;
+		entry->ageing_timer = jiffies;
+		entry->dev = dev;
+	}
+	return entry;
+}
+
+struct ipgre_tap_bridge_entry *__ipgre_tap_bridge_get(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct ipgre_tap_bridge_entry *entry;
+	hlist_for_each_entry_rcu(entry, h,
+		&tunnel->hash[ipgre_tap_bridge_hash(addr)], hlist)
+	{
+		if (!compare_ether_addr(entry->addr.addr, addr)) {
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
+struct ipgre_tap_bridge_entry *ipgre_tap_bridge_get(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	struct ipgre_tap_bridge_entry *entry;
+	rcu_read_lock();
+	entry = __ipgre_tap_bridge_get(tunnel, addr);
+	if (entry && !atomic_inc_not_zero(&entry->use_count))
+		entry = NULL;
+	rcu_read_unlock();
+	return entry;
+}
+
+__be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	struct ipgre_tap_bridge_entry *entry;
+	entry = ipgre_tap_bridge_get(tunnel, addr);
+	if (entry == NULL)
+		return 0;
+	else
+		return entry->raddr;
+}
+
+
+static inline struct ipgre_tap_bridge_entry *ipgre_tap_bridge_find(
+	struct hlist_head *head,
+	const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct ipgre_tap_bridge_entry *entry;
+	hlist_for_each_entry_rcu(entry, h, head, hlist) {
+		if (!compare_ether_addr(entry->addr.addr, addr))
+			return entry;
+	}
+	return NULL;
+}
+
+int ipgre_tap_bridge_init(void)
+{
+	ipgre_tap_bridge_cache = kmem_cache_create("ipgre_tap_bridge_cache",
+		sizeof(struct ipgre_tap_bridge_entry),
+		0,
+		SLAB_HWCACHE_ALIGN, NULL);
+	if (!ipgre_tap_bridge_cache)
+		return -ENOMEM;
+	get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
+	return 0;
+}
+
+void ipgre_tap_bridge_fini(void)
+{
+	kmem_cache_destroy(ipgre_tap_bridge_cache);
+}
+
+void ipgre_tap_bridge_cleanup(unsigned long _data)
+{
+	struct ip_tunnel *tunnel = (struct ip_tunnel *)_data;
+	unsigned long delay = tunnel->ageing_time;
+	unsigned long next_timer = jiffies + tunnel->ageing_time;
+	int i;
+	spin_lock_bh(&tunnel->hash_lock);
+	for (i = 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+		hlist_for_each_entry_safe(entry, h, n,
+			&tunnel->hash[i], hlist)
+		{
+			unsigned long this_timer;
+			this_timer = entry->ageing_timer + delay;
+			if (time_before_eq(this_timer, jiffies))
+				ipgre_tap_bridge_delete(entry);
+			else if (time_before(this_timer, next_timer))
+				next_timer = this_timer;
+		}
+	}
+	spin_unlock_bh(&tunnel->hash_lock);
+	mod_timer(&tunnel->gc_timer, round_jiffies(next_timer + HZ/4));
+}
+
+void ipgre_tap_bridge_flush(struct ip_tunnel *tunnel)
+{
+	int i;
+	spin_lock_bh(&tunnel->hash_lock);
+	for (i = 0; i < GRETAP_BR_HASH_SIZE; i++) {
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
+#endif
+
 /* Tunnel hash table */

 /*
@@ -563,6 +761,13 @@ static int ipgre_rcv(struct sk_buff *skb
 	int    offset = 4;
 	__be16 gre_proto;

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	u32 orig_source;
+	struct hlist_head *head;
+	struct ipgre_tap_bridge_entry *entry;
+	struct ethhdr *tethhdr;
+#endif
+
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;

@@ -659,10 +864,38 @@ static int ipgre_rcv(struct sk_buff *skb
 				tunnel->dev->stats.rx_errors++;
 				goto drop;
 			}
-
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			orig_source = iph->saddr;
+#endif
 			iph = ip_hdr(skb);
 			skb->protocol = eth_type_trans(skb, tunnel->dev);
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			if (ipv4_is_multicast(tunnel->parms.iph.daddr)) {
+				tethhdr = eth_hdr(skb);
+				if ((tethhdr->h_source[0]&1) == 0) {
+					head = &tunnel->hash[
+						ipgre_tap_bridge_hash(
+							tethhdr->h_source)];
+					entry = ipgre_tap_bridge_find(head,
+						tethhdr->h_source);
+					if (likely(entry)) {
+						entry->raddr = orig_source;
+						entry->ageing_timer = jiffies;
+					} else {
+						spin_lock(&tunnel->hash_lock);
+						if (!ipgre_tap_bridge_find(head,
+							tethhdr->h_source))
+							ipgre_tap_bridge_create(
+							 head,
+							 orig_source,
+							 tethhdr->h_source,
+							 tunnel->dev);
+						spin_unlock(&tunnel->hash_lock);
+					}
+				}
+			}
+#endif
 		}

 		tstats = this_cpu_ptr(tunnel->dev->tstats);
@@ -716,7 +949,17 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 		tiph = &tunnel->parms.iph;
 	}

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	if ((dev->type == ARPHRD_ETHER) && ipv4_is_multicast(
+		tunnel->parms.iph.daddr))
+		dst = ipgre_tap_bridge_get_raddr(tunnel,
+			((struct ethhdr *)skb->data)->h_dest);
+	if (dst == 0)
+		dst = tiph->daddr;
+	if (dst == 0) {
+#else
 	if ((dst = tiph->daddr) == 0) {
+#endif
 		/* NBMA tunnel */

 		if (skb_dst(skb) == NULL) {
@@ -1209,6 +1452,16 @@ static int ipgre_open(struct net_device
 			return -EADDRNOTAVAIL;
 		t->mlink = dev->ifindex;
 		ip_mc_inc_group(__in_dev_get_rtnl(dev), t->parms.iph.daddr);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		if (t->dev->type == ARPHRD_ETHER) {
+			INIT_HLIST_HEAD(t->hash);
+			spin_lock_init(&t->hash_lock);
+			t->ageing_time = 300 * HZ;
+			setup_timer(&t->gc_timer, ipgre_tap_bridge_cleanup,
+				(unsigned long) t);
+			mod_timer(&t->gc_timer, jiffies + t->ageing_time);
+		}
+#endif
 	}
 	return 0;
 }
@@ -1219,6 +1472,12 @@ static int ipgre_close(struct net_device

 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		if (t->dev->type == ARPHRD_ETHER) {
+			ipgre_tap_bridge_flush(t);
+			del_timer_sync(&t->gc_timer);
+		}
+#endif
 		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
 		if (in_dev)
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
@@ -1341,6 +1600,12 @@ static int __net_init ipgre_init_net(str
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int err;

+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	err = ipgre_tap_bridge_init();
+	if (err)
+		goto err_out;
+#endif
+
 	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
 					   ipgre_tunnel_setup);
 	if (!ign->fb_tunnel_dev) {
@@ -1362,6 +1627,10 @@ static int __net_init ipgre_init_net(str
 err_reg_dev:
 	ipgre_dev_free(ign->fb_tunnel_dev);
 err_alloc_dev:
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	ipgre_tap_bridge_fini();
+err_out:
+#endif
 	return err;
 }

@@ -1375,6 +1644,9 @@ static void __net_exit ipgre_exit_net(st
 	ipgre_destroy_tunnels(ign, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	ipgre_tap_bridge_fini();
+#endif
 }

 static struct pernet_operations ipgre_net_ops = {

-- 
Stefan Gula
CCNP, CCIP
