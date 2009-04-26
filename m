From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] poll: Avoid extra wakeups
Date: Sun, 26 Apr 2009 12:46:39 +0200
Message-ID: <49F43B8F.2050907@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>	<49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux.com, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45450 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbZDZKrp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 06:47:45 -0400
In-Reply-To: <20090426.020411.157511269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> Great stuff Eric.
>=20
> We've discussed splitting the wait queue up before, but shorter-term
> your idea is pretty cool too :-)

Well, I only got this idea because Davide did its previous work, he is
the one who did the hard stuff :)

About poll()/select() improvements, I believe following patch should
be fine too.

Note some lines on this patch are longer than 80 columns, I am
aware of this but could not find an elegant/efficient way to
avoid this.

Thank you

[PATCH] poll: Avoid extra wakeups in select/poll

After introduction of keyed wakeups  Davide Libenzi did on epoll, we
are able to avoid spurious wakeups in poll()/select() code too.

=46or example, typical use of poll()/select() is to wait for incoming
network frames on many sockets. But TX completion for UDP/TCP=20
frames call sock_wfree() which in turn schedules thread.

When scheduled, thread does a full scan of all polled fds and
can sleep again, because nothing is really available. If number
of fds is large, this cause significant load.

This patch makes select()/poll() aware of keyed wakeups and
useless wakeups are avoided. This reduces number of context
switches by about 50% on some setups, and work performed
by sofirq handlers.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/select.c          |   28 +++++++++++++++++++++++++---
 include/linux/poll.h |    3 +++
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 0fe0e14..2708187 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -168,7 +168,7 @@ static struct poll_table_entry *poll_get_entry(stru=
ct poll_wqueues *p)
 	return table->entry++;
 }
=20
-static int pollwake(wait_queue_t *wait, unsigned mode, int sync, void =
*key)
+static int __pollwake(wait_queue_t *wait, unsigned mode, int sync, voi=
d *key)
 {
 	struct poll_wqueues *pwq =3D wait->private;
 	DECLARE_WAITQUEUE(dummy_wait, pwq->polling_task);
@@ -194,6 +194,16 @@ static int pollwake(wait_queue_t *wait, unsigned m=
ode, int sync, void *key)
 	return default_wake_function(&dummy_wait, mode, sync, key);
 }
=20
+static int pollwake(wait_queue_t *wait, unsigned mode, int sync, void =
*key)
+{
+	struct poll_table_entry *entry;
+
+	entry =3D container_of(wait, struct poll_table_entry, wait);
+	if (key && !((unsigned long)key & entry->key))
+		return 0;
+	return __pollwake(wait, mode, sync, key);
+}
+
 /* Add a new entry */
 static void __pollwait(struct file *filp, wait_queue_head_t *wait_addr=
ess,
 				poll_table *p)
@@ -205,6 +215,7 @@ static void __pollwait(struct file *filp, wait_queu=
e_head_t *wait_address,
 	get_file(filp);
 	entry->filp =3D filp;
 	entry->wait_address =3D wait_address;
+	entry->key =3D p->key;
 	init_waitqueue_func_entry(&entry->wait, pollwake);
 	entry->wait.private =3D pwq;
 	add_wait_queue(wait_address, &entry->wait);
@@ -418,8 +429,16 @@ int do_select(int n, fd_set_bits *fds, struct time=
spec *end_time)
 				if (file) {
 					f_op =3D file->f_op;
 					mask =3D DEFAULT_POLLMASK;
-					if (f_op && f_op->poll)
+					if (f_op && f_op->poll) {
+						if (wait) {
+							wait->key =3D POLLEX_SET;
+							if (in & bit)
+								wait->key |=3D POLLIN_SET;
+							if (out & bit)
+								wait->key |=3D POLLOUT_SET;
+						}
 						mask =3D (*f_op->poll)(file, retval ? NULL : wait);
+					}
 					fput_light(file, fput_needed);
 					if ((mask & POLLIN_SET) && (in & bit)) {
 						res_in |=3D bit;
@@ -685,8 +704,11 @@ static inline unsigned int do_pollfd(struct pollfd=
 *pollfd, poll_table *pwait)
 		mask =3D POLLNVAL;
 		if (file !=3D NULL) {
 			mask =3D DEFAULT_POLLMASK;
-			if (file->f_op && file->f_op->poll)
+			if (file->f_op && file->f_op->poll) {
+				if (pwait)
+					pwait->key =3D pollfd->events | POLLERR | POLLHUP;
 				mask =3D file->f_op->poll(file, pwait);
+			}
 			/* Mask out unneeded events. */
 			mask &=3D pollfd->events | POLLERR | POLLHUP;
 			fput_light(file, fput_needed);
diff --git a/include/linux/poll.h b/include/linux/poll.h
index 8c24ef8..3327389 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -32,6 +32,7 @@ typedef void (*poll_queue_proc)(struct file *, wait_q=
ueue_head_t *, struct poll_
=20
 typedef struct poll_table_struct {
 	poll_queue_proc qproc;
+	unsigned long key;
 } poll_table;
=20
 static inline void poll_wait(struct file * filp, wait_queue_head_t * w=
ait_address, poll_table *p)
@@ -43,10 +44,12 @@ static inline void poll_wait(struct file * filp, wa=
it_queue_head_t * wait_addres
 static inline void init_poll_funcptr(poll_table *pt, poll_queue_proc q=
proc)
 {
 	pt->qproc =3D qproc;
+	pt->key =3D ~0UL; /* all events enabled */
 }
=20
 struct poll_table_entry {
 	struct file *filp;
+	unsigned long key;
 	wait_queue_t wait;
 	wait_queue_head_t *wait_address;
 };

