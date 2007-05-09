From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 09 May 2007 11:52:44 -0400
Message-ID: <1178725965.4058.75.camel@localhost>
References: <OFBBEFE969.8AD5C0AA-ON652572D6.004FC535-652572D6.00513837@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:38460 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807AbXEIPwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 11:52:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so227961wxd
        for <netdev@vger.kernel.org>; Wed, 09 May 2007 08:52:50 -0700 (PDT)
In-Reply-To: <OFBBEFE969.8AD5C0AA-ON652572D6.004FC535-652572D6.00513837@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna,

On Wed, 2007-09-05 at 20:17 +0530, Krishna Kumar2 wrote:

> Concurrently is not possible, since everyone needs the queue_lock
> to add/delete. Did I misunderstand your comment ?
> 

I think so, more below where you explain it:

> The dev->queue_lock is held by both enqueue'r and dequeue'r (though
> the dequeue'r drops it before calling xmit). But once the dequeue'r
> re-gets the lock, it is guaranteed that no one else has the lock
> Other CPU's trying to add will block on the lock, or if they have
> already added by getting the lock for a short time while my CPU was
                
That is how concurency is achieved on the queue. If you have N CPUs, N-1
could be queueing.
Important to note, only one - that owns the QDISC_RUNNING can dequeue.
                       
> doing the xmit, then their qdisc_run returns doing nothing as RUNNING
> is true.
> 

lack of ownership of QDISC_RUNNING is what makes them enqueuers. The CPU
that owns it is the dequeuer. 

> Since I am holding a lock in these two changed areas till I return
> back to __qdisc_run (which clears the RUNNING bit) and then drop the
> lock, there is no way packets can be on the queue while I falsely
> return 0, or no packets on the queue while I falsely return -1.
> 

If you relinquish yourself from being a dequeuer by letting go of
RUNNING then it is possible during that short window one of the other
N-1 CPUs could have been enqueueing; that packet will never be dequeued
unless a new packet shows up some X amount of time later.

> I hope my explanation was not confusing.
> 

I hope what i described above helps. Off for about a day. CCing Herbert
who last made changes to that area incase i missed something ..

cheers,
jamal

PS:- Please dont use my temporary gmail account to respond; a reply-to
will pick the right address (@cyberus.ca).

