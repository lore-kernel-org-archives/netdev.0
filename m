From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 18 Nov 2016 07:03:28 -0500
Message-ID: <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-18 02:57 AM, Hayes Wang wrote:
..
> Besides, the maximum data length which the RTL8152 would send to
> the host is 16KB. That is, if the agg_buf_sz is 16KB, the host
> wouldn't split it. However, you still see problems for it.

How does the RTL8152 know that the limit is 16KB,
rather than some other number?  Is this a hardwired number
in the hardware, or is it a parameter that the software
sends to the chip during initialization?

I have a USB analyzer, but it is difficult to figure out how
to program an appropriate trigger point for the capture,
since the problem (with 16KB URBs) takes minutes to hours
or even days to trigger.

And the output from the analyzer is in some proprietary format.
The in-kernel software analzer could be useful, but I have never
figured out how to use it.  :)

Since my earlier email, I have figured out another piece of the
puzzle with this dongle.

The first issue is that a packet sometimes begins in one URB,
and completes in the next URB, without an rx_desc at the start
of the second URB.  This I have already reported earlier.

But the driver, as written, sometimes accesses bytes outside
of the 16KB URB buffer, because it trusts the non-existent
rx_desc in these cases, and also because it accesses bytes
from the rx_desc without first checking whether there is
sufficient remaining space in the URB to hold an rx_desc.

These incorrect accesses sometimes touch memory outside
of the URB buffer.  Since the driver allocates all of its
rx URB buffers at once, they are highly likely to be
physically (and therefore virtually) adjacent in memory.

So mistakenly accessing beyond the end of one buffer will
often result in a read from memory of the next URB buffer.
Which causes a portion of it to be loaded in the the D-cache.

When that URB is subsequently filled by DMA, there then exists
a data-consistency issue:  the D-cache contains stale information
from before the latest DMA cycle.

So this explains the strange memory behaviour observed earlier on.
When I add a call to invalidate_dcache_range() to the driver
just before it begins examining a new rx URB, the problems go away.
So this confirms the observations.

Using non-cacheable RAM also makes the problem go away.
But neither is a fix for the real buffer overrun accesses in the driver.

Fix the "packet spans URBs" bug, and fix the driver to ALWAYS
test lengths/ranges before accessing the actual buffer,
and everything should begin working reliably.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
