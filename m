From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] openvswitch: Add length check when retrieving
	TCP flags.
Date: Mon,  7 May 2012 18:51:23 -0700
Message-ID: <1336441885-11085-2-git-send-email-jesse@nicira.com>
References: <1336441885-11085-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1336441885-11085-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

When collecting TCP flags we check that the IP header indicates that
a TCP header is present but not that the packet is actually long
enough to contain the header.  This adds a check to prevent reading
off the end of the packet.

In practice, this is only likely to result in reading of bad data and
not a crash due to the presence of struct skb_shared_info at the end
of the packet.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 1252c30..2a11ec2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -183,7 +183,8 @@ void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 	u8 tcp_flags = 0;
 
 	if (flow->key.eth.type == htons(ETH_P_IP) &&
-	    flow->key.ip.proto == IPPROTO_TCP) {
+	    flow->key.ip.proto == IPPROTO_TCP &&
+	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
 		u8 *tcp = (u8 *)tcp_hdr(skb);
 		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
 	}
-- 
1.7.9.5
