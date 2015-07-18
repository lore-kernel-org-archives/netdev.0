From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RGC PATCH v3.10] net: sched: validate that class is found in
 qdisc_tree_decrease_qlen
Date: Sat, 18 Jul 2015 10:50:28 +0200
Message-ID: <1437209428.1026.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
	 <CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
	 <CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Alex Gartrell <agartrell@fb.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33143 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbGRIue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 04:50:34 -0400
Received: by wgmn9 with SMTP id n9so97153057wgm.0
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 01:50:33 -0700 (PDT)
In-Reply-To: <CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 17:27 -0700, Alex Gartrell wrote:
> On Fri, Jul 17, 2015 at 5:10 PM, Cong Wang <cwang@twopensource.com> wrote:
> > Hmm, but in htb_delete() we do reset the leaf qdisc before removing the
> > class from ha
> >
> >         if (!cl->level) {
> >                 qlen = cl->un.leaf.q->q.qlen;
> >                 qdisc_reset(cl->un.leaf.q);
> >                 qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
> >         }
> >
> > therefore, the leaf fq_codel qdisc is supposed to have 0 skb after that,
> > that is, the second fq_codel_reset() is supposed to return NULL immediately?
> > Why is qdidsc_tree_decrease_qlen() called in the second fq_codel_reset()?
> >
> > Or there is a race condition between ->delete() and ->put()? In which new
> > skb can be enqueued?
> 
> This makes the most sense to me, but I have ~32 hours of experience
> with this subsystem :)
> 
> Taking that for granted, it seems like it'd be appropriate to note the
> invariant in the code i've changed with a WARN_ON and to skip it, and
> then to otherwise find a way to close the hole.  Do you agree?
> 


HTB + fq_codel ?

Make sure you applied Cong fix

commit c0afd9ce4d6a646fb6433536f95a418bb348fab1
Author: WANG Cong <xiyou.wangcong@gmail.com>
Date:   Tue Jul 14 11:21:58 2015 -0700

    fq_codel: fix return value of fq_codel_drop()
    
    The ->drop() is supposed to return the number of bytes it dropped,
    however fq_codel_drop() returns the index of the flow where it drops
    a packet from.
    
    Fix this by introducing a helper to wrap fq_codel_drop().
