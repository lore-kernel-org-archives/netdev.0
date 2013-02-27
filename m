From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 22:40:03 +0200
Message-ID: <512E6F23.3090003@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <512E654A.2010209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512E654A.2010209@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/02/2013 21:58, Rick Jones wrote:
> On 02/27/2013 09:55 AM, Eliezer Tamir wrote:
>>
>> Performance numbers:
>> Kernel   Config     C3/6  rx-usecs  TCP  UDP
>> 3.8rc6   typical    off   adaptive  37k  40k
>> 3.8rc6   typical    off   0*        50k  56k
>> 3.8rc6   optimized  off   0*        61k  67k
>> 3.8rc6   optimized  on    adaptive  26k  29k
>> patched  typical    off   adaptive  70k  78k
>> patched  optimized  off   adaptive  79k  88k
>> patched  optimized  off   100       84k  92k
>> patched  optimized  on    adaptive  83k  91k
>> *rx-usecs=0 is usually not useful in a production environment.
>
> I would think that latency-sensitive folks would be using rx-usecs=0 in
> production - at least if the NIC in use didn't have low enough latency
> with its default interrupt coalescing/avoidance heuristics.

It will only work well if you have no bulk traffic on the same port as 
the low latency traffic at all.

> If I take the first "pure" A/B comparison it seems that the change as
> benchmarked takes latency for TCP from ~27 usec (37k) to ~14 usec (70k).
>   At what request/response size does the benefit taper-off?  13 usec
> seems to be about 16250 bytes at 10 GbE.

It's pretty easy to get a result of 80K+ with a little tweaking, an 
rx-usecs value of 100 with C3/6 enabled will get you that.

> When I last looked at netperf TCP_RR performance where something similar
> could happen I think it was IPoIB where it was possible to set things up
> such that polling happened rather than wakeups (perhaps it was with a
> shim library that converted netperf's socket calls to "native" IB).  My
> recollection is that it "did a number" on the netperf service demands
> thanks to the spinning.  It would be a good thing to include those
> figures in any subsequent rounds of benchmarking.

I will get service demand numbers, but we are busy polling so I can tell 
you right now that one core will be at 100%.

> Am I correct in assuming this is a mechanism which would not be used in
> a high aggregate PPS situation?

The current design has in mind situations where you want to react very 
fast to a trigger but that reaction could involve more than short 
messages. so we are willing to burn CPU cycles when there is nothing 
better to do, but we also want to work well when there is bulk traffic.
Ideally I would want the system to be smart about this and to know when 
not to allow busy polling.

> happy benchmarking,
we love netperf.
