From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: __udp4_lib_rcv: inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W}
 usage.
Date: Sun, 15 Dec 2013 09:49:59 -0800
Message-ID: <1387129799.19078.197.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131215063925.GC26348@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131215063925.GC26348@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-12-15 at 14:39 +0800, Fengguang Wu wrote:
> Greetings,
> 
> I got the below dmesg and the first bad commit is
> 
> commit 975022310233fb0f0193873d79a7b8438070fa82
> Author:     Eric Dumazet <edumazet@google.com>
> AuthorDate: Wed Dec 11 14:46:51 2013 -0800
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Wed Dec 11 20:21:10 2013 -0500
> 
>     udp: ipv4: must add synchronization in udp_sk_rx_dst_set()
>     
>     Unlike TCP, UDP input path does not hold the socket lock.
>     
>     Before messing with sk->sk_rx_dst, we must use a spinlock, otherwise
>     multiple cpus could leak a refcount.
>     
>     This patch also takes care of renewing a stale dst entry.
>     (When the sk->sk_rx_dst would not be used by IP early demux)
>     
>     Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> +----------------------------------------------+----+
> |                                              |    |
> +----------------------------------------------+----+
> | boot_successes                               | 0  |
> | boot_failures                                | 19 |
> | inconsistent_SOFTIRQ-ON-W-IN-SOFTIRQ-W_usage | 19 |
> +----------------------------------------------+----+
> 
> [   23.564204] [ INFO: inconsistent lock state ]
> [   23.564204] 3.13.0-rc3-00689-gb1daf37 #892 Not tainted
> [   23.564204] ---------------------------------
> [   23.564204] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> [   23.564204] swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   23.564204]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<ffffffff81a27fe2>] __udp4_lib_rcv+0x569/0x79d
> [   23.564204] {SOFTIRQ-ON-W} state was registered at:
> [   23.564204]   [<ffffffff810b16b7>] __lock_acquire+0x96c/0x185f
> [   23.564204]   [<ffffffff810b2c97>] lock_acquire+0xab/0x12e
> [   23.564204]   [<ffffffff81af12d3>] _raw_spin_lock+0x3b/0x6d
> [   23.564204]   [<ffffffff81a2f13d>] inet_bind+0x18d/0x1dc
> [   23.564204]   [<ffffffff8199d62c>] kernel_bind+0x10/0x12
> [   23.564204]   [<ffffffff81aae764>] xs_bind+0xa0/0x11e
> [   23.564204]   [<ffffffff81ab0271>] xs_create_sock.isra.14+0x20b/0x230
> [   23.564204]   [<ffffffff81ab047f>] xs_tcp_setup_socket+0x5f/0x3e5
> [   23.564204]   [<ffffffff8108a0d7>] process_one_work+0x247/0x443
> [   23.564204]   [<ffffffff8108aeac>] worker_thread+0x1d2/0x2bc
> [   23.564204]   [<ffffffff81090228>] kthread+0xf9/0x101
> [   23.564204]   [<ffffffff81af92fc>] ret_from_fork+0x7c/0xb0

Oh well, I'll post a fix, thanks !

As David suggested, we can use xchg() here anyway, instead of trying to
share the spinlock for the two inet dst.
