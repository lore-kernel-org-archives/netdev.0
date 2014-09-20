From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 03/29] fm10k: Add support for TLV message
 parsing and generation
Date: Sat, 20 Sep 2014 19:46:30 -0400
Message-ID: <20140920234625.2977.93874.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50598 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbaITXzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:55:14 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the TVL message formats supported by the PF,
VF, and Switch Management entity.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile    |    3 
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c |  543 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h |  141 +++++++
 3 files changed, 686 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index ddc0eb7..1052808 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -27,4 +27,5 @@
 
 obj-$(CONFIG_FM10K) += fm10k.o
 
-fm10k-objs := fm10k_main.o fm10k_pci.o
+fm10k-objs := fm10k_main.o fm10k_pci.o \
+	      fm10k_tlv.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
new file mode 100644
index 0000000..f1fc709
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -0,0 +1,543 @@
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
+#include "fm10k_tlv.h"
+
+/**
+ *  fm10k_tlv_msg_init - Initialize message block for TLV data storage
+ *  @msg: Pointer to message block
+ *  @msg_id: Message ID indicating message type
+ *
+ *  This function return success if provided with a valid message pointer
+ **/
+s32 fm10k_tlv_msg_init(u32 *msg, u16 msg_id)
+{
+	/* verify pointer is not NULL */
+	if (!msg)
+		return FM10K_ERR_PARAM;
+
+	*msg = (FM10K_TLV_FLAGS_MSG << FM10K_TLV_FLAGS_SHIFT) | msg_id;
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_put_null_string - Place null terminated string on message
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *  @string: Pointer to string to be stored in attribute
+ *
+ *  This function will reorder a string to be CPU endian and store it in
+ *  the attribute buffer.  It will return success if provided with a valid
+ *  pointers.
+ **/
+s32 fm10k_tlv_attr_put_null_string(u32 *msg, u16 attr_id,
+				   const unsigned char *string)
+{
+	u32 attr_data = 0, len = 0;
+	u32 *attr;
+
+	/* verify pointers are not NULL */
+	if (!string || !msg)
+		return FM10K_ERR_PARAM;
+
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+
+	/* copy string into local variable and then write to msg */
+	do {
+		/* write data to message */
+		if (len && !(len % 4)) {
+			attr[len / 4] = attr_data;
+			attr_data = 0;
+		}
+
+		/* record character to offset location */
+		attr_data |= (u32)(*string) << (8 * (len % 4));
+		len++;
+
+		/* test for NULL and then increment */
+	} while (*(string++));
+
+	/* write last piece of data to message */
+	attr[(len + 3) / 4] = attr_data;
+
+	/* record attribute header, update message length */
+	len <<= FM10K_TLV_LEN_SHIFT;
+	attr[0] = len | attr_id;
+
+	/* add header length to length */
+	len += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+	*msg += FM10K_TLV_LEN_ALIGN(len);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_get_null_string - Get null terminated string from attribute
+ *  @attr: Pointer to attribute
+ *  @string: Pointer to location of destination string
+ *
+ *  This function pulls the string back out of the attribute and will place
+ *  it in the array pointed by by string.  It will return success if provided
+ *  with a valid pointers.
+ **/
+s32 fm10k_tlv_attr_get_null_string(u32 *attr, unsigned char *string)
+{
+	u32 len;
+
+	/* verify pointers are not NULL */
+	if (!string || !attr)
+		return FM10K_ERR_PARAM;
+
+	len = *attr >> FM10K_TLV_LEN_SHIFT;
+	attr++;
+
+	while (len--)
+		string[len] = (u8)(attr[len / 4] >> (8 * (len % 4)));
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_put_mac_vlan - Store MAC/VLAN attribute in message
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *  @mac_addr: MAC address to be stored
+ *
+ *  This function will reorder a MAC address to be CPU endian and store it
+ *  in the attribute buffer.  It will return success if provided with a
+ *  valid pointers.
+ **/
+s32 fm10k_tlv_attr_put_mac_vlan(u32 *msg, u16 attr_id,
+				const u8 *mac_addr, u16 vlan)
+{
+	u32 len = ETH_ALEN << FM10K_TLV_LEN_SHIFT;
+	u32 *attr;
+
+	/* verify pointers are not NULL */
+	if (!msg || !mac_addr)
+		return FM10K_ERR_PARAM;
+
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+
+	/* record attribute header, update message length */
+	attr[0] = len | attr_id;
+
+	/* copy value into local variable and then write to msg */
+	attr[1] = le32_to_cpu(*(const __le32 *)&mac_addr[0]);
+	attr[2] = le16_to_cpu(*(const __le16 *)&mac_addr[4]);
+	attr[2] |= (u32)vlan << 16;
+
+	/* add header length to length */
+	len += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+	*msg += FM10K_TLV_LEN_ALIGN(len);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_get_mac_vlan - Get MAC/VLAN stored in attribute
+ *  @attr: Pointer to attribute
+ *  @attr_id: Attribute ID
+ *  @mac_addr: location of buffer to store MAC address
+ *
+ *  This function pulls the MAC address back out of the attribute and will
+ *  place it in the array pointed by by mac_addr.  It will return success
+ *  if provided with a valid pointers.
+ **/
+s32 fm10k_tlv_attr_get_mac_vlan(u32 *attr, u8 *mac_addr, u16 *vlan)
+{
+	/* verify pointers are not NULL */
+	if (!mac_addr || !attr)
+		return FM10K_ERR_PARAM;
+
+	*(__le32 *)&mac_addr[0] = cpu_to_le32(attr[1]);
+	*(__le16 *)&mac_addr[4] = cpu_to_le16((u16)(attr[2]));
+	*vlan = (u16)(attr[2] >> 16);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_put_bool - Add header indicating value "true"
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *
+ *  This function will simply add an attribute header, the fact
+ *  that the header is here means the attribute value is true, else
+ *  it is false.  The function will return success if provided with a
+ *  valid pointers.
+ **/
+s32 fm10k_tlv_attr_put_bool(u32 *msg, u16 attr_id)
+{
+	/* verify pointers are not NULL */
+	if (!msg)
+		return FM10K_ERR_PARAM;
+
+	/* record attribute header */
+	msg[FM10K_TLV_DWORD_LEN(*msg)] = attr_id;
+
+	/* add header length to length */
+	*msg += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_put_value - Store integer value attribute in message
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *  @value: Value to be written
+ *  @len: Size of value
+ *
+ *  This function will place an integer value of up to 8 bytes in size
+ *  in a message attribute.  The function will return success provided
+ *  that msg is a valid pointer, and len is 1, 2, 4, or 8.
+ **/
+s32 fm10k_tlv_attr_put_value(u32 *msg, u16 attr_id, s64 value, u32 len)
+{
+	u32 *attr;
+
+	/* verify non-null msg and len is 1, 2, 4, or 8 */
+	if (!msg || !len || len > 8 || (len & (len - 1)))
+		return FM10K_ERR_PARAM;
+
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+
+	if (len < 4) {
+		attr[1] = (u32)value & ((0x1ul << (8 * len)) - 1);
+	} else {
+		attr[1] = (u32)value;
+		if (len > 4)
+			attr[2] = (u32)(value >> 32);
+	}
+
+	/* record attribute header, update message length */
+	len <<= FM10K_TLV_LEN_SHIFT;
+	attr[0] = len | attr_id;
+
+	/* add header length to length */
+	len += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+	*msg += FM10K_TLV_LEN_ALIGN(len);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_get_value - Get integer value stored in attribute
+ *  @attr: Pointer to attribute
+ *  @value: Pointer to destination buffer
+ *  @len: Size of value
+ *
+ *  This function will place an integer value of up to 8 bytes in size
+ *  in the offset pointed to by value.  The function will return success
+ *  provided that pointers are valid and the len value matches the
+ *  attribute length.
+ **/
+s32 fm10k_tlv_attr_get_value(u32 *attr, void *value, u32 len)
+{
+	/* verify pointers are not NULL */
+	if (!attr || !value)
+		return FM10K_ERR_PARAM;
+
+	if ((*attr >> FM10K_TLV_LEN_SHIFT) != len)
+		return FM10K_ERR_PARAM;
+
+	if (len == 8)
+		*(u64 *)value = ((u64)attr[2] << 32) | attr[1];
+	else if (len == 4)
+		*(u32 *)value = attr[1];
+	else if (len == 2)
+		*(u16 *)value = (u16)attr[1];
+	else
+		*(u8 *)value = (u8)attr[1];
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_put_le_struct - Store little endian structure in message
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *  @le_struct: Pointer to structure to be written
+ *  @len: Size of le_struct
+ *
+ *  This function will place a little endian structure value in a message
+ *  attribute.  The function will return success provided that all pointers
+ *  are valid and length is a non-zero multiple of 4.
+ **/
+s32 fm10k_tlv_attr_put_le_struct(u32 *msg, u16 attr_id,
+				 const void *le_struct, u32 len)
+{
+	const __le32 *le32_ptr = (const __le32 *)le_struct;
+	u32 *attr;
+	u32 i;
+
+	/* verify non-null msg and len is in 32 bit words */
+	if (!msg || !len || (len % 4))
+		return FM10K_ERR_PARAM;
+
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+
+	/* copy le32 structure into host byte order at 32b boundaries */
+	for (i = 0; i < (len / 4); i++)
+		attr[i + 1] = le32_to_cpu(le32_ptr[i]);
+
+	/* record attribute header, update message length */
+	len <<= FM10K_TLV_LEN_SHIFT;
+	attr[0] = len | attr_id;
+
+	/* add header length to length */
+	len += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+	*msg += FM10K_TLV_LEN_ALIGN(len);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_get_le_struct - Get little endian struct form attribute
+ *  @attr: Pointer to attribute
+ *  @le_struct: Pointer to structure to be written
+ *  @len: Size of structure
+ *
+ *  This function will place a little endian structure in the buffer
+ *  pointed to by le_struct.  The function will return success
+ *  provided that pointers are valid and the len value matches the
+ *  attribute length.
+ **/
+s32 fm10k_tlv_attr_get_le_struct(u32 *attr, void *le_struct, u32 len)
+{
+	__le32 *le32_ptr = (__le32 *)le_struct;
+	u32 i;
+
+	/* verify pointers are not NULL */
+	if (!le_struct || !attr)
+		return FM10K_ERR_PARAM;
+
+	if ((*attr >> FM10K_TLV_LEN_SHIFT) != len)
+		return FM10K_ERR_PARAM;
+
+	attr++;
+
+	for (i = 0; len; i++, len -= 4)
+		le32_ptr[i] = cpu_to_le32(attr[i]);
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_nest_start - Start a set of nested attributes
+ *  @msg: Pointer to message block
+ *  @attr_id: Attribute ID
+ *
+ *  This function will mark off a new nested region for encapsulating
+ *  a given set of attributes.  The idea is if you wish to place a secondary
+ *  structure within the message this mechanism allows for that.  The
+ *  function will return NULL on failure, and a pointer to the start
+ *  of the nested attributes on success.
+ **/
+u32 *fm10k_tlv_attr_nest_start(u32 *msg, u16 attr_id)
+{
+	u32 *attr;
+
+	/* verify pointer is not NULL */
+	if (!msg)
+		return NULL;
+
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+
+	attr[0] = attr_id;
+
+	/* return pointer to nest header */
+	return attr;
+}
+
+/**
+ *  fm10k_tlv_attr_nest_start - Start a set of nested attributes
+ *  @msg: Pointer to message block
+ *
+ *  This function closes off an existing set of nested attributes.  The
+ *  message pointer should be pointing to the parent of the nest.  So in
+ *  the case of a nest within the nest this would be the outer nest pointer.
+ *  This function will return success provided all pointers are valid.
+ **/
+s32 fm10k_tlv_attr_nest_stop(u32 *msg)
+{
+	u32 *attr;
+	u32 len;
+
+	/* verify pointer is not NULL */
+	if (!msg)
+		return FM10K_ERR_PARAM;
+
+	/* locate the nested header and retrieve its length */
+	attr = &msg[FM10K_TLV_DWORD_LEN(*msg)];
+	len = (attr[0] >> FM10K_TLV_LEN_SHIFT) << FM10K_TLV_LEN_SHIFT;
+
+	/* only include nest if data was added to it */
+	if (len) {
+		len += FM10K_TLV_HDR_LEN << FM10K_TLV_LEN_SHIFT;
+		*msg += len;
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_validate - Validate attribute metadata
+ *  @attr: Pointer to attribute
+ *  @tlv_attr: Type and length info for attribute
+ *
+ *  This function does some basic validation of the input TLV.  It
+ *  verifies the length, and in the case of null terminated strings
+ *  it verifies that the last byte is null.  The function will
+ *  return FM10K_ERR_PARAM if any attribute is malformed, otherwise
+ *  it returns 0.
+ **/
+static s32 fm10k_tlv_attr_validate(u32 *attr,
+				   const struct fm10k_tlv_attr *tlv_attr)
+{
+	u32 attr_id = *attr & FM10K_TLV_ID_MASK;
+	u16 len = *attr >> FM10K_TLV_LEN_SHIFT;
+
+	/* verify this is an attribute and not a message */
+	if (*attr & (FM10K_TLV_FLAGS_MSG << FM10K_TLV_FLAGS_SHIFT))
+		return FM10K_ERR_PARAM;
+
+	/* search through the list of attributes to find a matching ID */
+	while (tlv_attr->id < attr_id)
+		tlv_attr++;
+
+	/* if didn't find a match then we should exit */
+	if (tlv_attr->id != attr_id)
+		return FM10K_NOT_IMPLEMENTED;
+
+	/* move to start of attribute data */
+	attr++;
+
+	switch (tlv_attr->type) {
+	case FM10K_TLV_NULL_STRING:
+		if (!len ||
+		    (attr[(len - 1) / 4] & (0xFF << (8 * ((len - 1) % 4)))))
+			return FM10K_ERR_PARAM;
+		if (len > tlv_attr->len)
+			return FM10K_ERR_PARAM;
+		break;
+	case FM10K_TLV_MAC_ADDR:
+		if (len != ETH_ALEN)
+			return FM10K_ERR_PARAM;
+		break;
+	case FM10K_TLV_BOOL:
+		if (len)
+			return FM10K_ERR_PARAM;
+		break;
+	case FM10K_TLV_UNSIGNED:
+	case FM10K_TLV_SIGNED:
+		if (len != tlv_attr->len)
+			return FM10K_ERR_PARAM;
+		break;
+	case FM10K_TLV_LE_STRUCT:
+		/* struct must be 4 byte aligned */
+		if ((len % 4) || len != tlv_attr->len)
+			return FM10K_ERR_PARAM;
+		break;
+	case FM10K_TLV_NESTED:
+		/* nested attributes must be 4 byte aligned */
+		if (len % 4)
+			return FM10K_ERR_PARAM;
+		break;
+	default:
+		/* attribute id is mapped to bad value */
+		return FM10K_ERR_PARAM;
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_tlv_attr_parse - Parses stream of attribute data
+ *  @attr: Pointer to attribute list
+ *  @results: Pointer array to store pointers to attributes
+ *  @tlv_attr: Type and length info for attributes
+ *
+ *  This function validates a stream of attributes and parses them
+ *  up into an array of pointers stored in results.  The function will
+ *  return FM10K_ERR_PARAM on any input or message error,
+ *  FM10K_NOT_IMPLEMENTED for any attribute that is outside of the array
+ *  and 0 on success.
+ **/
+s32 fm10k_tlv_attr_parse(u32 *attr, u32 **results,
+			 const struct fm10k_tlv_attr *tlv_attr)
+{
+	u32 i, attr_id, offset = 0;
+	s32 err = 0;
+	u16 len;
+
+	/* verify pointers are not NULL */
+	if (!attr || !results)
+		return FM10K_ERR_PARAM;
+
+	/* initialize results to NULL */
+	for (i = 0; i < FM10K_TLV_RESULTS_MAX; i++)
+		results[i] = NULL;
+
+	/* pull length from the message header */
+	len = *attr >> FM10K_TLV_LEN_SHIFT;
+
+	/* no attributes to parse if there is no length */
+	if (!len)
+		return 0;
+
+	/* no attributes to parse, just raw data, message becomes attribute */
+	if (!tlv_attr) {
+		results[0] = attr;
+		return 0;
+	}
+
+	/* move to start of attribute data */
+	attr++;
+
+	/* run through list parsing all attributes */
+	while (offset < len) {
+		attr_id = *attr & FM10K_TLV_ID_MASK;
+
+		if (attr_id < FM10K_TLV_RESULTS_MAX)
+			err = fm10k_tlv_attr_validate(attr, tlv_attr);
+		else
+			err = FM10K_NOT_IMPLEMENTED;
+
+		if (err < 0)
+			return err;
+		if (!err)
+			results[attr_id] = attr;
+
+		/* update offset */
+		offset += FM10K_TLV_DWORD_LEN(*attr) * 4;
+
+		/* move to next attribute */
+		attr = &attr[FM10K_TLV_DWORD_LEN(*attr)];
+	}
+
+	/* we should find ourselves at the end of the list */
+	if (offset != len)
+		return FM10K_ERR_PARAM;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
new file mode 100644
index 0000000..6d22db6
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
@@ -0,0 +1,141 @@
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
+#ifndef _FM10K_TLV_H_
+#define _FM10K_TLV_H_
+
+#include "fm10k_type.h"
+
+/* Message / Argument header format
+ *    3			  2		      1			  0
+ *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |	     Length	   | Flags |	      Type / ID		   |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * The message header format described here is used for messages that are
+ * passed between the PF and the VF.  To allow for messages larger then
+ * mailbox size we will provide a message with the above header and it
+ * will be segmented and transported to the mailbox to the other side where
+ * it is reassembled.  It contains the following fields:
+ * Len: Length of the message in bytes excluding the message header
+ * Flags: TBD
+ * Rule: These will be the message/argument types we pass
+ */
+/* message data header */
+#define FM10K_TLV_ID_SHIFT		0
+#define FM10K_TLV_ID_SIZE		16
+#define FM10K_TLV_ID_MASK		((1u << FM10K_TLV_ID_SIZE) - 1)
+#define FM10K_TLV_FLAGS_SHIFT		16
+#define FM10K_TLV_FLAGS_MSG		0x1
+#define FM10K_TLV_FLAGS_SIZE		4
+#define FM10K_TLV_LEN_SHIFT		20
+#define FM10K_TLV_LEN_SIZE		12
+
+#define FM10K_TLV_HDR_LEN		4ul
+#define FM10K_TLV_LEN_ALIGN_MASK \
+	((FM10K_TLV_HDR_LEN - 1) << FM10K_TLV_LEN_SHIFT)
+#define FM10K_TLV_LEN_ALIGN(tlv) \
+	(((tlv) + FM10K_TLV_LEN_ALIGN_MASK) & ~FM10K_TLV_LEN_ALIGN_MASK)
+#define FM10K_TLV_DWORD_LEN(tlv) \
+	((u16)((FM10K_TLV_LEN_ALIGN(tlv)) >> (FM10K_TLV_LEN_SHIFT + 2)) + 1)
+
+#define FM10K_TLV_RESULTS_MAX		32
+
+enum fm10k_tlv_type {
+	FM10K_TLV_NULL_STRING,
+	FM10K_TLV_MAC_ADDR,
+	FM10K_TLV_BOOL,
+	FM10K_TLV_UNSIGNED,
+	FM10K_TLV_SIGNED,
+	FM10K_TLV_LE_STRUCT,
+	FM10K_TLV_NESTED,
+	FM10K_TLV_MAX_TYPE
+};
+
+#define FM10K_TLV_ERROR (~0u)
+
+struct fm10k_tlv_attr {
+	unsigned int		id;
+	enum fm10k_tlv_type	type;
+	u16			len;
+};
+
+#define FM10K_TLV_ATTR_NULL_STRING(id, len) { id, FM10K_TLV_NULL_STRING, len }
+#define FM10K_TLV_ATTR_MAC_ADDR(id)	    { id, FM10K_TLV_MAC_ADDR, 6 }
+#define FM10K_TLV_ATTR_BOOL(id)		    { id, FM10K_TLV_BOOL, 0 }
+#define FM10K_TLV_ATTR_U8(id)		    { id, FM10K_TLV_UNSIGNED, 1 }
+#define FM10K_TLV_ATTR_U16(id)		    { id, FM10K_TLV_UNSIGNED, 2 }
+#define FM10K_TLV_ATTR_U32(id)		    { id, FM10K_TLV_UNSIGNED, 4 }
+#define FM10K_TLV_ATTR_U64(id)		    { id, FM10K_TLV_UNSIGNED, 8 }
+#define FM10K_TLV_ATTR_S8(id)		    { id, FM10K_TLV_SIGNED, 1 }
+#define FM10K_TLV_ATTR_S16(id)		    { id, FM10K_TLV_SIGNED, 2 }
+#define FM10K_TLV_ATTR_S32(id)		    { id, FM10K_TLV_SIGNED, 4 }
+#define FM10K_TLV_ATTR_S64(id)		    { id, FM10K_TLV_SIGNED, 8 }
+#define FM10K_TLV_ATTR_LE_STRUCT(id, len)   { id, FM10K_TLV_LE_STRUCT, len }
+#define FM10K_TLV_ATTR_NESTED(id)	    { id, FM10K_TLV_NESTED }
+#define FM10K_TLV_ATTR_LAST		    { FM10K_TLV_ERROR }
+
+s32 fm10k_tlv_msg_init(u32 *, u16);
+s32 fm10k_tlv_attr_put_null_string(u32 *, u16, const unsigned char *);
+s32 fm10k_tlv_attr_get_null_string(u32 *, unsigned char *);
+s32 fm10k_tlv_attr_put_mac_vlan(u32 *, u16, const u8 *, u16);
+s32 fm10k_tlv_attr_get_mac_vlan(u32 *, u8 *, u16 *);
+s32 fm10k_tlv_attr_put_bool(u32 *, u16);
+s32 fm10k_tlv_attr_put_value(u32 *, u16, s64, u32);
+#define fm10k_tlv_attr_put_u8(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 1)
+#define fm10k_tlv_attr_put_u16(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 2)
+#define fm10k_tlv_attr_put_u32(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 4)
+#define fm10k_tlv_attr_put_u64(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 8)
+#define fm10k_tlv_attr_put_s8(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 1)
+#define fm10k_tlv_attr_put_s16(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 2)
+#define fm10k_tlv_attr_put_s32(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 4)
+#define fm10k_tlv_attr_put_s64(msg, attr_id, val) \
+		fm10k_tlv_attr_put_value(msg, attr_id, val, 8)
+s32 fm10k_tlv_attr_get_value(u32 *, void *, u32);
+#define fm10k_tlv_attr_get_u8(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(u8))
+#define fm10k_tlv_attr_get_u16(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(u16))
+#define fm10k_tlv_attr_get_u32(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(u32))
+#define fm10k_tlv_attr_get_u64(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(u64))
+#define fm10k_tlv_attr_get_s8(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(s8))
+#define fm10k_tlv_attr_get_s16(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(s16))
+#define fm10k_tlv_attr_get_s32(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(s32))
+#define fm10k_tlv_attr_get_s64(attr, ptr) \
+		fm10k_tlv_attr_get_value(attr, ptr, sizeof(s64))
+s32 fm10k_tlv_attr_put_le_struct(u32 *, u16, const void *, u32);
+s32 fm10k_tlv_attr_get_le_struct(u32 *, void *, u32);
+u32 *fm10k_tlv_attr_nest_start(u32 *, u16);
+s32 fm10k_tlv_attr_nest_stop(u32 *);
+s32 fm10k_tlv_attr_parse(u32 *, u32 **, const struct fm10k_tlv_attr *);
+#endif /* _FM10K_MSG_H_ */
