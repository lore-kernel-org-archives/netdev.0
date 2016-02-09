From: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Subject: [PATCH] ip6_gre: clear IPCB in ip6gre_xmit2 in case dst_link_failure called
Date: Tue,  9 Feb 2016 17:07:54 +1300
Message-ID: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, stable@vger.kernel.org,
	bernie.harris@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb->cb may contain data from previous layers (in the observed case the
qdisc layer). In the observed scenario, the data was misinterpreted as
ip header options, which later caused the ihl to be set to an invalid
value (<5). This resulted in an infinite loop in the mips implementation
of ip_fast_csum.

This patch clears IPCB before dst_link_failure is called, similar to what
commit 11c21a30 does for the ipv4 case.

Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f37f18b..e820345 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -678,6 +678,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 
+			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			dst_link_failure(skb);
 		} else
 			tunnel->err_count = 0;
-- 
2.7.1
