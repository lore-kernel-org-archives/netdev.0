From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 6/9] xen-netback: Handle guests with too many
 frags
Date: Tue, 7 Jan 2014 15:23:15 +0000
Message-ID: <52CC1BE3.8080502@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-7-git-send-email-zoltan.kiss@citrix.com> <20131213154307.GN21900@zion.uk.xensource.com> <52AF2602.2000409@citrix.com> <20131216180908.GC25969@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:11122 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaAGPXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:23:19 -0500
In-Reply-To: <20131216180908.GC25969@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/13 18:09, Wei Liu wrote:
>>>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>>>> index e26cdda..f6ed1c8 100644
>>>> --- a/drivers/net/xen-netback/netback.c
>>>> +++ b/drivers/net/xen-netback/netback.c
>>>> @@ -906,11 +906,15 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>>>>   	u16 pending_idx = *((u16 *)skb->data);
>>>>   	int start;
>>>>   	pending_ring_idx_t index;
>>>> -	unsigned int nr_slots;
>>>> +	unsigned int nr_slots, frag_overflow = 0;
>>>>
>>>>   	/* At this point shinfo->nr_frags is in fact the number of
>>>>   	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
>>>>   	 */
>>>> +	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
>>>> +		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
>>>> +		shinfo->nr_frags = MAX_SKB_FRAGS;
>>>> +	}
>>>>   	nr_slots = shinfo->nr_frags;
>>>>
>>>
>>> It is also probably better to check whether shinfo->nr_frags is too
>>> large which makes frag_overflow > MAX_SKB_FRAGS. I know skb should be
>>> already be valid at this point but it wouldn't hurt to be more careful.
>> Ok, I've added this:
>> 	/* At this point shinfo->nr_frags is in fact the number of
>> 	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
>> 	 */
>> +	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
>> +		if (shinfo->nr_frags > XEN_NETBK_LEGACY_SLOTS_MAX) return NULL;
>> +		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
>>
>
> What I suggested is
>
>     BUG_ON(frag_overflow > MAX_SKB_FRAGS)

Ok, I've changed it.

Zoli
