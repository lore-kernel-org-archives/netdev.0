From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
	structures are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 09:43:55 -0500
Message-ID: <20081111144355.GB16253@gospo.rdu.redhat.com>
References: <20081111140055.GA30481@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54481 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbYKKOqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:46:33 -0500
Content-Disposition: inline
In-Reply-To: <20081111140055.GA30481@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 09:00:55AM -0500, Neil Horman wrote:
> Hey-
> 	I noted recently that bnx2 had a few problems with its poll_controller
> method:
> 
> 1) It passes a net_device structure to bnx2_interrupt, but bnx2_interrupt
> expects a bnx2_napi structure.
> 
> 2) bnx2_interrupt never checks all its rx queues, so theres no guarantee that
> we'll see incomming frames.
> 
> This patch should fix both those problems
> 
> Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  bnx2.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 430d430..9e1f0e3 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -7203,10 +7203,12 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
>  static void
>  poll_bnx2(struct net_device *dev)
>  {
> +	int i;
>  	struct bnx2 *bp = netdev_priv(dev);
>  
>  	disable_irq(bp->pdev->irq);
> -	bnx2_interrupt(bp->pdev->irq, dev);
> +	for (i = 0; i < bp->irq_nvecs; i++)
> +		bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
>  	enable_irq(bp->pdev->irq);
>  }
>  #endif

I suspect bnx2 isn't the only one that needs to address #2 above due to
ever-increasing usage of MSI-X and multiqueue rx.

Acked-by: Andy Gospodarek <andy@greyhouse.net>


