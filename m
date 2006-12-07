From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 3/16] Spidernet RX Locking
Date: Thu, 7 Dec 2006 11:50:46 -0600
Message-ID: <20061207175046.GB4614@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com> <20061206233134.GC4649@austin.ibm.com> <4577E850.6040500@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:32796 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162589AbWLGRvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 12:51:11 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB7Hosaq022162
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 12:50:54 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB7HosTo426398
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 10:50:54 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB7HoqX6001269
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 10:50:53 -0700
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4577E850.6040500@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 05:09:20AM -0500, Jeff Garzik wrote:
> Linas Vepstas wrote:
> >The RX packet handling can be called from several
> >places, yet does not protect the rx ring structure.
> >This patch places the ring buffer pointers under a lock.
> >
> >Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> >Cc: James K Lewis <jklewis@us.ibm.com>
> >Cc: Arnd Bergmann <arnd@arndb.de>
> 
> This is a HUGELY invasive patch.  A sledgehammer.

I am rather unlear what you perceive as being invasive, 
since the patch summary states:

 drivers/net/spider_net.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

> What /specifically/ are these "several places", 

spider_net_decode_one_descr() is called from
spider_net_poll() (which is the netdev->poll callback)
and also from spider_net_handle_rxram_full(). 

The rxramfull routine is called from a tasklet that
is fired off after a "RX ram full" interrupt is receved.
This interrupt is generated when the hardware runs out
of space to store incoming packets. We are seeing this
interrupt fire when the CPU is heavily loaded, and a
lot of traffic is being fired at the device.

> and what other 
> non-sledgehammer approaches were discarded before arriving at this one?

Well, I'm not that good at kernel programming, so I guess
I did not perceive this as a "sledgehammer."  And alternative
approach is to simply ignore the rxramfull interrupt entirely,
and depend on poll() do all the work.   I'll try this shortly.

--linas
