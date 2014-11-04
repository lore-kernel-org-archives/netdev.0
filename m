From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue,  4 Nov 2014 12:18:44 -0200
Message-ID: <66a8a101a2bfe645432ec393d22b9da44b9739cf.1415110605.git.mleitner@redhat.com>
Cc: ncardwell@google.com, ycheng@google.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbaKDOSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 09:18:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ueki Kohei reported that when we are using NewReno with connections that
have a very low traffic, we may timeout the connection too early if a
second loss occurs after the first one was successfully acked but no
data was transfered later. Below is his description of it:

When SACK is disabled, and a socket suffers multiple separate TCP
retransmissions, that socket's ETIMEDOUT value is calculated from the
time of the *first* retransmission instead of the *latest*
retransmission.

This happens because the tcp_sock's retrans_stamp is set once then never
cleared.

Take the following connection:

                      Linux                    remote-machine
                        |                           |
         send#1---->(*1)|--------> data#1 --------->|
                  |     |                           |
                 RTO    :                           :
                  |     |                           |
                 ---(*2)|----> data#1(retrans) ---->|
                  | (*3)|<---------- ACK <----------|
                  |     |                           |
                  |     :                           :
                  |     :                           :
                  |     :                           :
                16 minutes (or more)                :
                  |     :                           :
                  |     :                           :
                  |     :                           :
                  |     |                           |
         send#2---->(*4)|--------> data#2 --------->|
                  |     |                           |
                 RTO    :                           :
                  |     |                           |
                 ---(*5)|----> data#2(retrans) ---->|
                  |     |                           |
                  |     |                           |
                RTO*2   :                           :
                  |     |                           |
                  |     |                           |
      ETIMEDOUT<----(*6)|                           |

(*1) One data packet sent.
(*2) Because no ACK packet is received, the packet is retransmitted.
(*3) The ACK packet is received. The transmitted packet is acknowledged.

At this point the first "retransmission event" has passed and been
recovered from. Any future retransmission is a completely new "event".

(*4) After 16 minutes (to correspond with retries2=15), a new data
packet is sent. Note: No data is transmitted between (*3) and (*4).

The socket's timeout SHOULD be calculated from this point in time, but
instead it's calculated from the prior "event" 16 minutes ago.

(*5) Because no ACK packet is received, the packet is retransmitted.
(*6) At the time of the 2nd retransmission, the socket returns
ETIMEDOUT.


Therefore, now we clear retrans_stamp as soon as all data during the
loss window is fully acked.

Reported-by: Ueki Kohei
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 net/ipv4/tcp_input.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455928e52211efdc6b471ef54de6218f5df0..65686efeaaf3c36706390d3bfd260fd1fb942b7f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2410,6 +2410,8 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 		 * is ACKed. For Reno it is MUST to prevent false
 		 * fast retransmits (RFC2582). SACK TCP is safe. */
 		tcp_moderate_cwnd(tp);
+		if (!tcp_any_retrans_done(sk))
+			tp->retrans_stamp = 0;
 		return true;
 	}
 	tcp_set_ca_state(sk, TCP_CA_Open);
-- 
1.9.3
