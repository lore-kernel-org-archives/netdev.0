From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [except_nonlink net-next]r8169:Add exception when missing link
Date: Sun, 12 Jul 2015 20:20:07 +0200
Message-ID: <20150712182006.GA21621@electric-eye.fr.zoreil.com>
References: <CAGg4U=EF+_8qLW_K=ZYtLSjC75RSrVywsMVswua0YpM91GYZog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33462 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbGLSUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 14:20:22 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=EF+_8qLW_K=ZYtLSjC75RSrVywsMVswua0YpM91GYZog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marian Corcodel <corcodel.marian@gmail.com> :
> Add exception when missing link because original function "
> rtl8169_check_link_status" must be int instead of void.

You explain why the patch is done this way but you don't explain
why it is needed/useful.

> commit 21d27973b264192a4ccd6488b1487f07293b11c8
> Author: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
> Date:   Sat Jul 11 21:19:57 2015 +0300
> 
>      Committer: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
>      Add exception when nonexistent link occur because orig func
>      is void format instead of int.
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 410c1ee..7465ec4 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7643,6 +7643,12 @@ static int rtl_open(struct net_device *dev)
>  
>  	tp->saved_wolopts = 0;
>  	pm_runtime_put_noidle(&pdev->dev);
> +	if (!tp->link_ok(ioaddr)) {
> +			netif_carrier_off(dev);
> +		netif_info(tp, ifdown, dev, "link down\n");
> +		pm_schedule_suspend(&tp->pci_dev->dev, 200);

(nit: &tp->pci_dev->dev == &pdev->dev from a few lines above)

> +	  goto out; 
> +	}
>  
>  	rtl8169_check_link_status(dev, tp, ioaddr);
>  out:

You're (partly) reverting the change below without any sensible
explanation.

You should elaborate which problem you are trying to address.

Btw I can't help thinking that the style is terrible and the
whole stuff ought to stay in rtl8169_check_link_status.

commit e4fbce740f078bbc925ba5c86648d9c883968479
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Wed Dec 8 15:32:14 2010 +0000

    r8169: Fix runtime power management
    
    I noticed that one of the post-2.6.36 patches broke runtime PM of the
    r8169 on my MSI Wind test machine in such a way that the link was not
    brought up after reconnecting the network cable.
    
    In the process of debugging the issue I realized that we only should
    invoke the runtime PM functions in rtl8169_check_link_status() when
    link change is reported and if we do so, the problem goes away.
    Moreover, this allows rtl8169_runtime_idle() to be simplified quite
    a bit.
    
    Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
    Acked-by: Francois Romieu <romieu@fr.zoreil.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d33ef4..53b13de 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -744,26 +744,36 @@ static void rtl8169_xmii_reset_enable(void __iomem *ioaddr)
 	mdio_write(ioaddr, MII_BMCR, val & 0xffff);
 }
 
-static void rtl8169_check_link_status(struct net_device *dev,
+static void __rtl8169_check_link_status(struct net_device *dev,
 				      struct rtl8169_private *tp,
-				      void __iomem *ioaddr)
+				      void __iomem *ioaddr,
+				      bool pm)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		/* This is to cancel a scheduled suspend if there's one. */
-		pm_request_resume(&tp->pci_dev->dev);
+		if (pm)
+			pm_request_resume(&tp->pci_dev->dev);
 		netif_carrier_on(dev);
 		netif_info(tp, ifup, dev, "link up\n");
 	} else {
 		netif_carrier_off(dev);
 		netif_info(tp, ifdown, dev, "link down\n");
-		pm_schedule_suspend(&tp->pci_dev->dev, 100);
+		if (pm)
+			pm_schedule_suspend(&tp->pci_dev->dev, 100);
 	}
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static void rtl8169_check_link_status(struct net_device *dev,
+				      struct rtl8169_private *tp,
+				      void __iomem *ioaddr)
+{
+	__rtl8169_check_link_status(dev, tp, ioaddr, false);
+}
+
 #define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
 
 static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
@@ -4600,7 +4610,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		}
 
 		if (status & LinkChg)
-			rtl8169_check_link_status(dev, tp, ioaddr);
+			__rtl8169_check_link_status(dev, tp, ioaddr, true);
 
 		/* We need to see the lastest version of tp->intr_mask to
 		 * avoid ignoring an MSI interrupt and having to wait for
@@ -4890,11 +4900,7 @@ static int rtl8169_runtime_idle(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (!tp->TxDescArray)
-		return 0;
-
-	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
-	return -EBUSY;
+	return tp->TxDescArray ? -EBUSY : 0;
 }
 
 static const struct dev_pm_ops rtl8169_pm_ops = {
