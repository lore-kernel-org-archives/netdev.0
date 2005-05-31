From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH 1/2] Resend: LSM-IPSec Networking Hooks
Date: Mon, 30 May 2005 20:02:05 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505301940030.27651-100000@thoron.boston.redhat.com>
References: <1116361510.5560.121.camel@dyn9002018177.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <chrisw@osdl.org>, <serue@us.ibm.com>,
        <latten@austin.ibm.com>, <sds@tycho.nsa.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: jaegert <jaegert@us.ibm.com>
In-Reply-To: <1116361510.5560.121.camel@dyn9002018177.watson.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2005, jaegert wrote:

> The pfkey interface is tested using the ipsec-tools.  ipsec-tools have
> been modified (a separate ipsec-tools patch is available for version
> 0.5) that supports assignment of xfrm_policy entries and security
> associations with security contexts via setkey and the negotiation
> using the security contexts via racoon.
> 
> The xfrm_user interface is tested via ad hoc programs that set
> security contexts.  These programs are also available from me, and
> contain programs for setting, getting, and deleting policy for testing
> this interface.  Testing of sa functions was done by tracing kernel
> behavior.

Can you please publish or send me (so I can publish) the ipsec-tools patch 
and these xfrm_user utilities?

>        [SADB_X_EXT_NAT_T_OA]           = (u8) sizeof(struct sadb_address),
> +        [SADB_X_EXT_SEC_CTX]            = (u8) sizeof(struct sadb_x_sec_ctx),
> };

Indenting.


>  		if (km_query(x, tmpl, pol) == 0) {
> +			if (!xfrm_sec_ctx_match(xfrm_policy_security(pol), xfrm_state_security(x))) {
> +				x->km.state = XFRM_STATE_DEAD;
> +				xfrm_state_put(x);
> +				x = NULL;
> +				error = 1;
> +				goto out;
> +			}

Why set error to 1 here?  This should be an -E value.


> +               if (security_xfrm_policy_clone(old, newp)) {
> +                       kfree(newp);
> +                       return (struct xfrm_policy *)NULL;  /* ENOMEM */
> +               }

Don't cast NULL.


> +static inline int xfrm_user_sec_ctx_size(struct xfrm_policy *xp)
> +{
> +	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
> +	int len;
> +
> +	if (xfrm_ctx) {
> +		len = sizeof(struct xfrm_user_sec_ctx);
> +		len += xfrm_ctx->ctx_len;
> +		return len;
> +	}
> +	return 0;
> +}

This can be simplified with a single return path, initialize len to zero.


> +static int attach_sec_ctx(struct xfrm_state *x, struct rtattr *u_arg)
> +{
> +	struct xfrm_user_sec_ctx *uxsc = RTA_DATA(u_arg);
> +
> +	if (uxsc) {
> +		security_xfrm_state_free(x);
> +		return security_xfrm_state_alloc(x, uxsc);
> +	}
> +
> +	return 0;
> +}

The security_xfrm_state_free() seems unecesary and buggy if needed.  This
is called in state allocation context, i.e. just afer xfrm_state_alloc() 
and there should be no already allocate security state.


> +static int copy_sec_ctx(struct xfrm_policy *pol, struct xfrm_user_sec_ctx *uctx)
> +{
> +	int err = 0;
> +
> +	security_xfrm_policy_free(pol);
> +	err = security_xfrm_policy_alloc(pol, uctx);
> +	return err;
> +}

Again, why free just before allocation?  This code is only being called in 
policy allocation context and freeing like this would be buggy in any 
case.


> +static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **xfrma)
> +{
> +	struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
> +	struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
> +
> +	if (uctx) {
> +		copy_sec_ctx(pol, uctx);
> +	}
> +
> +	return 0;
> +}

If it always returns zero, make it a void function.


> +                 /* spi must be zero'd unless real tmpl */
> + 		for (tmpl = ut; tmpl->id.spi != 0; tmpl = tmpl + 1)

Indenting.


> + 	else {
> + 		uctx = (struct xfrm_user_sec_ctx *) NULL;
>  	nr = ((len - sizeof(*p)) / sizeof(*ut));
>  	if (nr > XFRM_MAX_DEPTH)
>  		return NULL;
> + 	}

Indenting.


> +	if (uctx)
> +		copy_sec_ctx(xp, uctx);

Why not just make copy_sec_ctx() check for uctx itself, so the calling 
code can be cleaner?


>  	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
>  	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
> +	len += xfrm_user_sec_ctx_size(xp);
>  	skb = alloc_skb(len, GFP_ATOMIC);

This looks wrong, the length is not aligned properly.  NLMSG_SPACE needs 
to enclose the xfrm_user_sec_ctx_size() as well.  (There's another one of 
these further down).



- James
-- 
James Morris
<jmorris@redhat.com>
