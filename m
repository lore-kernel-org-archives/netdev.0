From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 05/29] fm10k: Add support for mailbox
Date: Tue, 23 Sep 2014 04:16:33 -0700
Message-ID: <1411471017-28213-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10551 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472AbaIWLRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:08 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds generic mailbox support.  The general idea of the mailboxes
is to use a pair of ring buffers, one for request, one for response to send
data between the local driver and some remote entity be it the PF of the
Switch Manager.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h  | 240 +++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c  | 320 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h  |  45 ++++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h |   3 +
 4 files changed, 608 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
new file mode 100644
index 0000000..cb7aa4a
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
@@ -0,0 +1,240 @@
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
+#ifndef _FM10K_MBX_H_
+#define _FM10K_MBX_H_
+
+/* forward declaration */
+struct fm10k_mbx_info;
+
+#include "fm10k_type.h"
+#include "fm10k_tlv.h"
+
+/* PF Mailbox Registers */
+#define FM10K_MBMEM(_n)		((_n) + 0x18000)
+#define FM10K_MBMEM_VF(_n, _m)	(((_n) * 0x10) + (_m) + 0x18000)
+#define FM10K_MBMEM_SM(_n)	((_n) + 0x18400)
+#define FM10K_MBMEM_PF(_n)	((_n) + 0x18600)
+/* XOR provides means of switching from Tx to Rx FIFO */
+#define FM10K_MBMEM_PF_XOR	(FM10K_MBMEM_SM(0) ^ FM10K_MBMEM_PF(0))
+#define FM10K_MBX(_n)		((_n) + 0x18800)
+#define FM10K_MBX_REQ				0x00000002
+#define FM10K_MBX_ACK				0x00000004
+#define FM10K_MBX_REQ_INTERRUPT			0x00000008
+#define FM10K_MBX_ACK_INTERRUPT			0x00000010
+#define FM10K_MBX_INTERRUPT_ENABLE		0x00000020
+#define FM10K_MBX_INTERRUPT_DISABLE		0x00000040
+#define FM10K_MBICR(_n)		((_n) + 0x18840)
+#define FM10K_GMBX		0x18842
+
+/* VF Mailbox Registers */
+#define FM10K_VFMBX		0x00010
+#define FM10K_VFMBMEM(_n)	((_n) + 0x00020)
+#define FM10K_VFMBMEM_LEN	16
+#define FM10K_VFMBMEM_VF_XOR	(FM10K_VFMBMEM_LEN / 2)
+
+/* Delays/timeouts */
+#define FM10K_MBX_DISCONNECT_TIMEOUT		500
+#define FM10K_MBX_POLL_DELAY			19
+#define FM10K_MBX_INT_DELAY			20
+
+/* PF/VF Mailbox state machine
+ *
+ * +----------+	    connect()	+----------+
+ * |  CLOSED  | --------------> |  CONNECT |
+ * +----------+			+----------+
+ *   ^				  ^	 |
+ *   | rcv:	      rcv:	  |	 | rcv:
+ *   |  Connect	       Disconnect |	 |  Connect
+ *   |  Disconnect     Error	  |	 |  Data
+ *   |				  |	 |
+ *   |				  |	 V
+ * +----------+   disconnect()	+----------+
+ * |DISCONNECT| <-------------- |   OPEN   |
+ * +----------+			+----------+
+ *
+ * The diagram above describes the PF/VF mailbox state machine.  There
+ * are four main states to this machine.
+ * Closed: This state represents a mailbox that is in a standby state
+ *	   with interrupts disabled.  In this state the mailbox should not
+ *	   read the mailbox or write any data.  The only means of exiting
+ *	   this state is for the system to make the connect() call for the
+ *	   mailbox, it will then transition to the connect state.
+ * Connect: In this state the mailbox is seeking a connection.  It will
+ *	    post a connect message with no specified destination and will
+ *	    wait for a reply from the other side of the mailbox.  This state
+ *	    is exited when either a connect with the local mailbox as the
+ *	    destination is received or when a data message is received with
+ *	    a valid sequence number.
+ * Open: In this state the mailbox is able to transfer data between the local
+ *       entity and the remote.  It will fall back to connect in the event of
+ *       receiving either an error message, or a disconnect message.  It will
+ *       transition to disconnect on a call to disconnect();
+ * Disconnect: In this state the mailbox is attempting to gracefully terminate
+ *	       the connection.  It will do so at the first point where it knows
+ *	       that the remote endpoint is either done sending, or when the
+ *	       remote endpoint has fallen back into connect.
+ */
+enum fm10k_mbx_state {
+	FM10K_STATE_CLOSED,
+	FM10K_STATE_CONNECT,
+	FM10K_STATE_OPEN,
+	FM10K_STATE_DISCONNECT,
+};
+
+/* macros for retriving and setting header values */
+#define FM10K_MSG_HDR_MASK(name) \
+	((0x1u << FM10K_MSG_##name##_SIZE) - 1)
+#define FM10K_MSG_HDR_FIELD_SET(value, name) \
+	(((u32)(value) & FM10K_MSG_HDR_MASK(name)) << FM10K_MSG_##name##_SHIFT)
+#define FM10K_MSG_HDR_FIELD_GET(value, name) \
+	((u16)((value) >> FM10K_MSG_##name##_SHIFT) & FM10K_MSG_HDR_MASK(name))
+
+/* HNI/SM Mailbox FIFO format
+ *    3                   2                   1                   0
+ *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ * +-------+-----------------------+-------+-----------------------+
+ * | Error |      Remote Head      |Version|      Local Tail       |
+ * +-------+-----------------------+-------+-----------------------+
+ * |                                                               |
+ * .                        Local FIFO Data                        .
+ * .                                                               .
+ * +-------+-----------------------+-------+-----------------------+
+ *
+ * The layout above describes the format for the FIFOs used by the host
+ * network interface and the switch manager to communicate messages back
+ * and forth.  Both the HNI and the switch maintain one such FIFO.  The
+ * layout in memory has the switch manager FIFO followed immediately by
+ * the HNI FIFO.  For this reason I am using just the pointer to the
+ * HNI FIFO in the mailbox ops as the offset between the two is fixed.
+ *
+ * The header for the FIFO is broken out into the following fields:
+ * Local Tail:  Offset into FIFO region for next DWORD to write.
+ * Version:  Version info for mailbox, only values of 0/1 are supported.
+ * Remote Head:  Offset into remote FIFO to indicate how much we have read.
+ * Error: Error indication, values TBD.
+ */
+
+/* version number for switch manager mailboxes */
+#define FM10K_SM_MBX_VERSION		1
+#define FM10K_SM_MBX_FIFO_LEN		(FM10K_MBMEM_PF_XOR - 1)
+
+/* offsets shared between all SM FIFO headers */
+#define FM10K_MSG_SM_TAIL_SHIFT			0
+#define FM10K_MSG_SM_TAIL_SIZE			12
+#define FM10K_MSG_SM_VER_SHIFT			12
+#define FM10K_MSG_SM_VER_SIZE			4
+#define FM10K_MSG_SM_HEAD_SHIFT			16
+#define FM10K_MSG_SM_HEAD_SIZE			12
+#define FM10K_MSG_SM_ERR_SHIFT			28
+#define FM10K_MSG_SM_ERR_SIZE			4
+
+/* All error messages returned by mailbox functions
+ * The value -511 is 0xFE01 in hex.  The idea is to order the errors
+ * from 0xFE01 - 0xFEFF so error codes are easily visible in the mailbox
+ * messages.  This also helps to avoid error number collisions as Linux
+ * doesn't appear to use error numbers 256 - 511.
+ */
+#define FM10K_MBX_ERR(_n) ((_n) - 512)
+#define FM10K_MBX_ERR_NO_MBX		FM10K_MBX_ERR(0x01)
+#define FM10K_MBX_ERR_NO_SPACE		FM10K_MBX_ERR(0x03)
+#define FM10K_MBX_ERR_TAIL		FM10K_MBX_ERR(0x05)
+#define FM10K_MBX_ERR_HEAD		FM10K_MBX_ERR(0x06)
+#define FM10K_MBX_ERR_SRC		FM10K_MBX_ERR(0x08)
+#define FM10K_MBX_ERR_TYPE		FM10K_MBX_ERR(0x09)
+#define FM10K_MBX_ERR_SIZE		FM10K_MBX_ERR(0x0B)
+#define FM10K_MBX_ERR_BUSY		FM10K_MBX_ERR(0x0C)
+#define FM10K_MBX_ERR_RSVD0		FM10K_MBX_ERR(0x0E)
+#define FM10K_MBX_ERR_CRC		FM10K_MBX_ERR(0x0F)
+
+#define FM10K_MBX_CRC_SEED		0xFFFF
+
+struct fm10k_mbx_ops {
+	s32 (*connect)(struct fm10k_hw *, struct fm10k_mbx_info *);
+	void (*disconnect)(struct fm10k_hw *, struct fm10k_mbx_info *);
+	bool (*rx_ready)(struct fm10k_mbx_info *);
+	bool (*tx_ready)(struct fm10k_mbx_info *, u16);
+	bool (*tx_complete)(struct fm10k_mbx_info *);
+	s32 (*enqueue_tx)(struct fm10k_hw *, struct fm10k_mbx_info *,
+			  const u32 *);
+	s32 (*process)(struct fm10k_hw *, struct fm10k_mbx_info *);
+	s32 (*register_handlers)(struct fm10k_mbx_info *,
+				 const struct fm10k_msg_data *);
+};
+
+struct fm10k_mbx_fifo {
+	u32 *buffer;
+	u16 head;
+	u16 tail;
+	u16 size;
+};
+
+/* size of buffer to be stored in mailbox for FIFOs */
+#define FM10K_MBX_TX_BUFFER_SIZE	512
+#define FM10K_MBX_RX_BUFFER_SIZE	128
+#define FM10K_MBX_BUFFER_SIZE \
+	(FM10K_MBX_TX_BUFFER_SIZE + FM10K_MBX_RX_BUFFER_SIZE)
+
+/* minimum and maximum message size in dwords */
+#define FM10K_MBX_MSG_MAX_SIZE \
+	((FM10K_MBX_TX_BUFFER_SIZE - 1) & (FM10K_MBX_RX_BUFFER_SIZE - 1))
+#define FM10K_VFMBX_MSG_MTU	((FM10K_VFMBMEM_LEN / 2) - 1)
+
+#define FM10K_MBX_INIT_TIMEOUT	2000 /* number of retries on mailbox */
+#define FM10K_MBX_INIT_DELAY	500  /* microseconds between retries */
+
+struct fm10k_mbx_info {
+	/* function pointers for mailbox operations */
+	struct fm10k_mbx_ops ops;
+	const struct fm10k_msg_data *msg_data;
+
+	/* message FIFOs */
+	struct fm10k_mbx_fifo rx;
+	struct fm10k_mbx_fifo tx;
+
+	/* delay for handling timeouts */
+	u32 timeout;
+	u32 udelay;
+
+	/* mailbox state info */
+	u32 mbx_reg, mbmem_reg, mbx_lock, mbx_hdr;
+	u16 max_size, mbmem_len;
+	u16 tail, tail_len, pulled;
+	u16 head, head_len, pushed;
+	u16 local, remote;
+	enum fm10k_mbx_state state;
+
+	/* result of last mailbox test */
+	s32 test_result;
+
+	/* statistics */
+	u64 tx_busy;
+	u64 tx_dropped;
+	u64 tx_messages;
+	u64 tx_dwords;
+	u64 rx_messages;
+	u64 rx_dwords;
+	u64 rx_parse_err;
+
+	/* Buffer to store messages */
+	u32 buffer[FM10K_MBX_BUFFER_SIZE];
+};
+
+#endif /* _FM10K_MBX_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
index f1fc709..fd0a05f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -541,3 +541,323 @@ s32 fm10k_tlv_attr_parse(u32 *attr, u32 **results,
 
 	return 0;
 }
+
+/**
+ *  fm10k_tlv_msg_parse - Parses message header and calls function handler
+ *  @hw: Pointer to hardware structure
+ *  @msg: Pointer to message
+ *  @mbx: Pointer to mailbox information structure
+ *  @func: Function array containing list of message handling functions
+ *
+ *  This function should be the first function called upon receiving a
+ *  message.  The handler will identify the message type and call the correct
+ *  handler for the given message.  It will return the value from the function
+ *  call on a recognized message type, otherwise it will return
+ *  FM10K_NOT_IMPLEMENTED on an unrecognized type.
+ **/
+s32 fm10k_tlv_msg_parse(struct fm10k_hw *hw, u32 *msg,
+			struct fm10k_mbx_info *mbx,
+			const struct fm10k_msg_data *data)
+{
+	u32 *results[FM10K_TLV_RESULTS_MAX];
+	u32 msg_id;
+	s32 err;
+
+	/* verify pointer is not NULL */
+	if (!msg || !data)
+		return FM10K_ERR_PARAM;
+
+	/* verify this is a message and not an attribute */
+	if (!(*msg & (FM10K_TLV_FLAGS_MSG << FM10K_TLV_FLAGS_SHIFT)))
+		return FM10K_ERR_PARAM;
+
+	/* grab message ID */
+	msg_id = *msg & FM10K_TLV_ID_MASK;
+
+	while (data->id < msg_id)
+		data++;
+
+	/* if we didn't find it then pass it up as an error */
+	if (data->id != msg_id) {
+		while (data->id != FM10K_TLV_ERROR)
+			data++;
+	}
+
+	/* parse the attributes into the results list */
+	err = fm10k_tlv_attr_parse(msg, results, data->attr);
+	if (err < 0)
+		return err;
+
+	return data->func(hw, results, mbx);
+}
+
+/**
+ *  fm10k_tlv_msg_error - Default handler for unrecognized TLV message IDs
+ *  @hw: Pointer to hardware structure
+ *  @results: Pointer array to message, results[0] is pointer to message
+ *  @mbx: Unused mailbox pointer
+ *
+ *  This function is a default handler for unrecognized messages.  At a
+ *  a minimum it just indicates that the message requested was
+ *  unimplemented.
+ **/
+s32 fm10k_tlv_msg_error(struct fm10k_hw *hw, u32 **results,
+			struct fm10k_mbx_info *mbx)
+{
+	return FM10K_NOT_IMPLEMENTED;
+}
+
+static const unsigned char test_str[] =	"fm10k";
+static const unsigned char test_mac[ETH_ALEN] = { 0x12, 0x34, 0x56,
+						  0x78, 0x9a, 0xbc };
+static const u16 test_vlan = 0x0FED;
+static const u64 test_u64 = 0xfedcba9876543210ull;
+static const u32 test_u32 = 0x87654321;
+static const u16 test_u16 = 0x8765;
+static const u8  test_u8  = 0x87;
+static const s64 test_s64 = -0x123456789abcdef0ll;
+static const s32 test_s32 = -0x1235678;
+static const s16 test_s16 = -0x1234;
+static const s8  test_s8  = -0x12;
+static const __le32 test_le[2] = { cpu_to_le32(0x12345678),
+				   cpu_to_le32(0x9abcdef0)};
+
+/* The message below is meant to be used as a test message to demonstrate
+ * how to use the TLV interface and to test the types.  Normally this code
+ * be compiled out by stripping the code wrapped in FM10K_TLV_TEST_MSG
+ */
+const struct fm10k_tlv_attr fm10k_tlv_msg_test_attr[] = {
+	FM10K_TLV_ATTR_NULL_STRING(FM10K_TEST_MSG_STRING, 80),
+	FM10K_TLV_ATTR_MAC_ADDR(FM10K_TEST_MSG_MAC_ADDR),
+	FM10K_TLV_ATTR_U8(FM10K_TEST_MSG_U8),
+	FM10K_TLV_ATTR_U16(FM10K_TEST_MSG_U16),
+	FM10K_TLV_ATTR_U32(FM10K_TEST_MSG_U32),
+	FM10K_TLV_ATTR_U64(FM10K_TEST_MSG_U64),
+	FM10K_TLV_ATTR_S8(FM10K_TEST_MSG_S8),
+	FM10K_TLV_ATTR_S16(FM10K_TEST_MSG_S16),
+	FM10K_TLV_ATTR_S32(FM10K_TEST_MSG_S32),
+	FM10K_TLV_ATTR_S64(FM10K_TEST_MSG_S64),
+	FM10K_TLV_ATTR_LE_STRUCT(FM10K_TEST_MSG_LE_STRUCT, 8),
+	FM10K_TLV_ATTR_NESTED(FM10K_TEST_MSG_NESTED),
+	FM10K_TLV_ATTR_S32(FM10K_TEST_MSG_RESULT),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_tlv_msg_test_generate_data - Stuff message with data
+ *  @msg: Pointer to message
+ *  @attr_flags: List of flags indicating what attributes to add
+ *
+ *  This function is meant to load a message buffer with attribute data
+ **/
+static void fm10k_tlv_msg_test_generate_data(u32 *msg, u32 attr_flags)
+{
+	if (attr_flags & (1 << FM10K_TEST_MSG_STRING))
+		fm10k_tlv_attr_put_null_string(msg, FM10K_TEST_MSG_STRING,
+					       test_str);
+	if (attr_flags & (1 << FM10K_TEST_MSG_MAC_ADDR))
+		fm10k_tlv_attr_put_mac_vlan(msg, FM10K_TEST_MSG_MAC_ADDR,
+					    test_mac, test_vlan);
+	if (attr_flags & (1 << FM10K_TEST_MSG_U8))
+		fm10k_tlv_attr_put_u8(msg, FM10K_TEST_MSG_U8,  test_u8);
+	if (attr_flags & (1 << FM10K_TEST_MSG_U16))
+		fm10k_tlv_attr_put_u16(msg, FM10K_TEST_MSG_U16, test_u16);
+	if (attr_flags & (1 << FM10K_TEST_MSG_U32))
+		fm10k_tlv_attr_put_u32(msg, FM10K_TEST_MSG_U32, test_u32);
+	if (attr_flags & (1 << FM10K_TEST_MSG_U64))
+		fm10k_tlv_attr_put_u64(msg, FM10K_TEST_MSG_U64, test_u64);
+	if (attr_flags & (1 << FM10K_TEST_MSG_S8))
+		fm10k_tlv_attr_put_s8(msg, FM10K_TEST_MSG_S8,  test_s8);
+	if (attr_flags & (1 << FM10K_TEST_MSG_S16))
+		fm10k_tlv_attr_put_s16(msg, FM10K_TEST_MSG_S16, test_s16);
+	if (attr_flags & (1 << FM10K_TEST_MSG_S32))
+		fm10k_tlv_attr_put_s32(msg, FM10K_TEST_MSG_S32, test_s32);
+	if (attr_flags & (1 << FM10K_TEST_MSG_S64))
+		fm10k_tlv_attr_put_s64(msg, FM10K_TEST_MSG_S64, test_s64);
+	if (attr_flags & (1 << FM10K_TEST_MSG_LE_STRUCT))
+		fm10k_tlv_attr_put_le_struct(msg, FM10K_TEST_MSG_LE_STRUCT,
+					     test_le, 8);
+}
+
+/**
+ *  fm10k_tlv_msg_test_create - Create a test message testing all attributes
+ *  @msg: Pointer to message
+ *  @attr_flags: List of flags indicating what attributes to add
+ *
+ *  This function is meant to load a message buffer with all attribute types
+ *  including a nested attribute.
+ **/
+void fm10k_tlv_msg_test_create(u32 *msg, u32 attr_flags)
+{
+	u32 *nest = NULL;
+
+	fm10k_tlv_msg_init(msg, FM10K_TLV_MSG_ID_TEST);
+
+	fm10k_tlv_msg_test_generate_data(msg, attr_flags);
+
+	/* check for nested attributes */
+	attr_flags >>= FM10K_TEST_MSG_NESTED;
+
+	if (attr_flags) {
+		nest = fm10k_tlv_attr_nest_start(msg, FM10K_TEST_MSG_NESTED);
+
+		fm10k_tlv_msg_test_generate_data(nest, attr_flags);
+
+		fm10k_tlv_attr_nest_stop(msg);
+	}
+}
+
+/**
+ *  fm10k_tlv_msg_test - Validate all results on test message receive
+ *  @hw: Pointer to hardware structure
+ *  @results: Pointer array to attributes in the mesage
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This function does a check to verify all attributes match what the test
+ *  message placed in the message buffer.  It is the default handler
+ *  for TLV test messages.
+ **/
+s32 fm10k_tlv_msg_test(struct fm10k_hw *hw, u32 **results,
+		       struct fm10k_mbx_info *mbx)
+{
+	u32 *nest_results[FM10K_TLV_RESULTS_MAX];
+	unsigned char result_str[80];
+	unsigned char result_mac[ETH_ALEN];
+	s32 err = 0;
+	__le32 result_le[2];
+	u16 result_vlan;
+	u64 result_u64;
+	u32 result_u32;
+	u16 result_u16;
+	u8  result_u8;
+	s64 result_s64;
+	s32 result_s32;
+	s16 result_s16;
+	s8  result_s8;
+	u32 reply[3];
+
+	/* retrieve results of a previous test */
+	if (!!results[FM10K_TEST_MSG_RESULT])
+		return fm10k_tlv_attr_get_s32(results[FM10K_TEST_MSG_RESULT],
+					      &mbx->test_result);
+
+parse_nested:
+	if (!!results[FM10K_TEST_MSG_STRING]) {
+		err = fm10k_tlv_attr_get_null_string(
+					results[FM10K_TEST_MSG_STRING],
+					result_str);
+		if (!err && memcmp(test_str, result_str, sizeof(test_str)))
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_MAC_ADDR]) {
+		err = fm10k_tlv_attr_get_mac_vlan(
+					results[FM10K_TEST_MSG_MAC_ADDR],
+					result_mac, &result_vlan);
+		if (!err && memcmp(test_mac, result_mac, ETH_ALEN))
+			err = FM10K_ERR_INVALID_VALUE;
+		if (!err && test_vlan != result_vlan)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_U8]) {
+		err = fm10k_tlv_attr_get_u8(results[FM10K_TEST_MSG_U8],
+					    &result_u8);
+		if (!err && test_u8 != result_u8)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_U16]) {
+		err = fm10k_tlv_attr_get_u16(results[FM10K_TEST_MSG_U16],
+					     &result_u16);
+		if (!err && test_u16 != result_u16)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_U32]) {
+		err = fm10k_tlv_attr_get_u32(results[FM10K_TEST_MSG_U32],
+					     &result_u32);
+		if (!err && test_u32 != result_u32)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_U64]) {
+		err = fm10k_tlv_attr_get_u64(results[FM10K_TEST_MSG_U64],
+					     &result_u64);
+		if (!err && test_u64 != result_u64)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_S8]) {
+		err = fm10k_tlv_attr_get_s8(results[FM10K_TEST_MSG_S8],
+					    &result_s8);
+		if (!err && test_s8 != result_s8)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_S16]) {
+		err = fm10k_tlv_attr_get_s16(results[FM10K_TEST_MSG_S16],
+					     &result_s16);
+		if (!err && test_s16 != result_s16)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_S32]) {
+		err = fm10k_tlv_attr_get_s32(results[FM10K_TEST_MSG_S32],
+					     &result_s32);
+		if (!err && test_s32 != result_s32)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_S64]) {
+		err = fm10k_tlv_attr_get_s64(results[FM10K_TEST_MSG_S64],
+					     &result_s64);
+		if (!err && test_s64 != result_s64)
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+	if (!!results[FM10K_TEST_MSG_LE_STRUCT]) {
+		err = fm10k_tlv_attr_get_le_struct(
+					results[FM10K_TEST_MSG_LE_STRUCT],
+					result_le,
+					sizeof(result_le));
+		if (!err && memcmp(test_le, result_le, sizeof(test_le)))
+			err = FM10K_ERR_INVALID_VALUE;
+		if (err)
+			goto report_result;
+	}
+
+	if (!!results[FM10K_TEST_MSG_NESTED]) {
+		/* clear any pointers */
+		memset(nest_results, 0, sizeof(nest_results));
+
+		/* parse the nested attributes into the nest results list */
+		err = fm10k_tlv_attr_parse(results[FM10K_TEST_MSG_NESTED],
+					   nest_results,
+					   fm10k_tlv_msg_test_attr);
+		if (err)
+			goto report_result;
+
+		/* loop back through to the start */
+		results = nest_results;
+		goto parse_nested;
+	}
+
+report_result:
+	/* generate reply with test result */
+	fm10k_tlv_msg_init(reply, FM10K_TLV_MSG_ID_TEST);
+	fm10k_tlv_attr_put_s32(reply, FM10K_TEST_MSG_RESULT, err);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, reply);
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
index 6d22db6..7e045e8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
@@ -21,6 +21,9 @@
 #ifndef _FM10K_TLV_H_
 #define _FM10K_TLV_H_
 
