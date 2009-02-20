From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/5] igb: Add support for enabling VFs to PF driver.
Date: Thu, 19 Feb 2009 20:40:07 -0800
Message-ID: <20090220044006.29650.54737.stgit@lost.foo-projects.org>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Yu Zhao <yu.zhao@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753633AbZBTEkx@vger.kernel.org>
In-Reply-To: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds the support to handle requests from the VF to perform
operations such as completing resets, setting/reading mac address, adding
vlans, adding multicast addresses, setting rlpml, and general
communications between the PF and all VFs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Yu Zhao <yu.zhao@intel.com>
CC: LKML <linux-kernel@vger.kernel.org>
---

 drivers/net/igb/Makefile        |    2 
 drivers/net/igb/e1000_82575.c   |   42 ++++
 drivers/net/igb/e1000_82575.h   |   17 +
 drivers/net/igb/e1000_defines.h |    9 +
 drivers/net/igb/e1000_hw.h      |   31 +++
 drivers/net/igb/e1000_mac.c     |   24 ++
 drivers/net/igb/e1000_mac.h     |    1 
 drivers/net/igb/e1000_mbx.c     |  447 +++++++++++++++++++++++++++++++++++++++
 drivers/net/igb/e1000_mbx.h     |   77 +++++++
 drivers/net/igb/e1000_regs.h    |   12 +
 drivers/net/igb/igb.h           |   12 +
 drivers/net/igb/igb_main.c      |  429 +++++++++++++++++++++++++++++++++++--
 12 files changed, 1077 insertions(+), 26 deletions(-)
 create mode 100644 drivers/net/igb/e1000_mbx.c
 create mode 100644 drivers/net/igb/e1000_mbx.h

diff --git a/drivers/net/igb/Makefile b/drivers/net/igb/Makefile
index cda3ad5..8372cb9 100644
--- a/drivers/net/igb/Makefile
+++ b/drivers/net/igb/Makefile
@@ -33,5 +33,5 @@
 obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
-	    e1000_mac.o e1000_nvm.o e1000_phy.o
+	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o
 
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 7f43e25..ea63a21 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -213,6 +213,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		return -E1000_ERR_PHY;
 	}
 
+	/* if 82576 then initialize mailbox parameters */
+	if (mac->type == e1000_82576)
+		igb_init_mbx_params_pf(hw);
+
 	return 0;
 }
 
@@ -1413,6 +1417,44 @@ void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
 	rd32(E1000_MPC);
 }
 
+/**
+ *  igb_vmdq_set_loopback_pf - enable or disable vmdq loopback
+ *  @hw: pointer to the hardware struct
+ *  @enable: state to enter, either enabled or disabled
+ *
+ *  enables/disables L2 switch loopback functionality.
+ **/
+void igb_vmdq_set_loopback_pf(struct e1000_hw *hw, bool enable)
+{
+	u32 dtxswc = rd32(E1000_DTXSWC);
+
+	if (enable)
+		dtxswc |= E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+	else
+		dtxswc &= ~E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+
+	wr32(E1000_DTXSWC, dtxswc);
+}
+
+/**
+ *  igb_vmdq_set_replication_pf - enable or disable vmdq replication
+ *  @hw: pointer to the hardware struct
+ *  @enable: state to enter, either enabled or disabled
+ *
+ *  enables/disables replication of packets across multiple pools.
+ **/
+void igb_vmdq_set_replication_pf(struct e1000_hw *hw, bool enable)
+{
+	u32 vt_ctl = rd32(E1000_VT_CTL);
+
+	if (enable)
+		vt_ctl |= E1000_VT_CTL_VM_REPL_EN;
+	else
+		vt_ctl &= ~E1000_VT_CTL_VM_REPL_EN;
+
+	wr32(E1000_VT_CTL, vt_ctl);
+}
+
 static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.reset_hw             = igb_reset_hw_82575,
 	.init_hw              = igb_init_hw_82575,
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 116714f..eaf9770 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -162,6 +162,10 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_TXCTRL_CPUID_SHIFT 24 /* Tx CPUID now in the last byte */
 #define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last byte */
 
+#define MAX_NUM_VFS                   8
+
+#define E1000_DTXSWC_VMDQ_LOOPBACK_EN (1 << 31)  /* global VF LB enable */
+
 /* Easy defines for setting default pool, would normally be left a zero */
 #define E1000_VT_CTL_DEFAULT_POOL_SHIFT 7
 #define E1000_VT_CTL_DEFAULT_POOL_MASK  (0x7 << E1000_VT_CTL_DEFAULT_POOL_SHIFT)
