From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PATCH 2.6.23-rc3-mm1] request_irq fix DEBUG_SHIRQ handling Re: 2.6.23-rc2-mm1: rtl8139 inconsistent lock state
Date: Sat, 25 Aug 2007 11:43:08 +0200
Message-ID: <200708251143.09425.m.kozlowski@tuxland.pl>
References: <20070822133511.GH1684@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:2933 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbXHYJn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 05:43:28 -0400
In-Reply-To: <20070822133511.GH1684@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > =================================
> > [ INFO: inconsistent lock state ]
> > 2.6.23-rc2-mm1 #7
> > ---------------------------------
> > inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
> > ifconfig/5492 [HC0[0]:SC0[0]:HE1:SE1] takes:
> >  (&tp->lock){+...}, at: [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
> > {in-hardirq-W} state was registered at:
> >   [<c0138eeb>] __lock_acquire+0x949/0x11ac
> >   [<c01397e7>] lock_acquire+0x99/0xb2
> >   [<c0452ff3>] _spin_lock+0x35/0x42
> >   [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
> >   [<c0147a5d>] handle_IRQ_event+0x28/0x59
> >   [<c01493ca>] handle_level_irq+0xad/0x10b
> >   [<c0105a13>] do_IRQ+0x93/0xd0
> >   [<c010441e>] common_interrupt+0x2e/0x34
> ...
> > other info that might help us debug this:
> > 1 lock held by ifconfig/5492:
> >  #0:  (rtnl_mutex){--..}, at: [<c0451778>] mutex_lock+0x1c/0x1f
> > 
> > stack backtrace:
> ...
> >  [<c0452ff3>] _spin_lock+0x35/0x42
> >  [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
> >  [<c01480fd>] free_irq+0x11b/0x146
> >  [<de871d59>] rtl8139_close+0x8a/0x14a [8139too]
> >  [<c03bde63>] dev_close+0x57/0x74
> ...
> 
> It looks like this was possible after David's fix, which really
> enabled running of the handler in free_irq, but before Andrew's patch
> disabling local irqs for this time.
> 
> So, this bug should be fixed, but IMHO similar problem is possible in
> request_irq. And, I think, this is not only about lockdep complaining,
> but real lockup possibility, because any locks in such a handler are
> taken in another, not expected for them context, and could be
> vulnerable (especially with softirqs, but probably hardirqs as well).
> 
> Reported-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> ---
> 
> diff -Nurp 2.6.23-rc3-mm1-/kernel/irq/manage.c 2.6.23-rc3-mm1/kernel/irq/manage.c
> --- 2.6.23-rc3-mm1-/kernel/irq/manage.c	2007-08-22 13:58:58.000000000 +0200
> +++ 2.6.23-rc3-mm1/kernel/irq/manage.c	2007-08-22 14:12:21.000000000 +0200
> @@ -546,14 +546,11 @@ int request_irq(unsigned int irq, irq_ha
>  		 * We do this before actually registering it, to make sure that
>  		 * a 'real' IRQ doesn't run in parallel with our fake
>  		 */
> -		if (irqflags & IRQF_DISABLED) {
> -			unsigned long flags;
> +		unsigned long flags;
>  
> -			local_irq_save(flags);
> -			handler(irq, dev_id);
> -			local_irq_restore(flags);
> -		} else
> -			handler(irq, dev_id);
> +		local_irq_save(flags);
> +		handler(irq, dev_id);
> +		local_irq_restore(flags);
>  	}
>  #endif

I tested your patch and it still happens. Dmesg info from patched kernel attached.
I coulnd't reproduce that on 2.6.23-rc3-mm1 - but on 2.6.23-rc2-mm2 it is easily
reproducible.

If you need more info, test some patches, etc. - just mail me.

Pozdrawiam,

	Mariusz


=========================================================
[ INFO: possible irq lock inversion dependency detected ]
2.6.23-rc2-mm2 #2
---------------------------------------------------------
runscript.sh/5065 just changed the state of lock:
 (_xmit_ETHER){-+..}, at: [<c03cb659>] dev_watchdog+0x17/0xcc
but this lock took another, soft-irq-unsafe lock in the past:
 (&tp->lock){--..}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
1 lock held by runscript.sh/5065:
 #0:  (&mm->mmap_sem){----}, at: [<c0454569>] do_page_fault+0x159/0x6f0

the first lock's dependencies:
-> (_xmit_ETHER){-+..} ops: 21 {
   initial-use  at:
                        [<c0138ea9>] __lock_acquire+0x217/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c045281a>] _spin_lock_bh+0x3a/0x47
                        [<c03bc096>] dev_set_rx_mode+0x14/0x3b
                        [<c03bc59f>] dev_change_flags+0x68/0x190
                        [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                        [<c03fd432>] inet_ioctl+0x56/0x71
                        [<c03b151a>] sock_ioctl+0xa5/0x1d4
                        [<c0178a42>] do_ioctl+0x22/0x71
                        [<c0178ae6>] vfs_ioctl+0x55/0x29e
                        [<c0178d62>] sys_ioctl+0x33/0x69
                        [<c01041da>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   in-softirq-W at:
                        [<c0139384>] __lock_acquire+0x6f2/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c04527d3>] _spin_lock+0x35/0x42
                        [<c03cb659>] dev_watchdog+0x17/0xcc
                        [<c01224b7>] run_timer_softirq+0x14b/0x1a9
                        [<c011ecc2>] __do_softirq+0x5b/0xb2
                        [<c011ed66>] do_softirq+0x4d/0x4f
                        [<c011f04b>] irq_exit+0x48/0x4a
                        [<c01058f8>] do_IRQ+0x98/0xd0
                        [<c010444e>] common_interrupt+0x2e/0x34
                        [<c014b039>] find_lock_page+0x9b/0xa5
                        [<c014d680>] filemap_fault+0x188/0x4d9
                        [<c015760d>] __do_fault+0xb7/0x444
                        [<c0159164>] handle_mm_fault+0x18a/0x6fc
                        [<c0454864>] do_page_fault+0x454/0x6f0
                        [<c0453102>] error_code+0x6a/0x70
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c01393d0>] __lock_acquire+0x73e/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c045281a>] _spin_lock_bh+0x3a/0x47
                        [<c03bc096>] dev_set_rx_mode+0x14/0x3b
                        [<c03bc59f>] dev_change_flags+0x68/0x190
                        [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                        [<c03fd432>] inet_ioctl+0x56/0x71
                        [<c03b151a>] sock_ioctl+0xa5/0x1d4
                        [<c0178a42>] do_ioctl+0x22/0x71
                        [<c0178ae6>] vfs_ioctl+0x55/0x29e
                        [<c0178d62>] sys_ioctl+0x33/0x69
                        [<c01041da>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<c087e9e8>] netdev_xmit_lock_key+0x8/0x1c0
 -> (&tp->lock){--..} ops: 44 {
    initial-use  at:
                          [<c0138ea9>] __lock_acquire+0x217/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c04527d3>] _spin_lock+0x35/0x42
                          [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                          [<c0148bae>] request_irq+0xd6/0xf8
                          [<de87152d>] rtl8139_open+0x2f/0x1e2 [8139too]
                          [<c03be7fd>] dev_open+0x37/0x76
                          [<c03bc5c5>] dev_change_flags+0x8e/0x190
                          [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                          [<c03fd432>] inet_ioctl+0x56/0x71
                          [<c03b151a>] sock_ioctl+0xa5/0x1d4
                          [<c0178a42>] do_ioctl+0x22/0x71
                          [<c0178ae6>] vfs_ioctl+0x55/0x29e
                          [<c0178d62>] sys_ioctl+0x33/0x69
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    softirq-on-W at:
                          [<c01393f9>] __lock_acquire+0x767/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c04527d3>] _spin_lock+0x35/0x42
                          [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                          [<c01487ed>] free_irq+0x11b/0x146
                          [<de871c90>] rtl8139_close+0x8a/0x14a [8139too]
                          [<c03bd5c3>] dev_close+0x57/0x74
                          [<c03bc5c5>] dev_change_flags+0x8e/0x190
                          [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                          [<c03fd432>] inet_ioctl+0x56/0x71
                          [<c03b151a>] sock_ioctl+0xa5/0x1d4
                          [<c0178a42>] do_ioctl+0x22/0x71
                          [<c0178ae6>] vfs_ioctl+0x55/0x29e
                          [<c0178d62>] sys_ioctl+0x33/0x69
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                          [<c01393d0>] __lock_acquire+0x73e/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c04527d3>] _spin_lock+0x35/0x42
                          [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                          [<c01487ed>] free_irq+0x11b/0x146
                          [<de871c90>] rtl8139_close+0x8a/0x14a [8139too]
                          [<c03bd5c3>] dev_close+0x57/0x74
                          [<c03bc5c5>] dev_change_flags+0x8e/0x190
                          [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                          [<c03fd432>] inet_ioctl+0x56/0x71
                          [<c03b151a>] sock_ioctl+0xa5/0x1d4
                          [<c0178a42>] do_ioctl+0x22/0x71
                          [<c0178ae6>] vfs_ioctl+0x55/0x29e
                          [<c0178d62>] sys_ioctl+0x33/0x69
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<de875190>] __key.19796+0x0/0xffffd3c9 [8139too]
 ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<de870275>] rtl8139_set_rx_mode+0x1e/0x166 [8139too]
   [<c03bbe62>] __dev_set_rx_mode+0x24/0x85
   [<c03bc0a8>] dev_set_rx_mode+0x26/0x3b
   [<c03be820>] dev_open+0x5a/0x76
   [<c03bc5c5>] dev_change_flags+0x8e/0x190
   [<c03fcb4c>] devinet_ioctl+0x4af/0x652
   [<c03fd432>] inet_ioctl+0x56/0x71
   [<c03b151a>] sock_ioctl+0xa5/0x1d4
   [<c0178a42>] do_ioctl+0x22/0x71
   [<c0178ae6>] vfs_ioctl+0x55/0x29e
   [<c0178d62>] sys_ioctl+0x33/0x69
   [<c01041da>] sysenter_past_esp+0x5f/0x99
   [<ffffffff>] 0xffffffff

 -> (&priv->lock){++..} ops: 103 {
    initial-use  at:
                          [<c0138ea9>] __lock_acquire+0x217/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c04529bc>] _spin_lock_irq+0x3b/0x48
                          [<ded03256>] orinoco_init+0x8f5/0xbbd [orinoco]
                          [<c03bdbce>] register_netdevice+0x13a/0x3f8
                          [<c03bdebe>] register_netdev+0x32/0x3f
                          [<ded2c4bb>] orinoco_cs_probe+0x368/0x3df [orinoco_cs]
                          [<ded378d9>] pcmcia_device_probe+0xc9/0x14c [pcmcia]
                          [<c02f323f>] driver_probe_device+0xa6/0x198
                          [<c02f3482>] __driver_attach+0xa2/0xa4
                          [<c02f270a>] bus_for_each_dev+0x43/0x61
                          [<c02f30c1>] driver_attach+0x19/0x1b
                          [<c02f2a79>] bus_add_driver+0x7e/0x1a5
                          [<c02f362f>] driver_register+0x45/0x75
                          [<ded38560>] pcmcia_register_driver+0xdb/0x12f [pcmcia]
                          [<de87c024>] 0xde87c024
                          [<c0140a47>] sys_init_module+0xc4/0x1622
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    in-hardirq-W at:
                          [<c01395db>] __lock_acquire+0x949/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                          [<ded03bb4>] orinoco_interrupt+0x3f/0x1219 [orinoco]
                          [<c014814d>] handle_IRQ_event+0x28/0x59
                          [<c0149a0a>] handle_level_irq+0xad/0x10b
                          [<c01058f3>] do_IRQ+0x93/0xd0
                          [<c010444e>] common_interrupt+0x2e/0x34
                          [<ded06a99>] orinoco_get_wireless_stats+0xeb/0x140 [orinoco]
                          [<c042b2aa>] get_wireless_stats+0x1a/0x21
                          [<c042bf59>] wireless_seq_show+0x20/0x143
                          [<c0187347>] seq_read+0x1af/0x2b8
                          [<c01a1ec2>] proc_reg_read+0x57/0x78
                          [<c016d771>] vfs_read+0xaa/0x147
                          [<c016db96>] sys_read+0x3d/0x7b
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    in-softirq-W at:
                          [<c0139384>] __lock_acquire+0x6f2/0x11ac
                          [<c0139ed7>] lock_acquire+0x99/0xb2
                          [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                          [<ded03bb4>] orinoco_interrupt+0x3f/0x1219 [orinoco]
                          [<c014814d>] handle_IRQ_event+0x28/0x59
                          [<c0149a0a>] handle_level_irq+0xad/0x10b
                          [<c01058f3>] do_IRQ+0x93/0xd0
                          [<c010444e>] common_interrupt+0x2e/0x34
                          [<c011ed66>] do_softirq+0x4d/0x4f
                          [<c011f04b>] irq_exit+0x48/0x4a
                          [<c01058f8>] do_IRQ+0x98/0xd0
                          [<c010444e>] common_interrupt+0x2e/0x34
                          [<ded06a99>] orinoco_get_wireless_stats+0xeb/0x140 [orinoco]
                          [<c042b2aa>] get_wireless_stats+0x1a/0x21
                          [<c042bf59>] wireless_seq_show+0x20/0x143
                          [<c0187347>] seq_read+0x1af/0x2b8
                          [<c01a1ec2>] proc_reg_read+0x57/0x78
                          [<c016d771>] vfs_read+0xaa/0x147
                          [<c016db96>] sys_read+0x3d/0x7b
                          [<c01041da>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<ded0a298>] __key.20430+0x0/0xffffc9cd [orinoco]
  -> (lweventlist_lock){+...} ops: 8 {
     initial-use  at:
                            [<c0138ea9>] __lock_acquire+0x217/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c03c78cb>] linkwatch_add_event+0x10/0x31
                            [<c03c79aa>] linkwatch_fire_event+0x35/0x37
                            [<c03cb35a>] netif_carrier_off+0x19/0x20
                            [<ded023b5>] alloc_orinocodev+0x181/0x19c [orinoco]
                            [<ded2c170>] orinoco_cs_probe+0x1d/0x3df [orinoco_cs]
                            [<ded378d9>] pcmcia_device_probe+0xc9/0x14c [pcmcia]
                            [<c02f323f>] driver_probe_device+0xa6/0x198
                            [<c02f3482>] __driver_attach+0xa2/0xa4
                            [<c02f270a>] bus_for_each_dev+0x43/0x61
                            [<c02f30c1>] driver_attach+0x19/0x1b
                            [<c02f2a79>] bus_add_driver+0x7e/0x1a5
                            [<c02f362f>] driver_register+0x45/0x75
                            [<ded38560>] pcmcia_register_driver+0xdb/0x12f [pcmcia]
                            [<de87c024>] 0xde87c024
                            [<c0140a47>] sys_init_module+0xc4/0x1622
                            [<c01041da>] sysenter_past_esp+0x5f/0x99
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c01395db>] __lock_acquire+0x949/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c03c78cb>] linkwatch_add_event+0x10/0x31
                            [<c03c79aa>] linkwatch_fire_event+0x35/0x37
                            [<c03cb38a>] netif_carrier_on+0x29/0x2b
                            [<ded04bdc>] orinoco_interrupt+0x1067/0x1219 [orinoco]
                            [<c014814d>] handle_IRQ_event+0x28/0x59
                            [<c0149a0a>] handle_level_irq+0xad/0x10b
                            [<c01058f3>] do_IRQ+0x93/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c03706bb>] cpuidle_idle_call+0x74/0x99
                            [<c01025e4>] cpu_idle+0x87/0x89
                            [<c044f204>] rest_init+0x60/0x62
                            [<c05fcad5>] start_kernel+0x23a/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c05e4990>] lweventlist_lock+0x10/0x20
  ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<c03c78cb>] linkwatch_add_event+0x10/0x31
   [<c03c79aa>] linkwatch_fire_event+0x35/0x37
   [<c03cb38a>] netif_carrier_on+0x29/0x2b
   [<ded04bdc>] orinoco_interrupt+0x1067/0x1219 [orinoco]
   [<c014814d>] handle_IRQ_event+0x28/0x59
   [<c0149a0a>] handle_level_irq+0xad/0x10b
   [<c01058f3>] do_IRQ+0x93/0xd0
   [<c010444e>] common_interrupt+0x2e/0x34
   [<c03706bb>] cpuidle_idle_call+0x74/0x99
   [<c01025e4>] cpu_idle+0x87/0x89
   [<c044f204>] rest_init+0x60/0x62
   [<c05fcad5>] start_kernel+0x23a/0x2c5
   [<00000000>] 0x0
   [<ffffffff>] 0xffffffff

  -> (&cwq->lock){++..} ops: 4755 {
     initial-use  at:
                            [<c0138ea9>] __lock_acquire+0x217/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c0129002>] __queue_work+0xf/0x2d
                            [<c012909f>] queue_work+0x57/0x90
                            [<c0128714>] call_usermodehelper_exec+0xce/0xe1
                            [<c0265375>] kobject_uevent_env+0x34d/0x449
                            [<c026547b>] kobject_uevent+0xa/0xf
                            [<c0264b59>] kset_register+0x32/0x38
                            [<c0264b67>] subsystem_register+0x8/0xa
                            [<c02f2c8a>] bus_register+0x65/0x1f3
                            [<c0611db6>] platform_bus_init+0x23/0x38
                            [<c0611e0c>] driver_init+0x1c/0x31
                            [<c05fc68d>] kernel_init+0x5d/0x26b
                            [<c010454b>] kernel_thread_helper+0x7/0x1c
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c01395db>] __lock_acquire+0x949/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c0129002>] __queue_work+0xf/0x2d
                            [<c012909f>] queue_work+0x57/0x90
                            [<c029238a>] acpi_os_execute+0xae/0xcb
                            [<c02aa216>] acpi_ec_gpe_handler+0x4d/0x5e
                            [<c0297f41>] acpi_ev_gpe_dispatch+0x4b/0x115
                            [<c0298243>] acpi_ev_gpe_detect+0x9a/0xe1
                            [<c0296979>] acpi_ev_sci_xrupt_handler+0x15/0x1d
                            [<c0291a9e>] acpi_irq+0xe/0x18
                            [<c014814d>] handle_IRQ_event+0x28/0x59
                            [<c0149a0a>] handle_level_irq+0xad/0x10b
                            [<c01058f3>] do_IRQ+0x93/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c01025e4>] cpu_idle+0x87/0x89
                            [<c044f204>] rest_init+0x60/0x62
                            [<c05fcad5>] start_kernel+0x23a/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c0139384>] __lock_acquire+0x6f2/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c0129002>] __queue_work+0xf/0x2d
                            [<c0129044>] delayed_work_timer_fn+0x24/0x28
                            [<c01224b7>] run_timer_softirq+0x14b/0x1a9
                            [<c011ecc2>] __do_softirq+0x5b/0xb2
                            [<c011ed66>] do_softirq+0x4d/0x4f
                            [<c011f04b>] irq_exit+0x48/0x4a
                            [<c01058f8>] do_IRQ+0x98/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c0452cac>] _spin_unlock+0x16/0x4d
                            [<c02638ce>] _atomic_dec_and_lock+0x2e/0x50
                            [<c017e962>] dput+0x36/0x101
                            [<c0176080>] __link_path_walk+0x8de/0xe06
                            [<c0176603>] link_path_walk+0x5b/0xe0
                            [<c01766a0>] path_walk+0x18/0x1a
                            [<c01768b2>] do_path_lookup+0x8f/0x21c
                            [<c017757a>] __path_lookup_intent_open+0x44/0x99
                            [<c0177658>] path_lookup_open+0x21/0x27
                            [<c0171056>] open_exec+0x27/0xac
                            [<c0172776>] do_execve+0x34/0x181
                            [<c0102752>] sys_execve+0x48/0x98
                            [<c0104256>] syscall_call+0x7/0xb
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0657ae8>] __key.11148+0x0/0x8
   -> (&q->lock){++..} ops: 69175 {
      initial-use  at:
                              [<c0138ea9>] __lock_acquire+0x217/0x11ac
                              [<c0139ed7>] lock_acquire+0x99/0xb2
                              [<c04529bc>] _spin_lock_irq+0x3b/0x48
                              [<c044fce5>] wait_for_completion+0x24/0xb5
                              [<c012c1d1>] kthread_create+0x69/0xa8
                              [<c0606fcc>] cpu_callback+0x48/0xa3
                              [<c0607043>] spawn_ksoftirqd+0x1c/0x4e
                              [<c05fc66c>] kernel_init+0x3c/0x26b
                              [<c010454b>] kernel_thread_helper+0x7/0x1c
                              [<ffffffff>] 0xffffffff
      in-hardirq-W at:
                              [<c01395db>] __lock_acquire+0x949/0x11ac
                              [<c0139ed7>] lock_acquire+0x99/0xb2
                              [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                              [<c0113d3b>] __wake_up+0x15/0x42
                              [<c02aa1ef>] acpi_ec_gpe_handler+0x26/0x5e
                              [<c0297f41>] acpi_ev_gpe_dispatch+0x4b/0x115
                              [<c0298243>] acpi_ev_gpe_detect+0x9a/0xe1
                              [<c0296979>] acpi_ev_sci_xrupt_handler+0x15/0x1d
                              [<c0291a9e>] acpi_irq+0xe/0x18
                              [<c014814d>] handle_IRQ_event+0x28/0x59
                              [<c0149a0a>] handle_level_irq+0xad/0x10b
                              [<c01058f3>] do_IRQ+0x93/0xd0
                              [<c010444e>] common_interrupt+0x2e/0x34
                              [<c01025e4>] cpu_idle+0x87/0x89
                              [<c044f204>] rest_init+0x60/0x62
                              [<c05fcad5>] start_kernel+0x23a/0x2c5
                              [<00000000>] 0x0
                              [<ffffffff>] 0xffffffff
      in-softirq-W at:
                              [<c0139384>] __lock_acquire+0x6f2/0x11ac
                              [<c0139ed7>] lock_acquire+0x99/0xb2
                              [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                              [<c0113c7c>] complete+0x15/0x4b
                              [<c0129ebe>] wakeme_after_rcu+0xb/0xd
                              [<c012a013>] __rcu_process_callbacks+0x69/0x1cf
                              [<c012a18b>] rcu_process_callbacks+0x12/0x23
                              [<c011eda3>] tasklet_action+0x3b/0x7b
                              [<c011ecc2>] __do_softirq+0x5b/0xb2
                              [<c011ed66>] do_softirq+0x4d/0x4f
                              [<c011f04b>] irq_exit+0x48/0x4a
                              [<c01058f8>] do_IRQ+0x98/0xd0
                              [<c010444e>] common_interrupt+0x2e/0x34
                              [<c01025e4>] cpu_idle+0x87/0x89
                              [<c044f204>] rest_init+0x60/0x62
                              [<c05fcad5>] start_kernel+0x23a/0x2c5
                              [<00000000>] 0x0
                              [<ffffffff>] 0xffffffff
    }
    ... key      at: [<c0657f30>] __key.11466+0x0/0x8
    -> (&rq->rq_lock_key){++..} ops: 212030 {
       initial-use  at:
                                [<c0138ea9>] __lock_acquire+0x217/0x11ac
                                [<c0139ed7>] lock_acquire+0x99/0xb2
                                [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                                [<c060664a>] init_idle+0x40/0x6d
                                [<c06067e0>] sched_init+0x169/0x17c
                                [<c05fc970>] start_kernel+0xd5/0x2c5
                                [<00000000>] 0x0
                                [<ffffffff>] 0xffffffff
       in-hardirq-W at:
                                [<c01395db>] __lock_acquire+0x949/0x11ac
                                [<c0139ed7>] lock_acquire+0x99/0xb2
                                [<c04527d3>] _spin_lock+0x35/0x42
                                [<c01157f3>] scheduler_tick+0x20/0x192
                                [<c0122c31>] update_process_times+0x43/0x62
                                [<c0134325>] tick_periodic+0x24/0x75
                                [<c013438e>] tick_handle_periodic+0x18/0x7a
                                [<c01064ae>] timer_interrupt+0xe/0x15
                                [<c014814d>] handle_IRQ_event+0x28/0x59
                                [<c0149a0a>] handle_level_irq+0xad/0x10b
                                [<c01058f3>] do_IRQ+0x93/0xd0
                                [<c010444e>] common_interrupt+0x2e/0x34
                                [<c014890a>] setup_irq+0xf2/0x20d
                                [<c060656f>] time_init_hook+0x19/0x1b
                                [<c05ffcc8>] hpet_time_init+0xd/0x15
                                [<c05fca70>] start_kernel+0x1d5/0x2c5
                                [<00000000>] 0x0
                                [<ffffffff>] 0xffffffff
       in-softirq-W at:
                                [<c0139384>] __lock_acquire+0x6f2/0x11ac
                                [<c0139ed7>] lock_acquire+0x99/0xb2
                                [<c04527d3>] _spin_lock+0x35/0x42
                                [<c01157f3>] scheduler_tick+0x20/0x192
                                [<c0122c31>] update_process_times+0x43/0x62
                                [<c0134325>] tick_periodic+0x24/0x75
                                [<c013438e>] tick_handle_periodic+0x18/0x7a
                                [<c01064ae>] timer_interrupt+0xe/0x15
                                [<c014814d>] handle_IRQ_event+0x28/0x59
                                [<c0149a0a>] handle_level_irq+0xad/0x10b
                                [<c01058f3>] do_IRQ+0x93/0xd0
                                [<c010444e>] common_interrupt+0x2e/0x34
                                [<c011ed66>] do_softirq+0x4d/0x4f
                                [<c011f04b>] irq_exit+0x48/0x4a
                                [<c01058f8>] do_IRQ+0x98/0xd0
                                [<c010444e>] common_interrupt+0x2e/0x34
                                [<c029cf88>] acpi_ex_system_io_space_handler+0x3f/0x45
                                [<c0296612>] acpi_ev_address_space_dispatch+0x12f/0x170
                                [<c029a374>] acpi_ex_access_region+0x1a7/0x1b9
                                [<c029a497>] acpi_ex_field_datum_io+0x111/0x198
                                [<c029a812>] acpi_ex_write_with_update_rule+0xf7/0x100
                                [<c029aa97>] acpi_ex_insert_into_field+0x27c/0x289
                                [<c02991cc>] acpi_ex_write_data_to_field+0x207/0x21f
                                [<c029d1f8>] acpi_ex_store_object_to_node+0x70/0xa5
                                [<c029d387>] acpi_ex_store+0xd5/0x216
                                [<c029b2e6>] acpi_ex_opcode_1A_1T_1R+0x3a8/0x504
                                [<c0293f74>] acpi_ds_exec_end_op+0xc1/0x3bd
                                [<c02a2238>] acpi_ps_parse_loop+0x539/0x6d9
                                [<c02a16fa>] acpi_ps_parse_aml+0x68/0x235
                                [<c02a291c>] acpi_ps_execute_method+0x111/0x1b5
                                [<c029fd5b>] acpi_ns_evaluate+0x93/0xe8
                                [<c02a509c>] acpi_ut_evaluate_object+0x55/0x15f
                                [<c02a521f>] acpi_ut_execute_STA+0x1d/0x49
                                [<c029f7e7>] acpi_ns_get_device_callback+0x5a/0x11c
                                [<c02a0e74>] acpi_ns_walk_namespace+0xf0/0x10c
                                [<c029f711>] acpi_get_devices+0x47/0x5d
                                [<c06100a6>] pnpacpi_init+0x5e/0x8b
                                [<c05fc6c7>] kernel_init+0x97/0x26b
                                [<c010454b>] kernel_thread_helper+0x7/0x1c
                                [<ffffffff>] 0xffffffff
     }
     ... key      at: [<c0635d28>] per_cpu__runqueues+0x468/0x470
    ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c04527d3>] _spin_lock+0x35/0x42
   [<c0114ec2>] task_rq_lock+0x28/0x40
   [<c011504c>] try_to_wake_up+0x18/0x92
   [<c01150d1>] default_wake_function+0xb/0xd
   [<c011284b>] __wake_up_common+0x39/0x59
   [<c0113ca1>] complete+0x3a/0x4b
   [<c012c037>] kthread+0x1f/0x58
   [<c010454b>] kernel_thread_helper+0x7/0x1c
   [<ffffffff>] 0xffffffff

   ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<c0113d3b>] __wake_up+0x15/0x42
   [<c0128c6b>] insert_work+0x60/0x75
   [<c0129012>] __queue_work+0x1f/0x2d
   [<c012909f>] queue_work+0x57/0x90
   [<c0128714>] call_usermodehelper_exec+0xce/0xe1
   [<c0265375>] kobject_uevent_env+0x34d/0x449
   [<c026547b>] kobject_uevent+0xa/0xf
   [<c0264b59>] kset_register+0x32/0x38
   [<c0264b67>] subsystem_register+0x8/0xa
   [<c02f2c8a>] bus_register+0x65/0x1f3
   [<c0611db6>] platform_bus_init+0x23/0x38
   [<c0611e0c>] driver_init+0x1c/0x31
   [<c05fc68d>] kernel_init+0x5d/0x26b
   [<c010454b>] kernel_thread_helper+0x7/0x1c
   [<ffffffff>] 0xffffffff

  ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<c0129002>] __queue_work+0xf/0x2d
   [<c012909f>] queue_work+0x57/0x90
   [<c01294af>] queue_delayed_work+0x27/0x48
   [<c01294f2>] schedule_delayed_work+0x22/0x26
   [<c03c792c>] linkwatch_schedule_work+0x40/0x89
   [<c03c7999>] linkwatch_fire_event+0x24/0x37
   [<c03cb38a>] netif_carrier_on+0x29/0x2b
   [<ded04bdc>] orinoco_interrupt+0x1067/0x1219 [orinoco]
   [<c014814d>] handle_IRQ_event+0x28/0x59
   [<c0149a0a>] handle_level_irq+0xad/0x10b
   [<c01058f3>] do_IRQ+0x93/0xd0
   [<c010444e>] common_interrupt+0x2e/0x34
   [<c03706bb>] cpuidle_idle_call+0x74/0x99
   [<c01025e4>] cpu_idle+0x87/0x89
   [<c044f204>] rest_init+0x60/0x62
   [<c05fcad5>] start_kernel+0x23a/0x2c5
   [<00000000>] 0x0
   [<ffffffff>] 0xffffffff

  -> (base_lock_keys + cpu){++..} ops: 85554 {
     initial-use  at:
                            [<c0138ea9>] __lock_acquire+0x217/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c01229f6>] lock_timer_base+0x41/0x66
                            [<c0122ab8>] __mod_timer+0x3b/0xc5
                            [<c0122bea>] mod_timer+0x47/0x4b
                            [<c0611091>] con_init+0x24b/0x27e
                            [<c061075a>] console_init+0x20/0x2e
                            [<c05fca30>] start_kernel+0x195/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c01395db>] __lock_acquire+0x949/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c01229f6>] lock_timer_base+0x41/0x66
                            [<c0122a47>] del_timer+0x2c/0x62
                            [<c0302a7b>] ide_intr+0x72/0x1f0
                            [<c014814d>] handle_IRQ_event+0x28/0x59
                            [<c0149a0a>] handle_level_irq+0xad/0x10b
                            [<c01058f3>] do_IRQ+0x93/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c01025e4>] cpu_idle+0x87/0x89
                            [<c044f204>] rest_init+0x60/0x62
                            [<c05fcad5>] start_kernel+0x23a/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c0139384>] __lock_acquire+0x6f2/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c04529bc>] _spin_lock_irq+0x3b/0x48
                            [<c0122395>] run_timer_softirq+0x29/0x1a9
                            [<c011ecc2>] __do_softirq+0x5b/0xb2
                            [<c011ed66>] do_softirq+0x4d/0x4f
                            [<c011f04b>] irq_exit+0x48/0x4a
                            [<c01058f8>] do_IRQ+0x98/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c014890a>] setup_irq+0xf2/0x20d
                            [<c060656f>] time_init_hook+0x19/0x1b
                            [<c05ffcc8>] hpet_time_init+0xd/0x15
                            [<c05fca70>] start_kernel+0x1d5/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0657a96>] base_lock_keys+0x0/0xa
  ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<c01229f6>] lock_timer_base+0x41/0x66
   [<c0122ab8>] __mod_timer+0x3b/0xc5
   [<c0122bea>] mod_timer+0x47/0x4b
   [<c03cae57>] __netdev_watchdog_up+0x37/0x50
   [<c03cb380>] netif_carrier_on+0x1f/0x2b
   [<ded04bdc>] orinoco_interrupt+0x1067/0x1219 [orinoco]
   [<c014814d>] handle_IRQ_event+0x28/0x59
   [<c0149a0a>] handle_level_irq+0xad/0x10b
   [<c01058f3>] do_IRQ+0x93/0xd0
   [<c010444e>] common_interrupt+0x2e/0x34
   [<c03706bb>] cpuidle_idle_call+0x74/0x99
   [<c01025e4>] cpu_idle+0x87/0x89
   [<c044f204>] rest_init+0x60/0x62
   [<c05fcad5>] start_kernel+0x23a/0x2c5
   [<00000000>] 0x0
   [<ffffffff>] 0xffffffff

  -> (&list->lock#2){.+..} ops: 12 {
     initial-use  at:
                            [<c0138ea9>] __lock_acquire+0x217/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c03b70ab>] skb_queue_tail+0x14/0x33
                            [<c042b66b>] wireless_send_event+0x348/0x369
                            [<c042b9a9>] ioctl_standard_call+0x1b2/0x34d
                            [<c042be9e>] wext_handle_ioctl+0x35a/0x3e4
                            [<c03be755>] dev_ioctl+0x31e/0x325
                            [<c03b152c>] sock_ioctl+0xb7/0x1d4
                            [<c0178a42>] do_ioctl+0x22/0x71
                            [<c0178ae6>] vfs_ioctl+0x55/0x29e
                            [<c0178d62>] sys_ioctl+0x33/0x69
                            [<c01041da>] sysenter_past_esp+0x5f/0x99
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c0139384>] __lock_acquire+0x6f2/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c03b715c>] skb_dequeue+0x12/0x50
                            [<c042b31d>] wireless_nlevent_process+0x2d/0x33
                            [<c011eda3>] tasklet_action+0x3b/0x7b
                            [<c011ecc2>] __do_softirq+0x5b/0xb2
                            [<c011ed66>] do_softirq+0x4d/0x4f
                            [<c011f04b>] irq_exit+0x48/0x4a
                            [<c01058f8>] do_IRQ+0x98/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<ded028e3>] orinoco_ioctl_commit+0x8e/0x10c [orinoco]
                            [<c042b2e0>] call_commit_handler+0x2f/0x3f
                            [<c042b9c2>] ioctl_standard_call+0x1cb/0x34d
                            [<c042be9e>] wext_handle_ioctl+0x35a/0x3e4
                            [<c03be755>] dev_ioctl+0x31e/0x325
                            [<c03b152c>] sock_ioctl+0xb7/0x1d4
                            [<c0178a42>] do_ioctl+0x22/0x71
                            [<c0178ae6>] vfs_ioctl+0x55/0x29e
                            [<c0178d62>] sys_ioctl+0x33/0x69
                            [<c01041da>] sysenter_past_esp+0x5f/0x99
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0884a80>] __key.13323+0x0/0x20
  ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<c03b70ab>] skb_queue_tail+0x14/0x33
   [<c042b66b>] wireless_send_event+0x348/0x369
   [<ded03b69>] orinoco_send_wevents+0x9a/0xa6 [orinoco]
   [<c0128b28>] run_workqueue+0x110/0x1f3
   [<c0129648>] worker_thread+0x9a/0xf2
   [<c012c04e>] kthread+0x36/0x58
   [<c010454b>] kernel_thread_helper+0x7/0x1c
   [<ffffffff>] 0xffffffff

  -> (&rq->rq_lock_key){++..} ops: 212030 {
     initial-use  at:
                            [<c0138ea9>] __lock_acquire+0x217/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
                            [<c060664a>] init_idle+0x40/0x6d
                            [<c06067e0>] sched_init+0x169/0x17c
                            [<c05fc970>] start_kernel+0xd5/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-hardirq-W at:
                            [<c01395db>] __lock_acquire+0x949/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c04527d3>] _spin_lock+0x35/0x42
                            [<c01157f3>] scheduler_tick+0x20/0x192
                            [<c0122c31>] update_process_times+0x43/0x62
                            [<c0134325>] tick_periodic+0x24/0x75
                            [<c013438e>] tick_handle_periodic+0x18/0x7a
                            [<c01064ae>] timer_interrupt+0xe/0x15
                            [<c014814d>] handle_IRQ_event+0x28/0x59
                            [<c0149a0a>] handle_level_irq+0xad/0x10b
                            [<c01058f3>] do_IRQ+0x93/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c014890a>] setup_irq+0xf2/0x20d
                            [<c060656f>] time_init_hook+0x19/0x1b
                            [<c05ffcc8>] hpet_time_init+0xd/0x15
                            [<c05fca70>] start_kernel+0x1d5/0x2c5
                            [<00000000>] 0x0
                            [<ffffffff>] 0xffffffff
     in-softirq-W at:
                            [<c0139384>] __lock_acquire+0x6f2/0x11ac
                            [<c0139ed7>] lock_acquire+0x99/0xb2
                            [<c04527d3>] _spin_lock+0x35/0x42
                            [<c01157f3>] scheduler_tick+0x20/0x192
                            [<c0122c31>] update_process_times+0x43/0x62
                            [<c0134325>] tick_periodic+0x24/0x75
                            [<c013438e>] tick_handle_periodic+0x18/0x7a
                            [<c01064ae>] timer_interrupt+0xe/0x15
                            [<c014814d>] handle_IRQ_event+0x28/0x59
                            [<c0149a0a>] handle_level_irq+0xad/0x10b
                            [<c01058f3>] do_IRQ+0x93/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c011ed66>] do_softirq+0x4d/0x4f
                            [<c011f04b>] irq_exit+0x48/0x4a
                            [<c01058f8>] do_IRQ+0x98/0xd0
                            [<c010444e>] common_interrupt+0x2e/0x34
                            [<c029cf88>] acpi_ex_system_io_space_handler+0x3f/0x45
                            [<c0296612>] acpi_ev_address_space_dispatch+0x12f/0x170
                            [<c029a374>] acpi_ex_access_region+0x1a7/0x1b9
                            [<c029a497>] acpi_ex_field_datum_io+0x111/0x198
                            [<c029a812>] acpi_ex_write_with_update_rule+0xf7/0x100
                            [<c029aa97>] acpi_ex_insert_into_field+0x27c/0x289
                            [<c02991cc>] acpi_ex_write_data_to_field+0x207/0x21f
                            [<c029d1f8>] acpi_ex_store_object_to_node+0x70/0xa5
                            [<c029d387>] acpi_ex_store+0xd5/0x216
                            [<c029b2e6>] acpi_ex_opcode_1A_1T_1R+0x3a8/0x504
                            [<c0293f74>] acpi_ds_exec_end_op+0xc1/0x3bd
                            [<c02a2238>] acpi_ps_parse_loop+0x539/0x6d9
                            [<c02a16fa>] acpi_ps_parse_aml+0x68/0x235
                            [<c02a291c>] acpi_ps_execute_method+0x111/0x1b5
                            [<c029fd5b>] acpi_ns_evaluate+0x93/0xe8
                            [<c02a509c>] acpi_ut_evaluate_object+0x55/0x15f
                            [<c02a521f>] acpi_ut_execute_STA+0x1d/0x49
                            [<c029f7e7>] acpi_ns_get_device_callback+0x5a/0x11c
                            [<c02a0e74>] acpi_ns_walk_namespace+0xf0/0x10c
                            [<c029f711>] acpi_get_devices+0x47/0x5d
                            [<c06100a6>] pnpacpi_init+0x5e/0x8b
                            [<c05fc6c7>] kernel_init+0x97/0x26b
                            [<c010454b>] kernel_thread_helper+0x7/0x1c
                            [<ffffffff>] 0xffffffff
   }
   ... key      at: [<c0635d28>] per_cpu__runqueues+0x468/0x470
  ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c04527d3>] _spin_lock+0x35/0x42
   [<c0114ec2>] task_rq_lock+0x28/0x40
   [<c011504c>] try_to_wake_up+0x18/0x92
   [<c01150ee>] wake_up_process+0xf/0x11
   [<c011f5cc>] __tasklet_schedule+0x6d/0x6f
   [<c042b687>] wireless_send_event+0x364/0x369
   [<ded03b69>] orinoco_send_wevents+0x9a/0xa6 [orinoco]
   [<c0128b28>] run_workqueue+0x110/0x1f3
   [<c0129648>] worker_thread+0x9a/0xf2
   [<c012c04e>] kthread+0x36/0x58
   [<c010454b>] kernel_thread_helper+0x7/0x1c
   [<ffffffff>] 0xffffffff

 ... acquired at:
   [<c0139d2d>] __lock_acquire+0x109b/0x11ac
   [<c0139ed7>] lock_acquire+0x99/0xb2
   [<c0452a4f>] _spin_lock_irqsave+0x3e/0x4e
   [<ded03598>] orinoco_set_multicast_list+0x1b/0x5f [orinoco]
   [<c03bbe62>] __dev_set_rx_mode+0x24/0x85
   [<c03bc0a8>] dev_set_rx_mode+0x26/0x3b
   [<c03be820>] dev_open+0x5a/0x76
   [<c03bc5c5>] dev_change_flags+0x8e/0x190
   [<c03fcb4c>] devinet_ioctl+0x4af/0x652
   [<c03fd432>] inet_ioctl+0x56/0x71
   [<c03b151a>] sock_ioctl+0xa5/0x1d4
   [<c0178a42>] do_ioctl+0x22/0x71
   [<c0178ae6>] vfs_ioctl+0x55/0x29e
   [<c0178d62>] sys_ioctl+0x33/0x69
   [<c01041da>] sysenter_past_esp+0x5f/0x99
   [<ffffffff>] 0xffffffff


