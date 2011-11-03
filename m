From: Simon Kirby <sim@hostway.ca>
Subject: Re: Linux 3.1-rc9
Date: Wed, 2 Nov 2011 17:52:55 -0700
Message-ID: <20111103005255.GL5971@hostway.ca>
References: <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca> <20111031173246.GA10614@hostway.ca> <alpine.LFD.2.02.1111021725550.2829@ionos> <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1320256157.2292.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1320256701.2292.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111102191621.GF5971@hostway.ca> <4EB1C770.7070605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>,
	Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:49071 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698Ab1KCAxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 20:53:00 -0400
Content-Disposition: inline
In-Reply-To: <4EB1C770.7070605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2011 at 11:42:56PM +0100, Eric Dumazet wrote:

> On 02/11/2011 20:16, Simon Kirby wrote:
> 
>  
> > Actually, we have an anti-abuse daemon that injects blackhole routes, so
> > this makes sense. (The daemon was written before ipsets were merged and
> > normal netfilter rules make it fall over under attack.)
> > 
> > I'll try with this patch. Thanks!
> > 
> 
> 
> Thanks !
> 
> Here is the official submission, please add your 'Tested-by' signature
> when you can confirm problem goes away.
> 
> (It did here, when I injected random NULL returns from
> inet_csk_route_child_sock(), so I am confident this is the problem you hit )
> 
> [PATCH] net: add missing bh_unlock_sock() calls
> 
> Simon Kirby reported lockdep warnings and following messages :
> 
> [104661.897577] huh, entered softirq 3 NET_RX ffffffff81613740
> preempt_count 00000101, exited with 00000102?
> 
> [104661.923653] huh, entered softirq 3 NET_RX ffffffff81613740
> preempt_count 00000101, exited with 00000102?
> 
> Problem comes from commit 0e734419
> (ipv4: Use inet_csk_route_child_sock() in DCCP and TCP.)
> 
> If inet_csk_route_child_sock() returns NULL, we should release socket
> lock before freeing it.
> 
> Another lock imbalance exists if __inet_inherit_port() returns an error
> since commit 093d282321da ( tproxy: fix hash locking issue when using
> port redirection in __inet_inherit_port()) a backport is also needed for
> >= 2.6.37 kernels.
> 
> Reported-by: Dimon Kirby <sim@hostway.ca>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Balazs Scheidler <bazsi@balabit.hu>
> CC: KOVACS Krisztian <hidden@balabit.hu>
> ---
>  net/dccp/ipv4.c     |    1 +
>  net/ipv4/tcp_ipv4.c |    1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 332639b..90a919a 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -433,6 +433,7 @@ exit:
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
>  	return NULL;
>  put_and_exit:
> +	bh_unlock_sock(newsk);
>  	sock_put(newsk);
>  	goto exit;
>  }
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 0ea10ee..683d97a 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1510,6 +1510,7 @@ exit:
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
>  	return NULL;
>  put_and_exit:
> +	bh_unlock_sock(newsk);
>  	sock_put(newsk);
>  	goto exit;
>  }

Tested-by: Simon Kirby <sim@hostway.ca>

I tried many times, with route unreach/blackhole, and could not reproduce
the issue with this patch applied.

Thanks!

Simon-
