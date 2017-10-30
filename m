From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Mon, 30 Oct 2017 16:12:39 -0700
Message-ID: <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com> <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:51444 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753131AbdJ3XNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 19:13:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id n14so12218401pfh.8
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 16:13:00 -0700 (PDT)
In-Reply-To: <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 3:39 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
> e.On Thu, Oct 26, 2017 at 9:24 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Recently, the RCU callbacks used in TC filters and TC actions keep
>> drawing my attention, they introduce at least 4 race condition bugs:
> <snip>
>> As suggested by Paul, we could defer the work to a workqueue and
>> gain the permission of holding RTNL again without any performance
>> impact, however, in tcf_block_put() we could have a deadlock when
>> flushing workqueue while hodling RTNL lock, the trick here is to
>> defer the work itself in workqueue and make it queued after all
>> other works so that we keep the same ordering to avoid any
>> use-after-free. Please see the first patch for details.
>
> Cong, I don't believe the problem's been resolved just yet....  I have
> a new kernel, compiled just today and I'm still tripping over a kernel
> bug in this scenario when I run Chris' new test case.
>

Without a stack trace, I can't do anything. "a kernel bug" could
be anything, why do you believe it is caused by this patchset?

Note, there is a use-after-free bug caused by this patchset, the
fix is already on netdev in case you hit the same bug.

> I'm doing this on a machine where I don't have a spare device to use
> on the run. Instead I created a veth pair that will have one end
> migrated into the container.
>
> The bug isn't consistent. I'm running into it anywhere between one and
> four runs of the d052 test case.
>
> Steps to reproduce:
>
> sudo ip li add foo type veth
> sudo ./tdc.py -d foo -c flower
> [repeat until kernel bug encountered]

I tested with basic and u32 filter, since it is not specific to any type
of filters, all filters had the same problem. I will try flower filter too
before you provide a stack trace or a detailed report.
