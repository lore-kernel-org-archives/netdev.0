From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Mon, 28 Nov 2016 09:34:27 -0800
Message-ID: <1480354467.18162.66.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161125055017.7053-1-elicooper@gmx.com>
         <20161127130400.4a69ff1b@canb.auug.org.au>
         <20161128.114703.154301432767947066.davem@davemloft.net>
         <1480352023.18162.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>, sfr@canb.auug.org.au,
        elicooper@gmx.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33536 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753639AbcK1Rf3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:35:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so13695558pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:35:29 -0800 (PST)
In-Reply-To: <1480352023.18162.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 08:53 -0800, Eric Dumazet wrote:
> On Mon, 2016-11-28 at 11:47 -0500, David Miller wrote:
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Sun, 27 Nov 2016 13:04:00 +1100
> > 
> > > [Just for Dave's information]
> > > 
> > > On Fri, 25 Nov 2016 13:50:17 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> > >>
> > >> Similar to commit ae148b085876
> > >> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
> > >> sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
> > >> might not be properly segmented, which causes the packets being dropped.
> > >> 
> > >> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > >> Tested-by: Eli Cooper <elicooper@gmx.com>
> > >> Cc: stable@vger.kernel.org
> > >> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> > > 
> > > I tested this patch and it does *not* solve my problem.
> > 
> > I'm torn on this patch, because it looked exactly like it would solve the
> > kind of problem Stephen is running into.
> > 
> > Even though it doesn't fix his case, it seems correct to me.
> > 
> > I was wondering if it was also important to set the skb->protocol
> > before the call to ip_tunnel_encap() but I couldn't find a dependency.
> > 
> > In any event I'd like to see some other people review this change
> > before I apply it.
> > 
> > My only other guess for Stephen's problem is somehow the SKB headers
> > aren't set up properly for what the GSO engine expects.
> 
> Well, mlx4 just works, and uses GSO engine just fine.
> 
> So my guess is this is a bug in Intel IGB driver.

About Eli patch : I do not believe it is needed.

Here is the path followed by SIT packet being GSO at the device layer :

We can see that ip_output() was called, and ip_output() already does :

skb->protocol = htons(ETH_P_IP);

[   71.209437] sit: skb->protocol = dd86
[   71.215387] skb_mac_gso_segment type 8
[   71.219176] ------------[ cut here ]------------
[   71.219180] WARNING: CPU: 25 PID: 12087 at net/core/dev.c:2642 skb_mac_gso_segment+0x166/0x170
[   71.219200] CPU: 25 PID: 12087 Comm: netperf Not tainted 4.9.0-smp-DEV #362
[   71.219203]  ffffc90019d4b4d8 ffffffff813ca25b 0000000000000009 0000000000000000
[   71.219204]  ffffc90019d4b518 ffffffff810d0c13 00000a5219d4b4f0 0000000000000008
[   71.219205]  ffff881ff2524ae8 0000000000000001 0000000000000001 ffff881fe1107a9c
[   71.219205] Call Trace:
[   71.219209]  [<ffffffff813ca25b>] dump_stack+0x4d/0x72
[   71.219213]  [<ffffffff810d0c13>] __warn+0xd3/0xf0
[   71.219214]  [<ffffffff810d0cfe>] warn_slowpath_null+0x1e/0x20
[   71.219215]  [<ffffffff8167b656>] skb_mac_gso_segment+0x166/0x170
[   71.219216]  [<ffffffff8167b719>] __skb_gso_segment+0xb9/0x140
[   71.219218]  [<ffffffff8167bb26>] validate_xmit_skb+0x136/0x2d0
[   71.219219]  [<ffffffff8167bd03>] validate_xmit_skb_list+0x43/0x70
[   71.219221]  [<ffffffff816a4817>] sch_direct_xmit+0x147/0x1a0
[   71.219223]  [<ffffffff8167c431>] __dev_queue_xmit+0x421/0x620
[   71.219224]  [<ffffffff8167c640>] dev_queue_xmit+0x10/0x20
[   71.219226]  [<ffffffff816db2d4>] ip_finish_output2+0x254/0x330
[   71.219227]  [<ffffffff816dcaa6>] ip_finish_output+0x136/0x1d0
[   71.219228]  [<ffffffff816dd4db>] ip_output+0xab/0xc0
[   71.219230]  [<ffffffff816dc970>] ? ip_fragment.constprop.58+0x80/0x80
[   71.219231]  [<ffffffff816dccb5>] ip_local_out+0x35/0x40
[   71.219233]  [<ffffffff81725aec>] iptunnel_xmit+0x14c/0x1c0
[   71.219235]  [<ffffffff8178f77a>] sit_tunnel_xmit+0x50a/0x860
[   71.219236]  [<ffffffff8167bde0>] dev_hard_start_xmit+0xb0/0x200
[   71.219238]  [<ffffffff8167c592>] __dev_queue_xmit+0x582/0x620
[   71.219239]  [<ffffffff8167c640>] dev_queue_xmit+0x10/0x20
[   71.219241]  [<ffffffff81684fb1>] neigh_direct_output+0x11/0x20
[   71.219243]  [<ffffffff81750e91>] ip6_finish_output2+0x181/0x460
[   71.219245]  [<ffffffff8178d00b>] ? ip6table_mangle_hook+0x3b/0x130
[   71.219246]  [<ffffffff81750ea4>] ? ip6_finish_output2+0x194/0x460
[   71.219247]  [<ffffffff8178d00b>] ? ip6table_mangle_hook+0x3b/0x130
[   71.219249]  [<ffffffff81752436>] ip6_finish_output+0xa6/0x110
[   71.219250]  [<ffffffff81752535>] ip6_output+0x95/0xe0
[   71.219251]  [<ffffffff81752390>] ? ip6_fragment+0x9e0/0x9e0
[   71.219252]  [<ffffffff8174edaf>] dst_output+0xf/0x20
[   71.219254]  [<ffffffff8174f347>] NF_HOOK.constprop.45+0x77/0x90
[   71.219255]  [<ffffffff8174eda0>] ? ac6_proc_exit+0x20/0x20
[   71.219256]  [<ffffffff817505b8>] ip6_xmit+0x268/0x4d0
[   71.219257]  [<ffffffff8174eda0>] ? ac6_proc_exit+0x20/0x20
[   71.219258]  [<ffffffff817505b8>] ? ip6_xmit+0x268/0x4d0
[   71.219260]  [<ffffffff817834b0>] ? inet6_csk_route_socket+0x120/0x1d0
[   71.219262]  [<ffffffff8122f771>] ? __kmalloc_node_track_caller+0x31/0x40
[   71.219264]  [<ffffffff8178363e>] inet6_csk_xmit+0x7e/0xc0
[   71.219265]  [<ffffffff8122f771>] ? __kmalloc_node_track_caller+0x31/0x40
[   71.219267]  [<ffffffff816f62e7>] tcp_transmit_skb+0x547/0x910
[   71.219268]  [<ffffffff816f6a6d>] tcp_write_xmit+0x3bd/0xf70
[   71.219270]  [<ffffffff813d0580>] ? __radix_tree_create+0x2d0/0x360
[   71.219271]  [<ffffffff816f7734>] tcp_push_one+0x34/0x40
[   71.219272]  [<ffffffff816e9141>] tcp_sendmsg+0x511/0xbc0
[   71.219275]  [<ffffffff81716375>] inet_sendmsg+0x65/0xa0
[   71.219277]  [<ffffffff81659188>] sock_sendmsg+0x38/0x50
[   71.219278]  [<ffffffff8165a8d6>] SYSC_sendto+0x106/0x170
[   71.219281]  [<ffffffff81139c06>] ? do_setitimer+0x1f6/0x250
[   71.219282]  [<ffffffff81139ca1>] ? alarm_setitimer+0x41/0x70
[   71.219283]  [<ffffffff8165b55e>] SyS_sendto+0xe/0x10
[   71.219286]  [<ffffffff817b5720>] entry_SYSCALL_64_fastpath+0x13/0x94
