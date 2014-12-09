From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Mon, 08 Dec 2014 20:44:21 -0500 (EST)
Message-ID: <20141208.204421.1711121007978399962.davem@davemloft.net>
References: <20141202071304.GA22512@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maggie.mae.roxas@gmail.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451AbaLIBoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:44:23 -0500
In-Reply-To: <20141202071304.GA22512@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 2 Dec 2014 08:13:04 +0100

> The mvneta driver sets the amount of Tx coalesce packets to 16 by
> default. Normally that does not cause any trouble since the driver
> uses a much larger Tx ring size (532 packets). But some sockets
> might run with very small buffers, much smaller than the equivalent
> of 16 packets. This is what ping is doing for example, by setting
> SNDBUF to 324 bytes rounded up to 2kB by the kernel.
> 
> The problem is that there is no documented method to force a specific
> packet to emit an interrupt (eg: the last of the ring) nor is it
> possible to make the NIC emit an interrupt after a given delay.
> 
> In this case, it causes trouble, because when ping sends packets over
> its raw socket, the few first packets leave the system, and the first
> 15 packets will be emitted without an IRQ being generated, so without
> the skbs being freed. And since the socket's buffer is small, there's
> no way to reach that amount of packets, and the ping ends up with
> "send: no buffer available" after sending 6 packets. Running with 3
> instances of ping in parallel is enough to hide the problem, because
> with 6 packets per instance, that's 18 packets total, which is enough
> to grant a Tx interrupt before all are sent.
> 
> The original driver in the LSP kernel worked around this design flaw
> by using a software timer to clean up the Tx descriptors. This timer
> was slow and caused terrible network performance on some Tx-bound
> workloads (such as routing) but was enough to make tools like ping
> work correctly.
> 
> Instead here, we simply set the packet counts before interrupt to 1.
> This ensures that each packet sent will produce an interrupt. NAPI
> takes care of coalescing interrupts since the interrupt is disabled
> once generated.
> 
> No measurable performance impact nor CPU usage were observed on small
> nor large packets, including when saturating the link on Tx, and this
> fixes tools like ping which rely on too small a send buffer. If one
> wants to increase this value for certain workloads where it is safe
> to do so, "ethtool -C $dev tx-frames" will override this default
> setting.
> 
> This fix needs to be applied to stable kernels starting with 3.10.
> 
> Tested-By: Maggie Mae Roxas <maggie.mae.roxas@gmail.com>
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Applied and queued up for -stable, thanks.
