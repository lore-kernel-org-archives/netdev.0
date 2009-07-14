From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 10:55:14 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>
References: <20090709215455.703939259@linutronix.de> <20090709215606.526259917@linutronix.de> <20090712.135555.207096388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753268AbZGNIzl@vger.kernel.org>
In-Reply-To: <20090712.135555.207096388.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Sun, 12 Jul 2009, David Miller wrote:

> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Thu, 09 Jul 2009 21:59:22 -0000
> 
> > The hrtimer callback cbq_undelay() is not serialized against
> > cbq_ovl_delay(). That affects at least q->pmask and q->delay_timer.
> > 
> > Lock it proper.
> > 
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> 
> The problems here are even much deeper than it appears.
> 
> First of all, I am to understand that hrtimers run from hardware
> interrupt context, right?  If so, all of these datastructures are
> softirq safe only.
> 
> And it is not merely the immediate things you see being modified in
> this hrtimer, such as ->pmask etc., it is also the q->active[]
> pointers, the list state for the classes, just about everything in the
> qdisc state is referenced in this hrtimer code path.

That's what I was worried about.
 
> I wonder how many queer unexplainable bugs we see because of this.
> 
> What should probably happen is that the hrtimer merely fires off work
> at software interrupt context (perhaps a tasklet or similar), and that
> software interrupt code take the qdisc's root lock throughout it's
> execution.

Sigh, I almost expected that the removal of the callback modes will
fire back some day.

Thanks,

	tglx
