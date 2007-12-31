From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Mon, 31 Dec 2007 14:17:13 +0100
Message-ID: <64bb37e0712310517v5f9546a8o9f30b644660aef39@mail.gmail.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	 <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <20071230212443.GA23320@fieldses.org>
	 <64bb37e0712301335k3ae8c0car1fa9b34034f9df0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	netdev@vger.kernel.org, "Tom Tucker" <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:17075 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbXLaNRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 08:17:15 -0500
Received: by py-out-1112.google.com with SMTP id u52so9001913pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 05:17:14 -0800 (PST)
In-Reply-To: <64bb37e0712301335k3ae8c0car1fa9b34034f9df0e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 30, 2007 10:35 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> On Dec 30, 2007 10:24 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > From:   Tom Tucker <tom@opengridcomputing.com>
> > Date:   Sun, 30 Dec 2007 10:07:17 -0600
> >
> > Bruce/Aime:
> >
> > Here is what I believe to be the fix for the crashes/svc_xprt BUG_ON
> > that people are seeing. It would be great if those who have seen this
> > problem could apply this patch and see if it resolves their problem.
> >
> > The common code calls svc_xprt_received on behalf of the transport.
> > Since the provider was calling it as well, this resulted in clearing the
> > busy bit/resetting xpt_pool when the BUSY bit wasn't held.
> >
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 4628881..4d39db1 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1272,7 +1272,6 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
> >
> >         if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
> >                 svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
> > -               svc_xprt_received(&svsk->sk_xprt);
> >                 return (struct svc_xprt *)svsk;
> >         }
>
> I will send a mail, when I'm done with testing this...

Removing this line from 2.6.24-rc3-mm2 does not solve my crash
FYI the codepart from net/sunrpc/svcsock.c / svc_create_socket() where
I removed this:
        if (protocol == IPPROTO_TCP) {
                if ((error = kernel_listen(sock, 64)) < 0)
                        goto bummer;
        }

        if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
                memcpy(&svsk->sk_xprt.xpt_local, newsin, newlen);
                //svc_xprt_received(&svsk->sk_xprt);
                return (struct svc_xprt *)svsk;
        }

bummer:
        dprintk("svc: svc_create_socket error = %d\n", -error);


The crash itself:
[11166.565362] ------------[ cut here ]------------
[11166.568595] kernel BUG at lib/list_debug.c:33!
[11166.571696] invalid opcode: 0000 [1] SMP
[11166.574527] last sysfs file:
/sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
[11166.580017] CPU 3
[11166.581442] Modules linked in: radeon drm nfsd exportfs w83792d
ipv6 tuner tea5767 tda8290 tuner_xc2
028 tda9887 tuner_simple mt20xx tea5761 tvaudio msp3400 bttv ir_common
compat_ioctl32 videobuf_dma_sg v
ideobuf_core btcx_risc tveeprom videodev usbhid v4l2_common hid
v4l1_compat sg pata_amd i2c_nforce2
[11166.600470] Pid: 5548, comm: nfsv4-svc Not tainted 2.6.24-rc3-mm2 #3
[11166.604912] RIP: 0010:[<ffffffff803bae54>]  [<ffffffff803bae54>]
__list_add+0x54/0x60
[11166.610408] RSP: 0000:ffff81007d83fdc0  EFLAGS: 00010282
[11166.614144] RAX: 0000000000000088 RBX: ffff81007f2e0400 RCX: 0000000000000002
[11166.619113] RDX: ffff81007dc6eed0 RSI: 0000000000000001 RDI: ffffffff807590c0
[11166.624130] RBP: ffff81007d83fdc0 R08: 0000000000000001 R09: 0000000000000000
[11166.629124] R10: ffff810080058d48 R11: 0000000000000001 R12: ffff81007e444680
[11166.634129] R13: ffff81007e4446b8 R14: ffff81007e4446b8 R15: ffff81011ff50100
[11166.639128] FS:  00007fb815abc6f0(0000) GS:ffff81011ff13280(0000)
knlGS:0000000000000000
[11166.644786] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[11166.648809] CR2: 0000000000441770 CR3: 0000000000201000 CR4: 00000000000006e0
[11166.653796] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[11166.658784] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[11166.663783] Process nfsv4-svc (pid: 5548, threadinfo
FFFF81007D83E000, task FFFF81007DC6EED0)
[11166.669776] Stack:  ffff81007d83fe00 ffffffff805be25e
ffff81007e444688 ffff81011ff50100
[11166.675428]  ffff81007f2e0400 ffff81007dd62000 ffff81010a138000
ffff81011ff50110
[11166.680660]  ffff81007d83fe10 ffffffff805be357 ffff81007d83fee0
ffffffff805bf09c
[11166.685744] Call Trace:
[11166.687592]  [<ffffffff805be25e>] svc_xprt_enqueue+0x1ae/0x250
[11166.691672]  [<ffffffff805be357>] svc_xprt_received+0x17/0x20
[11166.695700]  [<ffffffff805bf09c>] svc_recv+0x39c/0x840
[11166.699299]  [<ffffffff805bea2f>] svc_send+0xaf/0xd0
[11166.702755]  [<ffffffff8022f590>] default_wake_function+0x0/0x10
[11166.706983]  [<ffffffff803163ea>] nfs_callback_svc+0x7a/0x130
[11166.710992]  [<ffffffff805cfe92>] trace_hardirqs_on_thunk+0x35/0x3a
[11166.715377]  [<ffffffff80259f8f>] trace_hardirqs_on+0xbf/0x160
[11166.719454]  [<ffffffff8020cbc8>] child_rip+0xa/0x12
[11166.722919]  [<ffffffff8020c2df>] restore_args+0x0/0x30
[11166.726578]  [<ffffffff80316370>] nfs_callback_svc+0x0/0x130
[11166.730540]  [<ffffffff8020cbbe>] child_rip+0x0/0x12
[11166.734024]
[11166.735072] INFO: lockdep is turned off.
[11166.737843]
[11166.737844] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16 48 89 e5 e8
[11166.744160] RIP  [<ffffffff803bae54>] __list_add+0x54/0x60
[11166.748015]  RSP <ffff81007d83fdc0>
[11166.750464] Kernel panic - not syncing: Aiee, killing interrupt handler!
-> then the system hung, no "---[ end trace xyz ]---"-output

Will it make a difference if I try it in -rc6-mm1?

Torsten
