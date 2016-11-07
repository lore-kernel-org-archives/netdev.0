From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 06/11] net: l3mdev: remove redundant calls
Date: Mon, 7 Nov 2016 19:13:13 +0900
Message-ID: <CAKD1Yr21aQnjyrb6P7aThvnhNLaJt-yrFsyokUBCyOJZkKXwJQ@mail.gmail.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com> <1473534602-23602-7-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:37979 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbcKGKNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 05:13:34 -0500
Received: by mail-it0-f53.google.com with SMTP id q124so117806278itd.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 02:13:34 -0800 (PST)
In-Reply-To: <1473534602-23602-7-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 4:09 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> A previous patch added l3mdev flow update making these hooks
> redundant. Remove them.
> [...]
> @@ -1582,8 +1582,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
>         }
>
>         oif = arg->bound_dev_if;
> -       if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
> -               oif = skb->skb_iif;
> +       oif = oif ? : skb->skb_iif;
>
>         flowi4_init_output(&fl4, oif,
>                            IP4_REPLY_MARK(net, skb->mark),

This broke one of our unit tests. The expectation in the test was that
the RST replying to a SYN sent to a closed port should be generated
with oif=0. In other words it should not prefer the interface where
the SYN came in on, but instead should follow whatever the routing
table says it should do.

As far as I can tell this changed ~2 months ago, on 2016-09-10, when
e0d56fd was applied (step #2 below). Previously, oif was either a
passed-in sk_bound_dev_if or 0. Specifically:

1. "f7ba868 net: Use VRF index for oif in ip_send_unicast_reply" set
oif if the interface was an L3 master.

-       flowi4_init_output(&fl4, arg->bound_dev_if,
+       oif = arg->bound_dev_if;
+       if (!oif && netif_index_is_vrf(net, skb->skb_iif))
+               oif = skb->skb_iif;
+
+       flowi4_init_output(&fl4, oif,

2. "e0d56fd net: l3mdev: remove redundant calls" removed the
netif_index_is_l3_master call and just set oif to skb_iif. This
changed the behaviour:

        oif = arg->bound_dev_if;
-       if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
-               oif = skb->skb_iif;
+       oif = oif ? : skb->skb_iif;

3. Later, netif_index_is_l3_master was removed by 19664c6a0009 ("net:
l3mdev: Remove netif_index_is_l3_master"). The removal was reverted by
"6104e11 net: ipv4: Do not drop to make_route if oif is l3mdev". But
this revert didn't change ip_send_unicast_reply back to what it was.

What should we do here? It would seem that now that
netif_index_is_l3_master has been resurrected, it's appropriate to use
it here as well. The user-visible behaviour changed only two months
ago. Unless we think that RSTs should always mirror the iif, in which
case I can change our tests accordingly.

Cheers,
Lorenzo
