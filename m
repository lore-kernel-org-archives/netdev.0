From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] dl2k: Implement suspend
Date: Tue, 17 Nov 2015 00:55:25 +0100
Message-ID: <20151116235525.GA3700@electric-eye.fr.zoreil.com>
References: <1447713711-32471-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447713711-32471-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
[...]
> diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
> index ccca479..23d13c5 100644
> --- a/drivers/net/ethernet/dlink/dl2k.c
> +++ b/drivers/net/ethernet/dlink/dl2k.c
[..]
> @@ -522,6 +515,28 @@ rio_open (struct net_device *dev)
>  	macctrl |= (np->tx_flow) ? TxFlowControlEnable : 0;
>  	macctrl |= (np->rx_flow) ? RxFlowControlEnable : 0;
>  	dw16(MACCtrl, macctrl);
> +}
> +
> +static int rio_open(struct net_device *dev)
> +{
> +	struct netdev_private *np = netdev_priv(dev);
> +	const int irq = np->pdev->irq;
> +	int i;
> +
> +	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
> +	if (i)
> +		return i;
> +
> +	alloc_list(dev);
> +
> +	rio_hw_init(dev);

- request shared irq
- allocate memory
- init chipset

It may have worked so far but you ought to nail it before your
changes start to look like regression (if shit can happen, it will).

Btw:
- alloc_list should not be allowed to return partially filled receive
  ring. Please make it return a proper status code.
  The driver itself should rather drop received data than leave holes
  in its receive ring.
- the suspend / resume logic does not need a complete free / alloc
  cycle. Use the same buffers and reset the cur_tx, cur_rx indexes
  as needed.

Go wild.

-- 
Ueimor
