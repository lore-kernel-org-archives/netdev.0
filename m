From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Change txhash on every SYN and RTO
 retransmit
Date: Tue, 27 Sep 2016 09:29:50 -0700
Message-ID: <1474993790.28155.60.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160927160629.1174360-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36484 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933655AbcI0Q3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:29:52 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so938665pfb.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 09:29:52 -0700 (PDT)
In-Reply-To: <20160927160629.1174360-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-27 at 09:06 -0700, Lawrence Brakmo wrote:
> The current code changes txhash (flowlables) on every retransmitted
> SYN/ACK, but only after the 2nd retransmitted SYN and only after
> tcp_retries1 RTO retransmits.
> 
> With this patch:
> 1) txhash is changed with every SYN retransmist
> 2) adds the option for the txhash to be changed before tcp_retries1
>    RTO retransmits. A new sysctl tcp_rto_txhash_prob represents the
>    probability that txhash will be changed. The default value is 0
>    which maintains previous behavior and a value of 100 will always
>    change it.

...

> @@ -213,6 +215,11 @@ static int tcp_write_timeout(struct sock *sk)
>  			tcp_mtu_probing(icsk, sk);
>  
>  			dst_negative_advice(sk);
> +		} else if (sk->sk_txhash && sysctl_tcp_rto_txhash_prob > 0) {
> +			u32 v = prandom_u32() % 100;
> +
> +			if (v < sysctl_tcp_rto_txhash_prob)
> +				sk_set_txhash(sk);
>  

Write timeouts are rare events and sk_txhash should already be set.

Also prandom_u32_max() is a bit faster (no divide, and even no multiply
for 100 which is 5*5*4, compiler can emit 2 lea instructions )

I would suggest not using all these tests and instead be very simple :

 	} else if (prandom_u32_max(100) < sysctl_tcp_rto_txhash_prob) {
		sk_set_txhash(sk);
	}

Finally, adding a new sysctl requires a Documentation update
( Documentation/networking/ip-sysctl.txt )

Thanks.
