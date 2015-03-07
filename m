From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: Refactor i40e_debug_aq and make some functions static
Date: Sat,  7 Mar 2015 07:03:09 -0800
Message-ID: <1425740603-11280-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38815 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbCGPD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:27 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

A sparse complaint in i40e_debug_aq in a funky buffer write goes away by
straightening out the code out to something less convoluted.

Also fix some other sparse warnings while we are at it, making some
functions static and using NULL instead of 0.

Change-ID: I93907534fe1f1f675830774b3d14ecf1c6ffc9a0
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 50 ++++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      |  8 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 44 +++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |  2 +-
 6 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 10f9451..fc4817a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -85,9 +85,8 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
 	u16 len = le16_to_cpu(aq_desc->datalen);
-	u8 *aq_buffer = (u8 *)buffer;
-	u32 data[4];
-	u32 i = 0;
+	u8 *buf = (u8 *)buffer;
+	u16 i = 0;
 
 	if ((!(mask & hw->debug_mask)) || (desc == NULL))
 		return;
@@ -109,29 +108,30 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		   le32_to_cpu(aq_desc->params.external.addr_low));
 
 	if ((buffer != NULL) && (aq_desc->datalen != 0)) {
-		memset(data, 0, sizeof(data));
 		i40e_debug(hw, mask, "AQ CMD Buffer:\n");
 		if (buf_len < len)
 			len = buf_len;
-		for (i = 0; i < len; i++) {
-			data[((i % 16) / 4)] |=
-				((u32)aq_buffer[i]) << (8 * (i % 4));
-			if ((i % 16) == 15) {
-				i40e_debug(hw, mask,
-					   "\t0x%04X  %08X %08X %08X %08X\n",
-					   i - 15, le32_to_cpu(data[0]),
-					   le32_to_cpu(data[1]),
-					   le32_to_cpu(data[2]),
-					   le32_to_cpu(data[3]));
-				memset(data, 0, sizeof(data));
-			}
+		/* write the full 16-byte chunks */
+		for (i = 0; i < (len - 16); i += 16)
+			i40e_debug(hw, mask,
+				   "\t0x%04X  %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X\n",
+				   i, buf[i], buf[i + 1], buf[i + 2],
+				   buf[i + 3], buf[i + 4], buf[i + 5],
+				   buf[i + 6], buf[i + 7], buf[i + 8],
+				   buf[i + 9], buf[i + 10], buf[i + 11],
+				   buf[i + 12], buf[i + 13], buf[i + 14],
+				   buf[i + 15]);
+		/* write whatever's left over without overrunning the buffer */
+		if (i < len) {
+			char d_buf[80];
+			int j = 0;
+
+			memset(d_buf, 0, sizeof(d_buf));
+			j += sprintf(d_buf, "\t0x%04X ", i);
+			while (i < len)
+				j += sprintf(&d_buf[j], " %02X", buf[i++]);
+			i40e_debug(hw, mask, "%s\n", d_buf);
 		}
-		if ((i % 16) != 0)
-			i40e_debug(hw, mask, "\t0x%04X  %08X %08X %08X %08X\n",
-				   i - (i % 16), le32_to_cpu(data[0]),
-				   le32_to_cpu(data[1]),
-				   le32_to_cpu(data[2]),
-				   le32_to_cpu(data[3]));
 	}
 }
 
@@ -3409,9 +3409,9 @@ i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
  * is not passed then only register at 'reg_addr0' is read.
  *
  **/
-i40e_status i40e_aq_alternate_read(struct i40e_hw *hw,
-				   u32 reg_addr0, u32 *reg_val0,
-				   u32 reg_addr1, u32 *reg_val1)
+static i40e_status i40e_aq_alternate_read(struct i40e_hw *hw,
+					  u32 reg_addr0, u32 *reg_val0,
+					  u32 reg_addr1, u32 *reg_val1)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_alternate_write *cmd_resp =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0937cf3..02672c3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7923,7 +7923,7 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 }
 #endif /* HAVE_BRIDGE_ATTRIBS */
 
