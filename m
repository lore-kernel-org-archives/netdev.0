From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] e1000e: changed some expensive calls of udelay to
 usleep_range
Date: Tue, 12 Sep 2017 01:34:48 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C69F721@ORSMSX101.amr.corp.intel.com>
References: <1504643244-9233-1-git-send-email-Michael.Kardonik@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Matthew Tan <matthew.tan_1@nxp.com>
To: Kardonik Michael <Michael.Kardonik@nxp.com>,
        "leoyang.li@nxp.com" <leoyang.li@nxp.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        Shannon Nelson <shannon.nelson@intel.com>,
        "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
        "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
        "Vick, Matthew" <matthew.vick@intel.com>,
        John Ronciak <john.ronciak@intel.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504643244-9233-1-git-send-email-Michael.Kardonik@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Kardonik Michael
> Sent: Tuesday, September 5, 2017 1:27 PM
> To: leoyang.li@nxp.com; michael.kardonik@nxp.com; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse
> <jesse.brandeburg@intel.com>; Shannon Nelson
> <shannon.nelson@intel.com>; Wyborny, Carolyn
> <carolyn.wyborny@intel.com>; Skidmore, Donald C
> <donald.c.skidmore@intel.com>; Vick, Matthew <matthew.vick@intel.com>;
> John Ronciak <john.ronciak@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Cc: Matthew Tan <matthew.tan_1@nxp.com>
> Subject: [PATCH] e1000e: changed some expensive calls of udelay to
> usleep_range
> 
> Calls to udelay are not preemtable by userspace so userspace
> applications experience a large (~200us) latency when running on core0.
> Instead usleep_range can be used to be more friendly to userspace
> since it is preemtable. This is due to udelay using busy-wait loops
> while usleep_rang uses hrtimers instead. It is recommended to use
> udelay when the delay is <10us since at that precision overhead of
> usleep_range hrtimer setup causes issues. However, the replaced calls
> are for 50us and 100us so this should not be not an issue.
> There is no open bug that this patch is fixing, but we see a good
> boost in zero loss performance of specific user space application
> (dpdk l3fwd) when this patch is applied: we get from 32% of 10Gb line
> to 49%.
> 
> Signed-off-by: Matthew Tan <matthew.tan_1@nxp.com>
> Signed-off-by: Michael Kardonik <michael.kardonik@nxp.com>
> 
> ---
>  drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 

This version continues to crash the same systems as the last (an 82577 and an i218.)  As before, when link partner is a lower speed (autoneg set for 100 half for this instance) and I simply bring up the interface I start getting stuck CPU messages:
----------------------------------------------------------------------------
Message from syslogd@u1459 at Sep 11 17:16:25 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:4204]

Message from syslogd@u1459 at Sep 11 17:16:53 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:4204]
----------------------------------------------------------------------------

