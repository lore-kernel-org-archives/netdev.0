From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Layer 2 acceleration vs GSO
Date: Fri, 10 Jan 2014 15:32:22 -0500
Message-ID: <20140110203222.GB2645@hmsreliant.think-freely.org>
References: <1389384339.2025.88.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57647 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758344AbaAJUcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:32:39 -0500
Content-Disposition: inline
In-Reply-To: <1389384339.2025.88.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 08:05:39PM +0000, Ben Hutchings wrote:
> What happens when an skb to be sent through ndo_dfwd_start_xmit()
> requires software GSO?
> 
> dev_hard_start_xmit() will segment it and then submit each segment, and
> then:
> 
> > gso:
> > 	do {
> [...]
> > 		if (accel_priv)
> > 			rc = ops->ndo_dfwd_start_xmit(nskb, dev, accel_priv);
> > 		else
> > 			rc = ops->ndo_start_xmit(nskb, dev);
> > 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
> [...]
> > 		txq_trans_update(txq);
> 
> Oops, txq is NULL.  And once we add the obvious condition to that,
> 
> > 		if (unlikely(netif_xmit_stopped(txq) && skb->next))
> > 			return NETDEV_TX_BUSY;
> 
> How can we tell if the hardware transmit queue filled up?
> 
> It seems like this feature currently relies on the driver returning
> NETDEV_TX_BUSY when the TX queue is already full, like ixgbe does.  But
> that is exactly what drivers are *not* supposed to do.
> 
> Ben.
> 
> > 	} while (skb->next);
> 
Dave just to a fix to deal with this (among some other issues) here today:
http://marc.info/?l=linux-kernel&m=138934276507518&w=2
Neil

> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
