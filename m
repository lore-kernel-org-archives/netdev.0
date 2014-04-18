From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Fri, 18 Apr 2014 10:18:09 -0700
Message-ID: <CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
	<534E77D0.8000307@mojatatu.com>
	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
	<534FBFF0.3020606@mojatatu.com>
	<CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
	<53513619.5060202@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:37786 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbaDRRSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 13:18:10 -0400
Received: by mail-ob0-f175.google.com with SMTP id wp4so2007499obc.6
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 10:18:10 -0700 (PDT)
In-Reply-To: <53513619.5060202@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2014 at 7:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Ok, let provide a slightly complex graph, sorry it is hard to do ascii
> diagram for this, so i will illustrate programmatically:
>
> if (icmp) {
>     mark with tag 11 //mark index 7
>     if (rate < 10kbs) { //policer index 1
>        return
>     } else {
>        mark with tag 12  //mark index 3
>        if (rate2 < 20kbs) {//policer index 2
>           return
>       } else {
>           mirror to dummy0 //mirred index 8
>       }
>    }
> }
>
> What does adding/deleting even mean in this case?

In this case, all the statements inside if (icmp) {} are actions, right?
Sorry, I still fail to see why not allowing to change them *together*?

IOW, what's wrong with changing if (icmp) { A } to if (icmp) { B } ?
where A and B could be any complex combination of actions.
RTNL lock guarantees this is transactional.

Users are responsible to ensure the logic of A or B is correct, not
the kernel. Kernel should allow even a wrong combination,
since there is no way to check the correctness in kernel.

I never mean to only add or remove one of them inside, although
my specific case is just for appending, my patch should allow to
overwrite all the actions together.

[...]

>
> If you really really really insist i has to be done in the kernel;
> then i would hope youd do it in some form of pseudo transacational
> approach as i described is done today in user space.
> I hope avoidance of a fat approach like 2PC as well is in order.
> Again as i said I am extremely leary of optimizing for such
> corner case since you can achieve all that in user space.
>


It is not a corner case, it is a very basic functionality we need:

We mirror icmp packets to every vethX device, when one of them
is gone, we just remove the action; when a new one comes up,
we append an action. So simple...
