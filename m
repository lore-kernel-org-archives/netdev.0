From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 09/12] ixgbevf: Mailbox communication
Date: Tue, 08 Dec 2009 14:15:54 -0800
Message-ID: <20091208221553.28373.85958.stgit@localhost.localdomain>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:34562
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966717AbZLHWQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:16:06 -0500
In-Reply-To: <20091208221258.28373.16663.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The 82599 virtual function device and the master 82599 physical function
device implement a mailbox utility for communication between the devices
using some SRAM scratch memory and a doorbell/answering mechanism enabled
via interrupt and/or polling.  This C module and accompanying header
file implement the base functions for use of this feature.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/mbx.c |  354 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbevf/mbx.h |  100 +++++++++++++
 2 files changed, 454 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ixgbevf/mbx.c
 create mode 100644 drivers/net/ixgbevf/mbx.h

diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ixgbevf/mbx.c
new file mode 100644
index 0000000..a6e81fe
--- /dev/null
+++ b/drivers/net/ixgbevf/mbx.c
@@ -0,0 +1,354 @@
+/*******************************************************************************
+
+  Intel 82599 Virtual Function driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
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
+#include "mbx.h"
+
+/**
+ *  ixgbevf_poll_for_msg - Wait for message notification
+ *  @hw: pointer to the HW structure
+ *
+ *  returns 0 if it successfully received a message notification
+ **/
+static s32 ixgbevf_poll_for_msg(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!mbx->ops.check_for_msg)
+		goto out;
+
+	while (countdown && mbx->ops.check_for_msg(hw)) {
+		countdown--;
+		udelay(mbx->udelay);
+	}
+
+	/* if we failed, all future posted messages fail until reset */
+	if (!countdown)
+		mbx->timeout = 0;
+out:
+	return countdown ? 0 : IXGBE_ERR_MBX;
+}
+
+/**
+ *  ixgbevf_poll_for_ack - Wait for message acknowledgement
+ *  @hw: pointer to the HW structure
+ *
+ *  returns 0 if it successfully received a message acknowledgement
+ **/
+static s32 ixgbevf_poll_for_ack(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!mbx->ops.check_for_ack)
+		goto out;
+
+	while (countdown && mbx->ops.check_for_ack(hw)) {
+		countdown--;
+		udelay(mbx->udelay);
+	}
+
+	/* if we failed, all future posted messages fail until reset */
+	if (!countdown)
+		mbx->timeout = 0;
+out:
+	return countdown ? 0 : IXGBE_ERR_MBX;
+}
+
+/**
+ *  ixgbevf_read_posted_mbx - Wait for message notification and receive message
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *
+ *  returns 0 if it successfully received a message notification and
+ *  copied it into the receive buffer.
+ **/
+static s32 ixgbevf_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (!mbx->ops.read)
+		goto out;
+
+	ret_val = ixgbevf_poll_for_msg(hw);
+
+	/* if ack received read message, otherwise we timed out */
+	if (!ret_val)
+		ret_val = mbx->ops.read(hw, msg, size);
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_write_posted_mbx - Write a message to the mailbox, wait for ack
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *
+ *  returns 0 if it successfully copied message into the buffer and
+ *  received an ack to that message within delay * timeout period
+ **/
+static s32 ixgbevf_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	/* exit if either we can't write or there isn't a defined timeout */
+	if (!mbx->ops.write || !mbx->timeout)
+		goto out;
+
+	/* send msg */
+	ret_val = mbx->ops.write(hw, msg, size);
+
+	/* if msg sent wait until we receive an ack */
+	if (!ret_val)
+		ret_val = ixgbevf_poll_for_ack(hw);
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_read_v2p_mailbox - read v2p mailbox
+ *  @hw: pointer to the HW structure
+ *
+ *  This function is used to read the v2p mailbox without losing the read to
+ *  clear status bits.
+ **/
+static u32 ixgbevf_read_v2p_mailbox(struct ixgbe_hw *hw)
+{
+	u32 v2p_mailbox = IXGBE_READ_REG(hw, IXGBE_VFMAILBOX);
+
+	v2p_mailbox |= hw->mbx.v2p_mailbox;
+	hw->mbx.v2p_mailbox |= v2p_mailbox & IXGBE_VFMAILBOX_R2C_BITS;
+
+	return v2p_mailbox;
+}
+
+/**
+ *  ixgbevf_check_for_bit_vf - Determine if a status bit was set
+ *  @hw: pointer to the HW structure
+ *  @mask: bitmask for bits to be tested and cleared
+ *
+ *  This function is used to check for the read to clear bits within
+ *  the V2P mailbox.
+ **/
+static s32 ixgbevf_check_for_bit_vf(struct ixgbe_hw *hw, u32 mask)
+{
+	u32 v2p_mailbox = ixgbevf_read_v2p_mailbox(hw);
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (v2p_mailbox & mask)
+		ret_val = 0;
+
+	hw->mbx.v2p_mailbox &= ~mask;
+
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_check_for_msg_vf - checks to see if the PF has sent mail
+ *  @hw: pointer to the HW structure
+ *
+ *  returns 0 if the PF has set the Status bit or else ERR_MBX
+ **/
+static s32 ixgbevf_check_for_msg_vf(struct ixgbe_hw *hw)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (!ixgbevf_check_for_bit_vf(hw, IXGBE_VFMAILBOX_PFSTS)) {
+		ret_val = 0;
+		hw->mbx.stats.reqs++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_check_for_ack_vf - checks to see if the PF has ACK'd
+ *  @hw: pointer to the HW structure
+ *
+ *  returns 0 if the PF has set the ACK bit or else ERR_MBX
+ **/
+static s32 ixgbevf_check_for_ack_vf(struct ixgbe_hw *hw)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (!ixgbevf_check_for_bit_vf(hw, IXGBE_VFMAILBOX_PFACK)) {
+		ret_val = 0;
+		hw->mbx.stats.acks++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_check_for_rst_vf - checks to see if the PF has reset
+ *  @hw: pointer to the HW structure
+ *
+ *  returns true if the PF has set the reset done bit or else false
+ **/
+static s32 ixgbevf_check_for_rst_vf(struct ixgbe_hw *hw)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (!ixgbevf_check_for_bit_vf(hw, (IXGBE_VFMAILBOX_RSTD |
+					 IXGBE_VFMAILBOX_RSTI))) {
+		ret_val = 0;
+		hw->mbx.stats.rsts++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_obtain_mbx_lock_vf - obtain mailbox lock
+ *  @hw: pointer to the HW structure
+ *
+ *  return 0 if we obtained the mailbox lock
+ **/
+static s32 ixgbevf_obtain_mbx_lock_vf(struct ixgbe_hw *hw)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	/* Take ownership of the buffer */
+	IXGBE_WRITE_REG(hw, IXGBE_VFMAILBOX, IXGBE_VFMAILBOX_VFU);
+
+	/* reserve mailbox for vf use */
+	if (ixgbevf_read_v2p_mailbox(hw) & IXGBE_VFMAILBOX_VFU)
+		ret_val = 0;
+
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_write_mbx_vf - Write a message to the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *
+ *  returns 0 if it successfully copied message into the buffer
+ **/
+static s32 ixgbevf_write_mbx_vf(struct ixgbe_hw *hw, u32 *msg, u16 size)
+{
+	s32 ret_val;
+	u16 i;
+
+
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = ixgbevf_obtain_mbx_lock_vf(hw);
+	if (ret_val)
+		goto out_no_write;
+
+	/* flush msg and acks as we are overwriting the message buffer */
+	ixgbevf_check_for_msg_vf(hw);
+	ixgbevf_check_for_ack_vf(hw);
+
+	/* copy the caller specified message to the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		IXGBE_WRITE_REG_ARRAY(hw, IXGBE_VFMBMEM, i, msg[i]);
+
+	/* update stats */
+	hw->mbx.stats.msgs_tx++;
+
+	/* Drop VFU and interrupt the PF to tell it a message has been sent */
+	IXGBE_WRITE_REG(hw, IXGBE_VFMAILBOX, IXGBE_VFMAILBOX_REQ);
+
+out_no_write:
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_read_mbx_vf - Reads a message from the inbox intended for vf
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *
+ *  returns 0 if it successfuly read message from buffer
+ **/
+static s32 ixgbevf_read_mbx_vf(struct ixgbe_hw *hw, u32 *msg, u16 size)
+{
+	s32 ret_val = 0;
+	u16 i;
+
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = ixgbevf_obtain_mbx_lock_vf(hw);
+	if (ret_val)
+		goto out_no_read;
+
+	/* copy the message from the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		msg[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_VFMBMEM, i);
+
+	/* Acknowledge receipt and release mailbox, then we're done */
+	IXGBE_WRITE_REG(hw, IXGBE_VFMAILBOX, IXGBE_VFMAILBOX_ACK);
+
+	/* update stats */
+	hw->mbx.stats.msgs_rx++;
+
+out_no_read:
+	return ret_val;
+}
+
+/**
+ *  ixgbevf_init_mbx_params_vf - set initial values for vf mailbox
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes the hw->mbx struct to correct values for vf mailbox
+ */
+s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+
+	/* start mailbox as timed out and let the reset_hw call set the timeout
+	 * value to begin communications */
+	mbx->timeout = 0;
+	mbx->udelay = IXGBE_VF_MBX_INIT_DELAY;
+
+	mbx->size = IXGBE_VFMAILBOX_SIZE;
+
+	mbx->stats.msgs_tx = 0;
+	mbx->stats.msgs_rx = 0;
+	mbx->stats.reqs = 0;
+	mbx->stats.acks = 0;
+	mbx->stats.rsts = 0;
+
+	return 0;
+}
+
+struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
+	.init_params   = ixgbevf_init_mbx_params_vf,
+	.read          = ixgbevf_read_mbx_vf,
+	.write         = ixgbevf_write_mbx_vf,
+	.read_posted   = ixgbevf_read_posted_mbx,
+	.write_posted  = ixgbevf_write_posted_mbx,
+	.check_for_msg = ixgbevf_check_for_msg_vf,
+	.check_for_ack = ixgbevf_check_for_ack_vf,
+	.check_for_rst = ixgbevf_check_for_rst_vf,
+};
+
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/ixgbevf/mbx.h
new file mode 100644
index 0000000..1b0e0bf
--- /dev/null
+++ b/drivers/net/ixgbevf/mbx.h
@@ -0,0 +1,100 @@
+/*******************************************************************************
+
+  Intel 82599 Virtual Function driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
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
+#ifndef _IXGBE_MBX_H_
+#define _IXGBE_MBX_H_
+
+#include "vf.h"
+
+#define IXGBE_VFMAILBOX_SIZE        16 /* 16 32 bit words - 64 bytes */
+#define IXGBE_ERR_MBX               -100
+
+#define IXGBE_VFMAILBOX             0x002FC
+#define IXGBE_VFMBMEM               0x00200
+
+/* Define mailbox register bits */
+#define IXGBE_VFMAILBOX_REQ      0x00000001 /* Request for PF Ready bit */
+#define IXGBE_VFMAILBOX_ACK      0x00000002 /* Ack PF message received */
+#define IXGBE_VFMAILBOX_VFU      0x00000004 /* VF owns the mailbox buffer */
+#define IXGBE_VFMAILBOX_PFU      0x00000008 /* PF owns the mailbox buffer */
+#define IXGBE_VFMAILBOX_PFSTS    0x00000010 /* PF wrote a message in the MB */
+#define IXGBE_VFMAILBOX_PFACK    0x00000020 /* PF ack the previous VF msg */
+#define IXGBE_VFMAILBOX_RSTI     0x00000040 /* PF has reset indication */
+#define IXGBE_VFMAILBOX_RSTD     0x00000080 /* PF has indicated reset done */
+#define IXGBE_VFMAILBOX_R2C_BITS 0x000000B0 /* All read to clear bits */
+
+#define IXGBE_PFMAILBOX(x)          (0x04B00 + (4 * x))
+#define IXGBE_PFMBMEM(vfn)          (0x13000 + (64 * vfn))
+
+#define IXGBE_PFMAILBOX_STS   0x00000001 /* Initiate message send to VF */
+#define IXGBE_PFMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
+#define IXGBE_PFMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
+#define IXGBE_PFMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
+#define IXGBE_PFMAILBOX_RVFU  0x00000010 /* Reset VFU - used when VF stuck */
+
+#define IXGBE_MBVFICR_VFREQ_MASK 0x0000FFFF /* bits for VF messages */
+#define IXGBE_MBVFICR_VFREQ_VF1  0x00000001 /* bit for VF 1 message */
+#define IXGBE_MBVFICR_VFACK_MASK 0xFFFF0000 /* bits for VF acks */
+#define IXGBE_MBVFICR_VFACK_VF1  0x00010000 /* bit for VF 1 ack */
+
+
+/* If it's a IXGBE_VF_* msg then it originates in the VF and is sent to the
+ * PF.  The reverse is true if it is IXGBE_PF_*.
+ * Message ACK's are the value or'd with 0xF0000000
+ */
+#define IXGBE_VT_MSGTYPE_ACK      0x80000000  /* Messages below or'd with
+					       * this are the ACK */
+#define IXGBE_VT_MSGTYPE_NACK     0x40000000  /* Messages below or'd with
+					       * this are the NACK */
+#define IXGBE_VT_MSGTYPE_CTS      0x20000000  /* Indicates that VF is still
+					       *  clear to send requests */
+#define IXGBE_VT_MSGINFO_SHIFT    16
+/* bits 23:16 are used for exra info for certain messages */
+#define IXGBE_VT_MSGINFO_MASK     (0xFF << IXGBE_VT_MSGINFO_SHIFT)
+
+#define IXGBE_VF_RESET            0x01 /* VF requests reset */
+#define IXGBE_VF_SET_MAC_ADDR     0x02 /* VF requests PF to set MAC addr */
+#define IXGBE_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
+#define IXGBE_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
+#define IXGBE_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
+
+/* length of permanent address message returned from PF */
+#define IXGBE_VF_PERMADDR_MSG_LEN 4
+/* word in permanent address message with the current multicast type */
+#define IXGBE_VF_MC_TYPE_WORD     3
+
+#define IXGBE_PF_CONTROL_MSG      0x0100 /* PF control message */
+
+#define IXGBE_VF_MBX_INIT_TIMEOUT 2000 /* number of retries on mailbox */
+#define IXGBE_VF_MBX_INIT_DELAY   500  /* microseconds between retries */
+
+/* forward declaration of the HW struct */
+struct ixgbe_hw;
+
+s32 ixgbevf_init_mbx_params_vf(struct ixgbe_hw *);
+
+#endif /* _IXGBE_MBX_H_ */

