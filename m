From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net v3 4/5] packet: infer protocol from ethernet header if unset
Date: Wed, 11 Nov 2015 18:10:51 -0500
Message-ID: <CA+FuTSfVmgbwHEFFaQ4g7gqACHA9jbMPdn+0JHvnZAmHcKeMzg@mail.gmail.com>
References: <cover.1447278504.git.daniel@iogearbox.net> <1ff9ac2b71fd4d65bec94db62e3750c88ada5d80.1447278504.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:33699 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbbKKXLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 18:11:23 -0500
Received: by vkbk63 with SMTP id k63so514707vkb.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 15:11:22 -0800 (PST)
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com. [209.85.213.49])
        by smtp.gmail.com with ESMTPSA id o138sm155900vkd.24.2015.11.11.15.11.21
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 15:11:21 -0800 (PST)
Received: by vkbk63 with SMTP id k63so514411vkb.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 15:11:21 -0800 (PST)
In-Reply-To: <1ff9ac2b71fd4d65bec94db62e3750c88ada5d80.1447278504.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 5:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> In case no struct sockaddr_ll has been passed to packet
> socket's sendmsg() when doing a TX_RING flush run, then
> skb->protocol is set to po->num instead, which is the protocol
> passed via socket(2)/bind(2).
>
> Applications only xmitting can go the path of allocating the
> socket as socket(PF_PACKET, <mode>, 0) and do a bind(2) on the
> TX_RING with sll_protocol of 0. That way, register_prot_hook()
> is neither called on creation nor on bind time, which saves
> cycles when there's no interest in capturing anyway.
>
> That leaves us however with po->num 0 instead and therefore
> the TX_RING flush run sets skb->protocol to 0 as well. Eric
> reported that this leads to problems when using tools like
> trafgen over bonding device.
> I.e. the bonding's hash function
> could invoke the kernel's flow dissector, which depends on
> skb->protocol being properly set. In the current situation, all
> the traffic is then directed to a single slave.
>
> Fix it up by inferring skb->protocol from the Ethernet header
> when not set and we have ARPHRD_ETHER device type. This is only
> done in case of SOCK_RAW and where we have a dev->hard_header_len
> length. In case of ARPHRD_ETHER devices, this is guaranteed to
> cover ETH_HLEN, and therefore being accessed on the skb after
> the skb_store_bits().
>
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/packet/af_packet.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 8795b0f..0066da2 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2338,6 +2338,15 @@ static bool ll_header_truncated(const struct net_device *dev, int len)
>         return false;
>  }
>
> +static void tpacket_set_protocol(const struct net_device *dev,
> +                                struct sk_buff *skb)
> +{
> +       if (dev->type == ARPHRD_ETHER) {
> +               skb_reset_mac_header(skb);
> +               skb->protocol = eth_hdr(skb)->h_proto;
> +       }
> +}
> +
>  static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>                 void *frame, struct net_device *dev, int size_max,
>                 __be16 proto, unsigned char *addr, int hlen)
> @@ -2419,6 +2428,8 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>                                 dev->hard_header_len);
>                 if (unlikely(err))
>                         return err;
> +               if (!skb->protocol)
> +                       tpacket_set_protocol(dev, skb);
>
>                 data += dev->hard_header_len;
>                 to_write -= dev->hard_header_len;
> --
> 1.9.3
>
