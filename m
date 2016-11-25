From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Thu, 24 Nov 2016 22:23:54 -0800
Message-ID: <CAM_iQpU=t-APBrPuW1K1FdRW8J9UydkbD9Y4h1eD_SU3yK=wvw@mail.gmail.com>
References: <58346C7B.7090006@iogearbox.net> <20161122161159.GC1819@nanopsycho>
 <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
 <20161124.152546.1174938340314080043.davem@davemloft.net> <58378309.2090101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
        Roi Dayan <roid@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34701 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbcKYGZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 01:25:50 -0500
Received: by mail-io0-f179.google.com with SMTP id c21so105895423ioj.1
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 22:24:15 -0800 (PST)
In-Reply-To: <58378309.2090101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 4:17 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>
> I'm not sure if setting a dummy object for each affected classifier is
> making things better. Are you having this in mind as a target for -net?
>
> We do kfree_rcu() the head (tp->root) and likewise do we kfree_rcu() the
> tp immediately after the callback. The head object's lifetime for such
> classifiers is thus always bound to the tp lifetime. And besides that,
> nothing apart from get() checks whether it's actually really NULL (and
> that check in get() is odd anyway; some cls do it, some don't).
>

Excellent point.

I thought we should exclude any parallel readers when we call destroy(),
you are taking a different approach by observing we only have to exclude
readers when we really free them, this seems fine to me after a second
thought, because the RCU API should take care of races with readers so
as long as we free everything in RCU callback we are good. Hmm...

But I may miss something since I am not an RCU expert.

[...]
>
> (Btw, matchall is still broken besides this fix. mall_delete() sets the
>  RCU_INIT_POINTER(head->filter, NULL), so that a mall_delete() plus
>  mall_destroy() combo doesn't free head->filter twice, but doing that is
>  racy with mall_classify() where head->filter is dereferenced unchecked.
>  Requires additional fix.)

This seems due to matchall only has one filter per tp. But you don't need
to worry since readers never read a freed pointer, right?
