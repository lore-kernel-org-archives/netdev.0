From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 3/3] vhost-net: Add mergeable RX buffer support
	to vhost-net
Date: Sun, 7 Mar 2010 18:26:33 +0200
Message-ID: <20100307162633.GC24997@redhat.com>
References: <OFD112C680.DB48ADA2-ON882576DB.0000CE4F-882576DB.0001E192@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OFD112C680.DB48ADA2-ON882576DB.0000CE4F-882576DB.0001E192@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 02, 2010 at 05:20:34PM -0700, David Stevens wrote:
> This patch glues them all together and makes sure we
> notify whenever we don't have enough buffers to receive
> a max-sized packet, and adds the feature bit.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Maybe split this up?

> diff -ruN net-next-p2/drivers/vhost/net.c net-next-p3/drivers/vhost/net.c
> --- net-next-p2/drivers/vhost/net.c     2010-03-02 13:01:34.000000000 
> -0800
> +++ net-next-p3/drivers/vhost/net.c     2010-03-02 15:25:15.000000000 
> -0800
> @@ -54,26 +54,6 @@
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
> @@ -97,7 +77,7 @@
>  static void handle_tx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> -       unsigned out, in, s;
> +       unsigned out, in;
>         struct iovec head;
>         struct msghdr msg = {
>                 .msg_name = NULL,
> @@ -110,6 +90,7 @@
>         size_t len, total_len = 0;
>         int err, wmem;
>         struct socket *sock = rcu_dereference(vq->private_data);
> +

I tend not to add empty lines if line below it is already short.

>         if (!sock)
>                 return;
>  
> @@ -166,11 +147,11 @@
>                 /* Skip header. TODO: support TSO. */
>                 msg.msg_iovlen = out;
>                 head.iov_len = len = iov_length(vq->iov, out);
> +

I tend not to add empty lines if line below it is a comment.

>                 /* Sanity check */
>                 if (!len) {
>                         vq_err(vq, "Unexpected header len for TX: "
> -                              "%zd expected %zd\n",
> -                              len, vq->guest_hlen);
> +                              "%zd expected %zd\n", len, vq->guest_hlen);
>                         break;
>                 }
>                 /* TODO: Check specific error and bomb out unless ENOBUFS? 
> */
> @@ -214,7 +195,7 @@
>  static void handle_rx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -       unsigned in, log, s;
> +       unsigned in, log;
>         struct vhost_log *vq_log;
>         struct msghdr msg = {
>                 .msg_name = NULL,
> @@ -245,30 +226,36 @@
>                 if (!headcount) {
>                         vhost_enable_notify(vq);
>                         break;
> -               }
> +               } else if (vq->maxheadcount < headcount)
> +                       vq->maxheadcount = headcount;
>                 /* Skip header. TODO: support TSO/mergeable rx buffers. */
>                 msg.msg_iovlen = in;
>                 len = iov_length(vq->iov, in);
> -
>                 /* Sanity check */
>                 if (!len) {
>                         vq_err(vq, "Unexpected header len for RX: "
> -                              "%zd expected %zd\n",
> -                              len, vq->guest_hlen);
> +                              "%zd expected %zd\n", len, vq->guest_hlen);
>                         break;
>                 }
>                 err = sock->ops->recvmsg(NULL, sock, &msg,
>                                          len, MSG_DONTWAIT | MSG_TRUNC);
> -               /* TODO: Check specific error and bomb out unless EAGAIN? 
> */
>                 if (err < 0) {
> -                       vhost_discard(vq, 1);
> +                       vhost_discard(vq, headcount);
>                         break;
>                 }
>                 /* TODO: Should check and handle checksum. */
> +               if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF)) 
> {
> +                       struct virtio_net_hdr_mrg_rxbuf *vhdr =
> +                               (struct virtio_net_hdr_mrg_rxbuf *)
> +                               vq->iov[0].iov_base;
> +                       /* add num_bufs */
> +                       vq->iov[0].iov_len = vq->guest_hlen;
> +                       vhdr->num_buffers = headcount;

I don't understand this. iov_base is a userspace pointer, isn't it.
How can you assign values to it like that?
Rusty also commented earlier that it's not a good idea to assume
specific layout, such as first chunk being large enough to
include virtio_net_hdr_mrg_rxbuf.

I think we need to use memcpy to/from iovec etc.

> +               }
>                 if (err > len) {
>                         pr_err("Discarded truncated rx packet: "
>                                " len %d > %zd\n", err, len);
> -                       vhost_discard(vq, 1);
> +                       vhost_discard(vq, headcount);
>                         continue;
>                 }
>                 len = err;
> @@ -573,8 +560,6 @@
>  
>  static int vhost_net_set_features(struct vhost_net *n, u64 features)
>  {
> -       size_t hdr_size = features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ?
> -               sizeof(struct virtio_net_hdr) : 0;
>         int i;
>         mutex_lock(&n->dev.mutex);
>         if ((features & (1 << VHOST_F_LOG_ALL)) &&
> diff -ruN net-next-p2/drivers/vhost/vhost.c 
> net-next-p3/drivers/vhost/vhost.c
> --- net-next-p2/drivers/vhost/vhost.c   2010-03-02 12:53:02.000000000 
> -0800
> +++ net-next-p3/drivers/vhost/vhost.c   2010-03-02 15:24:50.000000000 
> -0800
> @@ -115,6 +115,7 @@
>         vq->log_addr = -1ull;
>         vq->guest_hlen = 0;
>         vq->sock_hlen = 0;
> +       vq->maxheadcount = 0;
>         vq->private_data = NULL;
>         vq->log_base = NULL;
>         vq->error_ctx = NULL;
> @@ -410,6 +411,7 @@
>                 vq->last_avail_idx = s.num;
>                 /* Forget the cached index value. */
>                 vq->avail_idx = vq->last_avail_idx;
> +               vq->maxheadcount = 0;
>                 break;
>         case VHOST_GET_VRING_BASE:
>                 s.index = idx;
> @@ -1114,10 +1116,23 @@
>         return 0;
>  }
>  
> +int vhost_available(struct vhost_virtqueue *vq)
> +{
> +       int avail;
> +
> +       if (!vq->maxheadcount)  /* haven't got any yet */
> +               return 1;
> +       avail = vq->avail_idx - vq->last_avail_idx;
> +       if (avail < 0)
> +               avail += 0x10000; /* wrapped */
> +       return avail;
> +}
> +
>  /* This actually signals the guest, using eventfd. */
>  void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  {
>         __u16 flags = 0;
> +

I tend not to add empty lines if a line above it is already short.

>         if (get_user(flags, &vq->avail->flags)) {
>                 vq_err(vq, "Failed to get flags");
>                 return;
> @@ -1125,7 +1140,7 @@
>  
>         /* If they don't want an interrupt, don't signal, unless empty. */
>         if ((flags & VRING_AVAIL_F_NO_INTERRUPT) &&
> -           (vq->avail_idx != vq->last_avail_idx ||
> +           (vhost_available(vq) > vq->maxheadcount ||

I don't understand this change. It seems to make
code not match the comments.

>              !vhost_has_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY)))
>                 return;
>  
> diff -ruN net-next-p2/drivers/vhost/vhost.h 
> net-next-p3/drivers/vhost/vhost.h
> --- net-next-p2/drivers/vhost/vhost.h   2010-03-02 13:02:03.000000000 
> -0800
> +++ net-next-p3/drivers/vhost/vhost.h   2010-03-02 14:29:44.000000000 
> -0800
> @@ -85,6 +85,7 @@
>         struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */
>         struct iovec heads[VHOST_NET_MAX_SG];
>         size_t guest_hlen, sock_hlen;
> +       int maxheadcount;

I don't completely understand what does this field does.
It seems to be only set on rx? Maybe name should reflect this?

>         /* We use a kind of RCU to access private pointer.
>          * All readers access it from workqueue, which makes it possible 
> to
>          * flush the workqueue instead of synchronize_rcu. Therefore 
> readers do
> @@ -151,7 +152,8 @@
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


