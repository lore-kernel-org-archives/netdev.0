From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for/net-next 1/8] net/mlx5: Mellanox Connect-IB, core
 driver part 1/3
Date: Fri, 28 Jun 2013 21:03:29 -0700 (PDT)
Message-ID: <20130628.210329.240918119199058100.davem@davemloft.net>
References: <1372256537-21328-1-git-send-email-ogerlitz@mellanox.com>
	<1372256537-21328-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372256537-21328-2-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Wed, 26 Jun 2013 17:22:10 +0300

> +		buf->direct.buf   = dma_alloc_coherent(&dev->pdev->dev,
> +						       size, &t, GFP_KERNEL);
 ...
> +		memset(buf->direct.buf, 0, size);


This sequence is "dma_zalloc_coherent()", please use it.


> +	i = find_first_bit(pgdir->bitmap, MLX5_DB_PER_PAGE);
> +	if (i >= MLX5_DB_PER_PAGE)
> +		return -ENOMEM;
> +
> +	clear_bit(i, pgdir->bitmap);

You have other synchronizations protecting this bitmap, so you don't
need to use the atomic clear_bit(), please use __clear_bit() instead.

> +
> +	set_bit(db->index, db->u.pgdir->bitmap);

Likewise, use __set_bit().

> +	u8 own;
> +	unsigned long poll_end = jiffies + msecs_to_jiffies(MLX5_CMD_TIMEOUT_MSEC + 1000);

I know it sounds silly, but order local variable declarations from longest
to shortest line, it looks a lot nicer.

> +static int verify_signature(struct mlx5_cmd_work_ent *ent)
> +{
> +	int err;
> +	u8 sig;
> +	struct mlx5_cmd_mailbox *next = ent->out->next;

Likewise.

> +static void dump_buf(void *buf, int size, int data_only, int offset)
> +{
> +	int i;
> +	__be32 *p = buf;

Likewise.  Please go over all of this new driver and take care of this,
thanks.

> +static const char *status_to_str(u8 status)
> +{
> +	switch (status) {
> +	case 0:
> +		return "no errors";

Please add defines for these status codes rather than using magic
constants.

> +	for (i = 0; i < n; ++i) {

"i++", rather than "++i" is canonical in this situations, please.

> +	for (i = 0; i < (1 << cmd->log_sz); ++i) {

Likewise.  Please fix this up in all of this driver's code.

> +			/*
> +			 * for cached lists, we must explicitly state what is
> +			 * the real size
> +			 */

Comments in the networking are to be formatted:

	/* Like
	 * this.
	 */

and not:

	/*
	 * Like
	 * this.
	 */

Please take care of this in the entire driver, thanks.

> +ex_err:
> +	list_for_each_entry_safe(msg, n, &cmd->cache.large.head, list) {
> +		list_del(&msg->list);
> +		mlx5_free_cmd_msg(dev, msg);
> +	}
> +
> +	list_for_each_entry_safe(msg, n, &cmd->cache.med.head, list) {
> +		list_del(&msg->list);
> +		mlx5_free_cmd_msg(dev, msg);
> +	}
> +
> +	return err;

This cleanup code is duplicated...

> +static void destroy_msg_cache(struct mlx5_core_dev *dev)

Here.

Simply declare destroy_msg_cache() earlier and call it, instead
of duplicating all of it's code.

> +static const char *cmd_status_str(u8 status)
> +{
> +	switch (status) {
> +	case 0x0:	return "OK";

Again, make readable defines for these status values, rather than using magic
constants.

> +	switch (hdr->status) {
> +	case 0x0:	return 0;
> +	case 0x1:	return -EIO;

Likewise.

I also question how useful all of these debugfs facilities are after initial
development.  They take up memory even if they are never used.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
