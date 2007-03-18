From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Don't apply the offset of two allocations to the layer headers
Date: Sun, 18 Mar 2007 00:17:12 -0300
Message-ID: <39e6f6c70703172017g1b86198bw1c586f985dd508a6@mail.gmail.com>
References: <20070318031224.GA17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:58606 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbXCRDRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 23:17:14 -0400
Received: by nf-out-0910.google.com with SMTP id o25so683668nfa
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2007 20:17:13 -0700 (PDT)
In-Reply-To: <20070318031224.GA17811@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/18/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
>
> Hi David,
>
>         Here is the bugger, it wasn't because {transport,network,mac}_header
> is unsigned after all :-)
>
>         Please consider pulling from the usual place:
>
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
>
>         Please lemme know how longer it takes to crash your workstation, I hope
> not before next century 8-)
>
> - Arnaldo
>
> ---
> In pskb_expand_head and copy_skb_header (used in p?skb_copy(expand)?) the
> difference of two allocations were being applied to
> ->(transport|network|mac)_header, when this is not only not needed but causes
> problems, as those headers are now just offsets from ->head.
>
> This fixes the problem with xfrm (skb_copy_checksum was the first place this

Argh, skb_checksum_help! lemme fix this comment before its too late...

> bug would crash the machine, on the first packet being xfrm'ed), so reenable
> the offset code on 64bit arches.
>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  include/linux/skbuff.h |    4 +---
>  net/core/skbuff.c      |   18 ++++++++++++++----
>  2 files changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 673ca0c..3e4a2bd 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -180,9 +180,7 @@ enum {
>         SKB_GSO_TCPV6 = 1 << 4,
>  };
>
> -/* #if BITS_PER_LONG > 32 */
> -#if 0
> -/* Disabled for now till the ipsec problem is fixed -acme */
> +#if BITS_PER_LONG > 32
>  #define NET_SKBUFF_DATA_USES_OFFSET 1
>  #endif
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5db345a..ea03cbf 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -502,11 +502,12 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
>
>  static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  {
> +#ifndef NET_SKBUFF_DATA_USES_OFFSET
>         /*
>          *      Shift between the two data areas in bytes
>          */
>         unsigned long offset = new->data - old->data;
> -
> +#endif
>         new->sk         = NULL;
>         new->dev        = old->dev;
>         new->priority   = old->priority;
> @@ -515,9 +516,15 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  #ifdef CONFIG_INET
>         new->sp         = secpath_get(old->sp);
>  #endif
> -       new->transport_header = old->transport_header + offset;
> -       new->network_header   = old->network_header + offset;
> -       new->mac_header       = old->mac_header + offset;
> +       new->transport_header = old->transport_header;
> +       new->network_header   = old->network_header;
> +       new->mac_header       = old->mac_header;
> +#ifndef NET_SKBUFF_DATA_USES_OFFSET
> +       /* {transport,network,mac}_header are relative to skb->head */
> +       new->transport_header += offset;
> +       new->network_header   += offset;
> +       new->mac_header       += offset;
> +#endif
>         memcpy(new->cb, old->cb, sizeof(old->cb));
>         new->local_df   = old->local_df;
>         new->fclone     = SKB_FCLONE_UNAVAILABLE;
> @@ -693,9 +700,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>         skb->end      = data + size;
>         skb->data    += off;
>         skb->tail    += off;
> +#ifndef NET_SKBUFF_DATA_USES_OFFSET
> +       /* {transport,network,mac}_header are relative to skb->head */
>         skb->transport_header += off;
>         skb->network_header   += off;
>         skb->mac_header       += off;
> +#endif
>         skb->cloned   = 0;
>         skb->nohdr    = 0;
>         atomic_set(&skb_shinfo(skb)->dataref, 1);
> --
> 1.5.0.3
>
>
