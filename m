From: John Stultz <john.stultz@linaro.org>
Subject: Re: [RFC v5 1/6] Timekeeping cross timestamp interface for device drivers
Date: Thu, 7 Jan 2016 17:05:24 -0800
Message-ID: <CALAqxLVY=u1S8qy0fox6Fmkkb8yDS3yHu+UioQe9-qNraM7ngQ@mail.gmail.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
	<1451911523-8534-2-git-send-email-christopher.s.hall@intel.com>
	<CALAqxLXThwiibfoxEvWMZWMDTeFi2EqEU6i2tBvF5H89B3Pzxw@mail.gmail.com>
	<op.yav9khd91774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <op.yav9khd91774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 7, 2016 at 4:42 PM, Christopher Hall
<christopher.s.hall@intel.com> wrote:
> Hi John,
>
> On Wed, 06 Jan 2016 10:55:22 -0800, John Stultz <john.stultz@linaro.org>
> wrote:
>>
>> On Mon, Jan 4, 2016 at 4:45 AM, Christopher S. Hall
>> <christopher.s.hall@intel.com> wrote:
>>>
>>> +/*
>>> + * struct correlated_cs - Descriptor for a clocksource correlated to
>>> another
>>> + *     clocksource
>>> + * @related_cs:                Pointer to the related timekeeping
>>> clocksource
>>> + * @convert:           Conversion function to convert a timestamp from
>>> + *                     the correlated clocksource to cycles of the
>>> related
>>> + *                     timekeeping clocksource
>>> + */
>>> +struct correlated_cs {
>>> +       struct clocksource      *related_cs;
>>> +       cycle_t                 (*convert)(struct correlated_cs *cs,
>>> +                                          cycle_t cycles);
>>> +};
>
>
> How about making this another patch? It's not directly related to the cross
> timestamp. I would lean toward making it its own patch leaving the ART
> correlated clocksource patch touching arch/ only.

Sure. Tying it more closely (via explicit commit message) to the
change that uses it would be better then kind of slipping it in here.


>> I feel like this is introducing a lot of very small structures, which
>> to the casual reviewer aren't immediately obvious how they interlink
>> and are used.  It also adds to the number of types we have to keep in
>> our head. I dunno, maybe its just the correlated_cs is added but isn't
>> used in this patch, but I keep feeling like these should be more
>> obvious somehow.
>>
>> That's terribly vague feedback, so I'm sorry.  Maybe some concrete
>> suggestions?
>>
>> * Maybe try renaming get_sync_device_time as just
>> crosststamp_device/struct ?
>
>
> My goal here is to differentiate between the cross timestamp (final result)
> and the synchronized capture (intermediate value). Maybe it isn't
> particularly useful (or worse additionally confusing), but when reading the
> code I found it confusing to call everything a cross timestamp. I think it's
> the units - cycles and nanoseconds - that are the source of my confusion in
> this case. The units are obvious from the struct member types, but it seemed
> more straightforward to differentiate in the struct name.  Does this make
> sense?  If I missed the mark maybe it should be changed.

Sure. I think having a different type then just cycles here is good,
and counterval is fine for an alternate name, but get_sync_device_time
looks like a function, not a structure name to me. The fact that the
structure is mostly an accessor to the hardware is fine, but maybe
counterval_device or something would be better? counterval_source? I
dunno.


>> * raw_system_counterval feels like its of limited value. Maybe just
>> pass the clocksource and cycle value to the functions separately?
>
>
> I agree it is of somewhat limited value, but I think it makes the cross
> timestamp code more intuitive (the header file, as you pointed out, not as
> much). Maybe better commenting of the struct declaration would be useful
> here? To your comment above, I can keep more structs in my head than
> arguments. Also, to my thinking there isn't any intuitive ordering if these
> struct members are changed to individual arguments which might make the
> driver callback confusing.

Yea. I just feel like lots of structures add extra abstraction that
makes the code harder to learn or re-learn. Not only is one trying to
remember the base types that are being passed around, but you also
have to remember what all the meta-structures are for. Especially for
these two-value structures.

And I apologize. I know this sort of nit-picking is sort of the worst.
"Its great you named your child that, but I'd prefer to call them..."
;)  But for long-term maintenance, under the fog of time, obviousness
is really important.


>>> -static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
>>> +static inline s64 timekeeping_delta_to_ns(struct tk_read_base *tkr,
>>> +                                         cycle_t delta)
>>>  {
>>> -       cycle_t delta;
>>>         s64 nsec;
>>>
>>> -       delta = timekeeping_get_delta(tkr);
>>> -
>>>         nsec = delta * tkr->mult + tkr->xtime_nsec;
>>>         nsec >>= tkr->shift;
>>>
>>> @@ -312,6 +310,24 @@ static inline s64 timekeeping_get_ns(struct
>>> tk_read_base *tkr)
>>>         return nsec + arch_gettimeoffset();
>>>  }
>
>
>> Mind splitting the above out into its own small patch?
>
>
> Makes sense. To be clear your suggestion is to make this patch 1 of X and
> then 2 of X will be the cross timestamp patch.  Is that right?

Yep.


>>>  /**
>>>   * update_fast_timekeeper - Update the fast and NMI safe monotonic
>>> timekeeper.
>>>   * @tkr: Timekeeping readout base from which we take the update
>>> @@ -885,6 +901,59 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
>>>  #endif /* CONFIG_NTP_PPS */
>>>
>>>  /**
>>> + * get_device_system_crosststamp - Synchronously capture system/device
>>> timestamp
>>> + * @xtstamp:           Receives simultaneously captured system and
>>> device time
>>> + * @sync_devicetime:   Callback to get simultaneous device time and
>>> + *     system counter from the device driver
>>> + *
>>> + * Reads a timestamp from a device and correlates it to system time
>>> + */
>>> +int get_device_system_crosststamp(struct system_device_crosststamp
>>> *xtstamp,
>>> +                                 struct get_sync_device_time
>>> *sync_devicetime)
>>
>>
>> Another nit, but to me something like:
>> int get_device_system_crosststamp(struct get_sync_device_time
>> *sync_devicetime,
>>                                                           struct
>> system_device_crosststamp *ret)
>>
>> Reads better to me. ie: use this device_time -> return that crosststamp.
>
>
> OK.  My brain "works" the opposite way, but I think (after a small amount of
> research) I'm in the minority:)

Yea. memcpy and others do work the other way, but my left-to-right
bias is pretty strong. :)

thanks
-john
