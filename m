From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Sun, 27 Nov 2016 18:57:38 -0800
Message-ID: <583B9D22.8090906@gmail.com>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roid@mellanox.com, jiri@mellanox.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36040 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753944AbcK1C65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:58:57 -0500
Received: by mail-pg0-f42.google.com with SMTP id f188so51405183pgc.3
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:58:19 -0800 (PST)
In-Reply-To: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-23 05:58 PM, Cong Wang wrote:
> Roi reported we could have a race condition where in ->classify() path
> we dereference tp->root and meanwhile a parallel ->destroy() makes it
> a NULL.
> 
> This is possible because ->destroy() could be called when deleting
> a filter to check if we are the last one in tp, this tp is still
> linked and visible at that time.
> 
> The root cause of this problem is the semantic of ->destroy(), it
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
> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> Reported-by: Roi Dayan <roid@mellanox.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Hi Cong,

Thanks a lot for doing this. Can you rebase it on top of Daniel's patch
though,

 [PATCH net] net, sched: respect rcu grace period on cls destruction

And then push the NULL pointer work for the cls_fw and cls_route
classifiers into another patch.

Then I believe the last thing to make this correct is to convert the
call_rcu() paths to call_rcu_bh().

.John
