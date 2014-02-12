From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 02/13] sfc: Cache skb->data in local variable in
 efx_ptp_rx()
Date: Wed, 12 Feb 2014 18:58:34 +0000
Message-ID: <52FBC45A.9060809@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50927 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbaBLS6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:58:39 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 52be63d..7d0de50 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1366,6 +1366,7 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 	struct efx_ptp_match *match = (struct efx_ptp_match *)skb->cb;
 	u8 *match_data_012, *match_data_345;
 	unsigned int version;
+	u8 *data;
 
 	match->expiry = jiffies + msecs_to_jiffies(PKT_EVENT_LIFETIME_MS);
 
@@ -1374,7 +1375,8 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 		if (!pskb_may_pull(skb, PTP_V1_MIN_LENGTH)) {
 			return false;
 		}
-		version = ntohs(*(__be16 *)&skb->data[PTP_V1_VERSION_OFFSET]);
+		data = skb->data;
+		version = ntohs(*(__be16 *)&data[PTP_V1_VERSION_OFFSET]);
 		if (version != PTP_VERSION_V1) {
 			return false;
 		}
@@ -1382,13 +1384,14 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 		/* PTP V1 uses all six bytes of the UUID to match the packet
 		 * to the timestamp
 		 */
-		match_data_012 = skb->data + PTP_V1_UUID_OFFSET;
-		match_data_345 = skb->data + PTP_V1_UUID_OFFSET + 3;
+		match_data_012 = data + PTP_V1_UUID_OFFSET;
+		match_data_345 = data + PTP_V1_UUID_OFFSET + 3;
 	} else {
 		if (!pskb_may_pull(skb, PTP_V2_MIN_LENGTH)) {
 			return false;
 		}
-		version = skb->data[PTP_V2_VERSION_OFFSET];
+		data = skb->data;
+		version = data[PTP_V2_VERSION_OFFSET];
 		if ((version & PTP_VERSION_V2_MASK) != PTP_VERSION_V2) {
 			return false;
 		}
@@ -1400,17 +1403,17 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 		 * enhanced mode fixes this issue and uses bytes 0-2
 		 * and byte 5-7 of the UUID.
 		 */
-		match_data_345 = skb->data + PTP_V2_UUID_OFFSET + 5;
+		match_data_345 = data + PTP_V2_UUID_OFFSET + 5;
 		if (ptp->mode == MC_CMD_PTP_MODE_V2) {
-			match_data_012 = skb->data + PTP_V2_UUID_OFFSET + 2;
+			match_data_012 = data + PTP_V2_UUID_OFFSET + 2;
 		} else {
-			match_data_012 = skb->data + PTP_V2_UUID_OFFSET + 0;
+			match_data_012 = data + PTP_V2_UUID_OFFSET + 0;
 			BUG_ON(ptp->mode != MC_CMD_PTP_MODE_V2_ENHANCED);
 		}
 	}
 
 	/* Does this packet require timestamping? */
-	if (ntohs(*(__be16 *)&skb->data[PTP_DPORT_OFFSET]) == PTP_EVENT_PORT) {
+	if (ntohs(*(__be16 *)&data[PTP_DPORT_OFFSET]) == PTP_EVENT_PORT) {
 		match->state = PTP_PACKET_STATE_UNMATCHED;
 
 		/* We expect the sequence number to be in the same position in
@@ -1426,8 +1429,8 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 				   (match_data_345[0] << 24));
 		match->words[1] = (match_data_345[1]         |
 				   (match_data_345[2] << 8)  |
-				   (skb->data[PTP_V1_SEQUENCE_OFFSET +
-					      PTP_V1_SEQUENCE_LENGTH - 1] <<
+				   (data[PTP_V1_SEQUENCE_OFFSET +
+					 PTP_V1_SEQUENCE_LENGTH - 1] <<
 				    16));
 	} else {
 		match->state = PTP_PACKET_STATE_MATCH_UNWANTED;
