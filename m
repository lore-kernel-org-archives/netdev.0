From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit
 ethernet adapter driver
Date: Fri, 11 Jan 2013 10:45:38 +0800
Message-ID: <CACVXFVMdgx1we67poF5yU5pAYRYoA9Ao1EJqQgGBaaORuARFQQ@mail.gmail.com>
References: <1357867046-22918-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357867046-22918-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc netdev and usb lists.


On Fri, Jan 11, 2013 at 9:17 AM,  <freddy@asix.com.tw> wrote:
> From: Freddy Xin <freddy@asix.com.tw>
>
> This patch adds a driver for ASIX's AX88179 family of USB 3.0/2.0
> to gigabit ethernet adapters. It's based on the AX88xxx driver but
> the usb commands used to access registers for AX88179 are completely different.
> This driver had been verified on x86 system with AX88179/AX88178A and
> Sitcomm LN-032 USB dongles.
>
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>
> ---
>  drivers/net/usb/Kconfig        |   18 +
>  drivers/net/usb/Makefile       |    1 +
>  drivers/net/usb/ax88179_178a.c | 1457 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1476 insertions(+)
>  create mode 100644 drivers/net/usb/ax88179_178a.c
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index ef97621..75af401 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -158,6 +158,24 @@ config USB_NET_AX8817X
>           This driver creates an interface named "ethX", where X depends on
>           what other networking devices you have in use.
>
> +config USB_NET_AX88179_178A
> +       tristate "ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet"
> +       depends on USB_USBNET
> +       select CRC32
> +       select PHYLIB
> +       default y
> +       help
> +         This option adds support for ASIX AX88179 based USB 3.0/2.0
> +         to Gigabit Ethernet adapters.
> +
> +         This driver should work with at least the following devices:
> +           * ASIX AX88179
> +           * ASIX AX88178A
> +           * Sitcomm LN-032
> +
> +         This driver creates an interface named "ethX", where X depends on
> +         what other networking devices you have in use.
> +
>  config USB_NET_CDCETHER
>         tristate "CDC Ethernet support (smart devices such as cable modems)"
>         depends on USB_USBNET
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index 4786913..ce01578 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -9,6 +9,7 @@ obj-$(CONFIG_USB_RTL8150)       += rtl8150.o
>  obj-$(CONFIG_USB_HSO)          += hso.o
>  obj-$(CONFIG_USB_NET_AX8817X)  += asix.o
>  asix-y := asix_devices.o asix_common.o ax88172a.o
> +obj-$(CONFIG_USB_NET_AX88179_178A)     += ax88179_178a.o
>  obj-$(CONFIG_USB_NET_CDCETHER) += cdc_ether.o
>  obj-$(CONFIG_USB_NET_CDC_EEM)  += cdc_eem.o
>  obj-$(CONFIG_USB_NET_DM9601)   += dm9601.o
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> new file mode 100644
> index 0000000..47504ea
> --- /dev/null
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -0,0 +1,1457 @@
> +/*
> + * ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet Devices
> + *
> + * Copyright (C) 20011-2012 ASIX
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/etherdevice.h>
> +#include <linux/mii.h>
> +#include <linux/usb.h>
> +#include <linux/crc32.h>
> +#include <linux/usb/usbnet.h>
> +
> +
> +#define AX88179_PHY_ID                         0x03
> +#define AX_EEPROM_LEN                          0x100
> +#define AX_MCAST_FILTER_SIZE                   8
> +#define AX_MAX_MCAST                           64
> +#define AX_RX_CHECKSUM                         1
> +#define AX_TX_CHECKSUM                         2
> +#define AX_INT_PPLS_LINK                       BIT(0)
> +#define AX_RXHDR_L4_TYPE_UDP                   1
> +#define AX_RXHDR_L4_TYPE_TCP                   4
> +#define AX_ACCESS_MAC                          0x01
> +#define AX_ACCESS_PHY                          0x02
> +#define AX_ACCESS_EEPROM                       0x04
> +#define AX_ACCESS_EFUSE                                0x05
> +#define AX_PAUSE_WATERLVL_HIGH                 0x54
> +#define AX_PAUSE_WATERLVL_LOW                  0x55
> +
> +#define PHYSICAL_LINK_STATUS                   0x02
> +       #define AX_USB_SS               0x04
> +       #define AX_USB_HS               0x02
> +       #define AX_USB_FS               0x01
> +
> +#define GENERAL_STATUS                         0x03
> +/* Check AX88179 version. UA1:Bit2 = 0,  UA2:Bit2 = 1 */
> +       #define AX_SECLD                0x04
> +
> +#define AX_SROM_ADDR                           0x07
> +#define AX_SROM_CMD                            0x0a
> +       #define EEP_RD                  0x04
> +       #define EEP_BUSY                0x10
> +
> +
> +#define AX_SROM_DATA_LOW                       0x08
> +#define AX_SROM_DATA_HIGH                      0x09
> +
> +#define AX_RX_CTL                              0x0b
> +       #define AX_RX_CTL_DROPCRCERR    0x0100
> +       #define AX_RX_CTL_IPE           0x0200
> +       #define AX_RX_CTL_START         0x0080
> +       #define AX_RX_CTL_AP            0x0020
> +       #define AX_RX_CTL_AM            0x0010
> +       #define AX_RX_CTL_AB            0x0008
> +       #define AX_RX_CTL_AMALL         0x0002
> +       #define AX_RX_CTL_PRO           0x0001
> +       #define AX_RX_CTL_STOP          0x0000
> +
> +#define AX_NODE_ID                             0x10
> +#define AX_MULTI_FILTER_ARRY                   0x16
> +
> +#define AX_MEDIUM_STATUS_MODE                  0x22
> +       #define AX_MEDIUM_GIGAMODE      0x01
> +       #define AX_MEDIUM_FULL_DUPLEX   0x02
> +       #define AX_MEDIUM_ALWAYS_ONE    0x04
> +       #define AX_MEDIUM_RXFLOW_CTRLEN 0x10
> +       #define AX_MEDIUM_TXFLOW_CTRLEN 0x20
> +       #define AX_MEDIUM_RECEIVE_EN    0x100
> +       #define AX_MEDIUM_PS            0x200
> +
> +#define AX_MONITOR_MODE                                0x24
> +       #define AX_MONITOR_MODE_RWLC    0x02
> +       #define AX_MONITOR_MODE_RWMP    0x04
> +       #define AX_MONITOR_MODE_PMEPOL  0x20
> +       #define AX_MONITOR_MODE_PMETYPE 0x40
> +
> +#define AX_GPIO_CTRL                           0x25
> +       #define AX_GPIO_CTRL_GPIO3EN    0x80
> +       #define AX_GPIO_CTRL_GPIO2EN    0x40
> +       #define AX_GPIO_CTRL_GPIO1EN    0x20
> +
> +#define AX_PHYPWR_RSTCTL                       0x26
> +       #define AX_PHYPWR_RSTCTL_BZ     0x0010
> +       #define AX_PHYPWR_RSTCTL_IPRL   0x0020
> +       #define AX_PHYPWR_RSTCTL_AT     0x1000
> +
> +#define AX_RX_BULKIN_QCTRL                     0x2e
> +#define AX_CLK_SELECT                          0x33
> +       #define AX_CLK_SELECT_BCS       0x01
> +       #define AX_CLK_SELECT_ACS       0x02
> +       #define AX_CLK_SELECT_ULR       0x08
> +
> +#define AX_RXCOE_CTL                           0x34
> +       #define AX_RXCOE_IP             0x01
> +       #define AX_RXCOE_TCP            0x02
> +       #define AX_RXCOE_UDP            0x04
> +       #define AX_RXCOE_TCPV6          0x20
> +       #define AX_RXCOE_UDPV6          0x40
> +
> +#define AX_TXCOE_CTL                           0x35
> +       #define AX_TXCOE_IP             0x01
> +       #define AX_TXCOE_TCP            0x02
> +       #define AX_TXCOE_UDP            0x04
> +       #define AX_TXCOE_TCPV6          0x20
> +       #define AX_TXCOE_UDPV6          0x40
> +
> +#define AX_LEDCTRL                             0x73
> +
> +#define GMII_PHY_CONTROL                       0x00
> +       #define GMII_CONTROL_1000MB     0x0040
> +       #define GMII_CONTROL_ENAUTO     0x1000
> +       #define GMII_CONTROL_START_AUTO 0x0200
> +       #define GMII_CONTROL_FULLDUPLEX 0x0100
> +
> +#define GMII_PHY_PHYSR                         0x11
> +       #define GMII_PHY_PHYSR_SMASK    0xc000
> +       #define GMII_PHY_PHYSR_GIGA     0x8000
> +       #define GMII_PHY_PHYSR_100      0x4000
> +       #define GMII_PHY_PHYSR_FULL     0x2000
> +       #define GMII_PHY_PHYSR_LINK     0x400
> +
> +#define GMII_LED_ACTIVE                                0x1a
> +       #define GMII_LED_ACTIVE_MASK    0xff8fd
> +       #define GMII_LED0_ACTIVE        BIT(4)
> +       #define GMII_LED1_ACTIVE        BIT(5)
> +       #define GMII_LED2_ACTIVE        BIT(6)
> +
> +#define GMII_LED_LINK                          0x1c
> +       #define GMII_LED_LINK_MASK      0xf888
> +
> +       #define GMII_LED0_LINK_10       BIT(0)
> +       #define GMII_LED0_LINK_100      BIT(1)
> +       #define GMII_LED0_LINK_1000     BIT(2)
> +       #define GMII_LED1_LINK_10       BIT(4)
> +       #define GMII_LED1_LINK_100      BIT(5)
> +       #define GMII_LED1_LINK_1000     BIT(6)
> +       #define GMII_LED2_LINK_10       BIT(8)
> +       #define GMII_LED2_LINK_100      BIT(9)
> +       #define GMII_LED2_LINK_1000     BIT(10)
> +
> +       #define LED0_ACTIVE             BIT(0)
> +       #define LED0_LINK_10            BIT(1)
> +       #define LED0_LINK_100           BIT(2)
> +       #define LED0_LINK_1000          BIT(3)
> +       #define LED0_FD                 BIT(4)
> +       #define LED0_USB3_MASK          0x001f
> +
> +       #define LED1_ACTIVE             BIT(5)
> +       #define LED1_LINK_10            BIT(6)
> +       #define LED1_LINK_100           BIT(7)
> +       #define LED1_LINK_1000          BIT(8)
> +       #define LED1_FD                 BIT(9)
> +       #define LED1_USB3_MASK          0x03e0
> +
> +       #define LED2_ACTIVE             BIT(10)
> +       #define LED2_LINK_1000          BIT(13)
> +       #define LED2_LINK_100           BIT(12)
> +       #define LED2_LINK_10            BIT(11)
> +       #define LED2_FD                 BIT(14)
> +       #define LED_VALID               BIT(15)
> +       #define LED2_USB3_MASK          0x7c00
> +
> +#define GMII_PHYPAGE                           0x1e
> +#define GMII_PHY_PAGE_SELECT                   0x1f
> +       #define GMII_PHY_PGSEL_EXT      0x0007
> +       #define GMII_PHY_PGSEL_PAGE0    0X0000
> +
> +struct ax88179_data {
> +       u16 rxctl;
> +};
> +
> +struct ax88179_int_data {
> +       u16 res1;
> +       u8 link;
> +       u16 res2;
> +       u8 status;
> +       u16 res3;
> +} __packed;
> +
> +struct {unsigned char ctrl, timer_l, timer_h, size, ifg; }
> +AX88179_BULKIN_SIZE[] =        {
> +       {7, 0xa3, 0,    0x14, 0xff},
> +       {7, 0x1e, 5,    0x18, 0xff},
> +       {7, 0xae, 7,    0x18, 0xff},
> +       {7, 0xcc, 0x4c, 0x18, 8},
> +};
> +
> +struct ax88179_rx_pkt_header {
> +
> +       u8      l4_csum_err:1,
> +               l3_csum_err:1,
> +               l4_type:3,
> +               l3_type:2,
> +               ce:1;
> +
> +       u8      vlan_ind:3,
> +               rx_ok:1,
> +               pri:3,
> +               bmc:1;
> +
> +       u16     len:13,
> +               crc:1,
> +               mii:1,
> +               drop:1;
> +
> +} __packed;
> +
> +static int ax88179_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
> +                           u16 size, void *data)
> +{
> +       int ret;
> +       ret = usbnet_read_cmd(dev, cmd,
> +                              USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> +                              value, index, data, size);
> +
> +       if (ret != size && ret >= 0)
> +               return -EINVAL;
> +       return ret;
> +}
> +
> +static int ax88179_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
> +                            u16 size, void *data)
> +{
> +       return usbnet_write_cmd(dev, cmd, USB_DIR_OUT | USB_TYPE_VENDOR
> +                               | USB_RECIP_DEVICE, value, index, data, size);
> +}
> +
> +static void
> +ax88179_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
> +                                   u16 size, void *data)
> +{
> +       usbnet_write_cmd_async(dev, cmd,
> +                              USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> +                              value, index, data, size);
> +}
> +
> +static void ax88179_status(struct usbnet *dev, struct urb *urb)
> +{
> +       struct ax88179_int_data *event;
> +       int link;
> +
> +       if (urb->actual_length < 8)
> +               return;
> +
> +       event = urb->transfer_buffer;
> +       link = event->link & AX_INT_PPLS_LINK;
> +       if (netif_carrier_ok(dev->net) != link) {
> +               if (link)
> +                       usbnet_defer_kevent(dev, EVENT_LINK_RESET);
> +               else
> +                       netif_carrier_off(dev->net);
> +               netdev_info(dev->net, "ax8817X - Link status is: %d\n", link);
> +       }
> +}
> +
> +static int ax88179_mdio_read(struct net_device *netdev, int phy_id, int loc)
> +{
> +       struct usbnet *dev = netdev_priv(netdev);
> +       __u16 *res;
> +       u16 ret;
> +
> +       res = kmalloc(2, GFP_ATOMIC);

You needn't to allocate several bytes just for transferring one command
any more since usbnet_{read|write}_cmd() has handled that already,
so one simple stack variable is OK.

Also GFP_ATOMIC should be changed to GFP_KERNEL.

> +       if (!res)
> +               return 0;
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_PHY, phy_id, (__u16)loc, 2, res);
> +
> +       ret = *res & 0xffff;
> +       kfree(res);
> +
> +       return le16_to_cpu(ret);
> +}
> +
> +static void
> +ax88179_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
> +{
> +       struct usbnet *dev = netdev_priv(netdev);
> +       __le16 *res;
> +
> +       res = kmalloc(2, GFP_ATOMIC);

Same with above.

> +       if (!res)
> +               return;
> +
> +       *res = cpu_to_le16(val);
> +
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, phy_id, (__u16)loc, 2, res);
> +
> +       kfree(res);
> +}
> +
> +static int ax88179_suspend(struct usb_interface *intf, pm_message_t message)
> +{
> +       struct usbnet *dev = usb_get_intfdata(intf);
> +       u16 *tmp16;
> +
> +       usbnet_suspend(intf, message);
> +
> +       tmp16 = kmalloc(2, GFP_KERNEL);

Same with above.

> +       if (!tmp16)
> +               return 0;
> +
> +       /* Disable RX path */
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_MEDIUM_STATUS_MODE, 2, 2, tmp16);
> +       *tmp16 &= ~AX_MEDIUM_RECEIVE_EN;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_MEDIUM_STATUS_MODE, 2, 2, tmp16);
> +
> +       /* Force bulk-in zero length */
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       *tmp16 |= AX_PHYPWR_RSTCTL_BZ | AX_PHYPWR_RSTCTL_IPRL;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +
> +       /* change clock */
> +       *tmp16 = 0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp16);
> +
> +       /* Configure RX control register => stop operation */
> +       *tmp16 = AX_RX_CTL_STOP;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, tmp16);

