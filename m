From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe select_queue broken in 2.6.28
Date: Tue, 6 Jan 2009 10:40:38 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0901060909280.6204@ppwaskie-MOBL2.amr.corp.intel.com>
References: <E1LKBaB-0007kB-7f@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40483 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbZAFSrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 13:47:05 -0500
In-Reply-To: <E1LKBaB-0007kB-7f@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jan 2009, Herbert Xu wrote:

> Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:
> > 
> > I understand why you want to remove this, but at the same time it is 
> > something that is useful if we don't abuse it.  I know for a fact this 
> > function pointer is very useful for routing performance setups, where 
> > binding a Tx queue to the CPU is very useful.  Jesse actually did the work 
> > on testing and getting good results with this.
> 
> Sure.  But that is not driver-specific.  The only reason to do
> an override is if the hash needs to be driver-specific.  So far
> the only reasons that have been given are deficiencies in the
> current hash, rather than a genuine need by the driver.

I agree with your statement 100%.  I do have a genuine need though, now 
that I understand why the select_queue was being overridden for DCB.  When 
ixgbe is running in DCB mode, traffic will be filtered into the traffic 
classes (i.e. Tx queues) via tc filters.  Since each queue has a specific 
priority in the hardware queueing, it's important that traffic isn't 
distributed across queues without specifically being filtered there.  The 
best way to address this is to have select_queue return Tx queue 0, which 
is the lowest priority queue for DCB.  Then if we exit DCB mode, we return 
select_queue to NULL, so the kernel's hash takes back control.

If that sounds reasonable, I can fix the original problem Stephen pointed 
out that select_queue in DCB isn't using the netdev_ops pointer.  I do 
still believe the existence of this function pointer is necessary; please 
consider the DCB case and let me know if you agree or not.

Cheers,
-PJ Waskiewicz