System becomes unresponsive and on a reboot I am able to pull out  a trace file:
----------------------------------------------------------------------------
Sep 11 17:16:00 u1459 kernel: INFO: rcu_sched self-detected stall on CPU
Sep 11 17:16:00 u1459 kernel:   2-...: (20999 ticks this GP) idle=a5a/140000000000001/0 softirq=8232/8232 fqs=5250
Sep 11 17:16:00 u1459 kernel:    (t=21000 jiffies g=4013 c=4012 q=616)
Sep 11 17:16:00 u1459 kernel: NMI backtrace for cpu 2
Sep 11 17:16:00 u1459 kernel: CPU: 2 PID: 4204 Comm: kworker/2:0 Tainted: G            E   4.13.0_next-queue_dev-queue_41b1c97 #39
Sep 11 17:16:00 u1459 kernel: Hardware name:                  /NUC5i5MYBE, BIOS MYBDWi5v.86A.0030.2016.0527.1657 05/27/2016
Sep 11 17:16:00 u1459 kernel: Workqueue: events linkwatch_event
Sep 11 17:16:00 u1459 kernel: Call Trace:
Sep 11 17:16:00 u1459 kernel: <IRQ>
Sep 11 17:16:00 u1459 kernel: dump_stack+0x51/0x78
Sep 11 17:16:00 u1459 kernel: nmi_cpu_backtrace+0xd3/0xe0
Sep 11 17:16:00 u1459 kernel: ? hw_nmi_get_sample_period+0x20/0x20
Sep 11 17:16:00 u1459 kernel: nmi_trigger_cpumask_backtrace+0xf5/0x130
Sep 11 17:16:00 u1459 kernel: arch_trigger_cpumask_backtrace+0x19/0x20
Sep 11 17:16:00 u1459 kernel: rcu_dump_cpu_stacks+0xb7/0xe0
Sep 11 17:16:00 u1459 kernel: print_cpu_stall+0xfa/0x170
Sep 11 17:16:00 u1459 kernel: ? __update_load_avg_cfs_rq+0x183/0x190
Sep 11 17:16:00 u1459 kernel: ? sched_slice+0x55/0xa0
Sep 11 17:16:00 u1459 kernel: check_cpu_stall+0x110/0x120
Sep 11 17:16:00 u1459 kernel: ? check_preempt_curr+0x73/0x90
Sep 11 17:16:00 u1459 kernel: ? ttwu_do_wakeup+0x2b/0x170
Sep 11 17:16:00 u1459 kernel: ? cpu_needs_another_gp+0x7b/0x80
Sep 11 17:16:00 u1459 kernel: ? notifier_call_chain+0x56/0x80
Sep 11 17:16:00 u1459 kernel: rcu_pending+0x5f/0x180
Sep 11 17:16:00 u1459 kernel: ? raw_notifier_call_chain+0x16/0x20
Sep 11 17:16:00 u1459 kernel: ? timekeeping_update+0xd9/0x130
Sep 11 17:16:00 u1459 kernel: rcu_check_callbacks+0x8a/0x1b0
Sep 11 17:16:00 u1459 kernel: ? account_system_index_time+0x6b/0x80
Sep 11 17:16:00 u1459 kernel: update_process_times+0x39/0x70
Sep 11 17:16:00 u1459 kernel: tick_sched_handle+0x37/0x70
Sep 11 17:16:00 u1459 kernel: tick_sched_timer+0x52/0xa0
Sep 11 17:16:00 u1459 kernel: __run_hrtimer+0x77/0x1b0
Sep 11 17:16:00 u1459 kernel: ? tick_nohz_handler+0xc0/0xc0
Sep 11 17:16:00 u1459 kernel: ? ktime_get+0x5a/0xd0
Sep 11 17:16:00 u1459 kernel: __hrtimer_run_queues+0x67/0x90
Sep 11 17:16:00 u1459 kernel: hrtimer_interrupt+0xa4/0x1d0
Sep 11 17:16:00 u1459 kernel: smp_apic_timer_interrupt+0x6b/0x140
Sep 11 17:16:00 u1459 kernel: ? irq_exit+0xa2/0xc0
Sep 11 17:16:00 u1459 kernel: ? do_IRQ+0x60/0xf0
Sep 11 17:16:00 u1459 kernel: apic_timer_interrupt+0x90/0xa0
Sep 11 17:16:00 u1459 kernel: </IRQ>
Sep 11 17:16:00 u1459 kernel: RIP: 0010:queued_spin_lock_slowpath+0x56/0x1d0
Sep 11 17:16:00 u1459 kernel: RSP: 0018:ffffc9000223f8c8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
Sep 11 17:16:00 u1459 kernel: RAX: 0000000000000101 RBX: ffff8802399f8000 RCX: 0000000000000101
Sep 11 17:16:00 u1459 kernel: RDX: ffffc9000223f948 RSI: 0000000000000001 RDI: ffff8802399fb1a0
Sep 11 17:16:00 u1459 kernel: RBP: ffffc9000223f968 R08: 0000000000000001 R09: ffff88024a1cf1a4
Sep 11 17:16:00 u1459 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff8802399f8840
Sep 11 17:16:00 u1459 kernel: R13: ffff88024a1cf0e4 R14: ffff88024a1cf0e4 R15: ffffc9000223fa48
Sep 11 17:16:00 u1459 kernel: ? __schedule+0x2ba/0x6d0
Sep 11 17:16:00 u1459 kernel: ? netlink_broadcast_filtered+0x15b/0x1a0
Sep 11 17:16:00 u1459 kernel: _raw_spin_lock+0x21/0x30
Sep 11 17:16:00 u1459 kernel: e1000e_get_stats64+0x2b/0x140 [e1000e]
Sep 11 17:16:00 u1459 kernel: dev_get_stats+0x3d/0xc0
Sep 11 17:16:00 u1459 kernel: ? __nla_reserve+0x53/0x70
Sep 11 17:16:00 u1459 kernel: rtnl_fill_stats+0x6b/0x150
Sep 11 17:16:00 u1459 kernel: rtnl_fill_ifinfo+0x542/0x920
Sep 11 17:16:00 u1459 kernel: ? if_nlmsg_size+0xae/0x180
Sep 11 17:16:00 u1459 kernel: rtmsg_ifinfo_build_skb+0x90/0xe0
Sep 11 17:16:00 u1459 kernel: rtmsg_ifinfo_event+0x35/0x60
Sep 11 17:16:00 u1459 kernel: rtmsg_ifinfo+0x13/0x20
Sep 11 17:16:00 u1459 kernel: netdev_state_change+0x46/0x50
Sep 11 17:16:00 u1459 kernel: linkwatch_do_dev+0x3c/0x60
Sep 11 17:16:00 u1459 kernel: __linkwatch_run_queue+0x13a/0x210
Sep 11 17:16:00 u1459 kernel: ? put_prev_entity+0x32/0x530
Sep 11 17:16:00 u1459 kernel: linkwatch_event+0x25/0x30
Sep 11 17:16:00 u1459 kernel: process_one_work+0x193/0x410
Sep 11 17:16:00 u1459 kernel: ? __schedule+0x2ba/0x6d0
Sep 11 17:16:00 u1459 kernel: ? activate_task+0x4e/0xc0
Sep 11 17:16:00 u1459 kernel: ? idle_balance+0x9d/0x2f0
Sep 11 17:16:00 u1459 kernel: ? schedule+0x3a/0xa0
Sep 11 17:16:00 u1459 kernel: worker_thread+0x7c/0x420
Sep 11 17:16:00 u1459 kernel: ? do_task_dead+0x41/0x50
Sep 11 17:16:00 u1459 kernel: ? default_wake_function+0x12/0x20
Sep 11 17:16:00 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep 11 17:16:00 u1459 kernel: ? schedule+0x3a/0xa0
Sep 11 17:16:00 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep 11 17:16:00 u1459 kernel: kthread+0x111/0x150
Sep 11 17:16:00 u1459 kernel: ? __kthread_init_worker+0x40/0x40
Sep 11 17:16:00 u1459 kernel: ret_from_fork+0x22/0x30
Sep 11 17:16:25 u1459 kernel: watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:4204]
Sep 11 17:16:25 u1459 kernel: Modules linked in: e1000e ptp pps_core ip6table_filter ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc nfsd lockd grace nfs_acl auth_rpcgss sunrpc autofs4 ipv6 crc_ccitt dm_mirror dm_region_hash dm_log vhost_net vhost tap tun kvm_intel kvm irqbypass uinput joydev ax88179_178a usbnet mii iTCO_wdt iTCO_vendor_support sg i2c_i801 lpc_ich mfd_core xhci_pci snd_hda_codec_realtek xhci_hcd snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore dm_mod(E) dax(E) ext4(E) jbd2(E) mbcache(E) sd_mod(E) ahci(E) libahci(E) i915(E) drm_kms_helper
 (E) drm(E) fb_sys_fops(E)
