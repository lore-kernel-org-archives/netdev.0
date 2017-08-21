From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Mon, 21 Aug 2017 15:24:55 -0700
Message-ID: <52a0e01e-8a55-2360-ca11-b65c613a812c@gmail.com>
References: <20170821194143.27885-1-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B048CD@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:38738 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754015AbdHUWY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:24:58 -0400
Received: by mail-qk0-f194.google.com with SMTP id 130so7777053qkg.5
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 15:24:58 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B048CD@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2017 03:15 PM, Woojung.Huh@microchip.com wrote:
> Florian,
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Monday, August 21, 2017 3:42 PM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; andrew@lunn.ch;
>> vivien.didelot@savoirfairelinux.com; Woojung Huh - C21699; Florian Fainelli
>> Subject: [PATCH net] net: dsa: skb_put_padto() already frees nskb
>>
>> skb_put_padto() already frees the passed sk_buff reference upon error,
>> so calling kfree_skb() on it again is not necessary.
>>
>> Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")
>>
>> Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  net/dsa/tag_ksz.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
>> index de66ca8e6201..107172c82107 100644
>> --- a/net/dsa/tag_ksz.c
>> +++ b/net/dsa/tag_ksz.c
>> @@ -60,10 +60,8 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb,
>> struct net_device *dev)
>>  					 skb_transport_header(skb) - skb-
>>> head);
>>  		skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
>>
>> -		if (skb_put_padto(nskb, nskb->len + padlen)) {
>> -			kfree_skb(nskb);
>> +		if (skb_put_padto(nskb, nskb->len + padlen))
>>  			return NULL;
>> -		}
>>
>>  		kfree_skb(skb);
>>  	}
>> --
> 
> Because skb_put_padto() frees skb when it fails,  below lines in e71cb9e00922
> ("net: dsa: ksz: fix skb freeing") will be an issue to.
> 
> 	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
> +		if (skb_put_padto(skb, skb->len + padlen))
> +			return NULL;
> +
> 
> When it fails skb will be freed twice in skb_put_padto() and
> caller of dsa_slave_xmit().

You are right, I am not sure what is the best way to fix tag_ksz.c other
than somehow open coding skb_put_padto() minus the freeing on error part?
-- 
Florian
