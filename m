From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Mon, 23 Dec 2013 15:41:15 -0500
Message-ID: <52B89FEB.9090503@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com>	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>	<52B1FC6D.7040005@mojatatu.com>	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>	<52B71024.3090504@mojatatu.com>	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>	<52B74C3A.1050900@mojatatu.com>	<CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>	<52B82F80.8070902@mojatatu.com> <CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41805 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917Ab3LWUl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 15:41:27 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so6365463iec.33
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 12:41:26 -0800 (PST)
In-Reply-To: <CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/13 13:50, Cong Wang wrote:
> On Mon, Dec 23, 2013 at 4:41 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>>
>> It is about _correct policy_
>> If you have a packets going:
>> ->A-->B-->C-->D-->E
>>
>> That is the policy (decided by someone/thing in user space).
>> A to E are mechanisms.
>
> Apparently you have a different definition of "policy" and "mechanism"
> with me, probably with others too...
>

I think only with you ;->

> I assume you mean actions here, since we don't care about others
> in this thread.
>
[..]
>
> Since they are chained by a singly or doubly linked list in
> non-shared case, where are "other things in the graph"?
>

Nothing to do with implementation - think conceptually.

> Please do explain how can they be in a graph in non-shared
> case, it is not obvious to me at all.
>

[..]
> Nope, I only want to remove A from the chain by list_del() for non-shared
> case.
>

[..]

>
> Nope, you continue to mention graph, but don't explain why there is
> a graph in non-shared case. Nor I think you use "policy" or "mechanism"
> correctly. :)
>
> Jamal, please don't be abstract, just talk about actions. We DO NOT
> care about others in this thread.
>

It is not just actions that constitute the graph. It starts at netdev.
Actions are more complex because you have a real DAG. i.e you can
have branches etc.
So how best to explain this?
Ive gone the avenue of showing you shared actions and failed. So i am
trying to simplify it to a single basic graph;->
I will try again to use the graph concept:

If i or some program decide that a packet coming on is going to
traverse:
  -->netdevX->qdiscA->classifierB->{ActionC->Action D->ActionE}

That is a policy. It tells different parts of the kernel(the mechanisms)
how to treat a packet that traverses them in order to create some
resultant service.
What i drew above is a graph (as noted above {} is more complex
because you could have branches etc, eg i could go on Action C to do
sometimes but skip to E other times based on state, actually you
could have that with classifiers - but lets ignore that for now).
Each of the things preceeded by "->" is a graph node, otherwise known as 
a vertex (eg netdevX).
Each of the "->" is an known as a graph edge.
Each of the nodes in a graph is a mechanism.
If this still doesnt make sense to you, I can describe it differently
without using concept of graphs.

Now if you have such a graph:
User space can delete the node netdevX and then you (kernel)
can dereference all that is underneath it. That is a good optimization
since user just deleted the root; we can then notify user only about 
netdevX. It doesnt matter if Action D is shared; reference count will
decrease and if it hits zero, real destroy will happen.
User can delete the qdiscA and then kernel can dereference everything
underneath. That is fair optimization as above.
User can delete the filter and kernel can dereference
everything underneath it. That is also fair optimization as above.
What you cannot do is, on your own as kernel, decide you want to delete
one action that is _bound_ to a filter because one of its attributes is
gone berserk. It doesnt matter whether such an action is mirred or foo
or whether D and E dont exist. You can put a big hole where the town
used to be and leave roads leading to the town.
It will still be referenced by things preeceding it (primarily the 
classifier which keeps an action chain intact), which is bad when the
next packet arrives.
You let the user/control program which is monitoring things do that
and "reroute" around the problem. If you insist on putting a little part
of the medula oblangata in the stomach, then:
the only correct way to do it is delete the filter.
And you start doing that you are making some serious policy decisions
in the kernel and adding lots of complexity.

Ok, does it make sense now?;->

cheers,
jamal
