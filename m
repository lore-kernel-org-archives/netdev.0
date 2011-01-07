From: jeffrey.t.kirsher@intel.com
Subject: [net-next 10/12] ixgbe: cleanup flow director hash computation to improve performance
Date: Thu,  6 Jan 2011 16:29:57 -0800
Message-ID: <1294360199-9860-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63414 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112Ab1AGAaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:52 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change cleans up the layout of the flow director data, and the
algorithm used to calculate the hash resulting in a 35x / 3500% performance
increase versus the old flow director hash computation.  The overall effect
is only a 1% increase in transactions per second though due to the fact
that only 1 packet in 20 are actually hashed upon.

TCP_RR before:
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       60.00    23059.27
16384  87380

TCP_RR after:
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       60.00    23239.98
16384  87380

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |   18 +-
 drivers/net/ixgbe/ixgbe_82599.c   |  335 ++++++++++++++-----------------------
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 +-
 drivers/net/ixgbe/ixgbe_main.c    |   11 +-
 drivers/net/ixgbe/ixgbe_type.h    |   67 +++++---
 5 files changed, 182 insertions(+), 253 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index bdeaa9e..2666e69 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -526,25 +526,25 @@ extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
 extern s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
-                                                 struct ixgbe_atr_input *input,
+                                                 union ixgbe_atr_input *input,
                                                  u8 queue);
 extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
-                                      struct ixgbe_atr_input *input,
+                                      union ixgbe_atr_input *input,
                                       struct ixgbe_atr_input_masks *input_masks,
                                       u16 soft_id, u8 queue);
-extern s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_vlan_id_82599(union ixgbe_atr_input *input,
                                        u16 vlan_id);
-extern s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_src_ipv4_82599(union ixgbe_atr_input *input,
                                         u32 src_addr);
-extern s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_dst_ipv4_82599(union ixgbe_atr_input *input,
                                         u32 dst_addr);
-extern s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_src_port_82599(union ixgbe_atr_input *input,
                                         u16 src_port);
-extern s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_dst_port_82599(union ixgbe_atr_input *input,
                                         u16 dst_port);
-extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_flex_byte_82599(union ixgbe_atr_input *input,
                                          u16 flex_byte);
-extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
+extern s32 ixgbe_atr_set_l4type_82599(union ixgbe_atr_input *input,
                                       u8 l4type);
 extern void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
                                    struct ixgbe_ring *ring);
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index bfd3c22..40aa3c2 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1003,7 +1003,7 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 		udelay(10);
 	}
 	if (i >= IXGBE_FDIRCMD_CMD_POLL) {
-		hw_dbg(hw ,"Flow Director previous command isn't complete, "
+		hw_dbg(hw, "Flow Director previous command isn't complete, "
 		       "aborting table re-initialization.\n");
 		return IXGBE_ERR_FDIR_REINIT_FAILED;
 	}
@@ -1113,13 +1113,10 @@ s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc)
 	/* Move the flexible bytes to use the ethertype - shift 6 words */
 	fdirctrl |= (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT);
 
-	fdirctrl |= IXGBE_FDIRCTRL_REPORT_STATUS;
 
 	/* Prime the keys for hashing */
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY,
-	                htonl(IXGBE_ATR_BUCKET_HASH_KEY));
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY,
-	                htonl(IXGBE_ATR_SIGNATURE_HASH_KEY));
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY, IXGBE_ATR_BUCKET_HASH_KEY);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY, IXGBE_ATR_SIGNATURE_HASH_KEY);
 
 	/*
 	 * Poll init-done after we write the register.  Estimated times:
@@ -1209,10 +1206,8 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
 	fdirctrl |= (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT);
 
 	/* Prime the keys for hashing */
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY,
-	                htonl(IXGBE_ATR_BUCKET_HASH_KEY));
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY,
-	                htonl(IXGBE_ATR_SIGNATURE_HASH_KEY));
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY, IXGBE_ATR_BUCKET_HASH_KEY);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY, IXGBE_ATR_SIGNATURE_HASH_KEY);
 
 	/*
 	 * Poll init-done after we write the register.  Estimated times:
@@ -1251,8 +1246,8 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
  *  @stream: input bitstream to compute the hash on
  *  @key: 32-bit hash key
  **/
