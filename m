From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] xen: netfront: Drop GSO SKBs which do not have csum_blank.
Date: Mon, 24 Jan 2011 09:55:40 -0800
Message-ID: <4D3DBD1C.6020503@goop.org>
References: <1294233811-28123-1-git-send-email-ian.campbell@citrix.com>	 <4D3A2BD2.5030802@goop.org> <1295689392.3693.153.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:44610 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846Ab1AXRzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 12:55:43 -0500
In-Reply-To: <1295689392.3693.153.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2011 01:43 AM, Ian Campbell wrote:
> On Sat, 2011-01-22 at 00:58 +0000, Jeremy Fitzhardinge wrote: 
>> On 01/05/2011 05:23 AM, Ian Campbell wrote:
>>> The Linux network stack expects all GSO SKBs to have ip_summed ==
>>> CHECKSUM_PARTIAL (which implies that the frame contains a partial
>>> checksum) and the Xen network ring protocol similarly expects an SKB
>>> which has GSO set to also have NETRX_csum_blank (which also implies a
>>> partial checksum). Therefore drop such frames on receive otherwise
>>> they will trigger the warning in skb_gso_segment.
>>>
>>> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>>> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
>>> Cc: xen-devel@lists.xensource.com
>>> Cc: netdev@vger.kernel.org
>>> ---
>>>  drivers/net/xen-netfront.c |    5 +++++
>>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>> index cdbeec9..8b8c480 100644
>>> --- a/drivers/net/xen-netfront.c
>>> +++ b/drivers/net/xen-netfront.c
>>> @@ -836,6 +836,11 @@ static int handle_incoming_queue(struct net_device *dev,
>>>  				dev->stats.rx_errors++;
>>>  				continue;
>>>  			}
>>> +		} else if (skb_is_gso(skb)) {
>>> +			kfree_skb(skb);
>>> +			packets_dropped++;
>>> +			dev->stats.rx_errors++;
>>> +			continue;
>> This looks redundant; why not something like:
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 47e6a71..c1b8f64 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -852,13 +852,12 @@ static int handle_incoming_queue(struct net_device *dev,
>>  		/* Ethernet work: Delayed to here as it peeks the header. */
>>  		skb->protocol = eth_type_trans(skb, dev);
>>  
>> -		if (skb->ip_summed == CHECKSUM_PARTIAL) {
>> -			if (skb_checksum_setup(skb)) {
>> -				kfree_skb(skb);
>> -				packets_dropped++;
>> -				dev->stats.rx_errors++;
>> -				continue;
>> -			}
>> +		if (skb->ip_summed != CHECKSUM_PARTIAL ||
>> +		    skb_checksum_setup(skb)) {
> That drops non-partial skbs. However they are fine unless they also
> claim to be gso.
>
> Perhaps you meant "skb->ip_summed == CHECKSUM_PARTIAL && !
> skb_checksum_setup(skb)" which I think works but doesn't allow us to
> correctly chain the gso check onto the else.

No, I didn't mean to drop the skb_is_gso() test.  But still, the if()s
can be folded to share the same body.

    J
