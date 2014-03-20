From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] igb: enable VLAN stripping for VMs with i350
Date: Thu, 20 Mar 2014 01:32:51 -0700
Message-ID: <1395304385-6874-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755533AbaCTIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:48 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

For i350 VLAN stripping for VMs is not enabled in the VMOLR register but in
the DVMOLR register. Making the changes accordingly. It's not necessary to
unset the E1000_VMOLR_STRVLAN bit on i350 as the hardware will simply ignore
it.

Without this change if a VLAN is configured for a VF assigned to a guest
via (i.e.)
ip link set p1p1 vf 0 vlan 10
the VLAN tag will not be stripped from packets going into the VM. Which they
should be because the VM itself is not aware of the VLAN at all.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h | 4 ++++
 drivers/net/ethernet/intel/igb/e1000_regs.h  | 1 +
 drivers/net/ethernet/intel/igb/igb_main.c    | 7 +++++++
 3 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 2a721a1..09d78be 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -230,6 +230,10 @@ struct e1000_adv_tx_context_desc {
 #define E1000_VMOLR_STRVLAN    0x40000000 /* Vlan stripping enable */
 #define E1000_VMOLR_STRCRC     0x80000000 /* CRC stripping enable */
 
+#define E1000_DVMOLR_HIDEVLAN  0x20000000 /* Hide vlan enable */
+#define E1000_DVMOLR_STRVLAN   0x40000000 /* Vlan stripping enable */
+#define E1000_DVMOLR_STRCRC    0x80000000 /* CRC stripping enable */
+
 #define E1000_VLVF_ARRAY_SIZE     32
 #define E1000_VLVF_VLANID_MASK    0x00000FFF
 #define E1000_VLVF_POOLSEL_SHIFT  12
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index e9c5fdd..d0f14be 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -357,6 +357,7 @@
 #define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
 #define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
 #define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
+#define E1000_DVMOLR(_n)       (0x0C038 + (64 * (_n)))
 #define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine
                                                        * Filter - RW */
 #define E1000_VMVIR(_n)        (0x03700 + (4 * (_n)))
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ac06492..313e1a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3542,6 +3542,13 @@ static inline void igb_set_vmolr(struct igb_adapter *adapter,
 
 	vmolr = rd32(E1000_VMOLR(vfn));
 	vmolr |= E1000_VMOLR_STRVLAN; /* Strip vlan tags */
+	if (hw->mac.type == e1000_i350) {
+		u32 dvmolr;
+
+		dvmolr = rd32(E1000_DVMOLR(vfn));
+		dvmolr |= E1000_DVMOLR_STRVLAN;
+		wr32(E1000_DVMOLR(vfn), dvmolr);
+	}
 	if (aupe)
 		vmolr |= E1000_VMOLR_AUPE; /* Accept untagged packets */
 	else
-- 
1.8.3.1
