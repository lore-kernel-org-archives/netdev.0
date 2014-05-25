From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: latest net-next: iwlwifi: reproducible SOFTIRQ-unsafe lock order
 detected
Date: Sun, 25 May 2014 20:13:25 +0200
Message-ID: <538232C5.7000306@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.160]:38206 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaEYSNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 14:13:30 -0400
Received: from [192.168.178.40] (p5B0B09E7.dip0.t-ipconnect.de [91.11.9.231])
	by smtp.strato.de (RZmta 34.2 DYNA|AUTH)
	with ESMTPSA id g05967q4PIDQC98
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	for <netdev@vger.kernel.org>;
	Sun, 25 May 2014 20:13:26 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

with the latest net-next (3.15-rc6) I get a reproducible lock order splash.

When using the latest 3.15-rc6 from Linus' it is fine.

The '-dirty' from the version print is a small change in an unrelated CAN
driver (which was not even plugged-in / loaded that time).

Any ideas? Patches are welcome :-)

Regards,
Oliver

---


[   15.918348] 
[   15.918354] ======================================================
[   15.918356] [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
[   15.918359] 3.15.0-rc6-nn-02649-g54e5c4d-dirty #3 Not tainted
[   15.918360] ------------------------------------------------------
[   15.918363] wpa_supplicant/1690 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
[   15.918365]  (&(&priv->sta_lock)->rlock){+.....}, at: [<f8cec76d>] iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.918380] 
[   15.918380] and this task is already holding:
[   15.918382]  (_xmit_ETHER#2){+.-...}, at: [<c14103b2>] sch_direct_xmit+0x72/0x2d0
[   15.918390] which would create a new lock dependency:
[   15.918391]  (_xmit_ETHER#2){+.-...} -> (&(&priv->sta_lock)->rlock){+.....}
[   15.918397] 
[   15.918397] but this new dependency connects a SOFTIRQ-irq-safe lock:
[   15.918398]  (_xmit_ETHER#2){+.-...}
[   15.918398] ... which became SOFTIRQ-irq-safe at:
[   15.918402]   [<c107fb58>] __lock_acquire+0x268/0x1890
[   15.918407]   [<c108120a>] lock_acquire+0x8a/0x110
[   15.918409]   [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918414]   [<c14103b2>] sch_direct_xmit+0x72/0x2d0
[   15.918416]   [<c13f524f>] __dev_queue_xmit+0x1df/0x610
[   15.918421]   [<c13f568a>] dev_queue_xmit+0xa/0x10
[   15.918424]   [<c13fed15>] neigh_resolve_output+0x175/0x2a0
[   15.918428]   [<c1488cd4>] ip6_finish_output2+0x164/0x870
[   15.918431]   [<c148c9ba>] ip6_finish_output+0x7a/0x1b0
[   15.918434]   [<c148cb30>] ip6_output+0x40/0x230
[   15.918436]   [<c14abbf1>] mld_sendpack+0x2b1/0x630
[   15.918441]   [<c14ad181>] mld_ifc_timer_expire+0x191/0x2c0
[   15.918444]   [<c1045b40>] call_timer_fn+0x70/0x160
[   15.918449]   [<c1045e52>] run_timer_softirq+0x172/0x240
[   15.918452]   [<c103ff53>] __do_softirq+0xf3/0x2a0
[   15.918455]   [<c10043cd>] do_softirq_own_stack+0x1d/0x30
[   15.918460]   [<c1040375>] irq_exit+0xa5/0xb0
[   15.918463]   [<c10299d5>] smp_apic_timer_interrupt+0x35/0x50
[   15.918469]   [<c14dc5a2>] apic_timer_interrupt+0x32/0x38
[   15.918472] 
[   15.918472] to a SOFTIRQ-irq-unsafe lock:
[   15.918474]  (&(&txq->lock)->rlock){+.+...}
[   15.918474] ... which became SOFTIRQ-irq-unsafe at:
[   15.918477] ...  [<c107fba3>] __lock_acquire+0x2b3/0x1890
[   15.918480]   [<c108120a>] lock_acquire+0x8a/0x110
[   15.918482]   [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918485]   [<f8abe7e2>] iwl_pcie_txq_check_wrptrs+0x52/0x90 [iwlwifi]
[   15.918497]   [<f8abc27c>] iwl_pcie_irq_handler+0xbbc/0x15c0 [iwlwifi]
[   15.918503]   [<c108b7d3>] irq_thread_fn+0x13/0x30
[   15.918508]   [<c108bc6e>] irq_thread+0xee/0x120
[   15.918510]   [<c1059746>] kthread+0x96/0xb0
[   15.918515]   [<c14dcb41>] ret_from_kernel_thread+0x21/0x30
[   15.918518] 
[   15.918518] other info that might help us debug this:
[   15.918518] 
[   15.918520] Chain exists of:
[   15.918520]   _xmit_ETHER#2 --> &(&priv->sta_lock)->rlock --> &(&txq->lock)->rlock
[   15.918520] 
[   15.918525]  Possible interrupt unsafe locking scenario:
[   15.918525] 
[   15.918527]        CPU0                    CPU1
[   15.918529]        ----                    ----
[   15.918529]   lock(&(&txq->lock)->rlock);
[   15.918532]                                local_irq_disable();
[   15.918533]                                lock(_xmit_ETHER#2);
[   15.918535]                                lock(&(&priv->sta_lock)->rlock);
[   15.918537]   <Interrupt>
[   15.918538]     lock(_xmit_ETHER#2);
[   15.918540] 
[   15.918540]  *** DEADLOCK ***
[   15.918540] 
[   15.918543] 3 locks held by wpa_supplicant/1690:
[   15.918544]  #0:  (rcu_read_lock_bh){......}, at: [<c13f5070>] __dev_queue_xmit+0x0/0x610
[   15.918550]  #1:  (_xmit_ETHER#2){+.-...}, at: [<c14103b2>] sch_direct_xmit+0x72/0x2d0
[   15.918554]  #2:  (rcu_read_lock){......}, at: [<f8e43209>] ieee80211_subif_start_xmit+0x29/0xbc0 [mac80211]
[   15.918581] 
[   15.918581] the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
[   15.918597] -> (_xmit_ETHER#2){+.-...} ops: 7 {
[   15.918602]    HARDIRQ-ON-W at:
[   15.918604]                     [<c107fe3f>] __lock_acquire+0x54f/0x1890
[   15.918607]                     [<c108120a>] lock_acquire+0x8a/0x110
[   15.918609]                     [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918612]                     [<c1410bc8>] dev_deactivate_many+0xa8/0x200
[   15.918615]                     [<c1410d3f>] dev_deactivate+0x1f/0x30
[   15.918617]                     [<c1405627>] linkwatch_do_dev+0x27/0x50
[   15.918620]                     [<c1405919>] __linkwatch_run_queue+0x109/0x130
[   15.918623]                     [<c140595b>] linkwatch_event+0x1b/0x30
[   15.918626]                     [<c1053847>] process_one_work+0x187/0x490
[   15.918629]                     [<c1054429>] worker_thread+0xf9/0x330
[   15.918632]                     [<c1059746>] kthread+0x96/0xb0
[   15.918635]                     [<c14dcb41>] ret_from_kernel_thread+0x21/0x30
[   15.918638]    IN-SOFTIRQ-W at:
[   15.918639]                     [<c107fb58>] __lock_acquire+0x268/0x1890
[   15.918642]                     [<c108120a>] lock_acquire+0x8a/0x110
[   15.918644]                     [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918647]                     [<c14103b2>] sch_direct_xmit+0x72/0x2d0
[   15.918649]                     [<c13f524f>] __dev_queue_xmit+0x1df/0x610
[   15.918653]                     [<c13f568a>] dev_queue_xmit+0xa/0x10
[   15.918656]                     [<c13fed15>] neigh_resolve_output+0x175/0x2a0
[   15.918659]                     [<c1488cd4>] ip6_finish_output2+0x164/0x870
[   15.918661]                     [<c148c9ba>] ip6_finish_output+0x7a/0x1b0
[   15.918663]                     [<c148cb30>] ip6_output+0x40/0x230
[   15.918665]                     [<c14abbf1>] mld_sendpack+0x2b1/0x630
[   15.918668]                     [<c14ad181>] mld_ifc_timer_expire+0x191/0x2c0
[   15.918671]                     [<c1045b40>] call_timer_fn+0x70/0x160
[   15.918674]                     [<c1045e52>] run_timer_softirq+0x172/0x240
[   15.918677]                     [<c103ff53>] __do_softirq+0xf3/0x2a0
[   15.918680]                     [<c10043cd>] do_softirq_own_stack+0x1d/0x30
[   15.918683]                     [<c1040375>] irq_exit+0xa5/0xb0
[   15.918685]                     [<c10299d5>] smp_apic_timer_interrupt+0x35/0x50
[   15.918688]                     [<c14dc5a2>] apic_timer_interrupt+0x32/0x38
[   15.918691]    INITIAL USE at:
[   15.918693]                    [<c107fbf7>] __lock_acquire+0x307/0x1890
[   15.918695]                    [<c108120a>] lock_acquire+0x8a/0x110
[   15.918698]                    [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918701]                    [<c1410bc8>] dev_deactivate_many+0xa8/0x200
[   15.918703]                    [<c1410d3f>] dev_deactivate+0x1f/0x30
[   15.918706]                    [<c1405627>] linkwatch_do_dev+0x27/0x50
[   15.918709]                    [<c1405919>] __linkwatch_run_queue+0x109/0x130
[   15.918712]                    [<c140595b>] linkwatch_event+0x1b/0x30
[   15.918715]                    [<c1053847>] process_one_work+0x187/0x490
[   15.918717]                    [<c1054429>] worker_thread+0xf9/0x330
[   15.918720]                    [<c1059746>] kthread+0x96/0xb0
[   15.918723]                    [<c14dcb41>] ret_from_kernel_thread+0x21/0x30
[   15.918725]  }
[   15.918727]  ... key      at: [<c1d36188>] netdev_xmit_lock_key+0x8/0x1c8
[   15.918733]  ... acquired at:
[   15.918734]    [<c107e52e>] check_irq_usage+0x4e/0xc0
[   15.918736]    [<c1080656>] __lock_acquire+0xd66/0x1890
[   15.918738]    [<c108120a>] lock_acquire+0x8a/0x110
[   15.918740]    [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918742]    [<f8cec76d>] iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.918749]    [<f8ce9f36>] iwlagn_mac_tx+0x16/0x30 [iwldvm]
[   15.918756]    [<f8e4086e>] __ieee80211_tx+0x21e/0x310 [mac80211]
[   15.918770]    [<f8e424ff>] ieee80211_tx+0x9f/0xd0 [mac80211]
[   15.918784]    [<f8e42e40>] ieee80211_xmit+0x90/0xf0 [mac80211]
[   15.918798]    [<f8e4379f>] ieee80211_subif_start_xmit+0x5bf/0xbc0 [mac80211]
[   15.918813]    [<c13f4db4>] dev_hard_start_xmit+0x2c4/0x580
[   15.918817]    [<c14103d2>] sch_direct_xmit+0x92/0x2d0
[   15.918819]    [<c13f524f>] __dev_queue_xmit+0x1df/0x610
[   15.918822]    [<c13f568a>] dev_queue_xmit+0xa/0x10
[   15.918824]    [<c14cb1bb>] packet_sendmsg+0xa4b/0xcf0
[   15.918828]    [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.918831]    [<c13dda0f>] SYSC_sendto+0xdf/0x110
[   15.918834]    [<c13de8e4>] SYSC_socketcall+0x3b4/0x990
[   15.918837]    [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.918839]    [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.918842] 
[   15.918844] 
[   15.918844] the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
[   15.918858]  -> (&(&txq->lock)->rlock){+.+...} ops: 180 {
[   15.918862]     HARDIRQ-ON-W at:
[   15.918864]                       [<c107fe3f>] __lock_acquire+0x54f/0x1890
[   15.918866]                       [<c108120a>] lock_acquire+0x8a/0x110
[   15.918868]                       [<c14db6a0>] _raw_spin_lock_bh+0x40/0x50
[   15.918871]                       [<f8abdf2b>] iwl_pcie_enqueue_hcmd+0xfb/0x960 [iwlwifi]
[   15.918877]                       [<f8ac03c9>] iwl_trans_pcie_send_hcmd+0xd9/0x5f0 [iwlwifi]
[   15.918884]                       [<f8cef9c2>] iwl_dvm_send_cmd+0x72/0x210 [iwldvm]
[   15.918892]                       [<f8cefe4a>] iwl_dvm_send_cmd_pdu+0x3a/0x50 [iwldvm]
[   15.918898]                       [<f8cebde1>] iwl_load_ucode_wait_alive+0x201/0x3b0 [iwldvm]
[   15.918903]                       [<f8cec004>] iwl_run_init_ucode+0x74/0x120 [iwldvm]
[   15.918909]                       [<f8ce9d90>] iwlagn_mac_start+0xc0/0x250 [iwldvm]
[   15.918914]                       [<f8e30a8f>] ieee80211_do_open+0x2af/0xdd0 [mac80211]
[   15.918928]                       [<f8e315fd>] ieee80211_open+0x4d/0x50 [mac80211]
[   15.918942]                       [<c13f5d93>] __dev_open+0x83/0xf0
[   15.918946]                       [<c13f6035>] __dev_change_flags+0x85/0x160
[   15.918948]                       [<c13f6133>] dev_change_flags+0x23/0x60
[   15.918951]                       [<c140229d>] do_setlink+0x2cd/0x710
[   15.918954]                       [<c140493a>] rtnl_newlink+0x50a/0x6f0
[   15.918956]                       [<c14013ff>] rtnetlink_rcv_msg+0x7f/0x1f0
[   15.918959]                       [<c141bbd6>] netlink_rcv_skb+0x96/0xb0
[   15.918963]                       [<c140136e>] rtnetlink_rcv+0x1e/0x30
[   15.918966]                       [<c141b2e8>] netlink_unicast+0xd8/0x190
[   15.918968]                       [<c141b5da>] netlink_sendmsg+0x23a/0x6a0
[   15.918971]                       [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.918973]                       [<c13dd74a>] ___sys_sendmsg.part.18+0x25a/0x270
[   15.918976]                       [<c13de13f>] __sys_sendmsg+0x3f/0x70
[   15.918978]                       [<c13de69e>] SYSC_socketcall+0x16e/0x990
[   15.918981]                       [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.918983]                       [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.918985]     SOFTIRQ-ON-W at:
[   15.918987]                       [<c107fba3>] __lock_acquire+0x2b3/0x1890
[   15.918990]                       [<c108120a>] lock_acquire+0x8a/0x110
[   15.918992]                       [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.918995]                       [<f8abe7e2>] iwl_pcie_txq_check_wrptrs+0x52/0x90 [iwlwifi]
[   15.919002]                       [<f8abc27c>] iwl_pcie_irq_handler+0xbbc/0x15c0 [iwlwifi]
[   15.919008]                       [<c108b7d3>] irq_thread_fn+0x13/0x30
[   15.919011]                       [<c108bc6e>] irq_thread+0xee/0x120
[   15.919013]                       [<c1059746>] kthread+0x96/0xb0
[   15.919015]                       [<c14dcb41>] ret_from_kernel_thread+0x21/0x30
[   15.919018]     INITIAL USE at:
[   15.919019]                      [<c107fbf7>] __lock_acquire+0x307/0x1890
[   15.919021]                      [<c108120a>] lock_acquire+0x8a/0x110
[   15.919023]                      [<c14db6a0>] _raw_spin_lock_bh+0x40/0x50
[   15.919026]                      [<f8abdf2b>] iwl_pcie_enqueue_hcmd+0xfb/0x960 [iwlwifi]
[   15.919033]                      [<f8ac03c9>] iwl_trans_pcie_send_hcmd+0xd9/0x5f0 [iwlwifi]
[   15.919039]                      [<f8cef9c2>] iwl_dvm_send_cmd+0x72/0x210 [iwldvm]
[   15.919046]                      [<f8cefe4a>] iwl_dvm_send_cmd_pdu+0x3a/0x50 [iwldvm]
[   15.919053]                      [<f8cebde1>] iwl_load_ucode_wait_alive+0x201/0x3b0 [iwldvm]
[   15.919059]                      [<f8cec004>] iwl_run_init_ucode+0x74/0x120 [iwldvm]
[   15.919064]                      [<f8ce9d90>] iwlagn_mac_start+0xc0/0x250 [iwldvm]
[   15.919070]                      [<f8e30a8f>] ieee80211_do_open+0x2af/0xdd0 [mac80211]
[   15.919083]                      [<f8e315fd>] ieee80211_open+0x4d/0x50 [mac80211]
[   15.919096]                      [<c13f5d93>] __dev_open+0x83/0xf0
[   15.919099]                      [<c13f6035>] __dev_change_flags+0x85/0x160
[   15.919102]                      [<c13f6133>] dev_change_flags+0x23/0x60
[   15.919105]                      [<c140229d>] do_setlink+0x2cd/0x710
[   15.919108]                      [<c140493a>] rtnl_newlink+0x50a/0x6f0
[   15.919111]                      [<c14013ff>] rtnetlink_rcv_msg+0x7f/0x1f0
[   15.919113]                      [<c141bbd6>] netlink_rcv_skb+0x96/0xb0
[   15.919116]                      [<c140136e>] rtnetlink_rcv+0x1e/0x30
[   15.919119]                      [<c141b2e8>] netlink_unicast+0xd8/0x190
[   15.919121]                      [<c141b5da>] netlink_sendmsg+0x23a/0x6a0
[   15.919124]                      [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919127]                      [<c13dd74a>] ___sys_sendmsg.part.18+0x25a/0x270
[   15.919129]                      [<c13de13f>] __sys_sendmsg+0x3f/0x70
[   15.919132]                      [<c13de69e>] SYSC_socketcall+0x16e/0x990
[   15.919134]                      [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919136]                      [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.919139]   }
[   15.919140]   ... key      at: [<f8ad1ac8>] __key.46551+0x0/0xffff7538 [iwlwifi]
[   15.919148]   ... acquired at:
[   15.919149]    [<c108120a>] lock_acquire+0x8a/0x110
[   15.919152]    [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.919155]    [<f8ac0938>] iwl_trans_pcie_tx+0x58/0x6c0 [iwlwifi]
[   15.919162]    [<f8cec8d4>] iwlagn_tx_skb+0x554/0xb40 [iwldvm]
[   15.919168]    [<f8ce9f36>] iwlagn_mac_tx+0x16/0x30 [iwldvm]
[   15.919173]    [<f8e4086e>] __ieee80211_tx+0x21e/0x310 [mac80211]
[   15.919187]    [<f8e424ff>] ieee80211_tx+0x9f/0xd0 [mac80211]
[   15.919200]    [<f8e42e40>] ieee80211_xmit+0x90/0xf0 [mac80211]
[   15.919210]    [<f8e44051>] __ieee80211_tx_skb_tid_band+0x61/0x80 [mac80211]
[   15.919224]    [<f8e47eb6>] ieee80211_send_auth+0x166/0x210 [mac80211]
[   15.919240]    [<f8e5a268>] ieee80211_probe_auth+0x248/0x480 [mac80211]
[   15.919260]    [<f8e5f143>] ieee80211_mgd_auth+0x233/0x2a0 [mac80211]
[   15.919277]    [<f8e346b1>] ieee80211_auth+0x11/0x20 [mac80211]
[   15.919291]    [<f8b53bc7>] cfg80211_mlme_auth+0xe7/0x1f0 [cfg80211]
[   15.919316]    [<f8b4041b>] nl80211_authenticate+0x25b/0x2c0 [cfg80211]
[   15.919330]    [<c141d6a9>] genl_rcv_msg+0x219/0x3b0
[   15.919333]    [<c141bbd6>] netlink_rcv_skb+0x96/0xb0
[   15.919335]    [<c141c05c>] genl_rcv+0x1c/0x30
[   15.919338]    [<c141b2e8>] netlink_unicast+0xd8/0x190
[   15.919340]    [<c141b5da>] netlink_sendmsg+0x23a/0x6a0
[   15.919343]    [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919345]    [<c13dd74a>] ___sys_sendmsg.part.18+0x25a/0x270
[   15.919347]    [<c13de13f>] __sys_sendmsg+0x3f/0x70
[   15.919349]    [<c13de69e>] SYSC_socketcall+0x16e/0x990
[   15.919352]    [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919354]    [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.919357] 
[   15.919359] -> (&(&priv->sta_lock)->rlock){+.....} ops: 83 {
[   15.919363]    HARDIRQ-ON-W at:
[   15.919365]                     [<c107fe3f>] __lock_acquire+0x54f/0x1890
[   15.919368]                     [<c108120a>] lock_acquire+0x8a/0x110
[   15.919370]                     [<c14db6a0>] _raw_spin_lock_bh+0x40/0x50
[   15.919373]                     [<f8cf5a0a>] iwlagn_alloc_bcast_station+0x1a/0xf0 [iwldvm]
[   15.919381]                     [<f8ce9d6b>] iwlagn_mac_start+0x9b/0x250 [iwldvm]
[   15.919386]                     [<f8e30a8f>] ieee80211_do_open+0x2af/0xdd0 [mac80211]
[   15.919397]                     [<f8e315fd>] ieee80211_open+0x4d/0x50 [mac80211]
[   15.919410]                     [<c13f5d93>] __dev_open+0x83/0xf0
[   15.919412]                     [<c13f6035>] __dev_change_flags+0x85/0x160
[   15.919415]                     [<c13f6133>] dev_change_flags+0x23/0x60
[   15.919418]                     [<c140229d>] do_setlink+0x2cd/0x710
[   15.919421]                     [<c140493a>] rtnl_newlink+0x50a/0x6f0
[   15.919423]                     [<c14013ff>] rtnetlink_rcv_msg+0x7f/0x1f0
[   15.919425]                     [<c141bbd6>] netlink_rcv_skb+0x96/0xb0
[   15.919428]                     [<c140136e>] rtnetlink_rcv+0x1e/0x30
[   15.919431]                     [<c141b2e8>] netlink_unicast+0xd8/0x190
[   15.919433]                     [<c141b5da>] netlink_sendmsg+0x23a/0x6a0
[   15.919436]                     [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919438]                     [<c13dd74a>] ___sys_sendmsg.part.18+0x25a/0x270
[   15.919440]                     [<c13de13f>] __sys_sendmsg+0x3f/0x70
[   15.919442]                     [<c13de69e>] SYSC_socketcall+0x16e/0x990
[   15.919445]                     [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919447]                     [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.919450]    INITIAL USE at:
[   15.919452]                    [<c107fbf7>] __lock_acquire+0x307/0x1890
[   15.919454]                    [<c108120a>] lock_acquire+0x8a/0x110
[   15.919456]                    [<c14db6a0>] _raw_spin_lock_bh+0x40/0x50
[   15.919459]                    [<f8cf5a0a>] iwlagn_alloc_bcast_station+0x1a/0xf0 [iwldvm]
[   15.919466]                    [<f8ce9d6b>] iwlagn_mac_start+0x9b/0x250 [iwldvm]
[   15.919471]                    [<f8e30a8f>] ieee80211_do_open+0x2af/0xdd0 [mac80211]
[   15.919484]                    [<f8e315fd>] ieee80211_open+0x4d/0x50 [mac80211]
[   15.919495]                    [<c13f5d93>] __dev_open+0x83/0xf0
[   15.919498]                    [<c13f6035>] __dev_change_flags+0x85/0x160
[   15.919501]                    [<c13f6133>] dev_change_flags+0x23/0x60
[   15.919504]                    [<c140229d>] do_setlink+0x2cd/0x710
[   15.919506]                    [<c140493a>] rtnl_newlink+0x50a/0x6f0
[   15.919509]                    [<c14013ff>] rtnetlink_rcv_msg+0x7f/0x1f0
[   15.919511]                    [<c141bbd6>] netlink_rcv_skb+0x96/0xb0
[   15.919514]                    [<c140136e>] rtnetlink_rcv+0x1e/0x30
[   15.919516]                    [<c141b2e8>] netlink_unicast+0xd8/0x190
[   15.919519]                    [<c141b5da>] netlink_sendmsg+0x23a/0x6a0
[   15.919522]                    [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919524]                    [<c13dd74a>] ___sys_sendmsg.part.18+0x25a/0x270
[   15.919526]                    [<c13de13f>] __sys_sendmsg+0x3f/0x70
[   15.919528]                    [<c13de69e>] SYSC_socketcall+0x16e/0x990
[   15.919531]                    [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919533]                    [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.919536]  }
[   15.919537]  ... key      at: [<f8d07324>] __key.46877+0x0/0xffff6cdc [iwldvm]
[   15.919543]  ... acquired at:
[   15.919544]    [<c107e52e>] check_irq_usage+0x4e/0xc0
[   15.919546]    [<c1080656>] __lock_acquire+0xd66/0x1890
[   15.919548]    [<c108120a>] lock_acquire+0x8a/0x110
[   15.919551]    [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.919553]    [<f8cec76d>] iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.919559]    [<f8ce9f36>] iwlagn_mac_tx+0x16/0x30 [iwldvm]
[   15.919564]    [<f8e4086e>] __ieee80211_tx+0x21e/0x310 [mac80211]
[   15.919579]    [<f8e424ff>] ieee80211_tx+0x9f/0xd0 [mac80211]
[   15.919592]    [<f8e42e40>] ieee80211_xmit+0x90/0xf0 [mac80211]
[   15.919605]    [<f8e4379f>] ieee80211_subif_start_xmit+0x5bf/0xbc0 [mac80211]
[   15.919619]    [<c13f4db4>] dev_hard_start_xmit+0x2c4/0x580
[   15.919622]    [<c14103d2>] sch_direct_xmit+0x92/0x2d0
[   15.919624]    [<c13f524f>] __dev_queue_xmit+0x1df/0x610
[   15.919627]    [<c13f568a>] dev_queue_xmit+0xa/0x10
[   15.919630]    [<c14cb1bb>] packet_sendmsg+0xa4b/0xcf0
[   15.919632]    [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919634]    [<c13dda0f>] SYSC_sendto+0xdf/0x110
[   15.919636]    [<c13de8e4>] SYSC_socketcall+0x3b4/0x990
[   15.919639]    [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919641]    [<c14dcbd0>] sysenter_do_call+0x12/0x36
[   15.919643] 
[   15.919645] 
[   15.919645] stack backtrace:
[   15.919649] CPU: 1 PID: 1690 Comm: wpa_supplicant Not tainted 3.15.0-rc6-nn-02649-g54e5c4d-dirty #3
[   15.919651] Hardware name: Dell Inc. Latitude E6510/XXXXXX, BIOS A06 11/20/2010
[   15.919652]  00000000 00000000 ed82383c c14d4a0f c1a7fee0 ed8238cc c107e4d4 c1652abb
[   15.919658]  c1652dfc 0000069a 00000000 00000000 00000000 00000002 00000001 00000000
[   15.919663]  ed823878 c1c74f50 ed823878 c1c74f50 c107c6f0 00000009 c1a7fee0 00000014
[   15.919669] Call Trace:
[   15.919673]  [<c14d4a0f>] dump_stack+0x48/0x60
[   15.919676]  [<c107e4d4>] check_usage+0x3f4/0x400
[   15.919681]  [<c107c6f0>] ? noop_count+0x10/0x10
[   15.919684]  [<c107ccf3>] ? find_usage_backwards+0x33/0x70
[   15.919688]  [<c107cb6c>] ? __bfs+0xec/0x1d0
[   15.919691]  [<c107e52e>] check_irq_usage+0x4e/0xc0
[   15.919694]  [<c1080656>] __lock_acquire+0xd66/0x1890
[   15.919697]  [<c107e9cd>] ? mark_held_locks+0x5d/0x80
[   15.919702]  [<c112b185>] ? kmem_cache_alloc+0x1a5/0x3f0
[   15.919705]  [<c108120a>] lock_acquire+0x8a/0x110
[   15.919713]  [<f8cec76d>] ? iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.919716]  [<c14db64a>] _raw_spin_lock+0x3a/0x50
[   15.919723]  [<f8cec76d>] ? iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.919729]  [<f8cec76d>] iwlagn_tx_skb+0x3ed/0xb40 [iwldvm]
[   15.919732]  [<c107e9cd>] ? mark_held_locks+0x5d/0x80
[   15.919738]  [<f8ce9f36>] iwlagn_mac_tx+0x16/0x30 [iwldvm]
[   15.919752]  [<f8e4086e>] __ieee80211_tx+0x21e/0x310 [mac80211]
[   15.919767]  [<f8e424ff>] ieee80211_tx+0x9f/0xd0 [mac80211]
[   15.919782]  [<f8e42e40>] ieee80211_xmit+0x90/0xf0 [mac80211]
[   15.919797]  [<f8e4379f>] ieee80211_subif_start_xmit+0x5bf/0xbc0 [mac80211]
[   15.919813]  [<f8e43209>] ? ieee80211_subif_start_xmit+0x29/0xbc0 [mac80211]
[   15.919819]  [<c13f4db4>] dev_hard_start_xmit+0x2c4/0x580
[   15.919822]  [<c14db651>] ? _raw_spin_lock+0x41/0x50
[   15.919825]  [<c14103d2>] sch_direct_xmit+0x92/0x2d0
[   15.919829]  [<c14db651>] ? _raw_spin_lock+0x41/0x50
[   15.919832]  [<c13f524f>] __dev_queue_xmit+0x1df/0x610
[   15.919835]  [<c13f5070>] ? dev_hard_start_xmit+0x580/0x580
[   15.919848]  [<f8e2efed>] ? ieee80211_netdev_select_queue+0xd/0x10 [mac80211]
[   15.919851]  [<c13f568a>] dev_queue_xmit+0xa/0x10
[   15.919854]  [<c14cb1bb>] packet_sendmsg+0xa4b/0xcf0
[   15.919857]  [<c107fd23>] ? __lock_acquire+0x433/0x1890
[   15.919860]  [<c1080000>] ? __lock_acquire+0x710/0x1890
[   15.919862]  [<c13dd409>] sock_sendmsg+0x69/0x90
[   15.919868]  [<c1232344>] ? _copy_from_user+0x44/0x50
[   15.919870]  [<c13dd790>] ? move_addr_to_kernel+0x30/0x50
[   15.919872]  [<c13dda0f>] SYSC_sendto+0xdf/0x110
[   15.919878]  [<c110d189>] ? might_fault+0x49/0xa0
[   15.919881]  [<c110d189>] ? might_fault+0x49/0xa0
[   15.919883]  [<c110d1cf>] ? might_fault+0x8f/0xa0
[   15.919886]  [<c1232344>] ? _copy_from_user+0x44/0x50
[   15.919889]  [<c13de8e4>] SYSC_socketcall+0x3b4/0x990
[   15.919891]  [<c107ebfb>] ? trace_hardirqs_on+0xb/0x10
[   15.919897]  [<c10f28ba>] ? free_hot_cold_page_list+0x3a/0xa0
[   15.919900]  [<c10f73cf>] ? release_pages+0x6f/0x1c0
[   15.919905]  [<c111f792>] ? free_pages_and_swap_cache+0x92/0xb0
[   15.919908]  [<c110ccd3>] ? tlb_flush_mmu_free+0x23/0x40
[   15.919910]  [<c107e9cd>] ? mark_held_locks+0x5d/0x80
[   15.919914]  [<c112aa45>] ? kmem_cache_free+0xd5/0x100
[   15.919916]  [<c107ebfb>] ? trace_hardirqs_on+0xb/0x10
[   15.919919]  [<c1113d8a>] ? remove_vma+0x4a/0x50
[   15.919922]  [<c1115d46>] ? do_munmap+0x236/0x300
[   15.919924]  [<c14dcc03>] ? sysenter_exit+0xf/0x4c
[   15.919927]  [<c13def7e>] SyS_socketcall+0xe/0x10
[   15.919929]  [<c14dcbd0>] sysenter_do_call+0x12/0x36
