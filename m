From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [resend take 1] [2/3] Distributed storage release: network and threads.
Date: Wed, 5 Nov 2008 19:30:09 +0300
Message-ID: <20081105163009.GB11096@ioremap.net>
References: <20081105162704.GA10787@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:57768 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbYKEQaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 11:30:11 -0500
Content-Disposition: inline
In-Reply-To: <20081105162704.GA10787@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/drivers/block/dst/export.c b/drivers/block/dst/export.c
new file mode 100644
index 0000000..57154f1
--- /dev/null
+++ b/drivers/block/dst/export.c
@@ -0,0 +1,662 @@
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
+			printk("%s: revents: %x, socket: %p, err: %d.\n",
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
index 0000000..34b77e1
--- /dev/null
+++ b/drivers/block/dst/state.c
@@ -0,0 +1,838 @@
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
+		printk("%s: checking result: cmd: %d, size reported: %llu.\n",
+			__func__, cmd->cmd, cmd->sector);
+		goto out;
+	}
+
+	if (n->size != 0)
+		n->size = min_t(loff_t, n->size, cmd->sector);
+	else
+		n->size = cmd->sector;
+
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
+		printk("%s: failed to recv data: size: %llu, err: %d.\n",
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
+			printk("%s: revents: %x, socket: %p, size: %u, err: %d.\n",
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
diff --git a/drivers/block/dst/thread_pool.c b/drivers/block/dst/thread_pool.c
new file mode 100644
index 0000000..c35754d
--- /dev/null
+++ b/drivers/block/dst/thread_pool.c
@@ -0,0 +1,345 @@
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
+#include <linux/kernel.h>
+#include <linux/dst.h>
+#include <linux/kthread.h>
+#include <linux/slab.h>
+
+/*
+ * Thread pool abstraction allows to schedule a work to be performed
+ * on behalf of kernel thread. One does not operate with threads itself,
+ * instead user provides setup and cleanup callbacks for thread pool itself,
+ * and action and cleanup callbacks for each submitted work.
+ *
+ * Each worker has private data initialized at creation time and data,
+ * provided by user at scheduling time.
+ *
+ * When action is being performed, thread can not be used by other users,
+ * instead they will sleep until there is free thread to pick their work.
+ */
+struct thread_pool_worker
+{
+	struct list_head	worker_entry;
+
+	struct task_struct	*thread;
+
+	struct thread_pool	*pool;
+
+	int			error;
+	int			has_data;
+	int			need_exit;
+	unsigned int		id;
+
+	wait_queue_head_t	wait;
+
+	void			*private;
+	void			*schedule_data;
+
+	int			(* action)(void *private, void *schedule_data);
+	void			(* cleanup)(void *private);
+};
+
+static void thread_pool_exit_worker(struct thread_pool_worker *w)
+{
+	kthread_stop(w->thread);
+
+	w->cleanup(w->private);
+	kfree(w);
+}
+
+/*
+ * Called to mark thread as ready and allow users to schedule new work.
+ */
+static void thread_pool_worker_make_ready(struct thread_pool_worker *w)
+{
+	struct thread_pool *p = w->pool;
+
+	mutex_lock(&p->thread_lock);
+
+	if (!w->need_exit) {
+		list_move_tail(&w->worker_entry, &p->ready_list);
+		w->has_data = 0;
+		mutex_unlock(&p->thread_lock);
+
+		wake_up(&p->wait);
+	} else {
+		p->thread_num--;
+		list_del(&w->worker_entry);
+		mutex_unlock(&p->thread_lock);
+
+		thread_pool_exit_worker(w);
+	}
+}
+
+/*
+ * Thread action loop: waits until there is new work.
+ */
+static int thread_pool_worker_func(void *data)
+{
+	struct thread_pool_worker *w = data;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(w->wait,
+			kthread_should_stop() || w->has_data);
+
+		if (kthread_should_stop())
+			break;
+
+		if (!w->has_data)
+			continue;
+
+		w->action(w->private, w->schedule_data);
+		thread_pool_worker_make_ready(w);
+	}
+
+	return 0;
+}
+
+/*
+ * Remove single worker without specifying which one.
+ */
+void thread_pool_del_worker(struct thread_pool *p)
+{
+	struct thread_pool_worker *w = NULL;
+
+	while (!w) {
+		wait_event(p->wait, !list_empty(&p->ready_list) || !p->thread_num);
+
+		dprintk("%s: locking list_empty: %d, thread_num: %d.\n",
+				__func__, list_empty(&p->ready_list), p->thread_num);
+
+		mutex_lock(&p->thread_lock);
+		if (!list_empty(&p->ready_list)) {
+			w = list_first_entry(&p->ready_list,
+					struct thread_pool_worker,
+					worker_entry);
+
+			dprintk("%s: deleting w: %p, thread_num: %d, list: %p [%p.%p].\n",
+					__func__, w, p->thread_num, &p->ready_list,
+					p->ready_list.prev, p->ready_list.next);
+
+			p->thread_num--;
+			list_del(&w->worker_entry);
+		}
+		mutex_unlock(&p->thread_lock);
+	}
+
+	if (w)
+		thread_pool_exit_worker(w);
+	dprintk("%s: deleted w: %p, thread_num: %d.\n",
+			__func__, w, p->thread_num);
+}
+
+/*
+ * Remove a worker with given ID.
+ */
+void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id)
+{
+	struct thread_pool_worker *w;
+	int found = 0;
+
+	mutex_lock(&p->thread_lock);
+	list_for_each_entry(w, &p->ready_list, worker_entry) {
+		if (w->id == id) {
+			found = 1;
+			p->thread_num--;
+			list_del(&w->worker_entry);
+			break;
+		}
+	}
+
+	if (!found) {
+		list_for_each_entry(w, &p->active_list, worker_entry) {
+			if (w->id == id) {
+				w->need_exit = 1;
+				break;
+			}
+		}
+	}
+	mutex_unlock(&p->thread_lock);
+
+	if (found)
+		thread_pool_exit_worker(w);
+}
+
+/*
+ * Add new worker thread with given parameters.
+ * If initialization callback fails, return error.
+ */
+int thread_pool_add_worker(struct thread_pool *p,
+		char *name,
+		unsigned int id,
+		void *(* init)(void *private),
+		void (* cleanup)(void *private),
+		void *private)
+{
+	struct thread_pool_worker *w;
+	int err = -ENOMEM;
+
+	w = kzalloc(sizeof(struct thread_pool_worker), GFP_KERNEL);
+	if (!w)
+		goto err_out_exit;
+
+	w->pool = p;
+	init_waitqueue_head(&w->wait);
+	w->cleanup = cleanup;
+	w->id = id;
+
+	w->thread = kthread_run(thread_pool_worker_func, w, "%s", name);
+	if (IS_ERR(w->thread)) {
+		err = PTR_ERR(w->thread);
+		goto err_out_free;
+	}
+
+	w->private = init(private);
+	if (IS_ERR(w->private)) {
+		err = PTR_ERR(w->private);
+		goto err_out_stop_thread;
+	}
+
+	mutex_lock(&p->thread_lock);
+	list_add_tail(&w->worker_entry, &p->ready_list);
+	p->thread_num++;
+	mutex_unlock(&p->thread_lock);
+
+	return 0;
+
+err_out_stop_thread:
+	kthread_stop(w->thread);
+err_out_free:
+	kfree(w);
+err_out_exit:
+	return err;
+}
+
+/*
+ * Destroy the whole pool.
+ */
+void thread_pool_destroy(struct thread_pool *p)
+{
+	while (p->thread_num) {
+		dprintk("%s: num: %d.\n", __func__, p->thread_num);
+		thread_pool_del_worker(p);
+	}
+
+	kfree(p);
+}
+
+/*
+ * Create a pool with given number of threads.
+ * They will have sequential IDs started from zero.
+ */
+struct thread_pool *thread_pool_create(int num, char *name,
+		void *(* init)(void *private),
+		void (* cleanup)(void *private),
+		void *private)
+{
+	struct thread_pool_worker *w, *tmp;
+	struct thread_pool *p;
+	int err = -ENOMEM;
+	int i;
+
+	p = kzalloc(sizeof(struct thread_pool), GFP_KERNEL);
+	if (!p)
+		goto err_out_exit;
+
+	init_waitqueue_head(&p->wait);
+	mutex_init(&p->thread_lock);
+	INIT_LIST_HEAD(&p->ready_list);
+	INIT_LIST_HEAD(&p->active_list);
+	p->thread_num = 0;
+
+	for (i=0; i<num; ++i) {
+		err = thread_pool_add_worker(p, name, i, init,
+				cleanup, private);
+		if (err)
+			goto err_out_free_all;
+	}
+
+	return p;
+
+err_out_free_all:
+	list_for_each_entry_safe(w, tmp, &p->ready_list, worker_entry) {
+		list_del(&w->worker_entry);
+		thread_pool_exit_worker(w);
+	}
+	kfree(p);
+err_out_exit:
+	return ERR_PTR(err);
+}
+
+/*
+ * Schedule execution of the action on a given thread,
+ * provided ID pointer has to match previously stored
+ * private data.
+ */
+int thread_pool_schedule_private(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout, void *id)
+{
+	struct thread_pool_worker *w, *tmp, *worker = NULL;
+	int err = 0;
+
+	while (!worker && !err) {
+		timeout = wait_event_interruptible_timeout(p->wait,
+				!list_empty(&p->ready_list),
+				timeout);
+
+		if (!timeout) {
+			err = -ETIMEDOUT;
+			break;
+		}
+
+		worker = NULL;
+		mutex_lock(&p->thread_lock);
+		list_for_each_entry_safe(w, tmp, &p->ready_list, worker_entry) {
+			if (id && id != w->private)
+				continue;
+
+			worker = w;
+
+			list_move_tail(&w->worker_entry, &p->active_list);
+
+			err = setup(w->private, data);
+			if (!err) {
+				w->schedule_data = data;
+				w->action = action;
+				w->has_data = 1;
+				wake_up(&w->wait);
+			} else {
+				list_move_tail(&w->worker_entry, &p->ready_list);
+			}
+
+			break;
+		}
+		mutex_unlock(&p->thread_lock);
+	}
+
+	return err;
+}
+
+/*
+ * Schedule execution on arbitrary thread from the pool.
+ */
+int thread_pool_schedule(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout)
+{
+	return thread_pool_schedule_private(p, setup,
+			action, data, timeout, NULL);
+}
diff --git a/drivers/block/dst/trans.c b/drivers/block/dst/trans.c
new file mode 100644
index 0000000..557d372
--- /dev/null
+++ b/drivers/block/dst/trans.c
@@ -0,0 +1,335 @@
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
+#include <linux/bio.h>
+#include <linux/dst.h>
+#include <linux/slab.h>
+#include <linux/mempool.h>
+
+/*
+ * Transaction memory pool size.
+ */
+static int dst_mempool_num = 32;
+module_param(dst_mempool_num, int, 0644);
+
+/*
+ * Transaction tree management.
+ */
+static inline int dst_trans_cmp(dst_gen_t gen, dst_gen_t new)
+{
+	if (gen < new)
+		return 1;
+	if (gen > new)
+		return -1;
+	return 0;
+}
+
+struct dst_trans *dst_trans_search(struct dst_node *node, dst_gen_t gen)
+{
+	struct rb_root *root = &node->trans_root;
+	struct rb_node *n = root->rb_node;
+	struct dst_trans *t, *ret = NULL;
+	int cmp;
+
+	while (n) {
+		t = rb_entry(n, struct dst_trans, trans_entry);
+
+		cmp = dst_trans_cmp(t->gen, gen);
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			ret = t;
+			break;
+		}
+	}
+
+	dprintk("%s: %s transaction: id: %llu.\n", __func__,
+			(ret)?"found":"not found", gen);
+
+	return ret;
+}
+
+static int dst_trans_insert(struct dst_trans *new)
+{
+	struct rb_root *root = &new->n->trans_root;
+	struct rb_node **n = &root->rb_node, *parent = NULL;
+	struct dst_trans *ret = NULL, *t;
+	int cmp;
+
+	while (*n) {
+		parent = *n;
+
+		t = rb_entry(parent, struct dst_trans, trans_entry);
+
+		cmp = dst_trans_cmp(t->gen, new->gen);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			ret = t;
+			break;
+		}
+	}
+
+	new->send_time = jiffies;
+	if (ret) {
+		printk("%s: exist: old: gen: %llu, bio: %llu/%u, send_time: %lu, "
+				"new: gen: %llu, bio: %llu/%u, send_time: %lu.\n",
+			__func__,
+			ret->gen, (u64)ret->bio->bi_sector,
+			ret->bio->bi_size, ret->send_time,
+			new->gen, (u64)new->bio->bi_sector,
+			new->bio->bi_size, new->send_time);
+		return -EEXIST;
+	}
+
+	rb_link_node(&new->trans_entry, parent, n);
+	rb_insert_color(&new->trans_entry, root);
+
+	dprintk("%s: inserted: gen: %llu, bio: %llu/%u, send_time: %lu.\n",
+		__func__, new->gen, (u64)new->bio->bi_sector,
+		new->bio->bi_size, new->send_time);
+
+	return 0;
+}
+
+int dst_trans_remove_nolock(struct dst_trans *t)
+{
+	struct dst_node *n = t->n;
+
+	if (t->trans_entry.rb_parent_color) {
+		rb_erase(&t->trans_entry, &n->trans_root);
+		t->trans_entry.rb_parent_color = 0;
+	}
+	return 0;
+}
+
+int dst_trans_remove(struct dst_trans *t)
+{
+	int ret;
+	struct dst_node *n = t->n;
+
+	mutex_lock(&n->trans_lock);
+	ret = dst_trans_remove_nolock(t);
+	mutex_unlock(&n->trans_lock);
+
+	return ret;
+}
+
+/*
+ * When transaction is completed and there are no more users,
+ * we complete appriate block IO request with given error status.
+ */
+void dst_trans_put(struct dst_trans *t)
+{
+	if (atomic_dec_and_test(&t->refcnt)) {
+		struct bio *bio = t->bio;
+
+		dprintk("%s: completed t: %p, gen: %llu, bio: %p.\n",
+				__func__, t, t->gen, bio);
+
+		bio_endio(bio, t->error);
+		bio_put(bio);
+
+		dst_node_put(t->n);
+		mempool_free(t, t->n->trans_pool);
+	}
+}
+
+/*
+ * Process given block IO request: allocate transaction, insert it into the tree
+ * and send/schedule crypto processing.
+ */
+int dst_process_bio(struct dst_node *n, struct bio *bio)
+{
+	struct dst_trans *t;
+	int err = -ENOMEM;
+
+	t = mempool_alloc(n->trans_pool, GFP_NOFS);
+	if (!t)
+		goto err_out_exit;
+
+	t->n = dst_node_get(n);
+	t->bio = bio;
+	t->error = 0;
+	t->retries = 0;
+	atomic_set(&t->refcnt, 1);
+	t->gen = atomic_long_inc_return(&n->gen);
+
+	t->enc = bio_data_dir(bio);
+	dst_bio_to_cmd(bio, &t->cmd, DST_IO, t->gen);
+
+	mutex_lock(&n->trans_lock);
+	err = dst_trans_insert(t);
+	mutex_unlock(&n->trans_lock);
+	if (err)
+		goto err_out_free;
+
+	dprintk("%s: gen: %llu, bio: %llu/%u, dir/enc: %d, need_crypto: %d.\n",
+			__func__, t->gen, (u64)bio->bi_sector,
+			bio->bi_size, t->enc, dst_need_crypto(n));
+
+	if (dst_need_crypto(n) && t->enc)
+		dst_trans_crypto(t);
+	else
+		dst_trans_send(t);
+
+	return 0;
+
+err_out_free:
+	dst_node_put(n);
+	mempool_free(t, n->trans_pool);
+err_out_exit:
+	bio_endio(bio, err);
+	bio_put(bio);
+	return err;
+}
+
+/*
+ * Scan for timeout/stale transactions.
+ * Each transaction is being resent multiple times before error completion.
+ */
+static void dst_trans_scan(struct work_struct *work)
+{
+	struct dst_node *n = container_of(work, struct dst_node, trans_work.work);
+	struct rb_node *rb_node;
+	struct dst_trans *t;
+	unsigned long timeout = n->trans_scan_timeout;
+	int num = 10 * n->trans_max_retries;
+
+	mutex_lock(&n->trans_lock);
+
+	for (rb_node = rb_first(&n->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct dst_trans, trans_entry);
+
+		if (timeout && time_after(t->send_time + timeout, jiffies)
+				&& t->retries == 0)
+			break;
+#if 0
+		dprintk("%s: t: %p, gen: %llu, n: %s, retries: %u, max: %u.\n",
+			__func__, t, t->gen, n->name,
+			t->retries, n->trans_max_retries);
+#endif
+		if (--num == 0)
+			break;
+
+		dst_trans_get(t);
+
+		rb_node = rb_next(rb_node);
+
+		if (timeout && (++t->retries < n->trans_max_retries)) {
+			dst_trans_send(t);
+		} else {
+			t->error = -ETIMEDOUT;
+			dst_trans_remove_nolock(t);
+			dst_trans_put(t);
+		}
+
+		dst_trans_put(t);
+	}
+
+	mutex_unlock(&n->trans_lock);
+
+	/*
+	 * If no timeout specified then system is in the middle of exiting process,
+	 * so no need to reschedule scanning process again.
+	 */
+	if (timeout) {
+		if (!num)
+			timeout = HZ;
+		schedule_delayed_work(&n->trans_work, timeout);
+	}
+}
+
+/*
+ * Flush all transactions and mark them as timed out.
+ * Destroy transaction pools.
+ */
+void dst_node_trans_exit(struct dst_node *n)
+{
+	struct dst_trans *t;
+	struct rb_node *rb_node;
+
+	if (!n->trans_cache)
+		return;
+
+	dprintk("%s: n: %p, cancelling the work.\n", __func__, n);
+	cancel_delayed_work_sync(&n->trans_work);
+	flush_scheduled_work();
+	dprintk("%s: n: %p, work has been cancelled.\n", __func__, n);
+
+	for (rb_node = rb_first(&n->trans_root); rb_node; ) {
+		t = rb_entry(rb_node, struct dst_trans, trans_entry);
+
+		dprintk("%s: t: %p, gen: %llu, n: %s.\n",
+			__func__, t, t->gen, n->name);
+
+		rb_node = rb_next(rb_node);
+
+		t->error = -ETIMEDOUT;
+		dst_trans_remove_nolock(t);
+		dst_trans_put(t);
+	}
+
+	mempool_destroy(n->trans_pool);
+	kmem_cache_destroy(n->trans_cache);
+}
+
+/*
+ * Initialize transaction storage for given node.
+ * Transaction stores not only control information,
+ * but also network command and crypto data (if needed)
+ * to reduce number of allocations. Thus transaction size
+ * differs from node to node.
+ */
+int dst_node_trans_init(struct dst_node *n, unsigned int size)
+{
+	/*
+	 * We need this, since node with given name can be dropped from the
+	 * hash table, but be still alive, so subsequent creation of the node
+	 * with the same name may collide with existing cache name.
+	 */
+
+	snprintf(n->cache_name, sizeof(n->cache_name), "%s-%p", n->name, n);
+
+	n->trans_cache = kmem_cache_create(n->cache_name,
+			size + n->crypto.crypto_attached_size,
+			0, 0, NULL);
+	if (!n->trans_cache)
+		goto err_out_exit;
+
+	n->trans_pool = mempool_create_slab_pool(dst_mempool_num, n->trans_cache);
+	if (!n->trans_pool)
+		goto err_out_cache_destroy;
+
+	mutex_init(&n->trans_lock);
+	n->trans_root = RB_ROOT;
+
+	INIT_DELAYED_WORK(&n->trans_work, dst_trans_scan);
+	schedule_delayed_work(&n->trans_work, n->trans_scan_timeout);
+
+	dprintk("%s: n: %p, size: %u, crypto: %u.\n",
+		__func__, n, size, n->crypto.crypto_attached_size);
+
+	return 0;
+
+err_out_cache_destroy:
+	kmem_cache_destroy(n->trans_cache);
+err_out_exit:
+	return -ENOMEM;
+}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 5c7f946..1980f08 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -39,8 +39,10 @@
 #define CN_IDX_V86D			0x4
 #define CN_VAL_V86D_UVESAFB		0x1
 #define CN_IDX_BB			0x5	/* BlackBoard, from the TSP GPL sampling framework */
