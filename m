From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Sun, 24 Apr 2016 12:46:42 -0700
Message-ID: <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <43037.1461229555@turing-police.cc.vt.edu>
	 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5718DA71.7050902@stressinduktion.org>
	 <20160424.143833.2292980084570149367.davem@davemloft.net>
	 <571D14F8.6070306@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Valdis.Kletnieks@vt.edu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <571D14F8.6070306@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-04-24 at 20:48 +0200, Hannes Frederic Sowa wrote:
> On 24.04.2016 20:38, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Thu, 21 Apr 2016 15:49:37 +0200
> > 
> >> On 21.04.2016 15:31, Eric Dumazet wrote:
> >>> On Thu, 2016-04-21 at 05:05 -0400, Valdis.Kletnieks@vt.edu wrote:
> >>>> On Thu, 21 Apr 2016 09:42:12 +0200, Hannes Frederic Sowa said:
> >>>>> Hi,
> >>>>>
> >>>>> On Thu, Apr 21, 2016, at 02:30, Valdis Kletnieks wrote:
> >>>>>> linux-next 20160420 is whining at an incredible rate - in 20 minutes of
> >>>>>> uptime, I piled up some 41,000 hits from all over the place (cleaned up
> >>>>>> to skip the CPU and PID so the list isn't quite so long):
> >>>>>
> >>>>> Thanks for the report. Can you give me some more details:
> >>>>>
> >>>>> Is this an nfs socket? Do you by accident know if this socket went
> >>>>> through xs_reclassify_socket at any point? We do hold the appropriate
> >>>>> locks at that point but I fear that the lockdep reinitialization
> >>>>> confused lockdep.
> >>>>
> >>>> It wasn't an NFS socket, as NFS wasn't even active at the time.  I'm reasonably
> >>>> sure that multiple sockets were in play, given that tcp_v6_rcv and
> >>>> udpv6_queue_rcv_skb were both implicated.  I strongly suspect that pretty much
> >>>> any IPv6 traffic could do it - the frequency dropped off quite a bit when I
> >>>> closed firefox, which is usually a heavy network hitter on my laptop.
> >>>
> >>>
> >>> Looks like the following patch is needed, can you try it please ?
> >>>
> >>> Thanks !
> >>>
> >>> diff --git a/include/net/sock.h b/include/net/sock.h
> >>> index d997ec13a643..db8301c76d50 100644
> >>> --- a/include/net/sock.h
> >>> +++ b/include/net/sock.h
> >>> @@ -1350,7 +1350,8 @@ static inline bool lockdep_sock_is_held(const struct sock *csk)
> >>>  {
> >>>  	struct sock *sk = (struct sock *)csk;
> >>>  
> >>> -	return lockdep_is_held(&sk->sk_lock) ||
> >>> +	return !debug_locks ||
> >>> +	       lockdep_is_held(&sk->sk_lock) ||
> >>>  	       lockdep_is_held(&sk->sk_lock.slock);
> >>>  }
> >>>  #endif
> >>
> >> I would prefer to add debug_locks at the WARN_ON level, like
> >> WARN_ON(debug_locks && !lockdep_sock_is_held(sk)), but I am not sure if
> >> this fixes the initial splat.
> > 
> > Can we finish this conversation out and come up with a final patch
> > for this soon?
> 
> Eric's patch is worth to apply anyway, but I am not sure if it solves
> the (fundamental) problem. I couldn't reproduce it with the exact next-
> tag provided in the initial mail. All other reports also only happend
> with linux-next and not net-next.
> 
> I hope I Valdis provides his config soon and I will continue my analysis
> on this then.

Should be easy to force a lockdep splat and check if the patch solves
the issue.

Issue here is that once lockdep detected a problem (not necessarily in
net/ tree btw), your helper always 'detect' a problem, since lockdep
automatically disables itself.
