From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/4] forcedeth: fix rx error policy
Date: Wed, 06 Aug 2008 12:11:03 -0400
Message-ID: <4899CD17.4030105@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050603060602090808000808"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:10449 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbYHFTTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:19:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050603060602090808000808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch enforces a stricter policy on rx errors. The driver needs to 
verify whether there are multiple rx errors versus a single error.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050603060602090808000808
Content-Type: text/plain;
 name="patch-forcedeth-errors"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-errors"

--- old/drivers/net/forcedeth.c	2008-08-06 11:18:30.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-08-06 11:18:19.000000000 -0400
@@ -402,6 +402,7 @@
 #define NV_RX_FRAMINGERR	(1<<29)
 #define NV_RX_ERROR		(1<<30)
 #define NV_RX_AVAIL		(1<<31)
+#define NV_RX_ERROR_MASK	(NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3|NV_RX_ERROR4|NV_RX_CRCERR|NV_RX_OVERFLOW|NV_RX_FRAMINGERR)
 
 #define NV_RX2_CHECKSUMMASK	(0x1C000000)
 #define NV_RX2_CHECKSUM_IP	(0x10000000)
@@ -419,6 +420,7 @@
 /* error and avail are the same for both */
 #define NV_RX2_ERROR		(1<<30)
 #define NV_RX2_AVAIL		(1<<31)
+#define NV_RX2_ERROR_MASK	(NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3|NV_RX2_ERROR4|NV_RX2_CRCERR|NV_RX2_OVERFLOW|NV_RX2_FRAMINGERR)
 
 #define NV_RX3_VLAN_TAG_PRESENT (1<<16)
 #define NV_RX3_VLAN_TAG_MASK	(0x0000FFFF)
@@ -2632,7 +2634,7 @@
 			if (likely(flags & NV_RX_DESCRIPTORVALID)) {
 				len = flags & LEN_MASK_V1;
 				if (unlikely(flags & NV_RX_ERROR)) {
-					if (flags & NV_RX_ERROR4) {
+					if ((flags & NV_RX_ERROR_MASK) == NV_RX_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
 						if (len < 0) {
 							dev->stats.rx_errors++;
@@ -2641,7 +2643,7 @@
 						}
 					}
 					/* framing errors are soft errors */
-					else if (flags & NV_RX_FRAMINGERR) {
+					else if ((flags & NV_RX_ERROR_MASK) == NV_RX_FRAMINGERR) {
 						if (flags & NV_RX_SUBSTRACT1) {
 							len--;
 						}
@@ -2667,7 +2669,7 @@
 			if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
 				len = flags & LEN_MASK_V2;
 				if (unlikely(flags & NV_RX2_ERROR)) {
-					if (flags & NV_RX2_ERROR4) {
+					if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
 						if (len < 0) {
 							dev->stats.rx_errors++;
@@ -2676,7 +2678,7 @@
 						}
 					}
 					/* framing errors are soft errors */
-					else if (flags & NV_RX2_FRAMINGERR) {
+					else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
 						if (flags & NV_RX2_SUBSTRACT1) {
 							len--;
 						}
@@ -2766,7 +2768,7 @@
 		if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
 			len = flags & LEN_MASK_V2;
 			if (unlikely(flags & NV_RX2_ERROR)) {
-				if (flags & NV_RX2_ERROR4) {
+				if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_ERROR4) {
 					len = nv_getlen(dev, skb->data, len);
 					if (len < 0) {
 						dev_kfree_skb(skb);
@@ -2774,7 +2776,7 @@
 					}
 				}
 				/* framing errors are soft errors */
-				else if (flags & NV_RX2_FRAMINGERR) {
+				else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
 					if (flags & NV_RX2_SUBSTRACT1) {
 						len--;
 					}

--------------050603060602090808000808--
