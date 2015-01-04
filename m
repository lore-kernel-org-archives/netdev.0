From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: TCP out of memory - possible bug [3.18.0-rc3] / sched?
Date: Sun, 4 Jan 2015 09:42:40 +0100
Message-ID: <20150104084240.GA1710@x4>
References: <5457D095.9070502@qdot.me>
 <1415043704.1005.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomasz Mloduchowski <q@qdot.me>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:58564 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbADItX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 03:49:23 -0500
Content-Disposition: inline
In-Reply-To: <1415043704.1005.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014.11.03 at 11:41 -0800, Eric Dumazet wrote:
> On Mon, 2014-11-03 at 19:59 +0100, Tomasz Mloduchowski wrote:
> > Hi List,
> > 
> > I hope this is the right place to report a networking issue with
> > 3.18.0-rc2 and 3.18.0-rc3 - under heavy P2P load (tested both
> > rtorrent/libtorrent and bitcoind, so not protocol-specific), the system
> > quickly exhausts tcp_mem limits in a very strange sequence of events.
> > 
> > It might be scheduler or networking subsystem related.
> > 
> > It's 100% reproducible on my system, first observed under 3.18.0-rc2.
> > 
> 
> Sounds a perfect case for a bisection maybe ?

Any news on this issue?

I stumbled across the same problem today with 3.19.0-rc2:

Jan  4 09:23:22 x4 kernel: TCP: out of memory -- consider tuning tcp_mem
Jan  4 09:23:23 x4 kernel: ------------[ cut here ]------------
Jan  4 09:23:23 x4 kernel: WARNING: CPU: 3 PID: 32504 at net/core/stream.c:201 inet_csk_destroy_sock+0x4d/0x100()
Jan  4 09:23:23 x4 kernel: CPU: 3 PID: 32504 Comm: main Not tainted 3.19.0-rc2-00193-g5e0f872c7d7e-dirty #52
Jan  4 09:23:23 x4 kernel: Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
Jan  4 09:23:23 x4 kernel: 0000000000000000 ffffffff819b8544 ffffffff81686ffc 0000000000000000
Jan  4 09:23:23 x4 kernel: ffffffff8106b352 ffff88008a623a80 ffff88008a623be8 0000000000000004
Jan  4 09:23:23 x4 kernel: ffff88008a623ae8 ffff88012d3f9240 ffffffff8162fead ffff88008a623a80
Jan  4 09:23:23 x4 kernel: Call Trace:
Jan  4 09:23:23 x4 kernel: [<ffffffff81686ffc>] ? dump_stack+0x40/0x50
Jan  4 09:23:23 x4 kernel: [<ffffffff8106b352>] ? warn_slowpath_common+0x72/0xc0
Jan  4 09:23:23 x4 kernel: [<ffffffff8162fead>] ? inet_csk_destroy_sock+0x4d/0x100
Jan  4 09:23:23 x4 kernel: [<ffffffff81633746>] ? tcp_close+0x226/0x400
Jan  4 09:23:23 x4 kernel: [<ffffffff816582cd>] ? inet_release+0x6d/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff815cf090>] ? sock_release+0x10/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff815cf10d>] ? sock_close+0xd/0x20
Jan  4 09:23:23 x4 kernel: [<ffffffff8110eeca>] ? __fput+0xca/0x1e0
Jan  4 09:23:23 x4 kernel: [<ffffffff81081c0f>] ? task_work_run+0xaf/0x100
Jan  4 09:23:23 x4 kernel: [<ffffffff81689734>] ? __schedule+0x254/0x760
Jan  4 09:23:23 x4 kernel: [<ffffffff81039ae1>] ? do_notify_resume+0x61/0xa0
Jan  4 09:23:23 x4 kernel: [<ffffffff8110f33e>] ? fput+0x3e/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff8168dc18>] ? int_signal+0x12/0x17
Jan  4 09:23:23 x4 kernel: ---[ end trace ccb3dc614f5600b1 ]---
Jan  4 09:23:23 x4 kernel: ------------[ cut here ]------------
Jan  4 09:23:23 x4 kernel: WARNING: CPU: 3 PID: 32504 at net/ipv4/af_inet.c:153 inet_sock_destruct+0x169/0x1e0()
Jan  4 09:23:23 x4 kernel: CPU: 3 PID: 32504 Comm: main Tainted: G        W      3.19.0-rc2-00193-g5e0f872c7d7e-dirty #52
Jan  4 09:23:23 x4 kernel: Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
Jan  4 09:23:23 x4 kernel: 0000000000000000 ffffffff819b9876 ffffffff81686ffc 0000000000000000
Jan  4 09:23:23 x4 kernel: ffffffff8106b352 ffff88008a623a80 ffff88008a623bc8 ffff880100104a30
Jan  4 09:23:23 x4 kernel: ffff880216864660 ffff88012d3f9240 ffffffff816591e9 ffff8800d5e2a810
Jan  4 09:23:23 x4 kernel: Call Trace:
Jan  4 09:23:23 x4 kernel: [<ffffffff81686ffc>] ? dump_stack+0x40/0x50
Jan  4 09:23:23 x4 kernel: [<ffffffff8106b352>] ? warn_slowpath_common+0x72/0xc0
Jan  4 09:23:23 x4 kernel: [<ffffffff816591e9>] ? inet_sock_destruct+0x169/0x1e0
Jan  4 09:23:23 x4 kernel: [<ffffffff815d1792>] ? __sk_free+0x12/0xc0
Jan  4 09:23:23 x4 kernel: [<ffffffff816582cd>] ? inet_release+0x6d/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff815cf090>] ? sock_release+0x10/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff815cf10d>] ? sock_close+0xd/0x20
Jan  4 09:23:23 x4 kernel: [<ffffffff8110eeca>] ? __fput+0xca/0x1e0
Jan  4 09:23:23 x4 kernel: [<ffffffff81081c0f>] ? task_work_run+0xaf/0x100
Jan  4 09:23:23 x4 kernel: [<ffffffff81689734>] ? __schedule+0x254/0x760
Jan  4 09:23:23 x4 kernel: [<ffffffff81039ae1>] ? do_notify_resume+0x61/0xa0
Jan  4 09:23:23 x4 kernel: [<ffffffff8110f33e>] ? fput+0x3e/0x80
Jan  4 09:23:23 x4 kernel: [<ffffffff8168dc18>] ? int_signal+0x12/0x17
Jan  4 09:23:23 x4 kernel: ---[ end trace ccb3dc614f5600b2 ]---

rtorrent was spinning and the network was unusable until reboot.

-- 
Markus
