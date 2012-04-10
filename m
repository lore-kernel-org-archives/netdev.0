From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 12:31:40 +0300
Message-ID: <20120410093140.GA27651@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334048100.3126.21.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 10:55:00AM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 11:41 +0300, Michael S. Tsirkin wrote:
> > On Tue, Apr 10, 2012 at 09:55:58AM +0200, Eric Dumazet wrote:
> 
> > > In your case I would just not use qdisc at all, like other virtual
> > > devices.
> > 
> > I think that if we do this, this also disables gso
> > for the device, doesn't it?
> 
> Not at all, thats unrelated.
> 
> > If true that would be a problem as this would
> > hurt performance of virtualized setups a lot.
> 
> In fact, removing qdisc layer will help a lot, removing a contention
> point.
>
> Anyway, with a 500 packet limit in TUN queue itself, qdisc layer should
> be always empty. Whats the point storing more than 500 packets for a
> device ? Thats a latency killer.

AKA bufferbloat :)
We could try and reduce the TUN queue so that qdisc can drop packets in
an intelligent manner (e.g. choke) but this would conflict with what you
propose, right?

> > 
> > > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > > index bb8c72c..fd8c7f0 100644
> > > --- a/drivers/net/tun.c
> > > +++ b/drivers/net/tun.c
> > > @@ -396,7 +396,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
> > >  	    sk_filter(tun->socket.sk, skb))
> > >  		goto drop;
> > >  
> > > -	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
> > > +	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= TUN_READQ_SIZE) {
> > >  		if (!(tun->flags & TUN_ONE_QUEUE)) {
> > >  			/* Normal queueing mode. */
> > >  			/* Packet scheduler handles dropping of further packets. */
> > 
> > tx_queue_len is controllable by SIOCSIFTXQLEN
> > so we'll need to override SIOCSIFTXQLEN somehow
> > to avoid breaking userspace that actually uses SIOCSIFTXQLEN, right?
> 
> Right now, you control with this tx_queue_len both the qdisc limit (if
> pfifo_fast default) and the receive_queue in TUN.
> 
> That doesnt seem right to me, and more a hack/side effect.
> Maybe you want to introduce a new setting, only controling receive queue
> limit, and use tx_queue_len for its original meaning.
> 
> Then, setting tx_queue_len to 0 permits to remove qdisc layer, as any
> other netdevice.
> 
> 

True. Still this is the only interface we have for controlling
the internal queue length so it seems safe to assume someone
is using it for this purpose.

And if that happens we get the deadlock back since
tx_queue_len will get set to a non-0 value. Right?

-- 
MST
