From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 8 Sep 2010 16:14:50 +0400
Message-ID: <20100908121450.GA11412@ms2.inr.ac.ru>
References: <20100906.223010.173858342.davem@davemloft.net> <1283859552.2338.402.camel@edumazet-laptop> <alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi> <20100907.201843.179933180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	leandroal@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:34273 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756135Ab0IHMPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 08:15:13 -0400
Content-Disposition: inline
In-Reply-To: <20100907.201843.179933180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> [ Alexey, problem is that when receiver's maximum window is miniscule
>   (f.e. equal to MSS :-), we never send full MSS sized frames due to
>   our sender size SWS implementation. ]

I see.

The problem was that we do early packetization. If we chop
frames to real mss (> max_window/2), we cannot do #3
(min(D.U) >= Fs * Max(SND.WND)) without subsequent fragmentation.

The solution to chop to max_window/2 was mine and it was intended
to solve the problem for devices with _large_ mtu, where max_window
is comparable with mtu not because window is small, but because mtu is large.
This case was important from performance viewpoint, fragmentation
would destroy our smart early packetization technique.

What's about the case of sane mtu and small max_window, that case was not
simply ignored as "not-so-important", it also had a rational explanation, see below.

If the issue must be resolved, I would suggest to:

1. Complicate mss = min(mss, max_window/2). Probably, do something like:

   if (max_window >= 65536 /* just a guess */)
	mss = min(mss, max_window/2);
   else
	mss = min(mss, max_window);

2. Add SWS avoidance checks in tcp_write_xmit(). It should detect condition
   when end_seq > tcp_wnd_end(tp) (like now), but proceed with fragmentation when
   tp->snd_nxt == tp->snd_una && tp->snd_wnd >= tp->max_window/2.
   Luckily, all this logic is already there due to TSO, only conditions when
   to fragment are to be adjusted a little.


Frankly, I am not so sure that the issue should be resolved.
There is one more aspect, not related to SWS. When mss > max_window/2 we can have
only one segment in pipe, which is not good. When mss==max_window and we never see
full sized frame sent, this looks strange, but I bet it is still better
for performance under almost any curcumstances.

I do not know actual context, of course. I can guess the situation
can be like this: "I set window=mss exactly to see only one packet in flight
all the times. Why the hell linux tries to send two mss/2 sized?" :-)


> In ancient times we used to do this straight in sendmsg(), which had
> the comment:
> 
> 			/* We also need to worry about the window.  If
> 			 * window < 1/2 the maximum window we've seen
> 			 * from this host, don't use it.  This is
> 			 * sender side silly window prevention, as
> 			 * specified in RFC1122.  (Note that this is
> 			 * different than earlier versions of SWS
> 			 * prevention, e.g. RFC813.).  What we
> 			 * actually do is use the whole MSS.  Since
> 			 * the results in the right edge of the packet
> 			 * being outside the window, it will be queued
> 			 * for later rather than sent.
> 			 */

BTW the comment was good, but this logic was not actually implemented.
The code below this comment was incorrect, it chopped segments at tail of write_queue
(with seq > snd_nxt) based on window calculation at head of queue,
so that it did not work. Actually, this check can be done
not earlier than in tcp_write_xmit().

Alexey
