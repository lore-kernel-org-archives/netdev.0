From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] net: af_key: fix sleeping under rcu
Date: Tue, 4 Mar 2014 12:46:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D0092@AcuExch.aculab.com>
References: <20140227151954.GA30946@redhat.com>
 <1393935984-8733-1-git-send-email-nikolay@redhat.com>
 <1393935984-8733-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: 'Nikolay Aleksandrov' <nikolay@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46709 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756757AbaCDMrP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 07:47:15 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25595-07 for <netdev@vger.kernel.org>;
 Tue,  4 Mar 2014 12:47:12 +0000 (GMT)
In-Reply-To: <1393935984-8733-2-git-send-email-nikolay@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov
> There's a kmalloc with GFP_KERNEL in a helper
> (pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
> called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
> a gfp argument and adjust the users.
...
> @@ -3239,7 +3240,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
>  		}
>  		if ((*dir = verify_sec_ctx_len(p)))
>  			goto out;
> -		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
> +		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
>  		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
>  		kfree(uctx);

This looks like the only one that isn't passed GFP_KERNEL.
It looks as though it is missing the check for the allocation failing
(there might be a check inside security_xfrm_policy_alloc()).

In any case it looks as though this ought to be codeable without
the allocation of 'uctx' - since it is freed a line later.

I'd have thought that some of these paths should be allocating
the memory outside the rcu (where they can sleep) and then
possibly freeing the unused data later.

Returning ENOMEM doesn't really seem helpful.

	David
