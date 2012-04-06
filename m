From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 33/39] dmfe: stop using net_device.{base_addr,
 irq} and convert to __iomem.
Date: Fri, 6 Apr 2012 09:31:01 -0700
Message-ID: <CANEJEGs6SKqZESw8ttr8HKTgf3svQ9fFEBU2PLF9QOwUWsNqmg@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<83b453d5ea2df18d0af1a760e458c5b649415bfd.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:62934 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab2DFQbD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:31:03 -0400
Received: by obbtb18 with SMTP id tb18so3274048obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 09:31:02 -0700 (PDT)
In-Reply-To: <83b453d5ea2df18d0af1a760e458c5b649415bfd.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:06 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> This is a pure PCI driver, no ISA here.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

I want to point out one potential bug below (that can be fixed later
if necessary.)

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/dmfe.c | =C2=A0295 +++++++++++++=
++++----------------
> =C2=A01 files changed, 153 insertions(+), 142 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethe=
rnet/dec/tulip/dmfe.c
> index 1eccf49..0ef5b68 100644
> --- a/drivers/net/ethernet/dec/tulip/dmfe.c
> +++ b/drivers/net/ethernet/dec/tulip/dmfe.c
> @@ -150,6 +150,12 @@
> =C2=A0#define DMFE_TX_TIMEOUT ((3*HZ)/2) =C2=A0 =C2=A0 /* tx packet t=
ime-out time 1.5 s" */
> =C2=A0#define DMFE_TX_KICK =C2=A0 (HZ/2) =C2=A0/* tx packet Kick-out =
time 0.5 s" */
>
> +#define dw32(reg, val) iowrite32(val, ioaddr + (reg))
> +#define dw16(reg, val) iowrite16(val, ioaddr + (reg))
> +#define dr32(reg) =C2=A0 =C2=A0 =C2=A0ioread32(ioaddr + (reg))
> +#define dr16(reg) =C2=A0 =C2=A0 =C2=A0ioread16(ioaddr + (reg))
> +#define dr8(reg) =C2=A0 =C2=A0 =C2=A0 ioread8(ioaddr + (reg))
> +
> =C2=A0#define DMFE_DBUG(dbug_now, msg, value) =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dmfe_debug=
 || (dbug_now)) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> @@ -178,14 +184,6 @@
