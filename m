From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Fri, 5 Jul 2013 09:17:52 +0200
Message-ID: <20130705091752.675874b5@skate>
References: <20130704173552.GA23370@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:48949 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996Ab3GEHR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 03:17:56 -0400
In-Reply-To: <20130704173552.GA23370@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Thu, 4 Jul 2013 19:35:52 +0200, Willy Tarreau wrote:
> From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 15 Jun 2013 23:25:15 +0200
> Subject: [PATCH] net: convert mvneta to build_skb()
> 
> We store the frag_size in the mvneta_port struct. In practice we'd need
> a single bit to know how to free the data, but since we need the size to
> call build_skb() anyway, let's store the full size.
> 
> With this patch, I observed a reproducible 2% performance improvement on
> HTTP-based benchmarks.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 71 ++++++++++++++++++++++++-----------
>  1 file changed, 50 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index c966785..0f2c6df 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -225,6 +225,7 @@ struct mvneta_stats {
>  
>  struct mvneta_port {
>  	int pkt_size;
> +	unsigned int frag_size;
>  	void __iomem *base;
>  	struct mvneta_rx_queue *rxqs;
>  	struct mvneta_tx_queue *txqs;

Thanks Willy. Sorry for asking such a stupid question, but I'm not very
familiar with how this mechanism works. Can you explain why a single
'frag_size' field per port is sufficient? My concern is that this
frag_size seems to be a per-packet information, but we have potentially
multiple packets being received, and multiple RX queues. Is one single
'frag_size' per network interface sufficient?

For example, in mvneta_rx_refill(), you store the skb_size in
pp->frag_size, and then you later re-use it in mvneta_rxq_drop_pkts.
What guarantees you that mvneta_rx_refill() hasn't be called in the
mean time for a different packet, in a different rxq, for the same
network interface, and the value of pp->frag_size has been overridden?

Again, sorry for this stupid question, this is maybe just some basic
networking knowledge that I'm missing here, but I thought it would be
good to ask anyway.

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
