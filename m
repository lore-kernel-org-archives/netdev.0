From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v2] b44: fix misalignment and wasted space in rx handling
Date: Fri, 09 Jan 2009 23:55:26 +0100
Message-ID: <4967D5DE.2050002@openwrt.org>
References: <4967459D.3070207@openwrt.org> <200901092325.50955.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, zambrano@broadcom.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:34143 "EHLO ds10.mine.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400AbZAIWzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:55:35 -0500
In-Reply-To: <200901092325.50955.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Buesch wrote:
> On Friday 09 January 2009 13:39:57 Felix Fietkau wrote:
>> --- a/drivers/net/b44.c
>> +++ b/drivers/net/b44.c
>> @@ -73,8 +73,8 @@
>>  	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
>>  #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
>>  
>> -#define RX_PKT_OFFSET		30
>> -#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET + 64)
>> +#define RX_PKT_OFFSET		(RX_HEADER_LEN + 2)
>> +#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET)
>>  
>>  /* minimum number of free TX descriptors required to wake up TX process */
>>  #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
>> @@ -682,7 +682,6 @@ static int b44_alloc_rx_skb(struct b44 *
>>  	}
>>  
>>  	rh = (struct rx_header *) skb->data;
>> -	skb_reserve(skb, RX_PKT_OFFSET);
> 
> Looks correct.
> 
>>  	rh->len = 0;
>>  	rh->flags = 0;
>> @@ -693,13 +692,13 @@ static int b44_alloc_rx_skb(struct b44 *
>>  	if (src_map != NULL)
>>  		src_map->skb = NULL;
>>  
>> -	ctrl  = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - RX_PKT_OFFSET));
>> +	ctrl = (DESC_CTRL_LEN & RX_PKT_BUF_SZ);
> 
> Are you sure this is right? b43 has the same DMA engine, and we
> subtract the offset from the buffer size there. So we end up with
> the descriptor control field telling the space available for the frame payload.
Quote from a Datasheet for the BCM5365 that I found online:

"This field is the length, in bytes, of the data buffer associated with this
descriptor. A descriptor with a BufCount value greater than 0x1000 causes a
descriptor protocol error."

I checked the public hnddma.c code and it also appears to not subtract
the packet offset either, so I think my version is correct.

- Felix


