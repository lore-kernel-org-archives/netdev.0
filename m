From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 2/3] vhost-net: handle vnet_hdr processing for
	MRG_RX_BUF
Date: Sun, 7 Mar 2010 18:12:29 +0200
Message-ID: <20100307161229.GB24997@redhat.com>
References: <OF9CBCD776.645508E4-ON882576DB.0000CB6E-882576DB.0001DED1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219Ab0CGQQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Mar 2010 11:16:07 -0500
Content-Disposition: inline
In-Reply-To: <OF9CBCD776.645508E4-ON882576DB.0000CB6E-882576DB.0001DED1@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 05:20:26PM -0700, David Stevens wrote:
> This patch adds vnet_hdr processing for mergeable buffer
> support to vhost-net.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> diff -ruN net-next-p1/drivers/vhost/net.c net-next-p2/drivers/vhost/net.c

Could you please add -p to diff flags so that it's easier
to figure out which function is changes?

> --- net-next-p1/drivers/vhost/net.c     2010-03-01 11:44:22.000000000 
> -0800
> +++ net-next-p2/drivers/vhost/net.c     2010-03-02 13:01:34.000000000 
> -0800
> @@ -109,7 +109,6 @@
>         };
>         size_t len, total_len = 0;
>         int err, wmem;
> -       size_t hdr_size;
>         struct socket *sock = rcu_dereference(vq->private_data);
>         if (!sock)
>                 return;
> @@ -124,7 +123,6 @@
>  
>         if (wmem < sock->sk->sk_sndbuf * 2)
>                 tx_poll_stop(net);
> -       hdr_size = vq->hdr_size;
>  
>         for (;;) {
>                 head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
> @@ -148,25 +146,45 @@
>                                "out %d, int %d\n", out, in);
>                         break;
>                 }
> +               if (vq->guest_hlen > vq->sock_hlen) {
> +                       if (msg.msg_iov[0].iov_len == vq->guest_hlen)
> +                               msg.msg_iov[0].iov_len = vq->sock_hlen;
> +                       else if (out == ARRAY_SIZE(vq->iov))
> +                               vq_err(vq, "handle_tx iov overflow!");
> +                       else {
> +                               int i;
> +
> +                               /* give header its own iov */
> +                               for (i=out; i>0; ++i)
> +                                       msg.msg_iov[i+1] = msg.msg_iov[i];
> +                               msg.msg_iov[0].iov_len = vq->sock_hlen;
> +                               msg.msg_iov[1].iov_base += vq->guest_hlen;
> +                               msg.msg_iov[1].iov_len -= vq->guest_hlen;
> +                               out++;

We seem to spend a fair bit of code here and elsewhere trying to cover
the diff between header size in guest and host.  In hindsight, it was
not a good idea to put new padding between data and the header:
virtio-net should have added it *before*. But it is what it is.

Wouldn't it be easier to just add an ioctl to tap so that
vnet header size is made bigger by 4 bytes?

> +                       }
> +               }
>                 /* Skip header. TODO: support TSO. */
> -               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
>                 msg.msg_iovlen = out;
>                 head.iov_len = len = iov_length(vq->iov, out);
>                 /* Sanity check */
>                 if (!len) {
>                         vq_err(vq, "Unexpected header len for TX: "
>                                "%zd expected %zd\n",
> -                              iov_length(vq->hdr, s), hdr_size);
> +                              len, vq->guest_hlen);
>                         break;
>                 }
>                 /* TODO: Check specific error and bomb out unless ENOBUFS? 
> */
>                 err = sock->ops->sendmsg(NULL, sock, &msg, len);
>                 if (unlikely(err < 0)) {
> -                       vhost_discard(vq, 1);
> -                       tx_poll_start(net, sock);
> +                       if (err == -EAGAIN) {

The comment mentions ENOBUFS. Are you sure it's EAGAIN?

> +                               tx_poll_start(net, sock);

Don't we need to call discard to move the last avail header back?

> +                       } else {
> +                               vq_err(vq, "sendmsg: errno %d\n", -err);
> +                               /* drop packet; do not discard/resend */
> + vhost_add_used_and_signal(&net->dev,vq,&head,1);
> +                       }
>                         break;
> -               }
> -               if (err != len)
> +               } else if (err != len)


