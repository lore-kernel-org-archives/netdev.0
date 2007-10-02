From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 12:27:53 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
 <20071002150935.GC17418@bitmover.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48873 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbXJBT3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 15:29:11 -0400
In-Reply-To: <20071002150935.GC17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 2 Oct 2007, Larry McVoy wrote:
> 
> tcpdump is a good idea, take a look at this.  The window starts out
> at 46 and never opens up in my test case, but in the rsh case it 
> starts out the same but does open up.  Ideas?

I don't think that's an issue, since you only send one way. The window 
opening up only matters for the receiver. Also, you missed the "wscale=7" 
at the beginning, so the window of "46" looks like it actually is 5888 (ie 
fits four segments - and it's not grown because it never gets any data).

However, I think this is some strange TSO artifact:

...
> 08:08:18.843942 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 48181:64241(16060) ack 0 win 46
> 08:08:18.844681 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 48181 win 32768
> 08:08:18.844690 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: P 64241:80301(16060) ack 0 win 46
> 08:08:18.845556 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 64241 win 32768
> 08:08:18.845566 IP work-cluster.bitmover.com.31235 > hp-ia64.bitmover.com.49614: . 80301:96361(16060) ack 0 win 46
> 08:08:18.846304 IP hp-ia64.bitmover.com.49614 > work-cluster.bitmover.com.31235: . ack 80301 win 32768
...

We see a single packet containing 16060 bytes, which seems to be because 
of TSO on the sending side (you did your tcpdump on the sender, no?), so 
it will actually be broken up into 11 1460-byte regular frames by the 
network card, since they started out agreeing on a standard 1460-byte MSS. 
So the above is not a jumbo frame, it just kind of looks like one when you 
capture it on the sender side.

And maybe a 32kB window is not big enough when it causes the networking 
code to basically just have a single packet outstanding.

I also would have expected more ACK's from the HP box. It's been a long 
time since I did TCP, but I thought the rule was still that you were 
supposed to ACK at least every other full frame - but the HP box is acking 
roughly every 16K (and it's *not* always at TSO boundaries: the earlier 
ACK's in the sequence are at 1460-byte packet boundaries, but it does seem 
to end up getting into that pattern later on).

So I'm wondering if we get into some bad pattern with the networking code 
trying to make big TSO packets for e1000, but because they are *so* big 
that there's only room for two such packets per window, you don't get into 
any smooth pattern with lots of outstanding packets, but it starts 
stuttering.

Larry, try turning off TSO. Or rather, make the kernel use a smaller limit 
for the large packets. The easiest way to do that should be to just change 
the value in /proc/sys/net/ipv4/tcp_tso_win_divisor. It defaults to 3, try 
doing

	echo 6 > /proc/sys/net/ipv4/tcp_tso_win_divisor

and see if that changes anything.

And maybe I'm just whistling in the dark. In fact, it looks like for you 
it's not 3, but 2 (window of 32768, but the TSO frames are half the size). 
So maybe I'm just totally confused and I'm not reading that tcp dump 
correctly at all!

			Linus

