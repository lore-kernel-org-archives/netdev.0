From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 25/39] xircom_cb: stop using
 net_device.{base_addr, irq} and convert to __iomem.
Date: Fri, 6 Apr 2012 09:42:15 -0700
Message-ID: <CANEJEGu9fFNJN6BcmS4xPXgcQGjyrKRzoS9iOCGxWXtizM+k9A@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<d8cb2b1097a9c64778dc1ab9bb33bcf5bf62bfc7.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40473 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110Ab2DFQmQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:42:16 -0400
Received: by obbtb18 with SMTP id tb18so3285408obb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 09:42:15 -0700 (PDT)
In-Reply-To: <d8cb2b1097a9c64778dc1ab9bb33bcf5bf62bfc7.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:06 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

Similar to dmfe driver, possible MMIO write/udelay issue that can be
fixed later if the device actually offers MMIO registers.
(I'm looking at the hunk in initialize_card()).

Note that udelay() is just the easier-to-find case where posted writes
can cause problems. Other cases include disabling part of the chip
(e.g. receive engine) but the MMIO write is posted and the engine
isn't actually disabled until "much later". This is a problem if the
next section of code depends on chip being disabled and (for example)
starts tearing down or rebuilding shared memory
(dma_alloc_consistent).

To be clear, I don't see any "real bug" - just potential issues.
That's why I'd rather see this patch go in and address the potential
issues in a future patch.

thanks,
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/xircom_cb.c | =C2=A0227 ++++++++=
+++++++-------------
> =C2=A01 files changed, 124 insertions(+), 103 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net=
/ethernet/dec/tulip/xircom_cb.c
> index cbcc6d6..138bf83 100644
> --- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
> +++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> @@ -41,7 +41,9 @@ MODULE_DESCRIPTION("Xircom Cardbus ethernet driver"=
);
> =C2=A0MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
> =C2=A0MODULE_LICENSE("GPL");
>
> -
> +#define xw32(reg, val) iowrite32(val, ioaddr + (reg))
> +#define xr32(reg) =C2=A0 =C2=A0 =C2=A0ioread32(ioaddr + (reg))
> +#define xr8(reg) =C2=A0 =C2=A0 =C2=A0 ioread8(ioaddr + (reg))
>
> =C2=A0/* IO registers on the card, offsets */
> =C2=A0#define CSR0 =C2=A0 0x00
> @@ -83,7 +85,7 @@ struct xircom_private {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *tx_skb[4];
>
> - =C2=A0 =C2=A0 =C2=A0 unsigned long io_port;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int open;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit_used is the rotating counter t=
hat indicates which transmit
> @@ -137,7 +139,7 @@ static int link_status(struct xircom_private *car=
d);
>
>
> =C2=A0static DEFINE_PCI_DEVICE_TABLE(xircom_pci_table) =3D {
> - =C2=A0 =C2=A0 =C2=A0 {0x115D, 0x0003, PCI_ANY_ID, PCI_ANY_ID,},
> + =C2=A0 =C2=A0 =C2=A0 { PCI_VDEVICE(XIRCOM, 0x0003), },
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{0,},
> =C2=A0};
> =C2=A0MODULE_DEVICE_TABLE(pci, xircom_pci_table);
> @@ -146,9 +148,7 @@ static struct pci_driver xircom_ops =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D=
 "xircom_cb",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.id_table =C2=A0 =C2=A0 =C2=A0 =3D xircom_=
pci_table,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.probe =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 xircom_probe,
> - =C2=A0 =C2=A0 =C2=A0 .remove =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D xircom=
_remove,
> - =C2=A0 =C2=A0 =C2=A0 .suspend =3DNULL,
> - =C2=A0 =C2=A0 =C2=A0 .resume =3DNULL
> + =C2=A0 =C2=A0 =C2=A0 .remove =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D __deve=
xit_p(xircom_remove),
> =C2=A0};
>
>
> @@ -253,10 +253,13 @@ static int __devinit xircom_probe(struct pci_de=
v *pdev, const struct pci_device_
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0private->dev =3D dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0private->pdev =3D pdev;
> - =C2=A0 =C2=A0 =C2=A0 private->io_port =3D pci_resource_start(pdev, =
0);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* IO range. */
> + =C2=A0 =C2=A0 =C2=A0 private->ioaddr =3D pci_iomap(pdev, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!private->ioaddr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto reg_fail;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&private->lock);
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D private->io_port;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0initialize_card(private);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_mac_address(private);
> @@ -268,7 +271,7 @@ static int __devinit xircom_probe(struct pci_dev =
*pdev, const struct pci_device_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D register_netdev(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: ne=
tdevice registration failed\n", __func__);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto reg_fail;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_unmap;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_info(dev, "Xircom cardbus revision =
%i at irq %i\n",
> @@ -286,6 +289,8 @@ static int __devinit xircom_probe(struct pci_dev =
*pdev, const struct pci_device_
> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return rc;
>
> +err_unmap:
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, private->ioaddr);
> =C2=A0reg_fail:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, private->tx_buf=
fer, private->tx_dma_handle);
> @@ -314,6 +319,7 @@ static void __devexit xircom_remove(struct pci_de=
v *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct device *d =3D &pdev->dev;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unregister_netdev(dev);
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, card->ioaddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, card->tx_buffer=
, card->tx_dma_handle);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, card->rx_buffer=
, card->rx_dma_handle);
> @@ -326,11 +332,12 @@ static irqreturn_t xircom_interrupt(int irq, vo=
id *dev_instance)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D (struct net_dev=
ice *) dev_instance;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct xircom_private *card =3D netdev_pri=
v(dev);
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int status;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&card->lock);
> - =C2=A0 =C2=A0 =C2=A0 status =3D inl(card->io_port+CSR5);
> + =C2=A0 =C2=A0 =C2=A0 status =3D xr32(CSR5);
>
> =C2=A0#if defined DEBUG && DEBUG > 1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0print_binary(status);
> @@ -360,7 +367,7 @@ static irqreturn_t xircom_interrupt(int irq, void=
 *dev_instance)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Clear all remaining interrupts */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0status |=3D 0xffffffff; /* FIXME: make thi=
s clear only the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0r=
eal existing bits */
> - =C2=A0 =C2=A0 =C2=A0 outl(status,card->io_port+CSR5);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR5, status);
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i=3D0;i<NUMDESCRIPTORS;i++)
> @@ -438,11 +445,11 @@ static netdev_tx_t xircom_start_xmit(struct sk_=
buff *skb,
> =C2=A0static int xircom_open(struct net_device *dev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct xircom_private *xp =3D netdev_priv(=
dev);
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D xp->pdev->irq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int retval;
>
> - =C2=A0 =C2=A0 =C2=A0 netdev_info(dev, "xircom cardbus adaptor found=
, using irq %i\n",
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev-=
>irq);
> - =C2=A0 =C2=A0 =C2=A0 retval =3D request_irq(dev->irq, xircom_interr=
upt, IRQF_SHARED, dev->name, dev);
> + =C2=A0 =C2=A0 =C2=A0 netdev_info(dev, "xircom cardbus adaptor found=
, using irq %i\n", irq);
> + =C2=A0 =C2=A0 =C2=A0 retval =3D request_irq(irq, xircom_interrupt, =
IRQF_SHARED, dev->name, dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (retval)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return retval;
>
> @@ -474,7 +481,7 @@ static int xircom_close(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&card->lock,flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0card->open =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq,dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(card->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> @@ -484,35 +491,39 @@ static int xircom_close(struct net_device *dev)
> =C2=A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =C2=A0static void xircom_poll_controller(struct net_device *dev)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 disable_irq(dev->irq);
> - =C2=A0 =C2=A0 =C2=A0 xircom_interrupt(dev->irq, dev);
> - =C2=A0 =C2=A0 =C2=A0 enable_irq(dev->irq);
> + =C2=A0 =C2=A0 =C2=A0 struct xircom_private *xp =3D netdev_priv(dev)=
;
> + =C2=A0 =C2=A0 =C2=A0 const int irq =3D xp->pdev->irq;
> +
> + =C2=A0 =C2=A0 =C2=A0 disable_irq(irq);
> + =C2=A0 =C2=A0 =C2=A0 xircom_interrupt(irq, dev);
> + =C2=A0 =C2=A0 =C2=A0 enable_irq(irq);
> =C2=A0}
> =C2=A0#endif
>
>
> =C2=A0static void initialize_card(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> + =C2=A0 =C2=A0 =C2=A0 u32 val;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&card->lock, flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* First: reset the card */
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR0);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D 0x01; =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Software reset */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR0);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR0, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(100); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* give the card some time to reset */
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR0);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val &=3D ~0x01; =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* disable Software reset */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR0);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR0, val);
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D 0; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Value 0x00 is a safe and conservative value
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for the PCI configura=
tion settings */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR0);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR0, val);
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0disable_all_interrupts(card);
> @@ -530,10 +541,9 @@ ignored; I chose zero.
> =C2=A0*/
> =C2=A0static void trigger_transmit(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR1);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR1, 0);
> =C2=A0}
>
> =C2=A0/*
> @@ -545,10 +555,9 @@ ignored; I chose zero.
> =C2=A0*/
> =C2=A0static void trigger_receive(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR2);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR2, 0);
> =C2=A0}
>
> =C2=A0/*
> @@ -557,6 +566,7 @@ descriptors and programs the addresses into the c=
ard.
> =C2=A0*/
> =C2=A0static void setup_descriptors(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 address;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>
> @@ -586,7 +596,7 @@ static void setup_descriptors(struct xircom_priva=
te *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wmb();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Write the receive descriptor ring addre=
ss to the card */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0address =3D card->rx_dma_handle;
> - =C2=A0 =C2=A0 =C2=A0 outl(address, card->io_port + CSR3); =C2=A0 =C2=
=A0/* Receive descr list address */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR3, address); =C2=A0 =C2=A0/* Receive d=
escr list address */
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit descriptors */
> @@ -611,7 +621,7 @@ static void setup_descriptors(struct xircom_priva=
te *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wmb();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* wite the transmit descriptor ring to th=
e card */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0address =3D card->tx_dma_handle;
> - =C2=A0 =C2=A0 =C2=A0 outl(address, card->io_port + CSR4); =C2=A0 =C2=
=A0/* xmit descr list address */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR4, address); =C2=A0 =C2=A0/* xmit desc=
r list address */
> =C2=A0}
>
> =C2=A0/*
> @@ -620,11 +630,12 @@ valid by setting the address in the card to 0x0=
0.
> =C2=A0*/
> =C2=A0static void remove_descriptors(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR3); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Receive descriptor address */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR4); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Send descriptor address */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR3, val); =C2=A0 =C2=A0 =C2=A0 =C2=A0/*=
 Receive descriptor address */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR4, val); =C2=A0 =C2=A0 =C2=A0 =C2=A0/*=
 Send descriptor address */
