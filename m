From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v3 5/5] packet: fix tpacket_snd max frame len
Date: Wed, 11 Nov 2015 17:56:30 -0500
Message-ID: <CA+FuTScyeTKgg0ZgF9WH53Sa+Ugyx5s3A_LAQDa5UfKg1hKDCQ@mail.gmail.com>
References: <cover.1447278504.git.daniel@iogearbox.net> <45ebab096c421823fdf50bd3ff8b2fafd55a0402.1447278504.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:32888 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbbKKW5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:57:02 -0500
Received: by vkbk63 with SMTP id k63so327677vkb.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:57:01 -0800 (PST)
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com. [209.85.213.49])
        by smtp.gmail.com with ESMTPSA id 14sm102446vko.9.2015.11.11.14.57.00
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 14:57:00 -0800 (PST)
Received: by vkas68 with SMTP id s68so324997vka.2
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:57:00 -0800 (PST)
In-Reply-To: <45ebab096c421823fdf50bd3ff8b2fafd55a0402.1447278504.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 5:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Since it's introduction in commit 69e3c75f4d54 ("net: TX_RING and
> packet mmap"), TX_RING could be used from SOCK_DGRAM and SOCK_RAW
> side. When used with SOCK_DGRAM only, the size_max > dev->mtu +
> reserve check should have reserve as 0, but currently, this is
> unconditionally set (in it's original form as dev->hard_header_len).
>
> I think this is not correct since tpacket_fill_skb() would then
> take dev->mtu and dev->hard_header_len into account for SOCK_DGRAM,
> the extra VLAN_HLEN could be possible in both cases. Presumably, the
> reserve code was copied from packet_snd(), but later on missed the
> check. Make it similar as we have it in packet_snd().
>
> Fixes: 69e3c75f4d54 ("net: TX_RING and packet mmap")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 0066da2..242bce1 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2510,12 +2510,13 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>         if (unlikely(!(dev->flags & IFF_UP)))
>                 goto out_put;
>
> -       reserve = dev->hard_header_len + VLAN_HLEN;
> +       if (po->sk.sk_socket->type == SOCK_RAW)
> +               reserve = dev->hard_header_len;
>         size_max = po->tx_ring.frame_size
>                 - (po->tp_hdrlen - sizeof(struct sockaddr_ll));
>
> -       if (size_max > dev->mtu + reserve)
> -               size_max = dev->mtu + reserve;
> +       if (size_max > dev->mtu + reserve + VLAN_HLEN)
> +               size_max = dev->mtu + reserve + VLAN_HLEN;
>
>         do {
>                 ph = packet_current_frame(po, &po->tx_ring,
> @@ -2542,7 +2543,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>                 tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
>                                           addr, hlen);
>                 if (likely(tp_len >= 0) &&
> -                   tp_len > dev->mtu + dev->hard_header_len &&
> +                   tp_len > dev->mtu + reserve &&
>                     !packet_extra_vlan_len_allowed(dev, skb))
>                         tp_len = -EMSGSIZE;
>
> --
> 1.9.3
>
