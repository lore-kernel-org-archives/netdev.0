From: akpm@linux-foundation.org
Subject: [patch 2/4] bluetooth: hci_bcsp.c small cleanups/api users
Date: Mon, 09 Jun 2008 16:31:59 -0700
Message-ID: <200806092332.m59NW09M014556@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com, akinobu.mita@gmail.com,
	hidave.darkstar@gmail.com, marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58762 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755936AbYFIXcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Use bitrev16 from lib/bitrev.c.

Use the get_unaligned_be16 to get the crc from the packet, create a
small helper function for this.

Fix a shadowed variable sparse warning:
drivers/bluetooth/hci_bcsp.c:218:26: warning: symbol 'hdr' shadows an earlier one
drivers/bluetooth/hci_bcsp.c:187:5: originally declared here

[akpm@linux-foundation.org: select CONFIG_BITREVERSE, noted by akinobu.mita@gmail.com]
Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/Kconfig    |    1 
 drivers/bluetooth/hci_bcsp.c |   44 +++++++++------------------------
 2 files changed, 14 insertions(+), 31 deletions(-)

diff -puN drivers/bluetooth/hci_bcsp.c~bluetooth-hci_bcspc-small-cleanups-api-users drivers/bluetooth/hci_bcsp.c
--- a/drivers/bluetooth/hci_bcsp.c~bluetooth-hci_bcspc-small-cleanups-api-users
+++ a/drivers/bluetooth/hci_bcsp.c
@@ -39,6 +39,8 @@
 #include <linux/signal.h>
 #include <linux/ioctl.h>
 #include <linux/skbuff.h>
+#include <linux/bitrev.h>
+#include <asm/unaligned.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -124,27 +126,6 @@ static void bcsp_crc_update(u16 *crc, u8
 	*crc = reg;
 }
 
-/*
-   Get reverse of generated crc
-
-   Implementation note
-        The crc generator (bcsp_crc_init() and bcsp_crc_update())
-        creates a reversed crc, so it needs to be swapped back before
-        being passed on.
-*/
-static u16 bcsp_crc_reverse(u16 crc)
-{
-	u16 b, rev;
-
-	for (b = 0, rev = 0; b < 16; b++) {
-		rev = rev << 1;
-		rev |= (crc & 1);
-		crc = crc >> 1;
-	}
-
-	return (rev);
-}
-
 /* ---- BCSP core ---- */
 
 static void bcsp_slip_msgdelim(struct sk_buff *skb)
@@ -235,10 +216,10 @@ static struct sk_buff *bcsp_prepare_pkt(
 	}
 
 	if (hciextn && chan == 5) {
-		struct hci_command_hdr *hdr = (struct hci_command_hdr *) data;
+		__le16 opcode = ((struct hci_command_hdr *)data)->opcode;
 
 		/* Vendor specific commands */
-		if (hci_opcode_ogf(__le16_to_cpu(hdr->opcode)) == 0x3f) {
+		if (hci_opcode_ogf(__le16_to_cpu(opcode)) == 0x3f) {
 			u8 desc = *(data + HCI_COMMAND_HDR_SIZE);
 			if ((desc & 0xf0) == 0xc0) {
 				data += HCI_COMMAND_HDR_SIZE + 1;
@@ -296,7 +277,7 @@ static struct sk_buff *bcsp_prepare_pkt(
 
 	/* Put CRC */
 	if (bcsp->use_crc) {
-		bcsp_txmsg_crc = bcsp_crc_reverse(bcsp_txmsg_crc);
+		bcsp_txmsg_crc = bitrev16(bcsp_txmsg_crc);
 		bcsp_slip_one_byte(nskb, (u8) ((bcsp_txmsg_crc >> 8) & 0x00ff));
 		bcsp_slip_one_byte(nskb, (u8) (bcsp_txmsg_crc & 0x00ff));
 	}
@@ -566,6 +547,11 @@ static void bcsp_complete_rx_pkt(struct 
 	bcsp->rx_skb = NULL;
 }
 
+static u16 bscp_get_crc(struct bcsp_struct *bcsp)
+{
+	return get_unaligned_be16(&bcsp->rx_skb->data[bcsp->rx_skb->len - 2]);
+}
+
 /* Recv data */
 static int bcsp_recv(struct hci_uart *hu, void *data, int count)
 {
@@ -624,14 +610,10 @@ static int bcsp_recv(struct hci_uart *hu
 			continue;
 
 		case BCSP_W4_CRC:
-			if (bcsp_crc_reverse(bcsp->message_crc) !=
-					(bcsp->rx_skb->data[bcsp->rx_skb->len - 2] << 8) +
-					bcsp->rx_skb->data[bcsp->rx_skb->len - 1]) {
-
+			if (bitrev16(bcsp->message_crc) != bscp_get_crc(bcsp)) {
 				BT_ERR ("Checksum failed: computed %04x received %04x",
-					bcsp_crc_reverse(bcsp->message_crc),
-					(bcsp->rx_skb-> data[bcsp->rx_skb->len - 2] << 8) +
-					bcsp->rx_skb->data[bcsp->rx_skb->len - 1]);
+					bitrev16(bcsp->message_crc),
+					bscp_get_crc(bcsp));
 
 				kfree_skb(bcsp->rx_skb);
 				bcsp->rx_state = BCSP_W4_PKT_DELIMITER;
diff -puN drivers/bluetooth/Kconfig~bluetooth-hci_bcspc-small-cleanups-api-users drivers/bluetooth/Kconfig
--- a/drivers/bluetooth/Kconfig~bluetooth-hci_bcspc-small-cleanups-api-users
+++ a/drivers/bluetooth/Kconfig
@@ -71,6 +71,7 @@ config BT_HCIUART_H4
 config BT_HCIUART_BCSP
 	bool "BCSP protocol support"
 	depends on BT_HCIUART
+	select CONFIG_BITREVERSE
 	help
 	  BCSP (BlueCore Serial Protocol) is serial protocol for communication 
 	  between Bluetooth device and host. This protocol is required for non
_
