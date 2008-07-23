From: David Brownell <david-b@pacbell.net>
Subject: WARNING: at net/core/dev.c:1344 __netif_schedule+0x26/0x76()
Date: Wed, 23 Jul 2008 13:25:25 -0700
Message-ID: <200807231325.25672.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:34486 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755486AbYGWUZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 16:25:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing a GIT build from last night ... after disabling I2C to avoid
the oops-on-boot, I get warning that seems to have been introduced
by network queue changes (see below).

What change to device initialization is needed remove this warning?

- Dave


ACPI: PCI Interrupt Link [APC3] enabled at IRQ 18
net2280 0000:01:06.0: PCI INT A -> Link[APC3] -> GSI 18 (level, high) -> IRQ 18
net2280 0000:01:06.0: PLX NET228x USB Peripheral Controller
net2280 0000:01:06.0: irq 18, pci mem f8a60000, chip rev 0110
net2280 0000:01:06.0: version: 2005 Sept 27; dma enabled
g_cdc gadget: using random self ethernet address
g_cdc gadget: using random host ethernet address
usb0: MAC 06:fd:8a:d8:81:1d
usb0: HOST MAC ba:0b:6c:1d:b7:e1

	... I should probably add messages about ttyGS0, the CDC ACM device
	that's a sibling of this CDC Ethernet ("ECM") device...

g_cdc gadget: CDC Composite Gadget, version: King Kamehameha Day 2008
g_cdc gadget: g_cdc ready

	Connected this to a Linux host, which enumerated it just fine:

g_cdc gadget: high speed config #1: CDC Composite (ECM + ACM)

	Then on this system (peripheral) "ifconfig usb0 192.1.1.2" and:

------------[ cut here ]------------
WARNING: at net/core/dev.c:1344 __netif_schedule+0x26/0x76()
Modules linked in: g_cdc net2280 loop forcedeth ehci_hcd ohci_hcd
Pid: 2939, comm: ifconfig Not tainted 2.6.26-dev #40
 [<c0118caf>] warn_on_slowpath+0x41/0x66
 [<c0134d17>] ? __lock_acquire+0xbdc/0xc52
 [<c0131e69>] ? trace_hardirqs_off+0xb/0xd
 [<c0131ddd>] ? trace_hardirqs_off_caller+0x14/0x95
 [<c0131e69>] ? trace_hardirqs_off+0xb/0xd
 [<c010700a>] ? native_sched_clock+0x8b/0xa1
 [<c0133e67>] ? mark_held_locks+0x40/0x5b
 [<c0134035>] ? trace_hardirqs_on+0xb/0xd
 [<c0134003>] ? trace_hardirqs_on_caller+0xf5/0x11c
 [<c0134035>] ? trace_hardirqs_on+0xb/0xd
 [<c0339a3a>] ? _spin_unlock_irqrestore+0x42/0x58

	... line 1334 being
	
	if (WARN_ON_ONCE(q == &noop_qdisc))
		return

 [<c02d9fc3>] __netif_schedule+0x26/0x76

 	eth_start() calls netif_wake_queue()
	which morphs into netif_tx_wake_queue(netdev_get_tx_queue(dev,0))
	which morhps into __netif_schedule(dev_queue->qdisc)

 [<f8a5021d>] eth_start+0x2e/0x31 [g_cdc]
 [<f8a504a0>] eth_open+0x1f/0x42 [g_cdc]
 [<c02db2f3>] dev_open+0x68/0xa0
 [<c02db1dd>] dev_change_flags+0x9a/0x148
 [<c030d3bb>] devinet_ioctl+0x209/0x4f2
 [<c030e04a>] inet_ioctl+0x8e/0xa7
 [<c02d0c9d>] sock_ioctl+0x1ab/0x1cf
 [<c02d0af2>] ? sock_ioctl+0x0/0x1cf
 [<c016d0d4>] vfs_ioctl+0x20/0x65
 [<c016d374>] do_vfs_ioctl+0x25b/0x272
 [<c01fa7a4>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c016d3b5>] sys_ioctl+0x2a/0x45
 [<c0102b81>] sysenter_past_esp+0x6a/0xa5
 =======================
---[ end trace cce311c612b5581c ]---

	I do seem to be able to at least ping across this link.
