From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Thu, 07 Mar 2013 16:04:08 +0800
Message-ID: <513849F8.3090302@linux.vnet.ibm.com>
References: <513063B4.8070604@tlinx.org> <1362155087.15793.54.camel@edumazet-glaptop> <51317FCF.1070400@tlinx.org> <51318C5B.60001@tlinx.org> <51382AFE.5080302@linux.vnet.ibm.com> <51383C47.7050009@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Linda Walsh <lkml@tlinx.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51383C47.7050009@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/2013 03:05 PM, Linda Walsh wrote:
[snip]
> [   24.820010] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   24.826415] 4 locks held by kworker/u:2/109:
> [   24.826425]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.826428]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.826435]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   24.826441]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   24.826448] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   24.826451] Pid: 109, comm: kworker/u:2 Not tainted 3.8.1-Isht-Van #6
> [   24.826452] Call Trace:
> [   24.826459]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   24.826475]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   24.826479]  [<ffffffff81634744>] schedule+0x24/0x70
> [   24.826488]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   24.826495]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.826499]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   24.826507]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   24.826512]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   24.826518]  [<ffffffff814b2d8c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
> [   24.826527]  [<ffffffff814aeb1d>] ixgbe_read_phy_reg_generic+0x3d/0x140
> [   24.826532]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   24.826537]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   24.826543]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   24.826546]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   24.826552]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   24.826554]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630

And both bond_enslave() and bond_mii_monitor() are using bond_update_speed_duplex()
with preempt disabled.

Along with the changes in bond_enslave(), I think you also need this (untested):

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 11d01d6..9af143a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2373,7 +2373,9 @@ static void bond_miimon_commit(struct bonding *bond)
                                bond_set_backup_slave(slave);
                        }
 
+                       read_unlock(&bond->lock);
                        bond_update_speed_duplex(slave);
+                       read_lock(&bond->lock);
 
                        pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
                                bond->dev->name, slave->dev->name,


Regards,
Michael Wang

