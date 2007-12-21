From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [INET] Avoid an integer divide in rt_garbage_collect()
Date: Fri, 21 Dec 2007 09:20:50 +0100
Message-ID: <476B7762.30908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010309010709070404020500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48795 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbXLUIVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 03:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010309010709070404020500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Since 'goal' is a signed int, compiler may emit an integer divide
to compute goal/2.

Using a right shift is OK here and less expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010309010709070404020500
Content-Type: text/plain;
 name="route_divide.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="route_divide.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e35076e..10915bb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -851,14 +851,14 @@ static int rt_garbage_collect(void)
 			equilibrium = ipv4_dst_ops.gc_thresh;
 		goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
 		if (goal > 0) {
-			equilibrium += min_t(unsigned int, goal / 2, rt_hash_mask + 1);
+			equilibrium += min_t(unsigned int, goal >> 1, rt_hash_mask + 1);
 			goal = atomic_read(&ipv4_dst_ops.entries) - equilibrium;
 		}
 	} else {
 		/* We are in dangerous area. Try to reduce cache really
 		 * aggressively.
 		 */
-		goal = max_t(unsigned int, goal / 2, rt_hash_mask + 1);
+		goal = max_t(unsigned int, goal >> 1, rt_hash_mask + 1);
 		equilibrium = atomic_read(&ipv4_dst_ops.entries) - goal;
 	}
 

--------------010309010709070404020500--
