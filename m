From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next 33/34] dmfe: stop using net_device.{base_addr,
 irq} and convert to __iomem.
Date: Fri, 16 Mar 2012 10:48:42 -0700
Message-ID: <CANEJEGuoaTP1Pjs1yzRkx2uoC6VW2UV2n0Wgspbc38d6qdRBrQ@mail.gmail.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
	<6fbe1c856415aff0b1cf507a4687fe94cb9a384b.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:65075 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab2CPRsn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 13:48:43 -0400
Received: by gghe5 with SMTP id e5so4450101ggh.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 10:48:42 -0700 (PDT)
In-Reply-To: <6fbe1c856415aff0b1cf507a4687fe94cb9a384b.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 6:57 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> This is a pure PCI driver, no ISA here.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>
> ---
> =C2=A0drivers/net/ethernet/dec/tulip/dmfe.c | =C2=A0174 +++++++++++++=
+++++---------------
> =C2=A01 files changed, 95 insertions(+), 79 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethe=
rnet/dec/tulip/dmfe.c
> index 1eccf49..a1b5914 100644
> --- a/drivers/net/ethernet/dec/tulip/dmfe.c
> +++ b/drivers/net/ethernet/dec/tulip/dmfe.c
> @@ -178,6 +178,12 @@
>
> =C2=A0#define SROM_V41_CODE =C2=A0 0x14
>
> +#define outl =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iowrite32
> +#define outw =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 iowrite16
> +#define inl =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ioread32
> +#define inw =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ioread16
> +#define inb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ioread8

Hi Francois,
is there any reason you didn't want to directly use iowrite/ioread rout=
ines?

There is a semantic difference between outl and iowrite. Having
"outl()" source but instead generate an MMIO transaction could lead to
misunderstanding/bugs about posted MMIO writes. So I'd rather see a
direct transition to iowrite and just ditch all the inb/outb stuff.

I'm still suffering from jetlag right now and am not able to review
the rest of the patch now. I'll try to take a look at it tomorrow.

thanks,
grant

