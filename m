From: Dmitry Vyukov <dvyukov@google.com>
Subject: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Sun, 5 Mar 2017 16:08:39 +0100
Message-ID: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am getting the following deadlock reports while running syzkaller
fuzzer on net-next/8d70eeb84ab277377c017af6a21d0a337025dede:

======================================================
[ INFO: possible circular locking dependency detected ]
4.10.0+ #5 Not tainted
-------------------------------------------------------
syz-executor6/6143 is trying to acquire lock:
 (nlk->cb_mutex){+.+.+.}, at: [<ffffffff837df634>]
__netlink_dump_start+0xf4/0x760 net/netlink/af_netlink.c:2187

but task is already holding lock:
 (crypto_alg_sem){+++++.}, at: [<ffffffff821cd1f6>]
crypto_user_rcv_msg+0x136/0x4f0 crypto/crypto_user.c:507

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #4 (crypto_alg_sem){+++++.}:
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       down_read+0x9b/0x150 kernel/locking/rwsem.c:23
       crypto_alg_lookup+0x23/0x50 crypto/api.c:199
       crypto_larval_lookup.part.10+0x9a/0x3b0 crypto/api.c:217
       crypto_larval_lookup crypto/api.c:211 [inline]
       crypto_alg_mod_lookup+0x77/0x1b0 crypto/api.c:270
       crypto_alloc_base+0x50/0x1e0 crypto/api.c:416
       crypto_alloc_cipher include/linux/crypto.h:1407 [inline]
       tcp_fastopen_reset_cipher+0xc2/0x2e0 net/ipv4/tcp_fastopen.c:48
       tcp_fastopen_init_key_once+0x114/0x120 net/ipv4/tcp_fastopen.c:29
       do_tcp_setsockopt.isra.36+0x140a/0x20a0 net/ipv4/tcp.c:2684
       tcp_setsockopt+0xb0/0xd0 net/ipv4/tcp.c:2733
       sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2731
       SYSC_setsockopt net/socket.c:1786 [inline]
       SyS_setsockopt+0x25c/0x390 net/socket.c:1765
       entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #3 (sk_lock-AF_INET){+.+.+.}:
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       lock_sock_nested+0xcb/0x120 net/core/sock.c:2536
       lock_sock include/net/sock.h:1460 [inline]
       rds_tcp_listen_stop+0x57/0x140 net/rds/tcp_listen.c:284
       rds_tcp_kill_sock net/rds/tcp.c:529 [inline]
       rds_tcp_dev_event+0x383/0xc50 net/rds/tcp.c:568
       notifier_call_chain+0x1b5/0x2b0 kernel/notifier.c:93
       __raw_notifier_call_chain kernel/notifier.c:394 [inline]
       raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
       call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1646
       call_netdevice_notifiers net/core/dev.c:1662 [inline]
       netdev_run_todo+0x3b2/0xa30 net/core/dev.c:7530
       rtnl_unlock+0xe/0x10 net/core/rtnetlink.c:104
       default_device_exit_batch+0x504/0x620 net/core/dev.c:8334
       ops_exit_list.isra.6+0x100/0x150 net/core/net_namespace.c:144
       cleanup_net+0x551/0xa90 net/core/net_namespace.c:463
       process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
       worker_thread+0x223/0x1990 kernel/workqueue.c:2230
       kthread+0x326/0x3f0 kernel/kthread.c:229
       ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430