All the above ax88179_{write|read}_cmd in PM callback should be converted
to its _nopm version, see example in drivers/net/usb/smsc95xx.c. Otherwise,
deadlock will be caused during runtime PM.

> +       kfree(tmp16);
> +       return 0;
> +}
> +
> +/* This function is used to enable the autodetach function. */
> +/* This function is determined by offset 0x43 of EEPROM */
> +static int ax88179_auto_detach(struct usbnet *dev, int flags)
> +{
> +       u16 *tmp;
> +
> +       tmp = kmalloc(2, flags);
> +       if (!tmp)
> +               return -ENOMEM;
> +
> +       if (ax88179_read_cmd(dev, AX_ACCESS_EEPROM, 0x43, 1, 2, tmp) < 0) {
> +               kfree(tmp);
> +               return 0;
> +       }
> +
> +       if ((*tmp == 0xFFFF) || (!(*tmp & 0x0100))) {
> +               kfree(tmp);
> +               return 0;
> +       }
> +
> +       /* Enable Auto Detach bit */
> +       *tmp = 0;
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
> +       *tmp |= AX_CLK_SELECT_ULR;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp);
> +       *tmp |= AX_PHYPWR_RSTCTL_AT;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp);
> +       kfree(tmp);
> +
> +       return 0;
> +}

