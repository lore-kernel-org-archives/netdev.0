From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 10:48:47 -0700
Message-ID: <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	<1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
	<1332177118.9397.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>, kys@microsoft.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40112 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394Ab2CSRsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 13:48:51 -0400
In-Reply-To: <1332177118.9397.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Mar 2012 10:11:58 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2012-03-19 at 10:02 -0700, Haiyang Zhang wrote:
> > Instead of dropping the packet, we keep the skb buffer, and return
> > NETDEV_TX_BUSY to let upper layer retry send. This will not cause
> > endless loop, because the host is taking data away from ring buffer.
> > 
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/net/hyperv/netvsc_drv.c |    5 +----
> >  1 files changed, 1 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> > index 2517d20..dd29478 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -223,13 +223,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
> >  		net->stats.tx_bytes += skb->len;
> >  		net->stats.tx_packets++;
> >  	} else {
> > -		/* we are shutting down or bus overloaded, just drop packet */
> > -		net->stats.tx_dropped++;
> >  		kfree(packet);
> > -		dev_kfree_skb_any(skb);
> >  	}
> >  
> > -	return NETDEV_TX_OK;
> > +	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
> >  }
> >  
> >  /*
> 
> Thats simply not true at all.
> 
> A start_xmit() cannot do that.
> 
> TX_BUSY should never be returned at all, its a deprecated code, for
> pretty good reasons. (assuming queue is not stopped)
> 
> Try this on a machine with one CPU, I am pretty sure this can trigger
> complete freezes.
> 
> Once softirq loops in your start_xmit(), how do you think one process
> can help you now ?

Eric is right, look how devices with real physical rings work.
They test for space left at end of start xmit and stop the transmit
queue with netif_stop_queue.  The transmit done code then re-enables
when enough space is netif_wake_queue. Think of it as classic
high/low water mark on a FIFO.
