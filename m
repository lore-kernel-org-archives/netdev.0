From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 31/39] uli526x: stop using net_device.{base_addr,
 irq} and convert to __iomem.
Date: Fri, 6 Apr 2012 09:53:59 -0700
Message-ID: <CANEJEGus7cuHc5H_xdrdrwUt55isNKxqJyNfU4ej8URVTDvdtQ@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<0a3928f4342bab3bf0b2eb63fe71cecace548e99.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36157 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756159Ab2DFQyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:54:00 -0400
Received: by obbtb18 with SMTP id tb18so3297350obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 09:53:59 -0700 (PDT)
In-Reply-To: <0a3928f4342bab3bf0b2eb63fe71cecace548e99.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:06 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> The bulk of the patch comes from the __iomem changes.
>
> - the phy read and write operations were carrying the chip id deep
> =C2=A0down the call chain. Let's waste a pointer and contain the flyi=
ng
> =C2=A0spaghetti monster.
> - phy_{read, write}_1bit only need to access the DCR9 register. The l=
oss
> =C2=A0of generality here should not hurt.
> - removed a leftover printk of the EISA era. This is a pure PCI devic=
e.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-By: Grant Grundler <grundler@parisc-linux.org>

I suggest taking a look at srom_clk_write() and uli526x_init_one()
regarding posted MMIO write vs udelay().

I think I found an example that appears to get the ROM clocking
correct with MMIO:
    ethernet/realtek/8139cp.c: read_eeprom()