+#define CN_DST_IDX			0x6
+#define CN_DST_VAL			0x1
 
-#define CN_NETLINK_USERS		6
+#define CN_NETLINK_USERS		7
 
 /*
  * Maximum connector's message size.
diff --git a/include/linux/dst.h b/include/linux/dst.h
new file mode 100644
index 0000000..5b276da
--- /dev/null
+++ b/include/linux/dst.h
@@ -0,0 +1,572 @@
+/*
+ * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
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
+#ifndef __DST_H
+#define __DST_H
+
+#include <linux/types.h>
+#include <linux/connector.h>
+
+#define DST_NAMELEN		32
+#define DST_NAME		"dst"
+
+enum {
+	/* Remove node with given id from storage */
+	DST_DEL_NODE	= 0,
+	/* Add remote node with given id to the storage */
+	DST_ADD_REMOTE,
+	/* Add local node with given id to the storage to be exported and used by remote peers */
+	DST_ADD_EXPORT,
+	/* Crypto initialization command (hash/cipher used to protect the connection) */
+	DST_CRYPTO,
+	/* Security attributes for given connection (permissions for example) */
+	DST_SECURITY,
+	/* Register given node in the block layer subsystem */
+	DST_START,
+	DST_CMD_MAX
+};
+
+struct dst_ctl
+{
+	/* Storage name */
+	char			name[DST_NAMELEN];
+	/* Command flags */
+	__u32			flags;
+	/* Command itself (see above) */
+	__u32			cmd;
+	/* Maximum number of pages per single request in this device */
+	__u32			max_pages;
+	/* Stale/error transaction scanning timeout in milliseconds */
+	__u32			trans_scan_timeout;
+	/* Maximum number of retry sends before completing transaction as broken */
+	__u32			trans_max_retries;
+	/* Storage size */
+	__u64			size;
+};
+
+/* Reply command carries completion status */
+struct dst_ctl_ack
+{
+	struct cn_msg		msg;
+	int			error;
+	int			unused[3];
+};
+
+/*
+ * Unfortunaltely socket address structure is not exported to userspace
+ * and is redefined there.
+ */
+#define SADDR_MAX_DATA	128
+
+struct saddr {
+	/* address family, AF_xxx	*/
+	unsigned short		sa_family;
+	/* 14 bytes of protocol address	*/
+	char			sa_data[SADDR_MAX_DATA];
+	/* Number of bytes used in sa_data */
+	unsigned short		sa_data_len;
+};
+
+/* Address structure */
+struct dst_network_ctl
+{
+	/* Socket type: datagram, stream...*/
+	unsigned int		type;
+	/* Let me guess, is it a Jupiter diameter? */
+	unsigned int		proto;
+	/* Peer's address */
+	struct saddr		addr;
+};
+
+struct dst_crypto_ctl
+{
+	/* Cipher and hash names */
+	char			cipher_algo[DST_NAMELEN];
+	char			hash_algo[DST_NAMELEN];
+
+	/* Key sizes. Can be zero for digest for example */
+	unsigned int		cipher_keysize, hash_keysize;
+	/* Alignment. Calculated by the DST itself. */
+	unsigned int		crypto_attached_size;
+	/* Number of threads to perform crypto operations */
+	int			thread_num;
+};
+
+/* Export security attributes have this bits checked in when client connects */
+#define DST_PERM_READ		(1<<0)
+#define DST_PERM_WRITE		(1<<1)
+
+/*
+ * Right now it is simple model, where each remote address
+ * is assigned to set of permissions it is allowed to perform.
+ * In real world block device does not know anything but
+ * reading and writing, so it should be more than enough.
+ */
+struct dst_secure_user
+{
+	unsigned int		permissions;
+	struct saddr		addr;
+};
+
+/*
+ * Export control command: device to export and network address to accept
+ * clients to work with given device
+ */
+struct dst_export_ctl
+{
+	char			device[DST_NAMELEN];
+	struct dst_network_ctl	ctl;
+};
+
+enum {
+	DST_CFG	= 1, 		/* Request remote configuration */
+	DST_IO,			/* IO command */
+	DST_IO_RESPONSE,	/* IO response */
+	DST_PING,		/* Keepalive message */
+	DST_NCMD_MAX,
+};
+
+struct dst_cmd
+{
+	/* Network command itself, see above */
+	__u32			cmd;
+	/*
+	 * Size of the attached data
+	 * (in most cases, for READ command it means how many bytes were requested)
+	 */
+	__u32			size;
+	/* Crypto size: number of attached bytes with digest/hmac */
+	__u32			csize;
+	/* Here we can carry secret data */
+	__u32			reserved;
+	/* Read/write bits, see how they are encoded in bio structure */
+	__u64			rw;
+	/* BIO flags */
+	__u64			flags;
+	/* Unique command id (like transaction ID) */
+	__u64			id;
+	/* Sector to start IO from */
+	__u64			sector;
+	/* Hash data is placed after this header */
+	__u8			hash[0];
+};
+
+/*
+ * Convert command to/from network byte order.
+ * We do not use hton*() functions, since there is
+ * no 64-bit implementation.
+ */
+static inline void dst_convert_cmd(struct dst_cmd *c)
+{
+	c->cmd = __cpu_to_be32(c->cmd);
+	c->csize = __cpu_to_be32(c->csize);
+	c->size = __cpu_to_be32(c->size);
+	c->sector = __cpu_to_be64(c->sector);
+	c->id = __cpu_to_be64(c->id);
+	c->flags = __cpu_to_be64(c->flags);
+	c->rw = __cpu_to_be64(c->rw);
+}
+
+/* Transaction id */
+typedef __u64 dst_gen_t;
+
+#ifdef __KERNEL__
+
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/device.h>
+#include <linux/mempool.h>
+#include <linux/net.h>
+#include <linux/poll.h>
+#include <linux/rbtree.h>
+
+#ifdef CONFIG_DST_DEBUG
+#define dprintk(f, a...) printk(KERN_NOTICE f, ##a)
+#else
+static inline void __attribute__ ((format (printf, 1, 2)))
+	dprintk(const char *fmt, ...) {}
+#endif
+
+struct dst_node;
+
+struct dst_trans
+{
+	/* DST node we are working with */
+	struct dst_node		*n;
+
+	/* Entry inside transaction tree */
+	struct rb_node		trans_entry;
+
+	/* Merlin kills this transaction when this memory cell equals zero */
+	atomic_t		refcnt;
+
+	/* How this transaction should be processed by crypto engine */
+	short			enc;
+	/* How many times this transaction was resent */
+	short			retries;
+	/* Completion status */
+	int			error;
+
+	/* When did we send it to the remote peer */
+	long			send_time;
+
+	/* My name is...
+	 * Well, computers does not speak, they have unique id instead */
+	dst_gen_t		gen;
+
+	/* Block IO we are working with */
+	struct bio		*bio;
+
+	/* Network command for above block IO request */
+	struct dst_cmd		cmd;
+};
+
+struct dst_crypto_engine
+{
+	/* What should we do with all block requests */
+	struct crypto_hash	*hash;
+	struct crypto_ablkcipher	*cipher;
+
+	/* Pool of pages used to encrypt data into before sending */
+	int			page_num;
+	struct page		**pages;
+
+	/* What to do with current request */
+	int			enc;
+	/* Who we are and where do we go */
+	struct scatterlist	*src, *dst;
+
+	/* Maximum timeout waiting for encryption to be completed */
+	long			timeout;
+	/* IV is a 64-bit sequential counter */
+	u64			iv;
+
+	/* Secret data */
+	void			*private;
+
+	/* Cached temporary data lives here */
+	int			size;
+	void			*data;
+};
+
+struct dst_state
+{
+	/* The main state protection */
+	struct mutex		state_lock;
+
+	/* Polling machinery for sockets */
+	wait_queue_t 		wait;
+	wait_queue_head_t 	*whead;
+	/* Most of events are being waited here */
+	wait_queue_head_t 	thread_wait;
+
+	/* Who owns this? */
+	struct dst_node		*node;
+
+	/* Network address for this state */
+	struct dst_network_ctl	ctl;
+
+	/* Permissions to work with: read-only or rw connection */
+	u32			permissions;
+
+	/* Called when we need to clean private data */
+	void			(* cleanup)(struct dst_state *st);
+
+	/* Used by the server: BIO completion queues BIOs here */
+	struct list_head	request_list;
+	spinlock_t		request_lock;
+
+	/* Guess what? No, it is not number of planets */
+	atomic_t		refcnt;
+
+	/* This flags is set when connection should be dropped */
+	int			need_exit;
+
+	/*
+	 * Socket to work with. Second pointer is used for
+	 * lockless check if socket was changed before performing
+	 * next action (like working with cached polling result)
+	 */
+	struct socket		*socket, *read_socket;
+
+	/* Cached preallocated data */
+	void			*data;
+	unsigned int		size;
+
+	/* Currently processed command */
+	struct dst_cmd		cmd;
+};
+
+struct dst_node
+{
+	struct list_head	node_entry;
+
+	/* Hi, my name is stored here */
+	char			name[DST_NAMELEN];
+	/* My cache name is stored here */
+	char			cache_name[DST_NAMELEN];
+
+	/* Block device attached to given node.
+	 * Only valid for exporting nodes */
+	struct block_device 	*bdev;
+	/* Network state machine for given peer */
+	struct dst_state	*state;
+
+	/* Block IO machinery */
+	struct request_queue	*queue;
+	struct gendisk		*disk;
+
+	/* Number of threads in processing pool */
+	int			thread_num;
+	/* Maximum number of pages in single IO */
+	int			max_pages;
+
+	/* I'm that big in bytes */
+	loff_t			size;
+
+	/* Sysfs bits use this */
+	struct device		device;
+
+	/*
+	 * Security attribute list.
+	 * Used only by exporting node currently.
+	 */
+	struct list_head	security_list;
+	struct mutex		security_lock;
+
+	/*
+	 * When this unerflows below zero, university collapses.
+	 * But this will not happen, since node will be freed,
+	 * when reference counter reaches zero.
+	 */
+	atomic_t		refcnt;
+
+	/* How precisely should I be started? */
+	int 			(*start)(struct dst_node *);
+
+	/* Crypto capabilities */
+	struct dst_crypto_ctl	crypto;
+	u8			*hash_key;
+	u8			*cipher_key;
+
+	/* Pool of processing thread */
+	struct thread_pool	*pool;
+
+	/* Transaction IDs live here */
+	atomic_long_t		gen;
+
+	/*
+	 * How frequently and how many times transaction
+	 * tree should be scanned to drop stale objects.
+	 */
+	long			trans_scan_timeout;
+	int			trans_max_retries;
+
+	/* Small gnomes live here */
+	struct rb_root		trans_root;
+	struct mutex		trans_lock;
+
+	/*
+	 * Transaction cache/memory pool.
+	 * It is big enough to contain not only transaction
+	 * itself, but additional crypto data (digest/hmac).
+	 */
+	struct kmem_cache	*trans_cache;
+	mempool_t		*trans_pool;
+
+	/* This entity scans transaction tree */
+	struct delayed_work 	trans_work;
+
+	wait_queue_head_t	wait;
+};
+
+/* Kernel representation of the security attribute */
+struct dst_secure
+{
+	struct list_head	sec_entry;
+	struct dst_secure_user	sec;
+};
+
+int dst_process_bio(struct dst_node *n, struct bio *bio);
+
+int dst_node_init_connected(struct dst_node *n, struct dst_network_ctl *r);
+int dst_node_init_listened(struct dst_node *n, struct dst_export_ctl *le);
+
+static inline struct dst_state *dst_state_get(struct dst_state *st)
+{
+	BUG_ON(atomic_read(&st->refcnt) == 0);
+	atomic_inc(&st->refcnt);
+	return st;
+}
+
+void dst_state_put(struct dst_state *st);
+
+struct dst_state *dst_state_alloc(struct dst_node *n);
+int dst_state_socket_create(struct dst_state *st);
+void dst_state_socket_release(struct dst_state *st);
+
+void dst_state_exit_connected(struct dst_state *st);
+
+int dst_state_schedule_receiver(struct dst_state *st);
+
+void dst_dump_addr(struct socket *sk, struct sockaddr *sa, char *str);
+
+static inline void dst_state_lock(struct dst_state *st)
+{
+	mutex_lock(&st->state_lock);
+}
+
+static inline void dst_state_unlock(struct dst_state *st)
+{
+	mutex_unlock(&st->state_lock);
+}
+
+void dst_poll_exit(struct dst_state *st);
+int dst_poll_init(struct dst_state *st);
+
+static inline unsigned int dst_state_poll(struct dst_state *st)
+{
+	unsigned int revents = POLLHUP | POLLERR;
+
+	dst_state_lock(st);
+	if (st->socket)
+		revents = st->socket->ops->poll(NULL, st->socket, NULL);
+	dst_state_unlock(st);
+
+	return revents;
+}
+
+static inline int dst_thread_setup(void *private, void *data)
+{
+	return 0;
+}
+
+void dst_node_put(struct dst_node *n);
+
+static inline struct dst_node *dst_node_get(struct dst_node *n)
+{
+	atomic_inc(&n->refcnt);
+	return n;
+}
+
+int dst_data_recv(struct dst_state *st, void *data, unsigned int size);
+int dst_recv_cdata(struct dst_state *st, void *cdata);
+int dst_data_send_header(struct socket *sock,
+		void *data, unsigned int size, int more);
+
+int dst_send_bio(struct dst_state *st, struct dst_cmd *cmd, struct bio *bio);
+
+int dst_process_io(struct dst_state *st);
+int dst_export_crypto(struct dst_node *n, struct bio *bio);
+int dst_export_send_bio(struct bio *bio);
+int dst_start_export(struct dst_node *n);
+
+int __init dst_export_init(void);
+void dst_export_exit(void);
+
+/* Private structure for export block IO requests */
+struct dst_export_priv
+{
+	struct list_head		request_entry;
+	struct dst_state		*state;
+	struct bio			*bio;
+	struct dst_cmd			cmd;
+};
+
+static inline void dst_trans_get(struct dst_trans *t)
+{
+	atomic_inc(&t->refcnt);
+}
+
+struct dst_trans *dst_trans_search(struct dst_node *node, dst_gen_t gen);
+int dst_trans_remove(struct dst_trans *t);
+int dst_trans_remove_nolock(struct dst_trans *t);
+void dst_trans_put(struct dst_trans *t);
+
+/*
+ * Convert bio into network command.
+ */
+static inline void dst_bio_to_cmd(struct bio *bio, struct dst_cmd *cmd,
+		u32 command, u64 id)
+{
+	cmd->cmd = command;
+	cmd->flags = (bio->bi_flags << BIO_POOL_BITS) >> BIO_POOL_BITS;
+	cmd->rw = bio->bi_rw;
+	cmd->size = bio->bi_size;
+	cmd->csize = 0;
+	cmd->id = id;
+	cmd->sector = bio->bi_sector;
+};
+
+int dst_trans_send(struct dst_trans *t);
+int dst_trans_crypto(struct dst_trans *t);
+
+int dst_node_crypto_init(struct dst_node *n, struct dst_crypto_ctl *ctl);
+void dst_node_crypto_exit(struct dst_node *n);
+
+static inline int dst_need_crypto(struct dst_node *n)
+{
+	struct dst_crypto_ctl *c = &n->crypto;
+	/*
+	 * Logical OR is appropriate here, but boolean one produces
+	 * more optimal code, so it is used instead.
+	 */
+	return (c->hash_algo[0] | c->cipher_algo[0]);
+}
+
+int dst_node_trans_init(struct dst_node *n, unsigned int size);
+void dst_node_trans_exit(struct dst_node *n);
+
+/*
+ * Pool of threads.
+ * Ready list contains threads currently free to be used,
+ * active one contains threads with some work scheduled for them.
+ * Caller can wait in given queue when thread is ready.
+ */
+struct thread_pool
+{
+	int			thread_num;
+	struct mutex		thread_lock;
+	struct list_head	ready_list, active_list;
+
+	wait_queue_head_t	wait;
+};
+
+void thread_pool_del_worker(struct thread_pool *p);
+void thread_pool_del_worker_id(struct thread_pool *p, unsigned int id);
+int thread_pool_add_worker(struct thread_pool *p,
+		char *name,
+		unsigned int id,
+		void *(* init)(void *data),
+		void (* cleanup)(void *data),
+		void *data);
+
+void thread_pool_destroy(struct thread_pool *p);
+struct thread_pool *thread_pool_create(int num, char *name,
+		void *(* init)(void *data),
+		void (* cleanup)(void *data),
+		void *data);
+
+int thread_pool_schedule(struct thread_pool *p,
+		int (* setup)(void *stored_private, void *setup_data),
+		int (* action)(void *stored_private, void *setup_data),
+		void *setup_data, long timeout);
+int thread_pool_schedule_private(struct thread_pool *p,
+		int (* setup)(void *private, void *data),
+		int (* action)(void *private, void *data),
+		void *data, long timeout, void *id);
+
+#endif /* __KERNEL__ */
+#endif /* __DST_H */

-- 
	Evgeniy Polyakov
