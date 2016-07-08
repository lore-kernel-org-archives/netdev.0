From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum packets
Date: Fri, 8 Jul 2016 09:46:33 -0700
Message-ID: <CAKgT0UeONTtXw2SeVr7Zm_AZT50xqeFhLE8mTOAicabsifMLXQ@mail.gmail.com>
References: <cover.1467907022.git.pabeni@redhat.com> <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36584 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbcGHQqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:46:36 -0400
Received: by mail-it0-f67.google.com with SMTP id h190so5640221ith.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:46:35 -0700 (PDT)
In-Reply-To: <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> currently, UDP packets with zero checksum are not allowed to
> use udp offload's GRO. This patch admits such packets to
> GRO, if the related socket settings allow it: ipv6 packets
> are not admitted if the sockets don't have the no_check6_rx
> flag set.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/udp_offload.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 9c37338..ac783f4 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -257,7 +257,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>         struct sock *sk;
>
>         if (NAPI_GRO_CB(skb)->encap_mark ||
> -           (skb->ip_summed != CHECKSUM_PARTIAL &&
> +           (uh->check && skb->ip_summed != CHECKSUM_PARTIAL &&
>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>              !NAPI_GRO_CB(skb)->csum_valid))
>                 goto out;

So now all zero checksum UDP traffic will be targeted for GRO if I am
understanding this right.  Have you looked into how much of an impact
this might have on performance for non-tunnel UDP traffic using a zero
checksum?  I'm thinking it will be negative.  The issue is you are now
going to be performing an extra socket lookup for all incoming UDP
frames that have a zero checksum.

Also in the line below this line we are setting the encap_mark.  That
will probably need to be moved down to the point just before we call
gro_receive so that we can avoid setting unneeded data in the
NAPI_GRO_CB.

> @@ -271,6 +271,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
>         if (!sk || !udp_sk(sk)->gro_receive)
>                 goto out_unlock;
>
> +       if (!uh->check && skb->protocol == cpu_to_be16(ETH_P_IPV6) &&
> +           !udp_sk(sk)->no_check6_rx)
> +               goto out_unlock;
> +
>         flush = 0;
>
>         for (p = *head; p; p = p->next) {

So I am pretty sure this check doesn't pass the sniff test.
Specifically I don't believe you can use skb->protocol like you
currently are as it could be an 8021q frame for instance that is being
aggregated so the skb->protocol would be invalid.  I think what you
should probably be using is NAPI_GRO_CB(skb)->is_ipv6 although it
occurs to me that in the case of tunnels I don't know if that value is
being reset for IPv4 like it should be.

- Alex
