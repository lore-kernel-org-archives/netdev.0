From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Get rid of RCU callbacks in TC filters?
Date: Wed, 18 Oct 2017 10:36:28 -0700
Message-ID: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:46976 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbdJRRgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:36:49 -0400
Received: by mail-pf0-f174.google.com with SMTP id p87so4470434pfj.3
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:36:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

Recently, the RCU callbacks used in TC filters and TC actions keep
drawing my attention, they introduce at least 4 race condition bugs:

1. A simple one fixed by Daniel:

commit c78e1746d3ad7d548bdf3fe491898cc453911a49
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Wed May 20 17:13:33 2015 +0200

    net: sched: fix call_rcu() race on classifier module unloads

2. A very nasty one fixed by me:

commit 1697c4bb5245649a23f06a144cc38c06715e1b65
Author: Cong Wang <xiyou.wangcong@gmail.com>
Date:   Mon Sep 11 16:33:32 2017 -0700

    net_sched: carefully handle tcf_block_put()

3. Two more bugs found by Chris:
https://patchwork.ozlabs.org/patch/826696/
https://patchwork.ozlabs.org/patch/826695/


Usually RCU callbacks are simple, however for TC filters and actions,
they are complex because at least TC actions could be destroyed
together with the TC filter in one callback. And RCU callbacks are
invoked in BH context, without locking they are parallel too. All of
these contribute to the cause of these nasty bugs. It looks like they
bring us more problems than benefits.

Therefore, I have been thinking about getting rid of these callbacks,
because they are not strictly necessary, callers of these call_rcu()
are all on slow path and have RTNL lock, so blocking is permitted in
their contexts, and _I think_ it does not harm to use
synchronize_rcu() on slow paths, at least I can argue RTNL lock is
already there and is a bottleneck if we really care. :)

There are 3 solutions here:

1) Get rid of these RCU callbacks and use synchronize_rcu(). The
downside is this could hurt the performance of deleting TC filters,
but again it is slow path comparing to skb classification path. Note,
it is _not_ merely replacing call_rcu() with synchronize_rcu(),
because many call_rcu()'s are actually in list iterations, we have to
use a local list and call list_del_rcu()+list_add() before
synchronize_rcu() (Or is there any other API I am not aware of?). If
people really hate synchronize_rcu() because of performance, we could
also defer the work to a workqueue and callers could keep their
performance as they are.

2) Introduce a spinlock to serialize these RCU callbacks. But as I
said in commit 1697c4bb5245 ("net_sched: carefully handle
tcf_block_put()"), it is very hard to do because of tcf_chain_dump().
Potentially we need to do a lot of work to make it possible, if not
impossible.

3) Keep these RCU callbacks and fix all race conditions. Like what
Chris tries to do in his patchset, but my argument is that we can not
prove we are really race-free even with Chris' patches and his patches
are already large enough.


What do you think? Any other ideas?

Thanks.
