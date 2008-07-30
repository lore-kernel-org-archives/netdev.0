From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Wed, 30 Jul 2008 10:51:04 +0200
Message-ID: <1217407864.30512.111.camel@ecld0pohly>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
	 <1217343163.30512.34.camel@ecld0pohly> <20080729085457.033a9fd2@extreme>
	 <200807291911.10364.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Ingo Oeser <netdev@axxeo.de>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63087 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759576AbYG3Iw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 04:52:59 -0400
In-Reply-To: <200807291911.10364.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 19:11 +0300, Octavian Purdila wrote:
> On Tuesday 29 July 2008, Stephen Hemminger wrote:
> >
> > In my sky2 sample code, I took a different approach:
> >  1. Why have HW timestamps different than existing timestamps? If you
> >     just use existing timestamp, no socket API is needed.
> 
> I agree that is a much better approach if you are ok with the variance 
> introduced by synchronizing the HW timestamps with the CPU clock.
> 
> But if you want to precisely measure one-way delays, and if you have the hw 
> timestamp units synchronized across the nodes, then you need the hardware 
> timesetamp. 
> 
> Or maybe I am stuck on this idea because of doing things this way for a long 
> time and there is a better solution?

No, I think you have a valid case here. Synchronizing the clocks inside
the NICs can be useful:
      * for analysing the accuracy of clock synchronization (that's what
        I have done in the PTP paper that I mentioned earlier)
      * for highly accurate network measurements (your use case)
      * advanced usages of the NIC clock (for example, Intel's new NIC
        can use the NIC clock as trigger for hardware events - this may
        be useful for certain embedded hardware designs)

Any kind of transformation into system time gets in the way when trying
to do that. Having said that, I'm fine with a solution which only
exposes transformed hardware time stamps to the user space app. My goal
is the IMHO more common system time synchronization and therefore direct
access to raw hardware time stamps is not needed.

But there's one caveat: the fallback of returning software time stamps
to the app if no hardware time stamp is available will affect accuracy
of system time synchronization because time stamps will jump when
switching from one method to the other. That is primarily because a) the
time stamp is generated at a different point in the packet processing
pipeline but also because b) the NIC->system time conversion will
introduce a certain error, which is not present in time stamps taken in
software directly.

I had tried to use the system time time as fallback in the patched PTPd
when no hardware time stamp could be taken (which happened occassionally
under load). It didn't work well at all, simply ignoring the packet and
resending another Sync or DelayRequest was much better.

For received packets, the fallback would happen in
__sock_recv_timestamp(), as Ingo pointed out. My suggestion is to
introduce a new socket flag which indicates whether the app wants the
fallback or not.

For sent packets, Tavi's proposal is that "If timestamping is requested
and no timestamping is done in the device driver (potentially this may
use hardware timestamping), it will be done in software after the
device's start_hard_xmit routine." Perhaps the parameter of the new
SO_TXTIMESTAMP can be a multi-value? 0 = no TX time stamps, 1 = TX time
stamp in hardware if possible with software as fallback, 2 = only
hardware TX time stamps. Either that, or use the same new socket flag as
for RX time stamps.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

