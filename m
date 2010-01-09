From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Fri, 08 Jan 2010 16:02:52 -0800 (PST)
Message-ID: <20100108.160252.189352309.davem@davemloft.net>
References: <20100107010122.GA5872@electric-eye.fr.zoreil.com>
	<20100106.171514.104051841.davem@davemloft.net>
	<20100108234800.GA2908@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754498Ab0AIACo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 19:02:44 -0500
In-Reply-To: <20100108234800.GA2908@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 9 Jan 2010 00:48:00 +0100

> For a single packet, at the time the first interruption is received,
> 4 Rx descriptors have been written. The FirstFrag bit is set on the
> first descriptor only and the LastFrag bit is not set anywhere :
> 
> entry 019 opts1 0x20803ff0 opts2 0x00000000 used 1536 <- FirstFrag
> entry 020 opts1 0x00803ff0 opts2 0x00000000 used 1536
> entry 021 opts1 0x00803ff0 opts2 0x00000000 used 1536
> entry 022 opts1 0x00803ff0 opts2 0x00000000 used 1536
> entry 023 opts1 0x80000600 opts2 0x00000000 used 1524
>                                                  ^^^^
> (apparently we race with the DMA transfer)
>
> More events pop up, starting at 023. They are all identical to 20 / 21 /22.
> It then ends as :
> 
> entry 028 opts1 0x00803ff0 opts2 0x00000000 used 1536
> entry 029 opts1 0x10803ff0 opts2 0x00000000 used 1010 <- LastFrag bit set
> entry 030 opts1 0x80000600 opts2 0x00000000 used 000  <- 0 used byte. Entry
> entry 031 opts1 0x80000600 opts2 0x00000000 used 000     is available.
> entry 032 opts1 0x80000600 opts2 0x00000000 used 000
> 
> The total size of the DMA is not far from 16384 bytes (1536 * 10 + 1010).

My guess is that once the chip starts filling out frags like this,
the signal to trigger what should be the LastFrag entry never
propagates to the DMA engine and thus the descriptor table.

Thus the device just keeps filling packet contents with subsequent
data, with FirstFrag and LastFrag clear, until that ~16K limit is
reached.  At which point it finally sets LastFrag.

> Simply recycling the buffer may work. I'll do a few tests with it : I am
> still unable to corrupt the descriptor ring itself.

Whilst the above will end up gobbling up to (16K - BIG_PACKET_SZ)
worth of innocent frames, the DMA engine seems to keep things at least
self-consistent.

The only bug seems to be the omission of the LastFrag trigger at the
proper place.

About recycling, as far as I can tell that's exactly what the driver
already does in these exact cases, right?  If RxRes is not set, and
we don't see both FirstFrag and LastFrag set, we'll recycle the frame.

		if (unlikely(status & RxRES)) {
 ...
		} else {
 ...
			if (unlikely(rtl8169_fragmented_frame(status))) {
				dev->stats.rx_dropped++;
				dev->stats.rx_length_errors++;
				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
				continue;
			}

Therefore we shouldn't need to change anything and there is actually
no "bug" or "exploit" at all.  We just end up dropping some RX frames
because the chip didn't DMA them properly.

