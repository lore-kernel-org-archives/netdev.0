From: Linda Walsh <lkml@tlinx.org>
Subject: Re: BUG: scheduling while atomic: ifup-bonding/3711/0x00000002 -- V3.6.7
Date: Wed, 28 Nov 2012 17:04:54 -0800
Message-ID: <50B6B4B6.3070304@tlinx.org>
References: <50B5248A.5010908@tlinx.org> <CAM_iQpUW2Oz9p0K0gGKc6JoD7WAu0kJtRa4uBSe+WfXg0Nn3jA@mail.gmail.com> <50B67F6B.6050008@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50B67F6B.6050008@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cong Wang wrote:
> On Wed, Nov 28, 2012 at 4:37 AM, Linda Walsh <lkml@tlinx.org> wrote:  
>> Is this a known problem / bug, or should I file a bug on it? 
> Does this quick fix help?
> ...
> Thanks!
>   

    Applied:
--- bond_main.c.orig  2012-09-30 16:47:46.000000000 -0700
+++ bond_main.c 2012-11-28 12:58:34.064931997 -0800
@@ -1778,7 +1778,9 @@
    new_slave->link == BOND_LINK_DOWN ? "DOWN" :
      (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
+ read_unlock(&bond->lock);
  bond_update_speed_duplex(new_slave);
+ read_lock(&bond->lock);
 
  if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
    /* if there is a primary slave, remember it */
----
Recompile/run:
Linux Ishtar 3.6.8-Isht-Van #4 SMP PREEMPT Wed Nov 28 12:59:13 PST 2012 
x86_64 x86_64 x86_64 GNU/Linux

---

Similar.  The tracebacks are below.

Since I am running in round-robin, trying for RAID0 of the 2 links--
simple bandwidth aggregation, do I even need miimon?  I mean, what load
is there to balance?

Not that this is likely the root of the bug, but it might make it
not happen in my case, if I remove the load-bal stuff...??




[   52.457633] bonding: bond0: Adding slave p2p1.
[   52.941390] bonding: bond0: enslaving p2p1 as an active interface 
with a down link.
[   52.959329] bonding: bond0: Adding slave p2p2.
[   53.442769] bonding: bond0: enslaving p2p2 as an active interface 
with a down link.
[   58.588410] ixgbe 0000:06:00.0: p2p1: NIC Link is Up 10 Gbps, Flow 
Control: None
[   58.666760] BUG: scheduling while atomic: kworker/u:1/103/0x00000002
[   58.673144] 4 locks held by kworker/u:1/103:
[   58.673145]  #0:  ((bond_dev->name)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   58.673161]  #1:  ((&(&bond->mii_work)->work)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   58.673167]  #2:  (rtnl_mutex){......}, at: [<ffffffff815a4dd0>] 
rtnl_trylock+0x10/0x20
[   58.673175]  #3:  (&bond->lock){......}, at: [<ffffffff81480b5d>] 
bond_mii_monitor+0x2ed/0x640
[   58.673183] Modules linked in: fan kvm_intel mousedev kvm iTCO_wdt 
iTCO_vendor_support acpi_cpufreq tpm_tis tpm tpm_bios mperf processor
[   58.673196] Pid: 103, comm: kworker/u:1 Not tainted 3.6.8-Isht-Van #4
[   58.673198] Call Trace:
[   58.673203]  [<ffffffff8167bb36>] __schedule_bug+0x5e/0x6c
[   58.673208]  [<ffffffff816859bc>] __schedule+0x77c/0x810
[   58.673211]  [<ffffffff81685ad4>] schedule+0x24/0x70
[   58.673214]  [<ffffffff81684bec>] 
schedule_hrtimeout_range_clock+0xfc/0x140
[   58.673218]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   58.673222]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
[   58.673225]  [<ffffffff81684c3e>] schedule_hrtimeout_range+0xe/0x10
[   58.673229]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
[   58.673235]  [<ffffffff814d220c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x110
[   58.673238]  [<ffffffff814ce4dd>] ixgbe_read_phy_reg_generic+0x3d/0x120
[   58.673241]  [<ffffffff814ce74c>] 
ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
[   58.673244]  [<ffffffff81480b5d>] ? bond_mii_monitor+0x2ed/0x640
[   58.673248]  [<ffffffff814c6454>] ixgbe_get_settings+0x34/0x2b0
[   58.673253]  [<ffffffff8159af55>] __ethtool_get_settings+0x85/0x140
[   58.673256]  [<ffffffff8147c6e3>] bond_update_speed_duplex+0x23/0x60
[   58.673259]  [<ffffffff81480bc4>] bond_mii_monitor+0x354/0x640
[   58.673262]  [<ffffffff8105a9b7>] process_one_work+0x1a7/0x680
[   58.673264]  [<ffffffff8105a956>] ? process_one_work+0x146/0x680
[   58.673269]  [<ffffffff8108c7ce>] ? put_lock_stats.isra.21+0xe/0x40
[   58.673279]  [<ffffffff81480870>] ? bond_loadbalance_arp_mon+0x2c0/0x2c0
[   58.673286]  [<ffffffff8105b9ed>] worker_thread+0x18d/0x4f0
[   58.673296]  [<ffffffff81070991>] ? sub_preempt_count+0x51/0x60
[   58.673303]  [<ffffffff8105b860>] ? manage_workers+0x320/0x320
[   58.673312]  [<ffffffff81060f7d>] kthread+0x9d/0xb0
[   58.673317]  [<ffffffff816892e4>] kernel_thread_helper+0x4/0x10
[   58.673320]  [<ffffffff8106c197>] ? finish_task_switch+0x77/0x100
[   58.673323]  [<ffffffff81687526>] ? _raw_spin_unlock_irq+0x36/0x60
[   58.673326]  [<ffffffff81687a5d>] ? retint_restore_args+0xe/0xe
[   58.673329]  [<ffffffff81060ee0>] ? flush_kthread_worker+0x160/0x160
[   58.673332]  [<ffffffff816892e0>] ? gs_change+0xb/0xb
[   58.676704] BUG: scheduling while atomic: kworker/u:1/103/0x00000002
[   58.683107] 4 locks held by kworker/u:1/103:
[   58.683109]  #0:  ((bond_dev->name)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   58.683120]  #1:  ((&(&bond->mii_work)->work)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   58.683128]  #2:  (rtnl_mutex){......}, at: [<ffffffff815a4dd0>] 
rtnl_trylock+0x10/0x20
[   58.683136]  #3:  (&bond->lock){......}, at: [<ffffffff81480b5d>] 
bond_mii_monitor+0x2ed/0x640
[   58.683145] Modules linked in: fan kvm_intel mousedev kvm iTCO_wdt 
iTCO_vendor_support acpi_cpufreq tpm_tis tpm tpm_bios mperf processor
[   58.683162] Pid: 103, comm: kworker/u:1 Tainted: G        W    
3.6.8-Isht-Van #4
[   58.683164] Call Trace:
[   58.683170]  [<ffffffff8167bb36>] __schedule_bug+0x5e/0x6c
[   58.683175]  [<ffffffff816859bc>] __schedule+0x77c/0x810
[   58.683180]  [<ffffffff81685ad4>] schedule+0x24/0x70
[   58.683184]  [<ffffffff81684bec>] 
schedule_hrtimeout_range_clock+0xfc/0x140
[   58.683189]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   58.683194]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   58.683198]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
[   58.683203]  [<ffffffff81684c3e>] schedule_hrtimeout_range+0xe/0x10
[   58.683208]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
[   58.683213]  [<ffffffff814d213e>] ixgbe_release_swfw_sync_X540+0x4e/0x60
[   58.683217]  [<ffffffff814ce5a1>] ixgbe_read_phy_reg_generic+0x101/0x120
[   58.683222]  [<ffffffff814ce74c>] 
ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
[   58.683227]  [<ffffffff81480b5d>] ? bond_mii_monitor+0x2ed/0x640
[   58.683231]  [<ffffffff814c6454>] ixgbe_get_settings+0x34/0x2b0
[   58.683237]  [<ffffffff8159af55>] __ethtool_get_settings+0x85/0x140
[   58.683241]  [<ffffffff8147c6e3>] bond_update_speed_duplex+0x23/0x60
[   58.683246]  [<ffffffff81480bc4>] bond_mii_monitor+0x354/0x640
[   58.683250]  [<ffffffff8105a9b7>] process_one_work+0x1a7/0x680
[   58.683254]  [<ffffffff8105a956>] ? process_one_work+0x146/0x680
[   58.683259]  [<ffffffff8108c7ce>] ? put_lock_stats.isra.21+0xe/0x40
[   58.683264]  [<ffffffff81480870>] ? bond_loadbalance_arp_mon+0x2c0/0x2c0
[   58.683268]  [<ffffffff8105b9ed>] worker_thread+0x18d/0x4f0
[   58.683273]  [<ffffffff81070991>] ? sub_preempt_count+0x51/0x60
[   58.683278]  [<ffffffff8105b860>] ? manage_workers+0x320/0x320
[   58.683283]  [<ffffffff81060f7d>] kthread+0x9d/0xb0
[   58.683288]  [<ffffffff816892e4>] kernel_thread_helper+0x4/0x10
[   58.683293]  [<ffffffff8106c197>] ? finish_task_switch+0x77/0x100
[   58.683297]  [<ffffffff81687526>] ? _raw_spin_unlock_irq+0x36/0x60
[   58.683301]  [<ffffffff81687a5d>] ? retint_restore_args+0xe/0xe
[   58.683306]  [<ffffffff81060ee0>] ? flush_kthread_worker+0x160/0x160
[   58.683311]  [<ffffffff816892e0>] ? gs_change+0xb/0xb
[   58.686755] bonding: bond0: link status definitely up for interface 
p2p1, 10000 Mbps full duplex.
[   58.943059] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: Rx/Tx
[   59.717848] ixgbe 0000:06:00.1: p2p2: NIC Link is Up 10 Gbps, Flow 
Control: None
[   59.784848] BUG: scheduling while atomic: kworker/u:1/103/0x00000002
[   59.791219] 4 locks held by kworker/u:1/103:
[   59.791222]  #0:  ((bond_dev->name)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   59.791237]  #1:  ((&(&bond->mii_work)->work)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   59.791245]  #2:  (rtnl_mutex){......}, at: [<ffffffff815a4dd0>] 
rtnl_trylock+0x10/0x20
[   59.791256]  #3:  (&bond->lock){......}, at: [<ffffffff81480b5d>] 
bond_mii_monitor+0x2ed/0x640
[   59.791276] Modules linked in: fan kvm_intel mousedev kvm iTCO_wdt 
iTCO_vendor_support acpi_cpufreq tpm_tis tpm tpm_bios mperf processor
[   59.791296] Pid: 103, comm: kworker/u:1 Tainted: G        W    
3.6.8-Isht-Van #4
[   59.791299] Call Trace:
[   59.791306]  [<ffffffff8167bb36>] __schedule_bug+0x5e/0x6c
[   59.791312]  [<ffffffff816859bc>] __schedule+0x77c/0x810
[   59.791317]  [<ffffffff81685ad4>] schedule+0x24/0x70
[   59.791322]  [<ffffffff81684bec>] 
schedule_hrtimeout_range_clock+0xfc/0x140
[   59.791329]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   59.791334]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
[   59.791339]  [<ffffffff81684c3e>] schedule_hrtimeout_range+0xe/0x10
[   59.791345]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
[   59.791352]  [<ffffffff814d220c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x110
[   59.791357]  [<ffffffff814ce4dd>] ixgbe_read_phy_reg_generic+0x3d/0x120
[   59.791361]  [<ffffffff814ce74c>] 
ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
[   59.791366]  [<ffffffff81480b5d>] ? bond_mii_monitor+0x2ed/0x640
[   59.791372]  [<ffffffff814c6454>] ixgbe_get_settings+0x34/0x2b0
[   59.791381]  [<ffffffff8159af55>] __ethtool_get_settings+0x85/0x140
[   59.791386]  [<ffffffff8147c6e3>] bond_update_speed_duplex+0x23/0x60
[   59.791389]  [<ffffffff81480bc4>] bond_mii_monitor+0x354/0x640
[   59.791393]  [<ffffffff8105a9b7>] process_one_work+0x1a7/0x680
[   59.791396]  [<ffffffff8105a956>] ? process_one_work+0x146/0x680
[   59.791402]  [<ffffffff8108c7ce>] ? put_lock_stats.isra.21+0xe/0x40
[   59.791411]  [<ffffffff81480870>] ? bond_loadbalance_arp_mon+0x2c0/0x2c0
[   59.791421]  [<ffffffff8105b9ed>] worker_thread+0x18d/0x4f0
[   59.791434]  [<ffffffff81070991>] ? sub_preempt_count+0x51/0x60
[   59.791442]  [<ffffffff8105b860>] ? manage_workers+0x320/0x320
[   59.791453]  [<ffffffff81060f7d>] kthread+0x9d/0xb0
[   59.791460]  [<ffffffff816892e4>] kernel_thread_helper+0x4/0x10
[   59.791464]  [<ffffffff8106c197>] ? finish_task_switch+0x77/0x100
[   59.791468]  [<ffffffff81687526>] ? _raw_spin_unlock_irq+0x36/0x60
[   59.791472]  [<ffffffff81687a5d>] ? retint_restore_args+0xe/0xe
[   59.791476]  [<ffffffff81060ee0>] ? flush_kthread_worker+0x160/0x160
[   59.791480]  [<ffffffff816892e0>] ? gs_change+0xb/0xb
[   59.794932] BUG: scheduling while atomic: kworker/u:1/103/0x00000002
[   59.801333] 4 locks held by kworker/u:1/103:
[   59.801340]  #0:  ((bond_dev->name)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   59.801345]  #1:  ((&(&bond->mii_work)->work)){......}, at: 
[<ffffffff8105a956>] process_one_work+0x146/0x680
[   59.801350]  #2:  (rtnl_mutex){......}, at: [<ffffffff815a4dd0>] 
rtnl_trylock+0x10/0x20
[   59.801356]  #3:  (&bond->lock){......}, at: [<ffffffff81480b5d>] 
bond_mii_monitor+0x2ed/0x640
[   59.801365] Modules linked in: fan kvm_intel mousedev kvm iTCO_wdt 
iTCO_vendor_support acpi_cpufreq tpm_tis tpm tpm_bios mperf processor
[   59.801368] Pid: 103, comm: kworker/u:1 Tainted: G        W    
3.6.8-Isht-Van #4
[   59.801369] Call Trace:
[   59.801373]  [<ffffffff8167bb36>] __schedule_bug+0x5e/0x6c
[   59.801380]  [<ffffffff816859bc>] __schedule+0x77c/0x810
[   59.801385]  [<ffffffff81685ad4>] schedule+0x24/0x70
[   59.801391]  [<ffffffff81684bec>] 
schedule_hrtimeout_range_clock+0xfc/0x140
[   59.801395]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   59.801399]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
[   59.801404]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
[   59.801409]  [<ffffffff81684c3e>] schedule_hrtimeout_range+0xe/0x10
[   59.801414]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
[   59.801419]  [<ffffffff814d213e>] ixgbe_release_swfw_sync_X540+0x4e/0x60
[   59.801424]  [<ffffffff814ce5a1>] ixgbe_read_phy_reg_generic+0x101/0x120
[   59.801429]  [<ffffffff814ce74c>] 
ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
[   59.801433]  [<ffffffff81480b5d>] ? bond_mii_monitor+0x2ed/0x640
[   59.801441]  [<ffffffff814c6454>] ixgbe_get_settings+0x34/0x2b0
[   59.801446]  [<ffffffff8159af55>] __ethtool_get_settings+0x85/0x140
[   59.801450]  [<ffffffff8147c6e3>] bond_update_speed_duplex+0x23/0x60
[   59.801471]  [<ffffffff81480bc4>] bond_mii_monitor+0x354/0x640
[   59.801475]  [<ffffffff8105a9b7>] process_one_work+0x1a7/0x680
[   59.801477]  [<ffffffff8105a956>] ? process_one_work+0x146/0x680
[   59.801481]  [<ffffffff8108c7ce>] ? put_lock_stats.isra.21+0xe/0x40
[   59.801484]  [<ffffffff81480870>] ? bond_loadbalance_arp_mon+0x2c0/0x2c0
[   59.801489]  [<ffffffff8105b9ed>] worker_thread+0x18d/0x4f0
[   59.801495]  [<ffffffff81070991>] ? sub_preempt_count+0x51/0x60
[   59.801500]  [<ffffffff8105b860>] ? manage_workers+0x320/0x320
[   59.801505]  [<ffffffff81060f7d>] kthread+0x9d/0xb0
[   59.801510]  [<ffffffff816892e4>] kernel_thread_helper+0x4/0x10
[   59.801515]  [<ffffffff8106c197>] ? finish_task_switch+0x77/0x100
[   59.801519]  [<ffffffff81687526>] ? _raw_spin_unlock_irq+0x36/0x60
[   59.801524]  [<ffffffff81687a5d>] ? retint_restore_args+0xe/0xe
[   59.801530]  [<ffffffff81060ee0>] ? flush_kthread_worker+0x160/0x160
[   59.801536]  [<ffffffff816892e0>] ? gs_change+0xb/0xb
[   59.804986] bonding: bond0: link status definitely up for interface 
p2p2, 10000 Mbps full duplex.
