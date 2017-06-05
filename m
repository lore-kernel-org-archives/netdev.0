From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] net/ipv6: Fix CALIPSO causing GPF with datagram support
Date: Mon, 5 Jun 2017 11:55:34 -0400
Message-ID: <CAHC9VhRwzC=XTRj5gNfd11T=XzpYSrVfu-jnx9f4__duMAji1Q@mail.gmail.com>
References: <20170605154440.2434-1-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
To: Richard Haines <richard_c_haines@btinternet.com>,
        netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170605154440.2434-1-richard_c_haines@btinternet.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 5, 2017 at 11:44 AM, Richard Haines
<richard_c_haines@btinternet.com> wrote:
> When using CALIPSO with IPPROTO_UDP it is possible to trigger a GPF as the
> IP header may have moved.
>
> Also update the payload length after adding the CALIPSO option.
>
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
> ---
>  net/ipv6/calipso.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

Acked-by: Paul Moore <paul@paul-moore.com>

Thanks Richard.  DaveM, I assume you'll be pulling this into your tree?

> diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> index 37ac9de..8d772fe 100644
> --- a/net/ipv6/calipso.c
> +++ b/net/ipv6/calipso.c
> @@ -1319,7 +1319,7 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
>         struct ipv6hdr *ip6_hdr;
>         struct ipv6_opt_hdr *hop;
>         unsigned char buf[CALIPSO_MAX_BUFFER];
> -       int len_delta, new_end, pad;
> +       int len_delta, new_end, pad, payload;
>         unsigned int start, end;
>
>         ip6_hdr = ipv6_hdr(skb);
> @@ -1346,6 +1346,8 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
>         if (ret_val < 0)
>                 return ret_val;
>
> +       ip6_hdr = ipv6_hdr(skb); /* Reset as skb_cow() may have moved it */
> +
>         if (len_delta) {
>                 if (len_delta > 0)
>                         skb_push(skb, len_delta);
> @@ -1355,6 +1357,8 @@ static int calipso_skbuff_setattr(struct sk_buff *skb,
>                         sizeof(*ip6_hdr) + start);
>                 skb_reset_network_header(skb);
>                 ip6_hdr = ipv6_hdr(skb);
> +               payload = ntohs(ip6_hdr->payload_len);
> +               ip6_hdr->payload_len = htons(payload + len_delta);
>         }
>
>         hop = (struct ipv6_opt_hdr *)(ip6_hdr + 1);
> --
> 2.9.4
>



-- 
paul moore
www.paul-moore.com
