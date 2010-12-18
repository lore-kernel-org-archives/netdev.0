From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 3/3] igb: example of how to update igb to make use of
	in-kernel Toeplitz hashing
Date: Fri, 17 Dec 2010 17:00:48 -0800
Message-ID: <20101218010048.28602.49776.stgit@gitlad.jf.intel.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50446 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756381Ab0LRBAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 20:00:50 -0500
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id oBI10mvD028795
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 17:00:48 -0800
In-Reply-To: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows igb to make use of the in-kernel Toeplitz hashing so
that RX and TX hash queues can be matched up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igb/igb_main.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 72a2fad..9e6a437 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -45,6 +45,7 @@
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/aer.h>
+#include <linux/toeplitz.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
@@ -1691,6 +1692,7 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
 	.ndo_start_xmit		= igb_xmit_frame_adv,
+	.ndo_select_queue	= toeplitz_select_queue,
 	.ndo_get_stats64	= igb_get_stats64,
 	.ndo_set_rx_mode	= igb_set_rx_mode,
 	.ndo_set_multicast_list	= igb_set_rx_mode,
@@ -2660,19 +2662,14 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 		u32 dword;
 		u8  bytes[4];
 	} reta;
-	static const u8 rsshash[40] = {
-		0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2, 0x41, 0x67,
-		0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0, 0xd0, 0xca, 0x2b, 0xcb,
-		0xae, 0x7b, 0x30, 0xb4,	0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30,
-		0xf2, 0x0c, 0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa };
 
 	/* Fill out hash function seeds */
 	for (j = 0; j < 10; j++) {
-		u32 rsskey = rsshash[(j * 4)];
-		rsskey |= rsshash[(j * 4) + 1] << 8;
-		rsskey |= rsshash[(j * 4) + 2] << 16;
-		rsskey |= rsshash[(j * 4) + 3] << 24;
-		array_wr32(E1000_RSSRK(0), j, rsskey);
+		u32 toeplitz_key = (u32)toeplitz_get_key_byte((4 * j));
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * j) + 1) << 8;
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * j) + 2) << 16;
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * j) + 3) << 24;
+		array_wr32(E1000_RSSRK(0), j, toeplitz_key);
 	}
 
 	num_rx_queues = adapter->rss_queues;
@@ -2700,8 +2697,9 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 			shift = 6;
 	}
 
-	for (j = 0; j < (32 * 4); j++) {
-		reta.bytes[j & 3] = (j % num_rx_queues) << shift;
+	for (j = 0; j < 128; j++) {
+		u32 entry = ((j * num_rx_queues) & 0xFF80) >> 7;
+		reta.bytes[j & 3] = entry << shift;
 		if (shift2)
 			reta.bytes[j & 3] |= num_rx_queues << shift2;
 		if ((j & 3) == 3)

