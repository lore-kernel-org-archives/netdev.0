From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.50 5/6] datapath: Break out deacceleration
	portion of vlan_push
Date: Fri, 15 Nov 2013 18:10:22 +0900
Message-ID: <1384506623-18503-6-git-send-email-horms@verge.net.au>
References: <1384506623-18503-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1384506623-18503-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Break out deacceleration portion of vlan_push into vlan_put
so that it may be re-used by mpls_push.

For both vlan_push and mpls_push if there is an accelerated VLAN tag
present then it should be deaccelerated, adding it to the data of
the skb, before the new tag is added.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2.41 - v2.50
* No change

v2.40
* As suggested by Jesse Gross
  + Simplify vlan_push by returning an error code
    rather than an error code encoded as a struct xkb_buff *

v2.39
* First post
---
 datapath/actions.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index 30ea1d2..ee2456b 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -105,21 +105,29 @@ static int pop_vlan(struct sk_buff *skb)
 	return 0;
 }
 
-static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
+/* push down current VLAN tag */
+static int put_vlan(struct sk_buff *skb)
 {
-	if (unlikely(vlan_tx_tag_present(skb))) {
-		u16 current_tag;
+	u16 current_tag = vlan_tx_tag_get(skb);
 
-		/* push down current VLAN tag */
-		current_tag = vlan_tx_tag_get(skb);
+	if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
+		return -ENOMEM;
 
-		if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
-			return -ENOMEM;
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(skb->data
+				+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->csum = csum_add(skb->csum, csum_partial(skb->data
-					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
+	return 0;
+}
+
+static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
+{
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		int err;
 
+		err = put_vlan(skb);
+		if (unlikely(err))
+			return err;
 	}
 	__vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 	return 0;
-- 
1.8.4
