From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: suspend warning with 3c59x
Date: Tue, 14 Sep 2010 19:32:40 +0400
Message-ID: <4C8F9598.60309@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andrew@beldisplaytech.com, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35133 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327Ab0INPcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 11:32:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have got a warning with the 3c59.
(reproduced with pm-suspend)

[  254.214993] 3c59x 0000:00:0d.0: PME# enabled
[  254.215021] BUG: sleeping function called from invalid context at kernel/mutex.c:94
[  254.215030] in_atomic(): 0, irqs_disabled(): 1, pid: 4875, name: ethtool
[  254.215042] Pid: 4875, comm: ethtool Tainted: G        W   2.6.36-rc3+ #7
[  254.215049] Call Trace:
[  254.215050]  [] __might_sleep+0xb1/0xb6
[  254.215050]  [] mutex_lock+0x17/0x30
[  254.215050]  [] acpi_enable_wakeup_device_power+0x2b/0xb1
[  254.215050]  [] acpi_pm_device_sleep_wake+0x42/0x7f
[  254.215050]  [] acpi_pci_sleep_wake+0x5d/0x63
[  254.215050]  [] platform_pci_sleep_wake+0x1d/0x20
[  254.215050]  [] __pci_enable_wake+0x90/0xd0
[  254.215050]  [] acpi_set_WOL+0x8e/0xf5 [3c59x]
[  254.215050]  [] vortex_set_wol+0x4e/0x5e [3c59x]
[  254.215050]  [] dev_ethtool+0x1cf/0xb61
[  254.215050]  [] ? debug_mutex_free_waiter+0x45/0x4a
[  254.215050]  [] ? __mutex_lock_common+0x204/0x20e
[  254.215050]  [] ? __mutex_lock_slowpath+0x12/0x15
[  254.215050]  [] ? mutex_lock+0x23/0x30
[  254.215050]  [] dev_ioctl+0x42c/0x533
[  254.215050]  [] ? _cond_resched+0x8/0x1c
[  254.215050]  [] ? lock_page+0x1c/0x30
[  254.215050]  [] ? page_address+0x15/0x7c
[  254.215050]  [] ? filemap_fault+0x187/0x2c4
[  254.215050]  [] sock_ioctl+0x1d4/0x1e0
[  254.215050]  [] ? sock_ioctl+0x0/0x1e0
[  254.215050]  [] vfs_ioctl+0x19/0x33
[  254.215050]  [] do_vfs_ioctl+0x424/0x46f
[  254.215050]  [] ? selinux_file_ioctl+0x3c/0x40
[  254.215050]  [] sys_ioctl+0x40/0x5a
[  254.215050]  [] sysenter_do_call+0x12/0x22

Warning introduced with commit 690a1f2002a3091bd18a501f46c9530f10481463:
3c59x: Add ethtool WOL support

vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL acquires a mutex inside atomic context.
Do we really need to protect .set_wol with a vp->lock at all?
