From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 2/2] selinux: add gfp argument to security_xfrm_policy_alloc and fix callers
Date: Thu, 06 Mar 2014 22:22:02 -0500
Message-ID: <3932171.ispFyGS1cS@sifl>
References: <20140227151954.GA30946@redhat.com> <1393935984-8733-1-git-send-email-nikolay@redhat.com> <1393935984-8733-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	LSM list <linux-security-module@vger.kernel.org>,
	selinux@tycho.nsa.gov
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:40677 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaCGDWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 22:22:07 -0500
Received: by mail-qa0-f49.google.com with SMTP id cm18so3377227qab.22
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 19:22:05 -0800 (PST)
In-Reply-To: <1393935984-8733-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, March 04, 2014 01:26:24 PM Nikolay Aleksandrov wrote:
> security_xfrm_policy_alloc can be called in atomic context so the
> allocation should be done with GFP_ATOMIC. Add an argument to let the
> callers choose the appropriate way. In order to do so a gfp argument
> needs to be added to the method xfrm_policy_alloc_security in struct
> security_operations and to the internal function
> selinux_xfrm_alloc_user. After that switch to GFP_ATOMIC in the atomic
> callers and leave GFP_KERNEL as before for the rest.
> The path that needed the gfp argument addition is:
> security_xfrm_policy_alloc -> security_ops.xfrm_policy_alloc_security ->
> all users of xfrm_policy_alloc_security (e.g. selinux_xfrm_policy_alloc) ->
> selinux_xfrm_alloc_user (here the allocation used to be GFP_KERNEL only)
> 
> CC: Paul Moore <paul@paul-moore.com>
> CC: Dave Jones <davej@redhat.com>
> CC: Steffen Klassert <steffen.klassert@secunet.com>
> CC: Fan Du <fan.du@windriver.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: LSM list <linux-security-module@vger.kernel.org>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

[NOTE: added the SELinux list to the CC list above]

In general, the patch is pretty simple with the obvious necessary changes, 
just one gotcha, see below.

> diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
> index 0462cb3ff0a7..7ae773f4fe38 100644
> --- a/security/selinux/xfrm.c
> +++ b/security/selinux/xfrm.c
> @@ -78,7 +78,8 @@ static inline int selinux_authorizable_xfrm(struct
> xfrm_state *x) * xfrm_user_sec_ctx context.
>   */
>  static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx **ctxp,
> -				   struct xfrm_user_sec_ctx *uctx)
> +				   struct xfrm_user_sec_ctx *uctx,
> +				   gfp_t gfp)
>  {
>  	int rc;
>  	const struct task_security_struct *tsec = current_security();
> @@ -94,7 +95,7 @@ static int selinux_xfrm_alloc_user(struct xfrm_sec_ctx
> **ctxp, if (str_len >= PAGE_SIZE)
>  		return -ENOMEM;
> 
> -	ctx = kmalloc(sizeof(*ctx) + str_len + 1, GFP_KERNEL);
> +	ctx = kmalloc(sizeof(*ctx) + str_len + 1, gfp);
>  	if (!ctx)
>  		return -ENOMEM;

Also located in selinux_xfrm_alloc_user() is a call to 
security_context_to_sid() which calls security_context_to_sid_core() which in 
some cases does allocate memory.  The good news is that to_sid_core() does 
accept a gfp_t flag, the bad news is that to_sid() always passes GFP_KERNEL.

It looks like we need to extend this patch a bit, or add another.  Sorry about 
that.  If you're getting tired of playing with the LSM/SELinux code let me 
know :)

> @@ -282,9 +283,10 @@ int selinux_xfrm_skb_sid(struct sk_buff *skb, u32 *sid)
> * LSM hook implementation that allocs and transfers uctx spec to
> xfrm_policy. */
>  int selinux_xfrm_policy_alloc(struct xfrm_sec_ctx **ctxp,
> -			      struct xfrm_user_sec_ctx *uctx)
> +			      struct xfrm_user_sec_ctx *uctx,
> +			      gfp_t gfp)
>  {
> -	return selinux_xfrm_alloc_user(ctxp, uctx);
> +	return selinux_xfrm_alloc_user(ctxp, uctx, gfp);
>  }
> 
>  /*
> @@ -332,7 +334,7 @@ int selinux_xfrm_policy_delete(struct xfrm_sec_ctx *ctx)
> int selinux_xfrm_state_alloc(struct xfrm_state *x,
>  			     struct xfrm_user_sec_ctx *uctx)
>  {
> -	return selinux_xfrm_alloc_user(&x->security, uctx);
> +	return selinux_xfrm_alloc_user(&x->security, uctx, GFP_KERNEL);
>  }
> 
>  /*

-- 
paul moore
www.paul-moore.com
