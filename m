From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 18:52:34 +0300
Message-ID: <517E9742.1010002@freescale.com>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>  <1367243593.8964.306.camel@edumazet-glaptop>  <517E8354.1010503@freescale.com>  <1367249009.8964.312.camel@edumazet-glaptop> <1367249315.8964.314.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.14] ([65.55.88.14]:23220 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757091Ab3D2Px5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:53:57 -0400
In-Reply-To: <1367249315.8964.314.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/2013 6:28 PM, Eric Dumazet wrote:
> On Mon, 2013-04-29 at 08:23 -0700, Eric Dumazet wrote:
>> On Mon, 2013-04-29 at 17:27 +0300, Claudiu Manoil wrote:
>>> Hi,
>>>
>>> Unfortunately fixing this the other way around would imply changes
>>> in both xmit and clean_tx, and additional overhead in clean_tx.
>>> On xmit skb->len gets incremented with FCB_LEN and/or TXPAL_LEN,
>>> on a case by case basis. This would imply to add extra checks on
>>> clean_tx to identify whether only FCB_LEN has been added, or
>>> FCB+TXPAL or neither, all these just to report the bytes on wire
>>> for BQL.
>>> Does BQL really need to measure the bytes-on-wire or the bytes consumed
>>> for buffering?
>>
>> Yes.
>>
>> What about :
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
>> index 2375a01..bb727e1 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -2065,6 +2065,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	u32 bufaddr;
>>   	unsigned long flags;
>>   	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
>> +	unsigned int len;
>>
>>   	/* TOE=1 frames larger than 2500 bytes may see excess delays
>>   	 * before start of transmission.
>> @@ -2130,7 +2131,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	}
>>
>>   	/* Update transmit stats */
>> -	tx_queue->stats.tx_bytes += skb->len;
>> +	len = skb->len;

Already tried this change in xmit, but it breaks the UDP/TCP cases (eg. 
ftp). Due to (skb->ip_summed == CHECKSUM_PARTIAL) condition FCB is
added on xmit (skb->len increased with FCB_LEN only), and Tx completion
does not make this check.

> Idea is to use this value in TX completion.
>
> If at tx completion skb->len might be different, then store the true
> skb->len in skb->cb[]
>

Interesting but non-trivial, I think. Is this allowed? I mean, doesn't
the net stack overwrite this field?

Thanks,
Claudiu
