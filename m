From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Wed, 21 Dec 2016 21:02:51 +0100
Message-ID: <585ADFEB.3030206@iogearbox.net>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net> <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com> <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56985 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbcLUUC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 15:02:57 -0500
In-Reply-To: <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2016 08:10 PM, Cong Wang wrote:
> On Wed, Dec 21, 2016 at 10:51 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, Dec 21, 2016 at 9:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> What happens is that in tc_ctl_tfilter(), thread A allocates a new
>>> tp, initializes it, sets tp_created to 1, and calls into tp->ops->change()
>>> with it. In that classifier callback we had to unlock/lock the rtnl
>>> mutex and returned with -EAGAIN. One reason why we need to drop there
>>> is, for example, that we need to request an action module to be loaded.
>>
>> Excellent catch!
>>
>> But why do we have to replay the request here? Shouldn't we just return
>> EAGAIN to user-space and let user-space decide to retry or not?
>> Replaying is the root of the evil here.
>
> Answer myself: probably due to historical reasons, but still replaying
> inside such a big function is just error-prone, we should promote it
> out:

Have no strong opinion, I guess it could be done as a simplification
for net-next, why not, along with moving out the netlink_ns_capable()
check or possibly other things after careful analysis that don't need
to be redone in that circumstance.

Thanks,
Daniel
