From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 25 Aug 2009 17:46:35 -0400
Message-ID: <1251236795.9607.34.camel@lap75545.ornl.gov>
References: <200903041828.49972.m.bueker@berlin.de>
 <1242001754.4093.12.camel@obelisk.thedillows.org>
 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
 <1242077392.3716.15.camel@lap75545.ornl.gov> <4A09DC3E.2080807@googlemail.com>
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
 <1251232848.9607.15.camel@lap75545.ornl.gov> <m1k50r8u4p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755419AbZHYVqh@vger.kernel.org>
In-reply-to: <m1k50r8u4p.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-08-25 at 14:24 -0700, Eric W. Biederman wrote:
> David Dillow <dave@thedillows.org> writes:
> > I'm curious how you managed to receive an packet between us clearing the
> > all current sources and reading the current source list continuously for
> > 60+ seconds -- the loop is basically
> 
> 
> > status = get IRQ events from chip
> > while (status) {
> > 	/* process events, start NAPI if needed */
> > 	clear current events from chip
> > 	status = get IRQ events from chip
> > }
> >
> > That seems like a very small race window to consistently hit --
> > especially for long enough to trigger soft lockups.
> 
> Interesting indeed.  When I hit the guard we had popped out of NAPI
> mode while we were in the loop.  The only way to do that is if
> poll and interrupt were running on different cpus.

That is the normal case on an SMP machine, but again that race window
should be fairly small as well -- from the __napi_schedule() to the
acking of the interrupt source is only a few lines of code, most of
which is in an error case that is skipped. Granted there may be a fair
number of instructions there if debugging or tracing is on -- I've not
checked -- but even then hitting that race consistently for 60+ seconds
doesn't seem likely.

Being out of NAPI in the guard may be a red herring -- it doesn't tell
us how long you were out of NAPI when you hit it. If there's a stuck bit
somewhere, then you could have been out of NAPI after the first cycle
and we'd have no way to tell. You could add some variables to keep track
of the status and mask values, and how long ago they changed to see.

> I am a bit curious about TxDescUnavail.  Perhaps we had a temporary
> memory shortage and that is what was screaming?  I don't think we do
> anything at all with that state.

TxDescUnavail is normal -- it means the chip finished sending everything
we asked it to.

> Perhaps the flaw here is simply not masking TxDescUnavail while we are
> in NAPI mode?

No, we never enable it on the chip, and it gets masked out when we
decide if we want to go to NAPI mode -- it is not set in tp->napi_event:

	if (status & tp->intr_mask & tp->napi_event) {
