From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] bridge: Fix incorrect re-injection of LLDP
	packets
Date: Fri, 22 Jul 2016 14:56:20 +0300
Message-ID: <1469188580-12657-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: John Fastabend <john.fastabend@gmail.com>, yotamg@mellanox.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>,
	Ido Schimmel <idosch@mellanox.com>, jiri@mellanox.com,
	nogahf@mellanox.com, eladr@mellanox.com, ogerlitz@mellanox.com
To: <davem@davemloft.net>, <stephen@networkplumber.org>
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
returns QUEUE or STOLEN verdict") caused LLDP packets arriving through a
bridge port to be re-injected to the Rx path with skb->dev set to the
bridge device, but this breaks the lldpad daemon.

The lldpad daemon opens a packet socket with protocol set to ETH_P_LLDP
for any valid device on the system, which doesn't not include soft
devices such as bridge and VLAN.

Since packet sockets (ptype_base) are processed in the Rx path after the
Rx handler, LLDP packets with skb->dev set to the bridge device never
reach the lldpad daemon.

Fix this by making the bridge's Rx handler re-inject LLDP packets with
RX_HANDLER_PASS, which effectively restores the behaviour prior to the
mentioned commit.

This means netfilter will never receive LLDP packets coming through a
bridge port, as I don't see a way in which we can have okfn() consume
the packet without breaking existing behaviour. I've already carried out
a similar fix for STP packets in commit 56fae404fb2c ("bridge: Fix
incorrect re-injection of STP packets").

Fixes: 8626c56c8279 ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 net/bridge/br_input.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 43d2cd8..28d5ec2 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -288,6 +288,14 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		case 0x01:	/* IEEE MAC (Pause) */
 			goto drop;
 
+		case 0x0E:	/* 802.1AB LLDP */
+			fwd_mask |= p->br->group_fwd_mask;
+			if (fwd_mask & (1u << dest[5]))
+				goto forward;
+			*pskb = skb;
+			__br_handle_local_finish(skb);
+			return RX_HANDLER_PASS;
+
 		default:
 			/* Allow selective forwarding for most other protocols */
 			fwd_mask |= p->br->group_fwd_mask;
-- 
2.8.2
