From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2 v2] af-packet: Use existing netdev reference for bound
 sockets.
Date: Sat, 28 May 2011 10:01:09 -0700
Message-ID: <4DE12A55.2010606@candelatech.com>
References: <1306467745.2543.60.camel@edumazet-laptop>	 <4DDF2463.3020001@candelatech.com>	 <1306526921.2533.7.camel@edumazet-laptop>	 <20110527.161542.568477840432205227.davem@davemloft.net>	 <4DE00711.6070000@candelatech.com> <1306563630.2533.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50156 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486Ab1E1RBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2011 13:01:16 -0400
In-Reply-To: <1306563630.2533.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2011 11:20 PM, Eric Dumazet wrote:
> Le vendredi 27 mai 2011 =C3=A0 13:18 -0700, Ben Greear a =C3=A9crit :
>> On 05/27/2011 01:15 PM, David Miller wrote:
>>> From: Eric Dumazet<eric.dumazet@gmail.com>
>>> Date: Fri, 27 May 2011 22:08:41 +0200
>>>
>>>> Le jeudi 26 mai 2011 =C3=A0 21:11 -0700, Ben Greear a =C3=A9crit :
>>>>> On 05/26/2011 08:42 PM, Eric Dumazet wrote:
>>>>>> Le jeudi 26 mai 2011 =C3=A0 16:55 -0700, greearb@candelatech.com=
 a =C3=A9crit :
>>>>>
>>>>>>>     out_free:
>>>>>>>     	kfree_skb(skb);
>>>>>>>     out_unlock:
>>>>>>> -	if (dev)
>>>>>>> +	if (dev&&    need_rls_dev)
>>>>>>>     		dev_put(dev);
>>>>>>>     out:
>>>>>>>     	return err;
>>>>>>
>>>>>> Hmmm, I wonder why you want this Ben.
>>>>>>
>>>>>> IMHO this is buggy, because we can sleep in this function.
>>>>>>
>>>>>> We must take a ref on device (its really cheap these days, now w=
e have a
>>>>>> percpu device refcnt)
>>>>>
>>>>> Why must you take the reference?  And if we must, why isn't the
>>>>> current code that assigns the prot_hook.dev without taking a
>>>>> reference OK?
>>>>>
>>>>
>>>> If we sleep, device can disappear under us.
>>>>
>>>> The only way to not take a reference is to hold rcu_read_lock(), b=
ut
>>>> you're not allowed to sleep under rcu_read_lock().
>>>
>>> You still have not addresses Ben's point.
>>>
>>> Why is it ok for the po->prot_hook.dev handling to not take a
>>> reference?  It's been doing this forever.  Ben is just borrowing th=
is
>>> behavior for his uses.
>>>
>>> After some more research I think it happens to be OK because
>>> ->prot_hook.dev is used _only_ for pointer comparisons, it is never
>>> actually dereferenced or used in any other way.  Probably, we shoul=
d
>>> just use ->ifindex for this.
>>
>> It's easy enough to add a dev_hold() when I assign the skb instead
>> of looking it up in my patch, but perhaps it would be cleaner over a=
ll to
>> just hold a ref on the prot_hook.dev when it is originally assigned?
>
>
> Problem is : if packet_notifier(NETDEV_DOWN|UNREGISTER) is run while =
we
> sleep, what happens then ?
>
> Normally, if we sleep a long time in tpacket_snd() after device ref
> increment, and before dev_queue_xmit(), the unregister process can en=
ter
> the infamous msleep(250) loop in netdev_wait_allrefs(), but at least =
we
> dont crash.
>
> But if you dont take the reference, we can crash in dev_queue_xmit()
> when dereferencing the freed netdev structure.
>
> Please check commit 1a35ca80c1db7 (packet: dont call sleeping functio=
ns
> while holding rcu_read_lock()) for reference on possible problems.

I'll create a new patch to hold ref on the prot_hook.dev when it's assi=
gned,
and then layer the 'existing netdev reference' patch on top of that.  M=
ight
be a day or two...

Thanks,
Ben

>
> Thanks !
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
