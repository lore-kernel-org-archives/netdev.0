From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually belongs to
 device
Date: Tue, 15 Nov 2016 15:45:29 +0100
Message-ID: <7543fa0f-a053-8387-1862-d78ffadba688@stressinduktion.org>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
 <1479141867.3723362.787321689.4A3DCFD6@webmail.messagingengine.com>
 <fd1c804d-3e44-0321-8a3e-67d6ff7357fa@cumulusnetworks.com>
 <7d8c0210-9132-c755-9053-6ec19409e343@stressinduktion.org>
 <c75290bd-7ea2-0bf8-7ac0-fc5a3c81e312@cumulusnetworks.com>
 <7779da88-08dc-0adb-42dd-8e00502693df@stressinduktion.org>
 <0214eaf8-70c6-5a37-cddd-faa1c4268871@cumulusnetworks.com>
 <1479148385.3747043.787432273.5FCC2F4F@webmail.messagingengine.com>
 <CAHmME9ppx01YR9Db1oPpm6FJ+BmpqSxvjQ2S+GT0DXO09_M4oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Netdev <netdev@vger.kernel.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>,
        LKML <linux-kernel@vger.kernel.org>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38968 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933070AbcKOOpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 09:45:32 -0500
In-Reply-To: <CAHmME9ppx01YR9Db1oPpm6FJ+BmpqSxvjQ2S+GT0DXO09_M4oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Jason,

On 15.11.2016 01:45, Jason A. Donenfeld wrote:
> I'll have a better look at this. Perhaps this should be modeled on
> what we currently do for userspace, which might amount to something
> more or less like:

Cool, thanks!

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 6001e78..0721915 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -925,6 +925,7 @@ static int ip6_dst_lookup_tail(struct net *net,
> const struct sock *sk,
>  #endif
>          int err;
>          int flags = 0;
> +        int addr_type, bind_to_dev;
> 
>          /* The correct way to handle this would be to do
>           * ip6_route_get_saddr, and then ip6_route_output; however,
> @@ -1012,6 +1013,16 @@ static int ip6_dst_lookup_tail(struct net *net,
> const struct sock *sk,
>          }
>  #endif
> 
> +        addr_type = ipv6_addr_type(&fl6->saddr);
> +        if (addr_type == IPv6_ADDR_ANY)
> +                return 0;
> +
> +        err = -EINVAL;
> +        bind_to_dev = __ipv6_addr_src_scope(addr_type) <=
> IPV6_ADDR_SCOPE_LINKLOCAL;
> +        if (!ipv6_chk_addr(net, &fl6->saddr, bind_to_dev ?
> (*dst)->dev : NULL, 0) &&
> +            !ipv6_chk_acast_addr_src(net, (*dst)->dev, &fl6->saddr))
> +                goto out_err_release;
> +
>          return 0;
> 
>  out_err_release:
> 

We should not use (*dst)->dev, as this is the resulting device after the
lookup and not necessarily corresponds to the device the user asked for.
Thus you need to pass in fl6.flowi6_oif. Thus to kill the necessary
ifindex->net_device lookup, I would suggest to move
ipv6_chk_addr_and_flags to use ifindex instead of net_device (0
corresponds to the net_device == NULL case). It seems to me this would
make the code easier. ipv6_chk_addr can simply pass down dev->ifindex to
ipv6_chk_addr.

Probably for checking anycast address you need to look up the
net_device, thus use dev_get_by_index_rcu. But probably the unicast
filter will already hit thus the whole traversing of anycast addresses
won't happen in normal cases. This could be separated to its own function.

In the non-strict case we don't necessarily need bind_to_dev?

Bye,
Hannes
