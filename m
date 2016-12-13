From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: sctp: suspicious rcu_dereference_check() usage in
 sctp_epaddr_lookup_transport
Date: Tue, 13 Dec 2016 19:37:30 -0200
Message-ID: <20161213213730.GA4731@localhost.localdomain>
References: <CACT4Y+bEi6aXTTrk4P37hFnMdyte0voxUVdz8t0XQP95PgH9+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Xin Long <lucien.xin@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+bEi6aXTTrk4P37hFnMdyte0voxUVdz8t0XQP95PgH9+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 07:07:01PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I am getting the following reports while running syzkaller fuzzer:
> 
> [ INFO: suspicious RCU usage. ]
> 4.9.0+ #85 Not tainted
> -------------------------------
> ./include/linux/rhashtable.h:572 suspicious rcu_dereference_check() usage!
> 
> other info that might help us debug this:
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 1 lock held by syz-executor1/18023:
>  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<     inline     >] lock_sock
> include/net/sock.h:1454
>  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff87bb3ccf>]
> sctp_getsockopt+0x45f/0x6800 net/sctp/socket.c:6432
> 
> stack backtrace:
> CPU: 2 PID: 18023 Comm: syz-executor1 Not tainted 4.9.0+ #85
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
> [<     inline     >] __dump_stack lib/dump_stack.c:15
> [<        none        >] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
> [<        none        >] lockdep_rcu_suspicious+0x139/0x180
> kernel/locking/lockdep.c:4448
> [<     inline     >] __rhashtable_lookup ./include/linux/rhashtable.h:572
> [<     inline     >] rhltable_lookup ./include/linux/rhashtable.h:660
> [<        none        >] sctp_epaddr_lookup_transport+0x641/0x930
> net/sctp/input.c:946

I think this was introduced in the rhlist converstion. We had removed
some rcu_read_lock() calls on sctp stack because rhashtable was already
calling it, but then we didn't add them back when moving to rhlist.

This code:
+/* return a transport without holding it, as it's only used under sock lock */
 struct sctp_transport *sctp_epaddr_lookup_transport(
                                const struct sctp_endpoint *ep,
                                const union sctp_addr *paddr)
 {
        struct net *net = sock_net(ep->base.sk);
+       struct rhlist_head *tmp, *list;
+       struct sctp_transport *t;
        struct sctp_hash_cmp_arg arg = {
-               .ep    = ep,
                .paddr = paddr,
                .net   = net,
+               .lport = htons(ep->base.bind_addr.port),
        };
 
-       return rhashtable_lookup_fast(&sctp_transport_hashtable, &arg,
-                                     sctp_hash_params);
+       list = rhltable_lookup(&sctp_transport_hashtable, &arg,
+                              sctp_hash_params);

Had an implicit rcu_read_lock() on rhashtable_lookup_fast, but it
doesn't on rhltable_lookup and rhltable_lookup uses _rcu calls which
assumes we have rcu read protection.

  Marcelo
