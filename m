From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Road Runner HIPPI driver (rrunner)
Date: Fri, 12 Sep 2003 18:06:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F62437F.9080202@pobox.com>
References: <20030912144208.2886e2b9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030912144208.2886e2b9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> @@ -209,9 +208,9 @@ static int __devinit rr_init_one(struct 
>  
>  	dev->base_addr = 0;
>  
> -	ret = register_netdev(dev);
> -	if (ret)
> +	if (register_netdev(dev)) 
>  		goto out;
> +
>  	return 0;
>  
>   out:

We lose the register_netdev() return value, whereas the driver got it 
right before.


>  static void __devexit rr_remove_one (struct pci_dev *pdev)
>  {
> -	struct net_device *dev = pci_get_drvdata(pdev);
> -	struct rr_private *rr = (struct rr_private *)dev->priv;
> +	struct net_device *dev;
> +	struct rr_private *rr;
>  
> -	if (dev) {
> -		if (!(readl(&rr->regs->HostCtrl) & NIC_HALTED)){
> -			printk(KERN_ERR "%s: trying to unload running NIC\n",
> -			       dev->name);
> -			writel(HALT_NIC, &rr->regs->HostCtrl);
> -		}
> -
> -		pci_free_consistent(pdev, EVT_RING_SIZE, rr->evt_ring,
> -				    rr->evt_ring_dma);
> -		pci_free_consistent(pdev, RX_TOTAL_SIZE, rr->rx_ring,
> -				    rr->rx_ring_dma);
> -		pci_free_consistent(pdev, TX_TOTAL_SIZE, rr->tx_ring,
> -				    rr->tx_ring_dma);
> -		unregister_netdev(dev);
> -		iounmap(rr->regs);
> -		free_netdev(dev);
> -		pci_release_regions(pdev);
> -		pci_disable_device(pdev);
> -		pci_set_drvdata(pdev, NULL);
> +	if (!(dev = pci_get_drvdata(pdev)))
> +		return;

this is a fairly ugly construct.  It looks better as the driver had it, 
as an initializer.  Don't combine C statements when you don't need to.


> @@ -1201,8 +1205,8 @@ static int rr_open(struct net_device *de
>  	readl(&regs->HostCtrl);
>  	spin_unlock_irqrestore(&rrpriv->lock, flags);
>  
> -	if (request_irq(dev->irq, rr_interrupt, SA_SHIRQ, rrpriv->name, dev))
> -	{
> +	if (request_irq(dev->irq, rr_interrupt, SA_SHIRQ, 
> +			"RoadRunner serial HIPPI", dev)) {
>  		printk(KERN_WARNING "%s: Requested IRQ %d is busy\n",
>  		       dev->name, dev->irq);
>  		ecode = -EAGAIN;

If Jes doesn't mind, I would prefer that we pass in the interface name 
(dev->name I assume?) here.

	Jeff
