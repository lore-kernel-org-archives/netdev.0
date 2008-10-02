From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Thu, 2 Oct 2008 22:34:35 +0200
Message-ID: <20081002203435.GC2664@ami.dom.local>
References: <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com> <20081001233152.GA2411@ami.dom.local> <48E4E772.2020208@bull.net> <20081002183819.GA2664@ami.dom.local> <20081002215502.q9and4a6kg4cs0o8@intran0x.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Benjamin Thery <Benjamin.Thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:12358 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbYJBUdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 16:33:15 -0400
Received: by ik-out-1112.google.com with SMTP id c30so851990ika.5
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 13:33:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081002215502.q9and4a6kg4cs0o8@intran0x.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 09:55:02PM +0200, Benjamin Thery  wrote:
> Quoting Jarek Poplawski <jarkao2@gmail.com>:
...
>> As a matter of fact I've thought about something even simpler, which
>> probably should help for all above concerns too:
>>
>> 	if (event == NETDEV_UNREGISTER)
>>   	        dst_gc_task(&dst_gc_work.work);
>>
>> dst_gc_task() locking allows for this, and running this two times in
>> a row could be even faster than trying to cancel the unnecessary run.
>
> I've thought a bit more about my last proposal and come to the same
> conclusion as you, hmm, almost. I thought we could call
> cancel_delayed_work() unconditionally and then dst_gc_task().
>
>  	if (event == NETDEV_UNREGISTER) {
>                 cancel_delayed_work(&dst_gc_work);
>    	        dst_gc_task(&dst_gc_work.work);
>         }
>
> But, you're right, calling only dst_gc_task() seems fine to me.

I'm OK with any of these versions.

>
> I'll run some tests tomorrow and send a new patch.
>
> Do we agree that this fix (calling dst_gc_task() in dst_dev_event())
> is better/more appropriate than the first one (replacing rtnl_unlock()
> by the non-blocking __rtnl_unlock() in linkwatch_event())?

I agree it's more appropriate, because:
a) the job is done according to the rules (in the comment) during
   the notification and not in some future,
b) it removes some hidden dependencies between processes/works, which,
   even if they currently don't exist except this one in the linkwatch,
   could be extremly hard to diagnose, if added accidentally in the
   future.

On the other hand, until we are not sure of the reasons, why something
like this (the full destroying) was avoided in the past, and until it's
heavily tested (with lockdep), your first patch looks to me much safer
if applying to any -stable is considered.

Thanks,
Jarek P.