> +
> =C2=A0#define SROM_CLK_WRITE(data, ioaddr) \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); =
\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(5); \
> @@ -213,11 +219,11 @@ struct rx_desc {
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
> @@ -320,20 +326,20 @@ static netdev_tx_t dmfe_start_xmit(struct sk_bu=
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
> @@ -462,14 +468,16 @@ static int __devinit dmfe_init_one (struct pci_=
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
> @@ -484,9 +492,10 @@ static int __devinit dmfe_init_one (struct pci_d=
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
> @@ -494,16 +503,18 @@ static int __devinit dmfe_init_one (struct pci_=
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
> @@ -532,7 +543,7 @@ static void __devexit dmfe_remove_one (struct pci=
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
> @@ -555,13 +566,13 @@ static void __devexit dmfe_remove_one (struct p=
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
> @@ -615,7 +626,7 @@ static int dmfe_open(struct DEVICE *dev)
> =C2=A0static void dmfe_init_dm910x(struct DEVICE *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct dmfe_board_info *db =3D netdev_priv=
(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
>
> @@ -649,7 +660,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
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
> @@ -682,6 +693,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
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
> @@ -707,7 +719,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable NIC interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit this packet */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_insert_ptr;
> @@ -721,11 +733,11 @@ static netdev_tx_t dmfe_start_xmit(struct sk_bu=
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* saved time=
 stamp */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_queue_c=
nt++; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* queue TX packet */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Tx resource check */
> @@ -734,7 +746,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
 *skb,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free this SKB */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb(skb);
> @@ -751,7 +763,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff=
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
> @@ -764,10 +776,10 @@ static int dmfe_stop(struct DEVICE *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Reset & stop DM910X board */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(DM910X_RESET, ioaddr + DCR0);
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
> @@ -794,7 +806,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *=
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
> @@ -838,7 +850,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *=
dev_id)
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
> @@ -858,11 +870,14 @@ static irqreturn_t dmfe_interrupt(int irq, void=
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
> @@ -873,7 +888,7 @@ static void poll_dmfe (struct net_device *dev)
> =C2=A0static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_bo=
ard_info * db)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tx_desc *txptr;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 tdes0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_remove_ptr;
> @@ -897,7 +912,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, =
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
> @@ -1087,12 +1102,7 @@ static void dmfe_ethtool_get_drvinfo(struct ne=
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
> @@ -1132,10 +1142,11 @@ static const struct ethtool_ops netdev_ethtoo=
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
> @@ -1148,11 +1159,10 @@ static void dmfe_timer(unsigned long data)
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
> @@ -1177,7 +1187,7 @@ static void dmfe_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX polling kick monitor */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( db->tx_packet_cnt &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 time_after(jiffies, dev_tra=
ns_start(dev) + DMFE_TX_KICK) ) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 /* Tx polling again */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 /* Tx polling again */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX Timeout =
*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (time_after=
(jiffies, dev_trans_start(dev) + DMFE_TX_TIMEOUT) ) {
> @@ -1251,7 +1261,7 @@ static void dmfe_timer(unsigned long data)
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
> @@ -1288,17 +1298,18 @@ static void dmfe_timer(unsigned long data)
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
> + =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Disable Interrupt */
> + =C2=A0 =C2=A0 =C2=A0 outl(inl(ioaddr + DCR5), ioaddr + DCR5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable upper layer interface */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_stop_queue(dev);
> @@ -1364,9 +1375,10 @@ static void dmfe_reuse_skb(struct dmfe_board_i=
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
> @@ -1431,7 +1443,7 @@ static void dmfe_descriptor_init(struct net_dev=
ice *dev, unsigned long ioaddr)
> =C2=A0* =C2=A0 =C2=A0 Firstly stop DM910X , then written value and st=
art
> =C2=A0*/
>
> -static void update_cr6(u32 cr6_data, unsigned long ioaddr)
> +static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 cr6_tmp;
>
> @@ -1448,11 +1460,12 @@ static void update_cr6(u32 cr6_data, unsigned=
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
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr + 0xc0; =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ID Table */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct netdev_hw_addr *ha;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 * addrptr;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr+0xc0; =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* ID Table */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 hash_val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 i, hash_table[4];
>
> @@ -1490,7 +1503,7 @@ static void dm9132_id_table(struct DEVICE *dev)
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
> @@ -1535,12 +1548,14 @@ static void send_filter_frame(struct DEVICE *=
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->tx_queue_c=
nt++; =C2=A0 =C2=A0 /* Put in TX queue */
> @@ -1580,11 +1595,11 @@ static void allocate_rx_buffer(struct net_dev=
ice *dev)
> =C2=A0* =C2=A0 =C2=A0 Read one word data from the serial ROM
> =C2=A0*/
>
> -static u16 read_srom_word(long ioaddr, int offset)
> +static u16 read_srom_word(void __iomem *ioaddr, int offset)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *cr9_ioaddr =3D ioaddr + DCR9;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 srom_data =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 long cr9_ioaddr =3D ioaddr + DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(CR9_SROM_READ, cr9_ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr)=
;
> @@ -1620,13 +1635,14 @@ static u16 read_srom_word(long ioaddr, int of=
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
> @@ -1665,11 +1681,12 @@ static u8 dmfe_sense_speed(struct dmfe_board_=
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
> @@ -1765,18 +1782,16 @@ static void dmfe_process_mode(struct dmfe_boa=
rd_info *db)
> =C2=A0* =C2=A0 =C2=A0 Write a word to Phy register
> =C2=A0*/
>
> -static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
> +static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outw(phy_data, iob=
ase + 0x80 + offset * 4);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9102/DM91=
02A Chip */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase =
+ DCR9;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void __iomem *ioad=
dr =3D iobase + DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 syn=
chronization clock to Phy controller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; =
i < 35; i++)
> @@ -1816,11 +1831,11 @@ static void phy_write(unsigned long iobase, u=
8 phy_addr, u8 offset,
> =C2=A0* =C2=A0 =C2=A0 Read a word data from phy register
> =C2=A0*/
>
> -static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u3=
2 chip_id)
> +static u16 phy_read(void __iomem *iobase, u8 phy_addr, u8 offset, u3=
2 chip_id)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (chip_id =3D=3D PCI_DM9132_ID) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DM9132 Chip=
 */
> @@ -1870,7 +1885,7 @@ static u16 phy_read(unsigned long iobase, u8 ph=
y_addr, u8 offset, u32 chip_id)
> =C2=A0* =C2=A0 =C2=A0 Write one bit data to Phy Controller
> =C2=A0*/
>
> -static void phy_write_1bit(unsigned long ioaddr, u32 phy_data)
> +static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(phy_data, ioaddr); =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* MII Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> @@ -1885,7 +1900,7 @@ static void phy_write_1bit(unsigned long ioaddr=
, u32 phy_data)
> =C2=A0* =C2=A0 =C2=A0 Read one bit phy data from PHY controller
> =C2=A0*/
>
> -static u16 phy_read_1bit(unsigned long ioaddr)
> +static u16 phy_read_1bit(void __iomem *ioaddr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
>
> @@ -1978,7 +1993,7 @@ static void dmfe_parse_srom(struct dmfe_board_i=
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
> @@ -2095,6 +2110,7 @@ static int dmfe_suspend(struct pci_dev *pci_dev=
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
> @@ -2102,11 +2118,11 @@ static int dmfe_suspend(struct pci_dev *pci_d=
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
> + =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 outl(inl(ioaddr + DCR5), ioaddr + DCR5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Fre RX buffers */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dmfe_free_rxbuffer(db);
> --
> 1.7.7.6
>
