From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Fri, 30 Apr 2010 09:48:55 -0700
Message-ID: <OF1AAB7A88.8809F193-ON88257715.005C4266-88257715.005C5F92@us.ibm.com>
References: <20100429134515.GA26287@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:58470 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab0D3QtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:49:00 -0400
In-Reply-To: <20100429134515.GA26287@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 04/29/2010 06:45:15 AM:

> On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> > This patch adds mergeable receive buffer support to vhost_net.
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> I have applied this, thanks very much!
> I have also applied some tweaks on top,
> please take a look.
> 
> Thanks,
> MSt
> 

Looks fine to me.

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> commit 2809e94f5f26d89dc5232aaec753ffda95c4d95e
> Author: Michael S. Tsirkin <mst@redhat.com>
> Date:   Thu Apr 29 16:18:08 2010 +0300
> 
>     vhost-net: minor tweaks in mergeable buffer code
> 
>     Applies the following tweaks on top of mergeable buffers patch:
>     1. vhost_get_desc_n assumes that all desriptors are 'in' only.
>        It's also unlikely to be useful for any vhost frontend
>        besides vhost_net, so just move it to net.c, and rename
>        get_rx_bufs for brevity.
> 
>     2. for rx, we called iov_length within vhost_get_desc_n
>        (now get_rx_bufs) already, so we don't
>        need an extra call to iov_length to avoid overflow anymore.
>        Accordingly, copy_iovec_hdr can return void now.
> 
>     3. for rx, do some further code tweaks:
>        do not assign len = err as we check that err == len
>        handle data length in a way similar to how we handle
>        header length: datalen -> sock_len, len -> vhost_len.
>        add sock_hlen as a local variable, for symmetry with vhost_hlen.
> 
>     4. add some likely/unlikely annotations
> 
>     Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index d61d945..85519b4 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -74,9 +74,9 @@ static int move_iovec_hdr(struct iovec *from, struct 
iovec *to,
>     }
>     return seg;
>  }
> -/* Copy iovec entries for len bytes from iovec. Return segments used. 
*/
> -static int copy_iovec_hdr(const struct iovec *from, struct iovec *to,
> -           size_t len, int iovcount)
> +/* Copy iovec entries for len bytes from iovec. */
> +static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
> +            size_t len, int iovcount)
>  {
>     int seg = 0;
>     size_t size;
> @@ -89,7 +89,6 @@ static int copy_iovec_hdr(const struct iovec *from, 
struct iovec *to,
>        ++to;
>        ++seg;
>     }
> -   return seg;
>  }
> 
>  /* Caller must have TX VQ lock */
> @@ -204,7 +203,7 @@ static void handle_tx(struct vhost_net *net)
>     unuse_mm(net->dev.mm);
>  }
> 
> -static int vhost_head_len(struct vhost_virtqueue *vq, struct sock *sk)
> +static int peek_head_len(struct vhost_virtqueue *vq, struct sock *sk)
>  {
>     struct sk_buff *head;
>     int len = 0;
> @@ -212,17 +211,70 @@ static int vhost_head_len(struct vhost_virtqueue 
*vq, 
> struct sock *sk)
>     lock_sock(sk);
>     head = skb_peek(&sk->sk_receive_queue);
>     if (head)
> -      len = head->len + vq->sock_hlen;
> +      len = head->len;
>     release_sock(sk);
>     return len;
>  }
> 
> +/* This is a multi-buffer version of vhost_get_desc, that works if
> + *   vq has read descriptors only.
> + * @vq      - the relevant virtqueue
> + * @datalen   - data length we'll be reading
> + * @iovcount   - returned count of io vectors we fill
> + * @log      - vhost log
> + * @log_num   - log offset
> + *   returns number of buffer heads allocated, negative on error
> + */
> +static int get_rx_bufs(struct vhost_virtqueue *vq,
> +             struct vring_used_elem *heads,
> +             int datalen,
> +             unsigned *iovcount,
> +             struct vhost_log *log,
> +             unsigned *log_num)
> +{
> +   unsigned int out, in;
> +   int seg = 0;
> +   int headcount = 0;
> +   unsigned d;
> +   int r;
> +
> +   while (datalen > 0) {
> +      if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
> +         r = -ENOBUFS;
> +         goto err;
> +      }
> +      d = vhost_get_desc(vq->dev, vq, vq->iov + seg,
> +               ARRAY_SIZE(vq->iov) - seg, &out,
> +               &in, log, log_num);
> +      if (d == vq->num) {
> +         r = 0;
> +         goto err;
> +      }
> +      if (unlikely(out || in <= 0)) {
> +         vq_err(vq, "unexpected descriptor format for RX: "
> +            "out %d, in %d\n", out, in);
> +         r = -EINVAL;
> +         goto err;
> +      }
> +      heads[headcount].id = d;
> +      heads[headcount].len = iov_length(vq->iov + seg, in);
> +      datalen -= heads[headcount].len;
> +      ++headcount;
> +      seg += in;
> +   }
> +   *iovcount = seg;
> +   return headcount;
> +err:
> +   vhost_discard_desc(vq, headcount);
> +   return r;
> +}
> +
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
>  static void handle_rx(struct vhost_net *net)
>  {
>     struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -   unsigned in, log, s;
> +   unsigned uninitialized_var(in), log;
>     struct vhost_log *vq_log;
>     struct msghdr msg = {
>        .msg_name = NULL,
> @@ -238,9 +290,10 @@ static void handle_rx(struct vhost_net *net)
>        .hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
>     };
> 
> -   size_t len, total_len = 0;
> -   int err, headcount, datalen;
> -   size_t vhost_hlen;
> +   size_t total_len = 0;
> +   int err, headcount;
> +   size_t vhost_hlen, sock_hlen;
> +   size_t vhost_len, sock_len;
>     struct socket *sock = rcu_dereference(vq->private_data);
>     if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
>        return;
> @@ -249,14 +302,16 @@ static void handle_rx(struct vhost_net *net)
>     mutex_lock(&vq->mutex);
>     vhost_disable_notify(vq);
>     vhost_hlen = vq->vhost_hlen;
> +   sock_hlen = vq->sock_hlen;
> 
>     vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>        vq->log : NULL;
> 
> -   while ((datalen = vhost_head_len(vq, sock->sk))) {
> -      headcount = vhost_get_desc_n(vq, vq->heads,
> -                    datalen + vhost_hlen,
> -                    &in, vq_log, &log);
> +   while ((sock_len = peek_head_len(vq, sock->sk))) {
> +      sock_len += sock_hlen;
> +      vhost_len = sock_len + vhost_hlen;
> +      headcount = get_rx_bufs(vq, vq->heads, vhost_len,
> +               &in, vq_log, &log);
>        if (headcount < 0)
>           break;
>        /* OK, now we need to know about added descriptors. */
> @@ -272,34 +327,25 @@ static void handle_rx(struct vhost_net *net)
>           break;
>        }
>        /* We don't need to be notified again. */
> -      if (vhost_hlen)
> +      if (unlikely((vhost_hlen)))
>           /* Skip header. TODO: support TSO. */
> -         s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
> +         move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
>        else
> -         s = copy_iovec_hdr(vq->iov, vq->hdr, vq->sock_hlen, in);
> +         copy_iovec_hdr(vq->iov, vq->hdr, sock_hlen, in);
>        msg.msg_iovlen = in;
> -      len = iov_length(vq->iov, in);
> -      /* Sanity check */
> -      if (!len) {
> -         vq_err(vq, "Unexpected header len for RX: "
> -                "%zd expected %zd\n",
> -                iov_length(vq->hdr, s), vhost_hlen);
> -         break;
> -      }
>        err = sock->ops->recvmsg(NULL, sock, &msg,
> -                len, MSG_DONTWAIT | MSG_TRUNC);
> +                sock_len, MSG_DONTWAIT | MSG_TRUNC);
>        /* TODO: Check specific error and bomb out unless EAGAIN? */
>        if (err < 0) {
>           vhost_discard_desc(vq, headcount);
>           break;
>        }
> -      if (err != datalen) {
> +      if (err != sock_len) {
>           pr_err("Discarded rx packet: "
> -                " len %d, expected %zd\n", err, datalen);
> +                " len %d, expected %zd\n", err, sock_len);
>           vhost_discard_desc(vq, headcount);
>           continue;
>        }
> -      len = err;
>        if (vhost_hlen &&
>            memcpy_toiovecend(vq->hdr, (unsigned char *)&hdr, 0,
>                    vhost_hlen)) {
> @@ -311,17 +357,16 @@ static void handle_rx(struct vhost_net *net)
>        if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
>            memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
>                    offsetof(typeof(hdr), num_buffers),
> -                  sizeof(hdr.num_buffers))) {
> +                  sizeof hdr.num_buffers)) {
>           vq_err(vq, "Failed num_buffers write");
>           vhost_discard_desc(vq, headcount);
>           break;
>        }
> -      len += vhost_hlen;
>        vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
>                     headcount);
>        if (unlikely(vq_log))
> -         vhost_log_write(vq, vq_log, log, len);
> -      total_len += len;
> +         vhost_log_write(vq, vq_log, log, vhost_len);
> +      total_len += vhost_len;
>        if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>           vhost_poll_queue(&vq->poll);
>           break;
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 8ef5e3f..4b49991 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -862,53 +862,6 @@ static unsigned get_indirect(struct vhost_dev *dev, 

> struct vhost_virtqueue *vq,
>     return 0;
>  }
> 
> -/* This is a multi-buffer version of vhost_get_desc
> - * @vq      - the relevant virtqueue
> - * datalen   - data length we'll be reading
> - * @iovcount   - returned count of io vectors we fill
> - * @log      - vhost log
> - * @log_num   - log offset
> - *   returns number of buffer heads allocated, negative on error
> - */
> -int vhost_get_desc_n(struct vhost_virtqueue *vq, struct vring_used_elem 
*heads,
> -           int datalen, unsigned *iovcount, struct vhost_log *log,
> -           unsigned int *log_num)
> -{
> -   unsigned int out, in;
> -   int seg = 0;
> -   int headcount = 0;
> -   int r;
> -
> -   while (datalen > 0) {
> -      if (headcount >= VHOST_NET_MAX_SG) {
> -         r = -ENOBUFS;
> -         goto err;
> -      }
> -      heads[headcount].id = vhost_get_desc(vq->dev, vq, vq->iov + seg,
> -                     ARRAY_SIZE(vq->iov) - seg, &out,
> -                     &in, log, log_num);
> -      if (heads[headcount].id == vq->num) {
> -         r = 0;
> -         goto err;
> -      }
> -      if (out || in <= 0) {
> -         vq_err(vq, "unexpected descriptor format for RX: "
> -            "out %d, in %d\n", out, in);
> -         r = -EINVAL;
> -         goto err;
> -      }
> -      heads[headcount].len = iov_length(vq->iov + seg, in);
> -      datalen -= heads[headcount].len;
> -      ++headcount;
> -      seg += in;
> -   }
> -   *iovcount = seg;
> -   return headcount;
> -err:
> -   vhost_discard_desc(vq, headcount);
> -   return r;
> -}
> -
>  /* This looks in the virtqueue and for the first available buffer, and 
converts
>   * it to an iovec for convenient access.  Since descriptors consist of 
some
>   * number of output then some number of input descriptors, it's 
actually two
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 08d740a..4c9809e 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -122,9 +122,6 @@ long vhost_dev_ioctl(struct vhost_dev *, unsigned 
int 
> ioctl, unsigned long arg);
>  int vhost_vq_access_ok(struct vhost_virtqueue *vq);
>  int vhost_log_access_ok(struct vhost_dev *);
> 
> -int vhost_get_desc_n(struct vhost_virtqueue *, struct vring_used_elem 
*heads,
> -           int datalen, unsigned int *iovcount, struct vhost_log *log,
> -           unsigned int *log_num);
>  unsigned vhost_get_desc(struct vhost_dev *, struct vhost_virtqueue *,
>              struct iovec iov[], unsigned int iov_count,
>              unsigned int *out_num, unsigned int *in_num,
> 
> -- 
> MST

