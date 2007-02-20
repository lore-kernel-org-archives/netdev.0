From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] forcedeth: fixed missing call in napi poll
Date: Tue, 20 Feb 2007 11:26:01 -0500
Message-ID: <45DB2119.3030402@garzik.org>
References: <45D9B3E8.7030109@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44622 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030208AbXBTQ0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:26:13 -0500
In-Reply-To: <45D9B3E8.7030109@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> The napi poll routine was missing the call to the optimized rx process 
> routine. This patch adds the missing call for the optimized path.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- orig/drivers/net/forcedeth.c	2007-02-19 09:13:10.000000000 -0500
> +++ new/drivers/net/forcedeth.c	2007-02-19 09:13:46.000000000 -0500
> @@ -3104,13 +3104,17 @@
>  	struct fe_priv *np = netdev_priv(dev);
>  	u8 __iomem *base = get_hwbase(dev);
>  	unsigned long flags;
> +	u32 retcode;
>  
> -	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
> +	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
>  		pkts = nv_rx_process(dev, limit);
> -	else
> +		retcode = nv_alloc_rx(dev);
> +	} else {
>  		pkts = nv_rx_process_optimized(dev, limit);
> +		retcode = nv_alloc_rx_optimized(dev);
> +	}
>  
> -	if (nv_alloc_rx(dev)) {
> +	if (retcode) {

You should update this patch to change the return values of the above 
two functions from 'int' to 'u32', to match the code usage.  Both 
nv_rx_process() and nv_alloc_rx_optimized() return int, but you use them 
as if they return u32.

Or alternately, use the Linux kernel standard of negative values 
indicating failure, zero (or perhaps >=0) indicates success.

Otherwise, ACK.

	Jeff



