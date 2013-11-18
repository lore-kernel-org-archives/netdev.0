From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: Re: [PATCH net-next 02/13] driver: net: remove unnecessary skb NULL
 check before calling dev_kfree_skb_irq
Date: Tue, 19 Nov 2013 00:56:48 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1311190055150.10646@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com> <1383400074-30555-3-git-send-email-govindarajulu90@gmail.com> <20131104.151230.1978898006990867916.davem@davemloft.net> <alpine.LNX.2.03.1311111537020.2363@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, IvDoorn@gmail.com, sbhatewara@vmware.com,
	samuel@sortiz.org, chas@cmf.nrl.navy.mil, roland@kernel.org,
	isdn@linux-pingi.de, jcliburn@gmail.com,
	"Christian Benvenuti (benve)" <benve@cisco.com>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:45235 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3KRT0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:26:24 -0500
In-Reply-To: <alpine.LNX.2.03.1311111537020.2363@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

Did you have a chance to look at this? Let me know how you want me to
fix this.

//govind

On Mon, 11 Nov 2013, Govindarajulu Varadarajan wrote:

>
>
> On Mon, 4 Nov 2013, David Miller wrote:
>
>> From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
>> Date: Sat,  2 Nov 2013 19:17:43 +0530
>> 
>>> @@ -1030,10 +1030,8 @@ static void ni65_xmit_intr(struct net_device 
>>> *dev,int csr0)
>>>  		}
>>>
>>>  #ifdef XMT_VIA_SKB
>>> -		if(p->tmd_skb[p->tmdlast]) {
>>> -			 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
>>> -			 p->tmd_skb[p->tmdlast] = NULL;
>>> -		}
>>> +		 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
>>> +		 p->tmd_skb[p->tmdlast] = NULL;
>>>  #endif
>> 
>> I absolutely disagree with this kind of change.
>> 
>> There is a non-trivial cost for NULL'ing out that array entry
>> unconditionally.  It's a dirtied cache line and this is in the
>> fast path of TX SKB reclaim of this driver.
>> 
>> You've made several changes of this kind.
>> 
>> And it sort-of shows that the places that do check for NULL,
>> are getting something in return for that test, namely avoidance
>> of an unnecessary cpu store in the fast path of the driver.
>> 
>
> True, in case of dev_kfree_skb_irq. If you look at patch 06-12, at many
> places we do
>
> if (s->skb) {
> 	dev_kfree_skb_any(s->skb);
> 	s->skb = NULL)
> }
>
> This is in fast path. If the code is not running in hardirq,
> dev_kfree_skb_any calls dev_kfree_skb. Which again check if skb is NULL.
> So we are checking if skb is null twice. That is what this patch is
> trying to fix. (sorry I should have mentioned this in cover letter).
>
> I am not sure if you have read my previous mail. I am pasting it below.
>
>>> On Sun, 3 Nov 2013, Brandeburg, Jesse wrote: Thanks for this work, I'm a 
>>> little concerned that there is a
>>> non-trivial overhead to this patch.
>>> 
>>> when doing (for example in the Intel drivers): if (s->skb) {
>>>      dev_kfree_skb(s->skb);
>>>      s->skb = NULL; }
>>> 
>> 
>> In current code, dev_kfree_skb is NULL safe. Which means skb is
>> checked for NULL inside dev_kfree_skb. dev_kfree_skb_any is also NULL safe
>> when the code is running in non-hardirq.
>> 
>> Lets consider two cases
>> 
>> 1. skb is not NULL:
>>      * Without my patch:
>>           In the code above, we check for skb!=NULL twice. (once
>>           before calling dev_kfree_skb, once by dev_kfree_skb). And
>>           then we do assignment.
>>       * With this patch:
>>           we check for skb!=NULL once, And then we do assignment.
>>
>>       To fix the twice NULL check, we either have to remove the check
>>       which is inside dev_kfree_skb (1). Or do whats done in this
>>       patch.
>>
>>       (1) is not an option because a lot of kernel code already
>>       assumes that dev_kfree_skb is NULL safe.
>> 
>> 2. skb is NULL:
>>       * Without this patch:
>>           One if statement is executed.
>>       * With this patch:
>>           One if statement and one assignment is executed.
>> 
>> From my observation most of the dev_kfree_skb calls are from
>> e1000_unmap_and_free_tx_resource, e1000_put_txbuf,
>> atl1_clean_tx_ring, alx_free_txbuf etc. in clean up functions.
>> 
>> Is is quite unlikely thats skb is NULL. So it comes down to one extra
>> if-branching statement or one extra assignment. I would prefer extra
>> assignment to branching statement. In my opinion extra assignment is
>> very little price we pay.
>> 
>> //govind
>
> Another way to solve the double NULL check is to define a new function
> something like this
>
> dev_kfree_skb_NULL(struct sk_buff **skb)
> {
> 	if(*skb) {
> 		free_skb(*skb);
> 		*skb=NULL;
> 	}
> }
>
> and use this if you want to free a skb and make it NULL.
> Is this approach better?
>
> //govind
>
>