Considered that ax88179_auto_detach() is called in both non-PM and
PM path, so it is better to pass one 'in_pm' parameter to support the
two cases, see example of smsc95xx_start_rx_path().

> +
> +static int ax88179_resume(struct usb_interface *intf)
> +{
> +       struct usbnet *dev = usb_get_intfdata(intf);
> +       u16 *tmp16;
> +
> +       tmp16 = kmalloc(2, GFP_KERNEL);

Same with above.

> +       if (!tmp16)
> +               return usbnet_resume(intf);
> +
> +       netif_carrier_off(dev->net);
> +
> +       /* Power up ethernet PHY */
> +       *tmp16 = 0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       udelay(1000);
> +       *tmp16 = AX_PHYPWR_RSTCTL_IPRL;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       msleep(200);
> +
> +       /* Ethernet PHY Auto Detach*/
> +       ax88179_auto_detach(dev, GFP_ATOMIC);
> +
> +       /* enable clock */
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC,  AX_CLK_SELECT, 1, 1, tmp16);
> +       *tmp16 |= AX_CLK_SELECT_ACS | AX_CLK_SELECT_BCS;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp16);
> +       msleep(100);
> +
> +       /* Configure RX control register => start operation */
> +       *tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
> +                               AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, tmp16);

All the above ax88179_{write|read}_cmd in PM callback should be converted
to its _nopm version, see example in drivers/net/usb/smsc95xx.c. Otherwise,
deadlock will be caused during runtime PM.

> +
> +       kfree(tmp16);
> +       return usbnet_resume(intf);
> +}
> +
> +static void
> +ax88179_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       u8 *opt;
> +
> +       wolinfo->supported = 0;
> +       wolinfo->wolopts = 0;
> +
> +       opt = kmalloc(1, GFP_KERNEL);

Same with above.

> +       if (!opt)
> +               return;
> +
> +       if (ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_MONITOR_MODE, 1, 1, opt) < 0) {
> +               kfree(opt);
> +               return;
> +       }
> +
> +       wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
> +
> +       if (*opt & AX_MONITOR_MODE_RWLC)
> +               wolinfo->wolopts |= WAKE_PHY;
> +       if (*opt & AX_MONITOR_MODE_RWMP)
> +               wolinfo->wolopts |= WAKE_MAGIC;
> +
> +       kfree(opt);
> +}
> +
> +static int
> +ax88179_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       u8 *opt;
> +
> +       opt = kmalloc(1, GFP_KERNEL);

Same with above.

