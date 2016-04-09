From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] vxlan: reduce usage of synchronize_net in ndo_stop
Date: Sat,  9 Apr 2016 12:46:23 +0200
Message-ID: <1460198783-10026-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:53764 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751344AbcDIKqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 06:46:32 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id D6CA620A9A
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 06:46:30 -0400 (EDT)
Received: from z.localhost.localdomain (unknown [213.55.184.192])
	by mail.messagingengine.com (Postfix) with ESMTPA id 13967C00012
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 06:46:29 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only need to do the synchronize_net dance once for both, ipv4 and
ipv6 sockets, thus removing one synchronize_net in case both sockets get
dismantled.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Based on patch: [net-next,v2] vxlan: synchronously and race-free destruction of vxlan sockets

 drivers/net/vxlan.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 77ba31a0e44f97..c417bbfa3ab49f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1037,14 +1037,14 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-static void __vxlan_sock_release(struct vxlan_sock *vs)
+static bool __vxlan_sock_release_prep(struct vxlan_sock *vs)
 {
 	struct vxlan_net *vn;
 
 	if (!vs)
-		return;
+		return false;
 	if (!atomic_dec_and_test(&vs->refcnt))
-		return;
+		return false;
 
 	vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
 	spin_lock(&vn->sock_lock);
@@ -1052,16 +1052,28 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
-	synchronize_net();
-	udp_tunnel_sock_release(vs->sock);
-	kfree(vs);
+	return true;
 }
 
 static void vxlan_sock_release(struct vxlan_dev *vxlan)
 {
-	__vxlan_sock_release(vxlan->vn4_sock);
+	bool ipv4 = __vxlan_sock_release_prep(vxlan->vn4_sock);
 #if IS_ENABLED(CONFIG_IPV6)
-	__vxlan_sock_release(vxlan->vn6_sock);
+	bool ipv6 = __vxlan_sock_release_prep(vxlan->vn6_sock);
+#endif
+
+	synchronize_net();
+
+	if (ipv4) {
+		udp_tunnel_sock_release(vxlan->vn4_sock->sock);
+		kfree(vxlan->vn4_sock);
+	}
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipv6) {
+		udp_tunnel_sock_release(vxlan->vn6_sock->sock);
+		kfree(vxlan->vn6_sock);
+	}
 #endif
 }
 
-- 
2.5.5
