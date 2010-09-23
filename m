From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 21:36:54 +0100
Message-ID: <20100923213654.0c64b047@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
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

>    So as far as the POSIX standard is concerned, offering a clock id
>    to represent the PHC would be acceptable.

But completely useless as you may have more than one entirely different
time managed by PTP and in which you are not master but must work with
the timebases provided.


>     /sys/class/timesource/<name>/id
>     /sys/class/ptp/ptp_clock_X/id
> 
>     Note: I am not too sure that this is exactly what people imagined,
>           but it is my best understanding so far. I gleaned two
>           different ideas about where to offer the clock id. In order
>           to keep just one way, I will be happy to remove the less
>           popular one.

I see no fix proposed for the race condition I pointed out. This doesn't
work.


>    If the Linux system time is synchronized to the PHC via the PPS

To which PHC we can have several

>    + Intel IXP465
>      - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
>      - Target Time (optional interrupt)

And about 40 already supported by char driver interface clocks and rtcs
in the kernel...


I'd say the inability to have multiple clocks and the race condition
because of the clockid stuff leaves the proposal dead in the water.

It also ignores the existing APIs we have floating around attached to
devices.

You need to make one small important change. You need to take the POSIX
crap about enumerating things out and shoot it, bury it at a crossroads
and sprinkle holy water on it.

Drop the clockid_t and swap it for a file handle like a proper Unix or
Linux interface. The rest is much the same

	fd = open /sys/class/timesource/[whatever]

	various queries you may want to do to check the name etc

	fclock_adjtime(fd, ...)
	

The posix interface is fundamentally flawed. It only works for staticly
enumerable objects. Unix avoided that forty years ago by making the
identifier a handle which immediately cures all your object lifetime
problems in one swoop.

Namespace -> file handle translations are dynamic, but once you have it
open you hold on to the same object, which means you can check what you
have.



Alan
