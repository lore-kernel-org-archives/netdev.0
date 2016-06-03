From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] bridge: Fix incorrect re-injection of STP
	packets
Date: Fri, 3 Jun 2016 12:39:45 +0300
Message-ID: <1464946785-7651-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, Florian Westphal <fw@strlen.de>,
	Ido Schimmel <idosch@mellanox.com>, jiri@mellanox.com,
	nogahf@mellanox.com, eladr@mellanox.com, ogerlitz@mellanox.com
To: <stephen@networkplumber.org>, <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Commit 8626c56c8279 ("bridge: fix potential use-after-free when hook
returns QUEUE or STOLEN verdict") fixed incorrect usage of NF_HOOK's
return value by consuming packets in okfn via br_pass_frame_up().

However, this function re-injects packets to the Rx path with skb->dev
set to the bridge device, which breaks kernel's STP, as all STP packets
appear to originate from the bridge device itself.

Instead, if okfn was called for a packet, make bridge's rx_handler
re-inject it to the Rx path by returning RX_HANDLER_PASS. This is
consistent with previous behavior.

Cc: Florian Westphal <fw@strlen.de>
Fixes: 8626c56c8279 ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 net/bridge/br_input.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1607977..c73ed44 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -223,9 +223,7 @@ static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_bu
 	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
 
-	BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
-	br_pass_frame_up(skb);
-	return 0;
+	return RX_HANDLER_PASS;
 }
 
 /*
@@ -238,6 +236,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 	struct sk_buff *skb = *pskb;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	br_should_route_hook_t *rhook;
+	int err;
 
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return RX_HANDLER_PASS;
@@ -287,8 +286,11 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		}
 
 		/* Deliver packet to local host only */
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
-			NULL, skb, skb->dev, NULL, br_handle_local_finish);
+		err = NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
+			      NULL, skb, skb->dev, NULL,
+			      br_handle_local_finish);
+		if (err == RX_HANDLER_PASS)
+			return RX_HANDLER_PASS;
 		return RX_HANDLER_CONSUMED;
 	}
 
-- 
2.4.3
