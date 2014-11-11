From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] net: move vlan pop/push functions into common code
Date: Tue, 11 Nov 2014 11:13:08 +0100
Message-ID: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:51337 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbaKKKNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 05:13:13 -0500
Received: by mail-wg0-f49.google.com with SMTP id x13so11043936wgg.22
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 02:13:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it can be used from out of openvswitch code.
Did couple of cosmetic changes on the way, namely variable naming and
adding support for 8021AD proto.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/skbuff.h    |  2 ++
 net/core/skbuff.c         | 86 +++++++++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/actions.c | 76 ++---------------------------------------
 3 files changed, 90 insertions(+), 74 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 103fbe8..3b0445c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2673,6 +2673,8 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet);
 unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
+int skb_vlan_pop(struct sk_buff *skb);
+int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7001896..75e53d4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4151,6 +4151,92 @@ err_free:
 }
 EXPORT_SYMBOL(skb_vlan_untag);
 
+/* remove VLAN header from packet and update csum accordingly. */
+static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
+{
+	struct vlan_hdr *vhdr;
+	int err;
+
+	if (!pskb_may_pull(skb, VLAN_ETH_HLEN))
+		return -ENOMEM;
+
+	if (!skb_cloned(skb) || skb_clone_writable(skb, VLAN_ETH_HLEN))
+		return 0;
+
+	err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+	if (unlikely(err))
+		return err;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
+
+	vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
+	*vlan_tci = ntohs(vhdr->h_vlan_TCI);
+
+	memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
+	__skb_pull(skb, VLAN_HLEN);
+
+	vlan_set_encap_proto(skb, vhdr);
+	skb->mac_header += VLAN_HLEN;
+	if (skb_network_offset(skb) < ETH_HLEN)
+		skb_set_network_header(skb, ETH_HLEN);
+	skb_reset_mac_len(skb);
+
+	return 0;
+}
+
+int skb_vlan_pop(struct sk_buff *skb)
+{
+	u16 vlan_tci;
+	__be16 vlan_proto;
+	int err;
+
+	if (likely(vlan_tx_tag_present(skb))) {
+		skb->vlan_tci = 0;
+	} else {
+		if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
+			      skb->protocol != htons(ETH_P_8021AD)) ||
+			     skb->len < VLAN_ETH_HLEN))
+			return 0;
+
+		err = __skb_vlan_pop(skb, &vlan_tci);
+		if (err)
+			return err;
+	}
+	/* move next vlan tag to hw accel tag */
+	if (likely((skb->protocol != htons(ETH_P_8021Q) &&
+		    skb->protocol != htons(ETH_P_8021AD)) ||
+		   skb->len < VLAN_ETH_HLEN))
+		return 0;
+
+	vlan_proto = skb->protocol;
+	err = __skb_vlan_pop(skb, &vlan_tci);
+	if (unlikely(err))
+		return err;
+
+	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+	return 0;
+}
+EXPORT_SYMBOL(skb_vlan_pop);
+
+int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
+{
+	if (vlan_tx_tag_present(skb)) {
+		/* push down current VLAN tag */
+		if (!__vlan_put_tag(skb, skb->vlan_proto,
+				    vlan_tx_tag_get(skb)))
+			return -ENOMEM;
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->csum = csum_add(skb->csum, csum_partial(skb->data
+					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
+	}
+	__vlan_hwaccel_put_tag(skb, vlan_proto, vlan_tci);
+	return 0;
+}
+EXPORT_SYMBOL(skb_vlan_push);
+
 /**
  * alloc_skb_with_frags - allocate skb with page frags
  *
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index f7e5891..1b28110 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -206,86 +206,14 @@ static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
 	return 0;
 }
 
-/* remove VLAN header from packet and update csum accordingly. */
-static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
-{
-	struct vlan_hdr *vhdr;
-	int err;
-
-	err = make_writable(skb, VLAN_ETH_HLEN);
-	if (unlikely(err))
-		return err;
-
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
-					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
-
-	vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
-	*current_tci = vhdr->h_vlan_TCI;
-
-	memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
-	__skb_pull(skb, VLAN_HLEN);
-
-	vlan_set_encap_proto(skb, vhdr);
-	skb->mac_header += VLAN_HLEN;
-
-	if (skb_network_offset(skb) < ETH_HLEN)
-		skb_set_network_header(skb, ETH_HLEN);
-
-	/* Update mac_len for subsequent MPLS actions */
-	skb_reset_mac_len(skb);
-	return 0;
-}
-
 static int pop_vlan(struct sk_buff *skb)
 {
-	__be16 tci;
-	int err;
-
-	if (likely(vlan_tx_tag_present(skb))) {
-		skb->vlan_tci = 0;
-	} else {
-		if (unlikely(skb->protocol != htons(ETH_P_8021Q) ||
-			     skb->len < VLAN_ETH_HLEN))
-			return 0;
-
-		err = __pop_vlan_tci(skb, &tci);
-		if (err)
-			return err;
-	}
-	/* move next vlan tag to hw accel tag */
-	if (likely(skb->protocol != htons(ETH_P_8021Q) ||
-		   skb->len < VLAN_ETH_HLEN))
-		return 0;
-
-	err = __pop_vlan_tci(skb, &tci);
-	if (unlikely(err))
-		return err;
-
-	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(tci));
-	return 0;
+	return skb_vlan_pop(skb);
 }
 
 static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
 {
-	if (unlikely(vlan_tx_tag_present(skb))) {
-		u16 current_tag;
-
-		/* push down current VLAN tag */
-		current_tag = vlan_tx_tag_get(skb);
-
-		if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
-			return -ENOMEM;
-		/* Update mac_len for subsequent MPLS actions */
-		skb->mac_len += VLAN_HLEN;
-
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			skb->csum = csum_add(skb->csum, csum_partial(skb->data
-					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
-
-	}
-	__vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
-	return 0;
+	return skb_vlan_push(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 }
 
 static int set_eth_addr(struct sk_buff *skb,
-- 
1.9.3
