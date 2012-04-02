From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 47/51] iwlwifi: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:37 -0400
Message-ID: <1333335521-1348-48-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab2DBDAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:44 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/iwlwifi/iwl-testmode.c |   71 +++++++++++++++-----------
 1 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-testmode.c b/drivers/net/wireless/iwlwifi/iwl-testmode.c
index 76f7f92..a54e20e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@ -184,9 +184,10 @@ static void iwl_testmode_ucode_rx_pkt(struct iwl_priv *priv,
 			 "Run out of memory for messages to user space ?\n");
 		return;
 	}
-	NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND, IWL_TM_CMD_DEV2APP_UCODE_RX_PKT);
-	/* the length doesn't include len_n_flags field, so add it manually */
-	NLA_PUT(skb, IWL_TM_ATTR_UCODE_RX_PKT, length + sizeof(__le32), data);
+	if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND, IWL_TM_CMD_DEV2APP_UCODE_RX_PKT) ||
+	    /* the length doesn't include len_n_flags field, so add it manually */
+	    nla_put(skb, IWL_TM_ATTR_UCODE_RX_PKT, length + sizeof(__le32), data))
+		goto nla_put_failure;
 	cfg80211_testmode_event(skb, GFP_ATOMIC);
 	return;
 
@@ -314,8 +315,9 @@ static int iwl_testmode_ucode(struct ieee80211_hw *hw, struct nlattr **tb)
 	memcpy(reply_buf, &(pkt->hdr), reply_len);
 	iwl_free_resp(&cmd);
 
-	NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND, IWL_TM_CMD_DEV2APP_UCODE_RX_PKT);
-	NLA_PUT(skb, IWL_TM_ATTR_UCODE_RX_PKT, reply_len, reply_buf);
+	if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND, IWL_TM_CMD_DEV2APP_UCODE_RX_PKT) ||
+	    nla_put(skb, IWL_TM_ATTR_UCODE_RX_PKT, reply_len, reply_buf))
+		goto nla_put_failure;
 	return cfg80211_testmode_reply(skb);
 
 nla_put_failure:
@@ -379,7 +381,8 @@ static int iwl_testmode_reg(struct ieee80211_hw *hw, struct nlattr **tb)
 			IWL_ERR(priv, "Memory allocation fail\n");
 			return -ENOMEM;
 		}
-		NLA_PUT_U32(skb, IWL_TM_ATTR_REG_VALUE32, val32);
+		if (nla_put_u32(skb, IWL_TM_ATTR_REG_VALUE32, val32))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0)
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -478,10 +481,11 @@ static int iwl_testmode_driver(struct ieee80211_hw *hw, struct nlattr **tb)
 			IWL_ERR(priv, "Memory allocation fail\n");
 			return -ENOMEM;
 		}
-		NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND,
-			    IWL_TM_CMD_DEV2APP_SYNC_RSP);
-		NLA_PUT(skb, IWL_TM_ATTR_SYNC_RSP,
-			rsp_data_len, rsp_data_ptr);
+		if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
+				IWL_TM_CMD_DEV2APP_SYNC_RSP) ||
+		    nla_put(skb, IWL_TM_ATTR_SYNC_RSP,
+			    rsp_data_len, rsp_data_ptr))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0)
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -536,11 +540,12 @@ static int iwl_testmode_driver(struct ieee80211_hw *hw, struct nlattr **tb)
 				IWL_ERR(priv, "Memory allocation fail\n");
 				return -ENOMEM;
 			}
-			NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND,
-				IWL_TM_CMD_DEV2APP_EEPROM_RSP);
-			NLA_PUT(skb, IWL_TM_ATTR_EEPROM,
-				cfg(priv)->base_params->eeprom_size,
-				priv->shrd->eeprom);
+			if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
+					IWL_TM_CMD_DEV2APP_EEPROM_RSP) ||
+			    nla_put(skb, IWL_TM_ATTR_EEPROM,
+				    cfg(priv)->base_params->eeprom_size,
+				    priv->shrd->eeprom))
+				goto nla_put_failure;
 			status = cfg80211_testmode_reply(skb);
 			if (status < 0)
 				IWL_ERR(priv, "Error sending msg : %d\n",
@@ -566,8 +571,9 @@ static int iwl_testmode_driver(struct ieee80211_hw *hw, struct nlattr **tb)
 			IWL_ERR(priv, "Memory allocation fail\n");
 			return -ENOMEM;
 		}
