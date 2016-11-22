From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Tue, 22 Nov 2016 08:12:20 -0500
Message-ID: <b6671242-8c36-4926-2d59-f1faf44042bc@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-18 07:03 AM, Mark Lord wrote:
> On 16-11-18 02:57 AM, Hayes Wang wrote:
> ..
>> Besides, the maximum data length which the RTL8152 would send to
>> the host is 16KB. That is, if the agg_buf_sz is 16KB, the host
>> wouldn't split it. However, you still see problems for it.
>
> How does the RTL8152 know that the limit is 16KB,
> rather than some other number?  Is this a hardwired number
> in the hardware, or is it a parameter that the software
> sends to the chip during initialization?
..
> The first issue is that a packet sometimes begins in one URB,
> and completes in the next URB, without an rx_desc at the start
> of the second URB.  This I have already reported earlier.

Long run tests over the weekend, with the invalidate_dcache_range() call
before the inner loop of r8152_rx_bottom(), turned up a few instances
where packets were truncated inside a 16384 byte URB buffer, without filling the URB.

[10.293228] r8152_rx_bottom: 4278 corrupted urb: head=9d210000 urb_offset=2856/3376 pkt_len(1518) exceeds remainder(496)
[10.304523] r8152_dump_rx_desc: 044805ee 40080000 006005dc 06020000 00000000 00000000 rx_len=1518
..
[   16.660431] r8152_rx_bottom: 7802 corrupted urb: head=9d1f8000 urb_offset=1544/2064 pkt_len(1518) exceeds remainder(496)
[   16.671719] r8152_dump_rx_desc: 044805ee 40480000 004005dc 46020006 00000000 00000000 rx_len=1518

The r8152.c driver attempted to build skb's for the entire packet size,
even though the 1518-byte packets had only 496-bytes of data in the URB.
It is not clear what the chip did with the rest of the packets in question,
but the next URBs in each case began with a new/real rx_desc and new packet.

There were also unconnected events during the test runs where the
test code noticed totally invalid rx_desc structs in the middles of URBs.
The stock driver would again have attempted to treat those as "valid" (ugh).

..
[   10.273906] r8152_check_rx_desc: rx_desc looks bad.
[   10.279012] r8152_rx_bottom: 4338 corrupted urb. head=9d210000 urb_offset=2856/3376 len_used=2880
[   10.288196] r8152_dump_rx_desc: 312e3239 382e3836 0a20382e 3d435253 3034336d 202f3a30 rx_len=12857

..
[    7.184565] r8152_check_rx_desc: rx_desc looks bad.
[    7.189657] r8152_rx_bottom: 1678 corrupted urb. head=9d210000 urb_offset=2856/3376 len_used=2880
[    7.198852] r8152_dump_rx_desc: a1388402 803c9001 84380810 a67c5c4c a77c782b c64c782b rx_len=1026
..
[   10.351251] r8152_check_rx_desc: rx_desc looks bad.
[   10.356356] r8152_rx_bottom: 4397 corrupted urb. head=9d20c000 urb_offset=4400/7984 len_used=4424
[   10.365543] r8152_dump_rx_desc: 312e3239 382e3836 0a20382e 3d435253 3034336d 202f3a30 rx_len=12857
..
[   10.518119] r8152_check_rx_desc: rx_desc looks bad.
[   10.523204] r8152_rx_bottom: 4458 corrupted urb. head=9d210000 urb_offset=4400/7984 len_used=4424
[   10.532416] r8152_dump_rx_desc: 54544120 6e3d5352 636f6c6f 65762c6b 343d7372 6464612c rx_len=16672
..

> But the driver, as written, sometimes accesses bytes outside
> of the 16KB URB buffer, because it trusts the non-existent
> rx_desc in these cases, and also because it accesses bytes
> from the rx_desc without first checking whether there is
> sufficient remaining space in the URB to hold an rx_desc.
>
> These incorrect accesses sometimes touch memory outside
> of the URB buffer.  Since the driver allocates all of its
> rx URB buffers at once, they are highly likely to be
> physically (and therefore virtually) adjacent in memory.
>
> So mistakenly accessing beyond the end of one buffer will
> often result in a read from memory of the next URB buffer.
> Which causes a portion of it to be loaded in the the D-cache.
>
> When that URB is subsequently filled by DMA, there then exists
> a data-consistency issue:  the D-cache contains stale information
> from before the latest DMA cycle.
>
> So this explains the strange memory behaviour observed earlier on.
> When I add a call to invalidate_dcache_range() to the driver
> just before it begins examining a new rx URB, the problems go away.
> So this confirms the observations.
>
> Using non-cacheable RAM also makes the problem go away.
> But neither is a fix for the real buffer overrun accesses in the driver.
>
> Fix the "packet spans URBs" bug, and fix the driver to ALWAYS
> test lengths/ranges before accessing the actual buffer,
> and everything should begin working reliably.
