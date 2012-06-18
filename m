From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: added support for 40GbE link.
Date: Mon, 18 Jun 2012 18:09:36 +0100
Message-ID: <1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Parav Pandit <parav.pandit@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62511 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752974Ab2FRRJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 13:09:39 -0400
In-Reply-To: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 18:14 +0530, Parav Pandit wrote:
> 1. link speed of 40GbE and #4 KR4, CR4, SR4, LR4 modes defined.
> 2. removed code replication for tov calculation for 1G, 10G and
> made is common for 1G, 10G, 40G.
[...]
> @@ -1185,12 +1193,13 @@ struct ethtool_ops {
>   * it was forced up into this mode or autonegotiated.
>   */
>  
> -/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
> +/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE, 40GbE. */
>  #define SPEED_10		10
>  #define SPEED_100		100
>  #define SPEED_1000		1000
>  #define SPEED_2500		2500
>  #define SPEED_10000		10000
> +#define SPEED_40000		40000
>  #define SPEED_UNKNOWN		-1

I don't think there's any need to name all possible link speeds, and it
just encourages the bad practice of ethtool API users checking for
specific values.  You may notice there is no SPEED_20000.

>  /* Duplex, half or full. */
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 8a10d5b..dd0e503 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -542,13 +542,11 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
>  	rtnl_unlock();
>  	if (!err) {
>  		switch (ecmd.speed) {
> -		case SPEED_10000:
> -			msec = 1;
> -			div = 10000/1000;
> -			break;
>  		case SPEED_1000:
> +		case SPEED_10000:
> +		case SPEED_40000:
>  			msec = 1;
> -			div = 1000/1000;
> +			div = ecmd.speed / 1000;
>  			break;

This function should be fixed properly.  Firstly, it must use
ethtool_cmd_speed() rather than directly accessing ecmd.speed.
Secondly, it should allow any speed value rather than checking for
specific values.  Then there will be no need to make further changes for
100G or any other new speed.

Ben.

>  		/*
>  		 * If the link speed is so slow you don't really

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
