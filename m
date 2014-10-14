From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: TCP Small Queues and strange attractors
Date: Tue, 14 Oct 2014 14:10:18 -0700
Message-ID: <1413321018.17109.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413206867.9362.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141014.153308.2221538197341630790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46751 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755680AbaJNVKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:10:20 -0400
Received: by mail-pd0-f170.google.com with SMTP id p10so8279262pdj.29
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 14:10:20 -0700 (PDT)
In-Reply-To: <20141014.153308.2221538197341630790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-14 at 15:33 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 13 Oct 2014 06:27:47 -0700
> 
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 8d4eac793700..4a7e97811d71 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -839,26 +839,38 @@ void tcp_wfree(struct sk_buff *skb)
> >  {
>  ...
> >  		local_irq_restore(flags);
> > -	} else {
> > -		sock_wfree(skb);
> > +		return;
> >  	}
> > +out:
> > +	sk_free(sk);
> >  }
> >  
> 
> Why do we need to release the socket here?

Thats because we had to keep a reference at the very beginning :

+       /* Keep one reference on sk_wmem_alloc.
+        * Will be released by sk_free() from here or tcp_tasklet_func()
+        */
+       wmem = atomic_sub_return(skb->truesize - 1, &sk->sk_wmem_alloc);
+


If we find that we do not arm the tasklet (and keep the reference), we
then can remove the last ref we kept.

sk_free() is essentially doing :

if (atomic_dec_and_test(&sk->sk_wmem_alloc))
    __sk_free(sk)

sock_wfree() is the same, its only that we know that TCP socket do not
pass this test :

if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
   sk->sk_write_space(sk);
}
