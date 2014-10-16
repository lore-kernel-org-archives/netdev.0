From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] ixgbe: check for vfs outside of sriov_num_vfs before dereference
Date: Thu, 16 Oct 2014 02:36:27 -0700
Message-ID: <1413452187-2950-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32154 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbaJPJgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 05:36:32 -0400
In-Reply-To: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The check for vfinfo is not sufficient because it does not protect
against specifying vf that is outside of sriov_num_vfs range.
All of the ndo functions have a check for it except for
ixgbevf_ndo_set_spoofcheck().

The following patch is all we need to protect against this panic:

ip link set p96p1 vf 0 spoofchk off
BUG: unable to handle kernel NULL pointer dereference at 0000000000000052
IP: [<ffffffffa044a1c1>]
ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]

Reported-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Thierry Herbelot <thierry.herbelot@6wind.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 706fc69..97c85b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1261,6 +1261,9 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 regval;
 
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
 	adapter->vfinfo[vf].spoofchk_enabled = setting;
 
 	regval = IXGBE_READ_REG(hw, IXGBE_PFVFSPOOF(vf_target_reg));
-- 
1.9.3
