From: Frederic LAMBERT <frdrc66@gmail.com>
Subject: Re: [PATCH] Micrel KS8995MA 5-ports 10/100 managed Ethernet switch
 support added
Date: Sat, 24 Dec 2011 09:44:11 +0100
Message-ID: <CAMVnO+=LETvD+ec-+98au6jupHP5j0e6_=CLNwJLbva+6eq-kw@mail.gmail.com>
References: <1324229621-2054-1-git-send-email-frdrc66@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gabor Juhos <juhosg@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56755 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1LXIoN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 03:44:13 -0500
Received: by ghbg21 with SMTP id g21so800346ghb.19
        for <netdev@vger.kernel.org>; Sat, 24 Dec 2011 00:44:13 -0800 (PST)
In-Reply-To: <1324229621-2054-1-git-send-email-frdrc66@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is something still wrong with this driver or is it acceptable in this
state, now?

2011/12/18 Frederic LAMBERT <frdrc66@gmail.com>
>
> Signed-off-by: Gabor Juhos <juhosg@openwrt.org>
> Signed-off-by: Frederic Lambert <frdrc66@gmail.com>
> ---
> =A0drivers/net/phy/Kconfig =A0 =A0 =A0| =A0 =A05 +
> =A0drivers/net/phy/Makefile =A0 =A0 | =A0 =A01 +
> =A0drivers/net/phy/spi_ks8995.c | =A0376 ++++++++++++++++++++++++++++=
++++++++++++++
> =A03 files changed, 382 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/net/phy/spi_ks8995.c
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index a702443..050f069 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -131,3 +131,8 @@ config MDIO_OCTEON
> =A0 =A0 =A0 =A0 =A0If in doubt, say Y.
>
> =A0endif # PHYLIB
> +
> +config MICREL_KS8995MA
> + =A0 =A0 =A0 tristate "Micrel KS8995MA 5-ports 10/100 managed Ethern=
et switch"
> + =A0 =A0 =A0 depends on SPI
> +
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 2333215..e15c83f 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -23,3 +23,4 @@ obj-$(CONFIG_DP83640_PHY) =A0 =A0 +=3D dp83640.o
> =A0obj-$(CONFIG_STE10XP) =A0 =A0 =A0 =A0 =A0+=3D ste10Xp.o
> =A0obj-$(CONFIG_MICREL_PHY) =A0 =A0 =A0 +=3D micrel.o
> =A0obj-$(CONFIG_MDIO_OCTEON) =A0 =A0 =A0+=3D mdio-octeon.o
> +obj-$(CONFIG_MICREL_KS8995MA) =A0+=3D spi_ks8995.o
> diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks899=
5.c
> new file mode 100644
> index 0000000..e9ce085
> --- /dev/null
> +++ b/drivers/net/phy/spi_ks8995.c
> @@ -0,0 +1,376 @@
> +/*
> + * SPI driver for Micrel/Kendin KS8995M ethernet switch
> + *
> + * Copyright (C) 2008 Gabor Juhos <juhosg at openwrt.org>
> + *
> + * This file was based on: drivers/spi/at25.c
> + * =A0 =A0 Copyright (C) 2006 David Brownell
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify it
> + * under the terms of the GNU General Public License version 2 as pu=
blished
> + * by the Free Software Foundation.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/delay.h>
> +#include <linux/device.h>
> +
> +#include <linux/spi/spi.h>
> +
> +#define DRV_VERSION =A0 =A0 =A0 =A0 =A0 =A0"0.1.1"
> +#define DRV_DESC =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Micrel KS8995 Ethernet=
 switch SPI driver"
> +
> +/* -----------------------------------------------------------------=
------- */
> +
> +#define KS8995_REG_ID0 =A0 =A0 =A0 =A0 0x00 =A0 =A0/* Chip ID0 */
> +#define KS8995_REG_ID1 =A0 =A0 =A0 =A0 0x01 =A0 =A0/* Chip ID1 */
> +
> +#define KS8995_REG_GC0 =A0 =A0 =A0 =A0 0x02 =A0 =A0/* Global Control=
 0 */
> +#define KS8995_REG_GC1 =A0 =A0 =A0 =A0 0x03 =A0 =A0/* Global Control=
 1 */
