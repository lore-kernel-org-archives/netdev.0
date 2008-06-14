From: Marcel Holtmann <marcel@holtmann.org>
Subject: netlink circular locking dependency
Date: Sat, 14 Jun 2008 14:35:54 +0200
Message-ID: <1213446954.17870.154.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:32928 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbYFNMcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 08:32:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

so I have been working on integrating netlink support into the Bluetooth
stack. However this is running on a 2.6.26-rc2 kernel on a Quad G5 with
no netlink support for Bluetooth in the kernel, but with the userspace
part within hcid. That of course will fail to load, but that is fine and
expected if you run the new daemon on old kernels. I can upgrade that
machine to the latest vanilla kernel if needed, but just wanna quickly
check if anybody has seen this before:

NET: Registered protocol family 17
Bluetooth: L2CAP ver 2.9
Bluetooth: L2CAP socket layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM ver 1.8
hci_cmd_task: hci0 command tx timeout
hci_cmd_task: hci0 command tx timeout
hci_cmd_task: hci0 command tx timeout

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.26-rc2 #5
-------------------------------------------------------
hcid/4136 is trying to acquire lock:
 (genl_mutex){--..}, at: [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174

but task is already holding lock:
 (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (nlk->cb_mutex){--..}:
       [<c000000000077758>] .__lock_acquire+0xd14/0xf88
       [<c000000000077a9c>] .lock_acquire+0xd0/0x11c
       [<c000000000314068>] .mutex_lock_nested+0x158/0x3f4
       [<c0000000002aa9fc>] .netlink_dump_start+0x150/0x228
       [<c0000000002accc4>] .genl_rcv_msg+0xe4/0x1f8
       [<c0000000002a902c>] .netlink_rcv_skb+0x80/0x118
       [<c0000000002ad0f0>] .genl_rcv+0x4c/0x7c
       [<c0000000002a8ca4>] .netlink_unicast+0x2f8/0x3d8
       [<c0000000002a9920>] .netlink_sendmsg+0x2dc/0x320
       [<c00000000027e9b0>] .sock_sendmsg+0xf0/0x134
       [<c00000000027ec10>] .sys_sendmsg+0x21c/0x2b4
       [<c0000000002a2f68>] .compat_sys_sendmsg+0x20/0x38
       [<c0000000002a4200>] .compat_sys_socketcall+0x1ec/0x220
       [<c0000000000076b0>] syscall_exit+0x0/0x40

-> #0 (genl_mutex){--..}:
       [<c000000000077650>] .__lock_acquire+0xc0c/0xf88
       [<c000000000077a9c>] .lock_acquire+0xd0/0x11c
       [<c000000000314068>] .mutex_lock_nested+0x158/0x3f4
       [<c0000000002ace4c>] .ctrl_dumpfamily+0x74/0x174
       [<c0000000002a76a0>] .netlink_dump+0x8c/0x27c
       [<c0000000002a9b58>] .netlink_recvmsg+0x1f4/0x378
       [<c00000000027e878>] .sock_recvmsg+0x100/0x148
       [<c00000000027fedc>] .sys_recvmsg+0x180/0x31c
       [<c0000000002a2f30>] .compat_sys_recvmsg+0x20/0x38
       [<c0000000002a420c>] .compat_sys_socketcall+0x1f8/0x220
       [<c0000000000076b0>] syscall_exit+0x0/0x40

other info that might help us debug this:

1 lock held by hcid/4136:
 #0:  (nlk->cb_mutex){--..}, at: [<c0000000002a766c>] .netlink_dump+0x58/0x27c

stack backtrace:
Call Trace:
[c00000003bf37190] [c00000000000f7a0] .show_stack+0x84/0x1b8 (unreliable)
[c00000003bf37250] [c00000000000f8f4] .dump_stack+0x20/0x34
[c00000003bf372d0] [c000000000074b54] .print_circular_bug_tail+0x88/0xac
[c00000003bf373a0] [c000000000077650] .__lock_acquire+0xc0c/0xf88
[c00000003bf37490] [c000000000077a9c] .lock_acquire+0xd0/0x11c
[c00000003bf37550] [c000000000314068] .mutex_lock_nested+0x158/0x3f4
[c00000003bf37640] [c0000000002ace4c] .ctrl_dumpfamily+0x74/0x174
[c00000003bf37700] [c0000000002a76a0] .netlink_dump+0x8c/0x27c
[c00000003bf377c0] [c0000000002a9b58] .netlink_recvmsg+0x1f4/0x378
[c00000003bf378d0] [c00000000027e878] .sock_recvmsg+0x100/0x148
[c00000003bf37af0] [c00000000027fedc] .sys_recvmsg+0x180/0x31c
[c00000003bf37d00] [c0000000002a2f30] .compat_sys_recvmsg+0x20/0x38
[c00000003bf37d80] [c0000000002a420c] .compat_sys_socketcall+0x1f8/0x220
[c00000003bf37e30] [c0000000000076b0] syscall_exit+0x0/0x40
Bluetooth: BNEP (Ethernet Emulation) ver 1.2
Bluetooth: BNEP filters: protocol multicast

The system is running Ubuntu Hardy and using stock libnl for generic
netlink access.

Regards

Marcel


