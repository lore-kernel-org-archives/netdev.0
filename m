From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH net-next 00/11] Time Counter fixes and improvements
Date: Fri, 2 Jan 2015 10:37:09 -0800
Message-ID: <CALAqxLUVU3XmBMiNGH-X5KjGbEjDYtaR2WRXDOHfGNads9caOw@mail.gmail.com>
References: <cover.1418504883.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 21, 2014 at 10:46 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> Several PTP Hardware Clock (PHC) drivers implement the clock in
> software using the timecounter/cyclecounter code. This series adds on=
e
> simple improvement and one more subtle fix to the shared timecounter
> facility. Credit for this series goes to Janusz U=C5=BCycki, who poin=
ted
> the issues out to me off list.
>
> Patch #1 simply move the timecounter code into its own file. When
> working on this series, it was really annoying to see half the kernel
> recompile after every tweak to the timecounter stuff. There is no
> reason to keep this together with the clocksource code.

I did have some faint hope we could merge the cyclecounter and
clocksource struct at some point, and while we've gotten closer with
much of the time-specific values being kept in the timekeeper, the
full cleanup hasn't happened in a few years here, so its clearly not
something I've prioritized.

So no objection in concept.


> Patch #2 implements an improved adjtime() method, and patches 3-10
> convert all of the drivers over to the new method.
>
> Patch #11 fixes a subtle but important issue with the timecounter WRT
> frequency adjustment. As it stands now, a timecounter based PHC will
> exhibit a variable frequency resolution (and variable time error)
> depending on how often the clock is read.
>
> In timecounter_read_delta(), the expression
>
>    (delta * cc->mult) >> cc->shift;
>
> can lose resolution from the adjusted value of 'mult'. If the value
> of 'delta' is too small, then small changes in 'mult' have no effect.
> However, if the delta value is large enough, then small changes in
> 'mult' will have an effect.
>
> Reading the clock too often means smaller 'delta' values which in tur=
n
> will spoil the fine adjustments made to 'mult'. Up until now, this
> effect did not show up in my testing. The following example explains
> why.
>
> The CPTS has an input clock of 250 MHz, and the clock source uses
> mult=3D0x80000000 and shift=3D29, making the ticks to nanoseconds
> conversion like this:
>
>    ticks * 2^31
>    ------------
>        2^29
>
> Imagine what happens if the clock is read every 10 milliseconds. Ten
> milliseconds are about 2500000 ticks, which corresponds to about 21
> bits. The product in the numerator has then 52 bits. After the shift
> operation, 23 bits are preserved. This results in a frequency
> adjustment resolution of about 0.1 ppm (not _too_ bad.)
>
> A frequency resolution of 1 ppm requires 20 bits.
> A frequency resolution of 1 ppb requires 30 bits.
>
> For the 250 MHz CPTS clock, reading every 4 seconds yields a 1 ppb
> resolution (which is the finest that our API allows).
>
> However, the error can be much higher if the clock is read too often
> or if time stamps occur close in time to read operations. In general
> it is really not acceptable to allow the rate of clock readings to
> influence the clock accuracy.

Though, this does start to sound like issues the timekeeping code had
to resolve, so while its probably time to let some flowers bloom and
see what happens, we should be somewhat watchful for too much logic
duplication.

The patch set itself seems fairly straight forward (at least to my
back from vacation brain), so..
Acked-by: John Stultz <john.stultz@linaro.org>

thanks
-john
