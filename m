From: Stefan Gula <steweg@ynet.sk>
Subject: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 31 Jan 2012 14:21:51 +0100 (CET)
Message-ID: <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
References: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@gmail.com>

This patch is an extension for current Ethernet over GRE
implementation, which allows user to create virtual bridge (multipoint
VPN) and forward traffic based on Ethernet MAC address information in
it. It simulates the Bridge behavior learning mechanism, but instead
of learning port ID from which given MAC address comes, it learns IP
address of peer which encapsulated given packet. Multicast, Broadcast
and unknown-multicast traffic is send over network as multicast
encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
represented as one single virtual switch on logical level and be also
represented as one multicast IPv4 address on network level.

Signed-off-by: Stefan Gula <steweg@gmail.com>


---

V6&7 changes: 
  - added "[no]bridge" netlink option to enable or disable the behavior 
    based on configuration rather then using only kernel option. Example
    of such link creation:
    ip link add VPN1 type gretap local 10.1.1.1 remote 239.192.0.1 key
    12345 ttl 5 nopmtu bridge
    - Default value is "nobridge"
    - This provides backward compatibility with any previous installations
  - run flush function after interface moved from "bridge" to "nobridge"
    behavior

Before you decline this please consider the things below:
Reasons for adding this to kernel directly instead of openvswitch code:
  - neither NVGRE nor VXLAN are part of the openvswitch for now
  - NVGRE is even not yet fully standardized. Missing info how the mapping table will
    be build -> new RFC is expected for this
  - VXLAN uses always header of size 16B (8B VXLAN header + 8B UDP header)
  - openvswitch doesn't implement ebtables/arptables/iptables rules
    properly, so if one wanted to use this in combinations it needs
    original bridge code, which would be somehow connected to openvswitch
     - e.g. using veth module between them
    This brings 3 lookups (original bridge, openvswitch bridge and gre
    internal bridge) instead of only 2 (original bridge and bridge 
    inside the gretap interface) resulting apparently in non optimal
    performance.
     - e.g. in my scenario linux-based APs uses ebtables, iptables and
       arptables to prevent ARP spoofing, DHCP spoofing, IP spoofing, and
       do some mangling staff like NATting of some mac-addresses...

  - My patch uses headers of size from 8B to 20B (depends on configuration)
    - possible less fragmentation needed in contrast to VXLAN
  - methodology of learning VXLAN and my patch is almost the same - my is
    only missing mapping of inner multicast groups to outside multicast
    addresses. VXLAN relies on controller to define that, my is limited for 
    using only one multicast address for all inner multicasts
  - adding "bridge" keyword make this patch stable and backward compatible
  - fully compatible with any kind of filtering/mangling needed based on
    standard linux network stack (excluding filtering inside the gretap
    bridge itself)

Summary:
  - OpenVswitch is apparently good solution for virtualization deployments
    where network security is done on separate devices or not needed at all,
    but currently lacks several security aspects to be fully ready to 
    replace the original bridge code in non virtualized environments, where
    the boxes implement also network security features like linux based APs.
    I believe that such major changes should be driven by some maintainer of
    openvswitch rather than myself.

Patch V7:

diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/include/linux/if_tunnel.h linux/include/linux/if_tunnel.h
--- linux-3.2.1-orig/include/linux/if_tunnel.h	2012-01-27 13:38:56.000000000 +0000
+++ linux/include/linux/if_tunnel.h	2012-01-30 14:10:01.000000000 +0000
@@ -75,6 +75,7 @@ enum {
 	IFLA_GRE_TTL,
 	IFLA_GRE_TOS,
 	IFLA_GRE_PMTUDISC,
+	IFLA_GRE_BRIDGE,
 	__IFLA_GRE_MAX,
 };
 
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/include/net/ipip.h linux/include/net/ipip.h
--- linux-3.2.1-orig/include/net/ipip.h	2012-01-27 13:38:57.000000000 +0000
+++ linux/include/net/ipip.h	2012-01-30 14:10:01.000000000 +0000
@@ -27,6 +27,15 @@ struct ip_tunnel {
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
+	bool			br_enabled;
+#endif
 
 	struct ip_tunnel_parm	parms;
 
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/net/ipv4/Kconfig linux/net/ipv4/Kconfig
--- linux-3.2.1-orig/net/ipv4/Kconfig	2012-01-27 13:39:00.000000000 +0000
+++ linux/net/ipv4/Kconfig	2012-01-30 14:10:01.000000000 +0000
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
diff -uprN -X linux-3.2.1-orig/Documentation/dontdiff linux-3.2.1-orig/net/ipv4/ip_gre.c linux/net/ipv4/ip_gre.c
--- linux-3.2.1-orig/net/ipv4/ip_gre.c	2012-01-27 13:39:00.000000000 +0000
+++ linux/net/ipv4/ip_gre.c	2012-01-30 15:10:35.000000000 +0000
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
@@ -134,6 +139,203 @@ struct ipgre_net {
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
+	unsigned long		updated;
+	struct rcu_head		rcu;
+};
+
+static u32 ipgre_salt __read_mostly;
+
+static inline int ipgre_tap_bridge_hash(const unsigned char *mac)
+{
+	u32 key = get_unaligned((u32 *)(mac + 2));
+
+	return jhash_1word(key, ipgre_salt) & (GRETAP_BR_HASH_SIZE - 1);
+}
+
+static inline int ipgre_tap_bridge_has_expired(const struct ip_tunnel *tunnel,
+				const struct ipgre_tap_bridge_entry *entry)
+{
+	return time_before_eq(entry->updated + tunnel->ageing_time,
+				jiffies);
+}
+
+static inline void ipgre_tap_bridge_delete(struct ipgre_tap_bridge_entry *entry)
+{
+	hlist_del_rcu(&entry->hlist);
+	kfree_rcu(entry, rcu);
+}
+
+static void ipgre_tap_bridge_cleanup(unsigned long _data)
+{
+	struct ip_tunnel *tunnel = (struct ip_tunnel *)_data;
+	unsigned long delay = tunnel->ageing_time;
+	unsigned long next_timer = jiffies + tunnel->ageing_time;
+	int i;
+
+	spin_lock(&tunnel->hash_lock);
+	for (i = 0; i < GRETAP_BR_HASH_SIZE; i++) {
+		struct ipgre_tap_bridge_entry *entry;
+		struct hlist_node *h, *n;
+
+		hlist_for_each_entry_safe(entry, h, n,
+			&tunnel->hash[i], hlist)
+		{
+			unsigned long this_timer;
+			this_timer = entry->updated + delay;
+			if (time_before_eq(this_timer, jiffies))
+				ipgre_tap_bridge_delete(entry);
+			else if (time_before(this_timer, next_timer))
+				next_timer = this_timer;
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
+	for (i = 0; i < GRETAP_BR_HASH_SIZE; i++) {
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
+	__be32 source,
+	const unsigned char *addr)
+{
+	struct ipgre_tap_bridge_entry *entry;
+
+	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (entry) {
+		memcpy(entry->addr, addr, ETH_ALEN);
+		entry->raddr = source;
+		entry->updated = jiffies;
+		hlist_add_head_rcu(&entry->hlist, head);
+	}
+	return entry;
+}
+
+static __be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
+	const unsigned char *addr)
+{
+	__be32 raddr = 0;
+	struct ipgre_tap_bridge_entry *entry;
+
+	rcu_read_lock();
+	entry = __ipgre_tap_bridge_get(tunnel, addr);
+	if (entry)
+		raddr = entry->raddr;
+	rcu_read_unlock();
+
+	return raddr;
+}
+
+static void ipgre_tap_bridge_rcv(struct ip_tunnel *tunnel,
+	struct sk_buff *skb,
+	__be32 orig_source)
+{
+	const struct ethhdr *tethhdr;
+	struct hlist_head *head;
+	struct ipgre_tap_bridge_entry *entry;
+
+	if (ipv4_is_multicast(tunnel->parms.iph.daddr)) {
+		tethhdr = eth_hdr(skb);
+		if (!is_multicast_ether_addr(
+			tethhdr->h_source)) {
+			head = &tunnel->hash[
+				ipgre_tap_bridge_hash(tethhdr->h_source)];
+			entry = ipgre_tap_bridge_find_rcu(head,
+				tethhdr->h_source);
+			if (likely(entry)) {
+				entry->raddr = orig_source;
+				entry->updated = jiffies;
+			} else {
+				spin_lock(&tunnel->hash_lock);
+				if (!ipgre_tap_bridge_find(head,
+					tethhdr->h_source))
+					ipgre_tap_bridge_create(head,
+						orig_source,
+						tethhdr->h_source);
+				spin_unlock(&tunnel->hash_lock);
+			}
+		}
+	}
+}
+#endif
 /* Tunnel hash table */
 
 /*
@@ -562,6 +764,9 @@ static int ipgre_rcv(struct sk_buff *skb
 	struct ip_tunnel *tunnel;
 	int    offset = 4;
 	__be16 gre_proto;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	__be32 orig_source;
+#endif
 
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
@@ -654,6 +859,9 @@ static int ipgre_rcv(struct sk_buff *skb
 
 		/* Warning: All skb pointers will be invalidated! */
 		if (tunnel->dev->type == ARPHRD_ETHER) {
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			orig_source = iph->saddr;
+#endif
 			if (!pskb_may_pull(skb, ETH_HLEN)) {
 				tunnel->dev->stats.rx_length_errors++;
 				tunnel->dev->stats.rx_errors++;
@@ -663,6 +871,10 @@ static int ipgre_rcv(struct sk_buff *skb
 			iph = ip_hdr(skb);
 			skb->protocol = eth_type_trans(skb, tunnel->dev);
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+			if (tunnel->br_enabled)
+				ipgre_tap_bridge_rcv(tunnel, skb, orig_source);
+#endif
 		}
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
@@ -702,7 +914,7 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int    gre_hlen;
-	__be32 dst;
+	__be32 dst = 0;
 	int    mtu;
 
 	if (dev->type == ARPHRD_ETHER)
@@ -716,7 +928,15 @@ static netdev_tx_t ipgre_tunnel_xmit(str
 		tiph = &tunnel->parms.iph;
 	}
 
-	if ((dst = tiph->daddr) == 0) {
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	if (tunnel->br_enabled && (dev->type == ARPHRD_ETHER) &&
+		ipv4_is_multicast(tunnel->parms.iph.daddr))
+		dst = ipgre_tap_bridge_get_raddr(tunnel,
+			((struct ethhdr *)skb->data)->h_dest);
+#endif
+	if (dst == 0)
+		dst = tiph->daddr;
+	if (dst == 0) {
 		/* NBMA tunnel */
 
 		if (skb_dst(skb) == NULL) {
@@ -1209,6 +1429,16 @@ static int ipgre_open(struct net_device
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
@@ -1219,6 +1449,12 @@ static int ipgre_close(struct net_device
 
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
@@ -1488,6 +1724,10 @@ static int ipgre_tap_init(struct net_dev
 static const struct net_device_ops ipgre_tap_netdev_ops = {
 	.ndo_init		= ipgre_tap_init,
 	.ndo_uninit		= ipgre_tunnel_uninit,
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	.ndo_open		= ipgre_open,
+	.ndo_stop		= ipgre_close,
+#endif
 	.ndo_start_xmit		= ipgre_tunnel_xmit,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1532,6 +1772,13 @@ static int ipgre_newlink(struct net *src
 	/* Can use a lockless transmit, unless we generate output sequences */
 	if (!(nt->parms.o_flags & GRE_SEQ))
 		dev->features |= NETIF_F_LLTX;
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	if (data && (!data[IFLA_GRE_BRIDGE] ||
+		nla_get_u8(data[IFLA_GRE_BRIDGE])))
+		nt->br_enabled = true;
+	else
+		nt->br_enabled = false;
+#endif
 
 	err = register_netdevice(dev);
 	if (err)
@@ -1588,6 +1835,16 @@ static int ipgre_changelink(struct net_d
 			memcpy(dev->dev_addr, &p.iph.saddr, 4);
 			memcpy(dev->broadcast, &p.iph.daddr, 4);
 		}
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		if (data && (!data[IFLA_GRE_BRIDGE] ||
+		    nla_get_u8(data[IFLA_GRE_BRIDGE]))) {
+			t->br_enabled = true;
+		} else {
+			if(t->br_enabled)
+				ipgre_tap_bridge_flush(t);
+			t->br_enabled = false;
+		}
+#endif
 		ipgre_tunnel_link(ign, t);
 		netdev_state_change(dev);
 	}
@@ -1629,8 +1886,12 @@ static size_t ipgre_get_size(const struc
 		nla_total_size(1) +
 		/* IFLA_GRE_TOS */
 		nla_total_size(1) +
-		/* IFLA_GRE_PMTUDISC */
+		/* IFLA_GREPMTUDISC */
 		nla_total_size(1) +
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+		/* IFLA_GRE_BRIDGE */
+		nla_total_size(1) +
+#endif
 		0;
 }
 
@@ -1649,7 +1910,9 @@ static int ipgre_fill_info(struct sk_buf
 	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);
 	NLA_PUT_U8(skb, IFLA_GRE_TOS, p->iph.tos);
 	NLA_PUT_U8(skb, IFLA_GRE_PMTUDISC, !!(p->iph.frag_off & htons(IP_DF)));
-
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	NLA_PUT_U8(skb, IFLA_GRE_BRIDGE, t->br_enabled);
+#endif
 	return 0;
 
 nla_put_failure:
@@ -1667,6 +1930,7 @@ static const struct nla_policy ipgre_pol
 	[IFLA_GRE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GRE_TOS]		= { .type = NLA_U8 },
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
+	[IFLA_GRE_BRIDGE]	= { .type = NLA_U8 },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
@@ -1705,6 +1969,9 @@ static int __init ipgre_init(void)
 
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
 
+#ifdef CONFIG_NET_IPGRE_BRIDGE
+	get_random_bytes(&ipgre_salt, sizeof(ipgre_salt));
+#endif
 	err = register_pernet_device(&ipgre_net_ops);
 	if (err < 0)
 		return err;
