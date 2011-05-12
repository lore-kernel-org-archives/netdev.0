From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 07/15] ehea: Allocate large enough skbs to avoid partial cacheline DMA writes
Date: Thu, 12 May 2011 10:52:20 +1000
Message-ID: <20110512005623.100278010@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57638 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754979Ab1ELB16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:27:58 -0400
Content-Disposition: inline; filename=ehea_8.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ehea adapter has a mode where it will avoid partial cacheline DMA
writes on receive by always padding packets to fall on a cacheline
boundary.

Unfortunately we currently aren't allocating enough space for a full
ethernet MTU packet to be rounded up, so this optimisation doesn't hit.

It's unfortunate that the next largest packet size exposed by the
hypervisor interface is 2kB, meaning our skb allocation comes out of a
4kB SLAB. However the performance increase due to this optimisation is
quite large and my TCP stream numbers increase from 900MB to 1000MB/sec.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea.h	2011-05-12 07:47:53.490177714 +1000
+++ linux-net/drivers/net/ehea/ehea.h	2011-05-12 07:47:56.980233047 +1000
@@ -82,7 +82,7 @@
 #define EHEA_SG_RQ3 0
 
 #define EHEA_MAX_PACKET_SIZE    9022	/* for jumbo frames */
-#define EHEA_RQ2_PKT_SIZE       1522
+#define EHEA_RQ2_PKT_SIZE       2048
 #define EHEA_L_PKT_SIZE         256	/* low latency */
 
 #define MAX_LRO_DESCRIPTORS 8
@@ -93,7 +93,7 @@
 #define EHEA_PD_ID        0xaabcdeff
 
 #define EHEA_RQ2_THRESHOLD 	   1
-#define EHEA_RQ3_THRESHOLD 	   9	/* use RQ3 threshold of 1522 bytes */
+#define EHEA_RQ3_THRESHOLD	   4	/* use RQ3 threshold of 2048 bytes */
 
 #define EHEA_SPEED_10G         10000
 #define EHEA_SPEED_1G           1000


