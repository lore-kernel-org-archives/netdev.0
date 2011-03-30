From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 2/2] atm/solos-pci: Don't include frame pseudo-header on transmit hex-dump
Date: Wed, 30 Mar 2011 16:59:26 -0600
Message-ID: <1301525966-28566-1-git-send-email-philipp_subx@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:49200 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756504Ab1C3W71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 18:59:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip A. Prindeville <philipp@redfish-solutions.com>

Omit pkt_hdr preamble when dumping transmitted packet as hex-dump;
we can pull this up because the frame has already been sent, and
dumping it is the last thing we do with it before freeing it.

Also include the size, vpi, and vci in the debug as is done on
receive.

Use "port" consistently instead of "device" intermittently.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 drivers/atm/solos-pci.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2c4146a..968f022 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -697,7 +697,7 @@ void solos_bh(unsigned long card_arg)
 					      size);
 			}
 			if (atmdebug) {
-				dev_info(&card->dev->dev, "Received: device %d\n", port);
+				dev_info(&card->dev->dev, "Received: port %d\n", port);
 				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
 					 size, le16_to_cpu(header->vpi),
 					 le16_to_cpu(header->vci));
@@ -1018,8 +1018,15 @@ static uint32_t fpga_tx(struct solos_card *card)
 
 			/* Clean up and free oldskb now it's gone */
 			if (atmdebug) {
+				struct pkt_hdr *header = (void *)oldskb->data;
+				int size = le16_to_cpu(header->size);
+
+				skb_pull(oldskb, sizeof(*header));
 				dev_info(&card->dev->dev, "Transmitted: port %d\n",
 					 port);
+				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
+					 size, le16_to_cpu(header->vpi),
+					 le16_to_cpu(header->vci));
 				print_buffer(oldskb);
 			}
 
-- 
1.7.4

