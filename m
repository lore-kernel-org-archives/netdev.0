From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Wed, 26 Nov 2014 09:21:29 +1100
Message-ID: <20141125222128.GA7213@shangw>
References: <CAJ3xEMg_bWmDGPHUSk6HzYD7N7CBU_V6J1ovft2rEigP-DJupA@mail.gmail.com>
 <20141124215555.GA6970@shangw>
 <CAJ3xEMi9G+tFsaANwndhmOZ78gt79WZ35Oq4CiFOm1WqxBXyqQ@mail.gmail.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:40295 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbaKYWVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:21:35 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Wed, 26 Nov 2014 08:21:33 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 39AD72CE8056
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 09:21:31 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAPMLVAo29687860
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 09:21:31 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAPMLTw0001611
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 09:21:30 +1100
Content-Disposition: inline
In-Reply-To: <CAJ3xEMi9G+tFsaANwndhmOZ78gt79WZ35Oq4CiFOm1WqxBXyqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 12:00:31AM +0200, Or Gerlitz wrote:
>On Mon, Nov 24, 2014 at 11:55 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>> On Mon, Nov 24, 2014 at 11:17:55PM +0200, Or Gerlitz wrote:
>>>On Sat, Nov 22, 2014 at 12:56 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>>>> The patch fixes couple of EEH recovery failures on PPC PowerNV
>>>> platform:
>>>
>>>>    * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
>>>>      Otherwise, __mlx4_init_one() runs into kernel crash because
>>>>      of dereferencing to NULL pointer.
>>>
>>>I don't see this change in the patch, I see no-clearing of mlx4_priv
>>>in __mlx4_unload_one - please clarify, also is this patch
>>>based/targeted on the net or net-next tree?
>>>
>>
>> Yes, It would be: Don't clear struct mlx4_priv instance in mlx4_unload_one(),
>> which is called by mlx4_pci_err_detected().
>
>
>But the struct mlx4_priv instance is cleared in mlx4_unload_one() for
>a reason, I suspect that you might made the EEH callback to work, but
>broke something else... e.g did you made sure that kexec works after
>your changes as it did before?
>

Nope, I didn't try kexec out and I'll have a try, thanks!

Gavin

>> It's based on 3.18.rc5, where I had couple of EEH fixes on top of it.
>> When testing EEH with it, I hit the issue.
>
>>>> With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
>>>> PowerNV platform.
>>>>
>>>>    # lspci
>>>>    0003:0f:00.0 Network controller: Mellanox Technologies \
>>>>    MT27500 Family [ConnectX-3]
>>>>
>>>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>>>> ---
>>>>  drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
>>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>> index 90de6e1..e118ac9 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>> @@ -2809,7 +2809,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
>>>>         kfree(dev->caps.qp1_proxy);
>>>>         kfree(dev->dev_vfs);
>>>>
>>>> -       memset(priv, 0, sizeof(*priv));
>>>>         priv->pci_dev_data = pci_dev_data;
>>>>         priv->removed = 1;
>>>>  }
>>>> @@ -2900,6 +2899,8 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>>>>                                               pci_channel_state_t state)
>>>>  {
>>>>         mlx4_unload_one(pdev);
>>>> +       pci_release_regions(pdev);
>>>> +       pci_disable_device(pdev);
>>>>
>>>>         return state == pci_channel_io_perm_failure ?
>>>>                 PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
>>>> --
>
