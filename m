From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 01:11:50 +0200
Message-ID: <55F0BCB6.5030508@gmail.com>
References: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de> <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com> <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de> <55F07BBC.9020308@gmail.com>
 <20150909190805.GA26699@calimero.vinschen.de>
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
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34953 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbbIIXLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 19:11:54 -0400
Received: by wicge5 with SMTP id ge5so3848749wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 16:11:53 -0700 (PDT)
In-Reply-To: <20150909190805.GA26699@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2015 09:08 PM, Corinna Vinschen wrote:
> On Sep  9 20:34, poma wrote:
>> On 09/09/2015 05:55 PM, Corinna Vinschen wrote:
>>> On Sep  9 17:54, Corinna Vinschen wrote:
>>>> On Sep  9 17:24, poma wrote:
>>>>> [PATCH net] r8169: Fix sleeping function called during get_stats64
>>>>> http://marc.info/?l=linux-netdev&m=144180123410135&q=raw
>>>>> - the noise is still present
>>>>
>>>> Are you really sure?  The entire dma_alloc/dma_free stuff has been moved
>>>> away.  There's no locking or sleeping involved different from what was
>>>> there before my original patch when calling .ndo_get_stats64.
>>>>
>>
>>
>> It is literally the kernel ring buffer output,
>> so I really can not understand your question.
> 
> I'm asking because I'm wondering if you're actually testing the
> right r8169.ko module, the one with the patch applied.  See below.
> 


I already explained the patching/building procedure
http://www.spinics.net/lists/netdev/msg342268.html


>>>> How would I be able to reproduce this on the command line?
>>
>> This I have already written, here's once more for you,
>> <quote>
>>  This noise is induced via userspace, xfce4-netload-plugin,
>>  http://goodies.xfce.org/projects/panel-plugins/xfce4-netload-plugin
>>
>>  $ grep -i device .config/xfce4/panel/netload-16.rc
>>  Network_Device=enp3s0
>>
>>  $ ethtool -i enp3s0 | grep driver
>>  driver: r8169
>> </quote>
>>
>> Therefore, to try to reproduce this issue, 'xfce4-netload-plugin' must run within 'xfce4-panel',
>> moreover 'xfce4-netload-plugin' must be configured to monitor affected network interface.
> 
> I'lll see if I can try this tomorrow.
> 
>> No command line this time, hombre.
> 


This is how I managed to reproduce the noise within the CLI - via 'ifconfig',
no need to pre-configure interface: 

# ifconfig enp3s0 up
# dmesg 
[  390.128904] r8169 0000:03:00.0 enp3s0: link down
[  390.129669] IPv6: ADDRCONF(NETDEV_UP): enp3s0: link is not ready

# ifconfig
# dmesg
[  393.855932] ===============================
[  393.855937] [ INFO: suspicious RCU usage. ]
[  393.855945] 4.3.0-0.rc0.git9.1.fc24.x86_64 #1 Not tainted
[  393.855949] -------------------------------
[  393.855956] include/linux/rcupdate.h:579 Illegal context switch in RCU read-side critical section!
[  393.855960] 
               other info that might help us debug this:

[  393.855970] 
               rcu_scheduler_active = 1, debug_locks = 0
[  393.855977] 2 locks held by ifconfig/2642:
[  393.855981]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff8128f9ac>] seq_read+0x4c/0x3e0
[  393.856004]  #1:  (rcu_read_lock){......}, at: [<ffffffff8172a005>] dev_seq_start+0x5/0x140
[  393.856022] 
               stack backtrace:
