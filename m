From: Dave Jones <davej@redhat.com>
Subject: suspect locking in net/irda/iriap.c
Date: Wed, 20 Apr 2011 23:40:58 -0400
Message-ID: <20110421034057.GA10536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838Ab1DUDlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 23:41:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just hit this..

=============================================
[ INFO: possible recursive locking detected ]
2.6.39-rc4+ #13
---------------------------------------------
trinity/11336 is trying to acquire lock:
 (&(&hashbin->hb_spinlock)->rlock){......}, at: [<ffffffffa0653074>] irias_seq_show+0x4f/0x13b [irda]

but task is already holding lock:
 (&(&hashbin->hb_spinlock)->rlock){......}, at: [<ffffffffa0653669>] irias_seq_start+0x1e/0x59 [irda]

other info that might help us debug this:
2 locks held by trinity/11336:
 #0:  (&p->lock){+.+.+.}, at: [<ffffffff811562b6>] seq_read+0x3d/0x367
 #1:  (&(&hashbin->hb_spinlock)->rlock){......}, at: [<ffffffffa0653669>] irias_seq_start+0x1e/0x59 [irda]

stack backtrace:
Pid: 11336, comm: trinity Not tainted 2.6.39-rc4+ #13
Call Trace:
 [<ffffffff8108a7fd>] __lock_acquire+0x89b/0xc81
 [<ffffffffa0653074>] ? irias_seq_show+0x4f/0x13b [irda]
 [<ffffffff8108b0e3>] lock_acquire+0x108/0x133
 [<ffffffffa0653074>] ? irias_seq_show+0x4f/0x13b [irda]
 [<ffffffff814cc14b>] _raw_spin_lock+0x40/0x73
 [<ffffffffa0653074>] ? irias_seq_show+0x4f/0x13b [irda]
 [<ffffffffa0653074>] irias_seq_show+0x4f/0x13b [irda]
 [<ffffffff811564fe>] seq_read+0x285/0x367
 [<ffffffff81156279>] ? seq_lseek+0xe8/0xe8
 [<ffffffff8118a192>] proc_reg_read+0x90/0xaf
 [<ffffffff8113ab26>] vfs_read+0xac/0xf3
 [<ffffffff8113c043>] ? fget_light+0x3a/0xa1
 [<ffffffff8113abba>] sys_read+0x4d/0x74
 [<ffffffff814d2d02>] system_call_fastpath+0x16/0x1b


irias_seq_start does this ..
 996 {
 997         spin_lock_irq(&irias_objects->hb_spinlock);
 998 
 999         return *pos ? irias_seq_idx(*pos - 1) : SEQ_START_TOKEN;
1000 }

and then unlocks it in irias_seq_stop.

meanwhile in the seq_show iterator ...

1029                 /* Careful for priority inversions here !
1030                  * All other uses of attrib spinlock are independent of
1031                  * the object spinlock, so we are safe. Jean II */
1032                 spin_lock(&obj->attribs->hb_spinlock);

My reading of that comment suggests that the two locks aren't the same,
so is this just missing a lockdep annotation ?

	Dave

