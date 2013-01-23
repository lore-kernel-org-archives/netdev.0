From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 06:26:20 -0800
Message-ID: <1358951180.12374.787.camel@edumazet-glaptop>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	 <kdoibl$978$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:47740 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab3AWO0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 09:26:22 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so4788700pad.3
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 06:26:22 -0800 (PST)
In-Reply-To: <kdoibl$978$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 11:42 +0000, Cong Wang wrote:
> On Tue, 22 Jan 2013 at 02:01 GMT, Yannick Koehler <yannick@koehler.name> wrote:
> >
> >   I believe that the problem is that once we move the skb into the
> > client's receive queue we need to decrease the sk_wmem_alloc variable
> > of the server socket since that skb is no more tied to the server.
> > The code should then account for this memory as part of the
> > sk_rmem_alloc variable on the client's socket.  The function
> > "skb_set_owner_r(skb,owner)" would seem to be the function to do that,
> > so it would seem to me.
> 
> Something like below??
> 
> -------->
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 0c61236..e273072 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1205,6 +1205,7 @@ restart:
>  
>  	unix_state_unlock(sk);
>  
> +	skb_set_owner_r(skb, other);
>  	/* take ten and and send info to listening sock */
>  	spin_lock(&other->sk_receive_queue.lock);
>  	__skb_queue_tail(&other->sk_receive_queue, skb);
> @@ -1578,6 +1579,7 @@ restart:
>  
>  	if (sock_flag(other, SOCK_RCVTSTAMP))
>  		__net_timestamp(skb);
> +	skb_set_owner_r(skb, other);
>  	maybe_add_creds(skb, sock, other);
>  	skb_queue_tail(&other->sk_receive_queue, skb);
>  	if (max_level > unix_sk(other)->recursion_level)
> @@ -1693,6 +1695,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  		    (other->sk_shutdown & RCV_SHUTDOWN))
>  			goto pipe_err_free;
>  
> +		skb_set_owner_r(skb, other);
>  		maybe_add_creds(skb, sock, other);
>  		skb_queue_tail(&other->sk_receive_queue, skb);
>  		if (max_level > unix_sk(other)->recursion_level)
> 

So what prevents a malicious program to DOS the machine ?

Current behavior is on purpose. Limited, predictable, but less holes.

Some applications might depend on the current flow control : Limiting
the working set also permits to keep cpu caches hot.

If you want to change it, better do a full analysis, because hackers
will do it.

Its probably doable, but with a "man unix" change.
