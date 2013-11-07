From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 03:03:21 +0100
Message-ID: <20131107020321.GG8144@order.stressinduktion.org>
References: <20131104041108.GA22823@gondor.apana.org.au> <20131106013038.GA14894@gondor.apana.org.au> <20131106123900.GA20259@gondor.apana.org.au> <20131106133045.GA20931@gondor.apana.org.au> <20131106143927.GA21604@gondor.apana.org.au> <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com> <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com> <20131107011337.GD8144@order.stressinduktion.org> <1383787279.2878.22.camel@edumazet-glaptop2.roam.corp.google.com> <1383788068.2878.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54532 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab3KGCDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:03:23 -0500
Content-Disposition: inline
In-Reply-To: <1383788068.2878.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 05:34:28PM -0800, Eric Dumazet wrote:
> On Wed, 2013-11-06 at 17:21 -0800, Eric Dumazet wrote:
> > On Thu, 2013-11-07 at 02:13 +0100, Hannes Frederic Sowa wrote:
> > > On Wed, Nov 06, 2013 at 04:15:21PM -0800, Eric Dumazet wrote:
> > > > On Wed, 2013-11-06 at 11:47 -0800, Eric Dumazet wrote:
> > > > > I'll try a different way.
> > > > > 
> > > > > The frag_list would contain a bunch of frags, that we logically add to the bunch
> > > > > of frags found in the first skb shared_info structure.
> > > > 
> > > > Here is the patch I came into (I tested it and it works very fine)
> > > > 
> > > > The theory is that in GRO stack, all skbs use the head_frag trick,
> > > > so even if one NIC pulled some payload into skb->head, we do not have to
> > > > copy anything. Outside of GRO stack, we are not supposed to provide data
> > > > in skb->head (I am speaking of the skb found on the frag_list extension,
> > > > not the skb_head)
> > > > 
> > > > I put a fallback code, just in case, with a WARN_ON_ONCE() so that we
> > > > can catch the offenders (if any) to fix them.
> > > > 
> > > > I renamed @skb to @skb_head to more clearly document this code.
> > > > Same for @i renamed to @cur_frag
> > > 
> > > I wanted to understand this code more closely and tried it with a test case I
> > > used for the UDP_CORK bugs and also for the tbf panic.
> > > 
> > > The packet is allocated as an UFO one and gets segmented by tbf.
> > > 
> > > # tc qdisc replace dev eth0 root tbf rate 200kbit latency 20ms burst 5kb
> > > # ./udptest
> > > (Just doing two writes of 200 bytes, then a write of 4096 bytes on a udp
> > > socket. I can send you the source (or a stripped down version, because it got
> > > realy noisy.))
> > 
> > Interesting :
> > 
> >                        if (cskb == head_skb)
> >                                cskb = skb_shinfo(head_skb)->frag_list;
> >                        else
> >                                cskb = cskb->next;
> >                        if (!cskb) {
> >                                WARN_ON_ONCE(1);
> >                                goto err;
> >                        }
> > 
> > So here either head_skb->frag_list is NULL, or the frag_list chain finishes too early.
> > 
> > More probably I have a bug in the code ;)
> 
> Oh yes, I missed a : data_len += remain;
> 
> at line 2906 :
> 
> 	offset = remain;
> +	data_len += remain;
> 	continue;

Hm, I still hit the WARN_ON_ONCE (same test as above) with this fixed up:

[   27.962782] ------------[ cut here ]------------
[   27.964728] WARNING: CPU: 1 PID: 485 at net/core/skbuff.c:2875 skb_segment+0x72d/0x7b0()
[   27.967179] Modules linked in: sch_tbf joydev i2c_piix4 virtio_balloon i2c_core serio_raw nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_blk virtio_net virtio_pci virtio_ring virtio ata_generic pata_acpi
[   27.979403] CPU: 1 PID: 485 Comm: udptest Not tainted 3.12.0+ #5
[   27.982402] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   27.984125]  0000000000000009 ffff8800d581b8a8 ffffffff816423fb 0000000000000000
[   27.986873]  ffff8800d581b8e0 ffffffff81067dcd ffff8800372c2c00 ffffea0000de5800
[   27.990107]  00000000000005c8 0000000000000000 ffff8800372b4710 ffff8800d581b8f0
[   27.993473] Call Trace:
[   27.994506]  [<ffffffff816423fb>] dump_stack+0x45/0x56
[   27.996172]  [<ffffffff81067dcd>] warn_slowpath_common+0x7d/0xa0
[   27.998295]  [<ffffffff81067eaa>] warn_slowpath_null+0x1a/0x20
[   28.000127]  [<ffffffff8153f6fd>] skb_segment+0x72d/0x7b0
[   28.002090]  [<ffffffff815b0332>] udp4_ufo_fragment+0xc2/0x120
[   28.006193]  [<ffffffff815b8aed>] inet_gso_segment+0x11d/0x330
[   28.008292]  [<ffffffff812a0469>] ? selinux_ip_postroute+0x99/0x2c0
[   28.010469]  [<ffffffff8154c2ac>] skb_mac_gso_segment+0x9c/0x180
[   28.013065]  [<ffffffff8154c3f0>] __skb_gso_segment+0x60/0xc0
[   28.015326]  [<ffffffffa00e1a5f>] tbf_enqueue+0x5f/0x1f0 [sch_tbf]
[   28.017752]  [<ffffffff8154cd3b>] dev_queue_xmit+0x24b/0x480
[   28.019906]  [<ffffffff81585299>] ip_finish_output+0x2c9/0x3b0
[   28.022189]  [<ffffffff815866c8>] ip_output+0x58/0x90
[   28.024167]  [<ffffffff81585e35>] ip_local_out+0x25/0x30
[   28.026409]  [<ffffffff815871d5>] ip_send_skb+0x15/0x50
[   28.028517]  [<ffffffff815ababf>] udp_send_skb+0x20f/0x2a0
[   28.030700]  [<ffffffff815842c0>] ? ip_copy_metadata+0xc0/0xc0
[   28.033053]  [<ffffffff815aca0a>] udp_sendmsg+0x2fa/0xa10
[   28.035024]  [<ffffffff8129a560>] ? sock_has_perm+0x70/0x90
[   28.042218]  [<ffffffff8153799c>] ? release_sock+0x10c/0x160
[   28.044222]  [<ffffffff815b8734>] inet_sendmsg+0x64/0xb0
[   28.047297]  [<ffffffff8129a693>] ? selinux_socket_sendmsg+0x23/0x30
[   28.049649]  [<ffffffff815335db>] sock_sendmsg+0x8b/0xc0
[   28.052800]  [<ffffffff812b193e>] ? security_netlbl_sid_to_secattr+0x6e/0xb0
[   28.055594]  [<ffffffff811bdc45>] ? __d_alloc+0x25/0x180
[   28.057651]  [<ffffffff8162fb4f>] ? netlbl_domhsh_search+0x1f/0x90
[   28.060103]  [<ffffffff81533781>] SYSC_sendto+0x121/0x1c0
[   28.062332]  [<ffffffff811a81ce>] ? alloc_file+0x1e/0xc0
[   28.064561]  [<ffffffff815305fc>] ? sock_alloc_file+0x9c/0x130
[   28.066758]  [<ffffffff8153429e>] SyS_sendto+0xe/0x10
[   28.072865]  [<ffffffff81651329>] system_call_fastpath+0x16/0x1b
[   28.074981] ---[ end trace 351089f5102f0c6a ]---
