From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Tue, 12 Jun 2012 12:04:43 +0900
Message-ID: <20120612030442.GH10170@linux-sh.org>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
 <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com>
 <201102241820.55873.arnd@arndb.de>
 <4D6D0EA3.9000504@st.com>
 <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stuart Menefy <stuart.menefy@st.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux-sh.org ([111.68.239.195]:38135 "EHLO linux-sh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab2FLDFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 23:05:07 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 05:48:33PM +0100, Thomas Gleixner wrote:
> On Tue, 1 Mar 2011, Stuart Menefy wrote:
> > On 24/02/11 17:20, Arnd Bergmann wrote:
> > > On Tuesday 22 February 2011, Peppe CAVALLARO wrote:
> > >> From: Stuart Menefy <stuart.menefy@st.com>
> > >>
> > >> Many devices targeted at the embedded market provide a number of
> > >> generic timers which are capable of generating interrupts at a
> > >> requested rate. These can then be used in the implementation of drivers
> > >> for other peripherals which require a timer interrupt, without having
> > >> to provide an additional timer as part of that peripheral.
> 
> Why can't you just use an hrtimer and be done with it? Just because
> there is some extra hardware in the chip?
> 
..

> If we get some reasonable explanation why an extra timer interrupt is
> solving a specific problem better than hrtimers we can do that, but
> that needs more thought than picking the first available clockevent
> from a list. If we come to the conclusion, that we want/need this kind
> of functionality then I really prefer not to create yet another piece
> of infrastructure which deals with timer devices.
> 

I've run in to this issue again while working on local timer support on
SH, as we're presently dependent on broadcast and dummy tick devices in
the SMP case, while quite a few timer channels remain available for use.
(Ironically, while the aforementioned driver was able to solve the
problem with hrtimers, we have the same need to _provide_ hrtimers).

In the sh_tmu/cmt/mtu2 case all timer channels are handed off as platform
devices, and the block itself is global for all CPUs, though we can tweak
the IRQ affinity relative to the cpumask. My tentative plan is to deal
with the clockevent device as a percpu thing in the local timer case
which will require some additional side infrastructure, but some
additional work will need to be done in the clockevents code regardless.

The ARM approach is a bit backwards from what we're interested in
solving, as it uses its own local timer infrastructure and some
TWD-specific API for registering per-cpu timers and only then inserting
them in to the clockevents list. Whereas in our case we've got all of the
timer channels available at platform probe time (earlier for the early
timer case), and simply need a method for tracking unused channels as
well as having a facility for picking them up and reconfiguring them
later on when the secondary CPUs come up. I'm not at all interested in
registering the same timer multiple times with slightly different APIs,
having two different drivers fighting over the same register space is not
a thought that fills me with joy.

In any event, I'll hack on it a bit and see what falls out, patches
later.
