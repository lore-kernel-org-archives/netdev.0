From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] ixgbe: fix RAR entry counting for generic and fdb_add()
Date: Sat, 21 Jul 2012 16:08:58 -0700
Message-ID: <1342912142-11130-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22894 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab2GUXJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:12 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Do RAR entry accounting correctly so that errors are reported and
promisc mode is set correctly when the number of entries exceeds
the hardware limits.

This can happen with many macvlan devices attached to the PF or
by adding many fdb entries in SR-IOV modes.

Also this includes a small refactor to fdb_add() to avoid having so
many nested if/else statements after adding a check for the number
or RAR entries.

The max entries for the PF is currently 16 we allow 15 additional
entries to account for the defined MAC.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   27 +++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b376926..84370e7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3441,14 +3441,18 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	unsigned int rar_entries = IXGBE_MAX_PF_MACVLANS;
+	unsigned int rar_entries = hw->mac.num_rar_entries - 1;
 	int count = 0;
 
+	/* In SR-IOV mode significantly less RAR entries are available */
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		rar_entries = IXGBE_MAX_PF_MACVLANS - 1;
+
 	/* return ENOMEM indicating insufficient memory for addresses */
 	if (netdev_uc_count(netdev) > rar_entries)
 		return -ENOMEM;
 
-	if (!netdev_uc_empty(netdev) && rar_entries) {
+	if (!netdev_uc_empty(netdev)) {
 		struct netdev_hw_addr *ha;
 		/* return error if we do not support writing to RAR table */
 		if (!hw->mac.ops.set_rar)
@@ -6861,7 +6865,10 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm,
 			     u16 flags)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int err = -EOPNOTSUPP;
+	int err;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return -EOPNOTSUPP;
 
 	if (ndm->ndm_state & NUD_PERMANENT) {
 		pr_info("%s: FDB only supports static addresses\n",
@@ -6869,13 +6876,17 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm,
 		return -EINVAL;
 	}
 
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		if (is_unicast_ether_addr(addr))
+	if (is_unicast_ether_addr(addr)) {
+		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
+
+		if (netdev_uc_count(dev) < rar_uc_entries)
 			err = dev_uc_add_excl(dev, addr);
-		else if (is_multicast_ether_addr(addr))
-			err = dev_mc_add_excl(dev, addr);
 		else
-			err = -EINVAL;
+			err = -ENOMEM;
+	} else if (is_multicast_ether_addr(addr)) {
+		err = dev_mc_add_excl(dev, addr);
+	} else {
+		err = -EINVAL;
 	}
 
 	/* Only return duplicate errors if NLM_F_EXCL is set */
-- 
1.7.10.4
