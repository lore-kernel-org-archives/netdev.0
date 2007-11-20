From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth boot delay fix
Date: Tue, 20 Nov 2007 01:08:58 -0800
Message-ID: <20071120010858.4d098194.akpm@linux-foundation.org>
References: <47408EE5.2040302@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45709 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757043AbXKTJJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 04:09:43 -0500
In-Reply-To: <47408EE5.2040302@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Nov 2007 14:13:41 -0500 Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch fixes a long boot delay in the forcedeth driver. During 
> initialization, the timeout for the handshake between mgmt unit and 
> driver can be very long. The patch reduces the timeout by eliminating a 
> extra loop around the timeout logic.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> 
> [patch-forcedeth-sema-fix  text/plain (1.3KB)]
> --- old/drivers/net/forcedeth.c	2007-11-08 17:33:00.000000000 -0500
> +++ new/drivers/net/forcedeth.c	2007-11-08 17:34:25.000000000 -0500
> @@ -5286,20 +5286,17 @@
>  		if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_PHY_INIT) {
>  			np->mac_in_use = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_MGMT_ST;
>  			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n", pci_name(pci_dev), np->mac_in_use);
> -			for (i = 0; i < 5000; i++) {
> -				msleep(1);
> -				if (nv_mgmt_acquire_sema(dev)) {
> -					/* management unit setup the phy already? */
> -					if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
> -					    NVREG_XMITCTL_SYNC_PHY_INIT) {
> -						/* phy is inited by mgmt unit */
> -						phyinitialized = 1;
> -						dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
> -					} else {
> -						/* we need to init the phy */
> -					}
> -					break;
> +			if (nv_mgmt_acquire_sema(dev)) {
> +				/* management unit setup the phy already? */
> +				if ((readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_SYNC_MASK) ==
> +				    NVREG_XMITCTL_SYNC_PHY_INIT) {
> +					/* phy is inited by mgmt unit */
> +					phyinitialized = 1;
> +					dprintk(KERN_INFO "%s: Phy already initialized by mgmt unit.\n", pci_name(pci_dev));
> +				} else {
> +					/* we need to init the phy */
>  				}
> +				break;
>  			}
>  		}
>  	}

drivers/net/forcedeth.c: In function 'nv_probe':
drivers/net/forcedeth.c:5307: error: break statement not within loop or switch  
