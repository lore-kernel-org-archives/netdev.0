From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 2/4] udp offload: allow GRO on 0 checksum packets
Date: Fri, 8 Jul 2016 16:03:15 -0500
Message-ID: <CALx6S377LtT4tFwRaR1K6=+K9npdqxHW8wLgL4AubN65RwKNjg@mail.gmail.com>
References: <cover.1467907022.git.pabeni@redhat.com> <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35865 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbcGHVDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:03:17 -0400
Received: by mail-io0-f194.google.com with SMTP id s93so3462382ioi.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 14:03:16 -0700 (PDT)
In-Reply-To: <60369c715ef9948b088416639f0bec800f632f9a.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 10:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
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

Paolo,

I think you might be misunderstanding the intent of this conditional.
It is trying to deduce that that the inner TCP checksum has likely
been validated or can be validated without doing  packet checksum
calculation. This is trying to avoid doing host side checksum
calculation in the GRO path and really has little to do with rather
uh->check is zero or not. The assumption was that we shouldn't compute
whole packet checksums in the GRO path because of performance. If this
assumption is no longer valid (i.e. there's good data saying doing
checksums in GRO path is a benefit) then all the checksum parts of
this conditional should be removed.

Tom

>                 goto out;
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
> --
> 1.8.3.1
>
