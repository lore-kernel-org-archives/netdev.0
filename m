From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Thu, 21 Sep 2017 13:14:24 +0200
Message-ID: <11016d6f-e8c5-3e8b-4cd8-7c6d583661cd@itcare.pl>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl>
 <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
 <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
 <07f0c800-7ee7-1ebe-9f5f-eaad52a7b42d@itcare.pl>
 <548a893c-8a8f-3b07-00f7-d75de1d777ad@itcare.pl>
 <7d8731ee-6c91-bbfd-6313-c95f52d7b49a@itcare.pl>
 <26e8b899-d8b1-caa4-436b-e23ffe384b0f@itcare.pl>
 <6c36fa00-13e6-8cd7-ff5c-df7739220736@itcare.pl>
 <CAEA6p_DpSr84cYu3pXqoHV=V=daSsbiOcnzsF+Kt0r4Wv_jmdg@mail.gmail.com>
 <CAEA6p_AiLvZxsyu+iOCrPzW-H28N=HBnWycy8w6gdZHFk2Q1dQ@mail.gmail.com>
 <1505956639.29839.108.camel@edumazet-glaptop3.roam.corp.google.com>
 <a016d5bc-1cbb-44d7-9ebf-e7e5428e6f98@itcare.pl>
 <1505991826.29839.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <22cde020-e13a-3635-512c-25532f754bda@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>, Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.iq.pl ([86.111.242.220]:56107 "EHLO smtp11.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751531AbdIULQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 07:16:29 -0400
In-Reply-To: <22cde020-e13a-3635-512c-25532f754bda@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-09-21 o 13:12, Paweł Staszewski pisze:
>
>
> W dniu 2017-09-21 o 13:03, Eric Dumazet pisze:
>> On Thu, 2017-09-21 at 11:06 +0200, Paweł Staszewski wrote:
>>> W dniu 2017-09-21 o 03:17, Eric Dumazet pisze:
>>>> On Wed, 2017-09-20 at 18:09 -0700, Wei Wang wrote:
>>>>>> Thanks very much Pawel for the feedback.
>>>>>>
>>>>>> I was looking into the code (specifically IPv4 part) and found 
>>>>>> that in
>>>>>> free_fib_info_rcu(), we call free_nh_exceptions() without holding 
>>>>>> the
>>>>>> fnhe_lock. I am wondering if that could cause some race condition on
>>>>>> fnhe->fnhe_rth_input/output so a double call on dst_dev_put() on the
>>>>>> same dst could be happening.
>>>>>>
>>>>>> But as we call free_fib_info_rcu() only after the grace period, and
>>>>>> the lookup code which could potentially modify
>>>>>> fnhe->fnhe_rth_input/output all holds rcu_read_lock(), it seems
>>>>>> fine...
>>>>>>
>>>>> Hi Pawel,
>>>>>
>>>>> Could you try the following debug patch on top of net-next branch and
>>>>> reproduce the issue check if there are warning msg showing?
>>>>>
>>>>> diff --git a/include/net/dst.h b/include/net/dst.h
>>>>> index 93568bd0a352..82aff41c6f63 100644
>>>>> --- a/include/net/dst.h
>>>>> +++ b/include/net/dst.h
>>>>> @@ -271,7 +271,7 @@ static inline void dst_use_noref(struct dst_entry
>>>>> *dst, unsigned long time)
>>>>>    static inline struct dst_entry *dst_clone(struct dst_entry *dst)
>>>>>    {
>>>>>           if (dst)
>>>>> -               atomic_inc(&dst->__refcnt);
>>>>> +               dst_hold(dst);
>>>>>           return dst;
>>>>>    }
>>>>>
>>>>> Thanks.
>>>>> Wei
>>>>>
>>>> Yes, we believe skb_dst_force() and skb_dst_force_safe() should be
>>>> unified  (to the 'safe' version)
>>>>
>>>> We no longer have gc to protect from 0 -> 1 transition of dst 
>>>> refcount.
>>>>
>>>>
>>>>
>>>>
>>> After adding patch from Wei
>>> https://bugzilla.kernel.org/show_bug.cgi?id=197005#c14
>>>
>> OK we have two problems here
>>
>> 1) We need to unify skb_dst_force()  ( for net tree )
>>
>> 2) Vlan devices should try to correctly handle IFF_XMIT_DST_RELEASE from
>> lower device. This will considerably help your performance.
>>
>>
>> For 1), this is what I had in mind, can you try it ?
>>
>> Thanks a lot !
>>
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 
>> 93568bd0a3520bb7402f04d90cf04ac99c81cfbe..f23851eeaad917e8dafc06b58d23a2575405c894 
>> 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -271,7 +271,7 @@ static inline void dst_use_noref(struct dst_entry 
>> *dst, unsigned long time)
>>   static inline struct dst_entry *dst_clone(struct dst_entry *dst)
>>   {
>>       if (dst)
>> -        atomic_inc(&dst->__refcnt);
>> +        dst_hold(dst);
>>       return dst;
>>   }
>>   @@ -311,21 +311,6 @@ static inline void skb_dst_copy(struct sk_buff 
>> *nskb, const struct sk_buff *oskb
>>       __skb_dst_copy(nskb, oskb->_skb_refdst);
>>   }
>>   -/**
>> - * skb_dst_force - makes sure skb dst is refcounted
>> - * @skb: buffer
>> - *
>> - * If dst is not yet refcounted, let's do it
>> - */
>> -static inline void skb_dst_force(struct sk_buff *skb)
>> -{
>> -    if (skb_dst_is_noref(skb)) {
>> -        WARN_ON(!rcu_read_lock_held());
>> -        skb->_skb_refdst &= ~SKB_DST_NOREF;
>> -        dst_clone(skb_dst(skb));
>> -    }
>> -}
>> -
>>   /**
>>    * dst_hold_safe - Take a reference on a dst if possible
>>    * @dst: pointer to dst entry
>> @@ -356,6 +341,23 @@ static inline void skb_dst_force_safe(struct 
>> sk_buff *skb)
>>       }
>>   }
>>   +/**
>> + * skb_dst_force - makes sure skb dst is refcounted
>> + * @skb: buffer
>> + *
>> + * If dst is not yet refcounted, let's do it
>> + */
>> +static inline void skb_dst_force(struct sk_buff *skb)
>> +{
>> +    if (skb_dst_is_noref(skb)) {
>> +        struct dst_entry *dst = skb_dst(skb);
>> +
>> +        WARN_ON(!rcu_read_lock_held());
>> +        if (!dst_hold_safe(dst))
>> +            dst = NULL;
>> +        skb->_skb_refdst = (unsigned long)dst;
>> +    }
>> +}
>>     /**
>>    *    __skb_tunnel_rx - prepare skb for rx reinsert
>>
>>
>>
> Thanks
>
> What is weird i have this part in my net-next from git:
> /**
>  * skb_dst_force_safe - makes sure skb dst is refcounted
>  * @skb: buffer
>  *
>  * If dst is not yet refcounted and not destroyed, grab a ref on it.
>  */
> static inline void skb_dst_force_safe(struct sk_buff *skb)
> {
>         if (skb_dst_is_noref(skb)) {
>                 struct dst_entry *dst = skb_dst(skb);
>
>                 if (!dst_hold_safe(dst))
>                         dst = NULL;
>
>                 skb->_skb_refdst = (unsigned long)dst;
>         }
> }
>
>
>
ok the difference is skb_dst_force_safe not skb_dst_force
