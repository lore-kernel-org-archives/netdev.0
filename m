From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [2/3] Distributed storage. Network state machine.
Date: Thu, 18 Oct 2007 23:17:55 +0400
Message-ID: <20071018191755.GC848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/block/dst/kst.c b/drivers/block/dst/kst.c
new file mode 100644
index 0000000..b0608c9
--- /dev/null
+++ b/drivers/block/dst/kst.c
@@ -0,0 +1,1606 @@
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
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+#include <linux/kthread.h>
+#include <linux/net.h>
+#include <linux/in.h>
+#include <linux/poll.h>
+#include <linux/bio.h>
+#include <linux/dst.h>
+
+#include <net/sock.h>
+
+struct kst_poll_helper
+{
+	poll_table 		pt;
+	struct kst_state	*st;
+};
+
+static LIST_HEAD(kst_worker_list);
+static DEFINE_MUTEX(kst_worker_mutex);
+
+/*
+ * This function creates bound socket for local export node.
+ */
+static int kst_sock_create(struct kst_state *st, struct saddr *addr,
+		int type, int proto, int backlog)
+{
+	int err;
+
+	err = sock_create(addr->sa_family, type, proto, &st->socket);
+	if (err)
+		goto err_out_exit;
+
+	err = st->socket->ops->bind(st->socket, (struct sockaddr *)addr,
+			addr->sa_data_len);
+
+	err = st->socket->ops->listen(st->socket, backlog);
+	if (err)
+		goto err_out_release;
+
+	st->socket->sk->sk_allocation = GFP_NOIO;
+
+	return 0;
+
+err_out_release:
+	sock_release(st->socket);
+err_out_exit:
+	return err;
+}
+
+static void kst_sock_release(struct kst_state *st)
+{
+	if (st->socket) {
+		sock_release(st->socket);
+		st->socket = NULL;
+	}
+}
+
+void kst_wake(struct kst_state *st)
+{
+	if (st) {
+		struct kst_worker *w = st->node->w;
+		unsigned long flags;
+
+		spin_lock_irqsave(&w->ready_lock, flags);
+		if (list_empty(&st->ready_entry))
+			list_add_tail(&st->ready_entry, &w->ready_list);
+		spin_unlock_irqrestore(&w->ready_lock, flags);
+
+		wake_up(&w->wait);
+	}
+}
+EXPORT_SYMBOL_GPL(kst_wake);
+
+/*
+ * Polling machinery.
+ */
+static int kst_state_wake_callback(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct kst_state *st = container_of(wait, struct kst_state, wait);
+	kst_wake(st);
+	return 1;
+}
+
+static void kst_queue_func(struct file *file, wait_queue_head_t *whead,
+				 poll_table *pt)
+{
+	struct kst_state *st = container_of(pt, struct kst_poll_helper, pt)->st;
+
+	st->whead = whead;
+	init_waitqueue_func_entry(&st->wait, kst_state_wake_callback);
+	add_wait_queue(whead, &st->wait);
+}
+
+static void kst_poll_exit(struct kst_state *st)
+{
+	if (st->whead) {
+		remove_wait_queue(st->whead, &st->wait);
+		st->whead = NULL;
+	}
+}
+
+/*
+ * This function removes request from state tree and ordering list.
+ */
+void kst_del_req(struct dst_request *req)
+{
+	struct kst_state *st = req->state;
+
+	rb_erase(&req->request_entry, &st->request_root);
+	RB_CLEAR_NODE(&req->request_entry);
+	list_del_init(&req->request_list_entry);
+}
+EXPORT_SYMBOL_GPL(kst_del_req);
+
+static struct dst_request *kst_req_first(struct kst_state *st)
+{
+	struct dst_request *req = NULL;
+
+	if (!list_empty(&st->request_list))
+		req = list_entry(st->request_list.next, struct dst_request,
+				request_list_entry);
+	return req;
+}
+
+/*
+ * This function dequeues first request from the queue and tree.
+ */
+static struct dst_request *kst_dequeue_req(struct kst_state *st)
+{
+	struct dst_request *req;
+
+	mutex_lock(&st->request_lock);
+	req = kst_req_first(st);
+	if (req)
+		kst_del_req(req);
+	mutex_unlock(&st->request_lock);
+	return req;
+}
+
+static inline int dst_compare_request_id(struct dst_request *old,
+		struct dst_request *new)
+{
+	int cmd = 0;
+
+	if (old->start + to_sector(old->orig_size) <= new->start)
+		cmd = 1;
+	if (old->start >= new->start + to_sector(new->orig_size))
+		cmd = -1;
+
+	dprintk("%s: old: op: %lu, start: %llu, size: %llu, off: %u, "
+		"new: op: %lu, start: %llu, size: %llu, off: %u, cmp: %d.\n",
+		__func__, bio_rw(old->bio), old->start, old->orig_size,
+		old->offset,
+		bio_rw(new->bio), new->start, new->orig_size,
+		new->offset, cmd);
+
+	return cmd;
+}
+
+/*
+ * This function enqueues request into tree, indexed by start of the request,
+ * and also puts request into ordered queue.
+ */
+int kst_enqueue_req(struct kst_state *st, struct dst_request *req)
+{
+	struct rb_node **n = &st->request_root.rb_node, *parent = NULL;
+	struct dst_request *old = NULL;
+	int cmp, err = 0;
+
+	while (*n) {
+		parent = *n;
+		old = rb_entry(parent, struct dst_request, request_entry);
+
+		cmp = dst_compare_request_id(old, req);
+		if (cmp < 0)
+			n = &parent->rb_left;
+		else if (cmp > 0)
+			n = &parent->rb_right;
+		else {
+			printk("%s: [%c] old_req: %p, start: %llu, "
+					"size: %llu.\n",
+					__func__, 
+					(bio_rw(old->bio) == WRITE)?'W':'R',
+					old, old->start, old->orig_size);
+			err = -EEXIST;
+			break;
+		}
+	}
+
+	if (!err) {
+		rb_link_node(&req->request_entry, parent, n);
+		rb_insert_color(&req->request_entry, &st->request_root);
+	}
+
+	if (req->size != req->orig_size)
+		list_add(&req->request_list_entry, &st->request_list);
+	else
+		list_add_tail(&req->request_list_entry, &st->request_list);
+	return err;
+}
+EXPORT_SYMBOL_GPL(kst_enqueue_req);
+
+/*
+ * BIOs for local exporting node are freed via this function.
+ */
+static void kst_export_put_bio(struct bio *bio)
+{
+	int i;
+	struct bio_vec *bv;
+
+	dprintk("%s: bio: %p, size: %u, idx: %d, num: %d.\n",
+			__func__, bio, bio->bi_size, bio->bi_idx,
+			bio->bi_vcnt);
+
+	bio_for_each_segment(bv, bio, i)
+		__free_page(bv->bv_page);
+	bio_put(bio);
+}
+
+/*
+ * This is a generic request completion function for requests,
+ * queued for async processing.
+ * If it is local export node, state machine is different,
+ * see details below.
+ */
+void kst_complete_req(struct dst_request *req, int err)
+{
+	dprintk("%s: bio: %p, req: %p, size: %llu, orig_size: %llu, "
+			"bi_size: %u, err: %d, flags: %u.\n",
+			__func__, req->bio, req, req->size, req->orig_size,
+			req->bio->bi_size, err, req->flags);
+
+	if (req->flags & DST_REQ_EXPORT) {
+		if (req->flags & DST_REQ_EXPORT_WRITE) {
+			req->bio->bi_rw = WRITE;
+			generic_make_request(req->bio);
+		} else
+			kst_export_put_bio(req->bio);
+	} else {
+		req->bio_endio(req, err);
+	}
+	dst_free_request(req);
+}
+EXPORT_SYMBOL_GPL(kst_complete_req);
+
+static void kst_flush_requests(struct kst_state *st)
+{
+	struct dst_request *req;
+
+	while ((req = kst_dequeue_req(st)) != NULL)
+		kst_complete_req(req, -EIO);
+}
+
+static int kst_poll_init(struct kst_state *st)
+{
+	struct kst_poll_helper ph;
+
+	ph.st = st;
+	init_poll_funcptr(&ph.pt, &kst_queue_func);
+
+	st->socket->ops->poll(NULL, st->socket, &ph.pt);
+	return 0;
+}
+
+/*
+ * Main state creation function.
+ * It creates new state according to given operations
+ * and links it into worker structure and node.
+ */
+static struct kst_state *kst_state_init(struct dst_node *node,
+		unsigned int permissions,
+		struct kst_state_ops *ops, void *data)
+{
+	struct kst_state *st;
+	int err;
+
+	st = kzalloc(sizeof(struct kst_state), GFP_KERNEL);
+	if (!st)
+		return ERR_PTR(-ENOMEM);
+
+	st->permissions = permissions;
+	st->node = node;
+	st->ops = ops;
+	INIT_LIST_HEAD(&st->ready_entry);
+	INIT_LIST_HEAD(&st->entry);
+	st->request_root.rb_node = NULL;
+	INIT_LIST_HEAD(&st->request_list);
+	mutex_init(&st->request_lock);
+
+	err = st->ops->init(st, data);
+	if (err)
+		goto err_out_free;
+	mutex_lock(&node->w->state_mutex);
+	list_add_tail(&st->entry, &node->w->state_list);
+	mutex_unlock(&node->w->state_mutex);
+
+	kst_wake(st);
+
+	return st;
+
+err_out_free:
+	kfree(st);
+	return ERR_PTR(err);
+}
+
+/*
+ * This function is called when node is removed,
+ * or when state is destroyed for connected to local exporting
+ * node client.
+ */
+void kst_state_exit(struct kst_state *st)
+{
+	struct kst_worker *w = st->node->w;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+
+	mutex_lock(&w->state_mutex);
+	list_del_init(&st->entry);
+	mutex_unlock(&w->state_mutex);
+
+	st->ops->exit(st);
+
+	st->node->state = NULL;
+
+	kfree(st);
+}
+
+static int kst_error(struct kst_state *st, int err)
+{
+	if ((err == -ECONNRESET || err == -EPIPE) && st->ops->recovery(st, err))
+		err = st->ops->recovery(st, err);
+
+	return st->node->st->alg->ops->error(st, err);
+}
+
+/*
+ * This is main state processing function.
+ * It tries to complete request and invoke appropriate
+ * callbacks in case of errors or successfull operation finish.
+ */
+static int kst_thread_process_state(struct kst_state *st)
+{
+	int err, empty;
+	unsigned int revents;
+	struct dst_request *req, *tmp;
+
+	mutex_lock(&st->request_lock);
+	if (st->ops->ready) {
+		err = st->ops->ready(st);
+		if (err) {
+			mutex_unlock(&st->request_lock);
+			if (err < 0)
+				kst_state_exit(st);
+			return err;
+		}
+	}
+
+	err = 0;
+	empty = 1;
+	req = NULL;
+	list_for_each_entry_safe(req, tmp, &st->request_list,
+			request_list_entry) {
+		empty = 0;
+		revents = st->socket->ops->poll(st->socket->file,
+				st->socket, NULL);
+		dprintk("\n%s: st: %p, revents: %x.\n", __func__, st, revents);
+		if (!revents)
+			break;
+		err = req->callback(req, revents);
+		dprintk("%s: callback returned, st: %p, err: %d.\n",
+				__func__, st, err);
+		if (err)
+			break;
+	}
+	mutex_unlock(&st->request_lock);
+
+	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
+	if (err < 0) {
+		err = kst_error(st, err);
+		if (err && (st != st->node->state)) {
+			dprintk("%s: err: %d, st: %p, node->state: %p.\n",
+					__func__, err, st, st->node->state);
+			/*
+			 * Accepted client has state not related to storage
+			 * node, so it must be freed explicitely.
+			 */
+
+			kst_state_exit(st);
+			return err;
+		}
+
+		kst_wake(st);
+	}
+
+	if (list_empty(&st->request_list) && !empty)
+		kst_wake(st);
+
+	return err;
+}
+
+/*
+ * Main worker thread - one per storage.
+ */
+static int kst_thread_func(void *data)
+{
+	struct kst_worker *w = data;
+	struct kst_state *st;
+	unsigned long flags;
+	int err = 0;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible_timeout(w->wait,
+				!list_empty(&w->ready_list) ||
+				kthread_should_stop(),
+				HZ);
+
+		st = NULL;
+		spin_lock_irqsave(&w->ready_lock, flags);
+		if (!list_empty(&w->ready_list)) {
+			st = list_entry(w->ready_list.next, struct kst_state,
+					ready_entry);
+			list_del_init(&st->ready_entry);
+		}
+		spin_unlock_irqrestore(&w->ready_lock, flags);
+
+		if (!st)
+			continue;
+
+		err = kst_thread_process_state(st);
+	}
+
+	return err;
+}
+
+/*
+ * Worker initialization - this object will host andprocess all states,
+ * which in turn host requests for remote targets.
+ */
+struct kst_worker *kst_worker_init(int id)
+{
+	struct kst_worker *w;
+	int err;
+
+	w = kzalloc(sizeof(struct kst_worker), GFP_KERNEL);
+	if (!w)
+		return ERR_PTR(-ENOMEM);
+
+	w->id = id;
+	init_waitqueue_head(&w->wait);
+	spin_lock_init(&w->ready_lock);
+	mutex_init(&w->state_mutex);
+
+	INIT_LIST_HEAD(&w->ready_list);
+	INIT_LIST_HEAD(&w->state_list);
+
+	w->req_pool = mempool_create_slab_pool(256, dst_request_cache);
+	if (!w->req_pool) {
+		err = -ENOMEM;
+		goto err_out_free;
+	}
+
+	w->thread = kthread_run(&kst_thread_func, w, "kst%d", w->id);
+	if (IS_ERR(w->thread)) {
+		err = PTR_ERR(w->thread);
+		goto err_out_destroy;
+	}
+
+	mutex_lock(&kst_worker_mutex);
+	list_add_tail(&w->entry, &kst_worker_list);
+	mutex_unlock(&kst_worker_mutex);
+
+	return w;
+
+err_out_destroy:
+	mempool_destroy(w->req_pool);
+err_out_free:
+	kfree(w);
+	return ERR_PTR(err);
+}
+
+void kst_worker_exit(struct kst_worker *w)
+{
+	struct kst_state *st, *n;
+
+	mutex_lock(&kst_worker_mutex);
+	list_del(&w->entry);
+	mutex_unlock(&kst_worker_mutex);
+
+	kthread_stop(w->thread);
+
+	list_for_each_entry_safe(st, n, &w->state_list, entry) {
+		kst_state_exit(st);
+	}
+
+	mempool_destroy(w->req_pool);
+	kfree(w);
+}
+
+/*
+ * Common state exit callback.
+ * Removes itself from worker's list of states,
+ * releases socket and flushes all requests.
+ */
+static void kst_common_exit(struct kst_state *st)
+{
+	unsigned long flags;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+	kst_poll_exit(st);
+
+	spin_lock_irqsave(&st->node->w->ready_lock, flags);
+	list_del_init(&st->ready_entry);
+	spin_unlock_irqrestore(&st->node->w->ready_lock, flags);
+
+	kst_sock_release(st);
+	kst_flush_requests(st);
+}
+
+/*
+ * Listen socket contains security attributes in request_list,
+ * so it can not be flushed via usual way.
+ */
+static void kst_listen_flush(struct kst_state *st)
+{
+	struct dst_secure *s, *tmp;
+
+	list_for_each_entry_safe(s, tmp, &st->request_list, sec_entry) {
+		list_del(&s->sec_entry);
+		kfree(s);
+	}
+}
+
+static void kst_listen_exit(struct kst_state *st)
+{
+	kst_listen_flush(st);
+	kst_common_exit(st);
+}
+
+/*
+ * Header sending function - may block.
+ */
+static int kst_data_send_header(struct kst_state *st,
+		struct dst_remote_request *r)
+{
+	struct msghdr msg;
+	struct kvec iov;
+
+	iov.iov_base = r;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | MSG_NOSIGNAL;
+
+	return kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+}
+
+/*
+ * BIO vector receiving function - does not block, but may sleep because
+ * of scheduling policy.
+ */
+static int kst_data_recv_bio_vec(struct kst_state *st, struct bio_vec *bv,
+		unsigned int offset, unsigned int size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	void *kaddr;
+	int err;
+
+	kaddr = kmap(bv->bv_page);
+
+	iov.iov_base = kaddr + bv->bv_offset + offset;
+	iov.iov_len = size;
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1, iov.iov_len,
+			msg.msg_flags);
+	kunmap(bv->bv_page);
+
+	return err;
+}
+
+/*
+ * BIO vector sending function - does not block, but may sleep because
+ * of scheduling policy.
+ */
+static int kst_data_send_bio_vec(struct kst_state *st, struct bio_vec *bv,
+		unsigned int offset, unsigned int size)
+{
+	return kernel_sendpage(st->socket, bv->bv_page,
+			bv->bv_offset + offset, size,
+			MSG_DONTWAIT | MSG_NOSIGNAL);
+}
+
+typedef int (*kst_data_process_bio_vec_t)(struct kst_state *st,
+		struct bio_vec *bv, unsigned int offset, unsigned int size);
+
+/*
+ * @req: processing request.
+ * Contains BIO and all related to its processing info.
+ *
+ * This function sends or receives requested number of pages from given BIO.
+ *
+ * In case of errors negative return value is returned and @size,
+ * @index and @off are set to the:
+ * - number of bytes not yet processed (i.e. the rest of the bytes to be
+ *   processed).
+ * - index of the last bio_vec started to be processed (header sent).
+ * - offset of the first byte to be processed in the bio_vec.
+ *
+ * If there are no errors, zero is returned.
+ * -EAGAIN is not an error and is transformed into zero return value,
+ * called must check if @size is zero, in that case whole BIO is processed
+ * and thus req->bio_endio() can be called, othervise new request must be allocated
+ * to be processed later.
+ */
+static int kst_data_process_bio(struct dst_request *req)
+{
+	int err = -ENOSPC, partial = (req->size != req->orig_size);
+	struct dst_remote_request r;
+	kst_data_process_bio_vec_t func;
+	unsigned int cur_size;
+
+	r.flags = cpu_to_be32(((unsigned long)req->bio) & 0xffffffff);
+
+	if (bio_rw(req->bio) == WRITE) {
+		r.cmd = cpu_to_be32(DST_WRITE);
+		func = kst_data_send_bio_vec;
+	} else {
+		r.cmd = cpu_to_be32(DST_READ);
+		func = kst_data_recv_bio_vec;
+	}
+
+	dprintk("%s: start: [%c], start: %llu, idx: %d, num: %d, "
+			"size: %llu, offset: %u.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size, req->offset);
+
+	while (req->idx < req->num) {
+		struct bio_vec *bv = bio_iovec_idx(req->bio, req->idx);
+
+		cur_size = min_t(u64, bv->bv_len - req->offset, req->size);
+
+		if (cur_size == 0) {
+			printk("%s: %d/%d: start: %llu, "
+				"bv_offset: %u, bv_len: %u, "
+				"req_offset: %u, req_size: %llu, "
+				"req: %p, bio: %p, err: %d.\n",
+				__func__, req->idx, req->num, req->start, 
+				bv->bv_offset, bv->bv_len,
+				req->offset, req->size,
+				req, req->bio, err);
+			BUG();
+		}
+
+		if (!(req->flags & DST_REQ_HEADER_SENT)) {
+			r.sector = cpu_to_be64(req->start);
+			r.offset = cpu_to_be32(bv->bv_offset + req->offset);
+			r.size = cpu_to_be32(cur_size);
+
+			err = kst_data_send_header(req->state, &r);
+			if (err != sizeof(struct dst_remote_request)) {
+				dprintk("%s: %d/%d: header: start: %llu, "
+					"bv_offset: %u, bv_len: %u, "
+					"a offset: %u, offset: %u, "
+					"cur_size: %u, err: %d.\n",
+					__func__, req->idx, req->num,
+					req->start, bv->bv_offset, bv->bv_len,
+					bv->bv_offset + req->offset,
+					req->offset, cur_size, err);
+				if (err >= 0)
+					err = -EINVAL;
+				break;
+			}
+
+			req->flags |= DST_REQ_HEADER_SENT;
+		}
+
+		err = func(req->state, bv, req->offset, cur_size);
+		if (err <= 0)
+			break;
+
+		req->offset += err;
+		req->size -= err;
+
+		if (req->offset != bv->bv_len) {
+			dprintk("%s: %d/%d: this: start: %llu, bv_offset: %u, "
+				"bv_len: %u, a offset: %u, offset: %u, "
+				"cur_size: %u, err: %d.\n",
+				__func__, req->idx, req->num, req->start,
+				bv->bv_offset, bv->bv_len,
+				bv->bv_offset + req->offset,
+				req->offset, cur_size, err);
+			err = -EAGAIN;
+			break;
+		}
+		req->offset = 0;
+		req->idx++;
+		req->flags &= ~DST_REQ_HEADER_SENT;
+
+		req->start += to_sector(bv->bv_len);
+	}
+
+	if (err <= 0 && err != -EAGAIN) {
+		if (err == 0)
+			err = -ECONNRESET;
+	} else
+		err = 0;
+
+	if (req->size) {
+		req->state->flags |= KST_FLAG_PARTIAL;
+	} else if (partial) {
+		req->state->flags &= ~KST_FLAG_PARTIAL;
+	}
+
+	if (err < 0 || (req->idx == req->num && req->size)) {
+		dprintk("%s: return: idx: %d, num: %d, offset: %u, "
+				"size: %llu, err: %d.\n",
+			__func__, req->idx, req->num, req->offset,
+			req->size, err);
+	}
+	dprintk("%s: end: start: %llu, idx: %d, num: %d, "
+			"size: %llu, offset: %u.\n",
+		__func__, req->start, req->idx, req->num,
+		req->size, req->offset);
+
+	return err;
+}
+
+void kst_bio_endio(struct dst_request *req, int err)
+{
+	if (err)
+		printk("%s: freeing bio: %p, bi_size: %u, "
+			"orig_size: %llu, req: %p.\n",
+		__func__, req->bio, req->bio->bi_size, req->orig_size, req);
+	bio_endio(req->bio, req->orig_size, err);
+}
+EXPORT_SYMBOL_GPL(kst_bio_endio);
+
+/*
+ * This callback is invoked by worker thread to process given request.
+ */
+int kst_data_callback(struct dst_request *req, unsigned int revents)
+{
+	int err;
+
+	dprintk("%s: req: %p, num: %d, idx: %d, bio: %p, "
+			"revents: %x, flags: %x.\n",
+			__func__, req, req->num, req->idx, req->bio,
+			revents, req->flags);
+
+	if (req->flags & DST_REQ_EXPORT_READ)
+		return 1;
+
+	err = kst_data_process_bio(req);
+	if (err < 0)
+		goto err_out;
+
+	if (!req->size) {
+		dprintk("%s: complete: req: %p, bio: %p.\n",
+				__func__, req, req->bio);
+		kst_del_req(req);
+		kst_complete_req(req, 0);
+		return 0;
+	}
+
+	if (revents & (POLLERR | POLLHUP | POLLRDHUP)) {
+		err = -EPIPE;
+		goto err_out;
+	}
+
+	return 1;
+
+err_out:
+	return err;
+}
+EXPORT_SYMBOL_GPL(kst_data_callback);
+
+#define KST_CONG_COMPLETED		(0)
+#define KST_CONG_NOT_FOUND		(1)
+#define KST_CONG_QUEUE			(-1)
+
+/*
+ * kst_congestion - checks for data congestion, i.e. the case, when given
+ * 	block request crosses an area of the another block request which
+ * 	is not yet sent to the remote node.
+ *
+ * @req: dst request containing block io related information.
+ *
+ * Return value:
+ * %KST_CONG_COMPLETED  - congestion was found and processed,
+ * 	bio must be ended, request is completed.
+ * %KST_CONG_NOT_FOUND  - no congestion found,
+ * 	request must be processed as usual
+ * %KST_CONG_QUEUE - congestion has been found, but bio is not completed,
+ * 	new request must be allocated and processed.
+ */
+static int kst_congestion(struct dst_request *req)
+{
+	int cmp, i;
+	struct kst_state *st = req->state;
+	struct rb_node *n = st->request_root.rb_node;
+	struct dst_request *old = NULL, *dst_req, *src_req;
+
+	while (n) {
+		src_req = rb_entry(n, struct dst_request, request_entry);
+		cmp = dst_compare_request_id(src_req, req);
+
+		if (cmp < 0)
+			n = n->rb_left;
+		else if (cmp > 0)
+			n = n->rb_right;
+		else {
+			old = src_req;
+			break;
+		}
+	}
+
+	if (likely(!old))
+		return KST_CONG_NOT_FOUND;
+
+	dprintk("%s: old: op: %lu, start: %llu, size: %llu, off: %u, "
+			"new: op: %lu, start: %llu, size: %llu, off: %u.\n",
+		__func__, bio_rw(old->bio), old->start, old->orig_size,
+		old->offset,
+		bio_rw(req->bio), req->start, req->orig_size, req->offset);
+
+	if ((bio_rw(old->bio) != WRITE) && (bio_rw(req->bio) != WRITE)) {
+		return KST_CONG_QUEUE;
+	}
+
+	if (unlikely(req->offset != old->offset))
+		return KST_CONG_QUEUE;
+
+	src_req = old;
+	dst_req = req;
+	if (bio_rw(req->bio) == WRITE) {
+		dst_req = old;
+		src_req = req;
+	}
+
+	/* Actually we could partially complete new request by copying
+	 * part of the first one, but not now, consider this as a
+	 * (low-priority) todo item.
+	 */
+	if (src_req->start + src_req->orig_size <
+			dst_req->start + dst_req->orig_size)
+		return KST_CONG_QUEUE;
+
+	/*
+	 * So, only process if new request is differnt from old one,
+	 * or subsequent write, i.e.:
+	 * - not completed write and request to read
+	 * - not completed read and request to write
+	 * - not completed write and request to (over)write
+	 */
+	for (i = old->idx; i < old->num; ++i) {
+		struct bio_vec *bv_src, *bv_dst;
+		void *src, *dst;
+		u64 len;
+
+		bv_src = bio_iovec_idx(src_req->bio, i);
+		bv_dst = bio_iovec_idx(dst_req->bio, i);
+
+		if (unlikely(bv_dst->bv_offset != bv_src->bv_offset))
+			return KST_CONG_QUEUE;
+
+		if (unlikely(bv_dst->bv_len != bv_src->bv_len))
+			return KST_CONG_QUEUE;
+
+		src = kmap_atomic(bv_src->bv_page, KM_USER0);
+		dst = kmap_atomic(bv_dst->bv_page, KM_USER1);
+
+		len = min_t(u64, bv_dst->bv_len, dst_req->size);
+
+		memcpy(dst + bv_dst->bv_offset, src + bv_src->bv_offset, len);
+
+		kunmap_atomic(src, KM_USER0);
+		kunmap_atomic(dst, KM_USER1);
+
+		dst_req->idx++;
+		dst_req->size -= len;
+		dst_req->offset = 0;
+		dst_req->start += to_sector(len);
+
+		if (!dst_req->size)
+			break;
+	}
+
+	if (req == dst_req)
+		return KST_CONG_COMPLETED;
+
+	kst_del_req(dst_req);
+	kst_complete_req(dst_req, 0);
+
+	return KST_CONG_NOT_FOUND;
+}
+
+struct dst_request *dst_clone_request(struct dst_request *req, mempool_t *pool)
+{
+	struct dst_request *new_req;
+
+	new_req = mempool_alloc(pool, GFP_NOIO);
+	if (!new_req)
+		return NULL;
+
+	memset(new_req, 0, sizeof(struct dst_request));
+
+	dprintk("%s: req: %p, new_req: %p, bio: %p.\n",
+			__func__, req, new_req, req->bio);
+
+	RB_CLEAR_NODE(&new_req->request_entry);
+
+	if (req) {
+		new_req->bio = req->bio;
+		new_req->state = req->state;
+		new_req->node = req->node;
+		new_req->idx = req->idx;
+		new_req->num = req->num;
+		new_req->size = req->size;
+		new_req->orig_size = req->orig_size;
+		new_req->offset = req->offset;
+		new_req->start = req->start;
+		new_req->flags = req->flags;
+		new_req->bio_endio = req->bio_endio;
+		new_req->priv = req->priv;
+	}
+
+	return new_req;
+}
+EXPORT_SYMBOL_GPL(dst_clone_request);
+
+void dst_free_request(struct dst_request *req)
+{
+	dprintk("%s: free req: %p, pool: %p, bio: %p, state: %p, node: %p.\n",
+			__func__, req, req->node->w->req_pool,
+			req->bio, req->state, req->node);
+	mempool_free(req, req->node->w->req_pool);
+}
+EXPORT_SYMBOL_GPL(dst_free_request);
+
+/*
+ * This is main data processing function, eventually invoked from block layer.
+ * It tries to complte request, but if it is about to block, it allocates
+ * new request and queues it to main worker to be processed when events allow.
+ */
+static int kst_data_push(struct dst_request *req)
+{
+	struct kst_state *st = req->state;
+	struct dst_request *new_req;
+	unsigned int revents;
+	int err, locked = 0;
+
+	dprintk("%s: start: %llu, size: %llu, bio: %p.\n",
+			__func__, req->start, req->size, req->bio);
+
+	if (mutex_trylock(&st->request_lock)) {
+		locked = 1;
+
+		if (st->flags & (KST_FLAG_PARTIAL | DST_REQ_ALWAYS_QUEUE))
+			goto alloc_new_req;
+
+		err = kst_congestion(req);
+		if (err == KST_CONG_COMPLETED) {
+			err = 0;
+			goto out_bio_endio;
+		}
+
+		if (err == KST_CONG_NOT_FOUND) {
+			revents = st->socket->ops->poll(NULL, st->socket, NULL);
+			dprintk("%s: st: %p, bio: %p, revents: %x.\n",
+					__func__, st, req->bio, revents);
+			if (revents & POLLOUT) {
+				err = kst_data_process_bio(req);
+				if (err < 0)
+					goto out_unlock;
+
+				if (!req->size) {
+					err = 0;
+					goto out_bio_endio;
+				}
+			}
+		}
+	}
+
+alloc_new_req:
+	err = -ENOMEM;
+	new_req = dst_clone_request(req, req->node->w->req_pool);
+	if (!new_req)
+		goto out_unlock;
+
+	new_req->callback = &kst_data_callback;
+
+	if (!locked)
+		mutex_lock(&st->request_lock);
+	locked = 1;
+
+	err = kst_enqueue_req(st, new_req);
+	mutex_unlock(&st->request_lock);
+	locked = 0;
+	if (err) {
+		printk(KERN_NOTICE "%s: congestion [%c], start: %llu, idx: %d,"
+				" num: %d, size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+	}
+
+	kst_wake(st);
+
+	return 0;
+
+out_bio_endio:
+	req->bio_endio(req, err);
+out_unlock:
+	if (locked)
+		mutex_unlock(&st->request_lock);
+	locked = 0;
+
+	if (err) {
+		err = kst_error(st, err);
+		if (!err)
+			goto alloc_new_req;
+	}
+
+	if (err) {
+		printk("%s: error [%c], start: %llu, idx: %d, num: %d, "
+				"size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+		req->bio_endio(req, err);
+	}
+
+	kst_wake(st);
+	return err;
+}
+
+/*
+ * Remote node initialization callback.
+ */
+static int kst_data_init(struct kst_state *st, void *data)
+{
+	int err;
+
+	st->socket = data;
+	st->socket->sk->sk_allocation = GFP_NOIO;
+	/*
+	 * Why not?
+	 */
+	st->socket->sk->sk_sndbuf = st->socket->sk->sk_sndbuf = 1024*1024*10;
+
+	err = kst_poll_init(st);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+/*
+ * Remote node recovery function - tries to reconnect to given target.
+ */
+static int kst_data_recovery(struct kst_state *st, int err)
+{
+	struct socket *sock;
+	struct sockaddr addr;
+	int addrlen;
+	struct dst_request *req;
+
+	if (err != -ECONNRESET && err != -EPIPE) {
+		dprintk("%s: state %p does not know how "
+				"to recover from error %d.\n",
+				__func__, st, err);
+		return err;
+	}
+
+	err = sock_create(st->socket->ops->family, st->socket->type,
+			st->socket->sk->sk_protocol, &sock);
+	if (err < 0)
+		goto err_out_exit;
+
+	sock->sk->sk_sndtimeo = sock->sk->sk_rcvtimeo =
+		msecs_to_jiffies(DST_DEFAULT_TIMEO);
+
+	err = sock->ops->getname(st->socket, &addr, &addrlen, 2);
+	if (err)
+		goto err_out_destroy;
+
+	err = sock->ops->connect(sock, &addr, addrlen, 0);
+	if (err)
+		goto err_out_destroy;
+
+	kst_poll_exit(st);
+	kst_sock_release(st);
+
+	mutex_lock(&st->request_lock);
+	err = st->ops->init(st, sock);
+	if (!err) {
+		/*
+		 * After reconnection is completed all requests
+		 * must be resent from the state they were finished previously,
+		 * but with new headers.
+		 */
+		list_for_each_entry(req, &st->request_list, request_list_entry)
+			req->flags &= ~DST_REQ_HEADER_SENT;
+	}
+	mutex_unlock(&st->request_lock);
+	if (err < 0)
+		goto err_out_destroy;
+
+	kst_wake(st);
+	dprintk("%s: recovery completed.\n", __func__);
+
+	return 0;
+
+err_out_destroy:
+	sock_release(sock);
+err_out_exit:
+	dprintk("%s: revovery failed: st: %p, err: %d.\n", __func__, st, err);
+	return err;
+}
+
+static inline void kst_convert_header(struct dst_remote_request *r)
+{
+	r->cmd = be32_to_cpu(r->cmd);
+	r->sector = be64_to_cpu(r->sector);
+	r->offset = be32_to_cpu(r->offset);
+	r->size = be32_to_cpu(r->size);
+	r->flags = be32_to_cpu(r->flags);
+}
+
+/*
+ * Local exporting node end IO callbacks.
+ */
+static int kst_export_write_end_io(struct bio *bio, unsigned int size, int err)
+{
+	dprintk("%s: bio: %p, size: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, bio, bio->bi_size, bio->bi_idx, bio->bi_vcnt, err);
+
+	if (bio->bi_size)
+		return 1;
+
+	kst_export_put_bio(bio);
+	return 0;
+}
+
+static int kst_export_read_end_io(struct bio *bio, unsigned int size, int err)
+{
+	struct dst_request *req = bio->bi_private;
+	struct kst_state *st = req->state;
+
+	dprintk("%s: bio: %p, req: %p, size: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, bio, req, bio->bi_size, bio->bi_idx,
+		bio->bi_vcnt, err);
+
+	if (bio->bi_size)
+		return 1;
+
+	bio->bi_size = req->size = req->orig_size;
+	bio->bi_rw = WRITE;
+	req->flags &= ~DST_REQ_EXPORT_READ;
+	kst_wake(st);
+	return 0;
+}
+
+/*
+ * This callback is invoked each time new request from remote
+ * node to given local export node is received.
+ * It allocates new block IO request and queues it for processing.
+ */
+static int kst_export_ready(struct kst_state *st)
+{
+	struct dst_remote_request r;
+	struct msghdr msg;
+	struct kvec iov;
+	struct bio *bio;
+	int err, nr, i;
+	struct dst_request *req;
+	sector_t data_size;
+	unsigned int revents = st->socket->ops->poll(NULL, st->socket, NULL);
+
+	if (revents & (POLLERR | POLLHUP)) {
+		err = -EPIPE;
+		goto err_out_exit;
+	}
+
+	if (!(revents & POLLIN) || !list_empty(&st->request_list))
+		return 0;
+
+	iov.iov_base = &r;
+	iov.iov_len = sizeof(struct dst_remote_request);
+
+	msg.msg_iov = (struct iovec *)&iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	msg.msg_flags = MSG_WAITALL | MSG_NOSIGNAL;
+
+	err = kernel_recvmsg(st->socket, &msg, &iov, 1,
+			iov.iov_len, msg.msg_flags);
+	if (err != sizeof(struct dst_remote_request)) {
+		err = -EINVAL;
+		goto err_out_exit;
+	}
+
+	kst_convert_header(&r);
+
+	dprintk("\n%s: cmd: %u, sector: %llu, size: %u, "
+			"flags: %x, offset: %u.\n",
+			__func__, r.cmd, r.sector, r.size, r.flags, r.offset);
+
+	err = -EINVAL;
+	if (r.cmd != DST_READ && r.cmd != DST_WRITE && r.cmd != DST_REMOTE_CFG)
+		goto err_out_exit;
+
+	data_size = get_capacity(st->node->bdev->bd_disk);
+	if ((signed)(r.sector + to_sector(r.size)) < 0 ||
+			(signed)(r.sector + to_sector(r.size)) > data_size ||
+			(signed)r.sector > data_size)
+		goto err_out_exit;
+
+	if (r.cmd == DST_REMOTE_CFG) {
+		r.sector = data_size;
+		kst_convert_header(&r);
+
+		iov.iov_base = &r;
+		iov.iov_len = sizeof(struct dst_remote_request);
+
+		msg.msg_iov = (struct iovec *)&iov;
+		msg.msg_iovlen = 1;
+		msg.msg_name = NULL;
+		msg.msg_namelen = 0;
+		msg.msg_control = NULL;
+		msg.msg_controllen = 0;
+		msg.msg_flags = MSG_WAITALL | MSG_NOSIGNAL;
+
+		err = kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+		if (err != sizeof(struct dst_remote_request)) {
+			err = -EINVAL;
+			goto err_out_exit;
+		}
+		kst_wake(st);
+		return 0;
+	}
+
+	nr = r.size/PAGE_SIZE + 1;
+
+	while (r.size) {
+		int nr_pages = min(BIO_MAX_PAGES, nr);
+		unsigned int size;
+		struct page *page;
+
+		err = -ENOMEM;
+		req = dst_clone_request(NULL, st->node->w->req_pool);
+		if (!req)
+			goto err_out_exit;
+
+		dprintk("%s: alloc req: %p, pool: %p.\n",
+				__func__, req, st->node->w->req_pool);
+
+		bio = bio_alloc(GFP_NOIO, nr_pages);
+		if (!bio)
+			goto err_out_free_req;
+
+		req->flags = DST_REQ_EXPORT | DST_REQ_HEADER_SENT;
+		req->bio = bio;
+		req->state = st;
+		req->node = st->node;
+		req->callback = &kst_data_callback;
+		req->bio_endio = &kst_bio_endio;
+
+		/*
+		 * Yes, looks a bit weird.
+		 * Logic is simple - for local exporting node all operations
+		 * are reversed compared to usual nodes, since usual nodes
+		 * process remote data and local export node process remote
+		 * requests, so that writing data means sending data to
+		 * remote node and receiving on the local export one.
+		 *
+		 * So, to process writing to the exported node we need first 
+		 * to receive data from the net (i.e. to perform READ 
+		 * operationin terms of usual node), and then put it to the 
+		 * storage (WRITE command, so it will be changed before 
+		 * calling generic_make_request()).
+		 *
+		 * To process read request from the exported node we need
+		 * first to read it from storage (READ command for BIO)
+		 * and then send it over the net (perform WRITE operation
+		 * in terms of network).
+		 */
+		if (r.cmd == DST_WRITE) {
+			req->flags |= DST_REQ_EXPORT_WRITE;
+			bio->bi_end_io = kst_export_write_end_io;
+		} else {
+			req->flags |= DST_REQ_EXPORT_READ;
+			bio->bi_end_io = kst_export_read_end_io;
+		}
+		bio->bi_rw = READ;
+		bio->bi_private = req;
+		bio->bi_sector = r.sector;
+		bio->bi_bdev = st->node->bdev;
+
+		for (i = 0; i < nr_pages; ++i) {
+			page = alloc_page(GFP_NOIO);
+			if (!page)
+				break;
+
+			size = min_t(u32, PAGE_SIZE, r.size);
+
+			err = bio_add_page(bio, page, size, r.offset);
+			dprintk("%s: %d/%d: page: %p, size: %u, offset: %u, "
+					"err: %d.\n",
+					__func__, i, nr_pages, page, size,
+					r.offset, err);
+			if (err <= 0)
+				break;
+
+			if (err == size) {
+				r.offset = 0;
+				nr--;
+			} else {
+				r.offset += err;
+			}
+
+			r.size -= err;
+			r.sector += to_sector(err);
+
+			if (!r.size)
+				break;
+		}
+
+		if (!bio->bi_vcnt) {
+			err = -ENOMEM;
+			goto err_out_put;
+		}
+
+		req->size = req->orig_size = bio->bi_size;
+		req->start = bio->bi_sector;
+		req->idx = 0;
+		req->num = bio->bi_vcnt;
+
+		dprintk("%s: submitting: bio: %p, req: %p, start: %llu, "
+			"size: %llu, idx: %d, num: %d, offset: %u, err: %d.\n",
+			__func__, bio, req, req->start, req->size,
+			req->idx, req->num, req->offset, err);
+
+		err = kst_enqueue_req(st, req);
+		if (err)
+			goto err_out_put;
+
+		if (r.cmd == DST_READ) {
+			generic_make_request(bio);
+		}
+	}
+
+	kst_wake(st);
+	return 0;
+
+err_out_put:
+	bio_put(bio);
+err_out_free_req:
+	dst_free_request(req);
+err_out_exit:
+	dprintk("%s: error: %d.\n", __func__, err);
+	return err;
+}
+
+static void kst_export_exit(struct kst_state *st)
+{
+	struct dst_node *n = st->node;
+
+	dprintk("%s: st: %p.\n", __func__, st);
+
+	kst_common_exit(st);
+	dst_node_put(n);
+}
+
+static struct kst_state_ops kst_data_export_ops = {
+	.init = &kst_data_init,
+	.push = &kst_data_push,
+	.exit = &kst_export_exit,
+	.ready = &kst_export_ready,
+};
+
+/*
+ * This callback is invoked each time listening socket for
+ * given local export node becomes ready.
+ * It creates new state for connected client and queues for processing.
+ */
+static int kst_listen_ready(struct kst_state *st)
+{
+	struct socket *newsock;
+	struct saddr addr;
+	struct kst_state *newst;
+	int err;
+	unsigned int revents, permissions = 0;
+	struct dst_secure *s;
+
+	revents = st->socket->ops->poll(NULL, st->socket, NULL);
+	if (!(revents & POLLIN))
+		return 1;
+
+	err = sock_create(st->socket->ops->family, st->socket->type,
+			st->socket->sk->sk_protocol, &newsock);
+	if (err)
+		goto err_out_exit;
+
+	err = st->socket->ops->accept(st->socket, newsock, 0);
+	if (err)
+		goto err_out_put;
+
+	if (newsock->ops->getname(newsock, (struct sockaddr *)&addr,
+				  (int *)&addr.sa_data_len, 2) < 0) {
+		err = -ECONNABORTED;
+		goto err_out_put;
+	}
+
+	list_for_each_entry(s, &st->request_list, sec_entry) {
+		void *sec_addr, *new_addr;
+
+		sec_addr = ((void *)&s->sec.addr) + s->sec.check_offset;
+		new_addr = ((void *)&addr) + s->sec.check_offset;
+
+		if (!memcmp(sec_addr, new_addr,	
+				addr.sa_data_len - s->sec.check_offset)) {
+			permissions = s->sec.permissions;
+			break;
+		}
+	}
+
+	/*
+	 * So far only reading and writing are supported.
+	 * Block device does not know about anything else,
+	 * but as far as I recall, there was a prognosis,
+	 * that computer will never require more than 640kb of RAM.
+	 */
+	if (permissions == 0) {
+		err = -EPERM;
+		goto err_out_put;
+	}
+
+	if (st->socket->ops->family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&addr;
+		printk(KERN_INFO "%s: Client: %u.%u.%u.%u:%d.\n", __func__,
+			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	} else if (st->socket->ops->family == AF_INET6) {
+		struct sockaddr_in6 *sin = (struct sockaddr_in6 *)&addr;
+		printk(KERN_INFO "%s: Client: "
+			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d",
+			__func__, 
+			NIP6(sin->sin6_addr), ntohs(sin->sin6_port));
+	}
+
+	dst_node_get(st->node);
+	newst = kst_state_init(st->node, permissions,
+			&kst_data_export_ops, newsock);
+	if (IS_ERR(newst)) {
+		err = PTR_ERR(newst);
+		goto err_out_put;
+	}
+
+	/*
+	 * Negative return value means error, positive - stop this state 
+	 * processing. Zero allows to check state for pending requests.
+	 * Listening socket contains security objects in request list,
+	 * since it does not have any requests.
+	 */
+	return 1;
+
+err_out_put:
+	sock_release(newsock);
+err_out_exit:
+	return 1;
+}
+
+static int kst_listen_init(struct kst_state *st, void *data)
+{
+	int err = -ENOMEM, i;
+	struct dst_le_template *tmp = data;
+	struct dst_secure *s;
+
+	for (i=0; i<tmp->le->secure_attr_num; ++i) {
+		s = kmalloc(sizeof(struct dst_secure), GFP_KERNEL);
+		if (!s)
+			goto err_out_exit;
+
+		memcpy(&s->sec, tmp->data, sizeof(struct dst_secure_user));
+
+		list_add_tail(&s->sec_entry, &st->request_list);
+		tmp->data += sizeof(struct dst_secure_user);
+
+		if (s->sec.addr.sa_family == AF_INET) {
+			struct sockaddr_in *sin = 
+				(struct sockaddr_in *)&s->sec.addr;
+			printk(KERN_INFO "%s: Client: %u.%u.%u.%u:%d, "
+					"permissions: %x.\n", 
+				__func__, NIPQUAD(sin->sin_addr.s_addr), 
+				ntohs(sin->sin_port), s->sec.permissions);
+		} else if (s->sec.addr.sa_family == AF_INET6) {
+			struct sockaddr_in6 *sin = 
+				(struct sockaddr_in6 *)&s->sec.addr;
+			printk(KERN_INFO "%s: Client: "
+				"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%d, "
+				"permissions: %x.\n", 
+				__func__, NIP6(sin->sin6_addr), 
+				ntohs(sin->sin6_port), s->sec.permissions);
+		}
+	}
+
+	err = kst_sock_create(st, &tmp->le->rctl.addr, tmp->le->rctl.type,
+			tmp->le->rctl.proto, tmp->le->backlog);
+	if (err)
+		goto err_out_exit;
+
+	err = kst_poll_init(st);
+	if (err)
+		goto err_out_release;
+
+	return 0;
+
+err_out_release:
+	kst_sock_release(st);
+err_out_exit:
+	kst_listen_flush(st);
+	return err;
+}
+
+/*
+ * Operations for different types of states.
+ * There are three:
+ * data state - created for remote node, when distributed storage connects
+ * 	to remote node, which contain data.
+ * listen state - created for local export node, when remote distributed
+ * 	storage's node connects to given node to get/put data.
+ * data export state - created for each client connected to above listen
+ * 	state.
+ */
+static struct kst_state_ops kst_listen_ops = {
+	.init = &kst_listen_init,
+	.exit = &kst_listen_exit,
+	.ready = &kst_listen_ready,
+};
+static struct kst_state_ops kst_data_ops = {
+	.init = &kst_data_init,
+	.push = &kst_data_push,
+	.exit = &kst_common_exit,
+	.recovery = &kst_data_recovery,
+};
+
+struct kst_state *kst_listener_state_init(struct dst_node *node,
+		struct dst_le_template *tmp)
+{
+	return kst_state_init(node, DST_PERM_READ | DST_PERM_WRITE,
+			&kst_listen_ops, tmp);
+}
+
+struct kst_state *kst_data_state_init(struct dst_node *node,
+		struct socket *newsock)
+{
+	return kst_state_init(node, DST_PERM_READ | DST_PERM_WRITE,
+			&kst_data_ops, newsock);
+}
+
+/*
+ * Remove all workers and associated states.
+ */
+void kst_exit_all(void)
+{
+	struct kst_worker *w, *n;
+
+	list_for_each_entry_safe(w, n, &kst_worker_list, entry) {
+		kst_worker_exit(w);
+	}
+}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 10eb56b..9e67d58 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -36,9 +36,11 @@
 #define CN_VAL_CIFS                     0x1
 #define CN_W1_IDX			0x3	/* w1 communication */
 #define CN_W1_VAL			0x1
+#define CN_DST_IDX			0x4	/* Distributed storage */
+#define CN_DST_VAL			0x1
 
 
-#define CN_NETLINK_USERS		4
+#define CN_NETLINK_USERS		5
 
 /*
  * Maximum connector's message size.
diff --git a/include/linux/dst.h b/include/linux/dst.h
new file mode 100644
index 0000000..3fd41dd
--- /dev/null
+++ b/include/linux/dst.h
@@ -0,0 +1,354 @@
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
+
+#define DST_NAMELEN		32
+#define DST_NAME		"dst"
+#define DST_IOCTL		0xba
+
+enum {
+	DST_DEL_NODE	= 0,	/* Remove node with given id from storage */
+	DST_ADD_REMOTE,		/* Add remote node with given id to the storage */
+	DST_ADD_LOCAL,		/* Add local node with given id to the storage */
+	DST_ADD_LOCAL_EXPORT,	/* Add local node with given id to the storage to be exported and used by remote peers */
+	DST_START_STORAGE,	/* Array is ready and storage can be started, if there will be new nodes
+				 * added to the storage, they will be checked against existing size and
+				 * probably be dropped (for example in mirror format when new node has smaller
+				 * size than array created) or inserted.
+				 */
+	DST_STOP_STORAGE,	/* Remove array and all nodes. */
+	DST_CMD_MAX
+};
+
+#define DST_CTL_FLAGS_REMOTE	(1<<0)
+#define DST_CTL_FLAGS_EXPORT	(1<<1)
+
+struct dst_ctl
+{
+	char			st[DST_NAMELEN];
+	char			alg[DST_NAMELEN];
+	__u32			flags, cmd;
+	__u64			start, size;
+};
+
+struct dst_local_ctl
+{
+	char			name[DST_NAMELEN];
+};
+
+#define SADDR_MAX_DATA	128
+
+struct saddr {
+	unsigned short		sa_family;			/* address family, AF_xxx	*/
+	char			sa_data[SADDR_MAX_DATA];	/* 14 bytes of protocol address	*/
+	unsigned short		sa_data_len;			/* Number of bytes used in sa_data */
+};
+
+struct dst_remote_ctl
+{
+	__u16			type;
+	__u16			proto;
+	struct saddr		addr;
+};
+
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
+	unsigned short		check_offset;
+	struct saddr		addr;
+};
+
+struct dst_local_export_ctl
+{
+	__u32			backlog;
+	int			secure_attr_num;
+	struct dst_local_ctl	lctl;
+	struct dst_remote_ctl	rctl;
+};
+
+enum {
+	DST_REMOTE_CFG		= 1, 		/* Request remote configuration */
+	DST_WRITE,				/* Writing */
+	DST_READ,				/* Reading */
+	DST_NCMD_MAX,
+};
+
+struct dst_remote_request
+{
+	__u32			cmd;
+	__u32			flags;
+	__u64			sector;
+	__u32			offset;
+	__u32			size;
+};
+
+#ifdef __KERNEL__
+
+#include <linux/rbtree.h>
+#include <linux/net.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/mempool.h>
+#include <linux/device.h>
+
+//#define DST_DEBUG
+
+#ifdef DST_DEBUG
+#define dprintk(f, a...) printk(KERN_NOTICE f, ##a)
+#else
+#define dprintk(f, a...) do {} while (0)
+#endif
+
+struct kst_worker
+{
+	struct list_head	entry;
+
+	struct list_head	state_list;
+	struct mutex		state_mutex;
+
+	struct list_head	ready_list;
+	spinlock_t		ready_lock;
+
+	mempool_t		*req_pool;
+
+	struct task_struct	*thread;
+
+	wait_queue_head_t 	wait;
+
+	int			id;
+};
+
+struct kst_state;
+struct dst_node;
+
+#define DST_REQ_HEADER_SENT	(1<<0)
+#define DST_REQ_EXPORT		(1<<1)
+#define DST_REQ_EXPORT_WRITE	(1<<2)
+#define DST_REQ_EXPORT_READ	(1<<3)
+#define DST_REQ_ALWAYS_QUEUE	(1<<4)
+
+struct dst_request
+{
+	struct rb_node		request_entry;
+	struct list_head	request_list_entry;
+	struct bio		*bio;
+	struct kst_state 	*state;
+	struct dst_node 	*node;
+
+	u32			flags;
+
+	int 			(*callback)(struct dst_request *dst,
+						unsigned int revents);
+	void			(*bio_endio)(struct dst_request *dst, 
+						int err);
+
+	void			*priv;
+	atomic_t		refcnt;
+
+	u64			size, orig_size, start;
+	int			idx, num;
+	u32			offset;
+};
+
+struct kst_state_ops
+{
+	int 		(*init)(struct kst_state *, void *);
+	int 		(*push)(struct dst_request *req);
+	int		(*ready)(struct kst_state *);
+	int		(*recovery)(struct kst_state *, int err);
+	void 		(*exit)(struct kst_state *);
+};
+
+#define KST_FLAG_PARTIAL		(1<<0)
+
+struct kst_state
+{
+	struct list_head	entry;
+	struct list_head	ready_entry;
+
+	wait_queue_t 		wait;
+	wait_queue_head_t 	*whead;
+
+	struct dst_node		*node;
+	struct socket		*socket;
+
+	u32			flags, permissions;
+
+	struct rb_root		request_root;
+	struct mutex		request_lock;
+	struct list_head	request_list;
+
+	struct kst_state_ops	*ops;
+};
+
+#define DST_DEFAULT_TIMEO	2000
+
+struct dst_storage;
+
+struct dst_alg_ops
+{
+	int			(*add_node)(struct dst_node *n);
+	void			(*del_node)(struct dst_node *n);
+	int 			(*remap)(struct dst_request *req);
+	int			(*error)(struct kst_state *state, int err);
+	struct module 		*owner;
+};
+
+struct dst_alg
+{
+	struct list_head	entry;
+	char			name[DST_NAMELEN];
+	atomic_t		refcnt;
+	struct dst_alg_ops	*ops;
+};
+
+#define DST_ST_STARTED		(1<<0)
+
+struct dst_storage
+{
+	struct list_head	entry;
+	char			name[DST_NAMELEN];
+	struct dst_alg		*alg;
+	atomic_t		refcnt;
+	struct mutex		tree_lock;
+	struct rb_root		tree_root;
+
+	request_queue_t		*queue;
+	struct gendisk		*disk;
+
+	long			flags;
+	u64			disk_size;
+
+	struct device		device;
+};
+
+#define DST_NODE_FROZEN		0
+#define DST_NODE_NOTSYNC	1
+
+struct dst_node
+{
+	struct rb_node		tree_node;
+
+	struct list_head	shared;
+	struct dst_node		*shared_head;
+
+	struct block_device 	*bdev;
+	struct dst_storage	*st;
+	struct kst_state	*state;
+	struct kst_worker	*w;
+
+	atomic_t		refcnt;
+	atomic_t		shared_num;
+
+	void			(*cleanup)(struct dst_node *);
+
+	long			flags;
+
+	u64			start, size;
+
+	void			(*priv_callback)(struct dst_node *);
+	void			*priv;
+
+	struct device		device;
+};
+
+struct dst_le_template
+{
+	struct dst_local_export_ctl	*le;
+	void 				*data;
+};
+
+struct dst_secure
+{
+	struct list_head	sec_entry;
+	struct dst_secure_user	sec;
+};
+
+void kst_state_exit(struct kst_state *st);
+
+struct kst_worker *kst_worker_init(int id);
+void kst_worker_exit(struct kst_worker *w);
+
+struct kst_state *kst_listener_state_init(struct dst_node *node,
+		struct dst_le_template *tmp);
+struct kst_state *kst_data_state_init(struct dst_node *node,
+		struct socket *newsock);
+
+void kst_wake(struct kst_state *st);
+
+void kst_exit_all(void);
+
+struct dst_alg *dst_alloc_alg(char *name, struct dst_alg_ops *ops);
+void dst_remove_alg(struct dst_alg *alg);
+
+struct dst_node *dst_storage_tree_search(struct dst_storage *st, u64 start);
+
+void dst_node_put(struct dst_node *n);
+
+static inline struct dst_node *dst_node_get(struct dst_node *n)
+{
+	atomic_inc(&n->refcnt);
+	return n;
+}
+
+struct dst_request *dst_clone_request(struct dst_request *req, mempool_t *pool);
+void dst_free_request(struct dst_request *req);
+
+void kst_complete_req(struct dst_request *req, int err);
+void kst_bio_endio(struct dst_request *req, int err);
+void kst_del_req(struct dst_request *req);
+int kst_enqueue_req(struct kst_state *st, struct dst_request *req);
+
+int kst_data_callback(struct dst_request *req, unsigned int revents);
+
+extern struct kmem_cache *dst_request_cache;
+
+static inline sector_t to_sector(unsigned long n)
+{
+	return (n >> 9);
+}
+
+static inline unsigned long to_bytes(sector_t n)
+{
+	return (n << 9);
+}
+
+/*
+ * Checks state's permissions.
+ * Returns -EPERM if check failed.
+ */
+static inline int kst_check_permissions(struct kst_state *st, struct bio *bio)
+{
+	if ((bio_rw(bio) == WRITE) && !(st->permissions & DST_PERM_WRITE))
+		return -EPERM;
+
+	return 0;
+}
+
+#endif /* __KERNEL__ */
+#endif /* __DST_H */


-- 
	Evgeniy Polyakov
