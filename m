From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: (usagi-core 31727) Re: [PATCH][IPSEC][6/7] inter address family
 ipsec tunnel
Date: Mon, 04 Dec 2006 13:26:29 +0900
Message-ID: <4573A375.7010100@miyazawa.org>
References: <20061203.175847.08320724.davem@davemloft.net>	<20061203.182814.74748972.davem@davemloft.net>	<45738CE1.3070304@miyazawa.org> <20061203.191208.74749805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:1166 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1759753AbWLDE1J
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 23:27:09 -0500
To: usagi-core@linux-ipv6.org
In-Reply-To: <20061203.191208.74749805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Mon, 04 Dec 2006 11:50:09 +0900
> 
>> Thank you for your tracing the bug.
>>
>> I understood the issue.
>> Mmm, if we can not use ut->family, can we use
>> ut->id.family instead?
>>
>> Or is it also uninitialized?
> 
> struct xfrm_id does not have a family field
> 
> struct xfrm_id
> {
> 	xfrm_address_t	daddr;
> 	__be32		spi;
> 	__u8		proto;
> };
> 
> That's what ut->id is.
> 
> You're thinking of xfrm_usersa_id, which is used by
> another structure, xfrm_aevent_id.
> 

Sorry I misread.

> For the time being I'm thinking of using the following
> patch.  I removed the xp->family clobbering, the AF_KEY
> changes don't do this, so there is no reason for the
> xfrm_user side to do it either.
> 
> Every path that leads to copy_templates() will perform
> a validate_tmpl() which will change ut->family == 0
> to the policy's family value.  Any other non-supported
> value will trigger an error.
> 
> Let's hope this fix is sufficient.  I'm about to test
> this now.
> 

Thank you very much.

If uninitialized ut->family is AF_INET or AF_INET6 by chance
and the family of outer addresses (ut->saddr) is differnt
ut->family, it results some garbage in the kernel as you know.

I think it does not results any oops or a segmentation fault
because xfrm_address always has enough length (16 bytes) to wrong
access.

 From the point of view of security, the policy has garbege
templates, but the selector is valid and it mangates applying
IPsec. So it result blocking the traffic.
Accordingly, I think it falls down to secure side.

Anyway I will test the patch.

Thank you,

> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 6f97665..311205f 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -858,7 +858,6 @@ static void copy_templates(struct xfrm_p
>  	int i;
>  
>  	xp->xfrm_nr = nr;
> -	xp->family = ut->family;
>  	for (i = 0; i < nr; i++, ut++) {
>  		struct xfrm_tmpl *t = &xp->xfrm_vec[i];
>  
> @@ -876,19 +875,53 @@ static void copy_templates(struct xfrm_p
>  	}
>  }
>  
> +static int validate_tmpl(int nr, struct xfrm_user_tmpl *ut, u16 family)
> +{
> +	int i;
> +
> +	if (nr > XFRM_MAX_DEPTH)
> +		return -EINVAL;
> +
> +	for (i = 0; i < nr; i++) {
> +		/* We never validated the ut->family value, so many
> +		 * applications simply leave it at zero.  The check was
> +		 * never made and ut->family was ignored because all
> +		 * templates could be assumed to have the same family as
> +		 * the policy itself.  Now that we will have ipv4-in-ipv6
> +		 * and ipv6-in-ipv4 tunnels, this is no longer true.
> +		 */
> +		if (!ut[i].family)
> +			ut[i].family = family;
> +
> +		switch (ut[i].family) {
> +		case AF_INET:
> +			break;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +		case AF_INET6:
> +			break;
> +#endif
> +		default:
> +			return -EINVAL;
> +		};
> +	}
> +
> +	return 0;
> +}
> +
>  static int copy_from_user_tmpl(struct xfrm_policy *pol, struct rtattr **xfrma)
>  {
>  	struct rtattr *rt = xfrma[XFRMA_TMPL-1];
> -	struct xfrm_user_tmpl *utmpl;
> -	int nr;
>  
>  	if (!rt) {
>  		pol->xfrm_nr = 0;
>  	} else {
> -		nr = (rt->rta_len - sizeof(*rt)) / sizeof(*utmpl);
> +		struct xfrm_user_tmpl *utmpl = RTA_DATA(rt);
> +		int nr = (rt->rta_len - sizeof(*rt)) / sizeof(*utmpl);
> +		int err;
>  
> -		if (nr > XFRM_MAX_DEPTH)
> -			return -EINVAL;
> +		err = validate_tmpl(nr, utmpl, pol->family);
> +		if (err)
> +			return err;
>  
>  		copy_templates(pol, RTA_DATA(rt), nr);
>  	}
> @@ -1530,7 +1563,8 @@ static int xfrm_add_acquire(struct sk_bu
>  	}
>  
>  	/*   build an XP */
> -	xp = xfrm_policy_construct(&ua->policy, (struct rtattr **) xfrma, &err);        if (!xp) {
> +	xp = xfrm_policy_construct(&ua->policy, (struct rtattr **) xfrma, &err);
> +	if (!xp) {
>  		kfree(x);
>  		return err;
>  	}
> @@ -1979,7 +2013,7 @@ #endif
>  		return NULL;
>  
>  	nr = ((len - sizeof(*p)) / sizeof(*ut));
> -	if (nr > XFRM_MAX_DEPTH)
> +	if (validate_tmpl(nr, ut, p->sel.family))
>  		return NULL;
>  
>  	if (p->dir > XFRM_POLICY_OUT)
> 
> 

