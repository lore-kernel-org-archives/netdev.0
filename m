From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Fri, 5 Dec 2014 15:28:10 +1100
Message-ID: <20141205042810.GB31214@shangw>
References: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amirv@mellanox.com, davem@davemloft.net,
	yishaih@mellanox.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:33014 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbaLEE2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 23:28:16 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 5 Dec 2014 14:28:14 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DCE22357804F
	for <netdev@vger.kernel.org>; Fri,  5 Dec 2014 15:28:11 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB54SBin31195316
	for <netdev@vger.kernel.org>; Fri, 5 Dec 2014 15:28:11 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB54SBCu021418
	for <netdev@vger.kernel.org>; Fri, 5 Dec 2014 15:28:11 +1100
Content-Disposition: inline
In-Reply-To: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2014 at 09:56:47PM +1100, Gavin Shan wrote:

Yishai already had patches fixing the issue. So please ignore
this patch and drop it.

Thanks,
Gavin

>The patch fixes couple of EEH recovery failures on PPC PowerNV
>platform:
>
>   * Release reserved memory regions in mlx4_pci_err_detected().
>     Otherwise, __mlx4_init_one() fails because of reserving
>     same memory regions recursively.
>   * Disable PCI device in mlx4_pci_err_detected(). Otherwise,
>     pci_enable_device() in __mlx4_init_one() doesn't enable
>     the PCI device because it's already in enabled state indicated
>     by struct pci_dev::enable_cnt.
>   * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>     Otherwise, __mlx4_init_one() runs into kernel crash because
>     of dereferencing to NULL pointer.
>
>With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
>PowerNV platform.
>
>   # lspci
>   0003:0f:00.0 Network controller: Mellanox Technologies \
>   MT27500 Family [ConnectX-3]
>
>Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>---
> drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>index 90de6e1..e118ac9 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>@@ -2809,7 +2809,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
> 	kfree(dev->caps.qp1_proxy);
> 	kfree(dev->dev_vfs);
>
>-	memset(priv, 0, sizeof(*priv));
> 	priv->pci_dev_data = pci_dev_data;
> 	priv->removed = 1;
> }
>@@ -2900,6 +2899,8 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
> 					      pci_channel_state_t state)
> {
> 	mlx4_unload_one(pdev);
>+	pci_release_regions(pdev);
>+	pci_disable_device(pdev);
>
> 	return state == pci_channel_io_perm_failure ?
> 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
>-- 
>1.8.3.2
>
