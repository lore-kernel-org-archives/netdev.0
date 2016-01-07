From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious rcu_dereference in tcp_v6_send_synack
Date: Thu, 07 Jan 2016 09:37:46 -0800
Message-ID: <1452188266.8255.220.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160107153248.GA30472@codemonkey.org.uk>
	 <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160107162030.GO3818@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34117 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbcAGRhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:37:48 -0500
Received: by mail-pa0-f51.google.com with SMTP id uo6so245379068pac.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 09:37:48 -0800 (PST)
In-Reply-To: <20160107162030.GO3818@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-07 at 08:20 -0800, Paul E. McKenney wrote:
>  This is not clear if this is a lockdep false positive.
> > 
> > Paul, can you remind me why it is needed, as a softirq handler is not
> > allowed to schedule or be preempted ?
> 
> Hello, Eric!
> 
> If this were rcu_dereference_bh(), then you would be OK as is, given that
> you are in a softirq handler.  But for rcu_dereference(), lockdep does
> indeed insist on an rcu_read_lock().  Yes, you would in fact be OK with
> the current implementation (I think, anyway), even with preemptible RCU,
> but that is an accident of implementation.
> 
> Is the required rcu_read_lock() and rcu_read_unlock() resulting in a
> performance problem?

No performance problem.

This comes from my 45f6fad84cc305103b28d73482b344d7f5b76f39
commit ("ipv6: add complete rcu protection around np->opt")

I added the rcu_read_lock()/unlock() sections where I thought they were
needed, and when I considered tcp_v6_send_synack() case, my reasoning
was that we were holding rcu_read_lock() in the normal non retransmit
case, since the SYN packet is processed under rcu_read_lock()
protection, and wrongly assumed the timer irq was also holding
rcu_read_lock()

Also my RCU lockdep enabled tests did not trigger the warning seen by
Dave Jones.... Strange...

I will submit a formal patch.

Thanks !
