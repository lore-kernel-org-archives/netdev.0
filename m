From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Tue, 17 Jul 2012 23:32:49 +0200
Message-ID: <1342560769.2626.1165.camel@edumazet-glaptop>
References: <1342525290.2626.459.camel@edumazet-glaptop>
	 <CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:55738 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878Ab2GQVcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 17:32:54 -0400
Received: by gglu4 with SMTP id u4so925923ggl.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 14:32:54 -0700 (PDT)
In-Reply-To: <CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 14:02 -0700, Vijay Subramanian wrote:
> On 17 July 2012 04:41, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Implement the RFC 5691 mitigation against Blind
> > Reset attack using SYN bit.
> >
> > Section 4.2 of RFC 5961 advises to send a Challenge ACK and drop
> > incoming packet, instead of resetting the session.
> 
> Eric,
> Section 4.2 has this to say:
> "If the SYN bit is set, irrespective of the sequence number, TCP
>       MUST send an ACK (also referred to as challenge ACK) to the remote
>       peer:"
> 
> I believe your patch only sends challenge acks for in-window SYN packets.
> After this patch, the code for out of window packets is like this:
> 
>         /* Step 1: check sequence number */
>         if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)) {
>                 /* RFC793, page 37: "In all states except SYN-SENT, all reset
>                  * (RST) segments are validated by checking their SEQ-fields."
>                  * And page 69: "If an incoming segment is not acceptable,
>                  * an acknowledgment should be sent in reply (unless the RST
>                  * bit is set, if so drop the segment and return)".
>                  */
>                 if (!th->rst)
>                         tcp_send_dupack(sk, skb);
>                 goto discard;
>         }
> 
> 
> For SYN packets that are not in window, we do end up calling
> tcp_send_dupack() but not tcp_send_challenge_ack().  Will it be more
> appropriate to call the latter so that
> we do proper rate limiting of challenge acks and update SNMP counters correctly?

Well, I only wanted to avoid RST ;)

But you probably are right, we could test th->syn here as well.

Something like that ?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8aaec55..fdd49f1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5296,8 +5296,11 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 		 * an acknowledgment should be sent in reply (unless the RST
 		 * bit is set, if so drop the segment and return)".
 		 */
-		if (!th->rst)
+		if (!th->rst) {
+			if (th->syn)
+				goto syn_challenge;
 			tcp_send_dupack(sk, skb);
+		}
 		goto discard;
 	}
 
@@ -5327,6 +5330,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 	 * RFC 5691 4.2 : Send a challenge ack
 	 */
 	if (th->syn) {
+syn_challenge:
 		if (syn_inerr)
 			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNCHALLENGE);
