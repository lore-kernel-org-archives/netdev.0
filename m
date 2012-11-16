From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [PATCH 2/4] xen/netback: Split one page pool into two(tx/rx)
 page pool.
Date: Fri, 16 Nov 2012 11:10:01 +0800
Message-ID: <50A5AE89.3090500@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>  <1352963089-599-1-git-send-email-annie.li@oracle.com> <1352970913.3499.47.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24149 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab2KPDKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 22:10:13 -0500
In-Reply-To: <1352970913.3499.47.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 17:15, Ian Campbell wrote:
> On Thu, 2012-11-15 at 07:04 +0000, Annie Li wrote:
>> For tx path, this implementation simplifies the work of searching out
>> grant page from page pool based on grant reference.
> It's still a linear search though, and it doesn't look much simpler to
> me:
>    	for (i = 0; i<  count; i++) {
> 		if (tx_pool)
> 			vif = netbk->gnttab_tx_vif[i];
> 		else
> 			vif = netbk->gnttab_rx_vif[i];
>
> 		pers_entry = vif->persistent_gnt;
> 		gnt_count =&vif->persistent_gntcnt;
> 		gnt_total = MAXIMUM_OUTSTANDING_BLOCK_REQS;
> becomes:
> 	for (i = 0; i<  count; i++) {
> 		if (tx_pool) {
> 			vif = netbk->gnttab_tx_vif[i];
> 			gnt_count =&vif->persistent_tx_gntcnt;
> 			gnt_total = XEN_NETIF_TX_RING_SIZE;
> 			pers_entry = vif->persistent_tx_gnt;
> 		} else {
> 			vif = netbk->gnttab_rx_vif[i];
> 			gnt_count =&vif->persistent_rx_gntcnt;
> 			gnt_total = 2*XEN_NETIF_RX_RING_SIZE;
> 			pers_entry = vif->persistent_rx_gnt;
> 		}

Yes, the code is not simpler. If we make netback per-VIF based, then 
these code will disappear.
The simplifying here means for tx path, the max search index is 
XEN_NETIF_TX_RING_SIZE(256 here), and this change can save some time 
when searching out grant page for specific grant reference.

>
>> @@ -111,8 +109,16 @@ struct xenvif {
>>
>>   	wait_queue_head_t waiting_to_free;
>>
>> -	struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];
>> -	unsigned int persistent_gntcnt;
>> +	struct persistent_entry *persistent_tx_gnt[XEN_NETIF_TX_RING_SIZE];
>> +
>> +	/*
>> +	 * 2*XEN_NETIF_RX_RING_SIZE is for the case of each head/fragment page
> Shouldn't that been incorporated into MAXIMUM_OUTSTANDING_BLOCK_REQS
> (sic) too?

Yes, the total value is same as MAXIMUM_OUTSTANDING_BLOCK_REQS. But here

2*XEN_NETIF_RX_RING_SIZE means it is only used by rx path, and it is used just like other elements in netback structure, such as grant_copy_op, meta, etc.


>> +	 * using 2 copy operations.
>> +	 */
>> +	struct persistent_entry *persistent_rx_gnt[2*XEN_NETIF_RX_RING_SIZE];
> What is the per-vif memory overhead after this change?

Per-vif memory overhead is following,
for tx path, it is about XEN_NETIF_RX_RING_SIZE*PAGE_SIZE  (256 
PAGE_SIZE here)
for rx path, it is about 2*XEN_NETIF_RX_RING_SIZE*PAGE_SIZE  (512 
PAGE_SIZE here)

I can add some comment here.

Thanks
Annie
>
> Ian.
>
