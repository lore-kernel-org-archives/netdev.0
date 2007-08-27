From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 14:02:51 -0700 (PDT)
Message-ID: <20070827.140251.95055210.davem@davemloft.net>
References: <46D1D634.7060007@katalix.com>
	<20070826.185815.93042514.davem@davemloft.net>
	<46D2F301.7050105@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tklein@de.ibm.com, themann@de.ibm.com, stefan.roscher@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	raisch@de.ibm.com, linuxppc-dev@ozlabs.org, akepner@sgi.com,
	meder@de.ibm.com, ossthema@de.ibm.com, shemminger@linux-foundation.org
To: jchapman@katalix.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <46D2F301.7050105@katalix.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 27 Aug 2007 16:51:29 +0100

> To implement this, there's no need for timers, hrtimers or generic NAPI 
> support that others have suggested. A driver's poll() would set an 
> internal flag and record the current jiffies value when finding 
> workdone=0 rather than doing an immediate napi_complete(). Early in 
> poll() it would test this flag and if set, do a low-cost test to see if 
> it had any work to do. If no work, it would check the saved jiffies 
> value and do the napi_complete() only if no work has been done for a 
> configurable number of jiffies. This keeps interrupts disabled longer at 
> the expense of many more calls to poll() where no work is done. So 
> critical to this scheme is modifying the driver's poll() to fastpath the 
> case of having no work to do while waiting for its local jiffy count to 
> expire.
> 
> Here's an untested patch for tg3 that illustrates the idea.

It's only going to work with hrtimers, these interfaces can
process at least 100,000 per jiffies tick.

And the hrtimer granularity is going to need to be significantly low,
and futhermore you're adding a guaranteed extra interrupt (for the
hrtimer firing) in these cases where we're exactly trying to avoid is
more interrupts.

If you can make it work, fine, but it's going to need to be at a
minimum disabled when the hrtimer granularity is not sufficient.

But there are huger fish to fry for you I think.  Talk to your
platform maintainers and ask for an interface for obtaining
a flat static distribution of interrupts to cpus in order to
support multiqueue NAPI better.

In your previous postings you made arguments saying that the
automatic placement of interrupts to cpus made everything
bunch of to a single cpu and you wanted to propagate the
NAPI work to other cpu's software interrupts from there.

That logic is bogus, because it merely proves that the hardware
interrupt distribution is broken.  If it's a bad cpu to run
software interrupts on, it's also a bad cpu to run hardware
interrupts on.
