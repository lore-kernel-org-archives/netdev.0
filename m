From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/7] vxlan: simplify vxlan_remcsum
Date: Tue, 16 Feb 2016 21:58:59 +0100
Message-ID: <3f99ea8201babacc4755a771e049d15e2ed78ef9.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbcBPU7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:34 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 020DDC09FAA6
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:34 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxv018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:33 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of the parameters is not needed. Simplify the caller of this function
in preparation of making vxlan rx more comprehensible.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 58cc0942f39a..6ac9776a8eb0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1125,29 +1125,25 @@ static int vxlan_igmp_leave(struct vxlan_dev *vxlan)
 	return ret;
 }
 
-static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
-				      size_t hdrlen, __be32 vni_field,
-				      bool nopartial)
+static bool vxlan_remcsum(struct sk_buff *skb, u32 vxflags, __be32 vni_field)
 {
 	size_t start, offset, plen;
 
 	if (skb->remcsum_offload)
-		return vh;
+		return true;
 
 	start = vxlan_rco_start(vni_field);
 	offset = start + vxlan_rco_offset(vni_field);
 
-	plen = hdrlen + offset + sizeof(u16);
+	plen = sizeof(struct vxlanhdr) + offset + sizeof(u16);
 
 	if (!pskb_may_pull(skb, plen))
-		return NULL;
-
-	vh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
+		return false;
 
-	skb_remcsum_process(skb, (void *)vh + hdrlen, start, offset,
-			    nopartial);
+	skb_remcsum_process(skb, (void *)(vxlan_hdr(skb) + 1), start, offset,
+			    !!(vxflags & VXLAN_F_REMCSUM_NOPARTIAL));
 
-	return vh;
+	return true;
 }
 
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
@@ -1275,9 +1271,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
-		if (!vxlan_remcsum(skb, vxlan_hdr(skb), sizeof(struct vxlanhdr),
-				   vni_field,
-				   !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL)))
+		if (!vxlan_remcsum(skb, vs->flags, vni_field))
 			goto drop;
 
 		flags &= ~VXLAN_HF_RCO;
-- 
1.8.3.1
