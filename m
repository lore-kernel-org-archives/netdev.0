From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Wed, 15 Mar 2017 10:08:20 +0100
Message-ID: <CACT4Y+a+SHMAB=xsMahgawEsQKRNVp0dgc6v3pv=TADqADsLpA@mail.gmail.com>
References: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
 <CACT4Y+bJ1-d3DhCvzEN0PeDd7+P2LNgjF2NHwALXBubOKaOEsw@mail.gmail.com>
 <CACT4Y+YhLM0CetOZn6uXwyBBGM_oVsW-CC3NMg8A5K0xd3F2mA@mail.gmail.com>
 <CACT4Y+YTBPDMOZGMLuZPaQhSFXbeQeahHc8BUDOgNYm6hRy6fw@mail.gmail.com> <20170314152519.GA21159@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>, santosh.shilimkar@oracle.com,
        rds-devel@oss.oracle.com, syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:35183 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbdCOJIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 05:08:43 -0400
Received: by mail-vk0-f47.google.com with SMTP id x75so5188500vke.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 02:08:42 -0700 (PDT)
In-Reply-To: <20170314152519.GA21159@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 4:25 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/14/17 09:14), Dmitry Vyukov wrote:
>> Another one now involving rds_tcp_listen_stop
>    :
>> kworker/u4:1/19 is trying to acquire lock:
>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8409a6ec>] lock_sock
>> include/net/sock.h:1460 [inline]
>>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8409a6ec>]
>> rds_tcp_listen_stop+0x5c/0x150 net/rds/tcp_listen.c:288
>>
>> but task is already holding lock:
>>  (rtnl_mutex){+.+.+.}, at: [<ffffffff8370b057>] rtnl_lock+0x17/0x20
>> net/core/rtnetlink.c:70
>
> Is this also a false positive?
>
> genl_lock_dumpit takes the genl_lock and then waits on the rtnl_lock
> (e.g., out of tipc_nl_bearer_dump).
>
> netdev_run_todo takes the rtnl_lock and then wants lock_sock()
> for the TCP/IPv4 socket.
>
> Why is lockdep seeing a circular dependancy here? Same pattern
> seems to be happening  for
>   http://www.spinics.net/lists/netdev/msg423368.html
> and maybe also http://www.spinics.net/lists/netdev/msg423323.html?
>
> --Sowmini
>
>> Chain exists of:
>>   sk_lock-AF_INET --> genl_mutex --> rtnl_mutex
>>
>>  Possible unsafe locking scenario:
>>
>>        CPU0                    CPU1
>>        ----                    ----
>>   lock(rtnl_mutex);
>>                                lock(genl_mutex);
>>                                lock(rtnl_mutex);
>>   lock(sk_lock-AF_INET);
>>
>>  *** DEADLOCK ***
>>
>> 4 locks held by kworker/u4:1/19:
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
>> __write_once_size include/linux/compiler.h:283 [inline]
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] atomic64_set
>> arch/x86/include/asm/atomic64_64.h:33 [inline]
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] atomic_long_set
>> include/asm-generic/atomic-long.h:56 [inline]
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] set_work_data
>> kernel/workqueue.c:617 [inline]
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
>> set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
>>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
>> process_one_work+0xab3/0x1c10 kernel/workqueue.c:2089
>>  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff81497997>]
>> process_one_work+0xb07/0x1c10 kernel/workqueue.c:2093
>>  #2:  (net_mutex){+.+.+.}, at: [<ffffffff836965cb>]
>> cleanup_net+0x22b/0xa90 net/core/net_namespace.c:429
>>  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8370b057>]
>> rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70



After I've applied the patch these reports stopped to happen, and I
have not seem any other reports that look relevant.
However, it there was one, but it looks like a different issue and it
was probably masked by massive amounts of original deadlock reports:


[ INFO: possible circular locking dependency detected ]
4.10.0+ #29 Not tainted
-------------------------------------------------------
syz-executor5/29222 is trying to acquire lock:
 (genl_mutex){+.+.+.}, at: [<ffffffff837ea67e>] genl_lock
net/netlink/genetlink.c:32 [inline]
 (genl_mutex){+.+.+.}, at: [<ffffffff837ea67e>]
