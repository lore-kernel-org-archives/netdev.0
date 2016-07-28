From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 1/1] xfrm: dst lookup doesn't account for fwmark
Date: Thu, 28 Jul 2016 07:31:47 +0200
Message-ID: <20160728053147.GL5710@gauss.secunet.com>
References: <CACwzwmXYUhHdzGLoi73enk-5CCECkdDjJDsOeYHKswqwa9AzyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Doug Applegate <doug.applegate@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34072 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368AbcG1Fbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 01:31:51 -0400
Content-Disposition: inline
In-Reply-To: <CACwzwmXYUhHdzGLoi73enk-5CCECkdDjJDsOeYHKswqwa9AzyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 03:50:43PM -0600, Doug Applegate wrote:
> If route table includes routing based on fwmark, xfrm will not take it
> into account when routing ipsec traffic. We address this issue by adding
> fwmark information before calling route lookup.
> 
> Signed-off-by: Doug Applegate <doug.applegate@gmail.com>
> ---
>  include/net/xfrm.h      |  3 ++-
>  net/ipv4/xfrm4_policy.c | 15 +++++++++++----
>  net/ipv6/xfrm6_policy.c | 11 +++++++++--
>  net/xfrm/xfrm_policy.c  | 28 +++++++++++++++++++++++-----
>  4 files changed, 45 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index adfebd6..13e80d1 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -282,7 +282,7 @@ struct xfrm_policy_afinfo {
>   struct dst_ops *dst_ops;
>   void (*garbage_collect)(struct net *net);
>   struct dst_entry *(*dst_lookup)(struct net *net,
> -       int tos, int oif,
> +       int tos, int oif, int mark,
>         const xfrm_address_t *saddr,
>         const xfrm_address_t *daddr);
>   int (*get_saddr)(struct net *net, int oif,
> @@ -292,6 +292,7 @@ struct xfrm_policy_afinfo {
>    struct flowi *fl,
>    int reverse);
>   int (*get_tos)(const struct flowi *fl);
> + int (*get_mark)(const struct flowi *fl);
>   int (*init_path)(struct xfrm_dst *path,
>       struct dst_entry *dst,
>       int nfheader_len);
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index 7b0edb3..5dcd411 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -20,7 +20,7 @@
>  static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
> 
>  static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct
> flowi4 *fl4,
> -    int tos, int oif,
> +    int tos, int oif, int mark,
>      const xfrm_address_t *saddr,
>      const xfrm_address_t *daddr)
>  {
> @@ -30,6 +30,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
> net *net, struct flowi4 *fl4,
>   fl4->daddr = daddr->a4;
>   fl4->flowi4_tos = tos;
>   fl4->flowi4_oif = oif;
> + fl4->flowi4_mark = mark;
>   if (saddr)
>   fl4->saddr = saddr->a4;
> 
> @@ -42,13 +43,13 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
> net *net, struct flowi4 *fl4,
>   return ERR_CAST(rt);
>  }
> 
> -static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos, int oif,
> +static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
> int oif, int mark,
>    const xfrm_address_t *saddr,
>    const xfrm_address_t *daddr)

We may consider to setup the flowi earlier instead of adding yet another
parameter to this function. This would have also the advantage that we
don't need to change that function whenever we find out that we need
more flow informations.
