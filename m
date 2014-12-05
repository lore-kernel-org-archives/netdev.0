From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH 2/2] gianfar: handle map error in gfar_start_xmit()
Date: Fri, 5 Dec 2014 16:51:38 +0200
Message-ID: <5481C67A.2090200@freescale.com>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
 <1417775874-17775-3-git-send-email-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Arseny Solokha <asolokha@kb.kras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417775874-17775-3-git-send-email-asolokha@kb.kras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/5/2014 12:37 PM, Arseny Solokha wrote:
> From: Arseny Solokha <asolokha@kb.kras.ru>
>
> When DMA-API debugging is enabled in the kernel, it spews the following
> upon upping the link:
>
> WARNING: at lib/dma-debug.c:1135
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W  O   3.18.0-rc7 #1
> task: c0720340 ti: effe2000 task.ti: c0750000
> NIP: c01d7c1c LR: c01d7c1c CTR: c02250fc
> REGS: effe3d40 TRAP: 0700   Tainted: G        W  O    (3.18.0-rc7)
> MSR: 00021000 <CE,ME>  CR: 22044242  XER: 20000000
>
> GPR00: c01d7c1c effe3df0 c0720340 00000095 c201e404 c201e9f0 00021000 01a9d000
> GPR08: 00000007 00000000 01a9d000 00000313 22044242 00583f60 05f41012 00000000
> GPR16: 00000000 000000ff 00000000 00000000 00000000 c5dc3b40 c5677720 00000001
> GPR24: c0730000 00029000 c0d0d828 c072c394 effe3e48 c075baec c0d0f020 ee31e600
> NIP [c01d7c1c] check_unmap+0x5b4/0xae4
> LR [c01d7c1c] check_unmap+0x5b4/0xae4
> Call Trace:
> [effe3df0] [c01d7c1c] check_unmap+0x5b4/0xae4 (unreliable)
> [effe3e40] [c01d81c4] debug_dma_unmap_page+0x78/0x8c
> [effe3ec0] [c0286ba0] gfar_clean_tx_ring+0x120/0x3c0
> [effe3f30] [c0286f90] gfar_poll_tx_sq+0x48/0x94
> o[effe3f50] [c030c388] net_rx_action+0x130/0x1ac
> [effe3f80] [c00319e0] __do_softirq+0x134/0x240
> [effe3fe0] [c0031dd0] irq_exit+0xa4/0xc8
> [effe3ff0] [c000e01c] call_do_irq+0x24/0x3c
> [c0751e70] [c0004a04] do_IRQ+0x8c/0x108
> [c0751e90] [c0010068] ret_from_except+0x0/0x18
> --- interrupt: 501 at arch_cpu_idle+0x24/0x5c
>      LR = arch_cpu_idle+0x24/0x5c
> [c0751f50] [c007d2e4] rcu_idle_enter+0xc8/0xcc (unreliable)
> [c0751f60] [c006587c] cpu_startup_entry+0x1d4/0x29c
> [c0751fb0] [c054399c] start_kernel+0x338/0x34c
> [c0751ff0] [c000046c] set_ivor+0x154/0x190
> Instruction dump:
> 394adb30 80fc0018 811c001c 3c60c04f 5529103a 7cca482e 38639e60 813c0020
> 815c0024 90c10008 4cc63182 48240b01 <0fe00000> 3c60c04f 3863971c 4cc63182
> ---[ end trace 3eb7bf62ba1b80f9 ]---
> Mapped at:
>   [<c0287420>] gfar_start_xmit+0x424/0x910
>   [<c030e964>] dev_hard_start_xmit+0x20c/0x3d8
>   [<c032cc3c>] sch_direct_xmit+0x124/0x22c
>   [<c030ede8>] __dev_queue_xmit+0x2b8/0x674
>
> Or the following upon starting transmission of some large chunks
> of data:
>
> fsl-gianfar ffe25000.ethernet: DMA-API: device driver failed to check map error[device address=0x0000000005fa8000]
> ------------[ cut here ]------------
> WARNING: at lib/dma-debug.c:1135
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O   3.18.0-rc7 #35
> task: c071d340 ti: effe2000 task.ti: c074e000
> NIP: c01d7c1c LR: c01d7c1c CTR: c022339c
> REGS: effe3d40 TRAP: 0700   Tainted: G           O    (3.18.0-rc7)
> MSR: 00021000 <CE,ME>  CR: 22044242  XER: 20000000
>
> GPR00: c01d7c1c effe3df0 c071d340 00000094 00000001 c0071750 00000000 00000001
> GPR08: 00000000 00000000 effe2000 00000000 20044242 00581f60 05fa8000 000001c4
> GPR16: 00000000 000000ff 00000000 000000e4 00000039 c5b1a9c0 c5679c60 00000002
> GPR24: c0730000 00029000 c0d0c528 c0729394 effe3e48 c0759aec c0d0d020 ee315900
> NIP [c01d7c1c] check_unmap+0x5b4/0xae4
> LR [c01d7c1c] check_unmap+0x5b4/0xae4
> Call Trace:
> [effe3df0] [c01d7c1c] check_unmap+0x5b4/0xae4 (unreliable)
> [effe3e40] [c01d81c4] debug_dma_unmap_page+0x78/0x8c
> [effe3ec0] [c0284c78] gfar_clean_tx_ring+0x1b4/0x3c0
> [effe3f30] [c0284fd4] gfar_poll_tx_sq+0x48/0x94
> [effe3f50] [c030a5c4] net_rx_action+0x130/0x1ac
> [effe3f80] [c00319e0] __do_softirq+0x134/0x240
> [effe3fe0] [c0031dd0] irq_exit+0xa4/0xc8
> [effe3ff0] [c000e01c] call_do_irq+0x24/0x3c
> [c074fe70] [c0004a04] do_IRQ+0x8c/0x108
> [c074fe90] [c0010068] ret_from_except+0x0/0x18
> --- interrupt: 501 at arch_cpu_idle+0x24/0x5c
>      LR = arch_cpu_idle+0x24/0x5c
> [c074ff50] [c007d2e4] rcu_idle_enter+0xc8/0xcc (unreliable)
> [c074ff60] [c006587c] cpu_startup_entry+0x1d4/0x29c
> [c074ffb0] [c054199c] start_kernel+0x338/0x34c
> [c074fff0] [c000046c] set_ivor+0x154/0x190
> Instruction dump:
> 394abb30 80fc0018 811c001c 3c60c04e 5529103a 7cca482e 386379f0 813c0020
> 815c0024 90c10008 4cc63182 4823ed39 <0fe00000> 3c60c04e 386372ac 4cc63182
> ---[ end trace 008c59ca7ca1f712 ]---
> Mapped at:
>   [<c0285264>] gfar_start_xmit+0x224/0x95c
>   [<c030cba0>] dev_hard_start_xmit+0x20c/0x3d8
>   [<c032ae78>] sch_direct_xmit+0x124/0x22c
>   [<c032b008>] __qdisc_run+0x88/0x1c0
>   [<c0307920>] net_tx_action+0xf0/0x19c
>
> Ignore these mapping failures in hope we'll have more luck next time.
>
> Signed-off-by: Arseny Solokha <asolokha@kb.kras.ru>
> ---
>   drivers/net/ethernet/freescale/gianfar.c | 17 +++++++++++++++--
>   1 file changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index f34ca55..9ea887e 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2296,6 +2296,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   						   0,
>   						   frag_len,
>   						   DMA_TO_DEVICE);
> +			if (unlikely(dma_mapping_error(priv->dev, bufaddr))) {
> +				/* As DMA mapping failed, pretend the TX path
> +				 * is busy to retry later
> +				 */
> +				return NETDEV_TX_BUSY;

This is not right.
Proper bailout code missing: un-mapping of skb fragments and 
de-allocation of resources.
This is not a TX_BUSY error condition, it's a system failure.
(will resubmit this one:
http://permalink.gmane.org/gmane.linux.network/336274)

> +			}
>
>   			/* set the TxBD length and buffer pointer */
>   			txbdp->bufPtr = bufaddr;
> @@ -2345,8 +2351,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   		fcb->ptp = 1;
>   	}
>
> -	txbdp_start->bufPtr = dma_map_single(priv->dev, skb->data,
> -					     skb_headlen(skb), DMA_TO_DEVICE);
> +	bufaddr = dma_map_single(priv->dev, skb->data, skb_headlen(skb),
> +				 DMA_TO_DEVICE);
> +	if (unlikely(dma_mapping_error(priv->dev, bufaddr))) {
> +		/* As DMA mapping failed, pretend the TX path is busy to retry
> +		 * later
> +		 */
> +		return NETDEV_TX_BUSY;

same here

> +	}
> +	txbdp_start->bufPtr = bufaddr;
>
>   	/* If time stamping is requested one additional TxBD must be set up. The
>   	 * first TxBD points to the FCB and must have a data length of
>
