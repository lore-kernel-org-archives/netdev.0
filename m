From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix inet_proto_csum_replace4() sparse errors
Date: Mon, 25 May 2015 18:50:01 -0700
Message-ID: <1432605001.4060.215.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christophe Leroy <christophe.leroy@c-s.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35186 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbbEZBuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 21:50:03 -0400
Received: by iesa3 with SMTP id a3so81942364ies.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 18:50:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

make C=2 CF=-D__CHECK_ENDIAN__ net/core/utils.o
...
net/core/utils.c:307:72: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:307:72:    expected restricted __wsum [usertype] addend
net/core/utils.c:307:72:    got restricted __be32 [usertype] from
net/core/utils.c:308:34: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:308:34:    expected restricted __wsum [usertype] addend
net/core/utils.c:308:34:    got restricted __be32 [usertype] to
net/core/utils.c:310:70: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:310:70:    expected restricted __wsum [usertype] addend
net/core/utils.c:310:70:    got restricted __be32 [usertype] from
net/core/utils.c:310:77: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:310:77:    expected restricted __wsum [usertype] addend
net/core/utils.c:310:77:    got restricted __be32 [usertype] to
net/core/utils.c:312:72: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:312:72:    expected restricted __wsum [usertype] addend
net/core/utils.c:312:72:    got restricted __be32 [usertype] from
net/core/utils.c:313:35: warning: incorrect type in argument 2 (different base types)
net/core/utils.c:313:35:    expected restricted __wsum [usertype] addend
net/core/utils.c:313:35:    got restricted __be32 [usertype] to

Note we can use csum_replace4() helper

Fixes: 58e3cac5613aa ("net: optimise inet_proto_csum_replace4()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/utils.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index 7b803884c162..a7732a068043 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -304,13 +304,15 @@ void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 			      __be32 from, __be32 to, int pseudohdr)
 {
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		*sum = csum_fold(csum_add(csum_sub(~csum_unfold(*sum), from),
-				 to));
+		csum_replace4(sum, from, to);
 		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
-			skb->csum = ~csum_add(csum_sub(~(skb->csum), from), to);
+			skb->csum = ~csum_add(csum_sub(~(skb->csum),
+						       (__force __wsum)from),
+					      (__force __wsum)to);
 	} else if (pseudohdr)
-		*sum = ~csum_fold(csum_add(csum_sub(csum_unfold(*sum), from),
-				  to));
+		*sum = ~csum_fold(csum_add(csum_sub(csum_unfold(*sum),
+						    (__force __wsum)from),
+					   (__force __wsum)to));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace4);
 
