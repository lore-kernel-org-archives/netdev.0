From: Jason Baron <jbaron@akamai.com>
Subject: Re: [RFC PATCH] tcp: accept RST for rcv_nxt - 1 after receiving a FIN
Date: Fri, 13 Jan 2017 12:28:19 -0500
Message-ID: <10070e29-2278-8df4-4abb-61a16895dfa4@akamai.com>
References: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
 <1484149690.21472.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:57750 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750885AbdAMR2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:28:20 -0500
In-Reply-To: <1484149690.21472.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2017 10:48 AM, Eric Dumazet wrote:

> On Thu, 2017-01-05 at 16:33 -0500, Jason Baron wrote:
>
>>  
>> +/* Accept RST for rcv_nxt - 1 after a FIN.
>> + * When tcp connections are abruptly terminated from Mac OSX (via ^C), a
>> + * FIN is sent followed by a RST packet. The RST is sent with the same
>> + * sequence number as the FIN, and thus according to RFC 5961 a challenge
>> + * ACK should be sent. However, Mac OSX does not reply to the challenge ACK
>> + * with a RST on the closed socket, hence accept this class of RSTs.
>> + */
>> +static bool tcp_reset_check(struct sock *sk, struct sk_buff *skb)
> const struct sock *sk, const struct sk_buff *skb
>
>> +{
>> +	struct tcp_sock *tp = tcp_sk(sk);
>> +
>> +	return unlikely((TCP_SKB_CB(skb)->seq == (tp->rcv_nxt - 1)) &&
>> +			(TCP_SKB_CB(skb)->end_seq == (tp->rcv_nxt - 1))	&&
> Why is the test on end_seq needed ?

Hi,

(Re-sending - seems like my reply was lost)

I wanted to define this condition as narrowly as I could. I'm ok
dropping it -
I'm not sure its going to make much difference in practice. So to that end,
dropping this extra check makes sense.

I posted this as RFC because RFC 5961, I don't think says anything about
accepting rcv_nxt - 1 in this case, so I was wondering what people
thought...

Thanks,

-Jason

>> +			(sk->sk_state == TCP_CLOSE_WAIT ||
>> +			 sk->sk_state == TCP_LAST_ACK ||
>> +			 sk->sk_state == TCP_CLOSING));
>> +}
> Testing many states can be done more efficiently :
>
>    (1 << sk->sk_state) & (TCPF_CLOSE_WAIT | TCPF_LAST_ACK |
>                           TCPF_CLOSING)
>
> Thanks
>
