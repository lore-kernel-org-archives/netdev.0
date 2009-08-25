From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 25 Aug 2009 13:22:15 -0700
Message-ID: <m1prajabk8.fsf@fess.ebiederm.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?Q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756158AbZHYUW0@vger.kernel.org>
In-Reply-To: <1251169150.4023.11.camel@obelisk.thedillows.org> (David Dillow's message of "Mon\, 24 Aug 2009 22\:59\:10 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> writes:

> On Mon, 2009-08-24 at 17:51 -0700, Eric W. Biederman wrote:
>> When I decode the bits in status they are TxOK, RxOK and TxDescUnavail so it looks
>> there is some bidirectional communication going on.
>> 
>> Do we really want to loop when those bits are set?
>
> Maybe not when only those bits are set, but I worry that we would trade
> one race for another where we stop getting interrupts from the card.
>
>> Perhaps we want to remove them from rtl_cfg_infos for the part?
>
> Then you'd never get an interrupt for them in the first place, I think.
>
> I'm not real happy with the interrupt handling in the driver; it makes a
> certain amount of sense to split the MSI vs non-MSI interrupt cases out.
> It also means another pass through re-auditing things against the vendor
> driver. That's more work than I'm able to commit to at the moment.
>
> I've not been able to reproduce it locally on my r8169d, running for ~30
> minutes straight at full speed. I've not tried running it in UP, though.
> Perhaps I can do that tomorrow.
>
> Here's a possible patch to mask the NAPI events while we're running in
> NAPI mode. I'm not sure it is going to help, since the intr_mask was
> 0xffff when you hit the loop guard, so I left it in for now.

Interesting.

If I understand this correctly the situation is that we have on the
chip there is correct logic for a level triggered interrupt and that
the msi logic sits on it and sends an event when the interrupt signal
goes high, but when we acknowledge some bits but not all it does not
send another interrupt.

Baring playing games with what version of the card has working logic
and which does not we seem to have to simple choices (if we don't want
to loop possibly forever).
- Don't use the msi logic on this card.
- Move all of the logic into rtl8169_poll and only come out of NAPI
  mode when we have caught up with all of the interrupt work.

Is that how you understand the hardware issue you are trying to work
around?

Eric
