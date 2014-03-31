From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by
 pci_match_id()
Date: Mon, 31 Mar 2014 11:12:33 +0800
Message-ID: <20140331031233.GA7593@richard>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:47501 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbaCaDMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 23:12:44 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 31 Mar 2014 13:12:41 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 7B7F53578055
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 14:12:38 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2V2qDu636896822
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 13:52:13 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2V3CaVR002662
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 14:12:37 +1100
Content-Disposition: inline
In-Reply-To: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Amir and Bjorn,

I missed this code path, we should take dynids carefully.

On Sun, Mar 30, 2014 at 06:26:55PM +0300, Amir Vadai wrote:
>Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>pci_device_id.driver_data to __mlx4_init_one during reset".
>
>pci_match_id() might return NULL if someone binds the driver to a device
>manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>before using it.
>
>Thanks to Bjorn who raised the problem.
>
>CC: Bjorn Helgaas <bhelgaas@google.com>
>CC: Wei Yang <weiyang@linux.vnet.ibm.com>
>Signed-off-by: Amir Vadai <amirv@mellanox.com>
>---
> drivers/net/ethernet/mellanox/mlx4/main.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>index f0ae95f..a2f6623 100644
>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>@@ -2759,6 +2759,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
> 	int ret;
>
> 	id = pci_match_id(mlx4_pci_table, pdev);
>+	if (!id)
>+		return PCI_ERS_RESULT_DISCONNECT;
>+

So when there is really someone create a new dynamic id for this driver, this
change will fail to reset this device. And actually, in general, driver can
reset it. In my mind, we can't say it is disconnected, since we just not find it.

My suggestion is we find it both in dynamic ids and static ids. Will send a
fix soon.

> 	ret = __mlx4_init_one(pdev, id->driver_data);
>
> 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>-- 
>1.8.3.4

-- 
Richard Yang
Help you, Help me
