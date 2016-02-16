From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Subject: [PATCH v2] gre: Avoid kernel panic by clearing IPCB before dst_link_failure called
Date: Tue, 16 Feb 2016 14:10:16 +1300
Message-ID: <1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
References: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, stable@vger.kernel.org,
	bernie.harris@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->cb may contain data from previous layers (in the observed case the
qdisc layer). In the observed scenario, the data was misinterpreted as
ip header options, which later caused the ihl to be set to an invalid
value (<5). This resulted in an infinite loop in the mips implementation
of ip_fast_csum.

This patch clears IPCB before dst_link_failure is called from the functions
ip_tunnel_xmit and ip6gre_xmit2, similar to what commit 11c21a30 does for
an ipv4 case.

Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
---
 net/ipv4/ip_tunnel.c | 1 +
 net/ipv6/ip6_gre.c   | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 89e8861..946091a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -799,6 +799,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 #if IS_ENABLED(CONFIG_IPV6)
 tx_error_icmp:
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	dst_link_failure(skb);
 #endif
 tx_error:
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f37f18b..93fc6f9 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -678,6 +678,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 
+			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			dst_link_failure(skb);
 		} else
 			tunnel->err_count = 0;
@@ -761,6 +762,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	dst_link_failure(skb);
 tx_err_dst_release:
 	dst_release(dst);
-- 
2.7.1
