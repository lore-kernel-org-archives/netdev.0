From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] Fix a potential NULL pointer dereference in uli526x_interrupt()
 in drivers/net/tulip/uli526x.c
Date: Tue, 4 Sep 2007 14:06:31 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709041352450.13651@enigma.security.iitk.ac.in>
References: <46DD121A.2010404@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	jgarzik@pobox.com
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48357 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbXIDIX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 04:23:26 -0400
In-Reply-To: <46DD121A.2010404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Micah,


On Tue, 4 Sep 2007, Micah Gruber wrote:

> This patch fixes a potential null dereference bug where we dereference
> dev before a null check. This patch simply moves the dereferencing after
> the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> ---
> 
> --- a/drivers/net/tulip/uli526x.c
> +++ b/drivers/net/tulip/uli526x.c
> @@ -663,7 +663,7 @@
>  {
>  	struct net_device *dev = dev_id;
>  	struct uli526x_board_info *db = netdev_priv(dev);
> -	unsigned long ioaddr;
> +	unsigned long ioaddr = dev->base_addr;
>  	unsigned long flags;
>  
>  	if (!dev) {
> @@ -671,8 +671,6 @@
>  		return IRQ_NONE;
>  	}
>  
> -	ioaddr = dev->base_addr;
> -
>  	spin_lock_irqsave(&db->lock, flags);
>  	outl(0, ioaddr + DCR7);


[The patch is reversed.]

But it is also complete -- you've left out the "netdev_priv(dev)"
statement _just_ before the dereference that you've pushed down.
Coverity wasn't smart enough to tell, but that's actually a dev->priv,
so we'll _still_ be dereferencing dev before checking it for NULL below.
And lastly, the patch isn't quite correct. It is the (!dev) check that
is redundant and must be removed instead :-)

I bet more such pointless checks exist all over. It makes more sense to
remove them than unnecessarily try to solve "potential" NULL dereferences,
that we (naturally) never saw earlier, because they're impossible. ISTR
pointing out two similar patches a month or so back when Jeff pushed net
driver patches upstream, IIRC ... ]


Satyam
