From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Mon, 5 Apr 2010 19:15:24 -0700
Message-ID: <20100405191524.2a7848f3@nehalam>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4ADAB2A@rrsmsx501.amr.corp.intel.com>
	<20100323.233323.93371615.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
	<20100405.161221.159637463.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52324 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757116Ab0DFCdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 22:33:04 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Apr 2010 17:50:38 -0600
"Tantilov, Emil S" <emil.s.tantilov@intel.com> wrote:

> David Miller wrote:
> > From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> > Date: Mon, 5 Apr 2010 17:03:56 -0600
> > 
> >> David Miller wrote:
> >>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> >>> Date: Tue, 23 Mar 2010 12:28:08 -0600
> >>> 
> >>>> Bisecting points to this patch:
> >>>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
> >>>> 
> >>>> And I confirmed that the issue goes away after reverting it.
> >>>> 
> >>>> Steps to reproduce:
> >>>> 1. Load the driver and configure IPv6 address.
> >>>> 2. Run ethtool diag:
> >>>> ethtool -t eth0
> >>>> 
> >>>> 3. If this doesn't brake it try again, or just do ifdown/up. Other
> >>>> operations on the interface will eventually panic the system:
> >>> 
> >>> Stephen please fix this, thanks.
> >> 
> >> Just FYI - I still see this issue with latest pull from net-2.6.
> > 
> > It's net-next-2.6 that introduced the problem and has the follow-on
> > fixes, not net-2.6
> 
> Same in net-next:
> 
> [   55.706583] WARNING: at net/ipv6/ip6_fib.c:1170 fib6_del+0x44/0x39f [ipv6]()
> [   55.714851] Hardware name: S5520HC
> [   55.719037] Modules linked in: ipv6 e1000e e1000
> [   55.724866] Pid: 5599, comm: ifconfig Not tainted 2.6.34-rc1-net-next-e1000e-040510 #9
> [   55.734418] Call Trace:
> [   55.737540]  [<ffffffff81033a3e>] ? __wake_up+0x43/0x50
> [   55.743773]  [<ffffffffa006cb4e>] ? fib6_del+0x44/0x39f [ipv6]
> [   55.750687]  [<ffffffff81038b1e>] warn_slowpath_common+0x77/0x8f
> [   55.757793]  [<ffffffff81038b45>] warn_slowpath_null+0xf/0x11
> [   55.764608]  [<ffffffffa006cb4e>] fib6_del+0x44/0x39f [ipv6]
> [   55.771314]  [<ffffffffa006a13b>] __ip6_del_rt+0x49/0x68 [ipv6]
> [   55.778319]  [<ffffffffa006a2aa>] ip6_del_rt+0x38/0x3a [ipv6]
> [   55.785136]  [<ffffffffa0065573>] __ipv6_ifa_notify+0x141/0x17d [ipv6]
> [   55.792816]  [<ffffffffa00660a4>] addrconf_ifdown+0x1ed/0x2cb [ipv6]
> [   55.800300]  [<ffffffffa0067126>] addrconf_notify+0x705/0x7b6 [ipv6]
> [   55.807788]  [<ffffffff810456ce>] ? spin_unlock_irqrestore+0x9/0xb
> [   55.815088]  [<ffffffff81045b80>] ? __mod_timer+0x125/0x137
> [   55.821703]  [<ffffffff8144eb60>] ? _raw_write_unlock_bh+0x12/0x14
> [   55.828995]  [<ffffffff8103e37d>] ? local_bh_enable_ip+0x9/0xb
> [   55.835906]  [<ffffffff8144ec75>] ? _raw_spin_unlock_bh+0x12/0x14
> [   55.843109]  [<ffffffffa006ca9b>] ? fib6_run_gc+0xca/0xcf [ipv6]
> [   55.850213]  [<ffffffff81451b29>] notifier_call_chain+0x33/0x5b
> [   55.857216]  [<ffffffff81055575>] __raw_notifier_call_chain+0x9/0xb
> [   55.864604]  [<ffffffff81055586>] raw_notifier_call_chain+0xf/0x11
> [   55.871901]  [<ffffffff81397d8f>] call_netdevice_notifiers+0x16/0x18
> [   55.879390]  [<ffffffff81397eb2>] __dev_notify_flags+0x35/0x59
> [   55.886293]  [<ffffffff81397f1c>] dev_change_flags+0x46/0x52
> [   55.893007]  [<ffffffff813f0844>] devinet_ioctl+0x27f/0x54b
> [   55.899614]  [<ffffffff813f2c18>] inet_ioctl+0x8a/0xa2
> [   55.905733]  [<ffffffff81387275>] sock_do_ioctl+0x26/0x46
> [   55.912149]  [<ffffffff81387490>] sock_ioctl+0x1fb/0x20e
> [   55.918461]  [<ffffffff810e7b4b>] vfs_ioctl+0x2a/0x9d
> [   55.924495]  [<ffffffff810e80c2>] do_vfs_ioctl+0x48c/0x4dd
> [   55.930999]  [<ffffffff810e816a>] sys_ioctl+0x57/0x7a
> [   55.937033]  [<ffffffff81002a2b>] system_call_fastpath+0x16/0x1b
> [   55.944123] ---[ end trace c1c390412f982fb6 ]---
> [   55.949677] Freeing alive inet6 address ffff8801eee32000
> [   56.034060] fib6_clean_node: del failed: rt=ffff8801ec984e00@(null) err=-2
> 

Which driver is this, the test function is driver dependent?



-- 
