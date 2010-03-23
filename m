From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: net-next: 2.6.34-rc1 regression: panic when running diagnostic on
 interface with IPv6
Date: Tue, 23 Mar 2010 12:28:08 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4ADAB2A@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24541 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657Ab0CWS2K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 14:28:10 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bisecting points to this patch:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6

And I confirmed that the issue goes away after reverting it.

Steps to reproduce:
1. Load the driver and configure IPv6 address.
2. Run ethtool diag:
ethtool -t eth0

3. If this doesn't brake it try again, or just do ifdown/up. Other operations on the interface will eventually panic the system:

[  436.118773] ------------[ cut here ]------------
[  436.124009] WARNING: at net/ipv6/ip6_fib.c:1159 fib6_del+0x44/0x39f()
[  436.131280] Hardware name: S5520HC
[  436.135147] Modules linked in: bnx2 e1000e ixgbe mdio e1000
[  436.141894] Pid: 7290, comm: ethtool Not tainted 2.6.33-net-next-master-bisect #45
[  436.150427] Call Trace:
[  436.153230]  [<ffffffff81033c41>] ? __wake_up+0x43/0x50
[  436.159139]  [<ffffffff8142728d>] ? fib6_del+0x44/0x39f
[  436.165043]  [<ffffffff81038e97>] warn_slowpath_common+0x77/0x8f
[  436.171826]  [<ffffffff81038ebe>] warn_slowpath_null+0xf/0x11
[  436.178321]  [<ffffffff8142728d>] fib6_del+0x44/0x39f
[  436.184037]  [<ffffffff81424864>] __ip6_del_rt+0x49/0x68
[  436.190043]  [<ffffffff814249d3>] ip6_del_rt+0x38/0x3a
[  436.195855]  [<ffffffff8141fe8f>] __ipv6_ifa_notify+0x141/0x17c
[  436.202541]  [<ffffffff814209bf>] addrconf_ifdown+0x1e2/0x292
[  436.209034]  [<ffffffff8142199a>] addrconf_notify+0x6e7/0x7a0
[  436.215531]  [<ffffffff814addec>] ? _raw_spin_lock_irqsave+0x11/0x19
[  436.222730]  [<ffffffff81045ac6>] ? spin_unlock_irqrestore+0x9/0xb
[  436.229727]  [<ffffffff81046266>] ? del_timer+0x72/0x80
[  436.235644]  [<ffffffff81426914>] ? fib6_age+0x0/0x6e
[  436.241723]  [<ffffffff8103e73d>] ? local_bh_enable_ip+0x9/0xb
[  436.248639]  [<ffffffff814add75>] ? _raw_spin_unlock_bh+0x12/0x14
[  436.255880]  [<ffffffff814271da>] ? fib6_run_gc+0xca/0xcf
[  436.262297]  [<ffffffff814b05c0>] notifier_call_chain+0x33/0x5b
[  436.283900]  [<ffffffff810556c5>] __raw_notifier_call_chain+0x9/0xb
[  436.291282]  [<ffffffff810556d6>] raw_notifier_call_chain+0xf/0x11
[  436.298624]  [<ffffffff813953f9>] call_netdevice_notifiers+0x16/0x18
[  436.306172]  [<ffffffff81395912>] dev_close+0x39/0x3f
[  436.312204]  [<ffffffffa00580dd>] e1000_diag_test+0xc0/0x952 [e1000e]
[  436.319788]  [<ffffffff810d4727>] ? __kmalloc+0x103/0x115
[  436.326200]  [<ffffffff81398703>] ? ethtool_self_test+0x97/0x111
[  436.333300]  [<ffffffff8139871f>] ethtool_self_test+0xb3/0x111
[  436.340254]  [<ffffffff81399928>] dev_ethtool+0x891/0xd3d
[  436.346721]  [<ffffffff813974b2>] dev_ioctl+0x4c2/0x61d
[  436.352944]  [<ffffffff810a42b0>] ? lock_page+0x11/0x29
[  436.359167]  [<ffffffff810a5865>] ? filemap_fault+0x1b4/0x308
[  436.365973]  [<ffffffff810a4391>] ? unlock_page+0xf/0x11
[  436.372292]  [<ffffffff813843e0>] sock_do_ioctl+0x3b/0x46
[  436.378745]  [<ffffffff813845f8>] sock_ioctl+0x20d/0x220
[  436.385071]  [<ffffffff810e6d0b>] vfs_ioctl+0x2a/0x9d
[  436.391085]  [<ffffffff810e7282>] do_vfs_ioctl+0x48c/0x4dd
[  436.397599]  [<ffffffff814b057e>] ? do_page_fault+0x23e/0x24d
[  436.404466]  [<ffffffff810e732a>] sys_ioctl+0x57/0x7a
[  436.410540]  [<ffffffff81002a2b>] system_call_fastpath+0x16/0x1b
[  436.417694] ---[ end trace c17f3867d68797ab ]---

