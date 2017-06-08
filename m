From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Thu,  8 Jun 2017 08:57:55 +0800
Message-ID: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
To: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
skb_dst_set to begin and tun_dst would be freed by kfree_skb.

CC: Pravin B Shelar <pshelar@nicira.com>
Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
---
 net/ipv4/ip_tunnel.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b878ecb..27fc20f 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -386,6 +386,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	const struct iphdr *iph = ip_hdr(skb);
 	int err;
 
+	if (tun_dst)
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(iph->daddr)) {
 		tunnel->dev->stats.multicast++;
@@ -439,9 +442,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
-	if (tun_dst)
-		skb_dst_set(skb, (struct dst_entry *)tun_dst);
-
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
-- 
1.8.3.1
