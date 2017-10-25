From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Learn addresses on CPU
 port when bridged
Date: Wed, 25 Oct 2017 12:54:18 +0200
Message-ID: <b0da2547-69d3-b323-6918-1022e112f7db@egil-hjelmeland.no>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-3-privat@egil-hjelmeland.no>
 <9235D6609DB808459E95D78E17F2E43D40B889C8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Woojung.Huh@microchip.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:56686 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932455AbdJYKyd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 06:54:33 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B889C8@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Woojung!

On 24. okt. 2017 19:18, Woojung.Huh@microchip.com wrote:
> Hi Egil,
> 
>> +static inline int lan9303_tx_use_arl(struct dsa_port *dp, u8 *dest_addr)
>> +{
>> +	struct lan9303 *chip = dp->ds->priv;
>> +
>> +	return chip->is_bridged && !ether_addr_equal(dest_addr,
>> eth_stp_addr);
>> +}
>>
>>   static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device
>> *dev)
>>   {
>> @@ -62,7 +80,10 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb,
>> struct net_device *dev)
>>
>>   	lan9303_tag = (u16 *)(skb->data + 2 * ETH_ALEN);
>>   	lan9303_tag[0] = htons(ETH_P_8021Q);
>> -	lan9303_tag[1] = htons(dp->index | BIT(4));
>> +	lan9303_tag[1] = lan9303_tx_use_arl(dp, skb->data) ?
> 
> How about using skb_mac_header(skb) than skb->data?
> 
>> +				LAN9303_TAG_TX_USE_ALR :
>> +				dp->index |
> 

I am not the expert here.

I see that skb_mac_header() is (skb->head + skb->mac_header). So it will
cost a few nano seconds per packet. Not the end of the world though.
But I see that other net/dsa/tag_*.c use skb->data, assuming that
skb->data point to mac header.

Anyway, it may be an idea to decrement skb->mac_header, in case the
master interface driver uses it? What about skb->mac_len?

If to use skb_mac_header() at all, I would replace all use of skb->data,
like this:

---
/* provide 'LAN9303_TAG_LEN' bytes additional space */
skb_push(skb, LAN9303_TAG_LEN);

/* make room between MACs and Ether-Type */
memmove(skb_mac_header(skb) - LAN9303_TAG_LEN, skb_mac_header(skb),
		2 * ETH_ALEN);
skb->mac_header -= LAN9303_TAG_LEN;

lan9303_tag = (u16 *)(skb_mac_header(skb) + 2 * ETH_ALEN);
lan9303_tag[0] = htons(ETH_P_8021Q);
lan9303_tag[1] = lan9303_tx_use_arl(dp, skb_mac_header(skb)) ?
			LAN9303_TAG_TX_USE_ALR :
			dp->index | LAN9303_TAG_TX_STP_OVERRIDE;
lan9303_tag[1] = htons(lan9303_tag[1]);
---

But I will really like to hear the opinion from more people on this
before going down that road. Anyway, I think it would belong to a
separate patch.


> Thanks.
> Woojung
> 
> 

Regards
Egil
