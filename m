From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Wed, 14 Oct 2015 18:57:33 -0700
Message-ID: <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1510132116480.25029@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1510132116480.25029@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas,

On Tue, 13 Oct 2015 12:42:52 -0700, Thomas Gleixner <tglx@linutronix.de>  
wrote:
> On Mon, 12 Oct 2015, Christopher S. Hall wrote:
>> audio.
>
> This wants to be a seperate patch, really.

OK. This makes sense, I'll do this the next time.

>> +/* This needs to be 3 or greater for backtracking to be useful */
>
> Why?

The current index points to a copy and the next may be being changed by  
update_wall_time(). Leaving n-2 entries available with useful history in  
them. I'll add more descriptive comments here.

>
>> +#define SHADOW_HISTORY_DEPTH 7
>
> And that number is 7 because?

Due to power of 2 it will be 8 instead. As above the useful history is  
8-2*1 ms (1 ms is the minimum jiffy length).  Array size 4 would not be  
enough history for the DSP which requires 4 ms of history, in the worst  
case.

>> +static int shadow_index = -1; /* incremented to zero in
>
> What's the point of this? Aside of that, please do not use tail comments.

It's removed.  A check for validity is added below and this isn't  
necessary.

> That's silly. Make DEPTH a power of 2 and do:
>
>        idx = (idx + 1) & (DEPTH - 1);

This is changed.

>> +		true : *shadow_index_out < shadow_index;
>
> All this can go away.

Yes.

>> +	/* Also make sure that entry is valid based on current shadow_index */
>> +	*shadow_index_io = ret;
>> +	return true;
>
> You surely try hard to do stuff in the most unreadable way.

Is like this easier to follow?

+static struct timekeeper *search_shadow_history(cycles_t cycles,
+                                               struct clocksource *cs)
+{
+       struct timekeeper *tk = &tk_core.timekeeper;
+       int srchidx = shadow_index;
+       cycles_t cycles_start, cycles_end;
+
+       cycles_start = tk->tkr_mono.cycle_last;
+       do {
+               srchidx = !srchidx-- ? srchidx+SHADOW_HISTORY_DEPTH :  
srchidx;
+               tk = shadow_timekeeper + srchidx;
+
+               /* The next shadow entry may be in flight, don't use it */
+               if (srchidx == ((shadow_index+1) &  
(SHADOW_HISTORY_DEPTH-1)))
+                       return NULL;
+
+               /* Make sure timekeeper is related to clock on this  
interval */
+               if (tk->tkr_mono.clock != cs)
+                       return NULL;
+
+               cycles_end = cycles_start;
+               cycles_start = tk->tkr_mono.cycle_last;
+       } while (!cycle_between(cycles_start, cycles, cycles_end));
+
+       return tk;
+}
A check for validity is added here using the clocksource pointer.

and inside of get_correlated_timestamp():

+                * into account. If the value is in the past, try to  
backtrack
+                */
+               cycles_end = tk->tkr_mono.read(tk->tkr_mono.clock);
+               cycles_start = tk->tkr_mono.cycle_last;
+               if (!cycle_between(cycles_start, cycles, cycles_end)) {
+                       tk = search_shadow_history(cycles,  
crs->related_cs);
+                       if (!tk)
+                               return -EAGAIN;
+               }



>> +		/*
>> +		 * Get a timestamp from the device if get_ts is non-NULL
>> +		 */
>> +		if( crt->get_ts ) {
>> +			ret = crt->get_ts(crt);
>> +			if (ret)
>> +				return ret;
>> +		}
>
> What's the point of this? Why are you not making the few lines which
> you can actually reuse a helper function and leave the PTP code alone?

The audio driver is structured in such a way that it's simpler to provide  
a value rather than a callback.  I changed this to allow the audio  
developers to provide an ART value as input.  If a callback is provided,  
the resulting counter value is guaranteed to be later than cycle_last and  
there is no need to do extra checking (the goto skips that check).  Is  
this an answer to your question?

> So I reached enf of patch and did not find anything in
> timekeeping_init() which tells that the index is incremented to 0. It
> really would need a comment, but why do you want to do that at all. It
> does not matter whether the first entry is at 0 or 1. You need a
> validity check for the entries anyway.

I think this should be resolved.  There's no sensitivity with regard to  
the start index with an added validity check.

Thanks,
Chris
