From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/2] ixgbe: Force QDE via PFQDE for VFs during reset
Date: Wed, 15 Jan 2014 17:38:40 -0800
Message-ID: <1389836321-17013-2-git-send-email-aaron.f.brown@intel.com>
References: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31147 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbaAPBij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 20:38:39 -0500
In-Reply-To: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the QDE bits are set for a VF before the Rx
queues are enabled.  As such we avoid head of line blocking in the event
that the VF stops cleaning Rx descriptors for whatever reason.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>

 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   14 ++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    7 ++++---
 2 files changed, 18 insertions(+), 3 deletions(-)
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 14 ++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  7 ++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 359f6e6..43e10c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -631,11 +631,14 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 
 static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 {
+	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
 	struct ixgbe_hw *hw = &adapter->hw;
 	unsigned char *vf_mac = adapter->vfinfo[vf].vf_mac_addresses;
 	u32 reg, reg_offset, vf_shift;
 	u32 msgbuf[4] = {0, 0, 0, 0};
 	u8 *addr = (u8 *)(&msgbuf[1]);
+	u32 q_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
+	int i;
 
 	e_info(probe, "VF Reset msg received from vf %d\n", vf);
 
@@ -654,6 +657,17 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	reg |= 1 << vf_shift;
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), reg);
 
+	/* force drop enable for all VF Rx queues */
+	for (i = vf * q_per_pool; i < ((vf + 1) * q_per_pool); i++) {
+		/* flush previous write */
+		IXGBE_WRITE_FLUSH(hw);
+
+		/* indicate to hardware that we want to set drop enable */
+		reg = IXGBE_QDE_WRITE | IXGBE_QDE_ENABLE;
+		reg |= i <<  IXGBE_QDE_IDX_SHIFT;
+		IXGBE_WRITE_REG(hw, IXGBE_QDE, reg);
+	}
+
 	/* enable receive for vf */
 	reg = IXGBE_READ_REG(hw, IXGBE_VFRE(reg_offset));
 	reg |= 1 << vf_shift;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7c19e96..d8e59f4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1980,9 +1980,10 @@ enum {
 #define IXGBE_FWSM_TS_ENABLED	0x1
 
 /* Queue Drop Enable */
-#define IXGBE_QDE_ENABLE     0x00000001
-#define IXGBE_QDE_IDX_MASK   0x00007F00
-#define IXGBE_QDE_IDX_SHIFT           8
+#define IXGBE_QDE_ENABLE	0x00000001
+#define IXGBE_QDE_IDX_MASK	0x00007F00
+#define IXGBE_QDE_IDX_SHIFT	8
+#define IXGBE_QDE_WRITE		0x00010000
 
 #define IXGBE_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
 #define IXGBE_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
-- 
1.8.5.GIT
