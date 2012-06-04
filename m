From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_make_synack() can use alloc_skb()
Date: Mon, 04 Jun 2012 07:50:43 +0200
Message-ID: <1338789043.2760.1719.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38816 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab2FDFur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 01:50:47 -0400
Received: by wibhn6 with SMTP id hn6so2484019wib.1
        for <netdev@vger.kernel.org>; Sun, 03 Jun 2012 22:50:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is no value using sock_wmalloc() in tcp_make_synack().

A listener socket only sends SYNACK packets, they are not queued in a
socket queue, only in Qdisc and device layers, so the number of in
flight packets is limited in these layers. We used sock_wmalloc() with
the %force parameter set to 1 to ignore socket limits anyway.

This patch removes two atomic operations per SYNACK packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 803cbfe..f0b0e44 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2461,7 +2461,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER + 15 + s_data_desired, GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
