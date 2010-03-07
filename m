From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC][ PATCH 1/3] vhost-net: support multiple buffer heads in
	receiver
Date: Sun, 7 Mar 2010 17:31:30 +0200
Message-ID: <20100307153130.GA24997@redhat.com>
References: <OF201C1B9E.C89ADF9F-ON882576DB.00006AD7-882576DB.0001DA4E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF201C1B9E.C89ADF9F-ON882576DB.00006AD7-882576DB.0001DA4E@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 02, 2010 at 05:20:15PM -0700, David Stevens wrote:
> This patch generalizes buffer handling functions to
> support multiple buffer heads.
> 
> In-line for viewing, attached for applying.
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> diff -ruN net-next-p0/drivers/vhost/net.c net-next-p1/drivers/vhost/net.c
> --- net-next-p0/drivers/vhost/net.c     2010-02-24 12:59:24.000000000 
> -0800
> +++ net-next-p1/drivers/vhost/net.c     2010-03-01 11:44:22.000000000 
> -0800
> @@ -97,7 +97,8 @@
>  static void handle_tx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_TX];
> -       unsigned head, out, in, s;
> +       unsigned out, in, s;
> +       struct iovec head;
>         struct msghdr msg = {
>                 .msg_name = NULL,
>                 .msg_namelen = 0,
> @@ -126,12 +127,10 @@
>         hdr_size = vq->hdr_size;
>  
>         for (;;) {
> -               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -                                        ARRAY_SIZE(vq->iov),
> -                                        &out, &in,
> -                                        NULL, NULL);
> +               head.iov_base = (void *)vhost_get_vq_desc(&net->dev, vq,
> +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, NULL, 
> NULL);

Should type for head be changed so that we do not need to cast?

I also prefer aligning descendants on the opening (.

>                 /* Nothing new?  Wait for eventfd to tell us they 
> refilled. */
> -               if (head == vq->num) {
> +               if (head.iov_base == (void *)vq->num) {
>                         wmem = atomic_read(&sock->sk->sk_wmem_alloc);
>                         if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
>                                 tx_poll_start(net, sock);
> @@ -152,7 +151,7 @@
>                 /* Skip header. TODO: support TSO. */
>                 s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, out);
>                 msg.msg_iovlen = out;
> -               len = iov_length(vq->iov, out);
> +               head.iov_len = len = iov_length(vq->iov, out);
>                 /* Sanity check */
>                 if (!len) {
>                         vq_err(vq, "Unexpected header len for TX: "
> @@ -163,14 +162,14 @@
>                 /* TODO: Check specific error and bomb out unless ENOBUFS? 
> */
>                 err = sock->ops->sendmsg(NULL, sock, &msg, len);
>                 if (unlikely(err < 0)) {
> -                       vhost_discard_vq_desc(vq);
> +                       vhost_discard(vq, 1);

Isn't the original name a bit more descriptive?

>                         tx_poll_start(net, sock);
>                         break;
>                 }
>                 if (err != len)
>                         pr_err("Truncated TX packet: "
>                                " len %d != %zd\n", err, len);
> -               vhost_add_used_and_signal(&net->dev, vq, head, 0);
> +               vhost_add_used_and_signal(&net->dev, vq, &head, 1);
>                 total_len += len;
>                 if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>                         vhost_poll_queue(&vq->poll);
> @@ -182,12 +181,22 @@
>         unuse_mm(net->dev.mm);
>  }
>  
> +static int skb_head_len(struct sk_buff_head *skq)
> +{
> +       struct sk_buff *head;
> +
> +       head = skb_peek(skq);
> +       if (head)
> +               return head->len;
> +       return 0;
> +}
> +

This is done without locking, which I think can crash
if skb is consumed after we peek it but before we read the
length.


>  /* Expects to be always run from workqueue - which acts as
>   * read-size critical section for our kind of RCU. */
>  static void handle_rx(struct vhost_net *net)
>  {
>         struct vhost_virtqueue *vq = &net->dev.vqs[VHOST_NET_VQ_RX];
> -       unsigned head, out, in, log, s;
> +       unsigned in, log, s;
>         struct vhost_log *vq_log;
>         struct msghdr msg = {
>                 .msg_name = NULL,
> @@ -204,10 +213,11 @@
>         };
>  
>         size_t len, total_len = 0;
> -       int err;
> +       int err, headcount, datalen;
>         size_t hdr_size;
>         struct socket *sock = rcu_dereference(vq->private_data);
> -       if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
> +
> +       if (!sock || !skb_head_len(&sock->sk->sk_receive_queue))
>                 return;
>  

Isn't this equivalent? Do you expect zero len skbs in socket?
If yes, maybe we should discard these, not stop processing ...


>         use_mm(net->dev.mm);
> @@ -218,13 +228,10 @@
>         vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
>                 vq->log : NULL;
>  
> -       for (;;) {
> -               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> -                                        ARRAY_SIZE(vq->iov),
> -                                        &out, &in,
> -                                        vq_log, &log);
> +       while ((datalen = skb_head_len(&sock->sk->sk_receive_queue))) {

This peeks in the queue to figure out how much data we have.
It's a neat trick, but it does introduce new failure modes
where an skb is consumed after we did the peek:
- new skb could be shorter, we should return the unconsumed part
- new skb could be longer, this will drop a packet.
  maybe this last is not an issue as the race should be rare in practice

> +               headcount = vhost_get_heads(vq, datalen, &in, vq_log, 
> &log);
>                 /* OK, now we need to know about added descriptors. */
> -               if (head == vq->num) {
> +               if (!headcount) {
>                         if (unlikely(vhost_enable_notify(vq))) {
>                                 /* They have slipped one in as we were
>                                  * doing that: check again. */
> @@ -235,13 +242,6 @@
>                          * they refilled. */
>                         break;
>                 }
> -               /* We don't need to be notified again. */

you find this comment unhelpful?

> -               if (out) {
> -                       vq_err(vq, "Unexpected descriptor format for RX: "
> -                              "out %d, int %d\n",
> -                              out, in);
> -                       break;
> -               }


we still need this check, don't we?

>                 /* Skip header. TODO: support TSO/mergeable rx buffers. */
>                 s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
>                 msg.msg_iovlen = in;
> @@ -257,14 +257,14 @@
>                                          len, MSG_DONTWAIT | MSG_TRUNC);
>                 /* TODO: Check specific error and bomb out unless EAGAIN? 
> */
>                 if (err < 0) {
> -                       vhost_discard_vq_desc(vq);
> +                       vhost_discard(vq, 1);
>                         break;
>                 }
>                 /* TODO: Should check and handle checksum. */
>                 if (err > len) {
>                         pr_err("Discarded truncated rx packet: "
>                                " len %d > %zd\n", err, len);
> -                       vhost_discard_vq_desc(vq);
> +                       vhost_discard(vq, 1);
>                         continue;
>                 }
>                 len = err;
> @@ -275,7 +275,7 @@
>                         break;
>                 }
>                 len += hdr_size;
> -               vhost_add_used_and_signal(&net->dev, vq, head, len);
> +               vhost_add_used_and_signal(&net->dev, vq, vq->heads, 
> headcount);
>                 if (unlikely(vq_log))
>                         vhost_log_write(vq, vq_log, log, len);
>                 total_len += len;
> diff -ruN net-next-p0/drivers/vhost/vhost.c 
> net-next-p1/drivers/vhost/vhost.c
> --- net-next-p0/drivers/vhost/vhost.c   2010-02-15 20:08:35.000000000 
> -0800
> +++ net-next-p1/drivers/vhost/vhost.c   2010-03-01 11:44:06.000000000 
> -0800
> @@ -848,6 +848,38 @@
>         return 0;
>  }
>  
> +unsigned vhost_get_heads(struct vhost_virtqueue *vq, int datalen, int 
> *iovcount,
> +       struct vhost_log *log, unsigned int *log_num)

Could you please document this function's parameters? It's not obvious
what iovcount, log, log_num are.

> +{
> +       struct iovec *heads = vq->heads;
> +       int out, in;
> +       int hc = 0;
> +
> +       while (datalen > 0) {
> +               if (hc >= VHOST_NET_MAX_SG) {
> +                       vhost_discard(vq, hc);
> +                       return 0;
> +               }
> +               heads[hc].iov_base = (void *)vhost_get_vq_desc(vq->dev, 
> vq,
> +                       vq->iov, ARRAY_SIZE(vq->iov), &out, &in, log, 
> log_num);
> +               if (heads[hc].iov_base == (void *)vq->num) {
> +                       vhost_discard(vq, hc);
> +                       return 0;
> +               }
> +               if (out || in <= 0) {
> +                       vq_err(vq, "unexpected descriptor format for RX: "
> +                               "out %d, in %d\n", out, in);
> +                       vhost_discard(vq, hc);
> +                       return 0;
> +               }
> +               heads[hc].iov_len = iov_length(vq->iov, in);
> +               hc++;
> +               datalen -= heads[hc].iov_len;
> +       }
> +       *iovcount = in;


Only the last value?

> +       return hc;
> +}
> +
>  /* This looks in the virtqueue and for the first available buffer, and 
> converts
>   * it to an iovec for convenient access.  Since descriptors consist of 
> some
>   * number of output then some number of input descriptors, it's actually 
> two
> @@ -973,31 +1005,32 @@
>  }
>  
>  /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */
> -void vhost_discard_vq_desc(struct vhost_virtqueue *vq)
> +void vhost_discard(struct vhost_virtqueue *vq, int n)
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
>  {
>         struct vring_used_elem *used;
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
> +       for (i=0; i<count; i++, vq->last_used_idx++) {

whitespace damage: I prefer space around =, <.
I also use ++i, etc in this driver, better be consistent?
Also for clarity, I prefer to put vq->last_used_idx inside the loop.

> +               used = &vq->used->ring[vq->last_used_idx % vq->num];
> +               if (put_user((unsigned)heads[i].iov_base, &used->id)) {
> +                       vq_err(vq, "Failed to write used id");
> +                       return -EFAULT;
> +               }
> +               if (put_user(heads[i].iov_len, &used->len)) {
> +                       vq_err(vq, "Failed to write used len");
> +                       return -EFAULT;
> +               }

If this fails, last_used_idx will still be incremented, which I think is wrong.

>         }
>         /* Make sure buffer is written before we update index. */
>         smp_wmb();
> -       if (put_user(vq->last_used_idx + 1, &vq->used->idx)) {
> +       if (put_user(vq->last_used_idx, &vq->used->idx)) {

here, too

>                 vq_err(vq, "Failed to increment used idx");
>                 return -EFAULT;
>         }
> @@ -1011,7 +1044,6 @@
>                 if (vq->log_ctx)
>                         eventfd_signal(vq->log_ctx, 1);
>         }
> -       vq->last_used_idx++;
>         return 0;
>  }
>  
> @@ -1038,9 +1070,9 @@
>  /* And here's the combo meal deal.  Supersize me! */
>  void vhost_add_used_and_signal(struct vhost_dev *dev,
>                                struct vhost_virtqueue *vq,
> -                              unsigned int head, int len)
> +                              struct iovec *heads, int count)
>  {
> -       vhost_add_used(vq, head, len);
> +       vhost_add_used(vq, heads, count);
>         vhost_signal(dev, vq);
>  }
>  
> diff -ruN net-next-p0/drivers/vhost/vhost.h 
> net-next-p1/drivers/vhost/vhost.h
> --- net-next-p0/drivers/vhost/vhost.h   2010-02-15 20:08:35.000000000 
> -0800
> +++ net-next-p1/drivers/vhost/vhost.h   2010-03-01 11:42:18.000000000 
> -0800
> @@ -84,6 +84,7 @@
>         struct iovec indirect[VHOST_NET_MAX_SG];
>         struct iovec iov[VHOST_NET_MAX_SG];
>         struct iovec hdr[VHOST_NET_MAX_SG];
> +       struct iovec heads[VHOST_NET_MAX_SG];
>         size_t hdr_size;
>         /* We use a kind of RCU to access private pointer.
>          * All readers access it from workqueue, which makes it possible 
> to
> @@ -120,16 +121,18 @@
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
> +void vhost_discard(struct vhost_virtqueue *, int);
>  
> -int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
> -void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
> +int vhost_add_used(struct vhost_virtqueue *, struct iovec *heads, int 
> count);
>  void vhost_add_used_and_signal(struct vhost_dev *, struct vhost_virtqueue 
> *,
> -                              unsigned int head, int len);
> +                              struct iovec *heads, int count);
> +void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
>  void vhost_disable_notify(struct vhost_virtqueue *);
>  bool vhost_enable_notify(struct vhost_virtqueue *);
>  