Previous if ends with break so no need for else here.

>                         pr_err("Truncated TX packet: "
>                                " len %d != %zd\n", err, len);
>                 vhost_add_used_and_signal(&net->dev, vq, &head, 1);
> @@ -207,14 +225,8 @@
>                 .msg_flags = MSG_DONTWAIT,
>         };
>  
> -       struct virtio_net_hdr hdr = {
> -               .flags = 0,
> -               .gso_type = VIRTIO_NET_HDR_GSO_NONE
> -       };
> -
>         size_t len, total_len = 0;
>         int err, headcount, datalen;
> -       size_t hdr_size;
>         struct socket *sock = rcu_dereference(vq->private_data);
>  
>         if (!sock || !skb_head_len(&sock->sk->sk_receive_queue))
> @@ -223,7 +235,6 @@
>         use_mm(net->dev.mm);
>         mutex_lock(&vq->mutex);
>         vhost_disable_notify(vq);
> -       hdr_size = vq->hdr_size;
>  
>         vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>                 vq->log : NULL;
> @@ -232,25 +243,18 @@
>                 headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
> &log);
>                 /* OK, now we need to know about added descriptors. */
>                 if (!headcount) {
> -                       if (unlikely(vhost_enable_notify(vq))) {
> -                               /* They have slipped one in as we were
> -                                * doing that: check again. */
> -                               vhost_disable_notify(vq);
> -                               continue;
> -                       }
> -                       /* Nothing new?  Wait for eventfd to tell us
> -                        * they refilled. */
> +                       vhost_enable_notify(vq);


You don't think this race can happen?

>                         break;
>                 }
>                 /* Skip header. TODO: support TSO/mergeable rx buffers. */
> -               s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
>                 msg.msg_iovlen = in;
>                 len = iov_length(vq->iov, in);
> +
>                 /* Sanity check */
>                 if (!len) {
>                         vq_err(vq, "Unexpected header len for RX: "
>                                "%zd expected %zd\n",
> -                              iov_length(vq->hdr, s), hdr_size);
> +                              len, vq->guest_hlen);
>                         break;
>                 }
>                 err = sock->ops->recvmsg(NULL, sock, &msg,
> @@ -268,13 +272,7 @@
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
> +               len += vq->guest_hlen - vq->sock_hlen;
>                 vhost_add_used_and_signal(&net->dev, vq, vq->heads, 
> headcount);
>                 if (unlikely(vq_log))
>                         vhost_log_write(vq, vq_log, log, len);
> @@ -483,6 +481,13 @@
>         return ERR_PTR(-ENOTSOCK);
>  }
>  
> +static int vhost_sock_is_raw(struct socket *sock)
> +{
> +       if (!sock || !sock->sk)
> +               return 0;
> +       return sock->sk->sk_type == SOCK_RAW;
> +}
> +
>  static long vhost_net_set_backend(struct vhost_net *n, unsigned index, 
> int fd)
>  {
>         struct socket *sock, *oldsock;
> @@ -519,6 +524,20 @@
>  
>         vhost_net_disable_vq(n, vq);
>         rcu_assign_pointer(vq->private_data, sock);
> +
> +       if (sock && sock->sk) {
> +               if (!vhost_sock_is_raw(sock) ||

I dislike this backend-specific code, it ties us with specifics of
backend implementations, which change without notice.  Ideally all
backend-specific stuff should live in userspace, userspace programs
vhost device appropriately.

> +                   vhost_has_feature(&n->dev, 
> VHOST_NET_F_VIRTIO_NET_HDR)) {
> +                       vq->sock_hlen = sizeof(struct virtio_net_hdr);
> +                       if (vhost_has_feature(&n->dev, 
> VIRTIO_NET_F_MRG_RXBUF))
> +                               vq->guest_hlen =
> +                                       sizeof(struct 
> virtio_net_hdr_mrg_rxbuf);
> +                       else
> +                               vq->guest_hlen = sizeof(struct 
> virtio_net_hdr);
> +               } else
> +                       vq->guest_hlen = vq->sock_hlen = 0;
> +       } else
> +               vq_err(vq, "vhost_net_set_backend: sock->sk is NULL");

As proposed above, IMO it would be nicer to add an ioctl in tap
that let us program header size.

>         vhost_net_enable_vq(n, vq);
>         mutex_unlock(&vq->mutex);
>  done:
> @@ -566,8 +585,17 @@
>         n->dev.acked_features = features;
>         smp_wmb();
>         for (i = 0; i < VHOST_NET_VQ_MAX; ++i) {
> -               mutex_lock(&n->vqs[i].mutex);
> -               n->vqs[i].hdr_size = hdr_size;
> +               struct vhost_virtqueue *vq = n->vqs + i;
> +               struct socket *sock = vq->private_data;
> +
> +               mutex_lock(&vq->mutex);
> +               if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
> +                       vq->sock_hlen = sizeof(struct 
> virtio_net_hdr_mrg_rxbuf);
> +               else if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR) ||
> +                        !vhost_sock_is_raw(sock))
> +                       vq->sock_hlen = sizeof(struct virtio_net_hdr);
> +               else
> +                       vq->sock_hlen = 0;
>                 mutex_unlock(&n->vqs[i].mutex);
>         }
>         vhost_net_flush(n);
> diff -ruN net-next-p1/drivers/vhost/vhost.c 
> net-next-p2/drivers/vhost/vhost.c
> --- net-next-p1/drivers/vhost/vhost.c   2010-03-01 11:44:06.000000000 
> -0800
> +++ net-next-p2/drivers/vhost/vhost.c   2010-03-02 12:53:02.000000000 
> -0800
> @@ -113,7 +113,8 @@
>         vq->used_flags = 0;
>         vq->log_used = false;
>         vq->log_addr = -1ull;
> -       vq->hdr_size = 0;
> +       vq->guest_hlen = 0;
> +       vq->sock_hlen = 0;
>         vq->private_data = NULL;
>         vq->log_base = NULL;
>         vq->error_ctx = NULL;
> @@ -848,20 +849,85 @@
>         return 0;
>  }
>  
> +static int
> +vhost_get_hdr(struct vhost_virtqueue *vq, int *in, struct vhost_log *log,
> +       int *log_num)
> +{
> +       struct iovec *heads = vq->heads;
> +       struct iovec *iov = vq->iov;
> +       int out;
> +
> +       *in = 0;
> +       iov[0].iov_len = 0;
> +
> +       /* get buffer, starting from iov[1] */
> +       heads[0].iov_base = (void *)vhost_get_vq_desc(vq->dev, vq,
> +               vq->iov+1, ARRAY_SIZE(vq->iov)-1, &out, in, log, log_num);
> +       if (out || *in <= 0) {
> +               vq_err(vq, "unexpected descriptor format for RX: out %d, "
> +                       "in %d\n", out, *in);
> +               return 0;
> +       }
> +       if (heads[0].iov_base == (void *)vq->num)
> +               return 0;
> +
> +       /* make iov[0] the header */
> +       if (!vq->guest_hlen) {
> +               if (vq->sock_hlen) {
> +                       static struct virtio_net_hdr junk; /* bit bucket 
> */
> +
> +                       iov[0].iov_base = &junk;
> +                       iov[0].iov_len = sizeof(junk);
> +               } else
> +                       iov[0].iov_len = 0;
> +       }
> +       if (vq->sock_hlen < vq->guest_hlen) {
> +               iov[0].iov_base = iov[1].iov_base;
> +               iov[0].iov_len = vq->sock_hlen;
> +
> +               if (iov[1].iov_len < vq->sock_hlen) {
> +                       vq_err(vq, "can't fit header in one buffer!");
> +                       vhost_discard(vq, 1);
> +                       return 0;
> +               }
> +               if (!vq->sock_hlen) {
> +                       static const struct virtio_net_hdr_mrg_rxbuf hdr = 
> {
> +                               .hdr.flags = 0,
> +                               .hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
> +                       };
> +                       memcpy(iov[0].iov_base, &hdr, vq->guest_hlen);
> +               }
> +               iov[1].iov_base += vq->guest_hlen;
> +               iov[1].iov_len -= vq->guest_hlen;
> +       }
> +       return 1;

The above looks kind of scary, lots of special-casing.  I'll send a
patch for tap to set vnet header size, let's see if it makes life easier
for us.

> +}
> +
>  unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
> *iovcount,
>         struct vhost_log *log, unsigned int *log_num)
>  {
>         struct iovec *heads = vq->heads;
> -       int out, in;
> +       int out, in = 0;
> +       int seg = 0;
>         int hc = 0;

I think it's better to stick to simple names like i
for index variables, alternatively give it a meaningful
name like "count".

>  
> +       if (vq->guest_hlen != vq->sock_hlen) {

Sticking guest_hlen/sock_hlen in vhost is somewhat ugly.

> +               seg = vhost_get_hdr(vq, &in, log, log_num);
> +               if (!seg)
> +                       return 0;
> +               hc++;
> +               datalen -= iov_length(vq->iov+seg, in);
> +               seg += in;
> +       }
> +
>         while (datalen > 0) {
>                 if (hc >= VHOST_NET_MAX_SG) {
>                         vhost_discard(vq, hc);
>                         return 0;
>                 }
>                 heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
> vq,
> -                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, log, 
> log_num);
> +                       vq->iov+seg, ARRAY_SIZE(vq->iov)-seg, &out, &in,
> +                       log, log_num);
>                 if (heads[hc].iov_base == (void *)vq->num) {
>                         vhost_discard(vq, hc);
>                         return 0;
> @@ -872,11 +938,12 @@
>                         vhost_discard(vq, hc);
>                         return 0;
>                 }
> -               heads[hc].iov_len = iov_length(vq->iov, in);
> -               hc++;
> +               heads[hc].iov_len = iov_length(vq->iov+seg, in);
>                 datalen -= heads[hc].iov_len;
> +               hc++;
> +               seg += in;
>         }
> -       *iovcount = in;
> +       *iovcount = seg;
>         return hc;
>  }
>  
> diff -ruN net-next-p1/drivers/vhost/vhost.h 
> net-next-p2/drivers/vhost/vhost.h
> --- net-next-p1/drivers/vhost/vhost.h   2010-03-01 11:42:18.000000000 
> -0800
> +++ net-next-p2/drivers/vhost/vhost.h   2010-03-02 13:02:03.000000000 
> -0800
> @@ -82,10 +82,9 @@
>         u64 log_addr;
>  
>         struct iovec indirect[VHOST_NET_MAX_SG];
> -       struct iovec iov[VHOST_NET_MAX_SG];
> -       struct iovec hdr[VHOST_NET_MAX_SG];
> +       struct iovec iov[VHOST_NET_MAX_SG+1]; /* an extra for vnet hdr */
>         struct iovec heads[VHOST_NET_MAX_SG];
> -       size_t hdr_size;
> +       size_t guest_hlen, sock_hlen;
>         /* We use a kind of RCU to access private pointer.
>          * All readers access it from workqueue, which makes it possible 
> to
>          * flush the workqueue instead of synchronize_rcu. Therefore 
> readers do
> 


