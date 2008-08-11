From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Mon, 11 Aug 2008 13:25:45 +0200
Message-ID: <20080811112545.GE6925@elte.hu>
References: <859858.77737.qm@web82105.mail.mud.yahoo.com> <20080809135650.GE8125@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Witbrodt <dawitbro@sbcglobal.net>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:37395 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342AbYHKL0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 07:26:10 -0400
Content-Disposition: inline
In-Reply-To: <20080809135650.GE8125@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > I'm _way_ over my head in this discussion, but here's some more food 
> > for thought.  Last weekend, when I first tried 2.6.26 and discovered 
> > the freeze, I thought an error of my own in .config was causing it.  
> > Before I ever sought help, I made about a dozen experiments with 
> > different .config files.
> > 
> > One series of those experiments involved turning off most of the 
> > kernel... including CONFIG_INET.  The kernel still froze, but when 
> > entering pci_init().  (This info can be read in my original post to 
> > the Debian BTS, which I have provided links for a couple of times in 
> > this LKML thread.  I even went further and removed enough that the 
> > freeze was avoided, but so much of the kernel was missing that my 
> > init scripts couldn't mount a hard disk any more.  Trying to restore 
> > enough to allow HD mounting just brought back the freeze.)
[...]
> 
> RCU doesn't use HPET directly.  Most of its time-dependent behavior 
> comes from its being invoked from the scheduling-clock interrupt.

such freezes frequently occur due to the plain lack of timer interrupts.

As networking's rcu_synchronize() is one of the first calls in the 
kernel that relies on a timer IRQ hitting the CPU, it would be the first 
one that "freezes". It's not a real freeze though: it's the lack of 
timer events breaking RCU completion. (RCU has an implicit and somewhat 
subtle dependency on timer irqs periodically hitting the CPU)

You can probably verify this by adding something like this to 
kernel/timer.c's do_timer() function:

   if (printk_ratelimit())
	printk("timer irq hit, jiffies: %ld\n", jiffies);

Yinghai, do you have any ideas about this particular problem? One theory 
would be that your e820 changes might have caused a shuffling of 
resources that made the hpet's timer IRQ generation inoperable.

David, it would be nice to check whether tip/master still locks up for 
you:

    http://people.redhat.com/mingo/tip.git/README

just to make sure no pending fix resolves your issue. (the bug is 
probably still present, but might be worth checking nevertheless.)

	Ingo
