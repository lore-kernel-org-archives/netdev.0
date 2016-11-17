From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 17 Nov 2016 09:25:56 -0500
Message-ID: <a0909dd5-e356-8f32-2f58-9e997f868529@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <a4a43da6-54e0-a9c8-8802-acb4e6c4a2c8@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Hayes Wang <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a4a43da6-54e0-a9c8-8802-acb4e6c4a2c8@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-17 09:14 AM, Mark Lord wrote:
..
> Using coherent buffers (non-cacheable, allocated with usb_alloc_coherent),

Note that the same behaviour also happens with the original kmalloc'd buffers.

> I can get it to fail extremely regularly by simply reducing the buffer size
> (agg_buf_sz) from 16KB down to 4KB.   This makes reproducing the issue
> much much easier -- the same problems do happen with the larger 16KB size,
> but much less often than with smaller sizes.

Increasing the buffer size to 64KB makes the problem much less frequent,
as one might expect.  Thus far I haven't seen it happen at all, but a longer
run (1-3 days) is needed to make sure.  This however is NOT a "fix".

> So.. with a 4KB URB transfer_buffer size, along with a ton of added error-checking,
> I see this behaviour every 10 (rx) URBs or so:
>
> First URB (number 593):
> [   34.260667] r8152_rx_bottom: 593 corrupted urb: head=bf014000 urb_offset=2856/4096 pkt_len(1518) exceeds remainder(1216)
> [   34.271931] r8152_dump_rx_desc: 044805ee 40080000 006005dc 06020000 00000000 00000000 rx_len=1518
>
> Next URB (number 594):
> [   34.281172] r8152_check_rx_desc: rx_desc looks bad.
> [   34.286228] r8152_rx_bottom: 594 corrupted urb. head=bf018000 urb_offset=0/304 len_used=24
> [   34.294774] r8152_dump_rx_desc: 00008300 00008400 00008500 00008600 00008700 00008800 rx_len=768
>
> What the above sample shows, is the URB transfer buffer ran out of space in the middle
> of a packet, and the hardware then tried to just continue that same packet in the next URB,
> without an rx_desc header inserted.  The r8152.c driver always assumes the URB buffer begins
> with an rx_desc, so of course this behaviour produces really weird effects, and system crashes, etc..
>
> So until that driver bug is addressed, I would advise disabling hardware RX checksums
> for all chip versions, not only for version 02.
>
> It is not clear to me how the chip decides when to forward an rx URB to the host.
> If you could describe how that part works for us, then it would help in further
> understanding why fast systems (eg. a PC) don't generally notice the issue,
> while much slower embedded systems do see the issue regularly.

That last part is critical to understanding things:
How does the chip decide that a URB is "full enough" before sending it to the host?
Why does a really fast host see fewer packets jammed together into a single URB than a slower host?

The answers will help understand if there are more bugs to be found/fixed,
or if everything is explained by what has been observed thus far.

To recap:  the hardware sometimes fills a URB to the very end, and then continues the
current packet at the first byte of the following URB.  The r8152.c driver does NOT
handle this situation; instead it always interprets the first 24 bytes of every URB
as an "rx_desc" structure, without any kind of sanity/validation.  This results in
buffer overruns (it trusts the packet length field, even though the URB is too small
to hold such a packet), and other semi-random behaviour.

Using software rx checksums prevents Bad Things(tm) happening from most of this,
but even that is not perfect given the severity of the bug.

Cheers
