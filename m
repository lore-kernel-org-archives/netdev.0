From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] fix TSO FACK loss marking in tcp_mark_head_lost
Date: Fri, 24 Sep 2010 16:22:06 -0700
Message-ID: <1285370526-18279-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: ilpo.jarvinen@helsinki.fi, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:46526 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab0IXXXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 19:23:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TCP uses FACK algorithm to mark lost packets in
tcp_mark_head_lost(), if the number of packets in the (TSO) skb is
greater than the number of packets that should be marked lost, TCP
incorrectly exits the loop and marks no packets lost in the skb. This
underestimates tp->lost_out and affects the recovery/retransmission.
This patch fargments the skb and marks the correct amount of packets
lost.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1bc87a0..e4f472e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2532,7 +2532,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
 			cnt += tcp_skb_pcount(skb);
 
 		if (cnt > packets) {
-			if (tcp_is_sack(tp) || (oldcnt >= packets))
+			if ((tcp_is_sack(tp) && !tcp_is_fack(tp)) ||
+			    (oldcnt >= packets))
 				break;
 
 			mss = skb_shinfo(skb)->gso_size;
-- 
1.7.1

