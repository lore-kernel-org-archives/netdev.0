From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 6/7] openvswitch: Check gso_type for
	correct sk_buff in queue_gso_packets().
Date: Fri, 20 Jul 2012 15:26:49 -0700
Message-ID: <1342823210-3308-7-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

At the point where it was used, skb_shinfo(skb)->gso_type referred to a
post-GSO sk_buff.  Thus, it would always be 0.  We want to know the pre-GSO
gso_type, so we need to obtain it before segmenting.

Before this change, the kernel would pass inconsistent data to userspace:
packets for UDP fragments with nonzero offset would be passed along with
flow keys that indicate a zero offset (that is, the flow key for "later"
fragments claimed to be "first" fragments).  This inconsistency tended
to confuse Open vSwitch userspace, causing it to log messages about
"failed to flow_del" the flows with "later" fragments.

Signed-off-by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 670e630..29dbfcb 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -263,6 +263,7 @@ err:
 static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
 			     const struct dp_upcall_info *upcall_info)
 {
+	unsigned short gso_type = skb_shinfo(skb)->gso_type;
 	struct dp_upcall_info later_info;
 	struct sw_flow_key later_key;
 	struct sk_buff *segs, *nskb;
@@ -279,7 +280,7 @@ static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
 		if (err)
 			break;
 
-		if (skb == segs && skb_shinfo(skb)->gso_type & SKB_GSO_UDP) {
+		if (skb == segs && gso_type & SKB_GSO_UDP) {
 			/* The initial flow key extracted by ovs_flow_extract()
 			 * in this case is for a first fragment, so we need to
 			 * properly mark later fragments.
-- 
1.7.9.5
