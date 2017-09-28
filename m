From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 5/5] vhost_net: basic tx virtqueue batched
	processing
Date: Wed, 27 Sep 2017 20:55:13 -0400
Message-ID: <CAF=yD-LuKXo93kUYS_1fhL88jGmS6LHiTzi=JpSoRucNSp3k4g@mail.gmail.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
	<1506067355-5771-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1506067355-5771-6-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

> @@ -461,6 +460,7 @@ static void handle_tx(struct vhost_net *net)
>         struct socket *sock;
>         struct vhost_net_ubuf_ref *uninitialized_var(ubufs);
>         bool zcopy, zcopy_used;
> +       int i, batched = VHOST_NET_BATCH;
>
>         mutex_lock(&vq->mutex);
>         sock = vq->private_data;
> @@ -475,6 +475,12 @@ static void handle_tx(struct vhost_net *net)
>         hdr_size = nvq->vhost_hlen;
>         zcopy = nvq->ubufs;
>
> +       /* Disable zerocopy batched fetching for simplicity */

This special case can perhaps be avoided if we no longer block
on vhost_exceeds_maxpend, but revert to copying.

> +       if (zcopy) {
> +               heads = &used;

Can this special case of batchsize 1 not use vq->heads?

> +               batched = 1;
> +       }
> +
>         for (;;) {
>                 /* Release DMAs done buffers first */
>                 if (zcopy)
> @@ -486,95 +492,114 @@ static void handle_tx(struct vhost_net *net)
>                 if (unlikely(vhost_exceeds_maxpend(net)))
>                         break;

> +                       /* TODO: Check specific error and bomb out
> +                        * unless ENOBUFS?
> +                        */
> +                       err = sock->ops->sendmsg(sock, &msg, len);
> +                       if (unlikely(err < 0)) {
> +                               if (zcopy_used) {
> +                                       vhost_net_ubuf_put(ubufs);
> +                                       nvq->upend_idx =
> +                                  ((unsigned)nvq->upend_idx - 1) % UIO_MAXIOV;
> +                               }
> +                               vhost_discard_vq_desc(vq, 1);
> +                               goto out;
> +                       }
> +                       if (err != len)
> +                               pr_debug("Truncated TX packet: "
> +                                       " len %d != %zd\n", err, len);
> +                       if (!zcopy) {
> +                               vhost_add_used_idx(vq, 1);
> +                               vhost_signal(&net->dev, vq);
> +                       } else if (!zcopy_used) {
> +                               vhost_add_used_and_signal(&net->dev,
> +                                                         vq, head, 0);

While batching, perhaps can also move this producer index update
out of the loop and using vhost_add_used_and_signal_n.

> +                       } else
> +                               vhost_zerocopy_signal_used(net, vq);
> +                       vhost_net_tx_packet(net);
> +                       if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> +                               vhost_poll_queue(&vq->poll);
> +                               goto out;
>                         }
> -                       vhost_discard_vq_desc(vq, 1);
> -                       break;
> -               }
> -               if (err != len)
> -                       pr_debug("Truncated TX packet: "
> -                                " len %d != %zd\n", err, len);
> -               if (!zcopy_used)
> -                       vhost_add_used_and_signal(&net->dev, vq, head, 0);
> -               else
> -                       vhost_zerocopy_signal_used(net, vq);
> -               vhost_net_tx_packet(net);
> -               if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> -                       vhost_poll_queue(&vq->poll);
> -                       break;

This patch touches many lines just for indentation. If having to touch
these lines anyway (dirtying git blame), it may be a good time to move
the processing of a single descriptor code into a separate helper function.
And while breaking up, perhaps another helper for setting up ubuf_info.
If you agree, preferably in a separate noop refactor patch that precedes
the functional changes.
