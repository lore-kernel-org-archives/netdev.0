From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 11/12] openvswitch: Use TCP flags in the
	flow key for stats.
Date: Fri, 16 May 2014 14:07:38 -0700
Message-ID: <1400274459-56304-12-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400274459-56304-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

We already extract the TCP flags for the key, might as well use that
for stats.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Acked-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 432f04d..e0fc12b 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -69,14 +69,12 @@ void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 
 	stats = rcu_dereference(flow->stats[node]);
 
-	if ((flow->key.eth.type == htons(ETH_P_IP) ||
-	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
-	    flow->key.ip.frag != OVS_FRAG_TYPE_LATER &&
-	    flow->key.ip.proto == IPPROTO_TCP &&
-	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
-		tcp_flags = TCP_FLAGS_BE16(tcp_hdr(skb));
+	if (likely(flow->key.ip.proto == IPPROTO_TCP)) {
+		if (likely(flow->key.eth.type == htons(ETH_P_IP)))
+			tcp_flags = flow->key.ipv4.tp.flags;
+		else if (likely(flow->key.eth.type == htons(ETH_P_IPV6)))
+			tcp_flags = flow->key.ipv6.tp.flags;
 	}
-
 	/* Check if already have node-specific stats. */
 	if (likely(stats)) {
 		spin_lock(&stats->lock);
-- 
1.9.1
