From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Fri, 10 Jan 2014 11:35:08 +0000
Message-ID: <52CFDAEC.5080708@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com> <1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com> <20140109153015.GF12164@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2673 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbaAJLfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 06:35:11 -0500
In-Reply-To: <20140109153015.GF12164@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 15:30, Wei Liu wrote:
> On Wed, Jan 08, 2014 at 12:10:11AM +0000, Zoltan Kiss wrote:
>> v3:
>> - delete a surplus checking from tx_action
>> - remove stray line
>> - squash xenvif_idx_unmap changes into the first patch
>> - init spinlocks
>> - call map hypercall directly instead of gnttab_map_refs()
>
> I suppose this is to avoid touching m2p override as well, just as
> previous patch uses unmap hypercall directly.

Yes.

>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -122,7 +122,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	BUG_ON(skb->dev != dev);
>>
>>   	/* Drop the packet if vif is not ready */
>> -	if (vif->task == NULL || !xenvif_schedulable(vif))
>> +	if (vif->task == NULL ||
>> +		vif->dealloc_task == NULL ||
>> +		!xenvif_schedulable(vif))
>
> Indentation.
Fixed, and the later ones as well

>> @@ -920,6 +852,18 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>>   	err = gop->status;
>>   	if (unlikely(err))
>>   		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
>> +	else {
>> +		if (vif->grant_tx_handle[pending_idx] !=
>> +			NETBACK_INVALID_HANDLE) {
>> +			netdev_err(vif->dev,
>> +				"Stale mapped handle! pending_idx %x handle %x\n",
>> +				pending_idx, vif->grant_tx_handle[pending_idx]);
>> +			BUG();
>> +		}
>> +		set_phys_to_machine(idx_to_pfn(vif, pending_idx),
>> +			FOREIGN_FRAME(gop->dev_bus_addr >> PAGE_SHIFT));
>
> What happens when you don't have this?
Your frags will be filled with garbage. I don't understand exactly what 
this function does, someone might want to enlighten us? I've took it's 
usage from classic kernel.
Also, it might be worthwhile to check the return value and BUG if it's 
false, but I don't know what exactly that return value means.

>
>>   		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
>>   			int target = min_t(int, skb->len, PKT_PROT_LEN);
>> @@ -1581,6 +1541,8 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   		if (checksum_setup(vif, skb)) {
>>   			netdev_dbg(vif->dev,
>>   				   "Can't setup checksum in net_tx_action\n");
>> +			if (skb_shinfo(skb)->destructor_arg)
>> +				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>
> Do you still care setting the flag even if this skb is not going to be
> delivered? If so can you state clearly the reason just like the
> following hunk?
Of course, otherwise the pages wouldn't be sent back to the guest. I've 
added a comment.

>> @@ -1715,7 +1685,7 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>>   int xenvif_tx_action(struct xenvif *vif, int budget)
>>   {
>>   	unsigned nr_gops;
>> -	int work_done;
>> +	int work_done, ret;
>>
>>   	if (unlikely(!tx_work_todo(vif)))
>>   		return 0;
>> @@ -1725,7 +1695,10 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>>   	if (nr_gops == 0)
>>   		return 0;
>>
>> -	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
>> +	ret = HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref,
>> +			vif->tx_map_ops,
>> +			nr_gops);
>
> Why do you need to replace gnttab_batch_copy with hypercall? In the
> ideal situation gnttab_batch_copy should behave the same as directly
> hypercall but it also handles GNTST_eagain for you.

I don't need gnttab_batch_copy at all, I'm using the grant mapping 
hypercall here.

Regards,

Zoli
