From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
 =?utf-8?q?possibly=09caused_by?= netem)
Date: Fri, 3 Jul 2009 03:31:31 +0200
Message-ID: <200907030331.32531.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8";
  format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:41494 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZGCBbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 21:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2009 01:59 PM, Andres Freund wrote:
> On 07/02/2009 01:54 PM, Jarek Poplawski wrote:
>> On Thu, Jul 02, 2009 at 01:43:49PM +0200, Andres Freund wrote: ...
>>> I will start trying to place the issue by testing with existing
>>> kernels between 2.6.30 and now.
>> If you can afford your time of course this would be very helpful.
> Well. Waiting for the issue to resolve itself would cost time as well
> ;-) I wont be able to finish this today, but perhaps some reduction
> of the search space will be enough.
I lied.

> I placed it between 2.6.30 and
> 03347e2592078a90df818670fddf97a33eec70fb (v2.6.30-5415-g03347e2) so
> far.
Ok. I finally see the light. I bisected the issue down to
eea08f32adb3f97553d49a4f79a119833036000a :  timers: Logic to move non
pinned timers

Disabling timer migration like provided in the earlier commit stops the issue 
from occuring.

That it is related to timers is sensible in the light of my findings, that I 
could trigger the issue only when using delay in netem - that is the codepath 
using qdisc_watchdog...

Andres

Repasted original problem description for newly CC'ed people:
> While playing around with netem (time, not packet count based loss-
> bursts) I experienced soft lockups several times - to exclude it was
> my modifications causing this I recompiled with the original and it
> is still locking up. I captured several of those traces via the
> thankfully still working netconsole. The simplest policy I could
> reproduce the error with was: tc qdisc add dev eth0 root handle 1:
> netem delay 10ms loss 0
>
> I could not reproduce the error without delay - but that may only be
> a timing issue, as the host I was mainly transferring data to was on
> a local network. I could not reproduce the issue on lo.
>
> The time to reproduce the error varied from seconds after executing
> tc to several minutes.
>
> Traces 5+6 are made with vanilla
> 52989765629e7d182b4f146050ebba0abf2cb0b7
>
> The earlier traces are made with parts of my patches applied, and
> only included for completeness as I don't believe my modifications
> were causing this and all traces are different, so it may give some
> clues.
>
> Lockdep was enabled but did not diagnose anything relevant (one dvb
> warning during bootup).
>
> Any ideas for debugging?

