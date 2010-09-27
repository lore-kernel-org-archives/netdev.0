From: "M. Warner Losh" <imp@bsdimp.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Mon, 27 Sep 2010 10:14:23 -0600 (MDT)
Message-ID: <20100927.101423.702773873740300798.imp@bsdimp.com>
References: <alpine.DEB.2.00.1009231533040.7522@router.home>
	<1285278136.2587.154.camel@localhost.localdomain>
	<alpine.DEB.2.00.1009271038150.9258@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnstul@us.ibm.com, giometti@linux.it, peterz@infradead.org,
	linux-api@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, tglx@linutronix.de,
	linuxppc-dev@lists.ozlabs.org, richardcochran@gmail.com,
	linux-arm-kernel@lists.infradead.org, khc@pm.waw.pl
To: cl@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1009271038150.9258@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message: <alpine.DEB.2.00.1009271038150.9258@router.home>
            Christoph Lameter <cl@linux.com> writes:
: On Thu, 23 Sep 2010, john stultz wrote:
: > The design actually avoids most userland induced latency.
: >
: > 1) On the PTP hardware syncing point, the reference packet gets
: > timestamped with the PTP hardware time on arrival. This allows the
: > offset calculation to be done in userland without introducing latency.
: 
: The timestamps allows the calculation of the network transmission time I
: guess and therefore its more accurate to calculate that effect out. Ok but
: then the overhead of getting to code in user space (that does the proper
: clock adjustments) is resulting in the addition of a relatively long time
: that is subject to OS scheduling latencies and noises.

The timestamps at the hardware level allow you to factor out variation
caused by OS Scheduling, OS network stack delay and internal buffering
on the NIC.  Variation in measurements is what kills accuracy.

When steering a clock by making an error measurement of the phase and
frequency of it, the latency induced by OS scheduling tends to be
unimportant.  It is far more important to know when you steered the
clock (called adjtime or friends) than to steer it at any fixed
latency to when the data for the measurements was made.  Measuring the
time of steer can tolerate errors in the range of OS scheduling
latencies easily, since that tends to produce a very small effect.  It
introduces an error in your expected phase for the next measurement on
the order of the product of the time of steer error times the change
in fractional frequency (abs( 1 - (nu_new / nu_old))).  Even if the
estimate is really bad at 100ms, most steers are on the order about
one part per million.  This leads to a sub-nanosecond phase error
estimate in the next measurement cycle (a non-accumulating error).  A
1ms error leads to maybe tens of picoseconds of estimate error.

This is a common error that I've seen repeated in this thread.  The
only reason that it has historically been important is because when
you are doing timestamping in software based on an interrupt, that
stuff does matter.

Warner
