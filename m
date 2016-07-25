From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 3/3] net: asix: Fix AX88772x resume failures
Date: Mon, 25 Jul 2016 14:45:10 -0700
Message-ID: <CANEJEGuQFJ+cwyOD-kpKkfeUUNM5dNnNVV3jwy0OijVB2_R=sA@mail.gmail.com>
References: <1469468424-22685-1-git-send-email-robert.foss@collabora.com> <1469468424-22685-3-git-send-email-robert.foss@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@chromium.org>, Mark_Craske@mentor.com,
	Dean_Jenkins@mentor.com, Vincent Palatin <vpalatin@chromium.org>,
	ivecera@redhat.com, linux@davidrobins.net,
	WK TSAI <wk.tsai@nvidia.com>, changchias@gmail.com,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	enric.balletbo@collabora.com, tomeu.vizoso@collabora.com
To: robert.foss@collabora.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:33592 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbcGYVpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 17:45:12 -0400
Received: by mail-yw0-f182.google.com with SMTP id r9so168222081ywg.0
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 14:45:12 -0700 (PDT)
In-Reply-To: <1469468424-22685-3-git-send-email-robert.foss@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert,
This patch content LGTM but isn't including the correct "meta data"
regarding it's origin.

On Mon, Jul 25, 2016 at 10:40 AM,  <robert.foss@collabora.com> wrote:
> From: WK Tsai <wk.tsai@nvidia.com>

WK Tsai is not the author of this patch.
I believe Allan Chou <allan@asix.com.tw> is the author.

> The change fixes AX88772x resume failure by
> - Restore incorrect AX88772A PHY registers when resetting
> - Need to stop MAC operation when suspending
> - Need to restart MII when restoring PHY
>
> Signed-off-by: WK Tsai <wk.tsai@nvidia.com>

This patch was applied to four different chromium.org kernel branches:
   https://chromium-review.googlesource.com/#/q/Fix+AX88772x+resume+failures

And has substantial meta data regarding author and reviewers:
  (summarized from https://chromium-review.googlesource.com/#/c/314520/)

Signed-off-by: Allan Chou <allan@asix.com.tw>
Signed-off-by: WK Tsai <wk.tsai@nvidia.com>
Tested-by: Grant Grundler <grundler@chromium.org>
Reviewed-by: Wang-Kai Tsai <gis555t@gmail.com>
Reviewed-by: Mark Kuo <mkuo@nvidia.com>
Reviewed-by: Grant Grundler <grundler@chromium.org>
Reviewed-by: Allan Chou <allanchou1357@gmail.com>
Reviewed-by: Vincent Palatin <vpalatin@chromium.org>

cheers,
grant

> ---
>  drivers/net/usb/asix_devices.c | 47 +++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 46 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
> index ebeb730..083dc2e 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -35,6 +35,15 @@
>
>  #define        PHY_MODE_RTL8211CL      0x000C
>
> +#define AX88772A_PHY14H                0x14
> +#define AX88772A_PHY14H_DEFAULT 0x442C
> +
> +#define AX88772A_PHY15H                0x15
> +#define AX88772A_PHY15H_DEFAULT 0x03C8
> +
> +#define AX88772A_PHY16H                0x16
> +#define AX88772A_PHY16H_DEFAULT 0x4044
> +
>  struct ax88172_int_data {
>         __le16 res1;
>         u8 link;
> @@ -424,7 +433,7 @@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
>  {
>         struct asix_data *data = (struct asix_data *)&dev->data;
>         int ret, embd_phy;
> -       u16 rx_ctl;
> +       u16 rx_ctl, phy14h, phy15h, phy16h;
>         u8 chipcode = 0;
>
>         ret = asix_write_gpio(dev, AX_GPIO_RSE, 5, in_pm);
> @@ -482,6 +491,32 @@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
>                                    ret);
>                         goto out;
>                 }
> +       } else if ((chipcode & AX_CHIPCODE_MASK) == AX_AX88772A_CHIPCODE) {
> +               /* Check if the PHY registers have default settings */
> +               phy14h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY14H);
> +               phy15h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY15H);
> +               phy16h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY16H);
> +
> +               netdev_dbg(dev->net,
> +                          "772a_hw_reset: MR20=0x%x MR21=0x%x MR22=0x%x\n",
> +                          phy14h, phy15h, phy16h);
> +
> +               /* Restore PHY registers default setting if not */
> +               if (phy14h != AX88772A_PHY14H_DEFAULT)
> +                       asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY14H,
> +                                            AX88772A_PHY14H_DEFAULT);
> +               if (phy15h != AX88772A_PHY15H_DEFAULT)
> +                       asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY15H,
> +                                            AX88772A_PHY15H_DEFAULT);
> +               if (phy16h != AX88772A_PHY16H_DEFAULT)
> +                       asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
> +                                            AX88772A_PHY16H,
> +                                            AX88772A_PHY16H_DEFAULT);
>         }
>
>         ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
> @@ -543,6 +578,15 @@ static const struct net_device_ops ax88772_netdev_ops = {
>  static void ax88772_suspend(struct usbnet *dev)
>  {
>         struct asix_common_private *priv = dev->driver_priv;
> +       u16 medium;
> +
> +       /* Stop MAC operation */
> +       medium = asix_read_medium_status(dev, 0);
> +       medium &= ~AX_MEDIUM_RE;
> +       asix_write_medium_mode(dev, medium, 0);
> +
> +       netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
> +                  asix_read_medium_status(dev, 0));
>
>         /* Preserve BMCR for restoring */
>         priv->presvd_phy_bmcr =
> @@ -577,6 +621,7 @@ static void ax88772_restore_phy(struct usbnet *dev)
>                 asix_mdio_write_nopm(dev->net, dev->mii.phy_id, MII_BMCR,
>                                      priv->presvd_phy_bmcr);
>
> +               mii_nway_restart(&dev->mii);
>                 priv->presvd_phy_advertise = 0;
>                 priv->presvd_phy_bmcr = 0;
>         }
> --
> 2.7.4
>
