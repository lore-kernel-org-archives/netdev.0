From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC controller driver
Date: Sun, 15 Jul 2007 23:20:19 +0200
Message-ID: <200707152320.21833.mb@bu3sch.de>
References: <1184491629.3140.59.camel@roc-laptop> <200707151417.10964.mb@bu3sch.de> <1184508064.6030.6.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40818
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbXGOVUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 17:20:41 -0400
In-Reply-To: <1184508064.6030.6.camel@roc-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 July 2007 16:01, Bryan Wu wrote:

> drivers/net/e100.c:             ns->tx_window_errors += le32_to_cpu(s->tx_late_collisions);
> drivers/net/e100.c:             ns->tx_carrier_errors += le32_to_cpu(s->tx_lost_crs);
> drivers/net/e100.c:             ns->tx_fifo_errors += le32_to_cpu(s->tx_underruns);
> drivers/net/e100.c:             ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
> drivers/net/e100.c:                     le32_to_cpu(s->tx_lost_crs);
> drivers/net/e100.c:             ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
> drivers/net/e100.c:             ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
> drivers/net/e100.c:             ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
> drivers/net/e100.c:             ns->rx_over_errors += le32_to_cpu(s->rx_overrun_errors);
> drivers/net/e100.c:             ns->rx_fifo_errors += le32_to_cpu(s->rx_overrun_errors);
> drivers/net/e100.c:             ns->rx_missed_errors += le32_to_cpu(s->rx_resource_errors);
> drivers/net/e100.c:             ns->rx_errors += le32_to_cpu(s->rx_crc_errors) +
> drivers/net/e100.c:                     le32_to_cpu(s->rx_alignment_errors) +
> drivers/net/e100.c:                     le32_to_cpu(s->rx_short_frame_errors) +
> drivers/net/e100.c:                     le32_to_cpu(s->rx_cdt_errors);
> drivers/net/e100.c:             nic->tx_deferred += le32_to_cpu(s->tx_deferred);
> drivers/net/e100.c:                     le32_to_cpu(s->tx_single_collisions);
> drivers/net/e100.c:                     le32_to_cpu(s->tx_multiple_collisions);
> drivers/net/e100.c:                     nic->tx_fc_pause += le32_to_cpu(s->fc_xmt_pause);
> drivers/net/e100.c:                     nic->rx_fc_pause += le32_to_cpu(s->fc_rcv_pause);
> drivers/net/e100.c:                             le32_to_cpu(s->fc_rcv_unsupported);
> drivers/net/e100.c:                             le32_to_cpu(cb->u.tcb.tbd.buf_addr),
> drivers/net/e100.c:                                     le32_to_cpu(cb->u.tcb.tbd.buf_addr),
> ---
> 
> Normally, it is used to protect some rx/tx status flags or dma buf addr.
> 
> Any guide line for this leXX_to_cpu usage?

Easy.

leXX_to_cpu converts a little endian value to CPU-endianess.
So if your CPU is LE, this is a no-op.
The cpu_to_leXX func converts from CPU-endianess to LE.
Same goes for the bigendian variants of the funcs.

In drivers you often have values with specific endianess
(mostly LE, sometimes BE). For example when values are put
by the device to DMA memory. So if the device works in LE,
you must convert the value from LE to CPU endianess after
reading it from DMA.

I your case, however, the issue is different. You had a byte
array and did pointer casting tricks on it. Pointer casting
_is_ a common source for endianess issues. In general, if
you try to cast a pointer, think twice about it. It's likely
a bug. So you had a pointer to a byte array, which is u8*.
You casted that to u16* and u32*. That's broken, because
an u8 array is "little endian". LE means the least significant
part of the entity comes first in memory. Which is obviously
always true for a byte array. So you must use
leXX_to_cpu when doing this kind of pointer tricks.
