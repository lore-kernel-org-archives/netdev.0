From: Eric Northup <digitaleric@google.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to page
	frag allocators
Date: Tue, 29 Oct 2013 18:44:40 +0000
Message-ID: <CAG7+5M1VFSZciaZf+Y_yzm=aq1Z4fZ-QgACN2srnC9twOWhVWw@mail.gmail.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383000258-1458-1-git-send-email-mwdalton@google.com>
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

On Mon, Oct 28, 2013 at 10:44 PM, Michael Dalton <mwdalton@google.com> wrote:
> The virtio_net driver's mergeable receive buffer allocator
> uses 4KB packet buffers. For MTU-sized traffic, SKB truesize
> is > 4KB but only ~1500 bytes of the buffer is used to store
> packet data, reducing the effective TCP window size
> substantially. This patch addresses the performance concerns
> with mergeable receive buffers by allocating MTU-sized packet
> buffers using page frag allocators. If more than MAX_SKB_FRAGS
> buffers are needed, the SKB frag_list is used.

This looks really good, just one nit below -- should we add MTU-sized
packets, or add MTU+sizeof(virtnet_hdr)-sized packets?

Reviewed-by: Eric Northup <digitaleric@google.com>

>
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
>  drivers/net/virtio_net.c | 164 ++++++++++++++++++++++++++++++-----------------
>  1 file changed, 106 insertions(+), 58 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9fbdfcd..113ee93 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -124,6 +124,11 @@ struct virtnet_info {
>         /* Lock for config space updates */
>         struct mutex config_lock;
>
> +       /* Page_frag for GFP_KERNEL packet buffer allocation when we run
> +        * low on memory.
> +        */
> +       struct page_frag alloc_frag;
> +
>         /* Does the affinity hint is set for virtqueues? */
>         bool affinity_hint_set;
>
> @@ -217,33 +222,18 @@ static void skb_xmit_done(struct virtqueue *vq)
>         netif_wake_subqueue(vi->dev, vq2txq(vq));
>  }
>
> -static void set_skb_frag(struct sk_buff *skb, struct page *page,
> -                        unsigned int offset, unsigned int *len)
> -{
> -       int size = min((unsigned)PAGE_SIZE - offset, *len);
> -       int i = skb_shinfo(skb)->nr_frags;
> -
> -       __skb_fill_page_desc(skb, i, page, offset, size);
> -
> -       skb->data_len += size;
> -       skb->len += size;
> -       skb->truesize += PAGE_SIZE;
> -       skb_shinfo(skb)->nr_frags++;
> -       skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
> -       *len -= size;
> -}
> -
>  /* Called from bottom half context */
>  static struct sk_buff *page_to_skb(struct receive_queue *rq,
> -                                  struct page *page, unsigned int len)
> +                                  struct page *page, unsigned int offset,
> +                                  unsigned int len, unsigned int truesize)
>  {
>         struct virtnet_info *vi = rq->vq->vdev->priv;
>         struct sk_buff *skb;
>         struct skb_vnet_hdr *hdr;
> -       unsigned int copy, hdr_len, offset;
> +       unsigned int copy, hdr_len, hdr_padded_len;
>         char *p;
>
> -       p = page_address(page);
> +       p = page_address(page) + offset;
>
>         /* copy small packet so we can reuse these pages for small data */
>         skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
> @@ -254,16 +244,17 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>
>         if (vi->mergeable_rx_bufs) {
>                 hdr_len = sizeof hdr->mhdr;
> -               offset = hdr_len;
> +               hdr_padded_len = sizeof hdr->mhdr;
>         } else {
>                 hdr_len = sizeof hdr->hdr;
> -               offset = sizeof(struct padded_vnet_hdr);
> +               hdr_padded_len = sizeof(struct padded_vnet_hdr);
>         }
>
>         memcpy(hdr, p, hdr_len);
>
>         len -= hdr_len;
> -       p += offset;
> +       offset += hdr_padded_len;
> +       p += hdr_padded_len;
>
>         copy = len;
>         if (copy > skb_tailroom(skb))
> @@ -273,6 +264,14 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>         len -= copy;
>         offset += copy;
>
> +       if (vi->mergeable_rx_bufs) {
> +               if (len)
> +                       skb_add_rx_frag(skb, 0, page, offset, len, truesize);
> +               else
> +                       put_page(page);
> +               return skb;
> +       }
> +
>         /*
>          * Verify that we can indeed put this data into a skb.
>          * This is here to handle cases when the device erroneously
> @@ -284,9 +283,12 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>                 dev_kfree_skb(skb);
>                 return NULL;
>         }
> -
> +       BUG_ON(offset >= PAGE_SIZE);
>         while (len) {
> -               set_skb_frag(skb, page, offset, &len);
> +               unsigned int frag_size = min((unsigned)PAGE_SIZE - offset, len);
> +               skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page, offset,
> +                               frag_size, truesize);
> +               len -= frag_size;
>                 page = (struct page *)page->private;
>                 offset = 0;
>         }
> @@ -297,33 +299,52 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
>         return skb;
>  }
>
> -static int receive_mergeable(struct receive_queue *rq, struct sk_buff *skb)
> +static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
>  {
> -       struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
> +       struct skb_vnet_hdr *hdr = skb_vnet_hdr(head_skb);
> +       struct sk_buff *curr_skb = head_skb;
> +       char *buf;
>         struct page *page;
> -       int num_buf, i, len;
> +       int num_buf, len;
>
>         num_buf = hdr->mhdr.num_buffers;
>         while (--num_buf) {
> -               i = skb_shinfo(skb)->nr_frags;
> -               if (i >= MAX_SKB_FRAGS) {
> -                       pr_debug("%s: packet too long\n", skb->dev->name);
> -                       skb->dev->stats.rx_length_errors++;
> -                       return -EINVAL;
> -               }
> -               page = virtqueue_get_buf(rq->vq, &len);
> -               if (!page) {
> +               int num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
> +               buf = virtqueue_get_buf(rq->vq, &len);
> +               if (unlikely(!buf)) {
>                         pr_debug("%s: rx error: %d buffers missing\n",
> -                                skb->dev->name, hdr->mhdr.num_buffers);
> -                       skb->dev->stats.rx_length_errors++;
> +                                head_skb->dev->name, hdr->mhdr.num_buffers);
> +                       head_skb->dev->stats.rx_length_errors++;
>                         return -EINVAL;
>                 }
> -
> -               if (len > PAGE_SIZE)
> -                       len = PAGE_SIZE;
> -
> -               set_skb_frag(skb, page, 0, &len);
> -
> +               if (unlikely(len > MAX_PACKET_LEN)) {
> +                       pr_debug("%s: rx error: merge buffer too long\n",
> +                                head_skb->dev->name);
> +                       len = MAX_PACKET_LEN;
> +               }
> +               if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
> +                       struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
> +                       if (unlikely(!nskb)) {
> +                               head_skb->dev->stats.rx_dropped++;
> +                               return -ENOMEM;
> +                       }
> +                       if (curr_skb == head_skb)
> +                               skb_shinfo(curr_skb)->frag_list = nskb;
> +                       else
> +                               curr_skb->next = nskb;
> +                       curr_skb = nskb;
> +                       head_skb->truesize += nskb->truesize;
> +                       num_skb_frags = 0;
> +               }
> +               if (curr_skb != head_skb) {
> +                       head_skb->data_len += len;
> +                       head_skb->len += len;
> +                       head_skb->truesize += MAX_PACKET_LEN;
> +               }
> +               page = virt_to_head_page(buf);
> +               skb_add_rx_frag(curr_skb, num_skb_frags, page,
> +                               buf - (char *)page_address(page), len,
> +                               MAX_PACKET_LEN);
>                 --rq->num;
>         }
>         return 0;
> @@ -341,8 +362,10 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>         if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
>                 pr_debug("%s: short packet %i\n", dev->name, len);
>                 dev->stats.rx_length_errors++;
> -               if (vi->mergeable_rx_bufs || vi->big_packets)
> +               if (vi->big_packets)
>                         give_pages(rq, buf);
> +               else if (vi->mergeable_rx_bufs)
> +                       put_page(virt_to_head_page(buf));
>                 else
>                         dev_kfree_skb(buf);
>                 return;
> @@ -352,19 +375,28 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>                 skb = buf;
>                 len -= sizeof(struct virtio_net_hdr);
>                 skb_trim(skb, len);
> +       } else if (vi->mergeable_rx_bufs) {
> +               struct page *page = virt_to_head_page(buf);
> +               skb = page_to_skb(rq, page,
> +                                 (char *)buf - (char *)page_address(page),
> +                                 len, MAX_PACKET_LEN);
> +               if (unlikely(!skb)) {
> +                       dev->stats.rx_dropped++;
> +                       put_page(page);
> +                       return;
> +               }
> +               if (receive_mergeable(rq, skb)) {
> +                       dev_kfree_skb(skb);
> +                       return;
> +               }
>         } else {
>                 page = buf;
> -               skb = page_to_skb(rq, page, len);
> +               skb = page_to_skb(rq, page, 0, len, PAGE_SIZE);
>                 if (unlikely(!skb)) {
>                         dev->stats.rx_dropped++;
>                         give_pages(rq, page);
>                         return;
>                 }
> -               if (vi->mergeable_rx_bufs)
> -                       if (receive_mergeable(rq, skb)) {
> -                               dev_kfree_skb(skb);
> -                               return;
> -                       }
>         }
>
>         hdr = skb_vnet_hdr(skb);
> @@ -501,18 +533,28 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
>
>  static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>  {
> -       struct page *page;
> +       struct virtnet_info *vi = rq->vq->vdev->priv;
> +       char *buf = NULL;
>         int err;
>
> -       page = get_a_page(rq, gfp);
> -       if (!page)
> +       if (gfp & __GFP_WAIT) {

Shouldn't this be MAX_PACKET_LEN + sizeof(virtio_net_hdr_mrg_rxbuf) ?

That way, we can receive an MTU-sized packet while only consuming a
single queue entry.

> +               if (skb_page_frag_refill(MAX_PACKET_LEN, &vi->alloc_frag,
> +                                        gfp)) {
> +                       buf = (char *)page_address(vi->alloc_frag.page) +
> +                             vi->alloc_frag.offset;
> +                       get_page(vi->alloc_frag.page);
> +                       vi->alloc_frag.offset += MAX_PACKET_LEN;
> +               }
> +       } else {
> +               buf = netdev_alloc_frag(MAX_PACKET_LEN);
> +       }
> +       if (!buf)
>                 return -ENOMEM;
>
> -       sg_init_one(rq->sg, page_address(page), PAGE_SIZE);
> -
> -       err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, page, gfp);
> +       sg_init_one(rq->sg, buf, MAX_PACKET_LEN);
> +       err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
>         if (err < 0)
> -               give_pages(rq, page);
> +               put_page(virt_to_head_page(buf));
>
>         return err;
>  }
> @@ -1343,8 +1385,10 @@ static void free_unused_bufs(struct virtnet_info *vi)
>                 struct virtqueue *vq = vi->rq[i].vq;
>
>                 while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
> -                       if (vi->mergeable_rx_bufs || vi->big_packets)
> +                       if (vi->big_packets)
>                                 give_pages(&vi->rq[i], buf);
> +                       else if (vi->mergeable_rx_bufs)
> +                               put_page(virt_to_head_page(buf));
>                         else
>                                 dev_kfree_skb(buf);
>                         --vi->rq[i].num;
> @@ -1650,6 +1694,8 @@ free_recv_bufs:
>  free_vqs:
>         cancel_delayed_work_sync(&vi->refill);
>         virtnet_del_vqs(vi);
> +       if (vi->alloc_frag.page)
> +               put_page(vi->alloc_frag.page);
>  free_index:
>         free_percpu(vi->vq_index);
>  free_stats:
> @@ -1685,6 +1731,8 @@ static void virtnet_remove(struct virtio_device *vdev)
>         unregister_netdev(vi->dev);
>
>         remove_vq_common(vi);
> +       if (vi->alloc_frag.page)
> +               put_page(vi->alloc_frag.page);
>
>         flush_work(&vi->config_work);
>
> --
> 1.8.4.1
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
