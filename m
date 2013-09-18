From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH -net] netpoll: fix NULL pointer dereference in netpoll_cleanup
Date: Wed, 18 Sep 2013 23:09:11 +0200
Message-ID: <523A1677.2090602@redhat.com>
References: <1379427155-8561-1-git-send-email-nikolay@redhat.com>  <20130918.121539.1213515779326200577.davem@davemloft.net> <1379521524.1787.44.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab3IRVJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 17:09:16 -0400
In-Reply-To: <1379521524.1787.44.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2013 06:25 PM, Joe Perches wrote:
> On Wed, 2013-09-18 at 12:15 -0400, David Miller wrote:
>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>> Date: Tue, 17 Sep 2013 16:12:35 +0200
>>
>>> @@ -1284,15 +1284,15 @@ EXPORT_SYMBOL_GPL(__netpoll_free_async);
>>>  
>>>  void netpoll_cleanup(struct netpoll *np)
>>>  {
>>> -     if (!np->dev)
>>> -             return;
>>> -
>>>       rtnl_lock();
>>> +     if (!np->dev) {
>>> +             rtnl_unlock();
>>> +             return;
>>> +     }
>>>       __netpoll_cleanup(np);
>>> -     rtnl_unlock();
>>> -
>>>       dev_put(np->dev);
>>>       np->dev = NULL;
>>> +     rtnl_unlock();
>>>  }
>>>  EXPORT_SYMBOL(netpoll_cleanup);
>>
>> I know it seems arbitrary, but please do this like:
>>
>>         lock();
>>         if (condition) {
>>                 ...
>>         }
>>         unlock();
>>
>> rather than having multiple return/unlock code paths.
>>
>> This style I am suggesting is easier to audit for locking problems.
> 
> Another alternative is:
> 
> 	lock();
> 
> 	if (!condition)
> 		goto out;
> 
> 	...
> 
> out:
> 	unlock();
> 	return ...;
> }
> 
Yup, this is the alternative I plan to use :-)

Thanks Joe
