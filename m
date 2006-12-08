From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 3/16] Spidernet RX Locking
Date: Sat, 09 Dec 2006 09:47:05 +1100
Message-ID: <1165618025.1103.85.camel@localhost.localdomain>
References: <20061206223223.GH17931@austin.ibm.com>
	 <20061206233134.GC4649@austin.ibm.com> <4577E850.6040500@pobox.com>
	 <20061207175046.GB4614@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34695 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761248AbWLHWrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:47:36 -0500
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061207175046.GB4614@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A spinlock is expensive in the fast path, which is why Jeff says it's
invasive.

> spider_net_decode_one_descr() is called from
> spider_net_poll() (which is the netdev->poll callback)
> and also from spider_net_handle_rxram_full(). 
> 
> The rxramfull routine is called from a tasklet that
> is fired off after a "RX ram full" interrupt is receved.
> This interrupt is generated when the hardware runs out
> of space to store incoming packets. We are seeing this
> interrupt fire when the CPU is heavily loaded, and a
> lot of traffic is being fired at the device.

How often does that interrupt happen in that case ?

A better approach is to keep the fast path (ie. poll()) lockless, and in
handle_rxram_full(), the slow path, protect against poll using
netif_disable_poll(). Though that means using a work queue, not a
tasklet, since it needs to schedule.

> > and what other 
> > non-sledgehammer approaches were discarded before arriving at this one?
> 
> Well, I'm not that good at kernel programming, so I guess
> I did not perceive this as a "sledgehammer."  And alternative
> approach is to simply ignore the rxramfull interrupt entirely,
> and depend on poll() do all the work.   I'll try this shortly.

or you can schedule rx work from the rxramfull interrupt after setting a
"something bad happened" flag. Then, poll can check this flag and do the
right thing.

Ben.


