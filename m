From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [patch] work around/fix deadlock in the bcm43xx driver by making
 netlink irq safe
Date: Sat, 08 Jul 2006 12:59:14 -0500
Message-ID: <44AFF272.8000109@lwfinger.net>
References: <1151677494.11434.47.camel@laptopd505.fenrus.org> <44A536BE.6020209@gentoo.org> <44A53918.2020700@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joseph Jezak <josejx@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:18881 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964922AbWGHR7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 13:59:17 -0400
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <44A53918.2020700@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Joseph Jezak wrote:
>> Can you provide the details to the list?  I'll look into getting
>> SoftMAC fixed if you do.
>>
> 
> sure
> the basic issue is that bcm43xx does it's rx processing in a softirq, 
> and holds the bcm->irq_lock during that time. The rx processing calls 
> into the softmac layer, which in turn calls into netlink.
> 
> With this you can get a deadlock that looks like this
>  cpu 0: user context                           |cpu1: softirq context
>     netlink_table_grab takes nl_table_lock as  |take bcm->irq_lock in
>     write_lock_bh, but leaves irqs enabled     |bcm43xx_interrupt_tasklet()
>                                                |which then in a few steps
>                                                |leads to a call to
>                                                |bcm43xx_rx
> 
> 
>     hardirq comes in and the isr tries to take |in bcm43xx_rx, call
>     bcm->irq_lock but has to wait on cpu 1     |ieee80211_rx_mgt which
>                                                |leads to a call to
>                                                |wireless_send_event which
>                                                |tries to take nl_table_lock
>                                                |for read but has to wait
>                                                |for cpu0
> 
> according to Michael Buesch, the softmac layer should queue the packet 
> internally for another softirq, similar to what DeviceScape does, so 
> that the rx softirq can just drop all packets quickly and drop its locks.

I think the deadlock dump shown below is related; however, since I have a uniprocessor system and 
the deadlock is not exactly the same, I'll include it here. This is using v2.6.18-rc1 from Linus's tree.