> =C2=A0}
>
> =C2=A0/*
> @@ -635,17 +646,17 @@ This function also clears the status-bit.
> =C2=A0*/
> =C2=A0static int link_status_changed(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR5); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Status register */
> -
> - =C2=A0 =C2=A0 =C2=A0 if ((val & (1 << 27)) =3D=3D 0) =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* no change */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR5); =C2=A0 =C2=A0 =C2=A0 /* St=
atus register */
> + =C2=A0 =C2=A0 =C2=A0 if (!(val & (1 << 27))) /* no change */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* clear the event by writing a 1 to the b=
it in the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 status register. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D (1 << 27);
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR5);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR5, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0}
> @@ -657,11 +668,9 @@ in a non-stopped state.
> =C2=A0*/
> =C2=A0static int transmit_active(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR5); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Status register */
> -
> - =C2=A0 =C2=A0 =C2=A0 if ((val & (7 << 20)) =3D=3D 0) =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* transmitter disabled */
> + =C2=A0 =C2=A0 =C2=A0 if (!(xr32(CSR5) & (7 << 20))) =C2=A0/* transm=
itter disabled */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> @@ -673,11 +682,9 @@ in a non-stopped state.
> =C2=A0*/
> =C2=A0static int receive_active(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> -
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR5); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Status register */
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
>
> - =C2=A0 =C2=A0 =C2=A0 if ((val & (7 << 17)) =3D=3D 0) =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* receiver disabled */
> + =C2=A0 =C2=A0 =C2=A0 if (!(xr32(CSR5) & (7 << 17))) =C2=A0/* receiv=
er disabled */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> @@ -695,10 +702,11 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void activate_receiver(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int counter;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If the "active" bit is set and the rece=
iver is already
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 active, no need to do the expensiv=
e thing */
> @@ -707,7 +715,7 @@ static void activate_receiver(struct xircom_priva=
te *card)
>
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D val & ~2; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* disable the receiver */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 10;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (counter > 0) {
> @@ -721,9 +729,9 @@ static void activate_receiver(struct xircom_priva=
te *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable the receiver */
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> - =C2=A0 =C2=A0 =C2=A0 val =3D val | 2; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable th=
e receiver */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D val | 2; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* enable the receiver */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* now wait for the card to activate again=
 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 10;
> @@ -748,12 +756,13 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void deactivate_receiver(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int counter;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> - =C2=A0 =C2=A0 =C2=A0 val =3D val & ~2; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* disable the =
receiver */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D val & ~2; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
/* disable the receiver */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 10;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (counter > 0) {
> @@ -780,10 +789,11 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void activate_transmitter(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int counter;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If the "active" bit is set and the rece=
iver is already
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 active, no need to do the expensiv=
e thing */
> @@ -791,7 +801,7 @@ static void activate_transmitter(struct xircom_pr=
ivate *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D val & ~(1 << 13); /* disable the t=
ransmitter */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 10;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (counter > 0) {
> @@ -806,9 +816,9 @@ static void activate_transmitter(struct xircom_pr=
ivate *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable the transmitter */
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D val | (1 << 13); =C2=A0/* enable t=
he transmitter */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* now wait for the card to activate again=
 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 10;
> @@ -833,12 +843,13 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void deactivate_transmitter(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int counter;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Operation mode */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6); =C2=A0 =C2=A0 =C2=A0 /* Op=
eration mode */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D val & ~2; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* disable the transmitter */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0counter =3D 20;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (counter > 0) {
> @@ -861,11 +872,12 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void enable_transmit_interrupt(struct xircom_private *ca=
rd)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR7); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Interrupt enable register */
> - =C2=A0 =C2=A0 =C2=A0 val |=3D 1; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
/* enable the transmit interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR7);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR7); =C2=A0 =C2=A0 =C2=A0 /* In=
terrupt enable register */
> + =C2=A0 =C2=A0 =C2=A0 val |=3D 1; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* enable the transmit interrupt */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR7, val);
> =C2=A0}
>
>
> @@ -876,11 +888,12 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void enable_receive_interrupt(struct xircom_private *car=
d)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR7); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Interrupt enable register */
> - =C2=A0 =C2=A0 =C2=A0 val =3D val | (1 << 6); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* enable the receive interrupt =
*/
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR7);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR7); =C2=A0 =C2=A0 =C2=A0 /* In=
terrupt enable register */
> + =C2=A0 =C2=A0 =C2=A0 val =3D val | (1 << 6); =C2=A0 /* enable the r=
eceive interrupt */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR7, val);
> =C2=A0}
>
> =C2=A0/*
> @@ -890,11 +903,12 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static void enable_link_interrupt(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR7); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Interrupt enable register */
> - =C2=A0 =C2=A0 =C2=A0 val =3D val | (1 << 27); =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable the link status chag=
e interrupt */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR7);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR7); =C2=A0 =C2=A0 =C2=A0 /* In=
terrupt enable register */
> + =C2=A0 =C2=A0 =C2=A0 val =3D val | (1 << 27); =C2=A0/* enable the l=
ink status chage interrupt */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR7, val);
> =C2=A0}
>
>
> @@ -906,10 +920,9 @@ must be called with the lock held and interrupts=
 disabled.
