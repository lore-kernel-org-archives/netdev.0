From: Tom Herbert <therbert@google.com>
Subject: Re: GRE with GRO very slow when forwarding starting with 3.14.24
Date: Mon, 24 Nov 2014 10:16:26 -0800
Message-ID: <CA+mtBx9SOr5RH7S63S28YbgxR8EwjgfS_dUkS2A4D1W3NzazHQ@mail.gmail.com>
References: <2340533.MickblD7NF@h2o.as.studentenwerk.mhn.de>
	<1416847696.17888.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Walter <linux@stwm.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:47755 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbaKXSQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 13:16:27 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so9416728iec.20
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 10:16:26 -0800 (PST)
In-Reply-To: <1416847696.17888.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 8:48 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Mon, 2014-11-24 at 17:13 +0100, Wolfgang Walter wrote:
> > Hello,
> >
> > starting with 3.14.24 GRE with GRO on is very slow. To be more specific:
> >
> > yyyy <--> GRO_endpoint <-_> .... <--> |eth0<->GRO-endpoint | eth1 |<-> xxxx
> >
> > routing (IPv4) between xxxx and yyyy is very slow when GRO is enabled on eth0
> > and/or eth1 starting with stable kernel 3.14.24
> >
> > Regards,
>
>
> tcpdump might help, but I presume GSO is no longer working properly on
> egress.
>
Inner mac header is probably not being set in GRO->GSO GRE path.
Please try this also:

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index bb5947b..51973dd 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -247,6 +247,9 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
                err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);

        rcu_read_unlock();
+
+       skb_set_inner_mac_header(skb, nhoff + grehlen);
+
        return err;
 }


> Can you try to revert :
>
> commit abe640984aa492652232b65d3579361cf6d461f5
> Author: Tom Herbert <therbert@google.com>
> Date:   Thu Oct 30 08:40:56 2014 -0700
>
>     gre: Use inner mac length when computing tunnel length
>
>     [ Upstream commit 14051f0452a2c26a3f4791e6ad6a435e8f1945ff ]
>
>     Currently, skb_inner_network_header is used but this does not account
>     for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header which
>     handles TEB and also should work with IP encapsulation in which case
>     inner mac and inner network headers are the same.
>
>     Tested: Ran TCP_STREAM over GRE, worked as expected.
>
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index 2d24f293f977..8c8493ea6b1c 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -50,7 +50,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>
>         greh = (struct gre_base_hdr *)skb_transport_header(skb);
>
> -       ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
> +       ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
>         if (unlikely(ghl < sizeof(*greh)))
>                 goto out;
>
>
