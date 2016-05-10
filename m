From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2] ila: ipv6/ila: fix nlsize calculation for lwtunnel
Date: Tue, 10 May 2016 08:51:48 -0700
Message-ID: <CALx6S36BhZqZ8ovn5ESWhKU7S7RQCwaPPBwBFeFxiEh2F-SNrg@mail.gmail.com>
References: <20160501.193926.994161705403597197.davem@davemloft.net>
	<1462874192-8360-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33073 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbcEJPvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 11:51:50 -0400
Received: by mail-ig0-f172.google.com with SMTP id c3so20007305igl.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 08:51:49 -0700 (PDT)
In-Reply-To: <1462874192-8360-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 2:56 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> From: Tom Herbert <tom@herbertland.com>
>
> The handler 'ila_fill_encap_info' adds two attributes: ILA_ATTR_LOCATOR
> and ILA_ATTR_CSUM_MODE.
>
> nla_total_size_64bit() must be use for ILA_ATTR_LOCATOR.
>
> Also, do nla_put_u8 instead of nla_put_u64 for ILA_ATTR_CSUM_MODE.
>
> Fixes: f13a82d87b21 ("ipv6: use nla_put_u64_64bit()")
> Fixes: 90bfe662db13 ("ila: add checksum neutral ILA translations")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>
> Tom, I have taken the liberty of resending your patch, I hope it's ok
> for you. Goal is to fix this before net-next closes.
>
> v1 -> v2:
>   update the patch after the merge of net (and thus update 'Fixes' tag)
>   use nla_total_size_64bit() for ILA_ATTR_LOCATOR
>
>  net/ipv6/ila/ila_lwt.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
> index 17038e1ede98..1dfb64166d7d 100644
> --- a/net/ipv6/ila/ila_lwt.c
> +++ b/net/ipv6/ila/ila_lwt.c
> @@ -133,7 +133,7 @@ static int ila_fill_encap_info(struct sk_buff *skb,
>         if (nla_put_u64_64bit(skb, ILA_ATTR_LOCATOR, (__force u64)p->locator.v64,
>                               ILA_ATTR_PAD))
>                 goto nla_put_failure;
> -       if (nla_put_u64(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
> +       if (nla_put_u8(skb, ILA_ATTR_CSUM_MODE, (__force u8)p->csum_mode))
>                 goto nla_put_failure;
>
>         return 0;
> @@ -144,7 +144,9 @@ nla_put_failure:
>
>  static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
>  {
> -       return nla_total_size(sizeof(u64)); /* ILA_ATTR_LOCATOR */
> +       return nla_total_size_64bit(sizeof(u64)) + /* ILA_ATTR_LOCATOR */
> +              nla_total_size(sizeof(u8)) +        /* ILA_ATTR_CSUM_MODE */
> +              0;
>  }
>
>  static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
> --
> 2.8.1
>

Acked-by: Tom Herbert <tom@herbertland.com>
