From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: net/ipv4: use-after-free in ipv4_mtu
Date: Wed, 05 Apr 2017 12:59:29 -0600
Message-ID: <df3240d8a5a341f1c13db6708e4bd52f@codeaurora.org>
References: <CAAeHK+zJ20r8O=MhPY69UPK7sObODp2ByK5136JXgw5U9SMofw@mail.gmail.com>
 <CANn89iKuT+VBZqbJ4=hTAgUbnhuZ0berg0PK+imd1CKuWLy1eQ@mail.gmail.com>
 <CAM_iQpUittpMt-8BpNePWv7iTDasCZuNYTEPnu=K-4sFK5qiBg@mail.gmail.com>
 <1491360338.10124.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491360338.10124.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Interesting. I might had too many beers tonight, but ...
> 
> refcount was removed in 2860583fe840 many months later
> 
> -static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
> -{
> -       if (fi->fib_metrics != (u32 *) dst_default_metrics) {
> -               rt->fi = fi;
> -               atomic_inc(&fi->fib_clntref);
> -       }
> -       dst_init_metrics(&rt->dst, fi->fib_metrics, true);
> -}
> -
>  static struct fib_nh_exception *find_exception(struct fib_nh *nh,
> __be32 daddr)
>  {
>         struct fnhe_hash_bucket *hash = nh->nh_exceptions;
> @@ -1261,7 +1239,7 @@ static void rt_set_nexthop(struct rtable *rt,
> __be32 daddr,
>                         rt->rt_gateway = nh->nh_gw;
>                 if (unlikely(fnhe))
>                         rt_bind_exception(rt, fnhe, daddr);
> -               rt_init_metrics(rt, fi);
> +               dst_init_metrics(&rt->dst, fi->fib_metrics, true);
>  #ifdef CONFIG_IP_ROUTE_CLASSID
>                 rt->dst.tclassid = nh->nh_tclassid;
>  #endif

Hi Eric

I encountered a crash on 4.4 kernel pointing to ipv4_mtu.
Is the crash similar to this one?
(target is ARM64 Android, was seen on a stability rack, so no reproducer
unfortunately)

<6> Kernel BUG at 00000000000005dc [verbose debug info unavailable]
<6> Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
<6> CPU: 1 PID: 4649 Comm: iperf Tainted: G        W  O    4.4.21+ #1
<6> task: ffffffef02242f00 ti: ffffffef021b8000 task.ti: 
ffffffef021b8000
<2> PC is at 0x5dc
<2> LR is at ipv4_mtu+0x70/0x84
<2> pc : [<00000000000005dc>] lr : [<ffffff9bd2c35ab8>] pstate: a0000145
<2> sp : ffffffef021bb9b0
<2> x29: ffffffef021bb9b0 x28: 0000000000000000
<2> x27: ffffffef318122c0 x26: 00000000000005be
<2> x25: ffffffef31812678 x24: ffffffef31812678
<2> x23: ffffffef8794c000 x22: ffffff9bd43f4380
<2> x21: ffffffef318122c0 x20: ffffffef6aef6ac0
<2> x19: ffffffef05026ac0 x18: 0000000001026749
<2> x17: 0000007fabaf145c x16: ffffff9bd1fe72bc
<2> x15: 00368fbefea52a8e x14: 3736353433323130
<2> x13: 3938373635343332 x12: 0000000000000003
<2> x11: 0000000000000028 x10: 0101010101010101
<2> x9 : 0000000000000001 x8 : 0000000000000098
<2> x7 : ffffff9bd2c8cbc0 x6 : 0000000000000000
<2> x5 : ffffffef68481c00 x4 : 00000000ffffefbf
<2> x3 : 0000000000000000 x2 : 0000000000000000
<2> x1 : 000000000000ef7f x0 : 0000000001280058
<2>
LR: 0xffffff9bd2c35a78:
<2> 5a78  b7f80241 f9401661 927ef421 b9400422 2a0203e0 350001a2 f9400e60 
b9400021
<2> 5a98  b9422800 361000c1 39428e61 34000081 7109001f 52804801 1a819000 
529fffe1
<2> 5ab8  6b01001f 1a819000 f9400bf3 a8c27bfd d65f03c0 a9ba7bfd 910003fd 
a90153f3
<2> 5ad8  a9025bf5 a90363f7 a9046bf9 aa0003f3 aa1e03e0 f9002fa1 2a0203f8 
2a0303f9
<2>
SP: 0xffffffef021bb970:
<2> b970  d2c35ab8 ffffff9b 021bb9b0 ffffffef 000005dc 00000000 a0000145 
00000000
<2> b990  6aef6ac0 ffffffef 6aef6ac0 ffffffef 00000000 00000080 d2c015b0 
ffffff9b
<2> b9b0  021bb9d0 ffffffef d2c3e4d4 ffffff9b 6aef6ac0 ffffffef 021bba18 
ffffffef
<2> b9d0  021bba20 ffffffef d2c3f05c ffffff9b d37d9418 ffffff9b 6aef6ac0 
ffffffef
<2>
<6> Process iperf (pid: 4649, stack limit = 0xffffffef021b8020)
<2> Call trace:
<2> [<00000000000005dc>] 0x5dc
<2> [<ffffff9bd2c3e4d4>] ip_finish_output+0xbc/0x1dc
<2> [<ffffff9bd2c3f05c>] ip_output+0xe8/0x15c
<2> [<ffffff9bd2c3e78c>] ip_local_out+0x58/0x68
<2> [<ffffff9bd2c3fa88>] ip_send_skb+0x2c/0xa8
<2> [<ffffff9bd2c643d0>] udp_send_skb+0x194/0x29c
<2> [<ffffff9bd2c66584>] udp_sendmsg+0x4e0/0x700
<2> [<ffffff9bd2c70788>] inet_sendmsg+0x98/0xc8
<2> [<ffffff9bd2ba82e8>] sock_sendmsg+0x48/0x60
<2> [<ffffff9bd2ba8394>] sock_write_iter+0x94/0xc0
<2> [<ffffff9bd1fe61c8>] __vfs_write+0xc0/0xf0
<2> [<ffffff9bd1fe6abc>] vfs_write+0xb8/0x150
<2> [<ffffff9bd1fe7314>] SyS_write+0x58/0x94
<2> [<ffffff9bd1e84e30>] el0_svc_naked+0x24/0x28
<6> Code: bad PC value
<6> ---[ end trace debf337ba02da94f ]---
<6> Kernel panic - not syncing: Fatal exception

--
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora 
Forum,
a Linux Foundation Collaborative Project
