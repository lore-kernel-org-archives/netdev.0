From: "Stanton, Kevin B" <kevin.b.stanton@intel.com>
Subject: RE: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 3 Nov 2015 19:18:10 +0000
Message-ID: <487620E8DE6666469C4E4133DA94A0EF31F42651@FMSMSX108.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1510132116480.25029@nanos>
 <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
 <alpine.DEB.2.11.1510151014330.3960@nanos>
 <op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
 <CALAqxLXu_C8sWaKyxqXJPFV+m5Zdk=4q4s7O6NoLR1B8bbyuxg@mail.gmail.com>
 <20151020085408.GA2542@netboy> <alpine.DEB.2.11.1510201246250.3982@nanos>
 <20151020115113.GA23428@netboy> <20151020145523.GA5207@netboy>
 <alpine.DEB.2.11.1510202107410.8159@nanos>
 <CALAqxLXGnzwH5OgDCyggzxbao7UvS6_SOtVVkNVmjrsrOL-YBw@mail.gmail.com>
 <alpine.DEB.2.11.1510210941130.4000@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"Hall, Christopher S" <christopher.s.hall@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: John Stultz <john.stultz@linaro.org>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1510210941130.4000@nanos>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Oct 2015, Thomas Gleixner wrote:
> On Tue, 20 Oct 2015, John Stultz wrote:
>> Being able to have various hardware sharing a time base is quite 
>> useful, and methods for correlating timestamps together are useful.
>> But I don't yet really understand why its important that we can 
>> translate a hardware timestamp from some time in the past to the 
>> correct system time in the past without error.

>If your device can only provide timestamps from the past, then
>having access to the history is important if you want to have
>precise correlation.

I hope this can be solved in timekeeping. But first, a quick
recap...

The timestamp pair (including the ART snapshot, as described
previously) is captured simultaneously by the hardware
resulting, effectively, in a (PTP,TSC) pair, or
(AudioPosition,TSC) pair. The in-the-past-TSC value needs to be
converted to system time so that it can be used by applications,
without exposing the underlying ART or TSC.

Note: ART is architectural, defined as part of Invariant
Timekeeping in the current SDM, so this isn't a one-off
capability.

To convert a past TSC timestamp to system time 'correctly' (in a
mathematical sense), a history of monotonic rate adjustments
since that time in the past must be maintained.

Regarding the amount of history, as Chris mentioned (and
in the context of new Intel hardware) LAN timestamp pairs are
a few microseconds in the past (no history would be required),
but for timestamps captured by the audio DSP, unfortunately,
they can be a small number of *milliseconds* in the past by the
time they're available to the audio driver (some history
required to convert accurately). I'm told that 4ms of adjustment
history accommodates known hardware.

Getting this 'correct' in one place (timekeeping) seems a lot
better than unnecessarily introducing inaccuracy via software
sampling (and extrapolation) or leaving it to each driver to do
it themselves, and to do it differently (and/or do it wrongly).

Best Regards,
Kevin
