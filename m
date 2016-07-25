From: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/3] net: asix: Avoid looping when the device is disconnected
Date: Mon, 25 Jul 2016 14:37:12 -0700
Message-ID: <CANEJEGvP=XdcoEvrZNr48NGaGF+mUSc09GGzrGm8wrQ0+fAhaQ@mail.gmail.com>
References: <1469468424-22685-1-git-send-email-robert.foss@collabora.com> <1469468424-22685-2-git-send-email-robert.foss@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
	Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org,
	WK TSAI <wk.tsai-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	enric.balletbo-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, tomeu.vizoso-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
To: robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469468424-22685-2-git-send-email-robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2016 at 10:40 AM,  <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org> wrote:
> From: Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>
> Check the answers from the USB stack and avoid re-sending multiple times
> the request if the device has disappeared.
>
> Signed-off-by: Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

The original chromium.org code review:
    https://chromium-review.googlesource.com/255931

resulted in some additional commit message meta-data that would be
nice to include in the kernel.org commit message:
    Reviewed-by: Julius Werner <jwerner-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
    Reviewed-by: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
    Tested-by: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

And yes, patch LGTM too. :)

cheers,
grant

> ---
>  drivers/net/usb/asix_common.c  | 56 +++++++++++++++++++++++++++++++++---------
>  drivers/net/usb/asix_devices.c |  2 ++
>  2 files changed, 46 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
> index f0ccf76..0339560 100644
> --- a/drivers/net/usb/asix_common.c
> +++ b/drivers/net/usb/asix_common.c
> @@ -428,13 +428,21 @@ int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
>         __le16 res;
>         u8 smsr;
>         int i = 0;
> +       int ret;
>
>         mutex_lock(&dev->phy_mutex);
>         do {
> -               asix_set_sw_mii(dev, 0);
> +               ret = asix_set_sw_mii(dev, 0);
> +               if (ret == -ENODEV)
> +                       break;
>                 usleep_range(1000, 1100);
> -               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
> -       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
> +               ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
> +                                   0, 0, 1, &smsr, 0);
> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
> +       if (ret == -ENODEV) {
> +               mutex_unlock(&dev->phy_mutex);
> +               return ret;
> +       }
>
>         asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
>                                 (__u16)loc, 2, &res, 0);
> @@ -453,16 +461,24 @@ void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
>         __le16 res = cpu_to_le16(val);
>         u8 smsr;
>         int i = 0;
> +       int ret;
>
>         netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
>                         phy_id, loc, val);
>
>         mutex_lock(&dev->phy_mutex);
>         do {
> -               asix_set_sw_mii(dev, 0);
> +               ret = asix_set_sw_mii(dev, 0);
> +               if (ret == -ENODEV)
> +                       break;
>                 usleep_range(1000, 1100);
> -               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
> -       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
> +               ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
> +                                   0, 0, 1, &smsr, 0);
> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
> +       if (ret == -ENODEV) {
> +               mutex_unlock(&dev->phy_mutex);
> +               return;
> +       }
>
>         asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
>                        (__u16)loc, 2, &res, 0);
> @@ -476,13 +492,21 @@ int asix_mdio_read_nopm(struct net_device *netdev, int phy_id, int loc)
>         __le16 res;
>         u8 smsr;
>         int i = 0;
> +       int ret;
>
>         mutex_lock(&dev->phy_mutex);
>         do {
> -               asix_set_sw_mii(dev, 1);
> +               ret = asix_set_sw_mii(dev, 1);
> +               if (ret == -ENODEV)
> +                       break;
>                 usleep_range(1000, 1100);
> -               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
> -       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
> +               ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
> +                                   0, 0, 1, &smsr, 1);
> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
> +       if (ret == -ENODEV) {
> +               mutex_unlock(&dev->phy_mutex);
> +               return ret;
> +       }
>
>         asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
>                       (__u16)loc, 2, &res, 1);
> @@ -502,16 +526,24 @@ asix_mdio_write_nopm(struct net_device *netdev, int phy_id, int loc, int val)
>         __le16 res = cpu_to_le16(val);
>         u8 smsr;
>         int i = 0;
> +       int ret;
>
>         netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
>                         phy_id, loc, val);
>
>         mutex_lock(&dev->phy_mutex);
>         do {
> -               asix_set_sw_mii(dev, 1);
> +               ret = asix_set_sw_mii(dev, 1);
> +               if (ret == -ENODEV)
> +                       break;
>                 usleep_range(1000, 1100);
> -               asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
> -       } while (!(smsr & AX_HOST_EN) && (i++ < 30));
> +               ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
> +                                   0, 0, 1, &smsr, 1);
> +       } while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
> +       if (ret == -ENODEV) {
> +               mutex_unlock(&dev->phy_mutex);
> +               return;
> +       }
>
>         asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
>                        (__u16)loc, 2, &res, 1);
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
> index aaa4290..ebeb730 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -79,6 +79,8 @@ static u32 asix_get_phyid(struct usbnet *dev)
>         /* Poll for the rare case the FW or phy isn't ready yet.  */
>         for (i = 0; i < 100; i++) {
>                 phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
> +               if (phy_reg < 0)
> +                       return 0;
>                 if (phy_reg != 0 && phy_reg != 0xFFFF)
>                         break;
>                 mdelay(1);
> --
> 2.7.4
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
