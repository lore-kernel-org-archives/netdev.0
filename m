From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/21] ixgbe: test for trust in macvlan adjustments for VF
Date: Tue,  3 Jan 2017 13:07:46 -0800
Message-ID: <20170103210757.38847-11-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Ken Cox <jkc@redhat.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966078AbdACVIM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:12 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Cox <jkc@redhat.com>

There are two methods for setting mac addresses in a Macvlan, that
differentiate themselves in the function macvlan_set_mac_Address.
If the macvlan mode is passthru, then we use the dev_set_mac_address
method, otherwise we use the dev_uc api via macvlan_sync_addresses.
The latter method (which would stem from using any non-passthru mode,
like bridge, or vepa), calls down into the driver in a path that terminates
in ixgbevf_set_uc_addr_vf, which sends a IXGBE_VF_SET_MACVLAN message,
which causes the pf to spawn the noted error message.  This occurs because
it appears that the guest is trying to delete the mac address of the macvlan
before adding another.

The other path in macvlan_set_mac_address uses dev_set_mac_address, which
calls into ixgbevf_set_mac which uses the IXGBE_VF_SET_MAC_ADDR to the
pf to set the macvlan mac address.

The discrepancy here is in the handlers.  The handler function for
IXGBE_VF_SET_MAC_ADDR (ixgbe_set_vf_mac_addr) has a check for
the vfinfo[].trusted bit to allow the operation if the vf is trusted.
In comparison, the IXGBE_VF_SET_MACVLAN message handler
(ixgbe_set_vf_macvlan_msg) has no such check of the trusted bit.

Signed-off-by: Ken Cox <jkc@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 7e5d985..dd1187c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -934,7 +934,8 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adapter *adapter,
 		    IXGBE_VT_MSGINFO_SHIFT;
 	int err;
 
-	if (adapter->vfinfo[vf].pf_set_mac && index > 0) {
+	if (adapter->vfinfo[vf].pf_set_mac && !adapter->vfinfo[vf].trusted &&
+	    index > 0) {
 		e_warn(drv,
 		       "VF %d requested MACVLAN filter but is administratively denied\n",
 		       vf);
-- 
2.9.3
