From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: Fix policy update bug when increasing priority of last policy
Date: Tue, 19 Oct 2004 09:48:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CJhER-0001vk-00@gondolin.me.apana.org.au>
References: <41742C24.6070305@trash.net>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <41742C24.6070305@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> When the last policy for a direction is replaced by a policy
> with equal selector but a higher priority, insertion of the
> new policy fails.

Well spotted, that's two bugs of my creation in one day :)
 
> This patch checks for *p != NULL before continuing the loop.

Unfortunately that doesn't fix it completely.  The real bug is
the fact that we continue with a bogus p pointing to the deleted
element.  So what we should do is continue without updating p
at all.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/xfrm/xfrm_policy.c 1.54 vs edited =====
--- 1.54/net/xfrm/xfrm_policy.c	2004-09-18 08:16:56 +10:00
+++ edited/net/xfrm/xfrm_policy.c	2004-10-19 09:36:47 +10:00
@@ -332,7 +332,7 @@
 	struct xfrm_policy **newpos = NULL;
 
 	write_lock_bh(&xfrm_policy_lock);
-	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
+	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
 		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
@@ -342,8 +342,10 @@
 			delpol = pol;
 			if (policy->priority > pol->priority)
 				continue;
-		} else if (policy->priority >= pol->priority)
+		} else if (policy->priority >= pol->priority) {
+			p = &pol->next;
 			continue;
+		}
 		if (!newpos)
 			newpos = p;
 		if (delpol)
