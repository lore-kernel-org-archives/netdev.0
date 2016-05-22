From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 17:17:42 +0800
Message-ID: <20160522091742.GA8681@debian-dorm>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
 <5740E82F.8040903@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, al.kochet@gmail.com
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35805 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbcEVJRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 05:17:51 -0400
Received: by mail-qk0-f194.google.com with SMTP id z80so632731qkb.2
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 02:17:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5740E82F.8040903@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2016 at 12:58:55AM +0200, Lino Sanfilippo wrote:
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -162,7 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
>  		struct sk_buff *skb = tx_buff->skb;
>  		unsigned int info = le32_to_cpu(txbd->info);
>  
> -		if ((info & FOR_EMAC) || !txbd->data || !skb)
> +		if (info & FOR_EMAC)
> +			break;
> +
> +		/* Make sure curr pointer is consistent with info */
> +		rmb();
> +
> +		if (*txbd_dirty == priv->txbd_curr)
>  			break;
>  
>  		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
> @@ -195,8 +201,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
>  		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
>  	}
>  
> -	/* Ensure that txbd_dirty is visible to tx() before checking
> -	 * for queue stopped.
> +	/* Ensure that txbd_dirty is visible to tx() and we see the most recent
> +	 * value for txbd_curr.
>  	 */
>  	smp_mb();
>  
> @@ -680,35 +686,29 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>  	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
>  
>  	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
> -
> -	/* Make sure pointer to data buffer is set */
> -	wmb();
> +	priv->tx_buff[*txbd_curr].skb = skb;
>  
>  	skb_tx_timestamp(skb);
>  
>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
>  
> -	/* Make sure info word is set */
> +	/* 1. Make sure that with respect to tx_clean everything is set up
> +	 * properly before we advance txbd_curr.
> +	 * 2. Make sure writes to DMA descriptors are completed before we inform
> +	 * the hardware.
> +	 */
>  	wmb();
>  
> -	priv->tx_buff[*txbd_curr].skb = skb;
> -
>  	/* Increment index to point to the next BD */
>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
>  
> -	/* Ensure that tx_clean() sees the new txbd_curr before
> -	 * checking the queue status. This prevents an unneeded wake
> -	 * of the queue in tx_clean().
> +	/* Ensure we see the most recent value of txbd_dirty and tx_clean() sees
> +	 * the updated value of txbd_curr.
>  	 */
>  	smp_mb();
>  
> -	if (!arc_emac_tx_avail(priv)) {
> +	if (!arc_emac_tx_avail(priv))
>  		netif_stop_queue(ndev);
> -		/* Refresh tx_dirty */
> -		smp_mb();
> -		if (arc_emac_tx_avail(priv))
> -			netif_start_queue(ndev);
> -	}
>  
>  	arc_reg_set(priv, R_STATUS, TXPL_MASK);
>  

Hi Lino,

I tested this patch, it still got panic under stress.
Just wget 2 large files simultaneously and it failed.

Looks like the problem comes from the if statement in tx_clean().
I changed your patch to use 

-               if (info & FOR_EMAC)
+               if ((info & FOR_EMAC) || !txbd->data || !skb)

and it worked. 

After further test, my patch to barrier timestamp() didn't work.
Just like the original code in the tree, the emac still got stuck under
high load, even if I changed the smp_wmb() to dma_wmb(). So the original
code do have race somewhere. 

I'm new to kernel development, and still trying to understand how memory
barrier works and why Francois' fix worked. Please be patient with me :-).

---