Sep 11 17:16:25 u1459 kernel: sysimgblt(E) sysfillrect(E) syscopyarea(E) i2c_algo_bit(E) i2c_core(E) iosf_mbi(E) video(E)
Sep 11 17:16:25 u1459 kernel: CPU: 2 PID: 4204 Comm: kworker/2:0 Tainted: G            E   4.13.0_next-queue_dev-queue_41b1c97 #39
Sep 11 17:16:25 u1459 kernel: Hardware name:                  /NUC5i5MYBE, BIOS MYBDWi5v.86A.0030.2016.0527.1657 05/27/2016
Sep 11 17:16:25 u1459 kernel: Workqueue: events linkwatch_event
Sep 11 17:16:25 u1459 kernel: task: ffff880239810080 task.stack: ffffc9000223c000
Sep 11 17:16:25 u1459 kernel: RIP: 0010:queued_spin_lock_slowpath+0x58/0x1d0
Sep 11 17:16:25 u1459 kernel: RSP: 0018:ffffc9000223f8c8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
Sep 11 17:16:25 u1459 kernel: RAX: 0000000000000101 RBX: ffff8802399f8000 RCX: 0000000000000101
Sep 11 17:16:25 u1459 kernel: RDX: ffffc9000223f948 RSI: 0000000000000001 RDI: ffff8802399fb1a0
Sep 11 17:16:25 u1459 kernel: RBP: ffffc9000223f968 R08: 0000000000000001 R09: ffff88024a1cf1a4
Sep 11 17:16:25 u1459 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff8802399f8840
Sep 11 17:16:25 u1459 kernel: R13: ffff88024a1cf0e4 R14: ffff88024a1cf0e4 R15: ffffc9000223fa48
Sep 11 17:16:25 u1459 kernel: FS:  0000000000000000(0000) GS:ffff880255d00000(0000) knlGS:0000000000000000
Sep 11 17:16:25 u1459 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep 11 17:16:25 u1459 kernel: CR2: 00000030d7e03088 CR3: 000000024a932002 CR4: 00000000003606e0
Sep 11 17:16:25 u1459 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep 11 17:16:25 u1459 kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Sep 11 17:16:25 u1459 kernel: Call Trace:
Sep 11 17:16:25 u1459 kernel: ? netlink_broadcast_filtered+0x15b/0x1a0
Sep 11 17:16:25 u1459 kernel: _raw_spin_lock+0x21/0x30
Sep 11 17:16:25 u1459 kernel: e1000e_get_stats64+0x2b/0x140 [e1000e]
Sep 11 17:16:25 u1459 kernel: dev_get_stats+0x3d/0xc0
Sep 11 17:16:25 u1459 kernel: ? __nla_reserve+0x53/0x70
Sep 11 17:16:25 u1459 kernel: rtnl_fill_stats+0x6b/0x150
Sep 11 17:16:25 u1459 kernel: rtnl_fill_ifinfo+0x542/0x920
Sep 11 17:16:25 u1459 kernel: ? if_nlmsg_size+0xae/0x180
Sep 11 17:16:25 u1459 kernel: rtmsg_ifinfo_build_skb+0x90/0xe0
Sep 11 17:16:25 u1459 kernel: rtmsg_ifinfo_event+0x35/0x60
Sep 11 17:16:25 u1459 kernel: rtmsg_ifinfo+0x13/0x20
Sep 11 17:16:25 u1459 kernel: netdev_state_change+0x46/0x50
Sep 11 17:16:25 u1459 kernel: linkwatch_do_dev+0x3c/0x60
Sep 11 17:16:25 u1459 kernel: __linkwatch_run_queue+0x13a/0x210
Sep 11 17:16:25 u1459 kernel: ? put_prev_entity+0x32/0x530
Sep 11 17:16:25 u1459 kernel: linkwatch_event+0x25/0x30
Sep 11 17:16:25 u1459 kernel: process_one_work+0x193/0x410
Sep 11 17:16:25 u1459 kernel: ? __schedule+0x2ba/0x6d0
Sep 11 17:16:25 u1459 kernel: ? activate_task+0x4e/0xc0
Sep 11 17:16:25 u1459 kernel: ? idle_balance+0x9d/0x2f0
Sep 11 17:16:25 u1459 kernel: ? schedule+0x3a/0xa0
Sep 11 17:16:25 u1459 kernel: worker_thread+0x7c/0x420
Sep 11 17:16:25 u1459 kernel: ? do_task_dead+0x41/0x50
Sep 11 17:16:25 u1459 kernel: ? default_wake_function+0x12/0x20
Sep 11 17:16:25 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep 11 17:16:25 u1459 kernel: ? schedule+0x3a/0xa0
Sep 11 17:16:25 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep 11 17:16:25 u1459 kernel: kthread+0x111/0x150
Sep 11 17:16:25 u1459 kernel: ? __kthread_init_worker+0x40/0x40
Sep 11 17:16:25 u1459 kernel: ret_from_fork+0x22/0x30
Sep 11 17:16:25 u1459 kernel: Code: 75 57 83 fe 01 89 ca 89 f0 41 0f 45 d0 f0 0f b1 17 39 f0 75 e3 83 fa 01 74 1c 8b 07 48 8d 55 e0 84 c0 89 45 e0 74 0a f3 90 8b 07 <84> c0 89 02 75 f6 66 c7 07 01 00 c9 c3 8b 37 48 8d 45 a0 81 fe
...
And repeats untill rebooted.
