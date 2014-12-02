From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 02 Dec 2014 04:18:08 -0800
Message-ID: <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:55930 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbaLBMSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 07:18:10 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so11342903ier.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 04:18:09 -0800 (PST)
In-Reply-To: <20141202071304.GA22512@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 08:13 +0100, Willy Tarreau wrote:
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
> 
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 4762994..35bfba7 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -214,7 +214,7 @@
>  /* Various constants */
>  
>  /* Coalescing */
> -#define MVNETA_TXDONE_COAL_PKTS		16
> +#define MVNETA_TXDONE_COAL_PKTS		1
>  #define MVNETA_RX_COAL_PKTS		32
>  #define MVNETA_RX_COAL_USEC		100
>  


I am surprised TCP even worked correctly with this problem.

I highly suggest BQL for this driver, now this issue is fixed.

I wonder if this high setting was not because of race conditions in the
driver :

mvneta_tx() seems to access skb->len too late, TX completion might have
already freed skb :

                u64_stats_update_begin(&stats->syncp);
                stats->tx_packets++;
                stats->tx_bytes  += skb->len;         // potential use after free
                u64_stats_update_end(&stats->syncp);

Thanks Willy !
