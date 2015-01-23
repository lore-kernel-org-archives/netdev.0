From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: udp_diag: Fix socket skipping within chain
Date: Sat, 24 Jan 2015 08:02:40 +1100
Message-ID: <20150123210240.GA1569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54002 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbAWVDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 16:03:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on rhashtable walking I noticed that the UDP diag
dumping code is buggy.  In particular, the socket skipping within
a chain never happens, even though we record the number of sockets
that should be skipped.

As this code was supposedly copied from TCP, this patch does what
TCP does and resets num before we walk a chain.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 7927db0..4a000f1 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -99,11 +99,13 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlin
 	s_slot = cb->args[0];
 	num = s_num = cb->args[1];
 
-	for (slot = s_slot; slot <= table->mask; num = s_num = 0, slot++) {
+	for (slot = s_slot; slot <= table->mask; s_num = 0, slot++) {
 		struct sock *sk;
 		struct hlist_nulls_node *node;
 		struct udp_hslot *hslot = &table->hash[slot];
 
+		num = 0;
+
 		if (hlist_nulls_empty(&hslot->head))
 			continue;
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