-static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
-                                        u32 key)
+static u32 ixgbe_atr_compute_hash_82599(union ixgbe_atr_input *atr_input,
+					u32 key)
 {
 	/*
 	 * The algorithm is as follows:
@@ -1272,100 +1267,68 @@ static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
 	 *    To simplify for programming, the algorithm is implemented
 	 *    in software this way:
 	 *
-	 *    Key[31:0], Stream[335:0]
+	 *    key[31:0], hi_hash_dword[31:0], lo_hash_dword[31:0], hash[15:0]
+	 *
+	 *    for (i = 0; i < 352; i+=32)
+	 *        hi_hash_dword[31:0] ^= Stream[(i+31):i];
+	 *
+	 *    lo_hash_dword[15:0]  ^= Stream[15:0];
+	 *    lo_hash_dword[15:0]  ^= hi_hash_dword[31:16];
+	 *    lo_hash_dword[31:16] ^= hi_hash_dword[15:0];
+	 *
+	 *    hi_hash_dword[31:0]  ^= Stream[351:320];
 	 *
-	 *    tmp_key[11 * 32 - 1:0] = 11{Key[31:0] = key concatenated 11 times
-	 *    int_key[350:0] = tmp_key[351:1]
-	 *    int_stream[365:0] = Stream[14:0] | Stream[335:0] | Stream[335:321]
+	 *    if(key[0])
+	 *        hash[15:0] ^= Stream[15:0];
 	 *
-	 *    hash[15:0] = 0;
-	 *    for (i = 0; i < 351; i++) {
-	 *        if (int_key[i])
-	 *            hash ^= int_stream[(i + 15):i];
+	 *    for (i = 0; i < 16; i++) {
+	 *        if (key[i])
+	 *            hash[15:0] ^= lo_hash_dword[(i+15):i];
+	 *        if (key[i + 16])
+	 *            hash[15:0] ^= hi_hash_dword[(i+15):i];
 	 *    }
+	 *
 	 */
+	__be32 common_hash_dword = 0;
+	u32 hi_hash_dword, lo_hash_dword, flow_vm_vlan;
+	u32 hash_result = 0;
+	u8 i;
 
-	union {
-		u64    fill[6];
-		u32    key[11];
-		u8     key_stream[44];
-	} tmp_key;
+	/* record the flow_vm_vlan bits as they are a key part to the hash */
+	flow_vm_vlan = ntohl(atr_input->dword_stream[0]);
 
-	u8   *stream = (u8 *)atr_input;
-	u8   int_key[44];      /* upper-most bit unused */
-	u8   hash_str[46];     /* upper-most 2 bits unused */
-	u16  hash_result = 0;
-	int  i, j, k, h;
+	/* generate common hash dword */
+	for (i = 10; i; i -= 2)
+		common_hash_dword ^= atr_input->dword_stream[i] ^
+				     atr_input->dword_stream[i - 1];
 
-	/*
-	 * Initialize the fill member to prevent warnings
-	 * on some compilers
-	 */
-	 tmp_key.fill[0] = 0;
+	hi_hash_dword = ntohl(common_hash_dword);
 
-	/* First load the temporary key stream */
-	for (i = 0; i < 6; i++) {
-		u64 fillkey = ((u64)key << 32) | key;
-		tmp_key.fill[i] = fillkey;
-	}
+	/* low dword is word swapped version of common */
+	lo_hash_dword = (hi_hash_dword >> 16) | (hi_hash_dword << 16);
 
-	/*
-	 * Set the interim key for the hashing.  Bit 352 is unused, so we must
-	 * shift and compensate when building the key.
-	 */
+	/* apply flow ID/VM pool/VLAN ID bits to hash words */
+	hi_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan >> 16);
 
