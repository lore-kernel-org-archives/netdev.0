From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: allow to avoid copying DSCP during
 encapsulation
Date: Fri, 22 Feb 2013 07:06:44 +0100
Message-ID: <20130222060644.GH17794@secunet.com>
References: <1361201559-31972-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39814 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908Ab3BVGGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 01:06:47 -0500
Content-Disposition: inline
In-Reply-To: <1361201559-31972-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 04:32:39PM +0100, Nicolas Dichtel wrote:
> By default, DSCP is copying during encapsulation.
> Copying the DSCP in IPsec tunneling may be a bit dangerous because packets with
> different DSCP may get reordered relative to each other in the network and then
> dropped by the remote IPsec GW if the reordering becomes too big compared to the
> replay window.
> 
> It is possible to avoid this copy with netfilter rules, but it's very convenient
> to be able to configure it for each SA directly.
> 
> This patch adds a toogle for this purpose. By default, it's not set to maintain
> backward compatibility.
> 
> Field flags in struct xfrm_usersa_info is full, hence I add a new attribute.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/net/xfrm.h           |  1 +
>  include/uapi/linux/xfrm.h    |  3 +++
>  net/ipv4/xfrm4_mode_tunnel.c |  8 ++++++--
>  net/ipv6/xfrm6_mode_tunnel.c |  7 +++++--
>  net/xfrm/xfrm_user.c         | 13 +++++++++++++
>  5 files changed, 28 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 30f3e5b..c5f12da 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -162,6 +162,7 @@ struct xfrm_state {
>  		xfrm_address_t	saddr;
>  		int		header_len;
>  		int		trailer_len;
> +		u32		extra_flags;
>  	} props;

Please ensure that your new extra_flags are copied whenever needed.
Right now we would loose them when we clone a state with
xfrm_state_clone().

>  
>  	struct xfrm_lifetime_cfg lft;
> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> index 28e493b..f07f422 100644
> --- a/include/uapi/linux/xfrm.h
> +++ b/include/uapi/linux/xfrm.h
> @@ -297,6 +297,7 @@ enum xfrm_attr_type_t {
>  	XFRMA_MARK,		/* struct xfrm_mark */
>  	XFRMA_TFCPAD,		/* __u32 */
>  	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
> +	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
>  	__XFRMA_MAX
>  
>  #define XFRMA_MAX (__XFRMA_MAX - 1)
> @@ -367,6 +368,8 @@ struct xfrm_usersa_info {
>  #define XFRM_STATE_ESN		128
>  };
>  
> +#define XFRM_STATE_EXTRA_FLAGS_DONT_ENCAP_DSCP		1

Can we have a shorter name for this flag, please?
