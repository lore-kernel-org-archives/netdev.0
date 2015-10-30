From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] xfrm: Fix unaligned access to stats in copy_to_user_state()
Date: Fri, 30 Oct 2015 07:16:27 +0100
Message-ID: <1446185790-24214-3-git-send-email-steffen.klassert@secunet.com>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39787 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758624AbbJ3GQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:42 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>

On sparc, deleting established SAs (e.g., by restarting ipsec)
results in unaligned access messages via xfrm_del_sa ->
km_state_notify -> xfrm_send_state_notify().

Even though struct xfrm_usersa_info is aligned on 8-byte boundaries,
netlink attributes are fundamentally only 4 byte aligned, and this
cannot be changed for nla_data() that is passed up to userspace.
As a result, the put_unaligned() macro needs to be used to
set up potentially unaligned fields such as the xfrm_stats in
copy_to_user_state()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a8de9e3..639e0d5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,6 +31,7 @@
 #if IS_ENABLED(CONFIG_IPV6)
 #include <linux/in6.h>
 #endif
+#include <asm/unaligned.h>
 
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
@@ -728,7 +729,9 @@ static void copy_to_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 	memcpy(&p->sel, &x->sel, sizeof(p->sel));
 	memcpy(&p->lft, &x->lft, sizeof(p->lft));
 	memcpy(&p->curlft, &x->curlft, sizeof(p->curlft));
-	memcpy(&p->stats, &x->stats, sizeof(p->stats));
+	put_unaligned(x->stats.replay_window, &p->stats.replay_window);
+	put_unaligned(x->stats.replay, &p->stats.replay);
+	put_unaligned(x->stats.integrity_failed, &p->stats.integrity_failed);
 	memcpy(&p->saddr, &x->props.saddr, sizeof(p->saddr));
 	p->mode = x->props.mode;
 	p->replay_window = x->props.replay_window;
-- 
1.9.1
