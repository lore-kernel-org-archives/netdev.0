From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net v2 9/9] net: ethernet: mediatek: fix error handling inside mtk_mdio_init
Date: Tue, 30 Aug 2016 00:10:03 +0800
Message-ID: <1472487003-21584-1-git-send-email-sean.wang@mediatek.com>
References: <20160829131558.GE12465@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
        <keyhaede@gmail.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:16975 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750786AbcH2QKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:10:09 -0400
In-Reply-To: <20160829131558.GE12465@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Mon, 29 Aug 2016 15:15:58 +0200,Andrew Lunn wrote:
>On Mon, Aug 29, 2016 at 01:03:23PM +0800, sean.wang@mediatek.com wrote:
>> From: Sean Wang <sean.wang@mediatek.com>
>> 
>> return -ENODEV if no child is found in MDIO bus.
>
>Hi Sean
>
>Why is it an error not to have any children on the bus?
>
>Say i have a fibre optical module connected to the MAC. It is unlikely
>to have an MII interface, so i would not list it on the bus. With this
>change, if i have the mdio-bus node in my device tree, i don't get a
>working system. Without this change, it simply does not instantiate
>the MDIO device, and returns without an error.
>
>I think this patch should be dropped, or maybe a comment adding, why
>the current code returns 0 at this point.
>
>    Andrew
>
Hi Andrew,

Sorry, i didn't add the comment enough and well on the patch for let you can't see 
what i am done

the patch I just want to let driver know if device tree is defined well at the earlier time

although original driver still works without this patch 

the original logic on the driver is 

1) returning -ENODEV if no mdio_bus defined in the device tree. 

2) returning -ENODEV inside ndo_init callback if no phy_dev detected on the bus

--
after with the patch, the logic becomes

1) returning -ENODEV if no mdio_bus defined in the device tree

2) returning -ENODEV if no phy_dev defined in the device tree 
a. that is used to check if the device tree about phy_dev is defined well
b. and it could be aligned with the above 1) is doing

3) returning -ENODEV inside ndo_init callback if no phy device detected on the bus 
(that is used to test if phy_device is workable or encounters real phy problems)

so add 2) help to make distinguish if it is a device tree definition 
problem or a real phy problem at the earlier time

this is my whole thought

thanks,
Sean

>> 
>> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
>> Acked-by: John Crispin <john@phrozen.org>
>> ---
>>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> index f741c6a..e48b2a4 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> @@ -304,7 +304,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
>>  	}
>>  
>>  	if (!of_device_is_available(mii_np)) {
>> -		ret = 0;
>> +		ret = -ENODEV;
>>  		goto err_put_node;
>>  	}
>>  
>> -- 
>> 1.9.1
>
