From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sch_htb: fix crash on init failure
Date: Tue, 29 Aug 2017 11:23:14 -0700
Message-ID: <1504030994.11498.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
         <1504030196.11498.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUh2LjwuzNQ1OqRRzKMJ1uARp0ouOQ42HEsAC5XJm_BWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36289 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2SXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:23:15 -0400
Received: by mail-pf0-f181.google.com with SMTP id z87so12431151pfi.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:23:15 -0700 (PDT)
In-Reply-To: <CAM_iQpUh2LjwuzNQ1OqRRzKMJ1uARp0ouOQ42HEsAC5XJm_BWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 11:13 -0700, Cong Wang wrote:
> On Tue, Aug 29, 2017 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2017-08-29 at 20:58 +0300, Nikolay Aleksandrov wrote:
> >> The commit below added a call to the ->destroy() callback for all qdiscs
> >> which failed in their ->init(), but some were not prepared for such
> >> change and can't handle partially initialized qdisc. HTB is one of them
> >> and if any error occurs before the qdisc watchdog timer and qdisc work are
> >> initialized then we can hit either a null ptr deref (timer->base) when
> >> canceling in ->destroy or lockdep error info about trying to register
> >> a non-static key and a stack dump. So to fix these two move the watchdog
> >> timer and workqueue init before anything that can err out.
> >> To reproduce userspace needs to send broken htb qdisc create request,
> >> tested with a modified tc (q_htb.c).
> >
> >> Note that probably this bug goes further back because the default qdisc
> >> handling always calls ->destroy on init failure too.
> >>
> >> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> >> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >> ---
> >> Always calling qdisc destroy on init failure in the default qdisc handling
> >> was added in commit 0fbbeb1ba43b. I'm not sure if I should include that
> >> one as fixes tag.
> >
> > Well, we probably need to audit init/destroy not only in net/sched, but
> > other parts of networking stack.
> >
> > What about the qdisc_skb_head_init(&q->direct_queue) call ?
> 
> It just zero the pointers:
> 
> static inline void qdisc_skb_head_init(struct qdisc_skb_head *qh)
> {
>         qh->head = NULL;
>         qh->tail = NULL;
>         qh->qlen = 0;
> }
> 
> And qdisc is already kzalloc()'ed.

Yeah, I was looking at some old tree, not having the
__qdisc_reset_queue() yet.
