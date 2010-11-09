From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [e1000e] BUG triggered when triggering LED blinking
Date: Tue, 9 Nov 2010 09:39:54 +0100
Message-ID: <20101109083954.GB11829@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vGgW1X5XWziG23Ko"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:62246 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab0KIIkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 03:40:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

using e1000e driver version 1.2.10 and kernel version 2.6.32.24 I see
the kernel go BUG() sporadically at the time 'ethtool -p eth0 3' comes
back.

Network hardware is four times 'Intel Corporation 82583V Gigabit Network
Connection' (0x8086:0x150c) on Atom N450.

kernel BUG at kernel/workqueue.c:287!
invalid opcode: 0000 [#1] SMP
last sysfs file:
/sys/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1:1.1/input/input2/event2/dev
Modules linked in: nls_utf8 isofs edd ide_cd_mod sr_mod cdrom sg sd_mod
pata_acpi ata_generic usb_storage ppdev ide_pci_generic ata_piix libata
evdev rtc_cmos uhci_hcd parport_pc scsi_mod i2c_i801 ehci_hcd rtc_core
rtc_lib e1000e parport ftdi_sio usbhid usbserial

Pid: 8, comm: events/1 Not tainted (2.6.32.24-62.gce8dff6-ai #1) To Be
Filled By O.E.M.
EIP: 0060:[<c102ed4f>] EFLAGS: 00010206 CPU: 1
EIP is at worker_thread+0xc5/0x144
EAX: c1c052e0 EBX: c1d052e0 ECX: f70cac1c EDX: f70cac1c
ESI: f81c75b0 EDI: f70cac18 EBP: f705e3b0 ESP: f7093f90
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process events/1 (pid: 8, ti=f7092000 task=f705e3b0 task.ti=f7092000)
Stack:
 f705e5a0 c1d052ec c1d052e4 00000000 f705e3b0 c103151e f7093fa8 f7093fa8
<0> f7061f68 c1d052e0 c102ec8a 00000000 c103132b 00000000 00000000
00000000
<0> f7093fd0 f7093fd0 c10312ca 00000000 00000000 c100329f f7061f5c
00000000
Call Trace:
 [<c103151e>] ? autoremove_wake_function+0x0/0x2d
 [<c102ec8a>] ? worker_thread+0x0/0x144
 [<c103132b>] ? kthread+0x61/0x66
 [<c10312ca>] ? kthread+0x0/0x66
 [<c100329f>] ? kernel_thread_helper+0x7/0x10
Code: e9 85 00 00 00 8d 79 fc 8b 77 0c 89 7b 18 8b 11 8b 41 04 89 42 04
89 10 89 09 89 49 04 f0 fe 03 fb 8b 41 fc 83 e0 fc 39 c3 74 04 <0f> 0b
eb fe f0 80 61 fc fe 89 f8 ff d6 89 e0 25 00 e0 ff ff 8b
EIP: [<c102ed4f>] worker_thread+0xc5/0x144 SS:ESP 0068:f7093f90
---[ end trace e297b781eb382c2f ]---

The full trace is attached, it may become clearer from that.

After taking a look I think this may be caused by initializing
adapter->led_blink_task several times in e1000_phys_id(), while possibly
led_blink_task is running:

	if ((hw->phy.type == e1000_phy_ife) ||
	    (hw->mac.type == e1000_pchlan) ||
	    (hw->mac.type == e1000_82574)) {
		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
		if (!adapter->blink_timer.function) {

I can't reproduce it after moving it inside the following if block,
but I'm not quite sure if this catches all races in there.  Especially
the msleep_interruptible() may be too optimistic because it may
actually not wait long enough.  Someone with more knowledge of the
driver should take a look.

I've attached a proposed fix for the double initialization, please check.

 /holger


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=unknown-8bit
Content-Disposition: attachment; filename="putty.log"
Content-Transfer-Encoding: 8bit

=~=~=~=~=~=~=~=~=~=~=~= PuTTY log 2010.11.03 16:51:28 =~=~=~=~=~=~=~=~=~=~=~=
ÿ------------[ cut here ]------------
kernel BUG at kernel/workqueue.c:287!
invalid opcode: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1:1.1/input/input2/event2/dev
Modules linked in: nls_utf8 isofs edd ide_cd_mod sr_mod cdrom sg sd_mod pata_acpi ata_generic usb_storage ppdev ide_pci_generic ata_piix libata evdev rtc_cmos uhci_hcd parport_pc scsi_mod i2c_i801 ehci_hcd rtc_core rtc_lib e1000e parport ftdi_sio usbhid usbserial

Pid: 8, comm: events/1 Not tainted (2.6.32.24-62.gce8dff6-ai #1) To Be Filled By O.E.M.
EIP: 0060:[<c102ed4f>] EFLAGS: 00010206 CPU: 1
EIP is at worker_thread+0xc5/0x144
EAX: c1c052e0 EBX: c1d052e0 ECX: f70cac1c EDX: f70cac1c
ESI: f81c75b0 EDI: f70cac18 EBP: f705e3b0 ESP: f7093f90
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process events/1 (pid: 8, ti=f7092000 task=f705e3b0 task.ti=f7092000)
Stack:
 f705e5a0 c1d052ec c1d052e4 00000000 f705e3b0 c103151e f7093fa8 f7093fa8
<0> f7061f68 c1d052e0 c102ec8a 00000000 c103132b 00000000 00000000 00000000
<0> f7093fd0 f7093fd0 c10312ca 00000000 00000000 c100329f f7061f5c 00000000
Call Trace:
 [<c103151e>] ? autoremove_wake_function+0x0/0x2d
 [<c102ec8a>] ? worker_thread+0x0/0x144
 [<c103132b>] ? kthread+0x61/0x66
 [<c10312ca>] ? kthread+0x0/0x66
 [<c100329f>] ? kernel_thread_helper+0x7/0x10
Code: e9 85 00 00 00 8d 79 fc 8b 77 0c 89 7b 18 8b 11 8b 41 04 89 42 04 89 10 89 09 89 49 04 f0 fe 03 fb 8b 41 fc 83 e0 fc 39 c3 74 04 <0f> 0b eb fe f0 80 61 fc fe 89 f8 ff d6 89 e0 25 00 e0 ff ff 8b 
EIP: [<c102ed4f>] worker_thread+0xc5/0x144 SS:ESP 0068:f7093f90
---[ end trace e297b781eb382c2f ]---
------------[ cut here ]------------
kernel BUG at kernel/workqueue.c:191!
invalid opcode: 0000 [#2] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1:1.1/input/input2/event2/dev
Modules linked in: nls_utf8 isofs edd ide_cd_mod sr_mod cdrom sg sd_mod pata_acpi ata_generic usb_storage ppdev ide_pci_generic ata_piix libata evdev rtc_cmos uhci_hcd parport_pc scsi_mod i2c_i801 ehci_hcd rtc_core rtc_lib e1000e parport ftdi_sio usbhid usbserial

Pid: 1012, comm: klogd Tainted: G      D    (2.6.32.24-62.gce8dff6-ai #1) To Be Filled By O.E.M.
EIP: 0060:[<c102eeac>] EFLAGS: 00010283 CPU: 0
EIP is at queue_work_on+0x1b/0x44
EAX: f70cac1c EBX: 00000000 ECX: f70cac18 EDX: 00000000
ESI: f7001280 EDI: f81c7920 EBP: f71dbf60 ESP: f71dbf3c
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process klogd (pid: 1012, ti=f71da000 task=f71d87a0 task.ti=f71da000)
Stack:
 f70c8330 c133ca00 f81c7931 00000100 c1029710 c133d810 c133d610 c133d410
<0> c133d210 f71dbf60 f71dbf60 00000001 00000004 00000100 00000141 c102652e
<0> c1318010 0000000a 00000000 00000046 00000000 099251d0 bfb6e968 c10265be
Call Trace:
 [<f81c7931>] ? e1000e_set_ethtool_ops+0x1d1/0x38b0 [e1000e]
 [<c1029710>] ? run_timer_softirq+0x116/0x16a
 [<c102652e>] ? __do_softirq+0x78/0xe5
 [<c10265be>] ? do_softirq+0x23/0x27
 [<c102668d>] ? irq_exit+0x26/0x58
 [<c100f9ea>] ? smp_apic_timer_interrupt+0x6c/0x76
 [<c10030f6>] ? apic_timer_interrupt+0x2a/0x30
Code: 2c c1 8b 00 03 04 8d c0 bb 2c c1 e9 3d ff ff ff 56 89 d6 53 89 c3 f0 0f ba 29 00 19 c0 31 d2 85 c0 75 2c 8d 41 04 39 41 04 74 04 <0f> 0b eb fe 83 7e 10 00 89 ca 0f 45 1d b4 bc 2c c1 8b 06 03 04 
EIP: [<c102eeac>] queue_work_on+0x1b/0x44 SS:ESP 0068:f71dbf3c
---[ end trace e297b781eb382c30 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 1012, comm: klogd Tainted: G      D    2.6.32.24-62.gce8dff6-ai #1
Call Trace:
 [<c11e0a50>] ? panic+0x38/0xda
 [<c11e3371>] ? oops_end+0x89/0x94
 [<c1003628>] ? do_invalid_op+0x0/0x70
 [<c100368f>] ? do_invalid_op+0x67/0x70
 [<c102eeac>] ? queue_work_on+0x1b/0x44
 [<c117bfb3>] ? sys_sendto+0xfc/0x127
 [<c101c3cc>] ? dequeue_task_fair+0x3f/0x1bc
 [<c1018e0b>] ? sched_slice+0x6d/0x79
 [<c11e2ac6>] ? error_code+0x66/0x6c
 [<f81c7920>] ? e1000e_set_ethtool_ops+0x1c0/0x38b0 [e1000e]
 [<c1003628>] ? do_invalid_op+0x0/0x70
 [<c102eeac>] ? queue_work_on+0x1b/0x44
 [<f81c7931>] ? e1000e_set_ethtool_ops+0x1d1/0x38b0 [e1000e]
 [<c1029710>] ? run_timer_softirq+0x116/0x16a
 [<c102652e>] ? __do_softirq+0x78/0xe5
 [<c10265be>] ? do_softirq+0x23/0x27
 [<c102668d>] ? irq_exit+0x26/0x58
 [<c100f9ea>] ? smp_apic_timer_interrupt+0x6c/0x76
 [<c10030f6>] ? apic_timer_interrupt+0x2a/0x30

--vGgW1X5XWziG23Ko
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="e1000e-fix.diff"

Index: linux-2.6.32.y/drivers/net/e1000e/ethtool.c
===================================================================
--- linux-2.6.32.y.orig/drivers/net/e1000e/ethtool.c	2010-11-08 15:34:35.000000000 +0100
+++ linux-2.6.32.y/drivers/net/e1000e/ethtool.c	2010-11-08 17:32:27.000000000 +0100
@@ -1833,8 +1833,8 @@
 	if ((hw->phy.type == e1000_phy_ife) ||
 	    (hw->mac.type == e1000_pchlan) ||
 	    (hw->mac.type == e1000_82574)) {
-		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 		if (!adapter->blink_timer.function) {
+			INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function =
 				e1000_led_blink_callback;

--vGgW1X5XWziG23Ko--
