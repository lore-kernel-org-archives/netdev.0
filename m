From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sat, 21 May 2016 21:46:56 +0800
Message-ID: <20160521134537.GA25346@debian-dorm>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36252 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcEUNrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 09:47:06 -0400
Received: by mail-qk0-f196.google.com with SMTP id l68so13395667qkf.3
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 06:47:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <573E2D0C.604@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 11:15:56PM +0200, Lino Sanfilippo wrote:
>  drivers/net/ethernet/arc/emac_main.c | 33 +++++++++++++++++----------------
>  1 file changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index a3a9392..b986499 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -162,8 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
>  		struct sk_buff *skb = tx_buff->skb;
>  		unsigned int info = le32_to_cpu(txbd->info);
>  
> -		if ((info & FOR_EMAC) || !txbd->data || !skb)
> +		if (info & FOR_EMAC) {
> +			/* Make sure we see consistent values for info, skb
> +			 * and data.
> +			 */
> +			rmb();
>  			break;
> +		}
>  
>  		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
>  			stats->tx_errors++;
> @@ -680,35 +685,31 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
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
> -	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
> -
> -	/* Make sure info word is set */
> +	/* Make sure info is set after data and skb with respect to
> +	 * tx_clean().
> +	 */
>  	wmb();
>  
> -	priv->tx_buff[*txbd_curr].skb = skb;
> +	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
>  
>  	/* Increment index to point to the next BD */
>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
>  
> -	/* Ensure that tx_clean() sees the new txbd_curr before
> +	/* 1.Ensure that tx_clean() sees the new txbd_curr before
>  	 * checking the queue status. This prevents an unneeded wake
>  	 * of the queue in tx_clean().
> +	 * 2.Ensure that all values are written to RAM and to DMA
> +	 * before hardware is informed.
> +	 * 3.Ensure we see the most recent value for tx_dirty.
>  	 */
> -	smp_mb();
> +	mb();
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
> 
Hi Lino,
I applied your patch and tested on my devices, it directly went to
panic. So there must be something wrong.


