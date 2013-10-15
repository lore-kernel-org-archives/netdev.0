From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] tcp: remove the sk_can_gso() check from
 tcp_set_skb_tso_segs()
Date: Tue, 15 Oct 2013 12:24:54 -0700
Message-ID: <1381865094.2045.69.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:62742 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933495Ab3JOTYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 15:24:55 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so9277402pdj.39
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 12:24:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_can_gso() should only be used as a hint in tcp_sendmsg() to build GSO
packets in the first place. (As a performance hint)

Once we have GSO packets in write queue, we can not decide they are no
longer GSO only because flow now uses a route which doesn't handle
TSO/GSO.

Core networking stack handles the case very well for us, all we need
is keeping track of packet counts in MSS terms, regardless of
segmentation done later (in GSO or hardware)

Right now, if  tcp_fragment() splits a GSO packet in two parts,
@left and @right, and route changed through a non GSO device,
both @left and @right have pcount set to 1, which is wrong,
and leads to incorrect packet_count tracking.

This problem was added in commit d5ac99a648 ("[TCP]: skb pcount with MTU
discovery")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8fad1c1..d46f214 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -989,8 +989,7 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 	/* Make sure we own this skb before messing gso_size/gso_segs */
 	WARN_ON_ONCE(skb_cloned(skb));
 
-	if (skb->len <= mss_now || !sk_can_gso(sk) ||
-	    skb->ip_summed == CHECKSUM_NONE) {
+	if (skb->len <= mss_now || skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
