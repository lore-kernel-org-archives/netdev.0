From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sch_htb: fix crash on init failure
Date: Tue, 29 Aug 2017 11:09:56 -0700
Message-ID: <1504030196.11498.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32861 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbdH2SJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:09:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id m15so3278581pgc.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:09:59 -0700 (PDT)
In-Reply-To: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 20:58 +0300, Nikolay Aleksandrov wrote:
> The commit below added a call to the ->destroy() callback for all qdiscs
> which failed in their ->init(), but some were not prepared for such
> change and can't handle partially initialized qdisc. HTB is one of them
> and if any error occurs before the qdisc watchdog timer and qdisc work are
> initialized then we can hit either a null ptr deref (timer->base) when
> canceling in ->destroy or lockdep error info about trying to register
> a non-static key and a stack dump. So to fix these two move the watchdog
> timer and workqueue init before anything that can err out.
> To reproduce userspace needs to send broken htb qdisc create request,
> tested with a modified tc (q_htb.c).

> Note that probably this bug goes further back because the default qdisc
> handling always calls ->destroy on init failure too.
> 
> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Always calling qdisc destroy on init failure in the default qdisc handling
> was added in commit 0fbbeb1ba43b. I'm not sure if I should include that
> one as fixes tag.

Well, we probably need to audit init/destroy not only in net/sched, but
other parts of networking stack.

What about the qdisc_skb_head_init(&q->direct_queue) call ?

I am surprised you do not crash in __skb_queue_purge(&q->direct_queue);
