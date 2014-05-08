From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP CLOSE_WAIT unacceptable ACK behavior and RFC 793 compliance
Date: Thu, 8 May 2014 15:20:45 -0400
Message-ID: <CADVnQy=cw6Z+8tTUHp6-b0+0M6iPar+VFTZAc+sgfm8tpZbQ2A@mail.gmail.com>
References: <c95895f13e2adae32cc9a23bf9ccf96b.squirrel@squirrel.science.ru.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Frits Vaandrager <f.vaandrager@cs.ru.nl>
To: P.Fiterau-Brostean@science.ru.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:46665 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325AbaEHTUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 15:20:46 -0400
Received: by mail-we0-f177.google.com with SMTP id x48so2875658wes.8
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 12:20:45 -0700 (PDT)
In-Reply-To: <c95895f13e2adae32cc9a23bf9ccf96b.squirrel@squirrel.science.ru.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 1:13 PM,  <P.Fiterau-Brostean@science.ru.nl> wrote:
> In short, when the SERVER is in CLOSE_WAIT state and the CLIENT sends an
> ACK  (or a FIN+ACK) with a valid seq number but an unacceptable ack
> number, the SERVER either responds with an ACK (re-transmission of last
> ACK sent by the server) or it doesn't respond at all. I attached a capture

Yes, this does not seem to match the RFC.

Have you tried this scenario with SEG.ACK > SND.NXT in other states,
e.g. ESTABLISHED?

Have you checked what other OSes do?

Here would be a proposed change, if we decide to send an ACK instead
of dropping (please excuse the formatting; for the real patch I'd use
git send-email...):

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6b46eb..08f2f55 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3383,11 +3383,15 @@ static int tcp_ack(...
                goto old_ack;
        }

-       /* If the ack includes data we haven't sent yet, discard
-        * this segment (RFC793 Section 3.9).
+       /* "If the ACK acks something not yet sent (SEG.ACK > SND.NXT)
+         * then send an ACK, drop the segment, and return." (RFC793
+         * Section 3.9, p. 72).
         */
-       if (after(ack, tp->snd_nxt))
+       if (after(ack, tp->snd_nxt)) {
+               /* RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation] */
+               tcp_send_challenge_ack(sk);
                goto invalid_ack;
+       }

        if (icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
            icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)

I am playing with that.

neal

---

BTW, here is a packetdrill test case to reproduce this scenario:

// Set up a server listening socket.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

// Establish connection
+0    < S 0:0(0) win 32792 <mss 1460,nop,nop,sackOK>
+0    > S. 0:0(0) ack 1    <mss 1460,nop,nop,sackOK>
+.010 < . 1:1(0) ack 1 win 32792

+0 accept(3, ..., ...) = 4

+.010 < F. 1:1(0) ack 1 win 32792
+0    > . 1:1(0) ack 2
+.010 < . 2:2(0) ack 500 win 32792
