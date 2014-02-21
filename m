From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Fw:[Bug 70471] xfrm policy node will double unlink.
Date: Fri, 21 Feb 2014 08:35:30 +0100
Message-ID: <20140221073530.GH32371@secunet.com>
References: <tencent_0D7FA5355C7998793C100B23@qq.com>
 <20140218083737.GB32371@secunet.com>
 <tencent_4CE06FA903D8DCB54F951A30@qq.com>
 <20140219114326.GE32371@secunet.com>
 <tencent_0260B87B11A1005909F5BB41@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Xianpeng Zhao <673321875@qq.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42018 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaBUHfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 02:35:34 -0500
Content-Disposition: inline
In-Reply-To: <tencent_0260B87B11A1005909F5BB41@qq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 10:01:19AM +0800, Xianpeng Zhao wrote:
> Sorry, I misunderstood your means in last mail.
>     I get your patch now. Later I will use your patch. 
> 

The patch below is what I plan to commit to the ipsec tree,
please test it. Thanks!

Subject: [PATCH] xfrm: Fix unlink race when policies are deleted.

When a policy is unlinked from the lists in thread context,
the xfrm timer can fire before we can mark this policy as dead.
So reinitialize the bydst hlist, then hlist_unhashed() will
notice that this policy is not linked and will avoid a
doulble unlink of that policy.

Reported-by: Xianpeng Zhao <673321875@qq.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4b98b25..1d5c7bf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1158,7 +1158,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 	if (hlist_unhashed(&pol->bydst))
 		return NULL;
 
-	hlist_del(&pol->bydst);
+	hlist_del_init(&pol->bydst);
 	hlist_del(&pol->byidx);
 	list_del(&pol->walk.all);
 	net->xfrm.policy_count[dir]--;
-- 
1.7.9.5
