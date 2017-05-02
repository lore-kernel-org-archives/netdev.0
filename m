From: Mike Manning <mmanning@brocade.com>
Subject: Re: net/ipv6: warning in inet6_ifa_finish_destroy
Date: Tue, 2 May 2017 15:04:50 +0100
Message-ID: <3f99a46a-1d5d-bd29-486a-135614f1b689@brocade.com>
References: <CAAeHK+y7z7PyCSqfdbRsEFS3wQ-Wwa8eQ7T=AexDZUSVrisVDA@mail.gmail.com>
 <CAM_iQpUTx_nDtZ63TRVGnqu5L33NzTE8XFMjaxSD_i4ghGFQ7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58708 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750952AbdEBOF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 10:05:59 -0400
In-Reply-To: <CAM_iQpUTx_nDtZ63TRVGnqu5L33NzTE8XFMjaxSD_i4ghGFQ7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/04/17 21:39, Cong Wang wrote:
> On Fri, Apr 28, 2017 at 6:08 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while fuzzing the kernel with syzkaller.
>>
>> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
>>
>> C reproducer and .config are attached.
>> It takes 1-2 minutes of running the reproducer to trigger the issue.
>>
>> ------------[ cut here ]------------
>> WARNING: CPU: 0 PID: 21 at net/ipv6/addrconf.c:894
>> inet6_ifa_finish_destroy+0x12e/0x190
>> Modules linked in:
>> CPU: 0 PID: 21 Comm: kworker/0:1 Not tainted 4.11.0-rc8+ #296
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Workqueue: ipv6_addrconf addrconf_dad_work
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16
>>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>>  __warn+0x19f/0x1e0 kernel/panic.c:549
>>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>>  inet6_ifa_finish_destroy+0x12e/0x190 c:894
>>  in6_ifa_put ./include/net/addrconf.h:330
>>  addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963
> 
> 
> I don't look too much, but a quick glance shows in the following
> path:
> 
>         } else if (action == DAD_ABORT) {
>                 in6_ifa_hold(ifp);
>                 addrconf_dad_stop(ifp, 1);
>                 if (disable_ipv6)
>                         addrconf_ifdown(idev->dev, 0);
>                 goto out;
>         }
> 
> the inet6_addr could be removed from hash table in
> addrconf_ifdown() before calling in6_ifa_put(). which causes
> this warning.
> 

git describe 85b51b12115c79cce7ea1ced6c0bd0339a165d3f --contains
v4.8-rc5~34^2~32

This fix was introduced in 4.8, so it is interesting that this problem is only showing up now for 4.11. Also, it is not reproducible manually, i.e. DAD failure with disable_ipv6 works just fine without triggering this warning, with or without keeping IPv6 addresses on admin down.

I will go ahead with putting out a fix so that in6_ifa_put() precedes the call to addrconf_ifdown() in this case.

Thanks for the heads up on this,
Mike
