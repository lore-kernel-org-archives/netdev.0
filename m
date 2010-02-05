From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 5/6] Bluetooth: Enter active mode before establishing a SCO link.
Date: Fri,  5 Feb 2010 12:05:38 -0800
Message-ID: <c390216b3e868b16d8154939f4b6f8c16dbd9a9f.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
 <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
 <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
 <6c2718da59613d76013b501bf0f8bcf9d7794b2d.1265399549.git.marcel@holtmann.org>
 <88d1a0cf659438a66135661538ae332b23f8635a.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54207 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab0BEUGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:47 -0500
In-Reply-To: <88d1a0cf659438a66135661538ae332b23f8635a.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Pelly <npelly@google.com>

When in sniff mode with a long interval time (1.28s) it can take 4+ seconds
to establish a SCO link. Fix by requesting active mode before requesting
SCO connection. This improves SCO setup time to ~500ms.

Bluetooth headsets that use a long interval time, and exhibit the long
SCO connection time include Motorola H790, HX1 and H17. They have a
CSR 2.1 chipset.

Verified this behavior and fix with host Bluetooth chipsets: BCM4329 and
TI1271.

2009-10-13 14:17:46.183722 > HCI Event: Mode Change (0x14) plen 6
    status 0x00 handle 1 mode 0x02 interval 2048
    Mode: Sniff
2009-10-13 14:17:53.436285 < HCI Command: Setup Synchronous Connection (0x01|0x0028) plen 17
    handle 1 voice setting 0x0060
2009-10-13 14:17:53.445593 > HCI Event: Command Status (0x0f) plen 4
    Setup Synchronous Connection (0x01|0x0028) status 0x00 ncmd 1
2009-10-13 14:17:57.788855 > HCI Event: Synchronous Connect Complete 0x2c) plen 17
    status 0x00 handle 257 bdaddr 00:1A:0E:F1:A4:7F type eSCO
    Air mode: CVSD

Signed-off-by: Nick Pelly <npelly@google.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_conn.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index b7c4224..b10e3cd 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -377,6 +377,9 @@ struct hci_conn *hci_connect(struct hci_dev *hdev, int type, bdaddr_t *dst, __u8
 
 	if (acl->state == BT_CONNECTED &&
 			(sco->state == BT_OPEN || sco->state == BT_CLOSED)) {
+		acl->power_save = 1;
+		hci_conn_enter_active_mode(acl);
+
 		if (lmp_esco_capable(hdev))
 			hci_setup_sync(sco, acl->handle);
 		else
-- 
1.6.6

