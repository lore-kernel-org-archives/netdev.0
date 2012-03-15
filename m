From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Thu, 15 Mar 2012 13:18:26 -0400
Message-ID: <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: e1000-devel@lists.sourceforge.net, jacob.e.keller@intel.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com,
	john.stultz@linaro.org, tglx@linutronix.de
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:60318 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965164Ab2CORS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 13:18:26 -0400
Received: by mail-pz0-f46.google.com with SMTP id r28so4800802daj.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 10:18:26 -0700 (PDT)
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
> the timecompare method
>
> This commit removes the legacy timecompare code from the igb driver and
> offers a tunable PHC instead.

Richard (and others who contributed),

This ptp stuff is great work(time-sync sources, pkt-time,
system-time)! Now, I've a few questions :) :

1) how can I use igb->PHC to set/discipline my system time?
 a) clock_gettime(IGB_CLK_ID...);
 b) clock_settime(REAL_TIME,...) ? Good/bad idea?

2) what is this deadlock from intel's datasheet
(http://download.intel.com/design/network/datashts/82576_Datasheet.pdf)
- goto pg 426
  2.1) Is this applicable? If not please ignore this question.
  2.2) Do we need to worry about it. Just asking because a quick
visual scan didn't pull up - TIMADJL/H.

3) Testing IGB PHC (couple of months from now because I'm busy with
something else):

   3.1) CardX(It's a different non-intel NIC) and CardY(intel) are in
hostA. Both cards will use the same time-source Z.
   3.2) CardX is time-sync'd using PTP.
   3.3) CardY - is a dual port card. Port 0 will receive PTP packets
via time-srcZ.
   3.4) Wait for some time for both the cards to get in-sync.
   3.5) feed same traffic to Card X and CardY-Port1.
   3.6) measure time-difference across packets from different NICs on hostA.

   Is this a good test configuration? Now, ofcourse there will be some
delta but the intention is to get a feel. See how far off are both the
adapters.

4) possible contention on tmreg_lock?
I will read previous emails/patches shortly but I was thinking - what
if there are many readers who would like to use PHC as reference time?
Then do we want them to block the driver who wants to time-stamp the
packet?
 igb_gettime->spin_lock::tmreg_lock         <---contention--->  driver
->igb_systim_to_hwtstamp->spin_lock::tmreg_lock


thanks
Chetan
