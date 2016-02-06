From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 03/10] net: Update remote checksum segmentation
 to support use of GSO checksum
Date: Sat, 6 Feb 2016 12:44:36 -0800
Message-ID: <CALx6S35J9SJp_btTiDBL703BRxNPkYMV0bNdTqRkdafGyHYEHQ@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232743.18529.68800.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36026 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbcBFUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:44:37 -0500
Received: by mail-ig0-f173.google.com with SMTP id xg9so34579272igb.1
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:44:37 -0800 (PST)
In-Reply-To: <20160205232743.18529.68800.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 3:27 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch addresses two main issues.
>
> First in the case of remote checksum offload we were avoiding dealing with
> scatter-gather issues.  As a result it would be possible to assemble a
> series of frames that used frags instead of being linearized as they should
> have if remote checksum offload was enabled.
>
> Second I have updated the code so that we now let GSO take care of doing
> the checksum on the data itself and drop the special case that was added
> for remote checksum offload.
>
Did you test this (with vxlan or GUE)?

> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  net/core/skbuff.c      |   10 ++++++----
>  net/ipv4/udp_offload.c |   22 ++++++++++------------
>  2 files changed, 16 insertions(+), 16 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 02c638a643ea..9c065ac72e87 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3098,8 +3098,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>                 if (nskb->len == len + doffset)
>                         goto perform_csum_check;
>
> -               if (!sg && !nskb->remcsum_offload) {
> -                       nskb->ip_summed = CHECKSUM_NONE;
> +               if (!sg) {
> +                       if (!nskb->remcsum_offload)
> +                               nskb->ip_summed = CHECKSUM_NONE;
>                         SKB_GSO_CB(nskb)->csum =
>                                 skb_copy_and_csum_bits(head_skb, offset,
>                                                        skb_put(nskb, len),
> @@ -3171,8 +3172,9 @@ skip_fraglist:
>                 nskb->truesize += nskb->data_len;
>
>  perform_csum_check:
> -               if (!csum && !nskb->remcsum_offload) {
> -                       nskb->ip_summed = CHECKSUM_NONE;
> +               if (!csum) {
> +                       if (!nskb->remcsum_offload)
> +                               nskb->ip_summed = CHECKSUM_NONE;
>                         SKB_GSO_CB(nskb)->csum =
>                                 skb_checksum(nskb, doffset,
>                                              nskb->len - doffset, 0);
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index ce64c2b7ba55..86687f58d613 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -66,6 +66,16 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>
>         features &= skb->dev->hw_enc_features;
>
> +       /* The only checksum offload we care about from here on out is the
> +        * outer one so strip the existing checksum feature flags and
> +        * instead set the flag based on our outer checksum offload value.
> +        */
> +       if (remcsum) {
> +               features &= ~NETIF_F_CSUM_MASK;
> +               if (offload_csum)
> +                       features |= NETIF_F_HW_CSUM;
> +       }
> +
>         /* segment inner packet. */
>         segs = gso_inner_segment(skb, features);
>         if (IS_ERR_OR_NULL(segs)) {
> @@ -116,18 +126,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                         skb->ip_summed = CHECKSUM_PARTIAL;
>                         skb->csum_start = skb_transport_header(skb) - skb->head;
>                         skb->csum_offset = offsetof(struct udphdr, check);
> -               } else if (remcsum) {
> -                       /* Need to calculate checksum from scratch,
> -                        * inner checksums are never when doing
> -                        * remote_checksum_offload.
> -                        */
> -
> -                       skb->csum = skb_checksum(skb, udp_offset,
> -                                                skb->len - udp_offset,
> -                                                0);
> -                       uh->check = csum_fold(skb->csum);
> -                       if (uh->check == 0)
> -                               uh->check = CSUM_MANGLED_0;
>                 } else {
>                         uh->check = gso_make_checksum(skb, ~uh->check);
>
>