> =C2=A0*/
> =C2=A0static void disable_all_interrupts(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D 0; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0/* disable all interrupts */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR7);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR7, 0);
> =C2=A0}
>
> =C2=A0/*
> @@ -919,9 +932,10 @@ must be called with the lock held and interrupts=
 disabled.
> =C2=A0*/
> =C2=A0static void enable_common_interrupts(struct xircom_private *car=
d)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR7); =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Interrupt enable register */
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR7); =C2=A0 =C2=A0 =C2=A0 /* In=
terrupt enable register */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<16); /* Normal Interrupt Summ=
ary */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<15); /* Abnormal Interrupt Su=
mmary */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<13); /* Fatal bus error */
> @@ -930,7 +944,7 @@ static void enable_common_interrupts(struct xirco=
m_private *card)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<5); =C2=A0/* Transmit Underfl=
ow */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<2); =C2=A0/* Transmit Buffer =
Unavailable */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val |=3D (1<<1); =C2=A0/* Transmit Process=
 Stopped */
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR7);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR7, val);
> =C2=A0}
>
> =C2=A0/*
> @@ -940,11 +954,12 @@ must be called with the lock held and interrupt=
s disabled.
> =C2=A0*/
> =C2=A0static int enable_promisc(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inl(card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr32(CSR6);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0val =3D val | (1 << 6);
> - =C2=A0 =C2=A0 =C2=A0 outl(val, card->io_port + CSR6);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR6, val);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> =C2=A0}
> @@ -959,13 +974,16 @@ Must be called in locked state with interrupts =
disabled
> =C2=A0*/
> =C2=A0static int link_status(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned int val;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> + =C2=A0 =C2=A0 =C2=A0 u8 val;
>
> - =C2=A0 =C2=A0 =C2=A0 val =3D inb(card->io_port + CSR12);
> + =C2=A0 =C2=A0 =C2=A0 val =3D xr8(CSR12);
>
> - =C2=A0 =C2=A0 =C2=A0 if (!(val&(1<<2))) =C2=A0/* bit 2 is 0 for 10m=
bit link, 1 for not an 10mbit link */
> + =C2=A0 =C2=A0 =C2=A0 /* bit 2 is 0 for 10mbit link, 1 for not an 10=
mbit link */
> + =C2=A0 =C2=A0 =C2=A0 if (!(val & (1 << 2)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 10;
> - =C2=A0 =C2=A0 =C2=A0 if (!(val&(1<<1))) =C2=A0/* bit 1 is 0 for 100=
mbit link, 1 for not an 100mbit link */
> + =C2=A0 =C2=A0 =C2=A0 /* bit 1 is 0 for 100mbit link, 1 for not an 1=
00mbit link */
> + =C2=A0 =C2=A0 =C2=A0 if (!(val & (1 << 1)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 100;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If we get here -> no link at all */
> @@ -984,29 +1002,31 @@ static int link_status(struct xircom_private *=
card)
> =C2=A0*/
> =C2=A0static void read_mac_address(struct xircom_private *card)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned char j, tuple, link, data_id, data_co=
unt;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> + =C2=A0 =C2=A0 =C2=A0 u8 link;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&card->lock, flags);
>
> - =C2=A0 =C2=A0 =C2=A0 outl(1 << 12, card->io_port + CSR9); =C2=A0 =C2=
=A0/* enable boot rom access */
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR9, 1 << 12); =C2=A0 =C2=A0/* enable bo=
ot rom access */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0x100; i < 0x1f7; i +=3D link +=
 2) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(i, card->io_p=
ort + CSR10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tuple =3D inl(card=
->io_port + CSR9) & 0xff;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(i + 1, card->=
io_port + CSR10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 link =3D inl(card-=
>io_port + CSR9) & 0xff;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(i + 2, card->=
io_port + CSR10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data_id =3D inl(ca=
rd->io_port + CSR9) & 0xff;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(i + 3, card->=
io_port + CSR10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data_count =3D inl=
(card->io_port + CSR9) & 0xff;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u8 tuple, data_id,=
 data_count;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xw32(CSR10, i);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tuple =3D xr32(CSR=
9);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xw32(CSR10, i + 1)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 link =3D xr32(CSR9=
);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xw32(CSR10, i + 2)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data_id =3D xr32(C=
SR9);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xw32(CSR10, i + 3)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data_count =3D xr3=
2(CSR9);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((tuple =3D=
=3D 0x22) && (data_id =3D=3D 0x04) && (data_count =3D=3D 0x06)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* This is it. =C2=A0We have the data we want.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 int j;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0for (j =3D 0; j < 6; j++) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 outl(i + j + 4, card->io_port + CSR=
10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 card->dev->dev_addr[j] =3D inl(card=
->io_port + CSR9) & 0xff;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 xw32(CSR10, i + j + 4);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 card->dev->dev_addr[j] =3D xr32(CSR=
9) & 0xff;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (lin=
k =3D=3D 0) {
> @@ -1025,6 +1045,7 @@ static void read_mac_address(struct xircom_priv=
ate *card)
> =C2=A0*/
> =C2=A0static void transceiver_voodoo(struct xircom_private *card)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *ioaddr =3D card->ioaddr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable all powermanagement */
> @@ -1034,14 +1055,14 @@ static void transceiver_voodoo(struct xircom_=
private *card)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&card->lock, flags);
>
> - =C2=A0 =C2=A0 =C2=A0 outl(0x0008, card->io_port + CSR15);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(25);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(0xa8050000, card->io_port + CSR15);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(25);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0outl(0xa00f0000, card->io_port + CSR15);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0udelay(25);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR15, 0x0008);
> + =C2=A0 =C2=A0 =C2=A0 udelay(25);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR15, 0xa8050000);
> + =C2=A0 =C2=A0 =C2=A0 udelay(25);
> + =C2=A0 =C2=A0 =C2=A0 xw32(CSR15, 0xa00f0000);
> + =C2=A0 =C2=A0 =C2=A0 udelay(25);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&card->lock, flag=
s);
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&card->lock, flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_start_queue(card->dev);
> =C2=A0}
> --
> 1.7.7.6
>
