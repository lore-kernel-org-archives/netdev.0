From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Thu, 11 Jan 2007 10:27:13 +1100
Message-ID: <20070110232713.GA13180@gondor.apana.org.au>
References: <20070110204922.GA1652@gondor.apana.org.au> <001601c734fb$89ed3b90$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'James Morris' <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3419 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965244AbXAJX1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 18:27:23 -0500
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
Content-Disposition: inline
In-Reply-To: <001601c734fb$89ed3b90$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 03:08:55PM -0600, Venkat Yekkirala wrote:
> 
> I was talking about this (the latter) as well. Currently, on a proper
> "negative", -ESRCH is returned by security_xfrm_policy_lookup(), and
> this comes back up as a 0 from resolver(), correctly indicating NO
> applicable
> xfrm policy (after taking security into account). But if
> security_xfrm_policy_lookup()
> were to return anything other than a zero or -ESRCH, such as -ENOMEM,
> you will see it come back up as such (as -ENOMEM) from resolver(),
> and in this case, it's neither a positive nor a negative, just an error.
> Hence a full lookup would be in order, the next time round.

OK, I see that now.  The EACCES error is translated to ESRCH in
the security layer.

> Also, I would fix the other bug you had noted, by something like:

I agree.

[IPSEC] flow: Fix potential memory leak

When old flow cache entries that are not at the head of their chain
trigger a transient security error they get unlinked along with all
the entries preceding them in the chain.  The preceding entries are
not freed correctly.

This patch fixes this by simply leaving the entry around.  It's based
on a suggestion by Venkat Yekkirala.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 
> I am planning to test and submit a patch to SELinux
> to invoke flow_cache_flush() on policy reloads tomorrow.

flow_cache_flush() shouldn't be used by SELinux.  You probably
want to increase the genid instead.

BTW, we should probably add some code to deal with overflows in
genid.  With the recent improvements in policy update speeds, it
could be conceivable for an overflow to occur.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/flow.c b/net/core/flow.c
index d137f97..5d25697 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -231,22 +231,16 @@ nocache:
 
 		err = resolver(key, family, dir, &obj, &obj_ref);
 
-		if (fle) {
-			if (err) {
-				/* Force security policy check on next lookup */
-				*head = fle->next;
-				flow_entry_kill(cpu, fle);
-			} else {
-				fle->genid = atomic_read(&flow_cache_genid);
-
-				if (fle->object)
-					atomic_dec(fle->object_ref);
-
-				fle->object = obj;
-				fle->object_ref = obj_ref;
-				if (obj)
-					atomic_inc(fle->object_ref);
-			}
+		if (fle && !err) {
+			fle->genid = atomic_read(&flow_cache_genid);
+
+			if (fle->object)
+				atomic_dec(fle->object_ref);
+
+			fle->object = obj;
+			fle->object_ref = obj_ref;
+			if (obj)
+				atomic_inc(fle->object_ref);
 		}
 		local_bh_enable();
 