[   13.084412] rockchip_emac 10204000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
[   13.093360] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   13.105915] Unable to handle kernel NULL pointer dereference at virtual address 000000a8
[   13.114173] pgd = c0004000
[   13.117069] [000000a8] *pgd=00000000
[   13.120778] Internal error: Oops: 5 [#1] SMP ARM
[   13.125404] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6.0+ #88
[   13.131404] Hardware name: Rockchip (Device Tree)
[   13.136108] task: c0804e00 ti: c0800000 task.ti: c0800000
[   13.141515] PC is at __dev_kfree_skb_irq+0xc/0x8c
[   13.146223] LR is at arc_emac_poll+0x94/0x584
[   13.150581] pc : [<c046f588>]    lr : [<c03c5e64>]    psr: 60080113
[   13.150581] sp : c0801d88  ip : c0801da0  fp : c0801d9c
[   13.162046] r10: ee092000  r9 : ee093000  r8 : 00000008
[   13.167268] r7 : 00000000  r6 : 00000004  r5 : f08d0400  r4 : 00000010
[   13.173789] r3 : 00000001  r2 : 00000000  r1 : 00000001  r0 : 00000000
[   13.180312] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[   13.187441] Control: 10c5387d  Table: 8d24c04a  DAC: 00000051
[   13.193184] Process swapper/0 (pid: 0, stack limit = 0xc0800210)
[   13.199187] Stack: (0xc0801d88 to 0xc0802000)
[   13.203548] 1d80:                   00000010 f08d0400 c0801df4 c0801da0 c03c5e64 c046f588
[   13.211723] 1da0: 00000000 ee0cc154 00000000 ee0924a8 c0801dcc 00000028 c0806614 f08d0408
[   13.219897] 1dc0: ee0922a8 0000007f 00000000 ee0924a8 c03c5dd0 00000028 0000012c fffee77c
[   13.228071] 1de0: c0802100 c0801e18 c0801e54 c0801df8 c0471bfc c03c5ddc c0801e3c c06e5ae8
[   13.236245] 1e00: c08029f4 c08029f4 c083d821 2e86f000 c07486c0 eefb76c0 c0801e18 c0801e18
[   13.244419] 1e20: c0801e20 c0801e20 ee841900 00000000 c080208c c0800000 00000100 00000003
[   13.252594] 1e40: c0802080 40000003 c0801eb4 c0801e58 c012810c c04719fc 00000001 ee808000
[   13.260768] 1e60: c08024a8 00200000 c0802100 fffee77b 0000000a c06017ec c083f940 c07432f8
[   13.268941] 1e80: c0802080 c0801e58 c0801eb4 c07463cc 00000000 00000000 00000001 ee808000
[   13.277115] 1ea0: c08024a8 eefe01c0 c0801ec4 c0801eb8 c01284f8 c0127ff4 c0801eec c0801ec8
[   13.285290] 1ec0: c016504c c012844c c08027b0 f080210c c0801f18 f0802100 f0803100 c08024a8
[   13.293463] 1ee0: c0801f14 c0801ef0 c0101438 c0164ff0 c0107fe4 60080013 ffffffff c0801f4c
[   13.301637] 1f00: c083d6c5 c08024a8 c0801f74 c0801f18 c010c014 c0101404 00000000 eefb4368
[   13.309812] 1f20: 00066cba c0116860 c0800000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[   13.317986] 1f40: eefe01c0 c0801f74 c0801f78 c0801f68 c0107fe0 c0107fe4 60080013 ffffffff
[   13.326159] 1f60: 00000051 c016e35c c0801f84 c0801f78 c015cc7c c0107fb0 c0801f9c c0801f88
[   13.334332] 1f80: c015cda8 c015cc60 00000000 c08023c0 c0801fac c0801fa0 c05c4e54 c015cc94
[   13.342507] 1fa0: c0801ff4 c0801fb0 c0700d34 c05c4de4 ffffffff ffffffff 00000000 c0700780
[   13.350680] 1fc0: 00000000 c07268c8 00000000 c083f294 c0802438 c07268c4 c0805f80 6000406a
[   13.358853] 1fe0: 413fc090 00000000 00000000 c0801ff8 60008078 c0700a2c 00000000 00000000
[   13.367017] Backtrace: 
[   13.369489] [<c046f57c>] (__dev_kfree_skb_irq) from [<c03c5e64>] (arc_emac_poll+0x94/0x584)
[   13.377830]  r5:f08d0400 r4:00000010
[   13.381442] [<c03c5dd0>] (arc_emac_poll) from [<c0471bfc>] (net_rx_action+0x20c/0x300)
[   13.389351]  r10:c0801e18 r9:c0802100 r8:fffee77c r7:0000012c r6:00000028 r5:c03c5dd0
[   13.397248]  r4:ee0924a8
[   13.399806] [<c04719f0>] (net_rx_action) from [<c012810c>] (__do_softirq+0x124/0x238)
[   13.407625]  r10:40000003 r9:c0802080 r8:00000003 r7:00000100 r6:c0800000 r5:c080208c
[   13.415520]  r4:00000000
[   13.418073] [<c0127fe8>] (__do_softirq) from [<c01284f8>] (irq_exit+0xb8/0x120)
[   13.425374]  r10:eefe01c0 r9:c08024a8 r8:ee808000 r7:00000001 r6:00000000 r5:00000000
[   13.433267]  r4:c07463cc
[   13.435825] [<c0128440>] (irq_exit) from [<c016504c>] (__handle_domain_irq+0x68/0xbc)
[   13.443655] [<c0164fe4>] (__handle_domain_irq) from [<c0101438>] (gic_handle_irq+0x40/0x7c)
[   13.451994]  r9:c08024a8 r8:f0803100 r7:f0802100 r6:c0801f18 r5:f080210c r4:c08027b0
[   13.459807] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[   13.467281] Exception stack(0xc0801f18 to 0xc0801f60)
[   13.472331] 1f00:                                                       00000000 eefb4368
[   13.480505] 1f20: 00066cba c0116860 c0800000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[   13.488679] 1f40: eefe01c0 c0801f74 c0801f78 c0801f68 c0107fe0 c0107fe4 60080013 ffffffff
[   13.496845]  r9:c08024a8 r8:c083d6c5 r7:c0801f4c r6:ffffffff r5:60080013 r4:c0107fe4
[   13.504667] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[   13.512758] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[   13.521369] [<c015cc88>] (cpu_startup_entry) from [<c05c4e54>] (rest_init+0x7c/0x80)
[   13.529102]  r7:c08023c0 r4:00000000
[   13.532715] [<c05c4dd8>] (rest_init) from [<c0700d34>] (start_kernel+0x314/0x320)
[   13.540195] [<c0700a20>] (start_kernel) from [<60008078>] (0x60008078)
[   13.546723] Code: e89da830 e1a0c00d e92dd830 e24cb004 (e59030a8) 
[   13.552874] ---[ end trace b1bc922158d3fc37 ]---
[   13.557511] Kernel panic - not syncing: Fatal exception in interrupt
[   13.563866] CPU2: stopping
[   13.566583] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D         4.6.0+ #88
[   13.573798] Hardware name: Rockchip (Device Tree)
[   13.578496] Backtrace: 
[   13.580973] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[   13.588534]  r7:ee89ff58 r6:60070193 r5:c081d8d8 r4:00000000
[   13.594260] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[   13.601484] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[   13.608871]  r7:ee89ff58 r6:00000002 r5:00000000 r4:c083f2b0
[   13.614589] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[   13.622149]  r7:f0802100 r6:ee89ff58 r5:f080210c r4:c08027b0
[   13.627865] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[   13.635341] Exception stack(0xee89ff58 to 0xee89ffa0)
[   13.640392] ff40:                                                       00000000 eefca368
[   13.648567] ff60: 00015268 c0116860 ee89e000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[   13.656742] ff80: 00000000 ee89ffb4 ee89ffb8 ee89ffa8 c0107fe0 c0107fe4 60070013 ffffffff
[   13.664908]  r9:c08024a8 r8:c083d6c5 r7:ee89ff8c r6:ffffffff r5:60070013 r4:c0107fe4
[   13.672731] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[   13.680821] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[   13.689431] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[   13.698463]  r7:c083f2c8 r4:c080c700
[   13.702069] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[   13.709456]  r5:00000051 r4:8e88406a
[   13.713059] CPU1: stopping
[   13.715775] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D         4.6.0+ #88
[   13.722990] Hardware name: Rockchip (Device Tree)
[   13.727689] Backtrace: 
[   13.730165] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[   13.737725]  r7:ee89df58 r6:600f0193 r5:c081d8d8 r4:00000000
[   13.743449] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[   13.750672] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[   13.758058]  r7:ee89df58 r6:00000001 r5:00000000 r4:c083f2b0
[   13.763775] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[   13.771336]  r7:f0802100 r6:ee89df58 r5:f080210c r4:c08027b0
[   13.777055] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[   13.784529] Exception stack(0xee89df58 to 0xee89dfa0)
[   13.789579] df40:                                                       00000000 eefbf368
[   13.797754] df60: 0001c888 c0116860 ee89c000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[   13.805929] df80: 00000000 ee89dfb4 ee89dfb8 ee89dfa8 c0107fe0 c0107fe4 600f0013 ffffffff
[   13.814095]  r9:c08024a8 r8:c083d6c5 r7:ee89df8c r6:ffffffff r5:600f0013 r4:c0107fe4
[   13.821913] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[   13.830003] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[   13.838612] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[   13.847647]  r7:c083f2c8 r4:c080c700
[   13.851254] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[   13.858641]  r5:00000051 r4:8e88406a
[   13.862245] CPU3: stopping
[   13.864959] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G      D         4.6.0+ #88
[   13.872175] Hardware name: Rockchip (Device Tree)
[   13.876874] Backtrace: 
[   13.879351] [<c010b2e8>] (dump_backtrace) from [<c010b494>] (show_stack+0x18/0x1c)
[   13.886912]  r7:ee8a1f58 r6:600d0193 r5:c081d8d8 r4:00000000
[   13.892637] [<c010b47c>] (show_stack) from [<c031eee0>] (dump_stack+0x94/0xa8)
[   13.899860] [<c031ee4c>] (dump_stack) from [<c010cd24>] (handle_IPI+0x17c/0x198)
[   13.907246]  r7:ee8a1f58 r6:00000003 r5:00000000 r4:c083f2b0
[   13.912963] [<c010cba8>] (handle_IPI) from [<c0101470>] (gic_handle_irq+0x78/0x7c)
[   13.920524]  r7:f0802100 r6:ee8a1f58 r5:f080210c r4:c08027b0
[   13.926240] [<c01013f8>] (gic_handle_irq) from [<c010c014>] (__irq_svc+0x54/0x70)
[   13.933716] Exception stack(0xee8a1f58 to 0xee8a1fa0)
[   13.938765] 1f40:                                                       00000000 eefd5368
[   13.946940] 1f60: 0001161e c0116860 ee8a0000 c0802454 c083d6c5 00000001 c083d6c5 c08024a8
[   13.955115] 1f80: 00000000 ee8a1fb4 ee8a1fb8 ee8a1fa8 c0107fe0 c0107fe4 600d0013 ffffffff
[   13.963282]  r9:c08024a8 r8:c083d6c5 r7:ee8a1f8c r6:ffffffff r5:600d0013 r4:c0107fe4
[   13.971100] [<c0107fa4>] (arch_cpu_idle) from [<c015cc7c>] (default_idle_call+0x28/0x34)
[   13.979190] [<c015cc54>] (default_idle_call) from [<c015cda8>] (cpu_startup_entry+0x120/0x168)
[   13.987800] [<c015cc88>] (cpu_startup_entry) from [<c010c968>] (secondary_start_kernel+0x11c/0x120)
[   13.996834]  r7:c083f2c8 r4:c080c700
[   14.000441] [<c010c84c>] (secondary_start_kernel) from [<6010150c>] (0x6010150c)
[   14.007828]  r5:00000051 r4:8e88406a
[   14.011435] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