-		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_VERSION,
-			    priv->fw->ucode_ver);
+		if (nla_put_u32(skb, IWL_TM_ATTR_FW_VERSION,
+				priv->fw->ucode_ver))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0)
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -582,7 +588,8 @@ static int iwl_testmode_driver(struct ieee80211_hw *hw, struct nlattr **tb)
 			IWL_ERR(priv, "Memory allocation fail\n");
 			return -ENOMEM;
 		}
-		NLA_PUT_U32(skb, IWL_TM_ATTR_DEVICE_ID, devid);
+		if (nla_put_u32(skb, IWL_TM_ATTR_DEVICE_ID, devid))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0)
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -602,9 +609,10 @@ static int iwl_testmode_driver(struct ieee80211_hw *hw, struct nlattr **tb)
 			inst_size = img->sec[IWL_UCODE_SECTION_INST].len;
 			data_size = img->sec[IWL_UCODE_SECTION_DATA].len;
 		}
-		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_TYPE, priv->shrd->ucode_type);
-		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size);
-		NLA_PUT_U32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size);
+		if (nla_put_u32(skb, IWL_TM_ATTR_FW_TYPE, priv->shrd->ucode_type) ||
+		    nla_put_u32(skb, IWL_TM_ATTR_FW_INST_SIZE, inst_size) ||
+		    nla_put_u32(skb, IWL_TM_ATTR_FW_DATA_SIZE, data_size))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0)
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -678,9 +686,10 @@ static int iwl_testmode_trace(struct ieee80211_hw *hw, struct nlattr **tb)
 			iwl_trace_cleanup(priv);
 			return -ENOMEM;
 		}
-		NLA_PUT(skb, IWL_TM_ATTR_TRACE_ADDR,
-			sizeof(priv->testmode_trace.dma_addr),
-			(u64 *)&priv->testmode_trace.dma_addr);
+		if (nla_put(skb, IWL_TM_ATTR_TRACE_ADDR,
+			    sizeof(priv->testmode_trace.dma_addr),
+			    (u64 *)&priv->testmode_trace.dma_addr))
+			goto nla_put_failure;
 		status = cfg80211_testmode_reply(skb);
 		if (status < 0) {
 			IWL_ERR(priv, "Error sending msg : %d\n", status);
@@ -725,9 +734,10 @@ static int iwl_testmode_trace_dump(struct ieee80211_hw *hw,
 			length = priv->testmode_trace.buff_size %
 				DUMP_CHUNK_SIZE;
 
-		NLA_PUT(skb, IWL_TM_ATTR_TRACE_DUMP, length,
-			priv->testmode_trace.trace_addr +
-			(DUMP_CHUNK_SIZE * idx));
+		if (nla_put(skb, IWL_TM_ATTR_TRACE_DUMP, length,
+			    priv->testmode_trace.trace_addr +
+			    (DUMP_CHUNK_SIZE * idx)))
+			goto nla_put_failure;
 		idx++;
 		cb->args[4] = idx;
 		return 0;
@@ -922,9 +932,10 @@ static int iwl_testmode_buffer_dump(struct ieee80211_hw *hw,
 			length = priv->testmode_mem.buff_size %
 				DUMP_CHUNK_SIZE;
 
-		NLA_PUT(skb, IWL_TM_ATTR_BUFFER_DUMP, length,
-			priv->testmode_mem.buff_addr +
-			(DUMP_CHUNK_SIZE * idx));
+		if (nla_put(skb, IWL_TM_ATTR_BUFFER_DUMP, length,
+			    priv->testmode_mem.buff_addr +
+			    (DUMP_CHUNK_SIZE * idx)))
+			goto nla_put_failure;
 		idx++;
 		cb->args[4] = idx;
 		return 0;
-- 
1.7.7.6
