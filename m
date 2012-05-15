From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Date: Tue, 15 May 2012 11:47:14 +0200
Message-ID: <1337075234.27694.9.camel@twins>
References: <1336658065-24851-2-git-send-email-mgorman@suse.de>
	 <20120511.011034.557833140906762226.davem@davemloft.net>
	 <20120514105604.GB29102@suse.de>
	 <20120514.162634.1094732813264319951.davem@davemloft.net>
	 <20120515091402.GG29102@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com, neilb@suse.de,
	hch@infradead.org, michaelc@cs.wisc.edu, emunson@mgebm.net
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120515091402.GG29102@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-15 at 10:14 +0100, Mel Gorman wrote:
> @@ -289,6 +289,18 @@ void sk_clear_memalloc(struct sock *sk)
>         sock_reset_flag(sk, SOCK_MEMALLOC);
>         sk->sk_allocation &=3D ~__GFP_MEMALLOC;
>         static_key_slow_dec(&memalloc_socks);
> +
> +       /*
> +        * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forwa=
rd
> +        * progress of swapping. However, if SOCK_MEMALLOC is cleared whi=
le
> +        * it has rmem allocations there is a risk that the user of the
> +        * socket cannot make forward progress due to exceeding the rmem
> +        * limits. By rights, sk_clear_memalloc() should only be called
> +        * on sockets being torn down but warn and reset the accounting i=
f
> +        * that assumption breaks.
> +        */
> +       if (WARN_ON(sk->sk_forward_alloc))

WARN_ON_ONCE() perhaps?

> +               sk_mem_reclaim(sk);
>  }=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
