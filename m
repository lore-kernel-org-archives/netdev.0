From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next 25/34] xircom_cb: stop using net_device.{base_addr,
 irq} and convert to __iomem.
Date: Tue, 3 Apr 2012 18:23:24 -0700
Message-ID: <CANEJEGsLvVLFQJjBMceLMF+v1A6iq_Jj5JwDHikvKnNfSHfvKg@mail.gmail.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
	<d01b498a140cc8f7245d2c05443706807f62e62a.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41794 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818Ab2DDBXY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 21:23:24 -0400
Received: by obbtb18 with SMTP id tb18so472485obb.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 18:23:24 -0700 (PDT)
In-Reply-To: <d01b498a140cc8f7245d2c05443706807f62e62a.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 6:57 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>
> ---
> =C2=A0drivers/net/ethernet/dec/tulip/xircom_cb.c | =C2=A0 37 ++++++++=
++++++++++----------
> =C2=A01 files changed, 24 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net=
/ethernet/dec/tulip/xircom_cb.c
> index cbcc6d6..4aed477 100644
> --- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
> +++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> @@ -41,7 +41,9 @@ MODULE_DESCRIPTION("Xircom Cardbus ethernet driver"=
);
> =C2=A0MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
> =C2=A0MODULE_LICENSE("GPL");
>
> -
> +#define outl =C2=A0 iowrite32
> +#define inl =C2=A0 =C2=A0ioread32
> +#define inb =C2=A0 =C2=A0ioread8

Everything but the hunk to redefine inl/outl functions looks good to
me. IIRC, you offered to resubmit with outl/inl calls replaced with
respective iowrite/ioread calls. I still think that's preferable even
if the patch is much bigger.

thanks,
grant

>
> =C2=A0/* IO registers on the card, offsets */
> =C2=A0#define CSR0 =C2=A0 0x00
> @@ -83,7 +85,7 @@ struct xircom_private {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *tx_skb[4];
>
> - =C2=A0 =C2=A0 =C2=A0 unsigned long io_port;
> + =C2=A0 =C2=A0 =C2=A0 void __iomem *io_port;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int open;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* transmit_used is the rotating counter t=
hat indicates which transmit
> @@ -253,10 +255,13 @@ static int __devinit xircom_probe(struct pci_de=
v *pdev, const struct pci_device_
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0private->dev =3D dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0private->pdev =3D pdev;
> - =C2=A0 =C2=A0 =C2=A0 private->io_port =3D pci_resource_start(pdev, =
0);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* IO range. */
> + =C2=A0 =C2=A0 =C2=A0 private->io_port =3D pci_iomap(pdev, 0, 0);
> + =C2=A0 =C2=A0 =C2=A0 if (!private->io_port)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto reg_fail;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&private->lock);
> - =C2=A0 =C2=A0 =C2=A0 dev->irq =3D pdev->irq;
> - =C2=A0 =C2=A0 =C2=A0 dev->base_addr =3D private->io_port;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0initialize_card(private);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_mac_address(private);
> @@ -268,7 +273,7 @@ static int __devinit xircom_probe(struct pci_dev =
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
> @@ -286,6 +291,8 @@ static int __devinit xircom_probe(struct pci_dev =
*pdev, const struct pci_device_
> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return rc;
>
> +err_unmap:
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, private->io_port);
> =C2=A0reg_fail:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, private->tx_buf=
fer, private->tx_dma_handle);
> @@ -314,6 +321,7 @@ static void __devexit xircom_remove(struct pci_de=
v *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct device *d =3D &pdev->dev;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unregister_netdev(dev);
> + =C2=A0 =C2=A0 =C2=A0 pci_iounmap(pdev, card->io_port);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, card->tx_buffer=
, card->tx_dma_handle);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dma_free_coherent(d, 8192, card->rx_buffer=
, card->rx_dma_handle);
> @@ -438,11 +446,11 @@ static netdev_tx_t xircom_start_xmit(struct sk_=
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
> @@ -474,7 +482,7 @@ static int xircom_close(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&card->lock,flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0card->open =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 free_irq(dev->irq,dev);
> + =C2=A0 =C2=A0 =C2=A0 free_irq(card->pdev->irq, dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> @@ -484,9 +492,12 @@ static int xircom_close(struct net_device *dev)
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
> --
> 1.7.7.6
>
