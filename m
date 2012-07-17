From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Tue, 17 Jul 2012 14:02:45 -0700
Message-ID: <CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
References: <1342525290.2626.459.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:60512 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248Ab2GQVCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 17:02:46 -0400
Received: by ghrr11 with SMTP id r11so896579ghr.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 14:02:46 -0700 (PDT)
In-Reply-To: <1342525290.2626.459.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 July 2012 04:41, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Implement the RFC 5691 mitigation against Blind
> Reset attack using SYN bit.
>
> Section 4.2 of RFC 5961 advises to send a Challenge ACK and drop
> incoming packet, instead of resetting the session.

Eric,
Section 4.2 has this to say:
"If the SYN bit is set, irrespective of the sequence number, TCP
      MUST send an ACK (also referred to as challenge ACK) to the remote
      peer:"

I believe your patch only sends challenge acks for in-window SYN packets.
After this patch, the code for out of window packets is like this:

        /* Step 1: check sequence number */
        if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)) {
                /* RFC793, page 37: "In all states except SYN-SENT, all reset
                 * (RST) segments are validated by checking their SEQ-fields."
                 * And page 69: "If an incoming segment is not acceptable,
                 * an acknowledgment should be sent in reply (unless the RST
                 * bit is set, if so drop the segment and return)".
                 */
                if (!th->rst)
                        tcp_send_dupack(sk, skb);
                goto discard;
        }


For SYN packets that are not in window, we do end up calling
tcp_send_dupack() but not tcp_send_challenge_ack().  Will it be more
appropriate to call the latter so that
we do proper rate limiting of challenge acks and update SNMP counters correctly?

Thanks,
Vijay
