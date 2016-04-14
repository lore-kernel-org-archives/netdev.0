From: marcelo.leitner@gmail.com
Subject: Re: [PATCH v3 0/2] sctp: delay calls to sk_data_ready() as much as
 possible
Date: Thu, 14 Apr 2016 17:19:00 -0300
Message-ID: <20160414201900.GK15005@localhost.localdomain>
References: <20160413.230532.676746231426161126.davem@davemloft.net>
 <20160414130324.GA6806@hmsreliant.think-freely.org>
 <570FCCC1.6090504@gmail.com>
 <20160414.145916.2286519059284215039.davem@davemloft.net>
 <20160414200351.GA4632@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	David.Laight@ACULAB.COM, jkbs@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbcDNUTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 16:19:04 -0400
Content-Disposition: inline
In-Reply-To: <20160414200351.GA4632@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 04:03:51PM -0400, Neil Horman wrote:
> On Thu, Apr 14, 2016 at 02:59:16PM -0400, David Miller wrote:
> > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > Date: Thu, 14 Apr 2016 14:00:49 -0300
> > 
> > > Em 14-04-2016 10:03, Neil Horman escreveu:
> > >> On Wed, Apr 13, 2016 at 11:05:32PM -0400, David Miller wrote:
> > >>> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > >>> Date: Fri,  8 Apr 2016 16:41:26 -0300
> > >>>
> > >>>> 1st patch is a preparation for the 2nd. The idea is to not call
> > >>>> ->sk_data_ready() for every data chunk processed while processing
> > >>>> packets but only once before releasing the socket.
> > >>>>
> > >>>> v2: patchset re-checked, small changelog fixes
> > >>>> v3: on patch 2, make use of local vars to make it more readable
> > >>>
> > >>> Applied to net-next, but isn't this reduced overhead coming at the
> > >>> expense of latency?  What if that lower latency is important to the
> > >>> application and/or consumer?
> > >> Thats a fair point, but I'd make the counter argument that, as it
> > >> currently
> > >> stands, any latency introduced (or removed), is an artifact of our
> > >> implementation rather than a designed feature of it.  That is to say,
> > >> we make no
> > >> guarantees at the application level regarding how long it takes to
> > >> signal data
> > >> readines from the time we get data off the wire, so I would rather see
> > >> our
> > >> throughput raised if we can, as thats been sctp's more pressing
> > >> achilles heel.
> > >>
> > >>
> > >> Thats not to say I'd like to enable lower latency, but I'd rather have
> > >> this now,
> > >> and start pondering how to design that in.  Perhaps we can convert the
> > >> pending
> > >> flag to a counter to count the number of events we enqueue, and call
> > >> sk_data_ready every  time we reach a sysctl defined threshold.
> > > 
> > > That and also that there is no chance of the application reading the
> > > first chunks before all current ToDo's are performed by either the bh
> > > or backlog handlers for that packet. Socket lock won't be cycled in
> > > between chunks so the application is going to wait all the processing
> > > one way or another.
> > 
> > But it takes time to signal the wakeup to the remote cpu the process
> > was running on, schedule out the current process on that cpu (if it
> > has in fact lost it's timeslice), and then finally look at the socket
> > queue.
> > 
> > Of course this is all assuming the process was sleeping in the first
> > place, either in recv or more likely poll.
> > 
> > I really think signalling early helps performance.
> > 
> 
> Early, yes, often, not so much :).  Perhaps what would be adventageous would be
> to signal at the start of a set of enqueues, rather than at the end.  That would
> be equivalent in terms of not signaling more than needed, but would eliminate
> the signaling on every chunk.   Perhaps what you could do Marcelo would be to
> change the sense of the signal_ready flag to be a has_signaled flag.  e.g. call
> sk_data_ready in ulp_event_tail like we used to, but only if the has_signaled
> flag isn't set, then set the flag, and clear it at the end of the command
> interpreter.
> 
> That would be a best of both worlds solution, as long as theres no chance of
> race with user space reading from the socket before we were done enqueuing (i.e.
> you have to guarantee that the socket lock stays held, which I think we do).

That is my feeling too. Will work on it. Thanks :-)

  Marcelo
