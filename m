From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use
 napi_complete_done()")
Date: Fri, 21 Apr 2017 06:29:35 -0700
Message-ID: <1492781375.6453.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170407181754.GL30290@intel.com>
         <20170421114001.GJ30290@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ville =?ISO-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170421114001.GJ30290@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-21 at 14:40 +0300, Ville Syrjälä wrote:
> BTW I've also been getting some lockdep grief from r8169 netpoll stuff
> recently. Not sure if it might be related to these changes or not, but
> I don't remember seeing this sort of stuff until quite recently.
> 
> [  251.911044] ======================================================
> [  251.911044] [ INFO: HARDIRQ-safe -> HARDIRQ-unsafe lock order detected ]
> [  251.911045] 4.11.0-rc6-elk+ #101 Not tainted
> [  251.911045] ------------------------------------------------------
> [  251.911046] kms_plane_blink/2132 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
> [  251.911046]  (&syncp->seq#2){+.-...}, at: [<c14398a3>] netpoll_poll_dev+0xb3/0x2a0
> [  251.911048] 
> [  251.911048] and this task is already holding:
> [  251.911049]  (target_list_lock){-.....}, at: [<f858693f>] write_msg+0x3f/0xd0 [netconsole]
> [  251.911050] which would create a new lock dependency:
> [  251.911050]  (target_list_lock){-.....} -> (&syncp->seq#2){+.-...}
> [  251.911053] 
> [  251.911053] but this new dependency connects a HARDIRQ-irq-safe lock:
> [  251.911054]  (target_list_lock){-.....}
> [  251.911055] ... which became HARDIRQ-irq-safe at:
> [  251.911055]   __lock_acquire+0x6ec/0x1440
> [  251.911056]   lock_acquire+0x7e/0x1a0
> [  251.911056]   _raw_spin_lock_irqsave+0x2b/0x40
> [  251.911056]   write_msg+0x3f/0xd0 [netconsole]
> [  251.911057]   console_unlock+0x41c/0x570
> [  251.911057]   vprintk_emit+0x26d/0x350
> [  251.911058]   vprintk_default+0x12/0x20
> [  251.911058]   vprintk_func+0x1c/0x50
> [  251.911058]   printk+0xe/0x10
> [  251.911059]   drm_printk+0x5a/0x60 [drm]
> [  251.911059]   intel_get_hpd_pins+0x87/0xa0 [i915]
> [  251.911060]   i9xx_hpd_irq_handler+0x96/0xe0 [i915]
> [  251.911060]   i965_irq_handler+0x2c8/0x2f0 [i915]
> [  251.911060]   __handle_irq_event_percpu+0x38/0x360
> [  251.911061]   handle_irq_event_percpu+0x19/0x50
> [  251.911061]   handle_irq_event+0x29/0x50
> [  251.911062]   handle_edge_irq+0x65/0x110
> [  251.911062]   handle_irq+0x9f/0xc0
> [  251.911062]   do_IRQ+0x4f/0x110
> [  251.911063]   common_interrupt+0x36/0x3c
> [  251.911063]   cpuidle_enter_state+0xcc/0x390
> [  251.911064]   cpuidle_enter+0xf/0x20
> [  251.911064]   call_cpuidle+0x1c/0x40
> [  251.911064]   do_idle+0x164/0x1d0
> [  251.911065]   cpu_startup_entry+0x1d/0x20
> [  251.911065]   start_secondary+0x104/0x170
> [  251.911066]   startup_32_smp+0x16b/0x16d
> [  251.911066] 
> [  251.911066] to a HARDIRQ-irq-unsafe lock:
> [  251.911067]  (&syncp->seq#2){+.-...}
> [  251.911068] ... which became HARDIRQ-irq-unsafe at:
> [  251.911068] ...  __lock_acquire+0x5d7/0x1440
> [  251.911069]   lock_acquire+0x7e/0x1a0
> [  251.911069]   rtl8169_poll+0x474/0x620 [r8169]
> [  251.911070]   net_rx_action+0x1d0/0x3f0
> [  251.911070]   __do_softirq+0x17d/0x460
> [  251.911070]   do_softirq_own_stack+0x1d/0x30
> [  251.911071]   irq_exit+0xa5/0xb0
> [  251.911071]   do_IRQ+0x58/0x110
> [  251.911072]   common_interrupt+0x36/0x3c
> [  251.911072]   cpuidle_enter_state+0xcc/0x390
> [  251.911072]   cpuidle_enter+0xf/0x20
> [  251.911073]   call_cpuidle+0x1c/0x40
> [  251.911073]   do_idle+0x164/0x1d0
> [  251.911073]   cpu_startup_entry+0x1d/0x20
> [  251.911074]   rest_init+0x10c/0x120
> [  251.911074]   start_kernel+0x30d/0x312
> [  251.911075]   i386_start_kernel+0x85/0x89
> [  251.911075]   startup_32_smp+0x16b/0x16d
> [  251.911075] 
> [  251.911076] other info that might help us debug this:
> [  251.911076] 
> [  251.911077]  Possible interrupt unsafe locking scenario:
> [  251.911077] 
> [  251.911077]        CPU0                    CPU1
> [  251.911078]        ----                    ----
> [  251.911078]   lock(&syncp->seq#2);
> [  251.911079]                                local_irq_disable();
> [  251.911080]                                lock(target_list_lock);
> [  251.911081]                                lock(&syncp->seq#2);
> [  251.911082]   <Interrupt>
> [  251.911082]     lock(target_list_lock);
> [  251.911083] 
> [  251.911084]  *** DEADLOCK ***
> [  251.911084] 
> [  251.911084] 2 locks held by kms_plane_blink/2132:
> [  251.911085]  #0:  (console_lock){+.+.+.}, at: [<c10ad3b4>] vprintk_emit+0x264/0x350
> [  251.911086]  #1:  (target_list_lock){-.....}, at: [<f858693f>] write_msg+0x3f/0xd0 [netconsole]
> [  251.911088] 
> [  251.911088] the dependencies between HARDIRQ-irq-safe lock and the holding lock:
> [  251.911089] -> (target_list_lock){-.....} ops: 482 {
> [  251.911090]    IN-HARDIRQ-W at:
> [  251.911091]                        __lock_acquire+0x6ec/0x1440
> [  251.911092]                        lock_acquire+0x7e/0x1a0
> [  251.911092]                        _raw_spin_lock_irqsave+0x2b/0x40
> [  251.911092]                        write_msg+0x3f/0xd0 [netconsole]
> [  251.911093]                        console_unlock+0x41c/0x570
> [  251.911093]                        vprintk_emit+0x26d/0x350
> [  251.911094]                        vprintk_default+0x12/0x20
> [  251.911094]                        vprintk_func+0x1c/0x50
> [  251.911095]                        printk+0xe/0x10
> [  251.911095]                        drm_printk+0x5a/0x60 [drm]
> [  251.911096]                        intel_get_hpd_pins+0x87/0xa0 [i915]
> [  251.911096]                        i9xx_hpd_irq_handler+0x96/0xe0 [i915]
> [  251.911097]                        i965_irq_handler+0x2c8/0x2f0 [i915]
> [  251.911097]                        __handle_irq_event_percpu+0x38/0x360
> [  251.911098]                        handle_irq_event_percpu+0x19/0x50
> [  251.911098]                        handle_irq_event+0x29/0x50
> [  251.911098]                        handle_edge_irq+0x65/0x110
> [  251.911099]                        handle_irq+0x9f/0xc0
> [  251.911099]                        do_IRQ+0x4f/0x110
> [  251.911100]                        common_interrupt+0x36/0x3c
> [  251.911100]                        cpuidle_enter_state+0xcc/0x390
> [  251.911101]                        cpuidle_enter+0xf/0x20
> [  251.911101]                        call_cpuidle+0x1c/0x40
> [  251.911102]                        do_idle+0x164/0x1d0
> [  251.911102]                        cpu_startup_entry+0x1d/0x20
> [  251.911102]                        start_secondary+0x104/0x170
> [  251.911103]                        startup_32_smp+0x16b/0x16d
> [  251.911103]    INITIAL USE at:
> [  251.911104]                       __lock_acquire+0x221/0x1440
> [  251.911104]                       lock_acquire+0x7e/0x1a0
> [  251.911105]                       _raw_spin_lock_irqsave+0x2b/0x40
> [  251.911105]                       make_netconsole_target+0x80/0xab [netconsole]
> [  251.911106]                       configfs_mkdir+0x312/0x3b0 [configfs]
> [  251.911106]                       vfs_mkdir+0xd2/0x1b0
> [  251.911107]                       SyS_mkdir+0x57/0xc0
> [  251.911107]                       do_fast_syscall_32+0x80/0x430
> [  251.911108]                       entry_SYSENTER_32+0x4c/0x7b
> [  251.911108]  }
> [  251.911108]  ... key      at: [<f85882f0>] target_list_lock+0x10/0xffffed20 [netconsole]
> [  251.911109]  ... acquired at:
> [  251.911109]    check_irq_usage+0x42/0xb0
> [  251.911110]    __lock_acquire+0xfbf/0x1440
> [  251.911110]    lock_acquire+0x7e/0x1a0
> [  251.911110]    rtl8169_poll+0x474/0x620 [r8169]
> [  251.911111]    netpoll_poll_dev+0xb3/0x2a0
> [  251.911111]    netpoll_send_skb_on_dev+0x180/0x240
> [  251.911112]    netpoll_send_udp+0x292/0x440
> [  251.911112]    write_msg+0x9c/0xd0 [netconsole]
> [  251.911112]    console_unlock+0x41c/0x570
> [  251.911113]    vprintk_emit+0x26d/0x350
> [  251.911113]    printk_emit+0x1b/0x1d
> [  251.911114]    devkmsg_write+0xeb/0x140
> [  251.911114]    __vfs_write+0xb0/0x110
> [  251.911114]    vfs_write+0xa1/0x1e0
> [  251.911115]    SyS_write+0x3d/0x90
> [  251.911115]    do_fast_syscall_32+0x80/0x430
> [  251.911116]    entry_SYSENTER_32+0x4c/0x7b
> [  251.911116] 
> [  251.911116] 
> [  251.911117] the dependencies between the lock to be acquired and HARDIRQ-irq-unsafe lock:
> [  251.911117] -> (&syncp->seq#2){+.-...} ops: 7439 {
> [  251.911119]    HARDIRQ-ON-W at:
> [  251.911120]                        __lock_acquire+0x5d7/0x1440
> [  251.911120]                        lock_acquire+0x7e/0x1a0
> [  251.911121]                        rtl8169_poll+0x474/0x620 [r8169]
> [  251.911121]                        net_rx_action+0x1d0/0x3f0
> [  251.911122]                        __do_softirq+0x17d/0x460
> [  251.911122]                        do_softirq_own_stack+0x1d/0x30
> [  251.911122]                        irq_exit+0xa5/0xb0
> [  251.911123]                        do_IRQ+0x58/0x110
> [  251.911123]                        common_interrupt+0x36/0x3c
> [  251.911124]                        cpuidle_enter_state+0xcc/0x390
> [  251.911124]                        cpuidle_enter+0xf/0x20
> [  251.911125]                        call_cpuidle+0x1c/0x40
> [  251.911125]                        do_idle+0x164/0x1d0
> [  251.911126]                        cpu_startup_entry+0x1d/0x20
> [  251.911126]                        rest_init+0x10c/0x120
> [  251.911127]                        start_kernel+0x30d/0x312
> [  251.911127]                        i386_start_kernel+0x85/0x89
> [  251.911127]                        startup_32_smp+0x16b/0x16d
> [  251.911128]    IN-SOFTIRQ-W at:
> [  251.911129]                        __lock_acquire+0x5b5/0x1440
> [  251.911129]                        lock_acquire+0x7e/0x1a0
> [  251.911129]                        rtl8169_poll+0x474/0x620 [r8169]
> [  251.911130]                        net_rx_action+0x1d0/0x3f0
> [  251.911130]                        __do_softirq+0x17d/0x460
> [  251.911131]                        do_softirq_own_stack+0x1d/0x30
> [  251.911131]                        irq_exit+0xa5/0xb0
> [  251.911132]                        do_IRQ+0x58/0x110
> [  251.911132]                        common_interrupt+0x36/0x3c
> [  251.911133]                        cpuidle_enter_state+0xcc/0x390
> [  251.911133]                        cpuidle_enter+0xf/0x20
> [  251.911133]                        call_cpuidle+0x1c/0x40
> [  251.911134]                        do_idle+0x164/0x1d0
> [  251.911134]                        cpu_startup_entry+0x1d/0x20
> [  251.911135]                        rest_init+0x10c/0x120
> [  251.911135]                        start_kernel+0x30d/0x312
> [  251.911136]                        i386_start_kernel+0x85/0x89
> [  251.911136]                        startup_32_smp+0x16b/0x16d
> [  251.911136]    INITIAL USE at:
> [  251.911137]                       __lock_acquire+0x221/0x1440
> [  251.911138]                       lock_acquire+0x7e/0x1a0
> [  251.911138]                       rtl8169_get_stats64+0x81/0x320 [r8169]
> [  251.911139]                       dev_get_stats+0x30/0xa0
> [  251.911139]                       rtnl_fill_stats+0x30/0x110
> [  251.911139]                       rtnl_fill_ifinfo+0x4be/0xd80
> [  251.911140]                       rtmsg_ifinfo_build_skb+0x45/0xc0
> [  251.911140]                       rtmsg_ifinfo.part.33+0xd/0x30
> [  251.911141]                       rtmsg_ifinfo+0x1b/0x20
> [  251.911141]                       register_netdevice+0x495/0x5e0
> [  251.911142]                       register_netdev+0x12/0x20
> [  251.911142]                       rtl_init_one+0x86d/0x1060 [r8169]
> [  251.911143]                       pci_device_probe+0x8b/0x100
> [  251.911143]                       driver_probe_device+0x1ad/0x2a0
> [  251.911144]                       __driver_attach+0x89/0x90
> [  251.911144]                       bus_for_each_dev+0x4f/0x80
> [  251.911144]                       driver_attach+0x14/0x20
> [  251.911145]                 
> [  251.911146] Lost 63 message(s)!
> 

Thanks for this report.

Interesting to see how many drivers got the netpoll stuff wrong :/

Can you try :

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 81f18a8335276495a59fa93219c4607c2b8a47aa..74e4c72c331d5a6cc5b653970ef4133c8ddf9999 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7668,7 +7668,7 @@ static void rtl8169_netpoll(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl8169_interrupt(tp->pci_dev->irq, dev);
+	napi_schedule(&tp->napi);
 }
 #endif
 
