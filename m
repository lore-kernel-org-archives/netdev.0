From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next 31/34] uli526x: stop using net_device.{base_addr,
 irq} and convert to __iomem.
Date: Sat, 17 Mar 2012 23:33:41 -0700
Message-ID: <CANEJEGvp1pRozUznyihvUGknVKUKBsupRPk7FxapOYobR2gHjA@mail.gmail.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
	<01b3ae027e23d903f38da93ebc9e6c0d18c940a3.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39244 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab2CRGdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 02:33:43 -0400
Received: by obbeh20 with SMTP id eh20so407815obb.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 23:33:42 -0700 (PDT)
In-Reply-To: <01b3ae027e23d903f38da93ebc9e6c0d18c940a3.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 6:57 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

(I'm now forwarding all my parisc-linux.org email to my gmail
account...so the "from" line won't match.)

Thanks!
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/uli526x.c | =C2=A0138 ++++++++++=
++++++--------------
> =C2=A01 files changed, 73 insertions(+), 65 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/e=
thernet/dec/tulip/uli526x.c
> index c9b3396..2035791 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -42,6 +42,8 @@
> =C2=A0#include <asm/dma.h>
> =C2=A0#include <asm/uaccess.h>
>
> +#define outl =C2=A0 iowrite32
> +#define inl =C2=A0 =C2=A0ioread32
>
> =C2=A0/* Board/System/Debug information/definition ---------------- *=
/
> =C2=A0#define PCI_ULI5261_ID =C2=A00x526110B9 =C2=A0 =C2=A0 /* ULi M5=
261 ID*/
> @@ -137,7 +139,7 @@ struct uli526x_board_info {
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
> @@ -227,21 +229,21 @@ static netdev_tx_t uli526x_start_xmit(struct sk=
_buff *,
> =C2=A0static int uli526x_stop(struct net_device *);
> =C2=A0static void uli526x_set_filter_mode(struct net_device *);
> =C2=A0static const struct ethtool_ops netdev_ethtool_ops;
> -static u16 read_srom_word(long, int);
> +static u16 read_srom_word(void __iomem *, int);
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
> +static u16 phy_read(void __iomem *, u8, u8, u32);
> +static u16 phy_readby_cr10(void __iomem *, u8, u8);
> +static void phy_write(void __iomem *, u8, u8, u16, u32);
> +static void phy_writeby_cr10(void __iomem *, u8, u8, u16);
> +static void phy_write_1bit(void __iomem *, u32, u32);
> +static u16 phy_read_1bit(void __iomem *, u32);
> =C2=A0static u8 uli526x_sense_speed(struct uli526x_board_info *);
> =C2=A0static void uli526x_process_mode(struct uli526x_board_info *);
> =C2=A0static void uli526x_timer(unsigned long);
> @@ -339,13 +341,15 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_dma_start =3D db->buf_pool_dm=
a_ptr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->chip_id =3D ent->driver_data;
> - =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D pci_resource_start(pdev, 0);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* IO region. */
> + =C2=A0 =C2=A0 =C2=A0 db->ioaddr =3D pci_iomap(pdev, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!db->ioaddr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
tx_buf;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->pdev =3D pdev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->init =3D 1;
>
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D db->ioaddr;
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Register some necessary functions */
> @@ -384,16 +388,18 @@ static int __devinit uli526x_init_one (struct p=
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
> @@ -418,6 +424,7 @@ static void __devexit uli526x_remove_one (struct =
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
> @@ -460,7 +467,8 @@ static int uli526x_open(struct net_device *dev)
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
> @@ -488,7 +496,7 @@ static int uli526x_open(struct net_device *dev)
> =C2=A0static void uli526x_init(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D db->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 =C2=A0 =C2=A0 =C2=A0phy_tmp;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 =C2=A0 =C2=A0 =C2=A0timeout;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 =C2=A0 =C2=A0 phy_value;
> @@ -571,6 +579,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
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
> @@ -596,7 +605,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable NIC interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(0, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit this packet */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txptr =3D db->tx_insert_ptr;
> @@ -610,7 +619,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( (db->tx_packet_cnt < TX_DESC_CNT) ) {
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
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -620,7 +629,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Restore CR7 to enable interrupt */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&db->lock, flags);
> - =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, dev->base_addr + DCR7);
> + =C2=A0 =C2=A0 =C2=A0 outl(db->cr7_data, ioaddr + DCR7);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free this SKB */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_kfree_skb(skb);
> @@ -637,7 +646,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_b=
uff *skb,
> =C2=A0static int uli526x_stop(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ULI526X_DBUG(0, "uli526x_stop", 0);
>
> @@ -653,7 +662,7 @@ static int uli526x_stop(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_write(db->ioaddr, db->phy_addr, 0, 0x8=
000, db->chip_id);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free interrupt */
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(db->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* free allocated rx buffer */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0uli526x_free_rxbuffer(db);
> @@ -671,7 +680,7 @@ static irqreturn_t uli526x_interrupt(int irq, voi=
d *dev_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D dev_id;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr =3D dev->base_addr;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D db->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&db->lock, flags);
> @@ -719,8 +728,10 @@ static irqreturn_t uli526x_interrupt(int irq, vo=
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
> @@ -954,12 +965,7 @@ static void netdev_get_drvinfo(struct net_device=
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
> @@ -1020,7 +1026,7 @@ static void uli526x_timer(unsigned long data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TX polling kick monitor */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( db->tx_packet_cnt &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 time_after(jiffies, dev_tra=
ns_start(dev) + ULI526X_TX_KICK) ) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, dev->bas=
e_addr + DCR1); =C2=A0 // Tx polling again
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, db->ioad=
dr + DCR1); =C2=A0 // Tx polling again
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0// TX Timeout
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ( time_afte=
r(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
> @@ -1111,12 +1117,13 @@ static void uli526x_timer(unsigned long data)
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
> + =C2=A0 =C2=A0 =C2=A0 outl(0, ioaddr + DCR7); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Disable Interrupt */
> + =C2=A0 =C2=A0 =C2=A0 outl(inl(ioaddr + DCR5), ioaddr + DCR5);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Disable upper layer interface */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_stop_queue(dev);
> @@ -1281,7 +1288,7 @@ static void uli526x_reuse_skb(struct uli526x_bo=
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
> @@ -1345,7 +1352,7 @@ static void uli526x_descriptor_init(struct net_=
device *dev, unsigned long ioaddr
> =C2=A0* =C2=A0 =C2=A0 Firstly stop ULI526X, then written value and st=
art
> =C2=A0*/
>
> -static void update_cr6(u32 cr6_data, unsigned long ioaddr)
> +static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
> =C2=A0{
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(cr6_data, ioaddr + DCR6);
> @@ -1367,6 +1374,7 @@ static void update_cr6(u32 cr6_data, unsigned l=
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
> @@ -1412,9 +1420,9 @@ static void send_filter_frame(struct net_device=
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
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(0x1, ioaddr +=
 DCR1); =C2=A0 =C2=A0 =C2=A0 /* Issue Tx polling */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_cr6(db->cr6=
_data, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->trans_sta=
rt =3D jiffies;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_err(dev=
, "No Tx resource - Send_filter_frame!\n");
> @@ -1457,11 +1465,11 @@ static void allocate_rx_buffer(struct net_dev=
ice *dev)
> =C2=A0* =C2=A0 =C2=A0 Read one word data from the serial ROM
> =C2=A0*/
>
> -static u16 read_srom_word(long ioaddr, int offset)
> +static u16 read_srom_word(void __iomem *ioaddr, int offset)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int i;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *cr9_ioaddr =3D ioaddr + DCR9;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 srom_data =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 long cr9_ioaddr =3D ioaddr + DCR9;
> + =C2=A0 =C2=A0 =C2=A0 int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(CR9_SROM_READ, cr9_ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr)=
;
> @@ -1615,18 +1623,18 @@ static void uli526x_process_mode(struct uli52=
6x_board_info *db)
> =C2=A0* =C2=A0 =C2=A0 Write a word to Phy register
> =C2=A0*/
>
> -static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, =
u16 phy_data, u32 chip_id)
> +static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 u16 phy_data, u32 chip_id)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 /* M5261/M5263 Chip */
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D iobase + DCR9;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 i;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if(chip_id =3D=3D PCI_ULI5263_ID)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0phy_writeby_cr=
10(iobase, phy_addr, offset, phy_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 /* M5261/M5263 Chip */
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR9;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Send 33 synchronization clock to Phy co=
ntroller */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < 35; i++)
> @@ -1663,11 +1671,11 @@ static void phy_write(unsigned long iobase, u=
8 phy_addr, u8 offset, u16 phy_data
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
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if(chip_id =3D=3D PCI_ULI5263_ID)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return phy_rea=
dby_cr10(iobase, phy_addr, offset);
> @@ -1706,41 +1714,41 @@ static u16 phy_read(unsigned long iobase, u8 =
phy_addr, u8 offset, u32 chip_id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return phy_data;
> =C2=A0}
>
> -static u16 phy_readby_cr10(unsigned long iobase, u8 phy_addr, u8 off=
set)
> +static u16 phy_readby_cr10(void __iomem *iobase, u8 phy_addr, u8 off=
set)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr,cr10_value;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D iobase + DCR10;
> + =C2=A0 =C2=A0 =C2=A0 u32 cr10_value;
>
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR10;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cr10_value =3D phy_addr;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<5) + offset;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<16) + 0x08000000;
> - =C2=A0 =C2=A0 =C2=A0 outl(cr10_value,ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << =C2=A05) + offse=
t;
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << 16) + 0x08000000=
;
> + =C2=A0 =C2=A0 =C2=A0 outl(cr10_value, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> - =C2=A0 =C2=A0 =C2=A0 while(1)
> - =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 while(1) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cr10_value =3D=
 inl(ioaddr);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(cr10_value&0x10=
000000)
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
> +static void phy_writeby_cr10(void __iomem *iobase, u8 phy_addr, u8 o=
ffset,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long ioaddr,cr10_value;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D iobase + DCR10;
> + =C2=A0 =C2=A0 =C2=A0 u32 cr10_value;
>
> - =C2=A0 =C2=A0 =C2=A0 ioaddr =3D iobase + DCR10;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cr10_value =3D phy_addr;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<5) + offset;
> - =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value<<16) + 0x04000000 +=
 phy_data;
> - =C2=A0 =C2=A0 =C2=A0 outl(cr10_value,ioaddr);
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << =C2=A05) + offse=
t;
> + =C2=A0 =C2=A0 =C2=A0 cr10_value =3D (cr10_value << 16) + 0x04000000=
 + phy_data;
> + =C2=A0 =C2=A0 =C2=A0 outl(cr10_value, ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> =C2=A0}
> =C2=A0/*
> =C2=A0* =C2=A0 =C2=A0 Write one bit data to Phy Controller
> =C2=A0*/
>
> -static void phy_write_1bit(unsigned long ioaddr, u32 phy_data, u32 c=
hip_id)
> +static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data, u32 c=
hip_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(phy_data , ioaddr); =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* MI=
I Clock Low */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(1);
> @@ -1755,7 +1763,7 @@ static void phy_write_1bit(unsigned long ioaddr=
, u32 phy_data, u32 chip_id)
> =C2=A0* =C2=A0 =C2=A0 Read one bit phy data from PHY controller
> =C2=A0*/
>
> -static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
> +static u16 phy_read_1bit(void __iomem *ioaddr, u32 chip_id)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 phy_data;
>
> --
> 1.7.7.6
>
