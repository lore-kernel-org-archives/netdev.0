From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 5/6] xfrm: state: simplify rcu_read_unlock handling in two spots
Date: Mon,  9 Jan 2017 14:20:49 +0100
Message-ID: <1483968050-788-6-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48776 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761579AbdAINUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:48 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ee1309e2b8b5..0245df063bd7 100644
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
2.7.3
