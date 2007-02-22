From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: [take37 0/10] kevent: Generic event handling mechanism (socket, pipes, files, signals, AIO, timers, posix timers...).
Date: Thu, 22 Feb 2007 15:17:40 +0000
Message-ID: <20070222151740.GD4113@slug>
References: <asasdasdzxczc036@2ka.mipt.ru> <11721524921823@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>, Ch@pimp.vs19.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:36269 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbXBVPTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 10:19:01 -0500
Received: by ug-out-1314.google.com with SMTP id 44so138213uga
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 07:19:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <11721524921823@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 22, 2007 at 04:54:52PM +0300, Evgeniy Polyakov wrote:
 
> Changes from 'take36' patchset:
>  * ported to 2.6.21-rc1
Hi Evgeniy,

The changes below were needed to be able to compile take37 on 2.6.21-rc1
with:
CONFIG_KEVENT=y
CONFIG_KEVENT_USER_STAT=y
CONFIG_KEVENT_TIMER=y
CONFIG_KEVENT_POLL=y
CONFIG_KEVENT_SOCKET=y
CONFIG_KEVENT_PIPE=y
CONFIG_KEVENT_SIGNAL=y
CONFIG_KEVENT_UNOTIFY=y
CONFIG_KEVENT_AIO=y

Regards,
Frederik

diff --git a/kernel/kevent/kevent_timer.c b/kernel/kevent/kevent_timer.c
index c21a155..19f0a88 100644
--- a/kernel/kevent/kevent_timer.c
+++ b/kernel/kevent/kevent_timer.c
@@ -33,7 +33,7 @@ struct kevent_timer
 	struct kevent		*ktimer_event;
 };
 
-static int kevent_timer_func(struct hrtimer *timer)
+static enum hrtimer_restart kevent_timer_func(struct hrtimer *timer)
 {
 	struct kevent_timer *t = container_of(timer, struct kevent_timer, ktimer);
 	struct kevent *k = t->ktimer_event;
@@ -55,7 +55,7 @@ static int kevent_timer_enqueue(struct kevent *k)
 	if (!t)
 		return -ENOMEM;
 
-	hrtimer_init(&t->ktimer, CLOCK_MONOTONIC, HRTIMER_REL);
+	hrtimer_init(&t->ktimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 	t->ktimer.expires = ktime_set(k->event.id.raw[0], k->event.id.raw[1]);
 	t->ktimer.function = kevent_timer_func;
 	t->ktimer_event = k;
@@ -69,7 +69,7 @@ static int kevent_timer_enqueue(struct kevent *k)
 	if (err)
 		goto err_out_st_fini;
 
-	hrtimer_start(&t->ktimer, t->ktimer.expires, HRTIMER_REL);
+	hrtimer_start(&t->ktimer, t->ktimer.expires, HRTIMER_MODE_REL);
 
 	return 0;
 
diff --git a/kernel/kevent/kevent_user.c b/kernel/kevent/kevent_user.c
index f25d696..883b82b 100644
--- a/kernel/kevent/kevent_user.c
+++ b/kernel/kevent/kevent_user.c
@@ -152,7 +152,7 @@ static struct kevent_user *kevent_user_alloc(struct kevent_ring __user *ring, un
 	u->pring = ring;
 	u->ring_size = num;
 
-	hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_ABS);
+	hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_MODE_ABS);
 
 	kevent_storage_init(u, &u->st);
 
@@ -881,7 +881,7 @@ out_remove:
 }
 
 /* Used to wakeup waiting syscalls in case high-resolution timer is used. */
-static int kevent_user_wake(struct hrtimer *timer)
+static enum hrtimer_restart kevent_user_wake(struct hrtimer *timer)
 {
 	struct kevent_user *u = container_of(timer, struct kevent_user, timer);
 
@@ -910,10 +910,10 @@ static int kevent_user_wait(struct file *file, struct kevent_user *u,
 
 		if (flags & KEVENT_FLAGS_ABSTIME) {
 			hrtimer_cancel(&u->timer);
-			hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_ABS);
+			hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_MODE_ABS);
 			u->timer.expires = ktime_set(timeout.tv_sec, timeout.tv_nsec);
 			u->timer.function = &kevent_user_wake;
-			hrtimer_start(&u->timer, u->timer.expires, HRTIMER_ABS);
+			hrtimer_start(&u->timer, u->timer.expires, HRTIMER_MODE_ABS);
 			if (unlikely(kevent_debug_abstime == 0)) {
 				printk(KERN_INFO "kevent: author was wrong, "
 						"someone uses absolute time in %s, "
@@ -1214,10 +1214,10 @@ asmlinkage long sys_kevent_wait(int ctl_fd, unsigned int num, unsigned int old_u
 
 		if (flags & KEVENT_FLAGS_ABSTIME) {
 			hrtimer_cancel(&u->timer);
-			hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_ABS);
+			hrtimer_init(&u->timer, CLOCK_REALTIME, HRTIMER_MODE_ABS);
 			u->timer.expires = ktime_set(timeout.tv_sec, timeout.tv_nsec);
 			u->timer.function = &kevent_user_wake;
-			hrtimer_start(&u->timer, u->timer.expires, HRTIMER_ABS);
+			hrtimer_start(&u->timer, u->timer.expires, HRTIMER_MODE_ABS);
 			if (unlikely(kevent_debug_abstime == 0)) {
 				printk(KERN_INFO "kevent: author was wrong, "
 						"someone uses absolute time in %s, "
