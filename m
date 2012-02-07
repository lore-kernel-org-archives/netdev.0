From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 02/11] e1000: Adding e1000_dump function
Date: Tue, 07 Feb 2012 07:40:03 -0800
Message-ID: <1328629203.4837.6.camel@joe2Laptop>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Tushar Dave <tushar.n.dave@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52173 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751625Ab2BGPkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 10:40:06 -0500
In-Reply-To: <1328618038-5008-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-07 at 04:33 -0800, Jeff Kirsher wrote:
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c

trivia:

> @@ -3239,6 +3239,228 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
>  	return NETDEV_TX_OK;
>  }
>  
> +#define NUM_REGS 38 /* 1 based count */
> +static void e1000_regdump(struct e1000_adapter *adapter)
> +{
> +	struct e1000_hw *hw = &adapter->hw;
> +	u32 regs[NUM_REGS];
> +	u32 *regs_buff = regs;
> +	int i = 0;
> +
> +	char *reg_name[] = {

static const char * const reg_name[]
(and the layout is poor)

> +	"CTRL",  "STATUS",
> +	"RCTL", "RDLEN", "RDH", "RDT", "RDTR",
> +	"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
> +	"TIDV", "TXDCTL", "TADV", "TARC0",
> +	"TDBAL1", "TDBAH1", "TDLEN1", "TDH1", "TDT1",
> +	"TXDCTL1", "TARC1",
> +	"CTRL_EXT", "ERT", "RDBAL", "RDBAH",
> +	"TDFH", "TDFT", "TDFHS", "TDFTS", "TDFPC",
> +	"RDFH", "RDFT", "RDFHS", "RDFTS", "RDFPC"
> +	};
> +	pr_info("Register dump\n");
> +	for (i = 0; i < NUM_REGS; i++) {
> +		printk(KERN_INFO "%-15s  %08x\n",
> +		reg_name[i], regs_buff[i]);
> +	}

		pr_info(%-15s  %08x\n", reg_name[i], regs_buff[i]);

[]
> +static void e1000_dump(struct e1000_adapter *adapter)
[]
> +	printk(KERN_INFO "Tc[desc]     [Ce CoCsIpceCoS] [MssHlRSCm0Plen] [bi->dma       ]"
> +	       " leng  ntw timestmp         bi->skb\n");
> +	printk(KERN_INFO "Td[desc]     [address 63:0  ] [VlaPoRSCm1Dlen] [bi->dma       ]"
> +	       " leng  ntw timestmp         bi->skb\n");

pr_info

> +
> +	if (!netif_msg_tx_done(adapter))
> +		goto rx_ring_summary;
> +
> +	for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
> +		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
> +		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
> +		struct my_u { u64 a; u64 b; };
> +		struct my_u *u = (struct my_u *)tx_desc;
> +		printk(KERN_INFO "T%c[0x%03X]    %016llX %016llX %016llX %04X  %3X "
> +		       "%016llX %p",
> +		       ((le64_to_cpu(u->b) & (1<<20)) ? 'd' : 'c'), i,
> +		       le64_to_cpu(u->a), le64_to_cpu(u->b),
> +		       (u64)buffer_info->dma, buffer_info->length,
> +		       buffer_info->next_to_watch, (u64)buffer_info->time_stamp,
> +		       buffer_info->skb);
> +		if (i == tx_ring->next_to_use &&bet i == tx_ring->next_to_clean)
> +			printk(KERN_CONT" NTC/U\n");
> +		else if (i == tx_ring->next_to_use)
> +			printk(KERN_CONT " NTU\n");
> +		else if (i == tx_ring->next_to_clean)
> +			printk(KERN_CONT " NTC\n");
> +		else
> +			printk(KERN_CONT "\n");
> +


better to use a temporary char * for NTC/NTU/NTC/""
and use a single pr_info()

> +	for (i = 0; rx_ring->desc && (i < rx_ring->count); i++) {
> +		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rx_ring, i);
> +		struct e1000_buffer *buffer_info = &rx_ring->buffer_info[i];
> +		struct my_u { u64 a; u64 b; };
> +		struct my_u *u = (struct my_u *)rx_desc;
> +		printk(KERN_INFO "R[0x%03X]     %016llX %016llX %016llX %p",
> +			i, le64_to_cpu(u->a), le64_to_cpu(u->b),
> +			(u64)buffer_info->dma, buffer_info->skb);
> +		if (i == rx_ring->next_to_use)
> +			printk(KERN_CONT " NTU\n");
> +		else if (i == rx_ring->next_to_clean)
> +			printk(KERN_CONT " NTC\n");
> +		else
> +			printk(KERN_CONT "\n");

temporary here too
