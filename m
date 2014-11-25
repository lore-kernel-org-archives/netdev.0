From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Wed, 26 Nov 2014 00:00:31 +0200
Message-ID: <CAJ3xEMi9G+tFsaANwndhmOZ78gt79WZ35Oq4CiFOm1WqxBXyqQ@mail.gmail.com>
References: <CAJ3xEMg_bWmDGPHUSk6HzYD7N7CBU_V6J1ovft2rEigP-DJupA@mail.gmail.com>
	<20141124215555.GA6970@shangw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:62032 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaKYWAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:00:32 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so1239079obc.1
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:00:32 -0800 (PST)
In-Reply-To: <20141124215555.GA6970@shangw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 11:55 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> On Mon, Nov 24, 2014 at 11:17:55PM +0200, Or Gerlitz wrote:
>>On Sat, Nov 22, 2014 at 12:56 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>>> The patch fixes couple of EEH recovery failures on PPC PowerNV
>>> platform:
>>
>>>    * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>>>      Otherwise, __mlx4_init_one() runs into kernel crash because
>>>      of dereferencing to NULL pointer.
>>
>>I don't see this change in the patch, I see no-clearing of mlx4_priv
>>in __mlx4_unload_one - please clarify, also is this patch
>>based/targeted on the net or net-next tree?
>>
>
> Yes, It would be: Don't clear struct mlx4_priv instance in mlx4_unload_one(),
> which is called by mlx4_pci_err_detected().


But the struct mlx4_priv instance is cleared in mlx4_unload_one() for
a reason, I suspect that you might made the EEH callback to work, but
broke something else... e.g did you made sure that kexec works after
your changes as it did before?

> It's based on 3.18.rc5, where I had couple of EEH fixes on top of it.
> When testing EEH with it, I hit the issue.

>>> With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
>>> PowerNV platform.
>>>
>>>    # lspci
>>>    0003:0f:00.0 Network controller: Mellanox Technologies \
>>>    MT27500 Family [ConnectX-3]
>>>
>>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>>> ---
>>>  drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>> index 90de6e1..e118ac9 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>> @@ -2809,7 +2809,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
>>>         kfree(dev->caps.qp1_proxy);
>>>         kfree(dev->dev_vfs);
>>>
>>> -       memset(priv, 0, sizeof(*priv));
>>>         priv->pci_dev_data = pci_dev_data;
>>>         priv->removed = 1;
>>>  }
>>> @@ -2900,6 +2899,8 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>>>                                               pci_channel_state_t state)
>>>  {
>>>         mlx4_unload_one(pdev);
>>> +       pci_release_regions(pdev);
>>> +       pci_disable_device(pdev);
>>>
>>>         return state == pci_channel_io_perm_failure ?
>>>                 PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
>>> --
