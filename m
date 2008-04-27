From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] via-rhine: suspend/resume bugfix
Date: Sun, 27 Apr 2008 10:59:23 +0200
Message-ID: <4814406B.8000907@gmail.com>
References: <20080427071351.GA20561@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Ondrej Zajicek <santiago@crfreenet.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756581AbYD0I7j@vger.kernel.org>
In-Reply-To: <20080427071351.GA20561@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2008 09:13 AM, Ondrej Zajicek wrote:
> There is a bug in via-rhine driver - the driver don't disable
> interrupts during suspend, which sometimes leads to globally
> disabled interrupt line.
> 
> This patch disables interrupts (and Rx/Tx) during suspend.
> 
> Signed-off-by: Ondrej Zajicek <santiago@crfreenet.org>
> 
> ---
> 
> diff -uprN -X linux-2.6.25/Documentation/dontdiff linux-2.6.25/drivers/net/via-rhine.c linux-2.6.25-feanor/drivers/net/via-rhine.c
> --- linux-2.6.25/drivers/net/via-rhine.c	2008-04-17 04:49:44.000000000 +0200
> +++ linux-2.6.25-feanor/drivers/net/via-rhine.c	2008-04-26 14:08:44.000000000 +0200
> @@ -1886,6 +1886,15 @@ static void rhine_shutdown (struct pci_d
>  	struct rhine_private *rp = netdev_priv(dev);
>  	void __iomem *ioaddr = rp->base;
>  
> +	/* Switch to loopback mode to avoid hardware races. */
> +	iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
> +
> +	/* Disable interrupts by clearing the interrupt mask. */
> +	iowrite16(0x0000, ioaddr + IntrEnable);
> +
> +	/* Stop the chip's Tx and Rx processes. */
> +	iowrite16(CmdStop, ioaddr + ChipCmd);
> +
>  	if (!(rp->quirks & rqWOL))
>  		return; /* Nothing to do for non-WOL adapters */

What about PCI posting?
