From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 11:08:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303271104270.31459-100000@home.transmeta.com>
References: <Pine.LNX.4.33.0303271315010.30532-100000@dane-linux.aiinet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <shmulik.hen@intel.com>,
   <bonding-devel@lists.sourceforge.net>,
   <bonding-announce@lists.sourceforge.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>, <linux-net@vger.kernel.org>,
   <mingo@redhat.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Eble <dane@aiinet.com>
In-Reply-To: <Pine.LNX.4.33.0303271315010.30532-100000@dane-linux.aiinet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, 27 Mar 2003, Dan Eble wrote:
> 
> This makes checks like the following (in alloc_skb) asymmetric:
> 
>     if (in_interrupt() && (gfp_mask & __GFP_WAIT)) {
>         static int count = 0;
>         if (++count < 5) {
>             printk(KERN_ERR "alloc_skb called nonatomically "
>                    "from interrupt %p\n", NET_CALLER(size));
>             BUG();
> 
> In a driver I'm writing, this bug was hidden until I switched from using
> write_lock_irqsave() to write_lock_bh().  Shouldn't this bug also be
> announced if interrupts are disabled?

Yeah. It should also probably use "in_atomic()" instead of 
"in_interrupt()", since that also finds people who have marked themselves 
non-preemptible.

So what the test SHOULD look like is this:

	if (gfp_mask & __GFP_WAIT) {
		if (in_atomic() || irqs_disabled()) {
			static int count = 0;
			...
		}
	}

which should catch all the cases we really care about.

		Linus
