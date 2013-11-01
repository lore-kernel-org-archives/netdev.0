From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT V2] rtlwifi: Fix endian error in extracting packet type
Date: Thu, 31 Oct 2013 19:43:58 -0500
Message-ID: <1383266638-4813-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:60073 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397Ab3KAAoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 20:44:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>

All of the rtlwifi drivers have an error in the routine that tests if
the data is "special". If it is, the subsequant transmission will be
at the lowest rate to enhance reliability. The 16-bit quantity is
big-endian, but was being extracted in native CPU mode. One of the
effects of this bug is to inhibit association under some conditions
as the TX rate is too high.

A statement that would have made the code correct had been changed to
a comment. Rather than just reinstating that code, the fix here passes
sparse tests. A side effect of fixing this problem would have been to force
all IPv6 frames to run at the lowest rate. The test for that frame type
is removed.

The original code only checked the lower-order byte of UDP ports for BOOTP
protocol. That is extended to the full 16-bit source and destination ports.

One of the local headers contained duplicates of some of the ETH_P_XXX
definitions. These are deleted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
Cc: Stable <stable@vger.kernel.org> [2.6.38+]
---

V2 - Addresses comments by Ben Hutchings and Bjorn Mork.

 drivers/net/wireless/rtlwifi/base.c |   15 ++++++---------
 drivers/net/wireless/rtlwifi/wifi.h |    6 +-----
 2 files changed, 7 insertions(+), 14 deletions(-)
Index: wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/base.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/base.c
@@ -1077,17 +1077,17 @@ u8 rtl_is_special_data(struct ieee80211_
 
 	ip = (struct iphdr *)((u8 *) skb->data + mac_hdr_len +
 			      SNAP_SIZE + PROTOC_TYPE_SIZE);
-	ether_type = *(u16 *) ((u8 *) skb->data + mac_hdr_len + SNAP_SIZE);
-	/*	ether_type = ntohs(ether_type); */
+	ether_type = be16_to_cpu(*(__be16 *)((u8 *)skb->data + mac_hdr_len +
+					     SNAP_SIZE));
 
 	if (ETH_P_IP == ether_type) {
 		if (IPPROTO_UDP == ip->protocol) {
 			struct udphdr *udp = (struct udphdr *)((u8 *) ip +
 							       (ip->ihl << 2));
-			if (((((u8 *) udp)[1] == 68) &&
-			     (((u8 *) udp)[3] == 67)) ||
-			    ((((u8 *) udp)[1] == 67) &&
-			     (((u8 *) udp)[3] == 68))) {
+			if (((((u16 *) udp)[0] == 68) &&
+			     (((u16 *) udp)[2] == 67)) ||
+			    ((((u16 *) udp)[0] == 67) &&
+			     (((u16 *) udp)[2] == 68))) {
 				/*
 				 * 68 : UDP BOOTP client
 				 * 67 : UDP BOOTP server
@@ -1126,9 +1126,6 @@ u8 rtl_is_special_data(struct ieee80211_
 		}
 
 		return true;
-	} else if (ETH_P_IPV6 == ether_type) {
-		/* IPv6 */
-		return true;
 	}
 
 	return false;
Index: wireless-testing-save/drivers/net/wireless/rtlwifi/wifi.h
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/wifi.h
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/wifi.h
@@ -77,11 +77,7 @@
 #define RTL_SLOT_TIME_9				9
 #define RTL_SLOT_TIME_20			20
 
-/*related with tcp/ip. */
-/*if_ehther.h*/
-#define ETH_P_PAE		0x888E	/*Port Access Entity (IEEE 802.1X) */
-#define ETH_P_IP		0x0800	/*Internet Protocol packet */
-#define ETH_P_ARP		0x0806	/*Address Resolution packet */
+/*related to tcp/ip. */
 #define SNAP_SIZE		6
 #define PROTOC_TYPE_SIZE	2
 
