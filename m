From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] enic: fix work done in tx napi_poll
Date: Wed, 12 Nov 2014 15:44:06 -0800
Message-ID: <5463F0C6.80501@gmail.com>
References: <1415832126-31901-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com,
	"edumazet@google.com >> Eric Dumazet" <edumazet@google.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:64456 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbaKLXoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 18:44:16 -0500
Received: by mail-pa0-f49.google.com with SMTP id lj1so13905462pab.22
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 15:44:15 -0800 (PST)
In-Reply-To: <1415832126-31901-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2014 02:42 PM, Govindarajulu Varadarajan wrote:
> With the commit d75b1ade567 ("net: less interrupt masking in NAPI") napi repoll
> is done only when work_done == budget. In tx napi poll we always return 0.
> So tx napi is not called again and we do not clean up the tx ring.

Good catch, I had exactly the same bug in bcmsysport.c, sounds like
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c could also need a fix.

Thanks!

> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 73cf165..5afe360 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -1312,9 +1312,10 @@ static int enic_poll_msix_wq(struct napi_struct *napi, int budget)
>  	if (!wq_work_done) {
>  		napi_complete(napi);
>  		vnic_intr_unmask(&enic->intr[intr]);
> +		return 0;
>  	}
>  
> -	return 0;
> +	return budget;
>  }
>  
>  static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
> 
