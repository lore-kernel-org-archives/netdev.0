From: Rolf Neugebauer via Virtualization
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH net] virtio-net: restore VIRTIO_HDR_F_DATA_VALID on
	receiving
Date: Fri, 20 Jan 2017 10:56:24 +0000
Message-ID: <CA+pO-2dmS1s-zGry-+Nodh-UrVVVDeVDM7OxfnHOaWPUS4bOqw@mail.gmail.com>
References: <1484893962-7614-1-git-send-email-jasowang@redhat.com>
Reply-To: Rolf Neugebauer <rolf.neugebauer@docker.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	mst@redhat.com, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1484893962-7614-1-git-send-email-jasowang@redhat.com>
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

On Fri, Jan 20, 2017 at 6:32 AM, Jason Wang <jasowang@redhat.com> wrote:
> Commit 501db511397f ("virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on
> xmit") in fact disables VIRTIO_HDR_F_DATA_VALID on receiving path too,
> fixing this by adding a hint (has_data_valid) and set it only on the
> receiving path.
>
> Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Rolf Neugebauer <rolf.neugebauer@docker.com>

Ah, I missed this use of the function. Looks like this patch does not
regress the issue I was seeing with virtio_net.

Rolf

> ---
>  drivers/net/macvtap.c      | 2 +-
>  drivers/net/tun.c          | 2 +-
>  drivers/net/virtio_net.c   | 2 +-
>  include/linux/virtio_net.h | 6 +++++-
>  net/packet/af_packet.c     | 4 ++--
>  5 files changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 5c26653..4026185 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -825,7 +825,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>                         return -EINVAL;
>
>                 if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
> -                                           macvtap_is_little_endian(q)))
> +                                           macvtap_is_little_endian(q), true))
>                         BUG();
>
>                 if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index cd8e02c..2cd10b2 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1360,7 +1360,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>                         return -EINVAL;
>
>                 if (virtio_net_hdr_from_skb(skb, &gso,
> -                                           tun_is_little_endian(tun))) {
> +                                           tun_is_little_endian(tun), true)) {
>                         struct skb_shared_info *sinfo = skb_shinfo(skb);
>                         pr_err("unexpected GSO type: "
>                                "0x%x, gso_size %d, hdr_len %d\n",
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4a10500..3474243 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1104,7 +1104,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>                 hdr = skb_vnet_hdr(skb);
>
>         if (virtio_net_hdr_from_skb(skb, &hdr->hdr,
> -                                   virtio_is_little_endian(vi->vdev)))
> +                                   virtio_is_little_endian(vi->vdev), false))
>                 BUG();
>
>         if (vi->mergeable_rx_bufs)
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 5643647..5209b5e 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -56,7 +56,8 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
>
>  static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>                                           struct virtio_net_hdr *hdr,
> -                                         bool little_endian)
> +                                         bool little_endian,
> +                                         bool has_data_valid)
>  {
>         memset(hdr, 0, sizeof(*hdr));   /* no info leak */
>
> @@ -91,6 +92,9 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>                                 skb_checksum_start_offset(skb));
>                 hdr->csum_offset = __cpu_to_virtio16(little_endian,
>                                 skb->csum_offset);
> +       } else if (has_data_valid &&
> +                  skb->ip_summed == CHECKSUM_UNNECESSARY) {
> +               hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
>         } /* else everything is zero */
>
>         return 0;
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b9e1a13..3d555c7 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1976,7 +1976,7 @@ static int packet_rcv_vnet(struct msghdr *msg, const struct sk_buff *skb,
>                 return -EINVAL;
>         *len -= sizeof(vnet_hdr);
>
> -       if (virtio_net_hdr_from_skb(skb, &vnet_hdr, vio_le()))
> +       if (virtio_net_hdr_from_skb(skb, &vnet_hdr, vio_le(), true))
>                 return -EINVAL;
>
>         return memcpy_to_msg(msg, (void *)&vnet_hdr, sizeof(vnet_hdr));
> @@ -2237,7 +2237,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
>         if (po->has_vnet_hdr) {
>                 if (virtio_net_hdr_from_skb(skb, h.raw + macoff -
>                                             sizeof(struct virtio_net_hdr),
> -                                           vio_le())) {
> +                                           vio_le(), true)) {
>                         spin_lock(&sk->sk_receive_queue.lock);
>                         goto drop_n_account;
>                 }
> --
> 2.7.4
>
