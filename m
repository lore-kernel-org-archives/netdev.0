From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Linux 2.6.0-test9
Date: Sun, 26 Oct 2003 16:21:59 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310261607230.3157-100000@home.osdl.org>
References: <20031026160158.74bd09c8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andries.Brouwer@cwi.nl, Kernel Mailing List <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>,
        <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031026160158.74bd09c8.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 26 Oct 2003, Andrew Morton wrote:
> 
> Can someone show us the diff for this?

There's only one change to tcp.c after -test8: it's 

	kuznet@ms2.inr.ac.ru:
	 TCP: do not return -EINTR, when data are available for read()

and I think it should just be reverted: the changeset even removes the 
comment that clearly says:

		/* We need to check signals first, to get correct SIGURG
		 * handling. FIXME: Need to check this doesn't impact 1003.1g
		 * and move it down to the bottom of the loop
		 */

And Alexey apparently tried to do the "FIXME" part, but without thinking 
about the SIGURG part.

We _need_ to stop at urgent data and we _should_ return -EINTR, and let
the SIGURG handler do the URG read. Otherwise we'll lose urgent data (or
we'll just read it inline without realizing that it was urgent data).

I don't know anybody sane who uses urgent data (telnet and rlogin do, I
don't know if they count as sane any more), but it does look like that
patch totally broke it.

I'd revert it myself, but since the networking code is fairly well 
maintained, I'll just wait for David and Alexey to weigh in, and tell me 
that I'm a total moron and I overlooked something. But I don't think I 
missed anything.

Andries, what was the situation that led to a TCP lockup? I don't see 
anything but URG being broken by that patch, so it would be good to verify 
that your breakage really was URG, to see that it's totally understood..

		Linus
