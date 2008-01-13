From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/5] forcedeth: checksum fix
Date: Sun, 13 Jan 2008 16:02:55 -0500
Message-ID: <478A7C7F.1040207@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060602050006000700070605"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:6117 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbYANWjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:39:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060602050006000700070605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The driver should inform the stack when checksum has been performed by 
the HW when both IP and TCP (or UDP) checksum flags are indicated by HW.

Previously, it would also inform the stack when only IP checksum flag 
was indicated by HW. This can cause data corruption when IP fragments 
are used. The IP Identification field can wrap around and cause data 
from new fragments to fill into older fragment slots with same IP Id. 
The stack would then not perform TCP/UDP checksum (after re-assembly of 
all fragments) since driver falsely stated it was already calculated.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------060602050006000700070605
Content-Type: text/plain;
 name="patch-forcedeth-checksum"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-checksum"

--- old/drivers/net/forcedeth.c	2008-01-13 15:01:36.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-13 15:08:31.000000000 -0500
@@ -471,9 +471,9 @@
 #define NV_RX_AVAIL		(1<<31)
 
 #define NV_RX2_CHECKSUMMASK	(0x1C000000)
-#define NV_RX2_CHECKSUMOK1	(0x10000000)
-#define NV_RX2_CHECKSUMOK2	(0x14000000)
-#define NV_RX2_CHECKSUMOK3	(0x18000000)
+#define NV_RX2_CHECKSUM_IP	(0x10000000)
+#define NV_RX2_CHECKSUM_IP_TCP	(0x14000000)
+#define NV_RX2_CHECKSUM_IP_UDP	(0x18000000)
 #define NV_RX2_DESCRIPTORVALID	(1<<29)
 #define NV_RX2_SUBSTRACT1	(1<<25)
 #define NV_RX2_ERROR1		(1<<18)
@@ -2375,14 +2375,9 @@
 						goto next_pkt;
 					}
 				}
-				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
+				if (((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_TCP) || /*ip and tcp */
+				    ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_UDP))   /*ip and udp */
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				} else {
-					if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
-					    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
-						skb->ip_summed = CHECKSUM_UNNECESSARY;
-					}
-				}
 			} else {
 				dev_kfree_skb(skb);
 				goto next_pkt;
@@ -2474,14 +2469,9 @@
 				}
 			}
 
-			if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
+			if (((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_TCP) || /*ip and tcp */
+			    ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_UDP))   /*ip and udp */
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			} else {
-				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
-				    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				}
-			}
 
 			/* got a valid packet - forward it to the network core */
 			skb_put(skb, len);

--------------060602050006000700070605--