> +#define KS8995_REG_GC2 =A0 =A0 =A0 =A0 0x04 =A0 =A0/* Global Control=
 2 */
> +#define KS8995_REG_GC3 =A0 =A0 =A0 =A0 0x05 =A0 =A0/* Global Control=
 3 */
> +#define KS8995_REG_GC4 =A0 =A0 =A0 =A0 0x06 =A0 =A0/* Global Control=
 4 */
> +#define KS8995_REG_GC5 =A0 =A0 =A0 =A0 0x07 =A0 =A0/* Global Control=
 5 */
> +#define KS8995_REG_GC6 =A0 =A0 =A0 =A0 0x08 =A0 =A0/* Global Control=
 6 */
> +#define KS8995_REG_GC7 =A0 =A0 =A0 =A0 0x09 =A0 =A0/* Global Control=
 7 */
> +#define KS8995_REG_GC8 =A0 =A0 =A0 =A0 0x0a =A0 =A0/* Global Control=
 8 */
> +#define KS8995_REG_GC9 =A0 =A0 =A0 =A0 0x0b =A0 =A0/* Global Control=
 9 */
> +
> +#define KS8995_REG_PC(p, r) =A0 =A0((0x10 * p) + r) =A0 =A0 =A0 =A0 =
/* Port Control */
> +#define KS8995_REG_PS(p, r) =A0 =A0((0x10 * p) + r + 0xe) =A0/* Port=
 Status */
