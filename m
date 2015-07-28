From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] bridge: Fix network header pointer for vlan
	tagged packets
Date: Tue, 28 Jul 2015 19:05:37 +0900
Message-ID: <1438077937-16134-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

There are several devices that can receive vlan tagged packets with
CHECKSUM_PARTIAL like tap, possibly veth and xennet.
When (multiple) vlan tagged packets with CHECKSUM_PARTIAL are forwarded
by bridge to a device with the IP_CSUM feature, they end up with checksum
error because before entering bridge, the network header is set to
ETH_HLEN (not including vlan header length) in __netif_receive_skb_core(),
get_rps_cpu(), or drivers' rx functions, and nobody fixes the pointer later.

Since the network header is exepected to be ETH_HLEN in flow-dissection
and hash-calculation in RPS in rx path, and since the header pointer fix
is needed only in tx path, set the appropriate network header on forwarding
packets.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_forward.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 0ff6e1b..fa7bfce 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -37,15 +37,30 @@ static inline int should_deliver(const struct net_bridge_port *p,
 
 int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
 {
-	if (!is_skb_forwardable(skb->dev, skb)) {
-		kfree_skb(skb);
-	} else {
-		skb_push(skb, ETH_HLEN);
-		br_drop_fake_rtable(skb);
-		skb_sender_cpu_clear(skb);
-		dev_queue_xmit(skb);
+	if (!is_skb_forwardable(skb->dev, skb))
+		goto drop;
+
+	skb_push(skb, ETH_HLEN);
+	br_drop_fake_rtable(skb);
+	skb_sender_cpu_clear(skb);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    (skb->protocol == htons(ETH_P_8021Q) ||
+	     skb->protocol == htons(ETH_P_8021AD))) {
+		int depth;
+
+		if (!__vlan_get_protocol(skb, skb->protocol, &depth))
+			goto drop;
+
+		skb_set_network_header(skb, depth);
 	}
 
+	dev_queue_xmit(skb);
+
+	return 0;
+
+drop:
+	kfree_skb(skb);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
-- 
1.8.1.2
