From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH 2/2] [sky2] Fix for interrupt handler
Date: Thu, 25 Oct 2012 15:36:46 -0700
Message-ID: <20121025223646.GA1131@elie.Belkin>
References: <1341394726.14972.41.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Gilbey <jdg@debian.org>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65093 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab2JYWgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:36:55 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so2334842pbb.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 15:36:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1341394726.14972.41.camel@mlindner-lin.skd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Mirko Lindner wrote:

> Re-enable interrupts if it is not our interrupt
>
> Signed-off-by: Mirko Lindner <mlindner@marvell.com>

Julian (cc-ed) is experiencing tx stalls[1] on a 3.2.y-based kernel:

	WARNING: at [...]/linux-3.2.21/net/sched/sch_generic.c:255 dev_watchdog+0xe9/0x148()
	Hardware name: Inspiron 1545                   
	NETDEV WATCHDOG: eth0 (sky2): transmit queue 0 timed out

Cherry-picking v3.6-rc1~125^2~264 (sky2: Fix for interrupt handler,
2012-07-03) fixes it.

Tested-by: Julian Gilbey <jdg@debian.org>

Dave, would this be a candidate for stable?  Patch left unsnipped for
reference.

Thanks,
Jonathan

[1] http://bugs.debian.org/681280
[2] http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

> ---
>  drivers/net/ethernet/marvell/sky2.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index f1163b2..2b0748d 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -3080,8 +3080,10 @@ static irqreturn_t sky2_intr(int irq, void *dev_id)
>  
>  	/* Reading this mask interrupts as side effect */
>  	status = sky2_read32(hw, B0_Y2_SP_ISRC2);
> -	if (status == 0 || status == ~0)
> +	if (status == 0 || status == ~0) {
> +		sky2_write32(hw, B0_Y2_SP_ICR, 2);
>  		return IRQ_NONE;
> +	}
>  
>  	prefetch(&hw->st_le[hw->st_idx]);
>  
> -- 
> 1.7.10.4
