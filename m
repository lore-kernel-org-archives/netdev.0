From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 06:58:32 +0200
Message-ID: <20151013045832.GA2437@netboy>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org,
	x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 11:45:19AM -0700, Christopher S. Hall wrote:
> Another representative use case of time sync and the correlated
> clocksource (in addition to PTP noted above) is PTP synchronized
> audio.

The added explanations of the audio use case do help.  However, you
did not address my point in the last series in any way.
 
> In a streaming application, as an example, samples will be sent
> and/or received by multiple devices with a presentation time that is
> in terms of the PTP master clock. Synchronizing the audio output on
> these devices requires correlating the audio clock with the PTP
> master clock. The more precise this correlation is, the better the
> audio quality (i.e. out of sync audio sounds bad).

^^^^
This is mega important.  You want to convert PTP time into audio clock
time.  There is no need for the system time at all.
 
> From an application standpoint, to correlate the PTP master clock
> with the audio device clock, the system clock is used as a
> intermediate timebase.

But why involve the system time base?

> The transforms such an application would
> perform are:
> 
> System Clock <-> Audio clock
> System Clock <-> Network Device Clock [<-> PTP Master Clock]

This is extra work with no benefit.  In fact, this hurts you
because of the need to take avoid update_wall_time AND because of the
NTP frequency adjustments.  Cascaded servos are prone to gain peaking,
and this can easily avoided in this case.
 
> Modern Intel platforms can perform a more accurate cross-
> timestamp in hardware (ART,audio device clock).  The audio driver
> requires ART->system time transforms -- the same as required for
> the network driver.

No, it doesn't need the system time.  It only needs the PTP time.

> The modification to the original patch accomodates these
> slow devices by adding the option of providing an ART value outside
> of the retry loop and adding a history which can consulted in the
> case of an out of date counter value. The history is kept by
> making the shadow_timekeeper an array. Each write to the
> timekeeper rotates through the array, preserving a
> history of updates.

This is all wrong.  All you need to provide the DSP with (ART, PTP)
pairs.  This can be done in a multiple of the DSP period, like every
1, 10, or 100 milliseconds.

Thanks,
Richard
