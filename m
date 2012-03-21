From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Wed, 21 Mar 2012 11:00:59 -0400
Message-ID: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:61791 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392Ab2CUPBA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 11:01:00 -0400
Received: by dajr28 with SMTP id r28so1707340daj.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 08:01:00 -0700 (PDT)
In-Reply-To: <20120316065537.GB2199@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 2:55 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Mar 15, 2012 at 01:18:26PM -0400, chetan loke wrote:
>>
>> 1) how can I use igb->PHC to set/discipline my system time?
>> =C2=A0a) clock_gettime(IGB_CLK_ID...);
>> =C2=A0b) clock_settime(REAL_TIME,...) ? Good/bad idea?
>
> This is a very crude method, and it will cause frequent jumps in your
> system clock.

Of course it's crude :). I wanted to make sure if my understanding was =
correct.



>> 4) possible contention on tmreg_lock?
>> I will read previous emails/patches shortly but I was thinking - wha=
t
>> if there are many readers who would like to use PHC as reference tim=
e?
>> Then do we want them to block the driver who wants to time-stamp the
>> packet?
>> =C2=A0igb_gettime->spin_lock::tmreg_lock =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 <---contention---> =C2=A0driver
>> ->igb_systim_to_hwtstamp->spin_lock::tmreg_lock
>
> Under normal use cases, I would not expect much contention at all.
>

Once PHC->gettime goes live(aka exported to user space), we can't
really control how users will use it in their applications. There
could be 100+ apps all trying to get real-time from the network to do
some time-keeping stuff. They might pound the ioctls at high rate. The
last thing we would want is to self-induce a light weight DOS. What
Eric Dumazet mentioned in the very first patch set seems like a good
comment. seqlock or whatever it is we use for jiffies.
We shouldn't let get_time block network traffic under cases when there
is high load and large number of threads are pounding get-time.
Reader's *must* wait.


reminder to myself: once this patch is applied, tpacket_v3 will
break(not because of spinlock but in general) under specific
conditions. Fix tpacket_v3.


> HTH,
>
> Richard

Chetan
