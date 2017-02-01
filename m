From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 08/15] xfrm: fix possible null deref in xfrm_init_tempstate
Date: Wed, 1 Feb 2017 09:17:50 +0100
Message-ID: <1485937077-612-9-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37068 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751817AbdBAISQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:16 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Dan reports following smatch warning:
 net/xfrm/xfrm_state.c:659
 error: we previously assumed 'afinfo' could be null (see line 651)

 649  struct xfrm_state_afinfo *afinfo = xfrm_state_afinfo_get_rcu(family);
 651  if (afinfo)
		...
 658  }
 659  afinfo->init_temprop(x, tmpl, daddr, saddr);

I am resonably sure afinfo cannot be NULL here.

xfrm_state4.c and state6.c are both part of ipv4/ipv6 (depends on
CONFIG_XFRM, a boolean) but even if ipv6 is a module state6.c can't
be removed (ipv6 lacks module_exit so it cannot be removed).

The only callers for xfrm6_fini that leads to state backend unregister
are error unwinding paths that can be called during ipv6 init function.

So after ipv6 module is loaded successfully the state backend cannot go
away anymore.

The family value from policy lookup path is taken from dst_entry, so
that should always be AF_INET(6).

However, since this silences the warning and avoids readers of this
code wondering about possible null deref it seems preferrable to
be defensive and just add the old check back.

Fixes: 711059b9752ad0 ("xfrm: add and use xfrm_state_afinfo_get_rcu")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a62097e..5a597db 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -648,8 +648,10 @@ void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_afinfo_get_rcu(family);
 
-	if (afinfo)
-		afinfo->init_tempsel(&x->sel, fl);
+	if (!afinfo)
+		return;
+
+	afinfo->init_tempsel(&x->sel, fl);
 
 	if (family != tmpl->encap_family) {
 		afinfo = xfrm_state_afinfo_get_rcu(tmpl->encap_family);
-- 
1.9.1
