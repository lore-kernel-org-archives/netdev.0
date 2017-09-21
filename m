From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Latest net-next from GIT panic
Date: Thu, 21 Sep 2017 15:18:53 +0200
Message-ID: <80e8948e-669b-4139-add6-637c6dd3405f@itcare.pl>
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
 <8d2b4263-bd81-9cff-81ac-2df686cf29aa@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Wei Wang <weiwan@google.com>, Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.iq.pl ([86.111.242.220]:54615 "EHLO smtp11.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751606AbdIUNU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 09:20:59 -0400
In-Reply-To: <8d2b4263-bd81-9cff-81ac-2df686cf29aa@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-09-21 o 13:31, Paweł Staszewski pisze:
>
>
> W dniu 2017-09-21 o 13:03, Eric Dumazet pisze:
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
>
> Patch applied - soo far no problems - and no warnings in dmesg
>
>
ok after adding patch all is working from now for about 1 hour of normal 
traffic witc all bgp sessions connected and about 600k prefixes in kernel.
