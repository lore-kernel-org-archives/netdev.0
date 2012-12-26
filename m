From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: should drop incoming frames without ACK flag set
Date: Wed, 26 Dec 2012 14:11:54 -0800 (PST)
Message-ID: <20121226.141154.115080358245263295.davem@davemloft.net>
References: <1356541801.20133.20615.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhiyunq@umich.edu, nanditad@google.com,
	ncardwell@google.com, john.dykstra1@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2LZWL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:11:57 -0500
In-Reply-To: <1356541801.20133.20615.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Dec 2012 09:10:01 -0800

> @@ -5540,6 +5540,9 @@ no_ack:
>  	}
>  
>  slow_path:
> +	if (!th->ack)
> +			goto discard;

One too many tabs there on that last line :-)

> +
>  	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
>  		goto csum_error;
>  
> @@ -5551,7 +5554,7 @@ slow_path:


Also, I would say that this checksum test should come first, because
that takes priority since you could be testing the ACK bit of a
corrupted packet.

Better to get the statistic bump on the bad checksum then a silent
drop on the ACK being cleared.

> @@ -5984,11 +5987,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>  		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
>  			goto discard;
>  	}
> +
> +	if (!th->ack)
> +		goto discard;
> +

And that is effectively what is going to happen in this case since
the caller has already done the checksum checks.

Thanks.