> +
> +#define KS8995_REG_TPC0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x60 =A0 =A0/=
* TOS Priority Control 0 */
> +#define KS8995_REG_TPC1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x61 =A0 =A0/=
* TOS Priority Control 1 */
> +#define KS8995_REG_TPC2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x62 =A0 =A0/=
* TOS Priority Control 2 */
> +#define KS8995_REG_TPC3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x63 =A0 =A0/=
* TOS Priority Control 3 */
> +#define KS8995_REG_TPC4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x64 =A0 =A0/=
* TOS Priority Control 4 */
> +#define KS8995_REG_TPC5 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x65 =A0 =A0/=
* TOS Priority Control 5 */
> +#define KS8995_REG_TPC6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x66 =A0 =A0/=
* TOS Priority Control 6 */
> +#define KS8995_REG_TPC7 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x67 =A0 =A0/=
* TOS Priority Control 7 */
> +
> +#define KS8995_REG_MAC0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x68 =A0 =A0/=
* MAC address 0 */
> +#define KS8995_REG_MAC1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x69 =A0 =A0/=
* MAC address 1 */
> +#define KS8995_REG_MAC2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6a =A0 =A0/=
* MAC address 2 */
> +#define KS8995_REG_MAC3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6b =A0 =A0/=
* MAC address 3 */
> +#define KS8995_REG_MAC4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6c =A0 =A0/=
* MAC address 4 */
> +#define KS8995_REG_MAC5 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6d =A0 =A0/=
* MAC address 5 */
> +
> +#define KS8995_REG_IAC0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6e =A0 =A0/=
* Indirect Access Control 0 */
> +#define KS8995_REG_IAC1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x6f =A0 =A0/=
* Indirect Access Control 0 */
> +#define KS8995_REG_IAD7 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x70 =A0 =A0/=
* Indirect Access Data 7 */
> +#define KS8995_REG_IAD6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x71 =A0 =A0/=
* Indirect Access Data 6 */
> +#define KS8995_REG_IAD5 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x72 =A0 =A0/=
* Indirect Access Data 5 */
> +#define KS8995_REG_IAD4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x73 =A0 =A0/=
* Indirect Access Data 4 */
> +#define KS8995_REG_IAD3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x74 =A0 =A0/=
* Indirect Access Data 3 */
> +#define KS8995_REG_IAD2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x75 =A0 =A0/=
* Indirect Access Data 2 */
> +#define KS8995_REG_IAD1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x76 =A0 =A0/=
* Indirect Access Data 1 */
> +#define KS8995_REG_IAD0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x77 =A0 =A0/=
* Indirect Access Data 0 */
> +
> +#define KS8995_REGS_SIZE =A0 =A0 =A0 0x80
> +
> +#define ID1_CHIPID_M =A0 =A0 =A0 =A0 =A0 0xf
> +#define ID1_CHIPID_S =A0 =A0 =A0 =A0 =A0 4
> +#define ID1_REVISION_M =A0 =A0 =A0 =A0 0x7
> +#define ID1_REVISION_S =A0 =A0 =A0 =A0 1
> +#define ID1_START_SW =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 /* start the =
switch */
> +
> +#define FAMILY_KS8995 =A0 =A0 =A0 =A0 =A00x95
> +#define CHIPID_M =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
> +
> +#define KS8995_CMD_WRITE =A0 =A0 =A0 0x02U
> +#define KS8995_CMD_READ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x03U
> +
> +#define KS8995_RESET_DELAY =A0 =A0 10 /* usec */
> +
> +struct ks8995_pdata {
> + =A0 =A0 =A0 /* not yet implemented */
> +};
> +
> +struct ks8995_switch {
> + =A0 =A0 =A0 struct spi_device =A0 =A0 =A0 *spi;
> + =A0 =A0 =A0 struct mutex =A0 =A0 =A0 =A0 =A0 =A0lock;
> + =A0 =A0 =A0 struct ks8995_pdata =A0 =A0 *pdata;
> +};
> +
> +static inline u8 get_chip_id(u8 val)
> +{
> + =A0 =A0 =A0 return (val >> ID1_CHIPID_S) & ID1_CHIPID_M;
> +}
> +
> +static inline u8 get_chip_rev(u8 val)
> +{
> + =A0 =A0 =A0 return (val >> ID1_REVISION_S) & ID1_REVISION_M;
> +}
> +
> +/* -----------------------------------------------------------------=
------- */
> +static int ks8995_read(struct ks8995_switch *ks, char *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned offset, size_t count)
> +{
> + =A0 =A0 =A0 u8 cmd[2];
> + =A0 =A0 =A0 struct spi_transfer t[2];
> + =A0 =A0 =A0 struct spi_message m;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 spi_message_init(&m);
> +
> + =A0 =A0 =A0 memset(&t, 0, sizeof(t));
> +
> + =A0 =A0 =A0 t[0].tx_buf =3D cmd;
> + =A0 =A0 =A0 t[0].len =3D sizeof(cmd);
> + =A0 =A0 =A0 spi_message_add_tail(&t[0], &m);
> +
> + =A0 =A0 =A0 t[1].rx_buf =3D buf;
> + =A0 =A0 =A0 t[1].len =3D count;
> + =A0 =A0 =A0 spi_message_add_tail(&t[1], &m);
> +
> + =A0 =A0 =A0 cmd[0] =3D KS8995_CMD_READ;
> + =A0 =A0 =A0 cmd[1] =3D offset;
> +
> + =A0 =A0 =A0 mutex_lock(&ks->lock);
> + =A0 =A0 =A0 err =3D spi_sync(ks->spi, &m);
> + =A0 =A0 =A0 mutex_unlock(&ks->lock);
> +
> + =A0 =A0 =A0 return err ? err : count;
> +}
> +
> +
> +static int ks8995_write(struct ks8995_switch *ks, char *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned offset, size_t count)
> +{
> + =A0 =A0 =A0 u8 cmd[2];
> + =A0 =A0 =A0 struct spi_transfer t[2];
> + =A0 =A0 =A0 struct spi_message m;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 spi_message_init(&m);
> +
> + =A0 =A0 =A0 memset(&t, 0, sizeof(t));
> +
> + =A0 =A0 =A0 t[0].tx_buf =3D cmd;
> + =A0 =A0 =A0 t[0].len =3D sizeof(cmd);
> + =A0 =A0 =A0 spi_message_add_tail(&t[0], &m);
> +
> + =A0 =A0 =A0 t[1].tx_buf =3D buf;
> + =A0 =A0 =A0 t[1].len =3D count;
> + =A0 =A0 =A0 spi_message_add_tail(&t[1], &m);
> +
> + =A0 =A0 =A0 cmd[0] =3D KS8995_CMD_WRITE;
> + =A0 =A0 =A0 cmd[1] =3D offset;
> +
> + =A0 =A0 =A0 mutex_lock(&ks->lock);
> + =A0 =A0 =A0 err =3D spi_sync(ks->spi, &m);
> + =A0 =A0 =A0 mutex_unlock(&ks->lock);
> +
> + =A0 =A0 =A0 return err ? err : count;
> +}
> +
> +static inline int ks8995_read_reg(struct ks8995_switch *ks, u8 addr,=
 u8 *buf)
