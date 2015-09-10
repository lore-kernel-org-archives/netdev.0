From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 16:42:47 -0300
Message-ID: <55F1DD37.1080900@gmail.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com> <55F09F57.6080602@gmail.com>
 <55F1847A.9010801@gmail.com> <55F19243.3010006@gmail.com>
 <55F1A6AE.2010804@gmail.com> <20150910162454.GB4496@localhost.localdomain>
 <20150910183520.GD4496@localhost.localdomain> <55F1D6A1.6060605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:32907 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbbIJTmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 15:42:55 -0400
In-Reply-To: <55F1D6A1.6060605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 10-09-2015 16:14, Vlad Yasevich escreveu:
> On 09/10/2015 02:35 PM, Marcelo Ricardo Leitner wrote:
>> On Thu, Sep 10, 2015 at 01:24:54PM -0300, Marcelo Ricardo Leitner wrote:
>>> On Thu, Sep 10, 2015 at 11:50:06AM -0400, Vlad Yasevich wrote:
>>>> On 09/10/2015 10:22 AM, Marcelo Ricardo Leitner wrote:
>>>>> Em 10-09-2015 10:24, Vlad Yasevich escreveu:
>>> ...
>>>>>> Then you can order sctp_net_init() such that it happens first, then protosw registration
>>>>>> happens, then control socket initialization happens, then inet protocol registration
>>>>>> happens.
>>>>>>
>>>>>> This way, we are always guaranteed that by the time user calls socket(), protocol
>>>>>> defaults are fully initialized.
>>>>>
>>>>> Okay, that works for module loading stage, but then how would we handle new netns's? We
>>>>> have to create the control socket per netns and AFAICT sctp_net_init() is the only hook
>>>>> called when a new netns is being created.
>>>>>
>>>>> Then if we move it a workqueue that is scheduled by sctp_net_init(), we loose the ability
>>>>> to handle its errors by propagating through sctp_net_init() return value, not good.
>>>>
>>>> Here is kind of what I had in mind.  It's incomplete and completely untested (not even
>>>> compiled), but good enough to describe the idea:
>>> ...
>>>
>>> Ohh, ok now I get it, thanks. If having two pernet_subsys for a given
>>> module is fine, that works for me. It's clearer and has no moment of
>>> temporary failure.
>>>
>>> I can finish this patch if everybody agrees with it.
>>>
>>>>>>> I used the list pointer because that's null as that memory is entirely zeroed when alloced
>>>>>>> and, after initialization, it's never null again. Works like a lock/condition without
>>>>>>> using an extra field.
>>>>>>>
>>>>>>
>>>>>> I understand this a well.  What I don't particularly like is that we are re-using
>>>>>> a list without really stating why it's now done this way.  Additionally, it's not really
>>>>>> the last that happens so it's seems kind of hacky...  If we need to add new
>>>>>> per-net initializers, we now need to make sure that the code is put in the right
>>>>>> place.  I'd just really like to have a cleaner solution...
>>>>>
>>>>> Ok, got you. We could add a dedicated flag/bit for that then, if reusing the list is not
>>>>> clear enough. Or, as we are discussing on the other part of thread, we could make it block
>>>>> and wait for the initialization, probably using some wait_queue. I'm still thinking on
>>>>> something this way, likely something more below than sctp then.
>>>>>
>>>>
>>>> I think if we don the above, the second process calling socket() will either find the
>>>> the protosw or will try to load the module also.  I think either is ok after
>>>> request_module returns we'll look at the protosw and will find find things.
>>>
>>> Seems so, yes. Nice.
>>
>> I was testing with it, something is not good. I finished your patch and
>> testing with a flooder like:
>>   # for j in {1..5}; do for i in {1234..1280}; do \
>>         sctp_darn -H 192.168.122.147 -P $j$i -l & done & done
>>
> ... snip...
>>
>> It seems that request_module will not serialize it as we wanted and we
>> would be putting unexpected pressure on it, yet it fixes the original
>> issue.
>
> So, wouldn't the same issue exist when running the above with DCCP sockets?

Pretty much, yes.

>> Maybe we can place a semaphore at inet_create(), protecting the
>> request_module()s so only one socket can do it at a time and, after it
>> is released, whoever was blocked on it re-checks if the module isn't
>> already loaded before attempting again. It makes the loading of
>> different modules slower, though, but I'm not sure if that's really a
>> problem. Not many modules are loaded at the same time like that. What do
>> you think?
>
> I think this is a different issue.  The fact that we keep trying to probe

Agreed. I'll post this one as v2 while we continue with the 
request_module part.

> the same module is silly.  May be a per proto semaphore so that SCTP doesn't
> block DCCP for example.

Can be, yes. It just has to be dynamic, otherwise we would have to have 
like 256 semaphores that are left unused for most of the system's 
lifetime. I'll see what I can do here.

Thanks,
Marcelo
