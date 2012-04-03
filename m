From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC] net:phy:phylib: phy shares the same interrupt with mac
Date: Tue, 03 Apr 2012 10:49:48 +0200
Message-ID: <4F7AB9AC.8000708@openwrt.org>
References: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jason Lin <kernel.jason@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34937 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab2DCIvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 04:51:04 -0400
Received: by bkcik5 with SMTP id ik5so3347910bkc.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 01:51:02 -0700 (PDT)
In-Reply-To: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le 04/03/12 04:11, Jason Lin a =C3=A9crit :
> 1)  Add a new definition PHY_MAC if phy shares the same
>       interrupt with mac.
> 2)  Add do_phy_workqueue(), that mac can invoke this function
>       in its ISR when link status changed or other conditions.
>
> Does this seems reasonable?

No, I think this is well handled by the PHY_IGNORE_INTERRUPT case=20
(documented in Documentation/networking/phy.txt) by doing the following=
:

- distinguish between MAC and PHY interrupts in your MAC interrupt=20
handler (most likely you have separate bits for PHY interrupts)
- once you see a PHY interrupt, call the appropriate PHY state machine=20
callbacks to update the PHY state machine

>
>
> ---------------------------
>   drivers/net/phy/phy.c        |   27 +++++++++++++++++++++++++++
>   drivers/net/phy/phy_device.c |    4 ++--
>   include/linux/phy.h          |    3 +++
>   3 files changed, 32 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7670aac..c8009e9 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -527,6 +527,28 @@ static irqreturn_t phy_interrupt(int irq, void *=
phy_dat)
>      return IRQ_HANDLED;
>   }
>
> +/*
> + * do_phy_workqueue - PHY interrupt handler used by MAC
> + * @irq: interrupt line
> + * @phydev: phy_device pointer
> + *
> + * Description: When a PHY use the same interrupt with MAC,
> + * the handler is invoked by MAC, and schedules  a work task
> + * to clear the PHY's interrupt.
> + * This handler is invoked only in MAC's ISR.
> + */
> +irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev) {
> +
> +   BUG_ON(!in_interrupt());
> +
> +   if (PHY_HALTED =3D=3D phydev->state)
> +       return IRQ_NONE;
> +
> +   schedule_work(&phydev->phy_queue);
> +   return IRQ_HANDLED;
> +}
> +EXPORT_SYMBOL(do_phy_workqueue);
> +
>   /**
>    * phy_enable_interrupts - Enable the interrupts from the PHY side
>    * @phydev: target phy_device struct
> @@ -589,6 +611,11 @@ int phy_start_interrupts(struct phy_device *phyd=
ev)
>
>      INIT_WORK(&phydev->phy_queue, phy_change);
>
> +   if (phydev->irq =3D=3D PHY_MAC) {
> +       err =3D phy_enable_interrupts(phydev);
> +       return err;
> +   }
> +
>      atomic_set(&phydev->irq_disable, 0);
>      if (request_irq(phydev->irq, phy_interrupt,
>                  IRQF_SHARED,
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index 993c52c..1857097 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -345,7 +345,7 @@ int phy_connect_direct(struct net_device *dev,
> struct phy_device *phydev,
>
>      phy_prepare_link(phydev, handler);
>      phy_start_machine(phydev, NULL);
> -   if (phydev->irq>  0)
> +   if ((phydev->irq>  0) || (phydev->irq =3D=3D PHY_MAC))
>          phy_start_interrupts(phydev);
>
>      return 0;
> @@ -399,7 +399,7 @@ EXPORT_SYMBOL(phy_connect);
>    */
>   void phy_disconnect(struct phy_device *phydev)
>   {
> -   if (phydev->irq>  0)
> +   if ((phydev->irq>  0) || (phydev->irq =3D=3D PHY_MAC))
>          phy_stop_interrupts(phydev);
>
>      phy_stop_machine(phydev);
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 7da5fa8..155822c 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -44,9 +44,11 @@
>    * Set phydev->irq to PHY_POLL if interrupts are not supported,
>    * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
>    * the attached driver handles the interrupt
> + * Set to PHY_MAC if using the same interrupt with MAC
>    */
>   #define PHY_POLL       -1
>   #define PHY_IGNORE_INTERRUPT   -2
> +#define PHY_MAC        -3
>
>   #define PHY_HAS_INTERRUPT  0x00000001
>   #define PHY_HAS_MAGICANEG  0x00000002
> @@ -510,6 +512,7 @@ int phy_ethtool_sset(struct phy_device *phydev,
> struct ethtool_cmd *cmd);
>   int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd =
*cmd);
>   int phy_mii_ioctl(struct phy_device *phydev,
>          struct ifreq *ifr, int cmd);
> +irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev);
>   int phy_start_interrupts(struct phy_device *phydev);
>   void phy_print_status(struct phy_device *phydev);
>   void phy_device_free(struct phy_device *phydev);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
