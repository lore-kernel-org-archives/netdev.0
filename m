From: Herbert Xu <herbert.xu@redhat.com>
Subject: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 18:22:51 +1100
Message-ID: <20070110072251.GA27030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4810 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932683AbXAJHXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 02:23:00 -0500
To: "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@redhat.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPSEC] flow: Cache negative security checks

This patch causes security policy denials to be cached instead of
causing a relookup every time.  This is OK because we already cache
positive security policy results which is strictly worse as far as
security is concerned.  In particular, if the security system (not
IPsec policies but the rules under security/) changes such that a
positive result turns negative (denial), we will ignore it and
continue to allow traffic through based on the cached policy.

So if the security folks actually care about this, they'd need to
flush the flow cache whenever a relevant change is made to the
security database.  Whether this is done or not does not affect
this patch.

Given that we do want to cache positive results even in the presence
of SELinux (otherwise we might as well disable flow.c entirely), it
is natural to cache negative results too.

This patch also happens to fix a nasty bug where if an expiring
flow entry that's not at the head happens to trigger a security
denial, all entries before it are removed from the cache and
leaked.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/flow.c b/net/core/flow.c
index d137f97..b0d1777 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -197,12 +197,16 @@ void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
 			if (fle->genid == atomic_read(&flow_cache_genid)) {
 				void *ret = fle->object;
 
-				if (ret)
+				if (fle->object_ref)
 					atomic_inc(fle->object_ref);
 				local_bh_enable();
 
 				return ret;
 			}
+
+			if (fle->object_ref)
+				atomic_dec(fle->object_ref);
+			fle->object_ref = NULL;
 			break;
 		}
 	}
@@ -218,7 +222,7 @@ void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
 			fle->family = family;
 			fle->dir = dir;
 			memcpy(&fle->key, key, sizeof(*key));
-			fle->object = NULL;
+			fle->object_ref = NULL;
 			flow_count(cpu)++;
 		}
 	}
@@ -230,28 +234,20 @@ nocache:
 		atomic_t *obj_ref;
 
 		err = resolver(key, family, dir, &obj, &obj_ref);
+		if (err)
+			obj = ERR_PTR(err);
 
 		if (fle) {
-			if (err) {
-				/* Force security policy check on next lookup */
-				*head = fle->next;
-				flow_entry_kill(cpu, fle);
-			} else {
-				fle->genid = atomic_read(&flow_cache_genid);
+			fle->object = obj;
+			fle->genid = atomic_read(&flow_cache_genid);
 
-				if (fle->object)
-					atomic_dec(fle->object_ref);
-
-				fle->object = obj;
+			if (!err && obj) {
 				fle->object_ref = obj_ref;
-				if (obj)
-					atomic_inc(fle->object_ref);
+				atomic_inc(obj_ref);
 			}
 		}
 		local_bh_enable();
 
-		if (err)
-			obj = ERR_PTR(err);
 		return obj;
 	}
 }
