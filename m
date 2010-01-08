From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Sat, 9 Jan 2010 00:48:00 +0100
Message-ID: <20100108234800.GA2908@electric-eye.fr.zoreil.com>
References: <4B4357A9.5010507@gmail.com>
 <20100105.124040.192660261.davem@davemloft.net>
 <20100107010122.GA5872@electric-eye.fr.zoreil.com>
 <20100106.171514.104051841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 49.119.116-78.rev.gaoland.net ([78.116.119.49]:60378 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754233Ab0AHXvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 18:51:08 -0500
Content-Disposition: inline
In-Reply-To: <20100106.171514.104051841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 05:15:14PM -0800, David Miller wrote:
[...]
> I don't even think we need to reset the chip, just do what the code
> does now and recycle the buffer back to the chip as we currently do
> when RxRes is set.  We can keep a state bit around, showing that we
> saw the beginning of a fragmented frame, and we recycle buffers back
> to the chip when in state state until we see LastFrag.
> 
> That should work, right ?
> 
> In your trace, we're merely seeing the >1536 frame being chopped
> into a fragmented frame by the device.  The first one has FirstFrag
> set and the remaining (that you've shown) have neither bit set.
> 
> Did you eventually get a descriptor with LastFrag (bit 28) set?

Yes.

For a single packet, at the time the first interruption is received,
4 Rx descriptors have been written. The FirstFrag bit is set on the
first descriptor only and the LastFrag bit is not set anywhere :

entry 019 opts1 0x20803ff0 opts2 0x00000000 used 1536 <- FirstFrag
entry 020 opts1 0x00803ff0 opts2 0x00000000 used 1536
entry 021 opts1 0x00803ff0 opts2 0x00000000 used 1536
entry 022 opts1 0x00803ff0 opts2 0x00000000 used 1536
entry 023 opts1 0x80000600 opts2 0x00000000 used 1524
                                                 ^^^^
(apparently we race with the DMA transfer)

More events pop up, starting at 023. They are all identical to 20 / 21 /22.
It then ends as :

entry 028 opts1 0x00803ff0 opts2 0x00000000 used 1536
entry 029 opts1 0x10803ff0 opts2 0x00000000 used 1010 <- LastFrag bit set
entry 030 opts1 0x80000600 opts2 0x00000000 used 000  <- 0 used byte. Entry
entry 031 opts1 0x80000600 opts2 0x00000000 used 000     is available.
entry 032 opts1 0x80000600 opts2 0x00000000 used 000

The total size of the DMA is not far from 16384 bytes (1536 * 10 + 1010).

Simply recycling the buffer may work. I'll do a few tests with it : I am
still unable to corrupt the descriptor ring itself.

-- 
Ueimor