+/* forward declaration */
+struct fm10k_msg_data;
+
 #include "fm10k_type.h"
 
 /* Message / Argument header format
@@ -93,6 +96,15 @@ struct fm10k_tlv_attr {
 #define FM10K_TLV_ATTR_NESTED(id)	    { id, FM10K_TLV_NESTED }
 #define FM10K_TLV_ATTR_LAST		    { FM10K_TLV_ERROR }
 
+struct fm10k_msg_data {
+	unsigned int		    id;
+	const struct fm10k_tlv_attr *attr;
+	s32			    (*func)(struct fm10k_hw *, u32 **,
+					    struct fm10k_mbx_info *);
+};
+
+#define FM10K_MSG_HANDLER(id, attr, func) { id, attr, func }
+
 s32 fm10k_tlv_msg_init(u32 *, u16);
 s32 fm10k_tlv_attr_put_null_string(u32 *, u16, const unsigned char *);
 s32 fm10k_tlv_attr_get_null_string(u32 *, unsigned char *);
@@ -138,4 +150,37 @@ s32 fm10k_tlv_attr_get_le_struct(u32 *, void *, u32);
 u32 *fm10k_tlv_attr_nest_start(u32 *, u16);
 s32 fm10k_tlv_attr_nest_stop(u32 *);
 s32 fm10k_tlv_attr_parse(u32 *, u32 **, const struct fm10k_tlv_attr *);
+s32 fm10k_tlv_msg_parse(struct fm10k_hw *, u32 *, struct fm10k_mbx_info *,
+			const struct fm10k_msg_data *);
+s32 fm10k_tlv_msg_error(struct fm10k_hw *hw, u32 **results,
+			struct fm10k_mbx_info *);
+
+#define FM10K_TLV_MSG_ID_TEST	0
+
+enum fm10k_tlv_test_attr_id {
+	FM10K_TEST_MSG_UNSET,
+	FM10K_TEST_MSG_STRING,
+	FM10K_TEST_MSG_MAC_ADDR,
+	FM10K_TEST_MSG_U8,
+	FM10K_TEST_MSG_U16,
+	FM10K_TEST_MSG_U32,
+	FM10K_TEST_MSG_U64,
+	FM10K_TEST_MSG_S8,
+	FM10K_TEST_MSG_S16,
+	FM10K_TEST_MSG_S32,
+	FM10K_TEST_MSG_S64,
+	FM10K_TEST_MSG_LE_STRUCT,
+	FM10K_TEST_MSG_NESTED,
+	FM10K_TEST_MSG_RESULT,
+	FM10K_TEST_MSG_MAX
+};
+
+extern const struct fm10k_tlv_attr fm10k_tlv_msg_test_attr[];
+void fm10k_tlv_msg_test_create(u32 *, u32);
+s32 fm10k_tlv_msg_test(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
+
+#define FM10K_TLV_MSG_TEST_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_TLV_MSG_ID_TEST, fm10k_tlv_msg_test_attr, func)
+#define FM10K_TLV_MSG_ERROR_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_TLV_ERROR, NULL, func)
 #endif /* _FM10K_MSG_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 1606805..eda0c7c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -28,6 +28,8 @@ struct fm10k_hw;
 #include <asm/byteorder.h>
 #include <linux/etherdevice.h>
 
+#include "fm10k_mbx.h"
+
 #define FM10K_DEV_ID_PF			0x15A4
 #define FM10K_DEV_ID_VF			0x15A5
 
@@ -573,6 +575,7 @@ struct fm10k_hw {
 	struct fm10k_mac_info mac;
 	struct fm10k_bus_info bus;
 	struct fm10k_bus_info bus_caps;
+	struct fm10k_mbx_info mbx;
 	struct fm10k_swapi_info swapi;
 	u16 device_id;
 	u16 vendor_id;
-- 
1.9.3
