From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Mon, 8 Jun 2015 09:10:56 -0700
Message-ID: <CALx6S36Tkx42TDjbVyzkL3aKEHbDg8pQXOK9jgE=aFLFmyRt=w@mail.gmail.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35180 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbbFHQK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 12:10:57 -0400
Received: by iesa3 with SMTP id a3so101439493ies.2
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 09:10:56 -0700 (PDT)
In-Reply-To: <1433779259-14328-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2015 at 9:00 AM, Josh Hunt <johunt@akamai.com> wrote:
> UDP encapsulation is broken on IPv6. This is because the logic to resubmit
> the nexthdr is inverted, checking for a ret value > 0 instead of < 0. Also,
> the resubmit label is in the wrong position since we already get the
> nexthdr value when performing decapsulation. In addition the skb pull is no
> longer necessary either.
>
> This changes the return value check to look for < 0, using it for the
> nexthdr on the next iteration, and moves the resubmit label to the proper
> location.
>
> With these changes the v6 code now matches what we do in the v4 ip input
> code wrt resubmitting when decapsulating.
>
Acked-by: "Tom Herbert" <tom@herbertland.com>

> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---
>
> v3: Fix formatting issues found by Sergei Shtylyov
> v2: Use returned nexthdr value
>
>  net/ipv6/ip6_input.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index f2e464e..41a73da 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -212,13 +212,13 @@ static int ip6_input_finish(struct sock *sk, struct sk_buff *skb)
>          */
>
>         rcu_read_lock();
> -resubmit:
>         idev = ip6_dst_idev(skb_dst(skb));
>         if (!pskb_pull(skb, skb_transport_offset(skb)))
>                 goto discard;
>         nhoff = IP6CB(skb)->nhoff;
>         nexthdr = skb_network_header(skb)[nhoff];
>
> +resubmit:
>         raw = raw6_local_deliver(skb, nexthdr);
>         ipprot = rcu_dereference(inet6_protos[nexthdr]);
>         if (ipprot) {
> @@ -246,10 +246,12 @@ resubmit:
>                         goto discard;
>
>                 ret = ipprot->handler(skb);
> -               if (ret > 0)
> +               if (ret < 0) {
> +                       nexthdr = -ret;
>                         goto resubmit;
> -               else if (ret == 0)
> +               } else if (ret == 0) {
>                         IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
> +               }
>         } else {
>                 if (!raw) {
>                         if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
> --
> 1.7.9.5
>
