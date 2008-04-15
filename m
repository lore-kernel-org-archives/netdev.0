From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Bad network performance over 2Gbps
Date: Tue, 15 Apr 2008 14:05:43 -0700
Message-ID: <480518A7.50703@intel.com>
References: <1208282804.23631.27.camel@localhost> <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com> <48051173.5030802@intel.com> <48051734.1000107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "H. Willstrand" <h.willstrand@gmail.com>,
	Anton Titov <a.titov@host.bg>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50298 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753469AbYDOVIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 17:08:09 -0400
In-Reply-To: <48051734.1000107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Snook wrote:
> Kok, Auke wrote:
>> H. Willstrand wrote:
>>> [Changed mail list]
>>>
>>> On Tue, Apr 15, 2008 at 8:06 PM, Anton Titov <a.titov@host.bg> wrote:
>>>> I use Linux for serving a huge amount of static web on few servers.
>>>> When
>>>>  network traffic goes above 2Gbit/sec ksoftirqd/5 (not every time 5,
>>>> but
>>>>  every time just one) starts using exactly 100% CPU time and packet
>>>>  packet loss starts preventing traffic from going up. When the network
>>>>  traffic is lower than 1.9Gbit ksoftirqds use 0% CPU according to top.
>>>>
>>>>  Uplink is 6 gigabit Intel cards bonded together using 802.3ad
>>>> algorithm
>>>>  with xmit_hash_policy set to layer3+4. On the other side is Cisco 2960
>>>>  switch. Machine is with two quad core Intel Xeons @2.33GHz.
>>>>
>>>>  Here goes a screen snapshot of "top" command. The described behavior
>>>>  have nothing to do with 13% io-wait. It happens even if it is 0%
>>>>  io-wait.
>>>>  http://www.titov.net/misc/top-snap.png
>>>>
>>>>  kernel configuration:
>>>>  http://www.titov.net/misc/config.gz
>>>>
>>>>  /proc/interrupts, lspci, dmesg (nothing intresting there), ifconfig,
>>>>  uname -a:
>>>>  http://www.titov.net/misc/misc.txt.gz
>>>>
>>>>  Is it a Linux bug or some hardware limitation?
>>
>> I'm wondering if this is not a classical demonstration of the NAPI-irq
>> trap where
>> after migration all the interrupts from the various cards are migrated
>> to a single
>> CPU, and because of NAPI once they're busy polling won't ever migrate
>> away from
>> that CPU again.
>>
>> Have you looked at `cat /proc/interrupts` before and after this happens?
>>
>> My guess is that your specific situation can benefit from setting
>> smp_affinity and
>> forcing the NIC irq's so that you're at least occupying the load over
>> multiple
>> CPU's (but preferably ones that use the same cache!) will help relieve
>> the situation.
>>
>> alternatively you might even see an improvement by disabling NAPI.
>> depending on
>> the driver that you're using this might be possible.
>>
>> I actually don't know much about bonding and how this affects
>> everything, but my
>> guess is that that's a less important factor in this issue.
>>
>> Cheers,
>>
>> Auke
> 
> I'm not sure that spreading IRQs out completely is necessarily a good
> idea, due to cache line ping-pong.  I suspect you'll get optimal
> performance by assigning the six IRQs to two cores that share an L2 cache.
> 
> Still, I think you're on to something here.  Disabling NAPI and instead
> tuning the cards' interrupt coalescing settings might allow irqbalance
> to do a better job than it is currently.

well I posted another reply to him after I looked at the debug output he posted
and it appeats that the in-kernel irqbalance is the culprit and the 100% softirqd
is because his interrupts are being balanced across all cores, therefore pretty
much guaranteeing him full cache misses on every single receive, not to mention
unneeded migration of tasks.

I definately think we should disable the in-kernel irqbalance option by default :)

as to what the best solution is with 6 adapters is not clear as they're all on the
same bridge, but hard setting the affinity to two cores that share an L2 seems to
give the best results quickly.

Cheers,

Auke
