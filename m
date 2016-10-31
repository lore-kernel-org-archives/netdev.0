From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause
 frames
Date: Mon, 31 Oct 2016 13:48:39 -0400 (EDT)
Message-ID: <20161031.134839.1774460363929061748.davem@davemloft.net>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zefir.kurtisi@neratec.com,
        scampbel@codeaurora.org, alokc@codeaurora.org,
        shankerd@codeaurora.org, andrew@lunn.ch, f.fainelli@gmail.com
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759598AbcJaRsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:48:45 -0400
In-Reply-To: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 27 Oct 2016 17:05:01 -0500

> The Atheros 8031 PHY supports the 802.3 extension for symmetric and
> asymmetric pause frames, so set that to the list of features supported
> by the phy.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

It looks like Florian and you need to discuss this a little further
but here are some comments on my part.

First of all the PHY state for pause is merely a control for what gets
advertised in negotiation and the result after negotiation completes,
and that's about it.  Maybe is has an influence upon whether PAUSE
frames are passed to/from the MAC, but that would be the largest
extent of it even if so.

The MAC does all of the actual PAUSE processing.  When the MAC sees a
PAUSE frame is backs off it's transmitter.  When the amount of unused
RX buffers in it's ring gets very low, the MAC emits a PAUSE frame.

You also mentioned that you were surprised that getting 900MBit on a
multi-core 2GHZ ARM without drops isn't happening.  Well, this is a
very complex issue to analyze.  I can only give a few pointers after
taking a quick look at this out-of-tree driver.

Are you testing single-flow performance?  If so, even though this is a
multi-queue NIC the traffic will be going over only one of the queues
and thus all of those other cores are basically wasted, because only
one core will be processing this flow's packets.

Next, there are probably a lot of batching optimizations missing from
the driver.  For example, unconditionally always posting replenished
RX buffers ever time you process the RX ring is expensive.  Especially
expensive is the MMIO write to post the new RX buffers.  You should
batch them and only perform the MMIO write when say 8 or more new
RX buffers have been posted.

This is a pretty common optimization if you look at other drivers.

Next, the DMA map/unmap operations could be (relatively) expensive
on this platform and contribute to what packet rates are possible
without drops.

But all of this is speculation, you really need to look at "perf"
output to see if the kernel is spending an excessive amount of time in
one place or another during your tests.  At least this way you'll have
some hard data to work with and have some kind of idea what might be
the reason.
