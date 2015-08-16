From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Updates to netif_index_is_vrf
Date: Sat, 15 Aug 2015 18:09:53 -0600
Message-ID: <1439683793-2999-1-git-send-email-dsa@cumulusnetworks.com>
Cc: eric.dumazet@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38860 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbHPAKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 20:10:03 -0400
Received: by igfj19 with SMTP id j19so33758338igf.1
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 17:10:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Eric noted netif_index_is_vrf is not called with rcu_read_lock held,
so use dev_get_by_index instead of dev_get_by_index_rcu.

If VRF is not enabled or oif is 0 skip the device lookup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/netdevice.h | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f7a6ef2fae3a..dca36a618781 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3819,12 +3819,20 @@ static inline bool netif_is_vrf(const struct net_device *dev)
 
 static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 {
-	struct net_device *dev = dev_get_by_index_rcu(net, ifindex);
 	bool rc = false;
 
-	if (dev)
-		rc = netif_is_vrf(dev);
+#if IS_ENABLED(CONFIG_NET_VRF)
+	struct net_device *dev;
+
+	if (ifindex == 0)
+		return false;
 
+	dev = dev_get_by_index(net, ifindex);
+	if (dev) {
+		rc = netif_is_vrf(dev);
+		dev_put(dev);
+	}
+#endif
 	return rc;
 }
 
-- 
2.3.2 (Apple Git-55)
