From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Wed, 06 Jan 2010 17:15:14 -0800 (PST)
Message-ID: <20100106.171514.104051841.davem@davemloft.net>
References: <4B4357A9.5010507@gmail.com>
	<20100105.124040.192660261.davem@davemloft.net>
	<20100107010122.GA5872@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756519Ab0AGBPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 20:15:09 -0500
In-Reply-To: <20100107010122.GA5872@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 7 Jan 2010 02:01:22 +0100

> entry 024 opts1 0x20803ff0 opts2 0x00000000 size 1536 <- problem starts here.
> entry 025 opts1 0x00803ff0 opts2 0x00000000 size 1536    The lines below are
> entry 026 opts1 0x00803ff0 opts2 0x00000000 size 1536    not meaningful.
> entry 027 opts1 0x00803ff0 opts2 0x00000000 size 1536
> 
> The driver will mess things up because it needs the desc->opts1.RxRes bit
> to be set before it claims that the packet is broken. Since this condition
> is not fulfilled when opts1 = 0x20803ff0, the problem goes unnoticed and
> it can be further exploited.
> 
> AFAIUI, if the driver does not lose sync (to use the paper's words), i.e.
> if it notices the condition above and stops / resets the chipset, there
> is not much to exploit.

Thanks for doing this test.

Also note the FirstFrag and LastFrag bits.  Here we see FirstFrag set,
and this indicates a fragmented frame.

The fix seems to be to simply check the error bits unconditionally, or
alternatively validate the FirstFrag and LastFrag bits
unconditionally.

I don't even think we need to reset the chip, just do what the code
does now and recycle the buffer back to the chip as we currently do
when RxRes is set.  We can keep a state bit around, showing that we
saw the beginning of a fragmented frame, and we recycle buffers back
to the chip when in state state until we see LastFrag.

That should work, right?

In your trace, we're merely seeing the >1536 frame being chopped
into a fragmented frame by the device.  The first one has FirstFrag
set and the remaining (that you've shown) have neither bit set.

Did you eventually get a descriptor with LastFrag (bit 28) set?