-	int_key[0] = tmp_key.key_stream[0] >> 1;
-	for (i = 1, j = 0; i < 44; i++) {
-		unsigned int this_key = tmp_key.key_stream[j] << 7;
-		j++;
-		int_key[i] = (u8)(this_key | (tmp_key.key_stream[j] >> 1));
-	}
+	/* Process bits 0 and 16 */
+	if (key & 0x0001) hash_result ^= lo_hash_dword;
+	if (key & 0x00010000) hash_result ^= hi_hash_dword;
 
 	/*
-	 * Set the interim bit string for the hashing.  Bits 368 and 367 are
-	 * unused, so shift and compensate when building the string.
+	 * apply flow ID/VM pool/VLAN ID bits to lo hash dword, we had to
+	 * delay this because bit 0 of the stream should not be processed
+	 * so we do not add the vlan until after bit 0 was processed
 	 */
-	hash_str[0] = (stream[40] & 0x7f) >> 1;
-	for (i = 1, j = 40; i < 46; i++) {
-		unsigned int this_str = stream[j] << 7;
-		j++;
-		if (j > 41)
-			j = 0;
-		hash_str[i] = (u8)(this_str | (stream[j] >> 1));
-	}
+	lo_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan << 16);
 
-	/*
-	 * Now compute the hash.  i is the index into hash_str, j is into our
-	 * key stream, k is counting the number of bits, and h interates within
-	 * each byte.
-	 */
-	for (i = 45, j = 43, k = 0; k < 351 && i >= 2 && j >= 0; i--, j--) {
-		for (h = 0; h < 8 && k < 351; h++, k++) {
-			if (int_key[j] & (1 << h)) {
-				/*
-				 * Key bit is set, XOR in the current 16-bit
-				 * string.  Example of processing:
-				 *    h = 0,
-				 *      tmp = (hash_str[i - 2] & 0 << 16) |
-				 *            (hash_str[i - 1] & 0xff << 8) |
-				 *            (hash_str[i] & 0xff >> 0)
-				 *      So tmp = hash_str[15 + k:k], since the
-				 *      i + 2 clause rolls off the 16-bit value
-				 *    h = 7,
-				 *      tmp = (hash_str[i - 2] & 0x7f << 9) |
-				 *            (hash_str[i - 1] & 0xff << 1) |
-				 *            (hash_str[i] & 0x80 >> 7)
-				 */
-				int tmp = (hash_str[i] >> h);
-				tmp |= (hash_str[i - 1] << (8 - h));
-				tmp |= (int)(hash_str[i - 2] & ((1 << h) - 1))
-				             << (16 - h);
-				hash_result ^= (u16)tmp;
-			}
-		}
+
+	/* process the remaining 30 bits in the key 2 bits at a time */
+	for (i = 15; i; i-- ) {
+		if (key & (0x0001 << i)) hash_result ^= lo_hash_dword >> i;
+		if (key & (0x00010000 << i)) hash_result ^= hi_hash_dword >> i;
 	}
 
-	return hash_result;
+	return hash_result & IXGBE_ATR_HASH_MASK;
 }
 
 /**
@@ -1373,10 +1336,9 @@ static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
  *  @input: input stream to modify
  *  @vlan: the VLAN id to load
  **/
-s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
+s32 ixgbe_atr_set_vlan_id_82599(union ixgbe_atr_input *input, __be16 vlan)
 {
-	input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] = vlan >> 8;
-	input->byte_stream[IXGBE_ATR_VLAN_OFFSET] = vlan & 0xff;
+	input->formatted.vlan_id = vlan;
 
 	return 0;
 }
@@ -1386,14 +1348,9 @@ s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
  *  @input: input stream to modify
  *  @src_addr: the IP address to load
  **/
-s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
+s32 ixgbe_atr_set_src_ipv4_82599(union ixgbe_atr_input *input, __be32 src_addr)
 {
-	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 3] = src_addr >> 24;
-	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 2] =
-	                                               (src_addr >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 1] =
-	                                                (src_addr >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET] = src_addr & 0xff;
+	input->formatted.src_ip[0] = src_addr;
 
 	return 0;
 }