kernel: -> (af_callback_keys + sk->sk_family#2){-.-?} ops: 431 {
kernel:    initial-use  at:
kernel:                         [<c0135d48>] lock_acquire+0x68/0x90
kernel:                         [<c030c195>] _read_lock+0x45/0x60
kernel:                         [<c02a786f>] sock_def_readable+0x1f/0x90
kernel:                         [<c02bf072>] netlink_broadcast+0x282/0x320
kernel:                         [<c01ef236>] kobject_uevent+0x366/0x4c0
kernel:                         [<c01eed08>] kobject_register+0x48/0x60
kernel:                         [<c013ce89>] sys_init_module+0x1439/0x1870
kernel:                         [<c01031cd>] sysenter_past_esp+0x56/0x8d
kernel:    hardirq-on-W at:
kernel:                         [<c0135d48>] lock_acquire+0x68/0x90
kernel:                         [<c030c37a>] _write_lock_bh+0x4a/0x60
kernel:                         [<c02beba3>] netlink_release+0xe3/0x330
kernel:                         [<c02a439d>] sock_release+0x1d/0xf0
kernel:                         [<c02a44a7>] sock_close+0x37/0x60
kernel:                         [<c0163688>] __fput+0xd8/0x210
kernel:                         [<c01637d8>] fput+0x18/0x20
kernel:                         [<c0160574>] filp_close+0x54/0x80
kernel:                         [<c011a5df>] put_files_struct+0x7f/0xd0
kernel:                         [<c011b6cc>] do_exit+0x12c/0x9a0
kernel:                         [<c011bf7d>] do_group_exit+0x3d/0xa0
kernel:                         [<c011bff5>] sys_exit_group+0x15/0x20
kernel:                         [<c01031cd>] sysenter_past_esp+0x56/0x8d
kernel:    in-softirq-R at:
kernel:                         [<c0135d48>] lock_acquire+0x68/0x90
kernel:                         [<c030c195>] _read_lock+0x45/0x60
kernel:                         [<c02a786f>] sock_def_readable+0x1f/0x90
kernel:                         [<c02bf072>] netlink_broadcast+0x282/0x320
kernel:                         [<c02bb6e4>] wireless_send_event+0x244/0x3b0
kernel:                         [<e4a2c586>] ieee80211softmac_call_events_locked+0x86/0x140 
[ieee80211softmac]
kernel:                         [<e4a2c674>] ieee80211softmac_call_events+0x34/0x6f [ieee80211softmac]
kernel:                         [<e4a28faf>] ieee80211softmac_auth_resp+0x19f/0x620 [ieee80211softmac]
kernel:                         [<e4a1e413>] ieee80211_rx_mgt+0x543/0x810 [ieee80211]
kernel:                         [<e4a7ea2b>] bcm43xx_rx+0x34b/0x980 [bcm43xx]
kernel:                         [<e4a820bc>] bcm43xx_dma_rx+0x23c/0x550 [bcm43xx]
kernel:                         [<e4a6751e>] bcm43xx_interrupt_tasklet+0x38e/0x970 [bcm43xx]
kernel:                         [<c011e4de>] tasklet_action+0x4e/0x90
kernel:                         [<c011ecc2>] __do_softirq+0x62/0xe0
kernel:                         [<c01055cb>] do_softirq+0x9b/0xf0
kernel:    softirq-on-R at:
kernel:                         [<c0135d48>] lock_acquire+0x68/0x90
kernel:                         [<c030c195>] _read_lock+0x45/0x60
kernel:                         [<c02a786f>] sock_def_readable+0x1f/0x90
kernel:                         [<c02bf072>] netlink_broadcast+0x282/0x320
kernel:                         [<c01ef236>] kobject_uevent+0x366/0x4c0
kernel:                         [<c01eed08>] kobject_register+0x48/0x60
kernel:                         [<c013ce89>] sys_init_module+0x1439/0x1870
kernel:                         [<c01031cd>] sysenter_past_esp+0x56/0x8d
kernel:    hardirq-on-R at:
kernel:                         [<c0135d48>] lock_acquire+0x68/0x90
kernel:                         [<c030c195>] _read_lock+0x45/0x60
kernel:                         [<c02a786f>] sock_def_readable+0x1f/0x90
kernel:                         [<c02bf072>] netlink_broadcast+0x282/0x320
kernel:                         [<c01ef236>] kobject_uevent+0x366/0x4c0
kernel:                         [<c01eed08>] kobject_register+0x48/0x60
kernel:                         [<c013ce89>] sys_init_module+0x1439/0x1870
kernel:                         [<c01031cd>] sysenter_past_esp+0x56/0x8d
kernel:  }
kernel   ... key      at: [<c05bad60>] af_callback_keys+0x80/0x100
kernel:
kernel: stack backtrace:
kernel:  [<c0103d1d>] show_trace_log_lvl+0x13d/0x160
kernel:  [<c010525b>] show_trace+0x1b/0x20
kernel:  [<c0105286>] dump_stack+0x26/0x30
kernel:  [<c0133f7d>] check_usage+0x26d/0x280
kernel:  [<c013536f>] __lock_acquire+0x77f/0xdd0
kernel:  [<c0135d48>] lock_acquire+0x68/0x90
kernel:  [<c030c195>] _read_lock+0x45/0x60
kernel:  [<c02a786f>] sock_def_readable+0x1f/0x90
kernel:  [<c02bf072>] netlink_broadcast+0x282/0x320
kernel:  [<c02bb6e4>] wireless_send_event+0x244/0x3b0
kernel:  [<e4a2c586>] ieee80211softmac_call_events_locked+0x86/0x140 [ieee80211softmac]
kernel:  [<e4a2c674>] ieee80211softmac_call_events+0x34/0x6f [ieee80211softmac]
kernel:  [<e4a28faf>] ieee80211softmac_auth_resp+0x19f/0x620 [ieee80211softmac]
kernel:  [<e4a1e413>] ieee80211_rx_mgt+0x543/0x810 [ieee80211]
kernel:  [<e4a7ea2b>] bcm43xx_rx+0x34b/0x980 [bcm43xx]
kernel:  [<e4a820bc>] bcm43xx_dma_rx+0x23c/0x550 [bcm43xx]
kernel:  [<e4a6751e>] bcm43xx_interrupt_tasklet+0x38e/0x970 [bcm43xx]
kernel:  [<c011e4de>] tasklet_action+0x4e/0x90
kernel:  [<c011ecc2>] __do_softirq+0x62/0xe0
kernel:  [<c01055cb>] do_softirq+0x9b/0xf0
kernel:  [<c01056d1>] do_IRQ+0xb1/0x110
kernel:  [<c0103439>] common_interrupt+0x25/0x2c
kernel:  [<c015e01e>] kmem_cache_free+0x6e/0xa0
kernel:  [<c019631d>] proc_destroy_inode+0x1d/0x20
kernel:  [<c017d7eb>] destroy_inode+0x2b/0x60
kernel:  [<c017e753>] generic_delete_inode+0xb3/0x100
kernel:  [<c017d8fd>] iput+0x6d/0x80
kernel:  [<c017b79b>] dentry_iput+0x7b/0xd0
kernel:  [<c017bee4>] dput+0x84/0x190
kernel:  [<c0172194>] path_release+0x14/0x30
kernel:  [<c017295a>] __link_path_walk+0x3ea/0xef0
kernel:  [<c01734b4>] link_path_walk+0x54/0xf0
kernel:  [<c017394e>] do_path_lookup+0xae/0x260
kernel:  [<c017403a>] __path_lookup_intent_open+0x4a/0x90
kernel:  [<c017410a>] path_lookup_open+0x2a/0x30
kernel:  [<c01743a7>] open_namei+0x77/0x6d0
kernel:  [<c0161898>] do_filp_open+0x38/0x60
kernel:  [<c016190b>] do_sys_open+0x4b/0x100
kernel:  [<c0161a17>] sys_open+0x27/0x30
kernel:  [<c01031cd>] sysenter_past_esp+0x56/0x8d
kernel:  [<b7fb9410>] 0xb7fb9410
kernel: SoftMAC: sent association request!
kernel: SoftMAC: associated!
kernel: SoftMAC: Scanning finished

So far, this situation has only occurred during the initial association/authorization steps during 
bootup.

Larry
