From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 1/2] net: remove NET_LL_RX_POLL config menue
Date: Thu, 13 Jun 2013 13:09:36 +0300
Message-ID: <51B99A60.6010605@linux.intel.com>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com> <20130611142428.17879.33582.stgit@ladj378.jer.intel.com> <20130612.151205.1822920389019274346.davem@davemloft.net> <20130612190103.1545e310@nehalam.linuxnetplumber.net> <51B92ACE.7000307@linux.intel.com> <51B97C1A.8000302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, eliezer@tamir.org.il
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B97C1A.8000302@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/06/2013 11:00, Daniel Borkmann wrote:
> On 06/13/2013 04:13 AM, Eliezer Tamir wrote:
>> On 13/06/2013 05:01, Stephen Hemminger wrote:
>>> On Wed, 12 Jun 2013 15:12:05 -0700 (PDT)
>>> David Miller <davem@davemloft.net> wrote:
>>>
>>>> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>>>> Date: Tue, 11 Jun 2013 17:24:28 +0300
>>>>
>>>>>       depends on X86_TSC
>>>>
>>>> Wait a second, I didn't notice this before.  There needs to be a better
>>>> way to test for the accuracy you need, or if the issue is lack of a
>>>> proper
>>>> API for cycle counter reading, fix that rather than add ugly arch
>>>> specific dependencies to generic networking code.
>>>
>>> This should be sched_clock(), rather than direct TSC access.
>>> Also any code using TSC or sched_clock has to be carefully audited to
>>> deal with
>>> clocks running at different rates on different CPU's. Basically value
>>> is only
>>> meaning full on same CPU.
>>
>> OK,
>>
>> If we covert to sched_clock(), would adding a define such as
>> HAVE_HIGH_PRECISION_CLOCK to architectures that have both a high
>> precision clock and a 64 bit cycles_t be a good solution?
>>
>> (if not any other suggestion?)
>
> Hm, probably cpu_clock() and similar might be better, since they use
> sched_clock() in the background when !CONFIG_HAVE_UNSTABLE_SCHED_CLOCK
> (meaning when sched_clock() provides synchronized highres time source from
> the architecture), and, quoting ....

I don't think we want the overhead of disabling IRQs
that cpu_clock() adds.

We don't really care about precise measurement.
All we need is a sane cut-off for busy polling.
It's no big deal if on a rare occasion we poll less,
or even poll twice the time.
As long as it's rare it should not matter.

Maybe the answer is not to use cycle counting at all?
Maybe just wait the full sk_rcvtimo?
(resched() when proper, bail out if signal pending, etc.)

This could only be a safe/sane thing to do after we add
a socket option, because this can't be a global setting.

This would of course turn the option into a flag.
If it's set (and !nonblock), busy wait up to sk_recvtimo.

Opinions?
