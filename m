From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 07/15] xfrm: state: simplify rcu_read_unlock handling in two spots
Date: Wed, 1 Feb 2017 09:17:49 +0100
Message-ID: <1485937077-612-8-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37088 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751787AbdBAISQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:16 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Instead of:
  if (foo) {
      unlock();
      return bar();
   }
   unlock();
do:
   unlock();
   if (foo)
       return bar();

This is ok because rcu protected structure is only dereferenced before
the conditional.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b5dad89..a62097e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -231,17 +231,18 @@ static const struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 		return NULL;
 	typemap = afinfo->type_map;
 
-	type = typemap[proto];
+	type = READ_ONCE(typemap[proto]);
 	if (unlikely(type && !try_module_get(type->owner)))
 		type = NULL;
+
+	rcu_read_unlock();
+
 	if (!type && !modload_attempted) {
-		rcu_read_unlock();
 		request_module("xfrm-type-%d-%d", family, proto);
 		modload_attempted = 1;
 		goto retry;
 	}
 
-	rcu_read_unlock();
 	return type;
 }
 
@@ -327,17 +328,17 @@ static struct xfrm_mode *xfrm_get_mode(unsigned int encap, int family)
 	if (unlikely(afinfo == NULL))
 		return NULL;
 
-	mode = afinfo->mode_map[encap];
+	mode = READ_ONCE(afinfo->mode_map[encap]);
 	if (unlikely(mode && !try_module_get(mode->owner)))
 		mode = NULL;
+
+	rcu_read_unlock();
 	if (!mode && !modload_attempted) {
-		rcu_read_unlock();
 		request_module("xfrm-mode-%d-%d", family, encap);
 		modload_attempted = 1;
 		goto retry;
 	}
 
-	rcu_read_unlock();
 	return mode;
 }
 
-- 
1.9.1
