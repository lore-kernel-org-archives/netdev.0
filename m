From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Wed, 16 Dec 2009 10:40:30 -0800
Message-ID: <1260988830.31045.79.camel@nseg_linux_HP1.broadcom.com>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
 <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
 <1260965365-14255-3-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3477 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782AbZLPSun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 13:50:43 -0500
In-Reply-To: <1260965365-14255-3-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-12-16 at 04:09 -0800, leitao@linux.vnet.ibm.com wrote:
> Acutally if a BNX2 interface gets time outs, the reset_task is
> called to restart the interface. But, the NIC is turned off with
> some packages to transmitt, and this causes the function
> napi_disable() to loop forever, crashing the kernel.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> ---
>  drivers/net/bnx2.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index f81f082..40c883b 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -652,8 +652,6 @@ bnx2_napi_enable(struct bnx2 *bp)
>  static void
>  bnx2_netif_stop(struct bnx2 *bp)
>  {
> -	bnx2_cnic_stop(bp);

bnx2_cnic_stop() needs to be done before NAPI is disabled because we
still need to service events in NAPI while stopping cnic.  So we need to
keep the call here.

> -	bnx2_disable_int_sync(bp);
>  	if (netif_running(bp->dev)) {
>  		int i;
>  
> @@ -667,6 +665,8 @@ bnx2_netif_stop(struct bnx2 *bp)
>  			txq->trans_start = jiffies;
>  		}
>  	}
> +	bnx2_cnic_stop(bp);
> +	bnx2_disable_int_sync(bp);

Moving bnx2_disable_int_sync() here looks ok.  Thanks.

>  }
>  
>  static void


