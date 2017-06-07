From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed,  7 Jun 2017 22:16:16 +0800
Message-ID: <1496844976-15282-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1496844976-15282-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496844976-15282-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When __ip6_tnl_rcv fails, the tun_dst won't be freed, so move
skb_dst_set to begin and tun_dst would be freed by kfree_skb.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_tunnel.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9b37f97..bf45f1b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -789,6 +789,9 @@ static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	int err;
 
+	if (tun_dst)
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+
 	if ((!(tpi->flags & TUNNEL_CSUM) &&
 	     (tunnel->parms.i_flags & TUNNEL_CSUM)) ||
 	    ((tpi->flags & TUNNEL_CSUM) &&
@@ -852,9 +855,6 @@ static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(tunnel->dev)));
 
-	if (tun_dst)
-		skb_dst_set(skb, (struct dst_entry *)tun_dst);
-
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
-- 
1.8.3.1
