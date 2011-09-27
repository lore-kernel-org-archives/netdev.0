From: Taehun Kim <kth3321@gmail.com>
Subject: Re: [PATCH] w5300: add WIZnet W5300 Ethernet driver
Date: Tue, 27 Sep 2011 19:03:42 +0900
Message-ID: <CAOkfWjcHxh60D9KvxLfgL0tw9XdPyDN9xr7q+9V+nM6B6g8tDA@mail.gmail.com>
References: <1316261666-28555-1-git-send-email-kth3321@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316261666-28555-1-git-send-email-kth3321@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/9/17 Taehun Kim <kth3321@gmail.com>:
> WIZnet W5300 is a network chip into which 10/100 Ethernet controller,=
 MAC, and TCP/IP are integrated.
> This driver supports just Ethernet function in W5300.
>
> Signed-off-by: Taehun Kim <kth3321@gmail.com>
> ---
> =A0drivers/net/Kconfig =A0| =A0 =A05 +
> =A0drivers/net/Makefile | =A0 =A01 +
> =A0drivers/net/w5300.c =A0| =A0669 ++++++++++++++++++++++++++++++++++=
++++++++++++++++
> =A0drivers/net/w5300.h =A0| =A0350 ++++++++++++++++++++++++++
> =A04 files changed, 1025 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/w5300.c
> =A0create mode 100644 drivers/net/w5300.h
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 8d0314d..4a8a100 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2016,6 +2016,11 @@ config LANTIQ_ETOP
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0Support for the MII0 inside the Lantiq SoC
>
> +config W5300
> + =A0 =A0 =A0 tristate "WIZnet W5300 ethernet driver"
> + =A0 =A0 =A0 depends on ARM
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This is driver for WIZnet W5300 network chip.
>
> =A0source "drivers/net/fs_enet/Kconfig"
>
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index e1eca2a..288fce1 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -266,6 +266,7 @@ obj-$(CONFIG_XTENSA_XT2000_SONIC) +=3D xtsonic.o
> =A0obj-$(CONFIG_DNET) +=3D dnet.o
> =A0obj-$(CONFIG_MACB) +=3D macb.o
> =A0obj-$(CONFIG_S6GMAC) +=3D s6gmac.o
> +obj-$(CONFIG_W5300) +=3D w5300.o
>
> =A0obj-$(CONFIG_ARM) +=3D arm/
> =A0obj-$(CONFIG_DEV_APPLETALK) +=3D appletalk/
> diff --git a/drivers/net/w5300.c b/drivers/net/w5300.c
> new file mode 100644
> index 0000000..fcc2579
> --- /dev/null
> +++ b/drivers/net/w5300.c
> @@ -0,0 +1,669 @@
> +/* w5300.c: A Linux Ethernet driver for the WIZnet W5300 chip. */
> +/*
> + =A0Copyright (C) 2011 Taehun Kim <kth3321@gmail.com>
> +
> + =A0This software may be used and distributed according to the terms=
 of
> + =A0the GNU General Public License (GPL), incorporated herein by ref=
erence.
> + =A0Drivers based on or derived from this code fall under the GPL an=
d must
> + =A0retain the authorship, copyright and license notice. =A0This fil=
e is not
> + =A0a complete program and may only be used when the entire operatin=
g
> + =A0system is licensed under the GPL.
> +*/
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/delay.h>
> +#include <linux/interrupt.h>
> +#include <linux/irq.h>
> +#include <linux/errno.h>
> +
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +
> +#include <linux/device.h>
> +#include <linux/platform_device.h>
> +#include <linux/ioport.h>
> +#include <linux/io.h>
> +
> +#include "w5300.h"
> +
> +#define DEV_NAME =A0 =A0"w5300"
> +#define DRV_VERSION "1.0"
> +#define DRV_RELDATE "Sept 17, 2011"
> +
> +static const char driver_info[] =3D
> + =A0 =A0 =A0 KERN_INFO DEV_NAME ": Ethernet driver v" DRV_VERSION "(=
"
> + =A0 =A0 =A0 DRV_RELDATE ")\n";
> +
> +MODULE_AUTHOR("Taehun Kim <kth3321@gmail.com>");
> +MODULE_DESCRIPTION("WIZnet W5300 Ethernet driver");
> +MODULE_VERSION(DRV_VERSION);
> +MODULE_LICENSE("GPL");
> +
> +/* Transmit timeout, default 5 seconds. */
> +static int watchdog =3D 5000;
> +module_param(watchdog, int, 0400);
> +MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
> +
> +/*
> + * This is W5300 information structure.
> + * Additional information is included in struct net_device.
> + */
> +struct wiz_private {
> + =A0 =A0 =A0 void __iomem *base;
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 u8 rxbuf_conf[MAX_SOCK_NUM];
> + =A0 =A0 =A0 u8 txbuf_conf[MAX_SOCK_NUM];
> + =A0 =A0 =A0 struct net_device_stats stats;
> + =A0 =A0 =A0 struct napi_struct napi;
> + =A0 =A0 =A0 spinlock_t lock;
> +};
> +
> +/* Default MAC address. */
> +static const u8 w5300_defmac[6] =3D {0x00, 0x08, 0xDC, 0xA0, 0x00, 0=
x01};
> +
> +/* Default RX/TX buffer size(KByte). */
> +static const u8 w5300_rxbuf_conf[MAX_SOCK_NUM] =3D { 64, 0, 0, 0, 0,=
 0, 0, 0 };
> +static const u8 w5300_txbuf_conf[MAX_SOCK_NUM] =3D { 64, 0, 0, 0, 0,=
 0, 0, 0 };
