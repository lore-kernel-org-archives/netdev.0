From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Fix static checker warnings
Date: Tue, 15 Jul 2014 14:57:38 -0700
Message-ID: <53C5A3D2.6090401@chelsio.com>
References: <1405451843-3081-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	dan.carpenter@oracle.com
To: Anish Bhatt <anish@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35671
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934026AbaGOV5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 17:57:45 -0400
In-Reply-To: <1405451843-3081-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   While it's great to fix these warnings, it seems like this might be 
going in the wrong direction.

   Currently only the cxgb4 and bnx2x drivers offer (struct 
dcbnl_rtnl_ops).setapp() calls.  The bnx2x driver also returns -EINVAL, 
etc.  Meanwhile, the only call to the .setapp() entry is in 
dcbnl_setapp() and it stores the result back into an int "ret".  It 
strikes me that the real bug may be an incorrect "u8" return type for 
the .setapp() prototype in include/net/dcbnl.h.  The prototype was added 
in commit 7114323b almost 5 years ago so I'm not sure if the original 
author, Yi Zou <yi.zou@intel.com>, will be around to offer backing 
information on this ...

Casey

On 07/15/14 12:17, Anish Bhatt wrote:
> This patch fixes static checker warnings as pointed out on by Dan Carpenter
>
> Fixes: 76bcb31efc06 ("cxgb4 : Add DCBx support codebase  and dcbnl_ops")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> index a8b1073e6373..8734dfe0da32 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
> @@ -676,15 +676,15 @@ static u8 cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
>   
>   
>   	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
> -		return -EINVAL;
> +		return 0;
>   
>   	/* DCB info gets thrown away on link up */
>   	if (!netif_carrier_ok(dev))
> -		return -ENOLINK;
> +		return 0;
>   
>   	if (app_idtype != DCB_APP_IDTYPE_ETHTYPE &&
>   	    app_idtype != DCB_APP_IDTYPE_PORTNUM)
> -		return -EINVAL;
> +		return 0;
>   
>   	for (i = 0; i < CXGB4_MAX_DCBX_APP_SUPPORTED; i++) {
>   		INIT_PORT_DCB_READ_LOCAL_CMD(pcmd, pi->port_id);
> @@ -710,7 +710,7 @@ static u8 cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
>   	if (i == CXGB4_MAX_DCBX_APP_SUPPORTED) {
>   		/* no empty slots available */
>   		dev_err(adap->pdev_dev, "DCB app table full\n");
> -		return -EBUSY;
> +		return 0;
>   	}
>   
>   	/* write out new app table entry */
