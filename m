From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] net: optimise inet_proto_csum_replace4()
Date: Tue, 23 Sep 2014 10:54:37 +0200 (CEST)
Message-ID: <20140923085437.696B81AB26D@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

csum_partial() is a generic function which is not optimised for small fixed
length calculations, and its use requires to store "from" and "to" values in
memory while we already have them available in registers. This also has impact,
especially on RISC processors. In the same spirit as the change done by
Eric Dumazet on csum_replace2(), this patch rewrites inet_proto_csum_replace4()
taking into account RFC1624.

I spotted during a NATted tcp transfert that csum_partial() is one of top 5
consuming functions (around 8%), and the second user of csum_partial() is 
inet_proto_csum_replace4().

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
--
 net/core/utils.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index eed3433..efc76dd 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -306,16 +306,14 @@ EXPORT_SYMBOL(in6_pton);
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 			      __be32 from, __be32 to, int pseudohdr)
 {
-	__be32 diff[] = { ~from, to };
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		*sum = csum_fold(csum_partial(diff, sizeof(diff),
-				~csum_unfold(*sum)));
+		*sum = csum_fold(csum_add(csum_sub(~csum_unfold(*sum), from),
+				 to));
 		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
-			skb->csum = ~csum_partial(diff, sizeof(diff),
-						~skb->csum);
+			skb->csum = ~csum_add(csum_sub(~(skb->csum), from), to);
 	} else if (pseudohdr)
-		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
-				csum_unfold(*sum)));
+		*sum = ~csum_fold(csum_add(csum_sub(csum_unfold(*sum), from),
+				  to));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace4);
 
-- 
2.1.0
