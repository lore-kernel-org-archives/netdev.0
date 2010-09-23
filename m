From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 12:53:20 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231238170.2962@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <cover.1285261533.git.richard.cochran@omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, Richard Cochran wrote:

>   Support for obtaining timestamps from a PHC already exists via the
>   SO_TIMESTAMPING socket option, integrated in kernel version 2.6.30.
>   This patch set completes the picture by allow user space programs to
>   adjust the PHC and to control its ancillary features.

Is there a way to use the PHC as a system clock? I think the main benefit
of PTP is to have syncronized time on multiple machines in a cluster. That
may mean getting rid of ntp and using an in kernel PHC based way to sync time.

>    So as far as the POSIX standard is concerned, offering a clock id
>    to represent the PHC would be acceptable.

Sure but what would you do with it? HPET timer support has no such need.

> 3.2.1 Using the POSIX Clock API
> --------------------------------
>
>     Looking at the mapping from PHC operation to the POSIX clock API,
>     we see that two of the basic clock operations, marked with *, have
>     no POSIX equivalent. The items marked NA are peculiar to PHCs and
>     will be discussed separately, below.
>
>       Clock Operation               POSIX function
>      -----------------------------+-----------------------------
>       Set time                      clock_gettime
>       Get time                      clock_settime
>       Shift the clock               *
>       Adjust clock frequency        *
>      -----------------------------+-----------------------------
>       Time stamp external events    NA
>       Enable PPS events             NA
>       Periodic output signals       NA
>       One shot or periodic alarms   timer_create, timer_settime
>
>     In contrast to the standard Linux system clock, a PHC is
>     adjustable in hardware, for example using frequency compensation
>     registers or a VCO. The ability to directly tune the PHC is
>     essential to reap the benefit of hardware timestamping.

There is a reason for not being able to shift posix clocks: The system has
one time base. The various clocks are contributing to maintaining that
sytem wide time.

I do not understand why you want to maintain different clocks running at
different speeds. Certainly interesting for some uses I guess that I
do not have the energy to imagine right now. But can we get the PTP killer
feature of synchronized accurate system time first?

> 3.3 Synchronizing the Linux System Time
> ========================================
>
>    One could offer a PHC as a combined clock source and clock event
>    device. The advantage of this approach would be that it obviates
>    the need for synchronization when the PHC is selected as the system
>    timer. However, some PHCs, namely the PHY based clocks, cannot be
>    used in this way.

Why not? Do PHY based clock not at least provide a counter that increments
in synchronized intervals throughout the network?

>    Instead, the patch set provides a way to offer a Pulse Per Second
>    (PPS) event from the PHC to the Linux PPS subsystem. A user space
>    application can read the PPS events and tune the system clock, just
>    like when using other external time sources like radio clocks or
>    GPS.

User space is subject to various latencies created by the OS etc. I would
that in order to have fine grained (read microsecond) accurary we would
have to run the portions that are relevant to obtaining the desired
accuracy in the kernel.
