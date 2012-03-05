From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] Netfilter: xt_LOG: Implement ring buffer support
Date: Mon, 05 Mar 2012 13:58:47 -0500
Message-ID: <1330973927.25686.338.camel@gandalf.stny.rr.com>
References: <1329348480-11147-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, pablo@netfilter.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329348480-11147-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-16 at 00:27 +0100, Richard Weinberger wrote:

> +int xt_LOG_ring_add_record(const struct xt_LOG_ring_ctx *rctx,
> +			   const char *buf, unsigned int len)
> +{
> +	struct rlog_entry *entry;
> +	struct ring_buffer_event *event;
> +
> +	event = ring_buffer_lock_reserve(rctx->buffer, sizeof(*entry) + len);
> +	if (!event)
> +		return 1;
> +
> +	entry = ring_buffer_event_data(event);
> +	memcpy(entry->msg, buf, len);
> +	entry->count = len;
> +
> +	ring_buffer_unlock_commit(rctx->buffer, event);
> +	rlog_wake_up();
> +
> +	return 0;
> +}
> +
> +static struct rlog_entry *peek_next_entry(struct rlog_iter *iter, int cpu,
> +					  unsigned long long *ts)
> +{
> +	struct ring_buffer_event *event;
> +
> +	event = ring_buffer_peek(iter->buffer, cpu, ts, &iter->lost_events);
> +
> +	if (event)
> +		return ring_buffer_event_data(event);
> +
> +	return NULL;
> +}
> +
> +static struct rlog_entry *find_next_entry(struct rlog_iter *iter)
> +{
> +	struct rlog_entry *ent, *next = NULL;
> +	unsigned long long next_ts = 0, ts;
> +	int cpu, next_cpu = -1;
> +
> +	for_each_buffer_cpu (iter->buffer, cpu) {
> +		if (ring_buffer_empty_cpu(iter->buffer, cpu))
> +			continue;
> +
> +		ent = peek_next_entry(iter, cpu, &ts);
> +
> +		if (ent && (!next || ts < next_ts)) {
> +			next = ent;
> +			next_cpu = cpu;
> +			next_ts = ts;
> +		}
> +	}
> +
> +	iter->cpu = next_cpu;
> +
> +	return next;
> +}
> +
> +static struct rlog_iter *find_next_entry_inc(struct rlog_iter *iter)
> +{
> +	iter->ent = find_next_entry(iter);
> +
> +	if (iter->ent)
> +		return iter;

I know you used the name from trace.c, but I hate that name too :-)

No big deal, but perhaps we should rename this to find_next_iter_entry()
or something. The "_inc" is very misleading.

The _inc() part of trace.c is because when it uses the ring buffer
iterator (non consuming read) it does increment the iterator. But on the
consuming read (like you implemented) it does not. But the name is
incorrect for that case.

Lets not spread this falsehood around.


