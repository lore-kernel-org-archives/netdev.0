From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v4 1/3] macvtap: simplify usage of tap_features
Date: Fri, 16 Aug 2013 15:25:00 -0400
Message-ID: <1376681102-19753-2-git-send-email-vyasevic@redhat.com>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758418Ab3HPWyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 18:54:11 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7GJP7qE015018
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:25:07 -0400
In-Reply-To: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In macvtap, tap_features specific the features of that the user
has specified via ioctl().  If we treat macvtap as a macvlan+tap
then we could all the tap a pseudo-device and give it other features
like SG and GSO.  Then we can stop using the features of lower
device (macvlan) when forwarding the traffic the tap.

This solves the issue of possible checksum offload mismatch between
tap feature and macvlan features.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index b51db2a..448f8a5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -68,6 +68,8 @@ static const struct proto_ops macvtap_socket_ops;
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
 		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
+#define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
+
 /*
  * RCU usage:
  * The macvtap_queue and the macvlan_dev are loosely coupled, the
@@ -278,7 +280,8 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
-	netdev_features_t features;
+	netdev_features_t features = TAP_FEATURES;
+
 	if (!q)
 		goto drop;
 
@@ -289,7 +292,7 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 	/* Apply the forward feature mask so that we perform segmentation
 	 * according to users wishes.
 	 */
-	features = netif_skb_features(skb) & vlan->tap_features;
+	features |= vlan->tap_features;
 	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
@@ -1064,8 +1067,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 	/* tap_features are the same as features on tun/tap and
 	 * reflect user expectations.
 	 */
-	vlan->tap_features = vlan->dev->features &
-			    (feature_mask | ~TUN_OFFLOADS);
+	vlan->tap_features = feature_mask;
 	vlan->set_features = features;
 	netdev_update_features(vlan->dev);
 
-- 
1.8.1.4