@@ -1403,14 +1360,9 @@ s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
  *  @input: input stream to modify
  *  @dst_addr: the IP address to load
  **/
-s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
+s32 ixgbe_atr_set_dst_ipv4_82599(union ixgbe_atr_input *input, __be32 dst_addr)
 {
-	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 3] = dst_addr >> 24;
-	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 2] =
-	                                               (dst_addr >> 16) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 1] =
-	                                                (dst_addr >> 8) & 0xff;
-	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET] = dst_addr & 0xff;
+	input->formatted.dst_ip[0] = dst_addr;
 
 	return 0;
 }
@@ -1420,10 +1372,9 @@ s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
  *  @input: input stream to modify
  *  @src_port: the source port to load
  **/
-s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
+s32 ixgbe_atr_set_src_port_82599(union ixgbe_atr_input *input, __be16 src_port)
 {
-	input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET + 1] = src_port >> 8;
-	input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET] = src_port & 0xff;
+	input->formatted.src_port = src_port;
 
 	return 0;
 }
@@ -1433,10 +1384,9 @@ s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
  *  @input: input stream to modify
  *  @dst_port: the destination port to load
  **/
-s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
+s32 ixgbe_atr_set_dst_port_82599(union ixgbe_atr_input *input, __be16 dst_port)
 {
-	input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET + 1] = dst_port >> 8;
-	input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET] = dst_port & 0xff;
+	input->formatted.dst_port = dst_port;
 
 	return 0;
 }
@@ -1446,10 +1396,10 @@ s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
  *  @input: input stream to modify
  *  @flex_bytes: the flexible bytes to load
  **/
-s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
+s32 ixgbe_atr_set_flex_byte_82599(union ixgbe_atr_input *input,
+				  __be16 flex_bytes)
 {
-	input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET + 1] = flex_byte >> 8;
-	input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET] = flex_byte & 0xff;
+	input->formatted.flex_bytes = flex_bytes;
 
 	return 0;
 }
@@ -1459,9 +1409,9 @@ s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
  *  @input: input stream to modify
  *  @l4type: the layer 4 type value to load
  **/
-s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
+s32 ixgbe_atr_set_l4type_82599(union ixgbe_atr_input *input, u8 l4type)
 {
-	input->byte_stream[IXGBE_ATR_L4TYPE_OFFSET] = l4type;
+	input->formatted.flow_type = l4type;
 
 	return 0;
 }
@@ -1471,10 +1421,9 @@ s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
  *  @input: input stream to search
  *  @vlan: the VLAN id to load
  **/
-static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
+static s32 ixgbe_atr_get_vlan_id_82599(union ixgbe_atr_input *input, __be16 *vlan)
 {
-	*vlan = input->byte_stream[IXGBE_ATR_VLAN_OFFSET];
-	*vlan |= input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] << 8;
+	*vlan = input->formatted.vlan_id;
 
 	return 0;
 }
@@ -1484,13 +1433,10 @@ static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
  *  @input: input stream to search
  *  @src_addr: the IP address to load
  **/
-static s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input,
-                                        u32 *src_addr)
+static s32 ixgbe_atr_get_src_ipv4_82599(union ixgbe_atr_input *input,
+                                        __be32 *src_addr)
 {
-	*src_addr = input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET];
-	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 1] << 8;
-	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 2] << 16;
-	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 3] << 24;
+	*src_addr = input->formatted.src_ip[0];
 
 	return 0;
 }
@@ -1500,13 +1446,10 @@ static s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input,
  *  @input: input stream to search
  *  @dst_addr: the IP address to load
  **/
-static s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input,
-                                        u32 *dst_addr)
+static s32 ixgbe_atr_get_dst_ipv4_82599(union ixgbe_atr_input *input,
+                                        __be32 *dst_addr)
 {
-	*dst_addr = input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET];
-	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 1] << 8;
-	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 2] << 16;
-	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 3] << 24;
+	*dst_addr = input->formatted.dst_ip[0];
 
 	return 0;
 }
