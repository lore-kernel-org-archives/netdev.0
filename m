From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] vlan: Fix the b0rked ingress VLAN_FLAG_REORDER_HDR check.
Date: Mon, 23 May 2011 17:11:51 -0700
Message-ID: <m1oc2tyn20.fsf_-_@fess.ebiederm.org>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>
	<20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46413 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063Ab1EXAME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 20:12:04 -0400
In-Reply-To: <20110523.172047.1438754754048434316.davem@davemloft.net> (David
	Miller's message of "Mon, 23 May 2011 17:20:47 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag but
rather in vlan_do_receive.  In attempting to test VLAN_FLAG_REORDER_HDR
we are attempting to deference vlan private network device members a non
vlan device, which is just wrong.  Move the test into vlan_do_receive so
that the vlan header will not be properly put on the packet in the case
of vlan header acceleration.

As we remove the check from vlan_check_reorder_header rename it
vlan_reorder_header to keep the naming clean.

Hopefully at somepoint we will just declare the case where
VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove the code.
Until then this keeps it working correctly.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/if_vlan.h |   25 ++++++++++++++++++++++---
 net/8021q/vlan_core.c   |   25 ++++++++++++++-----------
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 290bd8a..26f3c92 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -220,7 +220,7 @@ static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
 }
 
 /**
- * __vlan_put_tag - regular VLAN tag inserting
+ * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
  *
@@ -229,8 +229,10 @@ static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
  *
  * Following the skb_unshare() example, in case of error, the calling function
  * doesn't have to worry about freeing the original skb.
+ *
+ * Does not change skb->protocol so this function can be used for receive.
  */
-static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -250,8 +252,25 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
 
-	skb->protocol = htons(ETH_P_8021Q);
+	return skb;
+}
 
+/**
+ * __vlan_put_tag - regular VLAN tag inserting
+ * @skb: skbuff to tag
+ * @vlan_tci: VLAN TCI to insert
+ *
+ * Inserts the VLAN tag into @skb as part of the payload
+ * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
+ *
+ * Following the skb_unshare() example, in case of error, the calling function
+ * doesn't have to worry about freeing the original skb.
+ */
+static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
+{
+	skb = vlan_insert_tag(skb, vlan_tci);
+	if (skb)
+		skb->protocol = htons(ETH_P_8021Q);
 	return skb;
 }
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 41495dc..c08dae7 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -23,6 +23,11 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		return false;
 
 	skb->dev = vlan_dev;
+	if (unlikely(!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR))) {
+		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
+		if (!skb)
+			return false;
+	}
 	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
@@ -89,17 +94,15 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 }
 EXPORT_SYMBOL(vlan_gro_frags);
 
-static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
+static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
-	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_cow(skb, skb_headroom(skb)) < 0)
-			skb = NULL;
-		if (skb) {
-			/* Lifted from Gleb's VLAN code... */
-			memmove(skb->data - ETH_HLEN,
-				skb->data - VLAN_ETH_HLEN, 12);
-			skb->mac_header += VLAN_HLEN;
-		}
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		skb = NULL;
+	if (skb) {
+		/* Lifted from Gleb's VLAN code... */
+		memmove(skb->data - ETH_HLEN,
+			skb->data - VLAN_ETH_HLEN, 12);
+		skb->mac_header += VLAN_HLEN;
 	}
 	return skb;
 }
@@ -161,7 +164,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
 
-	skb = vlan_check_reorder_header(skb);
+	skb = vlan_reorder_header(skb);
 	if (unlikely(!skb))
 		goto err_free;
 
-- 
1.7.5.1.217.g4e3aa

