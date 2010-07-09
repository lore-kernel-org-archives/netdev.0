From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH v2 -net-2.6] ll_temac: fix DMA resources leak
Date: Sat, 10 Jul 2010 00:09:51 +0400
Message-ID: <4C37820F.80309@kernel.org>
References: <20100708202451.GA4062@hera.kernel.org> <20100709114347.GA3553@albatros> <20100709175952.GA5450@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <dkirjanov@hera.kernel.org>, davem@davemloft.net,
	john.linn@xilinx.com, brian.hill@xilinx.com,
	grant.likely@secretlab.ca, jpirko@redhat.com,
	netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:32904 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754119Ab0GIUKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jul 2010 16:10:10 -0400
In-Reply-To: <20100709175952.GA5450@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2010 09:59 PM, Kulikov Vasiliy wrote:
> On Fri, Jul 09, 2010 at 15:43 +0400, Kulikov Vasiliy wrote:
>> On Thu, Jul 08, 2010 at 20:24 +0000, Denis Kirjanov wrote:
>>> V2: Check pointers before releasing resources.
>>>
>>> Fix DMA resources leak.
>>> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
>>> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
>>> ---
>>>  1 files changed, 32 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
>>> index fa303c8..b57d0ff 100644
>>> --- a/drivers/net/ll_temac_main.c
>>> +++ b/drivers/net/ll_temac_main.c
>>> @@ -193,6 +193,35 @@ static int temac_dcr_setup(struct temac_local *lp, struct of_device *op,
>>>  #endif
>>>  
>>>  /**
>>> + *  * temac_dma_bd_release - Release buffer descriptor rings
>>> + */
>>> +static void temac_dma_bd_release(struct net_device *ndev)
>>> +{
>>> +	struct temac_local *lp = netdev_priv(ndev);
>>> +	int i;
>>> +
>>> +	for (i = 0; i < RX_BD_NUM; i++) {
>>> +		if (!lp->rx_skb[i])
>>> +			break;
>>> +		else {
>>> +			dma_unmap_single(ndev->dev.parent, lp->rx_bd_v[i].phys,
>>> +					XTE_MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
>>> +			dev_kfree_skb(lp->rx_skb[i]);
>>> +		}
>>> +	}
>> This cycle is needed only if (lp->rx_skb != NULL).
>>
>>> +	if (lp->rx_bd_v)
>>> +		dma_free_coherent(ndev->dev.parent,
>>> +				sizeof(*lp->rx_bd_v) * RX_BD_NUM,
>>> +				lp->rx_bd_v, lp->rx_bd_p);
>>> +	if (lp->tx_bd_v)
>>> +		dma_free_coherent(ndev->dev.parent,
>>> +				sizeof(*lp->tx_bd_v) * TX_BD_NUM,
>>> +				lp->tx_bd_v, lp->tx_bd_p);
>> After temac_dma_bd_release() lp->rx_bd_v and lp->rx_bd_p are freed but
>> are nonzero. If lp->rx_skb allocation fails second time then these DMA's
>> would be freed second time.
>> lp->tx_bd_v = lp->rx_bd_v = NULL here fixes this.
>>
>>> +	if (lp->rx_skb)
>>> +		kfree(lp->rx_skb);
>>> +}
>>> +
>>> +/**
>>>   * temac_dma_bd_init - Setup buffer descriptor rings
>>>   */
>>>  static int temac_dma_bd_init(struct net_device *ndev)
>>> @@ -275,6 +304,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
>>>  	return 0;
>>>  
>>>  out:
>>> +	temac_dma_bd_release(ndev);
>>>  	return -ENOMEM;
>>>  }
>>>  
>>> @@ -858,6 +888,8 @@ static int temac_stop(struct net_device *ndev)
>>>  		phy_disconnect(lp->phy_dev);
>>>  	lp->phy_dev = NULL;
>>>  
>>> +	temac_dma_bd_release(ndev);
>>> +
>>>  	return 0;
>>>  }
>>>  
> I've fixed it in PATCH v3.
Could you please fix this on the top on the previous one.
Thanks.
> 
> http://marc.info/?l=kernel-janitors&m=127869815002994&w=2
> 

