From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Mon, 27 Mar 2017 14:42:41 +0200
Message-ID: <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
 <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com> <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:35386 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751973AbdC0MnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 08:43:18 -0400
Received: by mail-vk0-f54.google.com with SMTP id r69so49540198vke.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 05:43:17 -0700 (PDT)
In-Reply-To: <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 8, 2017 at 12:55 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Mar 7, 2017 at 9:00 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Tue, Mar 7, 2017 at 8:30 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>>> On 3/7/17 11:13 AM, Dmitry Vyukov wrote:
>>>>>>> on this warning:
>>>>>>>
>>>>>>> /* dst.next really should not be set at this point */
>>>>>>> if (rt->dst.next && rt->dst.next->ops->family != AF_INET6) {
>>>>>>>         pr_warn("fib6_add: adding rt with bad next -- family %d dst
>>>>>>> flags %x\n",
>>>>>>>                 rt->dst.next->ops->family, rt->dst.next->flags);
>>>>>>>
>>>>>>>         WARN_ON(1);
>>>>>>> }
>>>>>>>
>>>>>>> You should have seen the pr_warn in the log preceding the WARN_ON dump.
>>>>>>
>>>>>> Right. They all have the same "IPv6: fib6_add: adding rt with bad next
>>>>>> -- family 2 dst flags 6"
>>>>>
>>>>> remove the previous changes and try the attached.
>>>>
>>>>
>>>> Doing this now.
>>>> FWIW I've also applied your last patch with missing "iter->dst.flags
>>>> &= ~DST_IN_FIB;" and restored the warning in rt6_rcu_free and it did
>>>> not fire (in a limited run). I only saw the "WARNING in fib6_add" that
>>>> I already reported.
>>>
>>>
>>> So far I've hit only:
>>> [ 1103.840031] BUG: KASAN: slab-out-of-bounds in fib6_age+0x3fd/0x480
>>> at addr ffff8800799d2254
>>> without any preceeding warnings.
>>> But note that since the kernel is heavily stressed I can reliably get
>>> any pr_err output if it happens right before BUG/WARNING. Anything
>>> that happens minutes before will be lots because there are tons of
>>> output.
>>
>>
>>
>> So far 6 "KASAN: slab-out-of-bounds Read in fib6_age" but no other warnings.
>
>
> I've got a bunch of the crashes that I was getting previously, but no
> new warnings.



A friendly ping. This still happens all the time for us.

I also see the following warning, not sure if it's related or not:

on 0dc82fa59b9d82469799c354d3307d48e13d5d5e:

#if RT6_DEBUG >= 2
        if (rt->dst.obsolete > 0) {
                WARN_ON(fn);
                return -ENOENT;
        }
#endif

------------[ cut here ]------------
WARNING: CPU: 1 PID: 23535 at net/ipv6/ip6_fib.c:1472
fib6_del+0x923/0x14d0 net/ipv6/ip6_fib.c:1472
CPU: 1 PID: 23535 Comm: syz-executor3 Not tainted 4.11.0-rc3+ #517
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:52
 panic+0x1fb/0x412 kernel/panic.c:180
 __warn+0x1c4/0x1e0 kernel/panic.c:541
 warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
 fib6_del+0x923/0x14d0 net/ipv6/ip6_fib.c:1472
 __ip6_del_rt+0x100/0x160 net/ipv6/route.c:2153
 ip6_del_rt+0x140/0x1b0 net/ipv6/route.c:2166
 __ipv6_ifa_notify+0x269/0x780 net/ipv6/addrconf.c:5506
 ipv6_ifa_notify+0xdf/0x1d0 net/ipv6/addrconf.c:5518
 ipv6_del_addr+0x62b/0xa80 net/ipv6/addrconf.c:1175
 inet6_addr_del+0x348/0x5b0 net/ipv6/addrconf.c:2853
 addrconf_del_ifaddr+0x154/0x1e0 net/ipv6/addrconf.c:2898
 inet6_ioctl+0x86/0x1e0 net/ipv6/af_inet6.c:525
 sock_do_ioctl+0x65/0xb0 net/socket.c:906
 sock_ioctl+0x2c2/0x440 net/socket.c:1004
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x44fb79
RSP: 002b:00007f4b299bfb58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000008936 RCX: 000000000044fb79
RDX: 0000000020000000 RSI: 0000000000008936 RDI: 000000000000001a
RBP: 000000000000001a R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000708000
R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000000
