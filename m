From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 00:38:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406110036490.11647@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>   <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.02.1406101726390.11647@dtop>   <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.10.1406102114520.28698@dinf> <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406110011170.11647@dtop> <alpine.DEB.2.02.1406110022550.11647@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:38237 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbaFKHiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 03:38:20 -0400
In-Reply-To: <alpine.DEB.2.02.1406110022550.11647@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014, dormando wrote:

> On Wed, 11 Jun 2014, dormando wrote:
>
> > On Tue, 10 Jun 2014, Eric Dumazet wrote:
> >
> > > On Tue, 2014-06-10 at 21:16 -0700, dormando wrote:
> > >
> > > > Ran our udpkill util against 3.10.42 with both of your patches applied...
> > > > seems like it ran a bit longer than normally would with this test (15-20
> > > > minutes), then died:
> > >
> > > Well, could you try a recent kernel instead ?
> > >
> > > I can see some races and fixes are probably worth it.
> > >
> > > $ git log --oneline v3.10.42..v3.15 net/ipv4/route.c
> > > fbdc0ad ipv4: initialise the itag variable in __mkroute_input
> > > 0d5edc6 ipv4, route: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()
> > > aad8872 ipv4: add a sock pointer to dst->output() path.
> > > 9114615 ipv4: return valid RTA_IIF on ip route get
> > > 3ed66e9 net: replace __this_cpu_inc in route.c with raw_cpu_inc
> > > 0b8c7f6 ipv4: remove ip_rt_dump from route.c
> > > 4a4eb21 ipv4: remove ipv4_ifdown_dst from route.c
> > > 1e8d642 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> > > a625486 ipv4: fix counter in_slow_tot
> > > cd0f0b9 ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
> > > 2045cea net: remove unnecessary return's
> > > f87c10a ipv4: introduce ip_dst_mtu_maybe_forward and protect forwarding path against pmtu spoofing
> > > dcdfdf5 ipv4: fix race in concurrent ip_route_input_slow()
> > > 482fc60 ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
> > > 0baf2b3 ipv4: shrink rt_cache_stat
> > > 0a7e226 ipv4: fix ineffective source address selection
> > > 734d272 ipv4: raise IP_MAX_MTU to theoretical limit
> > > ca4c3fc net: split rt_genid for ipv4 and ipv6
> > > 2ffae99 ipv4: use next hop exceptions also for input routes
> > > fe2c633 net: Convert uses of typedef ctl_table to struct ctl_table
> > > 6bc19fb Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> > > 5aad1de ipv4: use separate genid for next hop exceptions
> > > f016229 ipv4: rate limit updating of next hop exceptions with same pmtu
> > > 387aa65 ipv4: properly refresh rtable entries on pmtu/redirect events
> > >
> > >
> >
> > Newest I can realistically roll would be 3.14.6, so I just tried
> > that... Without your two patches, it still dies from the UDP bug.
>
> --> Meant to say here that both *with* and *without* your two new patches
> it still crashes.
>
> > Unfortunately 3.14 has a few regressions.. one is some bad CPU usage i'll
> > have to track down, and two something about pstore is broken, so I can't
> > get the trace from the crash. It's compressing now and has more of the
> > kernel log, but it's missing the actual panic part.
> >
> > $ git log --oneline v3.14..v3.15 net/ipv4/route.c
> > fbdc0ad ipv4: initialise the itag variable in __mkroute_input
> > 0d5edc6 ipv4, route: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()
> > aad8872 ipv4: add a sock pointer to dst->output() path.
> > 9114615 ipv4: return valid RTA_IIF on ip route get
> > 3ed66e9 net: replace __this_cpu_inc in route.c with raw_cpu_inc
> > 0b8c7f6 ipv4: remove ip_rt_dump from route.c
> > 4a4eb21 ipv4: remove ipv4_ifdown_dst from route.c
> > 1e8d642 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> > 2045cea net: remove unnecessary return's
> >
> > No more obvious race fixes. I can try 3.15 fully vanilla but I'm having
> > doubts?
> >
> > We have a few patches on top of this, but none of them are active at the
> > time of my test. I've tried removing them in the past and it did nothing
> > as well.
> >
> > Sorry :(
> >

Spamming now! The pstore'd dmesg looked suspiciously like the boot before
I booted the crashed kernel.. checked pstore again and the crash is there
after a second reboot (wtf.. will test tomorrow).

<4>[  203.161414] general protection fault: 0000 [#1] SMP
<4>[  203.161531] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge
gpio_ich ipmi_watchdog ipmi_devintf x86_pkg_temp_thermal coretemp
crct10dif_pclmul crc32_pclmul ghash_clmulni_intel microcode sb_edac
edac_core igb ixgbe i2c_algo_bit lpc_ich mfd_core ptp pps_core mdio
tpm_tis tpm ipmi_si ipmi_msghandler
<4>[  203.162626] CPU: 3 PID: 28456 Comm: udpkill Not tainted
3.14.6 #1
<4>[  203.162674] Hardware name: Supermicro
X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[  203.162726] task: ffff885e5f080000 ti: ffff885e5406c000 task.ti:
ffff885e5406c000
<4>[  203.162777] RIP: 0010:[<ffffffff816608c5>]  [<ffffffff816608c5>]
ipv4_dst_destroy+0x45/0x80
<4>[  203.162867] RSP: 0018:ffff885e5406dbd8  EFLAGS: 00010246
<4>[  203.162912] RAX: dead000000200200 RBX: ffff885e4ee03440 RCX:
dead000000100100
<4>[  203.162959] RDX: dead000000100100 RSI: 0000000000000200 RDI:
ffffffff81ead102
<4>[  203.163007] RBP: ffff885e5406dbe8 R08: 0000000000000000 R09:
ffff885e5406dd38
<4>[  203.163054] R10: 0000000000000001 R11: 0000000000000001 R12:
0000000000000000
<4>[  203.163102] R13: 0000000000000140 R14: ffff885e5406de10 R15:
ffffffff8166a9b0
<4>[  203.163150] FS:  00007f24d1af9700(0000) GS:ffff882fbfc60000(0000)
knlGS:0000000000000000
<4>[  203.163200] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[  203.163246] CR2: 00007f7650df30f8 CR3: 0000005e46fdd000 CR4:
00000000000407e0
<4>[  203.163307] Stack:
<4>[  203.163360]  0000000000000000 ffff885e4ee03440 ffff885e5406dc08
ffffffff8161c47a
<4>[  203.163574]  ffff885e4ee03440 0000000000000000 ffff885e5406dc28
ffffffff8161c786
<4>[  203.163786]  0000000000000000 ffff885f70f51f80 ffff885e5406dc48
ffffffff815ffa92
<4>[  203.163999] Call Trace:
<4>[  203.164058]  [<ffffffff8161c47a>] dst_destroy+0x2a/0xe0
<4>[  203.164118]  [<ffffffff8161c786>] dst_release+0x56/0x80
<4>[  203.164183]  [<ffffffff815ffa92>] sk_dst_check+0x82/0x90
<4>[  203.164247]  [<ffffffff81692b35>] udp_sendmsg+0x585/0x830
<4>[  203.164314]  [<ffffffff8169dbe5>] inet_sendmsg+0x45/0xb0
<4>[  203.164375]  [<ffffffff815f9248>] sock_aio_write+0xc8/0xd0
<4>[  203.164439]  [<ffffffff8118073f>] do_sync_write+0x5f/0x90
<4>[  203.164499]  [<ffffffff81182681>] vfs_write+0x1d1/0x1e0
<4>[  203.164559]  [<ffffffff8118277a>] SyS_write+0x5a/0xd0
<4>[  203.164622]  [<ffffffff8172b9d2>] system_call_fastpath+0x16/0x1b
<4>[  203.164681] Code: 87 b0 00 00 00 74 4f 48 c7 c7 02 d1 ea 81 e8 a3 25
0c 00 48 8b 93 b0 00 00 00 48 8b 83 b8 00 00 00 48 b9 00 01 10 00 00 00 ad
de <48> 89 42 08 48 c7 c7 02 d1 ea 81 48 89 10 48 ba 00 02 20 00 00
<1>[  203.167034] RIP  [<ffffffff816608c5>] ipv4_dst_destroy+0x45/0x80
<4>[  203.167129]  RSP <ffff885e5406dbd8>
<4>[  203.167193] ---[ end trace 0201f2e2310d79bd ]---
<0>[  204.422742] Kernel panic - not syncing: Fatal exception in interrupt
<0>[  204.427379] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffff9fffffff)
