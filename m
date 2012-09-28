From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Fri, 28 Sep 2012 09:16:42 -0400
Message-ID: <20120928131642.GA31568@hmsreliant.think-freely.org>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
 <20120927142334.GA3194@neilslaptop.think-freely.org>
 <1348813987.7264.41.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54368 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab2I1NQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 09:16:58 -0400
Content-Disposition: inline
In-Reply-To: <1348813987.7264.41.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 02:33:07PM +0800, Cong Wang wrote:
> On Thu, 2012-09-27 at 10:23 -0400, Neil Horman wrote:
> > On Thu, Sep 27, 2012 at 04:41:01PM +0800, Cong Wang wrote:
> > > Some customer requests this feature, as they stated:
> > > 
> > > 	"This parameter is necessary, especially for software that continually 
> > >         creates many ephemeral processes which open sockets, to avoid socket 
> > >         exhaustion. In many cases, the risk of the exhaustion can be reduced by 
> > >         tuning reuse interval to allow sockets to be reusable earlier.
> > > 
> > >         In commercial Unix systems, this kind of parameters, such as 
> > >         tcp_timewait in AIX and tcp_time_wait_interval in HP-UX, have 
> > >         already been available. Their implementations allow users to tune 
> > >         how long they keep TCP connection as TIME-WAIT state on the 
> > >         millisecond time scale."
> > > 
> > > We indeed have "tcp_tw_reuse" and "tcp_tw_recycle", but these tunings
> > > are not equivalent in that they cannot be tuned directly on the time
> > > scale nor in a safe way, as some combinations of tunings could still
> > > cause some problem in NAT. And, I think second scale is enough, we don't
> > > have to make it in millisecond time scale.
> > > 
> > I think I have a little difficultly seeing how this does anything other than
> > pay lip service to actually having sockets spend time in TIME_WAIT state.  That
> > is to say, while I see users using this to just make the pain stop.  If we wait
> > less time than it takes to be sure that a connection isn't being reused (either
> > by waiting two segment lifetimes, or by checking timestamps), then you might as
> > well not wait at all.  I see how its tempting to be able to say "Just don't wait
> > as long", but it seems that theres no difference between waiting half as long as
> > the RFC mandates, and waiting no time at all.  Neither is a good idea.
> 
> I don't think reducing TIME_WAIT is a good idea either, but there must
> be some reason behind as several UNIX provides a microsecond-scale
> tuning interface, or maybe in non-recycle mode, their RTO is much less
> than 2*MSL?
> 
My guess?  Cash was the reason.  I certainly wasn't there for any of those
developments, but a setting like this just smells to me like some customer waved
some cash under IBM's/HP's/Sun's nose and said, "We'd like to get our tcp
sockets back to CLOSED state faster, what can you do for us?"

> > 
> > Given the problem you're trying to solve here, I'll ask the standard question in
> > response: How does using SO_REUSEADDR not solve the problem?  Alternatively, in
> > a pinch, why not reduce the tcp_max_tw_buckets sufficiently to start forcing
> > TIME_WAIT sockets back into CLOSED state?
> > 
> > The code looks fine, but the idea really doesn't seem like a good plan to me.
> > I'm sure HPUX/Solaris/AIX/etc have done this in response to customer demand, but
> > that doesn't make it the right solution.
> > 
> 
> *I think* the customer doesn't want to modify their applications, so
> that is why they don't use SO_REUSERADDR.
> 
Well, ok, thats a legitimate distro problem.  What its not is an upstream
problem.  Fixing the appilcation is the right thing to do, wether or not they
want to. 

> I didn't know tcp_max_tw_buckets can do the trick, nor the customer, so
> this is a side effect of tcp_max_tw_buckets? Is it documented?
man 7 tcp:
tcp_max_tw_buckets (integer; default: see below; since Linux 2.4)
	The maximum number of sockets in TIME_WAIT state allowed in the
	system.  This limit exists only  to  prevent  simple
	denial-of-service attacks.   The  default  value of NR_FILE*2 is
        adjusted depending on the memory in the system.  If this number
	is exceeded, the socket is closed and a warning is printed.

Neil
