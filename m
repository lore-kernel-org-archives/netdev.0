From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Adding support for VRF traffic passed by mangle table
Date: Mon, 3 Apr 2017 09:24:06 -0400
Message-ID: <30880eec-7d79-170b-4369-73c4d0ccc4ba@cumulusnetworks.com>
References: <1491188266363.26046@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Jack Ma <Jack.Ma@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36774 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753048AbdDCNYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 09:24:10 -0400
Received: by mail-pg0-f46.google.com with SMTP id g2so118991665pge.3
        for <netdev@vger.kernel.org>; Mon, 03 Apr 2017 06:24:10 -0700 (PDT)
In-Reply-To: <1491188266363.26046@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/2/17 10:57 PM, Jack Ma wrote:
> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
> index c0cc6aa..07168d4 100644
> --- a/net/ipv4/netfilter.c
> +++ b/net/ipv4/netfilter.c
> @@ -46,6 +46,14 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
>                 fl4.flowi4_oif = l3mdev_master_ifindex(dev);

How does the above line (which is part of this block:
        fl4.flowi4_oif = sk ? sk->sk_bound_dev_if : 0;
        if (!fl4.flowi4_oif)
                fl4.flowi4_oif = l3mdev_master_ifindex(dev);

) not work? The dst should be set on the skb at this point and the
device would reference the VRF.


>         fl4.flowi4_mark = skb->mark;
>         fl4.flowi4_flags = flags;
> +
> +       /* Since we have already known this is vrf flow passed by
> +        * mangle table, we wrap the oif with the master interface.
> +        */
> +       if (fl4.flowi4_oif == 0 && fl4.daddr && skb->dev &&
> +           netif_index_is_l3_master(net, skb->dev->ifindex))
> +               fl4.flowi4_oif = skb->dev->ifindex;
> +
>         rt = ip_route_output_key(net, &fl4);
>         if (IS_ERR(rt))
>                 return PTR_ERR(rt);
> 
