From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: gettimeofday scalability
Date: Tue, 5 Oct 2004 20:55:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005185553.GG26820@dualathlon.random>
References: <4162CD76.4070204@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
Content-Disposition: inline
In-Reply-To: <4162CD76.4070204@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2004 at 05:36:06PM +0100, P@draigBrady.com wrote:
> I've seen various gettimeofday locking speedup patches floating
> around for 2.4. There is a version from Stephen and Andrea
> that uses frlock, claiming 18%, and one from ingo that uses brlock.
> 2.6.8.1 uses seqlock, which contains the comment
> that it's not as cache friendly as brlock.

seqlock and frlock are the same thing. I don't see how the brlock can
work well given the fact you'll have to take it in write mode at every
timer irq. Maybe it works on a 2-way, sure not more than that. brlock
should be totally replaced by RCU anyways. brlock can also starve the
writer, which make it a security DoS (at least for some architecture,
there were two implementations, maybe one is safe).

> So can anyone summarise the relative merits of these locking
> mechanisms, before I start benchmarking?

frlock/seqlock (2.4/2.6 respectively) is the way to go, no write
starvation, and zero cacheline bouncing. 

upgrade to x86-64, there I implemented gettimeofday with vsyscalls which
also avoids entering exiting userspace which becomes the by far biggest
overhead after using seqlock. (speedup is tenfold or so)

Hope this helps.
