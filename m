From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 25 Aug 2009 14:24:06 -0700
Message-ID: <m1k50r8u4p.fsf@fess.ebiederm.org>
References: <200903041828.49972.m.bueker@berlin.de>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	<1242077392.3716.15.camel@lap75545.ornl.gov>
	<4A09DC3E.2080807@googlemail.com>
	<1242268709.4979.7.camel@obelisk.thedillows.org>
	<4A0C6504.8000704@googlemail.com>
	<1242328457.32579.12.camel@lap75545.ornl.gov>
	<4A0C7443.1010000@googlemail.com>
	<1243042174.3580.23.camel@obelisk.thedillows.org>
	<m1skfkrik2.fsf@fess.ebiederm.org>
	<1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
	<m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org>
	<1250973787.3582.14.camel@obelisk.thedillows.org>
	<m1r5v0ogvw.fsf@fess.ebiederm.org>
	<1251169150.4023.11.camel@obelisk.thedillows.org>
	<m1prajabk8.fsf@fess.ebiederm.org>
	<1251232848.9607.15.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?Q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46921 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756082AbZHYVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 17:24:12 -0400
In-Reply-To: <1251232848.9607.15.camel@lap75545.ornl.gov> (David Dillow's message of "Tue\, 25 Aug 2009 16\:40\:48 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Dillow <dave@thedillows.org> writes:

> On Tue, 2009-08-25 at 13:22 -0700, Eric W. Biederman wrote:
>> David Dillow <dave@thedillows.org> writes:
>> > I'm not real happy with the interrupt handling in the driver; it makes a
>> > certain amount of sense to split the MSI vs non-MSI interrupt cases out.
>> > It also means another pass through re-auditing things against the vendor
>> > driver. That's more work than I'm able to commit to at the moment.
>> >
>> > I've not been able to reproduce it locally on my r8169d, running for ~30
>> > minutes straight at full speed. I've not tried running it in UP, though.
>> > Perhaps I can do that tomorrow.
>> >
>> > Here's a possible patch to mask the NAPI events while we're running in
>> > NAPI mode. I'm not sure it is going to help, since the intr_mask was
>> > 0xffff when you hit the loop guard, so I left it in for now.
>> 
>> Interesting.
>> 
>> If I understand this correctly the situation is that we have on the
>> chip there is correct logic for a level triggered interrupt and that
>> the msi logic sits on it and sends an event when the interrupt signal
>> goes high, but when we acknowledge some bits but not all it does not
>> send another interrupt.
>
> Correct, we have to acknowledge all current outstanding event sources
> before we get another MSI interrupt. It looks like the MSI interrupt is
> triggered on the edge transition of a logical OR of all irq sources.
>
>> Baring playing games with what version of the card has working logic
>> and which does not we seem to have to simple choices (if we don't want
>> to loop possibly forever).
>> - Don't use the msi logic on this card.
>> - Move all of the logic into rtl8169_poll and only come out of NAPI
>>   mode when we have caught up with all of the interrupt work.
>> 
>> Is that how you understand the hardware issue you are trying to work
>> around?
>
> That's how I understood the issue I was working around with the
> problematic patch, but I thought I had covered both issues fairly well
> without having to split the handling any further -- we ACK all existing
> sources each pass through the loop, so we'll get a new interrupt on the
> unmasked events, but not on ones we've masked out for NAPI until NAPI
> completes and unmasks them.


> I'm curious how you managed to receive an packet between us clearing the
> all current sources and reading the current source list continuously for
> 60+ seconds -- the loop is basically


> status = get IRQ events from chip
> while (status) {
> 	/* process events, start NAPI if needed */
> 	clear current events from chip
> 	status = get IRQ events from chip
> }
>
> That seems like a very small race window to consistently hit --
> especially for long enough to trigger soft lockups.

Interesting indeed.  When I hit the guard we had popped out of NAPI
mode while we were in the loop.  The only way to do that is if
poll and interrupt were running on different cpus.

I am a bit curious about TxDescUnavail.  Perhaps we had a temporary
memory shortage and that is what was screaming?  I don't think we do
anything at all with that state.

Perhaps the flaw here is simply not masking TxDescUnavail while we are
in NAPI mode?

Eric
