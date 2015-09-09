From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Wed, 9 Sep 2015 20:34:36 +0200
Message-ID: <55F07BBC.9020308@gmail.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de> <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com> <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37683 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbbIISel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 14:34:41 -0400
Received: by wicfx3 with SMTP id fx3so31848920wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 11:34:40 -0700 (PDT)
In-Reply-To: <20150909155511.GD19913@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2015 05:55 PM, Corinna Vinschen wrote:
> On Sep  9 17:54, Corinna Vinschen wrote:
>> On Sep  9 17:24, poma wrote:
>>> [PATCH net] r8169: Fix sleeping function called during get_stats64
>>> http://marc.info/?l=linux-netdev&m=144180123410135&q=raw
>>> - the noise is still present
>>
>> Are you really sure?  The entire dma_alloc/dma_free stuff has been moved
>> away.  There's no locking or sleeping involved different from what was
>> there before my original patch when calling .ndo_get_stats64.
>>


It is literally the kernel ring buffer output,
so I really can not understand your question.


>> How would I be able to reproduce this on the command line?
> 


This I have already written, here's once more for you,
<quote>
 This noise is induced via userspace, xfce4-netload-plugin,
 http://goodies.xfce.org/projects/panel-plugins/xfce4-netload-plugin

 $ grep -i device .config/xfce4/panel/netload-16.rc
 Network_Device=enp3s0

 $ ethtool -i enp3s0 | grep driver
 driver: r8169
</quote>

Therefore, to try to reproduce this issue, 'xfce4-netload-plugin' must run within 'xfce4-panel',
moreover 'xfce4-netload-plugin' must be configured to monitor affected network interface.

No command line this time, hombre.

If you are eager to test it,
https://kojipkgs.fedoraproject.org/work/tasks/170/11000170/Fedora-Live-Xfce-x86_64-rawhide-20150908.iso


> It would also be interesting to see the "noise" as it looks after
> applying the above patch...
> 
> 
> Corinna
> 


The "noise" after applying "r8169: Fix sleeping function called during get_stats64":

[  215.048821] ===============================
[  215.048826] [ INFO: suspicious RCU usage. ]
[  215.048834] 4.3.0-0.rc0.git9.1.fc24.x86_64 #1 Not tainted
[  215.048838] -------------------------------
[  215.048844] include/linux/rcupdate.h:579 Illegal context switch in RCU read-side critical section!
[  215.048849] 
               other info that might help us debug this:

[  215.048858] 
               rcu_scheduler_active = 1, debug_locks = 0
[  215.048865] 3 locks held by panel-16-netloa/2546:
[  215.048869]  #0:  (&f->f_pos_lock){+.+.+.}, at: [<ffffffff81288f19>] __fdget_pos+0x49/0x50
[  215.048893]  #1:  (&p->lock){+.+.+.}, at: [<ffffffff8128f9ac>] seq_read+0x4c/0x3e0
[  215.048986]  #2:  (rcu_read_lock){......}, at: [<ffffffff8172a005>] dev_seq_start+0x5/0x140
[  215.049008] 
               stack backtrace:
