From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 29 Nov 2016 11:48:59 -0500
Message-ID: <20161129164859.GD26673@madcap2.tricolour.ca>
References: <CACT4Y+aG1+91U1PWMTwpE_6vbEuqG7CdLCM1H=3WVJWtz=>
 <CAM_iQpVeLvfYV+1jX1ZKOntZim4roof4=>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpVeLvfYV+1jX1ZKOntZim4roof4=>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-11-26 17:11, Cong Wang wrote:
> On Sat, Nov 26, 2016 at 7:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > Hello,

Eric, thanks for the heads up on this.  (more below...)

> > The following program triggers GPF in sock_sndtimeo:
> > https://gist.githubusercontent.com/dvyukov/c19cadd309791cf5cb9b2bf936d3f48d/raw/1743ba0211079a5465d039512b427bc6b59b1a76/gistfile1.txt
> >
> > On commit 16ae16c6e5616c084168740990fc508bda6655d4 (Nov 24).
> >
> > general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 1 PID: 19950 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > task: ffff88002a0d0840 task.stack: ffff880036920000
> > RIP: 0010:[<ffffffff86cb35e1>]  [<     inline     >] sock_sndtimeo
> > include/net/sock.h:2075
> > RIP: 0010:[<ffffffff86cb35e1>]  [<ffffffff86cb35e1>]
> > netlink_unicast+0xe1/0x730 net/netlink/af_netlink.c:1232
> > RSP: 0018:ffff880036926f68  EFLAGS: 00010202
> > RAX: 0000000000000068 RBX: ffff880036927000 RCX: ffffc900021d0000
> > RDX: 0000000000000d63 RSI: 00000000024000c0 RDI: 0000000000000340
> > RBP: ffff880036927028 R08: ffffed0006ea7aab R09: ffffed0006ea7aab
> > R10: 0000000000000001 R11: ffffed0006ea7aaa R12: dffffc0000000000
> > R13: 0000000000000000 R14: ffff880035de3400 R15: ffff880035de3400
> > FS:  00007f90a2fc7700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 00000000006de0c0 CR3: 0000000035de6000 CR4: 00000000000006e0
> > Stack:
> >  ffff880035de3400 ffffffff819f02a1 1ffff10006d24df4 0000000000000004
> >  00004db400000014 ffff880036926fd8 ffffffff00000000 0000000041b58ab3
> >  ffffffff89653c11 ffffffff86cb3500 ffffffff819f0345 ffff880035de3400
> > Call Trace:
> >  [<     inline     >] audit_replace kernel/audit.c:817
> >  [<ffffffff816c34b9>] audit_receive_msg+0x22c9/0x2ce0 kernel/audit.c:894
> >  [<     inline     >] audit_receive_skb kernel/audit.c:1120
> >  [<ffffffff816c40ac>] audit_receive+0x1dc/0x360 kernel/audit.c:1133
> >  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
> >  [<ffffffff86cb3a14>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1240
> >  [<ffffffff86cb46d4>] netlink_sendmsg+0xaa4/0xe50 net/netlink/af_netlink.c:1786
> >  [<     inline     >] sock_sendmsg_nosec net/socket.c:621
> >  [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
> >  [<ffffffff86a6d8bb>] sock_write_iter+0x32b/0x620 net/socket.c:829
> >  [<     inline     >] new_sync_write fs/read_write.c:499
> >  [<ffffffff81a6f24e>] __vfs_write+0x4fe/0x830 fs/read_write.c:512
> >  [<ffffffff81a70cf5>] vfs_write+0x175/0x4e0 fs/read_write.c:560
> >  [<     inline     >] SYSC_write fs/read_write.c:607
> >  [<ffffffff81a75180>] SyS_write+0x100/0x240 fs/read_write.c:599
> >  [<ffffffff81009a24>] do_syscall_64+0x2f4/0x940 arch/x86/entry/common.c:280
> >  [<ffffffff88149e8d>] entry_SYSCALL64_slow_path+0x25/0x25
> > Code: fe 4c 89 f7 e8 31 16 ff ff 8b 8d 70 ff ff ff 49 89 c7 31 c0 85
> > c9 75 25 e8 7d 4a a3 fa 49 8d bd 40 03 00 00 48 89 f8 48 c1 e8 03 <42>
> > 80 3c 20 00 0f 85 3a 06 00 00 49 8b 85 40 03 00 00 4c 8d 73
> > RIP  [<     inline     >] sock_sndtimeo include/net/sock.h:2075
> > RIP  [<ffffffff86cb35e1>] netlink_unicast+0xe1/0x730
> > net/netlink/af_netlink.c:1232
> >  RSP <ffff880036926f68>
> > ---[ end trace 8383a15fba6fdc59 ]---
> 
> It is racy on audit_sock, especially on the netns exit path.

I think that is the only place it is racy.  The other places audit_sock
is set is when the socket failure has just triggered a reset.

Is there a notifier callback for failed or reaped sockets?

> Could the following patch help a little bit? Also, I don't see how the
> synchronize_net() here could sync with netlink rcv path, since unlike
> packets from wire, netlink messages are not handled in BH context
> nor I see any RCU taken on rcv path.

Thanks Cong, this looks like it could help.  I'll have a closer look.

> diff --git a/kernel/audit.c b/kernel/audit.c
> index f1ca116..20bc79e 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -1167,10 +1167,13 @@ static void __net_exit audit_net_exit(struct net *net)
>  {
>         struct audit_net *aunet = net_generic(net, audit_net_id);
>         struct sock *sock = aunet->nlsk;
> +
> +       mutex_lock(&audit_cmd_mutex);
>         if (sock == audit_sock) {
>                 audit_pid = 0;
>                 audit_sock = NULL;
>         }
> +       mutex_unlock(&audit_cmd_mutex);
> 
>         RCU_INIT_POINTER(aunet->nlsk, NULL);
>         synchronize_net();

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
