From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Tue, 5 Feb 2013 15:05:54 +0800
Message-ID: <CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<loom.20130204T174808-896@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:42308 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab3BEHF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 02:05:57 -0500
Received: by mail-we0-f172.google.com with SMTP id x10so5430624wey.31
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 23:05:55 -0800 (PST)
In-Reply-To: <loom.20130204T174808-896@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/5 Jim Baxter <jim_baxter@mentor.com>:
> Frank Li <Frank.Li <at> freescale.com> writes:
>
>>
>> BUG: spinlock bad magic on CPU#1, swapper/0/1
>> lock: 0xbfae0f8c, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
>> Backtrace:
>>  [<80011d54>] (dump_backtrace+0x0/0x10c) from [<804e7800>]
> (dump_stack+0x18/0x1c)
>>  r6:bfae0000 r5:bfae0f8c r4:00000000 r3:806c1310
>>  [<804e77e8>] (dump_stack+0x0/0x1c) from [<804e9f20>] (spin_dump+0x80/0x94)
>>  [<804e9ea0>] (spin_dump+0x0/0x94) from [<804e9f60>] (spin_bug+0x2c/0x30)
>>  r5:805f6f8c r4:bfae0f8c
>>  [<804e9f34>] (spin_bug+0x0/0x30) from [<80257984>]
> (do_raw_spin_lock+0x170/0x1b0                                         )
>>  r5:806b4950 r4:bfae0f8c
>>  [<80257814>] (do_raw_spin_lock+0x0/0x1b0) from [<804ed15c>]
> (_raw_spin_lock_irqs                                         ave+0x18/0x20)
>>  [<804ed144>] (_raw_spin_lock_irqsave+0x0/0x20) from [<8033c694>]
> (fec_ptp_start_                                         cyclecounter+0x3c/0x120)
>>  r4:bfae0f8c r3:00000002
>>  [<8033c658>] (fec_ptp_start_cyclecounter+0x0/0x120) from [<80339e08>]
> (fec_resta                                         rt+0x56c/0x5f8)
>>  r8:00000000 r7:806e6f48 r6:00000112 r5:806b4950 r4:bfae0000
>>  [<8033989c>] (fec_restart+0x0/0x5f8) from [<8033b9e4>]
> (fec_probe+0x508/0xa48)
>>
>> Signed-off-by: Frank Li <Frank.Li <at> freescale.com>
>> ---
>>  drivers/net/ethernet/freescale/fec.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c
> b/drivers/net/ethernet/freescale/fec.c
>> index 69b16b9..f900ae4 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -1607,6 +1607,7 @@ static int fec_enet_init(struct net_device *ndev)
>>       }
>>
>>       spin_lock_init(&fep->hw_lock);
>> +     spin_lock_init(&fep->tmreg_lock);
>>
>>       fep->netdev = ndev;
>>
>
>
>
> I still get spinlock errors when booting with this patch as shown below:
>
>
> [    9.903511] =========================================================
> [    9.909959] [ INFO: possible irq lock inversion dependency detected ]
> [    9.916411] 3.5.7.3-01268-g6696bd7-dirty #1 Not tainted
> [    9.921643] ---------------------------------------------------------
> [    9.928089] swapper/0/0 just changed the state of lock:
> [    9.933320]  (&(&fep->hw_lock)->rlock){-.....}, at: [<8029d154>]
> fec_enet_interrupt+0x74/0x600
> [    9.942026] but this lock took another, HARDIRQ-unsafe lock in the past:
> [    9.948731]  (prepare_lock){+.+...}
>
> and interrupts could create inverse lock ordering between them.
>
> [    9.958266]
> [    9.958266] other info that might help us debug this:
> [    9.964802]  Possible interrupt unsafe locking scenario:
> [    9.964802]
> [    9.971598]        CPU0                    CPU1
> [    9.976133]        ----                    ----
> [    9.980668]   lock(prepare_lock);
> [    9.984021]                                local_irq_disable();
> [    9.989945]                                lock(&(&fep->hw_lock)->rlock);
> [    9.996769]                                lock(prepare_lock);
> [   10.002637]   <Interrupt>
> [   10.005262]     lock(&(&fep->hw_lock)->rlock);
> [   10.009742]
> [   10.009742]  *** DEADLOCK ***
> [   10.009742]
> [   10.015673] no locks held by swapper/0/0.
> [   10.019689]
> [   10.019689] the shortest dependencies between 2nd lock and 1st lock:
> [   10.027528]  -> (prepare_lock){+.+...} ops: 272 {
> [   10.032321]     HARDIRQ-ON-W at:
> [   10.035570]                       [<800688d8>] mark_lock+0x290/0x628
> [   10.041963]                       [<80069320>] __lock_acquire+0x6b0/0x1998
> [   10.048866]                       [<8006ac20>] lock_acquire+0x124/0x148
> [   10.055506]                       [<803dc02c>] mutex_lock_nested+0x54/0x37c
> [   10.062499]                       [<802f5d34>] clk_prepare+0x20/0x40
> [   10.068882]                       [<803d8094>] twd_timer_setup+0x48/0x250
> [   10.075696]                       [<803d7dcc>] percpu_timer_setup+0x64/0xbc
> [   10.082682]                       [<80551864>] smp_prepare_cpus+0x4c/0x64
> [   10.089504]                       [<8054e8dc>] kernel_init+0x5c/0x1d0
> [   10.095970]                       [<80026970>] do_exit+0x0/0x780
> [   10.102009]     SOFTIRQ-ON-W at:
> [   10.105258]                       [<800688d8>] mark_lock+0x290/0x628
> [   10.111637]                       [<80069344>] __lock_acquire+0x6d4/0x1998
> [   10.118537]                       [<8006ac20>] lock_acquire+0x124/0x148
> [   10.125177]                       [<803dc02c>] mutex_lock_nested+0x54/0x37c
> [   10.132164]                       [<802f5d34>] clk_prepare+0x20/0x40
> [   10.138543]                       [<803d8094>] twd_timer_setup+0x48/0x250
> [   10.145355]                       [<803d7dcc>] percpu_timer_setup+0x64/0xbc
> [   10.152341]                       [<80551864>] smp_prepare_cpus+0x4c/0x64
> [   10.159154]                       [<8054e8dc>] kernel_init+0x5c/0x1d0
> [   10.165619]                       [<80026970>] do_exit+0x0/0x780
> [   10.171652]     INITIAL USE at:
> [   10.174814]                      [<800688d8>] mark_lock+0x290/0x628
> [   10.181108]                      [<800693a8>] __lock_acquire+0x738/0x1998
> [   10.187922]                      [<8006ac20>] lock_acquire+0x124/0x148
> [   10.194474]                      [<803dc02c>] mutex_lock_nested+0x54/0x37c
> [   10.201373]                      [<802f60f4>] __clk_init+0x28/0x360
> [   10.207664]                      [<802f656c>] clk_register+0x140/0x1a4
> [   10.214217]                      [<802f677c>]
> clk_register_fixed_rate+0xb0/0xe0
> [   10.221552]                      [<80554e84>] mx6q_clocks_init+0x2c/0x2bd4
> [   10.228457]                      [<80557a3c>] imx6q_timer_init+0x10/0x50
> [   10.235184]                      [<80551668>] time_init+0x28/0x38
> [   10.241303]                      [<8054e728>] start_kernel+0x1b4/0x30c
> [   10.247855]                      [<10008044>] 0x10008044
> [   10.253192]   }
> [   10.254950]   ... key      at: [<805c2b40>] prepare_lock+0x3c/0x4c
> [   10.261172]   ... acquired at:
> [   10.264232]    [<8006a0e0>] __lock_acquire+0x1470/0x1998
> [   10.269570]    [<8006ac20>] lock_acquire+0x124/0x148
> [   10.274560]    [<803dc02c>] mutex_lock_nested+0x54/0x37c
> [   10.279897]    [<802f59bc>] clk_get_rate+0x20/0x40
> [   10.284712]    [<8029d9d8>] fec_ptp_start_cyclecounter+0x24/0x114
> [   10.290832]    [<8029c2b4>] fec_restart+0x4b4/0x4f8
> [   10.295734]    [<8029cb64>] fec_enet_adjust_link+0x78/0xdc
> [   10.301244]    [<802993e4>] phy_state_machine+0x438/0x4a0
> [   10.306684]    [<8003da60>] process_one_work+0x2e4/0x508
> [   10.312027]    [<8003e184>] worker_thread+0x1b4/0x2cc
> [   10.317104]    [<8004271c>] kthread+0x94/0xa0
> [   10.321494]    [<80026970>] do_exit+0x0/0x780
> [   10.325877]
> [   10.327374] -> (&(&fep->hw_lock)->rlock){-.....} ops: 2 {
> [   10.332860]    IN-HARDIRQ-W at:
> [   10.336021]                     [<800688d8>] mark_lock+0x290/0x628
> [   10.342228]                     [<8006928c>] __lock_acquire+0x61c/0x1998
> [   10.348955]                     [<8006ac20>] lock_acquire+0x124/0x148
> [   10.355421]                     [<803de31c>] _raw_spin_lock+0x40/0x50
> [   10.361892]                     [<8029d154>] fec_enet_interrupt+0x74/0x600
> [   10.368791]                     [<800812f0>]
> handle_irq_event_percpu+0xbc/0x2a8
> [   10.376132]                     [<80081520>] handle_irq_event+0x44/0x64
> [   10.382771]                     [<800842f8>] handle_fasteoi_irq+0xd0/0x11c
> [   10.389675]                     [<80080be8>] generic_handle_irq+0x28/0x38
> [   10.396489]                     [<8000e298>] handle_IRQ+0x80/0xc0
> [   10.402618]                     [<8000850c>] gic_handle_irq+0x40/0x64
> [   10.409084]                     [<803deec4>] __irq_svc+0x44/0x78
> [   10.415118]                     [<8000e748>] cpu_idle+0xb0/0x110
> [   10.421151]                     [<803cba2c>] rest_init+0xac/0xd4
> [   10.427192]                     [<8054e830>] start_kernel+0x2bc/0x30c
> [   10.433658]                     [<10008044>] 0x10008044
> [   10.438907]    INITIAL USE at:
> [   10.441982]                    [<800688d8>] mark_lock+0x290/0x628
> [   10.448102]                    [<800693a8>] __lock_acquire+0x738/0x1998
> [   10.454742]                    [<8006ac20>] lock_acquire+0x124/0x148
> [   10.461121]                    [<803de434>] _raw_spin_lock_irqsave+0x4c/0x60
> [   10.468195]                    [<8029cb10>] fec_enet_adjust_link+0x24/0xdc
> [   10.475096]                    [<802993e4>] phy_state_machine+0x438/0x4a0
> [   10.481912]                    [<8003da60>] process_one_work+0x2e4/0x508
> [   10.488639]                    [<8003e184>] worker_thread+0x1b4/0x2cc
> [   10.495104]                    [<8004271c>] kthread+0x94/0xa0
> [   10.500878]                    [<80026970>] do_exit+0x0/0x780
> [   10.506651]  }
> [   10.508321]  ... key      at: [<80b36b74>] __key.33768+0x0/0x8
> [   10.514191]  ... acquired at:
> [   10.517164]    [<80067a1c>] print_irq_inversion_bug+0x184/0x1e8
> [   10.523110]    [<80067b5c>] check_usage_forwards+0xdc/0xfc
> [   10.528621]    [<800689c4>] mark_lock+0x37c/0x628
> [   10.533349]    [<8006928c>] __lock_acquire+0x61c/0x1998
> [   10.538600]    [<8006ac20>] lock_acquire+0x124/0x148
> [   10.543590]    [<803de31c>] _raw_spin_lock+0x40/0x50
> [   10.548580]    [<8029d154>] fec_enet_interrupt+0x74/0x600
> [   10.554005]    [<800812f0>] handle_irq_event_percpu+0xbc/0x2a8
> [   10.559864]    [<80081520>] handle_irq_event+0x44/0x64
> [   10.565027]    [<800842f8>] handle_fasteoi_irq+0xd0/0x11c
> [   10.570451]    [<80080be8>] generic_handle_irq+0x28/0x38
> [   10.575787]    [<8000e298>] handle_IRQ+0x80/0xc0
> [   10.580432]    [<8000850c>] gic_handle_irq+0x40/0x64
> [   10.585421]    [<803deec4>] __irq_svc+0x44/0x78
> [   10.589977]    [<8000e748>] cpu_idle+0xb0/0x110
> [   10.594533]    [<803cba2c>] rest_init+0xac/0xd4
> [   10.599091]    [<8054e830>] start_kernel+0x2bc/0x30c
> [   10.604080]    [<10008044>] 0x10008044
> [   10.607852]
> [   10.609350]
> [   10.609350] stack backtrace:
> [   10.613715] Backtrace:
> [   10.616201] [<80011a58>] (dump_backtrace+0x0/0x10c) from [<803da960>]
> (dump_stack+0x18/0x1c)
> [   10.624645]  r6:805896d8 r5:8061fbf4 r4:8057fca0 r3:805896d8
> [   10.630388] [<803da948>] (dump_stack+0x0/0x1c) from [<80067a3c>]
> (print_irq_inversion_bug+0x1a4/0x1e8)
> [   10.639711] [<80067898>] (print_irq_inversion_bug+0x0/0x1e8) from
> [<80067b5c>] (check_usage_forwards+0xdc/0xfc)
> [   10.649815] [<80067a80>] (check_usage_forwards+0x0/0xfc) from [<800689c4>]
> (mark_lock+0x37c/0x628)
> [   10.658789] [<80068648>] (mark_lock+0x0/0x628) from [<8006928c>]
> (__lock_acquire+0x61c/0x1998)
> [   10.667416] [<80068c70>] (__lock_acquire+0x0/0x1998) from [<8006ac20>]
> (lock_acquire+0x124/0x148)
> [   10.676304] [<8006aafc>] (lock_acquire+0x0/0x148) from [<803de31c>]
> (_raw_spin_lock+0x40/0x50)
> [   10.684931] [<803de2dc>] (_raw_spin_lock+0x0/0x50) from [<8029d154>]
> (fec_enet_interrupt+0x74/0x600)
> [   10.694068]  r5:ac74a500 r4:ac74a000
> [   10.697694] [<8029d0e0>] (fec_enet_interrupt+0x0/0x600) from [<800812f0>]
> (handle_irq_event_percpu+0xbc/0x2a8)
> [   10.707711] [<80081234>] (handle_irq_event_percpu+0x0/0x2a8) from
> [<80081520>] (handle_irq_event+0x44/0x64)
> [   10.717467] [<800814dc>] (handle_irq_event+0x0/0x64) from [<800842f8>]
> (handle_fasteoi_irq+0xd0/0x11c)
> [   10.726778]  r6:ffffffff r5:ac012290 r4:ac012240 r3:00000000
> [   10.732522] [<80084228>] (handle_fasteoi_irq+0x0/0x11c) from [<80080be8>]
> (generic_handle_irq+0x28/0x38)
> [   10.742008]  r5:00000000 r4:00000096
> [   10.745635] [<80080bc0>] (generic_handle_irq+0x0/0x38) from [<8000e298>]
> (handle_IRQ+0x80/0xc0)
> [   10.754339]  r4:00000096 r3:00000220
> [   10.757964] [<8000e218>] (handle_IRQ+0x0/0xc0) from [<8000850c>]
> (gic_handle_irq+0x40/0x64)
> [   10.766321]  r5:8057ff28 r4:f4000100
> [   10.769945] [<800084cc>] (gic_handle_irq+0x0/0x64) from [<803deec4>]
> (__irq_svc+0x44/0x78)
> [   10.778216] Exception stack(0x8057ff28 to 0x8057ff70)
> [   10.783279] ff20:                   00000001 00000004 00000000 00000000
> 00000001 00000002
> [   10.791469] ff40: ffffffff 80571fe4 81354b80 412fc09a 00000000 8057ff7c
> 8057ff40 8057ff70
> [   10.799655] ff60: 8006b574 8000e514 20000013 ffffffff
> [   10.804713]  r5:20000013 r4:8000e514
> [   10.808339] [<8000e4e4>] (default_idle+0x0/0x38) from [<8000e748>]
> (cpu_idle+0xb0/0x110)
> [   10.816447] [<8000e698>] (cpu_idle+0x0/0x110) from [<803cba2c>]
> (rest_init+0xac/0xd4)
> [   10.824293] [<803cb980>] (rest_init+0x0/0xd4) from [<8054e830>]
> (start_kernel+0x2bc/0x30c)
> [   10.832562]  r5:805ce340 r4:80586df0
> [   10.836185] [<8054e574>] (start_kernel+0x0/0x30c) from [<10008044>]
> (0x10008044)
> INIT: version 2.86 booting
>
>
> Have you seen this?
> I am using the following configs:
> CONFIG_KALLSYMS_ALL=y
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> CONFIG_DEBUG_LOCK_ALLOC=y
> CONFIG_PROVE_LOCKING=y
> CONFIG_LOCKDEP=y
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_TRACE_IRQFLAGS=y
>
>

Thank you for you tested my patch.
Can you try my new patch?

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
