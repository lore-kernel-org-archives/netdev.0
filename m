From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2] bridge: Fix crash with vlan filtering and tcpdump
Date: Thu, 23 Jan 2014 09:57:34 -0500
Message-ID: <52E12DDE.5090203@redhat.com>
References: <1390415070-1884-1-git-send-email-vyasevic@redhat.com> <1390480711.5347.8.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801AbaAWO5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 09:57:38 -0500
In-Reply-To: <1390480711.5347.8.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2014 07:38 AM, Toshiaki Makita wrote:
> On Wed, 2014-01-22 at 13:24 -0500, Vlad Yasevich wrote:
>> When the vlan filtering is enabled on the bridge, but
>> the filter is not configured on the bridge device itself,
>> running tcpdump on the bridge device will result in a
>> an Oops with NULL pointer dereference.  The reason
>> is that br_pass_frame_up() will bypass the vlan
>> check because promisc flag is set.  It will then try
>> to get the table pointer and process the packet based
>> on the table.  Since the table pointer is NULL, we oops.
>> Catch this special condition in br_handle_vlan().
>>
>> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>> Changes since v1:
>>   - Do not use a BUG or BUG_ON as it is possible to trigger the
>>     false BUG condition when thrashing the vlan_enable toggle.
>>     Instead just drop the skb.
> 
> Maybe that frame went through should_deliver() while vlan_filtering was
> disabled?

yes.  That's what happend.

> I hope it doesn't affect other codes in an adverse way...

I didn't see any adverse conditions while running the while(1) loop
changing vlan_flitering, but I didn't run it for all that long (about a
minute).

I am working on a series to reduce the possible races that involves
marking the skb (in the cb) and using that marking in later invocations.

> 
>>
>>  net/bridge/br_input.c | 11 ++++++-----
>>  net/bridge/br_vlan.c  | 14 ++++++++++++++
>>  2 files changed, 20 insertions(+), 5 deletions(-)
>>
> ...
>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>> index af5ebd1..abc841c 100644
>> --- a/net/bridge/br_vlan.c
>> +++ b/net/bridge/br_vlan.c
>> @@ -144,6 +144,20 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>>  	if (!br->vlan_enabled)
>>  		goto out;
>>  
>> +	/* Vlan filter table must be configured at this point.  The
>> +	 * only exception is the bridge is set in promisc mode and the
>> +	 * packet is destined for the bridge device.  In this case
>> +	 * pass the packet as is.
>> +	 */
>> +	if (!pv) {
>> +		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev)
>> +			goto out;
>> +		else {
>> +			kfree_skb_list(skb);
> 
> Why is this not kfree_skb() but kfree_skb_list()?
> I haven't seen kfree_skb_list() in the bridge code.

I thought it is possible to get a list here, but upon further inspection
I don't see that happening.   I'll change that to kfree_skb().

Thanks
-vlad

> 
> Thanks,
> Toshiaki Makita
> 
>> +			return NULL;
>> +		}
>> +	}
>> +
>>  	/* At this point, we know that the frame was filtered and contains
>>  	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
>>  	 * send untagged; otherwise, send taged.
> 
> 
