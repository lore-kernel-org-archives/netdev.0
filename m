From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Thu, 26 Mar 2009 07:52:39 +0100
Message-ID: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:60641 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbZCZHPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 03:15:50 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 33CEBDA79
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 06:51:58 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6A3B54BDAC
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 06:53:00 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move in memory all the frames with an incorrect alignment.
This is to prevent unaligned memory accesses into the upper layers.
Note 1: this is a penalty for some architecture like SH.
Note 2: indeed, this patch restores an old one posted three years ago
(http://marc.info/?l=linux-usb-devel&m=116578791817830&w=2).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/usb/asix.c |   42 ++++++++++++++++++++++++------------------
 1 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 396f821..cea98be 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -298,26 +298,37 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 
 static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	u8  *head;
-	u32  header;
-	char *packet;
-	struct sk_buff *ax_skb;
-	u16 size;
-
-	head = (u8 *) skb->data;
-	memcpy(&header, head, sizeof(header));
+	unsigned int header;
+
+	memcpy(&header, skb->data, sizeof(header));
 	le32_to_cpus(&header);
-	packet = head + sizeof(header);
 
 	skb_pull(skb, 4);
 
 	while (skb->len > 0) {
+		struct sk_buff *ax_skb;
+		unsigned int size;
+		int offset;
+
 		if ((short)(header & 0x0000ffff) !=
 		    ~((short)((header & 0xffff0000) >> 16))) {
 			deverr(dev,"asix_rx_fixup() Bad Header Length");
 		}
+
 		/* get the packet length */
-		size = (u16) (header & 0x0000ffff);
+		size = header & 0x0000ffff;
+
+		/* Move in memory frames with incorrect alignment.
+		 * This is to prevent unaligned memory accesses into
+		 * the upper layers. */
+		offset = NET_IP_ALIGN ? ((unsigned long)skb->data -
+			 NET_IP_ALIGN) & 3 : 0;
+
+		if (offset) {
+			skb->data -= offset;
+			skb->tail -= offset;
+			memmove(skb->data - offset, skb->data, skb->len);
+		}
 
 		if ((skb->len) - ((size + 1) & 0xfffe) == 0)
 			return 2;
@@ -327,23 +338,18 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		}
 		ax_skb = skb_clone(skb, GFP_ATOMIC);
 		if (ax_skb) {
-			ax_skb->len = size;
-			ax_skb->data = packet;
-			skb_set_tail_pointer(ax_skb, size);
+			skb_trim(ax_skb, size);
 			usbnet_skb_return(dev, ax_skb);
-		} else {
+		} else
 			return 0;
-		}
 
 		skb_pull(skb, (size + 1) & 0xfffe);
 
 		if (skb->len == 0)
 			break;
 
-		head = (u8 *) skb->data;
-		memcpy(&header, head, sizeof(header));
+		memcpy(&header, skb->data, sizeof(header));
 		le32_to_cpus(&header);
-		packet = head + sizeof(header);
 		skb_pull(skb, 4);
 	}
 
-- 
1.6.0.6

