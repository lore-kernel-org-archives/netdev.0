From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] 8139too NAPI for net-drivers-2.5-exp
Date: Thu, 20 Nov 2003 04:02:14 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <871xs4w5ah.fsf@devron.myhome.or.jp>
References: <20031118161730.2690cb76.shemminger@osdl.org>
	<3FBBA565.3090206@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jes Sorensen <jes@wildopensource.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FBBA565.3090206@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> Stephen Hemminger wrote:
> > Here is the 8139too version in net-drivers-2.5-exp modified for NAPI.
> > Also:
> > 	64k receive ring - has to handle wrap for that case;
> > 	   the NoWrap flag does nothing if using this big ring.
> > 	assert() -> BUG_ON()
> > 	
> > To deal with the races with tx_timeout, put back in the rx_lock from earlier versions.

> +		local_irq_disable();
> +		netif_rx_complete(dev);
> +		RTL_W16_F(IntrMask, rtl8139_intr_mask);
> +		local_irq_enable();

Probably, by my mistake in previous mail. Sorry.  This still has the
races condition. It can trigger the same problem by shared interrupt
on SMP. 

Probably the following ISR style should use the below combination.

   in ISR
	if (netif_rx_schedule_prep(dev)) {
		RTL_W16 (IntrMask, rtl8139_norx_intr_mask);
		__netif_rx_schedule(dev);
	}

   in ->poll
	local_irq_disable();
	RTL_W16_F(IntrMask, rtl8139_intr_mask);
	__netif_rx_complete(dev);
	local_irq_enable();


And another one should use the below combination.  (this style can
change the flags of __LINK_STATE_RX_SCHED or __LINK_STATE_START anytime)

   in ISR
	if (status & RxAckBits) {
		RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
		netif_rx_schedule (dev);
	}

   in ->poll
	local_irq_disable();
	__netif_rx_complete(dev);
	RTL_W16_F(IntrMask, rtl8139_intr_mask);
	local_irq_enable();

   If happen the shared interrupt, the this ISR style may lose a
   chance of netif_rx_schedule().


Anyway, the following patch should fix the problem. Please apply.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

 drivers/net/8139too.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/8139too.c~8139too-fix-race drivers/net/8139too.c
--- linux-2.6.0-test9/drivers/net/8139too.c~8139too-fix-race	2003-11-19 23:48:46.000000000 +0900
+++ linux-2.6.0-test9-hirofumi/drivers/net/8139too.c	2003-11-19 23:49:05.000000000 +0900
@@ -2107,8 +2107,8 @@ static int rtl8139_poll(struct net_devic
 		 * again when we think we are done.
 		 */
 		local_irq_disable();
-		netif_rx_complete(dev);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
+		__netif_rx_complete(dev);
 		local_irq_enable();
 	}
 	spin_unlock(&tp->rx_lock);

_
