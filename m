From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Fri, 8 Jun 2007 17:10:40 -0700
Message-ID: <20070608171040.2b4a2dd7@localhost.localdomain>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>
	<20070608162415.1481dfec@localhost.localdomain>
	<4669E967.5030708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38883 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762465AbXFIAKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 20:10:52 -0400
In-Reply-To: <4669E967.5030708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Jun 2007 16:42:31 -0700
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> Stephen Hemminger wrote:
> >>  
> >> +#define ndev_printk(kern_level, netif_level, netdev, format, arg...) \
> >> +	do { if ((netdev)->msg_enable & NETIF_MSG_##netif_level) { \
> >> +		printk(kern_level "%s: " format, \
> >> +		(netdev)->name, ## arg); } } while (0)
> > 
> > Could you make a version that doesn't evaluate the arguments twice?
> 
> hmm you lost me there a bit; Do you want me to duplicate this code for all the 
> ndev_err/ndev_info functions instead so that ndev_err doesn't direct back to 
> ndev_printk?

It is good practice in a macro to avoid potential problems with usage
by only touching the arguments once. Otherwise, something (bogus) like
	ndev_printk(KERN_DEBUG, NETIF_MSG_PKTDATA, "got %d\n",
		    dev++, skb->len)
would increment dev twice.

My preference would be something more like dev_printk or even use that?
You want to show both device name, and physical attachment in the message.

> >> +#ifdef DEBUG
> >> +#define ndev_dbg(level, netdev, format, arg...) \
> >> +	ndev_printk(KERN_DEBUG, level, netdev, format, ## arg)
> >> +#else
> >> +#define ndev_dbg(level, netdev, format, arg...) \
> >> +	do { (void)(netdev); } while (0)
> >> +#endif
> >> +
> >> +#define ndev_err(level, netdev, format, arg...) \
> >> +	ndev_printk(KERN_ERR, level, netdev, format, ## arg)
> >> +#define ndev_info(level, netdev, format, arg...) \
> >> +	ndev_printk(KERN_INFO, level, netdev, format, ## arg)
> >> +#define ndev_warn(level, netdev, format, arg...) \
> >> +	ndev_printk(KERN_WARNING, level, netdev, format, ## arg)
> >> +#define ndev_notice(level, netdev, format, arg...) \
> >> +	ndev_printk(KERN_NOTICE, level, netdev, format, ## arg)
> >> +
> >>  #define netif_msg_drv(p)	((p)->msg_enable & NETIF_MSG_DRV)
> >>  #define netif_msg_probe(p)	((p)->msg_enable & NETIF_MSG_PROBE)
> >>  #define netif_msg_link(p)	((p)->msg_enable & NETIF_MSG_LINK)
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index 5a7f20f..e854c09 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -3376,6 +3376,16 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
> >>  		dev->priv = netdev_priv(dev);
> >>  
> >>  	dev->get_stats = internal_stats;
> >> +	dev->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK;
> >> +#ifdef DEBUG
> >> +	/* put these to good use: */
> >> +	dev->msg_enable |= NETIF_MSG_TIMER | NETIF_MSG_IFDOWN |
> >> +	                   NETIF_MSG_IFUP | NETIF_MSG_RX_ERR |
> >> +	                   NETIF_MSG_TX_ERR | NETIF_MSG_TX_QUEUED |
> >> +	                   NETIF_MSG_INTR | NETIF_MSG_TX_DONE |
> >> +	                   NETIF_MSG_RX_STATUS | NETIF_MSG_PKTDATA |
> >> +	                   NETIF_MSG_HW | NETIF_MSG_WOL;
> >> +#endif
> > 
> > Let driver writer choose message enable bits please.
> 
> the driver can, since these bits are set in alloc_netdev, nothing prevents a 
> driver from setting the mask immediately afterwards. Putting in a sane default 
> seems a good idea and good practice.
> 
> Maybe I went a bit far by going all out on the DEBUG flags tho... perhaps those 
> can be removed or only NETIF_MSG_RX_ERR and NETIF_MSG_TX_ERR set with DEBUG.
> 
> Auke


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
