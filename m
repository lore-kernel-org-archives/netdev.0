From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next 8/8] xfrm: policy: convert policy_lock to
 spinlock
Date: Wed, 24 Aug 2016 13:28:47 +0200
Message-ID: <20160824112847.GP3735@gauss.secunet.com>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <1470921479-25592-9-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:55656 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753057AbcHXL3h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 07:29:37 -0400
Content-Disposition: inline
In-Reply-To: <1470921479-25592-9-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 03:17:59PM +0200, Florian Westphal wrote:
> @@ -972,14 +972,14 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
>  			if (pol->type != type)
>  				continue;
>  			__xfrm_policy_unlink(pol, dir);
> -			write_unlock_bh(&net->xfrm.xfrm_policy_lock);
> +			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
>  			cnt++;
>  
>  			xfrm_audit_policy_delete(pol, 1, task_valid);
>  
>  			xfrm_policy_kill(pol);
>  
> -			write_lock_bh(&net->xfrm.xfrm_policy_lock);
> +			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);

I've just noticed that you accidentally replaced write_lock_bh
with spin_unlock_bh here.

I fixed it up in the ipsec-next testing branch with:

>From 4141b36ab16d7a66b4cf712f2d21eba61c5927e5 Mon Sep 17 00:00:00 2001
From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 24 Aug 2016 13:08:40 +0200
Subject: [PATCH ipsec-next] xfrm: Fix xfrm_policy_lock imbalance

An earlier patch accidentally replaced a write_lock_bh
with a spin_unlock_bh. Fix this by using spin_lock_bh
instead.

Fixes: 9d0380df6217 ("xfrm: policy: convert policy_lock to spinlock")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dd01fd2..f7ce626 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -979,7 +979,7 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 
 			xfrm_policy_kill(pol);
 
-			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
+			spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 			goto again1;
 		}
 
-- 
1.9.1
