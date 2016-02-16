From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] vxlan: do not use fdb in metadata mode
Date: Tue, 16 Feb 2016 22:18:26 +0100
Message-ID: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbcBPVSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 16:18:37 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 1B4A38E921
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 21:18:37 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-84.brq.redhat.com [10.40.204.84])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1GLIZbl024948
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 16:18:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In metadata mode, the vxlan interface is not supposed to use the fdb control
plane but an external one (openvswitch or static routes). With the current
code, packets may leak into the fdb handling code which usually causes them
to be dropped anyway but may have strange side effects.

Just drop the packets directly when in metadata mode if the destination data
are not correctly provided on egress.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index db96f3a16f6c..e6944b29588e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2171,9 +2171,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	}
 
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA &&
-	    info && info->mode & IP_TUNNEL_INFO_TX) {
-		vxlan_xmit_one(skb, dev, NULL, false);
+	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+		if (info && info->mode & IP_TUNNEL_INFO_TX)
+			vxlan_xmit_one(skb, dev, NULL, false);
+		else
+			kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
-- 
1.8.3.1
