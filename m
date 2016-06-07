From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net v2] bridge: Fix incorrect re-injection of STP
	packets
Date: Tue, 7 Jun 2016 12:06:58 +0300
Message-ID: <1465290418-8015-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, Florian Westphal <fw@strlen.de>,
	Ido Schimmel <idosch@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, nogahf@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
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

Instead, if STP is enabled and bridge isn't a 802.1ad bridge, then learn
packet's SMAC and inject it back to the Rx path for further processing
by the packet handlers.

The patch also makes netfilter's behavior consistent with regards to
packets destined to the Bridge Group Address, as no hook registered at
LOCAL_IN will ever be called, regardless if STP is enabled or not.

Cc: Florian Westphal <fw@strlen.de>
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Fixes: 8626c56c8279 ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
--
v1->v2:
* Prevent a memory leak and set pskb before returning RX_HANDLER_PASS
(Shmulik L)
* Skip LOCAL_IN hooks
---
 net/bridge/br_input.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1607977..43d2cd8 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -213,8 +213,7 @@ drop:
 }
 EXPORT_SYMBOL_GPL(br_handle_frame_finish);
 
-/* note: already called with rcu_read_lock */
-static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+static void __br_handle_local_finish(struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
@@ -222,6 +221,14 @@ static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_bu
 	/* check if vlan is allowed, to avoid spoofing */
 	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
+}
+
+/* note: already called with rcu_read_lock */
+static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
+
+	__br_handle_local_finish(skb);
 
 	BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
 	br_pass_frame_up(skb);
@@ -274,7 +281,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 			if (p->br->stp_enabled == BR_NO_STP ||
 			    fwd_mask & (1u << dest[5]))
 				goto forward;
-			break;
+			*pskb = skb;
+			__br_handle_local_finish(skb);
+			return RX_HANDLER_PASS;
 
 		case 0x01:	/* IEEE MAC (Pause) */
 			goto drop;
-- 
2.8.2