>
> =C2=A0#define SROM_V41_CODE =C2=A0 0x14
>
> -#define SROM_CLK_WRITE(data, ioaddr) \
> - =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
> - =C2=A0 =C2=A0 =C2=A0 udelay(5); \
> - =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioa=
ddr); \
> - =C2=A0 =C2=A0 =C2=A0 udelay(5); \
> - =C2=A0 =C2=A0 =C2=A0 outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
> - =C2=A0 =C2=A0 =C2=A0 udelay(5);
> -
> =C2=A0#define __CHK_IO_SIZE(pci_id, dev_rev) \
> =C2=A0(( ((pci_id)=3D=3DPCI_DM9132_ID) || ((dev_rev) >=3D 0x30) ) ? \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DM9102A_IO_SIZE: DM9102_IO_SIZE)
> @@ -213,11 +211,11 @@ struct rx_desc {
> =C2=A0struct dmfe_board_info {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 chip_id; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Chip vendor/Device ID */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 chip_revision; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 /* Chip revision */
> - =C2=A0 =C2=A0 =C2=A0 struct DEVICE *next_dev; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* next device */
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *next_dev; =C2=A0 =C2=A0/* n=
ext device */
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
> @@ -320,20 +318,20 @@ static netdev_tx_t dmfe_start_xmit(struct sk_bu=
ff *, struct DEVICE *);
> =C2=A0static int dmfe_stop(struct DEVICE *);
> =C2=A0static void dmfe_set_filter_mode(struct DEVICE *);
> =C2=A0static const struct ethtool_ops netdev_ethtool_ops;
> -static u16 read_srom_word(long ,int);
> +static u16 read_srom_word(void __iomem *, int);
> =C2=A0static irqreturn_t dmfe_interrupt(int , void *);
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =C2=A0static void poll_dmfe (struct net_device *dev);
> =C2=A0#endif
> -static void dmfe_descriptor_init(struct net_device *, unsigned long)=
;
> +static void dmfe_descriptor_init(struct net_device *);
> =C2=A0static void allocate_rx_buffer(struct net_device *);
> -static void update_cr6(u32, unsigned long);
> +static void update_cr6(u32, void __iomem *);
> =C2=A0static void send_filter_frame(struct DEVICE *);
> =C2=A0static void dm9132_id_table(struct DEVICE *);
> -static u16 phy_read(unsigned long, u8, u8, u32);
> -static void phy_write(unsigned long, u8, u8, u16, u32);
> -static void phy_write_1bit(unsigned long, u32);
> -static u16 phy_read_1bit(unsigned long);
> +static u16 phy_read(void __iomem *, u8, u8, u32);
> +static void phy_write(void __iomem *, u8, u8, u16, u32);
> +static void phy_write_1bit(void __iomem *, u32);
> +static u16 phy_read_1bit(void __iomem *);
> =C2=A0static u8 dmfe_sense_speed(struct dmfe_board_info *);
> =C2=A0static void dmfe_process_mode(struct dmfe_board_info *);
> =C2=A0static void dmfe_timer(unsigned long);
> @@ -462,14 +460,16 @@ static int __devinit dmfe_init_one (struct pci_=
dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_dma_start =3D db->buf_pool_dm=
a_ptr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->chip_id =3D ent->driver_data;
> - =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D pci_resource_start(pdev, 0);
> + =C2=A0 =C2=A0 =C2=A0 /* IO type range. */
> + =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D pci_iomap(pdev, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!db->ioaddr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
buf;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->chip_revision =3D pdev->revision;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->wol_mode =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->pdev =3D pdev;
>
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D db->ioaddr;
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D &netdev_ops;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->ethtool_ops =3D &netdev_ethtool_ops;
> @@ -484,9 +484,10 @@ static int __devinit dmfe_init_one (struct pci_d=
ev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->chip_type =
=3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* read 64 word srom data */
> - =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < 64; i++)
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < 64; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0((__le16 *) db=
->srom)[i] =3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0cpu_to_le16(read_srom_word(db->ioaddr, i));
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Set Node address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 6; i++)
> @@ -494,16 +495,18 @@ static int __devinit dmfe_init_one (struct pci_=
dev *pdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D register_netdev (dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
buf;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_unmap=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_info(&dev->dev, "Davicom DM%04lx at pc=
i%s, %pM, irq %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ent->driver_d=
ata >> 16,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_name(pde=
v), dev->dev_addr, dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_name(pde=
v), dev->dev_addr, pdev->irq);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> +err_out_unmap:
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, db->ioaddr);
> =C2=A0err_out_free_buf:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consistent(pdev, TX_BUF_ALLOC * T=
X_DESC_CNT + 4,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_ptr, db->buf_pool_dma_ptr);
> @@ -532,7 +535,7 @@ static void __devexit dmfe_remove_one (struct pci=
_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dev) {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unregister_net=
dev(dev);
> -
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_iounmap(db->pd=
ev, db->ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consi=
stent(db->pdev, sizeof(struct tx_desc) *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0D=
ESC_ALL_CNT + 0x20, db->desc_pool_ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0d=
b->desc_pool_dma_ptr);
> @@ -555,13 +558,13 @@ static void __devexit dmfe_remove_one (struct p=
ci_dev *pdev)
>
> =C2=A0static int dmfe_open(struct DEVICE *dev)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D db->pdev->irq;
> + =C2=A0 =C2=A0 =C2=A0 int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_open", 0);
>
> - =C2=A0 =C2=A0 =C2=A0 ret =3D request_irq(dev->irq, dmfe_interrupt,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 IRQF_SHARED, dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D request_irq(irq, dmfe_interrupt, IRQF_=
SHARED, dev->name, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> @@ -615,14 +618,14 @@ static int dmfe_open(struct DEVICE *dev)
> =C2=A0static void dmfe_init_dm910x(struct DEVICE *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset DM910x MAC controller */
> - =C2=A0 =C2=A0 =C2=A0 outl(DM910X_RESET, ioaddr + DCR0); =C2=A0 =C2=A0=
 =C2=A0/* RESET MAC */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR0, DM910X_RESET); =C2=A0 =C2=A0 =C2=A0=
 /* RESET MAC */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(100);

If this driver supports devices that offer MMIO BARs, the dw32()
followed by udelay() won't work the same way outl()/udelay() worked.
See http://www.parisc-linux.org/~grundler/talks/ols_2002/4_3MMIO_is_har=
der.html
for explanation of problem and how to fix this (It's simple enough).

Ugh..since I wrote "Porting to ZX1" 10 years ago, the link to the tg3
patch is dead (long live bitkeeper!). I think it was this patch:
    http://permalink.gmane.org/gmane.linux.kernel.commits.2-4/7007

You might find modeling after this patch to be helpful.

thanks,
grant

> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr0_data, ioaddr + DCR0);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR0, db->cr0_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Phy addr : DM910(A)2/DM9132/9801, phy a=
ddress =3D 1 */
> @@ -633,12 +636,12 @@ static void dmfe_init_dm910x(struct DEVICE *dev=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->media_mode =3D dmfe_media_mode;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* RESET Phyxcer Chip by GPR port bit 7 */
> - =C2=A0 =C2=A0 =C2=A0 outl(0x180, ioaddr + DCR12); =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Let bit 7 output port */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR12, 0x180); =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* Let bit 7 output port */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->chip_id =3D=3D PCI_DM9009_ID) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x80, ioaddr =
+ DCR12); =C2=A0 =C2=A0 /* Issue RESET signal */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR12, 0x80);=
 =C2=A0 =C2=A0 =C2=A0/* Issue RESET signal */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mdelay(300); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* De=
lay 300 ms */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 outl(0x0, ioaddr + DCR12); =C2=A0 =C2=A0 =C2=A0=
/* Clear RESET signal */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR12, 0x0); =C2=A0 =C2=A0 =C2=A0 /* Clea=
r RESET signal */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Process Phyxcer Media Mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(db->media_mode & 0x10) ) /* Force 1=
M mode */
> @@ -649,7 +652,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->op_mode =3D=
 db->media_mode; =C2=A0 /* Force Mode */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Initialize Transmit/Receive decriptor a=
nd CR3/4 */
> - =C2=A0 =C2=A0 =C2=A0 dmfe_descriptor_init(dev, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 dmfe_descriptor_init(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init CR6 to program DM910x operation */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_cr6(db->cr6_data, ioaddr);
> @@ -662,10 +665,10 @@ static void dmfe_init_dm910x(struct DEVICE *dev=
)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init CR7, interrupt active bit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr7_data =3D CR7_DEFAULT;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init CR15, Tx jabber and Rx watchdog ti=
mer */
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr15_data, ioaddr + DCR15);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR15, db->cr15_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Enable DM910X Tx/Rx function */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data |=3D CR6_RXSC | CR6_TXSC | 0x=
40000;
> @@ -682,6 +685,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
struct DEVICE *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *txptr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> @@ -707,7 +711,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable NIC interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit this packet */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_insert_ptr;
> @@ -721,11 +725,11 @@ static netdev_tx_t dmfe_start_xmit(struct sk_bu=
ff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( (!db->tx_queue_cnt) && (db->tx_packet=
_cnt < TX_MAX_SEND_CNT) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr->tdes0 =3D=
 cpu_to_le32(0x80000000); /* Set owner bit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_packet_=
cnt++; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Ready to send */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* saved time=
 stamp */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_queue_c=
nt++; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* queue TX packet */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Tx resource check */
> @@ -734,7 +738,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free this SKB */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb(skb);
> @@ -751,7 +755,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
> =C2=A0static int dmfe_stop(struct DEVICE *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_stop", 0);
>
> @@ -762,12 +766,12 @@ static int dmfe_stop(struct DEVICE *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0del_timer_sync(&db->timer);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset & stop DM910X board */
> - =C2=A0 =C2=A0 =C2=A0 outl(DM910X_RESET, ioaddr + DCR0);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR0, DM910X_RESET);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> - =C2=A0 =C2=A0 =C2=A0 phy_write(db->ioaddr, db->phy_addr, 0, 0x8000,=
 db->chip_id);
> + =C2=A0 =C2=A0 =C2=A0 phy_write(ioaddr, db->phy_addr, 0, 0x8000, db-=
>chip_id);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free interrupt */
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(db->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free allocated rx buffer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dmfe_free_rxbuffer(db);
> @@ -794,7 +798,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *=
dev_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct DEVICE *dev =3D dev_id;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_interrupt()", 0);
> @@ -802,15 +806,15 @@ static irqreturn_t dmfe_interrupt(int irq, void=
 *dev_id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&db->lock, flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Got DM910X status */
> - =C2=A0 =C2=A0 =C2=A0 db->cr5_data =3D inl(ioaddr + DCR5);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr5_data, ioaddr + DCR5);
> + =C2=A0 =C2=A0 =C2=A0 db->cr5_data =3D dr32(DCR5);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR5, db->cr5_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( !(db->cr5_data & 0xc1) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_ir=
qrestore(&db->lock, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return IRQ_HAN=
DLED;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable all interrupt in CR7 to solve t=
he interrupt edge problem */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, 0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check system status */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->cr5_data & 0x2000) {
> @@ -838,11 +842,11 @@ static irqreturn_t dmfe_interrupt(int irq, void=
 *dev_id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->dm910x_chk_mode & 0x2) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->dm910x_chk=
_mode =3D 0x4;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data |=
=3D 0x100;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt mask */
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, db->cr7_data);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return IRQ_HANDLED;
> @@ -858,11 +862,14 @@ static irqreturn_t dmfe_interrupt(int irq, void=
 *dev_id)
>
> =C2=A0static void poll_dmfe (struct net_device *dev)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct dmfe_board_info *db =3D netdev_priv(dev=
);
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D db->pdev->irq;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable_irq here is not very nice, but =
with the lockless
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 interrupt handler we have no other=
 choice. */
> - =C2=A0 =C2=A0 =C2=A0 disable_irq(dev->irq);
> - =C2=A0 =C2=A0 =C2=A0 dmfe_interrupt (dev->irq, dev);
> - =C2=A0 =C2=A0 =C2=A0 enable_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 disable_irq(irq);
> + =C2=A0 =C2=A0 =C2=A0 dmfe_interrupt (irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 enable_irq(irq);
> =C2=A0}
> =C2=A0#endif
>
> @@ -873,7 +880,7 @@ static void poll_dmfe (struct net_device *dev)
> =C2=A0static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_bo=
ard_info * db)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *txptr;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 tdes0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_remove_ptr;
> @@ -897,7 +904,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, =
struct dmfe_board_info * db)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0d=
b->tx_fifo_underrun++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i=
f ( !(db->cr6_data & CR6_SFT) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data =3D db->cr6_data | CR6_SFT;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (tdes0 & 0x0100)
> @@ -924,7 +931,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, =
struct dmfe_board_info * db)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr->tdes0 =3D=
 cpu_to_le32(0x80000000); /* Set owner bit */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_packet_=
cnt++; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* Ready to send */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_queue_c=
nt--;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Issue Tx po=
lling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0/* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* saved time=
 stamp */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -1087,12 +1094,7 @@ static void dmfe_ethtool_get_drvinfo(struct ne=
t_device *dev,
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
> =C2=A0static int dmfe_ethtool_set_wol(struct net_device *dev,
> @@ -1132,10 +1134,11 @@ static const struct ethtool_ops netdev_ethtoo=
l_ops =3D {
>
> =C2=A0static void dmfe_timer(unsigned long data)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *dev =3D (struct net_device =
*)data;
> + =C2=A0 =C2=A0 =C2=A0 struct dmfe_board_info *db =3D netdev_priv(dev=
);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 tmp_cr8;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned char tmp_cr12;
> - =C2=A0 =C2=A0 =C2=A0 struct DEVICE *dev =3D (struct DEVICE *) data;
> - =C2=A0 =C2=A0 =C2=A0 struct dmfe_board_info *db =3D netdev_priv(dev=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int link_ok, link_ok_phy;
> @@ -1148,11 +1151,10 @@ static void dmfe_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_in_c=
allback =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->chip_t=
ype && (db->chip_id=3D=3DPCI_DM9102_ID)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->cr6_data &=3D ~0x40000;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, db->ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy_write(db->ioaddr,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 db->phy_addr, 0, 0x1000, db-=
>chip_id);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 phy_write(ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->cr6_data |=3D 0x40000;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->timer.expires =3D DMFE_TIMER_WUT + HZ * 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0add_timer(&db->timer);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> @@ -1167,7 +1169,7 @@ static void dmfe_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->dm910x_chk=
_mode =3D 0x4;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Dynamic reset DM910X : system error or =
transmit time-out */
> - =C2=A0 =C2=A0 =C2=A0 tmp_cr8 =3D inl(db->ioaddr + DCR8);
> + =C2=A0 =C2=A0 =C2=A0 tmp_cr8 =3D dr32(DCR8);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( (db->interval_rx_cnt=3D=3D0) && (tmp_=
cr8) ) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->reset_cr8+=
+;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->wait_reset=
 =3D 1;
> @@ -1177,7 +1179,7 @@ static void dmfe_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX polling kick monitor */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( db->tx_packet_cnt &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 time_after(jiffies, dev_tra=
ns_start(dev) + DMFE_TX_KICK) ) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 /* Tx polling again */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR1, 0x1); =C2=
=A0 /* Tx polling again */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX Timeout =
*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (time_after=
(jiffies, dev_trans_start(dev) + DMFE_TX_TIMEOUT) ) {
> @@ -1200,9 +1202,9 @@ static void dmfe_timer(unsigned long data)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Link status check, Dynamic media type c=
hange */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->chip_id =3D=3D PCI_DM9132_ID)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp_cr12 =3D inb(d=
b->ioaddr + DCR9 + 3); =C2=A0/* DM9132 */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp_cr12 =3D dr8(D=
CR9 + 3); =C2=A0 =C2=A0 =C2=A0 /* DM9132 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp_cr12 =3D inb(d=
b->ioaddr + DCR12); =C2=A0 =C2=A0 /* DM9102/DM9102A */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp_cr12 =3D dr8(D=
CR12); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9102/DM9102A */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( ((db->chip_id =3D=3D PCI_DM9102_ID) &=
&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(db->chip_revi=
sion =3D=3D 0x30)) ||
> @@ -1251,7 +1253,7 @@ static void dmfe_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* 10/100M link failed, used 1M Home-Net */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->cr6_data|=3D0x00040000; =C2=A0 =C2=A0 =C2=A0 /* bit18=
=3D1, MII */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0db->cr6_data&=3D~0x00000200; =C2=A0 =C2=A0 =C2=A0/* bit9=3D=
0, HD mode */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 update_cr6(db->cr6_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (!netif_carrier_ok(dev)) {
>
> @@ -1288,17 +1290,18 @@ static void dmfe_timer(unsigned long data)
> =C2=A0* =C2=A0 =C2=A0 Re-initialize DM910X board
> =C2=A0*/
>
> -static void dmfe_dynamic_reset(struct DEVICE *dev)
> +static void dmfe_dynamic_reset(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_dynamic_reset()", 0);
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
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, 0); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable I=
nterrupt */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR5, dr32(DCR5));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable upper layer interface */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_stop_queue(dev);
> @@ -1364,9 +1367,10 @@ static void dmfe_reuse_skb(struct dmfe_board_i=
nfo *db, struct sk_buff * skb)
> =C2=A0* =C2=A0 =C2=A0 Using Chain structure, and allocate Tx/Rx buffe=
r
> =C2=A0*/
>
> -static void dmfe_descriptor_init(struct net_device *dev, unsigned lo=
ng ioaddr)
> +static void dmfe_descriptor_init(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *tmp_tx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rx_desc *tmp_rx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned char *tmp_buf;
> @@ -1379,7 +1383,7 @@ static void dmfe_descriptor_init(struct net_dev=
ice *dev, unsigned long ioaddr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* tx descriptor start pointer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_insert_ptr =3D db->first_tx_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_remove_ptr =3D db->first_tx_desc;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->first_tx_desc_dma, ioaddr + DCR4); =C2=
=A0 =C2=A0 /* TX DESC address */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR4, db->first_tx_desc_dma); =C2=A0 =C2=A0=
 /* TX DESC address */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* rx descriptor start pointer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_rx_desc =3D (void *)db->first_tx=
_desc +
> @@ -1389,7 +1393,7 @@ static void dmfe_descriptor_init(struct net_dev=
ice *dev, unsigned long ioaddr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0sizeof(struct tx_desc) * TX_DESC_CNT;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->rx_insert_ptr =3D db->first_rx_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->rx_ready_ptr =3D db->first_rx_desc;
> - =C2=A0 =C2=A0 =C2=A0 outl(db->first_rx_desc_dma, ioaddr + DCR3); =C2=
=A0 =C2=A0 /* RX DESC address */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR3, db->first_rx_desc_dma); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* RX DESC address */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Init Transmit chain */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tmp_buf =3D db->buf_pool_start;
> @@ -1431,14 +1435,14 @@ static void dmfe_descriptor_init(struct net_d=
evice *dev, unsigned long ioaddr)
> =C2=A0* =C2=A0 =C2=A0 Firstly stop DM910X , then written value and st=
art
> =C2=A0*/
>
> -static void update_cr6(u32 cr6_data, unsigned long ioaddr)
> +static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 cr6_tmp;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cr6_tmp =3D cr6_data & ~0x2002; =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 /* stop Tx/Rx */
> - =C2=A0 =C2=A0 =C2=A0 outl(cr6_tmp, ioaddr + DCR6);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR6, cr6_tmp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> - =C2=A0 =C2=A0 =C2=A0 outl(cr6_data, ioaddr + DCR6);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR6, cr6_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> =C2=A0}
>
> @@ -1448,24 +1452,19 @@ static void update_cr6(u32 cr6_data, unsigned=
 long ioaddr)
> =C2=A0* =C2=A0 =C2=A0 This setup frame initialize DM910X address filt=
er mode
> =C2=A0*/
>
> -static void dm9132_id_table(struct DEVICE *dev)
> +static void dm9132_id_table(struct net_device *dev)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct dmfe_board_info *db =3D netdev_priv(dev=
);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr + 0xc0;
> + =C2=A0 =C2=A0 =C2=A0 u16 *addrptr =3D (u16 *)dev->dev_addr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct netdev_hw_addr *ha;
> - =C2=A0 =C2=A0 =C2=A0 u16 * addrptr;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr+0xc0; =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ID Table */
> - =C2=A0 =C2=A0 =C2=A0 u32 hash_val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 i, hash_table[4];
>
> - =C2=A0 =C2=A0 =C2=A0 DMFE_DBUG(0, "dm9132_id_table()", 0);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Node address */
> - =C2=A0 =C2=A0 =C2=A0 addrptr =3D (u16 *) dev->dev_addr;
> - =C2=A0 =C2=A0 =C2=A0 outw(addrptr[0], ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 ioaddr +=3D 4;
> - =C2=A0 =C2=A0 =C2=A0 outw(addrptr[1], ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 ioaddr +=3D 4;
> - =C2=A0 =C2=A0 =C2=A0 outw(addrptr[2], ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 ioaddr +=3D 4;
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < 3; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw16(0, addrptr[i]=
);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr +=3D 4;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Clear Hash Table */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(hash_table, 0, sizeof(hash_table));
> @@ -1475,13 +1474,14 @@ static void dm9132_id_table(struct DEVICE *de=
v)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the multicast address in Hash Table : 6=
4 bits */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_for_each_mc_addr(ha, dev) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hash_val =3D cal_C=
RC((char *) ha->addr, 6, 0) & 0x3f;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 hash_val =3D c=
al_CRC((char *)ha->addr, 6, 0) & 0x3f;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hash_table[has=
h_val / 16] |=3D (u16) 1 << (hash_val % 16);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Write the hash table to MAC MD table */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 4; i++, ioaddr +=3D 4)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outw(hash_table[i]=
, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw16(0, hash_table=
[i]);
> =C2=A0}
>
>
> @@ -1490,7 +1490,7 @@ static void dm9132_id_table(struct DEVICE *dev)
> =C2=A0* =C2=A0 =C2=A0 This setup frame initialize DM910X address filt=
er mode
> =C2=A0*/
>
> -static void send_filter_frame(struct DEVICE *dev)
> +static void send_filter_frame(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct netdev_hw_addr *ha;
> @@ -1535,12 +1535,14 @@ static void send_filter_frame(struct DEVICE *=
dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Resource Check and Send the setup packe=
t */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!db->tx_packet_cnt) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void __iomem *ioad=
dr =3D db->ioaddr;
> +
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR1, 0x1); =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_queue_c=
nt++; =C2=A0 =C2=A0 /* Put in TX queue */
> @@ -1575,43 +1577,55 @@ static void allocate_rx_buffer(struct net_dev=
ice *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->rx_insert_ptr =3D rxptr;
> =C2=A0}
>
> +static void srom_clk_write(void __iomem *ioaddr, u32 data)
> +{
> + =C2=A0 =C2=A0 =C2=A0 static const u32 cmd[] =3D {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CR9_SROM_READ | CR=
9_SRCS,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CR9_SROM_READ | CR=
9_SRCS | CR9_SRCLK,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CR9_SROM_READ | CR=
9_SRCS
> + =C2=A0 =C2=A0 =C2=A0 };
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < ARRAY_SIZE(cmd); i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, data | =
cmd[i]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(5);
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
>
> =C2=A0/*
> =C2=A0* =C2=A0 =C2=A0 Read one word data from the serial ROM
> =C2=A0*/
> -
> -static u16 read_srom_word(long ioaddr, int offset)
> +static u16 read_srom_word(void __iomem *ioaddr, int offset)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 u16 srom_data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> - =C2=A0 =C2=A0 =C2=A0 u16 srom_data =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 long cr9_ioaddr =3D ioaddr + DCR9;
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SROM_READ);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send the Read Command 110b */
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(ioaddr, SROM_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(ioaddr, SROM_DATA_1);
> + =C2=A0 =C2=A0 =C2=A0 srom_clk_write(ioaddr, SROM_DATA_0);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send the offset */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 5; i >=3D 0; i--) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0srom_data =3D =
(offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SROM_CLK_WRITE(sro=
m_data, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 srom_clk_write(ioa=
ddr, srom_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 16; i > 0; i--) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ=
 | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SRO=
M_READ | CR9_SRCS | CR9_SRCLK);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0srom_data =3D =
(srom_data << 1) |
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1=
 : 0);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ=
 | CR9_SRCS, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((dr32(DCR9) & CR9_CRDOUT) ? 1 : 0)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SRO=
M_READ | CR9_SRCS);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 outl(CR9_SROM_READ, cr9_ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, CR9_SROM_READ);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return srom_data;
> =C2=A0}
>
> @@ -1620,13 +1634,14 @@ static u16 read_srom_word(long ioaddr, int of=
fset)
> =C2=A0* =C2=A0 =C2=A0 Auto sense the media mode
> =C2=A0*/
>
> -static u8 dmfe_sense_speed(struct dmfe_board_info * db)
> +static u8 dmfe_sense_speed(struct dmfe_board_info *db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 ErrFlag =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_mode;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* CR6 bit18=3D0, select 10/100M */
> - =C2=A0 =C2=A0 =C2=A0 update_cr6( (db->cr6_data & ~0x40000), db->ioa=
ddr);
> + =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data & ~0x40000, ioaddr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_mode =3D phy_read(db->ioaddr, db->phy_=
addr, 1, db->chip_id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_mode =3D phy_read(db->ioaddr, db->phy_=
addr, 1, db->chip_id);
> @@ -1665,11 +1680,12 @@ static u8 dmfe_sense_speed(struct dmfe_board_=
info * db)
>
> =C2=A0static void dmfe_set_phyxcer(struct dmfe_board_info *db)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_reg;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Select 10/100M phyxcer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data &=3D ~0x40000;
> - =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, ioaddr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9009 Chip: Phyxcer reg18 bit12=3D0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (db->chip_id =3D=3D PCI_DM9009_ID) {
> @@ -1765,18 +1781,15 @@ static void dmfe_process_mode(struct dmfe_boa=
rd_info *db)
> =C2=A0* =C2=A0 =C2=A0 Write a word to Phy register
> =C2=A0*/
>
> -static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
> +static void phy_write(void __iomem *ioaddr, u8 phy_addr, u8 offset,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0u16 phy_data, u32 chip_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 i;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (chip_id =3D=3D PCI_DM9132_ID) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase =
+ 0x80 + offset * 4;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outw(phy_data, ioa=
ddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dw16(0x80 + offset=
 * 4, phy_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9102/DM91=
02A Chip */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase =
+ DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 syn=
chronization clock to Phy controller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; =
i < 35; i++)
> @@ -1816,19 +1829,16 @@ static void phy_write(unsigned long iobase, u=
8 phy_addr, u8 offset,
> =C2=A0* =C2=A0 =C2=A0 Read a word data from phy register
> =C2=A0*/
>
> -static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u3=
2 chip_id)
> +static u16 phy_read(void __iomem *ioaddr, u8 phy_addr, u8 offset, u3=
2 chip_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (chip_id =3D=3D PCI_DM9132_ID) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9132 Chip=
 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase =
+ 0x80 + offset * 4;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_data =3D inw(i=
oaddr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phy_data =3D dr16(=
0x80 + offset * 4);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9102/DM91=
02A Chip */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase =
+ DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 syn=
chronization clock to Phy controller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; =
i < 35; i++)
> @@ -1870,13 +1880,13 @@ static u16 phy_read(unsigned long iobase, u8 =
phy_addr, u8 offset, u32 chip_id)
> =C2=A0* =C2=A0 =C2=A0 Write one bit data to Phy Controller
> =C2=A0*/
>
> -static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
> +static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data, ioaddr); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* MII Clock Low */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, phy_data); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* MII Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data | MDCLKH, ioaddr); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* MII Clock High */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, phy_data | MDCLKH); =C2=A0/* MII Cl=
ock High */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 outl(phy_data, ioaddr); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* MII Clock Low */
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, phy_data); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* MII Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> =C2=A0}
>
> @@ -1885,14 +1895,14 @@ static void phy_write_1bit(unsigned long ioad=
dr, u32 phy_data)
> =C2=A0* =C2=A0 =C2=A0 Read one bit phy data from PHY controller
> =C2=A0*/
>
> -static u16 phy_read_1bit(unsigned long ioaddr)
> +static u16 phy_read_1bit(void __iomem *ioaddr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
>
> - =C2=A0 =C2=A0 =C2=A0 outl(0x50000, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, 0x50000);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 phy_data =3D ( inl(ioaddr) >> 19 ) & 0x1;
> - =C2=A0 =C2=A0 =C2=A0 outl(0x40000, ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 phy_data =3D (dr32(DCR9) >> 19) & 0x1;
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR9, 0x40000);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return phy_data;
> @@ -1978,7 +1988,7 @@ static void dmfe_parse_srom(struct dmfe_board_i=
nfo * db)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check DM9801 or DM9802 present or not *=
/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->HPNA_present =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data|0x40000, db->ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data | 0x40000, db->ioaddr)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tmp_reg =3D phy_read(db->ioaddr, db->phy_a=
ddr, 3, db->chip_id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( ( tmp_reg & 0xfff0 ) =3D=3D 0xb900 ) =
{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9801 or D=
M9802 present */
> @@ -2095,6 +2105,7 @@ static int dmfe_suspend(struct pci_dev *pci_dev=
, pm_message_t state)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D pci_get_drvdata=
(pci_dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 tmp;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable upper layer interface */
> @@ -2102,11 +2113,11 @@ static int dmfe_suspend(struct pci_dev *pci_d=
ev, pm_message_t state)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable Tx/Rx */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->cr6_data &=3D ~(CR6_RXSC | CR6_TXSC);
> - =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, dev->base_addr);
> + =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6_data, ioaddr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable Interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7);
> - =C2=A0 =C2=A0 =C2=A0 outl(inl (dev->base_addr + DCR5), dev->base_ad=
dr + DCR5);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR7, 0);
> + =C2=A0 =C2=A0 =C2=A0 dw32(DCR5, dr32(DCR5));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Fre RX buffers */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dmfe_free_rxbuffer(db);
> --
> 1.7.7.6
>
