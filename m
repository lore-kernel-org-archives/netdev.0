From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Lockdep warning and kernel panic with e1000e on
	2.6.33-rc4
Date: Fri, 22 Jan 2010 14:24:32 +0100
Message-ID: <20100122132432.GI8665@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

I just tried to unbind a device from the e1000e driver and got the following
output from lockdep and the kernel panic from a NULL pointer dereference. The
kernel running on the machine is 2.6.33-rc4 + kvm patches (which shouldn't
matter):

[  157.282671] =============================================
[  157.283400] [ INFO: possible recursive locking detected ]
[  157.283400] 2.6.33-rc4 #76
[  157.283400] ---------------------------------------------
[  157.283400] bash/3686 is trying to acquire lock:
[  157.283400]  (s_active){++++.+}, at: [<ffffffff811543f8>] sysfs_hash_and_remove+0x53/0x6a
[  157.283400] 
[  157.283400] but task is already holding lock:
[  157.283400]  (s_active){++++.+}, at: [<ffffffff811563fd>] sysfs_get_active_two+0x24/0x4b
[  157.283400] 
[  157.283400] other info that might help us debug this:
[  157.283400] 3 locks held by bash/3686:
[  157.283400]  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff81154d4d>] sysfs_write_file+0x3e/0x12b
[  157.283400]  #1:  (s_active){++++.+}, at: [<ffffffff811563fd>] sysfs_get_active_two+0x24/0x4b
[  157.283400]  #2:  (s_active){++++.+}, at: [<ffffffff8115640a>] sysfs_get_active_two+0x31/0x4b
[  157.283400] 
[  157.283400] stack backtrace:
[  157.283400] Pid: 3686, comm: bash Not tainted 2.6.33-rc4 #76
[  157.283400] Call Trace:
[  157.283400]  [<ffffffff81071576>] __lock_acquire+0xcf1/0xd86
[  157.283400]  [<ffffffff8106ff39>] ? debug_check_no_locks_freed+0x120/0x12f
[  157.283400]  [<ffffffff8106faff>] ? trace_hardirqs_on_caller+0x11f/0x14a
[  157.283400]  [<ffffffff810716cf>] lock_acquire+0xc4/0xe1
[  157.283400]  [<ffffffff811543f8>] ? sysfs_hash_and_remove+0x53/0x6a
[  157.283400]  [<ffffffff8115612a>] sysfs_addrm_finish+0xcd/0x135
[  157.283400]  [<ffffffff811543f8>] ? sysfs_hash_and_remove+0x53/0x6a
[  157.283400]  [<ffffffff8165ec51>] ? __mutex_lock_common+0x324/0x335
[  157.283400]  [<ffffffff8165ed20>] ? mutex_lock_nested+0x3c/0x41
[  157.283400]  [<ffffffff811543f8>] sysfs_hash_and_remove+0x53/0x6a
[  157.283400]  [<ffffffff811565eb>] sysfs_remove_link+0x21/0x23
[  157.283400]  [<ffffffff8135209f>] __device_release_driver+0x2d/0xce
[  157.283400]  [<ffffffff81352215>] device_release_driver+0x23/0x30
[  157.283400]  [<ffffffff81351a7e>] driver_unbind+0x5c/0x9e
[  157.283400]  [<ffffffff81350f36>] drv_attr_store+0x2c/0x2e
[  157.283400]  [<ffffffff81154e05>] sysfs_write_file+0xf6/0x12b
[  157.283400]  [<ffffffff810fe635>] vfs_write+0xb0/0x10a
[  157.283400]  [<ffffffff810fe75d>] sys_write+0x4c/0x75
[  157.283400]  [<ffffffff81002c1b>] system_call_fastpath+0x16/0x1b
[  157.506592] e1000e 0000:02:00.0: PCI INT A disabled
[  157.511796] BUG: unable to handle kernel NULL pointer dereference at 0000000000000024
[  157.512464] IP: [<ffffffff81212b7c>] do_raw_spin_unlock+0xc/0x8b
[  157.512464] PGD 835651067 PUD 835a98067 PMD 0 
[  157.512464] Oops: 0000 [#1] SMP 
[  157.512464] last sysfs file: /sys/bus/pci/drivers/e1000e/unbind
[  157.512464] CPU 19 
[  157.512464] Pid: 3686, comm: bash Not tainted 2.6.33-rc4 #76 Dinar/Dinar
[  157.512464] RIP: 0010:[<ffffffff81212b7c>]  [<ffffffff81212b7c>] do_raw_spin_unlock+0xc/0x8b
[  157.512464] RSP: 0018:ffff88043675dcf8  EFLAGS: 00010092
[  157.512464] RAX: ffff880435116540 RBX: 0000000000000020 RCX: 0000000000000000
[  157.512464] RDX: ffffffff81023c47 RSI: 0000000000000001 RDI: 0000000000000020
[  157.512464] RBP: ffff88043675dd08 R08: 0000000000000086 R09: 0000000000000000
[  157.512464] R10: ffff88043675ddc8 R11: ffff88043675dd08 R12: 0000000000000082
[  157.512464] R13: 0000000000000082 R14: 0000000000000282 R15: 0000000000000005
[  157.512464] FS:  00007f5ddd27f6f0(0000) GS:ffff88063f440000(0000) knlGS:0000000000000000
[  157.512464] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  157.512464] CR2: 0000000000000024 CR3: 0000000835601000 CR4: 00000000000006e0
[  157.512464] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  157.512464] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  157.512464] Process bash (pid: 3686, threadinfo ffff88043675c000, task ffff880435116540)
[  157.512464] Stack:
[  157.512464]  0000000000000282 0000000000000020 ffff88043675dd28 ffffffff816600ab
[  157.512464] <0> ffff880c35829600 ffff8808365dd088 ffff88043675dd58 ffffffff81023c47
[  157.512464] <0> 0000000000000005 ffff8808365dd088 0000000000000200 ffff880c359e75c0
[  157.512464] Call Trace:
[  157.512464]  [<ffffffff816600ab>] _raw_spin_unlock_irqrestore+0x2c/0x4c
[  157.512464]  [<ffffffff81023c47>] detach_device+0x90/0xc7
[  157.512464]  [<ffffffff81025687>] device_change_notifier+0x8e/0x127
[  157.512464]  [<ffffffff81662dda>] notifier_call_chain+0x38/0x60
[  157.512464]  [<ffffffff81063aba>] __blocking_notifier_call_chain+0x52/0x6f
[  157.512464]  [<ffffffff81063aeb>] blocking_notifier_call_chain+0x14/0x16
[  157.512464]  [<ffffffff8135213b>] __device_release_driver+0xc9/0xce
[  157.512464]  [<ffffffff81352215>] device_release_driver+0x23/0x30
[  157.512464]  [<ffffffff81351a7e>] driver_unbind+0x5c/0x9e
[  157.512464]  [<ffffffff81350f36>] drv_attr_store+0x2c/0x2e
[  157.512464]  [<ffffffff81154e05>] sysfs_write_file+0xf6/0x12b
[  157.512464]  [<ffffffff810fe635>] vfs_write+0xb0/0x10a
[  157.512464]  [<ffffffff810fe75d>] sys_write+0x4c/0x75
[  157.512464]  [<ffffffff81002c1b>] system_call_fastpath+0x16/0x1b
[  157.512464] Code: c0 4c 89 e6 48 c7 c7 9e 2a ac 81 31 c0 e8 c8 a7 44 00 e8 d8 a5 44 00 5f 5b 41 5c 41 5d c9 c3 55 48 89 e5 53 48 89 fb 48 83 ec 08 <81> 7f 04 ad 4e ad de 74 0c 48 c7 c6 4a 2a ac 81 e8 35 ff ff ff 
[  157.512464] RIP  [<ffffffff81212b7c>] do_raw_spin_unlock+0xc/0x8b
[  157.512464]  RSP <ffff88043675dcf8>
[  157.512464] CR2: 0000000000000024
[  157.512464] ---[ end trace a773b332cbda2d29 ]---

lspci of the affected card looks as follows:

evelt:~# lspci -n -vv -s 02:00.0
02:00.0 0200: 8086:10d3
        Subsystem: 8086:a01f
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 32
        Region 0: Memory at ce020000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at ce080000 (32-bit, non-prefetchable) [size=512K]
        Region 2: I/O ports at 3000 [size=32]
        Region 3: Memory at ce000000 (32-bit, non-prefetchable) [size=16K]
        [virtual] Expansion ROM at c8200000 [disabled] [size=256K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [a0] MSI-X: Enable+ Count=5 Masked-
                Vector table: BAR=3 offset=00000000
                PBA: BAR=3 offset=00002000
        Capabilities: [100] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140] Device Serial Number 00-1b-21-ff-ff-46-60-4a
        Kernel driver in use: e1000e

Please let me know if you need more information.

	Joerg



------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
