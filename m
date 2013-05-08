From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Wed, 8 May 2013 16:32:38 -0400
Message-ID: <CAAsGZS5SrH7vJ=dd+2JkpAF7RS1UGv09kU+nCjw-qXhDV7SZTA@mail.gmail.com>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
	<CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com>
	<518968DF.9070008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:47061 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755472Ab3EHUck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 16:32:40 -0400
Received: by mail-la0-f42.google.com with SMTP id fq13so2173196lab.1
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 13:32:38 -0700 (PDT)
In-Reply-To: <518968DF.9070008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 7, 2013 at 4:49 PM, Daniel Borkmann <dborkman@redhat.com> wrote:

>> remember, you were able to figure out what the problem was because of
>> the WARN and the forceful BUG.
>> Is BUG ok? Depends on how you look at it. If you are doing serious
>> network monitoring on a real life appliance
>> we don't really want folks to write crappy application. May be BUG is
>
>
> Right, and now we treat people who write crappy applications with BUG?
>
> BUG is only for consistency checks *within* the kernel and not meant to
> be triggered on purpose from user space.
>

I thought I made myself clear when I said, may be BUG is too harsh :).


>
>> too harsh. But then I don't see a WARN in this patch either (may be I
>> overlooked it).
>
>
> So what's the point? If people see a WARN() in their kernel log they go
> and complain on netdev that AF_PACKET is broken although its their
> application?
>

It's not complaining. Its called bug-reporting. Exactly, by removing
the WARN you deprived the user from fixing him/her buggy application.
Infact, that could have been a kernel bug. Who knows.

Pls re-read the code again. The code will also guard itself when you
start modifying it and forget to check the block-status before calling
it. There are checks like these everywhere. The caller doesn't trust
the callee.

If you don't even print a warning then we will never know what
happened. Again, you were able to see that the user-space was writing
crap because of this very same WARN + BUG. As mentioned earlier, you
can strip the BUG. But we need the WARN back. Use WARN_ONCE.


So this is what you need.

if (status == STATUS_KERNEL) {
...
return;
}
if (status == STATUS_USER)
return;
WARN_ONE();

There are two kinds of users:
1) User-A runs a one-shot capture. The corruption may/may-not happen
during that time.
2) A capture appliance is running 24x7 monitoring a network. If the
corruption does happen then some monitoring process will detect it
(when it scans the kernel-log file) and will raise an alert. Or even
sysadmins will look at the logfiles from time to time.

Your patch does NOT help in case 2). I can't mine the log file because
nothing was printed. This could go on for hours and we will lose all
the capture data during all that time. There are SLAs around
appliances.


> There was already a discussion on netdev with a different BUG macro in
> the TX_RING, where we concluded that it shouldn't be a warn either.
>
>
>>> of concern:
>>>
>>>    prb_retire_current_block() [when block status != TP_STATUS_KERNEL]
>>>    prb_open_block() [when block_status != TP_STATUS_KERN

Those checks are there today. But no guarantees when the next person
who is modifying the code does so without understanding it first.


>>>
>>> Calls to prb_open_block() are guarded by ealier checks if block_status
>>> is really TP_STATUS_KERNEL (racy!), but the first one BUG() is easily

racy? How?



> Yoda condition is called if you compare ``CONSTANT == var'', actually the
> other way round as it should be in CodingStyle. But that's not the big issue

FYI: Long back compilers weren't smart enough to warn the user about
if (var = CONSTANT), so you had to teach yourself to always write
(CONSTANT == var).
