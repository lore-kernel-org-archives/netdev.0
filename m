From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/7] vxlan: introduce vxlan_hdr
Date: Tue, 16 Feb 2016 21:58:57 +0100
Message-ID: <e937b2a548c52b3bd2e7d3a925d0e1074032f25b.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbcBPU7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:32 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 02065373955
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:31 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxTxt018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:31 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, pointer to the vxlan header is kept in a local variable. It has
to be reloaded whenever the pskb pull operations are performed which usually
happens somewhere deep in called functions.

Create a vxlan_hdr function and use it to reference the vxlan header
instead.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 17 +++++++----------
 include/net/vxlan.h |  5 +++++
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0a23c64379d6..a1f1a5aed19a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1247,7 +1247,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst = NULL;
 	struct vxlan_sock *vs;
-	struct vxlanhdr *vxh;
 	u32 flags, vni;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
@@ -1256,9 +1255,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
 		goto error;
 
-	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
-	flags = ntohl(vxh->vx_flags);
-	vni = ntohl(vxh->vx_vni);
+	flags = ntohl(vxlan_hdr(skb)->vx_flags);
+	vni = ntohl(vxlan_hdr(skb)->vx_vni);
 
 	if (flags & VXLAN_HF_VNI) {
 		flags &= ~VXLAN_HF_VNI;
@@ -1269,16 +1267,14 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
 		goto drop;
-	vxh = (struct vxlanhdr *)(udp_hdr(skb) + 1);
 
 	vs = rcu_dereference_sk_user_data(sk);
 	if (!vs)
 		goto drop;
 
 	if ((flags & VXLAN_HF_RCO) && (vs->flags & VXLAN_F_REMCSUM_RX)) {
-		vxh = vxlan_remcsum(skb, vxh, sizeof(struct vxlanhdr), vni,
-				    !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL));
-		if (!vxh)
+		if (!vxlan_remcsum(skb, vxlan_hdr(skb), sizeof(struct vxlanhdr), vni,
+				   !!(vs->flags & VXLAN_F_REMCSUM_NOPARTIAL)))
 			goto drop;
 
 		flags &= ~VXLAN_HF_RCO;
@@ -1303,7 +1299,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if ((flags & VXLAN_HF_GBP) && (vs->flags & VXLAN_F_GBP)) {
 		struct vxlanhdr_gbp *gbp;
 
-		gbp = (struct vxlanhdr_gbp *)vxh;
+		gbp = (struct vxlanhdr_gbp *)vxlan_hdr(skb);
 		md->gbp = ntohs(gbp->policy_id);
 
 		if (tun_dst)
@@ -1341,7 +1337,8 @@ drop:
 
 bad_flags:
 	netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-		   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
+		   ntohl(vxlan_hdr(skb)->vx_flags),
+		   ntohl(vxlan_hdr(skb)->vx_vni));
 
 error:
 	if (tun_dst)
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 25bd919c9ef0..3792e188e13d 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -261,6 +261,11 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
+static inline struct vxlanhdr *vxlan_hdr(struct sk_buff *skb)
+{
+	return (struct vxlanhdr *)(udp_hdr(skb) + 1);
+}
+
 #if IS_ENABLED(CONFIG_VXLAN)
 void vxlan_get_rx_port(struct net_device *netdev);
 #else
-- 
1.8.3.1
