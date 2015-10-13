From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] ixgbe: add flow control ethertype to the anti-spoofing filter
Date: Mon, 12 Oct 2015 22:53:16 -0700
Message-ID: <1444715598-20970-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65148 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbbJMFx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:27 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch makes sure that flow control packets initiated by the VF are
dropped and reported as spoofed.

Flow control packets can be used to limit the throughput or as DOS
attack when generated from a VF. Flow control is not supported per VF
hence any pause frames generated from a VF are considered malicious.

Also cleaned up indentation and some redundant comments.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 16 +++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  4 ++++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1910039..c4608f8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3723,14 +3723,20 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	hw->mac.ops.set_mac_anti_spoofing(hw, (adapter->num_vfs != 0),
 					  adapter->num_vfs);
 
-	/* Ensure LLDP is set for Ethertype Antispoofing if we will be
+	/* Ensure LLDP and FC is set for Ethertype Antispoofing if we will be
 	 * calling set_ethertype_anti_spoofing for each VF in loop below
 	 */
-	if (hw->mac.ops.set_ethertype_anti_spoofing)
+	if (hw->mac.ops.set_ethertype_anti_spoofing) {
 		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_LLDP),
-				(IXGBE_ETQF_FILTER_EN    | /* enable filter */
-				 IXGBE_ETQF_TX_ANTISPOOF | /* tx antispoof */
-				 IXGBE_ETH_P_LLDP));	   /* LLDP eth type */
+				(IXGBE_ETQF_FILTER_EN    |
+				 IXGBE_ETQF_TX_ANTISPOOF |
+				 IXGBE_ETH_P_LLDP));
+
+		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FC),
+				(IXGBE_ETQF_FILTER_EN |
+				 IXGBE_ETQF_TX_ANTISPOOF |
+				 ETH_P_PAUSE));
+	}
 
 	/* For VFs that have spoof checking turned off */
 	for (i = 0; i < adapter->num_vfs; i++) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 939c90c..995f031 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1752,6 +1752,9 @@ enum {
  *    FCoE (0x8906):         Filter 2
  *    1588 (0x88f7):         Filter 3
  *    FIP  (0x8914):         Filter 4
+ *    LLDP (0x88CC):         Filter 5
+ *    LACP (0x8809):         Filter 6
+ *    FC   (0x8808):         Filter 7
  */
 #define IXGBE_ETQF_FILTER_EAPOL          0
 #define IXGBE_ETQF_FILTER_FCOE           2
@@ -1759,6 +1762,7 @@ enum {
 #define IXGBE_ETQF_FILTER_FIP            4
 #define IXGBE_ETQF_FILTER_LLDP		 5
 #define IXGBE_ETQF_FILTER_LACP		 6
+#define IXGBE_ETQF_FILTER_FC		 7
 
 /* VLAN Control Bit Masks */
 #define IXGBE_VLNCTRL_VET       0x0000FFFF  /* bits 0-15 */
-- 
2.4.3
