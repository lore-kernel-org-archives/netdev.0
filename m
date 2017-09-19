From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp: do rmem bulk free even if the rx sk queue is empty
Date: Tue, 19 Sep 2017 12:11:43 +0200
Message-ID: <f82856528a033394c407539d1ff4b92e243bad36.1505815819.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35560 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750747AbdISKL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 06:11:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 6b229cf77d68 ("udp: add batching to udp_rmem_release()")
reduced greatly the cacheline contention between the BH and the US
reader batching the rmem updates in most scenarios.

Such optimization is explicitly avoided if the US reader is faster
then BH processing.

My fault, I initially suggested this kind of behavior due to concerns
of possible regressions with small sk_rcvbuf values. Tests showed
such concerns are misplaced, so this commit relaxes the condition
for rmem bulk updates, obtaining small but measurable performance
gain in the scenario described above.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ef29df8648e4..784ced0b9150 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1212,8 +1212,7 @@ static void udp_rmem_release(struct sock *sk, int size, int partial,
 	if (likely(partial)) {
 		up->forward_deficit += size;
 		size = up->forward_deficit;
-		if (size < (sk->sk_rcvbuf >> 2) &&
-		    !skb_queue_empty(&up->reader_queue))
+		if (size < (sk->sk_rcvbuf >> 2))
 			return;
 	} else {
 		size += up->forward_deficit;
-- 
2.13.5
