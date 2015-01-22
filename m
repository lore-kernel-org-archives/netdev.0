From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: netxen: box stuck in netxen_napi_disable()
Date: Thu, 22 Jan 2015 07:15:58 +0100
Message-ID: <1421907358.5286.42.camel@marge.simpson.net>
References: <1421901805.5286.37.camel@marge.simpson.net>
	 <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:46533 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbAVGQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 01:16:03 -0500
Received: by mail-wg0-f49.google.com with SMTP id l18so18086369wgh.8
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 22:16:01 -0800 (PST)
In-Reply-To: <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-21 at 21:57 -0800, Eric Dumazet wrote:

> This driver doesn't follow the NAPI model correctly.
> 
> Please try following fix :

Thanks Eric, I'll plug it in in a bit and poke at it.  No news is good
news, as good as news gets for unknown repeatability bugs that is ;-)

> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> index 613037584d08..c531c8ae1be4 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> @@ -2388,7 +2388,10 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
>  
>  	work_done = netxen_process_rcv_ring(sds_ring, budget);
>  
> -	if ((work_done < budget) && tx_complete) {
> +	if (!tx_complete)
> +		work_done = budget;
> +
> +	if (work_done < budget) {
>  		napi_complete(&sds_ring->napi);
>  		if (test_bit(__NX_DEV_UP, &adapter->state))
>  			netxen_nic_enable_int(sds_ring);
> 
> 
