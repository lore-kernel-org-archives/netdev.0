From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next] ipvlan: read direct ifindex instead of iflink
Date: Wed, 21 Oct 2015 11:32:11 -0700
Message-ID: <CAF2d9jgjgQnisih7d=d+sHMT7E1i8BgHkgRzbBLyHOWXRsyUOw@mail.gmail.com>
References: <20151020234732.GA16302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:35836 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbbJUScc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 14:32:32 -0400
Received: by ykaz22 with SMTP id z22so58867574yka.2
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 11:32:31 -0700 (PDT)
In-Reply-To: <20151020234732.GA16302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2015 at 4:47 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> In the ipv4 outbound path of an ipvlan device in l3 mode, the ifindex is
> being grabbed from dev_get_iflink. This works for the physical device
> case, since as the documentation of that function notes: "Physical
> interfaces have the same 'ifindex' and 'iflink' values.".  However, if
> the master device is a veth, and the pairs are in separate net
> namespaces, the route lookup will fail with -ENODEV due to outer veth
> pair being in a separate namespace from the ipvlan master/routing
> namespace.
>
>   ns0    |   ns1    |   ns2
>  veth0a--|--veth0b--|--ipvl0
>
interesting use case.

> In ipvlan_process_v4_outbound(), a packet sent from ipvl0 in the above
> configuration will pass fl.flowi4_oif == veth0a to
> ip_route_output_flow(), but *net == ns1.
>
> Notice also that ipv6 processing is not using iflink. Since there is a
> discrepancy in usage, fixup both v4 and v6 case to use local dev
> variable.
>
> Tested this with l3 ipvlan on top of veth, as well as with single
> physical interface in the top namespace.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/ipvlan/ipvlan_core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 24f8dbc..d50887e 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -348,7 +348,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>         struct rtable *rt;
>         int err, ret = NET_XMIT_DROP;
>         struct flowi4 fl4 = {
> -               .flowi4_oif = dev_get_iflink(dev),
> +               .flowi4_oif = dev->ifindex,
>                 .flowi4_tos = RT_TOS(ip4h->tos),
>                 .flowi4_flags = FLOWI_FLAG_ANYSRC,
>                 .daddr = ip4h->daddr,
> @@ -386,7 +386,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
>         struct dst_entry *dst;
>         int err, ret = NET_XMIT_DROP;
>         struct flowi6 fl6 = {
> -               .flowi6_iif = skb->dev->ifindex,
> +               .flowi6_iif = dev->ifindex,
>                 .daddr = ip6h->daddr,
>                 .saddr = ip6h->saddr,
>                 .flowi6_flags = FLOWI_FLAG_ANYSRC,
> --
> 2.6.1
>
