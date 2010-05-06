From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: Streamline MC filter setup for VFs
Date: Wed, 05 May 2010 22:57:30 -0700
Message-ID: <20100506055728.8482.77386.stgit@localhost.localdomain>
References: <20100506055703.8482.16515.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:51238 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab0EFF5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 01:57:47 -0400
In-Reply-To: <20100506055703.8482.16515.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The driver was calling the set Rx mode function for every multicast
filter set by the VF.  When starting many VMs where each might have
multiple VLAN interfaces this would result in the function being
called hundreds or even thousands of times.  This is unnecessary
for the case of the imperfect filters used in the MTA and has been
streamlined to be more efficient.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_sriov.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index c4e5150..f6cee94 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -48,7 +48,11 @@ int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 			    int entries, u16 *hash_list, u32 vf)
 {
 	struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
+	u32 vector_bit;
+	u32 vector_reg;
+	u32 mta_reg;
 
 	/* only so many hash values supported */
 	entries = min(entries, IXGBE_MAX_VF_MC_ENTRIES);
@@ -68,8 +72,13 @@ int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
 		vfinfo->vf_mc_hashes[i] = hash_list[i];;
 	}
 
-	/* Flush and reset the mta with the new values */
-	ixgbe_set_rx_mode(adapter->netdev);
+	for (i = 0; i < vfinfo->num_vf_mc_hashes; i++) {
+		vector_reg = (vfinfo->vf_mc_hashes[i] >> 5) & 0x7F;
+		vector_bit = vfinfo->vf_mc_hashes[i] & 0x1F;
+		mta_reg = IXGBE_READ_REG(hw, IXGBE_MTA(vector_reg));
+		mta_reg |= (1 << vector_bit);
+		IXGBE_WRITE_REG(hw, IXGBE_MTA(vector_reg), mta_reg);
+	}
 
 	return 0;
 }

