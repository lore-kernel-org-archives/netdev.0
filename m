From: Dmitry Monakhov <dmonakhov@sw.ru>
Subject: Re: [4/4] DST: Algorithms used in distributed storage.
Date: Wed, 12 Dec 2007 12:12:47 +0300
Message-ID: <20071212091246.GA12871@dmon-lap.sw.ru>
References: <11972872511269@2ka.mipt.ru> <11972872511718@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11972872511718@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14:47 Mon 10 Dec     , Evgeniy Polyakov wrote:
> 
> Algorithms used in distributed storage.
> Mirror and linear mapping code.
Hi, i've finally take a look on your DST solution.
It seems what your current implementation will not work on nonstandard
devices for example software raid0.
other comments are follows:
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> 
> diff --git a/drivers/block/dst/alg_linear.c b/drivers/block/dst/alg_linear.c
> new file mode 100644
> index 0000000..9dc0976
> --- /dev/null
> +++ b/drivers/block/dst/alg_linear.c
> @@ -0,0 +1,105 @@
> +/*
> + * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> + * All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/dst.h>
> +
> +static struct dst_alg *alg_linear;
> +
> +/*
> + * This callback is invoked when node is removed from storage.
> + */
> +static void dst_linear_del_node(struct dst_node *n)
> +{
> +}
> +
> +/*
> + * This callback is invoked when node is added to storage.
> + */
> +static int dst_linear_add_node(struct dst_node *n)
> +{
> +	struct dst_storage *st = n->st;
> +
> +	dprintk("%s: disk_size: %llu, node_size: %llu.\n",
> +			__func__, st->disk_size, n->size);
> +
> +	mutex_lock(&st->tree_lock);
> +	n->start = st->disk_size;
> +	st->disk_size += n->size;
> +	set_capacity(st->disk, st->disk_size);
> +	mutex_unlock(&st->tree_lock);
> +
> +	return 0;
> +}
> +
> +static int dst_linear_remap(struct dst_request *req)
> +{
> +	int err;
> +
> +	if (req->node->bdev) {
> +		generic_make_request(req->bio);
> +		return 0;
> +	}
> +
> +	err = kst_check_permissions(req->state, req->bio);
> +	if (err)
> +		return err;
> +
> +	return req->state->ops->push(req);
> +}
> +
> +/*
> + * Failover callback - it is invoked each time error happens during
> + * request processing.
> + */
> +static int dst_linear_error(struct kst_state *st, int err)
> +{
> +	if (err)
> +		set_bit(DST_NODE_FROZEN, &st->node->flags);
> +	else
> +		clear_bit(DST_NODE_FROZEN, &st->node->flags);
> +	return 0;
> +}
> +
> +static struct dst_alg_ops alg_linear_ops = {
> +	.remap		= dst_linear_remap,
> +	.add_node 	= dst_linear_add_node,
> +	.del_node 	= dst_linear_del_node,
> +	.error		= dst_linear_error,
> +	.owner		= THIS_MODULE,
> +};
> +
> +static int __devinit alg_linear_init(void)
> +{
> +	alg_linear = dst_alloc_alg("alg_linear", &alg_linear_ops);
> +	if (!alg_linear)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void __devexit alg_linear_exit(void)
> +{
> +	dst_remove_alg(alg_linear);
> +}
> +
> +module_init(alg_linear_init);
> +module_exit(alg_linear_exit);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
> +MODULE_DESCRIPTION("Linear distributed algorithm.");
> diff --git a/drivers/block/dst/alg_mirror.c b/drivers/block/dst/alg_mirror.c
> new file mode 100644
> index 0000000..3c457ff
> --- /dev/null
> +++ b/drivers/block/dst/alg_mirror.c
> @@ -0,0 +1,1128 @@
> +/*
> + * 2007+ Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> + * All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/poll.h>
> +#include <linux/dst.h>
> +
> +struct dst_mirror_node_data
> +{
> +	u64		age;
> +};
> +
> +struct dst_mirror_priv
> +{
> +	unsigned int		chunk_num;
> +
> +	u64			last_start;
> +
> +	spinlock_t		backlog_lock;
> +	struct list_head	backlog_list;
> +
> +	struct dst_mirror_node_data	old_data, new_data;
> +
> +	unsigned long		*chunk;
> +};
> +
> +static struct dst_alg *alg_mirror;
> +static struct bio_set *dst_mirror_bio_set;
> +
> +static int dst_mirror_resync(struct dst_node *n, int ndp);
> +
> +static void dst_mirror_mark_sync(struct dst_node *n)
> +{
> +	if (test_bit(DST_NODE_NOTSYNC, &n->flags)) {
> +		struct dst_mirror_priv *priv = n->priv;
> +
> +		clear_bit(DST_NODE_NOTSYNC, &n->flags);
> +		dprintk("%s: node: %p, %llu:%llu synchronization "
> +				"has been completed.\n",
> +			__func__, n, n->start, n->size);
> +		priv->old_data.age = 0;
> +	}
> +}
> +
> +static void dst_mirror_mark_notsync(struct dst_node *n)
> +{
> +	if (!test_bit(DST_NODE_NOTSYNC, &n->flags)) {
> +		set_bit(DST_NODE_NOTSYNC, &n->flags);
> +		dprintk("%s: not synced node n: %p.\n", __func__, n);
> +	}
> +}
> +
> +static void dst_mirror_mark_node_notsync(struct dst_node *n)
> +{
> +	struct dst_mirror_priv *p = n->priv;
> +
> +	memset(p->chunk, 0xff, DIV_ROUND_UP(p->chunk_num, BITS_PER_LONG)*sizeof(long));
> +	dst_mirror_mark_notsync(n);
> +	dst_mirror_resync(n, 0);
> +}
> +
> +static void dst_mirror_mark_node_sync(struct dst_node *n)
> +{
> +	struct dst_mirror_priv *p = n->priv;
> +
> +	memset(p->chunk, 0x0, DIV_ROUND_UP(p->chunk_num, BITS_PER_LONG)*sizeof(long));
> +	dst_mirror_mark_sync(n);
> +}
> +
> +static ssize_t dst_mirror_mark_dirty(struct device *dev, struct device_attribute *attr,
> +			 const char *buf, size_t count)
> +{
> +	struct dst_node *n = container_of(dev, struct dst_node, device);
> +
> +	dst_mirror_mark_node_notsync(n);
> +	return count;
> +}
> +
> +static ssize_t dst_mirror_mark_clean(struct device *dev, struct device_attribute *attr,
> +			 const char *buf, size_t count)
> +{
> +	struct dst_node *n = container_of(dev, struct dst_node, device);
> +
> +	dst_mirror_mark_node_sync(n);
> +	return count;
> +}
> +
> +static ssize_t dst_mirror_chunk_mask_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct dst_node *n = container_of(dev, struct dst_node, device);
> +	struct dst_mirror_priv *priv = n->priv;
> +	unsigned int i;
> +	int rest = PAGE_SIZE, rest_bits = priv->chunk_num;
> +
> +	for (i = 0; i < DIV_ROUND_UP(priv->chunk_num, BITS_PER_LONG); ++i) {
> +		int bit, j;
> +
> +		for (j = 0; j < min(BITS_PER_LONG, rest_bits); ++j) {
> +			bit = (priv->chunk[i] >> j) & 1;
> +			sprintf(buf, "%c", (bit)?'+':'-');
> +			buf++;
> +		}
> +
> +		rest_bits -= j;
> +		rest -= j;
> +
> +		if (rest < BITS_PER_LONG || rest_bits <= 0)
> +			break;
> +	}
> +
> +	return PAGE_SIZE - rest;
> +}
> +
> +static struct device_attribute dst_mirror_attrs[] = {
> +	__ATTR(chunks, S_IRUGO, dst_mirror_chunk_mask_show, NULL),
> +	__ATTR(dirty, S_IWUSR, NULL, dst_mirror_mark_dirty),
> +	__ATTR(clean, S_IWUSR, NULL, dst_mirror_mark_clean),
> +};
> +
> +/*
> + * This callback is invoked when node is removed from storage.
> + */
> +static void dst_mirror_del_node(struct dst_node *n)
> +{
> +	struct dst_mirror_priv *priv = n->priv;
> +	struct dst_request *req, *tmp;
> +
> +	list_for_each_entry_safe(req, tmp, &priv->backlog_list, request_list_entry) {
> +		kst_del_req(req);
> +		kst_complete_req(req, -ENODEV);
> +	}
> +
> +	if (priv) {
> +		vfree(priv->chunk);
> +		kfree(priv);
> +		n->priv = NULL;
> +	}
> +
> +	if (n->device.parent == &n->st->device) {
> +		int i;
> +
> +		for (i=0; i<ARRAY_SIZE(dst_mirror_attrs); ++i)
> +			device_remove_file(&n->device, &dst_mirror_attrs[i]);
> +	}
> +}
> +
> +static void dst_mirror_handle_priv(struct dst_node *n)
> +{
> +	if (n->priv) {
> +		int err, i;
> +
> +		for (i=0; i<ARRAY_SIZE(dst_mirror_attrs); ++i)
> +			err = device_create_file(&n->device,
> +					&dst_mirror_attrs[i]);
> +	}
> +}
> +
> +static void dst_mirror_destructor(struct bio *bio)
> +{
> +	dprintk("%s: bio: %p.\n", __func__, bio);
> +	bio_free(bio, dst_mirror_bio_set);
> +}
> +
> +/*
> + * This function copies node's private on-disk data from first node
> + * to the new one.
> + */
> +static int dst_mirror_get_node_data(struct dst_node *n,
> +		struct dst_mirror_node_data *ndata, int old)
> +{
> +	struct dst_node *first;
> +	struct dst_mirror_priv *p;
> +
> +	mutex_lock(&n->st->tree_lock);
> +	first = dst_storage_tree_search(n->st, n->start);
> +	mutex_unlock(&n->st->tree_lock);
> +	if (!first) {
> +		dprintk("%s: there are no nodes in the storage.\n", __func__);
> +		return -ENODEV;
> +	}
> +
> +	p = first->priv;
> +	memcpy(ndata, (old)?&p->old_data:&p->new_data, sizeof(struct dst_mirror_node_data));
> +
> +	dst_node_put(first);
> +	return 0;
> +}
> +
> +struct dst_mirror_ndp
> +{
> +	int			err;
> +	struct page		*page;
> +	struct completion	complete;
> +};
> +
> +static void dst_mirror_ndb_complete(struct dst_mirror_ndp *cmp, int err)
> +{
> +	cmp->err = err;
> +	dprintk("%s: completing request: cmp: %p, err: %d.\n",
> +			__func__, cmp, err);
> +	complete(&cmp->complete);
> +}
> +
> +static void dst_mirror_ndp_bio_endio(struct dst_request *req, int err)
> +{
> +	struct dst_mirror_ndp *cmp = req->bio->bi_private;
> +
> +	dst_mirror_ndb_complete(cmp, err);
> +}
> +
> +static int dst_mirror_ndp_end_io(struct bio *bio, unsigned int size, int err)
> +{
> +	struct dst_mirror_ndp *cmp = bio->bi_private;
> +
> +	if (bio->bi_size)
> +		return 0;
> +
> +	dst_mirror_ndb_complete(cmp, err);
> +	return 0;
> +}
> +
> +/*
> + * This function reads or writes node's private data from underlying media.
> + */
> +static int dst_mirror_process_node_data(struct dst_node *n,
> +		struct dst_mirror_node_data *ndata, int op)
> +{
> +	struct bio *bio;
> +	int err = -ENOMEM;
> +	struct dst_mirror_ndp *cmp;
> +	void *addr;
> +
> +	cmp = kzalloc(sizeof(struct dst_mirror_ndp), GFP_KERNEL);
> +	if (!cmp)
> +		goto err_out_exit;
> +
> +	cmp->page = alloc_page(GFP_NOIO);
> +	if (!cmp->page)
> +		goto err_out_free_cmp;
> +
> +	addr = kmap(cmp->page);
> +
> +	init_completion(&cmp->complete);
> +
> +	if (op == WRITE)
> +		memcpy(addr, ndata, sizeof(struct dst_mirror_node_data));
> +
> +	bio = bio_alloc_bioset(GFP_NOIO, 1, dst_mirror_bio_set);
> +	if (!bio)
> +		goto err_out_free_page;
> +
> +	bio->bi_rw = op;
> +	bio->bi_private = cmp;
> +	bio->bi_sector = n->size;
> +	bio->bi_bdev = n->bdev;
> +	bio->bi_destructor = dst_mirror_destructor;
> +	bio->bi_end_io = dst_mirror_ndp_end_io;
> +
> +	err = bio_add_pc_page(n->st->queue, bio, cmp->page, 512, 0);
> +	if (err <= 0)
> +		goto err_out_free_bio;
> +
> +	if (n->bdev) {
> +		generic_make_request(bio);
> +	} else {
> +		struct dst_request req;
> +
> +		memset(&req, 0, sizeof(struct dst_request));
> +
> +		req.node = n;
> +		req.state = n->state;
> +		req.start = bio->bi_sector;
> +		req.size = req.orig_size = bio->bi_size;
> +		req.bio = bio;
> +		req.idx = bio->bi_idx;
> +		req.num = bio->bi_vcnt;
> +		req.flags = 0;
> +		req.offset = 0;
> +		req.bio_endio = &dst_mirror_ndp_bio_endio;
> +		req.callback = &kst_data_callback;
> +
> +		err = req.state->ops->push(&req);
> +		if (err)
> +			req.bio_endio(&req, err);
> +	}
> +
> +	dprintk("%s: waiting for completion: bio: %p, cmp: %p.\n",
> +			__func__, bio, cmp);
> +
> +	wait_for_completion(&cmp->complete);
> +
> +	err = cmp->err;
> +
> +	if (!err && (op != WRITE))
> +		memcpy(ndata, addr, sizeof(struct dst_mirror_node_data));
> +
> +	kunmap(cmp->page);
<< MINOR_BUG:
   You has forgot to unmap page on error path, so IMHO it is better to move
   kunmap to "err_out_free_cmp" label.
> +
> +	dprintk("%s: freeing bio: %p, err: %d.\n", __func__, bio, err);
> +
> +err_out_free_bio:
> +	bio_put(bio);
> +err_out_free_page:
> +	__free_page(cmp->page);
> +err_out_free_cmp:
> +	kfree(cmp);
> +err_out_exit:
> +	return err;
> +}
> +
> +/*
> + * This function reads node's private data from underlying media.
> + */
> +static int dst_mirror_read_node_data(struct dst_node *n,
> +		struct dst_mirror_node_data *ndata)
> +{
> +	return dst_mirror_process_node_data(n, ndata, READ);
> +}
> +
> +/*
> + * This function writes node's private data from underlying media.
> + */
> +static int dst_mirror_write_node_data(struct dst_node *n,
> +		struct dst_mirror_node_data *ndata)
> +{
> +	dprintk("%s: writing new age: %llx, node: %p %llu-%llu.\n",
> +			__func__, ndata->age, n, n->start, n->size);
> +	return dst_mirror_process_node_data(n, ndata, WRITE);
> +}
> +
> +static int dst_mirror_ndp_setup(struct dst_node *n, int first_node, int clean_on_sync)
> +{
> +	struct dst_mirror_priv *p = n->priv;
> +	int sync = 1, err;
> +
> +	err = dst_mirror_read_node_data(n, &p->old_data);
> +	if (err)
> +		return err;
> +
> +	if (first_node) {
> +		p->new_data.age = *(u64 *)&n->st;
> +
> +		dprintk("%s: first age: %llx -> %llx. "
> +			"Old will be set to new for the first node.\n",
> +				__func__, p->old_data.age, p->new_data.age);
> +
> +		err = dst_mirror_write_node_data(n, &p->new_data);
> +		if (err)
> +			return err;
> +		p->old_data.age = p->new_data.age;
> +	} else {
> +		err = dst_mirror_get_node_data(n, &p->new_data, 1);
> +		if (err)
> +			return err;
> +
> +		if (p->new_data.age != p->old_data.age) {
> +			sync = 0;
> +			dprintk("%s: node %llu:%llu is not synced with the first "
> +					"node (old != new): %llx != %llx.\n",
> +					__func__, n->start, n->start+n->size,
> +					p->old_data.age, p->new_data.age);
> +			err = dst_mirror_get_node_data(n, &p->new_data, 0);
> +			if (err)
> +				return err;
> +		} else {
> +			err = dst_mirror_get_node_data(n, &p->new_data, 0);
> +			if (err)
> +				return err;
> +
> +			err = dst_mirror_write_node_data(n, &p->new_data);
> +			if (err)
> +				return err;
> +
> +			dprintk("%s: node %llu:%llu is in sync with the first node.\n",
> +					__func__, n->start, n->start+n->size);
> +		}
> +	}
> +
> +	if (!sync)
> +		dst_mirror_mark_node_notsync(n);
> +	else if (clean_on_sync)
> +		dst_mirror_mark_node_sync(n);
> +
> +	dprintk("%s: age: old: %llx, new: %llx.\n", __func__, p->old_data.age, p->new_data.age);
> +
> +	return 0;
> +}
> +
> +/*
> + * This callback is invoked when node is added to storage.
> + */
> +static int dst_mirror_add_node(struct dst_node *n)
> +{
> +	struct dst_storage *st = n->st;
> +	struct dst_mirror_priv *priv;
> +	int err = -ENOMEM, first_node = 0;
> +	u64 disk_size;
> +
> +	n->size--; /* A sector size actually. */
> +
> +	mutex_lock(&st->tree_lock);
> +	disk_size = st->disk_size;
> +	if (st->disk_size) {
> +		st->disk_size = min(n->size, st->disk_size);
> +	} else {
> +		st->disk_size = n->size;
> +		first_node = 1;
> +	}
> +	mutex_unlock(&st->tree_lock);
> +
> +	priv = kzalloc(sizeof(struct dst_mirror_priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	priv->chunk_num = st->disk_size;
> +
> +	priv->chunk = vmalloc(DIV_ROUND_UP(priv->chunk_num, BITS_PER_LONG) * sizeof(long));
<< Ohhh. My. I want to add my 500G hdd. Do you really wanna
   say what i have to store 128Mb in memory object for this.
> +	if (!priv->chunk)
> +		goto err_out_free;
> +
> +	spin_lock_init(&priv->backlog_lock);
> +	INIT_LIST_HEAD(&priv->backlog_list);
> +
> +	dprintk("%s: %llu:%llu, chunk_num: %u, disk_size: %llu.\n\n",
> +			__func__, n->start, n->size,
> +			priv->chunk_num, st->disk_size);
> +
> +	n->priv_callback = &dst_mirror_handle_priv;
> +	n->priv = priv;
> +
> +	err = dst_mirror_ndp_setup(n, first_node, 1);
> +	if (err)
> +		goto err_out_free_chunk;
> +
> +	return 0;
> +
> +err_out_free_chunk:
> +	vfree(priv->chunk);
> +err_out_free:
> +	kfree(priv);
> +	n->priv = NULL;
> +
> +	mutex_lock(&st->tree_lock);
> +	st->disk_size = disk_size;
> +	mutex_unlock(&st->tree_lock);
> +	return err;
> +}
> +
> +static void dst_mirror_sync_destructor(struct bio *bio)
> +{
> +	struct bio_vec *bv;
> +	int i;
> +
> +	bio_for_each_segment(bv, bio, i)
> +		__free_page(bv->bv_page);
> +	bio_free(bio, dst_mirror_bio_set);
> +}
> +
> +/*
> + * Without errors it is always called under node's request lock,
> + * so it is safe to requeue them.
> + */
> +static void dst_mirror_bio_error(struct dst_request *req, int err)
> +{
> +	int i;
> +	struct dst_mirror_priv *priv = req->node->priv;
> +	unsigned int num, idx;
> +	u64 start = req->start - to_sector(req->orig_size - req->size);
> +
> +	if (err)
> +		dst_mirror_mark_notsync(req->node);
> +
> +	priv->last_start = req->start;
> +
> +	idx = start;
> +	num = to_sector(req->orig_size);
> +
> +	dprintk("%s: %llu:%llu start: %llu, size: %llu, "
> +		"chunk_num: %u, idx: %d, num: %d, err: %d, node: %p.\n",
> +		__func__, req->node->start, req->node->size,
> +		start, req->orig_size, priv->chunk_num,
> +		idx, num, err, req->node);
> +
> +	if (unlikely(idx >= priv->chunk_num || idx + num > priv->chunk_num)) {
> +		dprintk("%s: %llu:%llu req: %p, start: %llu, orig_size: %llu, "
> +			"req_start: %llu, req_size: %llu, "
> +			"chunk_num: %u, idx: %d, num: %d, err: %d.\n",
> +			__func__, req->node->start, req->node->size, req,
> +			start, req->orig_size,
> +			req->start, req->size,
> +			priv->chunk_num, idx, num, err);
> +		return;
> +	}
> +
> +	if (err) {
> +		for (i=0; i<num; ++i)
> +			__set_bit(idx+i, priv->chunk);
> +	} else {
> +		for (i=0; i<num; ++i)
> +			__clear_bit(idx+i, priv->chunk);
> +	}
> +}
> +
> +static void dst_mirror_sync_req_endio(struct dst_request *req, int err)
> +{
> +	struct dst_node *n = req->node;
> +	struct dst_mirror_priv *p = req->node->priv;
> +	int i;
> +	unsigned long notsync = 0;
> +
> +	dst_mirror_bio_error(req, err);
> +
> +	dprintk("%s: freeing bio: %p, bi_size: %u, "
> +			"orig_size: %llu, req: %p, node: %p.\n",
> +		__func__, req->bio, req->bio->bi_size, req->orig_size, req,
> +		req->node);
> +
> +	bio_put(req->bio);
> +
> +	if (!test_bit(DST_NODE_NOTSYNC, &n->flags))
> +		return;
> +
> +	for (i = 0; i < DIV_ROUND_UP(p->chunk_num, BITS_PER_LONG); ++i) {
> +		notsync = p->chunk[i];
> +		if (notsync)
> +			break;
> +	}
> +
> +	if (notsync) {
> +		dprintk("%s: %d/%d sync: %lx, ffs: %lu, chunk_num (modulo %u): %d.\n",
> +				__func__, i, DIV_ROUND_UP(p->chunk_num, BITS_PER_LONG),
> +				notsync, __ffs(notsync), BITS_PER_LONG,
> +				p->chunk_num%BITS_PER_LONG);
> +		if (i != DIV_ROUND_UP(p->chunk_num, BITS_PER_LONG) - 1)
> +			return;
> +
> +		if (__ffs(notsync) != (p->chunk_num%BITS_PER_LONG))
> +			return;
> +	}
> +
> +	dst_mirror_mark_sync(n);
> +}
> +
> +static int dst_mirror_sync_endio(struct bio *bio, unsigned int size, int err)
> +{
> +	struct dst_request *req = bio->bi_private;
> +	struct dst_node *n = req->node;
> +	struct dst_mirror_priv *priv = n->priv;
> +	unsigned long flags;
> +
> +	dprintk("%s: bio: %p, err: %d, size: %u, req: %p.\n",
> +			__func__, bio, err, bio->bi_size, req);
> +
> +	if (bio->bi_size)
> +		return 1;
> +
> +	bio->bi_rw = WRITE;
> +	bio->bi_size = req->orig_size;
> +	bio->bi_sector = req->start;
> +
> +	if (!err) {
> +		spin_lock_irqsave(&priv->backlog_lock, flags);
> +		list_add_tail(&req->request_list_entry, &priv->backlog_list);
> +		spin_unlock_irqrestore(&priv->backlog_lock, flags);
> +		kst_wake(req->state);
> +	} else {
> +		req->bio_endio(req, err);
> +		dst_free_request(req);
> +	}
> +	return 0;
> +}
> +
> +static int dst_mirror_sync_block(struct dst_node *n,
> +		int bit_start, int bit_num)
> +{
> +	u64 start = to_bytes(bit_start);
> +	u32 size = to_bytes(bit_num);
> +	struct bio *bio;
> +	unsigned int nr_pages = DIV_ROUND_UP(size, PAGE_SIZE), i;
> +	struct page *page;
> +	int err = -ENOMEM;
> +	struct dst_request *req;
> +
> +	dprintk("%s: bit_start: %d, bit_num: %d, start: %llu, nr_pages: %u, "
> +			"disk_size: %llu.\n",
> +			__func__, bit_start, bit_num, start, nr_pages,
> +			n->st->disk_size);
> +
> +	while (nr_pages) {
> +		req = dst_clone_request(NULL, n->w->req_pool);
> +		if (!req)
> +			return -ENOMEM;
> +
> +		bio = bio_alloc_bioset(GFP_NOIO, nr_pages, dst_mirror_bio_set);
> +		if (!bio)
> +			goto err_out_free_req;
> +
> +		bio->bi_rw = READ;
> +		bio->bi_private = req;
> +		bio->bi_sector = to_sector(start);
> +		bio->bi_bdev = NULL;
> +		bio->bi_destructor = dst_mirror_sync_destructor;
> +		bio->bi_end_io = dst_mirror_sync_endio;
> +
> +		for (i = 0; i < nr_pages; ++i) {
> +			err = -ENOMEM;
> +
> +			page = alloc_page(GFP_NOIO);
> +			if (!page)
> +				break;
> +
> +			err = bio_add_pc_page(n->st->queue, bio, page,
> +					min_t(u32, PAGE_SIZE, size), 0);
> +			if (err <= 0)
> +				break;
> +			size -= err;
> +			err = 0;
> +		}
> +
> +		if (err && !bio->bi_vcnt)
> +			goto err_out_put_bio;
> +
> +		req->node = n;
> +		req->state = n->state;
> +		req->start = bio->bi_sector;
> +		req->size = req->orig_size = bio->bi_size;
> +		req->bio = bio;
> +		req->idx = bio->bi_idx;
> +		req->num = bio->bi_vcnt;
> +		req->flags = DST_REQ_CHECK_QUEUE;
> +		req->offset = 0;
> +		req->bio_endio = &dst_mirror_sync_req_endio;
> +		req->callback = &kst_data_callback;
> +
> +		dprintk("%s: start: %llu, size: %llu/%u, bio: %p, req: %p, "
> +				"node: %p.\n",
> +				__func__, req->start, req->size, nr_pages, bio,
> +				req, req->node);
> +
> +		err = n->st->queue->make_request_fn(n->st->queue, bio);
<< Why direct make_request_fn instead of generic_make_request?

> +		if (err)
> +			goto err_out_put_bio;
> +
> +		nr_pages -= bio->bi_vcnt;
> +		start += bio->bi_size;
> +	}
> +
> +	return 0;
> +
> +err_out_put_bio:
> +	bio_put(bio);
> +err_out_free_req:
> +	dst_free_request(req);
> +	return err;
> +}
> +
> +/*
> + * Resync logic.
> + *
> + * System allocates and queues requests for number of regions.
> + * Each request initially is reading from the one of the nodes.
> + * When it is completed, system checks if given region was already
> + * written to, and in such case just drops read request, otherwise
> + * it writes it to the node being updated. Any write clears not-uptodate
> + * bit, which is used as a flag that region must be synchronized or not.
> + * Reading is never performed from the node under resync.
> + */
> +static int dst_mirror_resync(struct dst_node *n, int ndp)
> +{
> +	struct dst_mirror_priv *priv = n->priv;
> +	int err = 0, sync = 1, total = priv->chunk_num;
> +	unsigned int i;
> +
> +	dprintk("%s: node: %p, %llu:%llu synchronization has been started.\n",
> +			__func__, n, n->start, n->size);
> +
> +	if (ndp) {
> +		err = dst_mirror_ndp_setup(n, 0, 0);
> +		if (err)
> +			return err;
> +	}
> +
> +	for (i = 0; i < DIV_ROUND_UP(priv->chunk_num, BITS_PER_LONG); ++i) {
> +		int bit, num, start;
> +		unsigned long word = priv->chunk[i];
> +
> +		if (!word)
> +			continue;
> +
> +		num = 0;
> +		start = -1;
> +		while (word && num < BITS_PER_LONG) {
> +			bit = __ffs(word);
> +			if (start == -1)
> +				start = bit;
> +			num++;
<< MINOR_BUG: Seems you have misstyped here. AFAIU @num represent position
   of last non zero bit (start + num == last_non_zero_bit_pos)
			if (start == -1) {
                		start = bit;
                     		num = 1;
			} else
                                num += bit;

> +			word >>= (bit+1);
> +
> +			if (--total == 0)
> +				break;
> +		}
> +
> +		if (start != -1) {
> +			err = dst_mirror_sync_block(n, start + i*BITS_PER_LONG,
> +					num);
> +			if (err)
> +				break;
> +			sync = 0;
> +		}
> +
> +		if (total == 0)
> +			break;
> +	}
> +
> +	return err;
> +}
> +
> +static int dst_mirror_end_io(struct bio *bio, unsigned int size, int err)
> +{
> +	struct dst_request *req = bio->bi_private;
> +
> +	if (bio->bi_size)
> +		return 0;
> +
> +	dprintk("%s: req: %p, bio: %p, req->bio: %p, err: %d.\n",
> +			__func__, req, bio, req->bio, err);
> +	req->bio_endio(req, err);
> +	bio_put(bio);
> +	return 0;
> +}
> +
> +static void dst_mirror_read_endio(struct dst_request *req, int err)
> +{
> +	dst_mirror_bio_error(req, err);
> +
> +	if (err && req->state)
> +		kst_wake(req->state);
> +
> +	if (!err || req->callback)
> +		kst_bio_endio(req, err);
> +}
> +
> +static void dst_mirror_write_endio(struct dst_request *req, int err)
> +{
> +	dst_mirror_bio_error(req, err);
> +
> +	if (err && req->state)
> +		kst_wake(req->state);
> +
> +	req = req->priv;
> +
> +	dprintk("%s: req: %p, priv: %p err: %d, bio: %p, "
> +			"cnt: %d, orig_size: %llu.\n",
> +		__func__, req, req->priv, err, req->bio,
> +		atomic_read(&req->refcnt), req->orig_size);
> +
> +	if (atomic_dec_and_test(&req->refcnt)) {
> +		bio_endio(req->bio, req->orig_size, 0);
> +		dst_free_request(req);
> +	}
> +}
> +
> +static int dst_mirror_process_request_nosync(struct dst_request *req,
> +		struct dst_node *n)
> +{
> +	int err = 0;
> +
> +	/*
> +	 * Block layer requires to clone a bio.
> +	 */
> +	if (n->bdev) {
> +		struct bio *clone = bio_alloc_bioset(GFP_NOIO,
> +			req->bio->bi_max_vecs, dst_mirror_bio_set);
> +
> +		__bio_clone(clone, req->bio);
> +
> +		clone->bi_bdev = n->bdev;
> +		clone->bi_destructor = dst_mirror_destructor;
> +		clone->bi_private = req;
> +		clone->bi_end_io = &dst_mirror_end_io;
> +
> +		dprintk("%s: clone: %p, bio: %p, req: %p.\n",
> +				__func__, clone, req->bio, req);
> +
> +		generic_make_request(clone);
> +	} else {
> +		struct dst_request nr;
> +		/*
> +		 * Network state processing engine will clone request
> +		 * by itself if needed. We can not use the same structure
> +		 * here, since number of its fields will be modified.
> +		 */
> +		memcpy(&nr, req, sizeof(struct dst_request));
> +
> +		nr.node = n;
> +		nr.state = n->state;
> +		nr.priv = req;
> +
> +		err = kst_check_permissions(n->state, req->bio);
> +		if (!err)
> +			err = n->state->ops->push(&nr);
> +	}
> +
> +	dprintk("%s: req: %p, n: %p, bdev: %p, err: %d.\n",
> +			__func__, req, n, n->bdev, err);
> +
> +	return err;
> +}
> +
> +static void dst_mirror_sync_requeue(struct dst_node *n)
> +{
> +	struct dst_mirror_priv *p = n->priv;
> +	struct dst_request *req;
> +	unsigned int num, idx, i;
> +	u64 start;
> +	unsigned long flags;
> +	int err;
> +
> +	while (!list_empty(&p->backlog_list)) {
> +		req = NULL;
> +		spin_lock_irqsave(&p->backlog_lock, flags);
> +		if (!list_empty(&p->backlog_list)) {
> +			req = list_entry(p->backlog_list.next,
> +					struct dst_request,
> +					request_list_entry);
> +			list_del_init(&req->request_list_entry);
> +		}
> +		spin_unlock_irqrestore(&p->backlog_lock, flags);
> +
> +		if (!req)
> +			break;
> +
> +		start = req->start - to_sector(req->orig_size - req->size);
> +
> +		idx = start;
> +		num = to_sector(req->orig_size);
> +
> +		for (i=0; i<num; ++i)
> +			if (test_bit(idx+i, p->chunk))
> +				break;
> +
> +		dprintk("%s: idx: %u, num: %u, i: %u, req: %p, "
> +				"start: %llu, size: %llu.\n",
> +				__func__, idx, num, i, req,
> +				req->start, req->orig_size);
> +
> +		err = -1;
> +		if (i != num) {
> +			err = dst_mirror_process_request_nosync(req, n);
> +			if (!err)
> +				dst_free_request(req);
> +		}
> +
> +		if (err)
> +			kst_complete_req(req, err);
> +	}
> +
> +	if (!test_bit(DST_NODE_NOTSYNC, &n->flags) &&
> +			p->old_data.age != p->new_data.age) {
> +		dst_mirror_write_node_data(n, &p->new_data);
> +		p->old_data.age = p->new_data.age;
> +	}
> +}
> +
> +static int dst_mirror_process_request(struct dst_request *req,
> +		struct dst_node *n)
> +{
> +	dst_mirror_sync_requeue(n);
> +	return dst_mirror_process_request_nosync(req, n);
> +}
> +
> +static int dst_mirror_write(struct dst_request *oreq)
> +{
> +	struct dst_node *n, *node = oreq->node;
> +	struct dst_request *req;
> +	int num, err = 0, err_num = 0, orig_num;
> +
> +	req = dst_clone_request(oreq, oreq->node->w->req_pool);
> +	if (!req) {
> +		err = -ENOMEM;
> +		goto err_out_exit;
> +	}
> +
> +	req->priv = req;
> +
> +	/*
> +	 * This logic is pretty simple - req->bio_endio will not
> +	 * call bio_endio() until all mirror devices completed
> +	 * processing of the request (no matter with or without error).
> +	 * Mirror's req->bio_endio callback will take care of that.
> +	 */
> +	orig_num = num = atomic_read(&req->node->shared_num) + 1;
> +	atomic_set(&req->refcnt, num);
> +
> +	req->bio_endio = &dst_mirror_write_endio;
> +
> +	dprintk("\n%s: req: %p, mirror to %d nodes.\n",
> +			__func__, req, num);
> +
> +	err = dst_mirror_process_request(req, node);
> +	if (err)
> +		err_num++;
> +
> +	if (--num) {
> +		list_for_each_entry(n, &node->shared, shared) {
> +			dprintk("\n%s: req: %p, start: %llu, size: %llu, "
> +					"num: %d, n: %p, state: %p.\n",
> +				__func__, req, req->start,
> +				req->size, num, n, n->state);
> +
> +			err = dst_mirror_process_request(req, n);
> +			if (err)
> +				err_num++;
> +
> +			if (--num <= 0)
> +				break;
> +		}
> +	}
> +
> +	if (err_num == orig_num) {
> +		dprintk("%s: req: %p, num: %d, err: %d.\n",
> +				__func__, req, num, err);
> +		err = -ENODEV;
> +		goto err_out_exit;
> +	}
> +
> +	return 0;
> +
> +err_out_exit:
> +	return err;
> +}
> +
> +static int dst_mirror_read(struct dst_request *req)
> +{
> +	struct dst_node *node = req->node, *n, *min_dist_node;
> +	struct dst_mirror_priv *priv = node->priv;
> +	u64 dist, d;
> +	int err;
> +
> +	req->bio_endio = &dst_mirror_read_endio;
> +
> +	do {
> +		err = -ENODEV;
> +		min_dist_node = NULL;
> +		dist = -1ULL;
> +
> +		/*
> +		 * Reading is never performed from the node under resync.
> +		 * If this will cause any troubles (like all nodes must be
> +		 * resynced between each other), this check can be removed
> +		 * and per-chunk dirty bit can be tested instead.
> +		 */
> +
> +		if (!test_bit(DST_NODE_NOTSYNC, &node->flags)) {
> +			priv = node->priv;
> +			if (req->start > priv->last_start)
> +				dist = req->start - priv->last_start;
> +			else
> +				dist = priv->last_start - req->start;
> +			min_dist_node = req->node;
> +		}
> +
> +		list_for_each_entry(n, &node->shared, shared) {
> +			if (test_bit(DST_NODE_NOTSYNC, &n->flags))
> +				continue;
> +
> +			priv = n->priv;
> +
> +			if (req->start > priv->last_start)
> +				d = req->start - priv->last_start;
> +			else
> +				d = priv->last_start - req->start;
> +
> +			if (d < dist)
> +				min_dist_node = n;
> +		}
> +
> +		if (!min_dist_node)
> +			break;
> +
> +		req->node = min_dist_node;
> +		req->state = req->node->state;
> +
> +		if (req->node->bdev) {
> +			req->bio->bi_bdev = req->node->bdev;
> +			generic_make_request(req->bio);
> +			err = 0;
> +			break;
> +		}
> +
> +		err = req->state->ops->push(req);
> +		if (err) {
> +			dprintk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
> +				__func__, req, req->bio, min_dist_node, err);
> +			dst_mirror_mark_notsync(req->node);
> +		}
> +	} while (err && min_dist_node);
> +
> +	if (err || !min_dist_node) {
> +		dprintk("%s: req: %p, bio: %p, node: %p, err: %d.\n",
> +			__func__, req, req->bio, min_dist_node, err);
> +		if (!err)
> +			err = -ENODEV;
> +	}
> +	dprintk("%s: req: %p, err: %d.\n", __func__, req, err);
> +	return err;
> +}
> +
> +/*
> + * This callback is invoked from block layer request processing function,
> + * its task is to remap block request to different nodes.
> + */
> +static int dst_mirror_remap(struct dst_request *req)
> +{
> +	int (*remap[])(struct dst_request *) =
> +		{&dst_mirror_read, &dst_mirror_write};
> +
> +	return remap[bio_rw(req->bio) == WRITE](req);
> +}
> +
> +static int dst_mirror_error(struct kst_state *st, int err)
> +{
> +	struct dst_request *req, *tmp;
> +	unsigned int revents = st->socket->ops->poll(NULL, st->socket, NULL);
> +
> +	dprintk("%s: err: %d, revents: %x, notsync: %d.\n",
> +			__func__, err, revents,
> +			test_bit(DST_NODE_NOTSYNC, &st->node->flags));
> +
> +	if (err == -EEXIST)
> +		return err;
> +
> +	if (!(revents & (POLLERR | POLLHUP)) &&
> +		   	(err == -EPIPE || err == -ECONNRESET)) {
> +		if (test_bit(DST_NODE_NOTSYNC, &st->node->flags)) {
> +			return dst_mirror_resync(st->node, 1);
> +		}
> +		return 0;
> +	}
> +
> +	if (atomic_read(&st->node->shared_num) == 0 &&
> +			!st->node->shared_head) {
> +		dprintk("%s: this node is the only one in the mirror, "
> +				"can not mark it notsync.\n", __func__);
> +		return err;
> +	}
> +
> +	dst_mirror_mark_notsync(st->node);
> +
> +	mutex_lock(&st->request_lock);
> +	list_for_each_entry_safe(req, tmp, &st->request_list,
> +					request_list_entry) {
> +		kst_del_req(req);
> +		dprintk("%s: requeue [%c], start: %llu, idx: %d,"
> +				" num: %d, size: %llu, offset: %u, err: %d.\n",
> +			__func__, (bio_rw(req->bio) == WRITE)?'W':'R',
> +			req->start, req->idx, req->num, req->size,
> +			req->offset, err);
> +
> +		if (bio_rw(req->bio) != WRITE) {
> +			req->start -= to_sector(req->orig_size - req->size);
> +			req->size = req->orig_size;
> +			req->flags &= ~(DST_REQ_HEADER_SENT | DST_REQ_CHEKSUM_RECV);
> +			req->idx = 0;
> +			if (dst_mirror_read(req))
> +				dst_free_request(req);
> +		} else {
> +			kst_complete_req(req, err);
> +		}
> +	}
> +	mutex_unlock(&st->request_lock);
> +	return err;
> +}
> +
> +static struct dst_alg_ops alg_mirror_ops = {
> +	.remap		= dst_mirror_remap,
> +	.add_node	= dst_mirror_add_node,
> +	.del_node	= dst_mirror_del_node,
> +	.error		= dst_mirror_error,
> +	.owner		= THIS_MODULE,
> +};
> +
> +static int __devinit alg_mirror_init(void)
> +{
> +	int err = -ENOMEM;
> +
> +	dst_mirror_bio_set = bioset_create(256, 256);
> +	if (!dst_mirror_bio_set)
> +		return -ENOMEM;
> +
> +	alg_mirror = dst_alloc_alg("alg_mirror", &alg_mirror_ops);
> +	if (!alg_mirror)
> +		goto err_out;
> +
> +	return 0;
> +
> +err_out:
> +	bioset_free(dst_mirror_bio_set);
> +	return err;
> +}
> +
> +static void __devexit alg_mirror_exit(void)
> +{
> +	dst_remove_alg(alg_mirror);
> +	bioset_free(dst_mirror_bio_set);
> +}
> +
> +module_init(alg_mirror_init);
> +module_exit(alg_mirror_exit);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
> +MODULE_DESCRIPTION("Mirror distributed algorithm.");
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

