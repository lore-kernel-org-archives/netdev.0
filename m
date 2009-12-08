From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 01/12] ixgbe: Mailbox header and code module
Date: Tue, 08 Dec 2009 14:13:12 -0800
Message-ID: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:57048
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966592AbZLHWNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:13:24 -0500
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

 drivers/net/ixgbe/ixgbe_mbx.c |  480 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_mbx.h |   96 ++++++++
 2 files changed, 576 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_mbx.c
 create mode 100644 drivers/net/ixgbe/ixgbe_mbx.h

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
new file mode 100644
index 0000000..5cd5ae8
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -0,0 +1,480 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
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
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include "ixgbe_type.h"
+#include "ixgbe_common.h"
+#include "ixgbe_mbx.h"
+
+/**
+ *  ixgbe_read_mbx - Reads a message from the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to read
+ *
+ *  returns SUCCESS if it successfuly read message from buffer
+ **/
+s32 ixgbe_read_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
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
+ *  ixgbe_write_mbx - Write a message to the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer
+ **/
+s32 ixgbe_write_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = 0;
+
+	if (size > mbx->size)
+		ret_val = IXGBE_ERR_MBX;
+
+	else if (mbx->ops.write)
+		ret_val = mbx->ops.write(hw, msg, size, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_msg - checks to see if someone sent us mail
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 ixgbe_check_for_msg(struct ixgbe_hw *hw, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (mbx->ops.check_for_msg)
+		ret_val = mbx->ops.check_for_msg(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_ack - checks to see if someone sent us ACK
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 ixgbe_check_for_ack(struct ixgbe_hw *hw, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (mbx->ops.check_for_ack)
+		ret_val = mbx->ops.check_for_ack(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_rst - checks to see if other side has reset
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to check
+ *
+ *  returns SUCCESS if the Status bit was found or else ERR_MBX
+ **/
+s32 ixgbe_check_for_rst(struct ixgbe_hw *hw, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (mbx->ops.check_for_rst)
+		ret_val = mbx->ops.check_for_rst(hw, mbx_id);
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_poll_for_msg - Wait for message notification
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message notification
+ **/
+static s32 ixgbe_poll_for_msg(struct ixgbe_hw *hw, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!countdown || !mbx->ops.check_for_msg)
+		goto out;
+
+	while (countdown && mbx->ops.check_for_msg(hw, mbx_id)) {
+		countdown--;
+		if (!countdown)
+			break;
+		udelay(mbx->usec_delay);
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
+ *  ixgbe_poll_for_ack - Wait for message acknowledgement
+ *  @hw: pointer to the HW structure
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message acknowledgement
+ **/
+static s32 ixgbe_poll_for_ack(struct ixgbe_hw *hw, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	int countdown = mbx->timeout;
+
+	if (!countdown || !mbx->ops.check_for_ack)
+		goto out;
+
+	while (countdown && mbx->ops.check_for_ack(hw, mbx_id)) {
+		countdown--;
+		if (!countdown)
+			break;
+		udelay(mbx->usec_delay);
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
+ *  ixgbe_read_posted_mbx - Wait for message notification and receive message
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully received a message notification and
+ *  copied it into the receive buffer.
+ **/
+s32 ixgbe_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size, u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (!mbx->ops.read)
+		goto out;
+
+	ret_val = ixgbe_poll_for_msg(hw, mbx_id);
+
+	/* if ack received read message, otherwise we timed out */
+	if (!ret_val)
+		ret_val = mbx->ops.read(hw, msg, size, mbx_id);
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_write_posted_mbx - Write a message to the mailbox, wait for ack
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @mbx_id: id of mailbox to write
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer and
+ *  received an ack to that message within delay * timeout period
+ **/
+s32 ixgbe_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size,
+                           u16 mbx_id)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	/* exit if either we can't write or there isn't a defined timeout */
+	if (!mbx->ops.write || !mbx->timeout)
+		goto out;
+
+	/* send msg */
+	ret_val = mbx->ops.write(hw, msg, size, mbx_id);
+
+	/* if msg sent wait until we receive an ack */
+	if (!ret_val)
+		ret_val = ixgbe_poll_for_ack(hw, mbx_id);
+out:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_init_mbx_ops_generic - Initialize MB function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Setup the mailbox read and write message function pointers
+ **/
+void ixgbe_init_mbx_ops_generic(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+
+	mbx->ops.read_posted = ixgbe_read_posted_mbx;
+	mbx->ops.write_posted = ixgbe_write_posted_mbx;
+}
+
+static s32 ixgbe_check_for_bit_pf(struct ixgbe_hw *hw, u32 mask, s32 index)
+{
+	u32 mbvficr = IXGBE_READ_REG(hw, IXGBE_MBVFICR(index));
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (mbvficr & mask) {
+		ret_val = 0;
+		IXGBE_WRITE_REG(hw, IXGBE_MBVFICR(index), mask);
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_msg_pf - checks to see if the VF has sent mail
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 ixgbe_check_for_msg_pf(struct ixgbe_hw *hw, u16 vf_number)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+	s32 index = IXGBE_MBVFICR_INDEX(vf_number);
+	u32 vf_bit = vf_number % 16;
+
+	if (!ixgbe_check_for_bit_pf(hw, IXGBE_MBVFICR_VFREQ_VF1 << vf_bit,
+	                            index)) {
+		ret_val = 0;
+		hw->mbx.stats.reqs++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_ack_pf - checks to see if the VF has ACKed
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 ixgbe_check_for_ack_pf(struct ixgbe_hw *hw, u16 vf_number)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+	s32 index = IXGBE_MBVFICR_INDEX(vf_number);
+	u32 vf_bit = vf_number % 16;
+
+	if (!ixgbe_check_for_bit_pf(hw, IXGBE_MBVFICR_VFACK_VF1 << vf_bit,
+	                            index)) {
+		ret_val = 0;
+		hw->mbx.stats.acks++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_check_for_rst_pf - checks to see if the VF has reset
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if the VF has set the Status bit or else ERR_MBX
+ **/
+static s32 ixgbe_check_for_rst_pf(struct ixgbe_hw *hw, u16 vf_number)
+{
+	u32 reg_offset = (vf_number < 32) ? 0 : 1;
+	u32 vf_shift = vf_number % 32;
+	u32 vflre = 0;
+	s32 ret_val = IXGBE_ERR_MBX;
+
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		vflre = IXGBE_READ_REG(hw, IXGBE_VFLRE(reg_offset));
+
+	if (vflre & (1 << vf_shift)) {
+		ret_val = 0;
+		IXGBE_WRITE_REG(hw, IXGBE_VFLREC(reg_offset), (1 << vf_shift));
+		hw->mbx.stats.rsts++;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_obtain_mbx_lock_pf - obtain mailbox lock
+ *  @hw: pointer to the HW structure
+ *  @vf_number: the VF index
+ *
+ *  return SUCCESS if we obtained the mailbox lock
+ **/
+static s32 ixgbe_obtain_mbx_lock_pf(struct ixgbe_hw *hw, u16 vf_number)
+{
+	s32 ret_val = IXGBE_ERR_MBX;
+	u32 p2v_mailbox;
+
+	/* Take ownership of the buffer */
+	IXGBE_WRITE_REG(hw, IXGBE_PFMAILBOX(vf_number), IXGBE_PFMAILBOX_PFU);
+
+	/* reserve mailbox for vf use */
+	p2v_mailbox = IXGBE_READ_REG(hw, IXGBE_PFMAILBOX(vf_number));
+	if (p2v_mailbox & IXGBE_PFMAILBOX_PFU)
+		ret_val = 0;
+
+	return ret_val;
+}
+
+/**
+ *  ixgbe_write_mbx_pf - Places a message in the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @vf_number: the VF index
+ *
+ *  returns SUCCESS if it successfully copied message into the buffer
+ **/
+static s32 ixgbe_write_mbx_pf(struct ixgbe_hw *hw, u32 *msg, u16 size,
+                              u16 vf_number)
+{
+	s32 ret_val;
+	u16 i;
+
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = ixgbe_obtain_mbx_lock_pf(hw, vf_number);
+	if (ret_val)
+		goto out_no_write;
+
+	/* flush msg and acks as we are overwriting the message buffer */
+	ixgbe_check_for_msg_pf(hw, vf_number);
+	ixgbe_check_for_ack_pf(hw, vf_number);
+
+	/* copy the caller specified message to the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		IXGBE_WRITE_REG_ARRAY(hw, IXGBE_PFMBMEM(vf_number), i, msg[i]);
+
+	/* Interrupt VF to tell it a message has been sent and release buffer*/
+	IXGBE_WRITE_REG(hw, IXGBE_PFMAILBOX(vf_number), IXGBE_PFMAILBOX_STS);
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
+ *  ixgbe_read_mbx_pf - Read a message from the mailbox
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ *  @vf_number: the VF index
+ *
+ *  This function copies a message from the mailbox buffer to the caller's
+ *  memory buffer.  The presumption is that the caller knows that there was
+ *  a message due to a VF request so no polling for message is needed.
+ **/
+static s32 ixgbe_read_mbx_pf(struct ixgbe_hw *hw, u32 *msg, u16 size,
+                             u16 vf_number)
+{
+	s32 ret_val;
+	u16 i;
+
+	/* lock the mailbox to prevent pf/vf race condition */
+	ret_val = ixgbe_obtain_mbx_lock_pf(hw, vf_number);
+	if (ret_val)
+		goto out_no_read;
+
+	/* copy the message to the mailbox memory buffer */
+	for (i = 0; i < size; i++)
+		msg[i] = IXGBE_READ_REG_ARRAY(hw, IXGBE_PFMBMEM(vf_number), i);
+
+	/* Acknowledge the message and release buffer */
+	IXGBE_WRITE_REG(hw, IXGBE_PFMAILBOX(vf_number), IXGBE_PFMAILBOX_ACK);
+
+	/* update stats */
+	hw->mbx.stats.msgs_rx++;
+
+out_no_read:
+	return ret_val;
+}
+
+/**
+ *  ixgbe_init_mbx_params_pf - set initial values for pf mailbox
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes the hw->mbx struct to correct values for pf mailbox
+ */
+s32 ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		mbx->timeout = 0;
+		mbx->usec_delay = 0;
+
+		mbx->size = IXGBE_VFMAILBOX_SIZE;
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
+struct ixgbe_mbx_operations mbx_ops_82599 = {
+	.read                   = ixgbe_read_mbx_pf,
+	.write                  = ixgbe_write_mbx_pf,
+	.read_posted            = ixgbe_read_posted_mbx,
+	.write_posted           = ixgbe_write_posted_mbx,
+	.check_for_msg          = ixgbe_check_for_msg_pf,
+	.check_for_ack          = ixgbe_check_for_ack_pf,
+	.check_for_rst          = ixgbe_check_for_rst_pf,
+};
+
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
new file mode 100644
index 0000000..5b3629b
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -0,0 +1,96 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
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
+#include "ixgbe_type.h"
+
+#define IXGBE_VFMAILBOX_SIZE        16 /* 16 32 bit words - 64 bytes */
+#define IXGBE_ERR_MBX               -100
+
+#define IXGBE_VFMAILBOX             0x002FC
+#define IXGBE_VFMBMEM               0x00200
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
+                                               * this are the ACK */
+#define IXGBE_VT_MSGTYPE_NACK     0x40000000  /* Messages below or'd with
+                                               * this are the NACK */
+#define IXGBE_VT_MSGTYPE_CTS      0x20000000  /* Indicates that VF is still
+                                                 clear to send requests */
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
+s32 ixgbe_read_mbx(struct ixgbe_hw *, u32 *, u16, u16);
+s32 ixgbe_write_mbx(struct ixgbe_hw *, u32 *, u16, u16);
+s32 ixgbe_read_posted_mbx(struct ixgbe_hw *, u32 *, u16, u16);
+s32 ixgbe_write_posted_mbx(struct ixgbe_hw *, u32 *, u16, u16);
+s32 ixgbe_check_for_msg(struct ixgbe_hw *, u16);
+s32 ixgbe_check_for_ack(struct ixgbe_hw *, u16);
+s32 ixgbe_check_for_rst(struct ixgbe_hw *, u16);
+void ixgbe_init_mbx_ops_generic(struct ixgbe_hw *hw);
+s32 ixgbe_init_mbx_params_pf(struct ixgbe_hw *);
+
+extern struct ixgbe_mbx_operations mbx_ops_82599;
+
+#endif /* _IXGBE_MBX_H_ */

