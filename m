From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy
Date: Thu, 13 Mar 2014 18:23:04 +0000
Message-ID: <5321F788.2010402@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com> <1394705313.25873.13.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>,
	Marcus Granado <Marcus.Granado@eu.citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394705313.25873.13.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/14 10:08, Ian Campbell wrote:
> On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
>> >A long known problem of the upstream netback implementation that on the TX
>> >path (from guest to Dom0) it copies the whole packet from guest memory into
>> >Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
>> >huge perfomance penalty. The classic kernel version of netback used grant
>> >mapping, and to get notified when the page can be unmapped, it used page
>> >destructors. Unfortunately that destructor is not an upstreamable solution.
>> >Ian Campbell's skb fragment destructor patch series [1] tried to solve this
>> >problem, however it seems to be very invasive on the network stack's code,
>> >and therefore haven't progressed very well.
>> >This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
>> >know when the skb is freed up. That is the way KVM solved the same problem,
>> >and based on my initial tests it can do the same for us. Avoiding the extra
>> >copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower AMD
>> >Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
>> >running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
>> >switch)
> Do you have any other numbers? e.g. for a modern Intel or AMD system? A
> slower box is likely to make the difference between copy and map larger,
> whereas modern Intel for example is supposed to be very good at copying.
Performance team made a lot of measurements, I've added Marcus to 
comment on that.
With the latest version and tip net-next kernel I could see even ~9.3 
Gbps peak throughput on the same AMD box, which is the practical maximum 
for 10G cards. However with older guests I couldn't reach that. A lot 
depends on netfront and TCP stack, e.g. the tcp_limit_output_bytes 
sysctl can cause an artificial cap.
Perf team now has 40 Gbps NICs I guess, it would be interesting to see 
how does this perform there.
I just checked the intrahost guest-to-guest throughput with 2 upstream 
kernel, I could get out 5.6-5.8 Gbps at most.

>
>> >Based on my investigations the packet get only copied if it is delivered to
>> >Dom0 IP stack through deliver_skb, which is due to this [2] patch. This affects
>> >DomU->Dom0 IP traffic and when Dom0 does routing/NAT for the guest. That's a bit
>> >unfortunate, but luckily it doesn't cause a major regression for this usecase.
> Numbers?
I've checked that back in November:

https://lkml.org/lkml/2013/11/5/288

Originally it was 5.4 vs with my patch it was 5.2. I've checked DomU to 
Dom0 iperf again, about the same still with my series.

Zoli
