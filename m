From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] netlink: fix an use-after-free issue for nlk groups
Date: Mon, 11 Sep 2017 00:02:14 +1200
Message-ID: <CADvbK_d4nFCAGKdnRe7LC6zD8-Vh+imtB_fUvWEy44U97vEVSA@mail.gmail.com>
References: <1217baf9faf9d034ba8224cb6362b822c51a0eae.1504669632.git.lucien.xin@gmail.com>
 <CAM_iQpU_ve5fRGeYmBFfYc5DgDPk0sngku=3y1dOc8py4PDAfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>, chunwang@redhat.com,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35539 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751472AbdIJMCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 08:02:16 -0400
Received: by mail-qt0-f195.google.com with SMTP id l25so1208587qtf.2
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 05:02:15 -0700 (PDT)
In-Reply-To: <CAM_iQpU_ve5fRGeYmBFfYc5DgDPk0sngku=3y1dOc8py4PDAfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 9, 2017 at 9:56 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Sep 5, 2017 at 8:47 PM, Xin Long <lucien.xin@gmail.com> wrote:
>> ChunYu found a netlink use-after-free issue by syzkaller:
>>
>> [28448.842981] BUG: KASAN: use-after-free in __nla_put+0x37/0x40 at addr ffff8807185e2378
>> [28448.969918] Call Trace:
>> [...]
>> [28449.117207]  __nla_put+0x37/0x40
>> [28449.132027]  nla_put+0xf5/0x130
>> [28449.146261]  sk_diag_fill.isra.4.constprop.5+0x5a0/0x750 [netlink_diag]
>> [28449.176608]  __netlink_diag_dump+0x25a/0x700 [netlink_diag]
>> [28449.202215]  netlink_diag_dump+0x176/0x240 [netlink_diag]
>> [28449.226834]  netlink_dump+0x488/0xbb0
>> [28449.298014]  __netlink_dump_start+0x4e8/0x760
>> [28449.317924]  netlink_diag_handler_dump+0x261/0x340 [netlink_diag]
>> [28449.413414]  sock_diag_rcv_msg+0x207/0x390
>> [28449.432409]  netlink_rcv_skb+0x149/0x380
>> [28449.467647]  sock_diag_rcv+0x2d/0x40
>> [28449.484362]  netlink_unicast+0x562/0x7b0
>> [28449.564790]  netlink_sendmsg+0xaa8/0xe60
>> [28449.661510]  sock_sendmsg+0xcf/0x110
>> [28449.865631]  __sys_sendmsg+0xf3/0x240
>> [28450.000964]  SyS_sendmsg+0x32/0x50
>> [28450.016969]  do_syscall_64+0x25c/0x6c0
>> [28450.154439]  entry_SYSCALL64_slow_path+0x25/0x25
>>
>> It was caused by no protection between nlk groups' free in netlink_release
>> and nlk groups' accessing in sk_diag_dump_groups. The similar issue also
>> exists in netlink_seq_show().
>>
>> This patch is to defer nlk groups' free in deferred_put_nlk_sk.
>
> This looks odd too, at least not complete.
>
> The netlink sock itself is protected by RCU to speed up
> the lookup path, but not necessarily nlk->groups, at least
> I don't see rcu_dereference() in sk_diag_dump_groups().
> And netlink_realloc_groups() needs fix too, right? Otherwise
> krealloc() could reallocate a brand new memory and
> existing readers will crash too?
We knew it's not good, but this one is not so bad as the one in
netlink_release, as krealloc will not alloc new memory when
the new size < old size, so it may not cause crash.

I was planning to fix it as a long term. As you also said, here needs
more work for nlk->groups, including  proper RCU api for readers.
I will check more.

Thanks.

>
> I am afraid you need more work to make nlk->groups
> RCU friendly. RCU is not just about call_rcu(), both
> readers and writers need to use proper RCU API.
