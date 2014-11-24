From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Mon, 24 Nov 2014 23:17:55 +0200
Message-ID: <CAJ3xEMg_bWmDGPHUSk6HzYD7N7CBU_V6J1ovft2rEigP-DJupA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33582 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaKXVR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:17:56 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so7891222obc.11
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 13:17:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2014 at 12:56 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> The patch fixes couple of EEH recovery failures on PPC PowerNV
> platform:

>    * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>      Otherwise, __mlx4_init_one() runs into kernel crash because
>      of dereferencing to NULL pointer.

I don't see this change in the patch, I see no-clearing of mlx4_priv
in __mlx4_unload_one - please clarify, also is this patch
based/targeted on the net or net-next tree?



> With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
> PowerNV platform.
>
>    # lspci
>    0003:0f:00.0 Network controller: Mellanox Technologies \
>    MT27500 Family [ConnectX-3]
>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 90de6e1..e118ac9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2809,7 +2809,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
>         kfree(dev->caps.qp1_proxy);
>         kfree(dev->dev_vfs);
>
> -       memset(priv, 0, sizeof(*priv));
>         priv->pci_dev_data = pci_dev_data;
>         priv->removed = 1;
>  }
> @@ -2900,6 +2899,8 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>                                               pci_channel_state_t state)
>  {
>         mlx4_unload_one(pdev);
> +       pci_release_regions(pdev);
> +       pci_disable_device(pdev);
>
>         return state == pci_channel_io_perm_failure ?
>                 PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
> --
> 1.8.3.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
