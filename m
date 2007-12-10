From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [3/4] DST: Network state machine.
Date: Mon, 10 Dec 2007 14:47:31 +0300
Message-ID: <11972872511269@2ka.mipt.ru>
References: <1197287250388@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1197287250388@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Network state machine.

Includes network async processing state machine and related tasks.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


diff --git a/drivers/block/dst/kst.c b/drivers/block/dst/kst.c
new file mode 100644
index 0000000..8fa3387
--- /dev/null
+++ b/drivers/block/dst/kst.c
@@ -0,0 +1,1513 @@
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
+/*
+ * This function enqueues request into tree, indexed by start of the request,
+ * and also puts request into ordered queue.
+ */
+int kst_enqueue_req(struct kst_state *st, struct dst_request *req)
+{
+	if (unlikely(req->flags & DST_REQ_CHECK_QUEUE)) {
+		struct dst_request *r;
+
+		list_for_each_entry(r, &st->request_list, request_list_entry) {
+			if (bio_rw(r->bio) != bio_rw(req->bio))
+				continue;
+
+			if (r->start >= req->start + req->size)
+				continue;
+
+			if (r->start + r->size <= req->start)
+				continue;
+
+			return -EEXIST;
+		}
+	}
+
+	list_add_tail(&req->request_list_entry, &st->request_list);
+	return 0;
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
+	dprintk("%s: bio: %p, size: %u, idx: %d, num: %d, req: %p.\n",
+			__func__, bio, bio->bi_size, bio->bi_idx,
+			bio->bi_vcnt, bio->bi_private);
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
+		if (err || !(req->flags & DST_REQ_EXPORT_WRITE)) {
+			req->bio_endio(req, err);
+			goto out;
+		}
+
+		req->bio->bi_rw = WRITE;
+		generic_make_request(req->bio);
+	} else {
+		req->bio_endio(req, err);
+	}
+out:
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
+	mutex_lock(&w->state_mutex);
+	list_del_init(&st->entry);
+	mutex_unlock(&w->state_mutex);
+
+	st->ops->exit(st);
+
+	if (st == st->node->state)
+		st->node->state = NULL;
+
+	kfree(st);
+}
+
+static int kst_error(struct kst_state *st, int err)
+{
+	if ((err == -ECONNRESET || err == -EPIPE) && st->ops->recovery)
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
+	list_for_each_entry_safe(req, tmp, &st->request_list, request_list_entry) {
+		empty = 0;
+		revents = st->socket->ops->poll(st->socket->file,
+				st->socket, NULL);
+		if (!revents)
+			break;
+		err = req->callback(req, revents);
+		if (req->size && !err)
+			err = 1;
+
+		if (err < 0 || !req->size) {
+			if (!req->size)
+				err = 0;
+			kst_del_req(req);
+			kst_complete_req(req, err);
+		}
+
+		if (err)
+			break;
+	}
+
+	dprintk("%s: broke the loop: err: %d, list_empty: %d.\n",
+			__func__, err, list_empty(&st->request_list));
+	mutex_unlock(&st->request_lock);
+
+	if (err < 0) {
+		dprintk("%s: req: %p, err: %d, st: %p, node->state: %p.\n",
+			__func__, req, err, st, st->node->state);
+
+		if (st != st->node->state) {
+			/*
+			 * Accepted client has state not related to storage
+			 * node, so it must be freed explicitely.
+			 * We do not try to fix clients connections to local
+			 * export nodes, just drop the client.
+			 */
+
+			kst_state_exit(st);
+			return err;
+		}
+
+		err = kst_error(st, err);
+		if (err)
+			return err;
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
+	kst_poll_exit(st);
+
+	spin_lock_irqsave(&st->node->w->ready_lock, flags);
+	list_del_init(&st->ready_entry);
+	spin_unlock_irqrestore(&st->node->w->ready_lock, flags);
+
+	kst_flush_requests(st);
+	kst_sock_release(st);
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
+static int kst_data_send_bio_vec_slow(struct kst_state *st, struct bio_vec *bv,
+		unsigned int offset, unsigned int size)
+{
+	struct msghdr msg;
+	struct kvec iov;
+	void *addr;
+	int err;
+
+	addr = kmap(bv->bv_page);
+	iov.iov_base = addr + bv->bv_offset + offset;
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
+	err = kernel_sendmsg(st->socket, &msg, &iov, 1, iov.iov_len);
+	kunmap(bv->bv_page);
+
+	return err;
+}
+
+static u32 dst_csum_bvec(struct bio_vec *bv, unsigned int offset, unsigned int size)
+{
+	void *addr;
+	u32 csum;
+
+	addr = kmap_atomic(bv->bv_page, KM_USER0);
+	csum =  dst_csum_data(addr + bv->bv_offset + offset, size);
+	kunmap_atomic(addr, KM_USER0);
+
+	return csum;
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
+ * In case of errors negative value is returned and @size,
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
+	int err = -ENOSPC;
+	struct dst_remote_request r;
+	kst_data_process_bio_vec_t func;
+	unsigned int cur_size;
+	int use_csum = test_bit(DST_NODE_USE_CSUM, &req->node->flags);
+
+	if (bio_rw(req->bio) == WRITE) {
+		int i;
+
+		func = kst_data_send_bio_vec;
+		for (i=req->idx; i<req->num; ++i) {
+			struct bio_vec *bv = bio_iovec_idx(req->bio, i);
+
+			if (PageSlab(bv->bv_page)) {
+				func = kst_data_send_bio_vec_slow;
+				break;
+			}
+		}
+		r.cmd = cpu_to_be32(DST_WRITE);
+	} else {
+		r.cmd = cpu_to_be32(DST_READ);
+		func = kst_data_recv_bio_vec;
+	}
+
+	dprintk("%s: start: [%c], start: %llu, idx: %d, num: %d, "
+			"size: %llu, offset: %u, flags: %x, use_csum: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size, req->offset,
+			req->flags, use_csum);
+
+	while (req->idx < req->num) {
+		struct bio_vec *bv = bio_iovec_idx(req->bio, req->idx);
+
+		cur_size = min_t(u64, bv->bv_len - req->offset, req->size);
+
+		dprintk("%s: page: %p, slab: %d, count: %d, max: %d, off: %u, len: %u, req->offset: %u, "
+				"req->size: %llu, cur_size: %u, flags: %x, "
+				"use_csum: %d, req->csum: %x.\n",
+				__func__, bv->bv_page, PageSlab(bv->bv_page),
+				atomic_read(&bv->bv_page->_count), req->bio->bi_vcnt,
+				bv->bv_offset, bv->bv_len,
+				req->offset, req->size, cur_size,
+				req->flags, use_csum, req->tmp_csum);
+
+		if (cur_size == 0) {
+			printk(KERN_ERR "%s: %d/%d: start: %llu, "
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
+			r.csum = 0;
+
+			if (use_csum && bio_rw(req->bio) == WRITE &&
+					!req->tmp_offset) {
+				req->tmp_offset = req->offset;
+				r.csum = cpu_to_be32(dst_csum_bvec(bv,
+						req->offset, cur_size));
+			}
+
+			err = dst_data_send_header(req->state->socket, &r);
+			dprintk("%s: %d/%d: sending header: cmd: %u, start: %llu, "
+				"bv_offset: %u, bv_len: %u, "
+				"a offset: %u, offset: %u, "
+				"cur_size: %u, err: %d.\n",
+				__func__, req->idx, req->num, be32_to_cpu(r.cmd),
+				req->start, bv->bv_offset, bv->bv_len,
+				bv->bv_offset + req->offset,
+				req->offset, cur_size, err);
+
+			if (err != sizeof(struct dst_remote_request)) {
+				if (err >= 0)
+					err = -EINVAL;
+				break;
+			}
+
+			req->flags |= DST_REQ_HEADER_SENT;
+		}
+
+		if (use_csum && (bio_rw(req->bio) != WRITE) &&
+				!(req->flags & DST_REQ_CHEKSUM_RECV)) {
+			struct dst_remote_request tmp_req;
+
+			err = dst_data_recv_header(req->state->socket, &tmp_req, 0);
+			dprintk("%s: %d/%d: receiving header: start: %llu, "
+				"bv_offset: %u, bv_len: %u, "
+				"a offset: %u, offset: %u, "
+				"cur_size: %u, err: %d.\n",
+				__func__, req->idx, req->num,
+				req->start, bv->bv_offset, bv->bv_len,
+				bv->bv_offset + req->offset,
+				req->offset, cur_size, err);
+
+			if (err != sizeof(struct dst_remote_request)) {
+				if (err >= 0)
+					err = -EINVAL;
+				break;
+			}
+
+			if (req->tmp_csum) {
+				printk("%s: req: %p, old csum: %x, new: %x.\n",
+						__func__, req, req->tmp_csum,
+						be32_to_cpu(tmp_req.csum));
+				BUG_ON(1);
+			}
+
+			dprintk("%s: req: %p, old csum: %x, new: %x.\n",
+					__func__, req, req->tmp_csum,
+					be32_to_cpu(tmp_req.csum));
+			req->tmp_csum = be32_to_cpu(tmp_req.csum);
+
+			req->flags |= DST_REQ_CHEKSUM_RECV;
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
+				"bv_len: %u, offset: %u, "
+				"cur_size: %u, err: %d.\n",
+				__func__, req->idx, req->num, req->start,
+				bv->bv_offset, bv->bv_len,
+				req->offset, cur_size, err);
+			err = -EAGAIN;
+			break;
+		}
+
+		if (use_csum && bio_rw(req->bio) != WRITE) {
+			u32 csum = dst_csum_bvec(bv, req->tmp_offset,
+					bv->bv_len - req->tmp_offset);
+
+			dprintk("%s: req: %p, csum: %x, received csum: %x.\n",
+					__func__, req, csum, req->tmp_csum);
+
+			if (csum != req->tmp_csum) {
+				printk("%s: %d/%d: broken checksum: start: %llu, "
+					"bv_offset: %u, bv_len: %u, "
+					"a offset: %u, offset: %u, "
+					"cur_size: %u, orig_size: %llu.\n",
+					__func__, req->idx, req->num,
+					req->start, bv->bv_offset, bv->bv_len,
+					bv->bv_offset + req->offset,
+					req->offset, cur_size, req->orig_size);
+				printk("%s: broken checksum: req: %p, csum: %x, "
+					"should be: %x, flags: %x, "
+					"req->tmp_offset: %u, rw: %lu.\n",
+					__func__, req, csum, req->tmp_csum,
+					req->flags, req->tmp_offset, bio_rw(req->bio));
+
+				req->offset -= err;
+				req->size += err;
+
+				err = -EREMOTEIO;
+				break;
+			}
+		}
+
+		req->offset = 0;
+		req->idx++;
+		req->flags &= ~(DST_REQ_HEADER_SENT | DST_REQ_CHEKSUM_RECV);
+		req->tmp_csum = 0;
+		req->start += to_sector(bv->bv_len);
+	}
+
+	if (err <= 0 && err != -EAGAIN) {
+		if (err == 0)
+			err = -ECONNRESET;
+	} else
+		err = 0;
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
+	if (err && printk_ratelimit())
+		printk("%s: freeing bio: %p, bi_size: %u, "
+			"orig_size: %llu, req: %p, err: %d.\n",
+		__func__, req->bio, req->bio->bi_size, req->orig_size,
+		req, err);
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
+
+	if (revents & (POLLERR | POLLHUP | POLLRDHUP))
+		err = -EPIPE;
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(kst_data_callback);
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
+	dprintk("%s: req: %p, new_req: %p.\n", __func__, req, new_req);
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
+		new_req->tmp_offset = req->tmp_offset;
+		new_req->tmp_csum = req->tmp_csum;
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
+	if (!list_empty(&st->request_list) || (req->flags & DST_REQ_ALWAYS_QUEUE))
+		goto alloc_new_req;
+
+	if (mutex_trylock(&st->request_lock)) {
+		locked = 1;
+
+		if (!list_empty(&st->request_list))
+			goto alloc_new_req;
+
+		revents = st->socket->ops->poll(NULL, st->socket, NULL);
+		if (revents & POLLOUT) {
+			err = kst_data_process_bio(req);
+			if (err < 0)
+				goto out_unlock;
+
+			if (!req->size)
+				goto out_bio_endio;
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
+
+	locked = 1;
+
+	err = kst_enqueue_req(st, new_req);
+	if (err)
+		goto out_unlock;
+	mutex_unlock(&st->request_lock);
+
+	err = 0;
+	goto out;
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
+	if (err && printk_ratelimit()) {
+		printk("%s: error [%c], start: %llu, idx: %d, num: %d, "
+				"size: %llu, offset: %u, err: %d.\n",
+			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
+			req->start, req->idx, req->num, req->size,
+			req->offset, err);
+	}
+
+out:
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
+			req->flags &= ~(DST_REQ_HEADER_SENT | DST_REQ_CHEKSUM_RECV);
+	}
+	mutex_unlock(&st->request_lock);
+	if (err < 0)
+		goto err_out_destroy;
+
+	kst_wake(st);
+	dprintk("%s: reconnected.\n", __func__);
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
+	int use_csum = test_bit(DST_NODE_USE_CSUM, &req->node->flags);
+
+	dprintk("%s: bio: %p, req: %p, size: %u, idx: %d, num: %d, err: %d.\n",
+		__func__, bio, req, bio->bi_size, bio->bi_idx,
+		bio->bi_vcnt, err);
+
+	if (bio->bi_size)
+		return 1;
+
+	if (err) {
+		kst_export_put_bio(bio);
+		return 0;
+	}
+
+	bio->bi_size = req->size = req->orig_size;
+	bio->bi_rw = WRITE;
+	if (use_csum)
+		req->flags &= ~(DST_REQ_HEADER_SENT | DST_REQ_CHEKSUM_RECV);
+
+	/*
+	 * This is a race with kst_data_callback(), which checks
+	 * this bit to determine if it can or can not process given
+	 * request. This does not harm actually, since subsequent
+	 * state wakeup will call it again and thus will pick
+	 * given request in time.
+	 */
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
+	struct bio *bio;
+	int err, nr, i;
+	struct dst_request *req;
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
+	err = dst_data_recv_header(st->socket, &r, 1);
+	if (err != sizeof(struct dst_remote_request)) {
+		err = -ECONNRESET;
+		goto err_out_exit;
+	}
+
+	kst_convert_header(&r);
+
+	dprintk("\n%s: st: %p, cmd: %u, sector: %llu, size: %u, "
+			"csum: %x, offset: %u.\n",
+			__func__, st, r.cmd, r.sector,
+			r.size, r.csum, r.offset);
+
+	err = -EINVAL;
+	if (r.cmd != DST_READ && r.cmd != DST_WRITE && r.cmd != DST_REMOTE_CFG)
+		goto err_out_exit;
+
+	if ((s64)(r.sector + to_sector(r.size)) < 0 ||
+		(r.sector + to_sector(r.size)) > st->node->size ||
+		r.offset >= PAGE_SIZE)
+		goto err_out_exit;
+
+	if (r.cmd == DST_REMOTE_CFG) {
+		r.sector = st->node->size;
+
+		if (test_bit(DST_NODE_USE_CSUM, &st->node->flags))
+			r.csum = 1;
+
+		kst_convert_header(&r);
+
+		err = dst_data_send_header(st->socket, &r);
+		if (err != sizeof(struct dst_remote_request)) {
+			err = -EINVAL;
+			goto err_out_exit;
+		}
+		kst_wake(st);
+		return 0;
+	}
+
+	nr = DIV_ROUND_UP(r.size, PAGE_SIZE);
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
+		bio = bio_alloc(GFP_NOIO, nr_pages);
+		if (!bio)
+			goto err_out_free_req;
+
+		req->flags = DST_REQ_EXPORT | DST_REQ_HEADER_SENT |
+				DST_REQ_CHEKSUM_RECV;
+		req->bio = bio;
+		req->state = st;
+		req->node = st->node;
+		req->callback = &kst_data_callback;
+		req->bio_endio = &kst_bio_endio;
+
+		req->tmp_offset = 0;
+		req->tmp_csum = r.csum;
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
+			size = min_t(u32, PAGE_SIZE - r.offset, r.size);
+
+			err = bio_add_page(bio, page, size, 0);
+			dprintk("%s: %d/%d: page: %p, size: %u, "
+					"offset: %u (used zero), err: %d.\n",
+					__func__, i, nr_pages, page, size,
+					r.offset, err);
+			if (err <= 0)
+				break;
+
+			if (err == size)
+				nr--;
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
+			"size: %llu, idx: %d, num: %d, offset: %u, csum: %x.\n",
+			__func__, bio, req, req->start, req->size,
+			req->idx, req->num, req->offset, req->tmp_csum);
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
+	return err;
+}
+
+static void kst_export_exit(struct kst_state *st)
+{
+	struct dst_node *n = st->node;
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

