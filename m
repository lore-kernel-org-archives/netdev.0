From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] be2net: add dma_mapping_error() check for dma_map_page()
Date: Wed, 15 Jan 2014 11:08:01 +0100
Message-ID: <52D65E01.5030306@redhat.com>
References: <1389724139-27111-1-git-send-email-ivecera@redhat.com> <89af1a0a-785c-4dfd-93c5-b1be112d5f60@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Subramanian Seetharaman <subbu.seetharaman@Emulex.Com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbaAOKIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 05:08:05 -0500
In-Reply-To: <89af1a0a-785c-4dfd-93c5-b1be112d5f60@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2014 08:36 AM, Sathya Perla wrote:
>> -----Original Message-----
>> From: Ivan Vecera [mailto:ivecera@redhat.com]
>>
>> The driver does not check value returned by dma_map_page. The patch
>> fixes this as well as one additional bug. The prev_page_info is
>> dereferenced after 'for' loop but if the 1st be_alloc_pages fails its
>> value is NULL.
>>
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>> ---
>>   drivers/net/ethernet/emulex/benet/be_main.c | 13 ++++++++++---
>>   1 file changed, 10 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
>> b/drivers/net/ethernet/emulex/benet/be_main.c
>> index bf40fda..f2811b5 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -1776,6 +1776,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>>   	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
>>   	struct be_queue_info *rxq = &rxo->q;
>>   	struct page *pagep = NULL;
>> +	struct device *dev = &adapter->pdev->dev;
>>   	struct be_eth_rx_d *rxd;
>>   	u64 page_dmaaddr = 0, frag_dmaaddr;
>>   	u32 posted, page_offset = 0;
>> @@ -1788,9 +1789,15 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>>   				rx_stats(rxo)->rx_post_fail++;
>>   				break;
>>   			}
>> -			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
>> -						    0, adapter->big_page_size,
>> +			page_dmaaddr = dma_map_page(dev, pagep, 0,
>> +						    adapter->big_page_size,
>>   						    DMA_FROM_DEVICE);
>> +			if (dma_mapping_error(dev, page_dmaaddr)) {
>> +				put_page(pagep);
>> +				pagep = NULL;
>> +				rx_stats(rxo)->rx_post_fail++;
>> +				break;
>> +			}
>>   			page_info->page_offset = 0;
>>   		} else {
>>   			get_page(pagep);
>> @@ -1816,7 +1823,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>>   		queue_head_inc(rxq);
>>   		page_info = &rxo->page_info_tbl[rxq->head];
>>   	}
>> -	if (pagep)
>> +	if (pagep && prev_page_info)
>>   		prev_page_info->last_page_user = true;
>
> Ivan, if the 1st be_alloc_pages() fails, won't "pagep" be NULL aswell.
> In that case, "prev_page_info" will not be dereferenced.
>
Sure Sathya, sorry... my bad eyes... Will post 2nd version.

Ivan
