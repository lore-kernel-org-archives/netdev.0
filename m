From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in tcpmss_tg6()
Date: Fri, 15 Jan 2016 08:43:38 -0800
Message-ID: <CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
References: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2016 at 8:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In case MSS option is added in TCP options, skb length increases by 4.
> IPv6 needs to update skb->csum if skb has CHECKSUM_COMPLETE,
> otherwise kernel complains loudly in netdev_rx_csum_fault() with a
> stack dump.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/netfilter/xt_TCPMSS.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
> index b7c43def0dc6..e118397254af 100644
> --- a/net/netfilter/xt_TCPMSS.c
> +++ b/net/netfilter/xt_TCPMSS.c
> @@ -228,7 +228,7 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
>  {
>         struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>         u8 nexthdr;
> -       __be16 frag_off;
> +       __be16 frag_off, oldlen, newlen;
>         int tcphoff;
>         int ret;
>
> @@ -244,7 +244,12 @@ tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
>                 return NF_DROP;
>         if (ret > 0) {
>                 ipv6h = ipv6_hdr(skb);
> -               ipv6h->payload_len = htons(ntohs(ipv6h->payload_len) + ret);
> +               oldlen = ipv6h->payload_len;
> +               newlen = htons(ntohs(oldlen) + ret);
> +               if (skb->ip_summed == CHECKSUM_COMPLETE)
> +                       skb->csum = csum_add(csum_sub(skb->csum, oldlen),
> +                                            newlen);
> +               ipv6h->payload_len = newlen;

Probably should have a utility function do this. Maybe something like
update_hdr_field(skb, old, new)? Could return new value so above could
just be:

ipv6h->payload_len = update_hdr_field(skb, ipv6h->payload_len,
htons(ntohs(oldlen) + ret);

>         }
>         return XT_CONTINUE;
>  }
>
>
