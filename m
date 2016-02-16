From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 7/7] vxlan: treat vni in metadata based tunnels consistently
Date: Tue, 16 Feb 2016 21:59:03 +0100
Message-ID: <2b0065665a93b780f1c88cd7a4fc92cf2f87ece5.1455656217.git.jbenc@redhat.com>
References: <cover.1455656217.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755962AbcBPU7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:59:38 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 07A3429AC7
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 20:59:38 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GKxT01018384
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:59:37 -0500
In-Reply-To: <cover.1455656217.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For metadata based tunnels, VNI is ignored when doing vxlan device lookups
(because such tunnel receives all VNIs). However, this was not honored by
vxlan_xmit_one when doing encapsulation bypass. Move the check for metadata
based tunnel to the common place where it belongs.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6cb26a8a1615..2b78677f3399 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -246,6 +246,10 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
 {
 	struct vxlan_dev *vxlan;
 
+	/* For flow based devices, map all packets to VNI 0 */
+	if (vs->flags & VXLAN_F_COLLECT_METADATA)
+		vni = 0;
+
 	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
 		if (vxlan->default_dst.remote_vni == vni)
 			return vxlan;
@@ -1184,10 +1188,6 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	union vxlan_addr saddr;
 	int err = 0;
 
-	/* For flow based devices, map all packets to VNI 0 */
-	if (vs->flags & VXLAN_F_COLLECT_METADATA)
-		vni = 0;
-
 	/* Is this VNI defined? */
 	vxlan = vxlan_vs_find_vni(vs, vni);
 	if (!vxlan)
-- 
1.8.3.1
