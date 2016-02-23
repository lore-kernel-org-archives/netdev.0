From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v7 6/8] x86: tsc: Always Running Timer (ART) correlated clocksource
Date: Mon, 22 Feb 2016 18:49:10 -0800
Message-ID: <CALCETrUNeYyy6aH3xKusH=nkEwTmgL5XN2o7bjQCqN_wmA3x=Q@mail.gmail.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-7-git-send-email-christopher.s.hall@intel.com>
 <56C63385.9050703@kernel.org> <op.yc9llxxf1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	John Stultz <john.stultz@linaro.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Network Development <netdev@vger.kernel.org>,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <op.yc9llxxf1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 6:38 PM, Christopher Hall
<christopher.s.hall@intel.com> wrote:
> On Thu, 18 Feb 2016 13:11:33 -0800, Andy Lutomirski <luto@kernel.org> wrote:
>>>
>>> +#define X86_FEATURE_INVARIANT_TSC (7*32+4) /* Intel Invariant TSC */
>
>
> This is removed. It was basically an alias for NONSTOP_TSC and not needed.
>
>>
>>> +/*
>>> + * Convert ART to TSC given numerator/denominator found in detect_art()
>>> + */
>>> +struct system_counterval_t convert_art_to_tsc(cycle_t art)
>>> +{
>>> +       u64 tmp, res, rem;
>>> +
>>> +       rem = do_div(art, art_to_tsc_denominator);
>>> +
>>> +       res = art * art_to_tsc_numerator;
>>> +       tmp = rem * art_to_tsc_numerator;
>>> +
>>> +       do_div(tmp, art_to_tsc_denominator);
>>> +       res += tmp;
>>> +
>>> +       return (struct system_counterval_t) {.cs =
>>> art_related_clocksource,
>>> +                       .cycles = res};
>>
>>
>> The SDM and the patch description both mention an offset "k".  Shouldn't
>> this code at least have a comment about how it deals with the k != 0 case?
>
>
> I don't deal with the k != 0 case. I assume that IA32 TSC adjust MSR is 0
> because it's almost always a *bad idea* to change it. I've discussed this
> with a few other developers and there is some consensus agreeing. From an
> earlier related thread Peter Zijlstra asserts that TSC adjust "had
> better" be 0.(http://lkml.iu.edu/hypermail/linux/kernel/1507.3/03734.html).

I'm having trouble finding that in the link you sent.

>
> Do we really need to accommodate BIOS's that do this?

There are three interesting cases that I can think of:

1. Crappy BIOS that sets TSC_ADJUST.  As the not-so-proud owner of a
piece of crap motherboard that actively messes with the TSC, I don't
trust BIOS.

2. Hypervisors.  What if we're running as a guest with an ART-using
NIC passed through?

3. Hypothetical improved future kernel that politely uses TSC_ADJUST
to keep the TSC from going backwards across suspend/resume.

--Andy
