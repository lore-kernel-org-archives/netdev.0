From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 07/15] ehea: Allocate large enough skbs to avoid partial cacheline DMA writes
Date: Fri, 14 Oct 2011 12:31:04 -0300
Message-ID: <1318606272-27647-8-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51428 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933207Ab1JNPbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:47 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqaFR010434
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:36 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZJUA3686412
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:20 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVXMg008697
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:34 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

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
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 8e7c594..7aa47d8 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
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
-- 
1.7.4.4
