From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 9 May 2007 10:05:57 +0530
Message-ID: <OF0E0FA5FB.06A0B8D0-ON652572D6.001854BA-652572D6.001943CC@in.ibm.com>
References: <20070508.190506.85687854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:50117 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935010AbXEIEhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:37:14 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l494unAK288896
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:56:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l494ebaB158300
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:40:38 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l494b19T020284
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 14:37:02 +1000
In-Reply-To: <20070508.190506.85687854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This change will not change existing behavior in case there are packets in
the queue, it will return -1 each time as does the original code. But when
there are no packets, the original qdisc_restart returns -1  and the caller
will
unnecessarily call qdisc_restart which branches to the bottom and returns
0 (qlen). This call can be avoided if we had returned 0 in the previous
iteration.
Branching to the bottom cannot be done since it breaks the "packets
present"
case, as it will return a positive number and the caller will assume that
the
queue is throttled.

thanks,

- KK

David Miller <davem@davemloft.net> wrote on 05/09/2007 07:35:06 AM:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Tue, 08 May 2007 13:01:32 +0530
>
> > Optimize return value of qdisc_restart so that it is not called an
> > extra time if there are no more packets on the queue to be sent out.
> > It is also not required to check for gso_skb (though the lock is
> > dropped) since another cpu which added this would have done a
> > netif_schedule.
> >
> > Patch against net-2.6.22.git
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> <0 return value here means that the queue is not empty, and the device
> is throttled.  If you want to do this, just branch down to the end of
> the function which asserts that q->q.qlen is not negative, and returns
> it.
>
> That will achieve the right effect.
>
> But I'm not so sure about this idea, I have this strange feeling that
> we do things this way for a reason... Hmmm...

