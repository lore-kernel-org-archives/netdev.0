From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] e1000e: changed some expensive calls
 of udelay to usleep_range
Date: Thu, 7 Sep 2017 22:19:47 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C69E5E5@ORSMSX101.amr.corp.intel.com>
References: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
 <20170904162555.GB21849@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "michael.kardonik@nxp.com" <michael.kardonik@nxp.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>, Matthew Tan <matthew.tan_1@nxp.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170904162555.GB21849@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On
> Behalf Of Pavel Machek
> Sent: Monday, September 4, 2017 9:26 AM
> To: Matthew Tan <matthew.tan_1@nxp.com>
> Cc: michael.kardonik@nxp.com; Williams, Mitch A
> <mitch.a.williams@intel.com>; linux-kernel@vger.kernel.org;
> john.ronciak@intel.com; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org
> Subject: Re: [Intel-wired-lan] [PATCH] e1000e: changed some expensive calls
> of udelay to usleep_range
> 
> Hi!
> 
> > @@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw
> *hw, u32 offset, u16 *data)
> >  	 * reading duplicate data in the next MDIC transaction.
> >  	 */
> >  	if (hw->mac.type == e1000_pch2lan)
> > -		udelay(100);
> > +		usleep_range(90, 100);
> >
> >  	return 0;
> >  }
> 
> Can you explain why shortening the delay is acceptable here?

Maybe it's not.

This patch is causing speed / duplex tests to fail on several of my test systems.  Specifically a Lenova laptop with an 82577 and a NUC with an i218 (though that does not mean it is limited to those or that it's not related to the individual link partner.)

In both cases they "blow up" when attempting to link at 10 Mb with a Call Trace on the console / log and a watchdog: BUG: soft lockup - CPU#X stuck appearing in the current login session.  The simplest way to produce the crash is simply load the interface and attempt to bring it up with the link partner configured to 10 Mb half (force or autoneg) or forced to 10 Mb full (autoneg to 10 Mb full did not blow up.)  The problem is also appearing at some, but not all 100 Mb speeds and duplexes.  100 Mb also crashes, apparently with the same pattern.  With the link partner set to 100 Mb half Autoneg on, 100 Mb half forced and 100 Mb full forced the system crashes, 100 Full autoneg seems to work fine.

The call trace repeats every 30 seconds, is captured in the log and looks a lot like this:
----------------------------------------
Sep  7 14:17:10 u1459 kernel: watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:23]
Sep  7 14:17:10 u1459 kernel: Modules linked in: e1000e ptp pps_core ip6table_filter ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc nfsd lockd grace nfs_acl auth_rpcgss sunrpc autofs4 ipv6 crc_ccitt dm_mirror dm_region_hash dm_log vhost_net vhost tap tun kvm_intel kvm irqbypass uinput joydev ax88179_178a usbnet mii iTCO_wdt iTCO_vendor_support sg i2c_i801 lpc_ich mfd_core xhci_pci snd_hda_codec_realtek xhci_hcd snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore dm_mod(E) dax(E) ext4(E) jbd2(E) mbcache(E) sd_mod(E) ahci(E) libahci(E) i915(E) drm_kms_helper
 (E) drm(E) fb_sys_fops(E)
