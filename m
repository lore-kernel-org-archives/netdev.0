From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/5] vxlan: consolidate GBP handling even more
Date: Tue, 23 Feb 2016 18:02:55 +0100
Message-ID: <4efe2a3320a88949ce9ee9aaed5edd80459321c4.1456246786.git.jbenc@redhat.com>
References: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbcBWRDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:08 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id A653A627F7
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:08 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AE008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:08 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when the packet is scrubbed early, skb->mark can be set in the GBP
handling code.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 909f7931c297..656a303c0ac8 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1164,6 +1164,7 @@ out:
 }
 
 static void vxlan_parse_gbp_hdr(struct vxlanhdr *unparsed,
+				struct sk_buff *skb, u32 vxflags,
 				struct vxlan_metadata *md,
 				struct metadata_dst *tun_dst)
 {
@@ -1183,6 +1184,9 @@ static void vxlan_parse_gbp_hdr(struct vxlanhdr *unparsed,
 	if (gbp->policy_applied)
 		md->gbp |= VXLAN_GBP_POLICY_APPLIED;
 
+	/* In flow-based mode, GBP is carried in dst_metadata */
+	if (!(vxflags & VXLAN_F_COLLECT_METADATA))
+		skb->mark = md->gbp;
 out:
 	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
 }
@@ -1228,9 +1232,6 @@ static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
 		goto drop;
 
 	skb_reset_network_header(skb);
-	/* In flow-based mode, GBP is carried in dst_metadata */
-	if (!(vs->flags & VXLAN_F_COLLECT_METADATA))
-		skb->mark = md->gbp;
 
 	if (oip6)
 		err = IP6_ECN_decapsulate(oip6, skb);
@@ -1329,7 +1330,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		if (!vxlan_remcsum(&unparsed, skb, vs->flags))
 			goto drop;
 	if (vs->flags & VXLAN_F_GBP)
-		vxlan_parse_gbp_hdr(&unparsed, md, tun_dst);
+		vxlan_parse_gbp_hdr(&unparsed, skb, vs->flags, md, tun_dst);
 
 	if (unparsed.vx_flags || unparsed.vx_vni) {
 		/* If there are any unprocessed flags remaining treat
-- 
1.8.3.1
