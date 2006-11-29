From: Li Yewang <lyw@nanjing-fnst.com>
Subject: Re:[PATCH]Fix BUG of ip_rt_send_redirect()
Date: Wed, 29 Nov 2006 16:08:45 +0800
Message-ID: <1164787726.14560.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:52623 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759859AbWLEIUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 03:20:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

> 
>I think there are two problems here:
> 
>1)The first time we hit the check rate_last is zero. We should simply
>proceed with the redirect rather than treating this as a jiffies value.
> 
>2)When a dst is so old that the jiffies have wrapped around.  I'm
>not sure whether this is worth solving as it should be extremely rare
>unless your HZ is sufficiently large and you're on a 32-bit platform.
> 
>One solution would be to periodically reset the rate_last fields to
>their original states.  Perhaps we can combine that with the GC.


Mr Herbert Xu:

According to your advice, I have made another patch for the redirect
bug.

This patch does not think of the jiffies wraparound any more.
Because if the router sends a redirect packet for the first time,
the redirect route cache entry will be created in the route cache.
If this entry is used frequently(This should be extremely rare), 
the rate_last will be update to the current jiffies when it sends 
the redirect packet. So we don't concern about the jiffies wraparound.
If this entry does not be used for a long time, the GC will remove 
it from route cache. Next time if we want to use this entry, 
the redirect entry will be created in the route cache again, and the
rate_last will be initialized to 0. So we don't care of the jiffies
wraparound too.


Following is my patch:

Signed-off-by: Li Yewang <lyw@nanjing-fnst.com>

--- linux-2.6.19/net/ipv4/route.c.org 2006-12-05 10:47:02.402147160
+0800
+++ linux-2.6.19/net/ipv4/route.c 2006-12-05 10:48:26.339386760 +0800
@@ -1327,7 +1327,8 @@ void ip_rt_send_redirect(struct sk_buff 
  /* Check for load limit; set rate_last to the latest sent
   * redirect.
   */
- if (time_after(jiffies,
+ if (rt->u.dst.rate_last == 0 ||
+     time_after(jiffies,
          (rt->u.dst.rate_last +
    (ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
   icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);


To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


