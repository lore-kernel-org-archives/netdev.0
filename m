From: Dan Eble <dane@aiinet.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 14:02:20 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0303271315010.30532-100000@dane-linux.aiinet.com>
References: <3B785392832ED71192AE00D0B7B0D75B539668@aimail.aiinet.com>
Reply-To: <dane@aiinet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <shmulik.hen@intel.com>,
   <bonding-devel@lists.sourceforge.net>,
   <bonding-announce@lists.sourceforge.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>, <linux-net@vger.kernel.org>,
   <mingo@redhat.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <3B785392832ED71192AE00D0B7B0D75B539668@aimail.aiinet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Mar 2003, Linus Torvalds wrote:
> 
> On Thu, 27 Mar 2003, David S. Miller wrote:
> > 
> > Ok, so can we add a:
> > 
> > 	if (irqs_disabled())
> > 		BUG();
> > 
> > check to do_softirq()?
> 
> I'd suggest making it a counting warning (with a static counter per
> local-bh-enable macro expansion) and adding it to local_bh_enable() -
> otherwise it will only BUG()  when the (potentially rare) condition
> happens - instead of always giving a nice backtrace of exact problem 
> spots.

So, to return to my original question...  local_bh_count() > 0 when 
a BH is running or after local_bh_disable().  local_irq_count() > 0 in 
interrupt context, but not necessarily when interrupts are disabled.

This makes checks like the following (in alloc_skb) asymmetric:

    if (in_interrupt() && (gfp_mask & __GFP_WAIT)) {
        static int count = 0;
        if (++count < 5) {
            printk(KERN_ERR "alloc_skb called nonatomically "
                   "from interrupt %p\n", NET_CALLER(size));
            BUG();

In a driver I'm writing, this bug was hidden until I switched from using
write_lock_irqsave() to write_lock_bh().  Shouldn't this bug also be
announced if interrupts are disabled?  (I understand that disabling bh/irq
in the correct order will ensure that this bug is properly detected, but
it seems like a strange policy to rely on correct coding to catch a bug.)

-- 
Dan Eble <dane@aiinet.com>  _____  .
                           |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|
