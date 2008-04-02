From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 2/2] bluetooth : __rfcomm_dlc_close lock fix
Date: Wed, 2 Apr 2008 14:02:43 +0800
Message-ID: <20080402060243.GB3050@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:49778 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbYDBF5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 01:57:31 -0400
Received: by mu-out-0910.google.com with SMTP id i10so3773545mue.5
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 22:57:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lockdep warning will be trigged while rfcomm connection closing.

The locks taken in rfcomm_dev_add:
rfcomm_dev_lock --> d->lock

In __rfcomm_dlc_close:
d->lock --> rfcomm_dev_lock (in rfcomm_dev_state_change)

There's two way to fix it, one is in rfcomm_dev_add we first locking
d->lock then the rfcomm_dev_lock

The other (in this patch), remove the locking of d->lock for
rfcomm_dev_state_change because just locking "d->state = BT_CLOSED;"
is enough.

[  295.002046] =======================================================
[  295.002046] [ INFO: possible circular locking dependency detected ]
[  295.002046] 2.6.25-rc7 #1
[  295.002046] -------------------------------------------------------
[  295.002046] krfcommd/2705 is trying to acquire lock:
[  295.002046]  (rfcomm_dev_lock){-.--}, at: [<f89a090a>] rfcomm_dev_state_change+0x6a/0xd0 [rfcomm]
[  295.002046] 
[  295.002046] but task is already holding lock:
[  295.002046]  (&d->lock){--..}, at: [<f899c533>] __rfcomm_dlc_close+0x43/0xd0 [rfcomm]
[  295.002046] 
[  295.002046] which lock already depends on the new lock.
[  295.002046] 
[  295.002046] 
[  295.002046] the existing dependency chain (in reverse order) is:
[  295.002046] 
[  295.002046] -> #1 (&d->lock){--..}:
[  295.002046]        [<c0149b23>] check_prev_add+0xd3/0x200
[  295.002046]        [<c0149ce5>] check_prevs_add+0x95/0xe0
[  295.002046]        [<c0149f6f>] validate_chain+0x23f/0x320
[  295.002046]        [<c014b7b1>] __lock_acquire+0x1c1/0x760
[  295.002046]        [<c014c349>] lock_acquire+0x79/0xb0
[  295.002046]        [<c03d6b99>] _spin_lock+0x39/0x80
[  295.002046]        [<f89a01c0>] rfcomm_dev_add+0x240/0x360 [rfcomm]
[  295.002046]        [<f89a047e>] rfcomm_create_dev+0x6e/0xe0 [rfcomm]
[  295.002046]        [<f89a0823>] rfcomm_dev_ioctl+0x33/0x60 [rfcomm]
[  295.002046]        [<f899facc>] rfcomm_sock_ioctl+0x2c/0x50 [rfcomm]
[  295.002046]        [<c0363d38>] sock_ioctl+0x118/0x240
[  295.002046]        [<c0194196>] vfs_ioctl+0x76/0x90
[  295.002046]        [<c0194446>] do_vfs_ioctl+0x56/0x140
[  295.002046]        [<c0194569>] sys_ioctl+0x39/0x60
[  295.002046]        [<c0104faa>] syscall_call+0x7/0xb
[  295.002046]        [<ffffffff>] 0xffffffff
[  295.002046] 
[  295.002046] -> #0 (rfcomm_dev_lock){-.--}:
[  295.002046]        [<c0149a84>] check_prev_add+0x34/0x200
[  295.002046]        [<c0149ce5>] check_prevs_add+0x95/0xe0
[  295.002046]        [<c0149f6f>] validate_chain+0x23f/0x320
[  295.002046]        [<c014b7b1>] __lock_acquire+0x1c1/0x760
[  295.002046]        [<c014c349>] lock_acquire+0x79/0xb0
[  295.002046]        [<c03d6639>] _read_lock+0x39/0x80
[  295.002046]        [<f89a090a>] rfcomm_dev_state_change+0x6a/0xd0 [rfcomm]
[  295.002046]        [<f899c548>] __rfcomm_dlc_close+0x58/0xd0 [rfcomm]
[  295.002046]        [<f899d44f>] rfcomm_recv_ua+0x6f/0x120 [rfcomm]
[  295.002046]        [<f899e061>] rfcomm_recv_frame+0x171/0x1e0 [rfcomm]
[  295.002046]        [<f899e357>] rfcomm_run+0xe7/0x550 [rfcomm]
[  295.002046]        [<c013c18c>] kthread+0x5c/0xa0
[  295.002046]        [<c0105c07>] kernel_thread_helper+0x7/0x10
[  295.002046]        [<ffffffff>] 0xffffffff
[  295.002046] 
[  295.002046] other info that might help us debug this:
[  295.002046] 
[  295.002046] 2 locks held by krfcommd/2705:
[  295.002046]  #0:  (rfcomm_mutex){--..}, at: [<f899e2eb>] rfcomm_run+0x7b/0x550 [rfcomm]
[  295.002046]  #1:  (&d->lock){--..}, at: [<f899c533>] __rfcomm_dlc_close+0x43/0xd0 [rfcomm]
[  295.002046] 
[  295.002046] stack backtrace:
[  295.002046] Pid: 2705, comm: krfcommd Not tainted 2.6.25-rc7 #1
[  295.002046]  [<c0128a38>] ? printk+0x18/0x20
[  295.002046]  [<c014927f>] print_circular_bug_tail+0x6f/0x80
[  295.002046]  [<c0149a84>] check_prev_add+0x34/0x200
[  295.002046]  [<c0149ce5>] check_prevs_add+0x95/0xe0
[  295.002046]  [<c0149f6f>] validate_chain+0x23f/0x320
[  295.002046]  [<c014b7b1>] __lock_acquire+0x1c1/0x760
[  295.002046]  [<c014c349>] lock_acquire+0x79/0xb0
[  295.002046]  [<f89a090a>] ? rfcomm_dev_state_change+0x6a/0xd0 [rfcomm]
[  295.002046]  [<c03d6639>] _read_lock+0x39/0x80
[  295.002046]  [<f89a090a>] ? rfcomm_dev_state_change+0x6a/0xd0 [rfcomm]
[  295.002046]  [<f89a090a>] rfcomm_dev_state_change+0x6a/0xd0 [rfcomm]
[  295.002046]  [<f899c548>] __rfcomm_dlc_close+0x58/0xd0 [rfcomm]
[  295.002046]  [<f899d44f>] rfcomm_recv_ua+0x6f/0x120 [rfcomm]
[  295.002046]  [<f899e061>] rfcomm_recv_frame+0x171/0x1e0 [rfcomm]
[  295.002046]  [<c014abd9>] ? trace_hardirqs_on+0xb9/0x130
[  295.002046]  [<c03d6e89>] ? _spin_unlock_irqrestore+0x39/0x70
[  295.002046]  [<f899e357>] rfcomm_run+0xe7/0x550 [rfcomm]
[  295.002046]  [<c03d4559>] ? __sched_text_start+0x229/0x4c0
[  295.002046]  [<c0120000>] ? cpu_avg_load_per_task+0x20/0x30
[  295.002046]  [<f899e270>] ? rfcomm_run+0x0/0x550 [rfcomm]
[  295.002046]  [<c013c18c>] kthread+0x5c/0xa0
[  295.002046]  [<c013c130>] ? kthread+0x0/0xa0
[  295.002046]  [<c0105c07>] kernel_thread_helper+0x7/0x10
[  295.002046]  =======================

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>

