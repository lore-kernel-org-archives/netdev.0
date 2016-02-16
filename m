From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 5/7] vxlan: clean up extension handling on rx
Date: Tue, 16 Feb 2016 21:59:01 +0100
Message-ID: <d351c89abe50d48cd3504af678020a4bf951ecc7.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919AbcBPU7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:36 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 048168DFE9
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:36 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxx018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:35 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bring the extension handling to a single place and move the actual handling
logic out of vxlan_udp_encap_recv as much as possible.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 62 +++++++++++++++++++++++++++--------------------------
 1 file changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 45467552162a..40f61c15a4a6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1125,15 +1125,16 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 	return ret;
 }
 
-static bool vxlan_remcsum(struct sk_buff *skb, u32 vxflags, __be32 vni_field)
+static bool vxlan_remcsum(struct vxlanhdr *unparsed,
+			  struct sk_buff *skb, u32 vxflags)
 {
 	size_t start, offset, plen;
 
-	if (skb->remcsum_offload)
-		return true;
+	if (!(unparsed->vx_flags & VXLAN_HF_RCO) || skb->remcsum_offload)
+		goto out;
 
-	start = vxlan_rco_start(vni_field);
-	offset = start + vxlan_rco_offset(vni_field);
+	start = vxlan_rco_start(unparsed->vx_vni);
+	offset = start + vxlan_rco_offset(unparsed->vx_vni);
 
 	plen = sizeof(struct vxlanhdr) + offset + sizeof(u16);
 
@@ -1142,16 +1143,21 @@ static bool vxlan_remcsum(struct sk_buff *skb, u32 vxflags, __be32 vni_field)
 
 	skb_remcsum_process(skb, (void *)(vxlan_hdr(skb) + 1), start, offset,
 			    !!(vxflags & VXLAN_F_REMCSUM_NOPARTIAL));
-
+out:
+	unparsed->vx_flags &= ~VXLAN_HF_RCO;
+	unparsed->vx_vni &= VXLAN_VNI_MASK;
 	return true;
 }
 
-static void vxlan_parse_gbp_hdr(struct sk_buff *skb, struct vxlan_metadata *md,
+static void vxlan_parse_gbp_hdr(struct vxlanhdr *unparsed,
+				struct vxlan_metadata *md,
 				struct metadata_dst *tun_dst)
 {
-	struct vxlanhdr_gbp *gbp;
+	struct vxlanhdr_gbp *gbp = (struct vxlanhdr_gbp *)unparsed;
+
+	if (!(unparsed->vx_flags & VXLAN_HF_GBP))
+		goto out;
 
-	gbp = (struct vxlanhdr_gbp *)vxlan_hdr(skb);
 	md->gbp = ntohs(gbp->policy_id);
 
 	if (tun_dst)
@@ -1162,6 +1168,9 @@ static void vxlan_parse_gbp_hdr(struct sk_buff *skb, struct vxlan_metadata *md,
 
 	if (gbp->policy_applied)
 		md->gbp |= VXLAN_GBP_POLICY_APPLIED;
+
+out:
+	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
 }
 
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
@@ -1263,7 +1272,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst = NULL;
 	struct vxlan_sock *vs;
-	__be32 flags, vni_field;
+	struct vxlanhdr unparsed;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 
@@ -1271,11 +1280,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	flags = vxlan_hdr(skb)->vx_flags;
-	vni_field = vxlan_hdr(skb)->vx_vni;
-
-	if (flags & VXLAN_HF_VNI) {
-		flags &= ~VXLAN_HF_VNI;
+	unparsed = *vxlan_hdr(skb);
+	if (unparsed.vx_flags & VXLAN_HF_VNI) {
+		unparsed.vx_flags &= ~VXLAN_HF_VNI;
+		unparsed.vx_vni &= ~VXLAN_VNI_MASK;
 	} else {
 		/* VNI flag always required to be set */
 		goto bad_flags;
@@ -1288,17 +1296,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
-	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
-		if (!vxlan_remcsum(skb, vs->flags, vni_field))
-			goto drop;
-
-		flags &= ~VXLAN_HF_RCO;
-		vni_field &= VXLAN_VNI_MASK;
-	}
-
 	if (vxlan_collect_metadata(vs)) {
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
-					 vxlan_vni(vni_field), sizeof(*md));
+					 vxlan_vni(vxlan_hdr(skb)->vx_vni),
+					 sizeof(*md));
 
 		if (!tun_dst)
 			goto drop;
@@ -1311,12 +1312,13 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	/* For backwards compatibility, only allow reserved fields to be
 	 * used by VXLAN extensions if explicitly requested.
 	 */
-	if ((flags & VXLAN_HF_GBP) && (vs->flags & VXLAN_F_GBP)) {
-		vxlan_parse_gbp_hdr(skb, md, tun_dst);
-		flags &= ~VXLAN_GBP_USED_BITS;
-	}
+	if (vs->flags & VXLAN_F_REMCSUM_RX)
+		if (!vxlan_remcsum(&unparsed, skb, vs->flags))
+			goto drop;
+	if (vs->flags & VXLAN_F_GBP)
+		vxlan_parse_gbp_hdr(&unparsed, md, tun_dst);
 
-	if (flags || vni_field & ~VXLAN_VNI_MASK) {
+	if (unparsed.vx_flags || unparsed.vx_vni) {
 		/* If there are any unprocessed flags remaining treat
 		 * this as a malformed packet. This behavior diverges from
 		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
@@ -1329,7 +1331,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	vxlan_rcv(vs, skb, md, vxlan_vni(vni_field), tun_dst);
+	vxlan_rcv(vs, skb, md, vxlan_vni(vxlan_hdr(skb)->vx_vni), tun_dst);
 	return 0;
 
 drop:
-- 
1.8.3.1
