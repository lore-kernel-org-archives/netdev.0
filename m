From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 30 Aug 2016 14:03:08 +0300
Message-ID: <20160830110308.GA7141@office.localdomain>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
 <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
 <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35849 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757841AbcH3LDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:03:17 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so2607701wmf.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 04:03:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 10:04:21PM -0700, Cong Wang wrote:
> On Fri, Aug 26, 2016 at 12:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2016-08-26 at 11:26 -0700, Cong Wang wrote:
> >> 1) Currently there are only a few actions using lockless, and they are
> >> questionable, as we already discussed before, there could be some
> >> race condition when you modify an existing action.
> >
> > There is no fundamental issue with a race condition.
> 
> For mirred action, maybe. As we already discussed, the more
> complex an action is, the harder to make it lockless in your
> way (that is, not using RCU)
> 
> >
> > Sure, there are races, but they have no serious effect.
> >
> > Feel free to send a fix if you really have time to spare.
> 
> It's because the code is written by you?
> 
> I am surprised how you try to hide your own problem in
> such a way...
> 
> 
> >
> >>
> >> 2) We need to change the tc action API in order to fully support RCU,
> >> which is what I have been working on these days. I should come up
> >> with something next Monday (if not this weekend).
> >>
> >> So for this patchset, using spinlock is fine, just as many other actions.
> >> I will take care of it later.
> >
> > This is _not_ fine.
> 
> 
> OK, so where are your patches to make the rest actions
> lockless?
> 
> 
> >
> > We are in 2016, not in 1995 anymore.
> >
> 
> Fair enough, sounds like all actions are already lockless in
> fast path now in 2016, you know this is not true...
> 
> 
> > We are not adding a spinlock in a hot path unless absolutely needed.
> 
> If it is bug-free, yes, I am totally with you. I care about corretness
> more than any performance.
> 
> 
> >
> > With multi queue NIC, this spinlock is going to hurt performance so much
> > that this action wont be used by any serious user.
> 
> We have used mirred action even before you make it lockless.
> 
> 
> >
> > Here, it is absolutely trivial to use RCU and/or percpu counters.
> 
> Sounds like we don't need any API change, why not go ahead
> and try it? Please do teach me how to modify an existing
> action in a lockless way without changing any API (and of course
> needs to be bug-free), I am very happy to learn your "trivial" way
> to fix this, since I don't have any trivial fix.
> 
> Please, stop bullsh*t, show me your trivial code.

Regarding the specific action in this patchset, correct me if I'm wrong,
but I think that the lock could be removed safely.

When the action is modified during traffic, an existing tcf_enc_metadata
is not changed, but a new metadata is allocated and the pointer is
replaced to point to the new one.
I just need to make sure that when changing an action from 'release'
into 'set' - tcf_enc_metadata will be set before the action type is
changed - change the order of operations and add a memory barrier.
Here is a pseudo code to explain:

metadata_new = new allocated metadata
metadata_old = t->tcft_enc_metadata

t->tcft_action = encapdecap

/* make sure the compiler won't swap the setting of tcft_action with
 * tcft_enc_metadata
 */
wmb()

t->tcft_enc_metadata = metadata_new
release metadata_old


This way, no need for lock between the init() and act() operations.

Please let me know if you see a problem with this approach.
I will also change the stats to be percpu.

Thanks,
Amir
