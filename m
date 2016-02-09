From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH] net: Copy inner L3 and L4 headers as unaligned on GRE TEB
Date: Tue, 9 Feb 2016 16:39:43 +0100
Message-ID: <CALx6S37Ut1oYbBBwUVtijM_vLqmpbkTbsdMYZA=Qg=yrqjcSXg@mail.gmail.com>
References: <20160209141234.19305.82202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34616 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756881AbcBIPjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 10:39:43 -0500
Received: by mail-ig0-f172.google.com with SMTP id ik10so110587421igb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 07:39:43 -0800 (PST)
In-Reply-To: <20160209141234.19305.82202.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 9, 2016 at 3:14 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch corrects the unaligned accesses seen on GRE TEB tunnels when
> generating hash keys.  Specifically what this patch does is make it so that
> we force the use of skb_copy_bits when the GRE inner headers will be
> unaligned due to NET_IP_ALIGNED being a non-zero value.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>
> I don't have the ability to test it but this should fix flow dissector for
> GRE TEB tunnels traffic seen on architectures that require network and
> transport headers to be 4 byte aligned.
>
>  net/core/flow_dissector.c |    7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 699b2c415cb0..9c181ba7263e 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -402,6 +402,13 @@ ip_proto_again:
>                                 goto out_bad;
>                         proto = eth->h_proto;
>                         nhoff += sizeof(*eth);
> +
> +                       /* Cap headers that we access via pointers at the
> +                        * end of the Ethernet header as our maximum alignment
> +                        * at that point is only 2 bytes.
> +                        */
> +                       if (NET_IP_ALIGN)
> +                               hlen = nhoff;
>                 }
>
>                 key_control->flags |= FLOW_DIS_ENCAPSULATION;
>
