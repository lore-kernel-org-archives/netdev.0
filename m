From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 01/12] net: mediatek: fix DQL support
Date: Mon, 6 Jun 2016 08:43:13 +0200
Message-ID: <e1b52f75-edb7-8504-3e6d-40fcb03e39df@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
 <1465108385-38286-2-git-send-email-john@phrozen.org>
 <20160605.003242.796780762112643713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	keyhaede@gmail.com, linux-kernel@vger.kernel.org, nbd@nbd.name
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160605.003242.796780762112643713.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/06/2016 09:32, David Miller wrote:
> From: John Crispin <john@phrozen.org>
> Date: Sun,  5 Jun 2016 08:32:54 +0200
> 
>> @@ -625,7 +625,16 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
>>  	WRITE_ONCE(itxd->txd3, (TX_DMA_SWC | TX_DMA_PLEN0(skb_headlen(skb)) |
>>  				(!nr_frags * TX_DMA_LS0)));
>>  
>> -	netdev_sent_queue(dev, skb->len);
>> +	/* we have a single DMA ring so BQL needs to be updated for all devices
>> +	 * sitting on this ring
>> +	 */
>> +	for (i = 0; i < MTK_MAC_COUNT; i++) {
>> +		if (!eth->netdev[i])
>> +			continue;
>> +
>> +		netdev_sent_queue(eth->netdev[i], skb->len);
>> +	}
>> +
>>  	skb_tx_timestamp(skb);
> 
> Sorry, this is very far from working.
> 
> You cannot asynchronously touch the DQL state of another netdevice.
> 
> You have to hold the TX lock of a queue while changing it's DQL state,
> otherwise you'll corrupt the state.
> 
> This "loop over all possible devices on this DMA ring" is pretty
> expensive for the problem you're trying to solve.
> 
> You'll have to find another way to fix this bug, which BTW I'm not too
> clear about.  The commit message doesn't explain sufficiently what the
> actual problem is.  "not deterministic" doesn't give enough details.
> 

Hi David,

DQL is supposed to measure how much data is enqueued on a netdev. the
problem here is that two devices share the same hardware queue. fq_codel
for example uses the values from dql to base its QoS judgement on. if we
track the dql of the 2 devices separately then the values will not take
the actual amount of data enqueued into account but only parts of it.
this will make the queue length used as a basis for fq_codel
calculations non deterministic thus breaking qos. dql needs to track the
amount of data in the physical queue underlying the netdev to be useful.
hope that explanation is better to understand.

i think one solution would be to add some code to have 2 devices share
the same dql instance. would that be an acceptable solution ?

anyhow, i will resend the series without the dql patch today and then
worry about it afterwards.

	John
