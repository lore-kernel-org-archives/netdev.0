From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] Add Mergeable RX buffer feature to vhost_net
Date: Wed, 31 Mar 2010 15:02:28 +0300
Message-ID: <20100331120228.GH31085@redhat.com>
References: <20100308080733.GC7482@redhat.com> <OF35D5EAC9.45A7DC5F-ON882576F7.0006F45E-882576F7.0007AB62@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932476Ab0CaMGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:06:16 -0400
Content-Disposition: inline
In-Reply-To: <OF35D5EAC9.45A7DC5F-ON882576F7.0006F45E-882576F7.0007AB62@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 07:23:48PM -0600, David Stevens wrote:
> This patch adds support for the Mergeable Receive Buffers feature to
> vhost_net.
> 
> Changes:
>         1) generalize descriptor allocation functions to allow multiple
>                 descriptors per packet
>         2) add socket "peek" to know datalen at buffer allocation time
>         3) change notification to enable a multi-buffer max packet, rather
>                 than the single-buffer run until completely empty
> 
> Changes from previous revision:
> 1) incorporate review comments from Michael Tsirkin
> 2) assume use of TUNSETVNETHDRSZ ioctl by qemu, which simplifies vnet 
> header
>         processing
> 3) fixed notification code to only affect the receive side
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>
> 
> [in-line for review, attached for applying w/o whitespace mangling]

attached patch seems to be whiespace damaged as well.
Does the origin pass checkpatch.pl for you?

