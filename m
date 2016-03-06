From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix tcpi_segs_in after connection establishment
Date: Sun, 06 Mar 2016 09:29:21 -0800
Message-ID: <1457285361.2663.24.camel@edumazet-ThinkPad-T530>
References: <1457135853-4110588-1-git-send-email-kafai@fb.com>
	 <1457138013.2761.12.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33555 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbcCFR3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 12:29:24 -0500
Received: by mail-pf0-f193.google.com with SMTP id 63so6560447pfe.0
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 09:29:24 -0800 (PST)
In-Reply-To: <1457138013.2761.12.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If final packet (ACK) of 3WHS is lost, it appears we do not properly
account the following incoming segment into tcpi_segs_in

While we are at it, starts segs_in with one, to count the SYN packet.

We do not yet count number of SYN we received for a request sock, we
might add this someday.

packetdrill script showing proper behavior after fix :

// Tests tcpi_segs_in when 3rd packet (ACK) of 3WHS is lost
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
+.020 < P. 1:1001(1000) ack 1 win 32792

   +0 accept(3, ..., ...) = 4

+.000 %{ assert tcpi_segs_in == 2, 'tcpi_segs_in=%d' % tcpi_segs_in }%

Fixes: 2efd055c53c06 ("tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_minisocks.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 75632a925824..9b02af2139d3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -455,7 +455,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->rcv_wup = newtp->copied_seq =
 		newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->segs_in = 0;
+		newtp->segs_in = 1;
 
 		newtp->snd_sml = newtp->snd_una =
 		newtp->snd_nxt = newtp->snd_up = treq->snt_isn + 1;
@@ -815,6 +815,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	int ret = 0;
 	int state = child->sk_state;
 
+	tcp_sk(child)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
 	if (!sock_owned_by_user(child)) {
 		ret = tcp_rcv_state_process(child, skb);
 		/* Wakeup parent, send SIGIO */
