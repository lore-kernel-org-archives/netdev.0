From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Possible DEADLOCK in rtnl_lock(v4.1.40)
Date: Wed, 21 Jun 2017 13:03:43 -0700
Message-ID: <CAM_iQpU1SVtQZpXdSJ9FKOweeiOR3B1SoESv4g=SZL16tAa2LQ@mail.gmail.com>
References: <CAJsXRPFnNA30Y5V+XN=1kM9jEDqNr0VkAf0-oAEr-kDBNk5FTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Vladislav Yasevich <vyasevich@gmail.com>, bblanco@plumgrid.com,
        moshe@mellanox.com, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dison River <pwn2river@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJsXRPFnNA30Y5V+XN=1kM9jEDqNr0VkAf0-oAEr-kDBNk5FTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jun 21, 2017 at 2:22 AM, Dison River <pwn2river@gmail.com> wrote:
> Hi:
>     I've got the following error report while fuzzing the kernel with
> syzkaller on v4.1.40
>
>
> Syzkaller hit 'possible deadlock in rtnl_lock' bug on commit .
>
> The guilty file is: /home/river/git_new/linux-stable/net/core/rtnetlink.c.
>
>
> ======================================================
> [ INFO: possible circular locking dependency detected ]
> 4.1.40 #4 Not tainted
> -------------------------------------------------------
> syz-executor1/4765 is trying to acquire lock:
>  (rtnl_mutex){+.+.+.}, at: [<ffffffff82734b62>] rtnl_lock+0x12/0x20
> /home/river/git_new/linux-stable/net/core/rtnetlink.c:70
>
> but task is already holding lock:
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff82848a75>] lock_sock
> /home/river/git_new/linux-stable/include/net/sock.h:1497 [inline]
>  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff82848a75>]
> do_ip_getsockopt.part.9+0xf5/0x1210
> /home/river/git_new/linux-stable/net/ipv4/ip_sockglue.c:1270
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
>        [<ffffffff811da5dd>] lock_acquire+0x13d/0x4d0
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:3623
>        [<ffffffff826ab259>] lock_sock_nested+0xb9/0x110
> /home/river/git_new/linux-stable/net/core/sock.c:2376
>        [<ffffffff8284ad8f>] lock_sock
> /home/river/git_new/linux-stable/include/net/sock.h:1497 [inline]
>        [<ffffffff8284ad8f>] do_ip_setsockopt.isra.12+0x15f/0x24f0
> /home/river/git_new/linux-stable/net/ipv4/ip_sockglue.c:622
>        [<ffffffff8284d14f>] ip_setsockopt+0x2f/0xb0
> /home/river/git_new/linux-stable/net/ipv4/ip_sockglue.c:1200
>        [<ffffffff826a95a3>] sock_common_setsockopt+0x73/0xf0
> /home/river/git_new/linux-stable/net/core/sock.c:2575
>        [<ffffffff826a6910>] SYSC_setsockopt
> /home/river/git_new/linux-stable/net/socket.c:1761 [inline]
>        [<ffffffff826a6910>] SyS_setsockopt+0x130/0x200
> /home/river/git_new/linux-stable/net/socket.c:1740
>        [<ffffffff82eb9fd7>] system_call_fastpath+0x12/0x6f
>
>        [<ffffffff811d6c91>] check_prev_add
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:1853
> [inline]
>        [<ffffffff811d6c91>] check_prevs_add
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:1958
> [inline]
>        [<ffffffff811d6c91>] validate_chain
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:2144
> [inline]
>        [<ffffffff811d6c91>] __lock_acquire+0x3551/0x51f0
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:3205
>        [<ffffffff811da5dd>] lock_acquire+0x13d/0x4d0
> /home/river/git_new/linux-stable/kernel/locking/lockdep.c:3623
>        [<ffffffff82eb0e50>] __mutex_lock_common
> /home/river/git_new/linux-stable/kernel/locking/mutex.c:521 [inline]
>        [<ffffffff82eb0e50>] mutex_lock_nested+0xc0/0x9c0
> /home/river/git_new/linux-stable/kernel/locking/mutex.c:620
>        [<ffffffff82734b62>] rtnl_lock+0x12/0x20
> /home/river/git_new/linux-stable/net/core/rtnetlink.c:70
>        [<ffffffff8294598d>] ip_mc_msfget+0xdd/0x5b0


Do you have this fix in your kernel?

commit 87e9f0315952b0dd8b5e51ba04beda03efc009d9
Author: WANG Cong <xiyou.wangcong@gmail.com>
Date:   Tue Nov 3 15:41:16 2015 -0800

    ipv4: fix a potential deadlock in mcast getsockopt() path
