From: William Tu <u9012063@gmail.com>
Subject: [net-next 3/3] ip_gre: cache the device mtu hard_header_len calc
Date: Mon,  9 Oct 2017 13:47:47 -0700
Message-ID: <1507582067-36718-4-git-send-email-u9012063@gmail.com>
References: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38103 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754755AbdJIUsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 16:48:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id a7so30359421pfj.5
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 13:48:05 -0700 (PDT)
In-Reply-To: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch introduces ip_tunnel->ether_mtu fields to cache the value of
dev->mtu + dev->hard_header_len.  This avoids the arithmetic operation
on every packet.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
---
 include/net/ip_tunnels.h | 1 +
 net/ipv4/ip_gre.c        | 8 ++++----
 net/ipv4/ip_tunnel.c     | 3 +++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index b41a1e057fce..19565be26e13 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -117,6 +117,7 @@ struct ip_tunnel {
 
 	/* This field used only by ERSPAN */
 	u32		index;		/* ERSPAN type II index */
+	unsigned int	ether_mtu;	/* The mtu including the ether hdr */
 
 	struct dst_cache dst_cache;
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e6e4c4811cc..994b8ddea0b1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -578,8 +578,8 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	if (gre_handle_offloads(skb, false))
 		goto err_free_rt;
 
-	if (skb->len > dev->mtu + dev->hard_header_len) {
-		pskb_trim(skb, dev->mtu + dev->hard_header_len);
+	if (skb->len > tunnel->ether_mtu) {
+		pskb_trim(skb, tunnel->ether_mtu);
 		truncate = true;
 	}
 
@@ -730,8 +730,8 @@ static netdev_tx_t erspan_xmit(struct sk_buff *skb,
 	if (skb_cow_head(skb, dev->needed_headroom))
 		goto free_skb;
 
-	if (skb->len > dev->mtu + dev->hard_header_len) {
-		pskb_trim(skb, dev->mtu + dev->hard_header_len);
+	if (skb->len > tunnel->ether_mtu) {
+		pskb_trim(skb, tunnel->ether_mtu);
 		truncate = true;
 	}
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fe6fee728ce4..859af5b86802 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -348,6 +348,7 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 
 	dev->needed_headroom = t_hlen + hlen;
 	mtu -= (dev->hard_header_len + t_hlen);
+	tunnel->ether_mtu = mtu + dev->hard_header_len;
 
 	if (mtu < 68)
 		mtu = 68;
@@ -952,6 +953,7 @@ int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict)
 	}
 
 	dev->mtu = new_mtu;
+	tunnel->ether_mtu = new_mtu + dev->hard_header_len;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__ip_tunnel_change_mtu);
@@ -1183,6 +1185,7 @@ int ip_tunnel_init(struct net_device *dev)
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
+	tunnel->ether_mtu = dev->mtu + dev->hard_header_len;
 	strcpy(tunnel->parms.name, dev->name);
 	iph->version		= 4;
 	iph->ihl		= 5;
-- 
2.7.4
