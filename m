From: "David S. Miller" <davem@redhat.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 01:52:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003015220.7ee6e451.davem@redhat.com>
References: <3F7C6F3B.6070502@sgi.com>
	<20031002125625.72b8c0a7.shemminger@osdl.org>
	<20031003004133.3148c39a.davem@redhat.com>
	<20031003082642.GF42593@gaz.sfgoth.com>
	<20031003012754.23de3f66.davem@redhat.com>
	<20031003084847.GH42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003084847.GH42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 01:48:47 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> David S. Miller wrote:
> > Doesn't work as-is.  You'd have to not only store the timestamp and
> > the cpu it was stored on, but also cross-call to that cpu to compute
> > the correct timeval.
> 
> That's definately the worst case.  You could have each CPU periodically
> store its current {tsc,timeval} tuple in a per-cpu location and extrapolate
> from that.

Right, that would work.

There is the weird issue (with both the sparc64 example and your's
here) of whether we should care about what happens when settimeofday()
occurs.  We probably shouldn't worry about it... as it gives weird
results even currently.

> It all depends on what percentage of skb's have ->stamp computed on a
> CPU different from the one they came it on.  For the common users of
> ->stamp won't they have stayed on the same CPU?  The worst case of
> doing a cross-cpu-call should only happen relatively rarely.

No, they typically won't.  The packet comes in on cpu X, we stamp
it on X, and we do a wakeup of tcpdump which will typically get
scheduled first onto some other processor before X is done processing
incoming packets.  The higher the packet load the more likely this will
happen.

But forget this, as your dual tsc+timeval recording idea would work
well and doesn't need a cross-cpu call.  Although we'd need to think
about how costly the cacheline activity is going to be with your idea
compared to the seqlocked accesses to xtime.  This is mainly a product
of how often you intend to update the tsc+timeval thingy.
