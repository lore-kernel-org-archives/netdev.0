From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Mon, 3 Oct 2016 23:39:08 -0700
Message-ID: <20161004063908.GB2638@templeofstupid.com>
References: <20161002031349.GB2635@templeofstupid.com>
 <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:43597 "EHLO
        hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbcJDGjL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 02:39:11 -0400
Received: from homiemail-a81.g.dreamhost.com (sub5.mail.dreamhost.com [208.113.200.129])
        by hapkido.dreamhost.com (Postfix) with ESMTP id B6DEEE97F3
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:39:10 -0700 (PDT)
Received: from homiemail-a81.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a81.g.dreamhost.com (Postfix) with ESMTP id CE4E95A39
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:39:09 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a81.g.dreamhost.com (Postfix) with ESMTPSA id 90F905A35
        for <netdev@vger.kernel.org>; Mon,  3 Oct 2016 23:39:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

Thanks for the feedback.

On Mon, Oct 03, 2016 at 11:22:33AM -0700, Cong Wang wrote:
> On Sat, Oct 1, 2016 at 8:13 PM, Krister Johansen
> <kjlx@templeofstupid.com> wrote:
> > A tc_action_ops structure is visibile as soon as it is placed in the
> > act_base list.  When tcf_regsiter_action adds an item to this list and
> > drops act_mod_lock, registration is not complete until
> > register_pernet_subsys() finishes.
> 
> Hmm, good catch, but does the fix have to be so complicated?

There were two reasons that the patch I submitted was more complicated
than your proposal.  The first is simply my own lack of knowledge.  I
didn't see many other net subsystems that held locks across the call to
register_pernet_subsys().  I avoided doing so out of caution / paranoia.

The other reason for blocking if a register_pernet_subsys() was already
pending is the behavior of this code when the lookup fails.  The code in
tcf_action_init_1() calls request_module() when tc_lookup_action_n()
fails.  In the cases that I observed, this could lead to hundreds
modprobe processes running for essentially the same few modules.  Only
one of these calls will succeed.

Since the call to request_module() will sleep until the modprobe process
exits, it didn't seem unreasonable to block other threads in the same
code path.  Instead of blocking on a redundant modprobe call, it blocks
pending the completion of a modprobe that's already in progress.

I admit that the patch I submitted didn't close this window entirely,
but in the tests that I ran I was able to see the number of concurrent
modprobe processes go from dozens down to just a few.

> How about moving register_pernet_subsys() under act_mod_lock?
> Similar is needed for unregister too of course. This also means
> we need to convert act_mod_lock to a mutex which allows blocking.
> Fortunately, we don't have to take act_mod_lock in any atomic context.

If it's permissible to hold act_mod_lock across the call to
register_pernet_subsys, then perhaps this could instead be simplified to
use mutex_lock_interruptible() instead of RCU locking.  The blocking
lock would prevent other operations from triggering a modprobe until
the outstanding load completes.  However, the downside is that any
request_module() would block all other lookups.  My attempt to get
around that problem was to record on the action ops whether a pernet
operation was in progress.

> Please try the attached patch. I also convert the read path to RCU
> to avoid a possible deadlock. A quick test shows no lockdep splat.

I'll give it a try, but it may take me a few days to report back with
results.  In the meantime, let's try to reach consensus on an acceptable
solution.

Thanks again,

-K
