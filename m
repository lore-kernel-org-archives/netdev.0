From: Daniel Borkmann <daniel@iogearbox.net>
Subject: matchall race (was: Re: [PATCH net-next] net/sched: cls_flower: verify
 root pointer before dereferncing it)
Date: Fri, 25 Nov 2016 10:43:39 +0100
Message-ID: <583807CB.4000503@iogearbox.net>
References: <58346C7B.7090006@iogearbox.net> <20161122161159.GC1819@nanopsycho> <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com> <20161124.152546.1174938340314080043.davem@davemloft.net> <58378309.2090101@iogearbox.net> <CAM_iQpU=t-APBrPuW1K1FdRW8J9UydkbD9Y4h1eD_SU3yK=wvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
        Roi Dayan <roid@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39013 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcKYJnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:43:47 -0500
In-Reply-To: <CAM_iQpU=t-APBrPuW1K1FdRW8J9UydkbD9Y4h1eD_SU3yK=wvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Making this a different thread, since unrelated to the other one. ]

On 11/25/2016 07:23 AM, Cong Wang wrote:
> On Thu, Nov 24, 2016 at 4:17 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
[...]
>>
>> (Btw, matchall is still broken besides this fix. mall_delete() sets the
>>   RCU_INIT_POINTER(head->filter, NULL), so that a mall_delete() plus
>>   mall_destroy() combo doesn't free head->filter twice, but doing that is
>>   racy with mall_classify() where head->filter is dereferenced unchecked.
>>   Requires additional fix.)
>
> This seems due to matchall only has one filter per tp. But you don't need
> to worry since readers never read a freed pointer, right?

The race would be that CPU0 is in tc_ctl_tfilter() with RTM_DELTFILTER and
tcm_handle = 1 request. matchall has only single handle and id of it is 1
(or a prior user-specified one). So in tc_ctl_tfilter() ->get() will find it,
returns pointer as fh. Then we call ->delete(). mall_delete() sets head->filter
to NULL with RCU_INIT_POINTER() (head->filter is not even an RCU pointer btw),
real filter destruction comes via call_rcu(). If we got here, that tp is still
visible and not unlinked from tp chain. So in CPU1 tc_classify() executes
mall_classify(), we fetch the head (tp->root) and the corresponding head->filter
from there, and dereference it next. Probably best would have been to just
return -EOPNOTSUPP for ->delete() like in cls_cgroup case. It probably makes
sense to just defer real destruction to mall_destroy() instead of mall_delete()
if one wants to avoid extra !f test in mall_classify().
