From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: scheduling while atomic: ifup-bonding/3711/0x00000002 -- V3.6.7
Date: Wed, 28 Nov 2012 13:47:08 +0800
Message-ID: <CAM_iQpUW2Oz9p0K0gGKc6JoD7WAu0kJtRa4uBSe+WfXg0Nn3jA@mail.gmail.com>
References: <50B5248A.5010908@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Linda Walsh <lkml@tlinx.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50B5248A.5010908@tlinx.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc netdev...

On Wed, Nov 28, 2012 at 4:37 AM, Linda Walsh <lkml@tlinx.org> wrote:
>
>
> Is this a known problem / bug, or should I file a bug on it?  It doesn't
> cause a complete failure, and it happens multiple times (~28 times
> in 2.5 days?... so maybe 10x/day?)  about 8 start with ifup, and the rest
> start @ kworker -- both happen upon enabling the bonding driver
> on a 10Gb dual port adapter (trying to get 1 20Gb adapter).
>
> The 2 tracebacks tyeps (ifup-bonding + kworker) follow:


Does this quick fix help?

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5f5b69f..4a4d9eb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1785,7 +1785,9 @@ int bond_enslave(struct net_device *bond_dev,
struct net_device *slave_dev)
                new_slave->link == BOND_LINK_DOWN ? "DOWN" :
                        (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));

+       read_unlock(&bond->lock);
        bond_update_speed_duplex(new_slave);
+       read_lock(&bond->lock);

        if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
                /* if there is a primary slave, remember it */

Thanks!

