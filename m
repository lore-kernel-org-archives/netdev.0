From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Mon, 7 Sep 2015 09:13:32 +0200
Message-ID: <55ED391C.2090906@gmail.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37748 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbIGHNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 03:13:36 -0400
Received: by wicfx3 with SMTP id fx3so73072308wic.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 00:13:35 -0700 (PDT)
In-Reply-To: <20150906101954.GE30539@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.09.2015 12:19, Corinna Vinschen wrote:
> On Sep  4 22:59, Francois Romieu wrote:
>> net/core/net-sysfs.c::netstat_show fetches statistics under dev_base_lock.
>>
>> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=104031
>> Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW counters")
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>> Cc: Corinna Vinschen <vinschen@redhat.com>
>> ---
>>
>>  Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b67766783a8.
>>
>>  drivers/net/ethernet/realtek/r8169.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>> index 24dcbe6..56829ea 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -2200,7 +2200,7 @@ static struct rtl8169_counters *rtl8169_map_counters(struct net_device *dev,
>>  	struct rtl8169_counters *counters;
>>  	u32 cmd;
>>  
>> -	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL);
>> +	counters = dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_ATOMIC);
>>  	if (counters) {
>>  		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
>>  		cmd = (u64)*paddr & DMA_BIT_MASK(32);
>> -- 
>> 2.4.3
> 
> I'll have a look tomorrow what I'm back to work, but for the time
> being, two questions.
> 
> - The code worked for me in local testing without problem, so I'm rather
>   puzzled.  How can I reproduce the problem?
> 
> - I'm pretty new to this stuff, so I don't understand this:
> 
>   The dma_alloc_coherent(...,GFP_KERNEL) call is not new in the code,
>   it's there since at least 2010.  It appears to work fine in the
>   context of @get_ethtool_stats.  Why does this not work in the context
>   of @ndo_get_stats64?
> 
> 
> Thanks,
> Corinna
> 

1. Reverted to r8169.c?id=eb78139
   - the noise is still present
2. Patches applied - Francois Romieu (3):
   r8169: decouple the counters data and the device private area.
   r8169: move rtl_reset_counters_cond before the hardware counters helpers.
   r8169: increase the lifespan of the hardware counters dump area.
   - the noise is still present

$ modinfo -n r8169 
/lib/modules/4.3.0-0.rc0.git7.1.fc24.x86_64/updates/r8169.ko

This noise is induced via userspace, xfce4-netload-plugin,
http://goodies.xfce.org/projects/panel-plugins/xfce4-netload-plugin

$ grep -i device .config/xfce4/panel/netload-16.rc
Network_Device=enp3s0

$ ethtool -i enp3s0 | grep driver
driver: r8169

$ dmesg | grep panel-16-netloa | wc -l
237

$ dmesg
...
[   68.597764] bridge0: port 1(enp3s0) entered forwarding state

[   70.016291] ===============================
[   70.016296] [ INFO: suspicious RCU usage. ]
[   70.016303] 4.3.0-0.rc0.git7.1.fc24.x86_64 #1 Not tainted
[   70.016308] -------------------------------
[   70.016314] include/linux/rcupdate.h:579 Illegal context switch in RCU read-side critical section!
[   70.016319] 
               other info that might help us debug this:

[   70.016327] 
               rcu_scheduler_active = 1, debug_locks = 0
[   70.016334] 2 locks held by panel-16-netloa/1806:
[   70.016338]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff8128e21c>] seq_read+0x4c/0x3e0
[   70.016362]  #1:  (rcu_read_lock){......}, at: [<ffffffff817261c5>] dev_seq_start+0x5/0x140
[   70.016380] 
               stack backtrace:
