From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Possible circular locking in dev_queue_xmit
Date: Tue, 08 Aug 2006 20:40:24 -0500
Message-ID: <44D93D08.2010000@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:60369 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030409AbWHIBkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:40:36 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the bcm43xx-d80211 driver/stack combination, my system will usually lock 
if the interface is plugged in while booting. On one occasion, it was able to 
boot with the following message in my logs. This was run with a non-premptible 
unit-processor x86 system. If you need further details, please let me know.


=======================================================
kernel: [ INFO: possible circular locking dependency detected ]
kernel: -------------------------------------------------------
kernel: dhcpcd/4627 is trying to acquire lock:
kernel:  (&dev->queue_lock){-+..}, at: [<c02c0a86>] dev_queue_xmit+0x56/0x290
kernel:
kernel: but task is already holding lock:
kernel:  (&dev->_xmit_lock){-+..}, at: [<c02c0c56>] dev_queue_xmit+0x226/0x290
larrylap kernel:
larrylap kernel: which lock already depends on the new lock.
kernel:
kernel:
kernel: the existing dependency chain (in reverse order) is:
kernel:
kernel: -> #1 (&dev->_xmit_lock){-+..}:
kernel:        [<c01335cb>] lock_acquire+0x5b/0x80
kernel:        [<c03114b0>] _spin_lock_bh+0x40/0x50
kernel:        [<c02cc87c>] dev_activate+0x6c/0x130
kernel:        [<c02bf11b>] dev_open+0x6b/0x90
kernel:        [<e496812d>] ieee80211_open+0x18d/0x360 [80211]
kernel:        [<c02bf0f3>] dev_open+0x43/0x90
kernel:        [<c02be0a5>] dev_change_flags+0x55/0x130
kernel:        [<c02fd2df>] devinet_ioctl+0x65f/0x6d0
kernel:        [<c02fd648>] inet_ioctl+0x88/0xb0
kernel:        [<c02b32fb>] sock_ioctl+0xbb/0x260
kernel:        [<c017182b>] do_ioctl+0x2b/0x80
kernel:        [<c01718d1>] vfs_ioctl+0x51/0x290
kernel:        [<c0171b51>] sys_ioctl+0x41/0x60
kernel:        [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:
kernel: -> #0 (&dev->queue_lock){-+..}:
kernel:        [<c01335cb>] lock_acquire+0x5b/0x80
kernel:        [<c031145b>] _spin_lock+0x3b/0x50
kernel:        [<c02c0a86>] dev_queue_xmit+0x56/0x290
kernel:        [<e49671af>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:        [<c02c0932>] dev_hard_start_xmit+0x142/0x240
kernel:        [<c02c0c74>] dev_queue_xmit+0x244/0x290
kernel:        [<c030cd25>] packet_sendmsg_spkt+0x1c5/0x200
kernel:        [<c02b497a>] sock_sendmsg+0xda/0x110
kernel:        [<c02b4ce3>] sys_sendto+0xd3/0x100
kernel:        [<c02b5382>] sys_socketcall+0x192/0x260
kernel:        [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:
kernel: other info that might help us debug this:
kernel:
kernel: 1 lock held by dhcpcd/4627:
kernel:  #0:  (&dev->_xmit_lock){-+..}, at: [<c02c0c56>] dev_queue_xmit+0x226/0x290
kernel:
kernel: stack backtrace:
kernel:  [<c0103b67>] show_trace_log_lvl+0x197/0x1c0
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c01312f1>] print_circular_bug_tail+0x61/0x70
kernel:  [<c0133020>] __lock_acquire+0xae0/0xd60
kernel:  [<c01335cb>] lock_acquire+0x5b/0x80
kernel:  [<c031145b>] _spin_lock+0x3b/0x50
kernel:  [<c02c0a86>] dev_queue_xmit+0x56/0x290
kernel:  [<e49671af>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:  [<c02c0932>] dev_hard_start_xmit+0x142/0x240
kernel:  [<c02c0c74>] dev_queue_xmit+0x244/0x290
kernel:  [<c030cd25>] packet_sendmsg_spkt+0x1c5/0x200
kernel:  [<c02b497a>] sock_sendmsg+0xda/0x110
kernel:  [<c02b4ce3>] sys_sendto+0xd3/0x100
kernel:  [<c02b5382>] sys_socketcall+0x192/0x260
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:  [<b7f5a410>] 0xb7f5a410
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c01312f1>] print_circular_bug_tail+0x61/0x70
kernel:  [<c0133020>] __lock_acquire+0xae0/0xd60
kernel:  [<c01335cb>] lock_acquire+0x5b/0x80
kernel:  [<c031145b>] _spin_lock+0x3b/0x50
kernel:  [<c02c0a86>] dev_queue_xmit+0x56/0x290
kernel:  [<e49671af>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:  [<c02c0932>] dev_hard_start_xmit+0x142/0x240
kernel:  [<c02c0c74>] dev_queue_xmit+0x244/0x290
kernel:  [<c030cd25>] packet_sendmsg_spkt+0x1c5/0x200
kernel:  [<c02b497a>] sock_sendmsg+0xda/0x110
kernel:  [<c02b4ce3>] sys_sendto+0xd3/0x100
kernel:  [<c02b5382>] sys_socketcall+0x192/0x260
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d

