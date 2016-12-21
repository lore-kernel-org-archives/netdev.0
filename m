From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Wed, 21 Dec 2016 12:47:22 -0800
Message-ID: <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
 <CAM_iQpXadrGWJYqizEkq+xmMKVV9krrcCWKur=ZCRZBS9Mx_8w@mail.gmail.com>
 <CAM_iQpX3Sk_YGDmvY-yj0CxPbG5qfT7P7ioNgY5Lb_DqsTWh6Q@mail.gmail.com> <585ADFEB.3030206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33146 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753885AbcLUUro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 15:47:44 -0500
Received: by mail-qk0-f195.google.com with SMTP id n21so10351836qka.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 12:47:43 -0800 (PST)
In-Reply-To: <585ADFEB.3030206@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 12:02 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 12/21/2016 08:10 PM, Cong Wang wrote:
>>
>> On Wed, Dec 21, 2016 at 10:51 AM, Cong Wang <xiyou.wangcong@gmail.com>
>> wrote:
>>>
>>> On Wed, Dec 21, 2016 at 9:04 AM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>>
>>>> What happens is that in tc_ctl_tfilter(), thread A allocates a new
>>>> tp, initializes it, sets tp_created to 1, and calls into
>>>> tp->ops->change()
>>>> with it. In that classifier callback we had to unlock/lock the rtnl
>>>> mutex and returned with -EAGAIN. One reason why we need to drop there
>>>> is, for example, that we need to request an action module to be loaded.
>>>
>>>
>>> Excellent catch!
>>>
>>> But why do we have to replay the request here? Shouldn't we just return
>>> EAGAIN to user-space and let user-space decide to retry or not?
>>> Replaying is the root of the evil here.
>>
>>
>> Answer myself: probably due to historical reasons, but still replaying
>> inside such a big function is just error-prone, we should promote it
>> out:
>
>
> Have no strong opinion, I guess it could be done as a simplification
> for net-next, why not, along with moving out the netlink_ns_capable()
> check or possibly other things after careful analysis that don't need
> to be redone in that circumstance.

It is only slightly bigger than your current one so could fit for -stable too.
Also, it could fix all potential problems like this one. Let compiler do the
work, not human. ;)
