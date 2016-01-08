From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [RFC v5 1/6] Timekeeping cross timestamp interface for device
 drivers
Date: Thu, 07 Jan 2016 16:42:07 -0800
Message-ID: <op.yav9khd91774gr@chall-mobl2.amr.corp.intel.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
 <1451911523-8534-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLXThwiibfoxEvWMZWMDTeFi2EqEU6i2tBvF5H89B3Pzxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "Thomas Gleixner" <tglx@linutronix.de>,
	"Richard Cochran" <richardcochran@gmail.com>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "John Stultz" <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLXThwiibfoxEvWMZWMDTeFi2EqEU6i2tBvF5H89B3Pzxw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

On Wed, 06 Jan 2016 10:55:22 -0800, John Stultz <john.stultz@linaro.org>  
wrote:
> On Mon, Jan 4, 2016 at 4:45 AM, Christopher S. Hall
> <christopher.s.hall@intel.com> wrote:
>> +/*
>> + * struct correlated_cs - Descriptor for a clocksource correlated to  
>> another
>> + *     clocksource
>> + * @related_cs:                Pointer to the related timekeeping  
>> clocksource
>> + * @convert:           Conversion function to convert a timestamp from
>> + *                     the correlated clocksource to cycles of the  
>> related
>> + *                     timekeeping clocksource
>> + */
>> +struct correlated_cs {
>> +       struct clocksource      *related_cs;
>> +       cycle_t                 (*convert)(struct correlated_cs *cs,
>> +                                          cycle_t cycles);
>> +};

How about making this another patch? It's not directly related to the  
cross timestamp. I would lean toward making it its own patch leaving the  
ART correlated clocksource patch touching arch/ only.

>> +/*
>> + * struct raw_system_counterval - system counter value captured in  
>> device
>> + *     driver used to produce system/device cross-timestamp
>> + * @system:    System counter value
>> + * @cs:                Clocksource related to system counter value.  
>> This is used by
>> + *             timekeeping code to verify validity of counter for  
>> system time
>> + *             conversion
>> + */
>> +struct raw_system_counterval {
>> +       cycle_t                 cycles;
>> +       struct clocksource      *cs;
>> +};
>> +
>>  #endif /* _LINUX_CLOCKSOURCE_H */
>> diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
>> index ec89d84..2209943 100644
>> --- a/include/linux/timekeeping.h
>> +++ b/include/linux/timekeeping.h
>> @@ -266,6 +266,41 @@ extern void timekeeping_inject_sleeptime64(struct  
>> timespec64 *delta);
>>  extern void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw,
>>                                         struct timespec64 *ts_real);
>>
>> +
>> +/*
>> + * struct system_device_crosststamp - system/device cross-timestamp
>> + *     (syncronized capture)
>> + * @device:    Device time
>> + * @realtime:  Realtime simultaneous with device time
>> + * @monoraw:   Monotonic raw simultaneous with device time
>> + */
>> +struct system_device_crosststamp {
>> +       ktime_t device;
>> +       ktime_t sys_realtime;
>> +       ktime_t sys_monoraw;
>> +};
>> +
>> +struct raw_system_counterval;
>> +/*
>> + * struct get_sync_device_time - Provides method to capture device time
>> + *     synchronized with raw system counter value
>> + * @get_time:  Callback providing synchronized capture of device time
>> + *             and system counter. Returns 0 on success, < 0 on failure
>> + * @ctx:       Context provided to callback function
>> + */
>> +struct get_sync_device_time {
>> +       int     (*get_time)(ktime_t *device,
>> +                           struct raw_system_counterval *system,
>> +                           void *ctx);
>> +       void     *ctx;
>> +};
>> +
>> +/*
>> + * Get cross timestamp between system clock and device clock
>> + */
>> +extern int get_device_system_crosststamp(struct  
>> system_device_crosststamp *ct,
>> +                                        struct get_sync_device_time  
>> *dt);
>
> I feel like this is introducing a lot of very small structures, which
> to the casual reviewer aren't immediately obvious how they interlink
> and are used.  It also adds to the number of types we have to keep in
> our head. I dunno, maybe its just the correlated_cs is added but isn't
> used in this patch, but I keep feeling like these should be more
> obvious somehow.
>
> That's terribly vague feedback, so I'm sorry.  Maybe some concrete  
> suggestions?
>
> * Maybe try renaming get_sync_device_time as just   
> crosststamp_device/struct ?

My goal here is to differentiate between the cross timestamp (final  
result) and the synchronized capture (intermediate value). Maybe it isn't  
particularly useful (or worse additionally confusing), but when reading  
the code I found it confusing to call everything a cross timestamp. I  
think it's the units - cycles and nanoseconds - that are the source of my  
confusion in this case. The units are obvious from the struct member  
types, but it seemed more straightforward to differentiate in the struct  
name.  Does this make sense?  If I missed the mark maybe it should be  
changed.

> * raw_system_counterval feels like its of limited value. Maybe just
> pass the clocksource and cycle value to the functions separately?

I agree it is of somewhat limited value, but I think it makes the cross  
timestamp code more intuitive (the header file, as you pointed out, not as  
much). Maybe better commenting of the struct declaration would be useful  
here? To your comment above, I can keep more structs in my head than  
arguments. Also, to my thinking there isn't any intuitive ordering if  
these struct members are changed to individual arguments which might make  
the driver callback confusing.

>>
>> -static inline s64 timekeeping_get_ns(struct tk_read_base *tkr)
>> +static inline s64 timekeeping_delta_to_ns(struct tk_read_base *tkr,
>> +                                         cycle_t delta)
>>  {
>> -       cycle_t delta;
>>         s64 nsec;
>>
>> -       delta = timekeeping_get_delta(tkr);
>> -
>>         nsec = delta * tkr->mult + tkr->xtime_nsec;
>>         nsec >>= tkr->shift;
>>
>> @@ -312,6 +310,24 @@ static inline s64 timekeeping_get_ns(struct  
>> tk_read_base *tkr)
>>         return nsec + arch_gettimeoffset();
>>  }

> Mind splitting the above out into its own small patch?

Makes sense. To be clear your suggestion is to make this patch 1 of X and  
then 2 of X will be the cross timestamp patch.  Is that right?

>>  /**
>>   * update_fast_timekeeper - Update the fast and NMI safe monotonic  
>> timekeeper.
>>   * @tkr: Timekeeping readout base from which we take the update
>> @@ -885,6 +901,59 @@ EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
>>  #endif /* CONFIG_NTP_PPS */
>>
>>  /**
>> + * get_device_system_crosststamp - Synchronously capture system/device  
>> timestamp
>> + * @xtstamp:           Receives simultaneously captured system and  
>> device time
>> + * @sync_devicetime:   Callback to get simultaneous device time and
>> + *     system counter from the device driver
>> + *
>> + * Reads a timestamp from a device and correlates it to system time
>> + */
>> +int get_device_system_crosststamp(struct system_device_crosststamp  
>> *xtstamp,
>> +                                 struct get_sync_device_time  
>> *sync_devicetime)
>
> Another nit, but to me something like:
> int get_device_system_crosststamp(struct get_sync_device_time  
> *sync_devicetime,
>                                                           struct
> system_device_crosststamp *ret)
>
> Reads better to me. ie: use this device_time -> return that crosststamp.

OK.  My brain "works" the opposite way, but I think (after a small amount  
of research) I'm in the minority:)

Thanks,
Chris
