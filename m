From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 02:13:37 +0100
Message-ID: <20131107011337.GD8144@order.stressinduktion.org>
References: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com> <20131103163103.GA18894@gondor.apana.org.au> <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com> <20131104041108.GA22823@gondor.apana.org.au> <20131106013038.GA14894@gondor.apana.org.au> <20131106123900.GA20259@gondor.apana.org.au> <20131106133045.GA20931@gondor.apana.org.au> <20131106143927.GA21604@gondor.apana.org.au> <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com> <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54431 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab3KGBNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:13:39 -0500
Content-Disposition: inline
In-Reply-To: <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 04:15:21PM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-06 at 11:47 -0800, Eric Dumazet wrote:
> > I'll try a different way.
> > 
> > The frag_list would contain a bunch of frags, that we logically add to the bunch
> > of frags found in the first skb shared_info structure.
> 
> Here is the patch I came into (I tested it and it works very fine)
> 
> The theory is that in GRO stack, all skbs use the head_frag trick,
> so even if one NIC pulled some payload into skb->head, we do not have to
> copy anything. Outside of GRO stack, we are not supposed to provide data
> in skb->head (I am speaking of the skb found on the frag_list extension,
> not the skb_head)
> 
> I put a fallback code, just in case, with a WARN_ON_ONCE() so that we
> can catch the offenders (if any) to fix them.
> 
> I renamed @skb to @skb_head to more clearly document this code.
> Same for @i renamed to @cur_frag

I wanted to understand this code more closely and tried it with a test case I
used for the UDP_CORK bugs and also for the tbf panic.

The packet is allocated as an UFO one and gets segmented by tbf.

# tc qdisc replace dev eth0 root tbf rate 200kbit latency 20ms burst 5kb
# ./udptest
(Just doing two writes of 200 bytes, then a write of 4096 bytes on a udp
socket. I can send you the source (or a stripped down version, because it got
realy noisy.))

[  370.372237] ------------[ cut here ]------------
[  370.374110] WARNING: CPU: 1 PID: 9359 at net/core/skbuff.c:2875 skb_segment+0x725/0x7a0()
[  370.382857] Modules linked in: sch_tbf(F) joydev nfsd auth_rpcgss nfs_acl lockd i2c_piix4 i2c_core virtio_balloon sunrpc serio_raw virtio_blk virtio_net virtio_pci virtio_ring ata_generic virtio pata_acpi
[  370.393546] CPU: 1 PID: 9359 Comm: udptest Tainted: GF            3.12.0+ #1
[  370.395541] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  370.397182]  0000000000000009 ffff88011804f8a8 ffffffff816423eb 0000000000000000
[  370.401220]  ffff88011804f8e0 ffffffff81067dcd ffff8800d2d52900 ffffea00045fac00
[  370.403912]  00000000000005c8 0000000000000000 ffff8800c45b7d10 ffff88011804f8f0
[  370.406681] Call Trace:
[  370.407514]  [<ffffffff816423eb>] dump_stack+0x45/0x56
[  370.409094]  [<ffffffff81067dcd>] warn_slowpath_common+0x7d/0xa0
[  370.421411]  [<ffffffff81067eaa>] warn_slowpath_null+0x1a/0x20
[  370.423776]  [<ffffffff8153f6f5>] skb_segment+0x725/0x7a0
[  370.425961]  [<ffffffff815b0322>] udp4_ufo_fragment+0xc2/0x120
[  370.430097]  [<ffffffff815b8add>] inet_gso_segment+0x11d/0x330
[  370.432763]  [<ffffffff812a0469>] ? selinux_ip_postroute+0x99/0x2c0
[  370.436632]  [<ffffffff8154c29c>] skb_mac_gso_segment+0x9c/0x180
[  370.439060]  [<ffffffff8154c3e0>] __skb_gso_segment+0x60/0xc0
[  370.446392]  [<ffffffffa00c9a5f>] tbf_enqueue+0x5f/0x1f0 [sch_tbf]
[  370.451242]  [<ffffffff8154cd2b>] dev_queue_xmit+0x24b/0x480
[  370.454330]  [<ffffffff81585289>] ip_finish_output+0x2c9/0x3b0
[  370.456631]  [<ffffffff815866b8>] ip_output+0x58/0x90
[  370.458439]  [<ffffffff81585e25>] ip_local_out+0x25/0x30
[  370.461258]  [<ffffffff815871c5>] ip_send_skb+0x15/0x50
[  370.463113]  [<ffffffff815abaaf>] udp_send_skb+0x20f/0x2a0
[  370.465031]  [<ffffffff815842b0>] ? ip_copy_metadata+0xc0/0xc0
[  370.467024]  [<ffffffff815ac9fa>] udp_sendmsg+0x2fa/0xa10
[  370.468884]  [<ffffffff8129a560>] ? sock_has_perm+0x70/0x90
[  370.470922]  [<ffffffff8153799c>] ? release_sock+0x10c/0x160
[  370.473651]  [<ffffffff815b8724>] inet_sendmsg+0x64/0xb0
[  370.475621]  [<ffffffff8129a693>] ? selinux_socket_sendmsg+0x23/0x30
[  370.478025]  [<ffffffff815335db>] sock_sendmsg+0x8b/0xc0
[  370.483445]  [<ffffffff812b193e>] ? security_netlbl_sid_to_secattr+0x6e/0xb0
[  370.487287]  [<ffffffff8162fae2>] ? netlbl_domhsh_hash+0x12/0x50
[  370.489441]  [<ffffffff8162fb3f>] ? netlbl_domhsh_search+0x1f/0x90
[  370.492770]  [<ffffffff81533781>] SYSC_sendto+0x121/0x1c0
[  370.495053]  [<ffffffff811a81ce>] ? alloc_file+0x1e/0xc0
[  370.497309]  [<ffffffff815305fc>] ? sock_alloc_file+0x9c/0x130
[  370.500255]  [<ffffffff8153429e>] SyS_sendto+0xe/0x10
[  370.503751]  [<ffffffff81651329>] system_call_fastpath+0x16/0x1b
[  370.506104] ---[ end trace 117f3806fa493b38 ]---

Maybe it does help.

Greetings,

  Hannes
