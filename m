From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v2 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 20:46:06 +0200
Message-ID: <552ABD6E.10000@openwrt.org>
References: <1428848565-94187-1-git-send-email-nbd@openwrt.org>	 <1428848565-94187-4-git-send-email-nbd@openwrt.org> <1428862182.25985.354.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:36537 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbbDLSqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2015 14:46:19 -0400
In-Reply-To: <1428862182.25985.354.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-12 20:09, Eric Dumazet wrote:
> On Sun, 2015-04-12 at 16:22 +0200, Felix Fietkau wrote:
>> The driver needs to inform the hardware about the first invalid (not yet
>> filled) rx slot, by writing its DMA descriptor pointer offset to the
>> BGMAC_DMA_RX_INDEX register.
>> 
>> This register was set to a value exceeding the rx ring size, effectively
>> allowing the hardware constant access to the full ring, regardless of
>> which slots are initialized.
>> 
>> Fix this by updating the register in bgmac_dma_rx_setup_desc.
>> 
>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac.c | 27 ++++++++++++++++++---------
>>  1 file changed, 18 insertions(+), 9 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
>> index e332de8..67993d7 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -362,6 +362,16 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
>>  	return 0;
>>  }
>>  
>> +static void bgmac_dma_rx_update_index(struct bgmac *bgmac,
>> +				      struct bgmac_dma_ring *ring)
>> +{
>> +	dma_wmb();
>> +
>> +	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
>> +		    ring->index_base +
>> +		    ring->end * sizeof(struct bgmac_dma_desc));
>> +}
>> +
>>  static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>>  				    struct bgmac_dma_ring *ring, int desc_idx)
>>  {
>> @@ -380,6 +390,8 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>>  	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
>>  	dma_desc->ctl0 = cpu_to_le32(ctl0);
>>  	dma_desc->ctl1 = cpu_to_le32(ctl1);
>> +
>> +	ring->end = (desc_idx + 1) % BGMAC_RX_RING_SLOTS;
> 
> Given the fact that previous driver kind of worked, have you tried not
> doing the modulo at all here ?
The previous driver was causing reproducible DMA corruption issues under
load. My patch fixes this, and I've verified this with hours of stress
testing (previously I could reproduce the issue in minutes).

> ring->end = desc_idx + 1;
> 
> It looks like the hardware accepted setting BGMAC_DMA_RX_INDEX to
> ring->index_base + ring->num_slots * sizeof(struct bgmac_dma_desc)
The hardware accepts it, but with that value, it considers all rx slot
entries filled, there's no CPU ownership bit in the descriptor.
According to documentation, that register indicates the first *invalid*
rx descriptor (i.e. one where the CPU hasn't posted a valid buffer yet).

> So apparently the presence of BGMAC_DESC_CTL0_EOT in last rx desc was
> enough to avoid any problem with this.
EOT serves a completely different purpose. It simply indicates the end
of the ring, telling the hardware to go back to the beginning for the
next descriptor.

- Felix
