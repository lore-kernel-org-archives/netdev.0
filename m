From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [RFC v5 3/6] Add history to cross timestamp interface supporting
 slower devices
Date: Fri, 08 Jan 2016 14:28:56 -0800
Message-ID: <op.yaxx2ivm1774gr@chall-mobl2.amr.corp.intel.com>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
 <1451911523-8534-4-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLVACLP1_PGWh5Ha9P6DT+HfDu9vg-B5NCShuFvNu21WUQ@mail.gmail.com>
 <op.yawaqe0i1774gr@chall-mobl2.amr.corp.intel.com>
 <alpine.DEB.2.11.1601081503210.3575@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "John Stultz" <john.stultz@linaro.org>,
	"Richard Cochran" <richardcochran@gmail.com>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1601081503210.3575@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Jan 2016 06:04:28 -0800, Thomas Gleixner <tglx@linutronix.de>  
wrote:
> On Thu, 7 Jan 2016, Christopher Hall wrote:
>> On Wed, 06 Jan 2016 11:37:23 -0800, John Stultz <john.stultz@linaro.org>
>> wrote:
>> > I've not done a super close reading here. But is it very likely the
>> > the history_ref->cs_seq is the same as the captured seq? I thought
>> > this history_ref was to allow old cross stamps to be used to improve
>> > the back-calculation of the time at the given cycle value. So throwing
>> > them out if they are older then the last tick seems strange.
>>
>> Maybe this needs more explanation. The clocksource sequence (cs_seq) is
>> incremented for each change in clocksource. I use this to detect a rare  
>> corner
>> case where the clocksource is changed from (on x86 anyway) TSC and then  
>> back.
>> If the history crosses one of these changes then interpolation  
>> shouldn't be
>> attempted (return error). It's not really enough when using the history  
>> to
>> just check that the current clocksource is equal to the one used at the  
>> start
>> of the history. The clocksource must not have changed at all. To answer  
>> your
>> question, it's not at all likely that this would occur.
>
> You can flush the history when a clocksource change happens. No need to  
> add
> extra data to the core structures.

Hi Thomas,

For slower devices like Intel's audio DSP, it's the responsibility of the  
driver to manage the history which is supplied as an argument to  
get_device_system_crosststamp(). The history is a triple (counter value,  
mono-raw time, real time). The clocksource change sequence number allows  
the timekeeping code to determine whether the supplied history is stale  
(returning an error if it is). I'm calling any history stale that crosses  
a clocksource change boundary.

Logically, the keeping of the history is split between the driver and  
timekeeping code with most of the burden on the driver. This introduces a  
small amount of redundancy in the form of the clocksource change sequence,  
but on balance results in a lot simpler timekeeping code.

Chris
