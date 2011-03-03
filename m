From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Thu, 3 Mar 2011 11:25:26 +0100
Message-ID: <4D6F6C96.1010303@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
 <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6>
 <4D6E7FD7.1060408@st.com> <201103030945.07486.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Stuart MENEFY <stuart.menefy@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201103030945.07486.arnd@arndb.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 3/3/2011 9:45 AM, Arnd Bergmann wrote:
>
> On Wednesday 02 March 2011, Peppe CAVALLARO wrote:
> > At any rate, I am happy to use the stmmac as experimental
> > driver to do this kind tests.
> > Indeed, in the past, on old Kernel (IIRC 2.6.23), I tried to use
> > the kernel timers but I removed the code from it because
> > I had noticed packets loss and a strange phenomenon with cyclesoak
> > (that showed broken sysload % during the heavy network activities).
> >
> > Let me know how to proceed:
> >
> > 1) experiment with stmmac and hrtimer for handling rx/tx?
> > 2) rework the patches for the Generic Timer Infra?
>
> I'd suggest doing the first. I'm surprised that using an unrelated
> timer for processing interrupts even helps you on stmmac.
>

Indeed, this helped especially to save the cpu usage
on heavy IP traffic (but with Max Throughput and no pkt
loss).

> The timers that you'd normally use for rx interrupt mitigation
> are not periodic timers but are started when a packet arrives
> from the outside.
>
Yes you are right but unfortunately our mac devices have
not this kind of HW.
>
> Doing periodic wakeups for RX instead of just waiting for
> packets to come in should have a significant impact on power
> management on an otherwise idle system.
>
To "mitigate" this issue, the driver does a fast (and extra)
check in the rings and it does not start any rx processes
in case there are no incoming frames.

> For tx resource reclaim, a relatively slow oneshot timer (not
> even hrtimer) should be good enough, since it only needs to be
> active when there is no other way to clean up. E.g. when you
> are in napi polling mode (interrupt disabled), you know that
> stmmac_poll gets called soon, and you can also do the reclaim
> from stmmac_xmit() in order to prevent the timer from triggering
> when you are constantly transmitting.
>
This logic is already in the driver, indeed.
What I've seen on our embedded systems is that the
cost of RX interrupts is very hight and NAPI partially helps.
Typically, in an IP-STB, I receive a burst of UDP pkt
and this  means that many interrupts occur (~99% of CPU
usage on slow platforms).
With the ext timer I was able to reduce the CPU usage in
these kind of scenarios to ~50%.
When there is no net traffic, indeed, the timer periodically
"disturbs" the system but the impact on the CPU usage
actually is low.

Thanks
Peppe
>
>         Arnd
>