-const struct net_device_ops i40e_netdev_ops = {
+static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
 	.ndo_start_xmit		= i40e_lan_xmit_frame,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 039018a..89bd5b4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -171,8 +171,8 @@ static i40e_status i40e_poll_sr_srctl_done_bit(struct i40e_hw *hw)
  *
  * Reads one 16 bit word from the Shadow RAM using the GLNVM_SRCTL register.
  **/
-i40e_status i40e_read_nvm_word_srctl(struct i40e_hw *hw, u16 offset,
-				     u16 *data)
+static i40e_status i40e_read_nvm_word_srctl(struct i40e_hw *hw, u16 offset,
+					    u16 *data)
 {
 	i40e_status ret_code = I40E_ERR_TIMEOUT;
 	u32 sr_reg;
@@ -237,8 +237,8 @@ i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
  * method. The buffer read is preceded by the NVM ownership take
  * and followed by the release.
  **/
-i40e_status i40e_read_nvm_buffer_srctl(struct i40e_hw *hw, u16 offset,
-				       u16 *words, u16 *data)
+static i40e_status i40e_read_nvm_buffer_srctl(struct i40e_hw *hw, u16 offset,
+					      u16 *words, u16 *data)
 {
 	i40e_status ret_code = 0;
 	u16 index, word;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d4b4aa7..7327952 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1044,7 +1044,7 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 			for (i = 0; i < rx_ring->count; i++) {
 				rx_bi = &rx_ring->rx_bi[i];
 				rx_bi->dma = 0;
-				rx_bi->hdr_buf = 0;
+				rx_bi->hdr_buf = NULL;
 			}
 		}
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 0335b3f..f07b9ff 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -85,9 +85,8 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
 	u16 len = le16_to_cpu(aq_desc->datalen);
-	u8 *aq_buffer = (u8 *)buffer;
-	u32 data[4];
-	u32 i = 0;
+	u8 *buf = (u8 *)buffer;
+	u16 i = 0;
 
 	if ((!(mask & hw->debug_mask)) || (desc == NULL))
 		return;
@@ -109,29 +108,30 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 		   le32_to_cpu(aq_desc->params.external.addr_low));
 
 	if ((buffer != NULL) && (aq_desc->datalen != 0)) {
-		memset(data, 0, sizeof(data));
 		i40e_debug(hw, mask, "AQ CMD Buffer:\n");
 		if (buf_len < len)
 			len = buf_len;
-		for (i = 0; i < len; i++) {
-			data[((i % 16) / 4)] |=
-				((u32)aq_buffer[i]) << (8 * (i % 4));
-			if ((i % 16) == 15) {
-				i40e_debug(hw, mask,
-					   "\t0x%04X  %08X %08X %08X %08X\n",
-					   i - 15, le32_to_cpu(data[0]),
-					   le32_to_cpu(data[1]),
-					   le32_to_cpu(data[2]),
-					   le32_to_cpu(data[3]));
-				memset(data, 0, sizeof(data));
-			}
+		/* write the full 16-byte chunks */
+		for (i = 0; i < (len - 16); i += 16)
+			i40e_debug(hw, mask,
+				   "\t0x%04X  %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X\n",
+				   i, buf[i], buf[i + 1], buf[i + 2],
+				   buf[i + 3], buf[i + 4], buf[i + 5],
+				   buf[i + 6], buf[i + 7], buf[i + 8],
+				   buf[i + 9], buf[i + 10], buf[i + 11],
+				   buf[i + 12], buf[i + 13], buf[i + 14],
+				   buf[i + 15]);
+		/* write whatever's left over without overrunning the buffer */
+		if (i < len) {
+			char d_buf[80];
+			int j = 0;
+
+			memset(d_buf, 0, sizeof(d_buf));
+			j += sprintf(d_buf, "\t0x%04X ", i);
+			while (i < len)
+				j += sprintf(&d_buf[j], " %02X", buf[i++]);
+			i40e_debug(hw, mask, "%s\n", d_buf);
 		}
-		if ((i % 16) != 0)
-			i40e_debug(hw, mask, "\t0x%04X  %08X %08X %08X %08X\n",
-				   i - (i % 16), le32_to_cpu(data[0]),
-				   le32_to_cpu(data[1]),
-				   le32_to_cpu(data[2]),
-				   le32_to_cpu(data[3]));
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index fe13ad2..021b0d4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -542,7 +542,7 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 			for (i = 0; i < rx_ring->count; i++) {
 				rx_bi = &rx_ring->rx_bi[i];
 				rx_bi->dma = 0;
-				rx_bi->hdr_buf = 0;
+				rx_bi->hdr_buf = NULL;
 			}
 		}
 	}
-- 
1.9.3