[  215.049020] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  215.049067] Call Trace:
[  215.049078]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  215.049090]  [<ffffffff81100d77>] lockdep_rcu_suspicious+0xd7/0x110
[  215.049099]  [<ffffffff810d5377>] ___might_sleep+0xa7/0x230
[  215.049107]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  215.049121]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  215.049130]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  215.049141]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
[  215.049149]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
[  215.049157]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  215.049168]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  215.049178]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  215.049193]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  215.049208]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  215.049221]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  215.049233]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  215.049243]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  215.049251]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  215.049262]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  215.049270]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  215.049281]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  215.049289]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  215.049299]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  215.049311]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  215.049318]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  215.049327]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  215.049337] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  215.049343] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  215.049348] INFO: lockdep is turned off.
[  215.049355] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  215.049403] Call Trace:
[  215.049412]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  215.049421]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  215.049429]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  215.049437]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  215.049448]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  215.049456]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
[  215.049464]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
[  215.049472]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  215.049483]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  215.049492]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  215.049502]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  215.049522]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  215.049534]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  215.049546]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  215.049555]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  215.049564]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  215.049576]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  215.049583]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  215.049593]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  215.049605]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  215.049614]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  215.049622]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  215.049630]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  215.049639]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  216.057245] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  216.057259] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  216.057265] INFO: lockdep is turned off.
[  216.057275] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  216.057320] Call Trace:
[  216.057336]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  216.057347]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  216.057355]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  216.057364]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  216.057374]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  216.057384]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  216.057395]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  216.057404]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  216.057412]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  216.057426]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  216.057438]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  216.057450]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  216.057460]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  216.057468]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  216.057478]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  216.057486]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  216.057496]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  216.057503]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  216.057512]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  216.057519]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  216.057526]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  216.057534]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  217.061487] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  217.061499] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  217.061505] INFO: lockdep is turned off.
[  217.061514] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  217.061558] Call Trace:
[  217.061573]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  217.061584]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  217.061592]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  217.061601]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  217.061611]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  217.061620]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  217.061631]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  217.061640]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  217.061648]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  217.061662]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  217.061674]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  217.061686]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  217.061696]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  217.061704]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  217.061714]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  217.061722]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  217.061731]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  217.061739]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  217.061748]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  217.061755]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  217.061762]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  217.061770]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  218.065067] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  218.065080] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  218.065085] INFO: lockdep is turned off.
[  218.065094] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  218.065229] Call Trace:
[  218.065246]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  218.065258]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  218.065269]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  218.065279]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  218.065290]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  218.065301]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  218.065313]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  218.065327]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  218.065335]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  218.065351]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  218.065365]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  218.065378]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  218.065388]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  218.065399]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  218.065410]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  218.065418]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  218.065431]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  218.065439]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  218.065449]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  218.065457]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  218.065466]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  218.065475]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  218.839694] CE: hpet increased min_delta_ns to 11521 nsec
[  219.068448] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  219.068461] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  219.068466] INFO: lockdep is turned off.
[  219.068476] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  219.068519] Call Trace:
[  219.068535]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  219.068547]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  219.068555]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  219.068564]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  219.068574]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  219.068583]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  219.068594]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  219.068603]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  219.068611]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  219.068626]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  219.068638]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  219.068650]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  219.068660]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  219.068668]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  219.068678]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  219.068686]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  219.068696]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  219.068703]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  219.068712]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  219.068719]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  219.068726]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  219.068735]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  220.072620] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  220.072632] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  220.072638] INFO: lockdep is turned off.
[  220.072647] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  220.072691] Call Trace:
[  220.072707]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  220.072719]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  220.072727]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  220.072735]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  220.072745]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  220.072755]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  220.072765]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  220.072775]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  220.072782]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  220.072797]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  220.072809]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  220.072821]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  220.072831]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  220.072839]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  220.072849]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  220.072857]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  220.072867]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  220.072874]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  220.072883]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  220.072890]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  220.072897]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  220.072906]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  221.076200] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  221.076213] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  221.076218] INFO: lockdep is turned off.
[  221.076226] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  221.076269] Call Trace:
[  221.076284]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  221.076373]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  221.076382]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  221.076391]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  221.076402]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  221.076412]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  221.076424]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  221.076435]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  221.076447]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  221.076462]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  221.076475]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  221.076488]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  221.076498]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  221.076507]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  221.076519]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  221.076528]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  221.076539]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  221.076546]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  221.076556]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  221.076564]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  221.076573]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  221.076590]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  222.079576] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  222.079588] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  222.079593] INFO: lockdep is turned off.
[  222.079602] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  222.079645] Call Trace:
[  222.079660]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  222.079670]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  222.079678]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  222.079687]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  222.079697]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  222.079706]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  222.079717]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  222.079726]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  222.079734]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  222.079748]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  222.079760]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  222.079772]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  222.079782]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  222.079790]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  222.079800]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  222.079808]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  222.079817]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  222.079824]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  222.079833]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  222.079841]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  222.079848]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  222.079856]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  223.083699] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  223.083712] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  223.083717] INFO: lockdep is turned off.
[  223.083726] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  223.083769] Call Trace:
[  223.083785]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  223.083795]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  223.083803]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  223.083812]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  223.083822]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  223.083831]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  223.083842]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  223.083851]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  223.083859]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  223.083873]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  223.083885]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  223.083897]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  223.083907]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  223.083915]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  223.083925]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  223.083933]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  223.083942]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  223.083950]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  223.083959]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  223.083966]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  223.083973]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  223.083981]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  224.087894] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  224.087906] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  224.087911] INFO: lockdep is turned off.
[  224.087920] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  224.087963] Call Trace:
[  224.087978]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  224.087988]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  224.087997]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  224.088005]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  224.088015]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  224.088024]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  224.088035]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  224.088044]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  224.088052]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  224.088066]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  224.088078]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  224.088089]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  224.088099]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  224.088107]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  224.088117]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  224.088125]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  224.088135]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  224.088142]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  224.088151]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  224.088158]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  224.088165]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  224.088174]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  225.091421] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  225.091433] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  225.091439] INFO: lockdep is turned off.
[  225.091448] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  225.091491] Call Trace:
[  225.091506]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  225.091517]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  225.091525]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  225.091616]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  225.091627]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  225.091644]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  225.091656]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  225.091666]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  225.091674]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  225.091689]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  225.091705]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  225.091717]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  225.091727]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  225.091737]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  225.091748]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  225.091757]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  225.091770]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  225.091778]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  225.091788]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  225.091796]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  225.091803]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  225.091813]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  226.094851] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  226.094864] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  226.094869] INFO: lockdep is turned off.
[  226.094878] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  226.094923] Call Trace:
[  226.094939]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  226.094950]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  226.094959]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  226.094967]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  226.094977]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  226.094987]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  226.094998]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  226.095007]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  226.095014]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  226.095029]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  226.095041]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  226.095053]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  226.095063]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  226.095071]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  226.095081]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  226.095089]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  226.095099]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  226.095106]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  226.095116]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  226.095123]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  226.095130]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  226.095138]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  227.099112] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  227.099124] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  227.099130] INFO: lockdep is turned off.
[  227.099140] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  227.099183] Call Trace:
[  227.099199]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  227.099210]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  227.099218]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  227.099227]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  227.099237]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  227.099247]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  227.099257]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  227.099267]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  227.099274]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  227.099288]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  227.099301]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  227.099312]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  227.099322]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  227.099331]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  227.099341]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  227.099348]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  227.099358]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  227.099365]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  227.099374]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  227.099382]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  227.099389]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  227.099397]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  228.102657] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  228.102670] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  228.102676] INFO: lockdep is turned off.
[  228.102686] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  228.102803] Call Trace:
[  228.102819]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  228.102831]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  228.102840]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  228.102850]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  228.102860]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  228.102871]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  228.102887]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  228.102898]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  228.102906]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  228.102921]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  228.102935]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  228.102948]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  228.102962]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  228.102971]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  228.102983]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  228.102992]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  228.103004]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  228.103017]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  228.103031]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  228.103038]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  228.103046]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  228.103055]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  229.105851] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  229.105863] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  229.105869] INFO: lockdep is turned off.
[  229.105878] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  229.105923] Call Trace:
[  229.105939]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  229.105950]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  229.105959]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  229.105968]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  229.105978]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  229.105988]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  229.105999]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  229.106008]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  229.106016]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  229.106030]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  229.106043]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  229.106055]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  229.106064]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  229.106073]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  229.106083]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  229.106091]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  229.106101]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  229.106108]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  229.106117]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  229.106125]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  229.106132]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  229.106140]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  230.110086] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  230.110099] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  230.110104] INFO: lockdep is turned off.
[  230.110114] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  230.110158] Call Trace:
[  230.110174]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  230.110185]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  230.110194]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  230.110203]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  230.110213]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  230.110222]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  230.110233]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  230.110242]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  230.110250]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  230.110265]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  230.110277]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  230.110289]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  230.110299]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  230.110307]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  230.110317]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  230.110325]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  230.110335]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  230.110342]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  230.110351]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  230.110358]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  230.110365]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  230.110374]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  231.114332] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  231.114345] in_atomic(): 1, irqs_disabled(): 0, pid: 2546, name: panel-16-netloa
[  231.114350] INFO: lockdep is turned off.
[  231.114360] CPU: 3 PID: 2546 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  231.114404] Call Trace:
[  231.114420]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  231.114431]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  231.114440]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  231.114448]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  231.114458]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  231.114468]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  231.114478]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  231.114488]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  231.114495]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  231.114510]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  231.114522]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  231.114534]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  231.114543]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  231.114552]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  231.114562]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  231.114570]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  231.114579]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  231.114587]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  231.114596]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  231.114604]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  231.114611]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  231.114619]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
...
etc.
  etc.
    etc.

This looks the same as at the beginning, as if you were dealing with an entirely different problem, hombre.
