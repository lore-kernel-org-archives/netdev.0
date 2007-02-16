From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 10:04:25 +0100
Message-ID: <20070216090425.GD1599@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216081051.GC1599@ff.dom.local> <45D569E9.7010407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:48091 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423426AbXBPJBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 04:01:10 -0500
Content-Disposition: inline
In-Reply-To: <45D569E9.7010407@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 12:23:05AM -0800, Ben Greear wrote:
> Jarek Poplawski wrote:
> >On Thu, Feb 15, 2007 at 11:40:32PM -0800, Ben Greear wrote:
> >...
> >  
> >>Maybe there should be something like an ASSERT_NOT_RTNL() in the 
> >>flush_scheduled_work()
> >>method?  If it's performance criticial, #ifdef it out if we're not 
> >>debugging locks?
> >>    
> >
> >Yes! I thought about the same (at first). But in my
> >opinion it was not enough, so I thought about doing
> >this in flush_workqueue. But in my next opinion it
> >was not enough too. Now I think something like this
> >should be done in rtnl_lock (under some debugging #if
> >of course). 
> >  
> The reason these bugs have been hidden is that most of the time, there 
> is nothing
> on the pending work queue that will try to grab RTNL.  But, the 
> flush_work_queue
> is still called with RTNL held, so an assert would find this much 
> earlier than
> waiting for someone to get lucky and actually catch (and debug and report)
> a deadlock...

Yes. Regarding this, you are right - it should be better.
But, anyway cancel_rearming... is equally dangerous,
so there is a question where: in all places where used,
in workqueue.c or maybe make it semi obligatory in
networking and add some net wrappers e.g.:
net_flush_work_queue and net_cancel_rearmnig with this
ASSERT_NO_RTNL?

> 
> I don't see how asserting it in the rtnl_lock would help anything, 
> because at that
> point we are about to deadlock anyway...  (and this is probably very 
> rare, as mentioned above.)

But it's happening now. Probably lockdep is not enough
and rtnl_lock is probably used in too many places, so I
meant some additional checks would be possible.
I wrote "something like this" and mean some check if we
have this lock already before trying to get it again.

But maybe it's really too much and your proposal is
sufficient for this.

Jarek P.
