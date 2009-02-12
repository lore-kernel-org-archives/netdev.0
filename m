From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Thu, 12 Feb 2009 16:11:19 +0100
Message-ID: <49943C17.5080509@free.fr>
References: <498ABDA2.5040603@dev.6wind.com> <20090205.234520.149982266.davem@davemloft.net> <498C403D.9040500@dev.6wind.com> <20090206.141026.85510254.davem@davemloft.net> <49919FD4.3000008@dev.6wind.com> <4991AE04.7020307@free.fr> <4991AFDA.8020704@dev.6wind.com> <4991B5C9.9040005@free.fr> <m1zlgtjtrf.fsf@fess.ebiederm.org> <4992F372.4020206@free.fr> <m1iqngh8yo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, nicolas.dichtel@dev.6wind.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:41850 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643AbZBLPMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 10:12:50 -0500
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id n1CFBOeV499322
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2009 15:11:24 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1CFBOXg1466470
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2009 15:11:24 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CFBNrO015280
	for <netdev@vger.kernel.org>; Thu, 12 Feb 2009 15:11:24 GMT
In-Reply-To: <m1iqngh8yo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>
>   
>> Eric W. Biederman wrote:
>>     
>>> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>>>   
>>>       
>>>> Hmm, at the first glance I would say it is useless but perhaps there is a
>>>>         
>> trick
>>     
>>>> here I do not understand.
>>>> Eric, is there any particular reason to call synchronize_net before exiting
>>>>         
>> the
>>     
>>>> dev_change_net_namespace function ?
>>>>     
>>>>         
>>> I haven't thought about that part of the code path in detail in a long
>>> time.  dev_change_net_namespace() is a condensed version of
>>> register_netdevice() unregister_netdevice().  With the calls down into
>>> the driver removed.
>>>
>>> On a side note.  It looks like we now cope with:
>>> call_netdevice_notifiers(NETDEV_REGISTER, dev); failing in
>>> register_netdev, but no one updated dev_change_net_namespace to handle
>>> the change, looks like a real pain to cope with.
>>>
>>> As for the synchronize_net, and in response to the original
>>> comment as best as I can tell we do have things being being
>>> deleted that are at least candidates for synchronize_net.
>>>
>>> dev_addr_discard(dev);
>>> dev_net_set(dev, net);
>>> netdev_unregister_kobject(dev);
>>>
>>> We very much do access dev->net with only rcu protection.
>>>
>>> Hmm.
>>>
>>> It looks like I originally took the second synchronize_net from what
>>> became rollback_registered, which happens just before we start freeing
>>> the netdevice.
>>>
>>> The nastiest case that I can envision is if we happen to receive a
>>> packet (on another cpu) for the network device that we are moving,
>>> just after it has registered in the new network namespace.  If we read
>>> the old network namespace and forward it up the network stack in that
>>> context I can imagine it being a recipe for all kinds of strange
>>> non-deterministic behavior.
>>>   
>>>       
>> The code does:
>>
>>    dev_close
>>       dev_deactive
>>          synchronize_rcu
>>    synchronize_net
>>    ...
>>    dev_shutdown
>>    ...
>>    synchronize_net
>>
>> The network device can no longer receive packets after dev_deactive, no ?
>> The first synchronize_net will wait for the outstanding packets to be delivered
>> to the upper layer and we change the nd_net field after.
>> Your scenario makes sense for the first synchronize_net but I am not sure that
>> can happen if we remove the second synchronize_net.
>>     
>
> Good point.  Visibility is key.  What can find us after we
> call list_netdevice() ?  Aren't there some pieces of code that
> do for_each_netdevice under the rcu lock?
>   
AFAIR, no. for_each_netdev is protected by rtnl_lock.

