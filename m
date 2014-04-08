From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 8 Apr 2014 08:30:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F1434@AcuExch.aculab.com>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org>
	<1396672506-9296-4-git-send-email-zhangfei.gao@linaro.org>
 <20140407.145356.928382660541891827.davem@davemloft.net>
 <5343AE45.4020308@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: 'zhangfei' <zhangfei.gao@linaro.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46021 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756199AbaDHIcP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 04:32:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26646-06 for <netdev@vger.kernel.org>;
 Tue,  8 Apr 2014 09:32:13 +0100 (BST)
In-Reply-To: <5343AE45.4020308@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zhangfei [mailto:zhangfei.gao@linaro.org]
> On 04/08/2014 02:53 AM, David Miller wrote:
> > From: Zhangfei Gao <zhangfei.gao@linaro.org>
> > Date: Sat,  5 Apr 2014 12:35:06 +0800
> >
> >> +struct tx_desc {
> >> +	u32 send_addr;
> >> +	u16 reserved_16;
> >> +	u16 send_size;

The above doesn't look right for endianness independence.
I'd guess the hardware spec shows a 32bit word with the 'send size'
in one half - that is what you need to define.

Since this is a tx descriptor (and written by the host) you
can't have 'reserved' field - the host has to write it.
probably these are 'must be zero' fields.

> >> +	u32 reserved_32;
> >> +	u32 cfg;
> >> +	u32 wb_addr;
> >> +} ____cacheline_aligned;
> >
> > I do not think that ____cacheline_aligned is appropriate at all here.
> >
> > First of all, this is a hardware descriptor, so it has a fixed layout
> > and therefore size.

The structure also isn't even a multiple of a power of two.
So there will be implicit padding at the end.

Since there isn't a 'pointer to next' I presume the hardware accesses
the descriptors from adjacent physical addresses.
So you need to explicitly pad to that size.
If the cache line size were 128 byte the above wouldn't work at all.

> >
> > Secondly, unless you declare this object statically in the data section
> > of the object file, the alignment doesn't matter.  These descriptors
> > are always dynamically allocated, rather than instantiated in the
> > kernel/driver image.
> 
> The ____cacheline_aligned used here is only for the requirement of
> alignment, and use dma_alloc_coherent, while at first dma_pool is used
> for the requirement of alignment.
> Otherwise desc[1] is not aligned and can not be used directly, the
> structure is smaller.

It sounds like you should be explicitly padding the structure
to 32 bytes - whether or not that is the cache line size.

...
> I am sorry, but unfortunately this series really does NOT have TX done
> interrupt after checked with hardware guy many times.
> And next series will add TX done interrupt according to the feedback.
> 
> There are two reasons of removing the TX done interrupt when the chip is
> designed.
> 1. The specific product does not care the latency, only care the throughput.
> 2. When doing many experiment, the tx done interrupt will impact the
> throughput, as a result reclaim is moved to xmit as one of
> optimizations, then finally tx done interrupt is removed at all.
> 
> Is it acceptable of removing timer as well as latency handling, or any
> other work around of this kind of hardware?

If you don't have a global 'TX done' interrupt, you need a per
descriptor one.
Otherwise you cannot send at maximum rate in the absence of
receive traffic.

	David
