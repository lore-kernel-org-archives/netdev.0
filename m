From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 17:06:11 +0200
Message-ID: <49F71B63.8010503@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>	<49F3308B.1030507@cosmosbay.com>	<20090426.020411.157511269.davem@davemloft.net>	<49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org,
	Ingo Molnar <mingo@elte.hu>
To: linux kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35484 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761728AbZD1PHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:07:21 -0400
In-Reply-To: <87ab60rh8t.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] poll: Avoid extra wakeups in select/poll

After introduction of keyed wakeups Davide Libenzi did on epoll, we
are able to avoid spurious wakeups in poll()/select() code too.

For example, typical use of poll()/select() is to wait for incoming
network frames on many sockets. But TX completion for UDP/TCP 
frames call sock_wfree() which in turn schedules thread.

When scheduled, thread does a full scan of all polled fds and
can sleep again, because nothing is really available. If number
of fds is large, this cause significant load.

This patch makes select()/poll() aware of keyed wakeups and
useless wakeups are avoided. This reduces number of context
switches by about 50% on some setups, and work performed
by sofirq handlers.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Andi Kleen <ak@linux.intel.com>
---
 fs/select.c          |   28 +++++++++++++++++++++++++---
 include/linux/poll.h |    3 +++
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 0fe0e14..2708187 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -168,7 +168,7 @@ static struct poll_table_entry *poll_get_entry(struct poll_wqueues *p)
 	return table->entry++;
 }
 
-static int pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+static int __pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
 {
 	struct poll_wqueues *pwq = wait->private;
 	DECLARE_WAITQUEUE(dummy_wait, pwq->polling_task);
@@ -194,6 +194,16 @@ static int pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
 	return default_wake_function(&dummy_wait, mode, sync, key);
 }
 
+static int pollwake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct poll_table_entry *entry;
+
+	entry = container_of(wait, struct poll_table_entry, wait);
+	if (key && !((unsigned long)key & entry->key))
+		return 0;
+	return __pollwake(wait, mode, sync, key);
+}
+
 /* Add a new entry */
 static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
 				poll_table *p)
@@ -205,6 +215,7 @@ static void __pollwait(struct file *filp, wait_queue_head_t *wait_address,
 	get_file(filp);
 	entry->filp = filp;
 	entry->wait_address = wait_address;
+	entry->key = p->key;
 	init_waitqueue_func_entry(&entry->wait, pollwake);
 	entry->wait.private = pwq;
 	add_wait_queue(wait_address, &entry->wait);
@@ -418,8 +429,16 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 				if (file) {
 					f_op = file->f_op;
 					mask = DEFAULT_POLLMASK;
-					if (f_op && f_op->poll)
+					if (f_op && f_op->poll) {
+						if (wait) {
+							wait->key = POLLEX_SET;
+							if (in & bit)
+								wait->key |= POLLIN_SET;
+							if (out & bit)
+								wait->key |= POLLOUT_SET;
+						}
 						mask = (*f_op->poll)(file, retval ? NULL : wait);
+					}
 					fput_light(file, fput_needed);
 					if ((mask & POLLIN_SET) && (in & bit)) {
 						res_in |= bit;
@@ -685,8 +704,11 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 		mask = POLLNVAL;
 		if (file != NULL) {
 			mask = DEFAULT_POLLMASK;
-			if (file->f_op && file->f_op->poll)
+			if (file->f_op && file->f_op->poll) {
+				if (pwait)
+					pwait->key = pollfd->events | POLLERR | POLLHUP;
 				mask = file->f_op->poll(file, pwait);
+			}
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
 			fput_light(file, fput_needed);
diff --git a/include/linux/poll.h b/include/linux/poll.h
index 8c24ef8..3327389 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -32,6 +32,7 @@ typedef void (*poll_queue_proc)(struct file *, wait_queue_head_t *, struct poll_
 
 typedef struct poll_table_struct {
 	poll_queue_proc qproc;
+	unsigned long key;
 } poll_table;
 
 static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
@@ -43,10 +44,12 @@ static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_addres
 static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc qproc)
 {
 	pt->qproc = qproc;
+	pt->key   = ~0UL; /* all events enabled */
 }
 
 struct poll_table_entry {
 	struct file *filp;
+	unsigned long key;
 	wait_queue_t wait;
 	wait_queue_head_t *wait_address;
 };

