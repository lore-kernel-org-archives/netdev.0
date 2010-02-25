From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Thu, 25 Feb 2010 00:31:24 -0800 (PST)
Message-ID: <20100225.003124.183011848.davem@davemloft.net>
References: <1267067593.16986.1583.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751192Ab0BYIbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 03:31:09 -0500
In-Reply-To: <1267067593.16986.1583.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 25 Feb 2010 11:13:13 +0800

> @@ -1372,8 +1372,13 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  	bh_lock_sock(sk);
>  	if (!sock_owned_by_user(sk))
>  		rc = __udp_queue_rcv_skb(sk, skb);
> -	else
> +	else {
> +		if (atomic_read(&sk->sk_backlog.len) >= sk->sk_rcvbuf) {
> +			bh_unlock_sock(sk);
> +			goto drop;
> +		}
>  		sk_add_backlog(sk, skb);
> +	}

We have to address this issue, of course, but I bet this method of
handling it negatively impacts performance in normal cases.

Right now we can queue up a lot and still get it to the application
if it is slow getting scheduled onto a cpu, but if you put this
limit here it could result in lots of drops.
