From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] gre: Add Transparent Ethernet Bridging
Date: Thu, 09 Oct 2008 15:05:28 +0800
Message-ID: <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53913 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525AbYJIHFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre: Add Transparent Ethernet Bridging

This patch adds support for Ethernet over GRE encapsulation.
This is exposed to user-space with a new link type of "gretap"
instead of "gre".  It will create an ARPHRD_ETHER device in
lieu of the usual ARPHRD_IPGRE.

Note that to preserver backwards compatibility all Transparent
Ethernet Bridging packets are passed to an ARPHRD_IPGRE tunnel
if its key matches and there is no ARPHRD_ETHER device whose
key matches more closely.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/if_ether.h |    1 
 net/ipv4/ip_gre.c        |  195 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 164 insertions(+), 32 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index e157c13..56f9039 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -56,6 +56,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_TEB	0x6558		/* Trans Ether Bridging		*/
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 25d2c77..bc462ee 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -27,6 +27,7 @@
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 
 #include <net/sock.h>
@@ -166,38 +167,64 @@ static DEFINE_RWLOCK(ipgre_lock);
 /* Given src, dst and key, find appropriate for input tunnel. */
 
 static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
-		__be32 remote, __be32 local, __be32 key)
+					      __be32 remote, __be32 local,
+					      __be32 key, __be16 gre_proto)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(key);
 	struct ip_tunnel *t;
+	struct ip_tunnel *t2 = NULL;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
+		       ARPHRD_ETHER : ARPHRD_IPGRE;
 
 	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
-				return t;
+			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
+				if (t->dev->type == dev_type)
+					return t;
+				if (t->dev->type == ARPHRD_IPGRE && !t2)
+					t2 = t;
+			}
 		}
 	}
+
 	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
 		if (remote == t->parms.iph.daddr) {
-			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
-				return t;
+			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
+				if (t->dev->type == dev_type)
+					return t;
+				if (t->dev->type == ARPHRD_IPGRE && !t2)
+					t2 = t;
+			}
 		}
 	}
+
 	for (t = ign->tunnels_l[h1]; t; t = t->next) {
 		if (local == t->parms.iph.saddr ||
 		     (local == t->parms.iph.daddr &&
 		      ipv4_is_multicast(local))) {
-			if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
-				return t;
+			if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
+				if (t->dev->type == dev_type)
+					return t;
+				if (t->dev->type == ARPHRD_IPGRE && !t2)
+					t2 = t;
+			}
 		}
 	}
+
 	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
-		if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
-			return t;
+		if (t->parms.i_key == key && t->dev->flags & IFF_UP) {
+			if (t->dev->type == dev_type)
+				return t;
+			if (t->dev->type == ARPHRD_IPGRE && !t2)
+				t2 = t;
+		}
 	}
 
+	if (t2)
+		return t2;
+
 	if (ign->fb_tunnel_dev->flags&IFF_UP)
 		return netdev_priv(ign->fb_tunnel_dev);
 	return NULL;
@@ -252,25 +279,37 @@ static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
 	}
 }
 
-static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
-		struct ip_tunnel_parm *parms, int create)
+static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
+					   struct ip_tunnel_parm *parms,
+					   int type)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	__be32 key = parms->i_key;
-	struct ip_tunnel *t, **tp, *nt;
+	struct ip_tunnel *t, **tp;
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+
+	for (tp = __ipgre_bucket(ign, parms); (t = *tp) != NULL; tp = &t->next)
+		if (local == t->parms.iph.saddr &&
+		    remote == t->parms.iph.daddr &&
+		    key == t->parms.i_key &&
+		    type == t->dev->type)
+			break;
+
+	return t;
+}
+
+static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
+		struct ip_tunnel_parm *parms, int create)
+{
+	struct ip_tunnel *t, *nt;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
-	for (tp = __ipgre_bucket(ign, parms); (t = *tp) != NULL; tp = &t->next) {
-		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
-			if (key == t->parms.i_key)
-				return t;
-		}
-	}
-	if (!create)
-		return NULL;
+	t = ipgre_tunnel_find(net, parms, ARPHRD_IPGRE);
+	if (t || !create)
+		return t;
 
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
@@ -385,8 +424,9 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 
 	read_lock(&ipgre_lock);
 	t = ipgre_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr,
-			(flags&GRE_KEY) ?
-			*(((__be32*)p) + (grehlen>>2) - 1) : 0);
+				flags & GRE_KEY ?
+				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
+				p[1]);
 	if (t == NULL || t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
 		goto out;
@@ -436,6 +476,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	u32    seqno = 0;
 	struct ip_tunnel *tunnel;
 	int    offset = 4;
+	__be16 gre_proto;
 
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
@@ -475,20 +516,22 @@ static int ipgre_rcv(struct sk_buff *skb)
 		}
 	}
 
