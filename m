From: William Tu <u9012063@gmail.com>
Subject: [net-next 2/3] ip_gre: fix erspan tunnel mtu calculation
Date: Mon,  9 Oct 2017 13:47:46 -0700
Message-ID: <1507582067-36718-3-git-send-email-u9012063@gmail.com>
References: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35762 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754188AbdJIUsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 16:48:05 -0400
Received: by mail-pf0-f193.google.com with SMTP id i23so30358057pfi.2
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 13:48:04 -0700 (PDT)
In-Reply-To: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unnecessary -4 and +4 bytes at mtu and headroom calculation.
In addition, erspan uses fixed 8-byte gre header, so add ERSPAN_GREHDR_LEN
macro for better readability.

Now tunnel->hlen = grehdr(8) + erspanhdr(8) = 16 byte.
The mtu should be ETH_DATA_LEN - 16 - iph(20) = 1464.
After the ip_tunnel_bind_dev(), the mtu is adjusted to
1464 - 14 (dev->hard_header_len) = 1450.
The maximum skb->len the erspan tunnel can carry without
being truncated is 1450 + 14 = 1464 byte.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
---
 include/net/erspan.h |  1 +
 net/ipv4/ip_gre.c    | 11 +++++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/erspan.h b/include/net/erspan.h
index ca94fc86865e..e28294e248d0 100644
--- a/include/net/erspan.h
+++ b/include/net/erspan.h
@@ -28,6 +28,7 @@
  */
 
 #define ERSPAN_VERSION	0x1
+#define ERSPAN_GREHDR_LEN 8	/* ERSPAN has fixed 8-byte GRE header */
 
 #define VER_MASK	0xf000
 #define VLAN_MASK	0x0fff
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 286065c35959..6e6e4c4811cc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -569,8 +569,7 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	key = &tun_info->key;
 
-	/* ERSPAN has fixed 8 byte GRE header */
-	tunnel_hlen = 8 + sizeof(struct erspanhdr);
+	tunnel_hlen = ERSPAN_GREHDR_LEN + sizeof(struct erspanhdr);
 
 	rt = prepare_fb_xmit(skb, dev, &fl, tunnel_hlen);
 	if (!rt)
@@ -591,7 +590,7 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	erspan_build_header(skb, tunnel_id_to_key32(key->tun_id),
 			    ntohl(md->index), truncate);
 
-	gre_build_header(skb, 8, TUNNEL_SEQ,
+	gre_build_header(skb, ERSPAN_GREHDR_LEN, TUNNEL_SEQ,
 			 htons(ETH_P_ERSPAN), 0, htonl(tunnel->o_seqno++));
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
@@ -1242,14 +1241,14 @@ static int erspan_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	int t_hlen;
 
-	tunnel->tun_hlen = 8;
+	tunnel->tun_hlen = ERSPAN_GREHDR_LEN;
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
 	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen +
 		       sizeof(struct erspanhdr);
 	t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
-	dev->needed_headroom = LL_MAX_HEADER + t_hlen + 4;
-	dev->mtu = ETH_DATA_LEN - t_hlen - 4;
+	dev->needed_headroom = LL_MAX_HEADER + t_hlen;
+	dev->mtu = ETH_DATA_LEN - t_hlen;
 	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
-- 
2.7.4
