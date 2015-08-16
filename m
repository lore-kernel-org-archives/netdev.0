From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Updates to netif_index_is_vrf
Date: Sun, 16 Aug 2015 07:49:20 -0600
Message-ID: <1439732960-3302-1-git-send-email-dsa@cumulusnetworks.com>
Cc: eric.dumazet@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34104 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbHPNta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 09:49:30 -0400
Received: by paccq16 with SMTP id cq16so46178274pac.1
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2015 06:49:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Eric noted netif_index_is_vrf is not called with rcu_read_lock held,
so wrap the dev_get_by_index_rcu in rcu_read_lock and unlock.

If VRF is not enabled or oif is 0 skip the device lookup. In both cases
index cannot be the VRF master.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2:
- per Florian's suggestion keep the dev_get_by_index_rcu and wrap with
  rcu_read_lock/unlock versus moving to dev_get_by_index with dev_hold/put

 include/linux/netdevice.h | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f7a6ef2fae3a..2d3cd86c5618 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3819,12 +3819,22 @@ static inline bool netif_is_vrf(const struct net_device *dev)
 
 static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 {
-	struct net_device *dev = dev_get_by_index_rcu(net, ifindex);
 	bool rc = false;
 
+#if IS_ENABLED(CONFIG_NET_VRF)
+	struct net_device *dev;
+
+	if (ifindex == 0)
+		return false;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
 		rc = netif_is_vrf(dev);
 
+	rcu_read_unlock();
+#endif
 	return rc;
 }
 
-- 
2.3.2 (Apple Git-55)