> +{
> + =A0 =A0 =A0 return (ks8995_read(ks, buf, addr, 1) !=3D 1);
> +}
> +
> +static inline int ks8995_write_reg(struct ks8995_switch *ks, u8 addr=
, u8 val)
> +{
> + =A0 =A0 =A0 char buf =3D val;
> +
> + =A0 =A0 =A0 return (ks8995_write(ks, &buf, addr, 1) !=3D 1);
> +}
> +
> +/* -----------------------------------------------------------------=
------- */
> +
> +static int ks8995_stop(struct ks8995_switch *ks)
> +{
> + =A0 =A0 =A0 return ks8995_write_reg(ks, KS8995_REG_ID1, 0);
> +}
> +
> +static int ks8995_start(struct ks8995_switch *ks)
> +{
> + =A0 =A0 =A0 return ks8995_write_reg(ks, KS8995_REG_ID1, 1);
> +}
> +
> +static int ks8995_reset(struct ks8995_switch *ks)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 err =3D ks8995_stop(ks);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 udelay(KS8995_RESET_DELAY);
> +
> + =A0 =A0 =A0 return ks8995_start(ks);
> +}
> +
> +/* -----------------------------------------------------------------=
------- */
> +
> +static ssize_t ks8995_registers_read(struct file *filp, struct kobje=
ct *kobj,
> + =A0 =A0 =A0 struct bin_attribute *bin_attr, char *buf, loff_t off, =
size_t count)
> +{
> + =A0 =A0 =A0 struct device *dev;
> + =A0 =A0 =A0 struct ks8995_switch *ks8995;
> +
> + =A0 =A0 =A0 dev =3D container_of(kobj, struct device, kobj);
> + =A0 =A0 =A0 ks8995 =3D dev_get_drvdata(dev);
> +
> + =A0 =A0 =A0 if (unlikely(off > KS8995_REGS_SIZE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if ((off + count) > KS8995_REGS_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D KS8995_REGS_SIZE - off;
> +
> + =A0 =A0 =A0 if (unlikely(!count))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return count;
> +
> + =A0 =A0 =A0 return ks8995_read(ks8995, buf, off, count);
> +}
> +
> +
> +static ssize_t ks8995_registers_write(struct file *filp, struct kobj=
ect *kobj,
> + =A0 =A0 =A0 struct bin_attribute *bin_attr, char *buf, loff_t off, =
size_t count)
> +{
> + =A0 =A0 =A0 struct device *dev;
> + =A0 =A0 =A0 struct ks8995_switch *ks8995;
> +
> + =A0 =A0 =A0 dev =3D container_of(kobj, struct device, kobj);
> + =A0 =A0 =A0 ks8995 =3D dev_get_drvdata(dev);
> +
> + =A0 =A0 =A0 if (unlikely(off >=3D KS8995_REGS_SIZE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFBIG;
> +
> + =A0 =A0 =A0 if ((off + count) > KS8995_REGS_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D KS8995_REGS_SIZE - off;
> +
> + =A0 =A0 =A0 if (unlikely(!count))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return count;
> +
> + =A0 =A0 =A0 return ks8995_write(ks8995, buf, off, count);
> +}
> +
> +
> +static struct bin_attribute ks8995_registers_attr =3D {
> + =A0 =A0 =A0 .attr =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =3D "registers",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =3D S_IRUSR | S_IWUSR,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 .size =A0 =3D KS8995_REGS_SIZE,
> + =A0 =A0 =A0 .read =A0 =3D ks8995_registers_read,
> + =A0 =A0 =A0 .write =A0=3D ks8995_registers_write,
> +};
> +
> +/* -----------------------------------------------------------------=
------- */
> +
> +static int __devinit ks8995_probe(struct spi_device *spi)
> +{
> + =A0 =A0 =A0 struct ks8995_switch =A0 =A0*ks;
> + =A0 =A0 =A0 struct ks8995_pdata =A0 =A0 *pdata;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0ids[2];
> + =A0 =A0 =A0 int =A0 =A0 err;
> +
> + =A0 =A0 =A0 /* Chip description */
> + =A0 =A0 =A0 pdata =3D spi->dev.platform_data;
> +
> + =A0 =A0 =A0 ks =3D kzalloc(sizeof(*ks), GFP_KERNEL);
> + =A0 =A0 =A0 if (!ks) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "no memory for priva=
te data\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_init(&ks->lock);
> + =A0 =A0 =A0 ks->pdata =3D pdata;
> + =A0 =A0 =A0 ks->spi =3D spi_dev_get(spi);
> + =A0 =A0 =A0 dev_set_drvdata(&spi->dev, ks);
> +
> + =A0 =A0 =A0 spi->mode =3D SPI_MODE_0;
> + =A0 =A0 =A0 spi->bits_per_word =3D 8;
> + =A0 =A0 =A0 err =3D spi_setup(spi);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "spi_setup failed, e=
rr=3D%d\n", err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_drvdata;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D ks8995_read(ks, ids, KS8995_REG_ID0, sizeof(ids=
));
> + =A0 =A0 =A0 if (err < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "unable to read id r=
egisters, err=3D%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_drvdata;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 switch (ids[0]) {
> + =A0 =A0 =A0 case FAMILY_KS8995:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "unknown family id:%=
02x\n", ids[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_drvdata;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D ks8995_reset(ks);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_drvdata;
> +
> + =A0 =A0 =A0 err =3D sysfs_create_bin_file(&spi->dev.kobj, &ks8995_r=
egisters_attr);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "unable to create sy=
sfs file, err=3D%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_drvdata;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_info(&spi->dev, "KS89%02X device found, Chip ID:%01=
x, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Revision:%01x\n", ids[=
0],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_chip_id(ids[1]), ge=
t_chip_rev(ids[1]));
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_drvdata:
> + =A0 =A0 =A0 dev_set_drvdata(&spi->dev, NULL);
> + =A0 =A0 =A0 kfree(ks);
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int __devexit ks8995_remove(struct spi_device *spi)
> +{
> + =A0 =A0 =A0 struct ks8995_data =A0 =A0 =A0*ks8995;
> +
> + =A0 =A0 =A0 ks8995 =3D dev_get_drvdata(&spi->dev);
> + =A0 =A0 =A0 sysfs_remove_bin_file(&spi->dev.kobj, &ks8995_registers=
_attr);
> +
> + =A0 =A0 =A0 dev_set_drvdata(&spi->dev, NULL);
> + =A0 =A0 =A0 kfree(ks8995);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* -----------------------------------------------------------------=
------- */
> +
> +static struct spi_driver ks8995_driver =3D {
> + =A0 =A0 =A0 .driver =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =A0 =A0 =A0 =3D "spi-ks8995",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .bus =A0 =A0 =A0 =A0 =3D &spi_bus_type,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .owner =A0 =A0 =3D THIS_MODULE,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 .probe =A0 =A0=3D ks8995_probe,
> + =A0 =A0 =A0 .remove =A0 =3D __devexit_p(ks8995_remove),
> +};
> +
> +static int __init ks8995_init(void)
> +{
> + =A0 =A0 =A0 printk(KERN_INFO DRV_DESC " version " DRV_VERSION"\n");
> +
> + =A0 =A0 =A0 return spi_register_driver(&ks8995_driver);
> +}
> +module_init(ks8995_init);
> +
> +static void __exit ks8995_exit(void)
> +{
> + =A0 =A0 =A0 spi_unregister_driver(&ks8995_driver);
> +}
> +module_exit(ks8995_exit);
> +
> +MODULE_DESCRIPTION(DRV_DESC);
> +MODULE_VERSION(DRV_VERSION);
> +MODULE_AUTHOR("Gabor Juhos <juhosg at openwrt.org>");
> +MODULE_LICENSE("GPL v2");
> +
> --
> 1.7.4.1
>

BR,
--
=46red
