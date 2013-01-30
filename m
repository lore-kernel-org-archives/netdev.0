From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [BUG] via-rhine: NOHZ: local_softirq_pending 08
Date: Tue, 29 Jan 2013 23:54:19 -0400
Message-ID: <51089971.132a650a.2c30.06ca@mx.google.com>
References: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
 <20130129.174702.196275387733819730.davem@davemloft.net>
 <20130130000432.GA28621@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rl@hellgate.ch,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f179.google.com ([209.85.161.179]:56844 "EHLO
	mail-gg0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282Ab3A3Dy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 22:54:27 -0500
Received: by mail-gg0-f179.google.com with SMTP id h4so199060ggn.10
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 19:54:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130130000432.GA28621@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 01:04:32AM +0100, Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
> [...]
> > I don't think you can't keep using dev_kfree_skb_irq() there.
> > 
> > Francois any objections to this patch?
> 
> None.
> 
> I have almost surely broken via-rhine with NOHZ as I broke the r8169
> driver before 7dbb491878a2c51d372a8890fa45a8ff80358af1. Something like
> the patch below could be needed as well (quick shot before bed time
> and ~24h delay if Jamie wants to try something now).
> 
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index 7992b3e..5c7e900 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -2010,11 +2010,7 @@ static void rhine_slow_event_task(struct work_struct *work)
>  	if (intr_status & IntrPCIErr)
>  		netif_warn(rp, hw, dev, "PCI error\n");
>  
> -	napi_disable(&rp->napi);
> -	rhine_irq_disable(rp);
> -	/* Slow and safe. Consider __napi_schedule as a replacement ? */
> -	napi_enable(&rp->napi);
> -	napi_schedule(&rp->napi);
> +	iowrite16(RHINE_EVENT & 0xffff, rp->base + IntrEnable);
>  
>  out_unlock:
>  	mutex_unlock(&rp->task_lock);

Francois's patch fixed the issue for me. thanks!

Regards,
Jamie Gloudon
