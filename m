From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [resend take 3 2/4] DST network files.
Date: Tue, 25 Nov 2008 17:37:48 +0300
Message-ID: <12276238741618-git-send-email-zbr@ioremap.net>
References: <12276238703113-git-send-email-zbr@ioremap.net>
 <1227623874638-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1227623874638-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/drivers/block/dst/export.c b/drivers/block/dst/export.c
new file mode 100644
index 0000000..c6bb0a5
--- /dev/null
+++ b/drivers/block/dst/export.c
@@ -0,0 +1,664 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/dst.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/poll.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+
+#include <net/sock.h>
+
+/*
+ * Export bioset is used for server block IO requests.
+ */
+static struct bio_set *dst_bio_set;
+
+int __init dst_export_init(void)
+{
+	int err = -ENOMEM;
+
+	dst_bio_set = bioset_create(32, 32);
+	if (!dst_bio_set)
+		goto err_out_exit;
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+void dst_export_exit(void)
+{
+	bioset_free(dst_bio_set);
+}
+
+/*
+ * When client connects and autonegotiates with the server node,
+ * its permissions are checked in a security attributes and sent
+ * back.
+ */
+static unsigned int dst_check_permissions(struct dst_state *main, struct dst_state *st)
+{
+	struct dst_node *n = main->node;
+	struct dst_secure *sentry;
+	struct dst_secure_user *s;
+	struct saddr *sa = &st->ctl.addr;
+	unsigned int perm = 0;
+
+	mutex_lock(&n->security_lock);
+	list_for_each_entry(sentry, &n->security_list, sec_entry) {
+		s = &sentry->sec;
+
+		if (s->addr.sa_family != sa->sa_family)
+			continue;
+
+		if (s->addr.sa_data_len != sa->sa_data_len)
+			continue;
+
+		/*
+		 * This '2' below is a port field. This may be very wrong to do
+		 * in atalk for example though. If there will be any need to extent
+		 * protocol to something else, I can create per-family helpers and
+		 * use them instead of this memcmp.
+		 */
+		if (memcmp(s->addr.sa_data + 2, sa->sa_data + 2,
+					sa->sa_data_len - 2))
+			continue;
+
+		perm = s->permissions;
+	}
+	mutex_unlock(&n->security_lock);
+
+	return perm;
+}
+
+/*
+ * Accept new client: allocate appropriate network state and check permissions.
+ */
+static struct dst_state *dst_accept_client(struct dst_state *st)
+{
+	unsigned int revents = 0;
+	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
+	unsigned int mask = err_mask | POLLIN;
+	struct dst_node *n = st->node;
+	int err = 0;
+	struct socket *sock = NULL;
+	struct dst_state *new;
+
+	while (!err && !sock) {
+		revents = dst_state_poll(st);
+
+		if (!(revents & mask)) {
+			DEFINE_WAIT(wait);
+
+			for (;;) {
+				prepare_to_wait(&st->thread_wait,
+						&wait, TASK_INTERRUPTIBLE);
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				revents = dst_state_poll(st);
+
+				if (revents & mask)
+					break;
+
+				if (signal_pending(current))
+					break;
+
+				/*
+				 * Magic HZ? Polling check above is not safe in
+				 * all cases (like socket reset in BH context),
+				 * so it is simpler just to postpone it to the
+				 * process context instead of implementing special
+				 * locking there.
+				 */
+				schedule_timeout(HZ);
+			}
+			finish_wait(&st->thread_wait, &wait);
+		}
+
+		err = -ECONNRESET;
+		dst_state_lock(st);
+
+		dprintk("%s: st: %p, revents: %x [err: %d, in: %d].\n",
+			__func__, st, revents, revents & err_mask,
+			revents & POLLIN);
+
+		if (revents & err_mask) {
+			dprintk("%s: revents: %x, socket: %p, err: %d.\n",
+					__func__, revents, st->socket, err);
+			err = -ECONNRESET;
+		}
+
+		if (!n->trans_scan_timeout || st->need_exit)
+			err = -ENODEV;
+
+		if (st->socket && (revents & POLLIN))
+			err = kernel_accept(st->socket, &sock, 0);
+
+		dst_state_unlock(st);
+	}
+
+	if (err)
+		goto err_out_exit;
+
+	new = dst_state_alloc(st->node);
+	if (!new) {
+		err = -ENOMEM;
+		goto err_out_release;
+	}
+	new->socket = sock;
+
+	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);
+	err = kernel_getpeername(sock, (struct sockaddr *)&new->ctl.addr,
+			(int *)&new->ctl.addr.sa_data_len);
+	if (err)
+		goto err_out_put;
+
+	new->permissions = dst_check_permissions(st, new);
+	if (new->permissions == 0) {
+		err = -EPERM;
+		dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
+				"Client is not allowed to connect");
+		goto err_out_put;
+	}
+
+	err = dst_poll_init(new);
+	if (err)
+		goto err_out_put;
+
+	dst_dump_addr(sock, (struct sockaddr *)&new->ctl.addr,
+			"Connected client");
+
+	return new;
+
+err_out_put:
+	dst_state_put(new);
+err_out_release:
+	sock_release(sock);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+/*
+ * Each server's block request sometime finishes.
+ * Usually it happens in hard irq context of the appropriate controller,
+ * so to play good with all cases we just queue BIO into the queue
+ * and wake up processing thread, which gets completed request and
+ * send (encrypting if needed) it back to the client (if it was a read
+ * request), or sends back reply that writing succesfully completed.
+ */
+static int dst_export_process_request_queue(struct dst_state *st)
+{
+	unsigned long flags;
+	struct dst_export_priv *p = NULL;
+	struct bio *bio;
+	int err = 0;
+
+	while (!list_empty(&st->request_list)) {
+		spin_lock_irqsave(&st->request_lock, flags);
+		if (!list_empty(&st->request_list)) {
+			p = list_first_entry(&st->request_list,
+				struct dst_export_priv, request_entry);
+			list_del(&p->request_entry);
+		}
+		spin_unlock_irqrestore(&st->request_lock, flags);
+
+		if (!p)
+			break;
+
+		bio = p->bio;
+
+		if (dst_need_crypto(st->node) && (bio_data_dir(bio) == READ))
+			err = dst_export_crypto(st->node, bio);
+		else
+			err = dst_export_send_bio(bio);
+
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+/*
+ * Cleanup export state.
+ * It has to wait until all requests are finished,
+ * and then free them all.
+ */
+static void dst_state_cleanup_export(struct dst_state *st)
+{
+	struct dst_export_priv *p;
+	unsigned long flags;
+
+	/*
+	 * This loop waits for all pending bios to be completed and freed.
+	 */
+	while (atomic_read(&st->refcnt) > 1) {
+		dprintk("%s: st: %p, refcnt: %d, list_empty: %d.\n",
+				__func__, st, atomic_read(&st->refcnt),
+				list_empty(&st->request_list));
+		wait_event_timeout(st->thread_wait,
+				(atomic_read(&st->refcnt) == 1) ||
+				!list_empty(&st->request_list),
+				HZ/2);
+
+		while (!list_empty(&st->request_list)) {
+			p = NULL;
+			spin_lock_irqsave(&st->request_lock, flags);
+			if (!list_empty(&st->request_list)) {
+				p = list_first_entry(&st->request_list,
+					struct dst_export_priv, request_entry);
+				list_del(&p->request_entry);
+			}
+			spin_unlock_irqrestore(&st->request_lock, flags);
+
+			if (p)
+				bio_put(p->bio);
+			
+			dprintk("%s: st: %p, refcnt: %d, list_empty: %d, p: %p.\n",
+				__func__, st, atomic_read(&st->refcnt),
+				list_empty(&st->request_list), p);
+		}
+	}
+	
+	dst_state_put(st);
+}
+
+/*
+ * Client accepting thread.
+ * Not only accepts new connection, but also schedules receiving thread
+ * and performs request completion described above.
+ */
+static int dst_accept(void *init_data, void *schedule_data)
+{
+	struct dst_state *main = schedule_data;
+	struct dst_node *n = init_data;
+	struct dst_state *st;
+	int err;
+
+	while (n->trans_scan_timeout && !main->need_exit) {
+		dprintk("%s: main: %p, n: %p.\n", __func__, main, n);
+		st = dst_accept_client(main);
+		if (IS_ERR(st))
+			continue;
+
+		err = dst_state_schedule_receiver(st);
+		if (!err) {
+			while (n->trans_scan_timeout) {
+				err = wait_event_interruptible_timeout(st->thread_wait,
+						!list_empty(&st->request_list) ||
+						!n->trans_scan_timeout ||
+						st->need_exit,
+					HZ);
+
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				if (list_empty(&st->request_list))
+					continue;
+
+				err = dst_export_process_request_queue(st);
+				if (err)
+					break;
+			}
+
+			st->need_exit = 1;
+			wake_up(&st->thread_wait);
+		}
+
+		dst_state_cleanup_export(st);
+	}
+
+	dprintk("%s: freeing listening socket st: %p.\n", __func__, main);
+	
+	dst_state_lock(main);
+	dst_poll_exit(main);
+	dst_state_socket_release(main);
+	dst_state_unlock(main);
+	dst_state_put(main);
+	dprintk("%s: freed listening socket st: %p.\n", __func__, main);
+
+	return 0;
+}
+
+int dst_start_export(struct dst_node *n)
+{
+	if (list_empty(&n->security_list)) {
+		printk(KERN_ERR "You are trying to export node '%s' without security attributes.\n"
+				"No clients will be allowed to connect. Exiting.\n", n->name);
+		return -EINVAL;
+	}
+	return dst_node_trans_init(n, sizeof(struct dst_export_priv));
+}
+
+/*
+ * Initialize listening state and schedule accepting thread.
+ */
+int dst_node_init_listened(struct dst_node *n, struct dst_export_ctl *le)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+	struct dst_network_ctl *ctl = &le->ctl;
+
+	memcpy(&n->info->net, ctl, sizeof(struct dst_network_ctl));
+
+	st = dst_state_alloc(n);
+	if (IS_ERR(st)) {
+		err = PTR_ERR(st);
+		goto err_out_exit;
+	}
+	memcpy(&st->ctl, ctl, sizeof(struct dst_network_ctl));
+
+	err = dst_state_socket_create(st);
+	if (err)
+		goto err_out_put;
+
+	st->socket->sk->sk_reuse = 1;
+
+	err = kernel_bind(st->socket, (struct sockaddr *)&ctl->addr,
+			ctl->addr.sa_data_len);
+	if (err)
+		goto err_out_socket_release;
+
+	err = kernel_listen(st->socket, 1024);
+	if (err)
+		goto err_out_socket_release;
+	n->state = st;
+
+	err = dst_poll_init(st);
+	if (err)
+		goto err_out_socket_release;
+
+	dst_state_get(st);
+
+	err = thread_pool_schedule(n->pool, dst_thread_setup,
+			dst_accept, st, MAX_SCHEDULE_TIMEOUT);
+	if (err)
+		goto err_out_poll_exit;
+
+	return 0;
+
+err_out_poll_exit:
+	dst_poll_exit(st);
+err_out_socket_release:
+	dst_state_socket_release(st);
+err_out_put:
+	dst_state_put(st);
+err_out_exit:
+	n->state = NULL;
+	return err;
+}
+
+/*
+ * Free bio and related private data.
+ * Also drop a reference counter for appropriate state,
+ * which waits when there are no more block IOs in-flight.
+ */
+static void dst_bio_destructor(struct bio *bio)
+{
+	struct bio_vec *bv;
+	struct dst_export_priv *priv = bio->bi_private;
+	int i;
+
+	bio_for_each_segment(bv, bio, i) {
+		if (!bv->bv_page)
+			break;
+
+		__free_page(bv->bv_page);
+	}
+
+	if (priv) {
+		struct dst_node *n = priv->state->node;
+
+		dst_state_put(priv->state);
+		mempool_free(priv, n->trans_pool);
+	}
+	bio_free(bio, dst_bio_set);
+}
+
+/*
+ * Block IO completion. Queue request to be sent back to
+ * the client (or just confirmation).
+ */
+static void dst_bio_end_io(struct bio *bio, int err)
+{
+	struct dst_export_priv *p = bio->bi_private;
+	struct dst_state *st = p->state;
+	unsigned long flags;
+
+	spin_lock_irqsave(&st->request_lock, flags);
+	list_add_tail(&p->request_entry, &st->request_list);
+	spin_unlock_irqrestore(&st->request_lock, flags);
+
+	wake_up(&st->thread_wait);
+}
+
+/*
+ * Allocate read request for the server.
+ */
+static int dst_export_read_request(struct bio *bio, unsigned int total_size)
+{
+	unsigned int size;
+	struct page *page;
+	int err;
+
+	while (total_size) {
+		err = -ENOMEM;
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			goto err_out_exit;
+
+		size = min_t(unsigned int, PAGE_SIZE, total_size);
+
+		err = bio_add_page(bio, page, size, 0);
+		dprintk("%s: bio: %llu/%u, size: %u, err: %d.\n",
+				__func__, (u64)bio->bi_sector, bio->bi_size,
+				size, err);
+		if (err <= 0)
+			goto err_out_free_page;
+
+		total_size -= size;
+	}
+
+	return 0;
+
+err_out_free_page:
+	__free_page(page);
+err_out_exit:
+	return err;
+}
+
+/*
+ * Allocate write request for the server.
+ * Should not only get pages, but also read data from the network.
+ */
+static int dst_export_write_request(struct dst_state *st,
+		struct bio *bio, unsigned int total_size)
+{
+	unsigned int size;
+	struct page *page;
+	void *data;
+	int err;
+
+	while (total_size) {
+		err = -ENOMEM;
+		page = alloc_page(GFP_KERNEL);
+		if (!page)
+			goto err_out_exit;
+
+		data = kmap(page);
+		if (!data)
+			goto err_out_free_page;
+
+		size = min_t(unsigned int, PAGE_SIZE, total_size);
+
+		err = dst_data_recv(st, data, size);
+		if (err)
+			goto err_out_unmap_page;
+
+		err = bio_add_page(bio, page, size, 0);
+		if (err <= 0)
+			goto err_out_unmap_page;
+
+		kunmap(page);
+
+		total_size -= size;
+	}
+
+	return 0;
+
+err_out_unmap_page:
+	kunmap(page);
+err_out_free_page:
+	__free_page(page);
+err_out_exit:
+	return err;
+}
+
+/*
+ * Groovy, we've gotten an IO request from the client.
+ * Allocate BIO from the bioset, private data from the mempool
+ * and lots of pages for IO.
+ */
+int dst_process_io(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	struct bio *bio;
+	struct dst_export_priv *priv;
+	int err = -ENOMEM;
+
+	if (unlikely(!n->bdev)) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	bio = bio_alloc_bioset(GFP_KERNEL,
+			PAGE_ALIGN(cmd->size) >> PAGE_SHIFT,
+			dst_bio_set);
+	if (!bio)
+		goto err_out_exit;
+	bio->bi_private = NULL;
+
+	priv = mempool_alloc(st->node->trans_pool, GFP_KERNEL);
+	if (!priv)
+		goto err_out_free;
+
+	priv->state = dst_state_get(st);
+	priv->bio = bio;
+
+	bio->bi_private = priv;
+	bio->bi_end_io = dst_bio_end_io;
+	bio->bi_destructor = dst_bio_destructor;
+	bio->bi_bdev = n->bdev;
+
+	/*
+	 * Server side is only interested in two low bits:
+	 * uptodate (set by itself actually) and rw block
+	 */
+	bio->bi_flags |= cmd->flags & 3;
+
+	bio->bi_rw = cmd->rw;
+	bio->bi_size = 0;
+	bio->bi_sector = cmd->sector;
+
+	dst_bio_to_cmd(bio, &priv->cmd, DST_IO_RESPONSE, cmd->id);
+
+	priv->cmd.flags = 0;
+	priv->cmd.size = cmd->size;
+
+	if (bio_data_dir(bio) == WRITE) {
+		err = dst_recv_cdata(st, priv->cmd.hash);
+		if (err)
+			goto err_out_free;
+
+		err = dst_export_write_request(st, bio, cmd->size);
+		if (err)
+			goto err_out_free;
+
+		if (dst_need_crypto(n))
+			return dst_export_crypto(n, bio);
+	} else {
+		err = dst_export_read_request(bio, cmd->size);
+		if (err)
+			goto err_out_free;
+	}
+
+	dprintk("%s: bio: %llu/%u, rw: %lu, dir: %lu, flags: %lx, phys: %d.\n",
+			__func__, (u64)bio->bi_sector, bio->bi_size,
+			bio->bi_rw, bio_data_dir(bio),
+			bio->bi_flags, bio->bi_phys_segments);
+
+	generic_make_request(bio);
+
+	return 0;
+
+err_out_free:
+	bio_put(bio);
+err_out_exit:
+	return err;
+}
+
+/*
+ * Ok, block IO is ready, let's send it back to the client...
+ */
+int dst_export_send_bio(struct bio *bio)
+{
+	struct dst_export_priv *p = bio->bi_private;
+	struct dst_state *st = p->state;
+	struct dst_cmd *cmd = &p->cmd;
+	int err;
+
+	dprintk("%s: id: %llu, bio: %llu/%u, csize: %u, flags: %lu, rw: %lu.\n",
+			__func__, cmd->id, (u64)bio->bi_sector, bio->bi_size,
+			cmd->csize, bio->bi_flags, bio->bi_rw);
+
+	dst_convert_cmd(cmd);
+
+	dst_state_lock(st);
+	if (!st->socket) {
+		err = -ECONNRESET;
+		goto err_out_unlock;
+	}
+
+	if (bio_data_dir(bio) == WRITE) {
+		/* ... or just confirmation that writing has completed. */
+		cmd->size = cmd->csize = 0;
+		err = dst_data_send_header(st->socket, cmd,
+				sizeof(struct dst_cmd), 0);
+		if (err)
+			goto err_out_unlock;
+	} else {
+		err = dst_send_bio(st, cmd, bio);
+		if (err)
+			goto err_out_unlock;
+	}
+
+	dst_state_unlock(st);
+
+	bio_put(bio);
+	return 0;
+
+err_out_unlock:
+	dst_state_unlock(st);
+
+	bio_put(bio);
+	return err;
+}
diff --git a/drivers/block/dst/state.c b/drivers/block/dst/state.c
new file mode 100644
index 0000000..7243d37
--- /dev/null
+++ b/drivers/block/dst/state.c
@@ -0,0 +1,839 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/buffer_head.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/connector.h>
+#include <linux/dst.h>
+#include <linux/device.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <linux/socket.h>
+#include <linux/slab.h>
+
+#include <net/sock.h>
+
+/*
+ * Polling machinery.
+ */
+
+struct dst_poll_helper
+{
+	poll_table 		pt;
+	struct dst_state	*st;
+};
+
+static int dst_queue_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct dst_state *st = container_of(wait, struct dst_state, wait);
+
+	wake_up(&st->thread_wait);
+	return 1;
+}
+
+static void dst_queue_func(struct file *file, wait_queue_head_t *whead,
+				 poll_table *pt)
+{
+	struct dst_state *st = container_of(pt, struct dst_poll_helper, pt)->st;
+
+	st->whead = whead;
+	init_waitqueue_func_entry(&st->wait, dst_queue_wake);
+	add_wait_queue(whead, &st->wait);
+}
+
+void dst_poll_exit(struct dst_state *st)
+{
+	if (st->whead) {
+		remove_wait_queue(st->whead, &st->wait);
+		st->whead = NULL;
+	}
+}
+
+int dst_poll_init(struct dst_state *st)
+{
+	struct dst_poll_helper ph;
+
+	ph.st = st;
+	init_poll_funcptr(&ph.pt, &dst_queue_func);
+
+	st->socket->ops->poll(NULL, st->socket, &ph.pt);
+	return 0;
+}
+
+/*
+ * Header receiving function - may block.
+ */
+static int dst_data_recv_header(struct socket *sock,
+		void *data, unsigned int size, int block)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	iov.iov_base = data;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = (block)?MSG_WAITALL:MSG_DONTWAIT;
+
+	err = kernel_recvmsg(sock, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err != size)
+		return -1;
+
+	return 0;
+}
+
+/*
+ * Header sending function - may block.
+ */
+int dst_data_send_header(struct socket *sock,
+		void *data, unsigned int size, int more)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	iov.iov_base = data;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | (more)?MSG_MORE:0;
+
+	err = kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
+	if (err != size) {
+		dprintk("%s: size: %u, more: %d, err: %d.\n",
+				__func__, size, more, err);
+		return -1;
+	}
+
+	return 0;
+}
+
+/*
+ * Block autoconfiguration: request size of the storage and permissions.
+ */
+static int dst_request_remote_config(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	int err = -EINVAL;
+	struct dst_cmd *cmd = st->data;
+
+	memset(cmd, 0, sizeof(struct dst_cmd));
+	cmd->cmd = DST_CFG;
+
+	dst_convert_cmd(cmd);
+
+	err = dst_data_send_header(st->socket, cmd, sizeof(struct dst_cmd), 0);
+	if (err)
+		goto out;
+
+	err = dst_data_recv_header(st->socket, cmd, sizeof(struct dst_cmd), 1);
+	if (err)
+		goto out;
+
+	dst_convert_cmd(cmd);
+
+	if (cmd->cmd != DST_CFG) {
+		err = -EINVAL;
+		dprintk("%s: checking result: cmd: %d, size reported: %llu.\n",
+			__func__, cmd->cmd, cmd->sector);
+		goto out;
+	}
+
+	if (n->size != 0)
+		n->size = min_t(loff_t, n->size, cmd->sector);
+	else
+		n->size = cmd->sector;
+
+	n->info->size = n->size;
+	st->permissions = cmd->rw;
+
+out:
+	dprintk("%s: n: %p, err: %d, size: %llu, permission: %x.\n",
+			__func__, n, err, n->size, st->permissions);
+	return err;
+}
+
+/*
+ * Socket machinery.
+ */
+
+#define DST_DEFAULT_TIMEO	20000
+
+int dst_state_socket_create(struct dst_state *st)
+{
+	int err;
+	struct socket *sock;
+	struct dst_network_ctl *ctl = &st->ctl;
+
+	err = sock_create(ctl->addr.sa_family, ctl->type, ctl->proto, &sock);
+	if (err < 0)
+		return err;
+
+	sock->sk->sk_sndtimeo = sock->sk->sk_rcvtimeo =
+		msecs_to_jiffies(DST_DEFAULT_TIMEO);
+	sock->sk->sk_allocation = GFP_NOIO;
+
+	st->socket = st->read_socket = sock;
+	return 0;
+}
+
+void dst_state_socket_release(struct dst_state *st)
+{
+	dprintk("%s: st: %p, socket: %p, n: %p.\n",
+			__func__, st, st->socket, st->node);
+	if (st->socket) {
+		sock_release(st->socket);
+		st->socket = NULL;
+		st->read_socket = NULL;
+	}
+}
+
+void dst_dump_addr(struct socket *sk, struct sockaddr *sa, char *str)
+{
+	if (sk->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)sa;
+		printk(KERN_INFO "%s %u.%u.%u.%u:%d.\n",
+			str, NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (sk->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)sa;
+		printk(KERN_INFO "%s %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+			str, NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+}
+
+void dst_state_exit_connected(struct dst_state *st)
+{
+	if (st->socket) {
+		dst_poll_exit(st);
+		st->socket->ops->shutdown(st->socket, 2);
+
+		dst_dump_addr(st->socket, (struct sockaddr *)&st->ctl.addr,
+				"Disconnected peer");
+		dst_state_socket_release(st);
+	}
+}
+
+static int dst_state_init_connected(struct dst_state *st)
+{
+	int err;
+	struct dst_network_ctl *ctl = &st->ctl;
+
+	err = dst_state_socket_create(st);
+	if (err)
+		goto err_out_exit;
+
+	err = kernel_connect(st->socket, (struct sockaddr *)&st->ctl.addr,
+			st->ctl.addr.sa_data_len, 0);
+	if (err)
+		goto err_out_release;
+
+	err = dst_poll_init(st);
+	if (err)
+		goto err_out_release;
+
+	dst_dump_addr(st->socket, (struct sockaddr *)&ctl->addr,
+			"Connected to peer");
+
+	return 0;
+
+err_out_release:
+	dst_state_socket_release(st);
+err_out_exit:
+	return err;
+}
+
+/*
+ * State reset is used to reconnect to the remote peer.
+ * May fail, but who cares, we will try again later.
+ */
+static void inline dst_state_reset_nolock(struct dst_state *st)
+{
+	dst_state_exit_connected(st);
+	dst_state_init_connected(st);
+}
+
+static void inline dst_state_reset(struct dst_state *st)
+{
+	dst_state_lock(st);
+	dst_state_reset_nolock(st);
+	dst_state_unlock(st);
+}
+
+/*
+ * Basic network sending/receiving functions.
+ * Blocked mode is used.
+ */
+static int dst_data_recv_raw(struct dst_state *st, void *buf, u64 size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	int err;
+
+	BUG_ON(!size);
+
+	iov.iov_base = buf;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_DONTWAIT;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	if (err <= 0) {
+		dprintk("%s: failed to recv data: size: %llu, err: %d.\n",
+				__func__, size, err);
+		if (err == 0)
+			err = -ECONNRESET;
+
+		dst_state_exit_connected(st);
+	}
+
+	return err;
+}
+
+/*
+ * Ping command to early detect failed nodes.
+ */
+static int dst_send_ping(struct dst_state *st)
+{
+	struct dst_cmd *cmd = st->data;
+	int err = -ECONNRESET;
+
+	dst_state_lock(st);
+	if (st->socket) {
+		memset(cmd, 0, sizeof(struct dst_cmd));
+
+		cmd->cmd = __cpu_to_be32(DST_PING);
+
+		err = dst_data_send_header(st->socket, cmd, sizeof(struct dst_cmd), 0);
+	}
+	dprintk("%s: st: %p, socket: %p, err: %d.\n", __func__, st, st->socket, err);
+	dst_state_unlock(st);
+
+	return err;
+}
+
+/*
+ * Receiving function, which should either return error or read
+ * whole block request. If there was no traffic for a one second,
+ * send a ping, since remote node may die.
+ */
+int dst_data_recv(struct dst_state *st, void *data, unsigned int size)
+{
+	unsigned int revents = 0;
+	unsigned int err_mask = POLLERR | POLLHUP | POLLRDHUP;
+	unsigned int mask = err_mask | POLLIN;
+	struct dst_node *n = st->node;
+	int err = 0;
+
+	while (size && !err) {
+		revents = dst_state_poll(st);
+
+		if (!(revents & mask)) {
+			DEFINE_WAIT(wait);
+
+			for (;;) {
+				prepare_to_wait(&st->thread_wait, &wait,
+						TASK_INTERRUPTIBLE);
+				if (!n->trans_scan_timeout || st->need_exit)
+					break;
+
+				revents = dst_state_poll(st);
+
+				if (revents & mask)
+					break;
+
+				if (signal_pending(current))
+					break;
+
+				if (!schedule_timeout(HZ)) {
+					err = dst_send_ping(st);
+					if (err)
+						return err;
+				}
+
+				continue;
+			}
+			finish_wait(&st->thread_wait, &wait);
+		}
+
+		err = -ECONNRESET;
+		dst_state_lock(st);
+
+		if (		st->socket &&
+				(st->read_socket == st->socket) &&
+				(revents & POLLIN)) {
+			err = dst_data_recv_raw(st, data, size);
+			if (err > 0) {
+				data += err;
+				size -= err;
+				err = 0;
+			}
+		}
+
+		if (revents & err_mask || !st->socket) {
+			dprintk("%s: revents: %x, socket: %p, size: %u, err: %d.\n",
+					__func__, revents, st->socket, size, err);
+			err = -ECONNRESET;
+		}
+
+		dst_state_unlock(st);
+
+		if (!n->trans_scan_timeout)
+			err = -ENODEV;
+	}
+
+	return err;
+}
+
+/*
+ * Send block autoconf reply.
+ */
+static int dst_process_cfg(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	int err;
+
+	cmd->sector = n->size;
+	cmd->rw = st->permissions;
+
+	dst_convert_cmd(cmd);
+
+	dst_state_lock(st);
+	err = dst_data_send_header(st->socket, cmd, sizeof(struct dst_cmd), 0);
+	dst_state_unlock(st);
+
+	return err;
+}
+
+/*
+ * Receive block IO from the network.
+ */
+static int dst_recv_bio(struct dst_state *st, struct bio *bio, unsigned int total_size)
+{
+	struct bio_vec *bv;
+	int i, err;
+	void *data;
+	unsigned int sz;
+
+	bio_for_each_segment(bv, bio, i) {
+		sz = min(total_size, bv->bv_len);
+
+		dprintk("%s: bio: %llu/%u, total: %u, len: %u, sz: %u, off: %u.\n",
+			__func__, (u64)bio->bi_sector, bio->bi_size, total_size,
+			bv->bv_len, sz, bv->bv_offset);
+
+		data = kmap(bv->bv_page) + bv->bv_offset;
+		err = dst_data_recv(st, data, sz);
+		kunmap(bv->bv_page);
+
+		bv->bv_len = sz;
+
+		if (err)
+			return err;
+
+		total_size -= sz;
+		if (total_size == 0)
+			break;
+	}
+
+	return 0;
+}
+
+/*
+ * Our block IO has just completed and arrived: get it.
+ */
+static int dst_process_io_response(struct dst_state *st)
+{
+	struct dst_node *n = st->node;
+	struct dst_cmd *cmd = st->data;
+	struct dst_trans *t;
+	int err = 0;
+	struct bio *bio;
+
+	mutex_lock(&n->trans_lock);
+	t = dst_trans_search(n, cmd->id);
+	mutex_unlock(&n->trans_lock);
+
+	if (!t)
+		goto err_out_exit;
+
+	bio = t->bio;
+
+	dprintk("%s: bio: %llu/%u, cmd_size: %u, csize: %u, dir: %lu.\n",
+		__func__, (u64)bio->bi_sector, bio->bi_size, cmd->size,
+		cmd->csize, bio_data_dir(bio));
+
+	if (bio_data_dir(bio) == READ) {
+		if (bio->bi_size != cmd->size - cmd->csize)
+			goto err_out_exit;
+
+		if (dst_need_crypto(n)) {
+			err = dst_recv_cdata(st, t->cmd.hash);
+			if (err)
+				goto err_out_exit;
+		}
+
+		err = dst_recv_bio(st, t->bio, bio->bi_size);
+		if (err)
+			goto err_out_exit;
+
+		if (dst_need_crypto(n))
+			return dst_trans_crypto(t);
+	} else {
+		err = -EBADMSG;
+		if (cmd->size || cmd->csize)
+			goto err_out_exit;
+	}
+
+	dst_trans_remove(t);
+	dst_trans_put(t);
+
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+/*
+ * Receive crypto data.
+ */
+int dst_recv_cdata(struct dst_state *st, void *cdata)
+{
+	struct dst_cmd *cmd = st->data;
+	struct dst_node *n = st->node;
+	struct dst_crypto_ctl *c = &n->crypto;
+	int err;
+
+	if (cmd->csize != c->crypto_attached_size) {
+		dprintk("%s: cmd: cmd: %u, sector: %llu, size: %u, "
+				"csize: %u != digest size %u.\n",
+				__func__, cmd->cmd, cmd->sector, cmd->size,
+				cmd->csize, c->crypto_attached_size);
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	err = dst_data_recv(st, cdata, cmd->csize);
+	if (err)
+		goto err_out_exit;
+
+	cmd->size -= cmd->csize;
+	return 0;
+
+err_out_exit:
+	return err;
+}
+
+/*
+ * Receive the command and start its processing.
+ */
+static int dst_recv_processing(struct dst_state *st)
+{
+	int err = -EINTR;
+	struct dst_cmd *cmd = st->data;
+
+	/*
+	 * If socket will be reset after this statement, then
+	 * dst_data_recv() will just fail and loop will
+	 * start again, so it can be done without any locks.
+	 *
+	 * st->read_socket is needed to prevents state machine
+	 * breaking between this data reading and subsequent one
+	 * in protocol specific functions during connection reset.
+	 * In case of reset we have to read next command and do
+	 * not expect data for old command to magically appear in
+	 * new connection.
+	 */
+	st->read_socket = st->socket;
+	err = dst_data_recv(st, cmd, sizeof(struct dst_cmd));
+	if (err)
+		goto out_exit;
+
+	dst_convert_cmd(cmd);
+
+	dprintk("%s: cmd: %u, size: %u, csize: %u, id: %llu, "
+			"sector: %llu, flags: %llx, rw: %llx.\n",
+			__func__, cmd->cmd, cmd->size,
+			cmd->csize, cmd->id, cmd->sector,
+			cmd->flags, cmd->rw);
+
+	/*
+	 * This should catch protocol breakage and random garbage instead of commands.
+	 */
+	if (unlikely(cmd->csize > st->size - sizeof(struct dst_cmd))) {
+		err = -EBADMSG;
+		goto out_exit;
+	}
+
+	err = -EPROTO;
+	switch (cmd->cmd) {
+		case DST_IO_RESPONSE:
+			err = dst_process_io_response(st);
+			break;
+		case DST_IO:
+			err = dst_process_io(st);
+			break;
+		case DST_CFG:
+			err = dst_process_cfg(st);
+			break;
+		case DST_PING:
+			err = 0;
+			break;
+		default:
+			break;
+	}
+
+out_exit:
+	return err;
+}
+
+/*
+ * Receiving thread. For the client node we should try to reconnect,
+ * for accepted client we just drop the state and expect it to reconnect.
+ */
+static int dst_recv(void *init_data, void *schedule_data)
+{
+	struct dst_state *st = schedule_data;
+	struct dst_node *n = init_data;
+	int err = 0;
+
+	dprintk("%s: start st: %p, n: %p, scan: %lu, need_exit: %d.\n",
+			__func__, st, n, n->trans_scan_timeout, st->need_exit);
+
+	while (n->trans_scan_timeout && !st->need_exit) {
+		err = dst_recv_processing(st);
+		if (err < 0) {
+			if (!st->ctl.type)
+				break;
+
+			if (!n->trans_scan_timeout || st->need_exit)
+				break;
+
+			dst_state_reset(st);
+			msleep(1000);
+		}
+	}
+
+	st->need_exit = 1;
+	wake_up(&st->thread_wait);
+
+	dprintk("%s: freeing receiving socket st: %p.\n", __func__, st);
+	dst_state_lock(st);
+	dst_state_exit_connected(st);
+	dst_state_unlock(st);
+	dst_state_put(st);
+
+	dprintk("%s: freed receiving socket st: %p.\n", __func__, st);
+
+	return err;
+}
+
+/*
+ * Network state dies here and borns couple of lines below.
+ * This object is the main network state processing engine:
+ * sending, receiving, reconnections, all network related
+ * tasks are handled on behalf of the state.
+ */
+static void dst_state_free(struct dst_state *st)
+{
+	dprintk("%s: st: %p.\n", __func__, st);
+	if (st->cleanup)
+		st->cleanup(st);
+	kfree(st->data);
+	kfree(st);
+}
+
+struct dst_state *dst_state_alloc(struct dst_node *n)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+
+	st = kzalloc(sizeof(struct dst_state), GFP_KERNEL);
+	if (!st)
+		goto err_out_exit;
+
+	st->node = n;
+	st->need_exit = 0;
+
+	st->size = PAGE_SIZE;
+	st->data = kmalloc(st->size, GFP_KERNEL);
+	if (!st->data)
+		goto err_out_free;
+
+	spin_lock_init(&st->request_lock);
+	INIT_LIST_HEAD(&st->request_list);
+
+	mutex_init(&st->state_lock);
+	init_waitqueue_head(&st->thread_wait);
+
+	/*
+	 * One for processing thread, another one for node itself.
+	 */
+	atomic_set(&st->refcnt, 2);
+
+	dprintk("%s: st: %p, n: %p.\n", __func__, st, st->node);
+
+	return st;
+
+err_out_free:
+	kfree(st);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+int dst_state_schedule_receiver(struct dst_state *st)
+{
+	return thread_pool_schedule_private(st->node->pool, dst_thread_setup,
+			dst_recv, st, MAX_SCHEDULE_TIMEOUT, st->node);
+}
+
+/*
+ * Initialize client's connection to the remote peer: allocate state,
+ * connect and perform block IO autoconfiguration.
+ */
+int dst_node_init_connected(struct dst_node *n, struct dst_network_ctl *r)
+{
+	struct dst_state *st;
+	int err = -ENOMEM;
+
+	st = dst_state_alloc(n);
+	if (IS_ERR(st)) {
+		err = PTR_ERR(st);
+		goto err_out_exit;
+	}
+	memcpy(&st->ctl, r, sizeof(struct dst_network_ctl));
+
+	err = dst_state_init_connected(st);
+	if (err)
+		goto err_out_free_data;
+
+	err = dst_request_remote_config(st);
+	if (err)
+		goto err_out_exit_connected;
+	n->state = st;
+
+	err = dst_state_schedule_receiver(st);
+	if (err)
+		goto err_out_exit_connected;
+
+	return 0;
+
+err_out_exit_connected:
+	dst_state_exit_connected(st);
+err_out_free_data:
+	dst_state_free(st);
+err_out_exit:
+	n->state = NULL;
+	return err;
+}
+
+void dst_state_put(struct dst_state *st)
+{
+	dprintk("%s: st: %p, refcnt: %d.\n",
+			__func__, st, atomic_read(&st->refcnt));
+	if (atomic_dec_and_test(&st->refcnt))
+		dst_state_free(st);
+}
+
+/*
+ * Send block IO to the network one by one using zero-copy ->sendpage().
+ */
+int dst_send_bio(struct dst_state *st, struct dst_cmd *cmd, struct bio *bio)
+{
+	struct bio_vec *bv;
+	struct dst_crypto_ctl *c = &st->node->crypto;
+	int err, i = 0;
+	int flags = MSG_WAITALL;
+
+	err = dst_data_send_header(st->socket, cmd,
+		sizeof(struct dst_cmd) + c->crypto_attached_size, bio->bi_vcnt);
+	if (err)
+		goto err_out_exit;
+
+	bio_for_each_segment(bv, bio, i) {
+		if (i < bio->bi_vcnt - 1)
+			flags |= MSG_MORE;
+
+		err = kernel_sendpage(st->socket, bv->bv_page, bv->bv_offset,
+				bv->bv_len, flags);
+		if (err <= 0)
+			goto err_out_exit;
+	}
+
+	return 0;
+
+err_out_exit:
+	dprintk("%s: %d/%d, flags: %x, err: %d.\n",
+			__func__, i, bio->bi_vcnt, flags, err);
+	return err;
+}
+
+/*
+ * Send transaction to the remote peer.
+ */
+int dst_trans_send(struct dst_trans *t)
+{
+	int err;
+	struct dst_state *st = t->n->state;
+	struct bio *bio = t->bio;
+
+	dst_convert_cmd(&t->cmd);
+
+	dst_state_lock(st);
+	if (!st->socket) {
+		err = dst_state_init_connected(st);
+		if (err)
+			goto err_out_unlock;
+	}
+
+	if (bio_data_dir(bio) == WRITE) {
+		err = dst_send_bio(st, &t->cmd, t->bio);
+	} else {
+		err = dst_data_send_header(st->socket, &t->cmd,
+				sizeof(struct dst_cmd), 0);
+	}
+	if (err)
+		goto err_out_reset;
+
+	dst_state_unlock(st);
+	return 0;
+
+err_out_reset:
+	dst_state_reset_nolock(st);
+err_out_unlock:
+	dst_state_unlock(st);
+
+	return err;
+}
