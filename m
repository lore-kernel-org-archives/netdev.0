From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 06:35:04 -0500
Message-ID: <1265110504.2861.135.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:49517 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab0BBLfX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 06:35:23 -0500
In-Reply-To: <1265108690.2861.118.camel@tonnant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-02 at 06:04 -0500, Jon Masters wrote:
> On Mon, 2010-02-01 at 16:02 +0100, Eric Dumazet wrote:
> > Le lundi 01 f=C3=A9vrier 2010 =C3=A0 16:58 +0200, Alexey Dobriyan a=
 =C3=A9crit :
> > > On Mon, Feb 1, 2010 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> > > > +       net->ct.nf_conntrack_cachep =3D kmem_cache_create("nf_c=
onntrack",
> > > > +                                                       sizeof(=
struct nf_conn), 0,
> > > > +                                                       SLAB_DE=
STROY_BY_RCU, NULL);
> > >=20
> > > Duplicate slab name detected.
> > >=20
> >=20
> > OK, need to build an unique name I guess... "nf_conntrack-%d", net-=
>id
>=20
> I shoved in an kasprintf but of course there isn't a per-namespace "i=
d".
> We probably should have one (or, a nice "name"), but meanwhile I am
> using the address of the net struct like "nf_ct-%p".

-ENOBANANA

Applying just this patch (without the per-ns hashtable metadata, but
with a trivial fix to name using nf_ct-%p for now), we still fall over
in the conntrack lookup code every single time:

[  210.697337] device vnet2 entered promiscuous mode
[  210.703868] br0: port 4(vnet2) entering forwarding state
[  220.766146] vnet2: no IPv6 routers present
[  236.216957] BUG: unable to handle kernel paging request at
ffff88037e613588
[  236.217638] IP: [<ffffffff813d47cc>] __nf_conntrack_find+0x53/0xb1
[  236.217638] PGD 1a3c063 PUD 0=20
[  236.217638] Oops: 0000 [#1] SMP=20
[  236.217638] last sysfs
file: /sys/devices/virtual/block/md0/md/sync_speed

Entering kdb (current=3D0xffff8801f32e8000, pid 3214) on processor 1 Oo=
ps:
(null)
due to oops @ 0xffffffff813d47cc
CPU 1 <c>
<d>Pid: 3214, comm: qemu-kvm Not tainted 2.6.33-rc5 #25 0F9382/Precisio=
n
WorkStation 490   =20
<d>RIP: 0010:[<ffffffff813d47cc>]  [<ffffffff813d47cc>]
__nf_conntrack_find+0x53/0xb1
<d>RSP: 0018:ffff8801d41a3758  EFLAGS: 00010286
<d>RAX: ffff88037e613588 RBX: ffff8801d41a3868 RCX: 000000004d1bab3a
<d>RDX: ffff8801f32e8000 RSI: 0000000081b04540 RDI: 0000000000000246
<d>RBP: ffff8801d41a3798 R08: 0000000045f1b45f R09: 000000005e5ffada
<d>R10: 00000000501b6d3f R11: ffff8801d41a388c R12: ffffffff8288ef70
<d>R13: ffff8801d41a3868 R14: ffffffffffffffb8 R15: 000000002bfc66b1
<d>FS:  00007f0059b01780(0000) GS:ffff88002fa00000(0000)
knlGS:0000000000000000
<d>CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
<d>CR2: ffff88037e613588 CR3: 00000001f05ed000 CR4: 00000000000026e0
<d>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<d>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 3214, threadinfo ffff8801d41a2000, task
ffff8801f32e8000)
<0>Stack:
 ffff8802206302e0 000000015fe33588 ffffffffffffffb8 ffffffff8288ef70