> +       if (!opt)
> +               return -ENOMEM;
> +
> +       *opt = 0;
> +       if (ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_MONITOR_MODE, 1, 1, opt) < 0) {
> +               kfree(opt);
> +               return 0;
> +       }
> +
> +       if (wolinfo->wolopts & WAKE_PHY)
> +               *opt |= AX_MONITOR_MODE_RWLC;
> +       else
> +               *opt &= ~AX_MONITOR_MODE_RWLC;
> +
> +       if (wolinfo->wolopts & WAKE_MAGIC)
> +               *opt |= AX_MONITOR_MODE_RWMP;
> +       else
> +               *opt &= ~AX_MONITOR_MODE_RWMP;
> +
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MODE, 1, 1, opt);
> +       kfree(opt);
> +
> +       return 0;
> +}
> +
> +static int ax88179_get_eeprom_len(struct net_device *net)
> +{
> +       return AX_EEPROM_LEN;
> +}
> +
> +static int ax88179_get_eeprom(struct net_device *net,
> +                             struct ethtool_eeprom *eeprom, u8 *data)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       u16 *ebuf = (u16 *)data;
> +       int i;
> +
> +       /* Crude hack to ensure that we don't overwrite memory
> +        * if an odd length is supplied
> +        */
> +       if (eeprom->len % 2)
> +               return -EINVAL;
> +
> +       /* ax8817x returns 2 bytes from eeprom on read */
> +       for (i = 0; i < eeprom->len / 2; i++) {
> +               if (ax88179_read_cmd(dev, AX_ACCESS_EEPROM,
> +                       eeprom->offset + i, 1, 2, &ebuf[i]) < 0)
> +                       return -EINVAL;
> +       }
> +       return 0;
> +}
> +
> +static int ax88179_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       return mii_ethtool_gset(&dev->mii, cmd);
> +}
> +
> +static int ax88179_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       return mii_ethtool_sset(&dev->mii, cmd);
> +}
> +
> +
> +static int ax88179_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
> +}
> +
> +static struct ethtool_ops ax88179_ethtool_ops = {
> +       .get_link               = ethtool_op_get_link,
> +       .get_msglevel           = usbnet_get_msglevel,
> +       .set_msglevel           = usbnet_set_msglevel,
> +       .get_wol                = ax88179_get_wol,
> +       .set_wol                = ax88179_set_wol,
> +       .get_eeprom_len         = ax88179_get_eeprom_len,
> +       .get_eeprom             = ax88179_get_eeprom,
> +       .get_settings           = ax88179_get_settings,
> +       .set_settings           = ax88179_set_settings,
> +       .nway_reset             = usbnet_nway_reset,
> +};
> +
> +static void ax88179_set_multicast(struct net_device *net)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       struct ax88179_data *data = (struct ax88179_data *)dev->data;
> +       u8 *m_filter = ((u8 *)dev->data) + 12;
> +       u16 rx_ctl = (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_CTL_IPE);
> +       int mc_count;
> +
> +       mc_count = netdev_mc_count(net);
> +
> +       if (net->flags & IFF_PROMISC) {
> +               rx_ctl |= AX_RX_CTL_PRO;
> +       } else if (net->flags & IFF_ALLMULTI
> +                  || mc_count > AX_MAX_MCAST) {
> +               rx_ctl |= AX_RX_CTL_AMALL;
> +       } else if (mc_count == 0) {
> +               /* just broadcast and directed */
> +       } else {
> +               /* We use the 20 byte dev->data for our 8 byte filter buffer
> +                * to avoid allocating memory that is tricky to free later
> +                */
> +               u32 crc_bits;
> +               struct netdev_hw_addr *ha;
> +               memset(m_filter, 0, AX_MCAST_FILTER_SIZE);
> +               netdev_for_each_mc_addr(ha, net) {
> +                       crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
> +                       *(m_filter + (crc_bits >> 3)) |=
> +                               1 << (crc_bits & 7);
> +               }
> +
> +               ax88179_write_cmd_async(dev, AX_ACCESS_MAC,
> +                       AX_MULTI_FILTER_ARRY, AX_MCAST_FILTER_SIZE,
> +                                       AX_MCAST_FILTER_SIZE, m_filter);
> +
> +               rx_ctl |= AX_RX_CTL_AM;
> +       }
> +
> +       data->rxctl = rx_ctl;
> +       ax88179_write_cmd_async(dev, AX_ACCESS_MAC,
> +                                       AX_RX_CTL, 2, 2, &data->rxctl);
> +}
> +
> +static struct net_device_stats *ax88179_get_stats(struct net_device *net)
> +{
> +       return &net->stats;
> +}
> +
> +static int
> +ax88179_set_features(struct net_device *net, netdev_features_t features)
> +{
> +       u8 *tmp;
> +       struct usbnet *dev = netdev_priv(net);
> +       netdev_features_t changed = net->features ^ features;
> +
> +       tmp = kmalloc(1, GFP_KERNEL);

Same with above.

> +       if (!tmp)
> +               return -ENOMEM;
> +
> +       if (changed & NETIF_F_TSO)
> +               net->features ^= NETIF_F_TSO;
> +
> +       if (changed & NETIF_F_SG)
> +               net->features ^= NETIF_F_SG;
> +
> +       if (changed & NETIF_F_IP_CSUM) {
> +
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +               *tmp ^= AX_TXCOE_TCP | AX_TXCOE_UDP;
> +
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +               net->features ^= NETIF_F_IP_CSUM;
> +       }
> +
> +       if (changed & NETIF_F_IPV6_CSUM) {
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +               *tmp ^= AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6;
> +
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +               net->features ^= NETIF_F_IPV6_CSUM;
> +       }
> +
> +       if (changed & NETIF_F_RXCSUM) {
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_RXCOE_CTL, 1, 1, tmp);
> +
> +               *tmp ^= AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
> +                               AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> +
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RXCOE_CTL, 1, 1, tmp);
> +
> +               net->features ^= NETIF_F_RXCSUM;
> +       }
> +
> +       kfree(tmp);
> +
> +       return 0;
> +}
> +
> +static int ax88179_set_mac_addr(struct net_device *net, void *p)
> +{
> +       struct usbnet *dev = netdev_priv(net);
> +       struct sockaddr *addr = p;
> +
> +       memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
> +
> +       /* Set the MAC address */
> +       return ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
> +                                               ETH_ALEN, net->dev_addr);
> +}
> +
> +static const struct net_device_ops ax88179_netdev_ops = {
> +       .ndo_open               = usbnet_open,
> +       .ndo_stop               = usbnet_stop,
> +       .ndo_start_xmit         = usbnet_start_xmit,
> +       .ndo_tx_timeout         = usbnet_tx_timeout,
> +       .ndo_change_mtu         = usbnet_change_mtu,
> +       .ndo_get_stats          = ax88179_get_stats,
> +       .ndo_set_mac_address    = ax88179_set_mac_addr,
> +       .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_do_ioctl           = ax88179_ioctl,
> +       .ndo_set_rx_mode        = ax88179_set_multicast,
> +       .ndo_set_features       = ax88179_set_features,
> +};
> +
> +static int ax88179_check_eeprom(struct usbnet *dev, int flags)
> +{
> +       u8 i;
> +       u8 buf;
> +       u8 *eeprom;
> +       u16 csum, delay = HZ / 10;
> +       unsigned long jtimeout;
> +
> +       eeprom = kmalloc(20, flags);

Same with above, also I am wondering if the 'flags' parameter is needed
since ax88179_write_cmd() should be called only in process context.

> +       if (!eeprom)
> +               return -ENOMEM;
> +
> +       /* Read EEPROM content */
> +       for (i = 0; i < 6; i++) {
> +               buf = i;
> +               if (ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                                       AX_SROM_ADDR, 1, 1, &buf) < 0) {
> +                       kfree(eeprom);
> +                       return -EINVAL;
> +               }
> +
> +               buf = EEP_RD;
> +               if (ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                                       AX_SROM_CMD, 1, 1, &buf) < 0) {
> +                       kfree(eeprom);
> +                       return -EINVAL;
> +               }
> +
> +               jtimeout = jiffies + delay;
> +               do {
> +                       ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                                               AX_SROM_CMD, 1, 1, &buf);
> +
> +                       if (time_after(jiffies, jtimeout)) {
> +                               kfree(eeprom);
> +                               return -EINVAL;
> +                       }
> +               } while (buf & EEP_BUSY);
> +
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_DATA_LOW, 2, 2, eeprom + (i * 2));
> +
> +               if ((i == 0) && (*eeprom == 0xFF)) {
> +                       kfree(eeprom);
> +                       return -EINVAL;
> +               }
> +       }
> +
> +       csum = *(eeprom + 6) + *(eeprom + 7) + *(eeprom + 8) + *(eeprom + 9);
> +       csum = (csum >> 8) + (csum & 0xff);
> +
> +       if ((csum + *(eeprom + 10)) != 0xff) {
> +               kfree(eeprom);
> +               return -EINVAL;
> +       }
> +
> +       kfree(eeprom);
> +       return 0;
> +}
> +
> +static int ax88179_check_efuse(struct usbnet *dev, u16 *ledmode, int flags)
> +{
> +       u8      i;
> +       u8      *efuse;
> +       u16     csum = 0;
> +
> +       efuse = kzalloc(64, flags);

Same with above.

> +       if (!efuse)
> +               return -ENOMEM;
> +
> +       if (ax88179_read_cmd(dev, AX_ACCESS_EFUSE, 0, 64, 64, efuse) < 0) {
> +               kfree(efuse);
> +               return -EINVAL;
> +       }
> +
> +       if (*efuse == 0xFF) {
> +               kfree(efuse);
> +               return -EINVAL;
> +       }
> +
> +       for (i = 0; i < 64; i++)
> +               csum = csum + *(efuse + i);
> +
> +       while (csum > 255)
> +               csum = (csum & 0x00FF) + ((csum >> 8) & 0x00FF);
> +
> +       if (csum != 0xFF) {
> +               kfree(efuse);
> +               return -EINVAL;
> +       }
> +
> +       memcpy((u8 *)ledmode, efuse + 51, 2);
> +       kfree(efuse);
> +       return 0;
> +
> +}
> +
> +static int ax88179_convert_old_led(struct usbnet *dev, u8 efuse, u16 *ledvalue)
> +{
> +       u16 led;
> +
> +       /* Loaded the old eFuse LED Mode */
> +       if (efuse) {
> +               if (ax88179_read_cmd(dev, AX_ACCESS_EFUSE,
> +                                       0x18, 1, 2, &led) < 0)
> +                       return -EINVAL;
> +               led &= 0xFF;
> +       } else {
> +               if (ax88179_read_cmd(dev, AX_ACCESS_EEPROM,
> +                                       0x3C, 1, 2, &led) < 0)
> +                       return -EINVAL;
> +               led >>= 8;
> +       }
> +
> +       switch (led) {
> +       case 0xFF:
> +               led = LED0_ACTIVE | LED1_LINK_10 | LED1_LINK_100 |
> +                       LED1_LINK_1000 | LED2_ACTIVE | LED2_LINK_10 |
> +                       LED2_LINK_100 | LED2_LINK_1000 | LED_VALID;
> +               break;
> +       case 0xFE:
> +               led = LED0_ACTIVE | LED1_LINK_1000 | LED2_LINK_100 | LED_VALID;
> +               break;
> +       case 0xFD:
> +               led = LED0_ACTIVE | LED1_LINK_1000 | LED2_LINK_100 |
> +                       LED2_LINK_10 | LED_VALID;
> +               break;
> +       case 0xFC:
> +               led = LED0_ACTIVE | LED1_ACTIVE | LED1_LINK_1000 | LED2_ACTIVE |
> +                               LED2_LINK_100 | LED2_LINK_10 | LED_VALID;
> +               break;
> +       default:
> +               led = LED0_ACTIVE | LED1_LINK_10 | LED1_LINK_100 |
> +                       LED1_LINK_1000 | LED2_ACTIVE | LED2_LINK_10 |
> +                       LED2_LINK_100 | LED2_LINK_1000 | LED_VALID;
> +               break;
> +       }
> +
> +       memcpy((u8 *)ledvalue, &led, 2);
> +       return 0;
> +}
> +
> +static int ax88179_led_setting(struct usbnet *dev, int flags)
> +{
> +       u8 ledfd, value = 0;
> +       u16 tmp, ledact, ledlink, ledvalue = 0, delay = HZ / 10;
> +       unsigned long jtimeout;
> +
> +       /* Check AX88179 version. UA1 or UA2*/
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, GENERAL_STATUS, 1, 1, &value);
> +
> +       if (!(value & AX_SECLD)) {      /* UA1 */
> +               value = AX_GPIO_CTRL_GPIO3EN | AX_GPIO_CTRL_GPIO2EN |
> +                                       AX_GPIO_CTRL_GPIO1EN;
> +               if (ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_GPIO_CTRL, 1, 1, &value) < 0)
> +                       return -EINVAL;
> +       }
> +
> +       /* Check EEPROM */
> +       if (!ax88179_check_eeprom(dev, flags)) {
> +               value = 0x42;
> +               if (ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_ADDR, 1, 1, &value) < 0)
> +                       return -EINVAL;
> +
> +               value = EEP_RD;
> +               if (ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_CMD, 1, 1, &value) < 0)
> +                       return -EINVAL;
> +
> +               jtimeout = jiffies + delay;
> +               do {
> +                       ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_CMD, 1, 1, &value);
> +
> +                       if (time_after(jiffies, jtimeout))
> +                               return -EINVAL;
> +               } while (value & EEP_BUSY);
> +
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_DATA_HIGH, 1, 1, &value);
> +               ledvalue = (value << 8);
> +               ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                               AX_SROM_DATA_LOW, 1, 1, &value);
> +               ledvalue |= value;
> +
> +               /* load internal ROM for defaule setting */
> +               if ((ledvalue == 0xFFFF) || ((ledvalue & LED_VALID) == 0))
> +                       ax88179_convert_old_led(dev, 0, &ledvalue);
> +       }
> +
> +       /* Check eFuse */
> +       else if (!ax88179_check_efuse(dev, &ledvalue, flags)) {
> +               if ((ledvalue == 0xFFFF) || ((ledvalue & LED_VALID) == 0))
> +                       ax88179_convert_old_led(dev, 0, &ledvalue);
> +       } else
> +               ax88179_convert_old_led(dev, 0, &ledvalue);
> +
> +       tmp = GMII_PHY_PGSEL_EXT;
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_PHY_PAGE_SELECT, 2, &tmp);
> +
> +       tmp = 0x2c;
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_PHYPAGE, 2, &tmp);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_LED_ACTIVE, 2, &ledact);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_LED_LINK, 2, &ledlink);
> +
> +       ledact &= GMII_LED_ACTIVE_MASK;
> +       ledlink &= GMII_LED_LINK_MASK;
> +
> +
> +       if (ledvalue & LED0_ACTIVE)
> +               ledact |= GMII_LED0_ACTIVE;
> +
> +       if (ledvalue & LED1_ACTIVE)
> +               ledact |= GMII_LED1_ACTIVE;
> +
> +       if (ledvalue & LED2_ACTIVE)
> +               ledact |= GMII_LED2_ACTIVE;
> +
> +       if (ledvalue & LED0_LINK_10)
> +               ledlink |= GMII_LED0_LINK_10;
> +
> +       if (ledvalue & LED1_LINK_10)
> +               ledlink |= GMII_LED1_LINK_10;
> +
> +       if (ledvalue & LED2_LINK_10)
> +               ledlink |= GMII_LED2_LINK_10;
> +
> +       if (ledvalue & LED0_LINK_100)
> +               ledlink |= GMII_LED0_LINK_100;
> +
> +       if (ledvalue & LED1_LINK_100)
> +               ledlink |= GMII_LED1_LINK_100;
> +
> +       if (ledvalue & LED2_LINK_100)
> +               ledlink |= GMII_LED2_LINK_100;
> +
> +       if (ledvalue & LED0_LINK_1000)
> +               ledlink |= GMII_LED0_LINK_1000;
> +
> +       if (ledvalue & LED1_LINK_1000)
> +               ledlink |= GMII_LED1_LINK_1000;
> +
> +       if (ledvalue & LED2_LINK_1000)
> +               ledlink |= GMII_LED2_LINK_1000;
> +
> +
> +       tmp = ledact;
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_LED_ACTIVE, 2, &tmp);
> +
> +       tmp = ledlink;
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_LED_LINK, 2, &tmp);
> +
> +       tmp = GMII_PHY_PGSEL_PAGE0;
> +       ax88179_write_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                               GMII_PHY_PAGE_SELECT, 2, &tmp);
> +
> +       /* LED full duplex setting */
> +       ledfd = 0;
> +       if (ledvalue & LED0_FD)
> +               ledfd |= 0x01;
> +       else if ((ledvalue & LED0_USB3_MASK) == 0)
> +               ledfd |= 0x02;
> +
> +       if (ledvalue & LED1_FD)
> +               ledfd |= 0x04;
> +       else if ((ledvalue & LED1_USB3_MASK) == 0)
> +               ledfd |= 0x08;
> +
> +       if (ledvalue & LED2_FD)
> +               ledfd |= 0x10;
> +       else if ((ledvalue & LED2_USB3_MASK) == 0)
> +               ledfd |= 0x20;
> +
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_LEDCTRL, 1, 1, &ledfd);
> +       return 0;
> +}
> +
> +static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +       void *buf;
> +       u16 *tmp16;
> +       u8 *tmp;
> +       struct ax88179_data *ax179_data =
> +                       (struct ax88179_data *)dev->data;
> +
> +       usbnet_get_endpoints(dev, intf);
> +
> +       buf = kmalloc(6, GFP_KERNEL);

