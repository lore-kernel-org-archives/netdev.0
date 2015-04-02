From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [rhashtable] [ INFO: suspicious RCU usage. ]
Date: Thu, 2 Apr 2015 12:11:35 +0800
Message-ID: <20150402041135.GA22514@wfg-t540p.sh.intel.com>
References: <20150402005211.GC12979@wfg-t540p.sh.intel.com>
 <20150402035810.GA5408@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63988 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbbDBELx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 00:11:53 -0400
Content-Disposition: inline
In-Reply-To: <20150402035810.GA5408@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 11:58:10AM +0800, Herbert Xu wrote:
> On Thu, Apr 02, 2015 at 08:52:11AM +0800, Fengguang Wu wrote:
> > Hi Herbert,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > 
> > commit ccd57b1bd32460d27bbb9c599e795628a3c66983
> > Author:     Herbert Xu <herbert@gondor.apana.org.au>
> > AuthorDate: Tue Mar 24 00:50:28 2015 +1100
> > Commit:     David S. Miller <davem@davemloft.net>
> > CommitDate: Mon Mar 23 22:07:52 2015 -0400
> > 
> >     rhashtable: Add immediate rehash during insertion
> >     
> >     This patch reintroduces immediate rehash during insertion.  If
> >     we find during insertion that the table is full or the chain
> >     length exceeds a set limit (currently 16 but may be disabled
> >     with insecure_elasticity) then we will force an immediate rehash.
> >     The rehash will contain an expansion if the table utilisation
> >     exceeds 75%.
> >     
> >     If this rehash fails then the insertion will fail.  Otherwise the
> >     insertion will be reattempted in the new hash table.
> >     
> >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >     Acked-by: Thomas Graf <tgraf@suug.ch>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > [    0.552992]   Adding 2048 keys
> > [    0.553792] 
> > [    0.554400] ===============================
> > [    0.555285] [ INFO: suspicious RCU usage. ]
> > [    0.556176] 4.0.0-rc4-01225-gccd57b1 #171 Not tainted
> > [    0.557156] -------------------------------
> > [    0.558044] lib/rhashtable.c:400 suspicious rcu_dereference_check() usage!
> 
> This should have been fixed by
> 
> 	58be8a583d8d316448bafa5926414cfb83c02dec.
> 
> Can you check whether this commit was in your tested tree?

Yes it is contained in next-20150401 which is bad:

# extra tests on tree/branch next/master
git bisect  bad e954104e2b634b42811dad8d502cbf240f206df2  # 21:22      0-     60  Add linux-next specific files for 20150401

The dmesg there is

[    1.149409] test_firmware: interface ready
[    1.150293] Running resizable hashtable tests...
[    1.151209]   Adding 2048 keys
[    1.152069] ------------[ cut here ]------------
[    1.152978] WARNING: CPU: 0 PID: 1 at lib/rhashtable.c:409 rhashtable_insert_rehash+0x9d/0x1d0()
[    1.154802] Modules linked in:
[    1.155628] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc6-next-20150401 #1
[    1.157185] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    1.159019]  ffffffff81d1ce18 ffff880010dc3d18 ffffffff8189b1c3 0000000000000000
[    1.160865]  0000000000000000 ffff880010dc3d58 ffffffff810b12aa ffff880010dc3d38
[    1.162716]  ffffffff8323a500 0000000000000010 ffff88000beda780 0000000000000001
[    1.164558] Call Trace:
[    1.165249]  [<ffffffff8189b1c3>] dump_stack+0x4c/0x65
[    1.166220]  [<ffffffff810b12aa>] warn_slowpath_common+0x8a/0xc0
[    1.167267]  [<ffffffff810b139a>] warn_slowpath_null+0x1a/0x20
[    1.168317]  [<ffffffff81443b3d>] rhashtable_insert_rehash+0x9d/0x1d0
[    1.169415]  [<ffffffff8225456e>] test_rht_init+0x310/0x12ba
[    1.170425]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    1.171466]  [<ffffffff8225425e>] ? test_firmware_init+0x79/0x79
[    1.172524]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    1.173552]  [<ffffffff8221e200>] kernel_init_freeable+0x22d/0x2b5
[    1.174625]  [<ffffffff81894f60>] ? rest_init+0x140/0x140
[    1.175617]  [<ffffffff81894f6e>] kernel_init+0xe/0xf0
[    1.176572]  [<ffffffff818a6c43>] ret_from_fork+0x53/0x90
[    1.177576]  [<ffffffff81894f60>] ? rest_init+0x140/0x140
[    1.178570] ---[ end trace 0ba1594e5c63400d ]---
[    1.179477] 
[    1.180071] ===============================
[    1.180911] [ INFO: suspicious RCU usage. ]
[    1.181768] 4.0.0-rc6-next-20150401 #1 Tainted: G        W      
[    1.182818] -------------------------------
[    1.183688] lib/test_rhashtable.c:176 suspicious rcu_dereference_check() usage!
[    1.185387] 
[    1.185387] other info that might help us debug this:
[    1.185387] 
[    1.187369] 
[    1.187369] rcu_scheduler_active = 1, debug_locks = 0
[    1.188835] no locks held by swapper/0/1.
[    1.189676] 
[    1.189676] stack backtrace:
[    1.190917] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W       4.0.0-rc6-next-20150401 #1
[    1.192595] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    1.194428]  0000000000000001 ffff880010dc3d78 ffffffff8189b1c3 0000000000000011
[    1.196272]  ffff880010db8000 ffff880010dc3da8 ffffffff81102d17 ffff880010f93d20
[    1.207362]  ffff88000c6530f0 0000000000000004 ffff88000beda6c0 ffff880010dc3e18
[    1.209218] Call Trace:
[    1.209897]  [<ffffffff8189b1c3>] dump_stack+0x4c/0x65
[    1.210867]  [<ffffffff81102d17>] lockdep_rcu_suspicious+0xe7/0x120
[    1.211948]  [<ffffffff822553c6>] test_rht_init+0x1168/0x12ba
[    1.212968]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    1.214007]  [<ffffffff8225425e>] ? test_firmware_init+0x79/0x79
[    1.215060]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    1.216075]  [<ffffffff8221e200>] kernel_init_freeable+0x22d/0x2b5
[    1.217140]  [<ffffffff81894f60>] ? rest_init+0x140/0x140
[    1.218130]  [<ffffffff81894f6e>] kernel_init+0xe/0xf0
[    1.219094]  [<ffffffff818a6c43>] ret_from_fork+0x53/0x90
[    1.220066]  [<ffffffff81894f60>] ? rest_init+0x140/0x140
[    1.221075] glob: 64 self-tests passed, 0 failed

Thanks,
Fengguang