>
>
> ----------------- ifup-bonding traceback:
>
> [  229.208603] bonding: bond0: Setting MII monitoring interval to 100.
> [  229.222336] bonding: bond0: Adding slave p2p1.
> [  229.685599] BUG: scheduling while atomic: ifup-bonding/3711/0x00000002
> [  229.692166] 4 locks held by ifup-bonding/3711:
> [  229.696645]  #0:  (&buffer->mutex){......}, at: [<ffffffff811acd3f>]
> sysfs_write_file+0x3f/0x150
> [  229.705721]  #1:  (s_active#75){......}, at: [<ffffffff811acdbb>]
> sysfs_write_file+0xbb/0x150
> [  229.714538]  #2:  (rtnl_mutex){......}, at: [<ffffffff8159e1e0>]
> rtnl_trylock+0x10/0x20
> [  229.722772]  #3:  (&bond->lock){......}, at: [<ffffffffa02964af>]
> bond_enslave+0x4df/0xb50 [bonding]
> [  229.732188] Modules linked in: bonding fan mousedev kvm_intel iTCO_wdt
> iTCO_vendor_support gpio_ich kvm acpi_cpufreq mperf tpm_tis tpm tpm_bios
> processor button
> [  229.747197] Pid: 3711, comm: ifup-bonding Not tainted 3.6.7-Isht-Van #1
> [  229.753843] Call Trace:
> [  229.756333]  [<ffffffff8168ead9>] __schedule_bug+0x5e/0x6c
> [  229.761863]  [<ffffffff8169893c>] __schedule+0x77c/0x810
> [  229.767214]  [<ffffffff81698a54>] schedule+0x24/0x70
> [  229.772214]  [<ffffffff81697b6c>]
> schedule_hrtimeout_range_clock+0xfc/0x140
> [  229.779210]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  229.784645]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
> [  229.790950]  [<ffffffff81697bbe>] schedule_hrtimeout_range+0xe/0x10
> [  229.797254]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
> [  229.802611]  [<ffffffff814c519c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x110
> [  229.809429]  [<ffffffff814c146d>] ixgbe_read_phy_reg_generic+0x3d/0x120
> [  229.816078]  [<ffffffff814c16dc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [  229.824022]  [<ffffffffa02964af>] ? bond_enslave+0x4df/0xb50 [bonding]
> [  229.830581]  [<ffffffff814b93e4>] ixgbe_get_settings+0x34/0x2b0
> [  229.836534]  [<ffffffff81594385>] __ethtool_get_settings+0x85/0x140
> [  229.842837]  [<ffffffffa0292303>] bond_update_speed_duplex+0x23/0x60
> [bonding]
> [  229.850092]  [<ffffffffa0296518>] bond_enslave+0x548/0xb50 [bonding]
> [  229.856478]  [<ffffffffa029e62f>] bonding_store_slaves+0x13f/0x190
> [bonding]
> [  229.863556]  [<ffffffff813fe163>] dev_attr_store+0x13/0x30
> [  229.869074]  [<ffffffff811acdd4>] sysfs_write_file+0xd4/0x150
> [  229.874856]  [<ffffffff81142c01>] vfs_write+0xb1/0x180
> [  229.880034]  [<ffffffff81142f28>] sys_write+0x48/0x90
> [  229.885125]  [<ffffffff8169b162>] system_call_fastpath+0x16/0x1b
> [  229.891259] BUG: scheduling while atomic: ifup-bonding/3711/0x00000002
> [  229.897839] 4 locks held by ifup-bonding/3711:
> [  229.902320]  #0:  (&buffer->mutex){......}, at: [<ffffffff811acd3f>]
> sysfs_write_file+0x3f/0x150
> [  229.911395]  #1:  (s_active#75){......}, at: [<ffffffff811acdbb>]
> sysfs_write_file+0xbb/0x150
> [  229.920212]  #2:  (rtnl_mutex){......}, at: [<ffffffff8159e1e0>]
> rtnl_trylock+0x10/0x20
> [  229.928449]  #3:  (&bond->lock){......}, at: [<ffffffffa02964af>]
> bond_enslave+0x4df/0xb50 [bonding]
> [  229.937866] Modules linked in: bonding fan mousedev kvm_intel iTCO_wdt
> iTCO_vendor_support gpio_ich kvm acpi_cpufreq mperf tpm_tis tpm tpm_bios
> processor button
> [  229.952904] Pid: 3711, comm: ifup-bonding Tainted: G        W
> 3.6.7-Isht-Van #1
> [  229.960507] Call Trace:
> [  229.962997]  [<ffffffff8168ead9>] __schedule_bug+0x5e/0x6c
> [  229.968526]  [<ffffffff8169893c>] __schedule+0x77c/0x810
> [  229.973875]  [<ffffffff81698a54>] schedule+0x24/0x70
> [  229.978876]  [<ffffffff81697b6c>]
> schedule_hrtimeout_range_clock+0xfc/0x140
> [  229.985871]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  229.991303]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  229.996739]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
> [  230.003040]  [<ffffffff81697bbe>] schedule_hrtimeout_range+0xe/0x10
> [  230.009344]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
> [  230.014698]  [<ffffffff814c50ce>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [  230.021435]  [<ffffffff814c1531>] ixgbe_read_phy_reg_generic+0x101/0x120
> [  230.028171]  [<ffffffff814c16dc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [  230.036117]  [<ffffffffa02964af>] ? bond_enslave+0x4df/0xb50 [bonding]
> [  230.042677]  [<ffffffff814b93e4>] ixgbe_get_settings+0x34/0x2b0
> [  230.048630]  [<ffffffff81594385>] __ethtool_get_settings+0x85/0x140
> [  230.054934]  [<ffffffffa0292303>] bond_update_speed_duplex+0x23/0x60
> [bonding]
> [  230.062189]  [<ffffffffa0296518>] bond_enslave+0x548/0xb50 [bonding]
> [  230.068580]  [<ffffffffa029e62f>] bonding_store_slaves+0x13f/0x190
> [bonding]
> [  230.075660]  [<ffffffff813fe163>] dev_attr_store+0x13/0x30
> [  230.081189]  [<ffffffff811acdd4>] sysfs_write_file+0xd4/0x150
> [  230.086971]  [<ffffffff81142c01>] vfs_write+0xb1/0x180
> [  230.092148]  [<ffffffff81142f28>] sys_write+0x48/0x90
> [  230.097245]  [<ffffffff8169b162>] system_call_fastpath+0x16/0x1b
> [  230.103427] bonding: bond0: enslaving p2p1 as an active interface with a
> down link.
> [  230.120623] bonding: bond0: Adding slave p2p2.
> [  230.575194] BUG: scheduling while atomic: ifup-bonding/3711/0x00000002
> [  230.581782] 4 locks held by ifup-bonding/3711:
> [  230.586262]  #0:  (&buffer->mutex){......}, at: [<ffffffff811acd3f>]
> sysfs_write_file+0x3f/0x150
> [  230.595287]  #1:  (s_active#75){......}, at: [<ffffffff811acdbb>]
> sysfs_write_file+0xbb/0x150
> [  230.604105]  #2:  (rtnl_mutex){......}, at: [<ffffffff8159e1e0>]
> rtnl_trylock+0x10/0x20
> [  230.612393]  #3:  (&bond->lock){......}, at: [<ffffffffa02964af>]
> bond_enslave+0x4df/0xb50 [bonding]
> [  230.621801] Modules linked in: bonding fan mousedev kvm_intel iTCO_wdt
> iTCO_vendor_support gpio_ich kvm acpi_cpufreq mperf tpm_tis tpm tpm_bios
> processor button
> [  230.636922] Pid: 3711, comm: ifup-bonding Tainted: G        W
> 3.6.7-Isht-Van #1
> [  230.644516] Call Trace:
> [  230.647009]  [<ffffffff8168ead9>] __schedule_bug+0x5e/0x6c
> [  230.652537]  [<ffffffff8169893c>] __schedule+0x77c/0x810
> [  230.657886]  [<ffffffff81698a54>] schedule+0x24/0x70
> [  230.662889]  [<ffffffff81697b6c>]
> schedule_hrtimeout_range_clock+0xfc/0x140
> [  230.669884]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  230.675320]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
> [  230.681622]  [<ffffffff81697bbe>] schedule_hrtimeout_range+0xe/0x10
> [  230.687921]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
> [  230.693283]  [<ffffffff814c519c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x110
> [  230.700113]  [<ffffffff814c146d>] ixgbe_read_phy_reg_generic+0x3d/0x120
> [  230.706763]  [<ffffffff814c16dc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [  230.714713]  [<ffffffffa02964af>] ? bond_enslave+0x4df/0xb50 [bonding]
> [  230.721275]  [<ffffffff814b93e4>] ixgbe_get_settings+0x34/0x2b0
> [  230.727231]  [<ffffffff81594385>] __ethtool_get_settings+0x85/0x140
> [  230.733535]  [<ffffffffa0292303>] bond_update_speed_duplex+0x23/0x60
> [bonding]
> [  230.740790]  [<ffffffffa0296518>] bond_enslave+0x548/0xb50 [bonding]
> [  230.747189]  [<ffffffffa029e62f>] bonding_store_slaves+0x13f/0x190
> [bonding]
> [  230.754270]  [<ffffffff813fe163>] dev_attr_store+0x13/0x30
> [  230.759792]  [<ffffffff811acdd4>] sysfs_write_file+0xd4/0x150
> [  230.765576]  [<ffffffff81142c01>] vfs_write+0xb1/0x180
> [  230.770753]  [<ffffffff81142f28>] sys_write+0x48/0x90
> [  230.775840]  [<ffffffff8169b162>] system_call_fastpath+0x16/0x1b
> [  230.781933] BUG: scheduling while atomic: ifup-bonding/3711/0x00000002
> [  230.788499] 4 locks held by ifup-bonding/3711:
> [  230.793021]  #0:  (&buffer->mutex){......}, at: [<ffffffff811acd3f>]
> sysfs_write_file+0x3f/0x150
> [  230.802051]  #1:  (s_active#75){......}, at: [<ffffffff811acdbb>]
> sysfs_write_file+0xbb/0x150
> [  230.810872]  #2:  (rtnl_mutex){......}, at: [<ffffffff8159e1e0>]
> rtnl_trylock+0x10/0x20
> [  230.819160]  #3:  (&bond->lock){......}, at: [<ffffffffa02964af>]
> bond_enslave+0x4df/0xb50 [bonding]
> [  230.828575] Modules linked in: bonding fan mousedev kvm_intel iTCO_wdt
> iTCO_vendor_support gpio_ich kvm acpi_cpufreq mperf tpm_tis tpm tpm_bios
> processor button
> [  230.843673] Pid: 3711, comm: ifup-bonding Tainted: G        W
> 3.6.7-Isht-Van #1
> [  230.851271] Call Trace:
> [  230.853759]  [<ffffffff8168ead9>] __schedule_bug+0x5e/0x6c
> [  230.859282]  [<ffffffff8169893c>] __schedule+0x77c/0x810
> [  230.864637]  [<ffffffff81698a54>] schedule+0x24/0x70
> [  230.869598]  [<ffffffff81697b6c>]
> schedule_hrtimeout_range_clock+0xfc/0x140
> [  230.876548]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  230.881966]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  230.887359]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
> [  230.893649]  [<ffffffff81697bbe>] schedule_hrtimeout_range+0xe/0x10
> [  230.899907]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
> [  230.905213]  [<ffffffff814c50ce>] ixgbe_release_swfw_sync_X540+0x4e/0x60
> [  230.911908]  [<ffffffff814c1531>] ixgbe_read_phy_reg_generic+0x101/0x120
> [  230.918599]  [<ffffffff814c16dc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [  230.926501]  [<ffffffffa02964af>] ? bond_enslave+0x4df/0xb50 [bonding]
> [  230.933018]  [<ffffffff814b93e4>] ixgbe_get_settings+0x34/0x2b0
> [  230.938929]  [<ffffffff81594385>] __ethtool_get_settings+0x85/0x140
> [  230.945185]  [<ffffffffa0292303>] bond_update_speed_duplex+0x23/0x60
> [bonding]
> [  230.952392]  [<ffffffffa0296518>] bond_enslave+0x548/0xb50 [bonding]
> [  230.958739]  [<ffffffffa029e62f>] bonding_store_slaves+0x13f/0x190
> [bonding]
> [  230.965774]  [<ffffffff813fe163>] dev_attr_store+0x13/0x30
> [  230.971251]  [<ffffffff811acdd4>] sysfs_write_file+0xd4/0x150
> [  230.976988]  [<ffffffff81142c01>] vfs_write+0xb1/0x180
> [  230.982146]  [<ffffffff81142f28>] sys_write+0x48/0x90
> [  230.987192]  [<ffffffff8169b162>] system_call_fastpath+0x16/0x1b
> [  230.993297] bonding: bond0: enslaving p2p2 as an active interface with a
> down link.
> [  231.014761] ixgbe 0000:06:00.0: p2p1: changing MTU from 1500 to 9000
> [  231.863728] ixgbe 0000:06:00.1: p2p2: changing MTU from 1500 to 9000
>
>
> ---------- kworker traceback:
> [  236.268690] ixgbe 0000:06:00.0: p2p1: NIC Link is Up 10 Gbps, Flow
> Control: None
> [  236.305628] BUG: scheduling while atomic: kworker/u:2/106/0x00000002
> [  236.312025] 4 locks held by kworker/u:2/106:
> [  236.312037]  #0:  ((bond_dev->name)){......}, at: [<ffffffff8105a956>]
> process_one_work+0x146/0x680
> [  236.312049]  #1:  ((&(&bond->mii_work)->work)){......}, at:
> [<ffffffff8105a956>] process_one_work+0x146/0x680
> [  236.312056]  #2:  (rtnl_mutex){......}, at: [<ffffffff8159e1e0>]
> rtnl_trylock+0x10/0x20
> [  236.312065]  #3:  (&bond->lock){......}, at: [<ffffffffa02955ad>]
> bond_mii_monitor+0x2ed/0x640 [bonding]
> [  236.312078] Modules linked in: ipv6 bonding fan mousedev kvm_intel
> iTCO_wdt iTCO_vendor_support gpio_ich kvm acpi_cpufreq mperf tpm_tis tpm
> tpm_bios processor button
> [  236.312082] Pid: 106, comm: kworker/u:2 Tainted: G        W
> 3.6.7-Isht-Van #1
> [  236.312083] Call Trace:
> [  236.312092]  [<ffffffff8168ead9>] __schedule_bug+0x5e/0x6c
> [  236.312102]  [<ffffffff8169893c>] __schedule+0x77c/0x810
> [  236.312108]  [<ffffffff81698a54>] schedule+0x24/0x70
> [  236.312114]  [<ffffffff81697b6c>]
> schedule_hrtimeout_range_clock+0xfc/0x140
> [  236.312121]  [<ffffffff81064c80>] ? update_rmtp+0x60/0x60
> [  236.312129]  [<ffffffff81065a1f>] ? hrtimer_start_range_ns+0xf/0x20
> [  236.312134]  [<ffffffff81697bbe>] schedule_hrtimeout_range+0xe/0x10
> [  236.312144]  [<ffffffff8104bddb>] usleep_range+0x3b/0x40
> [  236.312150]  [<ffffffff814c519c>] ixgbe_acquire_swfw_sync_X540+0xbc/0x110
> [  236.312157]  [<ffffffff814c146d>] ixgbe_read_phy_reg_generic+0x3d/0x120
> [  236.312161]  [<ffffffff814c16dc>]
> ixgbe_get_copper_link_capabilities_generic+0x2c/0x60
> [  236.312166]  [<ffffffffa02955ad>] ? bond_mii_monitor+0x2ed/0x640
> [bonding]
> [  236.312170]  [<ffffffff814b93e4>] ixgbe_get_settings+0x34/0x2b0
> [  236.312177]  [<ffffffff81594385>] __ethtool_get_settings+0x85/0x140
> [  236.312182]  [<ffffffffa0292303>] bond_update_speed_duplex+0x23/0x60
> [bonding]
> [  236.312188]  [<ffffffffa0295614>] bond_mii_monitor+0x354/0x640 [bonding]
> [  236.312198]  [<ffffffff8105a9b7>] process_one_work+0x1a7/0x680
> [  236.312203]  [<ffffffff8105a956>] ? process_one_work+0x146/0x680
> [  236.312210]  [<ffffffff8108c7ce>] ? put_lock_stats.isra.21+0xe/0x40
> [  236.312215]  [<ffffffffa02952c0>] ? bond_loadbalance_arp_mon+0x2c0/0x2c0
> [bonding]
> [  236.312234]  [<ffffffff8105b9ed>] worker_thread+0x18d/0x4f0
> [  236.312239]  [<ffffffff81070991>] ? sub_preempt_count+0x51/0x60
> [  236.312242]  [<ffffffff8105b860>] ? manage_workers+0x320/0x320
> [  236.312247]  [<ffffffff81060f7d>] kthread+0x9d/0xb0
> [  236.312250]  [<ffffffff8169c264>] kernel_thread_helper+0x4/0x10
> [  236.312254]  [<ffffffff8106c197>] ? finish_task_switch+0x77/0x100
> [  236.312262]  [<ffffffff8169a4a6>] ? _raw_spin_unlock_irq+0x36/0x60
> [  236.312268]  [<ffffffff8169a9dd>] ? retint_restore_args+0xe/0xe
> [  236.312273]  [<ffffffff81060ee0>] ? flush_kthread_worker+0x160/0x160
> [  236.312277]  [<ffffffff8169c260>] ? gs_change+0xb/0xb
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
