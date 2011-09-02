From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] ixgbe: drop zero length frame segments during a packet
 split rx
Date: Fri, 02 Sep 2011 09:17:40 -0700
Message-ID: <4E6101A4.4060802@intel.com>
References: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16338 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150Ab1IBQQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 12:16:25 -0400
In-Reply-To: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kind of fix just opens up a whole can of security related worms.  
If you are going to discard a packet you should do it after we have 
reached the EOP in the series.  My advice would be to determine what 
traits identify this packet and add those to the check for the 
IXGBE_RXDADV_ERR_FRAME_ERR_MASK check further down in the code.  Likely 
what you are seeing is skb_headlen(skb) will be equal to 0.

I'm suspecting this is some sort of read corruption.  It looks like in 
order to trigger it you have to either be reading rx_buffer_info->dma as 
0, or the header length is being read as 0.  Do you know if you actually 
have header split enabled when this is occuring?  Are you running with 
jumbo frames enabled to see the issue?  If not then packet split 
wouldn't be enabled.

Is this occurring on net-next or on an older kernel?  I just want to be 
sure since we added a read memory barrier in 2.6.34 to address the fact 
that the length and descriptor DD bits were being read in the wrong 
order resulting in the length being corrupted on PowerPC systems.  The 
fact that we are now seeing another length error on PowerPC seems very odd.

Thanks,

Alex

On 09/02/2011 07:03 AM, Neil Horman wrote:
> This oops was reported recently no ppc64 hardware:
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc0000000004dda0c
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=1024 NUMA pSeries
> Modules linked in: sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
> iptable_fi
> lter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
> nf_conntrack ip6table_filter ip6_tables ipv6 jsm ses enclosure sg ixgbe
> mdio e1000 ehea ext4 jbd2 mbcache sd_mod crc_t10dif ipr dm_mod
> NIP: c0000000004dda0c LR: c0000000004e3e50 CTR: c0000000004e3e20
> REGS: c0000001bffeb8d0 TRAP: 0300   Not tainted  (3.1.0-rc2-10121-gab7e2db)
> MSR: 8000000000009032<EE,ME,IR,DR>   CR: 28002042  XER: 20000000
> CFAR: c000000000004d70
> DAR: 0000000000000000, DSISR: 40000000
> TASK = c000000000d548e0[0] 'swapper' THREAD: c000000000dfc000 CPU: 0
> GPR04: c0000000010f4d80 c0000001bffebd80 0000000000000000 c0000001b18a8200
> GPR08: 0000000000000280 c0000001bcc517a8 c0000001b18a7f80 0000000000000000
> GPR12: d0000000047e5bb0 c000000001f10000 c0000001b19c8700 0000000000000000
> GPR16: c0000001bffebd80 0000000000000083 c00000018f2447a0 0000000000000002
> GPR20: 0000000000000000 c0000001ba860010 c0000001ba860000 d000000003d40000
> GPR24: 0000000000000000 0000000000000083 d000000003d40000 0000000000000001
> GPR28: c00000018f244780 c0000001b2b94310 c000000000da95f0 c0000001bcc51780
> NIP [c0000000004dda0c] .skb_gro_reset_offset+0x5c/0xe0
> LR [c0000000004e3e50] .napi_gro_receive+0x30/0x120
> Call Trace:
> [c0000001bffebb50] [c000000000da95f0] perf_callchain_user+0x0/0x10 (unreliable)
> [c0000001bffebbf0] [d0000000047bd118] .ixgbe_clean_rx_irq+0x7a8/0x8a0 [ixgbe]
> [c0000001bffebd10] [d0000000047bd414] .ixgbe_poll+0x64/0x160 [ixgbe]
> [c0000001bffebdd0] [c0000000004e3358] .net_rx_action+0x108/0x2a0
> [c0000001bffebea0] [c00000000009b220] .__do_softirq+0x110/0x2a0
> [c0000001bffebf90] [c000000000023798] .call_do_softirq+0x14/0x24
> [c000000000dff830] [c000000000011148] .do_softirq+0xf8/0x130
> [c000000000dff8d0] [c00000000009aeb4] .irq_exit+0xb4/0xc0
> [c000000000dff950] [c000000000011254] .do_IRQ+0xd4/0x300
> [c000000000dffa10] [c000000000005024] hardware_interrupt_entry+0x18/0x74
> --- Exception: 501 at .pseries_dedicated_idle_sleep+0xe4/0x210
> LR = .pseries_dedicated_idle_sleep+0x8c/0x210
> [c000000000dffd00] [c00000000005b194] .pseries_dedicated_idle_sleep+0x194/0x210
> (unreliable)
> [c000000000dffdc0] [c000000000018c84] .cpu_idle+0x164/0x210
> [c000000000dffe70] [c00000000000b0d0] .rest_init+0x90/0xb0
> [c000000000dffef0] [c000000000830bc0] .start_kernel+0x54c/0x56c
> [c000000000dfff90] [c00000000000953c] .start_here_common+0x1c/0x60
>
> Its caused when skb_gro_reset_offset attempts to call PageHighMem on
> skb_shinfo(skb)->frags[0].page, when the frags array was left uninitalized.
> This can happen in the ixgbe driver if the hardware reports a zero length rx
> descriptor ni the middle of a packet split receive transaction.  I've consulted
> with Jesse Brandeburg on this, who is attempting to root cause the issue at
> Intel, but it seems prudent to add this check to the driver to discard frames of
> that encounter this error to avoid the opps
>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> Signed-off-by: Thadeu Lima de Souza Cascardo<cascardo@linux.vnet.ibm.com>
> CC: Jesse Brandeburg<jesse.brandeburg@intel.com>
> CC: Alexander Duyck<alexander.h.duyck@intel.com>
> CC: John Fastabend<john.r.fastabend@intel.com>
> CC: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> CC: David S. Miller<davem@davemloft.net>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   17 +++++++++++------
>   1 files changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d20e804..6d59185 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1326,6 +1326,13 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>
>   		rx_buffer_info =&rx_ring->rx_buffer_info[i];
>
> +		i++;
> +		if (i == rx_ring->count)
> +			i = 0;
> +
> +		next_rxd = IXGBE_RX_DESC_ADV(rx_ring, i);
> +		prefetch(next_rxd);
> +
>   		skb = rx_buffer_info->skb;
>   		rx_buffer_info->skb = NULL;
>   		prefetch(skb->data);
> @@ -1367,6 +1374,10 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>   		} else {
>   			/* assume packet split since header is unmapped */
>   			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
> +			if (!upper_len) {
> +				rx_buffer_info->skb = skb;
> +				goto next_desc;
> +			}
>   		}
>
>   		if (upper_len) {
> @@ -1391,12 +1402,6 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>   			skb->truesize += upper_len;
>   		}
>
> -		i++;
> -		if (i == rx_ring->count)
> -			i = 0;
> -
> -		next_rxd = IXGBE_RX_DESC_ADV(rx_ring, i);
> -		prefetch(next_rxd);
>   		cleaned_count++;
>
>   		if (pkt_is_rsc) {
