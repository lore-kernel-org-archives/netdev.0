From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.47 3/4] datapath: Break out deacceleration portion of vlan_push
Date: Thu, 31 Oct 2013 16:16:31 +0900
Message-ID: <1383203792-9774-4-git-send-email-horms@verge.net.au>
References: <1383203792-9774-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37970 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab3JaHQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 03:16:37 -0400
In-Reply-To: <1383203792-9774-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Break out deacceleration portion of vlan_push into vlan_put
so that it may be re-used by mpls_push.

For both vlan_push and mpls_push if there is an accelerated VLAN tag
present then it should be deaccelerated, adding it to the data of
the skb, before the new tag is added.

Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.41 - v2.47
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
