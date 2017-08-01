From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/2] ipv6: constify inet6_protocol structures
Date: Tue, 1 Aug 2017 07:59:50 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1708010759050.2671@hadrien>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>  <1501273138-22771-2-git-send-email-Julia.Lawall@lip6.fr> <1501495011.1876.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:58768 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751003AbdHAF7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 01:59:52 -0400
In-Reply-To: <1501495011.1876.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 31 Jul 2017, Eric Dumazet wrote:

> On Fri, 2017-07-28 at 22:18 +0200, Julia Lawall wrote:
> > The inet6_protocol structure is only passed as the first argument to
> > inet6_add_protocol or inet6_del_protocol, both of which are declared as
> > const.  Thus the inet6_protocol structure itself can be const.
> >
> > Also drop __read_mostly where present on the newly const structures.
> >
> > Done with the help of Coccinelle.
> >
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> >
> > ---
> >  net/ipv6/ip6_gre.c  |    2 +-
> >  net/ipv6/tcp_ipv6.c |    2 +-
> >  net/ipv6/udp.c      |    2 +-
> >  3 files changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> > index 67ff2aa..33865d6 100644
> > --- a/net/ipv6/ip6_gre.c
> > +++ b/net/ipv6/ip6_gre.c
> > @@ -1080,7 +1080,7 @@ static void ip6gre_fb_tunnel_init(struct net_device *dev)
> >  }
> >
> >
> > -static struct inet6_protocol ip6gre_protocol __read_mostly = {
> > +static const struct inet6_protocol ip6gre_protocol = {
> >  	.handler     = gre_rcv,
> >  	.err_handler = ip6gre_err,
> >  	.flags       = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > index 90a3257..2968a33 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -1945,7 +1945,7 @@ struct proto tcpv6_prot = {
> >  	.diag_destroy		= tcp_abort,
> >  };
> >
> > -static struct inet6_protocol tcpv6_protocol = {
> > +static const struct inet6_protocol tcpv6_protocol = {
> >  	.early_demux	=	tcp_v6_early_demux,
> >  	.early_demux_handler =  tcp_v6_early_demux,
> >  	.handler	=	tcp_v6_rcv,
> > diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> > index 4a3e656..5f8b8d7 100644
> > --- a/net/ipv6/udp.c
> > +++ b/net/ipv6/udp.c
> > @@ -1448,7 +1448,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
> >  }
> >  #endif
> >
> > -static struct inet6_protocol udpv6_protocol = {
> > +static const struct inet6_protocol udpv6_protocol = {
> >  	.early_demux	=	udp_v6_early_demux,
> >  	.early_demux_handler =  udp_v6_early_demux,
> >  	.handler	=	udpv6_rcv,
> >
>
> This change breaks the kernel if one of these sysctls are changed:
> tcp_early_demux, udp_early_demux

The other patch in the series has the same problem and should be dropped
too.

julia


>
> Check commit dddb64bcb346 ("net: Add sysctl to toggle early demux for
> tcp and udp") why at least 2 structures were no longer const.
>
> (none):~# echo 0 >/proc/sys/net/ipv4/udp_early_demux
> [  101.746108] BUG: unable to handle kernel paging request at ffffffffb98cf5c0
> [  101.753093] IP: proc_udp_early_demux+0x46/0x60
> [  101.757565] PGD 13f540a067
> [  101.757565] P4D 13f540a067
> [  101.760372] PUD 13f540b063
> [  101.763171] PMD 80000013f50001e1
> [  101.765960]
> [  101.770790] Oops: 0003 [#1] SMP
> [  101.774376] gsmi: Log Shutdown Reason 0x03
> [  101.778473] Modules linked in: w1_therm wire cdc_acm ehci_pci ehci_hcd mlx4_en ib_uverbs mlx4_ib ib_core mlx4_core
> [  101.788890] CPU: 3 PID: 8819 Comm: bash Not tainted 4.13.0-smp-DEV #290
> [  101.795549] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.40.0 06/22/2016
> [  101.802517] task: ffff8e733b9c4140 task.stack: ffffa43548cd0000
> [  101.808445] RIP: 0010:proc_udp_early_demux+0x46/0x60
> [  101.813445] RSP: 0018:ffffa43548cd3e60 EFLAGS: 00010246
> [  101.818676] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000000
> [  101.825816] RDX: ffffffffb98cf5c0 RSI: 0000000000000000 RDI: ffff8e733f400100
> [  101.832957] RBP: ffffa43548cd3e68 R08: 0000000000000000 R09: 0000000000000001
> [  101.840096] R10: 0000000000000008 R11: f000000000000000 R12: 0000000000000001
> [  101.847260] R13: ffffffffffffffea R14: 0000000000000002 R15: ffffffffb9d00380
> [  101.854434] FS:  00007f7e1f34a700(0000) GS:ffff8e733f8c0000(0000) knlGS:0000000000000000
> [  101.862518] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  101.868263] CR2: ffffffffb98cf5c0 CR3: 000000100f0c8000 CR4: 00000000001406e0
> [  101.875439] Call Trace:
> [  101.877888]  proc_sys_call_handler+0xf3/0x190
> [  101.882260]  proc_sys_write+0x14/0x20
> [  101.885944]  vfs_write+0xc8/0x1e0
> [  101.889261]  SyS_write+0x48/0xa0
> [  101.892520]  entry_SYSCALL_64_fastpath+0x13/0x94
> [  101.897137] RIP: 0033:0x7f7e1ebd64a0
> [  101.900707] RSP: 002b:00007ffcbb851c58 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> [  101.908306] RAX: ffffffffffffffda RBX: 000000000232aba8 RCX: 00007f7e1ebd64a0
> [  101.915437] RDX: 0000000000000002 RSI: 00000000022ea808 RDI: 0000000000000001
> [  101.922567] RBP: 00007ffcbb851c50 R08: 00007f7e1ef691b0 R09: 00007f7e1f34a700
> [  101.929698] R10: 000000000048926a R11: 0000000000000246 R12: 000000000232b288
> [  101.936871] R13: 0000000002325e28 R14: 00000000022f0ce8 R15: 0000000000000000
> [  101.944012] Code: 15 e8 07 84 00 8b 0d 9a 3c 7d 00 48 85 d2 74 09 31 f6 85 c9 75 21 48 89 32 48 8b 15 4d 30 84 00 48 85 d2 74 09 31 f6 85 c9 75 06 <48> 89 32 5b 5d c3 48 8b 72 08 eb f4 48 8b 72 08 eb d9 0f 1f 84
> [  101.962907] RIP: proc_udp_early_demux+0x46/0x60 RSP: ffffa43548cd3e60
> [  101.969353] CR2: ffffffffb98cf5c0
> [  101.972680] ---[ end trace 116c0975bf9e19dd ]---
> [  101.977307] Kernel panic - not syncing: Fatal exception
> [  101.982590] Kernel Offset: 0x37e00000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
>
>
>