[  393.856032] CPU: 1 PID: 2642 Comm: ifconfig Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  393.856072] Call Trace:
[  393.856084]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  393.856095]  [<ffffffff81100d77>] lockdep_rcu_suspicious+0xd7/0x110
[  393.856104]  [<ffffffff810d5377>] ___might_sleep+0xa7/0x230
[  393.856111]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  393.856120]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  393.856129]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  393.856139]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
[  393.856146]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
[  393.856154]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  393.856164]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  393.856173]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  393.856240]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  393.856256]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  393.856278]  [<ffffffffa0036674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  393.856291]  [<ffffffffa00368ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  393.856307]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  393.856316]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  393.856327]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  393.856334]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  393.856345]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  393.856358]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  393.856368]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  393.856376]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  393.856384]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  393.856393]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  393.856402] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  393.856408] in_atomic(): 1, irqs_disabled(): 0, pid: 2642, name: ifconfig
[  393.856412] INFO: lockdep is turned off.
[  393.856420] CPU: 1 PID: 2642 Comm: ifconfig Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  393.856467] Call Trace:
[  393.856476]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  393.856484]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  393.856493]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  393.856501]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  393.856513]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  393.856522]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
[  393.856529]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
[  393.856537]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[  393.856547]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  393.856556]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  393.856564]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  393.856577]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  393.856594]  [<ffffffffa0036674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  393.856606]  [<ffffffffa00368ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  393.856615]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  393.856623]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  393.856635]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  393.856643]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  393.856657]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  393.856665]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  393.856673]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  393.856681]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  393.856688]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  393.856697]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76
[  426.311398] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[  426.311412] in_atomic(): 1, irqs_disabled(): 0, pid: 2651, name: ifconfig
[  426.311417] INFO: lockdep is turned off.
[  426.311426] CPU: 3 PID: 2651 Comm: ifconfig Not tainted 4.3.0-0.rc0.git9.1.fc24.x86_64 #1
...
[  426.311470] Call Trace:
[  426.311486]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
[  426.311497]  [<ffffffff810d5449>] ___might_sleep+0x179/0x230
[  426.311505]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
[  426.311514]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
[  426.311524]  [<ffffffff8142cf36>] ? debug_object_activate+0xb6/0x1e0
[  426.311534]  [<ffffffff8142d5c1>] ? debug_object_active_state+0x91/0x150
[  426.311545]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[  426.311555]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[  426.311562]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[  426.311577]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[  426.311589]  [<ffffffffa0036674>] rtl8169_update_counters+0x64/0x140 [r8169]
[  426.311601]  [<ffffffffa00368ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[  426.311612]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
[  426.311620]  [<ffffffff817299a7>] dev_seq_printf_stats+0x37/0x120
[  426.311630]  [<ffffffff81729aa4>] dev_seq_show+0x14/0x30
[  426.311638]  [<ffffffff8128fc5a>] seq_read+0x2fa/0x3e0
[  426.311648]  [<ffffffff812df0c2>] proc_reg_read+0x42/0x70
[  426.311655]  [<ffffffff812663c7>] __vfs_read+0x37/0x100
[  426.311664]  [<ffffffff81388743>] ? security_file_permission+0xa3/0xc0
[  426.311672]  [<ffffffff81266d46>] vfs_read+0x86/0x130
[  426.311679]  [<ffffffff81267ac8>] SyS_read+0x58/0xd0
[  426.311687]  [<ffffffff81855372>] entry_SYSCALL_64_fastpath+0x12/0x76


> If it has to be spanish, I'd prefer mujer, but whatever.
> 


But whatever.


>>> It would also be interesting to see the "noise" as it looks after
>>> applying the above patch...
>>
>> The "noise" after applying "r8169: Fix sleeping function called during get_stats64":
>> [...]
>> [  215.049067] Call Trace:
>> [  215.049078]  [<ffffffff8184b6c1>] dump_stack+0x4b/0x63
>> [  215.049090]  [<ffffffff81100d77>] lockdep_rcu_suspicious+0xd7/0x110
>> [  215.049099]  [<ffffffff810d5377>] ___might_sleep+0xa7/0x230
>> [  215.049107]  [<ffffffff810d5549>] __might_sleep+0x49/0x80
>> [  215.049121]  [<ffffffff811e575e>] __alloc_pages_nodemask+0x2fe/0xb90
>> [  215.049130]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
>> [  215.049141]  [<ffffffff81024b29>] ? sched_clock+0x9/0x10
>> [  215.049149]  [<ffffffff810e258c>] ? local_clock+0x1c/0x20
>> [  215.049157]  [<ffffffff81121b0d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
>> [  215.049168]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
>> [  215.049178]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
>> [  215.049193]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
>> [  215.049208]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
> 
> This is very certainly not the r8169.ko driver with my patch applied.
> There is no rtl8169_map_counters function anymore, just as with
> Francois' patch.  I'm not sure what you're doing wrong there, but this
> stack dump definitely cannot be produced with either Francois or my
> patch, so you're apparently testing the unpatched upstream driver all
> the time.
> 


$ modinfo -n r8169
/lib/modules/4.3.0-0.rc0.git9.1.fc24.x86_64/updates/r8169.ko
This one -patched- is used, right?

$ objdump -DS $(modinfo -n r8169) | grep rtl8169_map_counters ; echo $?
1

The one in "/lib/modules/$(uname -r)/updates/ has priority, right?


# unxz /lib/modules/4.3.0-0.rc0.git9.1.fc24.x86_64/kernel/drivers/net/ethernet/realtek/r8169.ko.xz
$ objdump -DS /lib/modules/4.3.0-0.rc0.git9.1.fc24.x86_64/kernel/drivers/net/ethernet/realtek/r8169.ko | grep rtl8169_map_counters 
0000000000002220 <rtl8169_map_counters>:
    2220:	e8 00 00 00 00       	callq  2225 <rtl8169_map_counters+0x5>
    2259:	e8 00 00 00 00       	callq  225e <rtl8169_map_counters+0x3e>
    2261:	74 19                	je     227c <rtl8169_map_counters+0x5c>
    366f:	e8 ac eb ff ff       	callq  2220 <rtl8169_map_counters>
    b44f:	e8 cc 6d ff ff       	callq  2220 <rtl8169_map_counters>

And this is the original, which is not used, right?


>> ...
>> etc.
>>   etc.
>>     etc.
>>
>> This looks the same as at the beginning, as if you were dealing with
>> an entirely different problem, hombre.
> 
> No, sorry, it's you running the wrong kernel module, and a single
> occurence of the stack dump would have been sufficient, but thanks
> all the same.
> 
> 
> Corinna
> 


If you say so, hombre.
