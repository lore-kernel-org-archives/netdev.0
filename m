From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 11:58:02 -0800
Message-ID: <512E654A.2010209@hp.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2013 09:55 AM, Eliezer Tamir wrote:
> This patchset adds the ability for the socket layer code to poll directly
> on an Ethernet device's RX queue. This eliminates the cost of the interrupt
> and context switch and with proper tuning allows us to get very close
> to the HW latency.
>
> This is a follow up to Jesse Brandeburg's Kernel Plumbers talk from last year
> http://www.linuxplumbersconf.org/2012/wp-content/uploads/2012/09/2012-lpc-Low-Latency-Sockets-slides-brandeburg.pdf
>
> Patch 1 adds ndo_ll_poll and the IP code to use it.
> Patch 2 is an example of how TCP can use ndo_ll_poll.
> Patch 3 shows how this method would be implemented for the ixgbe driver.
> Patch 4 adds statistics to the ixgbe driver for ndo_ll_poll events.
> (Optional) Patch 5 is a handy kprobes module to measure detailed latency
> numbers.
>
> this patchset is also available in the following git branch
> git://github.com/jbrandeb/lls.git rfc
>
> Performance numbers:
> Kernel   Config     C3/6  rx-usecs  TCP  UDP
> 3.8rc6   typical    off   adaptive  37k  40k
> 3.8rc6   typical    off   0*        50k  56k
> 3.8rc6   optimized  off   0*        61k  67k
> 3.8rc6   optimized  on    adaptive  26k  29k
> patched  typical    off   adaptive  70k  78k
> patched  optimized  off   adaptive  79k  88k
> patched  optimized  off   100       84k  92k
> patched  optimized  on    adaptive  83k  91k
> *rx-usecs=0 is usually not useful in a production environment.

I would think that latency-sensitive folks would be using rx-usecs=0 in 
production - at least if the NIC in use didn't have low enough latency 
with its default interrupt coalescing/avoidance heuristics.

If I take the first "pure" A/B comparison it seems that the change as 
benchmarked takes latency for TCP from ~27 usec (37k) to ~14 usec (70k). 
  At what request/response size does the benefit taper-off?  13 usec 
seems to be about 16250 bytes at 10 GbE.

When I last looked at netperf TCP_RR performance where something similar 
could happen I think it was IPoIB where it was possible to set things up 
such that polling happened rather than wakeups (perhaps it was with a 
shim library that converted netperf's socket calls to "native" IB).  My 
recollection is that it "did a number" on the netperf service demands 
thanks to the spinning.  It would be a good thing to include those 
figures in any subsequent rounds of benchmarking.

Am I correct in assuming this is a mechanism which would not be used in 
a high aggregate PPS situation?

happy benchmarking,

rick jones
