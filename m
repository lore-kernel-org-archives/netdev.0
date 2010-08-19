From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/20] ixgbe: Move virtualization config into a
	separate function
Date: Thu, 19 Aug 2010 16:38:57 -0700
Message-ID: <20100819233854.10335.15538.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:38929
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0HSXjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:39:18 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves the configuration that was done in configure_rx into a
separate virtualization configuration function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   84 ++++++++++++++++++++++------------------
 1 files changed, 46 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f8cdc99..d358bef 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2696,6 +2696,48 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 				psrtype);
 }
 
+static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 gcr_ext;
+	u32 vt_reg_bits;
+	u32 reg_offset, vf_shift;
+	u32 vmdctl;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return;
+
+	vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
+	vt_reg_bits = IXGBE_VMD_CTL_VMDQ_EN | IXGBE_VT_CTL_REPLEN;
+	vt_reg_bits |= (adapter->num_vfs << IXGBE_VT_CTL_POOL_SHIFT);
+	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl | vt_reg_bits);
+
+	vf_shift = adapter->num_vfs % 32;
+	reg_offset = (adapter->num_vfs > 32) ? 1 : 0;
+
+	/* Enable only the PF's pool for Tx/Rx */
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+
+	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
+	hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
+
+	/*
+	 * Set up VF register offsets for selected VT Mode,
+	 * i.e. 32 or 64 VFs for SR-IOV
+	 */
+	gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
+	gcr_ext |= IXGBE_GCR_EXT_MSIX_EN;
+	gcr_ext |= IXGBE_GCR_EXT_VT_MODE_64;
+	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
+
+	/* enable Tx loopback for VF/PF communication */
+	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+}
+
 static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -2820,7 +2862,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *rx_ring;
 	int i;
 	u32 rxctrl;
-	u32 gcr_ext;
 
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
@@ -2829,6 +2870,10 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	ixgbe_setup_psrtype(adapter);
 	ixgbe_setup_rdrxctl(adapter);
 
+	/* Program MRQC for the distribution of queues */
+	ixgbe_setup_mrqc(adapter);
+	ixgbe_configure_virtualization(adapter);
+
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbe_set_rx_buffer_len(adapter);
 
@@ -2843,43 +2888,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		ixgbe_configure_rscctl(adapter, rx_ring);
 	}
 
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		u32 vt_reg_bits;
-		u32 reg_offset, vf_shift;
-		u32 vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
-		vt_reg_bits = IXGBE_VMD_CTL_VMDQ_EN
-			| IXGBE_VT_CTL_REPLEN;
-		vt_reg_bits |= (adapter->num_vfs <<
-				IXGBE_VT_CTL_POOL_SHIFT);
-		IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl | vt_reg_bits);
-		IXGBE_WRITE_REG(hw, IXGBE_MRQC, 0);
-
-		vf_shift = adapter->num_vfs % 32;
-		reg_offset = adapter->num_vfs / 32;
-		IXGBE_WRITE_REG(hw, IXGBE_VFRE(0), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_VFRE(1), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_VFTE(0), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_VFTE(1), 0);
-		/* Enable only the PF's pool for Tx/Rx */
-		IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
-		IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
-		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-	}
-
-	/* Program MRQC for the distribution of queues */
-	ixgbe_setup_mrqc(adapter);
-
-	if (adapter->num_vfs) {
-		/* Map PF MAC address in RAR Entry 0 to first pool
-		 * following VFs */
-		hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
-
-		/* Set up VF register offsets for selected VT Mode, i.e.
-		 * 64 VFs for SR-IOV */
-		gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
-		gcr_ext |= IXGBE_GCR_EXT_SRIOV;
-		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
-	}
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)

