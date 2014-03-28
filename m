From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 4/4] vlan: Warn the user if lowerdev has bad vlan features.
Date: Thu, 27 Mar 2014 22:14:49 -0400
Message-ID: <1395972889-32289-5-git-send-email-vyasevic@redhat.com>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757256AbaC1CO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 22:14:56 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2S2EsEa029814
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 22:14:55 -0400
In-Reply-To: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers incorrectly assign vlan acceleration features to
vlan_features thus causing issues for Q-in-Q vlan configurations.
Warn the user of such cases.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdev_features.h | 7 +++++++
 net/8021q/vlan_dev.c            | 3 +++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 1005ebf..5a09a48 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -163,4 +163,11 @@ enum {
 /* changeable features with no special hardware requirements */
 #define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
 
+#define NETIF_F_VLAN_FEATURES	(NETIF_F_HW_VLAN_CTAG_FILTER | \
+				 NETIF_F_HW_VLAN_CTAG_RX | \
+				 NETIF_F_HW_VLAN_CTAG_TX | \
+				 NETIF_F_HW_VLAN_STAG_FILTER | \
+				 NETIF_F_HW_VLAN_STAG_RX | \
+				 NETIF_F_HW_VLAN_STAG_TX)
+
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index a9591ff..0e1db36 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -578,6 +578,9 @@ static int vlan_dev_init(struct net_device *dev)
 
 	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
+	if (dev->features & NETIF_F_VLAN_FEATURES)
+		netdev_warn(real_dev, "VLAN features are set incorrectly.  Q-in-Q configurations may not work correctly.\n");
+
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
-- 
1.8.5.3
