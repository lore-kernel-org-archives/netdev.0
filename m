From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] macvlan: Fix performance issues with vlan tagged packets
Date: Thu, 11 May 2017 11:09:52 -0400
Message-ID: <1494515392-30826-1-git-send-email-vyasevic@redhat.com>
Cc: jasowang@redhat.com, mst@redhat.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34737 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752018AbdEKPKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 11:10:02 -0400
Received: by mail-it0-f68.google.com with SMTP id c26so3391560itd.1
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 08:10:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvlan always turns on offload features that have sofware
fallback (NETIF_GSO_SOFTWARE).  This allows much higher guest-guest
communications over macvtap.

However, macvtap does not turn on these features for vlan tagged traffic.
As a result, depending on the HW that mactap is configured on, the
performance of guest-guest communication over a vlan is very
inconsistent.  If the HW supports TSO/UFO over vlans, then the
performance will be fine.  If not, the the performance will suffer
greatly since the VM may continue using TSO/UFO, and will force the host
segment the traffic and possibly overlow the macvtap queue.

This patch adds the always on offloads to vlan_features.  This
makes sure that any vlan tagged traffic between 2 guest will not
be segmented needlessly.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b34eaaa..346ad2f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -789,10 +789,12 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
  */
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
-#define ALWAYS_ON_FEATURES \
-	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX | \
+#define ALWAYS_ON_OFFLOADS \
+	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE | \
 	 NETIF_F_GSO_ROBUST)
 
+#define ALWAYS_ON_FEATURES (ALWAYS_ON_OFFLOADS | NETIF_F_LLTX)
+
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_LRO | \
@@ -827,6 +829,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->features		|= ALWAYS_ON_FEATURES;
 	dev->hw_features	|= NETIF_F_LRO;
 	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
+	dev->vlan_features	|= ALWAYS_ON_OFFLOADS;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->gso_max_segs	= lowerdev->gso_max_segs;
 	dev->hard_header_len	= lowerdev->hard_header_len;
-- 
2.7.4