[  138.501355] Unable to handle kernel NULL pointer dereference at virtual address 000000a8
[  138.509482] pgd = c0004000
[  138.512200] [000000a8] *pgd=00000000
[  138.515850] Internal error: Oops: 5 [#1] SMP ARM
[  138.520476] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6.0+ #98
[  138.526477] Hardware name: Rockchip (Device Tree)
[  138.531180] task: c0804e00 ti: c0800000 task.ti: c0800000
[  138.536588] PC is at __dev_kfree_skb_irq+0xc/0x8c
[  138.541295] LR is at arc_emac_poll+0x94/0x594
[  138.545653] pc : [<c046f590>]    lr : [<c03c5e64>]    psr: 60050113
[  138.545653] sp : c0801d88  ip : c0801da0  fp : c0801d9c
[  138.557118] r10: ee0a0000  r9 : ee0a1000  r8 : 000001f8
[  138.562340] r7 : 00000000  r6 : 000000fc  r5 : f08d0400  r4 : 000003f0
[  138.568861] r3 : 00000001  r2 : 00000042  r1 : 00000001  r0 : 00000000
[  138.575385] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[  138.582515] Control: 10c5387d  Table: 8da4004a  DAC: 00000051
[  138.588256] Process swapper/0 (pid: 0, stack limit = 0xc0800210)
[  138.594258] Stack: (0xc0801d88 to 0xc0802000)
[  138.598617] 1d80:                   000003f0 f08d0400 c0801df4 c0801da0 c03c5e64 c046f590
[  138.606794] 1da0: 00000000 c0171050 c0801ddc ee0a04a8 c016504c 00000028 c0806614 f08d05f8
[  138.614969] 1dc0: ee0a02a8 00000080 f0803100 ee0a04a8 c03c5dd0 00000028 0000012c ffff623d
[  138.623144] 1de0: c0802100 c0801e18 c0801e54 c0801df8 c0471c04 c03c5ddc c0801eb4 c06e5ae8
[  138.631318] 1e00: c08029f4 c08029f4 c083d821 2e86f000 c07486c0 eefb76c0 c0801e18 c0801e18
[  138.639492] 1e20: c0801e20 c0801e20 00000003 00000000 c080208c c0800000 00000100 00000003
[  138.647666] 1e40: c0802080 40000003 c0801eb4 c0801e58 c012810c c0471a04 00000001 ee808000
[  138.655841] 1e60: c08024a8 00200000 c0802100 ffff623c 00000009 c06017ec c083f940 c07432f8
[  138.664015] 1e80: c0802080 c0801e58 c0801eb4 c07463cc 00000000 00000000 00000001 ee808000
[  138.672188] 1ea0: c08024a8 eefe01c0 c0801ec4 c0801eb8 c01284f8 c0127ff4 c0801eec c0801ec8
[  138.680363] 1ec0: c016504c c012844c c08027b0 f080210c c0801f18 f0802100 f0803100 c08024a8
[  138.688536] 1ee0: c0801f14 c0801ef0 c0101438 c0164ff0 c0107fe4 60050013 ffffffff c0801f4c
[  138.696710] 1f00: c083d6c5 c08024a8 c0801f74 c0801f18 c010c014 c0101404 00000000 eefb4368
[  138.704884] 1f20: 006b18d8 c0116860 c0800000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[  138.713059] 1f40: eefe01c0 c0801f74 c0801f78 c0801f68 c0107fe0 c0107fe4 60050013 ffffffff
[  138.721232] 1f60: 00000051 c016e35c c0801f84 c0801f78 c015cc7c c0107fb0 c0801f9c c0801f88
[  138.729406] 1f80: c015cda8 c015cc60 00000000 c08023c0 c0801fac c0801fa0 c05c4e54 c015cc94
[  138.737580] 1fa0: c0801ff4 c0801fb0 c0700d34 c05c4de4 ffffffff ffffffff 00000000 c0700780
[  138.745754] 1fc0: 00000000 c07268c8 00000000 c083f294 c0802438 c07268c4 c0805f80 6000406a
[  138.753928] 1fe0: 413fc090 00000000 00000000 c0801ff8 60008078 c0700a2c 00000000 00000000
[  138.762093] Backtrace: 
[  138.764567] [<c046f584>] (__dev_kfree_skb_irq) from [<c03c5e64>] (arc_emac_poll+0x94/0x594)
[  138.772908]  r5:f08d0400 r4:000003f0
[  138.776522] [<c03c5dd0>] (arc_emac_poll) from [<c0471c04>] (net_rx_action+0x20c/0x300)
[  138.784430]  r10:c0801e18 r9:c0802100 r8:ffff623d r7:0000012c r6:00000028 r5:c03c5dd0
[  138.792324]  r4:ee0a04a8
[  138.794882] [<c04719f8>] (net_rx_action) from [<c012810c>] (__do_softirq+0x124/0x238)
[  138.802704]  r10:40000003 r9:c0802080 r8:00000003 r7:00000100 r6:c0800000 r5:c080208c
[  138.810596]  r4:00000000
[  138.813150] [<c0127fe8>] (__do_softirq) from [<c01284f8>] (irq_exit+0xb8/0x120)
[  138.820449]  r10:eefe01c0 r9:c08024a8 r8:ee808000 r7:00000001 r6:00000000 r5:00000000
[  138.828342]  r4:c07463cc
[  138.830899] [<c0128440>] (irq_exit) from [<c016504c>] (__handle_domain_irq+0x68/0xbc)
[  138.838729] [<c0164fe4>] (__handle_domain_irq) from [<c0101438>] (gic_handle_irq+0x40/0x7c)
[  138.847069]  r9:c08024a8 r8:f0803100 r7:f0802100 r6:c0801f18 r5:f080210c r4:c08027b0
[  138.854882] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[  138.862358] Exception stack(0xc0801f18 to 0xc0801f60)
[  138.867407] 1f00:                                                       00000000 eefb4368
[  138.875583] 1f20: 006b18d8 c0116860 c0800000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[  138.883757] 1f40: eefe01c0 c0801f74 c0801f78 c0801f68 c0107fe0 c0107fe4 60050013 ffffffff
[  138.891924]  r9:c08024a8 r8:c083d6c5 r7:c0801f4c r6:ffffffff r5:60050013 r4:c0107fe4
[  138.899749] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[  138.907839] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[  138.916451] [<c015cc88>] (cpu_startup_entry) from [<c05c4e54>] (rest_init+0x7c/0x80)
[  138.924185]  r7:c08023c0 r4:00000000
[  138.927799] [<c05c4dd8>] (rest_init) from [<c0700d34>] (start_kernel+0x314/0x320)
[  138.935279] [<c0700a20>] (start_kernel) from [<60008078>] (0x60008078)
[  138.941807] Code: e89da830 e1a0c00d e92dd830 e24cb004 (e59030a8) 
[  138.947973] ---[ end trace c64a970fa34feb9a ]---
[  138.952614] Kernel panic - not syncing: Fatal exception in interrupt
[  138.958978] CPU3: stopping
[  138.961697] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G      D         4.6.0+ #98
[  138.968913] Hardware name: Rockchip (Device Tree)
[  138.973613] Backtrace: 
[  138.976095] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[  138.983658]  r7:ee8a1f58 r6:60070193 r5:c081d8d8 r4:00000000
[  138.989385] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[  138.996610] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[  139.003998]  r7:ee8a1f58 r6:00000003 r5:00000000 r4:c083f2b0
[  139.009716] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[  139.017277]  r7:f0802100 r6:ee8a1f58 r5:f080210c r4:c08027b0
[  139.022996] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[  139.030471] Exception stack(0xee8a1f58 to 0xee8a1fa0)
[  139.035521] 1f40:                                                       00000000 eefd5368
[  139.043697] 1f60: 00d5d590 c0116860 ee8a0000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[  139.051872] 1f80: 00000000 ee8a1fb4 ee8a1fb8 ee8a1fa8 c0107fe0 c0107fe4 60070013 ffffffff
[  139.060039]  r9:c08024a8 r8:c083d6c5 r7:ee8a1f8c r6:ffffffff r5:60070013 r4:c0107fe4
[  139.067856] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[  139.075948] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[  139.084557] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[  139.093591]  r7:c083f2c8 r4:c080c700
[  139.097197] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[  139.104583]  r5:00000051 r4:8e88406a
[  139.108186] CPU2: stopping
[  139.110903] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D         4.6.0+ #98
[  139.118118] Hardware name: Rockchip (Device Tree)
[  139.122817] Backtrace: 
[  139.125293] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[  139.132855]  r7:ee89ff58 r6:60030193 r5:c081d8d8 r4:00000000
[  139.138581] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[  139.145803] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[  139.153191]  r7:ee89ff58 r6:00000002 r5:00000000 r4:c083f2b0
[  139.158909] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[  139.166470]  r7:f0802100 r6:ee89ff58 r5:f080210c r4:c08027b0
[  139.172188] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[  139.179664] Exception stack(0xee89ff58 to 0xee89ffa0)
[  139.184714] ff40:                                                       00000000 eefca368
[  139.192890] ff60: 00c866ca c0116860 ee89e000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[  139.201064] ff80: 00000000 ee89ffb4 ee89ffb8 ee89ffa8 c0107fe0 c0107fe4 60030013 ffffffff
[  139.209231]  r9:c08024a8 r8:c083d6c5 r7:ee89ff8c r6:ffffffff r5:60030013 r4:c0107fe4
[  139.217051] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[  139.225141] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[  139.233750] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[  139.242784]  r7:c083f2c8 r4:c080c700
[  139.246391] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[  139.253777]  r5:00000051 r4:8e88406a
[  139.257378] CPU1: stopping
[  139.260095] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D         4.6.0+ #98
[  139.267309] Hardware name: Rockchip (Device Tree)
[  139.272009] Backtrace: 
[  139.274484] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[  139.282046]  r7:ee89df58 r6:60070193 r5:c081d8d8 r4:00000000
[  139.287771] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[  139.294994] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[  139.302381]  r7:ee89df58 r6:00000001 r5:00000000 r4:c083f2b0
[  139.308100] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[  139.315661]  r7:f0802100 r6:ee89df58 r5:f080210c r4:c08027b0
[  139.321376] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[  139.328850] Exception stack(0xee89df58 to 0xee89dfa0)
[  139.333901] df40:                                                       00000000 eefbf368
[  139.342077] df60: 00c9fb38 c0116860 ee89c000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[  139.350252] df80: 00000000 ee89dfb4 ee89dfb8 ee89dfa8 c0107fe0 c0107fe4 60070013 ffffffff
[  139.358418]  r9:c08024a8 r8:c083d6c5 r7:ee89df8c r6:ffffffff r5:60070013 r4:c0107fe4
[  139.366235] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[  139.374327] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[  139.382935] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[  139.391969]  r7:c083f2c8 r4:c080c700
[  139.395575] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[  139.402961]  r5:00000051 r4:8e88406a
[  139.406570] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
