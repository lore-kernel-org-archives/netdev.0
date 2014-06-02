From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Mon, 2 Jun 2014 22:29:47 +0800
Message-ID: <20140602142947.GB28523@richard>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	weiyang@linux.vnet.ibm.com, bhelgaas@google.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:56934 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755022AbaFBO35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 10:29:57 -0400
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 2 Jun 2014 19:59:54 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 09A48E0044
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 20:00:43 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s52EUWCw58065036
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2014 20:00:32 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s52ETnZQ014283
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2014 19:59:50 +0530
Content-Disposition: inline
In-Reply-To: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 01, 2014 at 01:49:43PM +0300, Or Gerlitz wrote:
>From: Jack Morgenstein <jackm@dev.mellanox.co.il>
>
>Commit befdf89 did not take into account the case where the Host
>driver is being unloaded. In this case, pci_get_drvdata for the VF

In my mind, unloading PF's driver when there is alive VFs is not allowed.
Quoted in driver code:

	/* in SRIOV it is not allowed to unload the pf's
	 * driver while there are alive vf's */
	if (mlx4_is_master(dev) && mlx4_how_many_lives_vf(dev))
		printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");

Actually, I don't understand this restriction clearly. Maybe my understanding
of alive VF is not correct.

And in your code, unload PF's driver would call pci_disable_sriov() which will
destroy the VFs. While in your test, the VF's driver is still there?

>remove_one call may return NULL, so that dereferencing the priv
>struct results in a kernel oops.

Sorry for my poor mind, I still can't understand this situation.
Would you describe the situation more? You are unloading PF's driver in Host
at first, and then try to release the VF's driver?

>
>The fix is to also test that the dev pointer returned by
>pci_get_drvdata is non-NULL.
>
>Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
>Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
> drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>index c187d74..a6ae089 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>@@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
> 	int               pci_dev_data;
> 	int p;
>
>-	if (priv->removed)
>+	if (!dev || priv->removed)
> 		return;

This fix looks good to me.

As I remembered, I had this check in my first version, but I removed the check
on dev based on the suggestion from Bjorn. Since I agreed that there is no
chance for dev to be NULL. Bjorn, seems we are not correct :(

>
> 	pci_dev_data = priv->pci_dev_data;
>-- 
>1.7.1

-- 
Richard Yang
Help you, Help me
