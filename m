From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: locating the 'tc actions' hook
Date: Thu, 01 Aug 2013 16:18:23 -0700
Message-ID: <51FAECBF.3030704@intel.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22422 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757589Ab3HAXSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 19:18:25 -0400
In-Reply-To: <51FA493C.8080207@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> Am I missing something obvious here? Is there a way to link them to
>> filters? Sorry if it turns out to be a stupid question.
>>
>
> I think the second use case is what you are bumping into. I know from
> answering questions this is a very popular use case in some eastern
> European countries (where one policer with a specific rate is shared
> by many flows); i think they have a setup where you share your DSL
> connection with your neighbors. Its quiet a clever setup.
>

Great thanks I was missing part (b) above. Now I see how the index
works.

>
>> My motivation here is to use the filters/actions outside the qdisc lock
>> for mq, mqprio, and the ingress qdisc.
>>
>
> Are you trying to offload these actions into hardware?
> Is the classifier in hardware?
> Please let me know if you need further help. Example, I could send you
> a bunch of examples for either
>

I have two things in mind for this.

The first being directly related to the previous per queue rate limiter
patch. With rate limiters per queue on a multiqueue device using mq or
mqprio I need some mechanism to steer packets to queues. One way to do
this is to use mqprio and create a 'tc' with a single queue in it.
And then use iptables or netprio_cgroup to steer packets. Another way
to do this would be to use 'skbedit queue_mapping' to set the queue from
'tc' but unfortunately with the existing flows the queue has already
been selected by the time the classifiers are called. Calling into the
classifier chain before picking the qdisc would fix this. For flow based
QOS with multiqueue devices this type of functionality would be useful.

The second thought that I've been piecing together would be to populate
the rxhash (or maybe some other field) using the hardware flow
classifier in some meaningful way for the ingress qdisc. Some of the
existing Intel NICs can do this and I believe other vendors have similar
capabilities. Although currently with the qdisc lock running around the
ingress qdisc the multiqueue devices take a perf hit just by
instantiating the ingress qdisc which really is only using the lock to
guard some stats and keep the classifier/action chains sane.

If you have some good examples it would be great to see them and drop
them in my testbed. Go ahead and send them to me offlist if you can.

.John

> cheers,
> jamal
>
>
>> .John
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
