From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 17:59:10 +0200
Message-ID: <20140918175910.5fc67efa@redhat.com>
References: <20140917152653.1c824a22@redhat.com>
	<1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	<5419A1E7.8040109@intel.com>
	<20140918085640.0815df6d@redhat.com>
	<1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411054951.7106.272.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757274AbaIRP7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 11:59:18 -0400
In-Reply-To: <1411054951.7106.272.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Sep 2014 08:42:31 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2014-09-18 at 06:41 -0700, Eric Dumazet wrote:
> 
> > Last but not least, there is the fact that networking stacks use
> > mod_timer() to arm timers, and that by default, timer migration is on 
> > ( cf /proc/sys/kernel/timer_migration )

I don't have this proc file on my system, as I didn't select CONFIG_SCHED_DEBUG.

> > We probably should use mod_timer_pinned(), but I could not really see
> > any difference.
> 
> Hmm... actually its quite noticeable :

Interesting impact.

I'm looking for some 1G hardware without multiqueue, so I can get
around this measurement constraint.  And possibly turning it down to
100Mbit/s, so I can more easily measure the HoL blocking effect.


> # ./super_netperf 500 --google-pacing-rate 3000000 -H lpaa24 -l 1000 &
> ...

Interesting option "--google-pacing-rate" ;-)

> # echo 1 >/proc/sys/kernel/timer_migration
> # vmstat 5
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  2  0      0 261178336  15812 1001880    0    0     5     1  185  217  0  4 96  0
>  0  0      0 261173456  15812 1001884    0    0     0     0 1548055 35472  0 15 85  0
>  2  0      0 261174880  15812 1001888    0    0     0     0 1533309 35163  0 15 85  0
>  3  0      0 261176768  15812 1001896    0    0     0     0 1533442 35694  0 15 85  0
[]

> # echo 0 >/proc/sys/kernel/timer_migration
> # vmstat 5
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  2  0      0 261172784  15812 1001936    0    0     5     1  165  228  0  5 95  0
>  1  0      0 261175776  15812 1001940    0    0     0     0 1187446 32238  0 12 88  0
>  2  0      0 261172752  15812 1001940    0    0     0     3 1166697 32060  0 12 88  0

Quite significant, both interrupts and especially CPU system usage drop.


> I am tempted to simply :
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 9c3f823e76a9..868c6bcd7221 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2288,10 +2288,10 @@ void sk_send_sigurg(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_send_sigurg);
>  
> -void sk_reset_timer(struct sock *sk, struct timer_list* timer,
> +void sk_reset_timer(struct sock *sk, struct timer_list *timer,
>  		    unsigned long expires)
>  {
> -	if (!mod_timer(timer, expires))
> +	if (!mod_timer_pinned(timer, expires))
>  		sock_hold(sk);
>  }
>  EXPORT_SYMBOL(sk_reset_timer);
> 


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
