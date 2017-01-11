From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: accept RST for rcv_nxt - 1 after receiving a
 FIN
Date: Wed, 11 Jan 2017 07:48:10 -0800
Message-ID: <1484149690.21472.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32978 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756366AbdAKPsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:48:12 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so9593752pgd.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 07:48:12 -0800 (PST)
In-Reply-To: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-05 at 16:33 -0500, Jason Baron wrote:

>  
> +/* Accept RST for rcv_nxt - 1 after a FIN.
> + * When tcp connections are abruptly terminated from Mac OSX (via ^C), a
> + * FIN is sent followed by a RST packet. The RST is sent with the same
> + * sequence number as the FIN, and thus according to RFC 5961 a challenge
> + * ACK should be sent. However, Mac OSX does not reply to the challenge ACK
> + * with a RST on the closed socket, hence accept this class of RSTs.
> + */
> +static bool tcp_reset_check(struct sock *sk, struct sk_buff *skb)

const struct sock *sk, const struct sk_buff *skb

> +{
> +	struct tcp_sock *tp = tcp_sk(sk);
> +
> +	return unlikely((TCP_SKB_CB(skb)->seq == (tp->rcv_nxt - 1)) &&
> +			(TCP_SKB_CB(skb)->end_seq == (tp->rcv_nxt - 1))	&&

Why is the test on end_seq needed ?

> +			(sk->sk_state == TCP_CLOSE_WAIT ||
> +			 sk->sk_state == TCP_LAST_ACK ||
> +			 sk->sk_state == TCP_CLOSING));
> +}

Testing many states can be done more efficiently :

   (1 << sk->sk_state) & (TCPF_CLOSE_WAIT | TCPF_LAST_ACK |
                          TCPF_CLOSING)

Thanks