Same with above.

> +       if (!buf) {
> +               netdev_err(dev->net, "Cannot allocate memory for buffer");
> +               return -ENOMEM;
> +       }
> +       tmp16 = (u16 *)buf;
> +       tmp = (u8 *)buf;
> +
> +       memset(ax179_data, 0, sizeof(*ax179_data));
> +
> +       /* Power up ethernet PHY */
> +       *tmp16 = 0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       *tmp16 = AX_PHYPWR_RSTCTL_IPRL;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       msleep(200);
> +
> +       *tmp = AX_CLK_SELECT_ACS | AX_CLK_SELECT_BCS;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
> +       msleep(100);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN, ETH_ALEN,
> +                                               dev->net->dev_addr);
> +       memcpy(dev->net->perm_addr, dev->net->dev_addr, ETH_ALEN);
> +
> +       /* RX bulk configuration */
> +       memcpy(tmp, &AX88179_BULKIN_SIZE[0], 5);
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_BULKIN_QCTRL, 5, 5, tmp);
> +       dev->rx_urb_size = 1024 * 20;
> +
> +       *tmp = 0x34;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_LOW, 1, 1, tmp);
> +
> +       *tmp = 0x52;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                       AX_PAUSE_WATERLVL_HIGH, 1, 1, tmp);
> +
> +       dev->net->hard_header_len += 12;
> +       dev->net->netdev_ops = &ax88179_netdev_ops;
> +       dev->net->ethtool_ops = &ax88179_ethtool_ops;
> +       dev->net->needed_headroom = 8;
> +
> +       /* Initialize MII structure */
> +       dev->mii.dev = dev->net;
> +       dev->mii.mdio_read = ax88179_mdio_read;
> +       dev->mii.mdio_write = ax88179_mdio_write;
> +       dev->mii.phy_id_mask = 0xff;
> +       dev->mii.reg_num_mask = 0xff;
> +       dev->mii.phy_id = 0x03;
> +       dev->mii.supports_gmii = 1;
> +
> +       dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +                       NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
> +
> +       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +                       NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
> +
> +       /* Enable checksum offload */
> +       *tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
> +                               AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RXCOE_CTL, 1, 1, tmp);
> +
> +       *tmp = AX_TXCOE_IP | AX_TXCOE_TCP | AX_TXCOE_UDP |
> +                               AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +       /* Configure RX control register => start operation */
> +       *tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
> +                       AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, 0x0b, 2, 2, tmp16);
> +
> +       *tmp = AX_MONITOR_MODE_PMETYPE | AX_MONITOR_MODE_PMEPOL |
> +                                               AX_MONITOR_MODE_RWMP;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MODE, 1, 1, tmp);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MODE, 1, 1, tmp);
> +
> +       /* Configure default medium type => giga */
> +       *tmp16 = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
> +                AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE |
> +                AX_MEDIUM_FULL_DUPLEX | AX_MEDIUM_GIGAMODE;
> +
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_MEDIUM_STATUS_MODE, 2, 2, tmp16);
> +
> +       ax88179_led_setting(dev, GFP_KERNEL);
> +
> +       /* Restart autoneg */
> +       mii_nway_restart(&dev->mii);
> +
> +       netif_carrier_off(dev->net);
> +       kfree(buf);
> +       return 0;
> +}
> +
> +static void ax88179_unbind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +       u16 tmp16;
> +
> +       /* Configure RX control register => stop operation */
> +       tmp16 = AX_RX_CTL_STOP;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, &tmp16);
> +
> +       tmp16 = 0x0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                       AX_CLK_SELECT, 1, 1, &tmp16);
> +
> +       /* Power down ethernet PHY */
> +       tmp16 = 0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                       AX_PHYPWR_RSTCTL, 2, 2, &tmp16);
> +}
> +
> +static void
> +ax88179_rx_checksum(struct sk_buff *skb, struct ax88179_rx_pkt_header *pkt_hdr)
> +{
> +       skb->ip_summed = CHECKSUM_NONE;
> +
> +       /* checksum error bit is set */
> +       if (pkt_hdr->l3_csum_err || pkt_hdr->l4_csum_err)
> +               return;
> +
> +       /* It must be a TCP or UDP packet with a valid checksum */
> +       if ((pkt_hdr->l4_type == AX_RXHDR_L4_TYPE_TCP) ||
> +           (pkt_hdr->l4_type == AX_RXHDR_L4_TYPE_UDP))
> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
> +}
> +
> +static int ax88179_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> +{
> +       struct sk_buff *ax_skb;
> +       int pkt_cnt;
> +       u32 rx_hdr;
> +       u16 hdr_off;
> +       struct ax88179_rx_pkt_header *pkt_hdr;
> +
> +       skb_trim(skb, skb->len - 4);
> +       memcpy(&rx_hdr, skb_tail_pointer(skb), sizeof(rx_hdr));
> +       le32_to_cpus(&rx_hdr);
> +
> +       pkt_cnt = (u16)rx_hdr;
> +       hdr_off = (u16)(rx_hdr >> 16);
> +       pkt_hdr = (struct ax88179_rx_pkt_header *)(skb->data + hdr_off);
> +
> +       while (pkt_cnt--) {
> +
> +               u16 pkt_len;
> +
> +               le32_to_cpus((u32 *)pkt_hdr);
> +               pkt_len = pkt_hdr->len;
> +
> +               /* Check CRC or runt packet */
> +               if (pkt_hdr->crc || pkt_hdr->drop) {
> +                       skb_pull(skb, (pkt_len + 7) & 0xFFF8);
> +                       pkt_hdr++;
> +                       continue;
> +               }
> +
> +               if (pkt_cnt == 0) {
> +                       /* Skip IP alignment psudo header */
> +                       skb_pull(skb, 2);
> +
> +                       skb->len = pkt_len;
> +
> +                       skb_set_tail_pointer(skb, pkt_len);
> +
> +                       skb->truesize = pkt_len + sizeof(struct sk_buff);
> +
> +                       ax88179_rx_checksum(skb, pkt_hdr);
> +
> +                       return 2;
> +               }
> +
> +               ax_skb = skb_clone(skb, GFP_ATOMIC);
> +               if (ax_skb) {
> +                       ax_skb->len = pkt_len;
> +                       ax_skb->data = skb->data + 2;
> +
> +                       skb_set_tail_pointer(ax_skb, pkt_len);
> +
> +                       ax_skb->truesize = pkt_len + sizeof(struct sk_buff);
> +
> +                       ax88179_rx_checksum(ax_skb, pkt_hdr);
> +
> +                       usbnet_skb_return(dev, ax_skb);
> +               } else {
> +                       return 0;
> +               }
> +
> +               skb_pull(skb, (pkt_len + 7) & 0xFFF8);
> +               pkt_hdr++;
> +       }
> +       return 0;
> +}
> +
> +static struct sk_buff *
> +ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
> +{
> +       u32 tx_hdr1, tx_hdr2;
> +       int frame_size = dev->maxpacket;
> +       int mss = skb_shinfo(skb)->gso_size;
> +       int headroom;
> +       int tailroom;
> +
> +       tx_hdr1 = skb->len;
> +       tx_hdr2 = mss;
> +       if (((skb->len + 8) % frame_size) == 0) {
> +               tx_hdr2 |= 0x80008000;  /* Enable padding */
> +               skb->len += 2;
> +       }
> +
> +       skb_linearize(skb);
> +       headroom = skb_headroom(skb);
> +       tailroom = skb_tailroom(skb);
> +
> +       if (!skb_header_cloned(skb) && !skb_cloned(skb) &&
> +                               (headroom + tailroom) >= 8) {
> +               if (headroom < 8) {
> +                       skb->data = memmove(skb->head + 8, skb->data, skb->len);
> +                       skb_set_tail_pointer(skb, skb->len);
> +               }
> +       } else {
> +               struct sk_buff *skb2;
> +               skb2 = skb_copy_expand(skb, 8, 0, flags);
> +               dev_kfree_skb_any(skb);
> +               skb = skb2;
> +               if (!skb)
> +                       return NULL;
> +       }
> +
> +       skb_push(skb, 4);
> +       cpu_to_le32s(&tx_hdr2);
> +
> +       skb_copy_to_linear_data(skb, &tx_hdr2, 4);
> +
> +       skb_push(skb, 4);
> +       cpu_to_le32s(&tx_hdr1);
> +
> +       skb_copy_to_linear_data(skb, &tx_hdr1, 4);
> +
> +       return skb;
> +}
> +
> +static int ax88179_link_reset(struct usbnet *dev)
> +{
> +       struct ax88179_data *ax179_data = (struct ax88179_data *)dev->data;
> +       u8 *tmp, link_sts;
> +       u16 mode, tmp16, delay = HZ / 10;
> +       u32 tmp32 = 0x40000000;
> +       unsigned long jtimeout;
> +
> +       jtimeout = jiffies + delay;
> +
> +       while (tmp32 & 0x40000000) {
> +               mode = 0;
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_RX_CTL, 2, 2, &mode);
> +               ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_RX_CTL, 2, 2, &ax179_data->rxctl);
> +
> +               /*link up, check the usb device control TX FIFO full or empty*/
> +               ax88179_read_cmd(dev, 0x81, 0x8c, 0, 4, &tmp32);
> +
> +               if (time_after(jiffies, jtimeout))
> +                       return 0;
> +       }
> +
> +       mode = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
> +                  AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE;
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                       PHYSICAL_LINK_STATUS, 1, 1, &link_sts);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_PHY, AX88179_PHY_ID,
> +                                       GMII_PHY_PHYSR, 2, &tmp16);
> +
> +       tmp = kmalloc(5, GFP_KERNEL);

