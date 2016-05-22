From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 23:21:23 +0200
Message-ID: <20160522212123.GA5086@electric-eye.fr.zoreil.com>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
 <20160521194733.GA30557@electric-eye.fr.zoreil.com>
 <5740E98A.5050803@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5740E98A.5050803-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org> :
> On 21.05.2016 21:47, Francois Romieu wrote:
> > Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> :
> > [...]
> >> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> >> index a3a9392..c2447b0 100644
> >> --- a/drivers/net/ethernet/arc/emac_main.c
> >> +++ b/drivers/net/ethernet/arc/emac_main.c
> >> @@ -686,6 +686,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> >>  
> >>         skb_tx_timestamp(skb);
> >>  
> >> +       /* Make sure timestamp is set */
> >> +       smp_wmb();
> > 
> > Should be dma_wmb() (see davem's message).
> > 
> > It's completely unrelated to SMP.
> > 
> 
> Its also completely unrelated to dma so I doubt that this is what davem meant.

It's related to dma: nobody wants the device to perform dma from memory
while the CPU is writing timestamp.

The device must enforce a commit of any network buffer memory write before
releasing control, i.e. before writing *info.

See 'git log -p --grep=dma_[rw]mb': it appears several times.

> As far as I understood he was referring to the dma descriptor.

If the wmb() between *info = ... and *txbd_curr = ... is replaced by a
dma_wmb(), the device will see a consistent descriptor when if performs
a DMA read after the CPU wrote into the mailbox (arc_reg_set(..., TXPL_MASK)).

Ok, I agree on this one.

However, it doesn't help with the (SMP) requirement that no CPU sees
the txbd_curr write before *info is written by the local CPU. Afaiui
dma_wmb() is too weak for this part. If we don't want wmb() here,
it will have to be dma_wmb() + smp_wmb().

-- 
Ueimor
