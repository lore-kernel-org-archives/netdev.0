From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Tue, 2 Sep 2014 11:31:24 +0300
Message-ID: <20140902083124.GB10356@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <53F6F14B.1030609@redhat.com>
 <20140822074224.GB7372@gmail.com>
 <53FFEEC0.4000304@redhat.com>
 <540414AB.9000004@linux.intel.com>
 <54053998.4040604@redhat.com>
 <54056076.2030603@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495AbaIBJaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 05:30:17 -0400
Content-Disposition: inline
In-Reply-To: <54056076.2030603@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 09:15:18AM +0300, Eliezer Tamir wrote:
> On 02/09/2014 06:29, Jason Wang wrote:
> > On 09/01/2014 02:39 PM, Eliezer Tamir wrote:
> >> On 29/08/2014 06:08, Jason Wang wrote:
> >>>> Yes, but rx busy polling only works in process context and does not
> >>>> disable bh, so it may be not an issue.
> >> sk_busy_loop() uses rcu_read_lock_bh(), so it does run with bh disabled.
> > 
> > True, so we need probably also exit the loop when there are pending bhs.
> 
> I'm not so sure, in the typical busy poll scenario, the incoming
> traffic is the most time-critical thing in the system.
> It's so important that you are willing to trade lots of CPU power
> for better latency. The user has decided that he wants to dedicate
> this CPU mostly for that. This is not something that plays nice with
> other apps, but this is what the user wants.

I think most applications wouldn't interpret this flag as "burn up CPU I don't
care what is the result", what apps want is more of "maximise throughput
and minimise latency even if throughput/CPU ratio goes down".
Jason posted benchmarks that show throughput going up because other
processes get more of a chance to run, so this seems consistent
with that goal.


> So, you definitely don't want to starve any bh, and you should
> regularly re-enable bh's, but you also don't want to stop everything
> at any time a bh is scheduled.
> 
> You also want network processing on the queues that are busy polled
> to come through busy polling and not through NAPI, which is run in bh
> context.
> 
> -Eliezer
