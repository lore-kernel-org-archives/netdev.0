From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: rcu_sched_state detected stall on CPU 0, 3.0-rc2
Date: Sun, 19 Jun 2011 14:20:14 -0700
Message-ID: <20110619212014.GA17499@hexapodia.org>
References: <20110612195856.GA11580@hexapodia.org> <20110612231143.GC11580@hexapodia.org> <20110612235555.GD11580@hexapodia.org> <1307932206.22348.677.camel@localhost> <20110613060453.GA21778@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110613060453.GA21778@hexapodia.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2011 at 11:04:53PM -0700, Andy Isaacson wrote:
> On Sun, Jun 12, 2011 at 10:30:05PM -0400, Ben Hutchings wrote:
> > > Of course now that I'm trying to debug, I am seeing many successful
> > > suspend-resume cycles.  I don't see any signs of difference between the
> > > cases that hung and the cases that are now succeeding.
> > > 
> > > CCing netdev, because I suspend by running pm-suspend, and in at least
> > > one failure, an ethtool running under pm-suspend seemed to be the
> > > problem:
> > > 
> > > root 11558 pts/8    S+ \_ /bin/sh /usr/lib/pm-utils/sleep.d/00powers
> > > root 11559 pts/8    S+     \_ /bin/sh /usr/sbin/pm-powersave
> > > root 11576 pts/8    S+         \_ /bin/sh /usr/lib/pm-utils/power.d/
> > > root 11577 pts/8    D+             \_ ethtool -s eth0 wol g
> > [...]
> > 
> > Wake-on-LAN configuration is entirely handled by the relevant driver;
> > the ethtool core just copies the parameters in and out.  It looks like
> > there is some sort of deadlock or missing unlock in the driver.  So my
> > question would be which driver is running eth0?
> 
> I attached the whole gzipped dmesg, but anyways, it's e1000e:
> 
> [    1.168733] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
> [    1.168879] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [    1.169346] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> [    1.169494] e1000e 0000:00:19.0: setting latency timer to 64
> [    1.169603] usbcore: registered new interface driver usbfs
> [    1.169675] e1000e 0000:00:19.0: irq 40 for MSI/MSI-X
> [    1.169794] usbcore: registered new interface driver hub
> [    1.181231] usbcore: registered new device driver usb
> [    1.181879] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> [    1.190984] thermal LNXTHERM:00: registered as thermal_zone0
> [    1.191129] ACPI: Thermal Zone [THM0] (48 C)
> [    1.205191] SCSI subsystem initialized
> [    1.207349] libata version 3.00 loaded.
> [    1.352926] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:26:2d:f3:14:0f
> [    1.353243] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
> [    1.353473] e1000e 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: A002FF-0FF
> [snip]
> [ 1221.836727] PM: Entering mem sleep
> [ 1221.836855] Suspending console(s) (use no_console_suspend to debug)
> [ 1222.018735] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> [ 1222.063181] sd 0:0:0:0: [sda] Stopping disk
> [ 1222.272665] ehci_hcd 0000:00:1d.0: PCI INT D disabled
> [ 1222.272668] ehci_hcd 0000:00:1a.0: PCI INT D disabled
> [ 1222.304428] i915 0000:00:02.0: power state changed by ACPI to D3
> [ 1222.378384] e1000e 0000:00:19.0: PCI INT A disabled
> [ 1222.378393] e1000e 0000:00:19.0: PME# enabled
> [ 1222.378400] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
> 
> ethtool does show up in the failure dmesg:
> 
> [56520.872462] INFO: task ethtool:18105 blocked for more than 120 seconds.
> [56520.872465] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [56520.872468] ethtool         D 7fffffffffffffff     0 18105  18104 0x00000000
> [56520.872473]  ffff880105d99ad8 0000000000000082 ffffffff810d0c05 ffff880137d15730
> [56520.872479]  ffff880130fd3780 ffff880105d99fd8 ffff880105d99fd8 0000000000012500
> [56520.872485]  ffff8801333794d0 ffff880130fd3780 ffff880105d99fd8 ffff880137ffbe00
> [56520.872490] Call Trace:
> [56520.872499]  [<ffffffff810d0c05>] ? zone_statistics+0x7c/0x83
> [56520.872504]  [<ffffffff8131c13e>] schedule_timeout+0x34/0xde
> [56520.872509]  [<ffffffff8131bef8>] wait_for_common+0xa3/0x11a
> [56520.872514]  [<ffffffff8103c393>] ? try_to_wake_up+0x1ac/0x1ac
> [56520.872519]  [<ffffffff8131c023>] wait_for_completion+0x1d/0x1f
> [56520.872524]  [<ffffffff8109557d>] synchronize_sched+0x5a/0x5c
> [56520.872528]  [<ffffffff8105beac>] ? find_ge_pid+0x41/0x41
> [56520.872536]  [<ffffffff8122f67a>] wakeup_source_remove+0x60/0x64
> [56520.872541]  [<ffffffff8122f785>] wakeup_source_unregister+0x13/0x1f
> [56520.872546]  [<ffffffff8122f7f1>] device_wakeup_disable+0x60/0x6b
> [56520.872550]  [<ffffffff8122f942>] device_set_wakeup_enable+0x2d/0x2f
> [56520.872573]  [<ffffffffa003a56a>] e1000_set_wol+0x9b/0x9f [e1000e]
> [56520.872580]  [<ffffffff81261c8e>] dev_ethtool+0x338/0x1c06
> [56520.872585]  [<ffffffff810d4be4>] ? __do_fault+0x313/0x34a
> [56520.872591]  [<ffffffff810329ef>] ? should_resched+0xe/0x2d
> [56520.872595]  [<ffffffff8131be41>] ? _cond_resched+0xe/0x22
> [56520.872600]  [<ffffffff8126019d>] dev_ioctl+0x503/0x688
> [56520.872605]  [<ffffffff81319009>] ? __slab_alloc+0x330/0x342
> [56520.872610]  [<ffffffff8124ac72>] ? sock_alloc_inode+0x24/0xb7
> [56520.872615]  [<ffffffff8124b0c2>] sock_do_ioctl+0x3b/0x46
> [56520.872619]  [<ffffffff8124b4f1>] sock_ioctl+0x20d/0x21b
> [56520.872625]  [<ffffffff810feb02>] ? get_empty_filp+0x93/0x11b
> [56520.872630]  [<ffffffff8110b218>] do_vfs_ioctl+0x460/0x4a1
> [56520.872635]  [<ffffffff8124ca82>] ? sock_alloc_file+0xb3/0x114
> [56520.872640]  [<ffffffff8131d13e>] ? _raw_spin_lock+0xe/0x10
> [56520.872646]  [<ffffffff810fc23d>] ? fd_install+0x31/0x5d
> [56520.872650]  [<ffffffff8110b2a0>] sys_ioctl+0x47/0x6b
> [56520.872655]  [<ffffffff8131ddc2>] system_call_fastpath+0x16/0x1b

I've been using 3.0.0-rc2 at 3c25fa74 and haven't seen this problem
reoccur, so I guess it was either transient or fixed by something in
7f45e5c..3c25fa7.  Thanks for the help, everyone.

-andy
