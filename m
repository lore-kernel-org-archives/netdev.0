From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v3] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Tue, 18 Apr 2017 08:51:11 -0400
Message-ID: <366f3cf6-208a-375a-d6b9-5ccb4d1b78a3@mojatatu.com>
References: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Lucas Bates <lucasb@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33406 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752891AbdDRMvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 08:51:15 -0400
Received: by mail-io0-f169.google.com with SMTP id k87so165103933ioi.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 05:51:15 -0700 (PDT)
In-Reply-To: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-17 02:30 PM, Cong Wang wrote:
> Roi reported we could have a race condition where in ->classify() path
> we dereference tp->root and meanwhile a parallel ->destroy() makes it
> a NULL.
>
> This is possible because ->destroy() could be called when deleting
> a filter to check if we are the last one in tp, this tp is still
> linked and visible at that time.
>
> Daniel fixed this in commit d936377414fa
> ("net, sched: respect rcu grace period on cls destruction"), but
> the root cause of this problem is the semantic of ->destroy(), it
> does two things (for non-force case):
>
> 1) check if tp is empty
> 2) if tp is empty we could really destroy it
>
> and its caller, if cares, needs to check its return value to see if
> it is really destroyed. Therefore we can't unlink tp unless we know
> it is empty.
>
> As suggested by Daniel, we could actually move the test logic to ->delete()
> so that we can safely unlink tp after ->delete() tells us the last one is
> just deleted and before ->destroy().
>
> What's more, even we unlink it before ->destroy(), it could still have
> readers since we don't wait for a grace period here, we should not modify
> tp->root in ->destroy() either.
>
> Reported-by: Roi Dayan <roid@mellanox.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks good to me, Daniel?

Also - if we are not in a hurry could I/Lucas (and maybe Roi) be given 
the  chance to test it?

cheers,
jamal
