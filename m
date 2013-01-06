From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 06 Jan 2013 08:39:53 -0800
Message-ID: <1357490393.6919.267.camel@edumazet-glaptop>
References: <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
	 <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106025256.GY16031@1wt.eu>
	 <1357457724.1678.5941.camel@edumazet-glaptop>
	 <20130106092435.GZ16031@1wt.eu> <1357484342.6919.61.camel@edumazet-glaptop>
	 <20130106155123.GB16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:62781 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab3AFQj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 11:39:57 -0500
In-Reply-To: <20130106155123.GB16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 16:51 +0100, Willy Tarreau wrote:
> Hi Eric,
> 

> Oh sorry, I didn't really want to pollute the list with links and configs,
> especially during the initial report with various combined issues :-(
> 
> The client is my old "inject" tool, available here :
> 
>      http://git.1wt.eu/web?p=inject.git
> 
> The server is my "httpterm" tool, available here :
> 
>      http://git.1wt.eu/web?p=httpterm.git
>      Use "-O3 -DENABLE_POLL -DENABLE_EPOLL -DENABLE_SPLICE" for CFLAGS.
> 
> I'm starting httpterm this way :
>     httpterm -D -L :8000 -P 256
>     => it starts a server on port 8000, and sets pipe size to 256 kB. It
>        uses SPLICE_F_MORE on output data but removing it did not fix the
>        issue one of the early tests.
> 
> Then I'm starting inject this way :
>     inject -o 1 -u 1 -G 0:8000/?s=1g
>     => 1 user, 1 object at a time, and fetch /?s=1g from the loopback.
>        The server will then emit 1 GB of data using splice().
> 
> It's possible to disable splicing on the server using -dS. The client
> "eats" data using recv(MSG_TRUNC) to avoid a useless copy.
> 
> > TCP has very low defaults concerning initial window, and it appears you
> > set RCVBUF to even smaller values.
> 
> Yes, you're right, my bootup scripts still change the default value, though
> I increase them to larger values during the tests (except the one where you
> saw win 8030 due to the default rmem set to 16060). I've been using this
> value in the past with older kernels because it allowed an integer number
> of segments to fit into the default window, and offered optimal performance
> with large numbers of concurrent connections. Since 2.6, tcp_moderate_rcvbuf
> works very well and this is not needed anymore.
> 
> Anyway, it does not affect the test here. Good kernels are OK whatever the
> default value, and bad kernels are bad whatever the default value too.
> 
> Hmmm finally it's this commit again :
> 
>    2f53384 tcp: allow splice() to build full TSO packets
> 
> I'm saying "again" because we already diagnosed a similar effect several
> months ago that was revealed by this patch and we fixed it with the
> following  one, though I remember that we weren't completely sure it
> would fix everything :
> 
>    bad115c tcp: do_tcp_sendpages() must try to push data out on oom conditions
> 
> Just out of curiosity, I tried to re-apply the patch above just after the
> first one but it did not change anything (after all it changed a symptom
> which appeared in different conditions).
> 
> Interestingly, this commit (2f53384) significantly improved performance
> on spliced data over the loopback (more than 50% in this test). In 3.7,
> it seems to have no positive effect anymore. I reverted it using the
> following patch and now the problem is fixed (mtu=64k works fine now) :
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index e457c7a..61e4517 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -935,7 +935,7 @@ wait_for_memory:
>  	}
>  
>  out:
> -	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> +	if (copied)
>  		tcp_push(sk, flags, mss_now, tp->nonagle);
>  	return copied;
> 
> Regards,
> Willy
> 

Hmm, I'll have to check if this really can be reverted without hurting
vmsplice() again.
