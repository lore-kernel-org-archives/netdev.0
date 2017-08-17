From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Thu, 17 Aug 2017 18:16:39 +0200
Message-ID: <20170817161639.GO773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-2-equinox@diac24.net>
 <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:51056 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752704AbdHQQQm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 12:16:42 -0400
Content-Disposition: inline
In-Reply-To: <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 11:38:06PM +0300, Nikolay Aleksandrov wrote:
> On 16/08/17 20:01, David Lamparter wrote:
> > This implements holding dst metadata information in the bridge layer,
> > but only for unicast entries in the MAC table.  Multicast is still left
> > to design and implement.
> > 
> > Signed-off-by: David Lamparter <equinox@diac24.net>
> > ---
> 
> Hi David,
> Sorry but I do not agree with this change, adding a special case for VPLS

To prove that this is not a special case for VPLS, I have attached a
patch for GRETAP multicast+unicast learning below.

It's just 24(!) lines added to get functionality similar to "basic
VXLAN" (i.e. multicast with dataplane learning.)


-David

---
From: David Lamparter <equinox@diac24.net>
Date: Thu, 17 Aug 2017 18:11:16 +0200
Subject: [PATCH] gretap: support multicast + unicast learning

This enables using an IPv4 multicast destination for gretap and enables
learning unicast destinations through the bridge fdb.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 net/ipv4/ip_gre.c    | 27 +++++++++++++++++++++++----
 net/ipv4/ip_tunnel.c |  1 +
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7a7829e839c2..e58f8ccb2c87 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -266,7 +266,8 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			skb_pop_mac_header(skb);
 		else
 			skb_reset_mac_header(skb);
-		if (tunnel->collect_md) {
+		if (tunnel->collect_md
+		    || ipv4_is_multicast(tunnel->parms.iph.daddr)) {
 			__be16 flags;
 			__be64 tun_id;
 
@@ -379,7 +380,7 @@ static struct rtable *gre_get_rt(struct sk_buff *skb,
 static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 			__be16 proto)
 {
-	struct ip_tunnel_info *tun_info;
+	struct ip_tunnel_info *tun_info, flipped;
 	const struct ip_tunnel_key *key;
 	struct rtable *rt = NULL;
 	struct flowi4 fl;
@@ -390,10 +391,22 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	int err;
 
 	tun_info = skb_tunnel_info(skb);
-	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+	if (unlikely(!tun_info ||
 		     ip_tunnel_info_af(tun_info) != AF_INET))
 		goto err_free_skb;
 
+	if (!(tun_info->mode & IP_TUNNEL_INFO_TX)) {
+		struct ip_tunnel *tunnel = netdev_priv(dev);
+
+		flipped = *tun_info;
+		flipped.mode |= IP_TUNNEL_INFO_TX;
+		flipped.key.u.ipv4.dst = tun_info->key.u.ipv4.src;
+		flipped.key.u.ipv4.src = tunnel->parms.iph.saddr;
+		flipped.key.tp_src = tun_info->key.tp_dst;
+		flipped.key.tp_dst = tun_info->key.tp_src;
+		tun_info = &flipped;
+	}
+
 	key = &tun_info->key;
 	use_cache = ip_tunnel_dst_cache_usable(skb, tun_info);
 	if (use_cache)
@@ -507,8 +520,9 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 
-	if (tunnel->collect_md) {
+	if (tunnel->collect_md || tun_info) {
 		gre_fb_xmit(skb, dev, htons(ETH_P_TEB));
 		return NETDEV_TX_OK;
 	}
@@ -933,6 +947,7 @@ static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netif_keep_dst(dev);
 
 	return ip_tunnel_init(dev);
 }
@@ -940,6 +955,10 @@ static int gre_tap_init(struct net_device *dev)
 static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_init		= gre_tap_init,
 	.ndo_uninit		= ip_tunnel_uninit,
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	.ndo_open		= ipgre_open,
+	.ndo_stop		= ipgre_close,
+#endif
 	.ndo_start_xmit		= gre_tap_xmit,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 129d1a3616f8..451c11fc9ae5 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -140,6 +140,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
 		if ((local != t->parms.iph.saddr || t->parms.iph.daddr != 0) &&
+		    (local != t->parms.iph.saddr || !ipv4_is_multicast(t->parms.iph.daddr)) &&
 		    (local != t->parms.iph.daddr || !ipv4_is_multicast(local)))
 			continue;
 
-- 
2.13.0
