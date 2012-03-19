From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 17:50:59 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DCEA873@TK5EX14MBXC223.redmond.corp.microsoft.com>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	<1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
	<1332177118.9397.32.camel@edumazet-glaptop>
 <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120319104847.3a4c5fc0@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Monday, March 19, 2012 1:49 PM
> To: Eric Dumazet
> Cc: Haiyang Zhang; KY Srinivasan; davem@davemloft.net;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
> 
> On Mon, 19 Mar 2012 10:11:58 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2012-03-19 at 10:02 -0700, Haiyang Zhang wrote:
> > > Instead of dropping the packet, we keep the skb buffer, and return
> > > NETDEV_TX_BUSY to let upper layer retry send. This will not cause
> > > endless loop, because the host is taking data away from ring buffer.
> > >
> > > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > > ---
> > >  drivers/net/hyperv/netvsc_drv.c |    5 +----
> > >  1 files changed, 1 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/net/hyperv/netvsc_drv.c
> > > b/drivers/net/hyperv/netvsc_drv.c index 2517d20..dd29478 100644
> > > --- a/drivers/net/hyperv/netvsc_drv.c
> > > +++ b/drivers/net/hyperv/netvsc_drv.c
> > > @@ -223,13 +223,10 @@ static int netvsc_start_xmit(struct sk_buff *skb,
> struct net_device *net)
> > >  		net->stats.tx_bytes += skb->len;
> > >  		net->stats.tx_packets++;
> > >  	} else {
> > > -		/* we are shutting down or bus overloaded, just drop packet
> */
> > > -		net->stats.tx_dropped++;
> > >  		kfree(packet);
> > > -		dev_kfree_skb_any(skb);
> > >  	}
> > >
> > > -	return NETDEV_TX_OK;
> > > +	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
> > >  }
> > >
> > >  /*
> >
> > Thats simply not true at all.
> >
> > A start_xmit() cannot do that.
> >
> > TX_BUSY should never be returned at all, its a deprecated code, for
> > pretty good reasons. (assuming queue is not stopped)
> >
> > Try this on a machine with one CPU, I am pretty sure this can trigger
> > complete freezes.
> >
> > Once softirq loops in your start_xmit(), how do you think one process
> > can help you now ?
> 
> Eric is right, look how devices with real physical rings work.
> They test for space left at end of start xmit and stop the transmit queue with
> netif_stop_queue.  The transmit done code then re-enables when enough
> space is netif_wake_queue. Think of it as classic high/low water mark on a
> FIFO.

As in my previous reply to Eric --
We actually stop queue when the ring buffer is busy, see the code in netvsc.c

I have tested with one CPU. After NETDEV_TX_BUSY is returned, the Linux guest OS
continues to respond without any problem.

Thanks,
- Haiyang