@@ -1519,29 +1462,14 @@ static s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input,
  *  @src_addr_3: the third 4 bytes of the IP address to load
  *  @src_addr_4: the fourth 4 bytes of the IP address to load
  **/
-static s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 *src_addr_1, u32 *src_addr_2,
-                                        u32 *src_addr_3, u32 *src_addr_4)
+static s32 ixgbe_atr_get_src_ipv6_82599(union ixgbe_atr_input *input,
+                                        __be32 *src_addr_0, __be32 *src_addr_1,
+                                        __be32 *src_addr_2, __be32 *src_addr_3)
 {
-	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 12];
-	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 13] << 8;
-	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 14] << 16;
-	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 15] << 24;
-
-	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 8];
-	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 9] << 8;
-	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 10] << 16;
-	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 11] << 24;
-
-	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 4];
-	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 5] << 8;
-	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 6] << 16;
-	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 7] << 24;
-
-	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET];
-	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] << 8;
-	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 2] << 16;
-	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 3] << 24;
+	*src_addr_0 = input->formatted.src_ip[0];
+	*src_addr_1 = input->formatted.src_ip[1];
+	*src_addr_2 = input->formatted.src_ip[2];
+	*src_addr_3 = input->formatted.src_ip[3];
 
 	return 0;
 }
@@ -1556,11 +1484,10 @@ static s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
  *  endianness when retrieving the data.  This can be confusing since the
  *  internal hash engine expects it to be big-endian.
  **/
-static s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input,
-                                        u16 *src_port)
+static s32 ixgbe_atr_get_src_port_82599(union ixgbe_atr_input *input,
+                                        __be16 *src_port)
 {
-	*src_port = input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET] << 8;
-	*src_port |= input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET + 1];
+	*src_port = input->formatted.src_port;
 
 	return 0;
 }
@@ -1575,11 +1502,10 @@ static s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input,
  *  endianness when retrieving the data.  This can be confusing since the
  *  internal hash engine expects it to be big-endian.
  **/
-static s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input,
-                                        u16 *dst_port)
+static s32 ixgbe_atr_get_dst_port_82599(union ixgbe_atr_input *input,
+                                        __be16 *dst_port)
 {
-	*dst_port = input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET] << 8;
-	*dst_port |= input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET + 1];
+	*dst_port = input->formatted.dst_port;
 
 	return 0;
 }
@@ -1589,11 +1515,10 @@ static s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input,
  *  @input: input stream to modify
  *  @flex_bytes: the flexible bytes to load
  **/
-static s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
-                                         u16 *flex_byte)
+static s32 ixgbe_atr_get_flex_byte_82599(union ixgbe_atr_input *input,
+                                         __be16 *flex_bytes)
 {
-	*flex_byte = input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET];
-	*flex_byte |= input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET + 1] << 8;
+	*flex_bytes = input->formatted.flex_bytes;
 
 	return 0;
 }
@@ -1603,10 +1528,10 @@ static s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
  *  @input: input stream to modify
  *  @l4type: the layer 4 type value to load
  **/
-static s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input,
+static s32 ixgbe_atr_get_l4type_82599(union ixgbe_atr_input *input,
                                       u8 *l4type)
 {
-	*l4type = input->byte_stream[IXGBE_ATR_L4TYPE_OFFSET];
+	*l4type = input->formatted.flow_type;
 
 	return 0;
 }
@@ -1618,57 +1543,49 @@ static s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input,
  *  @queue: queue index to direct traffic to
  **/
 s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
