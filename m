From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCHv3 2/2] smsc95xx: enable dynamic autosuspend
Date: Wed, 19 Dec 2012 10:23:13 +0800
Message-ID: <CACVXFVPtSpXA1mHCKqRoTrbXCiPLVwj22xXVGeNtGyxm1NsppQ@mail.gmail.com>
References: <1355827574-15164-1-git-send-email-steve.glendinning@shawell.net>
	<1355827574-15164-3-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, oneukum@suse.de, gregkh@linuxfoundation.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40979 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636Ab2LSCXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 21:23:15 -0500
Received: from mail-ea0-f173.google.com ([209.85.215.173])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1Tl9JR-00079X-RS
	for netdev@vger.kernel.org; Wed, 19 Dec 2012 02:23:13 +0000
Received: by mail-ea0-f173.google.com with SMTP id i13so587152eaa.32
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 18:23:13 -0800 (PST)
In-Reply-To: <1355827574-15164-3-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 18, 2012 at 6:46 PM, Steve Glendinning
<steve.glendinning@shawell.net> wrote:
> This patch enables USB dynamic autosuspend for LAN9500A.  This
> saves very little power in itself, but it allows power saving

Putting device into suspend1 after link being off does save power, so
please update the commit log.

> in upstream hubs/hosts.
>
> The earlier devices in this family (LAN9500/9512/9514) do not
> support this feature.
>
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> ---
>  drivers/net/usb/smsc95xx.c |  151 +++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 150 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 124e67f..6a74a68 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -55,6 +55,13 @@
>  #define FEATURE_PHY_NLP_CROSSOVER      (0x02)
>  #define FEATURE_AUTOSUSPEND            (0x04)
>
> +#define SUSPEND_SUSPEND0               (0x01)
> +#define SUSPEND_SUSPEND1               (0x02)
> +#define SUSPEND_SUSPEND2               (0x04)
> +#define SUSPEND_SUSPEND3               (0x08)
> +#define SUSPEND_ALLMODES               (SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
> +                                        SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
> +
>  struct smsc95xx_priv {
>         u32 mac_cr;
>         u32 hash_hi;
> @@ -62,6 +69,7 @@ struct smsc95xx_priv {
>         u32 wolopts;
>         spinlock_t mac_cr_lock;
>         u8 features;
> +       u8 suspend_flags;
>  };
>
>  static bool turbo_mode = true;
> @@ -1242,6 +1250,8 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
>         /* read back PM_CTRL */
>         ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
>
> +       pdata->suspend_flags |= SUSPEND_SUSPEND0;
> +
>         return ret;
>  }
>
> @@ -1286,11 +1296,14 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
>
>         ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
>
> +       pdata->suspend_flags |= SUSPEND_SUSPEND1;
> +
>         return ret;
>  }
>
>  static int smsc95xx_enter_suspend2(struct usbnet *dev)
>  {
> +       struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
>         u32 val;
>         int ret;
>
> @@ -1303,9 +1316,97 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
>
>         ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
>
> +       pdata->suspend_flags |= SUSPEND_SUSPEND2;
> +
>         return ret;
>  }
>
> +static int smsc95xx_enter_suspend3(struct usbnet *dev)
> +{
> +       struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
> +       u32 val;
> +       int ret;
> +
> +       ret = smsc95xx_read_reg_nopm(dev, RX_FIFO_INF, &val);
> +       if (ret < 0)
> +               return ret;
> +
> +       if (val & 0xFFFF) {
> +               netdev_info(dev->net, "rx fifo not empty in autosuspend\n");
> +               return -EBUSY;
> +       }
> +
> +       ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
> +       if (ret < 0)
> +               return ret;
> +
> +       val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
> +       val |= PM_CTL_SUS_MODE_3 | PM_CTL_RES_CLR_WKP_STS;
> +
> +       ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
> +       if (ret < 0)
> +               return ret;
> +
> +       /* clear wol status */
> +       val &= ~PM_CTL_WUPS_;
> +       val |= PM_CTL_WUPS_WOL_;
> +
> +       ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
> +       if (ret < 0)
> +               return ret;
> +
> +       pdata->suspend_flags |= SUSPEND_SUSPEND3;
> +
> +       return 0;
> +}
> +
> +static int smsc95xx_autosuspend(struct usbnet *dev, u32 link_up)
> +{
> +       struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
> +       int ret;
> +
> +       if (!netif_running(dev->net)) {
> +               /* interface is ifconfig down so fully power down hw */
> +               netdev_dbg(dev->net, "autosuspend entering SUSPEND2\n");
> +               return smsc95xx_enter_suspend2(dev);
> +       }
> +
> +       if (!link_up) {
> +               /* link is down so enter EDPD mode, but only if device can
> +                * reliably resume from it.  This check should be redundant
> +                * as current FEATURE_AUTOSUSPEND parts also support
> +                * FEATURE_PHY_NLP_CROSSOVER but it's included for clarity */
> +               if (!(pdata->features & FEATURE_PHY_NLP_CROSSOVER)) {
> +                       netdev_warn(dev->net, "EDPD not supported\n");
> +                       return -EBUSY;
> +               }
> +
> +               netdev_dbg(dev->net, "autosuspend entering SUSPEND1\n");
> +
> +               /* enable PHY wakeup events for if cable is attached */
> +               ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
> +                       PHY_INT_MASK_ANEG_COMP_);
> +               if (ret < 0) {
> +                       netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
> +                       return ret;
> +               }
> +
> +               netdev_info(dev->net, "entering SUSPEND1 mode\n");
> +               return smsc95xx_enter_suspend1(dev);
> +       }
> +
> +       /* enable PHY wakeup events so we remote wakeup if cable is pulled */
> +       ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
> +               PHY_INT_MASK_LINK_DOWN_);
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "error enabling PHY wakeup ints\n");
> +               return ret;
> +       }
> +
> +       netdev_dbg(dev->net, "autosuspend entering SUSPEND3\n");
> +       return smsc95xx_enter_suspend3(dev);
> +}
> +
>  static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>  {
>         struct usbnet *dev = usb_get_intfdata(intf);
> @@ -1313,15 +1414,35 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>         u32 val, link_up;
>         int ret;
>
> +       /* TODO: don't indicate this feature to usb framework if
> +        * our current hardware doesn't have the capability
> +        */
> +       if ((message.event == PM_EVENT_AUTO_SUSPEND) &&
> +           (!(pdata->features & FEATURE_AUTOSUSPEND))) {
> +               netdev_warn(dev->net, "autosuspend not supported\n");
> +               return -EBUSY;
> +       }

The above is wrong, sorry for not mentioning it in the previous review.

Firstly, the flag FEATURE_AUTOSUSPEND is misleading, and it only
means that the device can't generate remote wakeup, and it shouldn't
mean that the device can't be put into auto-suspend. So a better name
might be FEATURE_REMOTE_WAKEUP.

Secondly, the device should and can be put into auto suspend when
the network interface is down, but the above change makes that
impossible.

> +
>         ret = usbnet_suspend(intf, message);
>         if (ret < 0) {
>                 netdev_warn(dev->net, "usbnet_suspend error\n");
>                 return ret;
>         }
>
> +       if (pdata->suspend_flags) {
> +               netdev_warn(dev->net, "error during last resume\n");
> +               pdata->suspend_flags = 0;
> +       }
> +
>         /* determine if link is up using only _nopm functions */
>         link_up = smsc95xx_link_ok_nopm(dev);
>
> +       if (message.event == PM_EVENT_AUTO_SUSPEND) {
> +               ret = smsc95xx_autosuspend(dev, link_up);
> +               goto done;
> +       }
> +
> +       /* if we get this far we're not autosuspending */
>         /* if no wol options set, or if link is down and we're not waking on
>          * PHY activity, enter lowest power SUSPEND2 mode
>          */
> @@ -1552,12 +1673,18 @@ static int smsc95xx_resume(struct usb_interface *intf)
>  {
>         struct usbnet *dev = usb_get_intfdata(intf);
>         struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
> +       u8 suspend_flags = pdata->suspend_flags;
>         int ret;
>         u32 val;
>
>         BUG_ON(!dev);
>
> -       if (pdata->wolopts) {
> +       netdev_dbg(dev->net, "resume suspend_flags=0x%02x\n", suspend_flags);
> +
> +       /* do this first to ensure it's cleared even in error case */
> +       pdata->suspend_flags = 0;
> +
> +       if (suspend_flags & SUSPEND_ALLMODES) {
>                 /* clear wake-up sources */
>                 ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
>                 if (ret < 0)
> @@ -1741,6 +1868,26 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
>         return skb;
>  }
>
> +static int smsc95xx_manage_power(struct usbnet *dev, int on)
> +{
> +       struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
> +
> +       dev->intf->needs_remote_wakeup = on;
> +
> +       if (pdata->features & FEATURE_AUTOSUSPEND)
> +               return 0;
> +
> +       /* this chip revision doesn't support autosuspend */
> +       netdev_info(dev->net, "hardware doesn't support USB autosuspend\n");

Both the comment and the log are misleading.

> +
> +       if (on)
> +               usb_autopm_get_interface_no_resume(dev->intf);
> +       else
> +               usb_autopm_put_interface(dev->intf);

As mentioned previously, playing the get/put trick is not good, why
can't we set .manage_power as null for these devices?

> +       return 0;
> +}
> +
>  static const struct driver_info smsc95xx_info = {
>         .description    = "smsc95xx USB 2.0 Ethernet",
>         .bind           = smsc95xx_bind,
> @@ -1750,6 +1897,7 @@ static const struct driver_info smsc95xx_info = {
>         .rx_fixup       = smsc95xx_rx_fixup,
>         .tx_fixup       = smsc95xx_tx_fixup,
>         .status         = smsc95xx_status,
> +       .manage_power   = smsc95xx_manage_power,
>         .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
>  };
>
> @@ -1857,6 +2005,7 @@ static struct usb_driver smsc95xx_driver = {
>         .reset_resume   = smsc95xx_resume,
>         .disconnect     = usbnet_disconnect,
>         .disable_hub_initiated_lpm = 1,
> +       .supports_autosuspend = 1,
>  };
>
>  module_usb_driver(smsc95xx_driver);
> --
> 1.7.10.4
>

Thanks,
--
Ming Lei
