From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 22/29] fm10k: Add support for PF <-> VF mailbox
Date: Sat, 20 Sep 2014 19:51:27 -0400
Message-ID: <20140920235120.2977.44214.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25144 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbaIUAAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 20:00:12 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the PF <-> VF mailbox.  It functions similar to
the PF <-> SM mailbox however there are several modifications made to
improve the reliability of the mailbox itself.  In addition the PF/VF
mailbox is much smaller an only supports a total size of 16 DWORDs vs the
1024 DWORDS provided for the PF/SM mailbox.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c |  770 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h |   64 ++
 2 files changed, 834 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 2609847..a6a66fd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -511,6 +511,148 @@ static s32 fm10k_mbx_push_tail(struct fm10k_hw *hw,
 	return 0;
 }
 
+/* pre-generated data for generating the CRC based on the poly 0xAC9A. */
+static const u16 fm10k_crc_16b_table[256] = {
+	0x0000, 0x7956, 0xF2AC, 0x8BFA, 0xBC6D, 0xC53B, 0x4EC1, 0x3797,
+	0x21EF, 0x58B9, 0xD343, 0xAA15, 0x9D82, 0xE4D4, 0x6F2E, 0x1678,
+	0x43DE, 0x3A88, 0xB172, 0xC824, 0xFFB3, 0x86E5, 0x0D1F, 0x7449,
+	0x6231, 0x1B67, 0x909D, 0xE9CB, 0xDE5C, 0xA70A, 0x2CF0, 0x55A6,
+	0x87BC, 0xFEEA, 0x7510, 0x0C46, 0x3BD1, 0x4287, 0xC97D, 0xB02B,
+	0xA653, 0xDF05, 0x54FF, 0x2DA9, 0x1A3E, 0x6368, 0xE892, 0x91C4,
+	0xC462, 0xBD34, 0x36CE, 0x4F98, 0x780F, 0x0159, 0x8AA3, 0xF3F5,
+	0xE58D, 0x9CDB, 0x1721, 0x6E77, 0x59E0, 0x20B6, 0xAB4C, 0xD21A,
+	0x564D, 0x2F1B, 0xA4E1, 0xDDB7, 0xEA20, 0x9376, 0x188C, 0x61DA,
+	0x77A2, 0x0EF4, 0x850E, 0xFC58, 0xCBCF, 0xB299, 0x3963, 0x4035,
+	0x1593, 0x6CC5, 0xE73F, 0x9E69, 0xA9FE, 0xD0A8, 0x5B52, 0x2204,
+	0x347C, 0x4D2A, 0xC6D0, 0xBF86, 0x8811, 0xF147, 0x7ABD, 0x03EB,
+	0xD1F1, 0xA8A7, 0x235D, 0x5A0B, 0x6D9C, 0x14CA, 0x9F30, 0xE666,
+	0xF01E, 0x8948, 0x02B2, 0x7BE4, 0x4C73, 0x3525, 0xBEDF, 0xC789,
+	0x922F, 0xEB79, 0x6083, 0x19D5, 0x2E42, 0x5714, 0xDCEE, 0xA5B8,
+	0xB3C0, 0xCA96, 0x416C, 0x383A, 0x0FAD, 0x76FB, 0xFD01, 0x8457,
+	0xAC9A, 0xD5CC, 0x5E36, 0x2760, 0x10F7, 0x69A1, 0xE25B, 0x9B0D,
+	0x8D75, 0xF423, 0x7FD9, 0x068F, 0x3118, 0x484E, 0xC3B4, 0xBAE2,
+	0xEF44, 0x9612, 0x1DE8, 0x64BE, 0x5329, 0x2A7F, 0xA185, 0xD8D3,
+	0xCEAB, 0xB7FD, 0x3C07, 0x4551, 0x72C6, 0x0B90, 0x806A, 0xF93C,
+	0x2B26, 0x5270, 0xD98A, 0xA0DC, 0x974B, 0xEE1D, 0x65E7, 0x1CB1,
+	0x0AC9, 0x739F, 0xF865, 0x8133, 0xB6A4, 0xCFF2, 0x4408, 0x3D5E,
+	0x68F8, 0x11AE, 0x9A54, 0xE302, 0xD495, 0xADC3, 0x2639, 0x5F6F,
+	0x4917, 0x3041, 0xBBBB, 0xC2ED, 0xF57A, 0x8C2C, 0x07D6, 0x7E80,
+	0xFAD7, 0x8381, 0x087B, 0x712D, 0x46BA, 0x3FEC, 0xB416, 0xCD40,
+	0xDB38, 0xA26E, 0x2994, 0x50C2, 0x6755, 0x1E03, 0x95F9, 0xECAF,
+	0xB909, 0xC05F, 0x4BA5, 0x32F3, 0x0564, 0x7C32, 0xF7C8, 0x8E9E,
+	0x98E6, 0xE1B0, 0x6A4A, 0x131C, 0x248B, 0x5DDD, 0xD627, 0xAF71,
+	0x7D6B, 0x043D, 0x8FC7, 0xF691, 0xC106, 0xB850, 0x33AA, 0x4AFC,
+	0x5C84, 0x25D2, 0xAE28, 0xD77E, 0xE0E9, 0x99BF, 0x1245, 0x6B13,
+	0x3EB5, 0x47E3, 0xCC19, 0xB54F, 0x82D8, 0xFB8E, 0x7074, 0x0922,
+	0x1F5A, 0x660C, 0xEDF6, 0x94A0, 0xA337, 0xDA61, 0x519B, 0x28CD };
+
+/**
+ *  fm10k_crc_16b - Generate a 16 bit CRC for a region of 16 bit data
+ *  @data: pointer to data to process
+ *  @seed: seed value for CRC
+ *  @len: length measured in 16 bits words
+ *
+ *  This function will generate a CRC based on the polynomial 0xAC9A and
+ *  whatever value is stored in the seed variable.  Note that this
+ *  value inverts the local seed and the result in order to capture all
+ *  leading and trailing zeros.
+ */
+static u16 fm10k_crc_16b(const u32 *data, u16 seed, u16 len)
+{
+	u32 result = seed;
+
+	while (len--) {
+		result ^= *(data++);
+		result = (result >> 8) ^ fm10k_crc_16b_table[result & 0xFF];
+		result = (result >> 8) ^ fm10k_crc_16b_table[result & 0xFF];
+
+		if (!(len--))
+			break;
+
+		result = (result >> 8) ^ fm10k_crc_16b_table[result & 0xFF];
+		result = (result >> 8) ^ fm10k_crc_16b_table[result & 0xFF];
+	}
+
+	return (u16)result;
+}
+
+/**
+ *  fm10k_fifo_crc - generate a CRC based off of FIFO data
+ *  @fifo: pointer to FIFO
+ *  @offset: offset point for start of FIFO
+ *  @len: number of DWORDS words to process
+ *  @seed: seed value for CRC
+ *
+ *  This function generates a CRC for some region of the FIFO
+ **/
+static u16 fm10k_fifo_crc(struct fm10k_mbx_fifo *fifo, u16 offset,
+			  u16 len, u16 seed)
+{
+	u32 *data = fifo->buffer + offset;
+
+	/* track when we should cross the end of the FIFO */
+	offset = fifo->size - offset;
+
+	/* if we are in 2 blocks process the end of the FIFO first */
+	if (offset < len) {
+		seed = fm10k_crc_16b(data, seed, offset * 2);
+		data = fifo->buffer;
+		len -= offset;
+	}
+
+	/* process any remaining bits */
+	return fm10k_crc_16b(data, seed, len * 2);
+}
+
+/**
+ *  fm10k_mbx_update_local_crc - Update the local CRC for outgoing data
+ *  @mbx: pointer to mailbox
+ *  @head: head index provided by remote mailbox
+ *
+ *  This function will generate the CRC for all data from the end of the
+ *  last head update to the current one.  It uses the result of the
+ *  previous CRC as the seed for this update.  The result is stored in
+ *  mbx->local.
+ **/
+static void fm10k_mbx_update_local_crc(struct fm10k_mbx_info *mbx, u16 head)
+{
+	u16 len = mbx->tail_len - fm10k_mbx_index_len(mbx, head, mbx->tail);
+
+	/* determine the offset for the start of the region to be pulled */
+	head = fm10k_fifo_head_offset(&mbx->tx, mbx->pulled);
+
+	/* update local CRC to include all of the pulled data */
+	mbx->local = fm10k_fifo_crc(&mbx->tx, head, len, mbx->local);
+}
+
+/**
+ *  fm10k_mbx_verify_remote_crc - Verify the CRC is correct for current data
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will take all data that has been provided from the remote
+ *  end and generate a CRC for it.  This is stored in mbx->remote.  The
+ *  CRC for the header is then computed and if the result is non-zero this
+ *  is an error and we signal an error dropping all data and resetting the
+ *  connection.
+ */
+static s32 fm10k_mbx_verify_remote_crc(struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_mbx_fifo *fifo = &mbx->rx;
+	u16 len = mbx->head_len;
+	u16 offset = fm10k_fifo_tail_offset(fifo, mbx->pushed) - len;
+	u16 crc;
+
+	/* update the remote CRC if new data has been received */
+	if (len)
+		mbx->remote = fm10k_fifo_crc(fifo, offset, len, mbx->remote);
+
+	/* process the full header as we have to validate the CRC */
+	crc = fm10k_crc_16b(&mbx->mbx_hdr, mbx->remote, 1);
+
+	/* notify other end if we have a problem */
+	return crc ? FM10K_MBX_ERR_CRC : 0;
+}
+
 /**
  *  fm10k_mbx_rx_ready - Indicates that a message is ready in the Rx FIFO
  *  @mbx: pointer to mailbox
@@ -686,6 +828,204 @@ static void fm10k_mbx_write(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx)
 }
 
 /**
+ *  fm10k_mbx_create_connect_hdr - Generate a connect mailbox header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function returns a connection mailbox header
+ **/
+static void fm10k_mbx_create_connect_hdr(struct fm10k_mbx_info *mbx)
+{
+	mbx->mbx_lock |= FM10K_MBX_REQ;
+
+	mbx->mbx_hdr = FM10K_MSG_HDR_FIELD_SET(FM10K_MSG_CONNECT, TYPE) |
+		       FM10K_MSG_HDR_FIELD_SET(mbx->head, HEAD) |
+		       FM10K_MSG_HDR_FIELD_SET(mbx->rx.size - 1, CONNECT_SIZE);
+}
+
+/**
+ *  fm10k_mbx_create_data_hdr - Generate a data mailbox header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function returns a data mailbox header
+ **/
+static void fm10k_mbx_create_data_hdr(struct fm10k_mbx_info *mbx)
+{
+	u32 hdr = FM10K_MSG_HDR_FIELD_SET(FM10K_MSG_DATA, TYPE) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->tail, TAIL) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->head, HEAD);
+	struct fm10k_mbx_fifo *fifo = &mbx->tx;
+	u16 crc;
+
+	if (mbx->tail_len)
+		mbx->mbx_lock |= FM10K_MBX_REQ;
+
+	/* generate CRC for data in flight and header */
+	crc = fm10k_fifo_crc(fifo, fm10k_fifo_head_offset(fifo, mbx->pulled),
+			     mbx->tail_len, mbx->local);
+	crc = fm10k_crc_16b(&hdr, crc, 1);
+
+	/* load header to memory to be written */
+	mbx->mbx_hdr = hdr | FM10K_MSG_HDR_FIELD_SET(crc, CRC);
+}
+
+/**
+ *  fm10k_mbx_create_disconnect_hdr - Generate a disconnect mailbox header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function returns a disconnect mailbox header
+ **/
+static void fm10k_mbx_create_disconnect_hdr(struct fm10k_mbx_info *mbx)
+{
+	u32 hdr = FM10K_MSG_HDR_FIELD_SET(FM10K_MSG_DISCONNECT, TYPE) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->tail, TAIL) |
+		  FM10K_MSG_HDR_FIELD_SET(mbx->head, HEAD);
+	u16 crc = fm10k_crc_16b(&hdr, mbx->local, 1);
+
+	mbx->mbx_lock |= FM10K_MBX_ACK;
+
+	/* load header to memory to be written */
+	mbx->mbx_hdr = hdr | FM10K_MSG_HDR_FIELD_SET(crc, CRC);
+}
+
+/**
+ *  fm10k_mbx_create_error_msg - Generate a error message
+ *  @mbx: pointer to mailbox
+ *  @err: local error encountered
+ *
+ *  This function will interpret the error provided by err, and based on
+ *  that it may shift the message by 1 DWORD and then place an error header
+ *  at the start of the message.
+ **/
+static void fm10k_mbx_create_error_msg(struct fm10k_mbx_info *mbx, s32 err)
+{
+	/* only generate an error message for these types */
+	switch (err) {
+	case FM10K_MBX_ERR_TAIL:
+	case FM10K_MBX_ERR_HEAD:
+	case FM10K_MBX_ERR_TYPE:
+	case FM10K_MBX_ERR_SIZE:
+	case FM10K_MBX_ERR_RSVD0:
+	case FM10K_MBX_ERR_CRC:
+		break;
+	default:
+		return;
+	}
+
+	mbx->mbx_lock |= FM10K_MBX_REQ;
+
+	mbx->mbx_hdr = FM10K_MSG_HDR_FIELD_SET(FM10K_MSG_ERROR, TYPE) |
+		       FM10K_MSG_HDR_FIELD_SET(err, ERR_NO) |
+		       FM10K_MSG_HDR_FIELD_SET(mbx->head, HEAD);
+}
+
+/**
+ *  fm10k_mbx_validate_msg_hdr - Validate common fields in the message header
+ *  @mbx: pointer to mailbox
+ *  @msg: message array to read
+ *
+ *  This function will parse up the fields in the mailbox header and return
+ *  an error if the header contains any of a number of invalid configurations
+ *  including unrecognized type, invalid route, or a malformed message.
+ **/
+static s32 fm10k_mbx_validate_msg_hdr(struct fm10k_mbx_info *mbx)
+{
+	u16 type, rsvd0, head, tail, size;
+	const u32 *hdr = &mbx->mbx_hdr;
+
+	type = FM10K_MSG_HDR_FIELD_GET(*hdr, TYPE);
+	rsvd0 = FM10K_MSG_HDR_FIELD_GET(*hdr, RSVD0);
+	tail = FM10K_MSG_HDR_FIELD_GET(*hdr, TAIL);
+	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
+	size = FM10K_MSG_HDR_FIELD_GET(*hdr, CONNECT_SIZE);
+
+	if (rsvd0)
+		return FM10K_MBX_ERR_RSVD0;
+
+	switch (type) {
+	case FM10K_MSG_DISCONNECT:
+		/* validate that all data has been received */
+		if (tail != mbx->head)
+			return FM10K_MBX_ERR_TAIL;
+
+		/* fall through */
+	case FM10K_MSG_DATA:
+		/* validate that head is moving correctly */
+		if (!head || (head == FM10K_MSG_HDR_MASK(HEAD)))
+			return FM10K_MBX_ERR_HEAD;
+		if (fm10k_mbx_index_len(mbx, head, mbx->tail) > mbx->tail_len)
+			return FM10K_MBX_ERR_HEAD;
+
+		/* validate that tail is moving correctly */
+		if (!tail || (tail == FM10K_MSG_HDR_MASK(TAIL)))
+			return FM10K_MBX_ERR_TAIL;
+		if (fm10k_mbx_index_len(mbx, mbx->head, tail) < mbx->mbmem_len)
+			break;
+
+		return FM10K_MBX_ERR_TAIL;
+	case FM10K_MSG_CONNECT:
+		/* validate size is in range and is power of 2 mask */
+		if ((size < FM10K_VFMBX_MSG_MTU) || (size & (size + 1)))
+			return FM10K_MBX_ERR_SIZE;
+
+		/* fall through */
+	case FM10K_MSG_ERROR:
+		if (!head || (head == FM10K_MSG_HDR_MASK(HEAD)))
+			return FM10K_MBX_ERR_HEAD;
+		/* neither create nor error include a tail offset */
+		if (tail)
+			return FM10K_MBX_ERR_TAIL;
+
+		break;
+	default:
+		return FM10K_MBX_ERR_TYPE;
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_mbx_create_reply - Generate reply based on state and remote head
+ *  @mbx: pointer to mailbox
+ *  @head: acknowledgement number
+ *
+ *  This function will generate an outgoing message based on the current
+ *  mailbox state and the remote fifo head.  It will return the length
+ *  of the outgoing message excluding header on success, and a negative value
+ *  on error.
+ **/
+static s32 fm10k_mbx_create_reply(struct fm10k_hw *hw,
+				  struct fm10k_mbx_info *mbx, u16 head)
+{
+	switch (mbx->state) {
+	case FM10K_STATE_OPEN:
+	case FM10K_STATE_DISCONNECT:
+		/* update our checksum for the outgoing data */
+		fm10k_mbx_update_local_crc(mbx, head);
+
+		/* as long as other end recognizes us keep sending data */
+		fm10k_mbx_pull_head(hw, mbx, head);
+
+		/* generate new header based on data */
+		if (mbx->tail_len || (mbx->state == FM10K_STATE_OPEN))
+			fm10k_mbx_create_data_hdr(mbx);
+		else
+			fm10k_mbx_create_disconnect_hdr(mbx);
+		break;
+	case FM10K_STATE_CONNECT:
+		/* send disconnect even if we aren't connected */
+		fm10k_mbx_create_connect_hdr(mbx);
+		break;
+	case FM10K_STATE_CLOSED:
+		/* generate new header based on data */
+		fm10k_mbx_create_disconnect_hdr(mbx);
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+/**
  *  fm10k_mbx_reset_work- Reset internal pointers for any pending work
  *  @mbx: pointer to mailbox
  *
@@ -731,6 +1071,359 @@ static void fm10k_mbx_update_max_size(struct fm10k_mbx_info *mbx, u16 size)
 }
 
 /**
+ *  fm10k_mbx_connect_reset - Reset following request for reset
+ *  @mbx: pointer to mailbox
+ *
+ *  This function resets the mailbox to either a disconnected state
+ *  or a connect state depending on the current mailbox state
+ **/
+static void fm10k_mbx_connect_reset(struct fm10k_mbx_info *mbx)
+{
+	/* just do a quick resysnc to start of frame */
+	fm10k_mbx_reset_work(mbx);
+
+	/* reset CRC seeds */
+	mbx->local = FM10K_MBX_CRC_SEED;
+	mbx->remote = FM10K_MBX_CRC_SEED;
+
+	/* we cannot exit connect until the size is good */
+	if (mbx->state == FM10K_STATE_OPEN)
+		mbx->state = FM10K_STATE_CONNECT;
+	else
+		mbx->state = FM10K_STATE_CLOSED;
+}
+
+/**
+ *  fm10k_mbx_process_connect - Process connect header
+ *  @mbx: pointer to mailbox
+ *  @msg: message array to process
+ *
+ *  This function will read an incoming connect header and reply with the
+ *  appropriate message.  It will return a value indicating the number of
+ *  data DWORDs on success, or will return a negative value on failure.
+ **/
+static s32 fm10k_mbx_process_connect(struct fm10k_hw *hw,
+				     struct fm10k_mbx_info *mbx)
+{
+	const enum fm10k_mbx_state state = mbx->state;
+	const u32 *hdr = &mbx->mbx_hdr;
+	u16 size, head;
+
+	/* we will need to pull all of the fields for verification */
+	size = FM10K_MSG_HDR_FIELD_GET(*hdr, CONNECT_SIZE);
+	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
+
+	switch (state) {
+	case FM10K_STATE_DISCONNECT:
+	case FM10K_STATE_OPEN:
+		/* reset any in-progress work */
+		fm10k_mbx_connect_reset(mbx);
+		break;
+	case FM10K_STATE_CONNECT:
+		/* we cannot exit connect until the size is good */
+		if (size > mbx->rx.size) {
+			mbx->max_size = mbx->rx.size - 1;
+		} else {
+			/* record the remote system requesting connection */
+			mbx->state = FM10K_STATE_OPEN;
+
+			fm10k_mbx_update_max_size(mbx, size);
+		}
+		break;
+	default:
+		break;
+	}
+
+	/* align our tail index to remote head index */
+	mbx->tail = head;
+
+	return fm10k_mbx_create_reply(hw, mbx, head);
+}
+
+/**
+ *  fm10k_mbx_process_data - Process data header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will read an incoming data header and reply with the
+ *  appropriate message.  It will return a value indicating the number of
+ *  data DWORDs on success, or will return a negative value on failure.
+ **/
+static s32 fm10k_mbx_process_data(struct fm10k_hw *hw,
+				  struct fm10k_mbx_info *mbx)
+{
+	const u32 *hdr = &mbx->mbx_hdr;
+	u16 head, tail;
+	s32 err;
+
+	/* we will need to pull all of the fields for verification */
+	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
+	tail = FM10K_MSG_HDR_FIELD_GET(*hdr, TAIL);
+
+	/* if we are in connect just update our data and go */
+	if (mbx->state == FM10K_STATE_CONNECT) {
+		mbx->tail = head;
+		mbx->state = FM10K_STATE_OPEN;
+	}
+
+	/* abort on message size errors */
+	err = fm10k_mbx_push_tail(hw, mbx, tail);
+	if (err < 0)
+		return err;
+
+	/* verify the checksum on the incoming data */
+	err = fm10k_mbx_verify_remote_crc(mbx);
+	if (err)
+		return err;
+
+	/* process messages if we have received any */
+	fm10k_mbx_dequeue_rx(hw, mbx);
+
+	return fm10k_mbx_create_reply(hw, mbx, head);
+}
+
+/**
+ *  fm10k_mbx_process_disconnect - Process disconnect header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will read an incoming disconnect header and reply with the
+ *  appropriate message.  It will return a value indicating the number of
+ *  data DWORDs on success, or will return a negative value on failure.
+ **/
+static s32 fm10k_mbx_process_disconnect(struct fm10k_hw *hw,
+					struct fm10k_mbx_info *mbx)
+{
+	const enum fm10k_mbx_state state = mbx->state;
+	const u32 *hdr = &mbx->mbx_hdr;
+	u16 head, tail;
+	s32 err;
+
+	/* we will need to pull all of the fields for verification */
+	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
+	tail = FM10K_MSG_HDR_FIELD_GET(*hdr, TAIL);
+
+	/* We should not be receiving disconnect if Rx is incomplete */
+	if (mbx->pushed)
+		return FM10K_MBX_ERR_TAIL;
+
+	/* we have already verified mbx->head == tail so we know this is 0 */
+	mbx->head_len = 0;
+
+	/* verify the checksum on the incoming header is correct */
+	err = fm10k_mbx_verify_remote_crc(mbx);
+	if (err)
+		return err;
+
+	switch (state) {
+	case FM10K_STATE_DISCONNECT:
+	case FM10K_STATE_OPEN:
+		/* state doesn't change if we still have work to do */
+		if (!fm10k_mbx_tx_complete(mbx))
+			break;
+
+		/* verify the head indicates we completed all transmits */
+		if (head != mbx->tail)
+			return FM10K_MBX_ERR_HEAD;
+
+		/* reset any in-progress work */
+		fm10k_mbx_connect_reset(mbx);
+		break;
+	default:
+		break;
+	}
+
+	return fm10k_mbx_create_reply(hw, mbx, head);
+}
+
+/**
+ *  fm10k_mbx_process_error - Process error header
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will read an incoming error header and reply with the
+ *  appropriate message.  It will return a value indicating the number of
+ *  data DWORDs on success, or will return a negative value on failure.
+ **/
+static s32 fm10k_mbx_process_error(struct fm10k_hw *hw,
+				   struct fm10k_mbx_info *mbx)
+{
+	const u32 *hdr = &mbx->mbx_hdr;
+	s32 err_no;
+	u16 head;
+
+	/* we will need to pull all of the fields for verification */
+	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
+
+	/* we only have lower 10 bits of error number os add upper bits */
+	err_no = FM10K_MSG_HDR_FIELD_GET(*hdr, ERR_NO);
+	err_no |= ~FM10K_MSG_HDR_MASK(ERR_NO);
+
+	switch (mbx->state) {
+	case FM10K_STATE_OPEN:
+	case FM10K_STATE_DISCONNECT:
+		/* flush any uncompleted work */
+		fm10k_mbx_reset_work(mbx);
+
+		/* reset CRC seeds */
+		mbx->local = FM10K_MBX_CRC_SEED;
+		mbx->remote = FM10K_MBX_CRC_SEED;
+
+		/* reset tail index and size to prepare for reconnect */
+		mbx->tail = head;
+
+		/* if open then reset max_size and go back to connect */
+		if (mbx->state == FM10K_STATE_OPEN) {
+			mbx->state = FM10K_STATE_CONNECT;
+			break;
+		}
+
+		/* send a connect message to get data flowing again */
+		fm10k_mbx_create_connect_hdr(mbx);
+		return 0;
+	default:
+		break;
+	}
+
+	return fm10k_mbx_create_reply(hw, mbx, mbx->tail);
+}
+
+/**
+ *  fm10k_mbx_process - Process mailbox interrupt
+ *  @hw: pointer to hardware structure
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will process incoming mailbox events and generate mailbox
+ *  replies.  It will return a value indicating the number of DWORDs
+ *  transmitted excluding header on success or a negative value on error.
+ **/
+static s32 fm10k_mbx_process(struct fm10k_hw *hw,
+			     struct fm10k_mbx_info *mbx)
+{
+	s32 err;
+
+	/* we do not read mailbox if closed */
+	if (mbx->state == FM10K_STATE_CLOSED)
+		return 0;
+
+	/* copy data from mailbox */
+	err = fm10k_mbx_read(hw, mbx);
+	if (err)
+		return err;
+
+	/* validate type, source, and destination */
+	err = fm10k_mbx_validate_msg_hdr(mbx);
+	if (err < 0)
+		goto msg_err;
+
+	switch (FM10K_MSG_HDR_FIELD_GET(mbx->mbx_hdr, TYPE)) {
+	case FM10K_MSG_CONNECT:
+		err = fm10k_mbx_process_connect(hw, mbx);
+		break;
+	case FM10K_MSG_DATA:
+		err = fm10k_mbx_process_data(hw, mbx);
+		break;
+	case FM10K_MSG_DISCONNECT:
+		err = fm10k_mbx_process_disconnect(hw, mbx);
+		break;
+	case FM10K_MSG_ERROR:
+		err = fm10k_mbx_process_error(hw, mbx);
+		break;
+	default:
+		err = FM10K_MBX_ERR_TYPE;
+		break;
+	}
+
+msg_err:
+	/* notify partner of errors on our end */
+	if (err < 0)
+		fm10k_mbx_create_error_msg(mbx, err);
+
+	/* copy data from mailbox */
+	fm10k_mbx_write(hw, mbx);
+
+	return err;
+}
+
+/**
+ *  fm10k_mbx_disconnect - Shutdown mailbox connection
+ *  @hw: pointer to hardware structure
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will shut down the mailbox.  It places the mailbox first
+ *  in the disconnect state, it then allows up to a predefined timeout for
+ *  the mailbox to transition to close on its own.  If this does not occur
+ *  then the mailbox will be forced into the closed state.
+ *
+ *  Any mailbox transactions not completed before calling this function
+ *  are not guaranteed to complete and may be dropped.
+ **/
+static void fm10k_mbx_disconnect(struct fm10k_hw *hw,
+				 struct fm10k_mbx_info *mbx)
+{
+	int timeout = mbx->timeout ? FM10K_MBX_DISCONNECT_TIMEOUT : 0;
+
+	/* Place mbx in ready to disconnect state */
+	mbx->state = FM10K_STATE_DISCONNECT;
+
+	/* trigger interrupt to start shutdown process */
+	fm10k_write_reg(hw, mbx->mbx_reg, FM10K_MBX_REQ |
+					  FM10K_MBX_INTERRUPT_DISABLE);
+	do {
+		udelay(FM10K_MBX_POLL_DELAY);
+		mbx->ops.process(hw, mbx);
+		timeout -= FM10K_MBX_POLL_DELAY;
+	} while ((timeout > 0) && (mbx->state != FM10K_STATE_CLOSED));
+
+	/* in case we didn't close just force the mailbox into shutdown */
+	fm10k_mbx_connect_reset(mbx);
+	fm10k_mbx_update_max_size(mbx, 0);
+
+	fm10k_write_reg(hw, mbx->mbmem_reg, 0);
+}
+
+/**
+ *  fm10k_mbx_connect - Start mailbox connection
+ *  @hw: pointer to hardware structure
+ *  @mbx: pointer to mailbox
+ *
+ *  This function will initiate a mailbox connection.  It will populate the
+ *  mailbox with a broadcast connect message and then initialize the lock.
+ *  This is safe since the connect message is a single DWORD so the mailbox
+ *  transaction is guaranteed to be atomic.
+ *
+ *  This function will return an error if the mailbox has not been initiated
+ *  or is currently in use.
+ **/
+static s32 fm10k_mbx_connect(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx)
+{
+	/* we cannot connect an uninitialized mailbox */
+	if (!mbx->rx.buffer)
+		return FM10K_MBX_ERR_NO_SPACE;
+
+	/* we cannot connect an already connected mailbox */
+	if (mbx->state != FM10K_STATE_CLOSED)
+		return FM10K_MBX_ERR_BUSY;
+
+	/* mailbox timeout can now become active */
+	mbx->timeout = FM10K_MBX_INIT_TIMEOUT;
+
+	/* Place mbx in ready to connect state */
+	mbx->state = FM10K_STATE_CONNECT;
+
+	/* initialize header of remote mailbox */
+	fm10k_mbx_create_disconnect_hdr(mbx);
+	fm10k_write_reg(hw, mbx->mbmem_reg ^ mbx->mbmem_len, mbx->mbx_hdr);
+
+	/* enable interrupt and notify other party of new message */
+	mbx->mbx_lock = FM10K_MBX_REQ_INTERRUPT | FM10K_MBX_ACK_INTERRUPT |
+			FM10K_MBX_INTERRUPT_ENABLE;
+
+	/* generate and load connect header into mailbox */
+	fm10k_mbx_create_connect_hdr(mbx);
+	fm10k_mbx_write(hw, mbx);
+
+	return 0;
+}
+
+/**
  *  fm10k_mbx_validate_handlers - Validate layout of message parsing data
  *  @msg_data: handlers for mailbox events
  *
@@ -806,6 +1499,83 @@ static s32 fm10k_mbx_register_handlers(struct fm10k_mbx_info *mbx,
 }
 
 /**
+ *  fm10k_pfvf_mbx_init - Initialize mailbox memory for PF/VF mailbox
+ *  @hw: pointer to hardware structure
+ *  @mbx: pointer to mailbox
+ *  @msg_data: handlers for mailbox events
+ *  @id: ID reference for PF as it supports up to 64 PF/VF mailboxes
+ *
+ *  This function initializes the mailbox for use.  It will split the
+ *  buffer provided an use that th populate both the Tx and Rx FIFO by
+ *  evenly splitting it.  In order to allow for easy masking of head/tail
+ *  the value reported in size must be a power of 2 and is reported in
+ *  DWORDs, not bytes.  Any invalid values will cause the mailbox to return
+ *  error.
+ **/
+s32 fm10k_pfvf_mbx_init(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx,
+			const struct fm10k_msg_data *msg_data, u8 id)
+{
+	/* initialize registers */
+	switch (hw->mac.type) {
+	case fm10k_mac_pf:
+		/* there are only 64 VF <-> PF mailboxes */
+		if (id < 64) {
+			mbx->mbx_reg = FM10K_MBX(id);
+			mbx->mbmem_reg = FM10K_MBMEM_VF(id, 0);
+			break;
+		}
+		/* fallthough */
+	default:
+		return FM10K_MBX_ERR_NO_MBX;
+	}
+
+	/* start out in closed state */
+	mbx->state = FM10K_STATE_CLOSED;
+
+	/* validate layout of handlers before assigning them */
+	if (fm10k_mbx_validate_handlers(msg_data))
+		return FM10K_ERR_PARAM;
+
+	/* initialize the message handlers */
+	mbx->msg_data = msg_data;
+
+	/* start mailbox as timed out and let the reset_hw call
+	 * set the timeout value to begin communications
+	 */
+	mbx->timeout = 0;
+	mbx->udelay = FM10K_MBX_INIT_DELAY;
+
+	/* initalize tail and head */
+	mbx->tail = 1;
+	mbx->head = 1;
+
+	/* initialize CRC seeds */
+	mbx->local = FM10K_MBX_CRC_SEED;
+	mbx->remote = FM10K_MBX_CRC_SEED;
+
+	/* Split buffer for use by Tx/Rx FIFOs */
+	mbx->max_size = FM10K_MBX_MSG_MAX_SIZE;
+	mbx->mbmem_len = FM10K_VFMBMEM_VF_XOR;
+
+	/* initialize the FIFOs, sizes are in 4 byte increments */
+	fm10k_fifo_init(&mbx->tx, mbx->buffer, FM10K_MBX_TX_BUFFER_SIZE);
+	fm10k_fifo_init(&mbx->rx, &mbx->buffer[FM10K_MBX_TX_BUFFER_SIZE],
+			FM10K_MBX_RX_BUFFER_SIZE);
+
+	/* initialize function pointers */
+	mbx->ops.connect = fm10k_mbx_connect;
+	mbx->ops.disconnect = fm10k_mbx_disconnect;
+	mbx->ops.rx_ready = fm10k_mbx_rx_ready;
+	mbx->ops.tx_ready = fm10k_mbx_tx_ready;
+	mbx->ops.tx_complete = fm10k_mbx_tx_complete;
+	mbx->ops.enqueue_tx = fm10k_mbx_enqueue_tx;
+	mbx->ops.process = fm10k_mbx_process;
+	mbx->ops.register_handlers = fm10k_mbx_register_handlers;
+
+	return 0;
+}
+
+/**
  *  fm10k_sm_mbx_create_data_hdr - Generate a mailbox header for local FIFO
  *  @mbx: pointer to mailbox
  *
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
index f5ba86f..0419a7f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
@@ -99,6 +99,39 @@ enum fm10k_mbx_state {
 	FM10K_STATE_DISCONNECT,
 };
 
+/* PF/VF Mailbox header format
+ *    3			  2		      1			  0
+ *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |        Size/Err_no/CRC        | Rsvd0 | Head  | Tail  | Type  |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * The layout above describes the format for the header used in the PF/VF
+ * mailbox.  The header is broken out into the following fields:
+ * Type: There are 4 supported message types
+ *		0x8: Data header - used to transport message data
+ *		0xC: Connect header - used to establish connection
+ *		0xD: Disconnect header - used to tear down a connection
+ *		0xE: Error header - used to address message exceptions
+ * Tail: Tail index for local FIFO
+ *		Tail index actually consists of two parts.  The MSB of
+ *		the head is a loop tracker, it is 0 on an even numbered
+ *		loop through the FIFO, and 1 on the odd numbered loops.
+ *		To get the actual mailbox offset based on the tail it
+ *		is necessary to add bit 3 to bit 0 and clear bit 3.  This
+ *		gives us a valid range of 0x1 - 0xE.
+ * Head: Head index for remote FIFO
+ *		Head index follows the same format as the tail index.
+ * Rsvd0: Reserved 0 portion of the mailbox header
+ * CRC: Running CRC for all data since connect plus current message header
+ * Size: Maximum message size - Applies only to connect headers
+ *		The maximum message size is provided during connect to avoid
+ *		jamming the mailbox with messages that do not fit.
+ * Err_no: Error number - Applies only to error headers
+ *		The error number provides a indication of the type of error
+ *		experienced.
+ */
+
 /* macros for retriving and setting header values */
 #define FM10K_MSG_HDR_MASK(name) \
 	((0x1u << FM10K_MSG_##name##_SIZE) - 1)
@@ -107,6 +140,35 @@ enum fm10k_mbx_state {
 #define FM10K_MSG_HDR_FIELD_GET(value, name) \
 	((u16)((value) >> FM10K_MSG_##name##_SHIFT) & FM10K_MSG_HDR_MASK(name))
 
+/* offsets shared between all headers */
+#define FM10K_MSG_TYPE_SHIFT			0
+#define FM10K_MSG_TYPE_SIZE			4
+#define FM10K_MSG_TAIL_SHIFT			4
+#define FM10K_MSG_TAIL_SIZE			4
+#define FM10K_MSG_HEAD_SHIFT			8
+#define FM10K_MSG_HEAD_SIZE			4
+#define FM10K_MSG_RSVD0_SHIFT			12
+#define FM10K_MSG_RSVD0_SIZE			4
+
+/* offsets for data/disconnect headers */
+#define FM10K_MSG_CRC_SHIFT			16
+#define FM10K_MSG_CRC_SIZE			16
+
+/* offsets for connect headers */
+#define FM10K_MSG_CONNECT_SIZE_SHIFT		16
+#define FM10K_MSG_CONNECT_SIZE_SIZE		16
+
+/* offsets for error headers */
+#define FM10K_MSG_ERR_NO_SHIFT			16
+#define FM10K_MSG_ERR_NO_SIZE			16
+
+enum fm10k_msg_type {
+	FM10K_MSG_DATA			= 0x8,
+	FM10K_MSG_CONNECT		= 0xC,
+	FM10K_MSG_DISCONNECT		= 0xD,
+	FM10K_MSG_ERROR			= 0xE,
+};
+
 /* HNI/SM Mailbox FIFO format
  *    3                   2                   1                   0
  *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
@@ -237,6 +299,8 @@ struct fm10k_mbx_info {
 	u32 buffer[FM10K_MBX_BUFFER_SIZE];
 };
 
+s32 fm10k_pfvf_mbx_init(struct fm10k_hw *, struct fm10k_mbx_info *,
+			const struct fm10k_msg_data *, u8);
 s32 fm10k_sm_mbx_init(struct fm10k_hw *, struct fm10k_mbx_info *,
 		      const struct fm10k_msg_data *);
 
