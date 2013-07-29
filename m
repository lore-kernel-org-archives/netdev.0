From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring
Date: Mon, 29 Jul 2013 10:55:19 +0100
Message-ID: <877gg9wv08.fsf@canonical.com>
References: <87k3kbdcmy.fsf@canonical.com>
	<1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	<1374969583.3669.23.camel@edumazet-glaptop>
	<20130727.200205.67471633133830510.davem@davemloft.net>
	<20130728104446.GB9876@neilslaptop.think-freely.org>
	<1375028154.3669.30.camel@edumazet-glaptop>
	<20130728185318.GA10795@neilslaptop.think-freely.org>
	<1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
	<1375052482.3669.54.camel@edumazet-glaptop>
	<1375053654.3669.58.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375053654.3669.58.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Sun, 28 Jul 2013 16:20:54 -0700")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Sun, 2013-07-28 at 16:01 -0700, Eric Dumazet wrote:
>> On Sun, 2013-07-28 at 21:22 +0100, Ben Hutchings wrote:
>> 
>> > 
>> > Since we know lengths > 4K work, perhaps it would be worth testing with
>> > the fragment cache size reduced to 16K?  The driver would never
>> > previously have used RX buffers crossing 16K boundaries, except if SLOB
>> > was used (and that's an unlikely combination).
>> 
>> Sure, please note the following maths :
>> 
>> NET_SKB_PAD + 1536 + sizeof(struct skb_shared_info) = 1920
>> 
>> 16384/1920 = 8
>> 
>> 32768/1920 = 17
>> 
>> I don't think atl1c is used in any critical host (given it doesn't even
>> provide RX checksums and GRO ...), so I will provide a patch doing mere
>> page allocations.
>> 
>
> Oh well, look at code around line 2530
>
>         * The atl1c chip can DMA to 64-bit addresses, but it uses a single
>          * shared register for the high 32 bits, so only a single, aligned,
>          * 4 GB physical address range can be used at a time.
>          *
>          * Supporting 64-bit DMA on this hardware is more trouble than it's
>          * worth.  It is far easier to limit to 32-bit DMA than update
>          * various kernel subsystems to support the mechanics required by a
>          * fixed-high-32-bit system.
>          */
>         if ((pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) ||
>             (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) != 0)) {
>                 dev_err(&pdev->dev, "No usable DMA configuration,aborting\n");
>                 goto err_dma;
>         }
>
> It looks like we have a winner !
>
> This $@!? really needs DMA32 allocations.
>
> Currently only tested on TX patch, it needs same care on RX
>
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 786a874..e2ee962 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1660,7 +1660,8 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
>  	while (next_info->flags & ATL1C_BUFFER_FREE) {
>  		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
>  
> -		skb = netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len);
> +		skb = __netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len,
> +					 GFP_ATOMIC | GFP_DMA32);
>  		if (unlikely(!skb)) {
>  			if (netif_msg_rx_err(adapter))
>  				dev_warn(&pdev->dev, "alloc rx buffer failed\n");
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Using both patches from Eric (to the atl1c driver and to
net/core/skbuff.c) , I got the following:

[   25.176311] ------------[ cut here ]------------
[   25.179857] kernel BUG at mm/slub.c:1360!
[   25.183495] invalid opcode: 0000 [#1] SMP 
[   25.186919] CPU: 3 PID: 1705 Comm: ip Not tainted 3.11.0-rc2+ #15
[   25.190319] Hardware name: ASUSTeK COMPUTER INC. X101CH/X101CH, BIOS X101CH.1203 07/30/2012
[   25.193828] task: f504f8c0 ti: f514e000 task.ti: f514e000
[   25.197348] EIP: 0060:[<c1135e27>] EFLAGS: 00010002 CPU: 3
[   25.200896] EIP is at new_slab+0x1c7/0x200
[   25.204391] EAX: f6801a00 EBX: f6801a00 ECX: ffffffff EDX: 00010224
[   25.207942] ESI: f6800ea0 EDI: f6801a00 EBP: f514f91c ESP: f514f904
[   25.211541]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   25.215113] CR0: 80050033 CR2: bff28afc CR3: 35fcd000 CR4: 000007f0
[   25.218695] Stack:
[   25.222259]  f514f954 c107acc7 00000003 00000000 f6800ea0 f6801a00 f514f984 c179d9e6
[   25.226156]  80100010 00000000 00100010 c162fb40 00010224 f6800ea0 8015000b 00000000
[   25.226168]  00000286 c162fb1c 00000024 f514f964 00000000 f5d963c0 00000296 f5d963c0
[   25.226170] Call Trace:
[   25.226184]  [<c107acc7>] ? enqueue_task_fair+0x5c7/0x7d0
[   25.226197]  [<c179d9e6>] __slab_alloc.constprop.71+0x248/0x409
[   25.226205]  [<c162fb40>] ? __alloc_skb+0x60/0x270
[   25.226211]  [<c162fb1c>] ? __alloc_skb+0x3c/0x270
[   25.226218]  [<c106f688>] ? ttwu_do_wakeup+0x18/0x100
[   25.226226]  [<c1139440>] __kmalloc_track_caller+0x100/0x150
[   25.226232]  [<c10718a9>] ? try_to_wake_up+0x149/0x230
[   25.226238]  [<c162fb40>] ? __alloc_skb+0x60/0x270
[   25.226244]  [<c162f482>] __kmalloc_reserve.isra.30+0x22/0x70
[   25.226250]  [<c162fb40>] __alloc_skb+0x60/0x270
[   25.226257]  [<c162ff71>] __netdev_alloc_skb+0x41/0xc0
[   25.226265]  [<c145cbe5>] atl1c_alloc_rx_buffer+0x125/0x290
[   25.226272]  [<c145ce79>] atl1c_configure+0x129/0x420
[   25.226279]  [<c164d48f>] ? linkwatch_fire_event+0x2f/0x90
[   25.226286]  [<c1006a10>] ? via_no_dac+0x40/0x40
[   25.226292]  [<c145dcb3>] atl1c_up+0x23/0x1e0
[   25.226298]  [<c1006a10>] ? via_no_dac+0x40/0x40
[   25.226305]  [<c145e3c9>] atl1c_open+0x269/0x310
[   25.226311]  [<c1006a10>] ? via_no_dac+0x40/0x40
[   25.226317]  [<c163dd43>] __dev_open+0x83/0xf0
[   25.226325]  [<c17a7224>] ? _raw_spin_unlock_bh+0x14/0x20
[   25.226331]  [<c163e021>] __dev_change_flags+0x81/0x160
[   25.226337]  [<c163e1a8>] dev_change_flags+0x18/0x50
[   25.226343]  [<c164b200>] do_setlink+0x2e0/0x810
[   25.226350]  [<c10fc110>] ? find_get_page+0x20/0xa0
[   25.226357]  [<c12ccff2>] ? nla_parse+0x22/0xa0
[   25.226364]  [<c116b413>] ? __find_get_block_slow+0xd3/0x180
[   25.226370]  [<c164bd92>] rtnl_newlink+0x282/0x510
[   25.226378]  [<c12735cc>] ? security_capable+0x1c/0x30
[   25.226384]  [<c1648c68>] rtnetlink_rcv_msg+0x88/0x1f0
[   25.226391]  [<c1139386>] ? __kmalloc_track_caller+0x46/0x150
[   25.226397]  [<c162fb40>] ? __alloc_skb+0x60/0x270
[   25.226403]  [<c1648be0>] ? rtnetlink_rcv+0x30/0x30
[   25.226410]  [<c165f016>] netlink_rcv_skb+0x86/0xa0
[   25.226416]  [<c1648bd1>] rtnetlink_rcv+0x21/0x30
[   25.226422]  [<c165db38>] netlink_unicast+0x118/0x1b0
[   25.226428]  [<c165e17f>] netlink_sendmsg+0x23f/0x3f0
[   25.226435]  [<c162926b>] sock_sendmsg+0x7b/0xb0
[   25.226443]  [<c1102dc9>] ? __alloc_pages_nodemask+0x119/0x7a0
[   25.226450]  [<c1629661>] ___sys_sendmsg+0x291/0x2a0
[   25.226457]  [<c10fbe56>] ? unlock_page+0x46/0x50
[   25.226464]  [<c111a348>] ? __do_fault+0x388/0x4a0
[   25.226471]  [<c1107196>] ? lru_cache_add+0x16/0x20
[   25.226477]  [<c1125174>] ? page_add_new_anon_rmap+0x74/0x100
[   25.226483]  [<c1631dd5>] ? skb_dequeue+0x45/0x60
[   25.226491]  [<c111da1a>] ? handle_mm_fault+0x1ca/0x2b0
[   25.226497]  [<c11545d1>] ? __d_free+0x31/0x50
[   25.226504]  [<c162a4e8>] __sys_sendmsg+0x38/0x70
[   25.226510]  [<c162a536>] SyS_sendmsg+0x16/0x20
[   25.226517]  [<c162ac1b>] SyS_socketcall+0x29b/0x2f0
[   25.226524]  [<c11440bd>] ? ____fput+0xd/0x10
[   25.226531]  [<c1035b80>] ? vmalloc_sync_all+0x10/0x10
[   25.226537]  [<c17a7fbb>] sysenter_do_call+0x12/0x22
[   25.226600] Code: e9 4a ff ff ff 8b 7d f0 eb b5 31 c0 eb dc 89 f9 b8 00 10 00 00 d3 e0 ba 5a 00 00 00 89 c1 8b 45 f0 e8 ae 42 18 00 e9 38 ff ff ff <0f> 0b 8b 7b 24 b9 00 0f af c1 8b 45 f0 c7 04 24 00 00 00 00 89
[   25.226609] EIP: [<c1135e27>] new_slab+0x1c7/0x200 SS:ESP 0068:f514f904
[   25.226614] ---[ end trace 6188393b9e234ab1 ]---
[   26.757161] input: ACPI Virtual Keyboard Device as /devices/virtual/input/input13

Reverting the skbuff.c patch and using only the atl1c_main.c one, I
see again the failures with the driver.

So far the only options that seem to get the driver working for me are
either Neil Horman's patch or reverting 69b08f6 ("net: use bigger
pages in __netdev_alloc_frag").

Cheers
-- 
Luis
