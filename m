From: "Tom Herbert" <therbert@google.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Tue, 23 Sep 2008 14:10:21 -0700
Message-ID: <65634d660809231410v47fb9d84s63fa76f358756729@mail.gmail.com>
References: <20080919.234824.223177211.davem@davemloft.net>
	 <48D80C9C.2070108@nortel.com>
	 <20080922.151233.229805934.davem@davemloft.net>
	 <48D92174.5010902@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:49612 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbYIWVKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 17:10:34 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m8NLANmD010865
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 22:10:23 +0100
Received: from rv-out-0506.google.com (rvbg37.prod.google.com [10.140.83.37])
	by zps36.corp.google.com with ESMTP id m8NL9wLB012692
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 14:10:21 -0700
Received: by rv-out-0506.google.com with SMTP id g37so2095714rvb.25
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 14:10:21 -0700 (PDT)
In-Reply-To: <48D92174.5010902@nortel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> That patch basically just picks an arbitrary cpu for each flow.  This would
> spread the load out across cpus, but it doesn't allow any input from
> userspace.
>

We've been running softRSS for a while
(http://marc.info/?l=linux-netdev&m=120475045519940&w=2) which I
believe has very similar functionality to this patch.  From this work
we found some nice ways to improve scaling that might be applicable:

- When routing packets to CPU based on hash, sending to another CPU
sharing L2 or L3 cache is best performance.
- We added a simple functionality to route packets to the CPU on which
the application last did a read for the socket.  This seems to be a
win for cache locality.
- We added a lookup table that maps the Toeplitz hash to the receiving
CPU where the application is running.  This is for those devices that
provide the Toeplitz hash in the receive descriptor.  This is a win
since the CPU receiving the interrupt doesn't need to take any cache
misses on the packet itself.
- In our (preliminary) 10G testing we found that routing packets in
software with the the above trick actually allows higher PPS and
better CPU utilization than using hardware RSS.  Also, using both the
software routing and hardware RSS yields the best results.

Tom

> We have a current application where there are 16 cores and 16 threads. They
> would really like to be able to pin one thread to each core and tell the
> kernel what packets they're interested in so that the kernel can process
> those packets on that core to gain the maximum caching benefit as well as
> reduce reordering issues.  In our case the hardware supports filtering for
> multiqueues, so we could pass this information down to the hardware to avoid
> software filtering.
>
> Either way, it requires some way for userspace to indicate interest in a
> particular flow.  Has anyone given any thought to what an API like this
> would look like?
>
> I suppose we could automatically look at bound network sockets owned by
> tasks that are affined to single cpus.  This would simplify userspace but
> would reduce flexibility for things like packet sockets with socket filters
> applied.
>
> Chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
