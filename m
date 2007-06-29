From: Patrick McHardy <kaber@trash.net>
Subject: Bluetooth lockdep warning
Date: Fri, 29 Jun 2007 14:37:53 +0200
Message-ID: <4684FD21.6030609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43793 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429AbXF2MiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:38:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting this on current -git after adding an obexfs mount
to my fstab:

=============================================
[ INFO: possible recursive locking detected ]
2.6.22-rc6 #2
---------------------------------------------
obexfs/3786 is trying to acquire lock:
 (sk_lock-AF_BLUETOOTH){--..}, at: [<ffffffff88216593>]
l2cap_sock_bind+0x37/0xf3 [l2cap]

but task is already holding lock:
 (sk_lock-AF_BLUETOOTH){--..}, at: [<ffffffff8821f4cc>]
rfcomm_sock_connect+0x47/0xe0 [rfcomm]

other info that might help us debug this:
2 locks held by obexfs/3786:
 #0:  (sk_lock-AF_BLUETOOTH){--..}, at: [<ffffffff8821f4cc>]
rfcomm_sock_connect+0x47/0xe0 [rfc
omm]
 #1:  (rfcomm_mutex){--..}, at: [<ffffffff8123888e>] mutex_lock+0x25/0x2a

stack backtrace:

Call Trace:
 [<ffffffff81044c91>] __lock_acquire+0x162/0xbbe
 [<ffffffff88216593>] :l2cap:l2cap_sock_bind+0x37/0xf3
 [<ffffffff81045769>] lock_acquire+0x7c/0xa0
 [<ffffffff88216593>] :l2cap:l2cap_sock_bind+0x37/0xf3
 [<ffffffff811a0fe8>] lock_sock_nested+0xd6/0xea
 [<ffffffff8104c18c>] module_put+0x4c/0x68
 [<ffffffff88216593>] :l2cap:l2cap_sock_bind+0x37/0xf3
 [<ffffffff8119e2f5>] kernel_bind+0xb/0xd
 [<ffffffff8821cb6f>] :rfcomm:rfcomm_dlc_open+0xc7/0x260
 [<ffffffff81030000>] iomem_open+0x17/0x39
 [<ffffffff8821f525>] :rfcomm:rfcomm_sock_connect+0xa0/0xe0
 [<ffffffff8119edbc>] sys_connect+0x68/0x8e
 [<ffffffff81076fd3>] fd_install+0x5e/0x67
 [<ffffffff81239aa8>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff81044684>] trace_hardirqs_on+0x11c/0x147
 [<ffffffff81239aa8>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff81009cee>] system_call+0x7e/0x83


The warning appears to be bogus (things work fine), the reason
seems to be that the rfcomm socket and the rfcomm l2 socket share
the same lockdep class. Can someone more familiar with that
code please have a look?


