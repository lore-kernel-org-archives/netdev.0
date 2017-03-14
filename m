From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Tue, 14 Mar 2017 10:44:10 +0100
Message-ID: <CACT4Y+YT6EZFtMTNywd4BtKyzWrJ9vtDU96TUFi9WLpypkgWhg@mail.gmail.com>
References: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
 <20170314091649.GA711@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:36571 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750895AbdCNJod (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 05:44:33 -0400
Received: by mail-vk0-f54.google.com with SMTP id t8so48909996vke.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 02:44:32 -0700 (PDT)
In-Reply-To: <20170314091649.GA711@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 10:16 AM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Sun, Mar 05, 2017 at 04:08:39PM +0100, Dmitry Vyukov wrote:
>>
>> -> #1 (genl_mutex){+.+.+.}:
>>        validate_chain kernel/locking/lockdep.c:2267 [inline]
>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
>>        __mutex_lock_common kernel/locking/mutex.c:756 [inline]
>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
>>        genl_lock net/netlink/genetlink.c:32 [inline]
>>        genl_lock_dumpit+0x41/0x90 net/netlink/genetlink.c:478
>>        netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
>>        __netlink_dump_start+0x4e5/0x760 net/netlink/af_netlink.c:2217
>>        genl_family_rcv_msg+0xd9d/0x1040 net/netlink/genetlink.c:546
>>        genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
>>        netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>>        genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
>>        netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>>        netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
>>        netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
>>        sock_sendmsg_nosec net/socket.c:633 [inline]
>>        sock_sendmsg+0xca/0x110 net/socket.c:643
>>        sock_write_iter+0x326/0x600 net/socket.c:846
>>        call_write_iter include/linux/fs.h:1733 [inline]
>>        new_sync_write fs/read_write.c:497 [inline]
>>        __vfs_write+0x483/0x740 fs/read_write.c:510
>>        vfs_write+0x187/0x530 fs/read_write.c:558
>>        SYSC_write fs/read_write.c:605 [inline]
>>        SyS_write+0xfb/0x230 fs/read_write.c:597
>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>>
>> -> #0 (nlk->cb_mutex){+.+.+.}:
>>        check_prev_add kernel/locking/lockdep.c:1830 [inline]
>>        check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1940
>>        validate_chain kernel/locking/lockdep.c:2267 [inline]
>>        __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
>>        lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
>>        __mutex_lock_common kernel/locking/mutex.c:756 [inline]
>>        __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
>>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
>>        __netlink_dump_start+0xf4/0x760 net/netlink/af_netlink.c:2187
>>        netlink_dump_start include/linux/netlink.h:165 [inline]
>>        crypto_user_rcv_msg+0x2ad/0x4f0 crypto/crypto_user.c:517
>>        netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>>        crypto_netlink_rcv+0x2a/0x40 crypto/crypto_user.c:538
>>        netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>>        netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
>>        netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
>>        sock_sendmsg_nosec net/socket.c:633 [inline]
>>        sock_sendmsg+0xca/0x110 net/socket.c:643
>>        ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
>>        __sys_sendmsg+0x138/0x300 net/socket.c:2019
>>        SYSC_sendmsg net/socket.c:2030 [inline]
>>        SyS_sendmsg+0x2d/0x50 net/socket.c:2026
>>        entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> This looks like a false positive.  The cb_mutex in #1 is not the
> same as the cb_mutex in #0.  The cb_mutex in #0 comes is obtained
> by crypto_user which uses straight netlink.  The cb_mutex in #1
> is a genl netlink socket.
>
> I'll have a look to see if we can annotate this.

Yes, please.
Disregarding some reports is not a good way long term.
