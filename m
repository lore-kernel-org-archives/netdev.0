From: =?UTF-8?Q?Markus_B=c3=b6hme?= <markus.boehme@mailbox.org>
Subject: Re: [PATCH v3 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Tue, 29 Nov 2016 13:15:55 +0100
Message-ID: <7da8cd2d-c570-d2c8-12b3-031d1226bf50@mailbox.org>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
 <910890ec-7acf-1ced-55c6-d854ee2cdccc@mailbox.org>
 <9a789bda-7d98-fa2c-8759-e046c6dd5145@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, davem@davemloft.net,
        charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:40445 "EHLO mx2.mailbox.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754216AbcK2MQX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 07:16:23 -0500
In-Reply-To: <9a789bda-7d98-fa2c-8759-e046c6dd5145@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 09:46 PM, Lino Sanfilippo wrote:
> Hi Markus,
> 
> On 27.11.2016 18:59, Markus Böhme wrote:
>> Hello Lino,
>>
>> just some things barely worth mentioning:
>>
> 
>>
>> I found a bunch of unused #defines in slic.h. I cannot judge if they are
>> worth keeping:
>>
>> 	SLIC_VRHSTATB_LONGE
>> 	SLIC_VRHSTATB_PREA
>> 	SLIC_ISR_IO
>> 	SLIC_ISR_PING_MASK
>> 	SLIC_GIG_SPEED_MASK
>> 	SLIC_GMCR_RESET
>> 	SLIC_XCR_RESET
>> 	SLIC_XCR_XMTEN
>> 	SLIC_XCR_PAUSEEN
>> 	SLIC_XCR_LOADRNG
>> 	SLIC_REG_DBAR
>> 	SLIC_REG_PING
>> 	SLIC_REG_DUMP_CMD
>> 	SLIC_REG_DUMP_DATA
>> 	SLIC_REG_WRHOSTID
>> 	SLIC_REG_LOW_POWER
>> 	SLIC_REG_RESET_IFACE
>> 	SLIC_REG_ADDR_UPPER
>> 	SLIC_REG_HBAR64
>> 	SLIC_REG_DBAR64
>> 	SLIC_REG_CBAR64
>> 	SLIC_REG_RBAR64
>> 	SLIC_REG_WRVLANID
>> 	SLIC_REG_READ_XF_INFO
>> 	SLIC_REG_WRITE_XF_INFO
>> 	SLIC_REG_TICKS_PER_SEC
>>
>> These device IDs are not used, either, but maybe it's good to keep them
>> for documentation purposes:
>>
>> 	PCI_SUBDEVICE_ID_ALACRITECH_1000X1_2
>> 	PCI_SUBDEVICE_ID_ALACRITECH_SES1001T
>> 	PCI_SUBDEVICE_ID_ALACRITECH_SEN2002XT
>> 	PCI_SUBDEVICE_ID_ALACRITECH_SEN2001XT
>> 	PCI_SUBDEVICE_ID_ALACRITECH_SEN2104ET
>> 	PCI_SUBDEVICE_ID_ALACRITECH_SEN2102ET
>>
> 
> I left these defines in for both documentation and to avoid gaps in
> register ranges. I would like to keep this as it is.

Seems reasonable.

[...]

>>> +static int slic_init_tx_queue(struct slic_device *sdev)
>>> +{
>>> +	struct slic_tx_queue *txq = &sdev->txq;
>>> +	struct slic_tx_buffer *buff;
>>> +	struct slic_tx_desc *desc;
>>> +	int err;
>>> +	int i;
>>
>> You could make i unsigned...
>>
> 
>>> +
>>> +	txq->len = SLIC_NUM_TX_DESCS;
>>> +	txq->put_idx = 0;
>>> +	txq->done_idx = 0;
>>> +
>>> +	txq->txbuffs = kcalloc(txq->len, sizeof(*buff), GFP_KERNEL);
>>> +	if (!txq->txbuffs)
>>> +		return -ENOMEM;
>>> +
>>> +	txq->dma_pool = dma_pool_create("slic_pool", &sdev->pdev->dev,
>>> +					sizeof(*desc), SLIC_TX_DESC_ALIGN,
>>> +					4096);
>>> +	if (!txq->dma_pool) {
>>> +		err = -ENOMEM;
>>> +		netdev_err(sdev->netdev, "failed to create dma pool\n");
>>> +		goto free_buffs;
>>> +	}
>>> +
>>> +	for (i = 0; i < txq->len; i++) {
>>
>> ...to fix a signed/unsigned comparison warning here, but...
>>
>>> +		buff = &txq->txbuffs[i];
>>> +		desc = dma_pool_zalloc(txq->dma_pool, GFP_KERNEL,
>>> +				       &buff->desc_paddr);
>>> +		if (!desc) {
>>> +			netdev_err(sdev->netdev,
>>> +				   "failed to alloc pool chunk (%i)\n", i);
>>> +			err = -ENOMEM;
>>> +			goto free_descs;
>>> +		}
>>> +
>>> +		desc->hnd = cpu_to_le32((u32)(i + 1));
>>> +		desc->cmd = SLIC_CMD_XMT_REQ;
>>> +		desc->flags = 0;
>>> +		desc->type = cpu_to_le32(SLIC_CMD_TYPE_DUMB);
>>> +		buff->desc = desc;
>>> +	}
>>> +
>>> +	return 0;
>>> +
>>> +free_descs:
>>> +	while (i--) {
>>
>> ...this would require reworking this logic to prevent an endless loop,
>> so probably not worth bothering, considering that txq->len is well
>> within the positive signed range.
> 
> AFAICS the logic does not have to be changed. The while loop will also work
> fine if "i" is unsigned.
> 

My bad! Of course you are right.


Regards,
Markus
