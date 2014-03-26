From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] vlan: Set hard_header_len according to available acceleration
Date: Wed, 26 Mar 2014 11:47:56 -0400
Message-ID: <1395848876-15244-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083AbaCZPsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 11:48:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if the card supports CTAG acceleration we do not
account for the vlan header even if we are configuring an
8021AD vlan.  This may not be best since we'll do software
tagging for 8021AD which will cause data copy on skb head expansion
Configure the length based on available hw offload capabilities and
vlan protocol.

CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan.c     | 4 +++-
 net/8021q/vlan_dev.c | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ec99099..175273f 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -307,9 +307,11 @@ static void vlan_sync_address(struct net_device *dev,
 static void vlan_transfer_features(struct net_device *dev,
 				   struct net_device *vlandev)
 {
+	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
+
 	vlandev->gso_max_size = dev->gso_max_size;
 
-	if (dev->features & NETIF_F_HW_VLAN_CTAG_TX)
+	if (vlan_hw_offload_capable(dev->features, vlan->vlan_proto))
 		vlandev->hard_header_len = dev->hard_header_len;
 	else
 		vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4b65aa4..a9591ff 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -592,7 +592,8 @@ static int vlan_dev_init(struct net_device *dev)
 #endif
 
 	dev->needed_headroom = real_dev->needed_headroom;
-	if (real_dev->features & NETIF_F_HW_VLAN_CTAG_TX) {
+	if (vlan_hw_offload_capable(real_dev->features,
+				    vlan_dev_priv(dev)->vlan_proto)) {
 		dev->header_ops      = &vlan_passthru_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
-- 
1.8.5.3
