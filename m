From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 2/3] net: replace more place to skb_put_[data:zero]
Date: Sun, 18 Jun 2017 22:49:30 +0800
Message-ID: <1497797370-25477-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:47323 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752925AbdFROuF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 10:50:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

spatch file,
@@
expression skb, len, data;
type t;
@@
-memcpy((t *)skb_put(skb, len), data, len);
+skb_put_data(skb, data, len);

@@
identifier p;
expression skb, len, data;
type t;
@@
-p = (t *)memset(skb_put(skb, len), data, len);
+p = skb_put_zero(skb, len);

@@
expression skb, len, data;
type t;
@@
-memcpy((t *)__skb_put(skb, len), data, len);
+__skb_put_data(skb, data, len);

@@
identifier p;
expression skb, len, data;
type t;
@@
-p = (t *)memset(__skb_put(skb, len), data, len);
+p = __skb_put_zero(skb, len);

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/net/usb/cdc_ncm.c                                 | 4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c       | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c       | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c       | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c       | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c       | 6 ++----
 7 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bcb9747..2067743 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1069,7 +1069,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
 
 	/* push a new empty NDP */
 	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
-		ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, ctx->max_ndp_size), 0, ctx->max_ndp_size);
+		ndp16 = skb_put_zero(skb, ctx->max_ndp_size);
 	else
 		ndp16 = ctx->delayed_ndp16;
 
@@ -1120,7 +1120,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 			goto exit_no_skb;
 		}
 		/* fill out the initial 16-bit NTB header */
-		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
+		nth16 = skb_put_zero(skb_out, sizeof(struct usb_cdc_ncm_nth16));
 		nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
 		nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
 		nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
index c7a7746..015476e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
@@ -647,8 +647,7 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet, totalpacketlen);
 
 	if (cmd_send_packet)
 		rtstatus = cmd_send_packet(hw, skb);
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
index 88faeab..f4129cf 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/fw.c
@@ -668,8 +668,7 @@ void rtl92d_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	if (!skb) {
 		dlok = false;
 	} else {
-		memcpy((u8 *) skb_put(skb, totalpacketlen),
-			&reserved_page_packet, totalpacketlen);
+		skb_put_data(skb, &reserved_page_packet, totalpacketlen);
 		rtstatus = _rtl92d_cmd_send_packet(hw, skb);
 
 		if (rtstatus)
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
index 1f42ce5..6f8f75a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c
@@ -708,8 +708,7 @@ void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet, totalpacketlen);
 
 	b_dlok = true;
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
index a954a87b..bf9859f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/fw.c
@@ -470,8 +470,7 @@ void rtl8723e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet, totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
index 4fc839b..01205578 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c
@@ -527,8 +527,7 @@ void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 		      u1rsvdpageloc, sizeof(u1rsvdpageloc));
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet, totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
index 7335010..67aec20 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c
@@ -1588,8 +1588,7 @@ void rtl8812ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 		      &reserved_page_packet_8812[0], totalpacketlen);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet_8812, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet_8812, totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
@@ -1725,8 +1724,7 @@ void rtl8821ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 		      &reserved_page_packet_8821[0], totalpacketlen);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *)skb_put(skb, totalpacketlen),
-	       &reserved_page_packet_8821, totalpacketlen);
+	skb_put_data(skb, &reserved_page_packet_8821, totalpacketlen);
 
 	rtstatus = rtl_cmd_send_packet(hw, skb);
 
-- 
2.7.4
