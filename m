From: Malcolm Priestley <tvboxspy@gmail.com>
Subject: [PATCH] staging: vt6656: [BUG] - Failed connection, incorrect
 endian.
Date: Wed, 29 Aug 2012 20:04:27 +0100
Message-ID: <1346267067.1959.9.camel@router7789>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48851 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab2H2TEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 15:04:36 -0400
Received: by wgbdr13 with SMTP id dr13so810141wgb.1
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2012 12:04:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug with driver failing to negotiate a connection.

The bug was traced to commit
203e4615ee9d9fa8d3506b9d0ef30095e4d5bc90
staging: vt6656: removed custom definitions of Ethernet packet types

In that patch, definitions in include/linux/if_ether.h replaced ones 
in tether.h which had both big and little endian definitions.

include/linux/if_ether.h only refers to big endian values, cpu_to_be16 
should be used for the correct endian architectures.


Signed-off-by: Malcolm Priestley <tvboxspy@gmail.com>
---
 drivers/staging/vt6656/dpc.c  |    2 +-
 drivers/staging/vt6656/rxtx.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/vt6656/dpc.c b/drivers/staging/vt6656/dpc.c
index e4bdf2a..3aa895e 100644
--- a/drivers/staging/vt6656/dpc.c
+++ b/drivers/staging/vt6656/dpc.c
@@ -200,7 +200,7 @@ s_vProcessRxMACHeader (
     } else if (!compare_ether_addr(pbyRxBuffer, &pDevice->abySNAP_RFC1042[0])) {
         cbHeaderSize += 6;
         pwType = (PWORD) (pbyRxBufferAddr + cbHeaderSize);
-	if ((*pwType == cpu_to_le16(ETH_P_IPX)) ||
+	if ((*pwType == cpu_to_be16(ETH_P_IPX)) ||
 	    (*pwType == cpu_to_le16(0xF380))) {
 		cbHeaderSize -= 8;
             pwType = (PWORD) (pbyRxBufferAddr + cbHeaderSize);
diff --git a/drivers/staging/vt6656/rxtx.c b/drivers/staging/vt6656/rxtx.c
index bb46452..7035f13 100644
--- a/drivers/staging/vt6656/rxtx.c
+++ b/drivers/staging/vt6656/rxtx.c
@@ -1699,7 +1699,7 @@ s_bPacketToWirelessUsb(
     // 802.1H
     if (ntohs(psEthHeader->wType) > ETH_DATA_LEN) {
 	if (pDevice->dwDiagRefCount == 0) {
-		if ((psEthHeader->wType == cpu_to_le16(ETH_P_IPX)) ||
+		if ((psEthHeader->wType == cpu_to_be16(ETH_P_IPX)) ||
 		    (psEthHeader->wType == cpu_to_le16(0xF380))) {
 			memcpy((PBYTE) (pbyPayloadHead),
 			       abySNAP_Bridgetunnel, 6);
@@ -2838,7 +2838,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
     Packet_Type = skb->data[ETH_HLEN+1];
     Descriptor_type = skb->data[ETH_HLEN+1+1+2];
     Key_info = (skb->data[ETH_HLEN+1+1+2+1] << 8)|(skb->data[ETH_HLEN+1+1+2+2]);
-    if (pDevice->sTxEthHeader.wType == cpu_to_le16(ETH_P_PAE)) {
+    if (pDevice->sTxEthHeader.wType == cpu_to_be16(ETH_P_PAE)) {
 	/* 802.1x OR eapol-key challenge frame transfer */
 	if (((Protocol_Version == 1) || (Protocol_Version == 2)) &&
 		(Packet_Type == 3)) {
@@ -2987,7 +2987,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
         }
     }
 
-    if (pDevice->sTxEthHeader.wType == cpu_to_le16(ETH_P_PAE)) {
+    if (pDevice->sTxEthHeader.wType == cpu_to_be16(ETH_P_PAE)) {
         if (pDevice->byBBType != BB_TYPE_11A) {
             pDevice->wCurrentRate = RATE_1M;
             pDevice->byACKRate = RATE_1M;
@@ -3015,7 +3015,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
 
     if (bNeedEncryption == TRUE) {
         DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"ntohs Pkt Type=%04x\n", ntohs(pDevice->sTxEthHeader.wType));
-	if ((pDevice->sTxEthHeader.wType) == cpu_to_le16(ETH_P_PAE)) {
+	if ((pDevice->sTxEthHeader.wType) == cpu_to_be16(ETH_P_PAE)) {
 		bNeedEncryption = FALSE;
             DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"Pkt Type=%04x\n", (pDevice->sTxEthHeader.wType));
             if ((pMgmt->eCurrMode == WMAC_MODE_ESS_STA) && (pMgmt->eCurrState == WMAC_STATE_ASSOC)) {
-- 
1.7.10.4