---
net/bluetooth/rfcomm/core.c |    2 +-
net/bluetooth/rfcomm/tty.c  |    5 -----
2 files changed, 1 insertion(+), 6 deletions(-)

diff -upr linux/net/bluetooth/rfcomm/core.c linux.new/net/bluetooth/rfcomm/core.c
--- linux/net/bluetooth/rfcomm/core.c	2008-04-02 13:01:24.000000000 +0800
+++ linux.new/net/bluetooth/rfcomm/core.c	2008-04-02 13:01:39.000000000 +0800
@@ -423,8 +423,8 @@ static int __rfcomm_dlc_close(struct rfc
 
 		rfcomm_dlc_lock(d);
 		d->state = BT_CLOSED;
-		d->state_change(d, err);
 		rfcomm_dlc_unlock(d);
+		d->state_change(d, err);
 
 		skb_queue_purge(&d->tx_queue);
 		rfcomm_dlc_unlink(d);
diff -upr linux/net/bluetooth/rfcomm/tty.c linux.new/net/bluetooth/rfcomm/tty.c
--- linux/net/bluetooth/rfcomm/tty.c	2008-04-01 17:52:42.000000000 +0800
+++ linux.new/net/bluetooth/rfcomm/tty.c	2008-04-02 13:02:56.000000000 +0800
@@ -570,12 +570,7 @@ static void rfcomm_dev_state_change(stru
 					return;
 
 				rfcomm_dev_del(dev);
-				/* We have to drop DLC lock here, otherwise
-				   rfcomm_dev_put() will dead lock if it's
-				   the last reference. */
-				rfcomm_dlc_unlock(dlc);
 				rfcomm_dev_put(dev);
-				rfcomm_dlc_lock(dlc);
 			}
 		} else
 			tty_hangup(dev->tty);
