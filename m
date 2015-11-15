From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Sun, 15 Nov 2015 04:30:25 +0200
Message-ID: <CAHp75VehDXoMNsXD08Et9Z5Pds+7Xf5+PXHE2pFzh4Srs-Tw+A@mail.gmail.com>
References: <1447538738-28605-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36424 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbbKOCa0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 21:30:26 -0500
In-Reply-To: <1447538738-28605-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 15, 2015 at 12:05 AM, Ondrej Zary
<linux@rainbow-software.org> wrote:
> Add support for IP1000A chips to dl2k driver.
> IP1000A chip looks like a TC9020 with integrated PHY.
>
> This allows IP1000A chips to work reliably because the ipg driver is
> buggy - it loses packets under load and then completely stops
> transmitting data.
>
> Tested with Asus NX1101 v2.0 at 10, 100 and 1000Mbps.
> Also verified that it does not break D-Link DGE-550T.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Nitpicks below.

> --- a/drivers/net/ethernet/dlink/dl2k.c
> +++ b/drivers/net/ethernet/dlink/dl2k.c
> @@ -253,6 +253,18 @@ rio_probe1 (struct pci_dev *pdev, const struct p=
ci_device_id *ent)
>         if (err)
>                 goto err_out_unmap_rx;
>
> +       if (np->chip_id =3D=3D CHIP_IP1000A &&
> +           (np->pdev->revision =3D=3D 0x40 || np->pdev->revision =3D=
=3D 0x41)) {
> +               /* PHY magic taken from ipg driver */
> +               mii_write(dev, np->phy_addr, 31, 0x0001);
> +               mii_write(dev, np->phy_addr, 27, 0x01e0);
> +               mii_write(dev, np->phy_addr, 31, 0x0002);
> +               mii_write(dev, np->phy_addr, 27, 0xeb8e);
> +               mii_write(dev, np->phy_addr, 31, 0x0000);
> +               mii_write(dev, np->phy_addr, 30, 0x005e);
> +               mii_write(dev, np->phy_addr, 9, 0x0700);

Isn't too many magic numbers?

> +       }
> +
>         /* Fiber device? */
>         np->phy_media =3D (dr16(ASICCtrl) & PhyMedia) ? 1 : 0;
>         np->link_status =3D 0;
> @@ -361,6 +373,11 @@ parse_eeprom (struct net_device *dev)
>         for (i =3D 0; i < 6; i++)
>                 dev->dev_addr[i] =3D psrom->mac_addr[i];
>
> +       if (np->chip_id =3D=3D CHIP_IP1000A) {
> +               np->led_mode =3D psrom->led_mode;
> +               return 0;
> +       }
> +
>         if (np->pdev->vendor !=3D PCI_VENDOR_ID_DLINK) {
>                 return 0;
>         }
> @@ -406,6 +423,28 @@ parse_eeprom (struct net_device *dev)
>         return 0;
>  }
>
> +static void rio_set_led_mode(struct net_device *dev)
> +{
> +       struct netdev_private *np =3D netdev_priv(dev);
> +       void __iomem *ioaddr =3D np->ioaddr;
> +       u32 mode;
> +
> +       if (np->chip_id !=3D CHIP_IP1000A)
> +               return;
> +
> +       mode =3D dr32(ASICCtrl);
> +       mode &=3D ~(IPG_AC_LED_MODE_BIT_1 | IPG_AC_LED_MODE | IPG_AC_=
LED_SPEED);
> +
> +       if ((np->led_mode & 0x03) > 1)

Isn't "& 0x03) > 1" the same as plain "& 0x02"?

> +               mode |=3D IPG_AC_LED_MODE_BIT_1;
> +       if ((np->led_mode & 0x01) =3D=3D 1)

Hmm=E2=80=A6 Seems redundant =3D=3D 1.

> +               mode |=3D IPG_AC_LED_MODE;
> +       if ((np->led_mode & 0x08) =3D=3D 8)

Similar here.

> +               mode |=3D IPG_AC_LED_SPEED;
> +
> +       dw32(ASICCtrl, mode);
> +}
> +
>  static int
>  rio_open (struct net_device *dev)
>  {
> @@ -424,6 +463,8 @@ rio_open (struct net_device *dev)
>              GlobalReset | DMAReset | FIFOReset | NetworkReset | Host=
Reset);
>         mdelay(10);
>
> +       rio_set_led_mode(dev);
> +
>         /* DebugCtrl bit 4, 5, 9 must set */
>         dw32(DebugCtrl, dr32(DebugCtrl) | 0x0230);
>
> @@ -433,9 +474,10 @@ rio_open (struct net_device *dev)
>
>         alloc_list (dev);
>
> -       /* Get station address */
> -       for (i =3D 0; i < 6; i++)
> -               dw8(StationAddr0 + i, dev->dev_addr[i]);
> +       /* Set station address */
> +       for (i =3D 0; i < 3; i++)
> +               dw16(StationAddr0 + 2 * i,
> +                    cpu_to_le16(((u16 *)dev->dev_addr)[i]));