-                                          struct ixgbe_atr_input *input,
+                                          union ixgbe_atr_input *input,
                                           u8 queue)
 {
 	u64  fdirhashcmd;
-	u64  fdircmd;
-	u32  fdirhash;
-	u16  bucket_hash, sig_hash;
-	u8   l4type;
-
-	bucket_hash = ixgbe_atr_compute_hash_82599(input,
-	                                           IXGBE_ATR_BUCKET_HASH_KEY);
-
-	/* bucket_hash is only 15 bits */
-	bucket_hash &= IXGBE_ATR_HASH_MASK;
-
-	sig_hash = ixgbe_atr_compute_hash_82599(input,
-	                                        IXGBE_ATR_SIGNATURE_HASH_KEY);
-
-	/* Get the l4type in order to program FDIRCMD properly */
-	/* lowest 2 bits are FDIRCMD.L4TYPE, third lowest bit is FDIRCMD.IPV6 */
-	ixgbe_atr_get_l4type_82599(input, &l4type);
+	u32  fdircmd;
+	u32  bucket_hash, sig_hash;
 
 	/*
-	 * The lower 32-bits of fdirhashcmd is for FDIRHASH, the upper 32-bits
-	 * is for FDIRCMD.  Then do a 64-bit register write from FDIRHASH.
+	 * Get the flow_type in order to program FDIRCMD properly
+	 * lowest 2 bits are FDIRCMD.L4TYPE, third lowest bit is FDIRCMD.IPV6
 	 */
-	fdirhash = sig_hash << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT | bucket_hash;
-
-	fdircmd = (IXGBE_FDIRCMD_CMD_ADD_FLOW | IXGBE_FDIRCMD_FILTER_UPDATE |
-	           IXGBE_FDIRCMD_LAST | IXGBE_FDIRCMD_QUEUE_EN);
-
-	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
-	case IXGBE_ATR_L4TYPE_TCP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_TCP;
-		break;
-	case IXGBE_ATR_L4TYPE_UDP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_UDP;
-		break;
-	case IXGBE_ATR_L4TYPE_SCTP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_SCTP;
+	switch (input->formatted.flow_type) {
+	case IXGBE_ATR_FLOW_TYPE_TCPV4:
+	case IXGBE_ATR_FLOW_TYPE_UDPV4:
+	case IXGBE_ATR_FLOW_TYPE_SCTPV4:
+	case IXGBE_ATR_FLOW_TYPE_TCPV6:
+	case IXGBE_ATR_FLOW_TYPE_UDPV6:
+	case IXGBE_ATR_FLOW_TYPE_SCTPV6:
 		break;
 	default:
-		hw_dbg(hw, "Error on l4type input\n");
+		hw_dbg(hw, " Error on flow type input\n");
 		return IXGBE_ERR_CONFIG;
 	}
 
-	if (l4type & IXGBE_ATR_L4TYPE_IPV6_MASK)
-		fdircmd |= IXGBE_FDIRCMD_IPV6;
+	/* configure FDIRCMD register */
+	fdircmd = IXGBE_FDIRCMD_CMD_ADD_FLOW | IXGBE_FDIRCMD_FILTER_UPDATE |
+	          IXGBE_FDIRCMD_LAST | IXGBE_FDIRCMD_QUEUE_EN;
+	fdircmd |= input->formatted.flow_type << IXGBE_FDIRCMD_FLOW_TYPE_SHIFT;
+	fdircmd |= (u32)queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT;
 
-	fdircmd |= ((u64)queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT);
-	fdirhashcmd = ((fdircmd << 32) | fdirhash);
+	/*
+	 * The lower 32-bits of fdirhashcmd is for FDIRHASH, the upper 32-bits
+	 * is for FDIRCMD.  Then do a 64-bit register write from FDIRHASH.
+	 */
+	fdirhashcmd = (u64)fdircmd << 32;
+
+	sig_hash = ixgbe_atr_compute_hash_82599(input,
+	                                        IXGBE_ATR_SIGNATURE_HASH_KEY);
+	fdirhashcmd |= sig_hash << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT;
+
+	bucket_hash = ixgbe_atr_compute_hash_82599(input,
+	                                           IXGBE_ATR_BUCKET_HASH_KEY);
+	fdirhashcmd |= bucket_hash;
 
 	IXGBE_WRITE_REG64(hw, IXGBE_FDIRHASH, fdirhashcmd);
 
@@ -1687,7 +1604,7 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
  *  hardware writes must be protected from one another.
  **/
 s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
-                                      struct ixgbe_atr_input *input,
+                                      union ixgbe_atr_input *input,
                                       struct ixgbe_atr_input_masks *input_masks,
                                       u16 soft_id, u8 queue)
 {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a8bab15..76e40e2 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2278,7 +2278,7 @@ static int ixgbe_set_rx_ntuple(struct net_device *dev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ethtool_rx_ntuple_flow_spec fs = cmd->fs;
-	struct ixgbe_atr_input input_struct;
+	union ixgbe_atr_input input_struct;
 	struct ixgbe_atr_input_masks input_masks;
 	int target_queue;
 
@@ -2293,7 +2293,7 @@ static int ixgbe_set_rx_ntuple(struct net_device *dev,
 	    (fs.action < ETHTOOL_RXNTUPLE_ACTION_DROP))
 		return -EINVAL;
 
-	memset(&input_struct, 0, sizeof(struct ixgbe_atr_input));
+	memset(&input_struct, 0, sizeof(union ixgbe_atr_input));
 	memset(&input_masks, 0, sizeof(struct ixgbe_atr_input_masks));
 
 	input_masks.src_ip_mask = fs.m_u.tcp_ip4_spec.ip4src;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e8ae311..26718ab 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6509,21 +6509,20 @@ static void ixgbe_tx_queue(struct ixgbe_ring *tx_ring,
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 		      u8 queue, u32 tx_flags, __be16 protocol)
 {
-	struct ixgbe_atr_input atr_input;
+	union ixgbe_atr_input atr_input;
 	struct iphdr *iph = ip_hdr(skb);
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
 	struct tcphdr *th;
-	u16 vlan_id;
+	__be16 vlan_id;
 
 	/* Right now, we support IPv4 w/ TCP only */
 	if (protocol != htons(ETH_P_IP) ||
 	    iph->protocol != IPPROTO_TCP)
 		return;
 
-	memset(&atr_input, 0, sizeof(struct ixgbe_atr_input));
+	memset(&atr_input, 0, sizeof(union ixgbe_atr_input));
 
-	vlan_id = (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK) >>
-		   IXGBE_TX_FLAGS_VLAN_SHIFT;
+	vlan_id = htons(tx_flags >> IXGBE_TX_FLAGS_VLAN_SHIFT);
 
 	th = tcp_hdr(skb);
 
@@ -6531,7 +6530,7 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	ixgbe_atr_set_src_port_82599(&atr_input, th->dest);
 	ixgbe_atr_set_dst_port_82599(&atr_input, th->source);
 	ixgbe_atr_set_flex_byte_82599(&atr_input, eth->h_proto);
-	ixgbe_atr_set_l4type_82599(&atr_input, IXGBE_ATR_L4TYPE_TCP);
+	ixgbe_atr_set_l4type_82599(&atr_input, IXGBE_ATR_FLOW_TYPE_TCPV4);
 	/* src and dst are inverted, think how the receiver sees them */
 	ixgbe_atr_set_src_ipv4_82599(&atr_input, iph->daddr);
 	ixgbe_atr_set_dst_ipv4_82599(&atr_input, iph->saddr);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 446f3467..c56a712 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1990,6 +1990,7 @@ enum ixgbe_fdir_pballoc_type {
 #define IXGBE_FDIRCMD_LAST                      0x00000800
 #define IXGBE_FDIRCMD_COLLISION                 0x00001000
 #define IXGBE_FDIRCMD_QUEUE_EN                  0x00008000
+#define IXGBE_FDIRCMD_FLOW_TYPE_SHIFT           5
 #define IXGBE_FDIRCMD_RX_QUEUE_SHIFT            16
 #define IXGBE_FDIRCMD_VT_POOL_SHIFT             24
 #define IXGBE_FDIR_INIT_DONE_POLL               10
@@ -2147,51 +2148,63 @@ typedef u32 ixgbe_physical_layer;
 #define FC_LOW_WATER(MTU)  (2 * (2 * PAUSE_MTU(MTU) + PAUSE_RTT))
 
 /* Software ATR hash keys */
-#define IXGBE_ATR_BUCKET_HASH_KEY    0xE214AD3D
-#define IXGBE_ATR_SIGNATURE_HASH_KEY 0x14364D17
-
-/* Software ATR input stream offsets and masks */
-#define IXGBE_ATR_VLAN_OFFSET       0
-#define IXGBE_ATR_SRC_IPV6_OFFSET   2
-#define IXGBE_ATR_SRC_IPV4_OFFSET  14
-#define IXGBE_ATR_DST_IPV6_OFFSET  18
-#define IXGBE_ATR_DST_IPV4_OFFSET  30
-#define IXGBE_ATR_SRC_PORT_OFFSET  34
-#define IXGBE_ATR_DST_PORT_OFFSET  36
-#define IXGBE_ATR_FLEX_BYTE_OFFSET 38
-#define IXGBE_ATR_VM_POOL_OFFSET   40
-#define IXGBE_ATR_L4TYPE_OFFSET    41
+#define IXGBE_ATR_BUCKET_HASH_KEY    0x3DAD14E2
+#define IXGBE_ATR_SIGNATURE_HASH_KEY 0x174D3614
 
+/* Software ATR input stream values and masks */
+#define IXGBE_ATR_HASH_MASK     0x7fff
 #define IXGBE_ATR_L4TYPE_MASK      0x3
-#define IXGBE_ATR_L4TYPE_IPV6_MASK 0x4
 #define IXGBE_ATR_L4TYPE_UDP       0x1
 #define IXGBE_ATR_L4TYPE_TCP       0x2
 #define IXGBE_ATR_L4TYPE_SCTP      0x3
-#define IXGBE_ATR_HASH_MASK     0x7fff
+#define IXGBE_ATR_L4TYPE_IPV6_MASK 0x4
+enum ixgbe_atr_flow_type {
+	IXGBE_ATR_FLOW_TYPE_IPV4   = 0x0,
+	IXGBE_ATR_FLOW_TYPE_UDPV4  = 0x1,
+	IXGBE_ATR_FLOW_TYPE_TCPV4  = 0x2,
+	IXGBE_ATR_FLOW_TYPE_SCTPV4 = 0x3,
+	IXGBE_ATR_FLOW_TYPE_IPV6   = 0x4,
+	IXGBE_ATR_FLOW_TYPE_UDPV6  = 0x5,
+	IXGBE_ATR_FLOW_TYPE_TCPV6  = 0x6,
+	IXGBE_ATR_FLOW_TYPE_SCTPV6 = 0x7,
+};
 
 /* Flow Director ATR input struct. */
-struct ixgbe_atr_input {
-	/* Byte layout in order, all values with MSB first:
+union ixgbe_atr_input {
+	/*
+	 * Byte layout in order, all values with MSB first:
 	 *
+	 * vm_pool    - 1 byte
+	 * flow_type  - 1 byte
 	 * vlan_id    - 2 bytes
 	 * src_ip     - 16 bytes
 	 * dst_ip     - 16 bytes
 	 * src_port   - 2 bytes
 	 * dst_port   - 2 bytes
 	 * flex_bytes - 2 bytes
-	 * vm_pool    - 1 byte
-	 * l4type     - 1 byte
+	 * rsvd0      - 2 bytes - space reserved must be 0.
 	 */
-	u8 byte_stream[42];
+	struct {
+		u8     vm_pool;
+		u8     flow_type;
+		__be16 vlan_id;
+		__be32 dst_ip[4];
+		__be32 src_ip[4];
+		__be16 src_port;
+		__be16 dst_port;
+		__be16 flex_bytes;
+		__be16 rsvd0;
+	} formatted;
+	__be32 dword_stream[11];
 };
 
 struct ixgbe_atr_input_masks {
-	u32 src_ip_mask;
-	u32 dst_ip_mask;
-	u16 src_port_mask;
-	u16 dst_port_mask;
-	u16 vlan_id_mask;
-	u16 data_mask;
+	__be32 src_ip_mask;
+	__be32 dst_ip_mask;
+	__be16 src_port_mask;
+	__be16 dst_port_mask;
+	__be16 vlan_id_mask;
+	__be16 data_mask;
 };
 
 enum ixgbe_eeprom_type {
-- 
1.7.3.4

