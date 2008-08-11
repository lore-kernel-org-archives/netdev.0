From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH diagnostic] Re: HPET regression in 2.6.26 versus 2.6.25
	-- RCU problem
Date: Mon, 11 Aug 2008 09:22:41 -0700
Message-ID: <20080811162241.GF6762@linux.vnet.ibm.com>
References: <433343.88181.qm@web82107.mail.mud.yahoo.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46385 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYHKQW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 12:22:56 -0400
Content-Disposition: inline
In-Reply-To: <433343.88181.qm@web82107.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 09:04:12AM -0700, David Witbrodt wrote:
> 
> I didn't check my email yesterday -- sorry about that, but sometimes life
> intervenes -- so I'm a bit late replying.
> 
> Also, I see several messages relevant to this thread in my inbox:  I have
> decided to address each in order, so that I don't mix something up and do
> something foolish.
> 
> 
> 
> > And here is the patch.  It is still a bit raw, so the results should
> > be viewed with some suspicion.  It adds a default-off kernel parameter
> > CONFIG_RCU_CPU_STALL which must be enabled.
> 
> Thanks for the patch.  I had a problem applying the patch because I
> have not yet transitioned my email system from my old machine to my new
> 3-system home network setup.  (I used to share a data partition between
> Windows and Linux so that my archives would stay in sync; my new setup
> will allow keeping the POP downloads on one machine, and sharing the
> archives via IMAP, but even since May I still haven't gotten around to 
> it.)
> 
> My ISP's webmail interface altered the whitespace, and I'm so new to
> git that I couldn't figure out how to keep it from rejecting the
> patch.  I had updated Linus' git tree to 2.6.27-rc2, and when I saw
> that your patch was against something in 2.6.27-rc1 I thought this
> might be the problem.  Visually inspecting the files, I saw that the
> lines matched perfectly, other than whitespace, so I just gave up and
> applied the patches manually.
> 
> I ran 'make menuconfig', but nothing about your new feature was asked.
> Then I realized that I had changed the .config to CONFIG_PREEMPT because
> of an experiment you had my try a few days ago.  When I disabled that,
> I was able to see the new option and enable it.
> 
> The kernel built fine, so I installed and rebooted...
> 
> 
> > Rather than exponential backoff, it backs off to once per 30 seconds.
> > My feeling upon thinking on it was that if you have stalled RCU grace
> > periods for that long, a few extra printk() messages are probably the
> > least of your worries...
> 
> Well, I was hoping to see something interesting.  I ran it with parameters
> "debug initcall_debug", and it locked up at the same place.  I let it for
> 15 minutes, in case of some delayed reaction.  Nada.

Interesting.  The causes could be:

o	Scheduling-clock interrupts aren't happening, as Ingo suggested.

o	All the CPUs are spinning with hard irqs disabled, or are
	otherwise AWOL.

And perhaps other issues as well.

							Thanx, Paul

> The output was nearly identical to what I posted last Tuesday (see
> http://www.uwsg.indiana.edu/hypermail/linux/kernel/0808.0/2224.html).
> Here are the last few lines:
> ==================================
> [snip]
> calling pci_bios_assign_resources+0x0/0x8b
> pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
> pci 0000:00:01.0:   IO window: 0xe000-0xefff
> pci 0000:00:01.0:   MEM window: 0xfdd00000-0xfdefffff
> pci 0000:00:01.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
> pci 0000:00:14.4: PCI bridge, secondary bus 0000:02
> pci 0000:00:14.4:   IO window: 0xd000-0xdfff
> pci 0000:00:14.4:   MEM window: 0xfdc00000-0xfdcfffff
> pci 0000:00:14.4:   PREFETCH window: 0x000000fdf00000-0x000000fdffffff
> initcall pci_bios_assign_resources returned 0 after 285702 msecs
> calling inet_init+0x0/0x250
> NET: Registered protocol family 2
> ===== END OUTPUT =================
> 
> The only difference in the output was trivial:  "285696 msecs" became
> "285702 msecs".  None of the printk()'s from your driver were executed.
> 
> (As I mentioned on Tuesday, that number of milliseconds is WAY off, and
> it still bothers me.  The total time from the GRUB screen disappearing
> to the last line printed is < 5 secs (maybe < 3 secs), not 285 secs!)
> 
> Moving on to the other LKML messages....
> 
> Thanks,
> Dave W.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