[  583.838894] general protection fault: 0000 [#1] SMP 
[  583.844981] last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:0b:00.0/local_cpus
[  583.854839] CPU 10 
[  583.857051] Modules linked in: bnx2 ixgbe mdio e1000 [last unloaded: e1000e]
[  583.866400] 
[  583.868450] Pid: 7644, comm: ifconfig Tainted: G        W  2.6.33-net-next-master-bisect #45 S5520HC/S5520HC
[  583.880203] RIP: 0010:[<ffffffff81423ac0>]  [<ffffffff81423ac0>] fib6_ifdown+0xb/0x26
[  583.889810] RSP: 0018:ffff8801eb0afbe8  EFLAGS: 00010202
[  583.896143] RAX: ffff8801ebbac000 RBX: 6b6b6b6b6b6b6b6b RCX: ffffffff81c13c60
[  583.904517] RDX: ffffffff81c13c60 RSI: ffff8801eb0afd28 RDI: 6b6b6b6b6b6b6b6b
[  583.912894] RBP: ffff8801eb0afbe8 R08: 0000000000000000 R09: ffff8801ae27d100
[  583.921324] R10: ffff8801ae27cfc0 R11: ffff8801edaab2c0 R12: ffff8801eb0afc78
[  583.921327] R13: ffffffff81c13c60 R14: ffff8801eb0afd28 R15: 0000000000000000
[  583.921331] FS:  00007fa9c7486710(0000) GS:ffff880028340000(0000) knlGS:0000000000000000
[  583.921334] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  583.921336] CR2: 000000377bcbd268 CR3: 00000001eb9e2000 CR4: 00000000000006e0
[  583.921339] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  583.921342] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  583.921345] Process ifconfig (pid: 7644, threadinfo ffff8801eb0ae000, task ffff8801ed774bf0)
[  583.921347] Stack:
[  583.921348]  ffff8801eb0afc28 ffffffff81427621 0000000000000000 ffffffff81c13c60
[  583.921352] <0> 0000000000000000 ffff8801eb88b1f0 ffff8801eb0afc78 ffff8801ef045c78
[  583.921355] <0> ffff8801eb0afc48 ffffffff81426cef ffff8801eb0afc48 ffff8801eb0afc78
[  583.921359] Call Trace:
[  583.921365]  [<ffffffff81427621>] fib6_clean_node+0x39/0xa2
[  583.921370]  [<ffffffff81426cef>] fib6_walk_continue+0xa1/0x101
[  583.921374]  [<ffffffff81426da2>] fib6_walk+0x53/0x6a
[  583.921378]  [<ffffffff81426df3>] fib6_clean_tree+0x3a/0x3c
[  583.921382]  [<ffffffff814275e8>] ? fib6_clean_node+0x0/0xa2
[  583.921386]  [<ffffffff81423ab5>] ? fib6_ifdown+0x0/0x26
[  583.921390]  [<ffffffff81426e67>] fib6_clean_all+0x58/0x76

Emil
