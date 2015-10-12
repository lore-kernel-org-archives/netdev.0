From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH] net: nhs: fix 32-bit build warning
Date: Mon, 12 Oct 2015 09:25:37 +0800
Message-ID: <561B0C11.9030800@hisilicon.com>
References: <8581924.9CPedieySC@wuerfel> <1444594420.8012.34.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Kenneth Lee <liguozhu@huawei.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:57790 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbbJLB0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 21:26:00 -0400
In-Reply-To: <1444594420.8012.34.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/10/12 4:13, Joe Perches wrote:
> On Tue, 2015-10-06 at 23:53 +0200, Arnd Bergmann wrote:
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
> []
>> @@ -448,12 +448,12 @@ static ssize_t handles_show(struct device *dev,
>>   		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
>>   			    i++, h->eport_id, h->dev->name);
>>   		for (j = 0; j < h->q_num; j++) {
>> -			s += sprintf(buf + s, "\tqueue[%d] on 0x%llx\n",
>> -				     j, (u64)h->qs[i]->io_base);
>> -#define HANDEL_TX_MSG "\t\ttx_ring on 0x%llx:%u,%u,%u,%u,%u,%llu,%llu\n"
>> +			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
>> +				     j, h->qs[i]->io_base);
>> +#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
>>   			s += sprintf(buf + s,
>>   				     HANDEL_TX_MSG,
> Maybe one day remove the misspelled and
> used once HANDEL_TX_MSG macro too.
>
> Another possibility is to use a generally
> smaller object code style like:
>
> 	char *s = buf;
> 	...
> 	s += sprintf(s, ...)
> 	...
> 	return s - buf;
>
> instead of
>
> 	ssize_t s = 0;
> 	...
> 	s += sprintf(buf + s, ...)
> 	...
> 	return s;
> ---
>   drivers/net/ethernet/hisilicon/hns/hnae.c | 35 +++++++++++++++----------------
>   1 file changed, 17 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
> index f52e99a..d2af46f 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hnae.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
> @@ -439,40 +439,39 @@ EXPORT_SYMBOL(hnae_ae_unregister);
>   static ssize_t handles_show(struct device *dev,
>   			    struct device_attribute *attr, char *buf)
>   {
> -	ssize_t s = 0;
> +	char *s = buf;
>   	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
>   	struct hnae_handle *h;
>   	int i = 0, j;
>   
>   	list_for_each_entry_rcu(h, &hdev->handle_list, node) {
> -		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
> -			    i++, h->eport_id, h->dev->name);
> +		s += sprintf(s, "handle %d (eport_id=%u from %s):\n",
> +			     i++, h->eport_id, h->dev->name);
>   		for (j = 0; j < h->q_num; j++) {
> -			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
> +			s += sprintf(s, "\tqueue[%d] on %p\n",
>   				     j, h->qs[i]->io_base);
> -#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
> -			s += sprintf(buf + s,
> -				     HANDEL_TX_MSG,
> +			s += sprintf(s,
> +				     "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
>   				     h->qs[i]->tx_ring.io_base,
>   				     h->qs[i]->tx_ring.buf_size,
>   				     h->qs[i]->tx_ring.desc_num,
>   				     h->qs[i]->tx_ring.max_desc_num_per_pkt,
>   				     h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
>   				     h->qs[i]->tx_ring.max_pkt_size,
> -				 h->qs[i]->tx_ring.stats.sw_err_cnt,
> -				 h->qs[i]->tx_ring.stats.io_err_cnt);
> -			s += sprintf(buf + s,
> -				"\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
> -				h->qs[i]->rx_ring.io_base,
> -				h->qs[i]->rx_ring.buf_size,
> -				h->qs[i]->rx_ring.desc_num,
> -				h->qs[i]->rx_ring.stats.sw_err_cnt,
> -				h->qs[i]->rx_ring.stats.io_err_cnt,
> -				h->qs[i]->rx_ring.stats.seg_pkt_cnt);
> +				     h->qs[i]->tx_ring.stats.sw_err_cnt,
> +				     h->qs[i]->tx_ring.stats.io_err_cnt);
> +			s += sprintf(s,
> +				     "\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
> +				     h->qs[i]->rx_ring.io_base,
> +				     h->qs[i]->rx_ring.buf_size,
> +				     h->qs[i]->rx_ring.desc_num,
> +				     h->qs[i]->rx_ring.stats.sw_err_cnt,
> +				     h->qs[i]->rx_ring.stats.io_err_cnt,
> +				     h->qs[i]->rx_ring.stats.seg_pkt_cnt);
>   		}
>   	}
>   
> -	return s;
> +	return s - buf;
>   }
>   
>   static DEVICE_ATTR_RO(handles);
>
>
>
> .
>
thanks Joe
your suggestion is good, will send out a patch to fix it.


-- 
Best Regards
Daode Huang
