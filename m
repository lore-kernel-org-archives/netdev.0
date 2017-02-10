From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Thu, 09 Feb 2017 19:19:25 -0800
Message-ID: <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
         <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        philip.pettersson@gmail.com, weongyo.linux@gmail.com,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-02-09 at 17:24 -0800, Cong Wang wrote:
> On Thu, Feb 9, 2017 at 5:14 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Hello,
> >
> > I've got the following use-after-free report in packet_rcv_fanout
> > while running syzkaller fuzzer on linux-next
> > e3e6c5f3544c5d05c6b3b309a34f4f2c3537e993. So far it happened once and
> > is not reproducible, but maybe the stacks will allow you to figure out
> > what happens.
> >
> > BUG: KASAN: use-after-free in __lock_acquire+0x3212/0x3430
> > kernel/locking/lockdep.c:3224 at addr ffff8801d903d538
> > Read of size 8 by task syz-executor1/10596
> > CPU: 1 PID: 10596 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170208 #1
> > Hardware name: Google Google Compute Engine/Google Compute Engine,
> > BIOS Google 01/01/2011
> >
> > Call Trace:
> >  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
> >  __lock_acquire+0x3212/0x3430 kernel/locking/lockdep.c:3224
> >  lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> >  __raw_spin_lock_bh include/linux/spinlock_api_smp.h:135 [inline]
> >  _raw_spin_lock_bh+0x3a/0x50 kernel/locking/spinlock.c:175
> >  spin_lock_bh include/linux/spinlock.h:304 [inline]
> >  packet_rcv_has_room+0x25/0xb0 net/packet/af_packet.c:1308
> >  fanout_demux_rollover+0x3bb/0x6b0 net/packet/af_packet.c:1388
> >  packet_rcv_fanout+0x674/0x800 net/packet/af_packet.c:1490
> >  dev_queue_xmit_nit+0x73a/0xa90 net/core/dev.c:1898
> >  xmit_one net/core/dev.c:2870 [inline]
> >  dev_hard_start_xmit+0x16b/0xab0 net/core/dev.c:2890
> >  __dev_queue_xmit+0x16d1/0x1e60 net/core/dev.c:3355
> >  dev_queue_xmit+0x17/0x20 net/core/dev.c:3388
> >  neigh_hh_output include/net/neighbour.h:468 [inline]
> >  dst_neigh_output include/net/dst.h:452 [inline]
> >  ip6_finish_output2+0x1461/0x2380 net/ipv6/ip6_output.c:123
> >  ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:149
> >  NF_HOOK_COND include/linux/netfilter.h:246 [inline]
> >  ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
> >  ip6_xmit+0xc2f/0x1e80 include/net/dst.h:498
> >  inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:139
> >  tcp_transmit_skb+0x1ab4/0x3460 net/ipv4/tcp_output.c:1054
> >  tcp_send_syn_data net/ipv4/tcp_output.c:3343 [inline]
> >  tcp_connect+0x11a7/0x2f50 net/ipv4/tcp_output.c:3375
> >  tcp_v6_connect+0x1a6e/0x1f70 net/ipv6/tcp_ipv6.c:295
> >  __inet_stream_connect+0x2d1/0xf80 net/ipv4/af_inet.c:618
> >  tcp_sendmsg_fastopen net/ipv4/tcp.c:1110 [inline]
> >  tcp_sendmsg+0x23ac/0x3bd0 net/ipv4/tcp.c:1133
> >  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
> >  sock_sendmsg_nosec net/socket.c:633 [inline]
> >  sock_sendmsg+0xca/0x110 net/socket.c:643
> >  SYSC_sendto+0x660/0x810 net/socket.c:1685
> >  SyS_sendto+0x40/0x50 net/socket.c:1653
> >  entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> It seems on-flying packets could still refer the struct sock pointer
> via f->arr[i], if so we need a sync before unlinking it:
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index d56ee46..8724a98 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2924,6 +2924,8 @@ static int packet_release(struct socket *sock)
>         sock_prot_inuse_add(net, sk->sk_prot, -1);
>         preempt_enable();
> 
> +       synchronize_net();
> +
>         spin_lock(&po->bind_lock);
>         unregister_prot_hook(sk, false);
>         packet_cached_dev_reset(po);

More likely the bug is in fanout_add(), with a buggy sequence in error
case, and not correct locking.

kfree(po->rollover);
po->rollover = NULL;

Two cpus entering fanout_add() (using the same af_packet socket,
syzkaller courtesy...) might both see po->fanout being NULL.

Then they grab the mutex.  Too late...
