From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Fw:[Bug 70471] xfrm policy node will double unlink.
Date: Tue, 18 Feb 2014 09:37:38 +0100
Message-ID: <20140218083737.GB32371@secunet.com>
References: <tencent_0D7FA5355C7998793C100B23@qq.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Xianpeng Zhao <673321875@qq.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47917 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212AbaBRIhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 03:37:41 -0500
Content-Disposition: inline
In-Reply-To: <tencent_0D7FA5355C7998793C100B23@qq.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 10:55:57AM +0800, Xianpeng Zhao wrote:
> Hi Group,
>      I found a problem about xfrm policy.
> 
>      In corner case, xfrm policy node will be double unlinked from the list.
> 
>     The scenario like this:
>     In thread context, After removed the node from list, before remove the xfrm policy expire timer. At this point, a timer interrupt come, and call the run_timer_softirq to execute the xfrm_policy_timer to remove the expired policy node; because this policy node had already removed from list. this remove will cause the node double unlinked.

Good catch!

I wonder why I've never seen this. Do you have a reproducer for this bug?

Looks like it is sufficient to reinitialize the bydst hlist in
__xfrm_policy_unlink(). Then hlist_unhashed() will notice that
this policy is not linked.

Does the patch below help?


diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 121399d..225f439 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1156,7 +1156,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 	if (hlist_unhashed(&pol->bydst))
 		return NULL;
 
-	hlist_del(&pol->bydst);
+	hlist_del_init(&pol->bydst);
 	hlist_del(&pol->byidx);
 	list_del(&pol->walk.all);
 	net->xfrm.policy_count[dir]--;
