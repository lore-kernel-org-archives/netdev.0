From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vhost: break out of polling loop on error
Date: Mon, 28 Jun 2010 10:11:43 -0700
Message-ID: <1277745103.23755.2.camel@w-sridhar.beaverton.ibm.com>
References: <20100627085907.GA8588@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <samudrala@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Jes.Sorensen@redhat.com,
	kraxel@redhat.com,
	Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47731 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336Ab0F1RL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 13:11:56 -0400
In-Reply-To: <20100627085907.GA8588@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-06-27 at 11:59 +0300, Michael S. Tsirkin wrote:
> When ring parsing fails, we currently handle this
> as ring empty condition. This means that we enable
> kicks and recheck ring empty: if this not empty,
> we re-start polling which of course will fail again.
> 
> Instead, let's return a negative error code and stop polling.

One minor comment on error return below. With that change,

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Dave, I'm sending this out so it can get reviewed.
> I'll put this on my vhost tree
> so no need for you to pick this patch directly.
> 
>  drivers/vhost/net.c   |   12 ++++++++++--
>  drivers/vhost/vhost.c |   33 +++++++++++++++++----------------
>  drivers/vhost/vhost.h |    8 ++++----
>  3 files changed, 31 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 0f41c91..54096ee 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -98,7 +98,8 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
>  static void handle_tx(struct vhost_net *net)
>  {
>  	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> -	unsigned head, out, in, s;
> +	unsigned out, in, s;
> +	int head;
>  	struct msghdr msg = {
>  		.msg_name = NULL,
>  		.msg_namelen = 0,
> @@ -135,6 +136,9 @@ static void handle_tx(struct vhost_net *net)
>  					 ARRAY_SIZE(vq->iov),
>  					 &out, &in,
>  					 NULL, NULL);
> +		/* On error, stop handling until the next kick. */
> +		if (head < 0)
> +			break;
>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
>  		if (head == vq->num) {
>  			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
> @@ -192,7 +196,8 @@ static void handle_tx(struct vhost_net *net)
>  static void handle_rx(struct vhost_net *net)
>  {
>  	struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -	unsigned head, out, in, log, s;
> +	unsigned out, in, log, s;
> +	int head;
>  	struct vhost_log *vq_log;
>  	struct msghdr msg = {
>  		.msg_name = NULL,
> @@ -228,6 +233,9 @@ static void handle_rx(struct vhost_net *net)
>  					 ARRAY_SIZE(vq->iov),
>  					 &out, &in,
>  					 vq_log, &log);
> +		/* On error, stop handling until the next kick. */
> +		if (head < 0)
> +			break;
>  		/* OK, now we need to know about added descriptors. */
>  		if (head == vq->num) {
>  			if (unlikely(vhost_enable_notify(vq))) {
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 3b83382..5ccd384 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -873,12 +873,13 @@ static unsigned get_indirect(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>   * number of output then some number of input descriptors, it's actually two
>   * iovecs, but we pack them into one and note how many of each there were.
>   *
> - * This function returns the descriptor number found, or vq->num (which
> - * is never a valid descriptor number) if none was found. */
> -unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
> -			   struct iovec iov[], unsigned int iov_size,
> -			   unsigned int *out_num, unsigned int *in_num,
> -			   struct vhost_log *log, unsigned int *log_num)
> + * This function returns the descriptor number found, or vq->num (which is
> + * never a valid descriptor number) if none was found.  A negative code is
> + * returned on error. */
> +int vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
> +		      struct iovec iov[], unsigned int iov_size,
> +		      unsigned int *out_num, unsigned int *in_num,
> +		      struct vhost_log *log, unsigned int *log_num)
>  {
>  	struct vring_desc desc;
>  	unsigned int i, head, found = 0;
> @@ -890,13 +891,13 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  	if (get_user(vq->avail_idx, &vq->avail->idx)) {
>  		vq_err(vq, "Failed to access avail idx at %p\n",
>  		       &vq->avail->idx);
> -		return vq->num;
> +		return -EFAULT;
>  	}
> 
>  	if ((u16)(vq->avail_idx - last_avail_idx) > vq->num) {
>  		vq_err(vq, "Guest moved used index from %u to %u",
>  		       last_avail_idx, vq->avail_idx);
> -		return vq->num;
> +		return -EFAULT;

This should be -EINVAL
>  	}
> 
>  	/* If there's nothing new since last we looked, return invalid. */
> @@ -912,14 +913,14 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  		vq_err(vq, "Failed to read head: idx %d address %p\n",
>  		       last_avail_idx,
>  		       &vq->avail->ring[last_avail_idx % vq->num]);
> -		return vq->num;
> +		return -EFAULT;
>  	}
> 
>  	/* If their number is silly, that's an error. */
>  	if (head >= vq->num) {
>  		vq_err(vq, "Guest says index %u > %u is available",
>  		       head, vq->num);
> -		return vq->num;
> +		return -EINVAL;
>  	}
> 
>  	/* When we start there are none of either input nor output. */
> @@ -933,19 +934,19 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  		if (i >= vq->num) {
>  			vq_err(vq, "Desc index is %u > %u, head = %u",
>  			       i, vq->num, head);
> -			return vq->num;
> +			return -EINVAL;
>  		}
>  		if (++found > vq->num) {
>  			vq_err(vq, "Loop detected: last one at %u "
>  			       "vq size %u head %u\n",
>  			       i, vq->num, head);
> -			return vq->num;
> +			return -EINVAL;
>  		}
>  		ret = copy_from_user(&desc, vq->desc + i, sizeof desc);
>  		if (ret) {
>  			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
>  			       i, vq->desc + i);
> -			return vq->num;
> +			return -EFAULT;
>  		}
>  		if (desc.flags & VRING_DESC_F_INDIRECT) {
>  			ret = get_indirect(dev, vq, iov, iov_size,
> @@ -954,7 +955,7 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  			if (ret < 0) {
>  				vq_err(vq, "Failure detected "
>  				       "in indirect descriptor at idx %d\n", i);
> -				return vq->num;
> +				return ret;
>  			}
>  			continue;
>  		}
> @@ -964,7 +965,7 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  		if (ret < 0) {
>  			vq_err(vq, "Translation failure %d descriptor idx %d\n",
>  			       ret, i);
> -			return vq->num;
> +			return ret;
>  		}
>  		if (desc.flags & VRING_DESC_F_WRITE) {
>  			/* If this is an input descriptor,
> @@ -981,7 +982,7 @@ unsigned vhost_get_vq_desc(struct vhost_dev *dev, struct vhost_virtqueue *vq,
>  			if (*in_num) {
>  				vq_err(vq, "Descriptor has out after in: "
>  				       "idx %d\n", i);
> -				return vq->num;
> +				return -EINVAL;
>  			}
>  			*out_num += ret;
>  		}
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 44591ba..11ee13d 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -120,10 +120,10 @@ long vhost_dev_ioctl(struct vhost_dev *, unsigned int ioctl, unsigned long arg);
>  int vhost_vq_access_ok(struct vhost_virtqueue *vq);
>  int vhost_log_access_ok(struct vhost_dev *);
> 
> -unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
> -			   struct iovec iov[], unsigned int iov_count,
> -			   unsigned int *out_num, unsigned int *in_num,
> -			   struct vhost_log *log, unsigned int *log_num);
> +int vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
> +		      struct iovec iov[], unsigned int iov_count,
> +		      unsigned int *out_num, unsigned int *in_num,
> +		      struct vhost_log *log, unsigned int *log_num);
>  void vhost_discard_vq_desc(struct vhost_virtqueue *);
> 
>  int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);

