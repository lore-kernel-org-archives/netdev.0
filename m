From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RGC PATCH v3.10] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Fri, 17 Jul 2015 17:10:51 -0700
Message-ID: <CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
References: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33818 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbbGRAKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 20:10:51 -0400
Received: by ykax123 with SMTP id x123so102162162yka.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 17:10:51 -0700 (PDT)
In-Reply-To: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 4:27 PM, Alex Gartrell <agartrell@fb.com> wrote:
> To my understanding, the following situation is taking place.
>
>   tc_ctl_tclass
>    -> htb_delete
>      -> class is deleted from clhash
>    -> htb_put
>      -> qdisc_destroy
>        -> fq_codel_reset
>          -> fq_codel_dequeue
>            -> qdidsc_tree_decrease_qlen
>              -> cl = htb_get # returns NULL, removed in htb_delete
>                -> htb_qlen_notify(sch, NULL) # BOOM
>
> This patch checks cl for 0 before invoking qlen_notify and put.  The notify
> is not necessary in this case, as the parent has already been deactivated
> anyway.
>

Hmm, but in htb_delete() we do reset the leaf qdisc before removing the
class from hash:

        if (!cl->level) {
                qlen = cl->un.leaf.q->q.qlen;
                qdisc_reset(cl->un.leaf.q);
                qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
        }

therefore, the leaf fq_codel qdisc is supposed to have 0 skb after that,
that is, the second fq_codel_reset() is supposed to return NULL immediately?
Why is qdidsc_tree_decrease_qlen() called in the second fq_codel_reset()?

Or there is a race condition between ->delete() and ->put()? In which new
skb can be enqueued?
