From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net-next 23/34] uli526x: fix regions leak in driver probe
 error path.
Date: Wed, 4 Apr 2012 12:10:47 -0700
Message-ID: <CANEJEGsFOBKi2CF+wpfLA695z_uTa2O1akmBCOT5vb3WNHPJqg@mail.gmail.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
	<cc6d6ac73b8297d3eda5ef20a83a1eb0587b52e9.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55245 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932371Ab2DDTKs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 15:10:48 -0400
Received: by yhmm54 with SMTP id m54so379721yhm.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 12:10:47 -0700 (PDT)
In-Reply-To: <cc6d6ac73b8297d3eda5ef20a83a1eb0587b52e9.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 6:57 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Grant Grundler <grundler@parisc-linux.org>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

cheers,
grant

> ---
> =C2=A0drivers/net/ethernet/dec/tulip/uli526x.c | =C2=A0 48 ++++++++++=
++-----------------
> =C2=A01 files changed, 20 insertions(+), 28 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/e=
thernet/dec/tulip/uli526x.c
> index fc4001f..c9b3396 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -313,9 +313,9 @@ static int __devinit uli526x_init_one (struct pci=
_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_d=
isable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 if (pci_request_regions(pdev, DRV_NAME)) {
> + =C2=A0 =C2=A0 =C2=A0 err =3D pci_request_regions(pdev, DRV_NAME);
> + =C2=A0 =C2=A0 =C2=A0 if (err < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_err("Failed=
 to request PCI regions\n");
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D -ENODEV;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_out_d=
isable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -323,18 +323,15 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db =3D netdev_priv(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Allocate Tx/Rx descriptor memory */
> + =C2=A0 =C2=A0 =C2=A0 err =3D -ENOMEM;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->desc_pool_ptr =3D pci_alloc_consistent=
(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma=
_ptr);
> - =C2=A0 =C2=A0 =C2=A0 if(db->desc_pool_ptr =3D=3D NULL)
> - =C2=A0 =C2=A0 =C2=A0 {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D -ENOMEM;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_nomem=
;
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (!db->desc_pool_ptr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_relea=
se;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_ptr =3D pci_alloc_consistent(=
pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
> - =C2=A0 =C2=A0 =C2=A0 if(db->buf_pool_ptr =3D=3D NULL)
> - =C2=A0 =C2=A0 =C2=A0 {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D -ENOMEM;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_nomem=
;
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (!db->buf_pool_ptr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
tx_desc;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_tx_desc =3D (struct tx_desc *) d=
b->desc_pool_ptr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0db->first_tx_desc_dma =3D db->desc_pool_dm=
a_ptr;
> @@ -387,7 +384,7 @@ static int __devinit uli526x_init_one (struct pci=
_dev *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D register_netdev (dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_res;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_free_=
tx_buf;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_info(dev, "ULi M%04lx at pci%s, %pM=
, irq %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
ent->driver_data >> 16, pci_name(pdev),
> @@ -397,16 +394,14 @@ static int __devinit uli526x_init_one (struct p=
ci_dev *pdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> -err_out_res:
> +err_out_free_tx_buf:
> + =C2=A0 =C2=A0 =C2=A0 pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DE=
SC_CNT + 4,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 db->buf_pool_ptr, db->buf_pool_dma_ptr);
> +err_out_free_tx_desc:
> + =C2=A0 =C2=A0 =C2=A0 pci_free_consistent(pdev, sizeof(struct tx_des=
c) * DESC_ALL_CNT + 0x20,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 db->desc_pool_ptr, db->desc_pool_dma_ptr);
> +err_out_release:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_release_regions(pdev);
> -err_out_nomem:
> - =C2=A0 =C2=A0 =C2=A0 if(db->desc_pool_ptr)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_free_consisten=
t(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 db->desc_pool_ptr, db->desc_pool_dma_ptr);
> -
> - =C2=A0 =C2=A0 =C2=A0 if(db->buf_pool_ptr !=3D NULL)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_free_consisten=
t(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 db->buf_pool_ptr, db->buf_pool_dma_ptr);
> =C2=A0err_out_disable:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> =C2=A0err_out_free:
> @@ -422,19 +417,16 @@ static void __devexit uli526x_remove_one (struc=
t pci_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net_device *dev =3D pci_get_drvdata=
(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct uli526x_board_info *db =3D netdev_p=
riv(dev);
>
> - =C2=A0 =C2=A0 =C2=A0 ULI526X_DBUG(0, "uli526x_remove_one()", 0);
> -
> + =C2=A0 =C2=A0 =C2=A0 unregister_netdev(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consistent(db->pdev, sizeof(struc=
t tx_desc) *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0DESC_ALL_CNT + 0x20, db->desc=
_pool_ptr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->desc_pool_dma_ptr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_free_consistent(db->pdev, TX_BUF_ALLOC=
 * TX_DESC_CNT + 4,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0db->buf_pool_ptr, db->buf_poo=
l_dma_ptr);
> - =C2=A0 =C2=A0 =C2=A0 unregister_netdev(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_release_regions(pdev);
> - =C2=A0 =C2=A0 =C2=A0 free_netdev(dev); =C2=A0 =C2=A0 =C2=A0 /* free=
 board information */
> - =C2=A0 =C2=A0 =C2=A0 pci_set_drvdata(pdev, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> - =C2=A0 =C2=A0 =C2=A0 ULI526X_DBUG(0, "uli526x_remove_one() exit", 0=
);
> + =C2=A0 =C2=A0 =C2=A0 pci_set_drvdata(pdev, NULL);
> + =C2=A0 =C2=A0 =C2=A0 free_netdev(dev);
> =C2=A0}
>
>
> --
> 1.7.7.6
>
