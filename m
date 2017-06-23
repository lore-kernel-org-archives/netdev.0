From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp: fix poll()
Date: Fri, 23 Jun 2017 14:19:51 +0200
Message-ID: <00735477ae8ffcc075e382ab45f6568ab158a0bf.1498220186.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Michael Ellerman <mpe@ellerman.id.au>,
        linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750932AbdFWMUW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 08:20:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael reported an UDP breakage caused by the commit b65ac44674dd
("udp: try to avoid 2 cache miss on dequeue").
The function __first_packet_length() can update the checksum bits
of the pending skb, making the scratched area out-of-sync, and
setting skb->csum, if the skb was previously in need of checksum
validation.

On later recvmsg() for such skb, checksum validation will be
invoked again - due to the wrong udp_skb_csum_unnecessary()
value - and will fail, causing the valid skb to be dropped.

This change addresses the issue refreshing the scratch area in
__first_packet_length() after the possible checksum update.

Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
Reported-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 067a607..47c7aa0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1446,16 +1446,23 @@ static struct sk_buff *__first_packet_length(struct sock *sk,
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(rcvq)) != NULL &&
-	       udp_lib_checksum_complete(skb)) {
-		__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
-				IS_UDPLITE(sk));
-		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
-				IS_UDPLITE(sk));
-		atomic_inc(&sk->sk_drops);
-		__skb_unlink(skb, rcvq);
-		*total += skb->truesize;
-		kfree_skb(skb);
+	while ((skb = skb_peek(rcvq)) != NULL) {
+		if (udp_lib_checksum_complete(skb)) {
+			__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
+					IS_UDPLITE(sk));
+			__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
+					IS_UDPLITE(sk));
+			atomic_inc(&sk->sk_drops);
+			__skb_unlink(skb, rcvq);
+			*total += skb->truesize;
+			kfree_skb(skb);
+		} else {
+			/* the csum related bits could be changed, refresh
+			 * the scratch area
+			 */
+			udp_set_dev_scratch(skb);
+			break;
+		}
 	}
 	return skb;
 }
-- 
2.9.4
