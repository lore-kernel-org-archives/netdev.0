From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] ixgbe: fix ethtool loopback diagnostic with DCB enabled
Date: Fri, 13 Sep 2013 14:12:06 -0700
Message-ID: <1379106730-14994-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3IMVMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:18 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch disables DCB prior to running the loopback test.
When DCB is enabled the frames may be modified on Tx (by adding vlan tag)
which will fail the check on Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 0e1b973..08efc253 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1805,6 +1805,10 @@ static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 	unsigned int size = 1024;
 	netdev_tx_t tx_ret_val;
 	struct sk_buff *skb;
+	u32 flags_orig = adapter->flags;
+
+	/* DCB can modify the frames on Tx */
+	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 
 	/* allocate test skb */
 	skb = alloc_skb(size, GFP_KERNEL);
@@ -1857,6 +1861,7 @@ static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 
 	/* free the original skb */
 	kfree_skb(skb);
+	adapter->flags = flags_orig;
 
 	return ret_val;
 }
-- 
1.8.3.1
