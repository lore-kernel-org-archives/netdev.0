From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: Add incoming CPU mask to sockets
Date: Tue, 19 May 2015 13:08:50 -0700
Message-ID: <1432066130.621.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432062109-1472984-1-git-send-email-tom@herbertland.com>
	 <1432062109-1472984-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34172 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbESUIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:08:52 -0400
Received: by igbhj9 with SMTP id hj9so43601999igb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:08:51 -0700 (PDT)
In-Reply-To: <1432062109-1472984-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-19 at 12:01 -0700, Tom Herbert wrote:

Hi Tom

>  struct sock;
>  struct proto;
>  struct net;
> @@ -420,6 +425,7 @@ struct sock {
>  	struct timer_list	sk_timer;
>  	ktime_t			sk_stamp;
>  	u16			sk_tsflags;
> +	struct rcu_cpumask __rcu *sk_incoming_cpu_mask;

This is in the middle of 2 fields, adding extra holes on 64bit

This is also very far away from other lookup fields, adding an extra
cache line miss in socket lookup.

>  	u32			sk_tskey;
>  	struct socket		*sk_socket;
>  	void			*sk_user_data;
> @@ -2213,6 +2219,27 @@ static inline bool sk_fullsock(const struct sock *sk)
>  	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
>  }
>  


This feature anyway depends on the final bits of TCP listener rewrite I
am currently doing.

You can not assume that SYN and the ACK packet (1st and 3rd packets or
3WHS) will be handled by the same cpu.

After my rewrite, the listener will be searched only for the SYN packet,
and your patch might be applied.

As I said, this is almost done.
