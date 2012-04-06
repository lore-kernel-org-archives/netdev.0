From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next #2 24/39] xircom_cb: fix device probe error path.
Date: Fri, 6 Apr 2012 09:56:09 -0700
Message-ID: <CANEJEGucRU5qkWGekPHr8r3TA0Xb3NFqN6SkNzfpBqR=cwWDrQ@mail.gmail.com>
References: <1333704408.git.romieu@fr.zoreil.com>
	<271dcd170006b9d55eb555b2e79e22c1fa86e0a0.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39183 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab2DFQ4K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:56:10 -0400
Received: by gghe5 with SMTP id e5so1323743ggh.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 09:56:09 -0700 (PDT)
In-Reply-To: <271dcd170006b9d55eb555b2e79e22c1fa86e0a0.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 3:06 AM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> - unbalanced pci_disable_device
> - PCI ressources were not released
> - mismatching pci_alloc_.../kfree pairs are replaced by DMA alloc hel=
pers.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

Very nice - thank you! :)

grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/xircom_cb.c | =C2=A0 53 ++++++++=
++++++++++----------
> =C2=A01 files changed, 34 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net=
/ethernet/dec/tulip/xircom_cb.c
> index fdb329f..cbcc6d6 100644
> --- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
> +++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> @@ -192,15 +192,18 @@ static const struct net_device_ops netdev_ops =3D=
 {
> =C2=A0*/
> =C2=A0static int __devinit xircom_probe(struct pci_dev *pdev, const s=
truct pci_device_id *id)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 struct device *d =3D &pdev->dev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct xircom_private *private;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned short tmp16;
> + =C2=A0 =C2=A0 =C2=A0 int rc;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* First do the PCI initialisation */
>
> - =C2=A0 =C2=A0 =C2=A0 if (pci_enable_device(pdev))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENODEV;
> + =C2=A0 =C2=A0 =C2=A0 rc =3D pci_enable_device(pdev);
> + =C2=A0 =C2=A0 =C2=A0 if (rc < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disable all powermanagement */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_write_config_dword(pdev, PCI_POWERMGMT=
, 0x0000);
> @@ -211,11 +214,13 @@ static int __devinit xircom_probe(struct pci_de=
v *pdev, const struct pci_device_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_read_config_word (pdev,PCI_STATUS, &tm=
p16);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_write_config_word (pdev, PCI_STATUS,tm=
p16);
>
> - =C2=A0 =C2=A0 =C2=A0 if (!request_region(pci_resource_start(pdev, 0=
), 128, "xircom_cb")) {
> + =C2=A0 =C2=A0 =C2=A0 rc =3D pci_request_regions(pdev, "xircom_cb");
> + =C2=A0 =C2=A0 =C2=A0 if (rc < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: fa=
iled to allocate io-region\n", __func__);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENODEV;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_disable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 rc =3D -ENOMEM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Before changing the hardware, allo=
cate the memory.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 This way, we can fail gracefully i=
f not enough memory
> @@ -223,17 +228,21 @@ static int __devinit xircom_probe(struct pci_de=
v *pdev, const struct pci_device_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev =3D alloc_etherdev(sizeof(struct xirco=
m_private));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!dev)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto device_fail;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_release;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0private =3D netdev_priv(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Allocate the send/receive buffers */
> - =C2=A0 =C2=A0 =C2=A0 private->rx_buffer =3D pci_alloc_consistent(pd=
ev,8192,&private->rx_dma_handle);
> + =C2=A0 =C2=A0 =C2=A0 private->rx_buffer =3D dma_alloc_coherent(d, 8=
192,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 &private->rx_dma_handle,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 GFP_KERNEL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (private->rx_buffer =3D=3D NULL) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: no=
 memory for rx buffer\n", __func__);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto rx_buf_fa=
il;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 private->tx_buffer =3D pci_alloc_consistent(pd=
ev,8192,&private->tx_dma_handle);
> + =C2=A0 =C2=A0 =C2=A0 private->tx_buffer =3D dma_alloc_coherent(d, 8=
192,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 &private->tx_dma_handle,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 GFP_KERNEL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (private->tx_buffer =3D=3D NULL) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: no=
 memory for tx buffer\n", __func__);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto tx_buf_fa=
il;
> @@ -256,7 +265,8 @@ static int __devinit xircom_probe(struct pci_dev =
*pdev, const struct pci_device_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D &netdev_ops;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, dev);
>
> - =C2=A0 =C2=A0 =C2=A0 if (register_netdev(dev)) {
> + =C2=A0 =C2=A0 =C2=A0 rc =3D register_netdev(dev);
> + =C2=A0 =C2=A0 =C2=A0 if (rc < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("%s: ne=
tdevice registration failed\n", __func__);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto reg_fail;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -273,17 +283,21 @@ static int __devinit xircom_probe(struct pci_de=
v *pdev, const struct pci_device_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&private->lock,flag=
s);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0trigger_receive(private);
> -
> - =C2=A0 =C2=A0 =C2=A0 return 0;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return rc;
>
> =C2=A0reg_fail:
> - =C2=A0 =C2=A0 =C2=A0 kfree(private->tx_buffer);
> + =C2=A0 =C2=A0 =C2=A0 pci_set_drvdata(pdev, NULL);
> + =C2=A0 =C2=A0 =C2=A0 dma_free_coherent(d, 8192, private->tx_buffer,=
 private->tx_dma_handle);
> =C2=A0tx_buf_fail:
> - =C2=A0 =C2=A0 =C2=A0 kfree(private->rx_buffer);
> + =C2=A0 =C2=A0 =C2=A0 dma_free_coherent(d, 8192, private->rx_buffer,=
 private->rx_dma_handle);
> =C2=A0rx_buf_fail:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_netdev(dev);
> -device_fail:
> - =C2=A0 =C2=A0 =C2=A0 return -ENODEV;
> +err_release:
> + =C2=A0 =C2=A0 =C2=A0 pci_release_regions(pdev);
> +err_disable:
> + =C2=A0 =C2=A0 =C2=A0 pci_disable_device(pdev);
> + =C2=A0 =C2=A0 =C2=A0 goto out;
> =C2=A0}
>
>
> @@ -297,14 +311,15 @@ static void __devexit xircom_remove(struct pci_=
dev *pdev)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D pci_get_drvdata=
(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct xircom_private *card =3D netdev_pri=
v(dev);
> + =C2=A0 =C2=A0 =C2=A0 struct device *d =3D &pdev->dev;
>
> - =C2=A0 =C2=A0 =C2=A0 pci_free_consistent(pdev,8192,card->rx_buffer,=
card->rx_dma_handle);
> - =C2=A0 =C2=A0 =C2=A0 pci_free_consistent(pdev,8192,card->tx_buffer,=
card->tx_dma_handle);
> -
> - =C2=A0 =C2=A0 =C2=A0 release_region(dev->base_addr, 128);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unregister_netdev(dev);
> - =C2=A0 =C2=A0 =C2=A0 free_netdev(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_drvdata(pdev, NULL);
> + =C2=A0 =C2=A0 =C2=A0 dma_free_coherent(d, 8192, card->tx_buffer, ca=
rd->tx_dma_handle);
> + =C2=A0 =C2=A0 =C2=A0 dma_free_coherent(d, 8192, card->rx_buffer, ca=
rd->rx_dma_handle);
> + =C2=A0 =C2=A0 =C2=A0 free_netdev(dev);
> + =C2=A0 =C2=A0 =C2=A0 pci_release_regions(pdev);
> + =C2=A0 =C2=A0 =C2=A0 pci_disable_device(pdev);
> =C2=A0}
>
> =C2=A0static irqreturn_t xircom_interrupt(int irq, void *dev_instance=
)
> --
> 1.7.7.6
>
