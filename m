From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Fri, 20 May 2016 06:47:49 -0700
Message-ID: <1463752069.18194.294.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	 <20160520092903.38620c60@redhat.com>
	 <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36078 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcETNrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 09:47:51 -0400
Received: by mail-pf0-f195.google.com with SMTP id g132so11404791pfb.3
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 06:47:51 -0700 (PDT)
In-Reply-To: <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-20 at 06:11 -0700, Eric Dumazet wrote:
> On Fri, 2016-05-20 at 09:29 +0200, Jesper Dangaard Brouer wrote:
> 
> 
> > The hole idea behind allowing bulk qdisc dequeue, was to mitigate this,
> > by allowing dequeue to do more work, while holding the lock.
> > 
> > You mention HTB.  Notice HTB does not take advantage of bulk dequeue.
> > Have you tried to enable/allow HTB to bulk dequeue?
> > 
> 
> Well, __QDISC___STATE_RUNNING means exactly that : one cpu is dequeueing
> many packets from the qdisc and tx them to the device.
> 
> It is generic for any kind of qdisc.
> 
> HTB bulk dequeue would have to call ->dequeue() mutiple times. If you do
> this while holding qdisc spinlock, you block other cpus from doing
> concurrent ->enqueue(), adding latencies (always the same trade off...)
> 
> HTB wont be anytime soon have separate protections for the ->enqueue()
> and the ->dequeue(). Have you looked at this monster ? I did, many
> times...
> 
> Note that I am working on a patch to transform __QDISC___STATE_RUNNING
> to a seqcount do that we can grab stats without holding the qdisc lock.

Slide note : __qdisc_run() could probably avoid a __netif_schedule()
when it breaks the loop, if another cpu is busy spinning on qdisc lock.

-> Less (spurious) TX softirq invocations, so less chance to trigger the
infamous ksoftirqd bug we discussed lately.
