From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 17:16:27 +0100
Message-ID: <20110321161627.GB28580@elte.hu>
References: <20110320.195156.226769634.davem@davemloft.net>
 <201103211550.10694.arnd@arndb.de>
 <1300719332.2884.370.camel@edumazet-laptop>
 <201103211622.40851.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201103211622.40851.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Arnd Bergmann <arnd@arndb.de> wrote:

> On Monday 21 March 2011, Eric Dumazet wrote:
> > > diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> > > index 4680b1e..b2cf1db 100644
> > > --- a/net/x25/af_x25.c
> > > +++ b/net/x25/af_x25.c
> > > @@ -669,8 +669,8 @@ static int x25_release(struct socket *sock)
> > >  
> > >       sock_orphan(sk);
> > >  out:
> > > -     release_sock(sk);
> > >       sock_put(sk);
> > > +     release_sock(sk);
> > >       return 0;
> > >  }
> > >  
> > 
> > Hmm, x25_release() looks fine, I believe no fix is needed.
> > 
> 
> D'oh. You're right of course. My patch would introduce the bug,
> not fix it. Updated patch below.
> 
> 	Arnd
> 8<-------------------------
> net/appletalk: fix atalk_release use after free
> 
> The BKL removal in appletalk introduced a use-after-free problem,
> where atalk_destroy_socket frees a sock, but we still release
> the socket lock on it.
> 
> An easy fix is to take an extra reference on the sock and sock_put
> it when returning from atalk_release.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> index 3d4f4b0..206e771 100644
> --- a/net/appletalk/ddp.c
> +++ b/net/appletalk/ddp.c
> @@ -1051,6 +1051,7 @@ static int atalk_release(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
>  
> +	sock_hold(sk);
>  	lock_sock(sk);
>  	if (sk) {
>  		sock_orphan(sk);
> @@ -1058,6 +1059,8 @@ static int atalk_release(struct socket *sock)
>  		atalk_destroy_socket(sk);
>  	}
>  	release_sock(sk);
> +	sock_put(sk);
> +
>  	return 0;
>  }

I have not triggered the lockdep warning in this code yet - but i've ran the 
patch and have seen no ill effects from it so far.

Thanks,

	Ingo
