From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Tue, 14 Mar 2017 11:25:19 -0400
Message-ID: <20170314152519.GA21159@oracle.com>
References: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
 <CACT4Y+bJ1-d3DhCvzEN0PeDd7+P2LNgjF2NHwALXBubOKaOEsw@mail.gmail.com>
 <CACT4Y+YhLM0CetOZn6uXwyBBGM_oVsW-CC3NMg8A5K0xd3F2mA@mail.gmail.com>
 <CACT4Y+YTBPDMOZGMLuZPaQhSFXbeQeahHc8BUDOgNYm6hRy6fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>, santosh.shilimkar@oracle.com,
        rds-devel@oss.oracle.com, syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+YTBPDMOZGMLuZPaQhSFXbeQeahHc8BUDOgNYm6hRy6fw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (03/14/17 09:14), Dmitry Vyukov wrote:
> Another one now involving rds_tcp_listen_stop
   :
> kworker/u4:1/19 is trying to acquire lock:
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8409a6ec>] lock_sock
> include/net/sock.h:1460 [inline]
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8409a6ec>]
> rds_tcp_listen_stop+0x5c/0x150 net/rds/tcp_listen.c:288
> 
> but task is already holding lock:
>  (rtnl_mutex){+.+.+.}, at: [<ffffffff8370b057>] rtnl_lock+0x17/0x20
> net/core/rtnetlink.c:70

Is this also a false positive?

genl_lock_dumpit takes the genl_lock and then waits on the rtnl_lock
(e.g., out of tipc_nl_bearer_dump).

netdev_run_todo takes the rtnl_lock and then wants lock_sock()
for the TCP/IPv4 socket. 

Why is lockdep seeing a circular dependancy here? Same pattern
seems to be happening  for 
  http://www.spinics.net/lists/netdev/msg423368.html
and maybe also http://www.spinics.net/lists/netdev/msg423323.html?

--Sowmini

> Chain exists of:
>   sk_lock-AF_INET --> genl_mutex --> rtnl_mutex
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(rtnl_mutex);
>                                lock(genl_mutex);
>                                lock(rtnl_mutex);
>   lock(sk_lock-AF_INET);
> 
>  *** DEADLOCK ***
> 
> 4 locks held by kworker/u4:1/19:
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
> __write_once_size include/linux/compiler.h:283 [inline]
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] atomic64_set
> arch/x86/include/asm/atomic64_64.h:33 [inline]
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] atomic_long_set
> include/asm-generic/atomic-long.h:56 [inline]
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>] set_work_data
> kernel/workqueue.c:617 [inline]
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
> set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
>  #0:  ("%s""netns"){.+.+.+}, at: [<ffffffff81497943>]
> process_one_work+0xab3/0x1c10 kernel/workqueue.c:2089
>  #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff81497997>]
> process_one_work+0xb07/0x1c10 kernel/workqueue.c:2093
>  #2:  (net_mutex){+.+.+.}, at: [<ffffffff836965cb>]
> cleanup_net+0x22b/0xa90 net/core/net_namespace.c:429
>  #3:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8370b057>]
> rtnl_lock+0x17/0x20 net/core/rtnetlink.c:70
> 
