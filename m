From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 04/11] net: Create and use new helper
 xfrm_dst_child().
Date: Tue, 31 Oct 2017 11:39:22 -0700
Message-ID: <1509475162.3828.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-5-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:50507 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdJaSjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:39:24 -0400
Received: by mail-io0-f194.google.com with SMTP id 97so909137iok.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:39:24 -0700 (PDT)
In-Reply-To: <20171031141054.9954-5-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> Only IPSEC routes have a non-NULL dst->child pointer.  And IPSEC
> routes are identified by a non-NULL dst->xfrm pointer.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/xfrm.h           |  9 +++++++++
>  net/core/dst.c               |  8 +++++---
>  net/ipv4/xfrm4_mode_tunnel.c |  2 +-
>  net/ipv6/xfrm6_mode_tunnel.c |  2 +-
>  net/ipv6/xfrm6_policy.c      |  2 +-
>  net/xfrm/xfrm_output.c       |  2 +-
>  net/xfrm/xfrm_policy.c       | 12 ++++++------
>  security/selinux/xfrm.c      |  2 +-
>  8 files changed, 25 insertions(+), 14 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index f002a2c5e33c..be599f9bb60d 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -993,6 +993,15 @@ struct xfrm_dst {
>  	u32 path_cookie;
>  };
>  
> +static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
> +{
> +#ifdef CONFIG_XFRM
> +	if (dst->xfrm)
> +		return dst->child;
> +#endif
> +	return NULL;
> +}
> +
>  #ifdef CONFIG_XFRM
>  static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
>  {
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 662a2d4a3d19..6a3c21b8fc8d 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -116,12 +116,14 @@ EXPORT_SYMBOL(dst_alloc);
>  
>  struct dst_entry *dst_destroy(struct dst_entry * dst)
>  {
> -	struct dst_entry *child;
> +	struct dst_entry *child = NULL;
>  
>  	smp_rmb();
>  
> -	child = dst->child;
> -
> +#ifdef CONFIG_XFRM
> +	if (dst->xfrm)
> +		child = dst->child;
> +#endif


Why not using here :

	child = xfrm_dst_child(dst);

This avoid the #ifdef and uses the new helper quite well.
