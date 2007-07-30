From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 31 Jul 2007 04:06:22 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707310349460.17287@enigma.security.iitk.ac.in>
References: <20070730212333.GA8049@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40432 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968060AbXG3WYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 18:24:05 -0400
In-Reply-To: <20070730212333.GA8049@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,


On Mon, 30 Jul 2007, Jeff Garzik wrote:

>       Fix a potential NULL pointer dereference in mace_interrupt() in drivers/net/pcmcia/nmclan_cs.c

This oops is _programmatically_ impossible (the only way it can occur
is if the kernel has gone bazooka already anyway ...)

[ BTW even if it were possible, we haven't fixed it still ...
  note the use of the netdev_priv() before the (dev == NULL)
  check in the function below ... ]


> diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
> index 73da611..997c2d0 100644
> --- a/drivers/net/pcmcia/nmclan_cs.c
> +++ b/drivers/net/pcmcia/nmclan_cs.c
> @@ -996,7 +996,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
>  {
>    struct net_device *dev = (struct net_device *) dev_id;
>    mace_private *lp = netdev_priv(dev);
> -  kio_addr_t ioaddr = dev->base_addr;
> +  kio_addr_t ioaddr;
>    int status;
>    int IntrCnt = MACE_MAX_IR_ITERATIONS;
>  
> @@ -1006,6 +1006,8 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
>      return IRQ_NONE;
>    }
>  
> +  ioaddr = dev->base_addr;
> +
>    if (lp->tx_irq_disabled) {
>      printk(
>        (lp->tx_irq_disabled?

I suggest we should just get rid of the (bogus, always false) dev == NULL
check itself, instead.

Will submit patch, in a bit ...


>       Fix a potential NULL pointer dereference in write_bulk_callback() in drivers/net/usb/pegasus.c

Ditto, for this. Impossible oops. And if it does occur, the kernel would
have gone irrevocably mad already ...


> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index a05fd97..04cba6b 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -768,11 +768,13 @@ done:
>  static void write_bulk_callback(struct urb *urb)
>  {
>  	pegasus_t *pegasus = urb->context;
> -	struct net_device *net = pegasus->net;
> +	struct net_device *net;
>  
>  	if (!pegasus)
>  		return;
>  
> +	net = pegasus->net;
> +
>  	if (!netif_device_present(net) || !netif_running(net))
>  		return;

Again, the (!pegasus) check is bogus (always false) and should be removed
instead. I believe the maintainer (CC'ed here) already has a patch for
exactly that.


Satyam
