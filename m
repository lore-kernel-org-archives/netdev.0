From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v2 3/3] packet: fix tpacket_snd max frame and vlan handling
Date: Tue, 10 Nov 2015 17:52:13 -0500
Message-ID: <CA+FuTSfkD4aMciGeqon0cLp=EJ7fWis56nGQsbku82ZC+=nNWg@mail.gmail.com>
References: <cover.1447191361.git.daniel@iogearbox.net> <f664dc9cf1d33a001fcdb0265833c96644db5bfd.1447191361.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, tklauser@distanz.ch,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:34610 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbKJWwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 17:52:44 -0500
Received: by ykfs79 with SMTP id s79so21338936ykf.1
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 14:52:43 -0800 (PST)
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com. [209.85.160.174])
        by smtp.gmail.com with ESMTPSA id m130sm6950022ywb.48.2015.11.10.14.52.42
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 14:52:43 -0800 (PST)
Received: by ykfs79 with SMTP id s79so21338086ykf.1
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 14:52:42 -0800 (PST)
In-Reply-To: <f664dc9cf1d33a001fcdb0265833c96644db5bfd.1447191361.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         if (sock->type == SOCK_DGRAM) {
> -               err = dev_hard_header(skb, dev, ntohs(proto), addr,
> -                               NULL, tp_len);
> +               /* In DGRAM sockets, we expect struct sockaddr_ll was filled
> +                * via struct msghdr, so we have dest mac and skb->protocol.
> +                * Otherwise there's not too much useful things we can do in
> +                * this flush run.
> +                */
> +               err = dev_hard_header(skb, dev, ntohs(skb->protocol), addr,
> +                                     NULL, tp_len);

This change is not really necessary.

>                 if (unlikely(err < 0))
>                         return -EINVAL;
> -       } else if (dev->hard_header_len) {

Why remove the check on hard_header_len?

> -               if (ll_header_truncated(dev, tp_len))
> -                       return -EINVAL;
> +       } else {
> +               /* If skb->protocol is still 0, try to infer/guess it. Might
> +                * not be fully reliable in the sense that a user could still
> +                * change/race data afterwards, but on the other hand the proto

The race goes away when probing it after the copy in skb_store_bits.
Then it is also certain that tp_len is long enough to hold the entire
link layer header.

> +                * can be set arbitrarily anyways. We only need to take care
> +                * in case of extra large VLAN frames.
> +                */
> +               if (!skb->protocol && tp_len >= ETH_HLEN)
> +                       skb->protocol = ((struct ethhdr *)data)->h_proto;

Packet sockets are not restricted to link layer of type Ethernet.

There are a few other points in this file that also cast mac header
to eth_hdr(skb).

>
> -               skb_push(skb, dev->hard_header_len);
> -               err = skb_store_bits(skb, 0, data,
> -                               dev->hard_header_len);
> -               if (unlikely(err))
> -                       return err;
> +               /* Copy Ethernet header in case we need to deal with extra
> +                * VLAN space as otherwise data could change underneath us.
> +                * The caller already accomodated for enough linear room.
> +                */
> +               if (dev->hard_header_len || tp_len > dev->mtu + reserve) {
> +                       int hdr_len = dev->hard_header_len;
> +
> +                       if (hdr_len < ETH_HLEN)
> +                               hdr_len = ETH_HLEN;
> +                       if (unlikely(ll_header_truncated(hdr_len, tp_len)))
> +                               return -EINVAL;
> +
> +                       skb_push(skb, hdr_len);
> +                       err = skb_store_bits(skb, 0, data, hdr_len);
> +                       if (unlikely(err))
> +                               return err;
>
> -               data += dev->hard_header_len;
> -               to_write -= dev->hard_header_len;
> +                       data     += hdr_len;
> +                       to_write -= hdr_len;
> +               }
>         }
>
>         offset = offset_in_page(data);
> @@ -2447,6 +2471,20 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>                 len = ((to_write > len_max) ? len_max : to_write);
>         }
>
> +       /* Check for full frame with extra VLAN space. We can probe
> +        * here on the linear header, if necessary. Earlier code
> +        * assumed this would be a VLAN pkt, double-check this now
> +        * that we have the actual packet and protocol at hand.
> +        */
> +       if (tp_len > dev->mtu + reserve) {
> +               if (skb->protocol != htons(ETH_P_8021Q))
> +                       return -EMSGSIZE;
> +
> +               skb_reset_mac_header(skb);
> +               if (eth_hdr(skb)->h_proto != htons(ETH_P_8021Q))
> +                       return -EMSGSIZE;
> +       }
> +
>         skb_probe_transport_header(skb, 0);
>
>         return tp_len;
> @@ -2493,12 +2531,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>         if (unlikely(!(dev->flags & IFF_UP)))
>                 goto out_put;
>
> -       reserve = dev->hard_header_len + VLAN_HLEN;
> -       size_max = po->tx_ring.frame_size
> -               - (po->tp_hdrlen - sizeof(struct sockaddr_ll));
> -
> -       if (size_max > dev->mtu + reserve)
> -               size_max = dev->mtu + reserve;
> +       if (po->sk.sk_socket->type == SOCK_RAW)
> +               reserve = dev->hard_header_len;
> +       size_max = po->tx_ring.frame_size - (po->tp_hdrlen -
> +                                            sizeof(struct sockaddr_ll));
> +       if (size_max > dev->mtu + reserve + VLAN_HLEN)
> +               size_max = dev->mtu + reserve + VLAN_HLEN;
>
>         do {
>                 ph = packet_current_frame(po, &po->tx_ring,
> @@ -2523,20 +2561,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>                         goto out_status;
>                 }
>                 tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
> -                                         addr, hlen);
> -               if (likely(tp_len >= 0) &&
> -                   tp_len > dev->mtu + dev->hard_header_len) {
> -                       struct ethhdr *ehdr;
> -                       /* Earlier code assumed this would be a VLAN pkt,
> -                        * double-check this now that we have the actual
> -                        * packet in hand.
> -                        */
> -
> -                       skb_reset_mac_header(skb);
> -                       ehdr = eth_hdr(skb);
> -                       if (ehdr->h_proto != htons(ETH_P_8021Q))
> -                               tp_len = -EMSGSIZE;
> -               }
> +                                         addr, hlen, reserve);
>                 if (unlikely(tp_len < 0)) {
>                         if (po->tp_loss) {
>                                 __packet_set_status(po, ph,
> @@ -2754,7 +2779,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>                 if (unlikely(offset < 0))
>                         goto out_free;
>         } else {
> -               if (ll_header_truncated(dev, len))
> +               if (unlikely(ll_header_truncated(dev->hard_header_len, len)))
>                         goto out_free;
>         }
>
> --
> 1.9.3
>
