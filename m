From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: MSI interrupts and disable_irq
Date: Fri, 05 Oct 2007 16:12:26 -0600
Message-ID: <m1prztgqid.fsf@ebiederm.dsl.xmission.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>
	<20070928200801.28f9bab7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50083 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758364AbXJEWM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:12:56 -0400
In-Reply-To: <20070928200801.28f9bab7@freepuppy.rosehill> (Stephen Hemminger's
	message of "Fri, 28 Sep 2007 20:08:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> On Fri, 28 Sep 2007 22:47:16 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
>
>> Ayaz Abdulla wrote:
>> > I am trying to track down a forcedeth driver issue described by bug 9047 
>> > in bugzilla (2.6.23-rc7-git1 forcedeth w/ MCP55 oops under heavy load). 
>> > I added a patch to synchronize the timer handlers so that one handler 
>> > doesn't accidently enable the IRQ while another timer handler is running 
>> > (see attachment 'Add timer lock' in bug report) and for other processing 
>> > protection.
>> > 
>> > However, the system still had an Oops. So I added a lock around the 
>> > nv_rx_process_optimized() and the Oops has not happened (see attachment 
>> > 'New patch for locking' in bug report). This would imply a 
>> > synchronization issue. However, the only callers of that function are 
>> > the IRQ handler and the timer handlers (in non-NAPI case). The timer 
>> > handlers  use disable_irq so that the IRQ handler does not contend with 
>> > them. It looks as if disable_irq is not working properly.
>> > 
>> > This issue repros only with MSI interrupt and not legacy INTx 
>> > interrupts. Any ideas?
>> 
>> (added linux-kernel to CC, since I think it's more of a general kernel 
>> issue)

I didn't see anything in disable_irq that would cause it to fail in
the suggested way.  But I couldn't quite convince myself we were
race free either.  I didn't see anything that was specific to MSI
that would cause something.  But switching from level to edge
triggered, and to a lower latency delivery path may have caused
some behavior changes.

>> To be brutally frank, I always thought this disable_irq() mess was a 
>> hack both ugly and fragile.  This disable_irq() work that appeared in a 
>> couple net drivers was correct at the time, so I didn't feel I had the 
>> justification to reject it, but it still gave me a bad feeling.
>> 
>> I think the scenario you outline is an illustration of the approach's 
>> fragility:  disable_irq() is a heavy hammer that originated with INTx, 
>> and it relies on a chip-specific disable method (kernel/irq/manage.c) 
>> that practically guarantees behavior will vary across MSI/INTx/etc.
>> 
>> 
>> Based on your report, it is certainly possible that there is a problem 
>> with MSI's desc->chip->disable() method...  but I would actually 
>> recommend working around the problem by making the forcedeth locking 
>> more standardized by removing all those disable_irq() hacks.
>> 
>
> I'll try and clean it up if the author doesn't get to it first.

I took a look at the underlying side of this.

I don't know if the MSI capability for the forcedeth supports a mask
bit or not.  Mine doesn't even have a msi capability.  If it doesn't
support a mask bit the pci spec provides not valid way to mask the
interrupt, so what we do is actually disable the msi capability.
At which point we might get weird INTx interactions.

We have a similar case with ioapics and INTx that also turns
a hardware level disable into a reroute to another irq command.
So I'm going to take a look and see how infrequently we can use
hardware level disabled.

Since it looks like hardware level disables tend to be creatively
implemented I recommend using disable_irq as little as possible.

Eric
