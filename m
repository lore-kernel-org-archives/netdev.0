From: Florian Zumbiehl <florz@gmx.de>
Subject: [PATCH 1/3] PPPoE: improved hashing routine
Date: Tue, 13 Mar 2007 15:52:18 +0100
Message-ID: <20070313145218.GN17712@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: mostrows@earthlink.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf9ce.pool.mediaWays.net ([217.187.249.206]:2794 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030736AbXCMPDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 11:03:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm not sure whether this is really worth it, but it looked so
extremely inefficient that I couldn't resist - so let's hope providers
will keep PPPoE around for a while, at least until terabit dsl ;-)

The new code produces the same results as the old version and is
~ 3 to 6 times faster for 4-bit hashes on the CPUs I tested.

Florian

---------------------------------------------------------------------------
Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 9e51fcc..954328c 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -108,19 +108,24 @@ static inline int cmp_addr(struct pppoe_addr *a, unsigned long sid, char *addr)
 		(memcmp(a->remote,addr,ETH_ALEN) == 0));
 }
 
-static int hash_item(unsigned long sid, unsigned char *addr)
+#if 8%PPPOE_HASH_BITS
+#error 8 must be a multiple of PPPOE_HASH_BITS
+#endif
+
+static int hash_item(unsigned int sid, unsigned char *addr)
 {
-	char hash = 0;
-	int i, j;
+	unsigned char hash = 0;
+	unsigned int i;
 
-	for (i = 0; i < ETH_ALEN ; ++i) {
-		for (j = 0; j < 8/PPPOE_HASH_BITS ; ++j) {
-			hash ^= addr[i] >> ( j * PPPOE_HASH_BITS );
-		}
+	for (i = 0 ; i < ETH_ALEN ; i++) {
+		hash ^= addr[i];
+	}
+	for (i = 0 ; i < sizeof(sid_t)*8 ; i += 8 ){
+		hash ^= sid>>i;
+	}
+	for (i = 8 ; (i>>=1) >= PPPOE_HASH_BITS ; ) {
+		hash ^= hash>>i;
 	}
-
-	for (i = 0; i < (sizeof(unsigned long)*8) / PPPOE_HASH_BITS ; ++i)
-		hash ^= sid >> (i*PPPOE_HASH_BITS);
 
 	return hash & ( PPPOE_HASH_SIZE - 1 );
 }
