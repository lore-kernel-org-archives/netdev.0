From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 14:25:00 +0300
Message-ID: <20120410112459.GA28825@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
 <20120410093140.GA27651@redhat.com>
 <1334052259.3126.68.camel@edumazet-glaptop>
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
In-Reply-To: <1334052259.3126.68.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 12:04:19PM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 12:31 +0300, Michael S. Tsirkin wrote:
> 
> > True. Still this is the only interface we have for controlling
> > the internal queue length so it seems safe to assume someone
> > is using it for this purpose.
> > 
> 
> So to workaround a problem in tun, you want to hack net/core/dev.c :(

Sorry about being unclear, I'm just saying that your patch assumes
tx_queue_len == 0 since you set it that way at device init but we can't
rely on this as existing users might have changed that value.
One way to fix would be a patch at the bottom: then we
can leave tun to treat tx_queue_len like it always did.

> Packets in qdisc should not be orphaned.
>
> If you think about it, why do we attach skb to socket in the first
> place ?

Good point. The answer is to avoid skb drops for local sockets by
stopping them, right?

> If its not needed for tun, why should it be needed for other devices ?

Maybe needed but it's already broken for tun since the skbs in the
private queue are orphaned by skb_orphan_try?

> If TUN has a problem being stopped forever, maybe it should take
> appropriate action to flush all packets in qdisc queue after a while, as
> this makes no sense to delay packets forever.
> 

Well arbitrary timers aren't a solid protection, right?
We get out of stalling transmitters forever but a bad VM can still
degrade performance significantly for others...


----

We don't want a queue for tun since it can stall forever, but userspace
might tweak it's tx_queue_len as a way to control RX queue depth,
and we don't want to break userspace. Use a private flag to disable queue.

Warning: untested.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27883d1..644ca53 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -695,7 +692,7 @@ static void attach_one_default_qdisc(struct net_device *dev,
 {
 	struct Qdisc *qdisc = &noqueue_qdisc;
 
-	if (dev->tx_queue_len) {
+	if (dev->tx_queue_len && !(dev->priv_flags & IFF_TX_CAN_STALL)) {
 		qdisc = qdisc_create_dflt(dev_queue,
 					  &pfifo_fast_ops, TC_H_ROOT);
 		if (!qdisc) {
-- 
MST
