From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next 1/3] net: ethernet: mediatek: get the chip id by
 ETHDMASYS registers
Date: Tue, 4 Oct 2016 14:14:06 +0200
Message-ID: <61bff877-e45a-3db7-da3a-db819059ad9b@phrozen.org>
References: <1475583160.7983.4.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47216 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbcJDMOL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:14:11 -0400
In-Reply-To: <1475583160.7983.4.camel@mtksdaap41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/10/2016 14:12, Nelson Chang wrote:
> Hi John,
> 
> Thanks for your review!
> I will modify that as below. Would you think it is okay?
> 
> static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
> {
> 	u32 val[2], id[4];
> 
> 	regmap_read(eth->ethsys, ETHSYS_CHIPID0_3, &val[0]);
> 	regmap_read(eth->ethsys, ETHSYS_CHIPID4_7, &val[1]);
> 
> 	id[3] = ((val[0] >> 16) & 0xff) - '0';
> 	id[2] = ((val[0] >> 24) & 0xff) - '0';
> 	id[1] = (val[1] & 0xff) - '0';
> 	id[0] = ((val[1] >> 8) & 0xff) - '0';
> 
> 	*chip_id = (id[3] * 1000) + (id[2] * 100) +
> 		   (id[1] * 10) + id[0];
> 
> 	if (!(*chip_id)) {
> 		dev_err(eth->dev, "failed to get chip id\n");
> 		return -ENODEV;
> 	}
> 
> 	dev_info(eth->dev, "chip id = %d\n", *chip_id);
> 
> 	return 0;
> }
> ...
> static int mtk_probe(struct platform_device *pdev)
> {
> 	...
> 	err = mtk_get_chip_id(eth, &eth->chip_id);
> 	if (err)
> 		return err;
> 	...
> }
> 
> 
> Nelson


Hi Nelson,

I think that looks nicer, thanks !

	John

> 
> -----Original Message-----
> From: John Crispin [mailto:john@phrozen.org] 
> Sent: Tuesday, October 04, 2016 3:17 AM
> To: Nelson Chang (張家祥); davem@davemloft.net
> Cc: nbd@openwrt.org; netdev@vger.kernel.org;
> linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
> Subject: Re: [PATCH net-next 1/3] net: ethernet: mediatek: get the chip
> id by ETHDMASYS registers
> 
> Hi Nelson,
> 
> comments inline
> 
> On 03/10/2016 09:18, Nelson Chang wrote:
>> The driver gets the chip id by ETHSYS_CHIPID0_3/ETHSYS_CHIPID4_7 
>> registers in mtk_probe().
>>
>> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
>> ---
>>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 27 
>> +++++++++++++++++++++++++++  
>> drivers/net/ethernet/mediatek/mtk_eth_soc.h |  5 +++++
>>  2 files changed, 32 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c 
>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> index ad4ab97..a3e4ae6 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
>> @@ -2323,6 +2323,27 @@ free_netdev:
>>  	return err;
>>  }
>>  
>> +static u32 mtk_get_chip_id(struct mtk_eth *eth) {
>> +	u32 val[2], id[4];
>> +	u32 chip_id;
>> +
>> +	regmap_read(eth->ethsys, ETHSYS_CHIPID0_3, &val[0]);
>> +	regmap_read(eth->ethsys, ETHSYS_CHIPID4_7, &val[1]);
>> +
>> +	id[3] = ((val[0] >> 16) & 0xff) - '0';
>> +	id[2] = ((val[0] >> 24) & 0xff) - '0';
>> +	id[1] = (val[1] & 0xff) - '0';
>> +	id[0] = ((val[1] >> 8) & 0xff) - '0';
>> +
>> +	chip_id = (id[3] * 1000) + (id[2] * 100) +
>> +		  (id[1] * 10) + id[0];
>> +
>> +	dev_info(eth->dev, "chip id = %d\n", chip_id);
> 
> the chip id is printed here
> 
>> +	return chip_id;
>> +}
>> +
>>  static int mtk_probe(struct platform_device *pdev)  {
>>  	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 
>> 0); @@ -2388,6 +2409,12 @@ static int mtk_probe(struct platform_device
> *pdev)
>>  	if (err)
>>  		return err;
>>  
>> +	eth->chip_id = mtk_get_chip_id(eth);
>> +	if (!eth->chip_id) {
>> +		dev_err(&pdev->dev, "failed to get chip id\n");
>> +		return -ENODEV;
>> +	}
>> +
> 
> and the error check happens here. maybe you could move the dev_err to
> the above function.
> 
> 	John
> 
>>  	for_each_child_of_node(pdev->dev.of_node, mac_np) {
>>  		if (!of_device_is_compatible(mac_np,
>>  					     "mediatek,eth-mac"))
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h 
>> b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> index 3003195..a5b422b 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> @@ -342,6 +342,10 @@
>>  #define GPIO_BIAS_CTRL		0xed0
>>  #define GPIO_DRV_SEL10		0xf00
>>  
>> +/* ethernet subsystem chip id register */
>> +#define ETHSYS_CHIPID0_3	0x0
>> +#define ETHSYS_CHIPID4_7	0x4
>> +
>>  /* ethernet subsystem config register */
>>  #define ETHSYS_SYSCFG0		0x14
>>  #define SYSCFG0_GE_MASK		0x3
>> @@ -534,6 +538,7 @@ struct mtk_eth {
>>  	unsigned long			sysclk;
>>  	struct regmap			*ethsys;
>>  	struct regmap			*pctl;
>> +	u32				chip_id;
>>  	bool				hwlro;
>>  	atomic_t			dma_refcnt;
>>  	struct mtk_tx_ring		tx_ring;
>>
> 
> 
