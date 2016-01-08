From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [RFC v5 3/6] Add history to cross timestamp interface supporting
 slower devices
Date: Thu, 07 Jan 2016 17:07:16 -0800
Message-ID: <op.yawaqe0i1774gr@chall-mobl2.amr.corp.intel.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
 <1451911523-8534-4-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLVACLP1_PGWh5Ha9P6DT+HfDu9vg-B5NCShuFvNu21WUQ@mail.gmail.com>
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
In-Reply-To: <CALAqxLVACLP1_PGWh5Ha9P6DT+HfDu9vg-B5NCShuFvNu21WUQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Jan 2016 11:37:23 -0800, John Stultz <john.stultz@linaro.org>  
wrote:
> On Mon, Jan 4, 2016 at 4:45 AM, Christopher S. Hall
> <christopher.s.hall@intel.com> wrote:
>> @@ -13,6 +13,9 @@
>>  /**
>>   * struct tk_read_base - base structure for timekeeping readout
>>   * @clock:     Current clocksource used for timekeeping.
>> + * @cs_seq:    Clocksource sequence is incremented per clocksource  
>> change.
>> + *     It's used to determine whether past system time can be related  
>> to
>> + *     current system time
>>   * @read:      Read function of @clock
>>   * @mask:      Bitmask for two's complement subtraction of non 64bit  
>> clocks
>>   * @cycle_last: @clock cycle value at last update
>> @@ -29,6 +32,7 @@
>>   */
>>  struct tk_read_base {
>>         struct clocksource      *clock;
>> +       u8                      cs_seq;
>>         cycle_t                 (*read)(struct clocksource *cs);
>>         cycle_t                 mask;
>>         cycle_t                 cycle_last;
>
>
> So Thomas optimized the tk_read_bases to fit in a cacheline, and so I
> worry about the u8 being added there. I'm also cautious about
> exporting these seq values out further via the system_time_snapshot.
> But I may just need some more time to warm up to the idea.

I think I missed the reason for the existence tk_read_base. Now I know.  
The clocksource sequence doesn't belong there. It should be moved  
timekeeper struct.  Below there is more discussion of why the sequence  
number needs to exist at all. I think it does.

Would it make more sense to take the sequence out of the snapshot struct  
and make it an additional argument? it makes the snapshot struct more  
intuitive but the arguments to ktime_get_snapshot() maybe less so.

>
>
>> diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
>> index 9c1ddc3..5a7f784 100644
>> --- a/kernel/time/timekeeping.c
>> +++ b/kernel/time/timekeeping.c
>> @@ -235,11 +235,13 @@ static void tk_setup_internals(struct timekeeper  
>> *tk, struct clocksource *clock)
>>
>>         old_clock = tk->tkr_mono.clock;
>>         tk->tkr_mono.clock = clock;
>> +       ++tk->tkr_mono.cs_seq;
>>         tk->tkr_mono.read = clock->read;
>>         tk->tkr_mono.mask = clock->mask;
>>         tk->tkr_mono.cycle_last = tk->tkr_mono.read(clock);
>>
>>         tk->tkr_raw.clock = clock;
>> +       ++tk->tkr_raw.cs_seq;
>>         tk->tkr_raw.read = clock->read;
>>         tk->tkr_raw.mask = clock->mask;
>>         tk->tkr_raw.cycle_last = tk->tkr_mono.cycle_last;
>> @@ -862,6 +864,39 @@ time64_t ktime_get_real_seconds(void)
>>  }
>>  EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
>>
>> +/**
>> + * ktime_get_snapshot - snapshots the realtime/monotonic raw clocks  
>> with counter
>> + * @snapshot:  pointer to struct receiving the system time snapshot
>> + */
>> +void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
>> +{
>> +       struct timekeeper *tk = &tk_core.timekeeper;
>> +       unsigned long seq;
>> +       ktime_t base_raw;
>> +       ktime_t base_real;
>> +       s64 nsec_raw;
>> +       s64 nsec_real;
>> +       cycle_t now;
>> +
>> +       do {
>> +               seq = read_seqcount_begin(&tk_core.seq);
>> +
>> +               now = tk->tkr_mono.read(tk->tkr_mono.clock);
>> +               systime_snapshot->cs_seq = tk->tkr_mono.cs_seq;
>> +               systime_snapshot->clock_set_seq = tk->clock_was_set_seq;
>> +               base_real = ktime_add(tk->tkr_mono.base,
>> +                                     tk_core.timekeeper.offs_real);
>> +               base_raw = tk->tkr_raw.base;
>> +               nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,  
>> now);
>> +               nsec_raw  = timekeeping_cycles_to_ns(&tk->tkr_raw, now);
>> +       } while (read_seqcount_retry(&tk_core.seq, seq));
>> +
>> +       systime_snapshot->cycles = now;
>> +       systime_snapshot->real = ktime_add_ns(base_real, nsec_real);
>> +       systime_snapshot->raw = ktime_add_ns(base_raw, nsec_raw);
>> +}
>> +EXPORT_SYMBOL_GPL(ktime_get_snapshot);
>
> So can you split out this adding of ktime_get_snapshot()  (maybe
> skipping the seqcount bits initially) into a separate patch?

