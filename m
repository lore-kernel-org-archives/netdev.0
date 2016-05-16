From: Dimitris Michailidis <dmichail@google.com>
Subject: [PATCH] net: don't lose features in netdev_add_tso_features()
Date: Mon, 16 May 2016 15:33:35 -0700
Message-ID: <1463438015-19529-1-git-send-email-dmichail@google.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35073 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbcEPWdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:33:45 -0400
Received: by mail-pa0-f54.google.com with SMTP id gj5so11232427pac.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 15:33:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of netdev_add_tso_features() is to enable all TSO features but
it unintentionally loses NETIF_F_ALL_FOR_ALL features. This is because
the netdev_increment_features() it calls clears any NETIF_F_ALL_FOR_ALL
bits that aren't included in the incremental features and none of them
are included in NETIF_F_ALL_TSO. The behavior can be seen by enabling
tx-nocache-copy on the slaves and noticing the feature remains off at
the master.

Fix this by including NETIF_F_ALL_FOR_ALL in the incremental features.

Signed-off-by: Dave Platt <dplatt@google.com>
Signed-off-by: Dimitris Michailidis <dmichail@google.com>
---
 include/linux/netdevice.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c2f5112..da45388 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3978,7 +3978,12 @@ netdev_features_t netdev_increment_features(netdev_features_t all,
 static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
 							netdev_features_t mask)
 {
-	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
+	/* OR in NETIF_F_ALL_FOR_ALL to preserve any of its bits already present
+	 * in features
+	 */
+	return netdev_increment_features(features,
+					 NETIF_F_ALL_TSO | NETIF_F_ALL_FOR_ALL,
+					 mask);
 }
 
 int __netdev_update_features(struct net_device *dev);
-- 
2.8.0.rc3.226.g39d4020
