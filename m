From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 12:43:56 +0200
Message-ID: <552A4C6C.7020802@openwrt.org>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org>	 <1428833292-15356-4-git-send-email-nbd@openwrt.org> <1428834675.25985.344.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:52391 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383AbbDLKoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2015 06:44:02 -0400
In-Reply-To: <1428834675.25985.344.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-12 12:31, Eric Dumazet wrote:
> On Sun, 2015-04-12 at 12:08 +0200, Felix Fietkau wrote:
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
>>  drivers/net/ethernet/broadcom/bgmac.c | 14 +++++++-------
>>  1 file changed, 7 insertions(+), 7 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
>> index e332de8..856ceee 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -693,10 +697,6 @@ static void bgmac_dma_init(struct bgmac *bgmac)
>>  		for (j = 0; j < ring->num_slots; j++)
>>  			bgmac_dma_rx_setup_desc(bgmac, ring, j);
>>  
> 
> Missing dma_wmb() here  (or legacy wmb() for stable kernels)
Right, thanks.

>> -		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
>> -			    ring->index_base +
>> -			    ring->num_slots * sizeof(struct bgmac_dma_desc));
>> -
> 
> 
> This might be better for performance to perform one single bgmac_write()
> at the end of bgmac_dma_rx_read(), and leave this one in place as well,
> not for performance since this is slow path, but correctness.
I intentionally made it write this field for every slot update, because
it might potentially allow the hardware to push frames faster when under
pressure. The CPU isn't fast enough to handle gigabit speeds anyway.

And by the way, the value that is written in this removed call is quite
wrong, so I'd rather just remove it instead of leaving a duplicate here.

> Also I am surprised there is no memory barrier to make sure changes to
> dma_desc are committed to memory ?
> 
> I would use dma_wmb() before bgmac_write(), like the wmb() done in
> bgmac_dma_tx_add()
Will add that.

- Felix
