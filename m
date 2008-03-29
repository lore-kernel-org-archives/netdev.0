From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Fri, 28 Mar 2008 18:09:24 -0700 (PDT)
Message-ID: <20080328.180924.154907485.davem@davemloft.net>
References: <20080328.173414.22278840.davem@davemloft.net>
	<1206752049.22530.105.camel@johannes.berg>
	<1206752485.22530.108.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755246AbYC2BJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 21:09:24 -0400
In-Reply-To: <1206752485.22530.108.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 29 Mar 2008 02:01:25 +0100

> 
> > > You can't flush a workqueue in the device close handler
> > > exactly because of this locking conflict.
> > > 
> > > Nobody has come up with a suitable way to fix this yet.
> > 
> > Maybe we should check which schedule_work users actually lock the rtnl
> > within the work function and move them to a uses-rtnl-in-work workqueue
> > so that everybody else can have rtnl around flush.
> 
> On the other hand, most drivers don't actually care that their work has
> run, they just care that it won't run in the future after they give up
> resources or similar, hence they can and should use cancel_work_sync()
> which doesn't suffer from the deadlock. But that needs actual inspection
> because it does change behaviour from "run and wait for it if scheduled"
> to "cancel if scheduled".

I don't see how you can not race with the transition from
scheduled to "executing" without taking the runqueue lock
for the testing.

And it is crucial that the workqueue function doesn't
execute "accidently" due to such a race before the module
and thus the workqueue code is about to get potentially
unloaded.
