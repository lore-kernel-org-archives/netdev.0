From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Wed, 4 Feb 2009 09:33:07 -0700
Message-ID: <e9c3a7c20902040833o760bf450g658e7c7ff456b023@mail.gmail.com>
References: <20090203134721.GA11069@pingi.kke.suse.de>
	 <200902041418.09630.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.cz>,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:20257 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641AbZBDQdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 11:33:08 -0500
In-Reply-To: <200902041418.09630.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2009 at 8:48 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Wednesday 04 February 2009 00:17:21 Karsten Keil wrote:
>> The refcount is a per CPU atomic variable, module_refcount() simple add
>> in a fully unprotected loop (not disabled irqs, not protected against
>> scheduling) all per cpu values.
>
> Hi Karsten,
>
>   Yes, the BUG_ON() is overly aggressive.  And I really hate __module_get,
> and it looks like most of the callers are completely bogus.  The watchdog
> drivers use it to nail themselves in place in their open routines: this is
> OK, if a bit weird.
>
>   We should only use __module_get() when you *can't handle* failure;
> otherwise you should accept that the admin did rmmod --wait and don't use the
> module any further.
>
>  dmaengine.c seems to be taking liberties like this.  AFAICT it can error
> out, so why not just try_module_get() always?

Currently there is no feedback loop for clients calling
dmaengine_get().  It simply means "I want to do offload, pin any
offload resources you may see, and don't let the resource leave until
dmaengine_ref_count == 0".  Even if we always called try_module_get()
we would still need to wait until dmaengine_ref_count reached zero to
be sure no transactions are in flight, effectively ignoring module_get
failures.

However, dma-driver module removal is still in the central control of
the administrator as downing all network interfaces and unloading the
async_tx api (i.e. raid456) will kill all dmaengine references.  We
just have the caveat highlighted below:

modprobe raid456
ifup eth0
rmmod --wait ioat_dma &
ifup eth1
modprobe -r raid456
ifdown eth0  <-- module removal succeeds here in a perfect world
ifdown eth1 <-- module removal currently succeeds here

Regards,
Dan
