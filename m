From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 02/20] net-ipv4: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:07 -0700
Message-ID: <1302050665-10460-3-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54000 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab1DFAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:52 -0400
In-Reply-To: <1302050665-10460-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv4/ip_gre.c                  |    6 +++---
 net/ipv4/ip_output.c               |   12 ++++++------
 net/ipv4/ipip.c                    |    4 ++--
 net/ipv4/ipmr.c                    |    2 +-
 net/ipv4/netfilter/nf_nat_helper.c |    2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index da5941f..e358cbf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1260,7 +1260,7 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 
@@ -1506,7 +1506,7 @@ static void ipgre_tap_setup(struct net_device *dev)
 	dev->destructor 	= ipgre_dev_free;
 
 	dev->iflink		= 0;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
@@ -1533,7 +1533,7 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nla
 
 	/* Can use a lockless transmit, unless we generate output sequences */
 	if (!(nt->parms.o_flags & GRE_SEQ))
-		dev->features |= NETIF_F_LLTX;
+		dev->legacy_features |= NETIF_F_LLTX;
 
 	err = register_netdevice(dev);
 	if (err)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 86a2843..cb83f7f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -816,7 +816,7 @@ static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
 	 */
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
-	    rt->dst.dev->features & NETIF_F_V4_CSUM &&
+	    rt->dst.dev->legacy_features & NETIF_F_V4_CSUM &&
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
@@ -825,7 +825,7 @@ static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
 	cork->length += length;
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO)) {
+	    (rt->dst.dev->legacy_features & NETIF_F_UFO)) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
 					 mtu, flags);
@@ -873,7 +873,7 @@ alloc_new_skb:
 			fraglen = datalen + fragheaderlen;
 
 			if ((flags & MSG_MORE) &&
-			    !(rt->dst.dev->features&NETIF_F_SG))
+			    !(rt->dst.dev->legacy_features & NETIF_F_SG))
 				alloclen = mtu;
 			else
 				alloclen = fraglen;
@@ -960,7 +960,7 @@ alloc_new_skb:
 		if (copy > length)
 			copy = length;
 
-		if (!(rt->dst.dev->features&NETIF_F_SG)) {
+		if (!(rt->dst.dev->legacy_features & NETIF_F_SG)) {
 			unsigned int off;
 
 			off = skb->len;
@@ -1131,7 +1131,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	if (inet->cork.flags & IPCORK_OPT)
 		opt = inet->cork.opt;
 
-	if (!(rt->dst.dev->features&NETIF_F_SG))
+	if (!(rt->dst.dev->legacy_features & NETIF_F_SG))
 		return -EOPNOTSUPP;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);
@@ -1151,7 +1151,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 	inet->cork.length += size;
 	if ((size + skb->len > mtu) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO)) {
+	    (rt->dst.dev->legacy_features & NETIF_F_UFO)) {
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfc17c5..37360d6 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -751,8 +751,8 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-	dev->features		|= NETIF_F_LLTX;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_LLTX;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 1f62eae..f94b754 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -469,7 +469,7 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->netdev_ops		= &reg_vif_netdev_ops,
 	dev->destructor		= free_netdev;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
 }
 
 static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 31427fb..7c4e698 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -160,7 +160,7 @@ static void nf_nat_csum(struct sk_buff *skb, struct iphdr *iph, void *data,
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    skb->dev->features & NETIF_F_V4_CSUM) {
+		    skb->dev->legacy_features & NETIF_F_V4_CSUM) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_headroom(skb) +
 					  skb_network_offset(skb) +
-- 
1.7.3.1

