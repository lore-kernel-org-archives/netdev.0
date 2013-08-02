From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: locating the 'tc actions' hook
Date: Fri, 02 Aug 2013 11:46:19 -0700
Message-ID: <51FBFE7B.1010602@gmail.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com> <51FAECBF.3030704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:58271 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab3HBSqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 14:46:43 -0400
Received: by mail-ob0-f179.google.com with SMTP id fb19so1810566obc.38
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 11:46:42 -0700 (PDT)
In-Reply-To: <51FAECBF.3030704@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2013 04:18 PM, John Fastabend wrote:
> [...]
>
>>> Am I missing something obvious here? Is there a way to link them to
>>> filters? Sorry if it turns out to be a stupid question.
>>>
>>
>> I think the second use case is what you are bumping into. I know from
>> answering questions this is a very popular use case in some eastern
>> European countries (where one policer with a specific rate is shared
>> by many flows); i think they have a setup where you share your DSL
>> connection with your neighbors. Its quiet a clever setup.
>>
>
> Great thanks I was missing part (b) above. Now I see how the index
> works.
>

Perhaps another incorrect observation but what protects the tc_actions?

Create a series of actions via 'tc actions' which populates the hash
table protected by hinfo->lock and also rtnetlink is holding the rtnl
lock.

Add a filter with index hook to get this action graph attached to a
filters tcf_exts pointer.

Now for what I think is the race, the classifier will call tcf_exts_exec
which will call tcf_action_exec() and start walking the actions and
executing them with the qdisc_lock held.

At the same time tcf_action_destroy() may be called via 'tc actions 
delete' which will only hold the rtnl lock via rtnetlink.

Again I think I might be missing a piece somewhere but I'm not seeing
how the locking adds up here. I'll look at it a bit more but thought
it might be worth asking.


>>
>>> My motivation here is to use the filters/actions outside the qdisc lock
>>> for mq, mqprio, and the ingress qdisc.
>>>
>>
>> Are you trying to offload these actions into hardware?
>> Is the classifier in hardware?
>> Please let me know if you need further help. Example, I could send you
>> a bunch of examples for either
>>
>
> I have two things in mind for this.
>
> The first being directly related to the previous per queue rate limiter
> patch. With rate limiters per queue on a multiqueue device using mq or
> mqprio I need some mechanism to steer packets to queues. One way to do
> this is to use mqprio and create a 'tc' with a single queue in it.
> And then use iptables or netprio_cgroup to steer packets. Another way
> to do this would be to use 'skbedit queue_mapping' to set the queue from
> 'tc' but unfortunately with the existing flows the queue has already
> been selected by the time the classifiers are called. Calling into the
> classifier chain before picking the qdisc would fix this. For flow based
> QOS with multiqueue devices this type of functionality would be useful.
>
> The second thought that I've been piecing together would be to populate
> the rxhash (or maybe some other field) using the hardware flow
> classifier in some meaningful way for the ingress qdisc. Some of the
> existing Intel NICs can do this and I believe other vendors have similar
> capabilities. Although currently with the qdisc lock running around the
> ingress qdisc the multiqueue devices take a perf hit just by
> instantiating the ingress qdisc which really is only using the lock to
> guard some stats and keep the classifier/action chains sane.
>
> If you have some good examples it would be great to see them and drop
> them in my testbed. Go ahead and send them to me offlist if you can.
>
> .John
>
>> cheers,
>> jamal
>>
>>
>>> .John
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