> +
> +/* Notifying packet size in the RX FIFO */
> +static int
> +w5300_get_rxsize(struct wiz_private *wp, int s)
> +{
> + =A0 =A0 =A0 u32 val;
> +
> + =A0 =A0 =A0 val =3D w5300_read(wp, Sn_RX_RSR(s));
> + =A0 =A0 =A0 val =3D (val << 16) + w5300_read(wp, Sn_RX_RSR2(s));
> + =A0 =A0 =A0 return val;
> +}
> +
> +/* Packet Receive Function. It reads received packet from the Rx FIF=
O. */
> +static int
> +w5300_recv_data(struct wiz_private *wp, int s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 *buf, ssize_t len, int swap_enable)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 u16 recv_data;
> +
> + =A0 =A0 =A0 if (unlikely(len <=3D 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (swap_enable) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* read from RX FIFO */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < len; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 recv_data =3D w5300_rea=
d(wp, Sn_RX_FIFO(s));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[i] =3D (u8) ((recv_=
data & 0xFF00) >> 8);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[i + 1] =3D (u8) (re=
cv_data & 0x00FF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < len; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 recv_data =3D w5300_rea=
d(wp, Sn_RX_FIFO(s));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[i] =3D (u8) (recv_d=
ata & 0x00FF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[i + 1] =3D (u8) ((r=
ecv_data & 0xFF00) >> 8);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return len;
> +}
> +
> +/* Setting MAC address of W5300 */
> +static void
> +w5300_set_macaddr(struct wiz_private *wp, u8 * addr)
> +{
> + =A0 =A0 =A0 w5300_write(wp, SHAR, (u16) (addr[0] << 8) | (u16) addr=
[1]);
> + =A0 =A0 =A0 w5300_write(wp, SHAR2, (u16) (addr[2] << 8) | (u16) add=
r[3]);
> + =A0 =A0 =A0 w5300_write(wp, SHAR4, (u16) (addr[4] << 8) | (u16) add=
r[5]);
> +}
> +
> +/* Opening channels of W5300 */
> +static int
> +w5300_open(struct wiz_private *wp, u32 type)
> +{
> + =A0 =A0 =A0 /* Which type will be used for open? */
> + =A0 =A0 =A0 switch (type) {
> + =A0 =A0 =A0 case Sn_MR_MACRAW:
> + =A0 =A0 =A0 case Sn_MR_MACRAW_MF:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, Sn_MR(0), type);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Unknown socket typ=
e (%d)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEV_NAME, type);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 w5300_write(wp, Sn_PORTR(0), 5300);
> +
> + =A0 =A0 =A0 w5300_write(wp, Sn_CR(0), Sn_CR_OPEN);
> + =A0 =A0 =A0 while (w5300_read(wp, Sn_CR(0)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* Activating the interrupt of related channel */
> +static void
> +w5300_interrupt_enable(struct wiz_private *wp, int s)
> +{
> + =A0 =A0 =A0 u16 mask;
> + =A0 =A0 =A0 mask =3D w5300_read(wp, IMR);
> + =A0 =A0 =A0 mask |=3D (0x01 << s);
> + =A0 =A0 =A0 w5300_write(wp, IMR, mask);
> +}
> +
> +/* De-activating the interrupt of related channel */
> +static void
> +w5300_interrupt_disable(struct wiz_private *wp, int s)
> +{
> + =A0 =A0 =A0 u16 mask;
> + =A0 =A0 =A0 mask =3D w5300_read(wp, IMR);
> + =A0 =A0 =A0 mask &=3D ~(0x01 << s);
> + =A0 =A0 =A0 w5300_write(wp, IMR, mask);
> +}
> +
> +/* W5300 initialization function */
> +static int
> +w5300_reset(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 u32 txbuf_total =3D 0, i;
> + =A0 =A0 =A0 u16 mem_cfg =3D 0;
> +
> + =A0 =A0 =A0 DPRINTK("%s: w5300 chip reset\n", __func__);
> +
> + =A0 =A0 =A0 /* W5300 is initialized by sending RESET command. */
> + =A0 =A0 =A0 w5300_write(wp, MR, MR_RST);
> + =A0 =A0 =A0 mdelay(5);
> +
> + =A0 =A0 =A0 /* Mode Register Setting
> + =A0 =A0 =A0 =A0* Ping uses S/W stack of the Linux kernel. Set the P=
ing Block.*/
> + =A0 =A0 =A0 w5300_write(wp, MR, MR_WDF(1) | MR_PB);
> +
> + =A0 =A0 =A0 /* Setting MAC address */
> + =A0 =A0 =A0 w5300_set_macaddr(wp, dev->dev_addr);
> +
> + =A0 =A0 =A0 /* Setting the size of Rx/Tx FIFO */
> + =A0 =A0 =A0 for (i =3D 0; i < MAX_SOCK_NUM; ++i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wp->rxbuf_conf[i] > 64) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Il=
legal Channel(%d) RX memory size.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEV_NAME=
, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wp->txbuf_conf[i] > 64) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Il=
legal Channel(%d) TX memory size.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEV_NAME=
, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 txbuf_total +=3D wp->txbuf_conf[i];
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (txbuf_total % 8) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Illegal memory siz=
e register setting.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEV_NAME);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 w5300_write(wp, RMSR0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->rxbuf_conf[0] << 8) =
| (u16) wp->rxbuf_conf[1]);
> + =A0 =A0 =A0 w5300_write(wp, RMSR2,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->rxbuf_conf[2] << 8) =
| (u16) wp->rxbuf_conf[3]);
> + =A0 =A0 =A0 w5300_write(wp, RMSR4,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->rxbuf_conf[4] << 8) =
| (u16) wp->rxbuf_conf[5]);
> + =A0 =A0 =A0 w5300_write(wp, RMSR6,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->rxbuf_conf[6] << 8) =
| (u16) wp->rxbuf_conf[7]);
> + =A0 =A0 =A0 w5300_write(wp, TMSR0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->txbuf_conf[0] << 8) =
| (u16) wp->txbuf_conf[1]);
> + =A0 =A0 =A0 w5300_write(wp, TMSR2,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->txbuf_conf[2] << 8) =
| (u16) wp->txbuf_conf[3]);
> + =A0 =A0 =A0 w5300_write(wp, TMSR4,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->txbuf_conf[4] << 8) =
| (u16) wp->txbuf_conf[5]);
> + =A0 =A0 =A0 w5300_write(wp, TMSR6,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (u16) (wp->txbuf_conf[6] << 8) =
| (u16) wp->txbuf_conf[7]);
> +
> + =A0 =A0 =A0 /* Setting FIFO Memory Type (TX&RX) */
> + =A0 =A0 =A0 for (i =3D 0; i < txbuf_total / 8; ++i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cfg <<=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cfg |=3D 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 w5300_write(wp, MTYPER, mem_cfg);
> +
> + =A0 =A0 =A0 /* Masking all interrupts */
> + =A0 =A0 =A0 w5300_write(wp, IMR, 0x0000);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* Interrupt Handler(ISR) */
> +static irqreturn_t
> +wiz_interrupt(int irq, void *dev_instance)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D dev_instance;
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned long isr, ssr;
> + =A0 =A0 =A0 int s;
> +
> + =A0 =A0 =A0 isr =3D w5300_read(wp, IR);
> +
> + =A0 =A0 =A0 /* Completing all interrupts at a time. */
> + =A0 =A0 =A0 while (isr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, IR, isr);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Finding the channel to create the in=
terrupt */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D find_first_bit(&isr, sizeof(u16))=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ssr =3D w5300_read(wp, Sn_IR(s));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* socket interrupt is cleared. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, Sn_IR(s), ssr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DPRINTK("%s: ISR =3D %X, SSR =3D %X, s =
=3D %X\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, isr, ssr, s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(!s)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ssr & Sn_IR_RECV) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* De-a=
ctivation of interrupt */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_i=
nterrupt_disable(wp, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Rece=
iving by polling method */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_sc=
hedule(&wp->napi);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Is there any interrupt to be process=
ed? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 isr =3D w5300_read(wp, IR);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
> +
> +static int
> +wiz_open(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 napi_enable(&wp->napi);
> +
> + =A0 =A0 =A0 ret =3D request_irq(dev->irq, wiz_interrupt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IRQF_IRQPOLL, dev->=
name, dev);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: request_irq() erro=
r!\n", DEV_NAME);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Activating the interrupt of channel 0 that is used f=
or MACRAW. */
> + =A0 =A0 =A0 w5300_interrupt_enable(wp, 0);
> +
> + =A0 =A0 =A0 /* Sending OPEN command to use channel 0 as MACRAW mode=
=2E */
> + =A0 =A0 =A0 w5300_open(wp, Sn_MR_MACRAW_MF);
> +
> + =A0 =A0 =A0 netif_start_queue(dev);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int
> +wiz_close(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 DPRINTK("%s\n", __func__);
> +
> + =A0 =A0 =A0 napi_disable(&wp->napi);
> +
> + =A0 =A0 =A0 /* Interrupt masking of all channels */
> + =A0 =A0 =A0 w5300_write(wp, IMR, 0x0000);
> + =A0 =A0 =A0 netif_stop_queue(dev);
> + =A0 =A0 =A0 w5300_write(wp, Sn_CR(0), Sn_CR_CLOSE);
> + =A0 =A0 =A0 free_irq(dev->irq, dev);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int
> +w5300_send_data(struct wiz_private *wp, u8 * buf, ssize_t len)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 u16 send_data;
> +
> + =A0 =A0 =A0 /* Writing packets in to Tx FIFO */
> + =A0 =A0 =A0 for (i =3D 0; i < len; i +=3D 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 send_data =3D (buf[i] << 8) | buf[i+1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, Sn_TX_FIFO(0), send_dat=
a);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 w5300_write(wp, Sn_TX_WRSR(0), (u16)(len >> 16));
> + =A0 =A0 =A0 w5300_write(wp, Sn_TX_WRSR2(0), (u16)len);
> + =A0 =A0 =A0 w5300_write(wp, Sn_CR(0), Sn_CR_SEND);
> + =A0 =A0 =A0 while (w5300_read(wp, Sn_CR(0)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(1);
> +
> + =A0 =A0 =A0 return len;
> +}
> +
> +/* Function to transmit data at the MACRAW mode */
> +static int
> +wiz_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 DPRINTK("%s: MAC_RAW SEND packet size =3D %d\n", __func=
__, skb->len);
> +
> + =A0 =A0 =A0 ret =3D w5300_send_data(wp, skb->data, skb->len);
> +
> + =A0 =A0 =A0 /* Statistical Process */
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.tx_dropped++;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.tx_bytes +=3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.tx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->trans_start =3D jiffies;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 dev_kfree_skb(skb);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct net_device_stats *
> +wiz_get_stats(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 DPRINTK("%s: get status\n", __func__);
> + =A0 =A0 =A0 return &wp->stats;
> +}
> +
> +/* It is called when multi-cast list or flag is changed. */
> +static void
> +wiz_set_multicast(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 DPRINTK("%s: multicast\n", __func__);
> + =A0 =A0 =A0 if (dev->flags & IFF_PROMISC)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_open(wp, Sn_MR_MACRAW);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_open(wp, Sn_MR_MACRAW_MF);
> +}
> +
> +static int
> +wiz_set_mac_address(struct net_device *dev, void *addr)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct sockaddr *sock_addr =3D addr;
> +
> + =A0 =A0 =A0 DPRINTK("%s: set mac address\n", __func__);
> +
> + =A0 =A0 =A0 spin_lock(&wp->lock);
> + =A0 =A0 =A0 /* Changing MAC address of W5300 */
> + =A0 =A0 =A0 w5300_set_macaddr(wp, sock_addr->sa_data);
> + =A0 =A0 =A0 /* Changing MAC address of material structure to manage=
 W5300 */
> + =A0 =A0 =A0 memcpy(dev->dev_addr, sock_addr->sa_data, dev->addr_len=
);
> + =A0 =A0 =A0 spin_unlock(&wp->lock);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void
> +wiz_tx_timeout(struct net_device *dev)
> +{
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 printk(KERN_WARNING "%s: Transmit timeout\n", dev->name=
);
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&wp->lock, flags);
> + =A0 =A0 =A0 /* Initializing W5300 chip. */
> + =A0 =A0 =A0 w5300_reset(dev);
> + =A0 =A0 =A0 /* Waking up network interface */
> + =A0 =A0 =A0 netif_wake_queue(dev);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&wp->lock, flags);
> +}
> +
> +/*
> + * Polling Function to process only receiving at the MACRAW mode.
> + * De-activating the interrupt when recv interrupt occurs,
> + * and processing the RECEIVE with this Function
> + * Activating the interrupt after completing RECEIVE process
> + * As recv interrupt often occurs at short intervals,
> + * there will system load in case that interrupt handler process the=
 RECEIVE.
> + */
> +static int
> +wiz_rx_poll(struct napi_struct *napi, int budget)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 struct wiz_private *wp =3D container_of(napi, struct wi=
z_private, napi);
> + =A0 =A0 =A0 struct net_device *dev =3D wp->dev;
> + =A0 =A0 =A0 u16 rxbuf_len, pktlen;
> + =A0 =A0 =A0 u32 crc;
> + =A0 =A0 =A0 int npackets =3D 0;
> +
> + =A0 =A0 =A0 /* Processing the RECEIVE during Rx FIFO is containing =
any packet */
> + =A0 =A0 =A0 while (w5300_get_rxsize(wp, 0) > 0) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The first 2byte is the information a=
bout packet lenth. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_recv_data(wp, 0, (u8 *)&pktlen, 2=
, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DPRINTK("%s: pktlen =3D %d\n", __func__=
, pktlen);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Allotting the socket buffer in whi=
ch packet will be contained
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Ethernet packet is of 14byte.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* In order to make it multiplied by =
2, the buffer allocation
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* should be 2bytes bigger than the p=
acket.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(pktlen + 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 *temp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "%s: Me=
mory squeeze, dropping packet.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->nam=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 temp =3D kmalloc(pktlen=
 + 4, GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.rx_dropped++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_recv_data(wp, 0, =
temp, pktlen + 4, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(temp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Initializing the socket buffer */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_put(skb, pktlen);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Reading packets from W5300 Rx FIFO i=
nto socket buffer. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_recv_data(wp, 0, (u8 *)skb->data,=
 pktlen, 1);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Reading and discarding 4byte CRC. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_recv_data(wp, 0, (u8 *)&crc, 4, 0=
);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The packet type is Ethernet. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_type_trans(skb, d=
ev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Passing packets to uppder stack (ker=
nel). */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_receive_skb(skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Processing statistical information *=
/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.rx_packets++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->stats.rx_bytes +=3D pktlen;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wp->dev->last_rx =3D jiffies;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxbuf_len -=3D pktlen;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 npackets++;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (npackets >=3D budget)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* If packet number is smaller than budget when getting=
 out of loopback,
> + =A0 =A0 =A0 =A0* the RECEIVE process is completed. */
> + =A0 =A0 =A0 if (npackets < budget) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&wp->lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_interrupt_enable(wp, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_complete(napi);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&wp->lock, flags=
);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return npackets;
> +}
> +
> +static const struct net_device_ops wiz_netdev_ops =3D {
> + =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =3D wiz_open,
> + =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =3D wiz_close,
> + =A0 =A0 =A0 .ndo_validate_addr =A0 =A0 =A0=3D eth_validate_addr,
> + =A0 =A0 =A0 .ndo_set_mac_address =A0 =A0=3D wiz_set_mac_address,
> + =A0 =A0 =A0 .ndo_set_multicast_list =3D wiz_set_multicast,
> + =A0 =A0 =A0 .ndo_get_stats =A0 =A0 =A0=3D wiz_get_stats,
> + =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =3D wiz_start_xmit,
> + =A0 =A0 =A0 .ndo_tx_timeout =A0 =A0 =3D wiz_tx_timeout,
> +};
> +
> +/* Initialize W5300 driver. */
> +static int __devinit
> +w5300_drv_probe(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 struct net_device *dev;
> + =A0 =A0 =A0 struct wiz_private *wp;
> + =A0 =A0 =A0 struct resource *res;
> + =A0 =A0 =A0 void __iomem *addr;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> + =A0 =A0 =A0 if (!res) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =A0=3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Request the chip register regions. */
> + =A0 =A0 =A0 if (!request_mem_region(res->start, SZ_1M, DEV_NAME)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Allocatting struct net_device structure which is man=
aging W5300 */
> + =A0 =A0 =A0 dev =3D alloc_etherdev(sizeof(struct wiz_private));
> + =A0 =A0 =A0 if (!dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto release_region;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev->dma =3D (unsigned char)-1;
> + =A0 =A0 =A0 dev->irq =3D platform_get_irq(pdev, 0);
> + =A0 =A0 =A0 wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 wp->dev =3D dev;
> + =A0 =A0 =A0 addr =3D ioremap(res->start, SZ_1M);
> + =A0 =A0 =A0 if (!addr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto release_both;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 platform_set_drvdata(pdev, dev);
> + =A0 =A0 =A0 wp->base =3D addr;
> +
> + =A0 =A0 =A0 spin_lock_init(&wp->lock);
> +
> + =A0 =A0 =A0 /* Initialization of Rx/Tx FIFO size */
> + =A0 =A0 =A0 memcpy(wp->rxbuf_conf, w5300_rxbuf_conf, MAX_SOCK_NUM *=
 sizeof(u8));
> + =A0 =A0 =A0 memcpy(wp->txbuf_conf, w5300_txbuf_conf, MAX_SOCK_NUM *=
 sizeof(u8));
> +
> + =A0 =A0 =A0 dev->base_addr =3D res->start;
> + =A0 =A0 =A0 dev->addr_len =3D 6; =A0 =A0 =A0/* MAC address length. =
*/
> + =A0 =A0 =A0 memcpy(dev->dev_addr, w5300_defmac, dev->addr_len);
> +
> + =A0 =A0 =A0 ether_setup(dev);
> + =A0 =A0 =A0 dev->netdev_ops =3D &wiz_netdev_ops;
> + =A0 =A0 =A0 /* Setting napi. Enabling to process max 16 packets at =
a time. */
> + =A0 =A0 =A0 netif_napi_add(dev, &wp->napi, wiz_rx_poll, 16);
> +
> + =A0 =A0 =A0 dev->watchdog_timeo =3D msecs_to_jiffies(watchdog);
> +
> + =A0 =A0 =A0 strcpy(dev->name, "eth%d");
> +
> + =A0 =A0 =A0 w5300_reset(dev);
> +
> + =A0 =A0 =A0 ret =3D register_netdev(dev);
> + =A0 =A0 =A0 if (ret !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 platform_set_drvdata(pdev, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(addr);
> +release_both:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_netdev(dev);
> +release_region:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_resource(res);
> + =A0 =A0 =A0 }
> +out:
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int __devexit
> +w5300_drv_remove(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
> + =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct resource *res;
> +
> + =A0 =A0 =A0 platform_set_drvdata(pdev, NULL);
> + =A0 =A0 =A0 unregister_netdev(dev);
> +
> + =A0 =A0 =A0 if (wp->base !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(wp->base);
> +
> + =A0 =A0 =A0 res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> + =A0 =A0 =A0 if (res !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_resource(res);
> +
> + =A0 =A0 =A0 free_netdev(dev);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int
> +w5300_drv_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
> +
> + =A0 =A0 =A0 if (dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(=
dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_running(dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_device_detach(dev=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, IMR, 0x=
0000);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_write(wp, Sn_CR(0=
), Sn_CR_CLOSE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int
> +w5300_drv_resume(struct platform_device *pdev)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
> +
> + =A0 =A0 =A0 if (dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct wiz_private *wp =3D netdev_priv(=
dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_running(dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_reset(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_interrupt_enable(=
wp, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 w5300_open(wp, Sn_MR_MA=
CRAW_MF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_device_attach(dev=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct platform_driver w5300_driver =3D {
> + =A0 =A0 =A0 .probe =A0=3D w5300_drv_probe,
> + =A0 =A0 =A0 .remove =3D __devexit_p(w5300_drv_remove),
> + =A0 =A0 =A0 .suspend =A0 =A0 =A0 =A0 =3D w5300_drv_suspend,
> + =A0 =A0 =A0 .resume =A0=3D w5300_drv_resume,
> + =A0 =A0 =A0 .driver =A0=3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0=3D DEV_NAME,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 },
> +};
> +
> +static int __init
> +wiz_module_init(void)
> +{
> + =A0 =A0 =A0 return platform_driver_register(&w5300_driver);
> +}
> +
> +static void __exit
> +wiz_module_exit(void)
> +{
> + =A0 =A0 =A0 platform_driver_unregister(&w5300_driver);
> +}
> +
> +module_init(wiz_module_init);
> +module_exit(wiz_module_exit);
> diff --git a/drivers/net/w5300.h b/drivers/net/w5300.h
> new file mode 100644
> index 0000000..d8583be
> --- /dev/null
> +++ b/drivers/net/w5300.h
> @@ -0,0 +1,350 @@
> +#ifndef =A0 =A0 =A0 =A0_W5300_H_
> +#define =A0 =A0 =A0 =A0_W5300_H_
> +
> +/* Maximum socket number. W5300 supports max 8 channels. */
> +#define MAX_SOCK_NUM 8
> +#ifdef W5300_DEBUG
> +#define DPRINTK(format, args...) printk(format, ##args)
> +#else
> +#define DPRINTK(format, args...)
> +#endif
> +
> +/* socket register */
> +#define CH_BASE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x200)
> +
> +/* size of each channel register map */
> +#define CH_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x40
> +
> +/* Mode Register address */
> +#define MR =A0 =A0 =A0 =A0 =A0 =A0 (0)
> +#define MR1 =A0 =A0 =A0 =A0 =A0 =A0(MR + 1)
> +
> +#define IDM_AR =A0 =A0 =A0 =A0 (0x02)
> +#define IDM_AR1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(IDM_AR + 1)
> +
> +#define IDM_DR =A0 =A0 =A0 =A0 (0x04)
> +#define IDM_DR1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(IDM_DR + 1)
> +
> +/* Interrupt Register */
> +#define IR =A0 =A0 =A0 =A0 =A0 =A0 (0x02)
> +#define IR1 =A0 =A0 =A0 =A0 =A0 =A0(IR + 1);
> +
> +/* =A0Interrupt mask register */
> +#define IMR =A0 =A0 =A0 =A0 =A0 =A0(0x04)
> +#define IMR1 =A0 (IMR + 1)
> +
> +/* Interrupt mask register */
> +#define STAR =A0 =A0 =A0 =A0 =A0 (0x06)
> +#define STAR1 =A0 =A0 =A0 =A0 =A0(STAR + 1)
> +
> +/* =A0Source MAC Register address */
> +#define SHAR =A0 =A0 =A0 =A0 =A0 (0x08)
> +#define SHAR1 =A0 =A0 =A0 =A0 =A0(SHAR + 1)
> +#define SHAR2 =A0 =A0 =A0 =A0 =A0(SHAR + 2)
> +#define SHAR3 =A0 =A0 =A0 =A0 =A0(SHAR + 3)
> +#define SHAR4 =A0 =A0 =A0 =A0 =A0(SHAR + 4)
> +#define SHAR5 =A0 =A0 =A0 =A0 =A0(SHAR + 5)
> +
> +/* Gateway IP Register address */
> +#define GAR =A0 =A0 =A0 =A0 =A0 =A0(0x10)
> +#define GAR1 =A0 =A0 =A0 =A0 =A0 (GAR + 1)
> +#define GAR2 =A0 =A0 =A0 =A0 =A0 (GAR + 2)
> +#define GAR3 =A0 =A0 =A0 =A0 =A0 (GAR + 3)
> +
> +/* Subnet mask Register address */
> +#define SUBR =A0 =A0 =A0 =A0 =A0 (0x14)
> +#define SUBR1 =A0 =A0 =A0 =A0 =A0(SUBR + 1)
> +#define SUBR2 =A0 =A0 =A0 =A0 =A0(SUBR + 2)
> +#define SUBR3 =A0 =A0 =A0 =A0 =A0(SUBR + 3)
> +
> +/* Source IP Register address */
> +#define SIPR =A0 =A0 =A0 =A0 =A0 (0x18)
> +#define SIPR1 =A0 =A0 =A0 =A0 =A0(SIPR + 1)
> +#define SIPR2 =A0 =A0 =A0 =A0 =A0(SIPR + 2)
> +#define SIPR3 =A0 =A0 =A0 =A0 =A0(SIPR + 3)
> +
> +/* Timeout register address(1 is 100us) */
> +#define RTR =A0 =A0 =A0 =A0 =A0 =A0(0x1C)
> +#define RTR1 =A0 =A0 =A0 =A0 =A0 (RTR + 1)
> +
> +/* Retry count reigster */
> +#define RCR =A0 =A0 =A0 =A0 =A0 =A0(0x1E)
> +#define RCR1 =A0 =A0 =A0 =A0 =A0 (RCR + 1)
> +
> +/* Transmit memory size reigster */
> +#define TMSR0 =A0 =A0 =A0 =A0 =A0(0x20)
> +#define TMSR1 =A0 =A0 =A0 =A0 =A0(TMSR0 + 1)
> +#define TMSR2 =A0 =A0 =A0 =A0 =A0(TMSR0 + 2)
> +#define TMSR3 =A0 =A0 =A0 =A0 =A0(TMSR0 + 3)
> +#define TMSR4 =A0 =A0 =A0 =A0 =A0(TMSR0 + 4)
> +#define TMSR5 =A0 =A0 =A0 =A0 =A0(TMSR0 + 5)
> +#define TMSR6 =A0 =A0 =A0 =A0 =A0(TMSR0 + 6)
> +#define TMSR7 =A0 =A0 =A0 =A0 =A0(TMSR0 + 7)
> +
> +#define TMSR_01 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x20)
> +#define TMSR_23 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(TMSR_01 + 2)
> +#define TMSR_45 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(TMSR_01 + 4)
> +#define TMSR_67 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(TMSR_01 + 6)
> +
> +/* Receive memory size reigster */
> +#define RMSR0 =A0 =A0 =A0 =A0 =A0(0x28)
> +#define RMSR1 =A0 =A0 =A0 =A0 =A0(RMSR0 + 1)
> +#define RMSR2 =A0 =A0 =A0 =A0 =A0(RMSR0 + 2)
> +#define RMSR3 =A0 =A0 =A0 =A0 =A0(RMSR0 + 3)
> +#define RMSR4 =A0 =A0 =A0 =A0 =A0(RMSR0 + 4)
> +#define RMSR5 =A0 =A0 =A0 =A0 =A0(RMSR0 + 5)
> +#define RMSR6 =A0 =A0 =A0 =A0 =A0(RMSR0 + 6)
> +#define RMSR7 =A0 =A0 =A0 =A0 =A0(RMSR0 + 7)
> +
> +#define RMSR_01 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(0x28)
> +#define RMSR_23 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(RMSR_01 + 2)
> +#define RMSR_45 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(RMSR_01 + 4)
> +#define RMSR_67 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(RMSR_01 + 6)
> +
> +/* Memory Type Register
> + * '1' - TX memory
> + * '0' - RX memory */
> +#define MTYPER =A0 =A0 =A0 =A0 (0x30)
> +#define MYYPER1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(MTYPER + 1)
> +
> +/* Authentication type register address in PPPoE mode */
> +#define PATR =A0 =A0 =A0 =A0 =A0 (0x32)
> +#define PATR1 =A0 =A0 =A0 =A0 =A0(PATR + 1)
> +
> +#define PTIMER =A0 =A0 =A0 =A0 (0x36)
> +#define PTIMER1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(PTIMER + 1)
> +
> +#define PMAGIC =A0 =A0 =A0 =A0 (0x38)
> +#define PMAGIC1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(PMAGIC + 1)
> +
> +/* PPPoE session ID register */
> +#define PSIDR =A0 =A0 =A0 =A0 =A0 (0x3C)
> +#define PSIDR1 =A0 =A0 =A0 =A0 =A0(PSIDR + 1)
> +
> +/* PPPoE destination hardware address register */
> +#define PDHAR =A0 =A0 =A0 =A0 =A0 (0x40)
> +#define PDHAR0 =A0 =A0 =A0 =A0 =A0PDHAR
> +#define PDHAR1 =A0 =A0 =A0 =A0 =A0(PDHAR + 1)
> +#define PDHAR2 =A0 =A0 =A0 =A0 =A0(PDHAR + 2)
> +#define PDHAR3 =A0 =A0 =A0 =A0 =A0(PDHAR + 3)
> +#define PDHAR4 =A0 =A0 =A0 =A0 =A0(PDHAR + 4)
> +#define PDHAR5 =A0 =A0 =A0 =A0 =A0(PDHAR + 5)
> +
> +/* Unreachable IP register address in UDP mode */
> +#define UIPR =A0 =A0 =A0 =A0 =A0 (0x48)
> +#define UIPR1 =A0 =A0 =A0 =A0 =A0(UIPR + 1)
> +#define UIPR2 =A0 =A0 =A0 =A0 =A0(UIPR + 2)
> +#define UIPR3 =A0 =A0 =A0 =A0 =A0(UIPR + 3)
> +
> +/* Unreachable Port register address in UDP mode */
> +#define UPORT =A0 =A0 =A0 =A0 =A0(0x4C)
> +#define UPORT1 =A0 =A0 =A0 =A0 (UPORT + 1)
> +
> +/* Fragment register */
> +#define FMTUR =A0 =A0 =A0 =A0 =A0(0x4E)
> +#define FMTUR1 =A0 =A0 =A0 =A0 (FMTUR + 1)
> +
> +/* PIN 'BRDYn' configure register */
> +#define Pn_BRDYR(n) =A0 =A0 (0x60 + n*4)
> +#define Pn_BRDYR1(n) =A0 =A0(Pn_BRDYR(n) + 1)
> +
> +/* PIN 'BRDYn' buffer depth register */
> +#define Pn_BDPTHR(n) =A0 =A0(0x62 + n*4)
> +#define Pn_BDPTHR1(n) =A0 (Pn_BDPTHR(n) + 1)
> +
> +/* Chip ID register(=3D0x5300) */
> +#define IDR =A0 =A0 =A0 =A0 =A0 =A0(0xFE)
> +#define IDR1 =A0 =A0 =A0 =A0 =A0 (IDR + 1)
> +
> +/* socket Mode register */
> +#define Sn_MR(ch) =A0 =A0 =A0(CH_BASE + ch * CH_SIZE + 0x00)
> +#define Sn_MR1(ch) =A0 =A0 (Sn_MR(ch)+1)
> +
> +/* socket command register */
> +#define Sn_CR(ch) =A0 =A0 =A0(CH_BASE + ch * CH_SIZE + 0x02)
> +#define Sn_CR1(ch) =A0 =A0 (Sn_CR(ch)+1);
> +
> +/* socket interrupt mask register */
> +#define Sn_IMR(ch) =A0 =A0 (CH_BASE + ch * CH_SIZE + 0x04)
> +#define Sn_IMR1(ch) =A0 =A0(Sn_IMR(ch)+1)
> +
> +/* socket interrupt register */
> +#define Sn_IR(ch) =A0 =A0 =A0(CH_BASE + ch * CH_SIZE + 0x06)
> +#define Sn_IR1(ch) =A0 =A0 (Sn_IR(ch)+1)
> +
> +/* socket status register */
> +#define Sn_SSR(ch) =A0 =A0 (CH_BASE + ch * CH_SIZE + 0x08)
> +#define Sn_SSR1(ch) =A0 =A0(Sn_SSR(ch)+1);
> +
> +/* source port register */
> +#define Sn_PORTR(ch) =A0 (CH_BASE + ch * CH_SIZE + 0x0A)
> +#define Sn_PORTR1(ch) =A0(Sn_PORTR(ch)+1)
> +
> +/* Peer MAC register address */
> +#define Sn_DHAR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x0C)
> +#define Sn_DHAR1(ch) =A0 (Sn_DHAR(ch)+1)
> +#define Sn_DHAR2(ch) =A0 (Sn_DHAR(ch)+2)
> +#define Sn_DHAR3(ch) =A0 (Sn_DHAR(ch)+3)
> +#define Sn_DHAR4(ch) =A0 (Sn_DHAR(ch)+4)
> +#define Sn_DHAR5(ch) =A0 (Sn_DHAR(ch)+5)
> +
> +/* Peer port register address */
> +#define Sn_DPORTR(ch) =A0(CH_BASE + ch * CH_SIZE + 0x12)
> +#define Sn_DPORTR1(ch) (Sn_DPORTR(ch)+1)
> +
> +/* Peer IP register address */
> +#define Sn_DIPR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x14)
> +#define Sn_DIPR1(ch) =A0 (Sn_DIPR(ch)+1)
> +#define Sn_DIPR2(ch) =A0 (Sn_DIPR(ch)+2)
> +#define Sn_DIPR3(ch) =A0 (Sn_DIPR(ch)+3)
> +
> +/* Maximum Segment Size(Sn_MSSR0) register address */
> +#define Sn_MSSR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x18)
> +#define Sn_MSSR1(ch) =A0 (Sn_MSSR(ch)+1)
> +
> +/* Protocol of IP Header field register in IP raw mode */
> +#define Sn_PROTOR(ch) =A0(CH_BASE + ch * CH_SIZE + 0x1A)
> +#define Sn_PROTOR1(ch) (Sn_PROTOR(ch)+1)
> +
> +/* Socket keep alive timer register */
> +#define Sn_KPALVTR(ch) =A0Sn_PROTOR(ch)
> +
> +/* IP Type of Service(TOS) Register */
> +#define Sn_TOSR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x1C)
> +#define Sn_TOSR1(ch) =A0 (Sn_TOSR(ch)+1)
> +
> +/* IP Time to live(TTL) Register */
> +#define Sn_TTLR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x1E)
> +#define Sn_TTLR1(ch) =A0 (Sn_TTLR(ch)+1)
> +
> +/* Transmit Size Register (Byte count) */
> +#define Sn_TX_WRSR(ch) (CH_BASE + ch * CH_SIZE + 0x20)
> +#define Sn_TX_WRSR1(ch) =A0 =A0 =A0 =A0(Sn_TX_WRSR(ch) + 1)
> +#define Sn_TX_WRSR2(ch) =A0 =A0 =A0 =A0(Sn_TX_WRSR(ch) + 2)
> +#define Sn_TX_WRSR3(ch) =A0 =A0 =A0 =A0(Sn_TX_WRSR(ch) + 3)
> +
> +/* Transmit free memory size register (Byte count) */
> +#define Sn_TX_FSR(ch) =A0(CH_BASE + ch * CH_SIZE + 0x24)
> +#define Sn_TX_FSR1(ch) (Sn_TX_FSR(ch) + 1)
> +#define Sn_TX_FSR2(ch) (Sn_TX_FSR(ch) + 2)
> +#define Sn_TX_FSR3(ch) (Sn_TX_FSR(ch) + 3)
> +
> +/* Received data size register (Byte count) */
> +#define Sn_RX_RSR(ch) =A0(CH_BASE + ch * CH_SIZE + 0x28)
> +#define Sn_RX_RSR1(ch) (Sn_RX_RSR(ch) + 1)
> +#define Sn_RX_RSR2(ch) (Sn_RX_RSR(ch) + 2)
> +#define Sn_RX_RSR3(ch) (Sn_RX_RSR(ch) + 3)
> +
> +/* Socket fragment register */
> +#define Sn_FRAGR(ch) =A0 =A0(CH_BASE + ch * CH_SIZE + 0x2C)
> +#define Sn_FRAGR1(ch) =A0 (Sn_FRAGR(ch) + 1)
> +
> +/* FIFO register for Transmit */
> +#define Sn_TX_FIFO(ch) (CH_BASE + ch * CH_SIZE + 0x2E)
> +#define Sn_TX_FIFO1(ch) =A0 =A0 =A0 =A0(Sn_TX_FIFO(ch) + 1)
> +
> +/* FIFO register for Receive */
> +#define Sn_RX_FIFO(ch) (CH_BASE + ch * CH_SIZE + 0x30)
> +#define Sn_RX_FIFO1(ch) =A0 =A0 =A0 =A0(Sn_RX_FIFO(ch) + 1)
> +
> +/* MODE register values */
> +#define MR_DBW =A0 =A0(1 << 15) /**< Data bus width bit of MR. */
> +#define MR_MPF =A0 =A0(1 << 14) /**< Mac layer pause frame bit of MR=
=2E */
> +#define MR_WDF(x) ((x & 0x07) << 11) /**< Write data fetch time bit =
of =A0MR. */
> +#define MR_RDH =A0 =A0(1 << 10) /**< Read data hold time bit of MR. =
*/
> +#define MR_FS =A0 =A0 (1 << 8) =A0/**< FIFO swap bit of MR. */
> +#define MR_RST =A0 =A0(1 << 7) =A0/**< S/W reset bit of MR. */
> +#define MR_MT =A0 =A0 (1 << 5) =A0/**< Memory test bit of MR. */
> +#define MR_PB =A0 =A0 (1 << 4) =A0/**< Ping block bit of MR. */
> +#define MR_PPPoE =A0(1 << 3) =A0/**< PPPoE bit of MR. */
> +#define MR_DBS =A0 =A0(1 << 2) =A0/**< Data bus swap of MR. */
> +#define MR_IND =A0 =A0(1 << 0) =A0/**< Indirect mode bit of MR. */
> +
> +/* IR register values */
> +#define IR_IPCF =A0 =A0 (1 << 7) =A0 /**< IP conflict bit of IR. */
> +#define IR_DPUR =A0 =A0 (1 << 6) =A0 /**< Destination port unreachab=
le bit of IR. */
> +#define IR_PPPT =A0 =A0 (1 << 5) =A0 /**< PPPoE terminate bit of IR.=
 */
> +#define IR_FMTU =A0 =A0 (1 << 4) =A0 /**< Fragment MTU bit of IR. */
> +#define IR_SnINT(n) (0x01 << n) =A0 =A0 =A0 =A0/**< SOCKETn interrup=
t occurrence bit of IR. */
> +
> +/* Pn_BRDYR values */
> +#define Pn_PEN =A0 =A0 =A0(1 << 7) =A0 /**< PIN 'BRDYn' enable bit o=
f Pn_BRDYR. */
> +#define Pn_MT =A0 =A0 =A0 (1 << 6) =A0 /**< PIN memory type bit of P=
n_BRDYR. */
> +#define Pn_PPL =A0 =A0 =A0(1 << 5) =A0 /**< PIN Polarity bit of Pn_B=
RDYR. */
> +#define Pn_SN(n) =A0 =A0((n & 0x07) << 0) =A0/**< PIN Polarity bit o=
f Pn_BRDYR. */
> +
> +/* Sn_MR values */
> +#define Sn_MR_ALIGN =A0 =A0 (1 << 8) =A0/**< Alignment bit of Sn_MR.=
 */
> +#define Sn_MR_MULTI =A0 =A0 (1 << 7) =A0/**< Multicasting bit of Sn_=
MR. */
> +#define Sn_MR_MF =A0 =A0 =A0 =A0(1 << 6) =A0/**< MAC filter bit of S=
n_MR. */
> +#define Sn_MR_IGMPv =A0 =A0 (1 << 5) =A0/**< IGMP version bit of Sn_=
MR. */
> +#define Sn_MR_ND =A0 =A0 =A0 =A0(1 << 5) =A0/**< No delayed ack bit =
of Sn_MR. */
> +#define Sn_MR_CLOSE =A0 =A0 0x00 =A0 =A0 /**< Protocol bits of Sn_MR=
=2E */
> +#define Sn_MR_TCP =A0 =A0 =A0 0x01 =A0 =A0 /**< Protocol bits of Sn_=
MR. */
> +#define Sn_MR_UDP =A0 =A0 =A0 0x02 =A0 =A0 /**< Protocol bits of Sn_=
MR. */
> +#define Sn_MR_IPRAW =A0 =A0 0x03 =A0 =A0 /**< Protocol bits of Sn_MR=
=2E */
> +#define Sn_MR_MACRAW =A0 =A00x04 =A0 =A0 /**< Protocol bits of Sn_MR=
=2E */
> +#define Sn_MR_MACRAW_MF 0x44 =A0 =A0 /**< Protocol bits of Sn_MR =A0=
*/
> +#define Sn_MR_PPPoE =A0 =A0 0x05 =A0 =A0 /**< Protocol bits of Sn_MR=
=2E */
> +
> +/* Sn_CR values */
> +#define Sn_CR_OPEN =A0 =A0 =A00x01 =A0 /**< OPEN command value of Sn=
_CR. */
> +#define Sn_CR_LISTEN =A0 =A00x02 =A0 /**< LISTEN command value of Sn=
_CR. */
> +#define Sn_CR_CONNECT =A0 0x04 =A0 /**< CONNECT command value of Sn_=
CR. */
> +#define Sn_CR_DISCON =A0 =A00x08 =A0 /**< DISCONNECT command value o=
f Sn_CR. */
> +#define Sn_CR_CLOSE =A0 =A0 0x10 =A0 /**< CLOSE command value of Sn_=
CR. */
> +#define Sn_CR_SEND =A0 =A0 =A00x20 =A0 /**< SEND command value of Sn=
_CR. */
> +#define Sn_CR_SEND_MAC =A00x21 =A0 /**< SEND_MAC command value of Sn=
_CR. */
> +#define Sn_CR_SEND_KEEP 0x22 =A0 /**< SEND_KEEP command value of Sn_=
CR */
> +#define Sn_CR_RECV =A0 =A0 =A00x40 =A0 /**< RECV command value of Sn=
_CR */
> +#define Sn_CR_PCON =A0 =A0 =A00x23 =A0 /**< PCON command value of Sn=
_CR */
> +#define Sn_CR_PDISCON =A0 0x24 =A0 /**< PDISCON command value of Sn_=
CR */
> +#define Sn_CR_PCR =A0 =A0 =A0 0x25 =A0 /**< PCR command value of Sn_=
CR */
> +#define Sn_CR_PCN =A0 =A0 =A0 0x26 =A0 /**< PCN command value of Sn_=
CR */
> +#define Sn_CR_PCJ =A0 =A0 =A0 0x27 =A0 /**< PCJ command value of Sn_=
CR */
> +
> +/* Sn_IR values */
> +#define Sn_IR_PRECV =A0 =A0 0x80 =A0 /**< PPP receive bit of Sn_IR *=
/
> +#define Sn_IR_PFAIL =A0 =A0 0x40 =A0 /**< PPP fail bit of Sn_IR */
> +#define Sn_IR_PNEXT =A0 =A0 0x20 =A0 /**< PPP next phase bit of Sn_I=
R */
> +#define Sn_IR_SENDOK =A0 =A00x10 =A0 /**< Send OK bit of Sn_IR */
> +#define Sn_IR_TIMEOUT =A0 0x08 =A0 /**< Timout bit of Sn_IR */
> +#define Sn_IR_RECV =A0 =A0 =A00x04 =A0 /**< Receive bit of Sn_IR */
> +#define Sn_IR_DISCON =A0 =A00x02 =A0 /**< Disconnect bit of Sn_IR */
> +#define Sn_IR_CON =A0 =A0 =A0 0x01 =A0 /**< Connect bit of Sn_IR */
> +
> +/* Sn_SSR values */
> +#define SOCK_CLOSED =A0 =A0 =A00x00 =A0/**< SOCKETn is released */
> +#define SOCK_ARP =A0 =A0 =A0 =A0 0x01 =A0/**< ARP-request is transmi=
tted in order to acquire destination hardware address. */
> +#define SOCK_INIT =A0 =A0 =A0 =A00x13 =A0/**< SOCKETn is open as TCP=
 mode. */
> +#define SOCK_LISTEN =A0 =A0 =A00x14 =A0/**< SOCKETn operates as "TCP=
 SERVER" and waits for connection-request (SYN packet) from "TCP CLIENT=
". */
> +#define SOCK_SYNSENT =A0 =A0 0x15 =A0/**< Connect-request(SYN packet=
) is transmitted to "TCP SERVER". */
> +#define SOCK_SYNRECV =A0 =A0 0x16 =A0/**< Connect-request(SYN packet=
) is received from "TCP CLIENT". */
> +#define SOCK_ESTABLISHED 0x17 =A0/**< TCP connection is established.=
 */
> +#define SOCK_FIN_WAIT =A0 =A00x18 =A0/**< SOCKETn is closing. */
> +#define SOCK_CLOSING =A0 =A0 0x1A =A0/**< SOCKETn is closing. */
> +#define SOCK_TIME_WAIT =A0 0x1B =A0/**< SOCKETn is closing. */
> +#define SOCK_CLOSE_WAIT =A00x1C =A0/**< Disconnect-request(FIN packe=
t) is received from the peer. */
> +#define SOCK_LAST_ACK =A0 =A00x1D =A0/**< SOCKETn is closing. */
> +#define SOCK_UDP =A0 =A0 =A0 =A0 0x22 =A0/**< SOCKETn is open as UDP=
 mode. */
> +#define SOCK_IPRAW =A0 =A0 =A0 0x32 =A0/**< SOCKETn is open as IPRAW=
 mode. */
> +#define SOCK_MACRAW =A0 =A0 =A00x42 =A0/**< SOCKET0 is open as MACRA=
W mode. */
> +#define SOCK_PPPoE =A0 =A0 =A0 0x5F =A0/**< SOCKET0 is open as PPPoE=
 mode. */
> +
> +/* IP PROTOCOL */
> +#define IPPROTO_IP =A0 =A0 0 =A0 =A0 =A0 /* Dummy for IP */
> +#define IPPROTO_ICMP =A0 1 =A0 =A0 =A0 /* Control message protocol *=
/
> +#define IPPROTO_IGMP =A0 2 =A0 =A0 =A0 /* Internet group management =
protocol */
> +#define IPPROTO_GGP =A0 =A03 =A0 =A0 =A0 /* Gateway^2 (deprecated) *=
/
> +#define IPPROTO_TCP =A0 =A06 =A0 =A0 =A0 /* TCP */
> +#define IPPROTO_PUP =A0 =A012 =A0 =A0 =A0/* PUP */
> +#define IPPROTO_UDP =A0 =A017 =A0 =A0 =A0/* UDP */
> +#define IPPROTO_IDP =A0 =A022 =A0 =A0 =A0/* XNS idp */
> +#define IPPROTO_ND =A0 =A0 77 =A0 =A0 =A0/* UNOFFICIAL net disk prot=
ocol */
> +#define IPPROTO_RAW =A0 =A0255 =A0 =A0 /* Raw IP packet */
> +
> +/* W5300 Register READ/WRITE funtions(Just 16 bit interface). */
> +#define w5300_write(wp, addr, val) writew(val, (wp->base + addr))
> +#define w5300_read(wp, addr) readw((wp->base + addr))
> +
> +#endif /* _W5300_H_ */
> --
> 1.7.1
>
>

Hi.

Please check this patch. Not only it had been finished testing, but
also confirmed by WIZnet(http://wiznet.co.kr).

If any problems, please let me know.

Best Regards,

Taehun Kim.
