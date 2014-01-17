From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v4 8/9] xen-netback: Timeout packets in RX path
Date: Fri, 17 Jan 2014 19:27:35 +0000
Message-ID: <52D98427.1060103@citrix.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com> <1389731995-9887-9-git-send-email-zoltan.kiss@citrix.com> <20140116000334.GE5331@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23835 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbaAQT1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:27:38 -0500
In-Reply-To: <20140116000334.GE5331@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/01/14 00:03, Wei Liu wrote:
> On Tue, Jan 14, 2014 at 08:39:54PM +0000, Zoltan Kiss wrote:
> [...]
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 109c29f..d1cd8ce 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -129,6 +129,9 @@ struct xenvif {
>>   	struct xen_netif_rx_back_ring rx;
>>   	struct sk_buff_head rx_queue;
>>   	RING_IDX rx_last_skb_slots;
>
> Hmm... You seemed to mix your other patch with this series. :-)
Yep, this series doesn't work without that patch (actually that is a bug 
in netback even without my series), so at the moment it is based on it.

>
>> +	bool rx_queue_purge;
>> +
>> +	struct timer_list wake_queue;
>>
>>   	/* This array is allocated seperately as it is large */
>>   	struct gnttab_copy *grant_copy_op;
>> @@ -225,4 +228,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
>>
>>   extern bool separate_tx_rx_irq;
>>
> [...]
>> @@ -559,7 +579,7 @@ void xenvif_free(struct xenvif *vif)
>>   		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>>   			unmap_timeout++;
>>   			schedule_timeout(msecs_to_jiffies(1000));
>> -			if (unmap_timeout > 9 &&
>> +			if (unmap_timeout > ((rx_drain_timeout_msecs/1000) * DIV_ROUND_UP(XENVIF_QUEUE_LENGTH, (XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS))) &&
>
> This line is really too long. And what's the rationale behind this long
> expression?
It calculates how many times you should ditch the internal queue of an 
another (maybe stucked) vif before Qdisc empties it's actual content. 
After that there shouldn't be any mapped handle left, so we should start 
printing these messages. Actually it should use vif->dev->tx_queue_len, 
and yes, it is probably better to move it to the beginning of the 
function into a new variable, and use that here.

Zoli
