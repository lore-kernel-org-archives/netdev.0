From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 4/4] bridge: add ability to turn off fdb used
 updates
Date: Fri, 3 Feb 2017 23:27:20 +0100
Message-ID: <511809bf-0a48-3daf-51b7-148510419503@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
 <20170202.214737.1978812863222769540.davem@davemloft.net>
 <45f588fd-bece-647c-5b1e-2c64975e640d@cumulusnetworks.com>
 <20170203102825.363907ae@xeon-e3>
 <08ba3317-6ec0-1a4e-bdb5-68f5bb91495b@cumulusnetworks.com>
 <20170203142403.52eca52f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36141 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbdBCW1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:27:22 -0500
Received: by mail-wm0-f50.google.com with SMTP id c85so50979067wmi.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 14:27:22 -0800 (PST)
In-Reply-To: <20170203142403.52eca52f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/17 23:24, Stephen Hemminger wrote:
> On Fri, 3 Feb 2017 19:34:19 +0100
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> On 03/02/17 19:28, Stephen Hemminger wrote:
>>> On Fri, 3 Feb 2017 09:30:37 +0100
>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>   
>>>> On 03/02/17 03:47, David Miller wrote:  
>>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>> Date: Tue, 31 Jan 2017 16:31:58 +0100
>>>>>     
>>>>>> @@ -197,7 +197,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>>>>>>  		if (dst->is_local)
>>>>>>  			return br_pass_frame_up(skb);
>>>>>>  
>>>>>> -		dst->used = jiffies;
>>>>>> +		if (br->used_enabled)
>>>>>> +			dst->used = jiffies;    
>>>>>
>>>>> Have you tried:
>>>>>
>>>>> 	if (dst->used != jiffies)
>>>>> 		dst->used = jiffies;
>>>>>
>>>>> If that isn't effective, you can tweak the test to decrease the
>>>>> granularity of the value.  Basically, if dst->used is within
>>>>> 1 HZ of jiffies, don't do the write.
>>>>>
>>>>> I suspect this might help a lot, and not require a new bridging
>>>>> option.
>>>>>     
>>>>
>>>> Yes, I actually have a patch titled "used granularity". :-) I've tested with different
>>>> values and it does help but it either needs to be paired with another similar test for
>>>> the "updated" field (since they share a write-heavy cache line) or they need to be
>>>> in separate cache lines to avoid that dst's source port from causing the load HitM for
>>>> all who check the value.
>>>>
>>>> I'll run some more tests and probably go this way for now.
>>>>
>>>> Thanks,
>>>>  Nik
>>>>  
>>>
>>> Since used doesn't need HZ granularity, it reports values in clock_t resolution so
>>> storing (and doing cmp and set would mean that it would only be 100 HZ
>>>   
>>
>> Yes, exactly what I'm currently testing. Will post the new set soon.
>> Since HZ can be different a generic way to obtain the granularity for
>> both should be clock_t_to_jiffies(1) if I'm not missing something.
>>
>>
> 
> USER_HZ is set by userspace ABI to 100 hz. HZ is configurable when kernel is built.
> 

Yes, the point I was trying to make is that we want to take the number of jiffies
we can skip by converting 1 clock_t to X jiffies because the user-space granularity
is clock_t and HZ can change, thus clock_t_to_jiffies(1) should give us the number
of updates we can skip for "used" and "updated".
By "both" I meant "used" and "updated" fields, not HZ and USER_HZ.
