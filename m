From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Wed, 12 Dec 2012 00:13:49 +0800
Message-ID: <CACVXFVNf1EWfnQmDBDoF991cqJOb8g_Ws+tuyBJdE34rbO6GSw@mail.gmail.com>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
To: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355239561-2740-1-git-send-email-steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 11, 2012 at 11:26 PM, Steve Glendinning
<steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org> wrote:
> This patch enables USB dynamic autosuspend for LAN9500A.  This
> saves very little power in itself, but it allows power saving
> in upstream hubs/hosts.
>
> The earlier devices in this family (LAN9500/9512/9514) do not
> support this feature.
>
> Signed-off-by: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
> ---
>  drivers/net/usb/smsc95xx.c |  159 +++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 158 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 9b73670..bdd51fd 100644
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
> @@ -1341,6 +1349,8 @@ static int smsc95xx_enter_suspend0(struct usbnet *dev)
>         if (ret < 0)
>                 netdev_warn(dev->net, "Error reading PM_CTRL\n");
>
> +       pdata->suspend_flags |= SUSPEND_SUSPEND0;
> +
>         return ret;
>  }
>
> @@ -1393,11 +1403,14 @@ static int smsc95xx_enter_suspend1(struct usbnet *dev)
>         if (ret < 0)
>                 netdev_warn(dev->net, "Error writing PM_CTRL\n");
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
> @@ -1414,9 +1427,105 @@ static int smsc95xx_enter_suspend2(struct usbnet *dev)
>         if (ret < 0)
>                 netdev_warn(dev->net, "Error writing PM_CTRL\n");
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
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "Error reading RX_FIFO_INF");
> +               return ret;
> +       }
> +
> +       if (val & 0xFFFF) {
> +               netdev_info(dev->net, "rx fifo not empty in autosuspend");
> +               return -EBUSY;
> +       }
> +
> +       ret = smsc95xx_read_reg_nopm(dev, PM_CTRL, &val);
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "Error reading PM_CTRL");
> +               return ret;
> +       }
> +
> +       val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
> +       val |= PM_CTL_SUS_MODE_3 | PM_CTL_RES_CLR_WKP_STS;
> +
> +       ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "Error writing PM_CTRL");
> +               return ret;
> +       }
> +
> +       /* clear wol status */
> +       val &= ~PM_CTL_WUPS_;
> +       val |= PM_CTL_WUPS_WOL_;
> +
> +       ret = smsc95xx_write_reg_nopm(dev, PM_CTRL, val);
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "Error writing PM_CTRL");
> +               return ret;
> +       }
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
> +               netdev_dbg(dev->net, "autosuspend entering SUSPEND2");
> +               return smsc95xx_enter_suspend2(dev);
> +       }
> +
> +       if (!link_up) {
> +               /* link is down so enter EDPD mode, but only if device can
> +                * reliably resume from it.  This check should be redundant
> +                * as current FEATURE_AUTOSUSPEND parts also support
> +                * FEATURE_PHY_NLP_CROSSOVER but it's included for clarity */
> +               if (!(pdata->features & FEATURE_PHY_NLP_CROSSOVER)) {
> +                       netdev_warn(dev->net, "EDPD not supported");
> +                       return -EBUSY;
> +               }
> +
> +               netdev_dbg(dev->net, "autosuspend entering SUSPEND1");
> +
> +               /* enable PHY wakeup events for if cable is attached */
> +               ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
> +                       PHY_INT_MASK_ANEG_COMP_);
> +               if (ret < 0) {
> +                       netdev_warn(dev->net, "error enabling PHY wakeup ints");
> +                       return ret;
> +               }
> +
> +               netdev_info(dev->net, "entering SUSPEND1 mode");
> +               return smsc95xx_enter_suspend1(dev);
> +       }
> +
> +       /* enable PHY wakeup events so we remote wakeup if cable is pulled */
> +       ret = smsc95xx_enable_phy_wakeup_interrupts(dev,
> +               PHY_INT_MASK_LINK_DOWN_);
> +       if (ret < 0) {
> +               netdev_warn(dev->net, "error enabling PHY wakeup ints");
> +               return ret;
> +       }
> +
> +       netdev_dbg(dev->net, "autosuspend entering SUSPEND3");
> +       return smsc95xx_enter_suspend3(dev);
> +}
> +
>  static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>  {
>         struct usbnet *dev = usb_get_intfdata(intf);
> @@ -1424,15 +1533,35 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>         u32 val, link_up;
>         int ret;
>
> +       /* TODO: don't indicate this feature to usb framework if
> +        * our current hardware doesn't have the capability
> +        */
> +       if ((message.event == PM_EVENT_AUTO_SUSPEND) &&
> +           (!(pdata->features & FEATURE_AUTOSUSPEND))) {
> +               netdev_warn(dev->net, "autosuspend not supported");
> +               return -EBUSY;
> +       }
> +
>         ret = usbnet_suspend(intf, message);
>         if (ret < 0) {
>                 netdev_warn(dev->net, "usbnet_suspend error\n");
>                 return ret;
>         }
>
> +       if (pdata->suspend_flags) {
> +               netdev_warn(dev->net, "error during last resume");
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
> @@ -1694,12 +1823,18 @@ static int smsc95xx_resume(struct usb_interface *intf)
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
> +       netdev_dbg(dev->net, "resume suspend_flags=0x%02x", suspend_flags);
> +
> +       /* do this first to ensure it's cleared even in error case */
> +       pdata->suspend_flags = 0;
> +
> +       if (suspend_flags & SUSPEND_ALLMODES) {
>                 /* clear wake-up sources */
>                 ret = smsc95xx_read_reg_nopm(dev, WUCSR, &val);
>                 if (ret < 0) {
> @@ -1891,6 +2026,26 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
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
> +
> +       if (on)
> +               usb_autopm_get_interface_no_resume(dev->intf);
> +       else
> +               usb_autopm_put_interface_no_suspend(dev->intf);

The above line should be

          usb_autopm_put_interface(dev->intf);

> +
> +       return 0;
> +}

IMO, it is better to keep smsc95xx_info.manage_power as NULL
for devices without FEATURE_AUTOSUSPEND, so that fewer code
and follow the current .mange_power usage(see its comment).

Currently, if the function pointer of manage_power is set, it means that
the device supports USB autosuspend, but your trick will make the
assumption not true for some smsc devices.

> +
>  static const struct driver_info smsc95xx_info = {
>         .description    = "smsc95xx USB 2.0 Ethernet",
>         .bind           = smsc95xx_bind,
> @@ -1900,6 +2055,7 @@ static const struct driver_info smsc95xx_info = {
>         .rx_fixup       = smsc95xx_rx_fixup,
>         .tx_fixup       = smsc95xx_tx_fixup,
>         .status         = smsc95xx_status,
> +       .manage_power   = smsc95xx_manage_power,
>         .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
>  };
>
> @@ -2007,6 +2163,7 @@ static struct usb_driver smsc95xx_driver = {
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
