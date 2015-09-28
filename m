From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] net: help compiler generate better code in
 eth_get_headlen
Date: Mon, 28 Sep 2015 12:47:14 +0200
Message-ID: <20150928104713.12016.65491.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297AbbI1KrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 06:47:15 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id C7FDCAC1A1
	for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:47:15 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed that the compiler (gcc version 4.8.5 20150623 (Red Hat 4.8.5-4) (GCC))
generated suboptimal assembler code in eth_get_headlen().

This early return coding style is usually not an issue, on super scalar CPUs,
but the compiler choose to put the return statement after this very unlikely
branch, thus creating larger jump down to the likely code path.

Performance wise, I could measure slightly less L1-icache-load-misses
and less branch-misses, and an improvement of 1 nanosec with an IP-forwarding
use-case with 257 bytes packets with ixgbe (CPU i7-4790K @ 4.00GHz).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ethernet/eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index d850fdc828f9..9e63f252a89e 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -127,7 +127,7 @@ u32 eth_get_headlen(void *data, unsigned int len)
 	struct flow_keys keys;
 
 	/* this should never happen, but better safe than sorry */
-	if (len < sizeof(*eth))
+	if (unlikely(len < sizeof(*eth)))
 		return len;
 
 	/* parse any remaining L2/L3 headers, check for L4 */
