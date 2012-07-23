From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Mon, 23 Jul 2012 07:16:25 +0200
Message-ID: <1343020585.2626.10054.camel@edumazet-glaptop>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42412 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab2GWFQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 01:16:31 -0400
Received: by weyx8 with SMTP id x8so3975426wey.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 22:16:30 -0700 (PDT)
In-Reply-To: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-22 at 16:19 -0400, Kevin Groeneveld wrote:
> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
> rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
> The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
> SIOCGPPPSTATS ioctl is still 32 bit stats only.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
> ---
>  drivers/net/ppp/ppp_generic.c |  110 +++++++++++++++++++++++++++++++++++------
>  1 file changed, 95 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 5c05572..210238c 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -94,6 +94,19 @@ struct ppp_file {
>  #define PF_TO_CHANNEL(pf)	PF_TO_X(pf, struct channel)
>  
>  /*
> + * Data structure to hold primary network stats for which
> + * we want to use 64 bit storage.  Other network stats
> + * are stored in dev->stats of the ppp strucute.
> + */
> +struct ppp_link_stats {
> +	struct u64_stats_sync syncp;
> +	u64 tx_bytes;
> +	u64 tx_packets;
> +	u64 rx_bytes;
> +	u64 rx_packets;
> +};

Hmm. This patches adds races, but also adds a good amount of memory on
these servers with thousand of ppp devices, and 64 cpus.

I really doubt ppp is performance sensitive, it so doesnt need percpu
counter.

If you really want 64bits stats on ppp, use proper synchronization
around u64 counters (but shared ones)