Sep  7 14:17:10 u1459 kernel: sysimgblt(E) sysfillrect(E) syscopyarea(E) i2c_algo_bit(E) i2c_core(E) iosf_mbi(E) video(E)
Sep  7 14:17:10 u1459 kernel: CPU: 2 PID: 23 Comm: kworker/2:0 Tainted: G            EL  4.13.0-rc6_next-queue_dev-queue_regress #38
Sep  7 14:17:10 u1459 kernel: Hardware name:                  /NUC5i5MYBE, BIOS MYBDWi5v.86A.0030.2016.0527.1657 05/27/2016
Sep  7 14:17:10 u1459 kernel: Workqueue: events linkwatch_event
Sep  7 14:17:10 u1459 kernel: task: ffff88024cf84680 task.stack: ffffc90000d44000
Sep  7 14:17:10 u1459 kernel: RIP: 0010:queued_spin_lock_slowpath+0x56/0x1d0
Sep  7 14:17:10 u1459 kernel: RSP: 0018:ffffc90000d478c8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
Sep  7 14:17:10 u1459 kernel: RAX: 0000000000000101 RBX: ffff880239fe8000 RCX: 0000000000000101
Sep  7 14:17:10 u1459 kernel: RDX: ffffc90000d47948 RSI: 0000000000000001 RDI: ffff880239feb1a0
Sep  7 14:17:10 u1459 kernel: RBP: ffffc90000d47968 R08: 0000000000000001 R09: ffff88024ce181a4
Sep  7 14:17:10 u1459 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff880239fe8840
Sep  7 14:17:10 u1459 kernel: R13: ffff88024ce180e4 R14: ffff88024ce180e4 R15: ffffc90000d47a48
Sep  7 14:17:10 u1459 kernel: FS:  0000000000000000(0000) GS:ffff880255d00000(0000) knlGS:0000000000000000
Sep  7 14:17:10 u1459 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep  7 14:17:10 u1459 kernel: CR2: 00007ffd4c3579b8 CR3: 0000000001c09000 CR4: 00000000003406e0
Sep  7 14:17:10 u1459 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  7 14:17:10 u1459 kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Sep  7 14:17:10 u1459 kernel: Call Trace:
Sep  7 14:17:10 u1459 kernel: ? netlink_broadcast_filtered+0x15f/0x1a0
Sep  7 14:17:10 u1459 kernel: _raw_spin_lock+0x21/0x30
Sep  7 14:17:10 u1459 kernel: e1000e_get_stats64+0x2b/0x140 [e1000e]
Sep  7 14:17:10 u1459 kernel: dev_get_stats+0x3d/0xc0
Sep  7 14:17:10 u1459 kernel: ? __nla_reserve+0x53/0x70
Sep  7 14:17:10 u1459 kernel: rtnl_fill_stats+0x6b/0x150
Sep  7 14:17:10 u1459 kernel: rtnl_fill_ifinfo+0x542/0x920
Sep  7 14:17:10 u1459 kernel: ? if_nlmsg_size+0xae/0x180
Sep  7 14:17:10 u1459 kernel: rtmsg_ifinfo_build_skb+0x90/0xe0
Sep  7 14:17:10 u1459 kernel: rtmsg_ifinfo_event+0x35/0x60
Sep  7 14:17:10 u1459 kernel: rtmsg_ifinfo+0x13/0x20
Sep  7 14:17:10 u1459 kernel: netdev_state_change+0x46/0x50
Sep  7 14:17:10 u1459 kernel: linkwatch_do_dev+0x3c/0x60
Sep  7 14:17:10 u1459 kernel: __linkwatch_run_queue+0x13a/0x210
Sep  7 14:17:10 u1459 kernel: ? set_task_cpu+0xbb/0x1a0
Sep  7 14:17:10 u1459 kernel: ? lock_timer_base+0x8a/0xb0
Sep  7 14:17:10 u1459 kernel: linkwatch_event+0x25/0x30
Sep  7 14:17:10 u1459 kernel: process_one_work+0x193/0x410
Sep  7 14:17:10 u1459 kernel: ? try_to_del_timer_sync+0x53/0x70
Sep  7 14:17:10 u1459 kernel: ? del_timer_sync+0x3d/0x50
Sep  7 14:17:10 u1459 kernel: ? maybe_create_worker+0x8b/0x110
Sep  7 14:17:10 u1459 kernel: ? schedule+0x3a/0xa0
Sep  7 14:17:10 u1459 kernel: worker_thread+0x7c/0x420
Sep  7 14:17:10 u1459 kernel: ? default_wake_function+0x12/0x20
Sep  7 14:17:10 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep  7 14:17:10 u1459 kernel: ? schedule+0x3a/0xa0
Sep  7 14:17:10 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep  7 14:17:10 u1459 kernel: kthread+0x111/0x150
Sep  7 14:17:10 u1459 kernel: ? __kthread_init_worker+0x40/0x40
Sep  7 14:17:10 u1459 kernel: ret_from_fork+0x22/0x30
Sep  7 14:17:10 u1459 kernel: Code: ff ff 75 57 83 fe 01 89 ca 89 f0 41 0f 45 d0 f0 0f b1 17 39 f0 75 e3 83 fa 01 74 1c 8b 07 48 8d 55 e0 84 c0 89 45 e0 74 0a f3 90 <8b> 07 84 c0 89 02 75 f6 66 c7 07 01 00 c9 c3 8b 37 48 8d 45 a0
Sep  7 14:17:38 u1459 kernel: watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:23]
Sep  7 14:17:38 u1459 kernel: Modules linked in: e1000e ptp pps_core ip6table_filter ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc nfsd lockd grace nfs_acl auth_rpcgss sunrpc autofs4 ipv6 crc_ccitt dm_mirror dm_region_hash dm_log vhost_net vhost tap tun kvm_intel kvm irqbypass uinput joydev ax88179_178a usbnet mii iTCO_wdt iTCO_vendor_support sg i2c_i801 lpc_ich mfd_core xhci_pci snd_hda_codec_realtek xhci_hcd snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore dm_mod(E) dax(E) ext4(E) jbd2(E) mbcache(E) sd_mod(E) ahci(E) libahci(E) i915(E) drm_kms_helper
 (E) drm(E) fb_sys_fops(E)
