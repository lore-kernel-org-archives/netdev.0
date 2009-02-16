From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Mon, 16 Feb 2009 14:46:46 +0100
Message-ID: <49996E46.7090102@dev.6wind.com>
References: <498ABDA2.5040603@dev.6wind.com>	<20090205.234520.149982266.davem@davemloft.net>	<498C403D.9040500@dev.6wind.com>	<20090206.141026.85510254.davem@davemloft.net>	<49919FD4.3000008@dev.6wind.com>
	<4991AE04.7020307@free.fr>	<4991AFDA.8020704@dev.6wind.com>
	<4991B5C9.9040005@free.fr>	<m1zlgtjtrf.fsf@fess.ebiederm.org>
	<4992F372.4020206@free.fr>	<m1iqngh8yo.fsf@fess.ebiederm.org>
	<49943C17.5080509@free.fr> <49983F0D.2090905@free.fr>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49983F0D.2090905-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
> Daniel Lezcano wrote:
>> Eric W. Biederman wrote:
>>  
>>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>>>
>>>      
>>>> Eric W. Biederman wrote:
>>>>          
>>>>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>>>>>                
>>>>>> Hmm, at the first glance I would say it is useless but perhaps 
>>>>>> there is a
>>>>>>                   
>>>> trick
>>>>          
>>>>>> here I do not understand.
>>>>>> Eric, is there any particular reason to call synchronize_net 
>>>>>> before exiting
>>>>>>                   
>>>> the
>>>>          
>>>>>> dev_change_net_namespace function ?
>>>>>>                       
>>>>> I haven't thought about that part of the code path in detail in a long
>>>>> time.  dev_change_net_namespace() is a condensed version of
>>>>> register_netdevice() unregister_netdevice().  With the calls down into
>>>>> the driver removed.
>>>>>
>>>>> On a side note.  It looks like we now cope with:
>>>>> call_netdevice_notifiers(NETDEV_REGISTER, dev); failing in
>>>>> register_netdev, but no one updated dev_change_net_namespace to handle
>>>>> the change, looks like a real pain to cope with.
>>>>>
>>>>> As for the synchronize_net, and in response to the original
>>>>> comment as best as I can tell we do have things being being
>>>>> deleted that are at least candidates for synchronize_net.
>>>>>
>>>>> dev_addr_discard(dev);
>>>>> dev_net_set(dev, net);
>>>>> netdev_unregister_kobject(dev);
>>>>>
>>>>> We very much do access dev->net with only rcu protection.
>>>>>
>>>>> Hmm.
>>>>>
>>>>> It looks like I originally took the second synchronize_net from what
>>>>> became rollback_registered, which happens just before we start freeing
>>>>> the netdevice.
>>>>>
>>>>> The nastiest case that I can envision is if we happen to receive a
>>>>> packet (on another cpu) for the network device that we are moving,
>>>>> just after it has registered in the new network namespace.  If we read
>>>>> the old network namespace and forward it up the network stack in that
>>>>> context I can imagine it being a recipe for all kinds of strange
>>>>> non-deterministic behavior.
>>>>>                 
>>>> The code does:
>>>>
>>>>    dev_close
>>>>       dev_deactive
>>>>          synchronize_rcu
>>>>    synchronize_net
>>>>    ...
>>>>    dev_shutdown
>>>>    ...
>>>>    synchronize_net
>>>>
>>>> The network device can no longer receive packets after dev_deactive, 
>>>> no ?
>>>> The first synchronize_net will wait for the outstanding packets to 
>>>> be delivered
>>>> to the upper layer and we change the nd_net field after.
>>>> Your scenario makes sense for the first synchronize_net but I am not 
>>>> sure that
>>>> can happen if we remove the second synchronize_net.
>>>>           
>>> Good point.  Visibility is key.  What can find us after we
>>> call list_netdevice() ?  Aren't there some pieces of code that
>>> do for_each_netdevice under the rcu lock?
>>>       
>> AFAIR, no. for_each_netdev is protected by rtnl_lock.
>>   
> 
> Nicolas,
> 
> At the first glance it looks like the removing of the second 
> synchronize_net is fine, but before posting the patch do you mind to 
> wait a little ?
> I would like to do some tests with your patch to check if we don't 
> missed something.
> 

Hi Daniel,

no problem, there is no hurry. Let me know the result of your tests.

Thanks,
Nicolas
