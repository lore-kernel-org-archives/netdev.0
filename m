From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] ehea:  use GFP_NOWAIT in ehea_error_data()
Date: Wed, 16 Apr 2014 07:30:49 -0300
Message-ID: <20140416103049.GC29537@oc0268524204.ibm.com>
References: <1397617620.13188.97.camel@ThinkPad-T5421.cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:40377 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304AbaDPKa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 06:30:57 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 16 Apr 2014 07:30:55 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 0B3873520052
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 06:30:49 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3GAUaj048562386
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 07:30:36 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3GAUpJt003938
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 06:30:52 -0400
Content-Disposition: inline
In-Reply-To: <1397617620.13188.97.camel@ThinkPad-T5421.cn.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2014 at 11:07:00AM +0800, Li Zhong wrote:
> I found following sleeping function called from invalid context complain
> while trying memory hot add/remove. 
> 
> As it could be called in atomic context, use GFP_NOWAIT here.
> 
> [64523.378595] BUG: sleeping function called from invalid context at mm/page_alloc.c:2706
> [64523.378599] in_atomic(): 1, irqs_disabled(): 1, pid: 18546, name: drmgr
> [64523.378605] CPU: 0 PID: 18546 Comm: drmgr Tainted: G        W     3.15.0-rc1+ #4
> [64523.378608] Call Trace:
> [64523.378616] [c000000ed7fd3690] [c000000000015f50] .show_stack+0x130/0x200 (unreliable)
> [64523.378624] [c000000ed7fd3760] [c0000000008bd314] .dump_stack+0xa0/0xdc
> [64523.378630] [c000000ed7fd37e0] [c0000000000e28cc] .__might_sleep+0x13c/0x170
> [64523.378637] [c000000ed7fd3870] [c0000000001e6734] .__alloc_pages_nodemask+0x3f4/0xca0
> [64523.378643] [c000000ed7fd3a30] [c00000000023bd3c] .alloc_pages_current+0xcc/0x170
> [64523.378648] [c000000ed7fd3ad0] [c0000000001df520] .__get_free_pages+0x30/0xb0
> [64523.378668] [c000000ed7fd3b50] [d0000000077dad10] .ehea_error_data+0x40/0x1b0 [ehea]
> [64523.378674] [c000000ed7fd3bf0] [d0000000077d3afc] .ehea_qp_aff_irq_handler+0x9c/0x110 [ehea]
> [64523.378680] [c000000ed7fd3c90] [c00000000011d144] .handle_irq_event_percpu+0x94/0x2f0
> [64523.378685] [c000000ed7fd3d60] [c00000000011d400] .handle_irq_event+0x60/0xa0
> [64523.378689] [c000000ed7fd3df0] [c000000000122314] .handle_fasteoi_irq+0xe4/0x290
> [64523.378693] [c000000ed7fd3e80] [c00000000011c244] .generic_handle_irq+0x54/0x80
> [64523.378698] [c000000ed7fd3f00] [c000000000010f30] .__do_irq+0x90/0x200
> [64523.378703] [c000000ed7fd3f90] [c000000000024bc8] .call_do_irq+0x14/0x24
> [64523.378707] [c000000ec50fefe0] [c000000000011138] .do_IRQ+0x98/0x110
> [64523.378712] [c000000ec50ff090] [c000000000002394] hardware_interrupt_common+0x114/0x180
> [64523.378718] --- Exception: 501 at .arch_local_irq_restore+0x74/0x90
> [64523.378718]     LR = .arch_local_irq_restore+0x74/0x90
> [64523.378724] [c000000ec50ff380] [c0000000000a855c] .wakeup_softirqd+0x3c/0x50 (unreliable)
> [64523.378731] [c000000ec50ff3f0] [c000000000751fd0] .__netif_schedule+0xb0/0x100
> [64523.378736] [c000000ec50ff470] [d0000000077d268c] .ehea_rereg_mrs+0x9dc/0xb40 [ehea]
> [64523.378741] [c000000ec50ff5d0] [d0000000077d295c] .ehea_mem_notifier+0x16c/0x180 [ehea]
> [64523.378748] [c000000ec50ff660] [c0000000008b184c] .notifier_call_chain+0x8c/0x100
> [64523.378754] [c000000ec50ff700] [c0000000000d896c] .__blocking_notifier_call_chain+0x6c/0xe0
> [64523.378761] [c000000ec50ff7a0] [c00000000055e2e8] .memory_notify+0x38/0x60
> [64523.378766] [c000000ec50ff820] [c000000000265ae8] .__offline_pages.constprop.16+0x2a8/0xa20
> [64523.378771] [c000000ec50ff990] [c00000000055e190] .memory_subsys_offline+0x70/0xe0
> [64523.378776] [c000000ec50ffa10] [c00000000053f6c8] .device_offline+0xf8/0x140
> [64523.378780] [c000000ec50ffaa0] [c00000000055ddd0] .store_mem_state+0x150/0x210
> [64523.378785] [c000000ec50ffb30] [c00000000053b8c4] .dev_attr_store+0x64/0xa0
> [64523.378790] [c000000ec50ffbc0] [c000000000311f4c] .sysfs_kf_write+0x7c/0xb0
> [64523.378794] [c000000ec50ffc50] [c000000000310fd4] .kernfs_fop_write+0x154/0x1e0
> [64523.378800] [c000000ec50ffcf0] [c00000000026b750] .vfs_write+0xe0/0x260
> [64523.378804] [c000000ec50ffd90] [c00000000026c444] .SyS_write+0x64/0x110
> [64523.378809] [c000000ec50ffe30] [c000000000009ffc] syscall_exit+0x0/0x7c
> 
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea_qmr.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> index 9b03033..fa16897 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> @@ -996,7 +996,7 @@ u64 ehea_error_data(struct ehea_adapter *adapter, u64 res_handle,
>  	u64 *rblock;
>  	u64 type = 0;
> 
> -	rblock = (void *)get_zeroed_page(GFP_KERNEL);
> +	rblock = (void *)get_zeroed_page(GFP_NOWAIT);
>  	if (!rblock) {
>  		pr_err("Cannot allocate rblock memory\n");
>  		goto out;
> 
> 

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
