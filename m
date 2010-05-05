From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ixgbe: Add boolean parameter to
	ixgbe_set_vmolr
Date: Wed, 05 May 2010 01:11:46 -0700
Message-ID: <20100505081129.5709.39430.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:45952 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932387Ab0EEIME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add a boolean parameter to ixgbe-set_vmolr so that the caller can
specify whether the pool should accept untagged packets.  Required
for a follow on patch to enable administrative configuration of port
VLAN for virtual functions.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c  |    2 +-
 drivers/net/ixgbe/ixgbe_sriov.c |   11 +++++++----
 drivers/net/ixgbe/ixgbe_sriov.h |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2ae5a51..0a0e90e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2722,7 +2722,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
 		IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
 		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-		ixgbe_set_vmolr(hw, adapter->num_vfs);
+		ixgbe_set_vmolr(hw, adapter->num_vfs, true);
 	}
 
 	/* Program MRQC for the distribution of queues */
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index d4cd20f..53f364d 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -113,13 +113,16 @@ int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid, u32 vf)
 }
 
 
-void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf)
+void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 {
 	u32 vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
-	vmolr |= (IXGBE_VMOLR_AUPE |
-		  IXGBE_VMOLR_ROMPE |
+	vmolr |= (IXGBE_VMOLR_ROMPE |
 		  IXGBE_VMOLR_ROPE |
 		  IXGBE_VMOLR_BAM);
+	if (aupe)
+		vmolr |= IXGBE_VMOLR_AUPE;
+	else
+		vmolr &= ~IXGBE_VMOLR_AUPE;
 	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
 }
 
@@ -128,7 +131,7 @@ inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	/* reset offloads to defaults */
-	ixgbe_set_vmolr(hw, vf);
+	ixgbe_set_vmolr(hw, vf, true);
 
 
 	/* reset multicast table array for vf */
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index 51d1106..7fb1288 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -32,7 +32,7 @@ int ixgbe_set_vf_multicasts(struct ixgbe_adapter *adapter,
                             int entries, u16 *hash_list, u32 vf);
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
 int ixgbe_set_vf_vlan(struct ixgbe_adapter *adapter, int add, int vid, u32 vf);
-void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf);
+void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe);
 void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf);
 void ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf);
 void ixgbe_msg_task(struct ixgbe_adapter *adapter);

