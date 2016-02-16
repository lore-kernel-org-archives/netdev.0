From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/7] vxlan: move GBP header parsing to a separate function
Date: Tue, 16 Feb 2016 21:59:00 +0100
Message-ID: <f672e1e6d5a04a23c8704be6e9a7bf7a5dca592f.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755893AbcBPU7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:35 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 054E47AE88
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:35 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxw018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:34 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make vxlan_udp_encap_recv shorter and more comprehensible.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6ac9776a8eb0..45467552162a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1146,6 +1146,24 @@ static bool vxlan_remcsum(struct sk_buff *skb, u32 vxflags, __be32 vni_field)
 	return true;
 }
 
+static void vxlan_parse_gbp_hdr(struct sk_buff *skb, struct vxlan_metadata *md,
+				struct metadata_dst *tun_dst)
+{
+	struct vxlanhdr_gbp *gbp;
+
+	gbp = (struct vxlanhdr_gbp *)vxlan_hdr(skb);
+	md->gbp = ntohs(gbp->policy_id);
+
+	if (tun_dst)
+		tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
+
+	if (gbp->dont_learn)
+		md->gbp |= VXLAN_GBP_DONT_LEARN;
+
+	if (gbp->policy_applied)
+		md->gbp |= VXLAN_GBP_POLICY_APPLIED;
+}
+
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		      struct vxlan_metadata *md, __be32 vni,
 		      struct metadata_dst *tun_dst)
@@ -1294,20 +1312,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	 * used by VXLAN extensions if explicitly requested.
 	 */
 	if ((flags & VXLAN_HF_GBP) && (vs->flags & VXLAN_F_GBP)) {
-		struct vxlanhdr_gbp *gbp;
-
-		gbp = (struct vxlanhdr_gbp *)vxlan_hdr(skb);
-		md->gbp = ntohs(gbp->policy_id);
-
-		if (tun_dst)
-			tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
-
-		if (gbp->dont_learn)
-			md->gbp |= VXLAN_GBP_DONT_LEARN;
-
-		if (gbp->policy_applied)
-			md->gbp |= VXLAN_GBP_POLICY_APPLIED;
-
+		vxlan_parse_gbp_hdr(skb, md, tun_dst);
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
 
-- 
1.8.3.1
