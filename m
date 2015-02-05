From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] ixgbevf: add RSS support for X550
Date: Thu,  5 Feb 2015 01:35:40 -0800
Message-ID: <1423128950-12388-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55144 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756684AbbBEJgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:05 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

X550 provides RSS registers for configuring RSS per VF.

This patch introduces ixgbevf_setup_vfmrqc() which uses the VFRETA,
VFRSSRK and VFMRQC registers to configure RSS on X550.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 35 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/regs.h         | 10 +++++++
 2 files changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 815808f..41fca1b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1584,6 +1584,39 @@ static void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
 		       reg_idx);
 }
 
+static void ixgbevf_setup_vfmrqc(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vfmrqc = 0, vfreta = 0;
+	u32 rss_key[10];
+	u16 rss_i = adapter->num_rx_queues;
+	int i, j;
+
+	/* Fill out hash function seeds */
+	netdev_rss_key_fill(rss_key, sizeof(rss_key));
+	for (i = 0; i < 10; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFRSSRK(i), rss_key[i]);
+
+	/* Fill out redirection table */
+	for (i = 0, j = 0; i < 64; i++, j++) {
+		if (j == rss_i)
+			j = 0;
+		vfreta = (vfreta << 8) | (j * 0x1);
+		if ((i & 3) == 3)
+			IXGBE_WRITE_REG(hw, IXGBE_VFRETA(i >> 2), vfreta);
+	}
+
+	/* Perform hash on these packet types */
+	vfmrqc |= IXGBE_VFMRQC_RSS_FIELD_IPV4 |
+		IXGBE_VFMRQC_RSS_FIELD_IPV4_TCP |
+		IXGBE_VFMRQC_RSS_FIELD_IPV6 |
+		IXGBE_VFMRQC_RSS_FIELD_IPV6_TCP;
+
+	vfmrqc |= IXGBE_VFMRQC_RSSEN;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VFMRQC, vfmrqc);
+}
+
 static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 				      struct ixgbevf_ring *ring)
 {
@@ -1640,6 +1673,8 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 
 	ixgbevf_setup_psrtype(adapter);
+	if (hw->mac.type >= ixgbe_mac_X550_vf)
+		ixgbevf_setup_vfmrqc(adapter);
 
 	/* notify the PF of our intent to use this size of frame */
 	ixgbevf_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
diff --git a/drivers/net/ethernet/intel/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
index 09dd8f6..3e712fd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/regs.h
+++ b/drivers/net/ethernet/intel/ixgbevf/regs.h
@@ -69,6 +69,16 @@
 #define IXGBE_VFGOTC_LSB       0x02020
 #define IXGBE_VFGOTC_MSB       0x02024
 #define IXGBE_VFMPRC           0x01034
+#define IXGBE_VFMRQC           0x3000
+#define IXGBE_VFRSSRK(x)       (0x3100 + ((x) * 4))
+#define IXGBE_VFRETA(x)        (0x3200 + ((x) * 4))
+
+/* VFMRQC bits */
+#define IXGBE_VFMRQC_RSSEN              0x00000001  /* RSS Enable */
+#define IXGBE_VFMRQC_RSS_FIELD_IPV4_TCP 0x00010000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV4     0x00020000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV6     0x00100000
+#define IXGBE_VFMRQC_RSS_FIELD_IPV6_TCP 0x00200000
 
 #define IXGBE_WRITE_FLUSH(a) (IXGBE_READ_REG(a, IXGBE_VFSTATUS))
 
-- 
1.9.3
