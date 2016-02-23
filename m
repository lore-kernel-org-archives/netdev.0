From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 5/5] vxlan: simplify metadata_dst usage in vxlan_rcv
Date: Tue, 23 Feb 2016 18:02:59 +0100
Message-ID: <e04a56f6cfa19f1f3c71498fc103daccc2508784.1456246786.git.jbenc@redhat.com>
References: <cover.1456246786.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217AbcBWRDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 12:03:12 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 98E3C1E41
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 17:03:12 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-63.brq.redhat.com [10.40.204.63])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1NH36AI008009
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 12:03:11 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when the packet is scrubbed early, the metadata_dst can be assigned to
the skb as soon as it is allocated. This simplifies the error cleanup path,
as the dst will be freed by kfree_skb. It is also not necessary to pass it
as a parameter to functions anymore.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index cfd6deb9f090..775ddb48388d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1165,16 +1165,17 @@ out:
 
 static void vxlan_parse_gbp_hdr(struct vxlanhdr *unparsed,
 				struct sk_buff *skb, u32 vxflags,
-				struct vxlan_metadata *md,
-				struct metadata_dst *tun_dst)
+				struct vxlan_metadata *md)
 {
 	struct vxlanhdr_gbp *gbp = (struct vxlanhdr_gbp *)unparsed;
+	struct metadata_dst *tun_dst;
 
 	if (!(unparsed->vx_flags & VXLAN_HF_GBP))
 		goto out;
 
 	md->gbp = ntohs(gbp->policy_id);
 
+	tun_dst = (struct metadata_dst *)skb_dst(skb);
 	if (tun_dst)
 		tun_dst->u.tun_info.key.tun_flags |= TUNNEL_VXLAN_OPT;
 
@@ -1250,7 +1251,6 @@ static bool vxlan_ecn_decapsulate(struct vxlan_sock *vs, void *oiph,
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 {
-	struct metadata_dst *tun_dst = NULL;
 	struct pcpu_sw_netstats *stats;
 	struct vxlan_dev *vxlan;
 	struct vxlan_sock *vs;
@@ -1289,6 +1289,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (vxlan_collect_metadata(vs)) {
 		__be32 vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
+		struct metadata_dst *tun_dst;
 
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
 					 vxlan_vni_to_tun_id(vni), sizeof(*md));
@@ -1297,6 +1298,8 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 
 		md = ip_tunnel_info_opts(&tun_dst->u.tun_info);
+
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
 	} else {
 		memset(md, 0, sizeof(*md));
 	}
@@ -1308,7 +1311,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 		if (!vxlan_remcsum(&unparsed, skb, vs->flags))
 			goto drop;
 	if (vs->flags & VXLAN_F_GBP)
-		vxlan_parse_gbp_hdr(&unparsed, skb, vs->flags, md, tun_dst);
+		vxlan_parse_gbp_hdr(&unparsed, skb, vs->flags, md);
 
 	if (unparsed.vx_flags || unparsed.vx_vni) {
 		/* If there are any unprocessed flags remaining treat
@@ -1325,11 +1328,6 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	if (!vxlan_set_mac(vxlan, vs, skb))
 		goto drop;
 
-	if (tun_dst) {
-		skb_dst_set(skb, (struct dst_entry *)tun_dst);
-		tun_dst = NULL;
-	}
-
 	oiph = skb_network_header(skb);
 	skb_reset_network_header(skb);
 
@@ -1349,9 +1347,6 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 drop:
-	if (tun_dst)
-		dst_release((struct dst_entry *)tun_dst);
-
 	/* Consume bad packet */
 	kfree_skb(skb);
 	return 0;
-- 
1.8.3.1
