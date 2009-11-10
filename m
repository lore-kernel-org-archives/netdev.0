From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: net: allow to propagate errors through ->ndo_hard_start_xmit()
Date: Tue, 10 Nov 2009 19:20:00 +0100
Message-ID: <4AF9AED0.90107@trash.net>
References: <4AF87070.6020007@trash.net> <20091110170838.GA4195@ami.dom.local> <4AF9A36F.7070807@trash.net> <20091110175736.GB4195@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42166 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433AbZKJSUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:20:00 -0500
In-Reply-To: <20091110175736.GB4195@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Nov 10, 2009 at 06:31:27PM +0100, Patrick McHardy wrote:
>>
>>>> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
>>>>   skbs is optimal. When the driver returns an error, it is assumed
>>>>   the current segment has been freed. The patch then frees the
>>>>   entire GSO skb, including all remaining segments. Alternatively
>>>>   it could try to transmit the remaining segments later.
>>> Anyway, it seems this freeing should be described in the changelog,
>>> if not moved to a separate patch, since it fixes another problem,
>>> unless I forgot something.
>> What other problem are you refering to? I'm not aware of any
>> problems in the existing function.
> 
> This patch is about propagating errors, so it's not clear why there
> are some additional kfrees mixed with this. (But I see it's explained
> below.)

Well, to handle now propagated errors :) But sure, I'll fix up
the changelog when I return from dinner.

>>>>  	if (likely(!skb->next)) {
>>>>  		if (!list_empty(&ptype_all))
>>>> @@ -1804,6 +1804,8 @@ gso:
>>>>  		nskb->next = NULL;
>>>>  		rc = ops->ndo_start_xmit(nskb, dev);
>>>>  		if (unlikely(rc != NETDEV_TX_OK)) {
>>>> +			if (rc & ~NETDEV_TX_MASK)
>>>> +				goto out_kfree_gso_skb;
>>> If e.g. (rc == NETDEV_TX_OK | NET_XMIT_CN), why exactly is this freeing
>>> necessary now?
>>>
>>> Is e.g. (rc == NETDEV_TX_BUSY | NET_XMIT_CN) legal? If so, there would
>>> be use after kfree, I guess. Otherwise, it should be documented above
>>> (and maybe checked somewhere as well).
>> NET_XMIT_CN is a valid return value, yes. But its not freeing the
>> transmitted segment but the remaining ones. Its not strictly
>> necessary, but its the easiest way to treat all errors similar.
>> Otherwise you get complicated cases, f.i. when the driver returns
>> NET_XMIT_CN for the first segment and NETDEV_TX_OK for the
>> remaining ones.
> 
> It should be in the changelog and maybe a comment too. Even if it's
> right it's a change of functionality/behavior here.
> 
> I still don't know if/why (rc == NETDEV_TX_BUSY | NET_XMIT_CN) is
> OK. IMHO skb will be requeued after kfree here.

Ah I misread. NETDEV_TX_BUSY | NET_XMIT_CN is not valid. The
return value can be either a NETDEV_TX code, a NET_XMIT code
or an errno code. NETDEV_TX_OK, NET_XMIT_SUCCESS and no error
(errno) all have the value zero.

>>>>  			nskb->next = skb->next;
>>>>  			skb->next = nskb;
>>>>  			return rc;
>>>> @@ -1813,11 +1815,14 @@ gso:
>>>>  			return NETDEV_TX_BUSY;
>>>>  	} while (skb->next);
>>>>  
>>>> -	skb->destructor = DEV_GSO_CB(skb)->destructor;
>>>> +	rc = NETDEV_TX_OK;
>>> When is (rc != NETDEV_TX_OK) possible in this place?
>> Its gone in the current version.
> 
> Why don't you send the current version?

I did 2 hours ago :)
