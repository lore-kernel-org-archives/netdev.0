From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 4/6] openvswitch: Fix parsing invalid LLC/SNAP
	ethertypes
Date: Thu, 14 Mar 2013 17:15:04 -0700
Message-ID: <1363306506-885-5-git-send-email-jesse@nicira.com>
References: <1363306506-885-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1363306506-885-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Rich Lane <rlane-oPdFNf9WwoK1Z/+hSey0Gg@public.gmane.org>

Before this patch, if an LLC/SNAP packet with OUI 00:00:00 had an
ethertype less than 1536 the flow key given to userspace in the upcall
would contain the invalid ethertype (for example, 3). If userspace
attempted to insert a kernel flow for this key it would be rejected
by ovs_flow_from_nlattrs.

This patch allows OVS to pass the OFTest pktact.DirectBadLlcPackets.

Signed-off-by: Rich Lane <rlane-oPdFNf9WwoK1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c3294ce..0c98d40 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -484,7 +484,11 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 		return htons(ETH_P_802_2);
 
 	__skb_pull(skb, sizeof(struct llc_snap_hdr));
-	return llc->ethertype;
+
+	if (ntohs(llc->ethertype) >= 1536)
+		return llc->ethertype;
+
+	return htons(ETH_P_802_2);
 }
 
 static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
-- 
1.7.10.4