@@ -181,8 +185,21 @@ struct e1000_adv_tx_context_desc {
 #define E1000_VMOLR_BAM        0x08000000 /* Accept Broadcast packets */
 #define E1000_VMOLR_MPME       0x10000000 /* Multicast promiscuous mode */
 #define E1000_VMOLR_STRVLAN    0x40000000 /* Vlan stripping enable */
+#define E1000_VMOLR_STRCRC     0x80000000 /* CRC stripping enable */
+
+#define E1000_VLVF_ARRAY_SIZE     32
+#define E1000_VLVF_VLANID_MASK    0x00000FFF
+#define E1000_VLVF_POOLSEL_SHIFT  12
+#define E1000_VLVF_POOLSEL_MASK   (0xFF << E1000_VLVF_POOLSEL_SHIFT)
+#define E1000_VLVF_LVLAN          0x00100000
+#define E1000_VLVF_VLANID_ENABLE  0x80000000
+
+#define E1000_IOVCTL 0x05BBC
+#define E1000_IOVCTL_REUSE_VFQ 0x00000001
 
 #define ALL_QUEUES   0xFFFF
 
+void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
+void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 
 #endif
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index d7613db..62e378b 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -45,6 +45,8 @@
 
 /* Extended Device Control */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
+/* Physical Func Reset Done Indication */
+#define E1000_CTRL_EXT_PFRSTD    0x00004000
 #define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_SGMII   0x00800000
@@ -325,6 +327,7 @@
 #define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
 #define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
 #define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_VMMB          0x00000100 /* VM MB event */
 /* If this bit asserted, the driver should claim the interrupt */
 #define E1000_ICR_INT_ASSERTED  0x80000000
 /* LAN connected device generates an interrupt */
@@ -362,6 +365,7 @@
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
 #define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_IMS_VMMB      E1000_ICR_VMMB      /* Mail box activity */
 #define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
 #define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
 #define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
@@ -413,6 +417,7 @@
 #define E1000_BLK_PHY_RESET   12
 #define E1000_ERR_SWFW_SYNC 13
 #define E1000_NOT_IMPLEMENTED 14
+#define E1000_ERR_MBX      15
 
 /* Loop limit on how long we wait for auto-negotiation to complete */
 #define COPPER_LINK_UP_LIMIT              10
@@ -659,4 +664,8 @@
 #define E1000_GEN_CTL_ADDRESS_SHIFT     8
 #define E1000_GEN_POLL_TIMEOUT          640
 
+#define E1000_VFTA_ENTRY_SHIFT               5
+#define E1000_VFTA_ENTRY_MASK                0x7F
+#define E1000_VFTA_ENTRY_BIT_SHIFT_MASK      0x1F
+
 #endif
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 10b872d..d793dca 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -32,7 +32,6 @@
 #include <linux/delay.h>
 #include <linux/io.h>
 
-#include "e1000_mac.h"
 #include "e1000_regs.h"
 #include "e1000_defines.h"
 
@@ -272,6 +271,7 @@ struct e1000_host_mng_command_info {
 #include "e1000_mac.h"
 #include "e1000_phy.h"
 #include "e1000_nvm.h"
+#include "e1000_mbx.h"
 
 struct e1000_mac_operations {
 	s32  (*check_for_link)(struct e1000_hw *);
@@ -427,6 +427,34 @@ struct e1000_fc_info {
 	enum e1000_fc_type original_type;
 };
 
+struct e1000_mbx_operations {
+	s32 (*init_params)(struct e1000_hw *hw);
+	s32 (*read)(struct e1000_hw *, u32 *, u16,  u16);
+	s32 (*write)(struct e1000_hw *, u32 *, u16, u16);
+	s32 (*read_posted)(struct e1000_hw *, u32 *, u16,  u16);
+	s32 (*write_posted)(struct e1000_hw *, u32 *, u16, u16);
+	s32 (*check_for_msg)(struct e1000_hw *, u16);
+	s32 (*check_for_ack)(struct e1000_hw *, u16);
+	s32 (*check_for_rst)(struct e1000_hw *, u16);
+};
+
+struct e1000_mbx_stats {
+	u32 msgs_tx;
+	u32 msgs_rx;
+
+	u32 acks;
+	u32 reqs;
+	u32 rsts;
+};
+
+struct e1000_mbx_info {
+	struct e1000_mbx_operations ops;
+	struct e1000_mbx_stats stats;
+	u32 timeout;
+	u32 usec_delay;
+	u16 size;
+};
+
 struct e1000_dev_spec_82575 {
 	bool sgmii_active;
 };
@@ -443,6 +471,7 @@ struct e1000_hw {
 	struct e1000_phy_info  phy;
 	struct e1000_nvm_info  nvm;
 	struct e1000_bus_info  bus;
+	struct e1000_mbx_info mbx;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
 
 	union {
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 5c249e2..2804db0 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -118,6 +118,30 @@ void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 }
 
 /**
+ *  igb_vfta_set - enable or disable vlan in VLAN filter table
+ *  @hw: pointer to the HW structure
+ *  @vid: VLAN id to add or remove
+ *  @add: if true add filter, if false remove
+ *
+ *  Sets or clears a bit in the VLAN filter table array based on VLAN id
+ *  and if we are adding or removing the filter
+ **/
+void igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add)
+{
+	u32 index = (vid >> E1000_VFTA_ENTRY_SHIFT) & E1000_VFTA_ENTRY_MASK;
+	u32 mask = 1 < (vid & E1000_VFTA_ENTRY_BIT_SHIFT_MASK);
+	u32 vfta;
+
+	vfta = array_rd32(E1000_VFTA, index);
+	if (add)
+		vfta |= mask;
+	else
+		vfta &= ~mask;
+
+	igb_write_vfta(hw, index, vfta);
+}
+
+/**
  *  igb_check_alt_mac_addr - Check for alternate MAC addr
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/igb/e1000_mac.h
index e5200de..eccc353 100644
--- a/drivers/net/igb/e1000_mac.h
+++ b/drivers/net/igb/e1000_mac.h
@@ -58,6 +58,7 @@ s32  igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 
 void igb_clear_hw_cntrs_base(struct e1000_hw *hw);
 void igb_clear_vfta(struct e1000_hw *hw);
+void igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add);
 void igb_config_collision_dist(struct e1000_hw *hw);
 void igb_mta_set(struct e1000_hw *hw, u32 hash_value);
 void igb_put_hw_semaphore(struct e1000_hw *hw);
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
new file mode 100644
index 0000000..fe71c7d
--- /dev/null
+++ b/drivers/net/igb/e1000_mbx.c
@@ -0,0 +1,447 @@
+/*******************************************************************************
+
+  Intel(R) Gigabit Ethernet Linux driver
+  Copyright(c) 2007-2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000_mbx.h"
+
+/**
+ *  igb_read_mbx - Reads a message from the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to read
+ *
+ *  returns SUCCESS if it successfuly read message from buffer
+ **/
+s32 igb_read_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = -E1000_ERR_MBX;
+
+	/* limit read to size of mailbox */
+	if (size > mbx->size)
+		size = mbx->size;
+
+	if (mbx->ops.read)
+		ret_val = mbx->ops.read(hw, msg, size, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  igb_write_mbx - Write a message to the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer
+ **/
+s32 igb_write_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = 0;
+
+	if (size > mbx->size)
+		ret_val = -E1000_ERR_MBX;
+
+	else if (mbx->ops.write)
+		ret_val = mbx->ops.write(hw, msg, size, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_msg - checks to see if someone sent us mail
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 igb_check_for_msg(struct e1000_hw *hw, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (mbx->ops.check_for_msg)
+		ret_val = mbx->ops.check_for_msg(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_ack - checks to see if someone sent us ACK
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 igb_check_for_ack(struct e1000_hw *hw, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (mbx->ops.check_for_ack)
+		ret_val = mbx->ops.check_for_ack(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_rst - checks to see if other side has reset
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 igb_check_for_rst(struct e1000_hw *hw, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (mbx->ops.check_for_rst)
+		ret_val = mbx->ops.check_for_rst(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  igb_poll_for_msg - Wait for message notification
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message notification
+ **/
+static s32 igb_poll_for_msg(struct e1000_hw *hw, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!mbx->ops.check_for_msg)
+		goto out;
+
+	while (mbx->ops.check_for_msg(hw, mbx_id)) {
+		if (!countdown)
+			break;
+		countdown--;
+		udelay(mbx->usec_delay);
+	}
+out:
+	return countdown ? 0 : -E1000_ERR_MBX;
+}
+
+/**
+ *  igb_poll_for_ack - Wait for message acknowledgement
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message acknowledgement
+ **/
+static s32 igb_poll_for_ack(struct e1000_hw *hw, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!mbx->ops.check_for_ack)
+		goto out;
+
+	while (mbx->ops.check_for_ack(hw, mbx_id)) {
+		if (!countdown)
+			break;
+		countdown--;
+		udelay(mbx->usec_delay);
+	}
+out:
+	return countdown ? 0 : -E1000_ERR_MBX;
+}
+
+/**
+ *  igb_read_posted_mbx - Wait for message notification and receive message
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message notification and
+ *  copied it into the receive buffer.
+ **/
+s32 igb_read_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (!mbx->ops.read)
+		goto out;
+
+	ret_val = igb_poll_for_msg(hw, mbx_id);
+
+	if (!ret_val)
+		ret_val = mbx->ops.read(hw, msg, size, mbx_id);
+out:
+	return ret_val;
+}
+
+/**
+ *  igb_write_posted_mbx - Write a message to the mailbox, wait for ack
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer and
+ *  received an ack to that message within delay * timeout period
+ **/
+s32 igb_write_posted_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = 0;
+
+	if (!mbx->ops.write)
+		goto out;
+
+	/* send msg*/
+	ret_val = mbx->ops.write(hw, msg, size, mbx_id);
+
+	/* if msg sent wait until we receive an ack */
+	if (!ret_val)
+		ret_val = igb_poll_for_ack(hw, mbx_id);
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_init_mbx_ops_generic - Initialize NVM function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups up the function pointers to no-op functions
+ **/
+void e1000_init_mbx_ops_generic(struct e1000_hw *hw)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+	mbx->ops.read_posted = igb_read_posted_mbx;
+	mbx->ops.write_posted = igb_write_posted_mbx;
+}
+
+static s32 igb_check_for_bit_pf(struct e1000_hw *hw, u32 mask)
+{
+	u32 mbvficr = rd32(E1000_MBVFICR);
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (mbvficr & mask) {
+		ret_val = 0;
+		wr32(E1000_MBVFICR, mask);
+	}
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_msg_pf - checks to see if the VF has sent mail
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 igb_check_for_msg_pf(struct e1000_hw *hw, u16 vf_number)
+{
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (!igb_check_for_bit_pf(hw, E1000_MBVFICR_VFREQ_VF1 << vf_number)) {
+		ret_val = 0;
+		hw->mbx.stats.reqs++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_ack_pf - checks to see if the VF has ACKed
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 igb_check_for_ack_pf(struct e1000_hw *hw, u16 vf_number)
+{
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (!igb_check_for_bit_pf(hw, E1000_MBVFICR_VFACK_VF1 << vf_number)) {
+		ret_val = 0;
+		hw->mbx.stats.acks++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  igb_check_for_rst_pf - checks to see if the VF has reset
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 igb_check_for_rst_pf(struct e1000_hw *hw, u16 vf_number)
+{
+	u32 vflre = rd32(E1000_VFLRE);
+	s32 ret_val = -E1000_ERR_MBX;
+
+	if (vflre & (1 << vf_number)) {
+		ret_val = 0;
+		wr32(E1000_VFLRE, (1 << vf_number));
+		hw->mbx.stats.rsts++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  igb_write_mbx_pf - Places a message in the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer
+ **/
+static s32 igb_write_mbx_pf(struct e1000_hw *hw, u32 *msg, u16 size,
+                              u16 vf_number)
+{
+	u32 p2v_mailbox;
+	s32 ret_val = 0;
+	u16 i;
+
+	/* Take ownership of the buffer */
+	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
+
+	/* Make sure we have ownership now... */
+	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
+	if (!(p2v_mailbox & E1000_P2VMAILBOX_PFU)) {
+		/* failed to grab ownership */
+		ret_val = -E1000_ERR_MBX;
+		goto out_no_write;
+	}
+
+	/*
+	 * flush any ack or msg which may already be in the queue
+	 * as they are likely the result of an error
+	 */
+	igb_check_for_ack_pf(hw, vf_number);
+	igb_check_for_msg_pf(hw, vf_number);
+
+	/* copy the caller specified message to the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		array_wr32(E1000_VMBMEM(vf_number), i, msg[i]);
+
+	/* Interrupt VF to tell it a message has been sent and release buffer*/
+	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_STS);
+
+	/* update stats */
+	hw->mbx.stats.msgs_tx++;
+
+out_no_write:
+	return ret_val;
+
+}
+
+/**
+ *  igb_read_mbx_pf - Read a message from the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @vf_number: the VF index
+ *
+ *  This function copies a message from the mailbox buffer to the caller's
+ *  memory buffer.  The presumption is that the caller knows that there was
+ *  a message due to a VF request so no polling for message is needed.
+ **/
+static s32 igb_read_mbx_pf(struct e1000_hw *hw, u32 *msg, u16 size,
+                             u16 vf_number)
+{
+	u32 p2v_mailbox;
+	s32 ret_val = 0;
+	u16 i;
+
+	/* Take ownership of the buffer */
+	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
+
+	/* Make sure we have ownership now... */
+	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
+	if (!(p2v_mailbox & E1000_P2VMAILBOX_PFU)) {
+		/* failed to grab ownership */
+		ret_val = -E1000_ERR_MBX;
+		goto out_no_read;
+	}
+
+	/* copy the message to the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		msg[i] = array_rd32(E1000_VMBMEM(vf_number), i);
+
+	/* Acknowledge the message and release buffer */
+	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_ACK);
+
+	/* update stats */
+	hw->mbx.stats.msgs_rx++;
+
+	ret_val = 0;
+
+out_no_read:
+	return ret_val;
+}
+
+/**
+ *  e1000_init_mbx_params_pf - set initial values for pf mailbox
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes the hw->mbx struct to correct values for pf mailbox
+ */
+s32 igb_init_mbx_params_pf(struct e1000_hw *hw)
+{
+	struct e1000_mbx_info *mbx = &hw->mbx;
+
+	if (hw->mac.type == e1000_82576) {
+		mbx->timeout = 0;
+		mbx->usec_delay = 0;
+
+		mbx->size = E1000_VFMAILBOX_SIZE;
+
+		mbx->ops.read = igb_read_mbx_pf;
+		mbx->ops.write = igb_write_mbx_pf;
+		mbx->ops.read_posted = igb_read_posted_mbx;
+		mbx->ops.write_posted = igb_write_posted_mbx;
+		mbx->ops.check_for_msg = igb_check_for_msg_pf;
+		mbx->ops.check_for_ack = igb_check_for_ack_pf;
+		mbx->ops.check_for_rst = igb_check_for_rst_pf;
+
+		mbx->stats.msgs_tx = 0;
+		mbx->stats.msgs_rx = 0;
+		mbx->stats.reqs = 0;
+		mbx->stats.acks = 0;
+		mbx->stats.rsts = 0;
+	}
+
+	return 0;
+}
+
diff --git a/drivers/net/igb/e1000_mbx.h b/drivers/net/igb/e1000_mbx.h
new file mode 100644
index 0000000..6ec9890
--- /dev/null
+++ b/drivers/net/igb/e1000_mbx.h
@@ -0,0 +1,77 @@
+/*******************************************************************************
+
+  Intel(R) Gigabit Ethernet Linux driver
+  Copyright(c) 2007-2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_MBX_H_
+#define _E1000_MBX_H_
+
+#include "e1000_hw.h"
+
+#define E1000_P2VMAILBOX_STS   0x00000001 /* Initiate message send to VF */
+#define E1000_P2VMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
+#define E1000_P2VMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
+#define E1000_P2VMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
+#define E1000_P2VMAILBOX_RVFU  0x00000010 /* Reset VFU - used when VF stuck */
+
+#define E1000_MBVFICR_VFREQ_MASK 0x000000FF /* bits for VF messages */
+#define E1000_MBVFICR_VFREQ_VF1  0x00000001 /* bit for VF 1 message */
+#define E1000_MBVFICR_VFACK_MASK 0x00FF0000 /* bits for VF acks */
+#define E1000_MBVFICR_VFACK_VF1  0x00010000 /* bit for VF 1 ack */
+
+#define E1000_VFMAILBOX_SIZE   16 /* 16 32 bit words - 64 bytes */
+
+/* If it's a E1000_VF_* msg then it originates in the VF and is sent to the
+ * PF.  The reverse is true if it is E1000_PF_*.
+ * Message ACK's are the value or'd with 0xF0000000
+ */
+#define E1000_VT_MSGTYPE_ACK      0x80000000  /* Messages below or'd with
+                                               * this are the ACK */
+#define E1000_VT_MSGTYPE_NACK     0x40000000  /* Messages below or'd with
+                                               * this are the NACK */
+#define E1000_VT_MSGTYPE_CTS      0x20000000  /* Indicates that VF is still
+                                                 clear to send requests */
+#define E1000_VT_MSGINFO_SHIFT    16
+/* bits 23:16 are used for exra info for certain messages */
+#define E1000_VT_MSGINFO_MASK     (0xFF << E1000_VT_MSGINFO_SHIFT)
+
+#define E1000_VF_RESET            0x01 /* VF requests reset */
+#define E1000_VF_SET_MAC_ADDR     0x02 /* VF requests PF to set MAC addr */
+#define E1000_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
+#define E1000_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
+#define E1000_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
+
+#define E1000_PF_CONTROL_MSG      0x0100 /* PF control message */
+
+s32 igb_read_mbx(struct e1000_hw *, u32 *, u16, u16);
+s32 igb_write_mbx(struct e1000_hw *, u32 *, u16, u16);
+s32 igb_read_posted_mbx(struct e1000_hw *, u32 *, u16, u16);
+s32 igb_write_posted_mbx(struct e1000_hw *, u32 *, u16, u16);
+s32 igb_check_for_msg(struct e1000_hw *, u16);
+s32 igb_check_for_ack(struct e1000_hw *, u16);
+s32 igb_check_for_rst(struct e1000_hw *, u16);
+s32 igb_init_mbx_params_pf(struct e1000_hw *);
+
+#endif /* _E1000_MBX_H_ */
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 5d00c86..0bd7728 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -321,9 +321,21 @@ enum {
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
 
 /* VT Registers */
+#define E1000_MBVFICR   0x00C80 /* Mailbox VF Cause - RWC */
+#define E1000_MBVFIMR   0x00C84 /* Mailbox VF int Mask - RW */
+#define E1000_VFLRE     0x00C88 /* VF Register Events - RWC */
+#define E1000_VFRE      0x00C8C /* VF Receive Enables */
+#define E1000_VFTE      0x00C90 /* VF Transmit Enables */
 #define E1000_QDE       0x02408 /* Queue Drop Enable - RW */
+#define E1000_DTXSWC    0x03500 /* DMA Tx Switch Control - RW */
+#define E1000_RPLOLR    0x05AF0 /* Replication Offload - RW */
+#define E1000_IOVTCL    0x05BBC /* IOV Control Register */
 /* These act per VF so an array friendly macro is used */
+#define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
+#define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
 #define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
+#define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine
+                                                       * Filter - RW */
 
 #define wr32(reg, value) (writel(value, hw->hw_addr + reg))
 #define rd32(reg) (readl(hw->hw_addr + reg))
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index d925f7d..e18ac1b 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -62,6 +62,17 @@ struct igb_adapter;
 #define IGB_MAX_TX_QUEUES     IGB_MAX_RX_QUEUES
 #define IGB_ABS_MAX_TX_QUEUES     4
 
+#define IGB_MAX_VF_MC_ENTRIES              30
+#define IGB_MAX_VF_FUNCTIONS               8
+#define IGB_MAX_VFTA_ENTRIES               128
+
+struct vf_data_storage {
+	unsigned char vf_mac_addresses[ETH_ALEN];
+	u16 vf_mc_hashes[IGB_MAX_VF_MC_ENTRIES];
+	u16 num_vf_mc_hashes;
+	bool clear_to_send;
+};
+
 /* RX descriptor control thresholds.
  * PTHRESH - MAC will consider prefetch if it has fewer than this number of
  *           descriptors available in its onboard memory.
@@ -272,6 +283,7 @@ struct igb_adapter {
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
 	unsigned int vfs_allocated_count;
+	struct vf_data_storage *vf_data;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6ca3043..f48f6d4 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -122,10 +122,16 @@ static void igb_vlan_rx_register(struct net_device *, struct vlan_group *);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
+static void igb_ping_all_vfs(struct igb_adapter *);
+static void igb_msg_task(struct igb_adapter *);
+static int igb_rcv_msg_from_vf(struct igb_adapter *, u32);
 static inline void igb_set_rah_pool(struct e1000_hw *, int , int);
 static void igb_set_mc_list_pools(struct igb_adapter *, int, u16);
+static void igb_vmm_control(struct igb_adapter *);
 static inline void igb_set_vmolr(struct e1000_hw *, int);
-static inline void igb_set_vf_rlpml(struct igb_adapter *, int, int);
+static inline int igb_set_vf_rlpml(struct igb_adapter *, int, int);
+static int igb_set_vf_mac(struct igb_adapter *adapter, int, unsigned char *);
+static void igb_restore_vf_multicasts(struct igb_adapter *adapter);
 
 static int igb_suspend(struct pci_dev *, pm_message_t);
 #ifdef CONFIG_PM
@@ -768,7 +774,10 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 		wr32(E1000_EIAC, adapter->eims_enable_mask);
 		wr32(E1000_EIAM, adapter->eims_enable_mask);
 		wr32(E1000_EIMS, adapter->eims_enable_mask);
-		wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC);
+		if (adapter->vfs_allocated_count)
+			wr32(E1000_MBVFIMR, 0xFF);
+		wr32(E1000_IMS, (E1000_IMS_LSC | E1000_IMS_VMMB |
+		                 E1000_IMS_DOUTSYNC));
 	} else {
 		wr32(E1000_IMS, IMS_ENABLE_MASK);
 		wr32(E1000_IAM, IMS_ENABLE_MASK);
@@ -892,6 +901,7 @@ int igb_up(struct igb_adapter *adapter)
 	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
 
+	igb_vmm_control(adapter);
 	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
 	igb_set_vmolr(hw, adapter->vfs_allocated_count);
 
@@ -1047,6 +1057,20 @@ void igb_reset(struct igb_adapter *adapter)
 	fc->send_xon = 1;
 	fc->type = fc->original_type;
 
+	/* disable receive for all VFs and wait one second */
+	if (adapter->vfs_allocated_count) {
+		int i;
+		for (i = 0 ; i < adapter->vfs_allocated_count; i++)
+			adapter->vf_data[i].clear_to_send = false;
+
+		/* ping all the active vfs to let them know we are going down */
+			igb_ping_all_vfs(adapter);
+
+		/* disable transmits and receives */
+		wr32(E1000_VFRE, 0);
+		wr32(E1000_VFTE, 0);
+	}
+
 	/* Allow time for pending master requests to run */
 	adapter->hw.mac.ops.reset_hw(&adapter->hw);
 	wr32(E1000_WUC, 0);
@@ -1624,6 +1648,7 @@ static int igb_open(struct net_device *netdev)
 	 * clean_rx handler before we do so.  */
 	igb_configure(adapter);
 
+	igb_vmm_control(adapter);
 	igb_set_rah_pool(hw, adapter->vfs_allocated_count, 0);
 	igb_set_vmolr(hw, adapter->vfs_allocated_count);
 
@@ -2456,6 +2481,8 @@ static void igb_set_multi(struct net_device *netdev)
 	                        mac->rar_entry_count);
 
 	igb_set_mc_list_pools(adapter, i, mac->rar_entry_count);
+	igb_restore_vf_multicasts(adapter);
+
 	kfree(mta_list);
 }
 
@@ -2571,6 +2598,8 @@ static void igb_watchdog_task(struct work_struct *work)
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 
+			igb_ping_all_vfs(adapter);
+
 			/* link state has changed, schedule phy info update */
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -2586,6 +2615,8 @@ static void igb_watchdog_task(struct work_struct *work)
 			netif_carrier_off(netdev);
 			netif_tx_stop_all_queues(netdev);
 
+			igb_ping_all_vfs(adapter);
+
 			/* link state has changed, schedule phy info update */
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -3523,15 +3554,19 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 		/* HW is reporting DMA is out of sync */
 		adapter->stats.doosync++;
 	}
-	if (!(icr & E1000_ICR_LSC))
-		goto no_link_interrupt;
-	hw->mac.get_link_status = 1;
-	/* guard against interrupt when we're going down */
-	if (!test_bit(__IGB_DOWN, &adapter->state))
-		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
-no_link_interrupt:
-	wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC);
+	/* Check for a mailbox event */
+	if (icr & E1000_ICR_VMMB)
+		igb_msg_task(adapter);
+
+	if (icr & E1000_ICR_LSC) {
+		hw->mac.get_link_status = 1;
+		/* guard against interrupt when we're going down */
+		if (!test_bit(__IGB_DOWN, &adapter->state))
+			mod_timer(&adapter->watchdog_timer, jiffies + 1);
+	}
+
+	wr32(E1000_IMS, E1000_IMS_LSC | E1000_IMS_DOUTSYNC | E1000_IMS_VMMB);
 	wr32(E1000_EIMS, adapter->eims_other);
 
 	return IRQ_HANDLED;
@@ -3719,6 +3754,317 @@ static int igb_notify_dca(struct notifier_block *nb, unsigned long event,
 }
 #endif /* CONFIG_IGB_DCA */
 
+static void igb_ping_all_vfs(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ping;
+	int i;
+
+	for (i = 0 ; i < adapter->vfs_allocated_count; i++) {
+		ping = E1000_PF_CONTROL_MSG;
+		if (adapter->vf_data[i].clear_to_send)
+			ping |= E1000_VT_MSGTYPE_CTS;
+		igb_write_mbx(hw, &ping, 1, i);
+	}
+}
+
+static int igb_set_vf_multicasts(struct igb_adapter *adapter,
+				  u32 *msgbuf, u32 vf)
+{
+	int n = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
+	u16 *hash_list = (u16 *)&msgbuf[1];
+	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
+	int i;
+
+	/* only up to 30 hash values supported */
+	if (n > 30)
+		n = 30;
+
+	/* salt away the number of multi cast addresses assigned
+	 * to this VF for later use to restore when the PF multi cast
+	 * list changes
+	 */
+	vf_data->num_vf_mc_hashes = n;
+
+	/* VFs are limited to using the MTA hash table for their multicast
+	 * addresses */
+	for (i = 0; i < n; i++)
+		vf_data->vf_mc_hashes[i] = hash_list[i];;
+
+	/* Flush and reset the mta with the new values */
+	igb_set_multi(adapter->netdev);
+
+	return 0;
+}
+
+static void igb_restore_vf_multicasts(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct vf_data_storage *vf_data;
+	int i, j;
+
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		vf_data = &adapter->vf_data[i];
+		for (j = 0; j < vf_data[i].num_vf_mc_hashes; j++)
+			igb_mta_set(hw, vf_data->vf_mc_hashes[j]);
+	}
+}
+
+static void igb_clear_vf_vfta(struct igb_adapter *adapter, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 pool_mask, reg, vid;
+	int i;
+
+	pool_mask = 1 << (E1000_VLVF_POOLSEL_SHIFT + vf);
+
+	/* Find the vlan filter for this id */
+	for (i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+		reg = rd32(E1000_VLVF(i));
+
+		/* remove the vf from the pool */
+		reg &= ~pool_mask;
+
+		/* if pool is empty then remove entry from vfta */
+		if (!(reg & E1000_VLVF_POOLSEL_MASK) &&
+		    (reg & E1000_VLVF_VLANID_ENABLE)) {
+			reg = 0;
+			vid = reg & E1000_VLVF_VLANID_MASK;
+			igb_vfta_set(hw, vid, false);
+		}
+
+		wr32(E1000_VLVF(i), reg);
+	}
+}
+
+static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg, i;
+
+	/* It is an error to call this function when VFs are not enabled */
+	if (!adapter->vfs_allocated_count)
+		return -1;
+
+	/* Find the vlan filter for this id */
+	for (i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+		reg = rd32(E1000_VLVF(i));
+		if ((reg & E1000_VLVF_VLANID_ENABLE) &&
+		    vid == (reg & E1000_VLVF_VLANID_MASK))
+			break;
+	}
+
+	if (add) {
+		if (i == E1000_VLVF_ARRAY_SIZE) {
+			/* Did not find a matching VLAN ID entry that was
+			 * enabled.  Search for a free filter entry, i.e.
+			 * one without the enable bit set
+			 */
+			for (i = 0; i < E1000_VLVF_ARRAY_SIZE; i++) {
+				reg = rd32(E1000_VLVF(i));
+				if (!(reg & E1000_VLVF_VLANID_ENABLE))
+					break;
+			}
+		}
+		if (i < E1000_VLVF_ARRAY_SIZE) {
+			/* Found an enabled/available entry */
+			reg |= 1 << (E1000_VLVF_POOLSEL_SHIFT + vf);
+
+			/* if !enabled we need to set this up in vfta */
+			if (!(reg & E1000_VLVF_VLANID_ENABLE)) {
+				/* add VID to filter table */
+				igb_vfta_set(hw, vid, true);
+				reg |= E1000_VLVF_VLANID_ENABLE;
+			}
+
+			wr32(E1000_VLVF(i), reg);
+			return 0;
+		}
+	} else {
+		if (i < E1000_VLVF_ARRAY_SIZE) {
+			/* remove vf from the pool */
+			reg &= ~(1 << (E1000_VLVF_POOLSEL_SHIFT + vf));
+			/* if pool is empty then remove entry from vfta */
+			if (!(reg & E1000_VLVF_POOLSEL_MASK)) {
+				reg = 0;
+				igb_vfta_set(hw, vid, false);
+			}
+			wr32(E1000_VLVF(i), reg);
+			return 0;
+		}
+	}
+	return -1;
+}
+
+static int igb_set_vf_vlan(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
+{
+	int add = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
+	int vid = (msgbuf[1] & E1000_VLVF_VLANID_MASK);
+
+	return igb_vlvf_set(adapter, vid, add, vf);
+}
+
+static inline void igb_vf_reset_event(struct igb_adapter *adapter, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* disable mailbox functionality for vf */
+	adapter->vf_data[vf].clear_to_send = false;
+
+	/* reset offloads to defaults */
+	igb_set_vmolr(hw, vf);
+
+	/* reset vlans for device */
+	igb_clear_vf_vfta(adapter, vf);
+
+	/* reset multicast table array for vf */
+	adapter->vf_data[vf].num_vf_mc_hashes = 0;
+
+	/* Flush and reset the mta with the new values */
+	igb_set_multi(adapter->netdev);
+}
+
+static inline void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned char *vf_mac = adapter->vf_data[vf].vf_mac_addresses;
+	u32 reg, msgbuf[3];
+	u8 *addr = (u8 *)(&msgbuf[1]);
+
+	/* process all the same items cleared in a function level reset */
+	igb_vf_reset_event(adapter, vf);
+
+	/* set vf mac address */
+	igb_rar_set(hw, vf_mac, vf + 1);
+	igb_set_rah_pool(hw, vf, vf + 1);
+
+	/* enable transmit and receive for vf */
+	reg = rd32(E1000_VFTE);
+	wr32(E1000_VFTE, reg | (1 << vf));
+	reg = rd32(E1000_VFRE);
+	wr32(E1000_VFRE, reg | (1 << vf));
+
+	/* enable mailbox functionality for vf */
+	adapter->vf_data[vf].clear_to_send = true;
+
+	/* reply to reset with ack and vf mac address */
+	msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
+	memcpy(addr, vf_mac, 6);
+	igb_write_mbx(hw, msgbuf, 3, vf);
+}
+
+static int igb_set_vf_mac_addr(struct igb_adapter *adapter, u32 *msg, int vf)
+{
+		unsigned char *addr = (char *)&msg[1];
+		int err = -1;
+
+		if (is_valid_ether_addr(addr))
+			err = igb_set_vf_mac(adapter, vf, addr);
+
+		return err;
+
+}
+
+static void igb_rcv_ack_from_vf(struct igb_adapter *adapter, u32 vf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 msg = E1000_VT_MSGTYPE_NACK;
+
+	/* if device isn't clear to send it shouldn't be reading either */
+	if (!adapter->vf_data[vf].clear_to_send)
+		igb_write_mbx(hw, &msg, 1, vf);
+}
+
+
+static void igb_msg_task(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 vf;
+
+	for (vf = 0; vf < adapter->vfs_allocated_count; vf++) {
+		/* process any reset requests */
+		if (!igb_check_for_rst(hw, vf)) {
+			adapter->vf_data[vf].clear_to_send = false;
+			igb_vf_reset_event(adapter, vf);
+		}
+
+		/* process any messages pending */
+		if (!igb_check_for_msg(hw, vf))
+			igb_rcv_msg_from_vf(adapter, vf);
+
+		/* process any acks */
+		if (!igb_check_for_ack(hw, vf))
+			igb_rcv_ack_from_vf(adapter, vf);
+
+	}
+}
+
+static int igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
+{
+	u32 mbx_size = E1000_VFMAILBOX_SIZE;
+	u32 msgbuf[mbx_size];
+	struct e1000_hw *hw = &adapter->hw;
+	s32 retval;
+
+	retval = igb_read_mbx(hw, msgbuf, mbx_size, vf);
+
+	if (retval)
+		dev_err(&adapter->pdev->dev,
+		        "Error receiving message from VF\n");
+
+	/* this is a message we already processed, do nothing */
+	if (msgbuf[0] & (E1000_VT_MSGTYPE_ACK | E1000_VT_MSGTYPE_NACK))
+		return retval;
+
+	/*
+	 * until the vf completes a reset it should not be
+	 * allowed to start any configuration.
+	 */
+
+	if (msgbuf[0] == E1000_VF_RESET) {
+		igb_vf_reset_msg(adapter, vf);
+
+		return retval;
+	}
+
+	if (!adapter->vf_data[vf].clear_to_send) {
+		msgbuf[0] |= E1000_VT_MSGTYPE_NACK;
+		igb_write_mbx(hw, msgbuf, 1, vf);
+		return retval;
+	}
+
+	switch ((msgbuf[0] & 0xFFFF)) {
+	case E1000_VF_SET_MAC_ADDR:
+		retval = igb_set_vf_mac_addr(adapter, msgbuf, vf);
+		break;
+	case E1000_VF_SET_MULTICAST:
+		retval = igb_set_vf_multicasts(adapter, msgbuf, vf);
+		break;
+	case E1000_VF_SET_LPE:
+		retval = igb_set_vf_rlpml(adapter, msgbuf[1], vf);
+		break;
+	case E1000_VF_SET_VLAN:
+		retval = igb_set_vf_vlan(adapter, msgbuf, vf);
+		break;
+	default:
+		dev_err(&adapter->pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
+		retval = -1;
+		break;
+	}
+
+	/* notify the VF of the results of what it sent us */
+	if (retval)
+		msgbuf[0] |= E1000_VT_MSGTYPE_NACK;
+	else
+		msgbuf[0] |= E1000_VT_MSGTYPE_ACK;
+
+	msgbuf[0] |= E1000_VT_MSGTYPE_CTS;
+
+	igb_write_mbx(hw, msgbuf, 1, vf);
+
+	return retval;
+}
+
 /**
  * igb_intr_msi - Interrupt Handler
  * @irq: interrupt number
@@ -4582,24 +4928,25 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 vfta, index;
+	int pf_id = adapter->vfs_allocated_count;
 
 	if ((hw->mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
-	/* add VID to filter table */
-	index = (vid >> 5) & 0x7F;
-	vfta = array_rd32(E1000_VFTA, index);
-	vfta |= (1 << (vid & 0x1F));
-	igb_write_vfta(&adapter->hw, index, vfta);
+
+	/* add vid to vlvf if sr-iov is enabled,
+	 * if that fails add directly to filter table */
+	if (igb_vlvf_set(adapter, vid, true, pf_id))
+		igb_vfta_set(hw, vid, true);
+
 }
 
 static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 vfta, index;
+	int pf_id = adapter->vfs_allocated_count;
 
 	igb_irq_disable(adapter);
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
@@ -4615,11 +4962,10 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 		return;
 	}
 
-	/* remove VID from filter table */
-	index = (vid >> 5) & 0x7F;
-	vfta = array_rd32(E1000_VFTA, index);
-	vfta &= ~(1 << (vid & 0x1F));
-	igb_write_vfta(&adapter->hw, index, vfta);
+	/* remove vid from vlvf if sr-iov is enabled,
+	 * if not in vlvf remove from vfta */
+	if (igb_vlvf_set(adapter, vid, false, pf_id))
+		igb_vfta_set(hw, vid, false);
 }
 
 static void igb_restore_vlan(struct igb_adapter *adapter)
@@ -4950,8 +5296,8 @@ static inline void igb_set_vmolr(struct e1000_hw *hw, int vfn)
 	wr32(E1000_VMOLR(vfn), reg_data);
 }
 
-static inline void igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
-                                    int vfn)
+static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
+                                 int vfn)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vmolr;
@@ -4960,6 +5306,8 @@ static inline void igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
 	vmolr &= ~E1000_VMOLR_RLPML_MASK;
 	vmolr |= size | E1000_VMOLR_LPE;
 	wr32(E1000_VMOLR(vfn), vmolr);
+
+	return 0;
 }
 
 static inline void igb_set_rah_pool(struct e1000_hw *hw, int pool, int entry)
@@ -4985,4 +5333,37 @@ static void igb_set_mc_list_pools(struct igb_adapter *adapter,
 		igb_set_rah_pool(hw, adapter->vfs_allocated_count, i);
 }
 
+static int igb_set_vf_mac(struct igb_adapter *adapter,
+                          int vf, unsigned char *mac_addr)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int rar_entry = vf + 1; /* VF MAC addresses start at entry 1 */
+
+	igb_rar_set(hw, mac_addr, rar_entry);
+
+	memcpy(adapter->vf_data[vf].vf_mac_addresses, mac_addr, 6);
+
+	igb_set_rah_pool(hw, vf, rar_entry);
+
+	return 0;
+}
+
+static void igb_vmm_control(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg_data;
+
+	if (!adapter->vfs_allocated_count)
+		return;
+
+	/* VF's need PF reset indication before they
+	 * can send/receive mail */
+	reg_data = rd32(E1000_CTRL_EXT);
+	reg_data |= E1000_CTRL_EXT_PFRSTD;
+	wr32(E1000_CTRL_EXT, reg_data);
+
+	igb_vmdq_set_loopback_pf(hw, true);
+	igb_vmdq_set_replication_pf(hw, true);
+}
+
 /* igb_main.c */
