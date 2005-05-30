From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH 2/2] Resend: LSM-IPSec Networking Hooks
Date: Mon, 30 May 2005 03:05:41 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505300239180.25434-100000@thoron.boston.redhat.com>
References: <1116361671.5560.125.camel@dyn9002018177.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <chrisw@osdl.org>, <serue@us.ibm.com>,
        <latten@austin.ibm.com>, <sds@tycho.nsa.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: jaegert <jaegert@us.ibm.com>
In-Reply-To: <1116361671.5560.125.camel@dyn9002018177.watson.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2005, jaegert wrote:

> +#define nethooks_debug(fmt, args...) {if (DEBUG) printk(KERN_NOTICE fmt,## args);}

Why isn't this debugging using KERN_DEBUG?

> +static inline struct inode_security_struct *get_sock_isec(struct sock *sk)
> +{
> +       if (!sk->sk_socket) {
> +               nethooks_debug("%s: no socket on this sock (!?)\n",
> +                              __FUNCTION__);
> +               return (struct inode_security_struct *) NULL;
> +       }

No need to cast NULL here.

> +int selinux_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir)
> +{
> +	int rc = 0;
> +	struct inode_security_struct *isec = NULL;
> +	u32 sock_sid, sel_sid = SECINITSID_UNLABELED;
> +
> +	nethooks_debug("%s: authorize\n", __FUNCTION__);
> +
> +	if (!sk) {
> +                /* no sock to send -- e.g., icmp reply */
> +		/* authorize as kernel packet */
> +		if (fl && fl->proto == IPPROTO_ICMP) {
> +			nethooks_debug("%s: ICMP case\n",
> +				       __FUNCTION__);
> +			sock_sid = SECINITSID_KERNEL;
> +			goto authorize;
> +		}
> +		/*
> +		 * hooks.c accepts packets with no socket unconditionally
> +		 */
> +		nethooks_debug("%s: no sock on this skbuff: non-ICMP\n",
> +			       __FUNCTION__);
> +		goto out;
> +	}

I'm not sure that ICMP is the only protocol which might be caught here;  
are there any other cases where there's no sk that also get caught here?  
The debugging in any case is not all that useful, I'd suggest adding a
protocol number.

> +	read_lock_bh(&sk->sk_callback_lock);

You only need this lock for (dir == FLOW_DIR_IN).

> +static inline int selinux_xfrm_selector_alloc(struct xfrm_selector *sel, struct sadb_x_sec_ctx *sec_ctx)
> +{
> +	int rc = 0;
> +
> +	if (!sec_ctx)
> +		return -EINVAL;

Shouldn't this be a BUG_ON() ?

> +	memcpy(sel->security->ctx_str,
> +	       sec_ctx+1,
> +	       sel->security->ctx_len);

Don't you need to validate that ctx_len is within bounds of the data 
copied from userspace?

> +	rc = security_context_to_sid(sel->security->ctx_str,
> +				     sel->security->ctx_len,
> +				     &sel->security->ctx_sid);
> +	sel->security->ctx_str[sel->security->ctx_len] = 0;

Why null terminate here?  security_context_to_sid() was looking for it 
already, assuming we haven't crashed yet.

> +int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx)
> +{
> +	int rc = 0;
> +
> +	if (!xp)
> +		return -EINVAL;

Another case for BUG_ON().

> +	nethooks_debug(KERN_NOTICE "%s: start alloc\n", __FUNCTION__);
> +
> +	rc = selinux_xfrm_selector_alloc(&xp->selector, sec_ctx);
> +
> +	return rc;
> +}

How about getting rid of rc and just return the value of the last 
function.

> +void selinux_xfrm_policy_free(struct xfrm_policy *xp)
> +{
> +	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
> +
> +	if (xfrm_ctx)
> +		kfree(xfrm_ctx);
> +}

Just call kfree() unconditionally.

> +int selinux_xfrm_state_alloc(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx)
> +{
> +	int rc = 0;
> +
> +	if (!x)
> +		return -EINVAL;

BUG_ON()

> +	rc = selinux_xfrm_selector_alloc(&x->sel, sec_ctx);
> +
> +	return rc;

No need for rc again.

> +void selinux_xfrm_state_free(struct xfrm_state *x)
> +{
> +	struct xfrm_sec_ctx *xfrm_ctx = xfrm_state_security(x);
> +
> +	if (xfrm_ctx)
> +		kfree(xfrm_ctx);
> +}

kfree() again.


(Still reviewing...)


- James
-- 
James Morris
<jmorris@redhat.com>
