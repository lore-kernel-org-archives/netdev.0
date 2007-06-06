From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22-rc3-mm1 - pppd hanging in netdev_run_todo while holding
 mutex
Date: Tue, 5 Jun 2007 23:14:23 -0700
Message-ID: <20070605231423.1c5ffa6c.akpm@linux-foundation.org>
References: <20070530235823.793f00d9.akpm@linux-foundation.org>
	<11184.1180980056@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58439 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756923AbXFFGOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 02:14:31 -0400
In-Reply-To: <11184.1180980056@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2007 14:00:56 -0400 Valdis.Kletnieks@vt.edu wrote:

> On Wed, 30 May 2007 23:58:23 PDT, Andrew Morton said:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.22-rc3/2.6.22-rc3-mm1/
> 
> Under 22-rc2-mm1, if my VPN connection got reset, ppp0 just quietly went away.
> 
> Under 22-rc3-mm1, it seems to end up wedged and waiting for references to
> go away:
> 
> Jun  4 09:23:01 turing-police kernel: [90089.270707] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
> Jun  4 09:23:11 turing-police kernel: [90099.396121] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
> Jun  4 09:23:21 turing-police kernel: [90109.520574] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
> Jun  4 09:23:32 turing-police kernel: [90119.653129] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8

Interesting refcount.

> 'echo t > /proc/sysrq_trigger' shows pppd hung up here:
> 
> Jun  4 10:52:57 turing-police kernel: [95478.047892] pppd          D 0000000105ad3830  4968  3815      1 (NOTLB)
> Jun  4 10:52:57 turing-police kernel: [95478.047902]  ffff810008d5fd78 0000000000000086 0000000000000000 ffff810003490000
> Jun  4 10:52:57 turing-police kernel: [95478.047911]  ffff810008d5fd28 ffff810008d4a040 ffff810003461820 ffff810008d4a2b0
> Jun  4 10:52:57 turing-police kernel: [95478.047920]  0000000105ad3733 0000000000000202 00000000000000ff ffffffff80239795
> Jun  4 10:52:57 turing-police kernel: [95478.047928] Call Trace:
> Jun  4 10:52:57 turing-police kernel: [95478.047936]  [<ffffffff805207a2>] schedule_timeout+0x8d/0xb4
> Jun  4 10:52:57 turing-police kernel: [95478.047945]  [<ffffffff805207e2>] schedule_timeout_uninterruptible+0x19/0x1b
> Jun  4 10:52:57 turing-police kernel: [95478.047954]  [<ffffffff802397bb>] msleep+0x14/0x1e
> Jun  4 10:52:57 turing-police kernel: [95478.047963]  [<ffffffff8048aa4e>] netdev_run_todo+0x12f/0x234 
> Jun  4 10:52:57 turing-police kernel: [95478.047972]  [<ffffffff8049166f>] rtnl_unlock+0x35/0x37
> Jun  4 10:52:57 turing-police kernel: [95478.047981]  [<ffffffff804894a9>] unregister_netdev+0x1e/0x23
> Jun  4 10:52:57 turing-police kernel: [95478.047994]  [<ffffffff88a5f2c2>] :ppp_generic:ppp_shutdown_interface+0x67/0xbb
> Jun  4 10:52:57 turing-police kernel: [95478.048018]  [<ffffffff88a5f5b8>] :ppp_generic:ppp_release+0x33/0x65
> Jun  4 10:52:57 turing-police kernel: [95478.048028]  [<ffffffff8028d54a>] __fput+0xac/0x176
> Jun  4 10:52:57 turing-police kernel: [95478.048036]  [<ffffffff8028d628>] fput+0x14/0x16
> Jun  4 10:52:57 turing-police kernel: [95478.048045]  [<ffffffff8028a9c6>] filp_close+0x66/0x71
> Jun  4 10:52:57 turing-police kernel: [95478.048054]  [<ffffffff8028bd54>] sys_close+0x98/0xd7
> Jun  4 10:52:57 turing-police kernel: [95478.048062]  [<ffffffff8020a03c>] tracesys+0xdc/0xe1
> Jun  4 10:52:57 turing-police kernel: [95478.048073]  [<00002b45cd2429a0>]

I don't know what could have caused this, sorry.  If it's still there in next -mm
(which is still 100000 compile fixes away) it'd be good if you could bisect it.
Suspects would be git-net.patch, get-netdev-all.patch and gregkh-driver-*.patch

Thanks.
