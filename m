From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 19:58:51 +0200
Message-ID: <c179303c-ba38-a576-ea0c-6d72e858ddb5@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
 <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
 <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
 <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
 <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <07c29702-cd0b-32af-df0a-83ad24b8c785@itcare.pl>
 <1505914479.29839.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <686ea8f0-d9f8-82bc-ca68-f1d97614aa6b@itcare.pl>
 <1505915099.29839.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <cf94cafb-07b0-f04d-016d-cbdb46b557c1@itcare.pl>
 <1505918451.29839.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <273f49c7-58c0-0b41-10ff-6f891ffb72e9@itcare.pl>
 <CAEA6p_D8Av0QAJ46Gzx=Bt3uP-NshTmz2QoBzYaO8OK9+CFQNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:43498 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751175AbdITSA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 14:00:59 -0400
In-Reply-To: <CAEA6p_D8Av0QAJ46Gzx=Bt3uP-NshTmz2QoBzYaO8OK9+CFQNA@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-09-20 o 19:46, Wei Wang pisze:
>>> This is why I suggested to replace the BUG() in another mail
>>>
>>> So :
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index
>>> f535779d9dc1dfe36934c2abba4e43d053ac5d6f..220cd12456754876edf2d3ef13195e82d70d5c74
>>> 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -3331,7 +3331,15 @@ void netdev_run_todo(void);
>>>     */
>>>    static inline void dev_put(struct net_device *dev)
>>>    {
>>> -       this_cpu_dec(*dev->pcpu_refcnt);
>>> +       int __percpu *pref = READ_ONCE(dev->pcpu_refcnt);
>>> +
>>> +       if (!pref) {
>>> +               pr_err("no pcpu_refcnt on dev %p(%s) state %d dismantle
>>> %d\n",
>>> +                      dev, dev->name, dev->reg_state, dev->dismantle);
>>> +               for (;;)
>>> +                       cpu_relax();
>>> +       }
>>> +       this_cpu_dec(*pref);
>>>    }
>>>      /**
>>>
> Thanks a lot Eric for the debug patch.
>
> Pawel,
>
> I want to confirm with you about the last good commit when you did bisection.
> You mentioned:
>
>> And the last one
>>
>> git bisect good
>> Bisecting: 1 revision left to test after this (roughly 1 step)
>> [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take dst->__refcnt for
>> insertion into fib6 tree
>>
>> With this have kernel panic same as always
>>
>> git bisect bad
>> Bisecting: 0 revisions left to test after this (roughly 0 steps)
>> [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC and
>> remove the operation of dst_free()
>
> So it breaks right at:
> [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC and
> remove the operation of dst_free()
> Right?
> If you sync the image to one commit before the above one:
> [9df16efadd2a8a82731dc76ff656c771e261827f] ipv4: call dst_hold_safe() properly
> Does it crash?
Later today i will repeat last three steps - in about next 3 hours after 
rush hours of internet traffic - now i cant touch backup router  :)

>
> And could you confirm that your config does not have any IPv6
> addresses or routes configured?
There is ipv6 enabled
And yes there are some ipv6 ip's
One interface have ipv6 enabled with one static route

  but no ipv6 bgp sessions - so nt many ipv6 prefixes and ipv6 fib is 
almost empty

ip -6 r ls | wc -l
57


>
> Thanks.
> Wei
>
>
> 6:03 +0200, Paweł Staszewski wrote:
>>>> Nit much more after adding this patch
>>>>
>>>> https://bugzilla.kernel.org/attachment.cgi?id=258529
>>>>
>>> This is why I suggested to replace the BUG() in another mail
>>>
>>> So :
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index
>>> f535779d9dc1dfe36934c2abba4e43d053ac5d6f..220cd12456754876edf2d3ef13195e82d70d5c74
>>> 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -3331,7 +3331,15 @@ void netdev_run_todo(void);
>>>     */
>>>    static inline void dev_put(struct net_device *dev)
>>>    {
>>> -       this_cpu_dec(*dev->pcpu_refcnt);
>>> +       int __percpu *pref = READ_ONCE(dev->pcpu_refcnt);
>>> +
>>> +       if (!pref) {
>>> +               pr_err("no pcpu_refcnt on dev %p(%s) state %d dismantle
>>> %d\n",
>>> +                      dev, dev->name, dev->reg_state, dev->dismantle);
>>> +               for (;;)
>>> +                       cpu_relax();
>>> +       }
>>> +       this_cpu_dec(*pref);
>>>    }
>>>      /**
>>>
>>>
>>>
>> Full panic
>>
>> https://bugzilla.kernel.org/attachment.cgi?id=258531
>>
>>
>> I will change patch and apply but later today cause now cant use backup
>> router as testlab - Internet rush hours if something happens this will be
>> bed when second router will have bugged kernel :)
>>
>>
