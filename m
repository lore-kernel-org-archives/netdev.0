From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 15:22:51 +0200
Message-ID: <47FF662B.2040302@trash.net>
References: <20080411124519.GA2701@ff.dom.local> <47FF5FBF.6030802@trash.net> <20080411132304.GB2701@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54403 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYDKNWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:22:54 -0400
In-Reply-To: <20080411132304.GB2701@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Fri, Apr 11, 2008 at 02:55:27PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> [NET_SCHED] cls_u32: refcounting fix for u32_delete()
>>>
>>> @@ -441,8 +443,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
>>>  	if (tp->root == ht)
>>>  		return -EINVAL;
>>>  -	if (--ht->refcnt == 0)
>>> +	if (ht->refcnt == 1) {
>>> +		ht->refcnt--;
>>>  		u32_destroy_hnode(tp, ht);
>>> +	}
>>>  
>> Shouldn't the refcount be decremented unconditionally?
>> Otherwise I'd suggest to reject the removal if refcnt > 1,
>> but silently doing nothing doesn't seem right.
> 
> If someone tries deleting and the refcnt is e.g. 3 (2 links)
> unconditional deleting could decrease refcnt without deleting
> and then unlinking would make it below 0. I think it's OK now:
> we can't delete hnode until it's referenced, but I could add
> a warning if you like?


I'd suggest to behave similar to qdiscs when trying to
removing classes that are still referenced, return -EBUSY.