Is it specific requirement for new HW? If not, may be another patch
with micro optimizations.

>
>         set_multicast (dev);
>         if (np->coalesce) {
> @@ -780,6 +822,7 @@ tx_error (struct net_device *dev, int tx_status)
>                                 break;
>                         mdelay (1);
>                 }
> +               rio_set_led_mode(dev);
>                 rio_free_tx (dev, 1);
>                 /* Reset TFDListPtr */
>                 dw32(TFDListPtr0, np->tx_ring_dma +
> @@ -799,6 +842,7 @@ tx_error (struct net_device *dev, int tx_status)
>                                 break;
>                         mdelay (1);
>                 }
> +               rio_set_led_mode(dev);
>                 /* Let TxStartThresh stay default value */
>         }
>         /* Maximum Collisions */
> @@ -965,6 +1009,7 @@ rio_error (struct net_device *dev, int int_statu=
s)
>                         dev->name, int_status);
>                 dw16(ASICCtrl + 2, GlobalReset | HostReset);
>                 mdelay (500);
> +               rio_set_led_mode(dev);
>         }
>  }
>
> diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet=
/dlink/dl2k.h
> index 23c07b0..8f4f612 100644
> --- a/drivers/net/ethernet/dlink/dl2k.h
> +++ b/drivers/net/ethernet/dlink/dl2k.h
> @@ -211,6 +211,10 @@ enum ASICCtrl_HiWord_bits {
>         ResetBusy =3D 0x0400,
>  };
>
> +#define IPG_AC_LED_MODE                BIT(14)
> +#define IPG_AC_LED_SPEED       BIT(27)
> +#define IPG_AC_LED_MODE_BIT_1  BIT(29)
> +
>  /* Transmit Frame Control bits */
>  enum TFC_bits {
>         DwordAlign =3D 0x00000000,
> @@ -332,7 +336,10 @@ typedef struct t_SROM {
>         u16 asic_ctrl;          /* 0x02 */
>         u16 sub_vendor_id;      /* 0x04 */
>         u16 sub_system_id;      /* 0x06 */
> -       u16 reserved1[12];      /* 0x08-0x1f */
> +       u16 pci_base_1;         /* 0x08 (IP1000A only) */
> +       u16 pci_base_2;         /* 0x0a (IP1000A only) */
> +       u16 led_mode;           /* 0x0c (IP1000A only) */
> +       u16 reserved1[9];       /* 0x0e-0x1f */
>         u8 mac_addr[6];         /* 0x20-0x25 */
>         u8 reserved2[10];       /* 0x26-0x2f */
>         u8 sib[204];            /* 0x30-0xfb */
> @@ -397,6 +404,7 @@ struct netdev_private {
>         u16 advertising;        /* NWay media advertisement */
>         u16 negotiate;          /* Negotiated media */
>         int phy_addr;           /* PHY addresses. */
> +       u16 led_mode;           /* LED mode read from EEPROM (IP1000A=
 only) */
>  };
>
>  /* The station address location in the EEPROM. */
> @@ -407,10 +415,15 @@ struct netdev_private {
>          class_mask              of the class are honored during the =
comparison.
>          driver_data             Data private to the driver.
>  */
> +#define CHIP_IP1000A   1
>
>  static const struct pci_device_id rio_pci_tbl[] =3D {
>         {0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
>         {0x13f0, 0x1021, PCI_ANY_ID, PCI_ANY_ID, },
> +       { PCI_VDEVICE(SUNDANCE, 0x1023), CHIP_IP1000A },
> +       { PCI_VDEVICE(SUNDANCE, 0x2021), CHIP_IP1000A },
> +       { PCI_VDEVICE(DLINK,    0x9021), CHIP_IP1000A },
> +       { PCI_VDEVICE(DLINK,    0x4020), CHIP_IP1000A },
>         { }
>  };
>  MODULE_DEVICE_TABLE (pci, rio_pci_tbl);
> --
> Ondrej Zary
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--=20
With Best Regards,
Andy Shevchenko