+	gre_proto = *(__be16 *)(h + 2);
+
 	read_lock(&ipgre_lock);
 	if ((tunnel = ipgre_tunnel_lookup(dev_net(skb->dev),
-					iph->saddr, iph->daddr, key)) != NULL) {
+					  iph->saddr, iph->daddr, key,
+					  gre_proto))) {
 		struct net_device_stats *stats = &tunnel->dev->stats;
 
 		secpath_reset(skb);
 
-		skb->protocol = *(__be16*)(h + 2);
+		skb->protocol = gre_proto;
 		/* WCCP version 1 and 2 protocol decoding.
 		 * - Change protocol to IP
 		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
 		 */
-		if (flags == 0 &&
-		    skb->protocol == htons(ETH_P_WCCP)) {
+		if (flags == 0 && gre_proto == htons(ETH_P_WCCP)) {
 			skb->protocol = htons(ETH_P_IP);
 			if ((*(h + offset) & 0xF0) != 0x40)
 				offset += 4;
@@ -496,7 +539,6 @@ static int ipgre_rcv(struct sk_buff *skb)
 
 		skb->mac_header = skb->network_header;
 		__pskb_pull(skb, offset);
-		skb_reset_network_header(skb);
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
@@ -530,7 +572,13 @@ static int ipgre_rcv(struct sk_buff *skb)
 		dst_release(skb->dst);
 		skb->dst = NULL;
 		nf_reset(skb);
+
+		if (tunnel->dev->type == ARPHRD_ETHER)
+			skb->protocol = eth_type_trans(skb, skb->dev);
+
+		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
+
 		netif_rx(skb);
 		read_unlock(&ipgre_lock);
 		return(0);
@@ -565,7 +613,10 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_error;
 	}
 
-	if (dev->header_ops) {
+	if (dev->type == ARPHRD_ETHER)
+		IPCB(skb)->flags = 0;
+
+	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
 		gre_hlen = 0;
 		tiph = (struct iphdr*)skb->data;
 	} else {
@@ -741,8 +792,9 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
 	}
 
-	((__be16*)(iph+1))[0] = tunnel->parms.o_flags;
-	((__be16*)(iph+1))[1] = skb->protocol;
+	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
+	((__be16 *)(iph + 1))[1] = (dev->type == ARPHRD_ETHER) ?
+				   htons(ETH_P_TEB) : skb->protocol;
 
 	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
 		__be32 *ptr = (__be32*)(((u8*)iph) + tunnel->hlen - 4);
@@ -804,7 +856,9 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
-		dev->flags |= IFF_POINTOPOINT;
+
+		if (dev->type != ARPHRD_ETHER)
+			dev->flags |= IFF_POINTOPOINT;
 	}
 
 	if (!tdev && tunnel->parms.link)
@@ -1250,6 +1304,30 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	__be32 daddr;
+
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+
+	if (!data)
+		goto out;
+
+	if (data[IFLA_GRE_REMOTE]) {
+		memcpy(&daddr, nla_data(data[IFLA_GRE_REMOTE]), 4);
+		if (!daddr)
+			return -EINVAL;
+	}
+
+out:
+	return ipgre_tunnel_validate(tb, data);
+}
+
 static void ipgre_netlink_parms(struct nlattr *data[],
 				struct ip_tunnel_parm *parms)
 {
@@ -1291,6 +1369,35 @@ static void ipgre_netlink_parms(struct nlattr *data[],
 		parms->iph.frag_off = htons(IP_DF);
 }
 
+static int ipgre_tap_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel;
+
+	tunnel = netdev_priv(dev);
+
+	tunnel->dev = dev;
+	strcpy(tunnel->parms.name, dev->name);
+
+	ipgre_tunnel_bind_dev(dev);
+
+	return 0;
+}
+
+static void ipgre_tap_setup(struct net_device *dev)
+{
+
+	ether_setup(dev);
+
+	dev->init		= ipgre_tap_init;
+	dev->uninit		= ipgre_tunnel_uninit;
+	dev->destructor 	= free_netdev;
+	dev->hard_start_xmit	= ipgre_tunnel_xmit;
+	dev->change_mtu		= ipgre_tunnel_change_mtu;
+
+	dev->iflink		= 0;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
+}
+
 static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[],
 			 struct nlattr *data[])
 {
@@ -1303,9 +1410,12 @@ static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[],
 	nt = netdev_priv(dev);
 	ipgre_netlink_parms(data, &nt->parms);
 
-	if (ipgre_tunnel_locate(net, &nt->parms, 0))
+	if (ipgre_tunnel_find(net, &nt->parms, dev->type))
 		return -EEXIST;
 
+	if (dev->type == ARPHRD_ETHER && !tb[IFLA_ADDRESS])
+		random_ether_addr(dev->dev_addr);
+
 	mtu = ipgre_tunnel_bind_dev(dev);
 	if (!tb[IFLA_MTU])
 		dev->mtu = mtu;
@@ -1455,6 +1565,19 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.fill_info	= ipgre_fill_info,
 };
 
+static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
+	.kind		= "gretap",
+	.maxtype	= IFLA_GRE_MAX,
+	.policy		= ipgre_policy,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.setup		= ipgre_tap_setup,
+	.validate	= ipgre_tap_validate,
+	.newlink	= ipgre_newlink,
+	.changelink	= ipgre_changelink,
+	.get_size	= ipgre_get_size,
+	.fill_info	= ipgre_fill_info,
+};
+
 /*
  *	And now the modules code and kernel interface.
  */
@@ -1478,9 +1601,15 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto rtnl_link_failed;
 
+	err = rtnl_link_register(&ipgre_tap_ops);
+	if (err < 0)
+		goto tap_ops_failed;
+
 out:
 	return err;
 
+tap_ops_failed:
+	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
 	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 gen_device_failed:
@@ -1490,6 +1619,7 @@ gen_device_failed:
 
 static void __exit ipgre_fini(void)
 {
+	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
@@ -1500,3 +1630,4 @@ module_init(ipgre_init);
 module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("rtnl-link-gre");
+MODULE_ALIAS("rtnl-link-gretap");
