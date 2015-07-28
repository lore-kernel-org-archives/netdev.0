From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Mon, 27 Jul 2015 21:05:27 -0700
Message-ID: <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
	<1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
	<CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2015 at 8:44 PM, John Stultz <john.stultz@linaro.org> wrote:
> On Mon, Jul 27, 2015 at 5:46 PM, Christopher Hall
> <christopher.s.hall@intel.com> wrote:
>> * counter_to_rawmono64
>> * counter_to_mono64
>> * counter_to_realtime64
>>
>> Enables drivers to translate a captured system clock counter to system
>> time. This is useful for network and audio devices that capture timestamps
>> in terms of both the system clock and device clock.
>
> Huh.  So for counter_to_realtime64 & mono64, this seems to ignore the
> fact that the multiplier is constantly adjusted and corrected. So that
> calling the function twice with the same counter value may result in
> different returned values.
>
> I've not yet groked the whole patchset, but it seems like there needs
> to be some mechanism that ensures the counter value is captured and
> used in the same (or at least close) interval that the timekeeper data
> is valid for.


So reading through. It looks like you only use art_to_realtime(), right?

So again, since CLOCK_MONOTONIC and CLOCK_REALTIME are constaly being
frequency adjusted, it might be best to construct this delta in the
following way.


Add counter_to_rawmono64(), which should be able to safely calculate
the corresponding CLOCK_MONOTONIC_RAW time from any given cycle value.

Use getnstime_raw_and_real() to get a immediate snapshot of current
MONOTONIC_RAW  and REALTIME clocks.

Then calculate the delta between the snapshotted counter raw time, and
the current raw time.  Then apply that offset to the current realtime.

The larger the raw-time delta, the larger the possible realtime error.
But I think that will be as good as it gets.

This should simplify the interfaces you're adding to the timekeeping core.

thanks
-john
