From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] net: do not do gso for CHECKSUM_UNNECESSARY in netif_needs_gso
Date: Sat, 17 Mar 2012 02:08:11 -0700
Message-ID: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33772 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932092Ab2CQJIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 05:08:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This is related to fixing the bug of dropping FCoE frames when disabling tx ip
checksum by 'ethtool -K ethx tx off'. The FCoE protocol stack driver would
use CHECKSUM_UNNECESSARY on tx path instead of CHECKSUM_PARTIAL (as indicated in
the 2/2 of this series). To do so, netif_needs_gso() has to be changed here to
not do gso for both CHECKSUM_PARTIAL and CHECKSUM_UNNECESSARY.

Ref. to original discussion thread:
http://patchwork.ozlabs.org/patch/146567/

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/netdevice.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..c1b2b5f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2636,7 +2636,8 @@ static inline int netif_needs_gso(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
-		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
+		unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
+			 (skb->ip_summed != CHECKSUM_UNNECESSARY)));
 }
 
 static inline void netif_set_gso_max_size(struct net_device *dev,
-- 
1.7.7.6
