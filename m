From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 4/4] packet: tpacket_snd gso and checksum offload
Date: Wed, 3 Feb 2016 11:38:12 -0500
Message-ID: <CAF=yD-KRbWbAqRB=4z+nPnQXLm3QGWd5TCs52uutt9WcLq=LDQ@mail.gmail.com>
References: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1454428609-26885-5-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:34819 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420AbcBCQix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 11:38:53 -0500
Received: by mail-lb0-f196.google.com with SMTP id dx9so755887lbc.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 08:38:52 -0800 (PST)
In-Reply-To: <1454428609-26885-5-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         union tpacket_uhdr ph;
On Tue, Feb 2, 2016 at 10:56 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Support socket option PACKET_VNET_HDR together with PACKET_TX_RING.
>>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 53 +++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 37 insertions(+), 16 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 89377bf..41e25b6 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2495,7 +2495,7 @@ static int packet_snd_vnet_gso(struct sk_buff *skb,
>

> +               if (po->has_vnet_hdr) {
> +                       vnet_hdr = data;
> +                       if (tp_len < sizeof(*vnet_hdr) ||
> +                           __packet_snd_vnet_parse(vnet_hdr, tp_len)) {
> +                               tp_len = -EINVAL;
> +                               goto tpacket_error;
> +                       }
> +                       data += sizeof(*vnet_hdr);
> +                       tp_len -= sizeof(*vnet_hdr);

I left a bug here. tp_len must have the virtio_net_hdr subtracted before
bounds check vnet_hdr->hdr_len <= tp_len in __packet_snd_vnet_gso.

Will send a v2.

> +                       copylen = __virtio16_to_cpu(vio_le(),
> +                                                   vnet_hdr->hdr_len);
> +               }
> +               if (dev->hard_header_len) {
> +                       if (ll_header_truncated(dev, tp_len)) {
> +                               tp_len = -EINVAL;
> +                               goto tpacket_error;
> +                       }
> +                       copylen = max_t(int, copylen, dev->hard_header_len);
> +               }
>                 skb = sock_alloc_send_skb(&po->sk,
> -                               hlen + tlen + sizeof(struct sockaddr_ll),
> +                               hlen + tlen + sizeof(struct sockaddr_ll) +
> +                               (copylen - dev->hard_header_len),
>                                 !need_wait, &err);
>
>                 if (unlikely(skb == NULL)) {
> @@ -2705,9 +2723,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>                         goto out_status;
>                 }
>                 tp_len = tpacket_fill_skb(po, skb, ph, dev, data, tp_len, proto,
> -                                         addr, hlen);
> +                                         addr, hlen, copylen);
>                 if (likely(tp_len >= 0) &&
>                     tp_len > dev->mtu + reserve &&
> +                   !po->has_vnet_hdr &&
>                     !packet_extra_vlan_len_allowed(dev, skb))
>                         tp_len = -EMSGSIZE;
>
> @@ -2726,6 +2745,11 @@ tpacket_error:
>                         }
>                 }
>
> +               if (po->has_vnet_hdr && packet_snd_vnet_gso(skb, vnet_hdr)) {
> +                       tp_len = -EINVAL;
> +                       goto tpacket_error;
> +               }
> +
>                 packet_pick_tx_queue(dev, skb);
>
>                 skb->destructor = tpacket_destruct_skb;
> @@ -3616,9 +3640,6 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>                 }
>                 if (optlen < len)
>                         return -EINVAL;
> -               if (pkt_sk(sk)->has_vnet_hdr &&
> -                   optname == PACKET_TX_RING)
> -                       return -EINVAL;
>                 if (copy_from_user(&req_u.req, optval, len))
>                         return -EFAULT;
>                 return packet_set_ring(sk, &req_u, 0,
> --
> 2.7.0.rc3.207.g0ac5344
>
