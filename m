From: Bill Fink <billfink@mindspring.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- revert for
 2.6.26-rc1 failed
Date: Thu, 14 Aug 2008 06:04:33 -0400
Message-ID: <20080814060433.684c4fe5.billfink@mindspring.com>
References: <737832.54450.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:57705 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752423AbYHNKEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 06:04:42 -0400
In-Reply-To: <737832.54450.qm@web82101.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, 13 Aug 2008, David Witbrodt wrote:

> [Yinghai, please note that I did not request a patch to revert the
> problem commit.  I was merely experimenting -- on my own time, so
> you folks would not have to bother -- to see if I could make it
> work.  I should have made that more clear!  Having said that, I am
> glad to test changes of any kind on my machine:  reverts, code for
> debugging or info, experiments, etc.]

I'm not sure Yinghai's revert patch is completely equivalent to
a revert of the original problematic commit, by a side-by-side
comparison of the original commit with his recent revert patch,
but then I don't really know that code at all.

In the original code there was a section (in e820_reserve_resources()):

#ifdef CONFIG_KEXEC
		   if (crashk_res.start != crashk_res.end)
			   request_resource(res, &crashk_res);
#endif

If you don't have CONFIG_KEXEC defined in your .config, which is
probably the case, then you would never request a crashk_res resource.
But in the code after the original commit, it unconditionally calls
(in reserve_crashkernel()):

	   crashk_res.start = crash_base;
	   crashk_res.end   = crash_base + crash_size - 1;
	   insert_resource(&iomem_resource, &crashk_res);

And after Yinghai's revert patch it still does (in reserve_crashkernel()):

        crashk_res.start = crash_base;
        crashk_res.end   = crash_base + crash_size - 1;
        crashk_res_ptr = &crashk_res;

and (in setup_arch()):

	num_res = 3;
	if (crashk_res_ptr) {
		res_kernel[num_res] = crashk_res_ptr;
		num_res++;
	}
	e820_reserve_resources(res_kernel, num_res);

then (in e820_reserve_resources()):

			for (j = 0; j < nr_res_k; j++) {
				if (!res_kernel[j])
					continue;
				request_resource(res, res_kernel[j]);
			}

which for j == 3 is:

	request_resource(res, &crashk_res);

Now it would appear that the new:

	insert_resource(&iomem_resource, &crashk_res);

or new:

	request_resource(res, &crashk_res);

should be noops.  But if for any reason crash_size is not zero,
then there could be a difference.  I have no idea if this is at all
significant, but I thought I'd point it out just in case.

						-Bill
