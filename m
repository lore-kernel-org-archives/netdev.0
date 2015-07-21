From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH,v2 net] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Tue, 21 Jul 2015 06:04:41 -0400
Message-ID: <55AE1939.105@mojatatu.com>
References: <1437421248-2796139-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, kernel-team@fb.com,
	stable@vger.kernel.org
To: Alex Gartrell <agartrell@fb.com>, xiyou.wangcong@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33874 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbbGUKEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 06:04:44 -0400
Received: by wibud3 with SMTP id ud3so109533682wib.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 03:04:42 -0700 (PDT)
In-Reply-To: <1437421248-2796139-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/15 15:40, Alex Gartrell wrote:
> We have an application that invokes tc to delete the root every time the
> config changes. As a result we stress the cleanup code and were seeing the
> following panic:
>
>    crash> bt
>    PID: 630839  TASK: ffff8823c990d280  CPU: 14  COMMAND: "tc"
>     [... snip ...]
>     #8 [ffff8820ceec17a0] page_fault at ffffffff8160a8c2
>        [exception RIP: htb_qlen_notify+24]
>        RIP: ffffffffa0841718  RSP: ffff8820ceec1858  RFLAGS: 00010282
>        RAX: 0000000000000000  RBX: 0000000000000000  RCX: ffff88241747b400
>        RDX: ffff88241747b408  RSI: 0000000000000000  RDI: ffff8811fb27d000
>        RBP: ffff8820ceec1868   R8: ffff88120cdeff24   R9: ffff88120cdeff30
>        R10: 0000000000000bd4  R11: ffffffffa0840919  R12: ffffffffa0843340
>        R13: 0000000000000000  R14: 0000000000000001  R15: ffff8808dae5c2e8
>        ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>     #9 [...] qdisc_tree_decrease_qlen at ffffffff81565375
>    #10 [...] fq_codel_dequeue at ffffffffa084e0a0 [sch_fq_codel]
>    #11 [...] fq_codel_reset at ffffffffa084e2f8 [sch_fq_codel]
>    #12 [...] qdisc_destroy at ffffffff81560d2d
>    #13 [...] htb_destroy_class at ffffffffa08408f8 [sch_htb]
>    #14 [...] htb_put at ffffffffa084095c [sch_htb]
>    #15 [...] tc_ctl_tclass at ffffffff815645a3
>    #16 [...] rtnetlink_rcv_msg at ffffffff81552cb0
>    [... snip ...]
>
> To my understanding, the following situation is taking place.
>

>    tc_ctl_tclass

>     -> htb_delete
>       -> class is deleted from clhash
>     -> htb_put
>       -> qdisc_destroy
>         -> fq_codel_reset

=========> this part looks suspicious. Why is reset invoking
a dequeue? Shouldnt a destroy just purge the queue?

>           -> fq_codel_dequeue
>             -> qdidsc_tree_decrease_qlen
>               -> cl = htb_get # returns NULL, removed in htb_delete
>                 -> htb_qlen_notify(sch, NULL) # BOOM
>

It is worrisome to fix the core code for this. The root cause seems to
be codel. Dont have time but in general, reset would be something like:

struct fq_codel_sched_data *q = qdisc_priv(sch);
qdisc_reset(q)

or something along those lines...
But certainly dequeue semantics dont seem right there..

cheers,
jamal



cheers,
jamal
