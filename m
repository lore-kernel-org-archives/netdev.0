From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: Cleanup FDB handling code
Date: Fri, 29 Aug 2014 02:30:16 -0700
Message-ID: <1409304620-23251-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53254 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837AbaH2Ja3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:29 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the behavior for FDB handling is consistent
between both the SR-IOV and non-SR-IOV cases.  The main change here is that we
perform bounds checking on the number of SR-IOV addresses regardless of if
SR-IOV is enabled or not as we can only support a certain number of addresses
in the hardware.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 34 ++++-----------------------
 1 file changed, 4 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 53fbf06..2210c6d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7741,39 +7741,13 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     const unsigned char *addr,
 			     u16 flags)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int err;
-
-	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
-		return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
-
-	/* Hardware does not support aging addresses so if a
-	 * ndm_state is given only allow permanent addresses
-	 */
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
-		pr_info("%s: FDB only supports static addresses\n",
-			ixgbe_driver_name);
-		return -EINVAL;
-	}
-
+	/* guarantee we can provide a unique filter for the unicast address */
 	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
-		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
-
-		if (netdev_uc_count(dev) < rar_uc_entries)
-			err = dev_uc_add_excl(dev, addr);
-		else
-			err = -ENOMEM;
-	} else if (is_multicast_ether_addr(addr)) {
-		err = dev_mc_add_excl(dev, addr);
-	} else {
-		err = -EINVAL;
+		if (IXGBE_MAX_PF_MACVLANS <= netdev_uc_count(dev))
+			return -ENOMEM;
 	}
 
-	/* Only return duplicate errors if NLM_F_EXCL is set */
-	if (err == -EEXIST && !(flags & NLM_F_EXCL))
-		err = 0;
-
-	return err;
+	return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
 }
 
 static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
-- 
1.9.3