Sep  7 14:17:38 u1459 kernel: sysimgblt(E) sysfillrect(E) syscopyarea(E) i2c_algo_bit(E) i2c_core(E) iosf_mbi(E) video(E)
Sep  7 14:17:38 u1459 kernel: CPU: 2 PID: 23 Comm: kworker/2:0 Tainted: G            EL  4.13.0-rc6_next-queue_dev-queue_regress #38
Sep  7 14:17:38 u1459 kernel: Hardware name:                  /NUC5i5MYBE, BIOS MYBDWi5v.86A.0030.2016.0527.1657 05/27/2016
Sep  7 14:17:38 u1459 kernel: Workqueue: events linkwatch_event
Sep  7 14:17:38 u1459 kernel: task: ffff88024cf84680 task.stack: ffffc90000d44000
Sep  7 14:17:38 u1459 kernel: RIP: 0010:queued_spin_lock_slowpath+0x56/0x1d0
Sep  7 14:17:38 u1459 kernel: RSP: 0018:ffffc90000d478c8 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
Sep  7 14:17:38 u1459 kernel: RAX: 0000000000000101 RBX: ffff880239fe8000 RCX: 0000000000000101
Sep  7 14:17:38 u1459 kernel: RDX: ffffc90000d47948 RSI: 0000000000000001 RDI: ffff880239feb1a0
Sep  7 14:17:38 u1459 kernel: RBP: ffffc90000d47968 R08: 0000000000000001 R09: ffff88024ce181a4
Sep  7 14:17:38 u1459 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff880239fe8840
Sep  7 14:17:38 u1459 kernel: R13: ffff88024ce180e4 R14: ffff88024ce180e4 R15: ffffc90000d47a48
Sep  7 14:17:38 u1459 kernel: FS:  0000000000000000(0000) GS:ffff880255d00000(0000) knlGS:0000000000000000
Sep  7 14:17:38 u1459 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Sep  7 14:17:38 u1459 kernel: CR2: 00007ffd4c3579b8 CR3: 0000000001c09000 CR4: 00000000003406e0
Sep  7 14:17:38 u1459 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Sep  7 14:17:38 u1459 kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Sep  7 14:17:38 u1459 kernel: Call Trace:
Sep  7 14:17:38 u1459 kernel: ? netlink_broadcast_filtered+0x15f/0x1a0
Sep  7 14:17:38 u1459 kernel: _raw_spin_lock+0x21/0x30
Sep  7 14:17:38 u1459 kernel: e1000e_get_stats64+0x2b/0x140 [e1000e]
Sep  7 14:17:38 u1459 kernel: dev_get_stats+0x3d/0xc0
Sep  7 14:17:38 u1459 kernel: ? __nla_reserve+0x53/0x70
Sep  7 14:17:38 u1459 kernel: rtnl_fill_stats+0x6b/0x150
Sep  7 14:17:38 u1459 kernel: rtnl_fill_ifinfo+0x542/0x920
Sep  7 14:17:38 u1459 kernel: ? if_nlmsg_size+0xae/0x180
Sep  7 14:17:38 u1459 kernel: rtmsg_ifinfo_build_skb+0x90/0xe0
Sep  7 14:17:38 u1459 kernel: rtmsg_ifinfo_event+0x35/0x60
Sep  7 14:17:38 u1459 kernel: rtmsg_ifinfo+0x13/0x20
Sep  7 14:17:38 u1459 kernel: netdev_state_change+0x46/0x50
Sep  7 14:17:38 u1459 kernel: linkwatch_do_dev+0x3c/0x60
Sep  7 14:17:38 u1459 kernel: __linkwatch_run_queue+0x13a/0x210
Sep  7 14:17:38 u1459 kernel: ? set_task_cpu+0xbb/0x1a0
Sep  7 14:17:38 u1459 kernel: ? lock_timer_base+0x8a/0xb0
Sep  7 14:17:38 u1459 kernel: linkwatch_event+0x25/0x30
Sep  7 14:17:38 u1459 kernel: process_one_work+0x193/0x410
Sep  7 14:17:38 u1459 kernel: ? try_to_del_timer_sync+0x53/0x70
Sep  7 14:17:38 u1459 kernel: ? del_timer_sync+0x3d/0x50
Sep  7 14:17:38 u1459 kernel: ? maybe_create_worker+0x8b/0x110
Sep  7 14:17:38 u1459 kernel: ? schedule+0x3a/0xa0
Sep  7 14:17:38 u1459 kernel: worker_thread+0x7c/0x420
Sep  7 14:17:38 u1459 kernel: ? default_wake_function+0x12/0x20
Sep  7 14:17:38 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep  7 14:17:38 u1459 kernel: ? schedule+0x3a/0xa0
Sep  7 14:17:38 u1459 kernel: ? maybe_create_worker+0x110/0x110
Sep  7 14:17:38 u1459 kernel: kthread+0x111/0x150
Sep  7 14:17:38 u1459 kernel: ? __kthread_init_worker+0x40/0x40
Sep  7 14:17:38 u1459 kernel: ret_from_fork+0x22/0x30
Sep  7 14:17:38 u1459 kernel: Code: ff ff 75 57 83 fe 01 89 ca 89 f0 41 0f 45 d0 f0 0f b1 17 39 f0 75 e3 83 fa 01 74 1c 8b 07 48 8d 55 e0 84 c0 89 45 e0 74 0a f3 90 <8b> 07 84 c0 89 02 75 f6 66 c7 07 01 00 c9 c3 8b 37 48 8d 45 a0
----------------------------------------

