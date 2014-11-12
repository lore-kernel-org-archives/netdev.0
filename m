From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/4] net: move vlan pop/push functions into common code
Date: Wed, 12 Nov 2014 15:52:29 +0100
Message-ID: <1415803950-9838-3-git-send-email-jiri@resnulli.us>
References: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34899 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbaKLOwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 09:52:40 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so5153955wib.11
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 06:52:39 -0800 (PST)
In-Reply-To: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So it can be used from out of openvswitch code.
Did couple of cosmetic changes on the way, namely variable naming and
adding support for 8021AD proto.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---

v1->v2:
- adjusted to fix recent ovs changes
- included change to use make_writable suggested by Eric

 include/linux/skbuff.h    |  2 ++
 net/core/skbuff.c         | 78 +++++++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/actions.c | 81 +++++------------------------------------------
 3 files changed, 88 insertions(+), 73 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e045516..78c299f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2679,6 +2679,8 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
 int skb_ensure_writable(struct sk_buff *skb, int write_len);
+int skb_vlan_pop(struct sk_buff *skb);
+int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d11bbe0..c7d3000 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4163,6 +4163,84 @@ int skb_ensure_writable(struct sk_buff *skb, int write_len)
 }
 EXPORT_SYMBOL(skb_ensure_writable);
 
+/* remove VLAN header from packet and update csum accordingly. */
+static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
+{
+	struct vlan_hdr *vhdr;
+	int err;
+
+	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
+	if (unlikely(err))
+		return err;
+
+	skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
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
index 04c9680..e1a5182 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -206,91 +206,26 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
-/* remove VLAN header from packet and update csum accordingly. */
-static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
-{
-	struct vlan_hdr *vhdr;
-	int err;
-
-	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
-	if (unlikely(err))
-		return err;
-
-	skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
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
 static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
-	__be16 tci;
 	int err;
 
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
-		   skb->len < VLAN_ETH_HLEN)) {
+	err = skb_vlan_pop(skb);
+	if (vlan_tx_tag_present(skb))
+		invalidate_flow_key(key);
+	else
 		key->eth.tci = 0;
-		return 0;
-	}
-
-	invalidate_flow_key(key);
-	err = __pop_vlan_tci(skb, &tci);
-	if (unlikely(err))
-		return err;
-
-	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(tci));
-	return 0;
+	return err;
 }
 
 static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_vlan *vlan)
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
+	if (vlan_tx_tag_present(skb))
 		invalidate_flow_key(key);
-	} else {
+	else
 		key->eth.tci = vlan->vlan_tci;
-	}
-	__vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
-	return 0;
+	return skb_vlan_push(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 }
 
 static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *key,
-- 
1.9.3
