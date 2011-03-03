From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Thu, 3 Mar 2011 09:45:07 +0100
Message-ID: <201103030945.07486.arnd@arndb.de>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com> <alpine.LFD.2.00.1103011630080.2701@localhost6.localdomain6> <4D6E7FD7.1060408@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Stuart MENEFY <stuart.menefy@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D6E7FD7.1060408@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 March 2011, Peppe CAVALLARO wrote:
> At any rate, I am happy to use the stmmac as experimental
> driver to do this kind tests.
> Indeed, in the past, on old Kernel (IIRC 2.6.23), I tried to use
> the kernel timers but I removed the code from it because
> I had noticed packets loss and a strange phenomenon with cyclesoak
> (that showed broken sysload % during the heavy network activities).
> 
> Let me know how to proceed:
> 
> 1) experiment with stmmac and hrtimer for handling rx/tx?
> 2) rework the patches for the Generic Timer Infra?

I'd suggest doing the first. I'm surprised that using an unrelated
timer for processing interrupts even helps you on stmmac.

The timers that you'd normally use for rx interrupt mitigation
are not periodic timers but are started when a packet arrives
from the outside.

Doing periodic wakeups for RX instead of just waiting for
packets to come in should have a significant impact on power
management on an otherwise idle system.

For tx resource reclaim, a relatively slow oneshot timer (not
even hrtimer) should be good enough, since it only needs to be
active when there is no other way to clean up. E.g. when you
are in napi polling mode (interrupt disabled), you know that
stmmac_poll gets called soon, and you can also do the reclaim
from stmmac_xmit() in order to prevent the timer from triggering
when you are constantly transmitting.

	Arnd
