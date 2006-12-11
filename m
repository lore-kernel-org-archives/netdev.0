From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 3/16] Spidernet RX Locking
Date: Mon, 11 Dec 2006 15:07:11 -0600
Message-ID: <20061211210711.GA4329@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com> <20061206233134.GC4649@austin.ibm.com> <4577E850.6040500@pobox.com> <20061207175046.GB4614@austin.ibm.com> <1165618025.1103.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:60016 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758682AbWLKVHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 16:07:19 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBBL7Isd029179
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 16:07:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBBL7DGI227830
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 16:07:13 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBBL7BwE007034
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 16:07:12 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1165618025.1103.85.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 09, 2006 at 09:47:05AM +1100, Benjamin Herrenschmidt wrote:
> A spinlock is expensive in the fast path, which is why Jeff says it's
> invasive.
> 
> > spider_net_decode_one_descr() is called from
> > spider_net_poll() (which is the netdev->poll callback)
> > and also from spider_net_handle_rxram_full(). 
> > 
> > The rxramfull routine is called from a tasklet that
> > is fired off after a "RX ram full" interrupt is receved.
> > This interrupt is generated when the hardware runs out
> > of space to store incoming packets. We are seeing this
> > interrupt fire when the CPU is heavily loaded, and a
> > lot of traffic is being fired at the device.
> 
> How often does that interrupt happen in that case ?

It is hard to reproduce; it is highly dependent on kernel version
and network config. It seems to occur when the system is somehow
loaded, and the tcp stack is unable to empty out the rx ring in a
timely manner. Jim is able o trigger this trivially for some kernels, 
but not others.

> A better approach is to keep the fast path (ie. poll()) lockless, and in
> handle_rxram_full(), the slow path, protect against poll using
> netif_disable_poll(). Though that means using a work queue, not a
> tasklet, since it needs to schedule.

Yes. Actually, I am thinking of treating this interrupt as if it were
just another RX interrupt. What the original drivers seemed to want to
do was to treat this as some sort of "high priority" rx interrupt, but
there doesn't seem to be any real way of doing this, so it seems simpler
just to rip out the tasklet and leave it at that.

> or you can schedule rx work from the rxramfull interrupt after setting a
> "something bad happened" flag. Then, poll can check this flag and do the
> right thing.

Yes, exactly.

--linas
> 