Yes.  This should be fine.

>
>> @@ -936,19 +1044,63 @@ int get_device_system_crosststamp(struct  
>> system_device_crosststamp *xtstamp,
>>                  */
>>                 if (tk->tkr_mono.clock != raw_sys.cs)
>>                         return -ENODEV;
>> +               cycles = raw_sys.cycles;
>> +
>> +               /*
>> +                * Check whether the system counter value provided by  
>> the
>> +                * device driver is on the current interval.
>> +                */
>> +               now = tk->tkr_mono.read(tk->tkr_mono.clock);
>> +               interval_start = tk->tkr_mono.cycle_last;
>> +               if (!cycle_between(interval_start, cycles, now)) {
>> +                       cs_seq = tk->tkr_mono.cs_seq;
>> +                       clock_was_set_seq = tk->clock_was_set_seq;
>> +                       cycles = interval_start;
>> +                       do_interp = true;
>> +               } else {
>> +                       do_interp = false;
>> +               }
>>
>>                 base_real = ktime_add(tk->tkr_mono.base,
>>                                       tk_core.timekeeper.offs_real);
>>                 base_raw = tk->tkr_raw.base;
>>
>> -               nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,
>> -                                                    raw_sys.cycles);
>> -               nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw,
>> -                                                   raw_sys.cycles);
>> +               nsec_real = timekeeping_cycles_to_ns(&tk->tkr_mono,  
>> cycles);
>> +               nsec_raw = timekeeping_cycles_to_ns(&tk->tkr_raw,  
>> cycles);
>>         } while (read_seqcount_retry(&tk_core.seq, seq));
>>
>>         xtstamp->sys_realtime = ktime_add_ns(base_real, nsec_real);
>>         xtstamp->sys_monoraw = ktime_add_ns(base_raw, nsec_raw);
>> +
>> +       /*
>> +        * Interpolate if necessary, working back from the start of the  
>> current
>> +        * interval
>> +        */
>> +       if (do_interp) {
>> +               cycle_t total_history_cycles;
>> +               ktime_t history_monoraw;
>> +               ktime_t history_realtime;
>> +               bool discontinuity;
>> +               cycle_t partial_history_cycles = cycles -  
>> raw_sys.cycles;
>> +
>> +               if (!history_ref || history_ref->cs_seq != cs_seq ||
>
> I've not done a super close reading here. But is it very likely the
> the history_ref->cs_seq is the same as the captured seq? I thought
> this history_ref was to allow old cross stamps to be used to improve
> the back-calculation of the time at the given cycle value. So throwing
> them out if they are older then the last tick seems strange.

Maybe this needs more explanation. The clocksource sequence (cs_seq) is  
incremented for each change in clocksource. I use this to detect a rare  
corner case where the clocksource is changed from (on x86 anyway) TSC and  
then back. If the history crosses one of these changes then interpolation  
shouldn't be attempted (return error). It's not really enough when using  
the history to just check that the current clocksource is equal to the one  
used at the start of the history. The clocksource must not have changed at  
all. To answer your question, it's not at all likely that this would occur.

>
> thanks
> -john