> diff -ruNp net-next-p0/drivers/vhost/net.c net-next-p3/drivers/vhost/net.c
> --- net-next-p0/drivers/vhost/net.c     2010-03-22 12:04:38.000000000 
> -0700
> +++ net-next-p3/drivers/vhost/net.c     2010-03-30 12:50:57.000000000 
> -0700
> @@ -54,26 +54,6 @@ struct vhost_net {
>         enum vhost_net_poll_state tx_poll_state;
>  };
>  
> -/* Pop first len bytes from iovec. Return number of segments used. */
> -static int move_iovec_hdr(struct iovec *from, struct iovec *to,
> -                         size_t len, int iov_count)
> -{
> -       int seg = 0;
> -       size_t size;
> -       while (len && seg < iov_count) {
> -               size = min(from->iov_len, len);
> -               to->iov_base = from->iov_base;
> -               to->iov_len = size;
> -               from->iov_len -= size;
> -               from->iov_base += size;
> -               len -= size;
> -               ++from;
> -               ++to;
> -               ++seg;
> -       }
> -       return seg;
> -}
> -
>  /* Caller must have TX VQ lock */
>  static void tx_poll_stop(struct vhost_net *net)
>  {
> @@ -97,7 +77,8 @@ static void tx_poll_start(struct vhost_n
>  static void handle_tx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> -       unsigned head, out, in, s;
> +       unsigned out, in;
> +       struct iovec head;
>         struct msghdr msg = {
>                 .msg_name = NULL,
>                 .msg_namelen = 0,
> @@ -108,8 +89,8 @@ static void handle_tx(struct vhost_net *
>         };
>         size_t len, total_len = 0;
>         int err, wmem;
> -       size_t hdr_size;
>         struct socket *sock = rcu_dereference(vq->private_data);
> +
>         if (!sock)
>                 return;
>  
> @@ -127,22 +108,19 @@ static void handle_tx(struct vhost_net *
>  
>         if (wmem < sock->sk->sk_sndbuf / 2)
>                 tx_poll_stop(net);
> -       hdr_size = vq->hdr_size;
>  
>         for (;;) {
> -               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -                                        ARRAY_SIZE(vq->iov),
> -                                        &out, &in,
> -                                        NULL, NULL);
> +               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
> +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 
> NULL);

I this casting confusing.
Is it really expensive to add an array of heads so that
we do not need to cast?


>                 /* Nothing new?  Wait for eventfd to tell us they 
> refilled. */
> -               if (head == vq->num) {
> +               if (head.iov_base == (void *)vq->num) {
>                         wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>                         if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
>                                 tx_poll_start(net, sock);
>                                 set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
>                                 break;
>                         }
> -                       if (unlikely(vhost_enable_notify(vq))) {
> +                       if (unlikely(vhost_enable_notify(vq, 0))) {
>                                 vhost_disable_notify(vq);
>                                 continue;
>                         }
> @@ -154,27 +132,30 @@ static void handle_tx(struct vhost_net *
>                         break;
>                 }
>                 /* Skip header. TODO: support TSO. */
> -               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
>                 msg.msg_iovlen = out;
> -               len = iov_length(vq->iov, out);
> +               head.iov_len = len = iov_length(vq->iov, out);
> +
>                 /* Sanity check */
>                 if (!len) {
> -                       vq_err(vq, "Unexpected header len for TX: "
> -                              "%zd expected %zd\n",
> -                              iov_length(vq->hdr, s), hdr_size);
> +                       vq_err(vq, "Unexpected buffer len for TX: %zd ", 
> len);
>                         break;
>                 }
> -               /* TODO: Check specific error and bomb out unless ENOBUFS? 
> */
>                 err = sock->ops->sendmsg(NULL, sock, &msg, len);
>                 if (unlikely(err < 0)) {
> -                       vhost_discard_vq_desc(vq);
> -                       tx_poll_start(net, sock);
> +                       if (err == -EAGAIN) {
> +                               vhost_discard_vq_desc(vq, 1);
> +                               tx_poll_start(net, sock);
> +                       } else {
> +                               vq_err(vq, "sendmsg: errno %d\n", -err);
> +                               /* drop packet; do not discard/resend */
> +                               vhost_add_used_and_signal(&net->dev, vq, 
> &head,
> +                                                         1, 0);
> +                       }
>                         break;
>                 }
>                 if (err != len)
> -                       pr_err("Truncated TX packet: "
> -                              " len %d != %zd\n", err, len);
> -               vhost_add_used_and_signal(&net->dev, vq, head, 0);
> +                       pr_err("Truncated TX packet: len %d != %zd\n", 
> err, len);
> +               vhost_add_used_and_signal(&net->dev, vq, &head, 1, 0);
>                 total_len += len;
>                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>                         vhost_poll_queue(&vq->poll);
> @@ -186,12 +167,25 @@ static void handle_tx(struct vhost_net *
>         unuse_mm(net->dev.mm);
>  }
>  
> +static int vhost_head_len(struct sock *sk)
> +{
> +       struct sk_buff *head;
> +       int len = 0;
> +
> +       lock_sock(sk);
> +       head = skb_peek(&sk->sk_receive_queue);
> +       if (head)
> +               len = head->len;
> +       release_sock(sk);
> +       return len;
> +}
> +
>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
>  static void handle_rx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -       unsigned head, out, in, log, s;
> +       unsigned in, log;
>         struct vhost_log *vq_log;
>         struct msghdr msg = {
>                 .msg_name = NULL,
> @@ -202,34 +196,25 @@ static void handle_rx(struct vhost_net *
>                 .msg_flags = MSG_DONTWAIT,
>         };
>  
> -       struct virtio_net_hdr hdr = {
> -               .flags = 0,
> -               .gso_type = VIRTIO_NET_HDR_GSO_NONE
> -       };
> -
>         size_t len, total_len = 0;
> -       int err;
> -       size_t hdr_size;
> +       int err, headcount, datalen;
>         struct socket *sock = rcu_dereference(vq->private_data);
> +
>         if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
>                 return;
>  
>         use_mm(net->dev.mm);
>         mutex_lock(&vq->mutex);
>         vhost_disable_notify(vq);
> -       hdr_size = vq->hdr_size;
>  
>         vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>                 vq->log : NULL;
>  
> -       for (;;) {
> -               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -                                        ARRAY_SIZE(vq->iov),
> -                                        &out, &in,
> -                                        vq_log, &log);
> +       while ((datalen = vhost_head_len(sock->sk))) {
> +               headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
> &log);
>                 /* OK, now we need to know about added descriptors. */
> -               if (head == vq->num) {
> -                       if (unlikely(vhost_enable_notify(vq))) {
> +               if (!headcount) {
> +                       if (unlikely(vhost_enable_notify(vq, 1))) {
>                                 /* They have slipped one in as we were
>                                  * doing that: check again. */
>                                 vhost_disable_notify(vq);
> @@ -240,46 +225,42 @@ static void handle_rx(struct vhost_net *
>                         break;
>                 }
>                 /* We don't need to be notified again. */
> -               if (out) {
> -                       vq_err(vq, "Unexpected descriptor format for RX: "
> -                              "out %d, int %d\n",
> -                              out, in);
> -                       break;
> -               }
> -               /* Skip header. TODO: support TSO/mergeable rx buffers. */
> -               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
> +               if (vq->rxmaxheadcount < headcount)
> +                       vq->rxmaxheadcount = headcount;

This seems the only place where we set the rxmaxheadcount
value. Maybe it can be moved out of vhost.c to net.c?
If vhost library needs this it can get it as function
parameter.

> +               /* Skip header. TODO: support TSO. */

You seem to have removed the code that skips the header.
Won't this break non-GSO backends such as raw?

>                 msg.msg_iovlen = in;
>                 len = iov_length(vq->iov, in);
>                 /* Sanity check */
>                 if (!len) {
> -                       vq_err(vq, "Unexpected header len for RX: "
> -                              "%zd expected %zd\n",
> -                              iov_length(vq->hdr, s), hdr_size);
> +                       vq_err(vq, "Unexpected buffer len for RX: %zd\n", 
> len);
>                         break;
>                 }
>                 err = sock->ops->recvmsg(NULL, sock, &msg,
>                                          len, MSG_DONTWAIT | MSG_TRUNC);
> -               /* TODO: Check specific error and bomb out unless EAGAIN? 
> */

Do you think it's not a good idea?

>                 if (err < 0) {
> -                       vhost_discard_vq_desc(vq);
> +                       vhost_discard_vq_desc(vq, headcount);
>                         break;
>                 }

I think we should detect and discard truncated messages,
since len might not be reliable if userspace pulls
a packet from under us. Also, if new packet is
shorter than the old one, there's no truncation but
headcount is wrong.

So simplest fix IMO would be to compare err with expected len.
If there's a difference, we hit the race and so
we would discard the packet.


>                 /* TODO: Should check and handle checksum. */
> +               if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) 
> {
> +                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
> +                               (struct virtio_net_hdr_mrg_rxbuf *)
> +                               vq->iov[0].iov_base;
> +                       /* add num_bufs */
> +                       if (put_user(headcount, &vhdr->num_buffers)) {
> +                               vq_err(vq, "Failed to write num_buffers");
> +                               vhost_discard_vq_desc(vq, headcount);

Let's do memcpy_to_iovecend etc so that we do not assume layout.
This is also why we need move_iovec: sendmsg might modify the iovec.
It would also be nice not to corrupt memory and
get a reasonable error if buffer size
that we get is smaller than expected header size.

> +                               break;
> +                       }
> +               }
>                 if (err > len) {
>                         pr_err("Discarded truncated rx packet: "
>                                " len %d > %zd\n", err, len);
> -                       vhost_discard_vq_desc(vq);
> +                       vhost_discard_vq_desc(vq, headcount);
>                         continue;
>                 }
>                 len = err;
> -               err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, 
> hdr_size);
> -               if (err) {
> -                       vq_err(vq, "Unable to write vnet_hdr at addr %p: 
> %d\n",
> -                              vq->iov->iov_base, err);
> -                       break;
> -               }
> -               len += hdr_size;

This seems to break non-GSO backends as well.

> -               vhost_add_used_and_signal(&net->dev, vq, head, len);
> + vhost_add_used_and_signal(&net->dev,vq,vq->heads,headcount,1);
>                 if (unlikely(vq_log))
>                         vhost_log_write(vq, vq_log, log, len);
>                 total_len += len;
> @@ -560,9 +541,6 @@ done:
>  
>  static int vhost_net_set_features(struct vhost_net *n, u64 features)
>  {
> -       size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> -               sizeof(struct virtio_net_hdr) : 0;
> -       int i;
>         mutex_lock(&n->dev.mutex);
>         if ((features & (1 << VHOST_F_LOG_ALL)) &&
>             !vhost_log_access_ok(&n->dev)) {
> @@ -571,11 +549,6 @@ static int vhost_net_set_features(struct
>         }
>         n->dev.acked_features = features;
>         smp_wmb();
> -       for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
> -               mutex_lock(&n->vqs[i].mutex);
> -               n->vqs[i].hdr_size = hdr_size;
> -               mutex_unlock(&n->vqs[i].mutex);

I expect the above is a leftover from the previous version
which calculated header size in kernel?

> -       }
>         vhost_net_flush(n);
>         mutex_unlock(&n->dev.mutex);
>         return 0;
> diff -ruNp net-next-p0/drivers/vhost/vhost.c 
> net-next-p3/drivers/vhost/vhost.c
> --- net-next-p0/drivers/vhost/vhost.c   2010-03-22 12:04:38.000000000 
> -0700
> +++ net-next-p3/drivers/vhost/vhost.c   2010-03-29 20:12:42.000000000 
> -0700
> @@ -113,7 +113,7 @@ static void vhost_vq_reset(struct vhost_
>         vq->used_flags = 0;
>         vq->log_used = false;
>         vq->log_addr = -1ull;
> -       vq->hdr_size = 0;
> +       vq->rxmaxheadcount = 0;
>         vq->private_data = NULL;
>         vq->log_base = NULL;
>         vq->error_ctx = NULL;
> @@ -410,6 +410,7 @@ static long vhost_set_vring(struct vhost
>                 vq->last_avail_idx = s.num;
>                 /* Forget the cached index value. */
>                 vq->avail_idx = vq->last_avail_idx;
> +               vq->rxmaxheadcount = 0;
>                 break;
>         case VHOST_GET_VRING_BASE:
>                 s.index = idx;
> @@ -856,6 +857,48 @@ static unsigned get_indirect(struct vhos
>         return 0;
>  }
>  
> +/* This is a multi-head version of vhost_get_vq_desc

How about:
version of vhost_get_vq_desc that returns multiple
descriptors

> + * @vq         - the relevant virtqueue
> + * datalen     - data length we'll be reading
> + * @iovcount   - returned count of io vectors we fill
> + * @log                - vhost log
> + * @log_num    - log offset

return value?
Also - why unsigned?

> + */
> +unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 

Would vhost_get_vq_desc_multiple be a better name?

> *iovcount,
> +       struct vhost_log *log, unsigned int *log_num)
> +{
> +       struct iovec *heads = vq->heads;

I think it's better to pass in heads array than take it from vq->heads.

> +       int out, in = 0;

Why is in initialized here?

> +       int seg = 0;            /* iov index */
> +       int hc = 0;             /* head count */
> +
> +       while (datalen > 0) {

Can't this simply call vhost_get_vq_desc in a loop somehow,
or use a common function that both this and vhost_get_vq_desc call?

> +               if (hc >= VHOST_NET_MAX_SG) {
> +                       vhost_discard_vq_desc(vq, hc);
> +                       return 0;
> +               }
> +               heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
> vq,
> +                       vq->iov+seg, ARRAY_SIZE(vq->iov)-seg, &out, &in, 
> log,
> +                       log_num);
> +               if (heads[hc].iov_base == (void *)vq->num) {
> +                       vhost_discard_vq_desc(vq, hc);
> +                       return 0;
> +               }
> +               if (out || in <= 0) {
> +                       vq_err(vq, "unexpected descriptor format for RX: "
> +                               "out %d, in %d\n", out, in);
> +                       vhost_discard_vq_desc(vq, hc);

goto err above might help simplify cleanup.

> +                       return 0;
> +               }
> +               heads[hc].iov_len = iov_length(vq->iov+seg, in);
> +               datalen -= heads[hc].iov_len;
> +               hc++;
> +               seg += in;
> +       }
> +       *iovcount = seg;
> +       return hc;
> +}
> +
>  /* This looks in the virtqueue and for the first available buffer, and 
> converts
>   * it to an iovec for convenient access.  Since descriptors consist of 
> some
>   * number of output then some number of input descriptors, it's actually 
> two
> @@ -981,31 +1024,36 @@ unsigned vhost_get_vq_desc(struct vhost_
>  }
>  
>  /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
> -void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> +void vhost_discard_vq_desc(struct vhost_virtqueue *vq, int n)
>  {
> -       vq->last_avail_idx--;
> +       vq->last_avail_idx -= n;
>  }
>  
>  /* After we've used one of their buffers, we tell them about it.  We'll 
> then
>   * want to notify the guest, using eventfd. */
> -int vhost_add_used(struct vhost_virtqueue *vq, unsigned int head, int 
> len)
> +int vhost_add_used(struct vhost_virtqueue *vq, struct iovec *heads, int 
> count)

count is always 0 for send, right?
I think it is better to have two APIs here as well:
vhost_add_used
vhost_add_used_multiple
we can use functions to avoid code duplication.

>  {
> -       struct vring_used_elem *used;
> +       struct vring_used_elem *used = 0;

why is used initialized here?

> +       int i;
>  
> -       /* The virtqueue contains a ring of used buffers.  Get a pointer 
> to the
> -        * next entry in that used ring. */
> -       used = &vq->used->ring[vq->last_used_idx % vq->num];
> -       if (put_user(head, &used->id)) {
> -               vq_err(vq, "Failed to write used id");
> -               return -EFAULT;
> -       }
> -       if (put_user(len, &used->len)) {
> -               vq_err(vq, "Failed to write used len");
> -               return -EFAULT;
> +       if (count <= 0)
> +               return -EINVAL;
> +
> +       for (i = 0; i < count; ++i) {
> +               used = &vq->used->ring[vq->last_used_idx % vq->num];
> +               if (put_user((unsigned)heads[i].iov_base, &used->id)) {
> +                       vq_err(vq, "Failed to write used id");
> +                       return -EFAULT;
> +               }
> +               if (put_user(heads[i].iov_len, &used->len)) {
> +                       vq_err(vq, "Failed to write used len");
> +                       return -EFAULT;
> +               }
> +               vq->last_used_idx++;

I think we should update last_used_idx on success only,
at the end. Simply use last_used_idx + count
instead of last_used_idx + 1.

>         }
>         /* Make sure buffer is written before we update index. */
>         smp_wmb();
> -       if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
> +       if (put_user(vq->last_used_idx, &vq->used->idx)) {
>                 vq_err(vq, "Failed to increment used idx");
>                 return -EFAULT;
>         }
> @@ -1023,22 +1071,35 @@ int vhost_add_used(struct vhost_virtqueu
>                 if (vq->log_ctx)
>                         eventfd_signal(vq->log_ctx, 1);
>         }
> -       vq->last_used_idx++;
>         return 0;
>  }
>  
> +int vhost_available(struct vhost_virtqueue *vq)

since this function is non-static, please document what it does.

> +{
> +       int avail;
> +
> +       if (!vq->rxmaxheadcount)        /* haven't got any yet */
> +               return 1;

since seems to make net - specific asumptions.
How about moving this check out to net.c?

> +       avail = vq->avail_idx - vq->last_avail_idx;
> +       if (avail < 0)
> +               avail += 0x10000; /* wrapped */

A branch that is likely non-taken. Also, rxmaxheadcount
is really unlikely to get as large as half the ring.
So this just wastes cycles?

> +       return avail;
> +}
> +
>  /* This actually signals the guest, using eventfd. */
> -void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> +void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq, bool 
> recvr)

This one is not elegant. receive is net.c concept, let's not
put it in vhost.c. Pass in headcount if you must.

>  {
>         __u16 flags = 0;
> +
>         if (get_user(flags, &vq->avail->flags)) {
>                 vq_err(vq, "Failed to get flags");
>                 return;
>         }
>  
> -       /* If they don't want an interrupt, don't signal, unless empty. */
> +       /* If they don't want an interrupt, don't signal, unless
> +        * empty or receiver can't get a max-sized packet. */
>         if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
> -           (vq->avail_idx != vq->last_avail_idx ||
> +           (!recvr || vhost_available(vq) >= vq->rxmaxheadcount ||

Is the above really worth the complexity?
Guests can't rely on this kind of fuzzy logic, can they?
Do you see this helping performance at all?

>              !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
>                 return;
>  
> @@ -1050,14 +1111,14 @@ void vhost_signal(struct vhost_dev *dev,
>  /* And here's the combo meal deal.  Supersize me! */
>  void vhost_add_used_and_signal(struct vhost_dev *dev,
>                                struct vhost_virtqueue *vq,
> -                              unsigned int head, int len)
> +                              struct iovec *heads, int count, bool recvr)
>  {
> -       vhost_add_used(vq, head, len);
> -       vhost_signal(dev, vq);
> +       vhost_add_used(vq, heads, count);
> +       vhost_signal(dev, vq, recvr);
>  }
>  
>  /* OK, now we need to know about added descriptors. */
> -bool vhost_enable_notify(struct vhost_virtqueue *vq)
> +bool vhost_enable_notify(struct vhost_virtqueue *vq, bool recvr)
>  {
>         u16 avail_idx;
>         int r;
> @@ -1080,6 +1141,8 @@ bool vhost_enable_notify(struct vhost_vi
>                 return false;
>         }
>  
> +       if (recvr && vq->rxmaxheadcount)
> +               return (avail_idx - vq->last_avail_idx) >= 
> vq->rxmaxheadcount;

The fuzzy logic behind rxmaxheadcount might be a good
optimization, but I am not comfortable using it
for correctness. Maybe vhost_enable_notify should get
the last head so we can redo poll when another one
is added.

>         return avail_idx != vq->last_avail_idx;
>  }
>  
> diff -ruNp net-next-p0/drivers/vhost/vhost.h 
> net-next-p3/drivers/vhost/vhost.h
> --- net-next-p0/drivers/vhost/vhost.h   2010-03-22 12:04:38.000000000 
> -0700
> +++ net-next-p3/drivers/vhost/vhost.h   2010-03-29 20:07:17.000000000 
> -0700
> @@ -82,9 +82,9 @@ struct vhost_virtqueue {
>         u64 log_addr;
>  
>         struct iovec indirect[VHOST_NET_MAX_SG];
> -       struct iovec iov[VHOST_NET_MAX_SG];
> -       struct iovec hdr[VHOST_NET_MAX_SG];
> -       size_t hdr_size;
> +       struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */

VHOST_NET_MAX_SG should already include iovec vnet hdr.

> +       struct iovec heads[VHOST_NET_MAX_SG];
> +       int rxmaxheadcount;
>         /* We use a kind of RCU to access private pointer.
>          * All readers access it from workqueue, which makes it possible 
> to
>          * flush the workqueue instead of synchronize_rcu. Therefore 
> readers do
> @@ -120,18 +120,20 @@ long vhost_dev_ioctl(struct vhost_dev *,
>  int vhost_vq_access_ok(struct vhost_virtqueue *vq);
>  int vhost_log_access_ok(struct vhost_dev *);
>  
> +unsigned vhost_get_heads(struct vhost_virtqueue *, int datalen, int 
> *iovcount,
> +                       struct vhost_log *log, unsigned int *log_num);
>  unsigned vhost_get_vq_desc(struct vhost_dev *, struct vhost_virtqueue *,
>                            struct iovec iov[], unsigned int iov_count,
>                            unsigned int *out_num, unsigned int *in_num,
>                            struct vhost_log *log, unsigned int *log_num);
> -void vhost_discard_vq_desc(struct vhost_virtqueue *);
> +void vhost_discard_vq_desc(struct vhost_virtqueue *, int);
>  
> -int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
> -void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
> +int vhost_add_used(struct vhost_virtqueue *, struct iovec *heads, int 
> count);
>  void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue 
> *,
> -                              unsigned int head, int len);
> +                              struct iovec *heads, int count, bool 
> recvr);
> +void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *, bool);
>  void vhost_disable_notify(struct vhost_virtqueue *);
> -bool vhost_enable_notify(struct vhost_virtqueue *);
> +bool vhost_enable_notify(struct vhost_virtqueue *, bool);
>  
>  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
>                     unsigned int log_num, u64 len);
> @@ -149,7 +151,8 @@ enum {
>         VHOST_FEATURES = (1 << VIRTIO_F_NOTIFY_ON_EMPTY) |
>                          (1 << VIRTIO_RING_F_INDIRECT_DESC) |
>                          (1 << VHOST_F_LOG_ALL) |
> -                        (1 << VHOST_NET_F_VIRTIO_NET_HDR),
> +                        (1 << VHOST_NET_F_VIRTIO_NET_HDR) |
> +                        (1 << VIRTIO_NET_F_MRG_RXBUF),
>  };
>  
>  static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
> 


