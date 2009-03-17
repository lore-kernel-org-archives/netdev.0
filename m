From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 01/30] solos: Fix length header in FPGA transfers
Date: Tue, 17 Mar 2009 21:29:02 +0000
Message-ID: <1237325342.27681.330.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37649 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbZCQV3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:07 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1LjgqN-0001uY-RC
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:04 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The length field shouldn't ever include the size of the header itself.
This fixes the problem that some people were seeing with 1500-byte
packets.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 72fc0f7..f030954 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -356,7 +356,7 @@ static int popen(struct atm_vcc *vcc)
 	}
 	header = (void *)skb_put(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(sizeof(*header));
+	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_POPEN);
@@ -389,7 +389,7 @@ static void pclose(struct atm_vcc *vcc)
 	}
 	header = (void *)skb_put(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(sizeof(*header));
+	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_PCLOSE);
@@ -507,6 +507,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct solos_card *card = vcc->dev->dev_data;
 	struct sk_buff *skb2 = NULL;
 	struct pkt_hdr *header;
+	int pktlen;
 
 	//dev_dbg(&card->dev->dev, "psend called.\n");
 	//dev_dbg(&card->dev->dev, "dev,vpi,vci = %d,%d,%d\n",SOLOS_CHAN(vcc->dev),vcc->vpi,vcc->vci);
@@ -524,7 +525,8 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (skb->len > (BUF_SIZE - sizeof(*header))) {
+	pktlen = skb->len;
+	if (pktlen > (BUF_SIZE - sizeof(*header))) {
 		dev_warn(&card->dev->dev, "Length of PDU is too large. Dropping PDU.\n");
 		solos_pop(vcc, skb);
 		return 0;
@@ -546,7 +548,8 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	header = (void *)skb_push(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(skb->len);
+	/* This does _not_ include the size of the header */
+	header->size = cpu_to_le16(pktlen);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_DATA);
-- 
1.6.0.6


