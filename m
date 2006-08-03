From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Thu, 03 Aug 2006 10:24:15 -0400
Message-ID: <1154615055.5155.19.camel@jzny2>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:52632 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932440AbWHCOYS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 10:24:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G8e7Y-0007Bp-AI
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 10:24:20 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-08 at 00:02 +1000, Herbert Xu wrote:

> Even if we get it wrong and wake up something that we shouldn't have,
> the xmit function will simply bail out and stop the queue for us.
> 

Infact thats close to what i was seeing. setup is:
eth0 tied to cpu 0
eth1 tied to cpu1

--> eth0 -- forward --> eth1
--> eth1 -- forward --> eth0

Take the example of eth1:
* It is actually being fed packets by cpu0 but is tied to cpu1.

The stop happens in cpu0 (99.99999% of the time) and the wake happens in
cpu1 (100% of the time)[1]. The wakes on most occasions dont even get to
run tx softirq on cpu1 since there is constant activity already
happening on cpu0. So that lock being grabbed was causing a collision on
the tx path which caused a requeue which caused a reschedule on cpu0 -
all this unnecessarily.

> Since this is exceedingly unlikely we should drop the locks rather
> than bother about it.

I should say that the fact that e1000 does its pruning of descriptors
only on the tx path makes the locking unnecessary when stopped.

cheers,
jamal

[1] As you may know this comes from testing your qdisc_is_running
change. I was hoping to induce a DOS attack such that a cpuX is busy
processing packets from another CPU (eg eth1 on cpu1) so that it forgets
to process its own receive path ;-> This is a theoretical possibility
with that change ;-> Clearly i failed given the % above ;->

