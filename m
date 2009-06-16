From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 11:59:34 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906161155400.3282@localhost.localdomain>
References: <20090616094813.GA1686@elte.hu> <20090616.025659.224075454.davem@davemloft.net> <20090616101132.GA28204@elte.hu> <20090616.033554.102149558.davem@davemloft.net> <4A37A058.1030701@gmail.com> <4A37AA0C.40507@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59535 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761258AbZFPS7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 14:59:52 -0400
In-Reply-To: <4A37AA0C.40507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 16 Jun 2009, Eric Dumazet wrote:
> 
> Here is first patch to take into account this initial offset in sk_wmem_alloc
> 
> (Only compiled, not tested)

I think this is incredibly ugly and hacky.

> @@ -162,7 +162,7 @@ static void atalk_destroy_timer(unsigned long data)
>  {
>  	struct sock *sk = (struct sock *)data;
>  
> -	if (atomic_read(&sk->sk_wmem_alloc) ||
> +	if (atomic_read(&sk->sk_wmem_alloc) > 1 ||
>  	    atomic_read(&sk->sk_rmem_alloc)) {

Seriously, look at that code, and tell me it makes sense.

No, it does not. The code looks like totally random line noise, and that 
whole "> 1" test makes no conceptual sense what-so-ever.

It _will_ result in random bugs later on, because code that doesn't make 
sense will never be good in the long run.

At the very least, add a helper function for "do I actually have 
outstanding allocations" or something like that. IOW, do a 

	/*
	 * Comment here about that magical "1"
	 */
	static inline int sk_has_allocations(struct sock *sk)
	{
		return atomic_read(&sk->sk_wmem_alloc) > 1 ||
			atomic_read(&sk->sk_rmem_alloc);
	}

and then make the various network protocols use that, rather than 
open-coding some random internal implementation magic.

		Linus
