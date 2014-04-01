From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 2/2] xen-netback: Grant copy the header instead
 of map and memcpy
Date: Tue, 1 Apr 2014 19:55:35 +0100
Message-ID: <533B0BA7.6040607@citrix.com>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com> <1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com> <9AAE0902D5BC7E449B7C8E4E778ABCD02B75F1@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jonathan Davies <Jonathan.Davies@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8058 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbaDASzj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 14:55:39 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD02B75F1@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/14 10:40, Paul Durrant wrote:
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
>> netback/netback.c
>> index e781366..ba11ff5 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -915,35 +915,30 @@ static inline void xenvif_grant_handle_reset(struct
>> xenvif *vif,
>>
>>   static int xenvif_tx_check_gop(struct xenvif *vif,
>>   			       struct sk_buff *skb,
>> -			       struct gnttab_map_grant_ref **gopp_map)
>> +			       struct gnttab_map_grant_ref **gopp_map,
>> +			       struct gnttab_copy **gopp_copy)
>>   {
>>   	struct gnttab_map_grant_ref *gop_map = *gopp_map;
>>   	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
>>   	struct skb_shared_info *shinfo = skb_shinfo(skb);
>> -	struct pending_tx_info *tx_info;
>>   	int nr_frags = shinfo->nr_frags;
>> -	int i, err, start;
>> +	int i, err;
>>   	struct sk_buff *first_skb = NULL;
>>
>>   	/* Check status of header. */
>> -	err = gop_map->status;
>> +	err = (*gopp_copy)->status;
>> +	(*gopp_copy)++;
>
> I guess there's no undo work in the case of a copy op so you can bump the copy count here, but it might have been nicer to pair it with the update to the map count.
I rather prefer to group related operations on the same variable to stay 
close to each other.


>> @@ -1067,9 +1051,9 @@ static int xenvif_get_extras(struct xenvif *vif,
>>
>>   		memcpy(&extra, RING_GET_REQUEST(&vif->tx, cons),
>>   		       sizeof(extra));
>> +		vif->tx.req_cons = ++cons;
>>   		if (unlikely(!extra.type ||
>>   			     extra.type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
>> -			vif->tx.req_cons = ++cons;
>>   			netdev_err(vif->dev,
>>   				   "Invalid extra type: %d\n", extra.type);
>>   			xenvif_fatal_tx_err(vif);
>> @@ -1077,7 +1061,6 @@ static int xenvif_get_extras(struct xenvif *vif,
>>   		}
>>
>>   		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
>> -		vif->tx.req_cons = ++cons;
>
> I know you called this out as unrelated, but I still think it would be better in a separate patch.
Ok


>> @@ -1269,24 +1255,39 @@ static unsigned xenvif_tx_build_gops(struct
>> xenvif *vif, int budget)
>>   			}
>>   		}
>>
>> -		xenvif_tx_create_gop(vif, pending_idx, &txreq, gop);
>> -
>> -		gop++;
>> -
>>   		XENVIF_TX_CB(skb)->pending_idx = pending_idx;
>>
>>   		__skb_put(skb, data_len);
>> +		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
>> +		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
>> +		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
>> +
>> +		vif->tx_copy_ops[*copy_ops].dest.u.gmfn =
>> +			virt_to_mfn(skb->data);
>> +		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>> +		vif->tx_copy_ops[*copy_ops].dest.offset =
>> +			offset_in_page(skb->data);
>> +
>> +		vif->tx_copy_ops[*copy_ops].len = data_len;
>> +		vif->tx_copy_ops[*copy_ops].flags =
>> GNTCOPY_source_gref;
>> +
>> +		(*copy_ops)++;
>>
>>   		skb_shinfo(skb)->nr_frags = ret;
>>   		if (data_len < txreq.size) {
>>   			skb_shinfo(skb)->nr_frags++;
>>   			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
>>   					     pending_idx);
>> +			xenvif_tx_create_gop(vif, pending_idx, &txreq,
>> gop);
>> +			gop++;
>>   		} else {
>>   			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
>>   					     INVALID_PENDING_IDX);
>> +			memcpy(&vif->pending_tx_info[pending_idx].req,
>> &txreq,
>> +			       sizeof(txreq));
>>   		}
>>
>> +
>
> Unnecessary whitespace change.
Ok

>
>>   		vif->pending_cons++;
>>
>>   		request_gop = xenvif_get_requests(vif, skb, txfrags, gop);
>> @@ -1301,11 +1302,13 @@ static unsigned xenvif_tx_build_gops(struct
>> xenvif *vif, int budget)
>>
>>   		vif->tx.req_cons = idx;
>>
>> -		if ((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif-
>>> tx_map_ops))
>> +		if (((gop-vif->tx_map_ops) >= ARRAY_SIZE(vif-
>>> tx_map_ops)) ||
>> +		    (*copy_ops >= ARRAY_SIZE(vif->tx_map_ops)))
>
> Do you mean ARRAY_SIZE(vif->tx_copy_ops) here?
Yes, I'll correct it.

>
>>   			break;
>>   	}
>>
>> -	return gop - vif->tx_map_ops;
>> +	(*map_ops) = gop - vif->tx_map_ops;
>> +	return;
>>   }
>>
>>   /* Consolidate skb with a frag_list into a brand new one with local pages on
>> @@ -1377,6 +1380,7 @@ static int xenvif_handle_frag_list(struct xenvif *vif,
>> struct sk_buff *skb)
>>   static int xenvif_tx_submit(struct xenvif *vif)
>>   {
>>   	struct gnttab_map_grant_ref *gop_map = vif->tx_map_ops;
>> +	struct gnttab_copy *gop_copy = vif->tx_copy_ops;
>>   	struct sk_buff *skb;
>>   	int work_done = 0;
>>
>> @@ -1389,7 +1393,7 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>   		txp = &vif->pending_tx_info[pending_idx].req;
>>
>>   		/* Check the remap error code. */
>> -		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map))) {
>> +		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map,
>> &gop_copy))) {
>>   			netdev_dbg(vif->dev, "netback grant failed.\n");
>
> It could have been the copy that failed. You should probably change the error message.
I've changed it to "netback grant op failed.\n"

>> @@ -1588,22 +1588,26 @@ static inline void xenvif_tx_dealloc_action(struct
>> xenvif *vif)
>>   /* Called after netfront has transmitted */
>>   int xenvif_tx_action(struct xenvif *vif, int budget)
>>   {
>> -	unsigned nr_mops;
>> +	unsigned nr_mops, nr_cops = 0;
>>   	int work_done, ret;
>>
>>   	if (unlikely(!tx_work_todo(vif)))
>>   		return 0;
>>
>> -	nr_mops = xenvif_tx_build_gops(vif, budget);
>> +	xenvif_tx_build_gops(vif, budget, &nr_cops, &nr_mops);
>>
>> -	if (nr_mops == 0)
>> +	if (nr_cops == 0)
>>   		return 0;
>> -
>> -	ret = gnttab_map_refs(vif->tx_map_ops,
>> -			      NULL,
>> -			      vif->pages_to_map,
>> -			      nr_mops);
>> -	BUG_ON(ret);
>> +	else {
>
> Do you need an 'else' here? Unless I'm misreading the diff your previous clause returns.
Indeed, it's not necessary there
