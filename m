From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: e100 kills S2R on my box, plus network drops dead
Date: Wed, 3 Jun 2009 08:01:23 +0200
Message-ID: <20090603060123.GA17558@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net> <20081229102515.GA17171@rhlx01.hs-esslingen.de> <20081229091728.d869f1c1.akpm@linux-foundation.org> <9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com> <20081230120756.GA5393@rhlx01.hs-esslingen.de> <20090228203757.GA18850@rhlx01.hs-esslingen.de> <9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com> <20090301212412.GA13210@rhlx01.hs-esslingen.de> <20090602214852.GA3095@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, rjw@sisk.pl,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:45100 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbZFCGBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 02:01:21 -0400
Content-Disposition: inline
In-Reply-To: <20090602214852.GA3095@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

following my patch I tested -rc8 with it, everything pretty fine so far,
except for a S2R attempt:


PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.02 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.00 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
sd 0:0:0:0: [sda] Synchronizing SCSI cache
sd 0:0:0:0: [sda] Stopping disk
ACPI handle has no context!
serial 00:09: disabled
ACPI handle has no context!
r8169 0000:02:0f.0: PME# enabled
ACPI handle has no context!
ACPI handle has no context!
e100 0000:02:07.0: PCI INT A disabled
pci_legacy_suspend(): e100_suspend+0x0/0x20 [e100] returns -5
pm_op(): pci_pm_suspend+0x0/0xd7 returns -5
PM: Device 0000:02:07.0 failed to suspend: error -5
PM: Some devices failed to suspend
firewire_ohci 0000:02:0e.0: restoring config space at offset 0xf (was
0x4020100, writing 0x402010b)
firewire_ohci 0000:02:0e.0: restoring config space at offset 0x5 (was
0x0, writing 0xfddf8000)



static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
{
        bool wake;
        __e100_shutdown(pdev, &wake);
        return __e100_power_off(pdev, wake);
}


static int __e100_power_off(struct pci_dev *pdev, bool wake)
{
        if (wake) {
                return pci_prepare_to_sleep(pdev);
        } else {
                pci_wake_from_d3(pdev, false);
                return pci_set_power_state(pdev, PCI_D3hot);
        }
}


Well, the problem being that my card does not _have_ any PM support:

lspci -vvv:

02:07.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet
Pro 100 (rev 01)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 32 (2000ns min, 14000ns max)
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at fdaff000 (32-bit, prefetchable) [size=4K]
        Region 1: I/O ports at df00 [size=32]
        Region 2: Memory at fdc00000 (32-bit, non-prefetchable)
[size=1M]
        [virtual] Expansion ROM at fdb00000 [disabled] [size=1M]
        Kernel driver in use: e100



So I'm back up to the desktop rather quicker than I would have liked.


Worse, after resume I don't have my network back, and attempting to
unload e100 or ifconfig eth0 down results in this:

INFO: task nmbd:4633 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
nmbd          D 00000061     0  4633      1
 f56f7d14 00000082 0410aa36 00000061 00000100 f6716240 f61a7200 c0563740
 c0563740 f6716000 f56f7cd0 f61f3000 f61f3284 c1f1f740 00000001 04132611
 00000061 00000000 f56f7cfc c031fe90 f61a7200 40000040 f61f3284 f6716240
Call Trace:
 [<c031fe90>] ? ip_push_pending_frames+0x2b6/0x2c0
 [<c0336a8e>] ? udp_push_pending_frames+0x296/0x2e3
 [<c0365bef>] __mutex_lock_common+0x136/0x239
 [<c0365d04>] __mutex_lock_slowpath+0x12/0x15
 [<c0365dbc>] ? mutex_lock+0x21/0x2e
 [<c0365dbc>] mutex_lock+0x21/0x2e
 [<c030b7ad>] rtnetlink_rcv+0x10/0x24
 [<c0316723>] netlink_unicast+0xee/0x144
 [<c0316996>] netlink_sendmsg+0x21d/0x22a
 [<c02f800e>] sock_sendmsg+0xca/0xe1
 [<c01352bf>] ? autoremove_wake_function+0x0/0x33
 [<c01352bf>] ? autoremove_wake_function+0x0/0x33
 [<c0183e88>] ? set_fd_set+0x38/0x3d
 [<c011a47b>] ? __wake_up+0x31/0x3b
 [<c022cb52>] ? might_fault+0x17/0x19
 [<c022cb7e>] ? copy_from_user+0x2a/0x112
 [<c02f825b>] sys_sendto+0xa4/0xc3
 [<c02f893d>] ? move_addr_to_user+0x40/0x57
 [<c02f8c63>] ? sys_getsockname+0x52/0x6f
 [<c0199905>] ? inotify_d_instantiate+0x12/0x34
 [<c0185f9f>] ? __d_instantiate+0x2d/0x30
 [<c02f7d21>] ? sock_attach_fd+0x7e/0xab
 [<c02f8ecc>] sys_socketcall+0xd5/0x16d
 [<c01029f5>] syscall_call+0x7/0xb


IOW, we're deadlocking on the rtnl lock - something must have gone wrong network-wise
during suspend / emergency-resume handling.


IOW, we have _two_ issues:

- that PM suspend part here doesn't support non-PM PCI cards
- PM suspend breaks networking stuff (or is that caused by incomplete reinitialization of my card,
  thus it's not network-suitable after resume and hangs on some network APIs?)

What to do?

(I should have provided some SysRq-T(?) lock traces I guess, will record that now)

Oh, and I will test whether eepro100 S2R works on that machine, and if
so what that driver does to avoid trouble.

Thanks,

Andreas Mohr
