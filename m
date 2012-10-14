From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [STABLE REQUEST] add: e1000: fix lockdep splat in shutdown
 handler
Date: Sun, 14 Oct 2012 21:24:46 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1210142102300.2868@ionos>
References: <1349993385.24256.79.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <ben@decadent.org.uk>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	stable <stable@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349993385.24256.79.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2012, Steven Rostedt wrote:
> commit 3a3847e007aae732d64d8fd1374126393e9879a3
> Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date:   Wed Jan 4 20:23:33 2012 +0000
> 
>     e1000: fix lockdep splat in shutdown handler

as I discussed with Jesse on IRC, there is another possible deadlock
lurking in the e1000 code.

static void e1000_reinit_safe(struct e1000_adapter *adapter)
{
	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
		msleep(1);
	mutex_lock(&adapter->mutex);
	e1000_down(adapter);

e1000_down() waits on the various work tasks to shut down, but those
work functions might be blocked on the adapter mutex.

I have no idea how I managed to trigger that one, but it's real. The
task dump I got out of the machine shows stuff waiting on each other
forever.

I can't give you a receipe to reprodruce. Looking at the code this is
not very surprising. It takes quite some coincidence of having
e1000_reinit_safe() being invoked and the delayed work timer bringing
the work on right after e1000_reinit_safe() took the adapter mutex.

Thanks,

	tglx
