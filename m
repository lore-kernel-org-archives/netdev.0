From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT] rtlwifi: Fix endian error in extracting packet type
Date: Mon, 28 Oct 2013 18:28:23 -0500
Message-ID: <1383002903-8746-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>

All of the rtlwifi drivers have an error in the routine that tests if
the received data is "special". The 16-bit quantity is big-endian, but
was being extracted in native CPU mode. One of the effects of this bug
is to inhibit association under some conditions.

A statement that would have made the code correct had been changed to
a comment. Rather than just reinstating that code, the fix here passes
sparse tests.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
Cc: Stable <stable@vger.kernel.org> [2.6.38+]
---
 drivers/net/wireless/rtlwifi/base.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 9a78e3d..1efde7f 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1077,8 +1077,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 
 	ip = (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
 			      SNAP_SIZE + PROTOC_TYPE_SIZE);
-	ether_type = *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
-	/*	ether_type = ntohs(ether_type); */
+	ether_type = be16_to_cpu(*(__be16 *)((u8 *)skb->data + mac_hdr_len +
+					     SNAP_SIZE));
 
 	if (ETH_P_IP == ether_type) {
 		if (IPPROTO_UDP == ip->protocol) {
-- 
1.8.4
