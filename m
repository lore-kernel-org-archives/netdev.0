From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: add support for netpoll
Date: Mon, 29 Oct 2007 15:17:44 +0300
Message-ID: <20071029121744.GA20372@localhost.localdomain>
References: <20071011124842.GB13963@localhost.localdomain> <4723389F.7010109@ru.mvista.com> <20071027143731.GA2616@zarina> <989B956029373F45A0B8AF0297081890019B61BF@zch01exm26.fsl.freescale.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang-r58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:33608 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751766AbXJ2MTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 08:19:14 -0400
Content-Disposition: inline
In-Reply-To: <989B956029373F45A0B8AF0297081890019B61BF@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 02:12:07PM +0800, Li Yang-r58472 wrote:
[...]
> > > > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > > > +/*
> > > > + * Polling 'interrupt' - used by things like netconsole to send 
> > > > +skbs
> > > > + * without having to re-enable interrupts. It's not called while
> > > > + * the interrupt routine is executing.
> > > > + */
> > > > +static void ucc_netpoll(struct net_device *dev) {
> > > > +	struct ucc_geth_private *ugeth = netdev_priv(dev);
> > > > +
> > > > +	disable_irq(ugeth->ug_info->uf_info.irq);
> > > > +	ucc_geth_irq_handler(ugeth->ug_info->uf_info.irq, dev);
> > > > +	enable_irq(ugeth->ug_info->uf_info.irq);
> > > 
> > >     Why not make it less complex (for a reader and gcc too :-) ?
> > 
> > Yup, I'm agree here but it's too late. Again. ;-)
> > 
> > This patch already accepted into the -mm (a week or so after 
> > the silence), so.. now I'd rather not bother Andrew with such 
> > really cosmetic changes. But if Jeff would directly apply 
> > modfied patch, I'll send it. ;-)
> 
> Oops.  The original patch happened to hit the Junk mail box. :(

That one as well? http://lkml.org/lkml/2007/10/11/128

> I think
> the patch is good to merge after the cosmetic change.  I can do it in
> next pull request to Jeff.

Ok, great. Thanks.

Here it is:

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: add support for netpoll

This patch adds netpoll support for the QE UCC Gigabit Ethernet
driver. Tested using netconsole and KGDBoE.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index bec413b..94e78d8 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3678,6 +3678,23 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void ucc_netpoll(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	int irq = ugeth->ug_info->uf_info.irq;
+
+	disable_irq(irq);
+	ucc_geth_irq_handler(irq, dev);
+	enable_irq(irq);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int ucc_geth_open(struct net_device *dev)
@@ -3963,6 +3980,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 #ifdef CONFIG_UGETH_NAPI
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
 #endif				/* CONFIG_UGETH_NAPI */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ucc_netpoll;
+#endif
 	dev->stop = ucc_geth_close;
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
-- 
1.5.2.2

