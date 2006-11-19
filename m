From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFT] bcm43xx-softmac: match specifications change in rssi
 processing
Date: Sun, 19 Nov 2006 17:44:50 -0600
Message-ID: <4560EC72.mailJBO11D63L@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.rdc-kc.rr.com ([24.94.166.129]:24222 "EHLO
	ms-smtp-03.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S933783AbWKSXpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 18:45:20 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On September 5, 2006, Johannes Berg changed the specifications for RSSI
processing. Implementing those changes involves specifying the bytes in
the RX header that contain the LNA (low-noise amplifier) bits, adding a
new argument to bcm43xx_rssi_postprocess, and the actual changes in
the rssi processing.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -382,8 +382,8 @@ void bcm43xx_generate_txhdr(struct bcm43
 }
 
 static s8 bcm43xx_rssi_postprocess(struct bcm43xx_private *bcm,
-				   u8 in_rssi, int ofdm,
-				   int adjust_2053, int adjust_2050)
+				   u8 in_rssi, int ofdm, int adjust_2053,
+				   int adjust_2050, u8 lna)
 {
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
@@ -395,12 +395,10 @@ static s8 bcm43xx_rssi_postprocess(struc
 			tmp = in_rssi;
 			if (tmp > 127)
 				tmp -= 256;
-			tmp *= 73;
-			tmp /= 64;
 			if (adjust_2050)
-				tmp += 25;
+				tmp += 17;
 			else
-				tmp -= 3;
+				tmp -= 4;
 		} else {
 			if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
 				if (in_rssi > 63)
@@ -409,7 +407,7 @@ static s8 bcm43xx_rssi_postprocess(struc
 				tmp = 31 - tmp;
 				tmp *= -131;
 				tmp /= 128;
-				tmp -= 57;
+				tmp -= 67;
 			} else {
 				tmp = in_rssi;
 				tmp = 31 - tmp;
@@ -418,8 +416,23 @@ static s8 bcm43xx_rssi_postprocess(struc
 				tmp -= 68;
 			}
 			if (phy->type == BCM43xx_PHYTYPE_G &&
-			    adjust_2050)
+			    adjust_2050) {
+				tmp += 20;
+				switch (lna) {
+				case 0:
+					tmp += 2;
+					break;
+				case 1:
+					tmp -= 19;
+					break;
+				case 2:
+					tmp -= 13;
+					break;
+				case 3:
+					tmp -= 25;
+				}
 				tmp += 25;
+			}
 		}
 		break;
 	case 0x2060:
@@ -454,7 +467,7 @@ static s8 bcm43xx_rssinoise_postprocess(
 		//TODO: Incomplete specs.
 		ret = 0;
 	} else
-		ret = bcm43xx_rssi_postprocess(bcm, in_rssi, 0, 1, 1);
+		ret = bcm43xx_rssi_postprocess(bcm, in_rssi, 0, 1, 1, 0);
 
 	return ret;
 }
@@ -476,6 +489,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
 	const u16 rxflags2 = le16_to_cpu(rxhdr->flags2);
 	const u16 rxflags3 = le16_to_cpu(rxhdr->flags3);
 	const int is_ofdm = !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_OFDM);
+	u8 lna;
 
 	if (rxflags2 & BCM43xx_RXHDR_FLAGS2_TYPE2FRAME) {
 		plcp = (struct bcm43xx_plcp_hdr4 *)(skb->data + 2);
@@ -493,9 +507,11 @@ int bcm43xx_rx(struct bcm43xx_private *b
 	memset(&stats, 0, sizeof(stats));
 	stats.mac_time = le16_to_cpu(rxhdr->mactime);
 	stats.rssi = rxhdr->rssi;
+	lna = (rxhdr->phy_rx_status2 & 0xc0000) >> 14;
 	stats.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
 					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
-					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
+					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ),
+					      lna);
 	stats.noise = bcm->stats.noise;
 	if (is_ofdm)
 		stats.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
@@ -94,7 +94,7 @@ struct bcm43xx_rxhdr {
 	__le16 flags1;
 	u8 rssi;
 	u8 signal_quality;
-	PAD_BYTES(2);
+	__le16 phy_rx_status2;
 	/* Flags field 3 */
 	__le16 flags3;
 	/* Flags field 2 */
