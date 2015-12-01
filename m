From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Tue, 01 Dec 2015 17:40:09 +0300
Message-ID: <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

 This one breaks networking on my machine:
--- cut ---
swiotlb: coherent allocation failed for device 0002:01:08.4 size=4198400
CPU: 2 PID: 3655 Comm: NetworkManager Tainted: G        W  O    4.2.6+ #201
Hardware name: Cavium ThunderX CN88XX board (DT)
Call trace:
[<ffffffc00008a3d4>] dump_backtrace+0x0/0x124
[<ffffffc00008a50c>] show_stack+0x14/0x1c
[<ffffffc0006df258>] dump_stack+0x88/0xc8
[<ffffffc000416994>] swiotlb_alloc_coherent+0x150/0x168
[<ffffffc00009555c>] __dma_alloc+0x58/0x1e8
[<ffffffc000507cd8>] nicvf_alloc_q_desc_mem.isra.14+0xc0/0xdc
[<ffffffc000508c8c>] nicvf_config_data_transfer+0x448/0x728
[<ffffffc000506c64>] nicvf_open+0x184/0x994
[<ffffffc0005ea0b4>] __dev_open+0xb4/0x120
[<ffffffc0005ea388>] __dev_change_flags+0x8c/0x150
[<ffffffc0005ea46c>] dev_change_flags+0x20/0x5c
[<ffffffc0005fb210>] do_setlink+0x27c/0x8e0
[<ffffffc0005fbe28>] rtnl_newlink+0x4b4/0x6c4
[<ffffffc0005fa6f0>] rtnetlink_rcv_msg+0x90/0x22c
[<ffffffc000611b74>] netlink_rcv_skb+0xd8/0x100
[<ffffffc0005fa650>] rtnetlink_rcv+0x30/0x40
[<ffffffc000611498>] netlink_unicast+0x158/0x1f8
[<ffffffc000611910>] netlink_sendmsg+0x324/0x380
[<ffffffc0005c6690>] sock_sendmsg+0x18/0x58
[<ffffffc0005c6db8>] ___sys_sendmsg+0x254/0x264
[<ffffffc0005c7bb8>] __sys_sendmsg+0x40/0x84
[<ffffffc0005c7c0c>] SyS_sendmsg+0x10/0x20
thunder-nicvf 0002:01:08.4 enP2p1s8f4: Failed to alloc/config VF's QSet resources
--- cut ---

 And none of interfaces work after this. Reverting this patch helps.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Sunil
> Goutham
> Sent: Tuesday, December 01, 2015 12:14 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> Sunil.Goutham@caviumnetworks.com; Sunil Goutham
> Subject: [PATCH 3/6] net: thunderx: Increase transmit queue length
> 
> From: Sunil Goutham <sgoutham@cavium.com>
> 
> Under high transmit rates and with TSO enabled observing fluctuations
> in TX performance. Seen especially with iperf3 application.
> 
> Since TSO is taken care at driver level, with 64KB of TSO packets
> and when window size is also high the rate at which CPU fills in
> transmit descriptors is much higher than what HW is able to process.
> Each 64KB TSO packet occupies gets segmented to ~43 1500 byte MTU packets
> and occupies ~130 descriptors. Hence increasing transmit queue size.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
> b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
> index fb4957d..b1e93a9 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
> @@ -62,7 +62,7 @@
>  #define SND_QUEUE_CNT		8
>  #define CMP_QUEUE_CNT		8 /* Max of RCV and SND qcount */
> 
> -#define SND_QSIZE		SND_QUEUE_SIZE2
> +#define SND_QSIZE		SND_QUEUE_SIZE3
>  #define SND_QUEUE_LEN		(1ULL << (SND_QSIZE + 10))
>  #define MAX_SND_QUEUE_LEN	(1ULL << (SND_QUEUE_SIZE6 + 10))
>  #define SND_QUEUE_THRESH	2ULL
> @@ -73,7 +73,7 @@
>  /* Keep CQ and SQ sizes same, if timestamping
>   * is enabled this equation will change.
>   */
> -#define CMP_QSIZE		CMP_QUEUE_SIZE2
> +#define CMP_QSIZE		CMP_QUEUE_SIZE3
>  #define CMP_QUEUE_LEN		(1ULL << (CMP_QSIZE + 10))
>  #define CMP_QUEUE_CQE_THRESH	0
>  #define CMP_QUEUE_TIMER_THRESH	220 /* 10usec */
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