the second lock's dependencies:
-> (&tp->lock){--..} ops: 44 {
   initial-use  at:
                        [<c0138ea9>] __lock_acquire+0x217/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c04527d3>] _spin_lock+0x35/0x42
                        [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                        [<c0148bae>] request_irq+0xd6/0xf8
                        [<de87152d>] rtl8139_open+0x2f/0x1e2 [8139too]
                        [<c03be7fd>] dev_open+0x37/0x76
                        [<c03bc5c5>] dev_change_flags+0x8e/0x190
                        [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                        [<c03fd432>] inet_ioctl+0x56/0x71
                        [<c03b151a>] sock_ioctl+0xa5/0x1d4
                        [<c0178a42>] do_ioctl+0x22/0x71
                        [<c0178ae6>] vfs_ioctl+0x55/0x29e
                        [<c0178d62>] sys_ioctl+0x33/0x69
                        [<c01041da>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   softirq-on-W at:
                        [<c01393f9>] __lock_acquire+0x767/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c04527d3>] _spin_lock+0x35/0x42
                        [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                        [<c01487ed>] free_irq+0x11b/0x146
                        [<de871c90>] rtl8139_close+0x8a/0x14a [8139too]
                        [<c03bd5c3>] dev_close+0x57/0x74
                        [<c03bc5c5>] dev_change_flags+0x8e/0x190
                        [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                        [<c03fd432>] inet_ioctl+0x56/0x71
                        [<c03b151a>] sock_ioctl+0xa5/0x1d4
                        [<c0178a42>] do_ioctl+0x22/0x71
                        [<c0178ae6>] vfs_ioctl+0x55/0x29e
                        [<c0178d62>] sys_ioctl+0x33/0x69
                        [<c01041da>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c01393d0>] __lock_acquire+0x73e/0x11ac
                        [<c0139ed7>] lock_acquire+0x99/0xb2
                        [<c04527d3>] _spin_lock+0x35/0x42
                        [<de8706e2>] rtl8139_interrupt+0x27/0x469 [8139too]
                        [<c01487ed>] free_irq+0x11b/0x146
                        [<de871c90>] rtl8139_close+0x8a/0x14a [8139too]
                        [<c03bd5c3>] dev_close+0x57/0x74
                        [<c03bc5c5>] dev_change_flags+0x8e/0x190
                        [<c03fcb4c>] devinet_ioctl+0x4af/0x652
                        [<c03fd432>] inet_ioctl+0x56/0x71
                        [<c03b151a>] sock_ioctl+0xa5/0x1d4
                        [<c0178a42>] do_ioctl+0x22/0x71
                        [<c0178ae6>] vfs_ioctl+0x55/0x29e
                        [<c0178d62>] sys_ioctl+0x33/0x69
                        [<c01041da>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<de875190>] __key.19796+0x0/0xffffd3c9 [8139too]

stack backtrace:
 [<c0104899>] show_trace_log_lvl+0x1a/0x30
 [<c0105296>] show_trace+0x12/0x14
 [<c01053fe>] dump_stack+0x15/0x17
 [<c0137462>] print_irq_inversion_bug+0x101/0x123
 [<c0137db1>] check_usage_forwards+0x3e/0x45
 [<c0137f67>] mark_lock+0x1af/0x70c
 [<c0139384>] __lock_acquire+0x6f2/0x11ac
 [<c0139ed7>] lock_acquire+0x99/0xb2
 [<c04527d3>] _spin_lock+0x35/0x42
 [<c03cb659>] dev_watchdog+0x17/0xcc
 [<c01224b7>] run_timer_softirq+0x14b/0x1a9
 [<c011ecc2>] __do_softirq+0x5b/0xb2
 [<c011ed66>] do_softirq+0x4d/0x4f
 [<c011f04b>] irq_exit+0x48/0x4a
 [<c01058f8>] do_IRQ+0x98/0xd0
 [<c010444e>] common_interrupt+0x2e/0x34
 [<c014b039>] find_lock_page+0x9b/0xa5
 [<c014d680>] filemap_fault+0x188/0x4d9
 [<c015760d>] __do_fault+0xb7/0x444
 [<c0159164>] handle_mm_fault+0x18a/0x6fc
 [<c0454864>] do_page_fault+0x454/0x6f0
 [<c0453102>] error_code+0x6a/0x70
 =======================
Clocksource tsc unstable (delta = 9373021754 ns)