[   70.016390] CPU: 3 PID: 1806 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git7.1.fc24.x86_64 #1
...
[   70.016435] Call Trace:
[   70.016445]  [<ffffffff81847841>] dump_stack+0x4b/0x63
[   70.016456]  [<ffffffff811008c7>] lockdep_rcu_suspicious+0xd7/0x110
[   70.016465]  [<ffffffff810d5297>] ___might_sleep+0xa7/0x230
[   70.016472]  [<ffffffff810d5469>] __might_sleep+0x49/0x80
[   70.016481]  [<ffffffff811e54ce>] __alloc_pages_nodemask+0x2fe/0xb90
[   70.016490]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[   70.016499]  [<ffffffff81024ab9>] ? sched_clock+0x9/0x10
[   70.016507]  [<ffffffff810e24ac>] ? local_clock+0x1c/0x20
[   70.016514]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[   70.016524]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[   70.016534]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[   70.016541]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[   70.016555]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[   70.016567]  [<ffffffffa0036674>] rtl8169_update_counters+0x64/0x140 [r8169]
[   70.016578]  [<ffffffffa00368ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[   70.016587]  [<ffffffff816fcd34>] dev_get_stats+0x54/0x100
[   70.016595]  [<ffffffff81725b67>] dev_seq_printf_stats+0x37/0x120
[   70.016605]  [<ffffffff81725c64>] dev_seq_show+0x14/0x30
[   70.016611]  [<ffffffff8128e4ca>] seq_read+0x2fa/0x3e0
[   70.016621]  [<ffffffff812dbec2>] proc_reg_read+0x42/0x70
[   70.016628]  [<ffffffff81264cc7>] __vfs_read+0x37/0x100
[   70.016637]  [<ffffffff81385113>] ? security_file_permission+0xa3/0xc0
[   70.016644]  [<ffffffff81265646>] vfs_read+0x86/0x130
[   70.016652]  [<ffffffff812663c8>] SyS_read+0x58/0xd0
[   70.016660]  [<ffffffff818514f2>] entry_SYSCALL_64_fastpath+0x12/0x76
[   70.016698] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[   70.016704] in_atomic(): 1, irqs_disabled(): 0, pid: 1806, name: panel-16-netloa
[   70.016708] INFO: lockdep is turned off.
[   70.016715] CPU: 3 PID: 1806 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git7.1.fc24.x86_64 #1
...
[   70.016760] Call Trace:
[   70.016768]  [<ffffffff81847841>] dump_stack+0x4b/0x63
[   70.016776]  [<ffffffff810d5369>] ___might_sleep+0x179/0x230
[   70.016784]  [<ffffffff810d5469>] __might_sleep+0x49/0x80
[   70.016792]  [<ffffffff811e54ce>] __alloc_pages_nodemask+0x2fe/0xb90
[   70.016800]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[   70.016809]  [<ffffffff81024ab9>] ? sched_clock+0x9/0x10
[   70.016817]  [<ffffffff810e24ac>] ? local_clock+0x1c/0x20
[   70.016826]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
[   70.016836]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
[   70.016847]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
[   70.016856]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
[   70.016868]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r8169]
[   70.016881]  [<ffffffffa0036674>] rtl8169_update_counters+0x64/0x140 [r8169]
[   70.016893]  [<ffffffffa00368ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
[   70.016904]  [<ffffffff816fcd34>] dev_get_stats+0x54/0x100
[   70.016912]  [<ffffffff81725b67>] dev_seq_printf_stats+0x37/0x120
[   70.016923]  [<ffffffff81725c64>] dev_seq_show+0x14/0x30
[   70.016930]  [<ffffffff8128e4ca>] seq_read+0x2fa/0x3e0
[   70.016939]  [<ffffffff812dbec2>] proc_reg_read+0x42/0x70
[   70.016948]  [<ffffffff81264cc7>] __vfs_read+0x37/0x100
[   70.016957]  [<ffffffff81385113>] ? security_file_permission+0xa3/0xc0
[   70.016965]  [<ffffffff81265646>] vfs_read+0x86/0x130
[   70.016972]  [<ffffffff812663c8>] SyS_read+0x58/0xd0
[   70.016980]  [<ffffffff818514f2>] entry_SYSCALL_64_fastpath+0x12/0x76
[   71.022092] BUG: sleeping function called from invalid context at mm/page_alloc.c:3186
[   71.022104] in_atomic(): 1, irqs_disabled(): 0, pid: 1806, name: panel-16-netloa
[   71.022109] INFO: lockdep is turned off.
[   71.022118] CPU: 0 PID: 1806 Comm: panel-16-netloa Not tainted 4.3.0-0.rc0.git7.1.fc24.x86_64 #1
...
