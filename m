From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Mon, 30 Mar 2009 08:01:50 -0600
Message-ID: <20090330080150.724378b0@bike.lwn.net>
References: <20090328075628.3565eb39@bike.lwn.net>
	<20090330085107.GA5822@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
	=?ISO-8859-2?Q?Ilpo_J?= =?ISO-8859-2?Q?=E4rvinen?=
	<ilpo.jarvinen@helsinki.fi>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754624AbZC3OCQ@vger.kernel.org>
In-Reply-To: <20090330085107.GA5822@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Mar 2009 08:51:07 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> Probably I miss something, but generally in a case like this "a_lock"
> doesn't have to be taken in IRQ mode to be dangerous. Eg. if one cpu
> is trying to take this lock after fasync_lock (with IRQs disabled),
> while another cpu is waiting for fasync_lock in IRQ, which preempted
> such "a_lock".

The possibility exists, I guess, yes.

> Could you give some details of this fix?

I just reverse the order of lock acquisition in fasync_helper().  Patch
is attached.  I'll be sending up a pull request shortly.

jon

>From 4a6a4499693a419a20559c41e33a7bd70bf20a6f Mon Sep 17 00:00:00 2001
From: Jonathan Corbet <corbet@lwn.net>
Date: Fri, 27 Mar 2009 12:24:31 -0600
Subject: [PATCH] Fix a lockdep warning in fasync_helper()

Lockdep gripes if file->f_lock is taken in a no-IRQ situation, since that
is not always the case.  We don't really want to disable IRQs for every
acquisition of f_lock; instead, just move it outside of fasync_lock.

Reported-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Jonathan Corbet <corbet@lwn.net>
---
 fs/fcntl.c         |   10 +++++++---
 include/linux/fs.h |    2 +-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index d865ca6..cc8e4de 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -531,6 +531,12 @@ int fasync_helper(int fd, struct file * filp, int on, struct fasync_struct **fap
 		if (!new)
 			return -ENOMEM;
 	}
+
+	/*
+	 * We need to take f_lock first since it's not an IRQ-safe
+	 * lock.
+	 */
+	spin_lock(&filp->f_lock);
 	write_lock_irq(&fasync_lock);
 	for (fp = fapp; (fa = *fp) != NULL; fp = &fa->fa_next) {
 		if (fa->fa_file == filp) {
@@ -555,14 +561,12 @@ int fasync_helper(int fd, struct file * filp, int on, struct fasync_struct **fap
 		result = 1;
 	}
 out:
-	/* Fix up FASYNC bit while still holding fasync_lock */
-	spin_lock(&filp->f_lock);
 	if (on)
 		filp->f_flags |= FASYNC;
 	else
 		filp->f_flags &= ~FASYNC;
-	spin_unlock(&filp->f_lock);
 	write_unlock_irq(&fasync_lock);
+	spin_unlock(&filp->f_lock);
 	return result;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7428c6d..2f13c1d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -848,7 +848,7 @@ struct file {
 #define f_dentry	f_path.dentry
 #define f_vfsmnt	f_path.mnt
 	const struct file_operations	*f_op;
-	spinlock_t		f_lock;  /* f_ep_links, f_flags */
+	spinlock_t		f_lock;  /* f_ep_links, f_flags, no IRQ */
 	atomic_long_t		f_count;
 	unsigned int 		f_flags;
 	fmode_t			f_mode;
-- 
1.6.2
