From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 10 May 2010 10:09:03 -0700
Message-ID: <OF1F65A110.7C63CDB3-ON8825771F.005DD80E-8825771F.005E3509@us.ibm.com>
References: <20100510164303.GA28798@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kvm@vger.kernel.org, kvm-owner@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.osdl.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100510164303.GA28798@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since "datalen" carries the difference and will be negative by that amount
from the original loop, what about just adding something like:

        }
        if (headcount)
                heads[headcount-1].len += datalen;
[and really, headcount >0 since datalen > 0, so just:

        heads[headcount-1].len += datalen;

                                                +-DLS


kvm-owner@vger.kernel.org wrote on 05/10/2010 09:43:03 AM:

> On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> > @@ -218,18 +248,19 @@ static void handle_rx(struct vhost_net *
> >     use_mm(net->dev.mm);
> >     mutex_lock(&vq->mutex);
> >     vhost_disable_notify(vq);
> > -   hdr_size = vq->hdr_size;
> > +   vhost_hlen = vq->vhost_hlen;
> > 
> >     vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
> >        vq->log : NULL;
> > 
> > -   for (;;) {
> > -      head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> > -                ARRAY_SIZE(vq->iov),
> > -                &out, &in,
> > -                vq_log, &log);
> > +   while ((datalen = vhost_head_len(vq, sock->sk))) {
> > +      headcount = vhost_get_desc_n(vq, vq->heads,
> > +                    datalen + vhost_hlen,
> > +                    &in, vq_log, &log);
> > +      if (headcount < 0)
> > +         break;
> >        /* OK, now we need to know about added descriptors. */
> > -      if (head == vq->num) {
> > +      if (!headcount) {
> >           if (unlikely(vhost_enable_notify(vq))) {
> >              /* They have slipped one in as we were
> >               * doing that: check again. */
> > @@ -241,46 +272,53 @@ static void handle_rx(struct vhost_net *
> >           break;
> >        }
> >        /* We don't need to be notified again. */
> > -      if (out) {
> > -         vq_err(vq, "Unexpected descriptor format for RX: "
> > -                "out %d, int %d\n",
> > -                out, in);
> > -         break;
> > -      }
> > -      /* Skip header. TODO: support TSO/mergeable rx buffers. */
> > -      s = move_iovec_hdr(vq->iov, vq->hdr, hdr_size, in);
> > +      if (vhost_hlen)
> > +         /* Skip header. TODO: support TSO. */
> > +         s = move_iovec_hdr(vq->iov, vq->hdr, vhost_hlen, in);
> > +      else
> > +         s = copy_iovec_hdr(vq->iov, vq->hdr, vq->sock_hlen, in);
> >        msg.msg_iovlen = in;
> >        len = iov_length(vq->iov, in);
> >        /* Sanity check */
> >        if (!len) {
> >           vq_err(vq, "Unexpected header len for RX: "
> >                  "%zd expected %zd\n",
> > -                iov_length(vq->hdr, s), hdr_size);
> > +                iov_length(vq->hdr, s), vhost_hlen);
> >           break;
> >        }
> >        err = sock->ops->recvmsg(NULL, sock, &msg,
> >                  len, MSG_DONTWAIT | MSG_TRUNC);
> >        /* TODO: Check specific error and bomb out unless EAGAIN? */
> >        if (err < 0) {
> > -         vhost_discard_vq_desc(vq);
> > +         vhost_discard_desc(vq, headcount);
> >           break;
> >        }
> > -      /* TODO: Should check and handle checksum. */
> > -      if (err > len) {
> > -         pr_err("Discarded truncated rx packet: "
> > -                " len %d > %zd\n", err, len);
> > -         vhost_discard_vq_desc(vq);
> > +      if (err != datalen) {
> > +         pr_err("Discarded rx packet: "
> > +                " len %d, expected %zd\n", err, datalen);
> > +         vhost_discard_desc(vq, headcount);
> >           continue;
> >        }
> >        len = err;
> > -      err = memcpy_toiovec(vq->hdr, (unsigned char *)&hdr, hdr_size);
> > -      if (err) {
> > -         vq_err(vq, "Unable to write vnet_hdr at addr %p: %d\n",
> > -                vq->iov->iov_base, err);
> > +      if (vhost_hlen &&
> > +          memcpy_toiovecend(vq->hdr, (unsigned char *)&hdr, 0,
> > +                  vhost_hlen)) {
> > +         vq_err(vq, "Unable to write vnet_hdr at addr %p\n",
> > +                vq->iov->iov_base);
> >           break;
> >        }
> > -      len += hdr_size;
> > -      vhost_add_used_and_signal(&net->dev, vq, head, len);
> > +      /* TODO: Should check and handle checksum. */
> > +      if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
> > +          memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
> > +                  offsetof(typeof(hdr), num_buffers),
> > +                  sizeof(hdr.num_buffers))) {
> > +         vq_err(vq, "Failed num_buffers write");
> > +         vhost_discard_desc(vq, headcount);
> > +         break;
> > +      }
> > +      len += vhost_hlen;
> > +      vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
> > +                   headcount);
> >        if (unlikely(vq_log))
> >           vhost_log_write(vq, vq_log, log, len);
> >        total_len += len;
> 
> OK I think I see the bug here: vhost_add_used_and_signal_n
> does not get the actual length, it gets the iovec length from vhost.
> Guest virtio uses this as packet length, with bad results.
> 
> So I have applied the follows and it seems to have fixed the problem:
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index c16db02..9d7496d 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -219,7 +219,7 @@ static int peek_head_len(struct vhost_virtqueue *vq, 

> struct sock *sk)
>  /* This is a multi-buffer version of vhost_get_desc, that works if
>   *   vq has read descriptors only.
>   * @vq      - the relevant virtqueue
> - * @datalen   - data length we'll be reading
> + * @datalen   - data length we'll be reading. must be > 0
>   * @iovcount   - returned count of io vectors we fill
>   * @log      - vhost log
>   * @log_num   - log offset
> @@ -236,9 +236,10 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
>     int seg = 0;
>     int headcount = 0;
>     unsigned d;
> +   size_t len;
>     int r, nlogs = 0;
> 
> -   while (datalen > 0) {
> +   for (;;) {
>        if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
>           r = -ENOBUFS;
>           goto err;
> @@ -260,16 +261,20 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
>           nlogs += *log_num;
>           log += *log_num;
>        }
> +      len = iov_length(vq->iov + seg, in);
> +      seg += in;
>        heads[headcount].id = d;
> -      heads[headcount].len = iov_length(vq->iov + seg, in);
> -      datalen -= heads[headcount].len;
> +      if (datalen <= len)
> +         break;
> +      heads[headcount].len = len;
>        ++headcount;
> -      seg += in;
> +      datalen -= len;
>     }
> +   heads[headcount].len = datalen;
>     *iovcount = seg;
>     if (unlikely(log))
>        *log_num = nlogs;
> -   return headcount;
> +   return headcount + 1;
>  err:
>     vhost_discard_desc(vq, headcount);
>     return r;
> 
> -- 
> MST
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

