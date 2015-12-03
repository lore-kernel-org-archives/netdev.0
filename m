From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] ixgbe: Allow FDB entries access to more RAR filters
Date: Thu,  3 Dec 2015 03:07:16 -0800
Message-ID: <1449140843-118580-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27448 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759783AbbLCLHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:31 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This change makes it so that we allow the PF to make use of all free RAR
entries for FDB use if needed.

Previously the code limited us to 16 unicast entries, however this was
shared between MACVLAN which wasn't limited and the FDB code which was.  So
instead of treating the FDB code as a second class citizen I have updated
it so that it has access to just as many entries as the MACVLAN filters.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 708e210..378c44d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8200,7 +8200,10 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	/* guarantee we can provide a unique filter for the unicast address */
 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
-		if (IXGBE_MAX_PF_MACVLANS <= netdev_uc_count(dev))
+		struct ixgbe_adapter *adapter = netdev_priv(dev);
+		u16 pool = VMDQ_P(0);
+
+		if (netdev_uc_count(dev) >= ixgbe_available_rars(adapter, pool))
 			return -ENOMEM;
 	}
 
-- 
2.5.0