-> #2 (rtnl_mutex){+.+.+.}:
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       __mutex_lock_common kernel/locking/mutex.c:756 [inline]
       __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
       mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
       rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
       tipc_nl_bearer_dump+0x3ef/0x720 net/tipc/bearer.c:774
       genl_lock_dumpit+0x68/0x90 net/netlink/genetlink.c:479
       netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
       __netlink_dump_start+0x4e5/0x760 net/netlink/af_netlink.c:2217
       genl_family_rcv_msg+0xd9d/0x1040 net/netlink/genetlink.c:546
       genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
       netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
       netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
       netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
       netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       sock_write_iter+0x326/0x600 net/socket.c:846
       call_write_iter include/linux/fs.h:1733 [inline]
       new_sync_write fs/read_write.c:497 [inline]
       __vfs_write+0x483/0x740 fs/read_write.c:510
       vfs_write+0x187/0x530 fs/read_write.c:558
       SYSC_write fs/read_write.c:605 [inline]
       SyS_write+0xfb/0x230 fs/read_write.c:597
       entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #1 (genl_mutex){+.+.+.}:
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       __mutex_lock_common kernel/locking/mutex.c:756 [inline]
       __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
       mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
       genl_lock net/netlink/genetlink.c:32 [inline]
       genl_lock_dumpit+0x41/0x90 net/netlink/genetlink.c:478
       netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
       __netlink_dump_start+0x4e5/0x760 net/netlink/af_netlink.c:2217
       genl_family_rcv_msg+0xd9d/0x1040 net/netlink/genetlink.c:546
       genl_rcv_msg+0xa6/0x140 net/netlink/genetlink.c:620
       netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:631
       netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
       netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
       netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       sock_write_iter+0x326/0x600 net/socket.c:846
       call_write_iter include/linux/fs.h:1733 [inline]
       new_sync_write fs/read_write.c:497 [inline]
       __vfs_write+0x483/0x740 fs/read_write.c:510
       vfs_write+0x187/0x530 fs/read_write.c:558
       SYSC_write fs/read_write.c:605 [inline]
       SyS_write+0xfb/0x230 fs/read_write.c:597
       entry_SYSCALL_64_fastpath+0x1f/0xc2

-> #0 (nlk->cb_mutex){+.+.+.}:
       check_prev_add kernel/locking/lockdep.c:1830 [inline]
       check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1940
       validate_chain kernel/locking/lockdep.c:2267 [inline]
       __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3340
       lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
       __mutex_lock_common kernel/locking/mutex.c:756 [inline]
       __mutex_lock+0x172/0x1730 kernel/locking/mutex.c:893
       mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
       __netlink_dump_start+0xf4/0x760 net/netlink/af_netlink.c:2187
       netlink_dump_start include/linux/netlink.h:165 [inline]
       crypto_user_rcv_msg+0x2ad/0x4f0 crypto/crypto_user.c:517
       netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
       crypto_netlink_rcv+0x2a/0x40 crypto/crypto_user.c:538
       netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
       netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
       netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
       sock_sendmsg_nosec net/socket.c:633 [inline]
       sock_sendmsg+0xca/0x110 net/socket.c:643
       ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
       __sys_sendmsg+0x138/0x300 net/socket.c:2019
       SYSC_sendmsg net/socket.c:2030 [inline]
       SyS_sendmsg+0x2d/0x50 net/socket.c:2026
       entry_SYSCALL_64_fastpath+0x1f/0xc2

other info that might help us debug this:

Chain exists of:
  nlk->cb_mutex --> sk_lock-AF_INET --> crypto_alg_sem

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(crypto_alg_sem);
                               lock(sk_lock-AF_INET);
                               lock(crypto_alg_sem);
  lock(nlk->cb_mutex);

 *** DEADLOCK ***

2 locks held by syz-executor6/6143:
 #0:  (crypto_cfg_mutex){+.+...}, at: [<ffffffff821cad9b>]
crypto_netlink_rcv+0x1b/0x40 crypto/crypto_user.c:537
 #1:  (crypto_alg_sem){+++++.}, at: [<ffffffff821cd1f6>]
crypto_user_rcv_msg+0x136/0x4f0 crypto/crypto_user.c:507

stack backtrace:
CPU: 0 PID: 6143 Comm: syz-executor6 Not tainted 4.10.0+ #5
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
 __netlink_dump_start+0xf4/0x760 net/netlink/af_netlink.c:2187
 netlink_dump_start include/linux/netlink.h:165 [inline]
 crypto_user_rcv_msg+0x2ad/0x4f0 crypto/crypto_user.c:517
 netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
 crypto_netlink_rcv+0x2a/0x40 crypto/crypto_user.c:538
 netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
 netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
 netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
 __sys_sendmsg+0x138/0x300 net/socket.c:2019
 SYSC_sendmsg net/socket.c:2030 [inline]
 SyS_sendmsg+0x2d/0x50 net/socket.c:2026
 entry_SYSCALL_64_fastpath+0x1f/0xc2
