From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 07/29] fm10k: Add support for PF
Date: Sat, 20 Sep 2014 19:47:46 -0400
Message-ID: <20140920234739.2977.43570.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8494 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbaITX4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:56:35 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic support for the PF.  With this it is possible to
bring up the interface, but without being able to configure any of the
filters on the interface itself.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile       |    3 
 drivers/net/ethernet/intel/fm10k/fm10k_common.c |  534 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_common.h |   13 +
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     |  392 +++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h     |   28 +
 5 files changed, 969 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_common.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pf.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pf.h

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index 6642611..0904bcb 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -27,5 +27,6 @@
 
 obj-$(CONFIG_FM10K) += fm10k.o
 
-fm10k-objs := fm10k_main.o fm10k_pci.o \
+fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
+	      fm10k_pf.o \
 	      fm10k_mbx.o fm10k_tlv.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
new file mode 100644
index 0000000..bf19dcc
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -0,0 +1,534 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k_common.h"
+
+/**
+ *  fm10k_get_bus_info_generic - Generic set PCI bus info
+ *  @hw: pointer to hardware structure
+ *
+ *  Gets the PCI bus info (speed, width, type) then calls helper function to
+ *  store this data within the fm10k_hw structure.
+ **/
+s32 fm10k_get_bus_info_generic(struct fm10k_hw *hw)
+{
+	u16 link_cap, link_status, device_cap, device_control;
+
+	/* Get the maximum link width and speed from PCIe config space */
+	link_cap = fm10k_read_pci_cfg_word(hw, FM10K_PCIE_LINK_CAP);
+
+	switch (link_cap & FM10K_PCIE_LINK_WIDTH) {
+	case FM10K_PCIE_LINK_WIDTH_1:
+		hw->bus_caps.width = fm10k_bus_width_pcie_x1;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_2:
+		hw->bus_caps.width = fm10k_bus_width_pcie_x2;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_4:
+		hw->bus_caps.width = fm10k_bus_width_pcie_x4;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_8:
+		hw->bus_caps.width = fm10k_bus_width_pcie_x8;
+		break;
+	default:
+		hw->bus_caps.width = fm10k_bus_width_unknown;
+		break;
+	}
+
+	switch (link_cap & FM10K_PCIE_LINK_SPEED) {
+	case FM10K_PCIE_LINK_SPEED_2500:
+		hw->bus_caps.speed = fm10k_bus_speed_2500;
+		break;
+	case FM10K_PCIE_LINK_SPEED_5000:
+		hw->bus_caps.speed = fm10k_bus_speed_5000;
+		break;
+	case FM10K_PCIE_LINK_SPEED_8000:
+		hw->bus_caps.speed = fm10k_bus_speed_8000;
+		break;
+	default:
+		hw->bus_caps.speed = fm10k_bus_speed_unknown;
+		break;
+	}
+
+	/* Get the PCIe maximum payload size for the PCIe function */
+	device_cap = fm10k_read_pci_cfg_word(hw, FM10K_PCIE_DEV_CAP);
+
+	switch (device_cap & FM10K_PCIE_DEV_CAP_PAYLOAD) {
+	case FM10K_PCIE_DEV_CAP_PAYLOAD_128:
+		hw->bus_caps.payload = fm10k_bus_payload_128;
+		break;
+	case FM10K_PCIE_DEV_CAP_PAYLOAD_256:
+		hw->bus_caps.payload = fm10k_bus_payload_256;
+		break;
+	case FM10K_PCIE_DEV_CAP_PAYLOAD_512:
+		hw->bus_caps.payload = fm10k_bus_payload_512;
+		break;
+	default:
+		hw->bus_caps.payload = fm10k_bus_payload_unknown;
+		break;
+	}
+
+	/* Get the negotiated link width and speed from PCIe config space */
+	link_status = fm10k_read_pci_cfg_word(hw, FM10K_PCIE_LINK_STATUS);
+
+	switch (link_status & FM10K_PCIE_LINK_WIDTH) {
+	case FM10K_PCIE_LINK_WIDTH_1:
+		hw->bus.width = fm10k_bus_width_pcie_x1;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_2:
+		hw->bus.width = fm10k_bus_width_pcie_x2;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_4:
+		hw->bus.width = fm10k_bus_width_pcie_x4;
+		break;
+	case FM10K_PCIE_LINK_WIDTH_8:
+		hw->bus.width = fm10k_bus_width_pcie_x8;
+		break;
+	default:
+		hw->bus.width = fm10k_bus_width_unknown;
+		break;
+	}
+
+	switch (link_status & FM10K_PCIE_LINK_SPEED) {
+	case FM10K_PCIE_LINK_SPEED_2500:
+		hw->bus.speed = fm10k_bus_speed_2500;
+		break;
+	case FM10K_PCIE_LINK_SPEED_5000:
+		hw->bus.speed = fm10k_bus_speed_5000;
+		break;
+	case FM10K_PCIE_LINK_SPEED_8000:
+		hw->bus.speed = fm10k_bus_speed_8000;
+		break;
+	default:
+		hw->bus.speed = fm10k_bus_speed_unknown;
+		break;
+	}
+
+	/* Get the negotiated PCIe maximum payload size for the PCIe function */
+	device_control = fm10k_read_pci_cfg_word(hw, FM10K_PCIE_DEV_CTRL);
+
+	switch (device_control & FM10K_PCIE_DEV_CTRL_PAYLOAD) {
+	case FM10K_PCIE_DEV_CTRL_PAYLOAD_128:
+		hw->bus.payload = fm10k_bus_payload_128;
+		break;
+	case FM10K_PCIE_DEV_CTRL_PAYLOAD_256:
+		hw->bus.payload = fm10k_bus_payload_256;
+		break;
+	case FM10K_PCIE_DEV_CTRL_PAYLOAD_512:
+		hw->bus.payload = fm10k_bus_payload_512;
+		break;
+	default:
+		hw->bus.payload = fm10k_bus_payload_unknown;
+		break;
+	}
+
+	return 0;
+}
+
+static u16 fm10k_get_pcie_msix_count_generic(struct fm10k_hw *hw)
+{
+	u16 msix_count;
+
+	/* read in value from MSI-X capability register */
+	msix_count = fm10k_read_pci_cfg_word(hw, FM10K_PCI_MSIX_MSG_CTRL);
+	msix_count &= FM10K_PCI_MSIX_MSG_CTRL_TBL_SZ_MASK;
+
+	/* MSI-X count is zero-based in HW */
+	msix_count++;
+
+	if (msix_count > FM10K_MAX_MSIX_VECTORS)
+		msix_count = FM10K_MAX_MSIX_VECTORS;
+
+	return msix_count;
+}
+
+/**
+ *  fm10k_get_invariants_generic - Inits constant values
+ *  @hw: pointer to the hardware structure
+ *
+ *  Initialize the common invariants for the device.
+ **/
+s32 fm10k_get_invariants_generic(struct fm10k_hw *hw)
+{
+	struct fm10k_mac_info *mac = &hw->mac;
+
+	/* initialize GLORT state to avoid any false hits */
+	mac->dglort_map = FM10K_DGLORTMAP_NONE;
+
+	/* record maximum number of MSI-X vectors */
+	mac->max_msix_vectors = fm10k_get_pcie_msix_count_generic(hw);
+
+	return 0;
+}
+
+/**
+ *  fm10k_start_hw_generic - Prepare hardware for Tx/Rx
+ *  @hw: pointer to hardware structure
+ *
+ *  This function sets the Tx ready flag to indicate that the Tx path has
+ *  been initialized.
+ **/
+s32 fm10k_start_hw_generic(struct fm10k_hw *hw)
+{
+	/* set flag indicating we are beginning Tx */
+	hw->mac.tx_ready = true;
+
+	return 0;
+}
+
+/**
+ *  fm10k_disable_queues_generic - Stop Tx/Rx queues
+ *  @hw: pointer to hardware structure
+ *  @q_cnt: number of queues to be disabled
+ *
+ **/
+s32 fm10k_disable_queues_generic(struct fm10k_hw *hw, u16 q_cnt)
+{
+	u32 reg;
+	u16 i, time;
+
+	/* clear tx_ready to prevent any false hits for reset */
+	hw->mac.tx_ready = false;
+
+	/* clear the enable bit for all rings */
+	for (i = 0; i < q_cnt; i++) {
+		reg = fm10k_read_reg(hw, FM10K_TXDCTL(i));
+		fm10k_write_reg(hw, FM10K_TXDCTL(i),
+				reg & ~FM10K_TXDCTL_ENABLE);
+		reg = fm10k_read_reg(hw, FM10K_RXQCTL(i));
+		fm10k_write_reg(hw, FM10K_RXQCTL(i),
+				reg & ~FM10K_RXQCTL_ENABLE);
+	}
+
+	fm10k_write_flush(hw);
+	udelay(1);
+
+	/* loop through all queues to verify that they are all disabled */
+	for (i = 0, time = FM10K_QUEUE_DISABLE_TIMEOUT; time;) {
+		/* if we are at end of rings all rings are disabled */
+		if (i == q_cnt)
+			return 0;
+
+		/* if queue enables cleared, then move to next ring pair */
+		reg = fm10k_read_reg(hw, FM10K_TXDCTL(i));
+		if (!~reg || !(reg & FM10K_TXDCTL_ENABLE)) {
+			reg = fm10k_read_reg(hw, FM10K_RXQCTL(i));
+			if (!~reg || !(reg & FM10K_RXQCTL_ENABLE)) {
+				i++;
+				continue;
+			}
+		}
+
+		/* decrement time and wait 1 usec */
+		time--;
+		if (time)
+			udelay(1);
+	}
+
+	return FM10K_ERR_REQUESTS_PENDING;
+}
+
+/**
+ *  fm10k_stop_hw_generic - Stop Tx/Rx units
+ *  @hw: pointer to hardware structure
+ *
+ **/
+s32 fm10k_stop_hw_generic(struct fm10k_hw *hw)
+{
+	return fm10k_disable_queues_generic(hw, hw->mac.max_queues);
+}
+
+/**
+ *  fm10k_read_hw_stats_32b - Reads value of 32-bit registers
+ *  @hw: pointer to the hardware structure
+ *  @addr: address of register containing a 32-bit value
+ *
+ *  Function reads the content of the register and returns the delta
+ *  between the base and the current value.
+ *  **/
+u32 fm10k_read_hw_stats_32b(struct fm10k_hw *hw, u32 addr,
+			    struct fm10k_hw_stat *stat)
+{
+	u32 delta = fm10k_read_reg(hw, addr) - stat->base_l;
+
+	if (FM10K_REMOVED(hw->hw_addr))
+		stat->base_h = 0;
+
+	return delta;
+}
+
+/**
+ *  fm10k_read_hw_stats_48b - Reads value of 48-bit registers
+ *  @hw: pointer to the hardware structure
+ *  @addr: address of register containing the lower 32-bit value
+ *
+ *  Function reads the content of 2 registers, combined to represent a 48-bit
+ *  statistical value. Extra processing is required to handle overflowing.
+ *  Finally, a delta value is returned representing the difference between the
+ *  values stored in registers and values stored in the statistic counters.
+ *  **/
+static u64 fm10k_read_hw_stats_48b(struct fm10k_hw *hw, u32 addr,
+				   struct fm10k_hw_stat *stat)
+{
+	u32 count_l;
+	u32 count_h;
+	u32 count_tmp;
+	u64 delta;
+
+	count_h = fm10k_read_reg(hw, addr + 1);
+
+	/* Check for overflow */
+	do {
+		count_tmp = count_h;
+		count_l = fm10k_read_reg(hw, addr);
+		count_h = fm10k_read_reg(hw, addr + 1);
+	} while (count_h != count_tmp);
+
+	delta = ((u64)(count_h - stat->base_h) << 32) + count_l;
+	delta -= stat->base_l;
+
+	return delta & FM10K_48_BIT_MASK;
+}
+
+/**
+ *  fm10k_update_hw_base_48b - Updates 48-bit statistic base value
+ *  @stat: pointer to the hardware statistic structure
+ *  @delta: value to be updated into the hardware statistic structure
+ *
+ *  Function receives a value and determines if an update is required based on
+ *  a delta calculation. Only the base value will be updated.
+ **/
+static void fm10k_update_hw_base_48b(struct fm10k_hw_stat *stat, u64 delta)
+{
+	if (!delta)
+		return;
+
+	/* update lower 32 bits */
+	delta += stat->base_l;
+	stat->base_l = (u32)delta;
+
+	/* update upper 32 bits */
+	stat->base_h += (u32)(delta >> 32);
+}
+
+/**
+ *  fm10k_update_hw_stats_tx_q - Updates TX queue statistics counters
+ *  @hw: pointer to the hardware structure
+ *  @q: pointer to the ring of hardware statistics queue
+ *  @idx: index pointing to the start of the ring iteration
+ *
+ *  Function updates the TX queue statistics counters that are related to the
+ *  hardware.
+ **/
+static void fm10k_update_hw_stats_tx_q(struct fm10k_hw *hw,
+				       struct fm10k_hw_stats_q *q,
+				       u32 idx)
+{
+	u32 id_tx, id_tx_prev, tx_packets;
+	u64 tx_bytes = 0;
+
+	/* Retrieve TX Owner Data */
+	id_tx = fm10k_read_reg(hw, FM10K_TXQCTL(idx));
+
+	/* Process TX Ring */
+	do {
+		tx_packets = fm10k_read_hw_stats_32b(hw, FM10K_QPTC(idx),
+						     &q->tx_packets);
+
+		if (tx_packets)
+			tx_bytes = fm10k_read_hw_stats_48b(hw,
+							   FM10K_QBTC_L(idx),
+							   &q->tx_bytes);
+
+		/* Re-Check Owner Data */
+		id_tx_prev = id_tx;
+		id_tx = fm10k_read_reg(hw, FM10K_TXQCTL(idx));
+	} while ((id_tx ^ id_tx_prev) & FM10K_TXQCTL_ID_MASK);
+
+	/* drop non-ID bits and set VALID ID bit */
+	id_tx &= FM10K_TXQCTL_ID_MASK;
+	id_tx |= FM10K_STAT_VALID;
+
+	/* update packet counts */
+	if (q->tx_stats_idx == id_tx) {
+		q->tx_packets.count += tx_packets;
+		q->tx_bytes.count += tx_bytes;
+	}
+
+	/* update bases and record ID */
+	fm10k_update_hw_base_32b(&q->tx_packets, tx_packets);
+	fm10k_update_hw_base_48b(&q->tx_bytes, tx_bytes);
+
+	q->tx_stats_idx = id_tx;
+}
+
+/**
+ *  fm10k_update_hw_stats_rx_q - Updates RX queue statistics counters
+ *  @hw: pointer to the hardware structure
+ *  @q: pointer to the ring of hardware statistics queue
+ *  @idx: index pointing to the start of the ring iteration
+ *
+ *  Function updates the RX queue statistics counters that are related to the
+ *  hardware.
+ **/
+static void fm10k_update_hw_stats_rx_q(struct fm10k_hw *hw,
+				       struct fm10k_hw_stats_q *q,
+				       u32 idx)
+{
+	u32 id_rx, id_rx_prev, rx_packets, rx_drops;
+	u64 rx_bytes = 0;
+
+	/* Retrieve RX Owner Data */
+	id_rx = fm10k_read_reg(hw, FM10K_RXQCTL(idx));
+
+	/* Process RX Ring*/
+	do {
+		rx_drops = fm10k_read_hw_stats_32b(hw, FM10K_QPRDC(idx),
+						   &q->rx_drops);
+
+		rx_packets = fm10k_read_hw_stats_32b(hw, FM10K_QPRC(idx),
+						     &q->rx_packets);
+
+		if (rx_packets)
+			rx_bytes = fm10k_read_hw_stats_48b(hw,
+							   FM10K_QBRC_L(idx),
+							   &q->rx_bytes);
+
+		/* Re-Check Owner Data */
+		id_rx_prev = id_rx;
+		id_rx = fm10k_read_reg(hw, FM10K_RXQCTL(idx));
+	} while ((id_rx ^ id_rx_prev) & FM10K_RXQCTL_ID_MASK);
+
+	/* drop non-ID bits and set VALID ID bit */
+	id_rx &= FM10K_RXQCTL_ID_MASK;
+	id_rx |= FM10K_STAT_VALID;
+
+	/* update packet counts */
+	if (q->rx_stats_idx == id_rx) {
+		q->rx_drops.count += rx_drops;
+		q->rx_packets.count += rx_packets;
+		q->rx_bytes.count += rx_bytes;
+	}
+
+	/* update bases and record ID */
+	fm10k_update_hw_base_32b(&q->rx_drops, rx_drops);
+	fm10k_update_hw_base_32b(&q->rx_packets, rx_packets);
+	fm10k_update_hw_base_48b(&q->rx_bytes, rx_bytes);
+
+	q->rx_stats_idx = id_rx;
+}
+
+/**
+ *  fm10k_update_hw_stats_q - Updates queue statistics counters
+ *  @hw: pointer to the hardware structure
+ *  @q: pointer to the ring of hardware statistics queue
+ *  @idx: index pointing to the start of the ring iteration
+ *  @count: number of queues to iterate over
+ *
+ *  Function updates the queue statistics counters that are related to the
+ *  hardware.
+ **/
+void fm10k_update_hw_stats_q(struct fm10k_hw *hw, struct fm10k_hw_stats_q *q,
+			     u32 idx, u32 count)
+{
+	u32 i;
+
+	for (i = 0; i < count; i++, idx++, q++) {
+		fm10k_update_hw_stats_tx_q(hw, q, idx);
+		fm10k_update_hw_stats_rx_q(hw, q, idx);
+	}
+}
+
+/**
+ *  fm10k_unbind_hw_stats_q - Unbind the queue counters from their queues
+ *  @hw: pointer to the hardware structure
+ *  @q: pointer to the ring of hardware statistics queue
+ *  @idx: index pointing to the start of the ring iteration
+ *  @count: number of queues to iterate over
+ *
+ *  Function invalidates the index values for the queues so any updates that
+ *  may have happened are ignored and the base for the queue stats is reset.
+ **/
+
+void fm10k_unbind_hw_stats_q(struct fm10k_hw_stats_q *q, u32 idx, u32 count)
+{
+	u32 i;
+
+	for (i = 0; i < count; i++, idx++, q++) {
+		q->rx_stats_idx = 0;
+		q->tx_stats_idx = 0;
+	}
+}
+
+/**
+ *  fm10k_get_host_state_generic - Returns the state of the host
+ *  @hw: pointer to hardware structure
+ *  @host_ready: pointer to boolean value that will record host state
+ *
+ *  This function will check the health of the mailbox and Tx queue 0
+ *  in order to determine if we should report that the link is up or not.
+ **/
+s32 fm10k_get_host_state_generic(struct fm10k_hw *hw, bool *host_ready)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	struct fm10k_mac_info *mac = &hw->mac;
+	s32 ret_val = 0;
+	u32 txdctl = fm10k_read_reg(hw, FM10K_TXDCTL(0));
+
+	/* process upstream mailbox in case interrupts were disabled */
+	mbx->ops.process(hw, mbx);
+
+	/* If Tx is no longer enabled link should come down */
+	if (!(~txdctl) || !(txdctl & FM10K_TXDCTL_ENABLE))
+		mac->get_host_state = true;
+
+	/* exit if not checking for link, or link cannot be changed */
+	if (!mac->get_host_state || !(~txdctl))
+		goto out;
+
+	/* if we somehow dropped the Tx enable we should reset */
+	if (hw->mac.tx_ready && !(txdctl & FM10K_TXDCTL_ENABLE)) {
+		ret_val = FM10K_ERR_RESET_REQUESTED;
+		goto out;
+	}
+
+	/* if Mailbox timed out we should request reset */
+	if (!mbx->timeout) {
+		ret_val = FM10K_ERR_RESET_REQUESTED;
+		goto out;
+	}
+
+	/* verify Mailbox is still valid */
+	if (!mbx->ops.tx_ready(mbx, FM10K_VFMBX_MSG_MTU))
+		goto out;
+
+	/* interface cannot receive traffic without logical ports */
+	if (mac->dglort_map == FM10K_DGLORTMAP_NONE)
+		goto out;
+
+	/* if we passed all the tests above then the switch is ready and we no
+	 * longer need to check for link
+	 */
+	mac->get_host_state = false;
+
+out:
+	*host_ready = !mac->get_host_state;
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
index 2b214a6..8250e14 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -41,4 +41,17 @@ do { \
 
 /* read ctrl register which has no clear on read fields as PCIe flush */
 #define fm10k_write_flush(hw) fm10k_read_reg((hw), FM10K_CTRL)
+s32 fm10k_get_bus_info_generic(struct fm10k_hw *hw);
+s32 fm10k_get_invariants_generic(struct fm10k_hw *hw);
+s32 fm10k_disable_queues_generic(struct fm10k_hw *hw, u16 q_cnt);
+s32 fm10k_start_hw_generic(struct fm10k_hw *hw);
+s32 fm10k_stop_hw_generic(struct fm10k_hw *hw);
+u32 fm10k_read_hw_stats_32b(struct fm10k_hw *hw, u32 addr,
+			    struct fm10k_hw_stat *stat);
+#define fm10k_update_hw_base_32b(stat, delta) ((stat)->base_l += (delta))
+void fm10k_update_hw_stats_q(struct fm10k_hw *hw, struct fm10k_hw_stats_q *q,
+			     u32 idx, u32 count);
+#define fm10k_unbind_hw_stats_32b(s) ((s)->base_h = 0)
+void fm10k_unbind_hw_stats_q(struct fm10k_hw_stats_q *q, u32 idx, u32 count);
+s32 fm10k_get_host_state_generic(struct fm10k_hw *hw, bool *host_ready);
 #endif /* _FM10K_COMMON_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
new file mode 100644
index 0000000..b798cd5
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -0,0 +1,392 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k_pf.h"
+
+/**
+ *  fm10k_reset_hw_pf - PF hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  This function should return the hardware to a state similar to the
+ *  one it is in after being powered on.
+ **/
+static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
+{
+	s32 err;
+	u32 reg;
+	u16 i;
+
+	/* Disable interrupts */
+	fm10k_write_reg(hw, FM10K_EIMR, FM10K_EIMR_DISABLE(ALL));
+
+	/* Lock ITR2 reg 0 into itself and disable interrupt moderation */
+	fm10k_write_reg(hw, FM10K_ITR2(0), 0);
+	fm10k_write_reg(hw, FM10K_INT_CTRL, 0);
+
+	/* We assume here Tx and Rx queue 0 are owned by the PF */
+
+	/* Shut off VF access to their queues forcing them to queue 0 */
+	for (i = 0; i < FM10K_TQMAP_TABLE_SIZE; i++) {
+		fm10k_write_reg(hw, FM10K_TQMAP(i), 0);
+		fm10k_write_reg(hw, FM10K_RQMAP(i), 0);
+	}
+
+	/* shut down all rings */
+	err = fm10k_disable_queues_generic(hw, FM10K_MAX_QUEUES);
+	if (err)
+		return err;
+
+	/* Verify that DMA is no longer active */
+	reg = fm10k_read_reg(hw, FM10K_DMA_CTRL);
+	if (reg & (FM10K_DMA_CTRL_TX_ACTIVE | FM10K_DMA_CTRL_RX_ACTIVE))
+		return FM10K_ERR_DMA_PENDING;
+
+	/* Inititate data path reset */
+	reg |= FM10K_DMA_CTRL_DATAPATH_RESET;
+	fm10k_write_reg(hw, FM10K_DMA_CTRL, reg);
+
+	/* Flush write and allow 100us for reset to complete */
+	fm10k_write_flush(hw);
+	udelay(FM10K_RESET_TIMEOUT);
+
+	/* Verify we made it out of reset */
+	reg = fm10k_read_reg(hw, FM10K_IP);
+	if (!(reg & FM10K_IP_NOTINRESET))
+		err = FM10K_ERR_RESET_FAILED;
+
+	return err;
+}
+
+/**
+ *  fm10k_init_hw_pf - PF hardware initialization
+ *  @hw: pointer to hardware structure
+ *
+ **/
+static s32 fm10k_init_hw_pf(struct fm10k_hw *hw)
+{
+	u32 dma_ctrl, txqctl;
+	u16 i;
+
+	/* Establish default VSI as valid */
+	fm10k_write_reg(hw, FM10K_DGLORTDEC(fm10k_dglort_default), 0);
+	fm10k_write_reg(hw, FM10K_DGLORTMAP(fm10k_dglort_default),
+			FM10K_DGLORTMAP_ANY);
+
+	/* Invalidate all other GLORT entries */
+	for (i = 1; i < FM10K_DGLORT_COUNT; i++)
+		fm10k_write_reg(hw, FM10K_DGLORTMAP(i), FM10K_DGLORTMAP_NONE);
+
+	/* reset ITR2(0) to point to itself */
+	fm10k_write_reg(hw, FM10K_ITR2(0), 0);
+
+	/* reset VF ITR2(0) to point to 0 avoid PF registers */
+	fm10k_write_reg(hw, FM10K_ITR2(FM10K_ITR_REG_COUNT_PF), 0);
+
+	/* loop through all PF ITR2 registers pointing them to the previous */
+	for (i = 1; i < FM10K_ITR_REG_COUNT_PF; i++)
+		fm10k_write_reg(hw, FM10K_ITR2(i), i - 1);
+
+	/* Enable interrupt moderator if not already enabled */
+	fm10k_write_reg(hw, FM10K_INT_CTRL, FM10K_INT_CTRL_ENABLEMODERATOR);
+
+	/* compute the default txqctl configuration */
+	txqctl = FM10K_TXQCTL_PF | FM10K_TXQCTL_UNLIMITED_BW |
+		 (hw->mac.default_vid << FM10K_TXQCTL_VID_SHIFT);
+
+	for (i = 0; i < FM10K_MAX_QUEUES; i++) {
+		/* configure rings for 256 Queue / 32 Descriptor cache mode */
+		fm10k_write_reg(hw, FM10K_TQDLOC(i),
+				(i * FM10K_TQDLOC_BASE_32_DESC) |
+				FM10K_TQDLOC_SIZE_32_DESC);
+		fm10k_write_reg(hw, FM10K_TXQCTL(i), txqctl);
+
+		/* configure rings to provide TPH processing hints */
+		fm10k_write_reg(hw, FM10K_TPH_TXCTRL(i),
+				FM10K_TPH_TXCTRL_DESC_TPHEN |
+				FM10K_TPH_TXCTRL_DESC_RROEN |
+				FM10K_TPH_TXCTRL_DESC_WROEN |
+				FM10K_TPH_TXCTRL_DATA_RROEN);
+		fm10k_write_reg(hw, FM10K_TPH_RXCTRL(i),
+				FM10K_TPH_RXCTRL_DESC_TPHEN |
+				FM10K_TPH_RXCTRL_DESC_RROEN |
+				FM10K_TPH_RXCTRL_DATA_WROEN |
+				FM10K_TPH_RXCTRL_HDR_WROEN);
+	}
+
+	/* set max hold interval to align with 1.024 usec in all modes */
+	switch (hw->bus.speed) {
+	case fm10k_bus_speed_2500:
+		dma_ctrl = FM10K_DMA_CTRL_MAX_HOLD_1US_GEN1;
+		break;
+	case fm10k_bus_speed_5000:
+		dma_ctrl = FM10K_DMA_CTRL_MAX_HOLD_1US_GEN2;
+		break;
+	case fm10k_bus_speed_8000:
+		dma_ctrl = FM10K_DMA_CTRL_MAX_HOLD_1US_GEN3;
+		break;
+	default:
+		dma_ctrl = 0;
+		break;
+	}
+
+	/* Configure TSO flags */
+	fm10k_write_reg(hw, FM10K_DTXTCPFLGL, FM10K_TSO_FLAGS_LOW);
+	fm10k_write_reg(hw, FM10K_DTXTCPFLGH, FM10K_TSO_FLAGS_HI);
+
+	/* Enable DMA engine
+	 * Set Rx Descriptor size to 32
+	 * Set Minimum MSS to 64
+	 * Set Maximum number of Rx queues to 256 / 32 Descriptor
+	 */
+	dma_ctrl |= FM10K_DMA_CTRL_TX_ENABLE | FM10K_DMA_CTRL_RX_ENABLE |
+		    FM10K_DMA_CTRL_RX_DESC_SIZE | FM10K_DMA_CTRL_MINMSS_64 |
+		    FM10K_DMA_CTRL_32_DESC;
+
+	fm10k_write_reg(hw, FM10K_DMA_CTRL, dma_ctrl);
+
+	/* record maximum queue count, we limit ourselves to 128 */
+	hw->mac.max_queues = FM10K_MAX_QUEUES_PF;
+
+	return 0;
+}
+
+/**
+ *  fm10k_is_slot_appropriate_pf - Indicate appropriate slot for this SKU
+ *  @hw: pointer to hardware structure
+ *
+ *  Looks at the PCIe bus info to confirm whether or not this slot can support
+ *  the necessary bandwidth for this device.
+ **/
+static bool fm10k_is_slot_appropriate_pf(struct fm10k_hw *hw)
+{
+	return (hw->bus.speed == hw->bus_caps.speed) &&
+	       (hw->bus.width == hw->bus_caps.width);
+}
+
+/**
+ *  fm10k_read_mac_addr_pf - Read device MAC address
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the device MAC address from the SM_AREA and stores the value.
+ **/
+static s32 fm10k_read_mac_addr_pf(struct fm10k_hw *hw)
+{
+	u8 perm_addr[ETH_ALEN];
+	u32 serial_num;
+	int i;
+
+	serial_num = fm10k_read_reg(hw, FM10K_SM_AREA(1));
+
+	/* last byte should be all 1's */
+	if ((~serial_num) << 24)
+		return  FM10K_ERR_INVALID_MAC_ADDR;
+
+	perm_addr[0] = (u8)(serial_num >> 24);
+	perm_addr[1] = (u8)(serial_num >> 16);
+	perm_addr[2] = (u8)(serial_num >> 8);
+
+	serial_num = fm10k_read_reg(hw, FM10K_SM_AREA(0));
+
+	/* first byte should be all 1's */
+	if ((~serial_num) >> 24)
+		return  FM10K_ERR_INVALID_MAC_ADDR;
+
+	perm_addr[3] = (u8)(serial_num >> 16);
+	perm_addr[4] = (u8)(serial_num >> 8);
+	perm_addr[5] = (u8)(serial_num);
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		hw->mac.perm_addr[i] = perm_addr[i];
+		hw->mac.addr[i] = perm_addr[i];
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_update_stats_hw_pf - Updates hardware related statistics of PF
+ *  @hw: pointer to hardware structure
+ *  @stats: pointer to the stats structure to update
+ *
+ *  This function collects and aggregates global and per queue hardware
+ *  statistics.
+ **/
+static void fm10k_update_hw_stats_pf(struct fm10k_hw *hw,
+				     struct fm10k_hw_stats *stats)
+{
+	u32 timeout, ur, ca, um, xec, vlan_drop, loopback_drop, nodesc_drop;
+	u32 id, id_prev;
+
+	/* Use Tx queue 0 as a canary to detect a reset */
+	id = fm10k_read_reg(hw, FM10K_TXQCTL(0));
+
+	/* Read Global Statistics */
+	do {
+		timeout = fm10k_read_hw_stats_32b(hw, FM10K_STATS_TIMEOUT,
+						  &stats->timeout);
+		ur = fm10k_read_hw_stats_32b(hw, FM10K_STATS_UR, &stats->ur);
+		ca = fm10k_read_hw_stats_32b(hw, FM10K_STATS_CA, &stats->ca);
+		um = fm10k_read_hw_stats_32b(hw, FM10K_STATS_UM, &stats->um);
+		xec = fm10k_read_hw_stats_32b(hw, FM10K_STATS_XEC, &stats->xec);
+		vlan_drop = fm10k_read_hw_stats_32b(hw, FM10K_STATS_VLAN_DROP,
+						    &stats->vlan_drop);
+		loopback_drop = fm10k_read_hw_stats_32b(hw,
+							FM10K_STATS_LOOPBACK_DROP,
+						     &stats->loopback_drop);
+		nodesc_drop = fm10k_read_hw_stats_32b(hw,
+						      FM10K_STATS_NODESC_DROP,
+						      &stats->nodesc_drop);
+
+		/* if value has not changed then we have consistent data */
+		id_prev = id;
+		id = fm10k_read_reg(hw, FM10K_TXQCTL(0));
+	} while ((id ^ id_prev) & FM10K_TXQCTL_ID_MASK);
+
+	/* drop non-ID bits and set VALID ID bit */
+	id &= FM10K_TXQCTL_ID_MASK;
+	id |= FM10K_STAT_VALID;
+
+	/* Update Global Statistics */
+	if (stats->stats_idx == id) {
+		stats->timeout.count += timeout;
+		stats->ur.count += ur;
+		stats->ca.count += ca;
+		stats->um.count += um;
+		stats->xec.count += xec;
+		stats->vlan_drop.count += vlan_drop;
+		stats->loopback_drop.count += loopback_drop;
+		stats->nodesc_drop.count += nodesc_drop;
+	}
+
+	/* Update bases and record current PF id */
+	fm10k_update_hw_base_32b(&stats->timeout, timeout);
+	fm10k_update_hw_base_32b(&stats->ur, ur);
+	fm10k_update_hw_base_32b(&stats->ca, ca);
+	fm10k_update_hw_base_32b(&stats->um, um);
+	fm10k_update_hw_base_32b(&stats->xec, xec);
+	fm10k_update_hw_base_32b(&stats->vlan_drop, vlan_drop);
+	fm10k_update_hw_base_32b(&stats->loopback_drop, loopback_drop);
+	fm10k_update_hw_base_32b(&stats->nodesc_drop, nodesc_drop);
+	stats->stats_idx = id;
+
+	/* Update Queue Statistics */
+	fm10k_update_hw_stats_q(hw, stats->q, 0, hw->mac.max_queues);
+}
+
+/**
+ *  fm10k_rebind_hw_stats_pf - Resets base for hardware statistics of PF
+ *  @hw: pointer to hardware structure
+ *  @stats: pointer to the stats structure to update
+ *
+ *  This function resets the base for global and per queue hardware
+ *  statistics.
+ **/
+static void fm10k_rebind_hw_stats_pf(struct fm10k_hw *hw,
+				     struct fm10k_hw_stats *stats)
+{
+	/* Unbind Global Statistics */
+	fm10k_unbind_hw_stats_32b(&stats->timeout);
+	fm10k_unbind_hw_stats_32b(&stats->ur);
+	fm10k_unbind_hw_stats_32b(&stats->ca);
+	fm10k_unbind_hw_stats_32b(&stats->um);
+	fm10k_unbind_hw_stats_32b(&stats->xec);
+	fm10k_unbind_hw_stats_32b(&stats->vlan_drop);
+	fm10k_unbind_hw_stats_32b(&stats->loopback_drop);
+	fm10k_unbind_hw_stats_32b(&stats->nodesc_drop);
+
+	/* Unbind Queue Statistics */
+	fm10k_unbind_hw_stats_q(stats->q, 0, hw->mac.max_queues);
+
+	/* Reinitialize bases for all stats */
+	fm10k_update_hw_stats_pf(hw, stats);
+}
+
+/**
+ *  fm10k_get_fault_pf - Record a fault in one of the interface units
+ *  @hw: pointer to hardware structure
+ *  @type: pointer to fault type register offset
+ *  @fault: pointer to memory location to record the fault
+ *
+ *  Record the fault register contents to the fault data structure and
+ *  clear the entry from the register.
+ *
+ *  Returns ERR_PARAM if invalid register is specified or no error is present.
+ **/
+static s32 fm10k_get_fault_pf(struct fm10k_hw *hw, int type,
+			      struct fm10k_fault *fault)
+{
+	u32 func;
+
+	/* verify the fault register is in range and is aligned */
+	switch (type) {
+	case FM10K_PCA_FAULT:
+	case FM10K_THI_FAULT:
+	case FM10K_FUM_FAULT:
+		break;
+	default:
+		return FM10K_ERR_PARAM;
+	}
+
+	/* only service faults that are valid */
+	func = fm10k_read_reg(hw, type + FM10K_FAULT_FUNC);
+	if (!(func & FM10K_FAULT_FUNC_VALID))
+		return FM10K_ERR_PARAM;
+
+	/* read remaining fields */
+	fault->address = fm10k_read_reg(hw, type + FM10K_FAULT_ADDR_HI);
+	fault->address <<= 32;
+	fault->address = fm10k_read_reg(hw, type + FM10K_FAULT_ADDR_LO);
+	fault->specinfo = fm10k_read_reg(hw, type + FM10K_FAULT_SPECINFO);
+
+	/* clear valid bit to allow for next error */
+	fm10k_write_reg(hw, type + FM10K_FAULT_FUNC, FM10K_FAULT_FUNC_VALID);
+
+	/* Record which function triggered the error */
+	if (func & FM10K_FAULT_FUNC_PF)
+		fault->func = 0;
+	else
+		fault->func = 1 + ((func & FM10K_FAULT_FUNC_VF_MASK) >>
+				   FM10K_FAULT_FUNC_VF_SHIFT);
+
+	/* record fault type */
+	fault->type = func & FM10K_FAULT_FUNC_TYPE_MASK;
+
+	return 0;
+}
+
+static struct fm10k_mac_ops mac_ops_pf = {
+	.get_bus_info		= &fm10k_get_bus_info_generic,
+	.reset_hw		= &fm10k_reset_hw_pf,
+	.init_hw		= &fm10k_init_hw_pf,
+	.start_hw		= &fm10k_start_hw_generic,
+	.stop_hw		= &fm10k_stop_hw_generic,
+	.is_slot_appropriate	= &fm10k_is_slot_appropriate_pf,
+	.read_mac_addr		= &fm10k_read_mac_addr_pf,
+	.update_hw_stats	= &fm10k_update_hw_stats_pf,
+	.rebind_hw_stats	= &fm10k_rebind_hw_stats_pf,
+	.get_fault		= &fm10k_get_fault_pf,
+	.get_host_state		= &fm10k_get_host_state_generic,
+};
+
+struct fm10k_info fm10k_pf_info = {
+	.mac		= fm10k_mac_pf,
+	.get_invariants	= &fm10k_get_invariants_generic,
+	.mac_ops	= &mac_ops_pf,
+};
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
new file mode 100644
index 0000000..054392f
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -0,0 +1,28 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _FM10K_PF_H_
+#define _FM10K_PF_H_
+
+#include "fm10k_type.h"
+#include "fm10k_common.h"
+
+extern struct fm10k_info fm10k_pf_info;
+#endif /* _FM10K_PF_H */