thanks!
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/uli526x.c | =C2=A0397 ++++++++++=
+++++---------------
> =C2=A01 files changed, 202 insertions(+), 195 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/e=
thernet/dec/tulip/uli526x.c
> index c9b3396..75d45f8 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -42,6 +42,8 @@
> =C2=A0#include <asm/dma.h>
> =C2=A0#include <asm/uaccess.h>
>
> +#define uw32(reg, val) iowrite32(val, ioaddr + (reg))
> +#define ur32(reg) =C2=A0 =C2=A0 =C2=A0ioread32(ioaddr + (reg))
>
> =C2=A0/* Board/System/Debug information/definition ---------------- *=
/
> =C2=A0#define PCI_ULI5261_ID =C2=A00x526110B9 =C2=A0 =C2=A0 /* ULi M5=
261 ID*/
> @@ -110,14 +112,6 @@ do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 \
>
> =C2=A0#define SROM_V41_CODE =C2=A0 0x14
>
> -#define SROM_CLK_WRITE(data, ioaddr) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM=
_READ|CR9_SRCS,ioaddr); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(5); =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM=
_READ|CR9_SRCS|CR9_SRCLK,ioaddr); =C2=A0 =C2=A0 \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(5); =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0\
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM=
_READ|CR9_SRCS,ioaddr); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(5);
> -
> =C2=A0/* Structure/enum declaration ------------------------------- *=
/
> =C2=A0struct tx_desc {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 __le32 tdes0, tdes1, tdes2, tdes3; /* Dat=
a for the card */
> @@ -132,12 +126,15 @@ struct rx_desc {
> =C2=A0} __attribute__(( aligned(32) ));
>
> =C2=A0struct uli526x_board_info {
> - =C2=A0 =C2=A0 =C2=A0 u32 chip_id; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Chip vendor/Device ID */
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void (*write)(stru=
ct uli526x_board_info *, u8, u8, u16);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 (*read)(struct=
 uli526x_board_info *, u8, u8);
> + =C2=A0 =C2=A0 =C2=A0 } phy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *next_dev; =C2=A0 =C2=A0=
/* next device */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pci_dev *pdev; =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* PCI device */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t lock;
>
> - =C2=A0 =C2=A0 =C2=A0 long ioaddr; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* I/O base address */
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* I/O base address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 cr0_data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 cr5_data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 cr6_data;
> @@ -227,21 +224,21 @@ static netdev_tx_t uli526x_start_xmit(struct sk=
_buff *,
> =C2=A0static int uli526x_stop(struct net_device *);
> =C2=A0static void uli526x_set_filter_mode(struct net_device *);
> =C2=A0static const struct ethtool_ops netdev_ethtool_ops;
> -static u16 read_srom_word(long, int);
> +static u16 read_srom_word(struct uli526x_board_info *, int);
> =C2=A0static irqreturn_t uli526x_interrupt(int, void *);
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =C2=A0static void uli526x_poll(struct net_device *dev);
> =C2=A0#endif
> -static void uli526x_descriptor_init(struct net_device *, unsigned lo=
ng);
> +static void uli526x_descriptor_init(struct net_device *, void __iome=
m *);
> =C2=A0static void allocate_rx_buffer(struct net_device *);
> -static void update_cr6(u32, unsigned long);
> +static void update_cr6(u32, void __iomem *);
> =C2=A0static void send_filter_frame(struct net_device *, int);
> -static u16 phy_read(unsigned long, u8, u8, u32);
> -static u16 phy_readby_cr10(unsigned long, u8, u8);
> -static void phy_write(unsigned long, u8, u8, u16, u32);
> -static void phy_writeby_cr10(unsigned long, u8, u8, u16);
> -static void phy_write_1bit(unsigned long, u32, u32);
> -static u16 phy_read_1bit(unsigned long, u32);
> +static u16 phy_readby_cr9(struct uli526x_board_info *, u8, u8);
> +static u16 phy_readby_cr10(struct uli526x_board_info *, u8, u8);
> +static void phy_writeby_cr9(struct uli526x_board_info *, u8, u8, u16=
);
> +static void phy_writeby_cr10(struct uli526x_board_info *, u8, u8, u1=
6);
> +static void phy_write_1bit(struct uli526x_board_info *db, u32);
> +static u16 phy_read_1bit(struct uli526x_board_info *db);
> =C2=A0static u8 uli526x_sense_speed(struct uli526x_board_info *);
> =C2=A0static void uli526x_process_mode(struct uli526x_board_info *);
> =C2=A0static void uli526x_timer(unsigned long);
> @@ -253,6 +250,18 @@ static void uli526x_free_rxbuffer(struct uli526x=
_board_info *);
> =C2=A0static void uli526x_init(struct net_device *);
> =C2=A0static void uli526x_set_phyxcer(struct uli526x_board_info *);
>
> +static void srom_clk_write(struct uli526x_board_info *db, u32 data)
> +{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> +
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS | C=
R9_SRCLK);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
> + =C2=A0 =C2=A0 =C2=A0 udelay(5);
> +}
> +
> =C2=A0/* ULI526X network board routine ---------------------------- *=
/
>
> =C2=A0static const struct net_device_ops netdev_ops =3D {
> @@ -277,6 +286,7 @@ static int __devinit uli526x_init_one (struct pci=
_dev *pdev,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db; =C2=A0/* bo=
ard information structure */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i, err;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ULI526X_DBUG(0, "uli526x_init_one()", 0);
> @@ -338,14 +348,26 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_start =3D db->buf_pool_ptr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_dma_start =3D db->buf_pool_dm=
a_ptr;
>
> - =C2=A0 =C2=A0 =C2=A0 db->chip_id =3D ent->driver_data;
> - =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D pci_resource_start(pdev, 0);
> + =C2=A0 =C2=A0 =C2=A0 switch (ent->driver_data) {
> + =C2=A0 =C2=A0 =C2=A0 case PCI_ULI5263_ID:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->phy.write =C2=A0=
 =3D phy_writeby_cr10;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->phy.read =C2=A0=
 =C2=A0=3D phy_readby_cr10;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->phy.write =C2=A0=
 =3D phy_writeby_cr9;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->phy.read =C2=A0=
 =C2=A0=3D phy_readby_cr9;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> + =C2=A0 =C2=A0 =C2=A0 /* IO region. */
> + =C2=A0 =C2=A0 =C2=A0 ioaddr =3D pci_iomap(pdev, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!ioaddr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
tx_buf;
> +
> + =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->pdev =3D pdev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->init =3D 1;
>
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D db->ioaddr;
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Register some necessary functions */
> @@ -357,24 +379,24 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* read 64 word srom data */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 64; i++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((__le16 *) db->sr=
om)[i] =3D cpu_to_le16(read_srom_word(db->ioaddr, i));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((__le16 *) db->sr=
om)[i] =3D cpu_to_le16(read_srom_word(db, i));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Set Node address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if(((u16 *) db->srom)[0] =3D=3D 0xffff || =
((u16 *) db->srom)[0] =3D=3D 0) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* SROM absent, so read MAC address from ID Table */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x10000, db->=
ioaddr + DCR0); =C2=A0 =C2=A0 =C2=A0 //Diagnosis mode
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1c0, db->io=
addr + DCR13); =C2=A0 =C2=A0 =C2=A0 =C2=A0//Reset dianostic pointer por=
t
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0, db->ioaddr=
 + DCR14); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Clear reset port
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x10, db->ioa=
ddr + DCR14); =C2=A0 =C2=A0 =C2=A0 =C2=A0 //Reset ID Table pointer
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0, db->ioaddr=
 + DCR14); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Clear reset port
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0, db->ioaddr=
 + DCR13); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Clear CR13
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1b0, db->io=
addr + DCR13); =C2=A0 =C2=A0 =C2=A0 =C2=A0//Select ID Table access port
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR0, 0x10000=
); =C2=A0 =C2=A0//Diagnosis mode
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR13, 0x1c0)=
; =C2=A0 =C2=A0 //Reset dianostic pointer port
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR14, 0); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 //Clear reset port
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR14, 0x10);=
 =C2=A0 =C2=A0 =C2=A0//Reset ID Table pointer
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR14, 0); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 //Clear reset port
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR13, 0); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 //Clear CR13
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR13, 0x1b0)=
; =C2=A0 =C2=A0 //Select ID Table access port
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Read MAC add=
ress from CR14
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; =
i < 6; i++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dev->dev_addr[i] =3D inl(db->ioaddr + DCR14);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dev->dev_addr[i] =3D ur32(DCR14);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Read end
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0, db->ioaddr=
 + DCR13); =C2=A0 =C2=A0//Clear CR13
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0, db->ioaddr=
 + DCR0); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 //Clear CR0
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR13, 0); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 //Clear CR13
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR0, 0); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0//Clear CR0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(10);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/*Exist SROM*/
> @@ -384,16 +406,18 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D register_netdev (dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
tx_buf;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_unmap=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_info(dev, "ULi M%04lx at pci%s, %pM=
, irq %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
ent->driver_data >> 16, pci_name(pdev),
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>dev_addr, dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>dev_addr, pdev->irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> +err_out_unmap:
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, db->ioaddr);
> =C2=A0err_out_free_tx_buf:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consistent(pdev, TX_BUF_ALLOC * T=
X_DESC_CNT + 4,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_ptr, db->buf_pool_dma_ptr);
> @@ -418,6 +442,7 @@ static void __devexit uli526x_remove_one (struct =
pci_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unregister_netdev(dev);
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, db->ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consistent(db->pdev, sizeof(struc=
t tx_desc) *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0DESC_ALL_CNT + 0x20, db->desc=
_pool_ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->desc_pool_dma_ptr);
> @@ -460,7 +485,8 @@ static int uli526x_open(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Initialize ULI526X board */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_init(dev);
>
> - =C2=A0 =C2=A0 =C2=A0 ret =3D request_irq(dev->irq, uli526x_interrup=
t, IRQF_SHARED, dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D request_irq(db->pdev->irq, uli526x_int=
errupt, IRQF_SHARED,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 dev->name, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> @@ -488,57 +514,57 @@ static int uli526x_open(struct net_device *dev)
> =C2=A0static void uli526x_init(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops *phy =3D &db->phy;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 =C2=A0 =C2=A0 =C2=A0phy_tmp;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 =C2=A0 =C2=A0 =C2=A0timeout;
> - =C2=A0 =C2=A0 =C2=A0 u16 =C2=A0 =C2=A0 phy_value;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_reg_reset;
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ULI526X_DBUG(0, "uli526x_init()", 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset M526x MAC controller */
> - =C2=A0 =C2=A0 =C2=A0 outl(ULI526X_RESET, ioaddr + DCR0); =C2=A0 =C2=
=A0 /* RESET MAC */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR0, ULI526X_RESET); =C2=A0 =C2=A0 =C2=A0=
/* RESET MAC */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(100);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr0_data, ioaddr + DCR0);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR0, db->cr0_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Phy addr : In some boards,M5261/M5263 p=
hy address !=3D 1 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->phy_addr =3D 1;
> - =C2=A0 =C2=A0 =C2=A0 for(phy_tmp=3D0;phy_tmp<32;phy_tmp++)
> - =C2=A0 =C2=A0 =C2=A0 {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_value=3Dphy_re=
ad(db->ioaddr,phy_tmp,3,db->chip_id);//peer add
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(phy_value !=3D =
0xffff&&phy_value!=3D0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 for (phy_tmp =3D 0; phy_tmp < 32; phy_tmp++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 phy_value;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_value =3D phy-=
>read(db, phy_tmp, 3); =C2=A0//peer add
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (phy_value !=3D=
 0xffff && phy_value !=3D 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->phy_addr =3D phy_tmp;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 if(phy_tmp =3D=3D 32)
> +
> + =C2=A0 =C2=A0 =C2=A0 if (phy_tmp =3D=3D 32)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_warn("Can n=
ot find the phy address!!!\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Parser SROM and media mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->media_mode =3D uli526x_media_mode;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* phyxcer capability setting */
> - =C2=A0 =C2=A0 =C2=A0 phy_reg_reset =3D phy_read(db->ioaddr, db->phy=
_addr, 0, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_reg_reset =3D phy->read(db, db->phy_addr, =
0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_reg_reset =3D (phy_reg_reset | 0x8000)=
;
> - =C2=A0 =C2=A0 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, phy_reg=
_reset, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy->write(db, db->phy_addr, 0, phy_reg_reset)=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* See IEEE 802.3-2002.pdf (Section 2, Cha=
pter "22.2.4 Management
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * functions") or phy data sheet for detai=
ls on phy reset
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(500);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0timeout =3D 10;
> - =C2=A0 =C2=A0 =C2=A0 while (timeout-- &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_read(db->ioadd=
r, db->phy_addr, 0, db->chip_id) & 0x8000)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 udelay(100);
> + =C2=A0 =C2=A0 =C2=A0 while (timeout-- && phy->read(db, db->phy_addr=
, 0) & 0x8000)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(100);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Process Phyxcer Media Mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_set_phyxcer(db);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Media Mode Process */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(db->media_mode & ULI526X_AUTO) )
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->op_mode =3D db=
->media_mode; =C2=A0 /* Force Mode */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->op_mode =3D db=
->media_mode; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Force Mode */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Initialize Transmit/Receive decriptor a=
nd CR3/4 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_descriptor_init(dev, ioaddr);
> @@ -551,10 +577,10 @@ static void uli526x_init(struct net_device *dev=
)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init CR7, interrupt active bit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr7_data =3D CR7_DEFAULT;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init CR15, Tx jabber and Rx watchdog ti=
mer */
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr15_data, ioaddr + DCR15);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR15, db->cr15_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Enable ULI526X Tx/Rx function */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data |=3D CR6_RXSC | CR6_TXSC;
> @@ -571,6 +597,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *txptr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> @@ -596,7 +623,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable NIC interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit this packet */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_insert_ptr;
> @@ -607,10 +634,10 @@ static netdev_tx_t uli526x_start_xmit(struct sk=
_buff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_insert_ptr =3D txptr->next_tx_desc;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Transmit Packet Process */
> - =C2=A0 =C2=A0 =C2=A0 if ( (db->tx_packet_cnt < TX_DESC_CNT) ) {
> + =C2=A0 =C2=A0 =C2=A0 if (db->tx_packet_cnt < TX_DESC_CNT) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr->tdes0 =3D=
 cpu_to_le32(0x80000000); /* Set owner bit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_packet_=
cnt++; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Ready to send */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* saved time=
 stamp */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -620,7 +647,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free this SKB */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb(skb);
> @@ -637,9 +664,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0static int uli526x_stop(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> -
> - =C2=A0 =C2=A0 =C2=A0 ULI526X_DBUG(0, "uli526x_stop", 0);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable system */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_stop_queue(dev);
> @@ -648,12 +673,12 @@ static int uli526x_stop(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0del_timer_sync(&db->timer);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset & stop ULI526X board */
> - =C2=A0 =C2=A0 =C2=A0 outl(ULI526X_RESET, ioaddr + DCR0);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR0, ULI526X_RESET);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> - =C2=A0 =C2=A0 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, 0x8000,=
 db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 db->phy.write(db, db->phy_addr, 0, 0x8000);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free interrupt */
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(db->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free allocated rx buffer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_free_rxbuffer(db);
> @@ -671,18 +696,18 @@ static irqreturn_t uli526x_interrupt(int irq, v=
oid *dev_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D dev_id;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&db->lock, flags);
> - =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Got ULI526X status */
> - =C2=A0 =C2=A0 =C2=A0 db->cr5_data =3D inl(ioaddr + DCR5);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr5_data, ioaddr + DCR5);
> + =C2=A0 =C2=A0 =C2=A0 db->cr5_data =3D ur32(DCR5);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR5, db->cr5_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(db->cr5_data & 0x180c1) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7=
 to enable interrupt mask */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data,=
 ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, db->cr7=
_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_ir=
qrestore(&db->lock, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return IRQ_HAN=
DLED;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -710,7 +735,7 @@ static irqreturn_t uli526x_interrupt(int irq, voi=
d *dev_id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_free_t=
x_pkt(dev, db);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt mask */
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return IRQ_HANDLED;
> @@ -719,8 +744,10 @@ static irqreturn_t uli526x_interrupt(int irq, vo=
id *dev_id)
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =C2=A0static void uli526x_poll(struct net_device *dev)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct uli526x_board_info *db =3D netdev_priv(=
dev);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* ISR grabs the irqsave lock, so this sho=
uld be safe */
> - =C2=A0 =C2=A0 =C2=A0 uli526x_interrupt(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 uli526x_interrupt(db->pdev->irq, dev);
> =C2=A0}
> =C2=A0#endif
>
> @@ -954,12 +981,7 @@ static void netdev_get_drvinfo(struct net_device=
 *dev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0strlcpy(info->driver, DRV_NAME, sizeof(inf=
o->driver));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0strlcpy(info->version, DRV_VERSION, sizeof=
(info->version));
> - =C2=A0 =C2=A0 =C2=A0 if (np->pdev)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 strlcpy(info->bus_=
info, pci_name(np->pdev),
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 sizeof(info->bus_info));
> - =C2=A0 =C2=A0 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sprintf(info->bus_=
info, "EISA 0x%lx %d",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dev->base_addr, dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 strlcpy(info->bus_info, pci_name(np->pdev), si=
zeof(info->bus_info));
> =C2=A0}
>
> =C2=A0static int netdev_get_settings(struct net_device *dev, struct e=
thtool_cmd *cmd) {
> @@ -999,18 +1021,20 @@ static const struct ethtool_ops netdev_ethtool=
_ops =3D {
>
> =C2=A0static void uli526x_timer(unsigned long data)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 u32 tmp_cr8;
> - =C2=A0 =C2=A0 =C2=A0 unsigned char tmp_cr12=3D0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D (struct net_dev=
ice *) data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops *phy =3D &db->phy;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> + =C2=A0 =C2=A0 =C2=A0 u8 tmp_cr12 =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 u32 tmp_cr8;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0//ULI526X_DBUG(0, "uli526x_timer()", 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&db->lock, flags);
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Dynamic reset ULI526X : system error or=
 transmit time-out */
> - =C2=A0 =C2=A0 =C2=A0 tmp_cr8 =3D inl(db->ioaddr + DCR8);
> + =C2=A0 =C2=A0 =C2=A0 tmp_cr8 =3D ur32(DCR8);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( (db->interval_rx_cnt=3D=3D0) && (tmp_=
cr8) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->reset_cr8+=
+;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->wait_reset=
 =3D 1;
> @@ -1020,7 +1044,7 @@ static void uli526x_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX polling kick monitor */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( db->tx_packet_cnt &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 time_after(jiffies, dev_tra=
ns_start(dev) + ULI526X_TX_KICK) ) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 // Tx polling again
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR1, 0x1); =C2=
=A0 // Tx polling again
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0// TX Timeout
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( time_afte=
r(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
> @@ -1041,7 +1065,7 @@ static void uli526x_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Link status check, Dynamic media type c=
hange */
> - =C2=A0 =C2=A0 =C2=A0 if((phy_read(db->ioaddr, db->phy_addr, 5, db->=
chip_id) & 0x01e0)!=3D0)
> + =C2=A0 =C2=A0 =C2=A0 if ((phy->read(db, db->phy_addr, 5) & 0x01e0)!=
=3D0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tmp_cr12 =3D 3=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(tmp_cr12 & 0x3) && !db->link_failed=
 ) {
> @@ -1054,7 +1078,7 @@ static void uli526x_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* For Force 1=
0/100M Half/Full mode: Enable Auto-Nego mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AUTO don't =
need */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(db->med=
ia_mode & 0x8) )
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy->write(db, db->phy_addr, 0, 0x1000);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AUTO mode, =
if INT phyxcer link failed, select EXT device */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->media_=
mode & ULI526X_AUTO) {
> @@ -1111,12 +1135,13 @@ static void uli526x_timer(unsigned long data)
> =C2=A0static void uli526x_reset_prepare(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sopt MAC controller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data &=3D ~(CR6_RXSC | CR6_TXSC); =
/* Disable Tx/Rx */
> - =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, dev->base_addr);
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7); =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 /* Disable Interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(inl(dev->base_addr + DCR5), dev->base_add=
r + DCR5);
> + =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR7, 0); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable I=
nterrupt */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR5, ur32(DCR5));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable upper layer interface */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_stop_queue(dev);
> @@ -1281,7 +1306,7 @@ static void uli526x_reuse_skb(struct uli526x_bo=
ard_info *db, struct sk_buff * sk
> =C2=A0* =C2=A0 =C2=A0 Using Chain structure, and allocate Tx/Rx buffe=
r
> =C2=A0*/
>
> -static void uli526x_descriptor_init(struct net_device *dev, unsigned=
 long ioaddr)
> +static void uli526x_descriptor_init(struct net_device *dev, void __i=
omem *ioaddr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *tmp_tx;
> @@ -1296,14 +1321,14 @@ static void uli526x_descriptor_init(struct ne=
t_device *dev, unsigned long ioaddr
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* tx descriptor start pointer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_insert_ptr =3D db->first_tx_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_remove_ptr =3D db->first_tx_desc;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->first_tx_desc_dma, ioaddr + DCR4); =C2=
=A0 =C2=A0 /* TX DESC address */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR4, db->first_tx_desc_dma); =C2=A0 =C2=A0=
 =C2=A0/* TX DESC address */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* rx descriptor start pointer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_rx_desc =3D (void *)db->first_tx=
_desc + sizeof(struct tx_desc) * TX_DESC_CNT;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_rx_desc_dma =3D =C2=A0db->first_=
tx_desc_dma + sizeof(struct tx_desc) * TX_DESC_CNT;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->rx_insert_ptr =3D db->first_rx_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->rx_ready_ptr =3D db->first_rx_desc;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->first_rx_desc_dma, ioaddr + DCR3); =C2=
=A0 =C2=A0 /* RX DESC address */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR3, db->first_rx_desc_dma); =C2=A0 =C2=A0=
 =C2=A0/* RX DESC address */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init Transmit chain */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tmp_buf =3D db->buf_pool_start;
> @@ -1344,11 +1369,9 @@ static void uli526x_descriptor_init(struct net=
_device *dev, unsigned long ioaddr
> =C2=A0* =C2=A0 =C2=A0 Update CR6 value
> =C2=A0* =C2=A0 =C2=A0 Firstly stop ULI526X, then written value and st=
art
> =C2=A0*/
> -
> -static void update_cr6(u32 cr6_data, unsigned long ioaddr)
> +static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
> =C2=A0{
> -
> - =C2=A0 =C2=A0 =C2=A0 outl(cr6_data, ioaddr + DCR6);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR6, cr6_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> =C2=A0}
>
> @@ -1367,6 +1390,7 @@ static void update_cr6(u32 cr6_data, unsigned l=
ong ioaddr)
> =C2=A0static void send_filter_frame(struct net_device *dev, int mc_cn=
t)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct netdev_hw_addr *ha;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *txptr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 * addrptr;
> @@ -1412,9 +1436,9 @@ static void send_filter_frame(struct net_device=
 *dev, int mc_cnt)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Resource Em=
pty */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_packet_=
cnt++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr->tdes0 =3D=
 cpu_to_le32(0x80000000);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data | 0x2000, dev->base_addr);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, dev->base_addr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data | 0x2000, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_err(dev=
, "No Tx resource - Send_filter_frame!\n");
> @@ -1457,37 +1481,38 @@ static void allocate_rx_buffer(struct net_dev=
ice *dev)
> =C2=A0* =C2=A0 =C2=A0 Read one word data from the serial ROM
> =C2=A0*/
>
> -static u16 read_srom_word(long ioaddr, int offset)
> +static u16 read_srom_word(struct uli526x_board_info *db, int offset)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int i;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 srom_data =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 long cr9_ioaddr =3D ioaddr + DCR9;
> + =C2=A0 =C2=A0 =C2=A0 int i;
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SROM_READ);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send the Read Command 110b */
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(db, SROM_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(db, SROM_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(db, SROM_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send the offset */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 5; i >=3D 0; i--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0srom_data =3D =
(offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(sro=
m_data, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 srom_clk_write(db,=
 srom_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 16; i > 0; i--) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ=
 | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SRO=
M_READ | CR9_SRCS | CR9_SRCLK);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 srom_data =3D (sro=
m_data << 1) | ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ=
 | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 srom_data =3D (sro=
m_data << 1) |
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ((ur32(DCR9) & CR9_CRDOUT) ? 1 : 0);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SRO=
M_READ | CR9_SRCS);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, CR9_SROM_READ);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return srom_data;
> =C2=A0}
>
> @@ -1498,15 +1523,16 @@ static u16 read_srom_word(long ioaddr, int of=
fset)
>
> =C2=A0static u8 uli526x_sense_speed(struct uli526x_board_info * db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops *phy =3D &db->phy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 ErrFlag =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_mode;
>
> - =C2=A0 =C2=A0 =C2=A0 phy_mode =3D phy_read(db->ioaddr, db->phy_addr=
, 1, db->chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_mode =3D phy_read(db->ioaddr, db->phy_addr=
, 1, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_mode =3D phy->read(db, db->phy_addr, 1);
> + =C2=A0 =C2=A0 =C2=A0 phy_mode =3D phy->read(db, db->phy_addr, 1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( (phy_mode & 0x24) =3D=3D 0x24 ) {
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_mode =3D ((phy=
_read(db->ioaddr, db->phy_addr, 5, db->chip_id) & 0x01e0)<<7);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_mode =3D ((phy=
->read(db, db->phy_addr, 5) & 0x01e0)<<7);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if(phy_mode&0x=
8000)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0phy_mode =3D 0x8000;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else if(phy_mo=
de&0x4000)
> @@ -1541,10 +1567,11 @@ static u8 uli526x_sense_speed(struct uli526x_=
board_info * db)
>
> =C2=A0static void uli526x_set_phyxcer(struct uli526x_board_info *db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops *phy =3D &db->phy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_reg;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Phyxcer capability setting */
> - =C2=A0 =C2=A0 =C2=A0 phy_reg =3D phy_read(db->ioaddr, db->phy_addr,=
 4, db->chip_id) & ~0x01e0;
> + =C2=A0 =C2=A0 =C2=A0 phy_reg =3D phy->read(db, db->phy_addr, 4) & ~=
0x01e0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->media_mode & ULI526X_AUTO) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AUTO Mode *=
/
> @@ -1565,10 +1592,10 @@ static void uli526x_set_phyxcer(struct uli526=
x_board_info *db)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_reg|=3Ddb-=
>PHY_reg4;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->media_mode=
|=3DULI526X_AUTO;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 4, phy_reg=
, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy->write(db, db->phy_addr, 4, phy_reg);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restart Auto-Negotiation */
> - =C2=A0 =C2=A0 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, 0x1200,=
 db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy->write(db, db->phy_addr, 0, 0x1200);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(50);
> =C2=A0}
>
> @@ -1582,6 +1609,7 @@ static void uli526x_set_phyxcer(struct uli526x_=
board_info *db)
>
> =C2=A0static void uli526x_process_mode(struct uli526x_board_info *db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct uli_phy_ops *phy =3D &db->phy;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_reg;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Full Duplex Mode Check */
> @@ -1593,10 +1621,10 @@ static void uli526x_process_mode(struct uli52=
6x_board_info *db)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_cr6(db->cr6_data, db->ioaddr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* 10/100M phyxcer force mode need */
> - =C2=A0 =C2=A0 =C2=A0 if ( !(db->media_mode & 0x8)) {
> + =C2=A0 =C2=A0 =C2=A0 if (!(db->media_mode & 0x8)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Forece Mode=
 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_reg =3D phy_re=
ad(db->ioaddr, db->phy_addr, 6, db->chip_id);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ( !(phy_reg & 0=
x1) ) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_reg =3D phy->r=
ead(db, db->phy_addr, 6);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(phy_reg & 0x=
1)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* parter without N-Way capability */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0phy_reg =3D 0x0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0switch(db->op_mode) {
> @@ -1605,148 +1633,126 @@ static void uli526x_process_mode(struct uli=
526x_board_info *db)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0case ULI526X_100MHF: phy_reg =3D 0x2000; break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0case ULI526X_100MFD: phy_reg =3D 0x2100; break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy->write(db, db->phy_addr, 0, phy_reg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
>
> -/*
> - * =C2=A0 =C2=A0 Write a word to Phy register
> - */
> -
> -static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, =
u16 phy_data, u32 chip_id)
> +/* M5261/M5263 Chip */
> +static void phy_writeby_cr9(struct uli526x_board_info *db, u8 phy_ad=
dr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 u8 offset, u16 phy_data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 i;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
> -
> - =C2=A0 =C2=A0 =C2=A0 if(chip_id =3D=3D PCI_ULI5263_ID)
> - =C2=A0 =C2=A0 =C2=A0 {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_writeby_cr10(i=
obase, phy_addr, offset, phy_data);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> - =C2=A0 =C2=A0 =C2=A0 }
> - =C2=A0 =C2=A0 =C2=A0 /* M5261/M5263 Chip */
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 synchronization clock to Phy co=
ntroller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 35; i++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, PHY_DATA_1, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 PHY_DATA_1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send start command(01) to Phy */
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_0);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send write command(01) to Phy */
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_0);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send Phy address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0x10; i > 0; i =3D i >> 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send register address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0x10; i > 0; i =3D i >> 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 offset & i ? PHY_DATA_1 : PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* written trasnition */
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Write a word data to PHY controller */
> - =C2=A0 =C2=A0 =C2=A0 for ( i =3D 0x8000; i > 0; i >>=3D 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, phy_data & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
> -
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0x8000; i > 0; i >>=3D 1)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
> =C2=A0}
>
> -
> -/*
> - * =C2=A0 =C2=A0 Read a word data from phy register
> - */
> -
> -static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u3=
2 chip_id)
> +static u16 phy_readby_cr9(struct uli526x_board_info *db, u8 phy_addr=
, u8 offset)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
> -
> - =C2=A0 =C2=A0 =C2=A0 if(chip_id =3D=3D PCI_ULI5263_ID)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return phy_readby_=
cr10(iobase, phy_addr, offset);
> - =C2=A0 =C2=A0 =C2=A0 /* M5261/M5263 Chip */
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR9;
> + =C2=A0 =C2=A0 =C2=A0 int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 synchronization clock to Phy co=
ntroller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 35; i++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, PHY_DATA_1, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 PHY_DATA_1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send start command(01) to Phy */
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_0);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send read command(10) to Phy */
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
> - =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db, PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send Phy address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0x10; i > 0; i =3D i >> 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send register address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0x10; i > 0; i =3D i >> 1)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(ioa=
ddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_write_1bit(db,=
 offset & i ? PHY_DATA_1 : PHY_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Skip transition state */
> - =C2=A0 =C2=A0 =C2=A0 phy_read_1bit(ioaddr, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_read_1bit(db);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* read 16bit data */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (phy_data =3D 0, i =3D 0; i < 16; i++)=
 {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_data <<=3D=
 1;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_data |=3D phy_=
read_1bit(ioaddr, chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_data |=3D phy_=
read_1bit(db);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return phy_data;
> =C2=A0}
>
> -static u16 phy_readby_cr10(unsigned long iobase, u8 phy_addr, u8 off=
set)
> +static u16 phy_readby_cr10(struct uli526x_board_info *db, u8 phy_add=
r,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0u8 offset)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr,cr10_value;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 u32 cr10_value =3D phy_addr;
>
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR10;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D phy_addr;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<5) + offset;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<16) + 0x08000000;
> - =C2=A0 =C2=A0 =C2=A0 outl(cr10_value,ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << =C2=A05) + offse=
t;
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << 16) + 0x08000000=
;
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR10, cr10_value);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 while(1)
> - =C2=A0 =C2=A0 =C2=A0 {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cr10_value =3D inl=
(ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(cr10_value&0x10=
000000)
> + =C2=A0 =C2=A0 =C2=A0 while (1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cr10_value =3D ur3=
2(DCR10);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (cr10_value & 0=
x10000000)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return cr10_value & 0x0ffff;
> =C2=A0}
>
> -static void phy_writeby_cr10(unsigned long iobase, u8 phy_addr, u8 o=
ffset, u16 phy_data)
> +static void phy_writeby_cr10(struct uli526x_board_info *db, u8 phy_a=
ddr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 offset, u16 phy_data)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr,cr10_value;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 u32 cr10_value =3D phy_addr;
>
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR10;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D phy_addr;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<5) + offset;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<16) + 0x04000000 +=
 phy_data;
> - =C2=A0 =C2=A0 =C2=A0 outl(cr10_value,ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << =C2=A05) + offse=
t;
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << 16) + 0x04000000=
 + phy_data;
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR10, cr10_value);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> =C2=A0}
> =C2=A0/*
> =C2=A0* =C2=A0 =C2=A0 Write one bit data to Phy Controller
> =C2=A0*/
>
> -static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 c=
hip_id)
> +static void phy_write_1bit(struct uli526x_board_info *db, u32 data)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data , ioaddr); =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* MII Cl=
ock Low */
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> +
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 /* MII Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data =C2=A0| MDCLKH, ioaddr); =C2=A0 =
=C2=A0 =C2=A0 /* MII Clock High */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data | MDCLKH); =C2=A0 =C2=A0 =C2=A0=
/* MII Clock High */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data , ioaddr); =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* MII Cl=
ock Low */
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, data); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 /* MII Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> =C2=A0}
>
> @@ -1755,14 +1761,15 @@ static void phy_write_1bit(unsigned long ioad=
dr, u32 phy_data, u32 chip_id)
> =C2=A0* =C2=A0 =C2=A0 Read one bit phy data from PHY controller
> =C2=A0*/
>
> -static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
> +static u16 phy_read_1bit(struct uli526x_board_info *db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
>
> - =C2=A0 =C2=A0 =C2=A0 outl(0x50000 , ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, 0x50000);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 phy_data =3D ( inl(ioaddr) >> 19 ) & 0x1;
> - =C2=A0 =C2=A0 =C2=A0 outl(0x40000 , ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 phy_data =3D (ur32(DCR9) >> 19) & 0x1;
> + =C2=A0 =C2=A0 =C2=A0 uw32(DCR9, 0x40000);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return phy_data;
> --
> 1.7.7.6
>