Here is the contents of an ssh session to the box (using a usb ethernet port for a control network as the LOM goes dead.) :
----------------------
u1459:[0]/root> modprobe e1000e
u1459:[0]/root> nwk
Bringing up eth0... -> success
Bringing up eth1... -> success
Bringing up eth1 IPv6... -> success
u1459:[0]/root> lnks

Message from syslogd@u1459 at Sep  7 14:04:42 ...
 kernel:watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [ifconfig:3980]

Message from syslogd@u1459 at Sep  7 14:04:42 ...
 kernel:watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [ifconfig:3983]
Write failed: Broken pipe
[root@s252 ~]# ssh u1459
Warning: Permanently added 'u1459,190.0.14.59' (RSA) to the list of known hosts.
Last login: Thu Sep  7 14:12:06 2017

You are running LINUX 4.13.0-rc6_next-queue_dev-queue_regress.

This system was (post)installed: Fri Jan 27 16:38:47 PST 2017

It has been more than 7 days since you ran 'sgetall' on this system!
Your root drive is 11% used.

You have 4 CPUs on-line.
The current ethtool is 4.11
Your ethool is 4.8
To get the current version, run 'ethtool.inst'
u1459:[0]/root> dmesg -c > /dev/null
u1459:[0]/root> modprobe e1000e
u1459:[0]/root> dmesg -c
pps_core: LinuxPPS API ver. 1 registered
pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
PTP clock support registered
e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
e1000e 0000:00:19.0 0000:00:19.0 (uninitialized): registered PHC clock
e1000e 0000:00:19.0 eth1: (PCI Express:2.5GT/s:Width x1) f4:4d:30:62:c7:14
e1000e 0000:00:19.0 eth1: Intel(R) PRO/1000 Network Connection
e1000e 0000:00:19.0 eth1: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
u1459:[0]/root> ifconfig eth1 190.1.14.59
u1459:[0]/root>
Message from syslogd@u1459 at Sep  7 14:15:06 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [kworker/2:0:23]

Message from syslogd@u1459 at Sep  7 14:15:34 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [kworker/2:0:23]

Message from syslogd@u1459 at Sep  7 14:16:06 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [kworker/2:0:23]

Message from syslogd@u1459 at Sep  7 14:16:34 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [kworker/2:0:23]

Message from syslogd@u1459 at Sep  7 14:17:10 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:23]

Message from syslogd@u1459 at Sep  7 14:17:38 ...
 kernel:watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [kworker/2:0:23]
