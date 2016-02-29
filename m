From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 05:58:09 +0100
Message-ID: <1456721889.3488.67.camel@gmail.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160228170109.GA16322@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-02-28 at 18:01 +0100, Francois Romieu wrote:
> Mike Galbraith <umgwanakikbuti@gmail.com> :
> [...]
> > Hrm, relatively new + tasklet woes rings a bell.  Ah, that..
> > 
> > 
> > What's worse is that at the point where this code was written it was
> > already well known that tasklets are a steaming pile of crap and
> > should die.
> > 
> > 
> > Source thereof https://lwn.net/Articles/588457/
> 
> tasklets are ingrained in the dmaengine API (see Documentation/dmaengine/client.txt
> and drivers/dma/virt-dma.h::vchan_cookie_complete).
> 
> Moving everything to irq context or handling his own sub-{jiffy/ms} timer
> while losing async dma doesn't exactly smell like roses either. :o(

https://lwn.net/Articles/239633/

If I'm listening properly, the root cause is that there is a timing
constraint involved, which is being exposed because one softirq raises
another (ew).  Processing timeout happens, freshly raised tasklet
wanders off to SCHED_NORMAL kthread context where its constraint dies.

Given the dma stuff apparently works fine in -rt (or did, see below),
timing constraints can't be super tight, so perhaps we could grow
realtime workqueue support for the truly deserving.  The tricky bit
would be being keeping everybody and his brother from abusing it.

WRT -rt: if dma tasklets really do have hard (ish) constraints, -rt
recently "broke" in the same way.. of all softirqs which are deferred
to kthread context, due to a recent change, only timer/hrtimer are
executed at realtime priority by default.

	-Mike
