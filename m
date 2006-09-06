From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/5] skge: irq lock race
Date: Wed, 06 Sep 2006 11:19:13 -0400
Message-ID: <44FEE6F1.7010701@pobox.com>
References: <20060901225346.750571061@zqx3.pdx.osdl.net> <20060901225449.239532256@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:19931 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751219AbWIFPTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:19:16 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060901225449.239532256@zqx3.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The driver needs to access the IRQ status inside of lock to avoid
> races with other places changing IRQ mask etc. This may be related
> to some of the SMP bugs reported against skge in kernel bugzilla.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- netdev-2.6.orig/drivers/net/skge.c
> +++ netdev-2.6/drivers/net/skge.c
> @@ -2891,13 +2891,15 @@ static irqreturn_t skge_intr(int irq, vo
>  {
>  	struct skge_hw *hw = dev_id;
>  	u32 status;
> +	int handled = 0;
>  
> +	spin_lock(&hw->hw_lock);
>  	/* Reading this register masks IRQ */
>  	status = skge_read32(hw, B0_SP_ISRC);
>  	if (status == 0)
> -		return IRQ_NONE;
> +		goto out;

You also need to check for device/hardware fault here (status==0xffffffff).

	Jeff



