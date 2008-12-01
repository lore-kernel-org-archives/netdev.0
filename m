From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Mon, 01 Dec 2008 11:37:41 +0100
Message-ID: <1228127861.16263.590.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <200811271602.16128.opurdila@ixiacom.com>
	 <1227799867.16263.517.camel@ecld0pohly>
	 <200811272053.10009.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62811 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbYLAKhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 05:37:45 -0500
In-Reply-To: <200811272053.10009.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 18:53 +0000, Octavian Purdila wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Thu, 27 Nov 2008 16:31:07 +0100
> > On Thu, 2008-11-27 at 14:02 +0000, Octavian Purdila wrote:
> > > Let me throw in another idea: when enabling hw timestamps could we
> > > allocate a bigger skb and store the hw timestamp somewhere in the skb
> > > data buffer?
> >
> > How does the socket layer detect that the HW timestamp is available in
> > the larger skb data buffer, and where?
> >
> 
> It doesn't know, thats why we need help from the device (the new netdev 
> method).

That just pushes the problem into the device driver: when it gets passed
a skb pointer, how can it tell reliably that the data buffer contains
the HW timestamping information?

I agree with Oliver, this approach doesn't look maintainable to me. I
don't know enough about the kernel to tell whether it works reliably at
the moment, much less whether it will work in the future.

Oliver asked:
> One additional question for Patrick:
> As you wrote that your hw timestamp contained in the new skbuff-field is 
> already cocked ... is there any identifier that tells the userspace 
> application about the type of hw timestamp he gets (e.g. cocked, raw 
> registers, offset to whatever, etc.) ?

In the proposed API the userspace application gets three time stamps:
software, "cooked" hardware time stamp (converted to nanoseconds by the
driver, but not tampered with in any other way), hardware time stamp
converted to system time. Each of these may be missing (not available,
couldn't be calculated). So yes, the userspace application knows what it
got and can pick the value that it needs.

Oliver suggested:
> What about just creating a new pointer in the struct skbuff that points 
> to a struct hwstamp when it is available OR the pointer is NULL when no 
> hwstamps are available.

I like this better than tampering with the data buffer pointers
implicitly because it enables usages of the additional information
inside the kernel itself. It's similar to skb_shared_info, except that
it is not allocated for all skbs.

The skb_shared_info is always at the end of the data buffer. Assume that
we have a new __netdev_alloc_hw_skb() which increases the allocated data
buffer to make room for the additional struct hwtstamp (either before
skb_shared_info or after). I cannot think of a way how the rest of the
kernel can tell that this additional data is available by just looking
at the existing head/data/end fields in a skb - if I missed something,
please let me know.

So it seems to me that we need the additional 32 bit offset (or pointer,
on 32 bit architectures) in skb which points towards the struct
hwtstamp. But that's actually less than the additional 64 bit which hold
the time stamp value, as in the current patch. I'll give it a few more
days for further debate, then try out this approach.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

