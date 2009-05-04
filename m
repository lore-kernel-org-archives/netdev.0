From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Mon, 4 May 2009 18:02:30 +0200
Message-ID: <200905041802.30527.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:36406 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbZEDQCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 12:02:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an invalid pointer access in case the receive queue holds no
pointer to the next skb when the queue is empty.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---

diff -Nurp -X dontdiff linux-2.6.30-rc4/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.30-rc4/drivers/net/ehea/ehea.h	2009-05-04 09:54:42.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2009-05-04 10:40:11.000000000 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0100"
+#define DRV_VERSION	"EHEA_0101"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.30-rc4/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.30-rc4/drivers/net/ehea/ehea_main.c	2009-05-04 09:54:42.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-05-04 10:40:11.000000000 +0200
@@ -545,14 +545,17 @@ static inline struct sk_buff *get_skb_by
 	x &= (arr_len - 1);
 
 	pref = skb_array[x];
-	prefetchw(pref);
-	prefetchw(pref + EHEA_CACHE_LINE);
+	if (pref) {
+		prefetchw(pref);
+		prefetchw(pref + EHEA_CACHE_LINE);
+
+		pref = (skb_array[x]->data);
+		prefetch(pref);
+		prefetch(pref + EHEA_CACHE_LINE);
+		prefetch(pref + EHEA_CACHE_LINE * 2);
+		prefetch(pref + EHEA_CACHE_LINE * 3);
+	}
 
-	pref = (skb_array[x]->data);
-	prefetch(pref);
-	prefetch(pref + EHEA_CACHE_LINE);
-	prefetch(pref + EHEA_CACHE_LINE * 2);
-	prefetch(pref + EHEA_CACHE_LINE * 3);
 	skb = skb_array[skb_index];
 	skb_array[skb_index] = NULL;
 	return skb;
@@ -569,12 +572,14 @@ static inline struct sk_buff *get_skb_by
 	x &= (arr_len - 1);
 
 	pref = skb_array[x];
-	prefetchw(pref);
-	prefetchw(pref + EHEA_CACHE_LINE);
-
-	pref = (skb_array[x]->data);
-	prefetchw(pref);
-	prefetchw(pref + EHEA_CACHE_LINE);
+	if (pref) {
+		prefetchw(pref);
+		prefetchw(pref + EHEA_CACHE_LINE);
+
+		pref = (skb_array[x]->data);
+		prefetchw(pref);
+		prefetchw(pref + EHEA_CACHE_LINE);
+	}
 
 	skb = skb_array[wqe_index];
 	skb_array[wqe_index] = NULL;
