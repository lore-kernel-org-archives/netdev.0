From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun netns BUG()
Date: Fri, 05 Jun 2009 09:42:07 +0100
Message-ID: <1244191328.3751.111.camel@macbook.infradead.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
	 <m17hzr7a0o.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55018 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbZFEImJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 04:42:09 -0400
In-Reply-To: <m17hzr7a0o.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-04 at 18:19 -0700, Eric W. Biederman wrote:
> David Woodhouse <dwmw2@infradead.org> writes:
> 
> > Johannes and I have been playing with using network namespaces for VPNs:
> > 	http://david.woodhou.se/vpnc-netns.sh
> >
> > The idea is that you set up a separate netns to be 'afflicted' by the
> > VPN, while your normal programs have a normal view of the network.
> >
> > One option was to run a SOCKS server in the VPN's netns, so that normal
> > programs could get to the VPN through that. That's not what I'm doing
> > here though -- this one is using NAT-PT so a range of IPv6 space is
> > mapped to the Legacy IP range on the VPN. Any connections to
> > fec0:0:0:ffff:0:0:xxyy:zzww get mapped to xx.yy.zz.ww on the VPN.
> >
> > This is done by passing the VPN tundev (from vpnc or openconnect) into
> > the new netns, and running ptrtd inside the netns. Then passing the
> > tundev from ptrtd back _out_ from the netns to the normal namespace.
> >
> > First I noticed that when vpnc/openconnect closes, the tundev doesn't
> > disappear from inside the netns -- that was unexpected.
> 
> Agreed.   If it doesn't ask for that handling it should not happen.
> 
> > So I made the
> > script in there exit some other way, and then it oopses when
> > vpnc/openconnect closes its tun fd.
> >
> > Looks like you can reproduce it by passing a tundev to a different
> > netns, then closing that netns before you close tun fd which is attached
> > to it.
> >
> > (This was actually tun.c from commit 1bded710a5 on 2.6.29.4, but I see
> > no reason to believe that 2.6.30-rc is different).
> 
> This?
> 
> commit 1bded710a574f20d41bc9e7fb531301db282d623
> 
>     tun: Check supplemental groups in TUN/TAP driver.

Yes. That's the latest version of tun.c from 2.6.30-rc which would build
against my distro's 2.6.29 kernel without me having to think. It
includes all your patches -- as you point out, the driver in 2.6.29
still has NETIF_F_NETNS_LOCAL.

There have been 6 patches to tun.c in 2.6.30-rc since that version -- 5
of which are from Herbert. Are you suggesting that one of those patches
fixes a bug which you introduced? At first glance, I didn't think that
looked likely.

> I haven't had a chance to go back and check it thoroughly.  The code
> in 2.6.30-rc at least tries to do the right thing.

This _is_ the tun.c code from 2.6.30-rc, basically.

> I will be happy to look into any problems with the driver on
> 2.6.30-rc.  The driver in 2.6.29 is enough different it isn't really
> worth trying to debug.

OK, here's one from 2.6.30-rc8. This one looks like it's the other way
round -- my VPN script passes one tun device _into_ the netns, and one
tun device _out_ of it. This time, it's oopsed on the one that was
passed _out_.

I've been experimenting with a standalone test case but haven't yet
managed to reproduce it -- I still had to use openconnect with the
vpnc-script I gave before (with the 'sleep 1 # to avoid BUG()' commented
out of course). Using that script with vpnc or anything similar should
presumably have the same effect.

