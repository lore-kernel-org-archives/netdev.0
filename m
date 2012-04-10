From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 15:41:51 +0300
Message-ID: <20120410124151.GA29808@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
 <20120410093140.GA27651@redhat.com>
 <1334052259.3126.68.camel@edumazet-glaptop>
 <20120410112459.GA28825@redhat.com>
 <1334058300.3126.99.camel@edumazet-glaptop>
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
In-Reply-To: <1334058300.3126.99.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 01:45:00PM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 14:25 +0300, Michael S. Tsirkin wrote:
> > On Tue, Apr 10, 2012 at 12:04:19PM +0200, Eric Dumazet wrote:
> > > On Tue, 2012-04-10 at 12:31 +0300, Michael S. Tsirkin wrote:
> > > 
> > > > True. Still this is the only interface we have for controlling
> > > > the internal queue length so it seems safe to assume someone
> > > > is using it for this purpose.
> > > > 
> > > 
> > > So to workaround a problem in tun, you want to hack net/core/dev.c :(
> > 
> > Sorry about being unclear, I'm just saying that your patch assumes
> > tx_queue_len == 0 since you set it that way at device init but we can't
> > rely on this as existing users might have changed that value.
> > One way to fix would be a patch at the bottom: then we
> > can leave tun to treat tx_queue_len like it always did.
> 
> 
> > ----
> > 
> > We don't want a queue for tun since it can stall forever, but userspace
> > might tweak it's tx_queue_len as a way to control RX queue depth,
> > and we don't want to break userspace. Use a private flag to disable queue.
> > 
> > Warning: untested.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index 27883d1..644ca53 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -695,7 +692,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
> >  {
> >  	struct Qdisc *qdisc = &noqueue_qdisc;
> >  
> > -	if (dev->tx_queue_len) {
> > +	if (dev->tx_queue_len && !(dev->priv_flags & IFF_TX_CAN_STALL)) {
> >  		qdisc = qdisc_create_dflt(dev_queue,
> >  					  &pfifo_fast_ops, TC_H_ROOT);
> >  		if (!qdisc) {
> 
> 
> Thing is this function is called before userspace can tweak tx_queue_len
> 
> So if you create a vlan device (this sets tx_queue_len to 0), no qdisc
> is attached.
>
> If later userspace changes tx_queue_len to this device, qdisc wont
> automatically be created/attached.

True. But there's another place where this can happen - after
dev_change_net_namespace, no?
This calls dev_shutdown.

> Really, tx_queue_len is private to net/sched layer, it should not be
> used by tun device to control a receive queue limit.
> 
> Please try to not hack net/sched or net/core for your needs.
> 
> Its not because tun abused tx_queue_len in the past we must keep this
> hack forever.
> 
> In ethernet drivers, TX ring size is controlled by ethtool -g
> 
> Why tun driver would use another way ?
> 

I think it's a bad interface too but it's in a userspace ABI
now so I suspect we are stuck with it for now. We can try deprecating
but we can't just drop it.

-- 
MST
