From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 5/5] udp: additional GRO support
Date: Sun, 22 Jun 2014 14:40:31 +0300
Message-ID: <CAJZOPZKQNK6uMB_ObYeBkJ1h3ybOpPmsurKCEHCForTR3Sv6kg@mail.gmail.com>
References: <alpine.DEB.2.02.1406201631360.11831@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:37375 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbaFVLkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 07:40:32 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so5103787qgf.1
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 04:40:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406201631360.11831@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 21, 2014 at 2:38 AM, Tom Herbert <therbert@google.com> wrote:
> Implement GRO for UDPv6. Add UDP checksum verification in gro_receive
> for both UDP4 and UDP6 calling skb_gro_checksum_validate_zero_check.
> Also, remove check for CHECKSUM_COMPLETE in udp_gro_receive, any
> checksum type should be handled now.


[...]

> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index fb8e6ba..2ab9051 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c

> -static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
> +struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
> +                                struct udphdr *uh)
>  {
>         struct udp_offload_priv *uo_priv;
>         struct sk_buff *p, **pp = NULL;
> -       struct udphdr *uh, *uh2;
> -       unsigned int hlen, off;
> +       struct udphdr *uh2;
> +       unsigned int off = skb_gro_offset(skb);
>         int flush = 1;
>
> -       if (NAPI_GRO_CB(skb)->udp_mark ||
> -           (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
> +       if (NAPI_GRO_CB(skb)->udp_mark)
>                 goto out;

Before this change we were practically requiring SKBs to carry their
->encapsulation mark set but not any more.