> +
> +	return NULL;
> +}
> +
> +static int buffer_empty(struct rlog_iter *iter)
> +{
> +	int cpu;
> +
> +	for_each_buffer_cpu (iter->buffer, cpu) {
> +		if (!ring_buffer_empty_cpu(iter->buffer, cpu))
> +			return 0;
> +	}
> +
> +	return 1;
> +}
> +
> +static ssize_t rlog_to_user(struct rlog_iter *iter, char __user *ubuf,
> +			    size_t cnt)
> +{
> +	int ret;
> +	int len;
> +
> +	if (!cnt)
> +		goto out;
> +
> +	len = iter->print_buf_len - iter->print_buf_pos;
> +	if (len < 1)
> +		return -EBUSY;
> +
> +	if (cnt > len)
> +		cnt = len;
> +
> +	ret = copy_to_user(ubuf, iter->print_buf + iter->print_buf_pos, cnt);
> +	if (ret == cnt)
> +		return -EFAULT;
> +
> +	cnt -= ret;
> +	iter->print_buf_pos += cnt;
> +
> +out:
> +	return cnt;
> +}
> +
> +static int rlog_open_pipe(struct inode *inode, struct file *file)
> +{
> +	struct rlog_iter *iter;
> +	struct xt_LOG_ring_ctx *tgt = PDE(inode)->data;
> +	int ret = 0;
> +
> +	/* only one consuming reader is allowed */
> +	if (atomic_cmpxchg(&tgt->pipe_in_use, 0, 1)) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	iter = kzalloc(sizeof(*iter), GFP_KERNEL);
> +	if (!iter) {
> +		ret = -ENOMEM;

If we fail here, we just blocked all new users with -EBUSY.

-- Steve


> +		goto out;
> +	}
> +
> +	mutex_init(&iter->lock);
> +	iter->buffer = tgt->buffer;
> +	iter->buffer_name = tgt->name;
> +
> +	file->private_data = iter;
> +out:
> +	return ret;
> +}
> +
> +static unsigned int rlog_poll_pipe(struct file *file, poll_table *poll_table)
> +{
> +	struct rlog_iter *iter = file->private_data;
> +
> +	if (!buffer_empty(iter))
> +		return POLLIN | POLLRDNORM;
> +
> +	poll_wait(file, &rlog_wait, poll_table);
> +
> +	if (!buffer_empty(iter))
> +		return POLLIN | POLLRDNORM;
> +
> +	return 0;
> +}
> +
> +static int rlog_release_pipe(struct inode *inode, struct file *file)
> +{
> +	struct rlog_iter *iter = file->private_data;
> +	struct xt_LOG_ring_ctx *tgt = PDE(inode)->data;
> +
> +	mutex_destroy(&iter->lock);
> +	kfree(iter);
> +	atomic_set(&tgt->pipe_in_use, 0);
> +
> +	return 0;
> +}
> +
> +static void wait_pipe(struct rlog_iter *iter)
> +{
> +	DEFINE_WAIT(wait);
> +
> +	prepare_to_wait(&rlog_wait, &wait, TASK_INTERRUPTIBLE);
> +
> +	if (buffer_empty(iter))
> +		schedule();
> +
> +	finish_wait(&rlog_wait, &wait);
> +}
> +
> +static int rlog_wait_pipe(struct file *file)
> +{
> +	struct rlog_iter *iter = file->private_data;
> +
> +	while (buffer_empty(iter)) {
> +		if (file->f_flags & O_NONBLOCK)
> +			return -EAGAIN;
> +
> +		mutex_unlock(&iter->lock);
> +
> +		wait_pipe(iter);
> +
> +		mutex_lock(&iter->lock);
> +
> +		if (signal_pending(current))
> +			return -EINTR;
> +	}
> +
> +	return 1;
> +}
> +
> +static ssize_t rlog_read_pipe(struct file *file, char __user *ubuf,
> +			      size_t cnt, loff_t *ppos)
> +{
> +	struct rlog_iter *iter = file->private_data;
> +	ssize_t ret;
> +
> +	ret = rlog_to_user(iter, ubuf, cnt);
> +	if (ret != -EBUSY)
> +		goto out;
> +
> +	iter->print_buf_pos = 0;
> +	iter->print_buf_len = 0;
> +
> +	if (cnt >= PAGE_SIZE)
> +		cnt = PAGE_SIZE - 1;
> +
> +	mutex_lock(&iter->lock);
> +again:
> +	ret = rlog_wait_pipe(file);
> +	if (ret <= 0)
> +		goto out_unlock;
> +
> +	while (find_next_entry_inc(iter) != NULL) {
> +		struct rlog_entry *ent;
> +		ent = iter->ent;
> +
> +		if (ent->count >= PAGE_SIZE - iter->print_buf_len)
> +			break;
> +
> +		memcpy(iter->print_buf + iter->print_buf_len, ent->msg,
> +			ent->count);
> +		iter->print_buf_len += ent->count;
> +
> +		ring_buffer_consume(iter->buffer, iter->cpu, NULL,
> +			&iter->lost_events);
> +		if (iter->lost_events)
> +			printk(KERN_WARNING KBUILD_MODNAME ": Ring %s "
> +				"lost %lu events\n", iter->buffer_name,
> +				iter->lost_events);
> +
> +		if (iter->print_buf_len >= cnt)
> +			break;
> +	}
> +
> +	ret = rlog_to_user(iter, ubuf, cnt);
> +
> +	if (iter->print_buf_pos >= iter->print_buf_len) {
> +		iter->print_buf_pos = 0;
> +		iter->print_buf_len = 0;
> +	}
> +
> +	if (ret == -EBUSY)
> +		goto again;
> +out_unlock:
> +	mutex_unlock(&iter->lock);
> +out:
> +	return ret;
> +}
> +