> [   24.826556]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   24.826558]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   24.826560]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   24.826563]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   24.826565]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   24.826569]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   24.826573]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   24.826576]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.826578]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   24.826580]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.829930] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   24.836284] 4 locks held by kworker/u:2/109:
> [   24.836287]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.836297]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   24.836304]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   24.836312]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   24.836320] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   24.836334] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   24.836336] Call Trace:
> [   24.836342]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   24.836348]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   24.836352]  [<ffffffff81634744>] schedule+0x24/0x70
> [   24.836357]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   24.836362]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.836366]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   24.836371]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   24.836375]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   24.836380]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   24.836385]  [<ffffffff814b2cbe>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [   24.836390]  [<ffffffff814aebed>] ixgbe_read_phy_reg_generic+0x10d/0x140
> [   24.836395]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   24.836400]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   24.836404]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   24.836409]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   24.836413]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   24.836418]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   24.836422]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   24.836426]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   24.836431]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   24.836436]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   24.836440]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   24.836445]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   24.836449]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   24.836455]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.836459]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   24.836464]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   24.839952] bonding: bond0: link status definitely up for interface
> eth_s2_0, 10000 Mbps full duplex.
> [   24.839968] bonding: bond0: first active interface up!
> [   24.955598] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: Rx/Tx
> [   25.621770] ixgbe 0000:06:00.1 eth_s2_1: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [   25.838277] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   25.844673] 4 locks held by kworker/u:2/109:
> [   25.844676]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.844689]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.844705]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   25.844715]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   25.844724] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   25.844740] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   25.844743] Call Trace:
> [   25.844752]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   25.844759]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   25.844764]  [<ffffffff81634744>] schedule+0x24/0x70
> [   25.844770]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   25.844776]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.844781]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   25.844786]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   25.844791]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   25.844798]  [<ffffffff814b2d8c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x100
> [   25.844805]  [<ffffffff814aeb1d>] ixgbe_read_phy_reg_generic+0x3d/0x140
> [   25.844811]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   25.844818]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   25.844832]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   25.844845]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   25.844858]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   25.844866]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   25.844871]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   25.844875]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   25.844880]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   25.844885]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   25.844890]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   25.844896]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   25.844901]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   25.844907]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.844911]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   25.844916]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.848369] BUG: scheduling while atomic: kworker/u:2/109/0x00000002
> [   25.854761] 4 locks held by kworker/u:2/109:
> [   25.854764]  #0:  ((bond_dev->name)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.854774]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105da4d>] process_one_work+0x13d/0x5d0
> [   25.854781]  #2:  (rtnl_mutex){......}, at: [<ffffffff81590c00>]
> rtnl_trylock+0x10/0x20
> [   25.854790]  #3:  (&bond->lock){......}, at: [<ffffffff8145af55>]
> bond_mii_monitor+0x2d5/0x630
> [   25.854798] Modules linked in: iptable_filter kvm_intel kvm iTCO_wdt
> acpi_cpufreq mperf button mousedev processor
> [   25.854812] Pid: 109, comm: kworker/u:2 Tainted: G        W   
> 3.8.1-Isht-Van #6
> [   25.854814] Call Trace:
> [   25.854820]  [<ffffffff8162b039>] __schedule_bug+0x5e/0x6c
> [   25.854826]  [<ffffffff816345a2>] __schedule+0x762/0x7f0
> [   25.854831]  [<ffffffff81634744>] schedule+0x24/0x70
> [   25.854835]  [<ffffffff81633704>]
> schedule_hrtimeout_range_clock+0xa4/0x130
> [   25.854840]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.854844]  [<ffffffff81068250>] ? update_rmtp+0x60/0x60
> [   25.854849]  [<ffffffff81068f9f>] ? hrtimer_start_range_ns+0xf/0x20
> [   25.854854]  [<ffffffff8163379e>] schedule_hrtimeout_range+0xe/0x10
> [   25.854858]  [<ffffffff8104ec1b>] usleep_range+0x3b/0x40
> [   25.854863]  [<ffffffff814b2cbe>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [   25.854869]  [<ffffffff814aebed>] ixgbe_read_phy_reg_generic+0x10d/0x140
> [   25.854874]  [<ffffffff814aedbc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [   25.854879]  [<ffffffff8145af55>] ? bond_mii_monitor+0x2d5/0x630
> [   25.854883]  [<ffffffff814a64f4>] ixgbe_get_settings+0x34/0x340
> [   25.854888]  [<ffffffff81586ac8>] __ethtool_get_settings+0x88/0x130
> [   25.854892]  [<ffffffff814568a3>] bond_update_speed_duplex+0x23/0x60
> [   25.854897]  [<ffffffff8145afc4>] bond_mii_monitor+0x344/0x630
> [   25.854901]  [<ffffffff8105dab1>] process_one_work+0x1a1/0x5d0
> [   25.854905]  [<ffffffff8105da4d>] ? process_one_work+0x13d/0x5d0
> [   25.854910]  [<ffffffff8145ac80>] ? bond_loadbalance_arp_mon+0x300/0x300
> [   25.854915]  [<ffffffff8105ed60>] worker_thread+0x160/0x3f0
> [   25.854920]  [<ffffffff8105ec00>] ? manage_workers+0x290/0x290
> [   25.854925]  [<ffffffff81064446>] kthread+0xd6/0xe0
> [   25.854929]  [<ffffffff8107004a>] ? finish_task_switch+0x3a/0x100
> [   25.854935]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.854939]  [<ffffffff81636fec>] ret_from_fork+0x7c/0xb0
> [   25.854944]  [<ffffffff81064370>] ? flush_kthread_worker+0x160/0x160
> [   25.858392] bonding: bond0: link status definitely up for interface
> eth_s2_1, 10000 Mbps full duplex.
> [   27.292402] bnx2 0000:01:00.1 eth3: NIC Copper Link is Up, 1000 Mbps
> full duplex
> [   27.292406] , receive & transmit flow control ON
> [   28.682172] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: Rx/Tx
> [   29.037441] Status code returned 0xc000005e NT_STATUS_NO_LOGON_SERVERS
> [   29.037451] CIFS VFS: Send error in SessSetup = -5
> [   29.043058] CIFS VFS: cifs_mount failed w/return code = -5
> [   30.005962] Status code returned 0xc000005e NT_STATUS_NO_LOGON_SERVERS
> [   30.005971] CIFS VFS: Send error in SessSetup = -5
> [   30.011333] CIFS VFS: cifs_mount failed w/return code = -5
> [   31.093294] Status code returned 0xc000000d NT_STATUS_INVALID_PARAMETER
> [   31.093303] CIFS VFS: Send error in SessSetup = -22
> [   31.098672] CIFS VFS: cifs_mount failed w/return code = -22
> [   32.339022] device eth0 entered promiscuous mode
> [   32.523684] device eth1 entered promiscuous mode
> [   32.739312] device eth2 entered promiscuous mode
> [   32.922051] device eth3 entered promiscuous mode
> [   33.075705] device bond0 entered promiscuous mode
> [   33.075711] device eth_s2_0 entered promiscuous mode
> [   33.076022] device eth_s2_1 entered promiscuous mode
> [   34.783087] u32 classifier
> [   34.783089]     Performance counters on
> [   34.783090]     input device check on
> [   34.783091]     Actions configured
> [   40.834154] bnx2 0000:01:00.0 eth2: NIC Copper Link is Up, 100 Mbps
> full duplex
> [   40.834158] , receive & transmit flow control ON
> 
> 
> 
