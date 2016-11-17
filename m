From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 17 Nov 2016 09:14:16 -0500
Message-ID: <a4a43da6-54e0-a9c8-8802-acb4e6c4a2c8@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.start.ca ([64.140.120.243]:55615 "EHLO mail3.start.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936397AbcKQO3j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 09:29:39 -0500
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resending.. not sure if the original had mailer errors)

On 16-11-16 10:36 PM, Hayes Wang wrote:
 > [...]
 >> Fix the hw rx checksum is always enabled, and the user couldn't switch
 >> it to sw rx checksum.
 >>
 >> Note that the RTL_VER_01 only supports sw rx checksum only. Besides,
 >> the hw rx checksum for RTL_VER_02 is disabled after
 >> commit b9a321b48af4 ("r8152: Fix broken RX checksums."). Re-enable it.
 >
 > Excuse me. If I want to re-send this one patch, should I let
 > RTL_VER_02 use rx hw checksum?

Definitely NOT.

I am still doing low-level tracing through the driver as time permits,
and just now found some really interesting evidence.

Using coherent buffers (non-cacheable, allocated with usb_alloc_coherent),
I can get it to fail extremely regularly by simply reducing the buffer size
(agg_buf_sz) from 16KB down to 4KB.   This makes reproducing the issue
much much easier -- the same problems do happen with the larger 16KB size,
but much less often than with smaller sizes.

So.. with a 4KB URB transfer_buffer size, along with a ton of added error-checking,
I see this behaviour every 10 (rx) URBs or so:

First URB (number 593):
[   34.260667] r8152_rx_bottom: 593 corrupted urb: head=bf014000 urb_offset=2856/4096 pkt_len(1518) exceeds remainder(1216)
[   34.271931] r8152_dump_rx_desc: 044805ee 40080000 006005dc 06020000 00000000 00000000 rx_len=1518

Next URB (number 594):
[   34.281172] r8152_check_rx_desc: rx_desc looks bad.
[   34.286228] r8152_rx_bottom: 594 corrupted urb. head=bf018000 urb_offset=0/304 len_used=24
[   34.294774] r8152_dump_rx_desc: 00008300 00008400 00008500 00008600 00008700 00008800 rx_len=768

What the above sample shows, is the URB transfer buffer ran out of space in the middle
of a packet, and the hardware then tried to just continue that same packet in the next URB,
without an rx_desc header inserted.  The r8152.c driver always assumes the URB buffer begins
with an rx_desc, so of course this behaviour produces really weird effects, and system crashes, etc..

So until that driver bug is addressed, I would advise disabling hardware RX checksums
for all chip versions, not only for version 02.

It is not clear to me how the chip decides when to forward an rx URB to the host.
If you could describe how that part works for us, then it would help in further
understanding why fast systems (eg. a PC) don't generally notice the issue,
while much slower embedded systems do see the issue regularly.

Thanks
Mark
