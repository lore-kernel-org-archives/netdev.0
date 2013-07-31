From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 03/12] tile: remove dead is_dup_ack() function from tilepro net driver
Date: Wed, 31 Jul 2013 11:05:04 -0400
Message-ID: <aa47cdfb2b518c7e56798ec5863c735c60d88eb2.1375283105.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<cover.1375283104.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:31240 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297Ab3GaPVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:21:43 -0400
In-Reply-To: <cover.1375283104.git.cmetcalf@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c | 76 -------------------------------------
 1 file changed, 76 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index cb67df7..ba40ecd 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -93,9 +93,6 @@
 /* ISSUE: This may actually hurt performance of the TCP blaster. */
 /* #define TILE_NET_GSO */
 
-/* Define this to collapse "duplicate" acks. */
-/* #define IGNORE_DUP_ACKS */
-
 /* HACK: Define this to verify incoming packets. */
 /* #define TILE_NET_VERIFY_INGRESS */
 
@@ -629,79 +626,6 @@ static void tile_net_handle_egress_timer(unsigned long arg)
 }
 
 
-#ifdef IGNORE_DUP_ACKS
-
-/*
- * Help detect "duplicate" ACKs.  These are sequential packets (for a
- * given flow) which are exactly 66 bytes long, sharing everything but
- * ID=2@0x12, Hsum=2@0x18, Ack=4@0x2a, WinSize=2@0x30, Csum=2@0x32,
- * Tstamps=10@0x38.  The ID's are +1, the Hsum's are -1, the Ack's are
- * +N, and the Tstamps are usually identical.
- *
- * NOTE: Apparently truly duplicate acks (with identical "ack" values),
- * should not be collapsed, as they are used for some kind of flow control.
- */
-static bool is_dup_ack(char *s1, char *s2, unsigned int len)
-{
-	int i;
-
-	unsigned long long ignorable = 0;
-
-	/* Identification. */
-	ignorable |= (1ULL << 0x12);
-	ignorable |= (1ULL << 0x13);
-
-	/* Header checksum. */
-	ignorable |= (1ULL << 0x18);
-	ignorable |= (1ULL << 0x19);
-
-	/* ACK. */
-	ignorable |= (1ULL << 0x2a);
-	ignorable |= (1ULL << 0x2b);
-	ignorable |= (1ULL << 0x2c);
-	ignorable |= (1ULL << 0x2d);
-
-	/* WinSize. */
-	ignorable |= (1ULL << 0x30);
-	ignorable |= (1ULL << 0x31);
-
-	/* Checksum. */
-	ignorable |= (1ULL << 0x32);
-	ignorable |= (1ULL << 0x33);
-
-	for (i = 0; i < len; i++, ignorable >>= 1) {
-
-		if ((ignorable & 1) || (s1[i] == s2[i]))
-			continue;
-
-#ifdef TILE_NET_DEBUG
-		/* HACK: Mention non-timestamp diffs. */
-		if (i < 0x38 && i != 0x2f &&
-		    net_ratelimit())
-			pr_info("Diff at 0x%x\n", i);
-#endif
-
-		return false;
-	}
-
-#ifdef TILE_NET_NO_SUPPRESS_DUP_ACKS
-	/* HACK: Do not suppress truly duplicate ACKs. */
-	/* ISSUE: Is this actually necessary or helpful? */
-	if (s1[0x2a] == s2[0x2a] &&
-	    s1[0x2b] == s2[0x2b] &&
-	    s1[0x2c] == s2[0x2c] &&
-	    s1[0x2d] == s2[0x2d]) {
-		return false;
-	}
-#endif
-
-	return true;
-}
-
-#endif
-
-
-
 static void tile_net_discard_aux(struct tile_net_cpu *info, int index)
 {
 	struct tile_netio_queue *queue = &info->queue;
-- 
1.8.3.1