genl_family_rcv_msg+0xdae/0x1040 net/netlink/genetlink.c:547

but task is already holding lock:
 (rtnl_mutex){+.+.+.}, at: [<ffffffff8370a057>] rtnl_lock+0x17/0x20
net/core/rtnetlink.c:70

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (rtnl_mutex){+.+.+.}:
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       __mutex_lock_common kernel/locking/mutex.c:756 [inline]
       __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
       mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
       rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
       nl80211_dump_wiphy+0x45/0x6d0 net/wireless/nl80211.c:1946
       genl_lock_dumpit+0x68/0x90 net/netlink/genetlink.c:479
       netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2168
       __netlink_dump_start+0x4e5/0x760 net/netlink/af_netlink.c:2258
       genl_family_rcv_msg+0xd9d/0x1040 net/netlink/genetlink.c:546
       genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
       netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2339
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
       netlink_unicast_kernel net/netlink/af_netlink.c:1272 [inline]
       netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1298
       netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1844
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
       __sys_sendmsg+0x138/0x300 net/socket.c:2019
       SYSC_sendmsg net/socket.c:2030 [inline]
       SyS_sendmsg+0x2d/0x50 net/socket.c:2026
       do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
       return_from_SYSCALL_64+0x0/0x7a

-> #0 (genl_mutex){+.+.+.}:
       check_prev_add kernel/locking/lockdep.c:1830 [inline]
       check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1940
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       __mutex_lock_common kernel/locking/mutex.c:756 [inline]
       __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
       mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
       genl_lock net/netlink/genetlink.c:32 [inline]
       genl_family_rcv_msg+0xdae/0x1040 net/netlink/genetlink.c:547
       genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
       netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2339
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
       netlink_unicast_kernel net/netlink/af_netlink.c:1272 [inline]
       netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1298
       netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1844
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       sock_write_iter+0x326/0x600 net/socket.c:846
       call_write_iter include/linux/fs.h:1733 [inline]
       new_sync_write fs/read_write.c:497 [inline]
       __vfs_write+0x483/0x740 fs/read_write.c:510
       vfs_write+0x187/0x530 fs/read_write.c:558
       SYSC_write fs/read_write.c:605 [inline]
       SyS_write+0xfb/0x230 fs/read_write.c:597
       do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
       return_from_SYSCALL_64+0x0/0x7a

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(rtnl_mutex);
                               lock(genl_mutex);
                               lock(rtnl_mutex);
  lock(genl_mutex);

 *** DEADLOCK ***

2 locks held by syz-executor5/29222:
 #0:  (cb_lock){++++++}, at: [<ffffffff837e98a9>] genl_rcv+0x19/0x40
net/netlink/genetlink.c:630
 #1:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8370a057>]
rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70

stack backtrace:
CPU: 1 PID: 29222 Comm: syz-executor5 Not tainted 4.10.0+ #29
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:52
 print_circular_bug+0x307/0x3b0 kernel/locking/lockdep.c:1204
 check_prev_add kernel/locking/lockdep.c:1830 [inline]
 check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1940
 validate_chain kernel/locking/lockdep.c:2267 [inline]
 __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
 lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
 __mutex_lock_common kernel/locking/mutex.c:756 [inline]
 __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
 mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
 genl_lock net/netlink/genetlink.c:32 [inline]
 genl_family_rcv_msg+0xdae/0x1040 net/netlink/genetlink.c:547
 genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
 netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2339
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
 netlink_unicast_kernel net/netlink/af_netlink.c:1272 [inline]
 netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1298
 netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1844
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 sock_write_iter+0x326/0x600 net/socket.c:846
 call_write_iter include/linux/fs.h:1733 [inline]
 new_sync_write fs/read_write.c:497 [inline]
 __vfs_write+0x483/0x740 fs/read_write.c:510
 vfs_write+0x187/0x530 fs/read_write.c:558
 SYSC_write fs/read_write.c:605 [inline]
 SyS_write+0xfb/0x230 fs/read_write.c:597
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:281
 entry_SYSCALL64_slow_path+0x25/0x25
