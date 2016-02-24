From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 1/5] flow_dissector: Check for IP fragmentation
 even if not using IPv4 address
Date: Wed, 24 Feb 2016 10:14:05 -0800
Message-ID: <CALx6S3499MvvS2SsDQF-c+ymtekcp6TMbmBnp=n4kb5trtJU5Q@mail.gmail.com>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
	<20160224172937.12339.81437.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34131 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbcBXSO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:14:26 -0500
Received: by mail-io0-f179.google.com with SMTP id 9so52515134iom.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:14:25 -0800 (PST)
In-Reply-To: <20160224172937.12339.81437.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 9:29 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch corrects the logic for the IPv4 parsing so that it is consistent
> with how we handle IPv6.  Specifically if we do not have the flow key
> indicating we want the addresses we still may need to take a look at the IP
> fragmentation bits and to see if we should stop after we have recognized
> the L3 header.
>
> Fixes: 807e165dc44f ("flow_dissector: Add control/reporting of fragmentation")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/core/flow_dissector.c |   17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 12e700332010..1f88f8280280 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -178,15 +178,16 @@ ip:
>
>                 ip_proto = iph->protocol;
>
> -               if (!dissector_uses_key(flow_dissector,
> -                                       FLOW_DISSECTOR_KEY_IPV4_ADDRS))
> -                       break;
> +               if (dissector_uses_key(flow_dissector,
> +                                      FLOW_DISSECTOR_KEY_IPV4_ADDRS)) {
> +                       key_addrs = skb_flow_dissector_target(flow_dissector,
> +                                                             FLOW_DISSECTOR_KEY_IPV4_ADDRS,
> +                                                             target_container);
>
> -               key_addrs = skb_flow_dissector_target(flow_dissector,
> -                             FLOW_DISSECTOR_KEY_IPV4_ADDRS, target_container);
> -               memcpy(&key_addrs->v4addrs, &iph->saddr,
> -                      sizeof(key_addrs->v4addrs));
> -               key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> +                       memcpy(&key_addrs->v4addrs, &iph->saddr,
> +                              sizeof(key_addrs->v4addrs));
> +                       key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> +               }
>
>                 if (ip_is_fragment(iph)) {
>                         key_control->flags |= FLOW_DIS_IS_FRAGMENT;
>
