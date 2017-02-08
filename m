From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/xfrm: use of uninit spinlock in xfrm_policy_flush
Date: Wed, 8 Feb 2017 11:24:21 +0100
Message-ID: <CACT4Y+Yd3zgOgtsAjdsREY3vm=bCNif-keYgvFeWGMckWrrjEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am getting the following reports while running syzkaller fuzzer on
linux-next e3e6c5f3544c5d05c6b3b309a34f4f2c3537e993:

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 0 PID: 13059 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170207 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 register_lock_class+0x1a5b/0x1bf0 kernel/locking/lockdep.c:738
 __lock_acquire+0x215/0x3430 kernel/locking/lockdep.c:3233
 lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 __raw_spin_lock_bh include/linux/spinlock_api_smp.h:135 [inline]
 _raw_spin_lock_bh+0x3a/0x50 kernel/locking/spinlock.c:175
 spin_lock_bh include/linux/spinlock.h:304 [inline]
 xfrm_policy_flush+0x32/0x470 net/xfrm/xfrm_policy.c:963
 xfrm_policy_fini+0xbf/0x560 net/xfrm/xfrm_policy.c:3041
 xfrm_net_init+0x79f/0x9e0 net/xfrm/xfrm_policy.c:3091
 ops_init+0x10a/0x530 net/core/net_namespace.c:115
 setup_net+0x2ed/0x690 net/core/net_namespace.c:291
 copy_net_ns+0x26c/0x530 net/core/net_namespace.c:396
 create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
 unshare_nsproxy_namespaces+0xae/0x1e0 kernel/nsproxy.c:205
 SYSC_unshare kernel/fork.c:2281 [inline]
 SyS_unshare+0x64e/0xfc0 kernel/fork.c:2231
 entry_SYSCALL_64_fastpath+0x1f/0xc2

Not sure if the memory under net->xfrm.xfrm_policy_lock is zeroed,
because otherwise it can easily lead to a lockup. The locks should
probably be initialized first in xfrm_net_init.