<0> ffff8802206302e0 ffff8801d41a3868 ffffffffffffffb8 ffffffff8288ef70
<0> ffff8801d41a37e8 ffffffff813d485d ffff8802206302e0 ffff8802206302e0
<0>Call Trace:
[1]more> <0> [<ffffffff813d485d>] nf_conntrack_find_get+0x33/0xb7
[1]more> <0> [<ffffffff813d58d5>] nf_conntrack_in+0x209/0x7b4
[1]more> <0> [<ffffffff8141a413>] ipv4_conntrack_local+0x40/0x49
[1]more> <0> [<ffffffff813d278a>] nf_iterate+0x46/0x89
[1]more> <0> [<ffffffff813e5458>] ? dst_output+0x0/0x12
[1]more> <0> [<ffffffff813d2845>] nf_hook_slow+0x78/0xe0
[1]more> <0> [<ffffffff813e5458>] ? dst_output+0x0/0x12
[1]more> <0> [<ffffffff813e67f2>] nf_hook_thresh.clone.0+0x41/0x4a
[1]more> <0> [<ffffffff81126846>] ? poll_freewait+0x32/0x70
[1]more> <0> [<ffffffff813e6ad2>] __ip_local_out+0x7e/0x80
[1]more> <0> [<ffffffff813e6aea>] ip_local_out+0x16/0x27
[1]more> <0> [<ffffffff813e7118>] ip_queue_xmit+0x30e/0x36e
[1]more> <0> [<ffffffff813f8aec>] tcp_transmit_skb+0x707/0x745
[1]more> <0> [<ffffffff813fb15e>] tcp_write_xmit+0x7cb/0x8ba
[1]more> <0> [<ffffffff813fb2b2>] __tcp_push_pending_frames+0x2f/0x5d
[1]more> <0> [<ffffffff813edecf>] tcp_push+0x88/0x8a
[1]more> <0> [<ffffffff813f01f0>] tcp_sendmsg+0x760/0x85b
[1]more> <0> [<ffffffff813a3ccc>] __sock_sendmsg+0x5e/0x69
[1]more> <0> [<ffffffff813a3fe2>] sock_sendmsg+0xa8/0xc1
[1]more> <0> [<ffffffff81119641>] ? fget_light+0x57/0xf2
[1]more> <0> [<ffffffff811195e8>] ? rcu_read_unlock+0x21/0x23
[1]more> <0> [<ffffffff81119641>] ? fget_light+0x57/0xf2
[1]more> <0> [<ffffffff8114893e>] ? eventfd_write+0x94/0x186
[1]more> <0> [<ffffffff813a4072>] ? sockfd_lookup_light+0x20/0x58
[1]more> <0> [<ffffffff813a5d37>] sys_sendto+0x110/0x152
[1]more> <0> [<ffffffff81118318>] ? fsnotify_modify+0x6c/0x74
[1]more> <0> [<ffffffff81118ad6>] ? vfs_write+0xd3/0x10b
[1]more> <0> [<ffffffff81457f00>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[1]more> <0> [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b
[1]more> <0>Code: 48 89 df e8 21 f5 ff ff 41 89 c7 45 89 ff e8 e7 fb c7
ff 4a 8d 04 fd 00 00 00 00 48 89 45 c8 48 8b 45 c8 49 03 84 24 98 06 00
00 <4c> 8b 28 eb 14 65 83 40 04 01 e8 bc fc c7 ff eb 3b 65 83 00 01=20
[1]more> Call Trace:
[1]more>  [<ffffffff813d47b4>] ? __nf_conntrack_find+0x3b/0xb1
[1]more>  [<ffffffff813d485d>] nf_conntrack_find_get+0x33/0xb7
[1]more>  [<ffffffff813d58d5>] nf_conntrack_in+0x209/0x7b4
[1]more>  [<ffffffff8141a413>] ipv4_conntrack_local+0x40/0x49
[1]more>  [<ffffffff813d278a>] nf_iterate+0x46/0x89
[1]more>  [<ffffffff813e5458>] ? dst_output+0x0/0x12
[1]more>  [<ffffffff813d2845>] nf_hook_slow+0x78/0xe0
[1]more>  [<ffffffff813e5458>] ? dst_output+0x0/0x12
[1]more>  [<ffffffff813e67f2>] nf_hook_thresh.clone.0+0x41/0x4a
[1]more>  [<ffffffff81126846>] ? poll_freewait+0x32/0x70
[1]more>  [<ffffffff813e6ad2>] __ip_local_out+0x7e/0x80
[1]more>  [<ffffffff813e6aea>] ip_local_out+0x16/0x27
[1]more>  [<ffffffff813e7118>] ip_queue_xmit+0x30e/0x36e
[1]more>  [<ffffffff813f8aec>] tcp_transmit_skb+0x707/0x745
[1]more>  [<ffffffff813fb15e>] tcp_write_xmit+0x7cb/0x8ba
[1]more>  [<ffffffff813fb2b2>] __tcp_push_pending_frames+0x2f/0x5d
[1]more>  [<ffffffff813edecf>] tcp_push+0x88/0x8a
[1]more>  [<ffffffff813f01f0>] tcp_sendmsg+0x760/0x85b
[1]more>  [<ffffffff813a3ccc>] __sock_sendmsg+0x5e/0x69
[1]more>  [<ffffffff813a3fe2>] sock_sendmsg+0xa8/0xc1
[1]more>  [<ffffffff81119641>] ? fget_light+0x57/0xf2
[1]more>  [<ffffffff811195e8>] ? rcu_read_unlock+0x21/0x23
[1]more>  [<ffffffff81119641>] ? fget_light+0x57/0xf2
[1]more>  [<ffffffff8114893e>] ? eventfd_write+0x94/0x186
[1]more>  [<ffffffff813a4072>] ? sockfd_lookup_light+0x20/0x58
[1]more>  [<ffffffff813a5d37>] sys_sendto+0x110/0x152
[1]more>  [<ffffffff81118318>] ? fsnotify_modify+0x6c/0x74
[1]more>  [<ffffffff81118ad6>] ? vfs_write+0xd3/0x10b
[1]more>  [<ffffffff81457f00>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[1]more>  [<ffffffff81009bf2>] system_call_fastpath+0x16/0x1b

I think there's something more fundamental going on here.

Jon.


