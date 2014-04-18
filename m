From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Fri, 18 Apr 2014 10:26:33 -0400
Message-ID: <53513619.5060202@mojatatu.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>	<534E77D0.8000307@mojatatu.com>	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>	<534FBFF0.3020606@mojatatu.com> <CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:50899 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbaDRO0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 10:26:54 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so720637igb.11
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 07:26:54 -0700 (PDT)
In-Reply-To: <CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/14 16:48, Cong Wang wrote:

> Actions attached to a filter are at the end of the graph, they should
> be able to be added/removed together.


I will try to be clear: you are changing policy which is a higher
level semantic than any one of filter or actions. Consider:

a) A simple policy in a linear graph
if (icmp) --> A-->B-->C-->D-->E

With the following individual change operations:
i)change to delete C
ii)change to add G after B
iii) add F as branch from D
iv) add H after E and maintain linear status
v) after #iv make the graph at node D selectively branch between E/H

Ok, let provide a slightly complex graph, sorry it is hard to do ascii
diagram for this, so i will illustrate programmatically:

if (icmp) {
     mark with tag 11 //mark index 7
     if (rate < 10kbs) { //policer index 1
        return
     } else {
        mark with tag 12  //mark index 3
        if (rate2 < 20kbs) {//policer index 2
           return
       } else {
           mirror to dummy0 //mirred index 8
       }
    }
}

What does adding/deleting even mean in this case?

>
> This is a workaround, not a fix. What if I have multiple threads
> trying to append an action at the same time? This workaround
> can't guarantee the correctness.
>

Sorry Cong, your approach is NOT a fix. There is _no way_ you can
achieve correctness without a two phase operation. Talk to the
netfilter guys about such experiences (in 2.x kernels?).
The multiple threads issue is taken care of by locking,
you just want to reduce the amount of lock time needed; that is
what that (proven) 2 phase approach is doing.
I called it workaround because you dont need to make any changes
in the kernel. There is a tiny window of inconsistency possible in
presence of multiple contenders but you already get that with things
like RCU (grace period) that you added.

> My case is a perfectly valid use,

I am not questioning your use case - just it shouldnt come as a hack at
the expense of all other use cases (of which the most important
are not replacing/changing a graph but creating and deleting one).

>we have to fix it, maybe in another way.

If you really really really insist i has to be done in the kernel;
then i would hope youd do it in some form of pseudo transacational
approach as i described is done today in user space.
I hope avoidance of a fat approach like 2PC as well is in order.
Again as i said I am extremely leary of optimizing for such
corner case since you can achieve all that in user space.

cheers,
jamal