Same with above.

> +       if (!tmp)
> +               return -ENOMEM;
> +
> +       if (!(tmp16 & GMII_PHY_PHYSR_LINK)) {
> +               kfree(tmp);
> +               return 0;
> +       } else if (GMII_PHY_PHYSR_GIGA == (tmp16 & GMII_PHY_PHYSR_SMASK)) {
> +               mode |= AX_MEDIUM_GIGAMODE;
> +               if (link_sts & AX_USB_SS)
> +                       memcpy(tmp, &AX88179_BULKIN_SIZE[0], 5);
> +               else if (link_sts & AX_USB_HS)
> +                       memcpy(tmp, &AX88179_BULKIN_SIZE[1], 5);
> +               else
> +                       memcpy(tmp, &AX88179_BULKIN_SIZE[3], 5);
> +       } else if (GMII_PHY_PHYSR_100 == (tmp16 & GMII_PHY_PHYSR_SMASK)) {
> +               mode |= AX_MEDIUM_PS;
> +               if (link_sts & (AX_USB_SS | AX_USB_HS))
> +                       memcpy(tmp, &AX88179_BULKIN_SIZE[2], 5);
> +               else
> +                       memcpy(tmp, &AX88179_BULKIN_SIZE[3], 5);
> +       } else {
> +               memcpy(tmp, &AX88179_BULKIN_SIZE[3], 5);
> +       }
> +
> +       /* RX bulk configuration */
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_BULKIN_QCTRL, 5, 5, tmp);
> +
> +       if (tmp16 & GMII_PHY_PHYSR_FULL)
> +               mode |= AX_MEDIUM_FULL_DUPLEX;
> +
> +       dev->rx_urb_size = (1024 * (*(tmp + 3)));
> +
> +       mode |= 0x08;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +               AX_MEDIUM_STATUS_MODE, 2, 2, &mode);
> +
> +       netif_carrier_on(dev->net);
> +       kfree(tmp);
> +       return 0;
> +}
> +
> +static int ax88179_reset(struct usbnet *dev)
> +{
> +       void *buf;
> +       u16 *tmp16;
> +       u8 *tmp;
> +
> +       buf = kmalloc(6, GFP_KERNEL);
> +       if (!buf)
> +               return -ENOMEM;
> +
> +       tmp16 = (u16 *)buf;
> +       tmp = (u8 *)buf;
> +
> +       /* Power up ethernet PHY */
> +       *tmp16 = 0;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       *tmp16 = AX_PHYPWR_RSTCTL_IPRL;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PHYPWR_RSTCTL, 2, 2, tmp16);
> +       msleep(200);
> +       *tmp = AX_CLK_SELECT_ACS | AX_CLK_SELECT_BCS;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_CLK_SELECT, 1, 1, tmp);
> +       msleep(100);
> +
> +       /* Ethernet PHY Auto Detach*/
> +       ax88179_auto_detach(dev, GFP_KERNEL);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_NODE_ID, ETH_ALEN,
> +                                               ETH_ALEN, dev->net->dev_addr);
> +       memcpy(dev->net->perm_addr, dev->net->dev_addr, ETH_ALEN);
> +
> +       /* RX bulk configuration */
> +       memcpy(tmp, &AX88179_BULKIN_SIZE[0], 5);
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_BULKIN_QCTRL, 5, 5, tmp);
> +
> +       dev->rx_urb_size = 1024 * 20;
> +
> +       *tmp = 0x34;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_PAUSE_WATERLVL_LOW, 1, 1, tmp);
> +
> +       *tmp = 0x52;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                               AX_PAUSE_WATERLVL_HIGH, 1, 1, tmp);
> +
> +       dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +                       NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
> +
> +       dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +                       NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
> +
> +       /* Enable checksum offload */
> +       *tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
> +                               AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RXCOE_CTL, 1, 1, tmp);
> +
> +       *tmp = AX_TXCOE_IP | AX_TXCOE_TCP | AX_TXCOE_UDP |
> +                               AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
> +
> +       /* Configure RX control register => start operation */
> +       *tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
> +                       AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, 0x0b, 2, 2, tmp16);
> +
> +       *tmp = AX_MONITOR_MODE_PMETYPE | AX_MONITOR_MODE_PMEPOL |
> +                                               AX_MONITOR_MODE_RWMP;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MODE, 1, 1, tmp);
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC, AX_MONITOR_MODE, 1, 1, tmp);
> +
> +       /* Configure default medium type => giga */
> +       *tmp16 = AX_MEDIUM_RECEIVE_EN | AX_MEDIUM_TXFLOW_CTRLEN |
> +                AX_MEDIUM_RXFLOW_CTRLEN | AX_MEDIUM_ALWAYS_ONE |
> +                AX_MEDIUM_FULL_DUPLEX | AX_MEDIUM_GIGAMODE;
> +
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                       AX_MEDIUM_STATUS_MODE, 2, 2, tmp16);
> +
> +       ax88179_led_setting(dev, GFP_KERNEL);
> +
> +       /* Restart autoneg */
> +       mii_nway_restart(&dev->mii);
> +
> +       netif_carrier_off(dev->net);
> +
> +       kfree(buf);
> +
> +       return 0;
> +}
> +
> +static int ax88179_stop(struct usbnet *dev)
> +{
> +       u16 tmp16;
> +
> +       ax88179_read_cmd(dev, AX_ACCESS_MAC,
> +                       AX_MEDIUM_STATUS_MODE, 2, 2, &tmp16);
> +       tmp16 &= ~AX_MEDIUM_RECEIVE_EN;
> +       ax88179_write_cmd(dev, AX_ACCESS_MAC,
> +                       AX_MEDIUM_STATUS_MODE, 2, 2, &tmp16);
> +
> +       return 0;
> +}
> +
> +static const struct driver_info ax88179_info = {
> +       .description = "ASIX AX88179 USB 3.0 Gigibit Ethernet",
> +       .bind = ax88179_bind,
> +       .unbind = ax88179_unbind,
> +       .status = ax88179_status,
> +       .link_reset = ax88179_link_reset,
> +       .reset = ax88179_reset,
> +       .stop = ax88179_stop,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX,
> +       .rx_fixup = ax88179_rx_fixup,
> +       .tx_fixup = ax88179_tx_fixup,
> +};
> +
> +static const struct driver_info ax88178a_info = {
> +       .description = "ASIX AX88178A USB 2.0 Gigibit Ethernet",
> +       .bind = ax88179_bind,
> +       .unbind = ax88179_unbind,
> +       .status = ax88179_status,
> +       .link_reset = ax88179_link_reset,
> +       .reset = ax88179_reset,
> +       .stop = ax88179_stop,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX,
> +       .rx_fixup = ax88179_rx_fixup,
> +       .tx_fixup = ax88179_tx_fixup,
> +};
> +
> +static const struct driver_info sitecom_info = {
> +       .description = "Sitecom USB 3.0 to Gigabit Adapter",
> +       .bind = ax88179_bind,
> +       .unbind = ax88179_unbind,
> +       .status = ax88179_status,
> +       .link_reset = ax88179_link_reset,
> +       .reset = ax88179_reset,
> +       .stop = ax88179_stop,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX,
> +       .rx_fixup = ax88179_rx_fixup,
> +       .tx_fixup = ax88179_tx_fixup,
> +};
> +
> +static const struct usb_device_id products[] = {
> +{
> +       /* ASIX AX88179 10/100/1000 */
> +       USB_DEVICE(0x0b95, 0x1790),
> +       .driver_info = (unsigned long)&ax88179_info,
> +}, {
> +       /* ASIX AX88178A 10/100/1000 */
> +       USB_DEVICE(0x0b95, 0x178a),
> +       .driver_info = (unsigned long)&ax88178a_info,
> +}, {
> +       /* Sitecom USB 3.0 to Gigabit Adapter */
> +       USB_DEVICE(0x0df6, 0x0072),
> +       .driver_info = (unsigned long) &sitecom_info,
> +},
> +       { },
> +};
> +MODULE_DEVICE_TABLE(usb, products);
> +
> +static struct usb_driver asix_driver = {
> +       .name =         "ax88179_178a",
> +       .id_table =     products,
> +       .probe =        usbnet_probe,
> +       .suspend =      ax88179_suspend,
> +       .resume =       ax88179_resume,
> +       .disconnect =   usbnet_disconnect,
> +};
> +
> +static int __init asix_init(void)
> +{
> +       return usb_register(&asix_driver);
> +}
> +module_init(asix_init);
> +
> +static void __exit asix_exit(void)
> +{
> +       usb_deregister(&asix_driver);
> +}
> +module_exit(asix_exit);
> +
> +MODULE_DESCRIPTION("ASIX AX88179/178A based USB 3.0/2.0 Gigabit Ethernet Devices");
> +MODULE_LICENSE("GPL");

Thanks,
--
Ming Lei
