From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] igb: Retain HW VLAN filtering while in promiscuous + VT mode
Date: Wed, 24 Apr 2013 21:08:44 -0700
Message-ID: <1366862927-1855-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15281 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab3DYEJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:09:10 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When using the new bridge FDB interface to allow SR-IOV virtual function
network devices to communicate with SW bridged network devices the
physical function is placed into promiscuous mode and hardware VLAN
filtering is disabled.  This defeats the ability to use VLAN tagging
to isolate user networks.  When the device is in promiscuous mode and
VT mode simultaneously ensure that VLAN hardware filtering remains
enabled.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 69 ++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 93be6ec..59a28fe 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3736,6 +3736,10 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE | E1000_RCTL_VFE);
 
 	if (netdev->flags & IFF_PROMISC) {
+		u32 mrqc = rd32(E1000_MRQC);
+		/* retain VLAN HW filtering if in VT mode */
+		if (mrqc & E1000_MRQC_ENABLE_VMDQ)
+			rctl |= E1000_RCTL_VFE;
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 		vmolr |= (E1000_VMOLR_ROPE | E1000_VMOLR_MPME);
 	} else {
@@ -5520,12 +5524,75 @@ out:
 	return err;
 }
 
+static int igb_find_vlvf_entry(struct igb_adapter *adapter, int vid)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+	u32 reg;
+
+	/* Find the vlan filter for this id */
+	for (i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+		reg = rd32(E1000_VLVF(i));
+		if ((reg & E1000_VLVF_VLANID_ENABLE) &&
+		    vid == (reg & E1000_VLVF_VLANID_MASK))
+			break;
+	}
+
+	if (i >= E1000_VLVF_ARRAY_SIZE)
+		i = -1;
+
+	return i;
+}
+
 static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	int add = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
 	int vid = (msgbuf[1] & E1000_VLVF_VLANID_MASK);
+	int err = 0;
 
-	return igb_vlvf_set(adapter, vid, add, vf);
+	/* If in promiscuous mode we need to make sure the PF also has
+	 * the VLAN filter set.
+	 */
+	if (add && (adapter->netdev->flags & IFF_PROMISC))
+		err = igb_vlvf_set(adapter, vid, add,
+				   adapter->vfs_allocated_count);
+	if (err)
+		goto out;
+
+	err = igb_vlvf_set(adapter, vid, add, vf);
+
+	if (err)
+		goto out;
+
+	/* Go through all the checks to see if the VLAN filter should
+	 * be wiped completely.
+	 */
+	if (!add && (adapter->netdev->flags & IFF_PROMISC)) {
+		u32 vlvf, bits;
+
+		int regndx = igb_find_vlvf_entry(adapter, vid);
+		if (regndx < 0)
+			goto out;
+		/* See if any other pools are set for this VLAN filter
+		 * entry other than the PF.
+		 */
+		vlvf = bits = rd32(E1000_VLVF(regndx));
+		bits &= 1 << (E1000_VLVF_POOLSEL_SHIFT +
+			      adapter->vfs_allocated_count);
+		/* If the filter was removed then ensure PF pool bit
+		 * is cleared if the PF only added itself to the pool
+		 * because the PF is in promiscuous mode.
+		 */
+		if ((vlvf & VLAN_VID_MASK) == vid &&
+		    !test_bit(vid, adapter->active_vlans) &&
+		    !bits)
+			igb_vlvf_set(adapter, vid, add,
+				     adapter->vfs_allocated_count);
+	}
+
+out:
+	return err;
 }
 
 static inline void igb_vf_reset(struct igb_adapter *adapter, u32 vf)
-- 
1.7.11.7
