From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: should drop incoming frames without ACK flag set
Date: Wed, 26 Dec 2012 09:10:01 -0800
Message-ID: <1356541801.20133.20615.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Zhiyun Qian <zhiyunq@umich.edu>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	John Dykstra <john.dykstra1@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35268 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab2LZRKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 12:10:05 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so4995609pad.25
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 09:10:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 96e0bf4b5193d (tcp: Discard segments that ack data not yet
sent) John Dykstra enforced a check against ack sequences.

In commit 354e4aa391ed5 (tcp: RFC 5961 5.2 Blind Data Injection Attack
Mitigation) I added more safety tests.

But we missed fact that these tests are not performed if ACK bit is
not set.

RFC 793 3.9 mandates TCP should drop a frame without ACK flag set.

" fifth check the ACK field,
      if the ACK bit is off drop the segment and return"

Not doing so permits an attacker to only guess an acceptable sequence
number, evading stronger checks.

Many thanks to Zhiyun Qian for bringing this issue to our attention.

See : http://web.eecs.umich.edu/~zhiyunq/pub/ccs12_TCP_sequence_number_inference.pdf

Reported-by: Zhiyun Qian <zhiyunq@umich.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: John Dykstra <john.dykstra1@gmail.com>
---
Notes
 - I left a "if (true)" block that I'll remove in a cleanup patch in
   linux-3.9, to permit this patch being easily back-ported to stable
   branches.
 - A followup patch will be sent (in net-next) to have stronger checks
   before sending dupack

 net/ipv4/tcp_input.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a136925..903d0ef 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5540,6 +5540,9 @@ no_ack:
 	}
 
 slow_path:
+	if (!th->ack)
+			goto discard;
+
 	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
 
@@ -5551,7 +5554,7 @@ slow_path:
 		return 0;
 
 step5:
-	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
+	if (tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
 		goto discard;
 
 	/* ts_recent update must be made after we are sure that the packet
@@ -5984,11 +5987,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
 			goto discard;
 	}
+
+	if (!th->ack)
+		goto discard;
+
 	if (!tcp_validate_incoming(sk, skb, th, 0))
 		return 0;
 
 	/* step 5: check the ACK field */
-	if (th->ack) {
+	if (true) {
 		int acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH) > 0;
 
 		switch (sk->sk_state) {
@@ -6138,8 +6145,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			}
 			break;
 		}
-	} else
-		goto discard;
+	}
 
 	/* ts_recent update must be made after we are sure that the packet
 	 * is in window.
