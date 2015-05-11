From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix a possible policy leak
Date: Mon, 11 May 2015 13:03:13 +0200
Message-ID: <20150511110310.GR8928@secunet.com>
References: <1431077979-1606-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <eparis@redhat.com>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60249 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753618AbbEKLDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 07:03:20 -0400
Content-Disposition: inline
In-Reply-To: <1431077979-1606-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2015 at 05:39:39PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> policy should be put if exit xfrm_policy_bysel_ctx() due to the
> failure of calling security_xfrm_policy_delete. since policy has
> been hold before
> 
> Fixes: ef41aaa0b7 [IPSEC]: xfrm_policy delete security check misplaced
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: Eric Paris <eparis@redhat.com>
> ---
>  net/xfrm/xfrm_policy.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 3d264e5..66450c3 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -824,6 +824,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
>  				*err = security_xfrm_policy_delete(
>  								pol->security);
>  				if (*err) {
> +					xfrm_pol_put(pol);
>  					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
>  					return pol;
>  				}
> @@ -863,6 +864,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
>  				*err = security_xfrm_policy_delete(
>  								pol->security);
>  				if (*err) {
> +					xfrm_pol_put(pol);
>  					write_unlock_bh(&net->xfrm.xfrm_policy_lock);
>  					return pol;
>  				}

We return this policy to the caller, so we better keep
the refcount here. The caller is responsible to drop
the refount.