[ 2103.148009] BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
[ 2103.155850] IP: [<ffffffffa0024371>] tun_chr_poll+0x23/0xb7 [tun]
[ 2103.161976] PGD 158024067 PUD 14e9a0067 PMD 0 
[ 2103.166433] Oops: 0000 [#1] SMP 
[ 2103.169691] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
[ 2103.177516] CPU 5 
[ 2103.179528] Modules linked in: tun firewire_ohci firewire_core crc_itu_t [last unloaded: scsi_wait_scan]
[ 2103.189093] Pid: 10336, comm: ptrtd Not tainted 2.6.30-rc8 #71         
[ 2103.195696] RIP: 0010:[<ffffffffa0024371>]  [<ffffffffa0024371>] tun_chr_poll+0x23/0xb7 [tun]
[ 2103.204221] RSP: 0018:ffff8801425439f8  EFLAGS: 00010246
[ 2103.209525] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff880142543a18
[ 2103.216650] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88015c103ca0
[ 2103.223775] RBP: ffff880142543a18 R08: ffff880159899958 R09: ffff880158479cc0
[ 2103.230905] R10: ffff88015fb11020 R11: 0000000000000001 R12: ffff8801584d2900
[ 2103.238032] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000005
[ 2103.245158] FS:  00007f82389836f0(0000) GS:ffff88002d07d000(0000) knlGS:0000000000000000
[ 2103.253244] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2103.258982] CR2: 0000000000000080 CR3: 000000015cc5a000 CR4: 00000000000006a0
[ 2103.266108] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2103.273238] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2103.280367] Process ptrtd (pid: 10336, threadinfo ffff880142542000, task ffff88015994ebd0)
[ 2103.288634] Stack:
[ 2103.290640]  0000000000000020 0000000000000000 0000000000000000 0000000000000000
[ 2103.297873]  ffff880142543d78 ffffffff810b9c00 ffff88015d8e7000 ffff8801584d2900
[ 2103.305345]  ffff880142543f38 ffff880142543ea8 ffff880142543dc0 ffff880142543dc8
[ 2103.313042] Call Trace:
[ 2103.315481]  [<ffffffff810b9c00>] do_select+0x303/0x4eb
[ 2103.320709]  [<ffffffff810b9de8>] ? __pollwait+0x0/0xbf
[ 2103.325934]  [<ffffffff810b9ea7>] ? pollwake+0x0/0x42
[ 2103.330984]  [<ffffffff810b9ea7>] ? pollwake+0x0/0x42
[ 2103.336034]  [<ffffffff810b9ea7>] ? pollwake+0x0/0x42
[ 2103.341115]  [<ffffffff810b9ea7>] ? pollwake+0x0/0x42
[ 2103.346166]  [<ffffffff813a82e5>] ? sock_alloc_send_pskb+0xa6/0x2ae
[ 2103.352437]  [<ffffffff810a8ea8>] ? __kmalloc_track_caller+0x110/0x122
[ 2103.358962]  [<ffffffff813a82e5>] ? sock_alloc_send_pskb+0xa6/0x2ae
[ 2103.365230]  [<ffffffff813ac41f>] ? __alloc_skb+0x69/0x13d
[ 2103.370713]  [<ffffffff8104ef02>] ? clocksource_read+0xa/0xc
[ 2103.376372]  [<ffffffff8104f158>] ? getnstimeofday+0x56/0xaa
[ 2103.382036]  [<ffffffff8104b75f>] ? ktime_get_real+0x11/0x3e
[ 2103.387715]  [<ffffffff810ba0b4>] core_sys_select+0x16f/0x205
[ 2103.393459]  [<ffffffff8104865d>] ? autoremove_wake_function+0x0/0x34
[ 2103.399904]  [<ffffffff8104ef02>] ? clocksource_read+0xa/0xc
[ 2103.405570]  [<ffffffff8104f158>] ? getnstimeofday+0x56/0xaa
[ 2103.411233]  [<ffffffff8104b565>] ? ktime_get_ts+0x49/0x4e
[ 2103.416719]  [<ffffffff810ba387>] sys_select+0x94/0xbc
[ 2103.421858]  [<ffffffff8100b9eb>] system_call_fastpath+0x16/0x1b
[ 2103.427868] Code: 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 41 56 41 55 41 54 49 89 fc 53 48 8b bf a0 00 00 00 48 89 f3 e8 f9 fd ff ff 48 85 db 49 89 c5 <4c> 8b b0 80 00 00 00 74 0f 48 8d b0 a0 00 00 00 48 89 da 4c 89 
[ 2103.447437] RIP  [<ffffffffa0024371>] tun_chr_poll+0x23/0xb7 [tun]
[ 2103.453620]  RSP <ffff8801425439f8>
[ 2103.457100] CR2: 0000000000000080
[ 2103.460806] ---[ end trace 0a4ee7821f3fe65e ]---


-- 
dwmw2

