From: Karl Beldan <karl.beldan@gmail.com>
Subject: [PATCH] net: tso: fix unaligned access to crafted TCP header in helper API
Date: Tue, 21 Oct 2014 16:06:05 +0200
Message-ID: <1413900365-12289-1-git-send-email-karl.beldan@gmail.com>
Cc: netdev@vger.kernel.org, Karl Beldan <karl.beldan@rivierawaves.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:52214 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442AbaJUOGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 10:06:31 -0400
Received: by mail-wi0-f175.google.com with SMTP id d1so10212949wiv.14
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 07:06:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Beldan <karl.beldan@rivierawaves.com>

The crafted header start address is from a driver supplied buffer, which
one can reasonably expect to be aligned on a 4-bytes boundary.
However ATM the TSO helper API is only used by ethernet drivers and
the tcp header will then be aligned to a 2-bytes only boundary from the
header start address.

Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 net/core/tso.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/tso.c b/net/core/tso.c
index 8c3203c..630b30b 100644
--- a/net/core/tso.c
+++ b/net/core/tso.c
@@ -1,6 +1,7 @@
 #include <linux/export.h>
 #include <net/ip.h>
 #include <net/tso.h>
+#include <asm/unaligned.h>
 
 /* Calculate expected number of TX descriptors */
 int tso_count_descs(struct sk_buff *skb)
@@ -23,7 +24,7 @@ void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 	iph->id = htons(tso->ip_id);
 	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
 	tcph = (struct tcphdr *)(hdr + skb_transport_offset(skb));
-	tcph->seq = htonl(tso->tcp_seq);
+	put_unaligned_be32(tso->tcp_seq, &tcph->seq);
 	tso->ip_id++;
 
 	if (!is_last) {
-- 
2.0.1
