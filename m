From: jamal <hadi@cyberus.ca>
Subject: Re: speaking of stacks
Date: Fri, 04 Apr 2008 08:24:12 -0400
Message-ID: <1207311852.4402.63.camel@localhost>
References: <1206969356.4424.120.camel@localhost>
	 <20080403.141815.218859276.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joern@lazybastard.org,
	herbert@gondor.apana.org.au, Paul Moore <paul.moore@hp.com>,
	James Morris <jmorris@namei.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:51326 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbYDDMYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 08:24:18 -0400
Received: by py-out-1112.google.com with SMTP id u52so40047pyb.10
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2008 05:24:15 -0700 (PDT)
In-Reply-To: <20080403.141815.218859276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-04 at 14:18 -0700, David Miller wrote:

> You probably have most of the security infrastructure turned
> off, therefore GCC can see that 'tmp' is basically unused
> and can therefore be totally eliminated.
> 
> The memset() call makes 'tmp' get passed by reference to
> another function, and thus become used.

Indeed, thanks - that resolves the mystery;->

Testing by moving the tmp memseting inside security_xfrm_policy_alloc()
so memset is only invoked when CONFIG_SECURITY_NETWORK_XFRM resolves the
stack abuse.
BTW, of the top 10 stack abusers _in the kernel_ (should say based on my
config) constitute 3-4 spots which are caused by this exact thing.
I could send a patch that resolves the issue by moving memset but that
would only fix it for people like myself who turn off SELinux.

> This whole song and dance here is for SELINUX to set only
> the policy->security, so that we can pass that back down
> into the subsequent xfrm_policy_bysel_ctx().
> 
> The thing to do is to rearrange these security layer hooks
> so that they take a "struct xfrm_sec_ctx **" instead of
> a full policy pointer.
> 
> Then the code would look like:
> 
> 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
> 		struct xfrm_sec_ctx *ctx;
> 
> 		err = verify_sec_ctx_len(attrs);
> 		if (err)
> 			return err;
> 
> 		if (rt) {
> 			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
> 
> 			if ((err = security_xfrm_policy_alloc(&ctx, uctx)))
> 				return err;
> 		}
> 		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
> 					   delete, &err);
> 		security_xfrm_policy_free(ctx);
> 
> And thus the xfrm_policy wouldn't need to be on the stack
> any longer.

Yes, that would be cleaner than what i did; i will give the opportunity
to the SELinux folks to take a first crack at it with the above
approach. 

CCing some of the SElinux folks. 
Thanks Dave.

cheers,
jamal

